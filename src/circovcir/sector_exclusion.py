"""Residual obstructions for polar CENTER SECTORS, not Cartesian rectangles.

The fixed witness point is missed for all s and theta in the center sector.
Only proposal is float. Acceptance uses outward trig intervals followed by
exact rational quadratic minimization. The finite-candidate theorem is untouched.
"""
from __future__ import annotations

from fractions import Fraction as Q

import numpy as np
from mpmath.ctx_iv import MPIntervalContext

from .exclusion import (
    _point,
    box_distance2,
    check_two_disk_obstruction,
    checked_boxes,
    distance2,
    rational_inside,
    two_disk_obstruction,
)
from .ordered_arcs import _interval, _iv, endpoints, ordered_polar_bounds, radius_interval


def sector_distance2(point, sector, *, dps=60):
    """Rigorous lower bound on min |point-s e(theta)|^2 over a polar sector."""
    p = _point(point)
    (lo, hi), (a, b) = (tuple(map(Q, v)) for v in sector)
    if not 0 <= lo <= hi or a > b or dps < 30:
        raise ValueError("invalid polar sector or precision")
    norm2 = distance2(p, (Q(0), Q(0)))
    if norm2 == 0:
        return lo*lo
    ctx = MPIntervalContext()
    ctx.dps = dps
    phi = ctx.atan2(_iv(ctx, p[1]), _iv(ctx, p[0]))
    projection = ctx.sqrt(_iv(ctx, norm2))*ctx.cos(_interval(ctx, a, b)-phi)
    maximum = endpoints(projection)[1]
    closest = min(hi, max(lo, maximum))
    return max(Q(0), norm2+closest*closest-2*closest*maximum)


def check_sector_points(polar, radius_floor, points, *, dps=60):
    """Every point lies in the target and misses every possible outer center."""
    points = tuple(_point(p) for p in points)
    return bool(points) and all(distance2(p, (Q(0), Q(0))) <= Q(radius_floor)**2
                               and all(sector_distance2(p, s, dps=dps) > 1 for s in polar)
                               for p in points)


def sector_candidates(polar, radius_floor, *, limit=32, excluded_boxes=()):
    """Concentric sample grids plus inner-facing circle arcs; proposal only."""
    rr = float(radius_floor)
    sectors = np.array(polar, float)
    theta = np.arange(192)*2*np.pi/192
    direction = np.column_stack([np.cos(theta), np.sin(theta)])
    # Many residual conflicts sit near the central ring, missed by midpoint
    # circumcenter-only proposals. Uniform scoring preserves the polar domain.
    clouds = [r*direction for r in np.linspace(0.8, min(1.9, rr), 23)]
    for (lo, hi), (a, b) in sectors:
        for s in (lo, (lo+hi)/2, hi):
            center = s*np.array([np.cos((a+b)/2), np.sin((a+b)/2)])
            clouds.append(center+1.001*direction)
    points = np.vstack(clouds)
    norm = np.linalg.norm(points, axis=1)
    angle = np.arctan2(points[:, 1], points[:, 0])
    score = np.full(len(points), np.inf)
    for (lo, hi), (a, b) in sectors:
        middle = (a+b)/2
        diff = (angle-middle+np.pi) % (2*np.pi)-np.pi
        delta = np.maximum(0, np.abs(diff)-(b-a)/2)
        projection = norm*np.cos(delta)
        closest = np.clip(projection, lo, hi)
        score = np.minimum(score, norm*norm+closest**2-2*closest*projection)
    valid = np.flatnonzero((norm <= rr) & (score > 1))
    extra = checked_boxes(excluded_boxes) if excluded_boxes else ()
    for lo, hi in extra:
        delta = np.maximum(np.maximum(np.array(lo, float)-points,
                                      points-np.array(hi, float)), 0)
        valid = valid[np.sum(delta[valid]**2, axis=1) > 1]
    chosen = []
    diversity = norm[valid].copy()
    available = np.ones(len(valid), bool)
    for _ in range(min(limit, len(valid))):
        j = int(np.argmax(np.where(available, diversity, -np.inf)))
        available[j] = False
        p = rational_inside(points[valid[j]], radius_floor)
        if (check_sector_points(polar, radius_floor, [p])
                and all(box_distance2(p, b) > 1 for b in extra)):
            chosen.append(p)
        diversity = np.minimum(diversity, np.linalg.norm(points[valid]-points[valid[j]], axis=1))
    return chosen


def propose_sector_exclusion(radii, bounds, *, dps=60, limit=32):
    polar = ordered_polar_bounds(radii, bounds, dps=dps)
    points = sector_candidates(polar, radius_interval(radii)[0], limit=limit)
    # The existing exact Helly solver returns a replayable conflict tree.
    # Only the points actually used by that tree are retained below.
    conflict = two_disk_obstruction(points)
    if conflict is None:
        return None
    used_edges = set()

    def used(node):
        used_edges.update(step[2] for step in node["forced"])
        if "conflict" in node:
            used_edges.add(node["conflict"])
        else:
            for child in node["children"]:
                used(child)

    used(conflict["tree"])
    indices = sorted({i for j in used_edges for i in conflict["edges"][j]})
    small = [points[i] for i in indices]
    smaller = two_disk_obstruction(small)
    if smaller is not None:
        points, conflict = small, smaller
    return {"points": [[str(x) for x in p] for p in points], "conflict": conflict}


def check_sector_exclusion(radii, bounds, leaf, *, dps=60):
    try:
        if set(leaf) != {"points", "conflict"}:
            return False
        polar = ordered_polar_bounds(radii, bounds, dps=dps)
        return (polar is not None
                and check_sector_points(polar, radius_interval(radii)[0], leaf["points"], dps=dps)
                and check_two_disk_obstruction(leaf["points"], leaf["conflict"]))
    except (ValueError, TypeError, KeyError, IndexError, ArithmeticError):
        return False
