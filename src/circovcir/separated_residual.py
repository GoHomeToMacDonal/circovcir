"""Adaptive finite residual witnesses using exact line-separation decisions.

A positive finite cover only proposes new points outside those two disks. It is
NEVER a coverage claim for the target, nor a constraint on the true inner disks.
"""
from __future__ import annotations

from fractions import Fraction as Q

from .sector_exclusion import check_sector_points, sector_candidates
from .two_disk_separation import (
    canonical_points,
    check_separated_two_disks,
    separated_two_disks,
)


def compress_separation(points, decision):
    """Remove unused conflict points, regenerate ALL chambers on the smaller set."""
    points = canonical_points(points)
    if decision["kind"] != "excluded":
        return points, decision
    while True:
        used_edges = {i for pair in decision["chambers"] for i in pair}
        used = sorted({j for i in used_edges for j in decision["edges"][i]})
        if len(used) == len(points):
            return points, decision
        smaller = canonical_points(points[j] for j in used)
        new = separated_two_disks(smaller)
        if new["kind"] != "excluded":
            raise ArithmeticError("discarding unused points lost obstruction")
        points, decision = smaller, new


def propose_separated_residual(polar, radius_floor, *, seed_limit=48, rounds=6, extra_limit=8):
    """Return status excluded or unresolved with an auditable finite-point decision."""
    points = canonical_points(sector_candidates(polar, radius_floor, limit=seed_limit))
    history = []
    for iteration in range(rounds+1):
        decision = separated_two_disks(points)
        if not check_separated_two_disks(points, decision):
            raise ArithmeticError("finite decision failed independent replay")
        history.append({"points": len(points), "kind": decision["kind"]})
        if decision["kind"] == "excluded":
            points, decision = compress_separation(points, decision)
            return {"status": "excluded", "points": [[str(x) for x in p] for p in points],
                    "decision": decision, "history": history}
        if iteration == rounds:
            break
        centers = [tuple(map(Q, c)) for c in decision["centers"]]
        proposed = sector_candidates(polar, radius_floor, limit=extra_limit,
                                     excluded_boxes=[(c, c) for c in centers])
        augmented = canonical_points((*points, *proposed))
        if len(augmented) == len(points):
            break
        points = augmented
    return {"status": "unresolved", "points": [[str(x) for x in p] for p in points],
            "decision": decision, "history": history}


def check_separated_residual(polar, radius_floor, certificate):
    """Only a full negative finite-point certificate accepts as residual exclusion."""
    try:
        return (certificate["status"] == "excluded"
                and certificate["decision"]["kind"] == "excluded"
                and check_sector_points(polar, radius_floor, certificate["points"])
                and check_separated_two_disks(certificate["points"], certificate["decision"]))
    except (KeyError, ValueError, TypeError, IndexError, ArithmeticError):
        return False


def replay_separated_cover(payload):
    """Complete contiguous radius coverage and all 56 rank roots, fail closed."""
    from .b9_rank import rank_cases
    from .ordered_arcs import radius_interval
    from .sliced_sectors import check_sliced_domain

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
                polar = check_sliced_domain(rr, entry["domain"])
                if polar is None or not check_separated_residual(polar, rr[0], entry["leaf"]):
                    return False
        return previous == upper
    except (KeyError, ValueError, TypeError, IndexError, ArithmeticError):
        return False
