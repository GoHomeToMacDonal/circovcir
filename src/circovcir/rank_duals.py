"""Exact LP dual certificates for root rank-domain coordinate contractions.

SciPy only PROPOSES a sparse dual. Normals, nonnegative weights and bound signs
are checked with Fractions. No numerical LP status or objective is a certificate.
"""
from __future__ import annotations

from fractions import Fraction as Q

import numpy as np
from scipy.optimize import linprog

from .b9_rank import checked_rank, rank_edges
from .ordered_arcs import radial_order_floors


def rank_planes(floors, rank):
    """A.x>=b for x>=0, sum(x)=1, specified order and three deficit floors."""
    i, j = checked_rank(rank)
    planes = []
    for k in range(18):
        row = [Q(0)]*18
        row[k] = Q(1)
        planes.append((row, Q(0)))
    planes += [([Q(1)]*18, Q(1)), ([Q(-1)]*18, Q(-1))]
    for a, b in rank_edges(rank):
        row = [Q(0)]*18
        row[a], row[b] = Q(1), Q(-1)
        planes.append((row, Q(0)))
    for k, floor in zip((0, i, j), floors, strict=True):
        row = [Q(0)]*18
        row[k] = Q(1)
        planes.append((row, Q(floor)))
    return planes


def check_rank_duals(floors, rank, bounds, duals):
    try:
        planes = rank_planes(floors, rank)
        if len(bounds) != 18 or len(duals) != 36:
            return False
        if any(Q(lo) > Q(hi) for lo, hi in bounds):
            return False
        for n, dual in enumerate(duals):
            k, side = divmod(n, 2)
            sign = 1 if side == 0 else -1
            lhs, rhs = [Q(0)]*18, Q(0)
            for index, weight in dual:
                if type(index) is not int or not 0 <= index < len(planes) or Q(weight) < 0:
                    return False
                row, constant = planes[index]
                lhs = [a+Q(weight)*b for a, b in zip(lhs, row, strict=True)]
                rhs += Q(weight)*constant
            if lhs != [Q(sign) if axis == k else Q(0) for axis in range(18)]:
                return False
            if rhs < sign*Q(bounds[k][side]):
                return False
        return True
    except (TypeError, ValueError, IndexError, ZeroDivisionError):
        return False


def replay_rank_cover_payload(payload):
    """Independent of the rank contractor: exact duals plus sector leaf replay.

    Returns True only for the complete interval range and all 56 cases. This
    proves exclusion on [lower,upper], not beyond it: combine 15b separately.
    """
    from .b9_rank import rank_cases
    from .ordered_arcs import ordered_polar_bounds
    from .residual_propagation import check_propagation
    from .sector_exclusion import check_sector_exclusion

    try:
        lower, upper = Q(payload["lower"]), Q(payload["upper"])
        panels = payload["panels"]
        if lower >= upper or not panels:
            return False
        previous = lower
        for panel in panels:
            rr = tuple(map(Q, panel["radii"]))
            if len(rr) != 2 or rr[0] != previous or rr[0] >= rr[1]:
                return False
            previous = rr[1]
            if len(panel["cases"]) != 56:
                return False
            current_floors = radial_order_floors(rr)
            for rank, entry in zip(rank_cases(), panel["cases"], strict=True):
                if tuple(entry["rank"]) != rank:
                    return False
                floors = tuple(map(Q, entry["floors"]))
                if len(floors) != 3 or any(f < 0 or f > c for f, c in zip(
                        floors, current_floors, strict=True)):
                    return False
                if not check_rank_duals(floors, rank, entry["bounds"], entry["duals"]):
                    return False
                if entry.get("leaf_type", "residual") == "propagation":
                    if not check_propagation(ordered_polar_bounds(rr, entry["bounds"]),
                                             rr[0], entry["leaf"]):
                        return False
                elif entry.get("leaf_type", "residual") == "residual":
                    if not check_sector_exclusion(rr, entry["bounds"], entry["leaf"]):
                        return False
                else:
                    return False
        return previous == upper
    except (ValueError, TypeError, KeyError, IndexError, ArithmeticError):
        return False


def propose_rank_duals(radius, rank, bounds, *, dps=60):
    floors = radial_order_floors(radius, dps=dps)
    planes = rank_planes(floors, rank)
    matrix = -np.array([row for row, _ in planes], float)
    rhs = -np.array([b for _, b in planes], float)
    duals = []
    for k in range(18):
        for sign in (1, -1):
            cost = np.zeros(18)
            cost[k] = sign
            solve = linprog(cost, A_ub=matrix, b_ub=rhs, bounds=[(None, None)]*18,
                            method="highs")
            if not solve.success:
                return None
            dual = [[i, str(Q(float(-v)).limit_denominator(10**6))]
                    for i, v in enumerate(solve.ineqlin.marginals) if v < -1e-10]
            duals.append(dual)
    if not check_rank_duals(floors, rank, bounds, duals):
        return None
    return {"floors": [str(x) for x in floors], "duals": duals}
