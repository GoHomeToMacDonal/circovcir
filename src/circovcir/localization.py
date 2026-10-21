"""b=9 localization leaves and radius-uniform rational exclusions.

A localization leaf proves only containment in a supplied certified target
(theorem 14a + 13b), not infeasibility. Callers must check that target theorem
separately. All rotations are EXACT rational orthogonal matrices, avoiding
midpoint-only gauge assumptions. This module does not load any implicit target.
"""
from __future__ import annotations

from fractions import Fraction as Q

import numpy as np

from .exclusion import (
    _point,
    check_two_disk_obstruction,
    check_witness,
    checked_boxes,
    rational_direction,
    residual_candidates,
    two_disk_obstruction,
)
from .ordered_arcs import radius_interval


def rotate_boxes(boxes, direction):
    """Exact Cartesian enclosure for one FIXED rational rotation of all boxes."""
    boxes = checked_boxes(boxes)
    co, si = _point(direction)
    if co*co+si*si != 1:
        raise ValueError("rotation must be exactly unit length")
    result = []
    for lo, hi in boxes:
        corners = [(co*x-si*y, si*x+co*y) for x in (lo[0], hi[0]) for y in (lo[1], hi[1])]
        result.append(tuple(tuple(extreme(p[k] for p in corners) for k in (0, 1))
                            for extreme in (min, max)))
    return tuple(result)


def check_localization(boxes, radii, target, leaf):
    """Check containment modulo rotation/permutation in the supplied G3 target.

    True is conditional on the target's separately checked theorem. In
    particular this does NOT derive local optimality from the target JSON.
    """
    try:
        boxes = checked_boxes(boxes)
        destination = checked_boxes(target["outer_boxes"])
        if len(boxes) != 9 or len(destination) != 9 or set(leaf) != {"rotation", "permutation"}:
            return False
        if radius_interval(radii)[0] < Q(target["radius_floor"]):
            return False
        perm = leaf["permutation"]
        if (len(perm) != 9 or any(type(i) is not int for i in perm)
                or sorted(perm) != list(range(9))):
            return False
        rotated = rotate_boxes(boxes, leaf["rotation"])
        return all(destination[j][0][k] <= rotated[i][0][k]
                   and rotated[i][1][k] <= destination[j][1][k]
                   for j, i in enumerate(perm) for k in (0, 1))
    except (ValueError, TypeError, KeyError, IndexError, ZeroDivisionError):
        return False


def propose_localization(boxes, radii, target):
    """Try nine cyclic matches; float proposes, rational inclusion alone accepts."""
    boxes = checked_boxes(boxes)
    destination = checked_boxes(target["outer_boxes"])
    if len(boxes) != 9 or len(destination) != 9:
        raise ValueError("expected nine source/target boxes")
    src = np.array([[(float(a)+float(b))/2 for a, b in zip(lo, hi, strict=True)]
                    for lo, hi in boxes])
    dst = np.array([[(float(a)+float(b))/2 for a, b in zip(lo, hi, strict=True)]
                    for lo, hi in destination])
    src_order = np.argsort(np.arctan2(src[:, 1], src[:, 0]))
    dst_order = np.argsort(np.arctan2(dst[:, 1], dst[:, 0]))
    for shift in range(9):
        perm = [0]*9
        for k, j in enumerate(dst_order):
            perm[int(j)] = int(src_order[(k+shift) % 9])
        aligned = src[perm]
        angle = np.arctan2(np.sum(aligned[:, 0]*dst[:, 1]-aligned[:, 1]*dst[:, 0]),
                           np.sum(aligned*dst))
        direction = rational_direction(Q(float(np.tan(angle/2))).limit_denominator(10**15))
        leaf = {"rotation": [str(v) for v in direction], "permutation": perm}
        if check_localization(boxes, radii, target, leaf):
            return leaf
    return None


def propose_residual_exclusion(boxes, radii, *, limit=18):
    """No boundary shortcut: |p|<=Rlo makes p internal for EVERY R in interval.

    Two non-boundary disks for radius R may cover the smaller Rlo boundary.
    Thus a single point at |p|=Rlo cannot exclude a whole radius interval.
    """
    floor = radius_interval(radii)[0]
    points = residual_candidates(boxes, floor, limit=limit)
    conflict = two_disk_obstruction(points)
    if conflict is None:
        return None
    # Keep only points used by the actual proof tree, not all proposed samples.
    # Re-solving the smaller set supplies a fresh independently replayable tree.
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
    reduced = [points[i] for i in indices]
    small = two_disk_obstruction(reduced)
    if small is not None:
        points, conflict = reduced, small
    return {"points": [[str(v) for v in p] for p in points], "conflict": conflict}


def check_residual_exclusion(boxes, radii, leaf):
    try:
        if set(leaf) != {"points", "conflict"}:
            return False
        floor = radius_interval(radii)[0]
        points = tuple(_point(p) for p in leaf["points"])
        return (all(check_witness(boxes, floor, p) is not None for p in points)
                and check_two_disk_obstruction(points, leaf["conflict"]))
    except (ValueError, TypeError, KeyError, IndexError, ZeroDivisionError):
        return False
