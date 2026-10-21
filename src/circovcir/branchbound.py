"""Exploratory, fail-closed bisection with exact witness leaves.

The supplied initial charts define the domain. This module does NOT assert that
such a domain contains every b=9 configuration. Budget/depth exhaustion returns
explicit unresolved boxes, never a theorem. Leaf proof trees can be replayed
without running the floating-point witness proposal again.
"""

from __future__ import annotations

from fractions import Fraction as Q
from math import isqrt

from .exclusion import (
    chart_box,
    check_b9_exclusion,
    check_witness,
    propose_b9_exclusion,
    propose_witness,
)


def b9_global_charts(radius, *, bits=40):
    """Nine root boxes containing all normalized b=9 covers at a fixed R>2.

    Use the proved existence of a boundary center of norm <=2 as the positive-x
    anchor. Each other direction is in the right or left closed semicircle,
    represented by base (+/-1,0), t in [-1,1]. Relabel interchangeable outer
    disks to group them by semicircle; their left-group size is 0,...,8.
    Radical-axis reflection provides the radial bound sqrt(R^2-1).
    The geometric reduction is documented in proofs/12-n11-b9-witness.md.
    """
    radius = Q(radius)
    if not 2 < radius < 3 or bits < 1:
        raise ValueError("global b9 charts require 2 < R < 3 and positive bits")
    den = 1 << bits
    square = (radius**2-1)*den**2
    top = isqrt(square.numerator//square.denominator)
    if Q(top*top) < square:
        top += 1
    upper = Q(top, den)
    roots = []
    for left_count in range(9):
        anchor = {"base": ["1", "0"], "radial": [str(radius-1), str(min(Q(2), upper))],
                  "tangent": ["0", "0"]}
        charts = [anchor]
        for i in range(8):
            charts.append({"base": ["-1" if i < left_count else "1", "0"],
                           "radial": [str(radius-1), str(upper)],
                           "tangent": ["-1", "1"]})
        roots.append(charts)
    return roots


def chart_product(charts):
    return tuple(chart_box(chart["radial"], chart["tangent"], chart["base"])
                 for chart in charts)


def exclude_chart_domain(charts, radius, *, budget=1000, max_depth=80, b9=False):
    radius = Q(radius)
    if radius <= 0 or budget < 1 or max_depth < 0:
        raise ValueError("invalid radius or search budget")
    # Validate even if the budget is too small to attempt a split.
    chart_product(charts)
    if b9 and len(charts) != 9:
        raise ValueError("b9 mode needs exactly nine outer charts")
    stats = {"visited": 0, "excluded": 0, "unresolved": 0, "max_depth": 0}

    def visit(current, depth):
        if stats["visited"] >= budget:
            stats["unresolved"] += 1
            return {"unresolved": "budget"}
        stats["visited"] += 1
        stats["max_depth"] = max(stats["max_depth"], depth)
        boxes = chart_product(current)
        if b9:
            certificate = propose_b9_exclusion(boxes, radius)
            if certificate is not None:
                stats["excluded"] += 1
                return {"b9": certificate}
        else:
            witness = propose_witness(boxes, radius)
            if witness is not None:
                stats["excluded"] += 1
                return {"point": [str(x) for x in witness.point]}
        if depth >= max_depth:
            stats["unresolved"] += 1
            return {"unresolved": "depth"}
        choices = []
        for i, c in enumerate(current):
            radial = tuple(map(Q, c["radial"]))
            tangent = tuple(map(Q, c["tangent"]))
            choices += [(radial[1]-radial[0], i, "radial"),
                        (2*radial[1]*(tangent[1]-tangent[0]), i, "tangent")]
        width, i, key = max(choices)
        if width == 0:
            stats["unresolved"] += 1
            return {"unresolved": "point"}
        lo, hi = map(Q, current[i][key])
        mid = (lo+hi)/2
        children = []
        for interval in ((lo, mid), (mid, hi)):
            child = [dict(c) for c in current]
            child[i][key] = [str(x) for x in interval]
            children.append(visit(child, depth+1))
        return {"split": [i, key], "children": children}

    tree = visit(charts, 0)
    return {"closed": stats["unresolved"] == 0, "stats": stats, "tree": tree}


def exclude_ordered_domain(radius, bounds=None, *, budget=255, max_depth=100, dps=60):
    """Search the ordered-arc simplex, using safe linear contraction at each node.

    This excludes ONLY by exact rational witness leaves. Empty linear domains
    have an independently recomputable proof. There is no local-optimum accept
    leaf: integrating the explicit collar requires lifting the two inner centers.
    """
    from .ordered_arcs import contract_simplex, global_simplex, ordered_center_boxes

    if budget < 1 or max_depth < 0:
        raise ValueError("invalid budget")
    radius = Q(radius)
    initial = global_simplex(radius, dps=dps) if bounds is None else bounds
    stats = {"visited": 0, "excluded": 0, "empty": 0, "unresolved": 0, "max_depth": 0}
    if initial is None:
        stats["visited"] = stats["empty"] = 1
        return {"closed": True, "stats": stats, "tree": {"radial_empty": True},
                "bounds": [["0", "1"] for _ in range(18)], "dps": dps}

    def visit(current, depth):
        if stats["visited"] >= budget:
            stats["unresolved"] += 1
            return {"unresolved": "budget"}
        stats["visited"] += 1
        stats["max_depth"] = max(stats["max_depth"], depth)
        contracted = contract_simplex(current)
        if contracted is None:
            stats["empty"] += 1
            return {"empty": True}
        boxes = ordered_center_boxes(radius, contracted, dps=dps)
        certificate = propose_b9_exclusion(boxes, radius)
        if certificate is not None:
            stats["excluded"] += 1
            return {"b9": certificate}
        if depth >= max_depth:
            stats["unresolved"] += 1
            return {"unresolved": "depth"}
        width, j = max((hi-lo, j) for j, (lo, hi) in enumerate(contracted))
        if width == 0:
            stats["unresolved"] += 1
            return {"unresolved": "point"}
        lo, hi = contracted[j]
        mid = (lo+hi)/2
        children = []
        for interval in ((lo, mid), (mid, hi)):
            child = list(contracted)
            child[j] = interval
            children.append(visit(child, depth+1))
        return {"split": j, "children": children}

    tree = visit(initial, 0)
    return {"closed": stats["unresolved"] == 0, "stats": stats, "tree": tree,
            "bounds": [[str(x) for x in b] for b in initial], "dps": dps}


def replay_ordered_exclusion(radius, bounds, tree, *, dps=60):
    """Replay contraction, complete binary splits, interval bounds and exact leaves."""
    from .ordered_arcs import contract_simplex, global_simplex, ordered_center_boxes

    try:
        def visit(current, node):
            if set(node) == {"radial_empty"}:
                return node["radial_empty"] is True and global_simplex(radius, dps=dps) is None
            contracted = contract_simplex(current)
            if set(node) == {"empty"}:
                return node["empty"] is True and contracted is None
            if contracted is None:
                return False
            if set(node) == {"b9"}:
                boxes = ordered_center_boxes(radius, contracted, dps=dps)
                return check_b9_exclusion(boxes, radius, node["b9"])
            if set(node) != {"split", "children"} or len(node["children"]) != 2:
                return False
            j = node["split"]
            if type(j) is not int or not 0 <= j < 18:
                return False
            lo, hi = contracted[j]
            if lo >= hi:
                return False
            mid = (lo+hi)/2
            for k, interval in enumerate(((lo, mid), (mid, hi))):
                child = list(contracted)
                child[j] = interval
                if not visit(child, node["children"][k]):
                    return False
            return True

        return visit(bounds, tree)
    except (ValueError, TypeError, KeyError, IndexError, ArithmeticError, RecursionError):
        return False


def replay_chart_exclusion(charts, radius, tree, *, b9=False):
    """Independent exact replay of a fully closed tree, including every split."""
    try:
        radius = Q(radius)
        if radius <= 0:
            return False

        def visit(current, node):
            boxes = chart_product(current)
            if "b9" in node:
                return (b9 and set(node) == {"b9"}
                        and check_b9_exclusion(boxes, radius, node["b9"]))
            if "point" in node:
                if b9 or set(node) != {"point"}:
                    return False
                return check_witness(boxes, radius, node["point"]) is not None
            if set(node) != {"split", "children"} or len(node["children"]) != 2:
                return False
            i, key = node["split"]
            if type(i) is not int or not 0 <= i < len(current) or key not in ("radial", "tangent"):
                return False
            lo, hi = map(Q, current[i][key])
            if lo >= hi:
                return False
            mid = (lo+hi)/2
            for k, interval in enumerate(((lo, mid), (mid, hi))):
                child = [dict(c) for c in current]
                child[i][key] = [str(x) for x in interval]
                if not visit(child, node["children"][k]):
                    return False
            return True

        return visit(charts, tree)
    except (KeyError, TypeError, ValueError, IndexError, RecursionError, ZeroDivisionError):
        return False
