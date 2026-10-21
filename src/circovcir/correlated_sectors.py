"""Exact support certificates retaining rank correlations in center angles.

LP solves only propose sparse nonnegative duals. Replay checks exact normals and
right-hand sides against the ORIGINAL rank polytope, never a float LP status.
"""
from __future__ import annotations

from fractions import Fraction as Q
from math import ceil, floor

import numpy as np
from scipy.optimize import linprog

from .ordered_arcs import (
    _iv,
    constants,
    endpoints,
    ordered_polar_bounds,
    radial_order_floors,
)
from .rank_duals import rank_planes


def angle_coefficients(j):
    """theta_j = 2*j*a - D*(co.x), with zero-based center labels."""
    if type(j) is not int or not 1 <= j <= 8:
        raise ValueError("non-anchor index must be 1..8")
    co = [Q(0)]*18
    co[0] = co[j] = Q(1)
    for i in range(1, j):
        co[i] = Q(2)
    for i in range(j):
        co[9+i] = Q(2)
    return co


def support_check(planes, coefficients, certificate):
    """Replay co.x in [lo,hi]; no numerical optimization in acceptance."""
    try:
        if set(certificate) != {"range", "duals"}:
            return False
        co = list(map(Q, coefficients))
        bounds = list(map(Q, certificate["range"]))
        if len(bounds) != 2 or bounds[0] > bounds[1] or len(certificate["duals"]) != 2:
            return False
        for side, sign in enumerate((1, -1)):
            lhs, rhs = [Q(0)]*len(co), Q(0)
            for index, weight in certificate["duals"][side]:
                weight = Q(weight)
                if type(index) is not int or not 0 <= index < len(planes) or weight < 0:
                    return False
                row, constant = planes[index]
                lhs = [a+weight*Q(b) for a, b in zip(lhs, row, strict=True)]
                rhs += weight*Q(constant)
            if lhs != [sign*x for x in co] or rhs < sign*bounds[side]:
                return False
        return True
    except (ValueError, TypeError, KeyError, IndexError, ArithmeticError):
        return False


def propose_support(planes, coefficients):
    """A rational dual bound remains valid even if the float optimum is wrong."""
    co = list(map(Q, coefficients))
    matrix = -np.array([row for row, _ in planes], float)
    rhs = -np.array([b for _, b in planes], float)
    ranges, duals = [], []
    for sign in (1, -1):
        solve = linprog(sign*np.array(co, float), A_ub=matrix, b_ub=rhs,
                        bounds=[(None, None)]*len(co), method="highs")
        if not solve.success:
            return None
        dual = [[i, str(Q(float(-v)).limit_denominator(10**6))]
                for i, v in enumerate(solve.ineqlin.marginals) if v < -1e-10]
        bound = sign*sum(Q(weight)*planes[i][1] for i, weight in dual)
        ranges.append(bound)
        duals.append(dual)
    cert = {"range": ranges, "duals": duals}
    return cert if support_check(planes, co, cert) else None


def outward(pair, digits=24):
    scale = 10**digits
    return (Q(floor(pair[0]*scale), scale), Q(ceil(pair[1]*scale), scale))


def _angle_range(radius, j, mass, *, dps=60):
    ctx, _, a, _ = constants(radius, dps=dps)
    lo, hi = map(Q, mass)
    if lo > hi:
        raise ValueError("inverted mass interval")
    values = [endpoints((2*j-9*_iv(ctx, m))*_iv(ctx, av)+ctx.pi*_iv(ctx, m))
              for av in endpoints(a) for m in (lo, hi)]
    return min(v[0] for v in values), max(v[1] for v in values)


def correlated_polar(radius, bounds, masses, *, dps=60):
    """Use independently CERTIFIED angle masses instead of their box relaxation.

    Caller must certify all supplied bounds/masses on its parameter domain.
    This routine computes the image enclosure, not that domain implication.
    """
    if len(masses) != 8:
        raise ValueError("expected eight angular support intervals")
    polar = list(ordered_polar_bounds(radius, bounds, dps=dps))
    for j, mass in enumerate(masses, 1):
        # Bilinear in (a,m): extrema at rectangle vertices. Avoid duplicating
        # the radius uncertainty in a and D=9*a-pi.
        angle = _angle_range(radius, j, mass, dps=dps)
        old = polar[j][1]
        polar[j] = (polar[j][0], (max(old[0], angle[0]), min(old[1], angle[1])))
    return tuple(polar)


def propose_correlated_domain(radius, rank):
    """All 18 coordinate supports and 8 angular supports of a full rank root."""
    floors = tuple(Q(floor(x*10**30), 10**30) for x in radial_order_floors(radius))
    planes = rank_planes(floors, rank)
    supports = []
    costs = [[Q(i == j) for i in range(18)] for j in range(18)]
    costs += [angle_coefficients(j) for j in range(1, 9)]
    for co in costs:
        cert = propose_support(planes, co)
        if cert is None:
            return None
        cert["range"] = outward(cert["range"])
        supports.append(cert)
    bounds = [s["range"] for s in supports[:18]]
    masses = [s["range"] for s in supports[18:]]
    polar = [[outward(p) for p in s] for s in correlated_polar(radius, bounds, masses)]
    return {"rank": rank, "floors": floors, "supports": supports, "polar": polar}


def check_correlated_domain(radius, certificate):
    """Return certified polar sectors, or None on any failed domain implication."""
    try:
        floors = tuple(map(Q, certificate["floors"]))
        if len(floors) != 3 or any(f < 0 or f > c for f, c in zip(
                floors, radial_order_floors(radius), strict=True)):
            return None
        planes = rank_planes(floors, certificate["rank"])
        costs = [[Q(i == j) for i in range(18)] for j in range(18)]
        costs += [angle_coefficients(j) for j in range(1, 9)]
        if len(certificate["supports"]) != len(costs):
            return None
        for co, support in zip(costs, certificate["supports"], strict=True):
            if not support_check(planes, co, support):
                return None
        bounds = [s["range"] for s in certificate["supports"][:18]]
        masses = [s["range"] for s in certificate["supports"][18:]]
        computed = correlated_polar(radius, bounds, masses)
        polar = tuple(tuple(tuple(map(Q, p)) for p in s) for s in certificate["polar"])
        if len(polar) != 9 or any(len(s) != 2 or any(len(p) != 2 for p in s) for s in polar):
            return None
        if any(not p[0] <= c[0] <= c[1] <= p[1] for s, t in zip(polar, computed, strict=True)
               for p, c in zip(s, t, strict=True)):
            return None
        return polar
    except (ValueError, TypeError, KeyError, IndexError, ArithmeticError):
        return None
