"""Exact necessary center bounds from assigned unit-disk coverage points.

For a rational reference a and a point p, |c-p|<=1 implies the supporting
half-plane 2(p-a).c >= |p|^2-|a|^2-1. Dropping |c-a|^2 is a safe relaxation,
not an assumption that c is already near a. Intersect these rational planes
with an initial box p0+[-1,1]^2 to get globally valid center enclosures.
"""

from __future__ import annotations

from fractions import Fraction as Q
from itertools import combinations

from .exclusion import (
    _point,
    check_witness,
    checked_boxes,
    distance2,
    unit_disk_conflict,
)


def center_polygon(points, reference):
    """Rational outer polygon for all centers whose unit disks cover points.

    Empty output proves impossibility. Nonempty output asserts only necessary
    conditions. The reference can be arbitrary and supplies no localization
    assumption. Retains line/point degeneracies; all inequalities are closed.
    """
    points = tuple(_point(p) for p in points)
    reference = _point(reference)
    if not points:
        raise ValueError("at least one assigned point is required")
    x, y = points[0]
    polygon = [(x-1, y-1), (x+1, y-1), (x+1, y+1), (x-1, y+1)]
    for p in points:
        normal = tuple(2*(q-a) for q, a in zip(p, reference, strict=True))
        rhs = sum(q*q-a*a for q, a in zip(p, reference, strict=True))-1

        def signed(v, normal=normal, rhs=rhs):
            return sum(n*c for n, c in zip(normal, v, strict=True))-rhs

        clipped = []
        for v, w in zip(polygon, polygon[1:]+polygon[:1], strict=True):
            sv, sw = signed(v), signed(w)
            if sv >= 0:
                clipped.append(v)
            if (sv < 0 < sw) or (sw < 0 < sv):
                t = sv/(sv-sw)
                clipped.append(tuple(a+t*(b-a) for a, b in zip(v, w, strict=True)))
        polygon = list(dict.fromkeys(clipped))
        if not polygon:
            break
    return tuple(polygon)


def center_box(points, reference):
    """Exact rational bounding box of center_polygon, or None if it is empty."""
    polygon = center_polygon(points, reference)
    if not polygon:
        return None
    return tuple(tuple(extreme(p[k] for p in polygon) for k in range(2))
                 for extreme in (min, max))


def _planes(points, reference):
    x, y = points[0]
    planes = [((Q(1), Q(0)), x-1), ((Q(-1), Q(0)), -x-1),
              ((Q(0), Q(1)), y-1), ((Q(0), Q(-1)), -y-1)]
    planes += [(tuple(2*(q-a) for q, a in zip(p, reference, strict=True)),
                sum(q*q-a*a for q, a in zip(p, reference, strict=True))-1)
               for p in points]
    return planes


def center_box_certificate(points, reference):
    """Propose four exact nonnegative dual combinations for coordinate bounds.

    The replay checks only rational linear combinations, not polygon clipping.
    None means this proposer failed (including empty polygons), not feasibility.
    """
    points = tuple(_point(p) for p in points)
    reference = _point(reference)
    box = center_box(points, reference)
    if box is None:
        return None
    planes = _planes(points, reference)
    duals = []
    for k, sign in ((0, 1), (1, 1), (0, -1), (1, -1)):
        target = (Q(sign) if k == 0 else Q(0), Q(sign) if k == 1 else Q(0))
        bound = sign*box[0 if sign == 1 else 1][k]
        found = None
        for i, j in combinations(range(len(planes)), 2):
            (a, ar), (b, br) = planes[i], planes[j]
            det = a[0]*b[1]-a[1]*b[0]
            if det == 0:
                continue
            u = (target[0]*b[1]-target[1]*b[0])/det
            v = (a[0]*target[1]-a[1]*target[0])/det
            if u >= 0 and v >= 0 and u*ar+v*br == bound:
                found = [[i, str(u)], [j, str(v)]]
                break
        if found is None:
            return None
        duals.append(found)
    return {"reference": [str(x) for x in reference],
            "box": [[str(x) for x in corner] for corner in box], "duals": duals}


def check_center_box_certificate(points, certificate):
    """Return proved box, or None. Does not call the polygon proposer."""
    try:
        points = tuple(_point(p) for p in points)
        if not points or set(certificate) != {"reference", "box", "duals"}:
            return None
        reference = _point(certificate["reference"])
        box = checked_boxes([certificate["box"]])[0]
        planes = _planes(points, reference)
        if len(certificate["duals"]) != 4:
            return None
        for dual, (k, sign) in zip(certificate["duals"],
                                   ((0, 1), (1, 1), (0, -1), (1, -1)), strict=True):
            normal = [Q(0), Q(0)]
            rhs = Q(0)
            for i, weight in dual:
                weight = Q(weight)
                if type(i) is not int or not 0 <= i < len(planes) or weight < 0:
                    return None
                a, b = planes[i]
                normal = [v+weight*u for u, v in zip(a, normal, strict=True)]
                rhs += weight*b
            target = [Q(sign) if k == j else Q(0) for j in (0, 1)]
            if normal != target or rhs < sign*box[0 if sign == 1 else 1][k]:
                return None
        return box
    except (ValueError, TypeError, KeyError, IndexError, ZeroDivisionError):
        return None


def check_two_center_lift(outer_boxes, radius_floor, certificate):
    """Replay a global-to-local implication for arbitrary two additional disks.

    All first-stage points must miss every outer box. A spanning conflict tree
    forces their assignments up to disk interchange. A certified first center
    box then makes extra residual points compulsory for the second disk.
    Returns (first_box, second_box, radius_upper), or None on ANY failure.
    It does not assert the existence of a covering configuration in the domain.
    """
    try:
        if set(certificate) != {"points", "color_tree", "first_bound", "second_points",
                                "second_bound", "radius_point", "radius_upper"}:
            return None
        outer_boxes = checked_boxes(outer_boxes)
        radius_floor = Q(radius_floor)
        points = tuple(_point(p) for p in certificate["points"])
        if not points or not all(check_witness(outer_boxes, radius_floor, p) for p in points):
            return None
        colors = [None]*len(points)
        colors[0] = 0
        for i, j in certificate["color_tree"]:
            if (type(i) is not int or type(j) is not int
                    or not 0 <= i < len(points) or not 0 <= j < len(points)
                    or colors[i] is not None or colors[j] is None
                    or not unit_disk_conflict([points[i], points[j]])):
                return None
            colors[i] = 1-colors[j]
        if any(c is None for c in colors) or set(colors) != {0, 1}:
            return None
        assigned = [[p for p, c in zip(points, colors, strict=True) if c == k] for k in (0, 1)]
        first = check_center_box_certificate(assigned[0], certificate["first_bound"])
        if first is None:
            return None
        extra = tuple(_point(p) for p in certificate["second_points"])
        if not all(check_witness((*outer_boxes, first), radius_floor, p) for p in extra):
            return None
        second = check_center_box_certificate(assigned[1]+list(extra), certificate["second_bound"])
        if second is None:
            return None
        upper = Q(certificate["radius_upper"])
        p = _point(certificate["radius_point"])
        if (upper <= radius_floor or distance2(p, (Q(0), Q(0))) != upper**2
                or check_witness((*outer_boxes, first, second), upper, p) is None):
            return None
        return first, second, upper
    except (ValueError, TypeError, KeyError, IndexError, ZeroDivisionError):
        return None


def square_box(center, radius):
    center = _point(center)
    radius = Q(radius)
    if radius < 0:
        raise ValueError("box radius must be nonnegative")
    return tuple(tuple(x+sign*radius for x in center) for sign in (-1, 1))
