"""Exact finite-point two-unit-disk decision by all strict line partitions.

A covering admits a nearest-center, line-separated assignment. Normals (1,t)
change projection order only at t=-(px-qx)/(py-qy). Every open chamber is checked;
vertical normals and event directions follow by perturbing a STRICT separator.
This does not assert contiguous cyclic assignment of an arbitrary residual set.
"""
from __future__ import annotations

from fractions import Fraction as Q
from itertools import combinations

from .exclusion import _point, distance2, unit_disk_conflict


def _cross(a, b):
    return a[0]*b[1]-a[1]*b[0]


def _sub(a, b):
    return a[0]-b[0], a[1]-b[1]


def _circle(points, ids):
    """Exact rational circle from one, two or three boundary points."""
    p = points[ids[0]]
    if len(ids) == 1:
        return p, Q(0), ids
    q = points[ids[1]]
    if len(ids) == 2:
        c = tuple((a+b)/2 for a, b in zip(p, q, strict=True))
    else:
        r = points[ids[2]]
        u, v = _sub(q, p), _sub(r, p)
        determinant = 2*_cross(u, v)
        if determinant == 0:
            return None
        uu, vv = distance2(p, q), distance2(p, r)
        c = (p[0]+(uu*v[1]-vv*u[1])/determinant,
             p[1]+(u[0]*vv-v[0]*uu)/determinant)
    return c, distance2(c, p), ids


def _incremental_circle(points):
    """Proposal via exact incremental boundary circles; output checked separately."""
    def outside(circle, i):
        return circle is None or distance2(points[i], circle[0]) > circle[1]

    def two_boundary(prefix, p, q):
        diameter = _circle(points, (p, q))
        left = right = None
        direction = _sub(points[q], points[p])
        for r in prefix:
            if not outside(diameter, r):
                continue
            side = _cross(direction, _sub(points[r], points[p]))
            candidate = _circle(points, (p, q, r))
            if candidate is None:
                continue
            value = _cross(direction, _sub(candidate[0], points[p]))
            if side > 0 and (left is None or value > left[0]):
                left = value, candidate
            elif side < 0 and (right is None or value < right[0]):
                right = value, candidate
        options = [v[1] for v in (left, right) if v is not None]
        return min(options, key=lambda v: v[1]) if options else diameter

    circle = None
    for i in range(len(points)):
        if not outside(circle, i):
            continue
        circle = _circle(points, (i,))
        for j in range(i):
            if outside(circle, j):
                circle = (_circle(points, (i, j)) if circle[1] == 0
                          else two_boundary(range(j+1), i, j))
    return circle


def one_disk_decision(points):
    """Return an exactly verified containing unit disk or a pair/triple conflict.

    Incremental circle construction is NOT trusted. Acceptance checks actual
    distances or an exact Helly conflict. Rare fallback is exhaustive, finite.
    """
    points = tuple(_point(p) for p in points)
    if not points:
        return {"center": (Q(0), Q(0))}
    circle = _incremental_circle(points)
    if circle is not None:
        center, _, ids = circle
        if all(distance2(p, center) <= 1 for p in points):
            return {"center": center}
        if len(ids) in (2, 3) and unit_disk_conflict([points[i] for i in ids]):
            return {"conflict": list(ids)}
    for size in (2, 3):
        for ids in combinations(range(len(points)), size):
            if unit_disk_conflict([points[i] for i in ids]):
                return {"conflict": list(ids)}
    # Helly guarantees feasibility; its minimum disk has a support of size <=3.
    for size in (1, 2, 3):
        for ids in combinations(range(len(points)), size):
            circle = _circle(points, ids)
            if circle is not None and all(distance2(p, circle[0]) <= 1 for p in points):
                return {"center": circle[0]}
    raise ArithmeticError("finite disk support enumeration inconsistent")


def canonical_points(points):
    """Equal rational points need only one label; sorted order is reproducible."""
    return tuple(sorted(set(_point(p) for p in points)))


def separator_slopes(points):
    """One exact finite slope in every open event chamber, including both tails."""
    events = sorted({-(p[0]-q[0])/(p[1]-q[1]) for p, q in combinations(points, 2)
                     if p[1] != q[1]})
    if not events:
        return (Q(0),)
    return (events[0]-1, *((a+b)/2 for a, b in zip(events[:-1], events[1:], strict=True)),
            events[-1]+1)


def separated_two_disks(points):
    """Complete finite decision with a positive cover OR negative chamber proof.

    For each order an infeasible prefix and suffix overlap in at most their
    cutoff point: max(position(prefix_conflict)) <= min(position(suffix_conflict)).
    Then every cut leaves at least one monochromatic conflict.
    """
    points = canonical_points(points)
    if not points:
        return {"kind": "covered", "centers": [["0", "0"], ["0", "0"]]}
    cache, edges, edge_ids, chambers = {}, [], {}, []
    previous = None

    def decide(ids):
        key = tuple(sorted(ids))
        if key not in cache:
            result = one_disk_decision([points[i] for i in key])
            if "conflict" in result:
                result = {"conflict": tuple(key[i] for i in result["conflict"])}
            cache[key] = result
        return cache[key]

    def register(edge):
        edge = tuple(sorted(edge))
        if edge not in edge_ids:
            edge_ids[edge] = len(edges)
            edges.append(list(edge))
        return edge_ids[edge]

    for slope in separator_slopes(points):
        order = sorted(range(len(points)), key=lambda i: points[i][0]+slope*points[i][1])
        position = {i: k for k, i in enumerate(order)}
        if previous is not None:
            a, b = previous
            if max(position[i] for i in a) <= min(position[i] for i in b):
                chambers.append([register(a), register(b)])
                continue
        # Binary search largest feasible prefix length; feasibility is monotone.
        lo, hi = 0, len(points)+1
        left = {"center": (Q(0), Q(0))}
        while hi-lo > 1:
            mid = (lo+hi)//2
            result = decide(order[:mid])
            if "center" in result:
                lo, left = mid, result
            else:
                hi = mid
        right = decide(order[lo:])
        if "center" in right:
            return {"kind": "covered", "centers":
                    [[str(x) for x in d["center"]] for d in (left, right)]}
        a = decide(order[:hi])["conflict"]
        b = right["conflict"]
        if max(position[i] for i in a) > min(position[i] for i in b):
            raise ArithmeticError("invalid cutoff conflicts")
        previous = a, b
        chambers.append([register(a), register(b)])
    return {"kind": "excluded", "edges": edges, "chambers": chambers}


def check_separated_two_disks(points, certificate):
    """Independent exact replay. True authenticates certificate['kind'], not coverage."""
    try:
        points = canonical_points(points)
        if certificate["kind"] == "covered":
            if set(certificate) != {"kind", "centers"} or len(certificate["centers"]) != 2:
                return False
            centers = [_point(p) for p in certificate["centers"]]
            return all(min(distance2(p, c) for c in centers) <= 1 for p in points)
        if set(certificate) != {"kind", "edges", "chambers"} or certificate["kind"] != "excluded":
            return False
        edges, chambers = certificate["edges"], certificate["chambers"]
        if not points or not edges:
            return False
        for edge in edges:
            if (len(edge) not in (2, 3) or len(set(edge)) != len(edge)
                    or any(type(i) is not int or not 0 <= i < len(points) for i in edge)
                    or not unit_disk_conflict([points[i] for i in edge])):
                return False
        slopes = separator_slopes(points)
        if len(chambers) != len(slopes):
            return False
        for slope, pair in zip(slopes, chambers, strict=True):
            if (len(pair) != 2 or any(type(i) is not int or not 0 <= i < len(edges) for i in pair)):
                return False
            order = sorted(range(len(points)), key=lambda i: points[i][0]+slope*points[i][1])
            position = {i: k for k, i in enumerate(order)}
            a, b = (edges[i] for i in pair)
            if max(position[i] for i in a) > min(position[i] for i in b):
                return False
        return True
    except (KeyError, TypeError, ValueError, IndexError, ArithmeticError):
        return False
