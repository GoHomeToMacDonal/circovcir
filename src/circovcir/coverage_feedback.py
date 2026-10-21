"""Coverage-to-domain feedback with forced owners, not fixed uniform residuals.

Outer center j occupies ONE of its sectors. Seeds force the two inner labels up
to interchange. A target point missed by all other center domains is forced to
one owner; all incompatible sectors of that owner can then be deleted. Repeat.
Acceptance uses exact Helly conflicts, rigorous point/sector and point/box
bounds, and exact radial-order/total-mass implications. Floats only propose.
"""
from __future__ import annotations

from fractions import Fraction as Q

import numpy as np

from .exclusion import _point, box_distance2, distance2, rational_inside
from .lifting import center_box_certificate, check_center_box_certificate
from .residual_propagation import conflict_component, propose_reference
from .sector_exclusion import check_sector_points, sector_candidates, sector_distance2
from .two_disk_separation import one_disk_decision


def _float_sector_distances(points, polar):
    sectors = np.array(polar, float)
    norm = np.linalg.norm(points, axis=1)
    angle = np.arctan2(points[:, 1], points[:, 0])
    result = []
    for (lo, hi), (a, b) in sectors:
        diff = (angle-(a+b)/2+np.pi) % (2*np.pi)-np.pi
        delta = np.maximum(0, np.abs(diff)-(b-a)/2)
        projection = norm*np.cos(delta)
        closest = np.clip(projection, lo, hi)
        result.append(norm*norm+closest**2-2*closest*projection)
    return np.array(result).T


def _float_box_distances(points, box):
    lo, hi = np.array(box, float)
    return np.sum(np.maximum(np.maximum(lo-points, points-hi), 0)**2, axis=1)


def _cloud(groups, radius):
    angle = np.arange(192)*2*np.pi/192
    directions = np.column_stack([np.cos(angle), np.sin(angle)])
    clouds = [r*directions for r in np.linspace(0, float(radius), 45)]
    for group in groups:
        for (lo, hi), (a, b) in np.array(group, float):
            center = (lo+hi)/2*np.array([np.cos((a+b)/2), np.sin((a+b)/2)])
            clouds.append(center+1.001*directions)
    pts = np.vstack(clouds)
    return pts[np.sum(pts**2, axis=1) <= float(radius)**2]


def _seed_state(groups, radius, limit):
    polar = [s for group in groups for s in group]
    component = conflict_component(sector_candidates(polar, radius, limit=limit))
    if component is None:
        return None
    seeds, tree = component
    colors = [None]*len(seeds)
    colors[0] = 0
    for i, j in tree:
        colors[i] = 1-colors[j]
    assigned = [[] for _ in range(9)]+[
        [p for p, c in zip(seeds, colors, strict=True) if c == k] for k in (0, 1)]
    return seeds, tree, assigned


def _float_assigned_scores(points, assigned):
    """Proposal-only Helly conflict scores; hull points form a safe subset."""
    from itertools import combinations

    from scipy.spatial import ConvexHull, QhullError

    cloud = np.array(assigned, float)
    if len(cloud) >= 3:
        try:
            cloud = cloud[ConvexHull(cloud).vertices]
        except QhullError:
            pass
    distances = np.sum((points[:, None, :]-cloud[None, :, :])**2, axis=2)
    score = np.max(distances, axis=1)/4
    for i, j in combinations(range(len(cloud)), 2):
        a, b = distances[:, i], distances[:, j]
        c = np.sum((cloud[i]-cloud[j])**2)
        acute = (a+b > c) & (a+c > b) & (b+c > a)
        u, v = cloud[i]-points, cloud[j]-points
        cross = u[:, 0]*v[:, 1]-u[:, 1]*v[:, 0]
        radius2 = np.divide(a*b*c, 4*cross**2, out=np.zeros_like(a), where=cross != 0)
        score = np.maximum(score, np.where(acute, radius2, 0))
    return score


def _hull_decision(points):
    """A subset proposes conflicts; failure to find one proves nothing."""
    from scipy.spatial import ConvexHull, QhullError

    ids = list(range(len(points)))
    if len(ids) >= 3:
        try:
            ids = list(map(int, ConvexHull(np.array(points, float)).vertices))
        except QhullError:
            pass
    decision = one_disk_decision([points[i] for i in ids])
    return ({"conflict": [ids[i] for i in decision["conflict"]]}
            if "conflict" in decision else {})


def _mass_floor(parameters, active):
    return sum(min(Q(parameters[j][k][0]) for k in ids) for j, ids in enumerate(active))


def _rank_impossible(parameters, active, rank, owner, piece):
    """Necessary order/sum consistency with one proposed radial piece fixed."""
    from .b9_rank import rank_edges

    lower = [min(Q(parameters[j][s][0]) for s in ids) for j, ids in enumerate(active)]
    upper = [max(Q(parameters[j][s][1]) for s in ids) for j, ids in enumerate(active)]
    lower[owner], upper[owner] = map(Q, parameters[owner][piece])
    for _ in range(9):
        for a, b in rank_edges(rank):
            lower[a] = max(lower[a], lower[b])
            upper[b] = min(upper[b], upper[a])
    return sum(lower) > 1 or any(a > b for a, b in zip(lower, upper, strict=True))


def propose_feedback(groups, radius, *, rounds=8, seed_limit=48, per_round=12, helly=True,
                     parameters=None, rank=None):
    """Propose a replayable forced-ownership/sector-elimination derivation.

    On failure, return explicit unresolved status and the verified prefix. A
    prefix can prove necessary contraction, but is not an exclusion certificate.
    """
    groups = [[tuple(tuple(map(Q, p)) for p in s) for s in group] for group in groups]
    if len(groups) != 9 or any(not group for group in groups):
        raise ValueError("expected nine nonempty sector unions")
    initial = _seed_state(groups, radius, seed_limit)
    if initial is None:
        return {"status": "unresolved", "reason": "no_seed_component"}
    seeds, tree, assigned = initial
    cert = {"status": "unresolved", "seed_points": seeds, "seed_tree": tree, "steps": []}
    active = [list(range(len(g))) for g in groups]
    boxes = [None, None]
    points = _cloud(groups, radius)
    distances = [_float_sector_distances(points, group) for group in groups]
    for _iteration in range(rounds):
        if parameters is not None and rank is not None:
            for j in range(9):
                for s in active[j].copy():
                    if _rank_impossible(parameters, active, rank, j, s):
                        cert["steps"].append({"rank_prune": {"owner": j, "piece": s}})
                        active[j].remove(s)
                        if not active[j]:
                            cert["status"] = "excluded"
                            return cert
        if parameters is not None and _mass_floor(parameters, active) > 1:
            cert["steps"].append({"mass": True})
            cert["status"] = "excluded"
            return cert
        for owner in range(11):
            if not assigned[owner]:
                continue
            result = _hull_decision(assigned[owner])
            if "conflict" in result:
                cert["steps"].append({"conflict": {"owner": owner, "indices": result["conflict"]}})
                cert["status"] = "excluded"
                return cert
        if not helly:
            for k in range(2):
                bound = center_box_certificate(assigned[9+k], propose_reference(assigned[9+k]))
                if bound is None:
                    return cert
                boxes[k] = check_center_box_certificate(assigned[9+k], bound)
                cert["steps"].append({"bound": {"owner": 9+k, "certificate": bound}})
        inner_scores = ([_float_assigned_scores(points, assigned[k]) for k in (9, 10)] if helly
                        else [_float_box_distances(points, b) for b in boxes])
        scores = np.column_stack([np.min(d[:, ids], axis=1)
                                  for d, ids in zip(distances, active, strict=True)] + inner_scores)
        possible = scores <= 1+1e-7
        candidates = np.flatnonzero(possible.sum(axis=1) <= 1)
        # Prefer points that discard many currently allowed outer sectors.
        merit = np.zeros(len(points))
        for j in range(9):
            merit += (possible[:, j] & (possible.sum(axis=1) == 1))*np.mean(
                distances[j][:, active[j]] > 1+1e-10, axis=1)
        merit += (possible.sum(axis=1) == 0)*10
        # Prefer isolated constraints over many adjacent points in one cluster.
        merit += 0.1*np.minimum(np.partition(scores, 1, axis=1)[:, 1]-1, 1)
        candidates = candidates[np.argsort(-merit[candidates], kind="stable")]
        candidates = candidates[:96]  # proposal budget only; never used as a proof
        progress, added = False, 0
        for idx in candidates:
            p = rational_inside(points[idx], radius)
            owners = [j for j in range(9) if any(sector_distance2(p, groups[j][s]) <= 1
                                                for s in active[j])]
            inner_conflicts = []
            for k in (9, 10):
                if helly:
                    decision = _hull_decision([*assigned[k], p])
                    if "conflict" in decision:
                        inner_conflicts.append([k, decision["conflict"]])
                    else:
                        owners.append(k)
                elif box_distance2(p, boxes[k-9]) <= 1:
                    owners.append(k)
            if not owners:
                cert["steps"].append({"hole": {"point": p, "inner_conflicts": inner_conflicts}})
                cert["status"] = "excluded"
                return cert
            if len(owners) != 1:
                continue
            owner = owners[0]
            if p in assigned[owner]:
                continue
            removed = ([s for s in active[owner] if sector_distance2(p, groups[owner][s]) > 1]
                       if owner < 9 else [])
            if owner < 9 and not removed:
                continue
            cert["steps"].append({"force": {"owner": owner, "point": p,
                                             "inner_conflicts": inner_conflicts}})
            assigned[owner].append(p)
            if removed:
                cert["steps"].append({"prune": {"owner": owner, "point_index":
                                                 len(assigned[owner])-1, "pieces": removed}})
                active[owner] = [s for s in active[owner] if s not in removed]
            progress = True
            added += 1
            if added >= per_round:
                break
        if not progress:
            break
    if parameters is not None and _mass_floor(parameters, active) > 1:
        cert["steps"].append({"mass": True})
        cert["status"] = "excluded"
    return cert


def replay_feedback(groups, radius, certificate, *, parameters=None, rank=None):
    """Return (excluded, surviving piece indices, inner boxes), or None if invalid.

    The *entire* derivation, including status and terminal position, is checked.
    Valid unresolved prefixes certify only necessary conditions for a cover.
    If supplied, parameters[j][s] MUST be the already certified u_j interval
    attached to sector s, and rank MUST hold on the original domain. Use
    replay_feedback_domain for end-to-end validation of these hypotheses.
    """
    try:
        groups = [[tuple(tuple(map(Q, p)) for p in s) for s in group] for group in groups]
        radius = Q(radius)
        if len(groups) != 9 or any(not group for group in groups) or radius <= 0:
            return None
        if certificate["status"] not in ("excluded", "unresolved"):
            return None
        seeds = [_point(p) for p in certificate["seed_points"]]
        polar = [s for group in groups for s in group]
        if len(seeds) < 2 or not check_sector_points(polar, radius, seeds):
            return None
        colors = [None]*len(seeds)
        colors[0] = 0
        for i, j in certificate["seed_tree"]:
            if (type(i) is not int or type(j) is not int or not 0 <= i < len(seeds)
                    or not 0 <= j < len(seeds) or colors[i] is not None or colors[j] is None
                    or distance2(seeds[i], seeds[j]) <= 4):
                return None
            colors[i] = 1-colors[j]
        if any(c is None for c in colors) or set(colors) != {0, 1}:
            return None
        assigned = [[] for _ in range(9)]+[
            [p for p, c in zip(seeds, colors, strict=True) if c == k] for k in (0, 1)]
        active = [list(range(len(g))) for g in groups]
        boxes = [None, None]

        def missed(p, owner, inner_conflicts=()):
            from .exclusion import unit_disk_conflict

            if owner < 9:
                return all(sector_distance2(p, groups[owner][s]) > 1 for s in active[owner])
            for k, ids in inner_conflicts:
                if k != owner:
                    continue
                pool = [*assigned[k], p]
                if (len(ids) in (2, 3) and len(set(ids)) == len(ids)
                        and all(type(i) is int and 0 <= i < len(pool) for i in ids)
                        and unit_disk_conflict([pool[i] for i in ids])):
                    return True
            return boxes[owner-9] is not None and box_distance2(p, boxes[owner-9]) > 1

        for index, step in enumerate(certificate["steps"]):
            terminal = False
            if set(step) == {"bound"}:
                k = step["bound"]["owner"]
                if type(k) is not int or k not in (9, 10):
                    return None
                boxes[k-9] = check_center_box_certificate(assigned[k], step["bound"]["certificate"])
                if boxes[k-9] is None:
                    return None
            elif set(step) == {"force"}:
                k = step["force"]["owner"]
                p = _point(step["force"]["point"])
                if (type(k) is not int or not 0 <= k < 11 or distance2(p, (0, 0)) > radius**2
                        or not all(missed(p, j, step["force"].get("inner_conflicts", ()))
                                   for j in range(11) if j != k)):
                    return None
                assigned[k].append(p)
            elif set(step) == {"prune"}:
                obj = step["prune"]
                k, i, removed = obj["owner"], obj["point_index"], obj["pieces"]
                if (type(k) is not int or not 0 <= k < 9 or type(i) is not int
                        or not 0 <= i < len(assigned[k]) or not removed
                        or len(set(removed)) != len(removed)
                        or any(type(s) is not int or s not in active[k] for s in removed)):
                    return None
                if not all(sector_distance2(assigned[k][i], groups[k][s]) > 1 for s in removed):
                    return None
                active[k] = [s for s in active[k] if s not in removed]
                terminal = not active[k]
            elif set(step) == {"hole"}:
                p = _point(step["hole"]["point"])
                if (distance2(p, (0, 0)) > radius**2 or not all(
                        missed(p, j, step["hole"].get("inner_conflicts", ())) for j in range(11))):
                    return None
                terminal = True
            elif set(step) == {"rank_prune"}:
                obj = step["rank_prune"]
                k, s = obj["owner"], obj["piece"]
                if (parameters is None or rank is None or type(k) is not int or not 0 <= k < 9
                        or type(s) is not int or s not in active[k]
                        or not _rank_impossible(parameters, active, rank, k, s)):
                    return None
                active[k].remove(s)
                terminal = not active[k]
            elif set(step) == {"mass"}:
                if parameters is None or not all(active) or _mass_floor(parameters, active) <= 1:
                    return None
                terminal = True
            elif set(step) == {"conflict"}:
                from .exclusion import unit_disk_conflict
                obj = step["conflict"]
                k, ids = obj["owner"], obj["indices"]
                if (type(k) is not int or not 0 <= k < 11 or len(ids) not in (2, 3)
                        or len(set(ids)) != len(ids)
                        or any(type(i) is not int or not 0 <= i < len(assigned[k]) for i in ids)
                        or not unit_disk_conflict([assigned[k][i] for i in ids])):
                    return None
                terminal = True
            else:
                return None
            if terminal:
                return ((True, active, boxes) if certificate["status"] == "excluded"
                        and index == len(certificate["steps"])-1 else None)
        return (False, active, boxes) if certificate["status"] == "unresolved" else None
    except (ValueError, TypeError, KeyError, IndexError, ArithmeticError):
        return None


def replay_feedback_domain(radii, entry):
    """Validate sectors/parameter links and the rank theorem before feedback."""
    from .ordered_arcs import radius_interval
    from .sliced_sectors import check_sliced_domain

    try:
        rr = radius_interval(radii)
        domain = entry["domain"]
        if check_sliced_domain(rr, domain) is None:
            return None
        groups = [[p["sector"] for p in g] for g in domain["pieces"]]
        parameters = [[p["parameter"] for p in g] for g in domain["pieces"]]
        return replay_feedback(groups, rr[0], entry["leaf"], parameters=parameters,
                               rank=domain["root"]["rank"])
    except (ValueError, TypeError, KeyError, IndexError, ArithmeticError):
        return None


def replay_feedback_cover(payload):
    """Only all 56 rank roots excluded proves the whole supplied radius panel."""
    from .b9_rank import rank_cases
    from .ordered_arcs import radius_interval

    try:
        rr = radius_interval(payload["radii"])
        if rr[0] >= rr[1] or len(payload["cases"]) != 56:
            return False
        for rank, entry in zip(rank_cases(), payload["cases"], strict=True):
            if tuple(entry["domain"]["root"]["rank"]) != rank:
                return False
            replay = replay_feedback_domain(rr, entry)
            if replay is None or not replay[0]:
                return False
        return True
    except (ValueError, TypeError, KeyError, IndexError, ArithmeticError):
        return False
