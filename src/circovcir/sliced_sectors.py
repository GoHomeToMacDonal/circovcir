"""Centerwise radial slices, retaining radius-angle correlations by sector unions.

Each center's entire parameter range is covered separately. No product-domain
subdivision or independence assumption is needed: missing ALL union pieces
implies missing that center. Slice angular bounds have exact original-LP duals.
"""
from __future__ import annotations

from fractions import Fraction as Q

from .correlated_sectors import (
    _angle_range,
    angle_coefficients,
    check_correlated_domain,
    outward,
    propose_correlated_domain,
    propose_support,
    support_check,
)
from .ordered_arcs import radial_bounds, radius_interval
from .rank_duals import rank_planes


def slice_planes(floors, rank, j, pair):
    planes = rank_planes(floors, rank)
    co = [Q(i == j) for i in range(18)]
    return planes+[(co, Q(pair[0])), ([-x for x in co], -Q(pair[1]))]


def slice_sector(radius, j, pair, mass=None):
    radial = radial_bounds(radius, j, pair)
    angle = (Q(0), Q(0)) if j == 0 else _angle_range(radius, j, mass)
    return radial, angle


def propose_sliced_domain(radius, rank, *, slices=8):
    root = propose_correlated_domain(radius, rank)
    if root is None or type(slices) is not int or slices < 1:
        return None
    pieces = []
    for j in range(9):
        lo, hi = map(Q, root["supports"][j]["range"])
        cuts = [lo+(hi-lo)*k/slices for k in range(slices+1)]
        parts = []
        for a, b in zip(cuts[:-1], cuts[1:], strict=True):
            if a == b:
                continue
            ps = slice_planes(root["floors"], rank, j, (a, b))
            support = None if j == 0 else propose_support(ps, angle_coefficients(j))
            if j != 0 and support is None:
                return None  # no unverified 'empty slice' shortcut
            sec = slice_sector(radius, j, (a, b), None if j == 0 else support["range"])
            # Intersect with the already certified whole-domain sector.
            sec = [(max(p[0], q[0]), min(p[1], q[1]))
                   for p, q in zip(sec, root["polar"][j], strict=True)]
            parts.append({"parameter": (a, b), "support": support,
                          "sector": [outward(p) for p in sec]})
        if not parts:
            return None
        pieces.append(parts)
    return {"root": root, "pieces": pieces}


def check_sliced_domain(radius, certificate):
    """Return a flat union of all nine centers' sectors, or None on failure.

    Flat union is safe for residual tests: every possible center is somewhere
    in it. The number of sectors is NOT the number of physical disks.
    """
    try:
        root = certificate["root"]
        original = check_correlated_domain(radius, root)
        if original is None or len(certificate["pieces"]) != 9:
            return None
        result = []
        for j, pieces in enumerate(certificate["pieces"]):
            lo, hi = map(Q, root["supports"][j]["range"])
            previous = lo
            if not pieces:
                return None
            for piece in pieces:
                pair = tuple(map(Q, piece["parameter"]))
                if len(pair) != 2 or pair[0] != previous or not pair[0] < pair[1] <= hi:
                    return None
                previous = pair[1]
                if j == 0:
                    if piece["support"] is not None:
                        return None
                    mass = None
                else:
                    ps = slice_planes(root["floors"], root["rank"], j, pair)
                    if not support_check(ps, angle_coefficients(j), piece["support"]):
                        return None
                    mass = piece["support"]["range"]
                sec = slice_sector(radius, j, pair, mass)
                computed = [(max(p[0], q[0]), min(p[1], q[1]))
                            for p, q in zip(sec, original[j], strict=True)]
                saved = tuple(tuple(map(Q, p)) for p in piece["sector"])
                if len(saved) != 2 or any(len(p) != 2 for p in saved):
                    return None
                if any(not p[0] <= c[0] <= c[1] <= p[1]
                       for p, c in zip(saved, computed, strict=True)):
                    return None
                result.append(saved)
            if previous != hi:
                return None
        return result
    except (ValueError, TypeError, KeyError, IndexError, ArithmeticError):
        return None


def replay_sliced_cover(payload):
    """Exact acceptance for contiguous radius panels and all 56 non-strict ranks."""
    from .b9_rank import rank_cases
    from .residual_propagation import check_propagation

    try:
        lower, upper = Q(payload["lower"]), Q(payload["upper"])
        previous = lower
        if lower >= upper or not payload["panels"]:
            return False
        for panel in payload["panels"]:
            rr = radius_interval(panel["radii"])
            if rr[0] != previous or rr[0] >= rr[1] or len(panel["cases"]) != 56:
                return False
            previous = rr[1]
            for rank, entry in zip(rank_cases(), panel["cases"], strict=True):
                if tuple(entry["domain"]["root"]["rank"]) != rank:
                    return False
                sectors = check_sliced_domain(rr, entry["domain"])
                if sectors is None or not check_propagation(sectors, rr[0], entry["leaf"]):
                    return False
        return previous == upper
    except (ValueError, TypeError, KeyError, IndexError, ArithmeticError):
        return False
