"""Exact *exclusion* witnesses for boxes of circle centers (not coverage verification).

Floating geometry only proposes points. A returned witness is checked with
fractions: it lies in the target disk and is farther than one from EVERY center
in EVERY box. None means unresolved, never covered. No tolerance is used in the
certificate checker. The finite-candidate implementation itself is unchanged.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import combinations
from math import isqrt

import numpy as np

from .geometry import candidate_points

type Point = tuple[Fraction, Fraction]
type Box = tuple[Point, Point]  # lower and upper Cartesian corners


def _point(p) -> Point:
    if len(p) != 2:
        raise ValueError("expected a two-dimensional point")
    return tuple(Fraction(x) for x in p)


def checked_boxes(boxes) -> tuple[Box, ...]:
    out = tuple((_point(lo), _point(hi)) for lo, hi in boxes)
    if not out or any(any(a > b for a, b in zip(lo, hi, strict=True)) for lo, hi in out):
        raise ValueError("expected nonempty, ordered center boxes")
    return out


def distance2(a: Point, b: Point) -> Fraction:
    return sum((x - y) ** 2 for x, y in zip(a, b, strict=True))


def box_distance2(p: Point, box: Box) -> Fraction:
    """Exact minimum squared distance to a closed Cartesian rectangle."""
    lo, hi = box
    return sum(max(a - x, x - b, Fraction(0)) ** 2
               for x, a, b in zip(p, lo, hi, strict=True))


@dataclass(frozen=True)
class Witness:
    point: Point
    margin2: Fraction


def check_witness(boxes, radius, point) -> Witness | None:
    """Prove one point is missed uniformly by a box product, or return None."""
    boxes = checked_boxes(boxes)
    radius = Fraction(radius)
    if radius <= 0:
        raise ValueError("radius must be positive")
    point = _point(point)
    if distance2(point, (Fraction(0), Fraction(0))) > radius**2:
        return None
    margin = min(box_distance2(point, box) for box in boxes) - 1
    return Witness(point, margin) if margin > 0 else None


def rational_inside(point, radius, bits: int = 48) -> Point:
    """Round a proposed float point inward, using an exact integer square root."""
    radius = Fraction(radius)
    if radius <= 0 or bits < 1:
        raise ValueError("positive radius and bits required")
    den = 1 << bits
    x, y = (round(float(v) * den) for v in point)
    q = (Fraction(x, den), Fraction(y, den))
    norm2 = x*x + y*y
    if Fraction(norm2, den*den) > radius**2:
        ceil_norm = isqrt(norm2)
        if ceil_norm**2 < norm2:
            ceil_norm += 1
        q = (radius*x/ceil_norm, radius*y/ceil_norm)
    return q


def propose_witness(boxes, radius, *, limit: int | None = 32) -> Witness | None:
    """Heuristic proposal, exact acceptance. Not finding a point proves nothing."""
    boxes = checked_boxes(boxes)
    radius = Fraction(radius)
    if radius <= 0 or (limit is not None and limit < 1):
        raise ValueError("positive radius and proposal limit required")
    lo = np.array([[float(v) for v in b[0]] for b in boxes])
    hi = np.array([[float(v) for v in b[1]] for b in boxes])
    mid = (lo + hi) / 2
    points = candidate_points(mid, float(radius))
    delta = np.maximum(np.maximum(lo[None, :, :] - points[:, None, :],
                                  points[:, None, :] - hi[None, :, :]), 0)
    scores = (delta**2).sum(axis=2).min(axis=1)
    order = np.argsort(scores)[::-1]
    if limit is not None:
        order = order[:limit]
    for k in order:
        result = check_witness(boxes, radius, rational_inside(points[k], radius))
        if result is not None:
            return result
    return None


def unit_disk_conflict(points) -> bool:
    """Exact Helly obstruction for two or three rational points.

    True means NO unit disk contains them. For an acute triangle compare its
    circumradius squared to 1; a right/obtuse triangle is controlled by a pair.
    Collinear triples are handled by pair distances, not by division by zero.
    """
    p = tuple(_point(q) for q in points)
    if len(p) not in (2, 3):
        raise ValueError("expected two or three points")
    lengths = [distance2(a, b) for a, b in combinations(p, 2)]
    if max(lengths) > 4:
        return True
    if len(p) == 2:
        return False
    a, b, c = sorted(lengths)
    if a + b <= c:
        return False
    u = (p[1][0] - p[0][0], p[1][1] - p[0][1])
    v = (p[2][0] - p[0][0], p[2][1] - p[0][1])
    cross = u[0]*v[1] - u[1]*v[0]
    return a*b*c > 4*cross*cross


def rational_direction(t) -> Point:
    """Exact unit vector in a stereographic chart, angle 2 arctan(t)."""
    t = Fraction(t)
    return (1-t*t)/(1+t*t), 2*t/(1+t*t)


def chart_box(radial, tangent, base=(1, 0)) -> Box:
    """Exact enclosing Cartesian box for s*Rot(2 arctan(t))*base.

    Endpoints and any derivative-zero chart parameters are included. The latter
    need square roots in general, so use a conservative rational interval
    evaluation instead. This is an enclosure, not an exact image rectangle.
    """
    s0, s1 = map(Fraction, radial)
    t0, t1 = map(Fraction, tangent)
    bx, by = _point(base)
    if not 0 <= s0 <= s1 or t0 > t1 or bx*bx + by*by != 1:
        raise ValueError("invalid polar chart")

    def mul(a, b):
        v = [x*y for x in a for y in b]
        return min(v), max(v)

    def add(a, b):
        return a[0]+b[0], a[1]+b[1]

    low2 = 0 if t0 <= 0 <= t1 else min(t0*t0, t1*t1)
    high2 = max(t0*t0, t1*t1)
    co = mul((1-high2, 1-low2), (1/(1+high2), 1/(1+low2)))
    si = mul((2*t0, 2*t1), (1/(1+high2), 1/(1+low2)))
    xx = mul((s0, s1), add(mul((bx, bx), co), mul((-by, -by), si)))
    yy = mul((s0, s1), add(mul((by, by), co), mul((bx, bx), si)))
    return (xx[0], yy[0]), (xx[1], yy[1])


def two_disk_obstruction(points) -> dict | None:
    """Exact finite-point two-center infeasibility, with an exhaustive proof tree.

    Build pair/triple Helly conflicts, then try every 2-coloring using unit
    propagation. Fix point 0 to color 0 only by interchangeability of the TWO
    disks, not by assuming any geometric symmetry. None means no obstruction.
    Intended for small adaptive witness sets, not a large sampled net.
    """
    points = tuple(_point(p) for p in points)
    if not points:
        return None
    edges = [e for e in combinations(range(len(points)), 2)
             if unit_disk_conflict([points[i] for i in e])]
    pairs = set(edges)
    edges += [e for e in combinations(range(len(points)), 3)
              if not any(p in pairs for p in combinations(e, 2))
              and unit_disk_conflict([points[i] for i in e])]

    def solve(colors):
        forced = []
        while True:
            progress = False
            for j, edge in enumerate(edges):
                known = {colors[i] for i in edge if colors[i] != -1}
                unknown = [i for i in edge if colors[i] == -1]
                if len(known) == 1:
                    if not unknown:
                        return {"forced": forced, "conflict": j}
                    if len(unknown) == 1:
                        i = unknown[0]
                        color = 1 - next(iter(known))
                        colors[i] = color
                        forced.append([i, color, j])
                        progress = True
            if not progress:
                break
        unresolved = [edge for edge in edges
                      if len({colors[i] for i in edge if colors[i] != -1}) < 2]
        if not unresolved:
            return None
        i = next(i for edge in unresolved for i in edge if colors[i] == -1)
        children = []
        for color in (0, 1):
            child_colors = colors.copy()
            child_colors[i] = color
            child = solve(child_colors)
            if child is None:
                return None
            children.append(child)
        return {"forced": forced, "split": i, "children": children}

    tree = solve([0] + [-1] * (len(points)-1))
    if tree is None:
        return None
    return {"edges": [list(e) for e in edges], "tree": tree}


def residual_candidates(boxes, radius, *, limit=18):
    """Propose rational points uniformly missed by all listed (outer) disks.

    The target is an interior residual-set obstruction, not a finite sampling
    coverage test. Candidate circle arcs are only a heuristic; exact inequalities
    certify each accepted point, independently of how it was found.
    """
    boxes = checked_boxes(boxes)
    radius = Fraction(radius)
    if radius <= 0 or limit < 1:
        raise ValueError("positive radius and limit required")
    lo = np.array([[float(x) for x in b[0]] for b in boxes])
    hi = np.array([[float(x) for x in b[1]] for b in boxes])
    mid = (lo+hi)/2
    theta = np.arange(128)*2*np.pi/128
    directions = np.column_stack([np.cos(theta), np.sin(theta)])
    # Slightly outside each outer disk, on several scales to see small holes.
    clouds = [candidate_points(mid, float(radius)), np.zeros((1, 2))]
    clouds += [(mid[:, None, :] + (1+eps)*directions[None, :, :]).reshape(-1, 2)
               for eps in (1e-7, 1e-4, 0.01)]
    points = np.vstack(clouds)
    delta = np.maximum(np.maximum(lo[None, :, :]-points[:, None, :],
                                  points[:, None, :]-hi[None, :, :]), 0)
    scores = (delta**2).sum(axis=2).min(axis=1)
    valid = np.flatnonzero((scores > 1) & ((points**2).sum(axis=1) <= float(radius)**2))
    if len(valid) == 0:
        return []
    # Farthest-first diversity is important: many copies of the same hole give
    # little information about the TWO-circle residual covering problem.
    chosen = []
    diversity = np.linalg.norm(points[valid], axis=1)
    available = np.ones(len(valid), dtype=bool)
    for _ in range(min(limit, len(valid))):
        k = int(np.argmax(np.where(available, diversity, -np.inf)))
        available[k] = False
        p = rational_inside(points[valid[k]], radius)
        checked = check_witness(boxes, radius, p)
        if checked is not None:
            chosen.append(p)
        diversity = np.minimum(diversity,
                               np.linalg.norm(points[valid]-points[valid[k]], axis=1))
    return chosen


def propose_b9_exclusion(boxes, radius):
    """An exact boundary-hole or residual two-disk obstruction for nine boxes."""
    boxes = checked_boxes(boxes)
    if len(boxes) != 9:
        raise ValueError("b9 mode needs exactly nine outer-center boxes")
    radius = Fraction(radius)
    mid = np.array([[float((x+y)/2) for x, y in zip(lo, hi, strict=True)]
                    for lo, hi in boxes])
    proposed = candidate_points(mid, float(radius))
    boundary = proposed[np.linalg.norm(proposed, axis=1) >= float(radius)*(1-1e-10)]
    for p in boundary:
        angle = np.arctan2(p[1], p[0])
        t = Fraction(float(np.tan(angle/2))).limit_denominator(10**10)
        unit = rational_direction(t)
        p = tuple(radius*x for x in unit)
        if check_witness(boxes, radius, p) is not None:
            return {"boundary_point": [str(x) for x in p]}
    points = residual_candidates(boxes, radius)
    if len(points) < 3:
        return None
    conflict = two_disk_obstruction(points)
    if conflict is None:
        return None
    return {"residual_points": [[str(x) for x in p] for p in points],
            "two_disk_conflict": conflict}


def check_b9_exclusion(boxes, radius, certificate):
    """Replay with exact rational checks, allowing arbitrary two inner centers."""
    try:
        boxes = checked_boxes(boxes)
        radius = Fraction(radius)
        if len(boxes) != 9 or radius <= 0:
            return False
        if set(certificate) == {"boundary_point"}:
            p = _point(certificate["boundary_point"])
            return (distance2(p, (0, 0)) == radius**2
                    and check_witness(boxes, radius, p) is not None)
        if set(certificate) != {"residual_points", "two_disk_conflict"}:
            return False
        points = tuple(_point(p) for p in certificate["residual_points"])
        return (all(check_witness(boxes, radius, p) is not None for p in points)
                and check_two_disk_obstruction(points, certificate["two_disk_conflict"]))
    except (KeyError, TypeError, ValueError, IndexError, ZeroDivisionError):
        return False


def check_two_disk_obstruction(points, certificate) -> bool:
    """Independent fail-closed replay; no trust in solver propagation or edges."""
    try:
        points = tuple(_point(p) for p in points)
        edges = certificate["edges"]
        if not points:
            return False
        for edge in edges:
            if (len(edge) not in (2, 3) or len(set(edge)) != len(edge)
                    or any(type(i) is not int or not 0 <= i < len(points) for i in edge)
                    or not unit_disk_conflict([points[i] for i in edge])):
                return False

        def replay(node, colors):
            for i, color, j in node["forced"]:
                if (type(i) is not int or not 0 <= i < len(points) or colors[i] != -1
                        or color not in (0, 1) or type(j) is not int or not 0 <= j < len(edges)):
                    return False
                edge = edges[j]
                if i not in edge or any(colors[k] != 1-color for k in edge if k != i):
                    return False
                colors[i] = color
            if "conflict" in node:
                if "split" in node or "children" in node:
                    return False
                j = node["conflict"]
                if type(j) is not int or not 0 <= j < len(edges):
                    return False
                return len({colors[i] for i in edges[j]}) == 1 and colors[edges[j][0]] != -1
            i = node["split"]
            if (type(i) is not int or not 0 <= i < len(points) or colors[i] != -1
                    or len(node["children"]) != 2):
                return False
            for color in (0, 1):
                child_colors = colors.copy()
                child_colors[i] = color
                if not replay(node["children"][color], child_colors):
                    return False
            return True

        return replay(certificate["tree"], [0] + [-1] * (len(points)-1))
    except (KeyError, TypeError, ValueError, IndexError, RecursionError):
        return False
