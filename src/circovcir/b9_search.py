"""Radius-interval b=9 proof trees: exclusion OR certified-target localization.

A closed tree proves that each covering point maps to the supplied target,
conditional on the target theorem (14a/13b). NOT an infeasibility statement.
Every split has both children; unresolved leaves never pass replay.
"""
from __future__ import annotations

from fractions import Fraction as Q

from .localization import (
    check_localization,
    check_residual_exclusion,
    propose_localization,
    propose_residual_exclusion,
)
from .ordered_arcs import (
    contract_radial_order,
    global_simplex,
    ordered_center_boxes,
    radius_interval,
)


def _contract(radii, bounds, dps, rank=None):
    root = global_simplex(radii, dps=dps)
    if root is None:
        return None
    bounds = tuple((max(Q(lo), rlo), min(Q(hi), rhi))
                   for (lo, hi), (rlo, rhi) in zip(bounds, root, strict=True))
    if any(lo > hi for lo, hi in bounds):
        return None
    if rank is not None:
        from .b9_rank import contract_ranked

        return contract_ranked(radii, bounds, rank, dps=dps)
    return contract_radial_order(radii, bounds, dps=dps)


def _split(radii, bounds, index):
    if index == 18:
        lo, hi = radii
        return [((lo, (lo+hi)/2), bounds), (((lo+hi)/2, hi), bounds)]
    lo, hi = bounds[index]
    result = []
    for interval in ((lo, (lo+hi)/2), ((lo+hi)/2, hi)):
        child = list(bounds)
        child[index] = interval
        result.append((radii, tuple(child)))
    return result


def localize_b9(radii, target, bounds=None, *, budget=255, max_depth=100, dps=60, rank=None,
                sectors=False, propagate=False):
    """Complete splits in a domain (optionally rank-constrained), budget-limited."""
    if rank is not None:
        from .b9_rank import checked_rank

        rank = checked_rank(rank)
    radii = radius_interval(radii)
    if budget < 1 or max_depth < 0:
        raise ValueError("invalid budget/depth")
    initial = tuple((Q(0), Q(1)) for _ in range(18)) if bounds is None else tuple(
        tuple(map(Q, p)) for p in bounds)
    if len(initial) != 18 or any(lo > hi for lo, hi in initial):
        raise ValueError("expected 18 ordered bounds")
    stats = {"visited": 0, "excluded": 0, "localized": 0, "empty": 0,
             "unresolved": 0, "max_depth": 0, "radius_splits": 0}

    def visit(rr, current, depth):
        if stats["visited"] >= budget:
            stats["unresolved"] += 1
            return {"unresolved": "budget"}
        stats["visited"] += 1
        stats["max_depth"] = max(depth, stats["max_depth"])
        b = _contract(rr, current, dps, rank)
        if b is None:
            stats["empty"] += 1
            return {"empty": True}
        boxes = ordered_center_boxes(rr, b, dps=dps)
        leaf = propose_localization(boxes, rr, target)
        if leaf is not None:
            stats["localized"] += 1
            return {"localization": leaf}
        if sectors:
            from .sector_exclusion import propose_sector_exclusion

            leaf = propose_sector_exclusion(rr, b, dps=dps, limit=18)
            if leaf is not None:
                stats["excluded"] += 1
                return {"sector_residual": leaf}
        if propagate:
            from .ordered_arcs import ordered_polar_bounds
            from .residual_propagation import propose_propagation

            leaf = propose_propagation(ordered_polar_bounds(rr, b, dps=dps), rr[0])
            if leaf is not None:
                stats["excluded"] += 1
                return {"propagation": leaf}
        leaf = propose_residual_exclusion(boxes, rr)
        if leaf is not None:
            stats["excluded"] += 1
            return {"residual": leaf}
        if depth >= max_depth:
            stats["unresolved"] += 1
            return {"unresolved": "depth"}
        width, j = max([(hi-lo, i) for i, (lo, hi) in enumerate(b)]+
                       [(8*(rr[1]-rr[0]), 18)])
        if width <= 0:
            stats["unresolved"] += 1
            return {"unresolved": "point"}
        stats["radius_splits"] += int(j == 18)
        return {"split": j, "children": [visit(cr, cb, depth+1)
                                          for cr, cb in _split(rr, b, j)]}

    tree = visit(radii, initial, 0)
    return {"closed_to_target": stats["unresolved"] == 0, "stats": stats,
            "radii": [str(x) for x in radii],
            "bounds": [[str(x) for x in p] for p in initial], "dps": dps,
            "rank": rank, "tree": tree}


def ranked_cover(radii, target, *, budget_per_case=1, max_depth=100, dps=60):
    """All 56 non-strict rank cases; success requires EVERY case to close."""
    from .b9_rank import rank_cases

    results = [localize_b9(radii, target, rank=rank, budget=budget_per_case,
                           max_depth=max_depth, dps=dps, sectors=True) for rank in rank_cases()]
    return {"radii": [str(x) for x in radius_interval(radii)], "cases": results,
            "closed_to_target": all(r["closed_to_target"] for r in results)}


def replay_ranked_cover(result, target):
    """Check full rank-case coverage, root domains and each tree independently."""
    from .b9_rank import rank_cases

    try:
        rr = radius_interval(result["radii"])
        cases = result["cases"]
        if len(cases) != 56:
            return False
        for rank, case in zip(rank_cases(), cases, strict=True):
            if (tuple(case["rank"]) != rank or radius_interval(case["radii"]) != rr
                    or [[Q(v) for v in p] for p in case["bounds"]] != [[Q(0), Q(1)]]*18
                    or not replay_b9_localization(case, target)):
                return False
        return True
    except (ValueError, TypeError, KeyError, IndexError):
        return False


def replay_b9_localization(result, target):
    """No trust in summary stats/closed flag; replay every actual leaf and split.

    The target is supplied by the caller, never accepted from an untrusted tree.
    Check 14a/13b separately before drawing a sharp upper-bound conclusion.
    """
    try:
        radii = radius_interval(result["radii"])
        initial = tuple(tuple(map(Q, p)) for p in result["bounds"])
        dps = result["dps"]
        rank = result.get("rank")
        if rank is not None:
            from .b9_rank import checked_rank

            rank = checked_rank(rank)
        if len(initial) != 18 or any(lo > hi for lo, hi in initial):
            return False

        def replay(rr, current, node):
            b = _contract(rr, current, dps, rank)
            if set(node) == {"empty"}:
                return b is None and node["empty"] is True
            if b is None:
                return False
            if set(node) == {"localization"}:
                return check_localization(ordered_center_boxes(rr, b, dps=dps), rr,
                                          target, node["localization"])
            if set(node) == {"residual"}:
                return check_residual_exclusion(ordered_center_boxes(rr, b, dps=dps),
                                                rr, node["residual"])
            if set(node) == {"sector_residual"}:
                from .sector_exclusion import check_sector_exclusion

                return check_sector_exclusion(rr, b, node["sector_residual"], dps=dps)
            if set(node) == {"propagation"}:
                from .ordered_arcs import ordered_polar_bounds
                from .residual_propagation import check_propagation

                return check_propagation(ordered_polar_bounds(rr, b, dps=dps), rr[0],
                                         node["propagation"], dps=dps)
            if set(node) != {"split", "children"} or len(node["children"]) != 2:
                return False
            j = node["split"]
            if type(j) is not int or not 0 <= j <= 18:
                return False
            lo, hi = rr if j == 18 else b[j]
            if lo >= hi:
                return False
            return all(replay(cr, cb, child) for (cr, cb), child in zip(
                _split(rr, b, j), node["children"], strict=True))

        return replay(radii, initial, result["tree"])
    except (ValueError, TypeError, KeyError, IndexError, ArithmeticError, RecursionError):
        return False
