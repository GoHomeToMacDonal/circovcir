"""Exact two-center residual propagation beyond a fixed finite obstruction.

A connected pair-conflict tree fixes disk labels up to interchange. Assigned
points yield GLOBAL necessary center boxes via exact LP duals. A point missed
by the outer sectors and one entire center box must belong to the other disk.
No presumed inner-center positions, symmetry, or contact graph is used.
"""
from __future__ import annotations

from fractions import Fraction as Q
from itertools import combinations

import numpy as np
from scipy.optimize import minimize

from .exclusion import _point, box_distance2, distance2, unit_disk_conflict
from .lifting import center_box_certificate, check_center_box_certificate
from .sector_exclusion import check_sector_points, sector_candidates


def conflict_component(points):
    """Propose a maximal connected pair-conflict component and its spanning tree."""
    p = tuple(_point(q) for q in points)
    neighbors = [[] for _ in p]
    for i, j in combinations(range(len(p)), 2):
        if distance2(p[i], p[j]) > 4:
            neighbors[i].append(j)
            neighbors[j].append(i)
    seen, components = set(), []
    for start in range(len(p)):
        if start in seen:
            continue
        queue, edges = [start], []
        seen.add(start)
        for j in queue:
            for i in neighbors[j]:
                if i not in seen:
                    seen.add(i)
                    queue.append(i)
                    edges.append((i, j))
        components.append((queue, edges))
    if not components:
        return None
    ids, edges = max(components, key=lambda c: len(c[0]))
    if len(ids) < 2:
        return None
    relabel = {old: new for new, old in enumerate(ids)}
    return [p[i] for i in ids], [[relabel[i], relabel[j]] for i, j in edges]


def propose_reference(points):
    """Float minimax reference only; an arbitrary reference is valid in replay."""
    p = np.array(points, float)
    mean = p.mean(axis=0)
    initial = np.r_[mean, np.max(np.sum((p-mean)**2, axis=1))]
    solve = minimize(lambda x: x[2], initial, method="SLSQP",
                     constraints=[{"type": "ineq", "fun": lambda x:
                                   x[2]-np.sum((p-x[:2])**2, axis=1)}],
                     options={"ftol": 1e-12, "maxiter": 100})
    chosen = solve.x[:2] if np.all(np.isfinite(solve.x)) else mean
    return tuple(Q(round(float(x)*10**10), 10**10) for x in chosen)


def _one_disk_conflict(points):
    for size in (2, 3):
        for ids in combinations(range(len(points)), size):
            if unit_disk_conflict([points[i] for i in ids]):
                return list(ids)
    return None


def propose_propagation(polar, radius_floor, *, rounds=4, seed_limit=24, extra_limit=12):
    """Find a finite derivation; failure means unresolved, not feasible."""
    seeds = sector_candidates(polar, radius_floor, limit=seed_limit)
    component = conflict_component(seeds)
    if component is None:
        return None
    seeds, tree = component
    colors = [None]*len(seeds)
    colors[0] = 0
    for i, j in tree:
        colors[i] = 1-colors[j]
    assigned = [[p for p, color in zip(seeds, colors, strict=True) if color == k]
                for k in (0, 1)]
    cert = {"seed_points": [[str(x) for x in p] for p in seeds],
            "seed_tree": tree, "steps": []}
    boxes = [None, None]
    for iteration in range(rounds):
        for k in (0, 1):
            conflict = _one_disk_conflict(assigned[k])
            if conflict is not None:
                cert["steps"].append({"conflict": {"color": k, "indices": conflict}})
                return cert
            bound = center_box_certificate(assigned[k], propose_reference(assigned[k]))
            if bound is None:
                return None
            boxes[k] = check_center_box_certificate(assigned[k], bound)
            cert["steps"].append({"bound": {"color": k, "certificate": bound}})
        progress = False
        for excluded in (iteration % 2, 1-iteration % 2):
            candidates = sector_candidates(polar, radius_floor, limit=extra_limit,
                                           excluded_boxes=[boxes[excluded]])
            for p in candidates:
                if p in assigned[1-excluded] or box_distance2(p, boxes[excluded]) <= 1:
                    continue
                if box_distance2(p, boxes[1-excluded]) > 1:
                    cert["steps"].append({"hole": [str(x) for x in p]})
                    return cert
                cert["steps"].append({"force": {"excluded": excluded,
                                                 "point": [str(x) for x in p]}})
                assigned[1-excluded].append(p)
                progress = True
        if not progress:
            return None
    return None


def check_propagation(polar, radius_floor, certificate, *, dps=60):
    """Replay all derivation steps, independently of reference/point proposals."""
    try:
        if set(certificate) != {"seed_points", "seed_tree", "steps"}:
            return False
        seeds = tuple(_point(p) for p in certificate["seed_points"])
        if len(seeds) < 2 or not check_sector_points(polar, radius_floor, seeds, dps=dps):
            return False
        colors = [None]*len(seeds)
        colors[0] = 0
        for i, j in certificate["seed_tree"]:
            if (type(i) is not int or type(j) is not int
                    or not 0 <= i < len(seeds) or not 0 <= j < len(seeds)
                    or colors[i] is not None or colors[j] is None
                    or distance2(seeds[i], seeds[j]) <= 4):
                return False
            colors[i] = 1-colors[j]
        if any(c is None for c in colors) or set(colors) != {0, 1}:
            return False
        assigned = [[p for p, c in zip(seeds, colors, strict=True) if c == k] for k in (0, 1)]
        boxes = [None, None]
        steps = certificate["steps"]
        for index, step in enumerate(steps):
            if set(step) == {"bound"}:
                k = step["bound"]["color"]
                if type(k) is not int or k not in (0, 1):
                    return False
                boxes[k] = check_center_box_certificate(assigned[k], step["bound"]["certificate"])
                if boxes[k] is None:
                    return False
            elif set(step) == {"force"}:
                k = step["force"]["excluded"]
                p = _point(step["force"]["point"])
                if (type(k) is not int or k not in (0, 1) or boxes[k] is None
                        or not check_sector_points(polar, radius_floor, [p], dps=dps)
                        or box_distance2(p, boxes[k]) <= 1):
                    return False
                assigned[1-k].append(p)
            elif set(step) == {"hole"}:
                p = _point(step["hole"])
                return (index == len(steps)-1 and all(b is not None for b in boxes)
                        and check_sector_points(polar, radius_floor, [p], dps=dps)
                        and all(box_distance2(p, b) > 1 for b in boxes))
            elif set(step) == {"conflict"}:
                k, ids = step["conflict"]["color"], step["conflict"]["indices"]
                if (index != len(steps)-1 or type(k) is not int or k not in (0, 1)
                        or len(ids) not in (2, 3) or len(set(ids)) != len(ids)
                        or any(type(i) is not int or not 0 <= i < len(assigned[k]) for i in ids)):
                    return False
                return unit_disk_conflict([assigned[k][i] for i in ids])
            else:
                return False
        return False
    except (TypeError, ValueError, KeyError, IndexError, ArithmeticError):
        return False
