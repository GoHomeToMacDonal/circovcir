"""Exact line-separation decision, degenerate events, tangencies and replay."""
import copy
import json
from fractions import Fraction as Q
from itertools import combinations
from pathlib import Path

import numpy as np
import pytest

from circovcir.exclusion import distance2, two_disk_obstruction, unit_disk_conflict
from circovcir.two_disk_separation import (
    canonical_points,
    check_separated_two_disks,
    one_disk_decision,
    separated_two_disks,
    separator_slopes,
)

ROOT = Path(__file__).parents[1]


@pytest.mark.parametrize("n", [1, 3, 4, 7])
def test_known_disks_never_excluded(n):
    data = json.loads((ROOT / f"data/configs/{n:02d}/known.json").read_text())
    # Rational centers close to known centers; points lie strictly inside two
    # of the original covering disks. No n-disk problem is mislabeled two-disk.
    points = []
    for center in data["centers"][:2]:
        c = tuple(map(Q, center))
        points += [tuple(c[i]+Q(999, 1000)*v[i] for i in range(2))
                   for v in [(1, 0), (0, 1), (-1, 0), (0, -1)]]
    cert = separated_two_disks(points)
    assert cert["kind"] == "covered" and check_separated_two_disks(points, cert)


def test_one_disk_decision_exhaustive_helly_crosscheck():
    rng = np.random.default_rng(190019)
    for _ in range(80):
        points = [tuple(Q(int(x), 4) for x in p) for p in rng.integers(-5, 6, (8, 2))]
        result = one_disk_decision(points)
        impossible = any(unit_disk_conflict(subset) for size in (2, 3)
                         for subset in combinations(points, size))
        assert ("conflict" in result) == impossible
        if impossible:
            assert unit_disk_conflict([points[i] for i in result["conflict"]])
        else:
            assert all(distance2(p, result["center"]) <= 1 for p in points)
    assert one_disk_decision([]) == {"center": (0, 0)}


@pytest.mark.parametrize("points", [[], [(0, 0)], [(0, 0)]*4,
                                    [(-1, 0), (1, 0), (3, 0)],
                                    [(0, 0), (0, 2), (0, 4)],
                                    [(0, 0), (0, 3), (0, 6)],
                                    [(-1, -1), (-1, 1), (1, -1), (1, 1)],
                                    [(0, 0), (3, 0), (0, 3)],
                                    [(-3, -3), (-3, 3), (3, -3), (3, 3)]])
def test_degenerate_orders_and_exact_tangencies(points):
    cert = separated_two_disks(points)
    assert check_separated_two_disks(points, cert)
    assert (cert["kind"] == "excluded") == (two_disk_obstruction(points) is not None)


def test_random_comparison_with_independent_coloring_solver():
    rng = np.random.default_rng(1919)
    for _ in range(35):
        points = [tuple(Q(int(x), 5) for x in p) for p in rng.integers(-10, 11, (9, 2))]
        cert = separated_two_disks(points)
        assert check_separated_two_disks(points, cert)
        assert (cert["kind"] == "excluded") == (two_disk_obstruction(points) is not None)


def test_event_chambers_all_exact_and_no_projection_ties():
    points = canonical_points([(0, 0), (0, 2), (1, 0), (1, 2), (2, 1)])
    slopes = separator_slopes(points)
    events = {-(p[0]-q[0])/(p[1]-q[1]) for p, q in combinations(points, 2)
              if p[1] != q[1]}
    assert len(slopes) == len(events)+1
    for slope in slopes:
        assert len({p[0]+slope*p[1] for p in points}) == len(points)


@pytest.mark.parametrize("change", ["missing_chamber", "invalid_edge", "wrong_pair",
                                    "unknown_kind"])
def test_bad_negative_certificate_rejected(change):
    points = [(0, 0), (3, 0), (0, 3)]
    cert = copy.deepcopy(separated_two_disks(points))
    assert cert["kind"] == "excluded"
    if change == "missing_chamber":
        cert["chambers"].pop()
    elif change == "invalid_edge":
        cert["edges"][0] = [0, 0]
    elif change == "wrong_pair":
        cert["chambers"][0] = [0, 0]
    else:
        cert["kind"] = "budget_exhausted"
    assert not check_separated_two_disks(points, cert)


def test_saved_cover_and_unresolved_not_accepted():
    from circovcir.separated_residual import check_separated_residual, replay_separated_cover
    from circovcir.sliced_sectors import check_sliced_domain

    path = ROOT / "experiments/2026-10-11-n11-b9-separation/results/separated-cover.json"
    data = json.loads(path.read_text())
    assert replay_separated_cover(data)
    entry = data["panels"][0]["cases"][0]
    polar = check_sliced_domain(data["panels"][0]["radii"], entry["domain"])
    bad = copy.deepcopy(entry["leaf"])
    bad["status"] = "unresolved"
    assert not check_separated_residual(polar, Q("2.725"), bad)
    for change in ("missing_rank", "radius_gap", "fake_point", "positive_as_exclusion"):
        altered = copy.deepcopy(data)
        if change == "missing_rank":
            altered["panels"][0]["cases"].pop()
        elif change == "radius_gap":
            altered["panels"][0]["radii"][0] = "2.726"
        elif change == "fake_point":
            altered["panels"][0]["cases"][0]["leaf"]["points"][0] = ["100", "0"]
        else:
            altered["panels"][0]["cases"][0]["leaf"]["decision"] = {
                "kind": "covered", "centers": [["0", "0"], ["0", "0"]]}
        assert not replay_separated_cover(altered)


def test_known_residual_adaptive_proposer_does_not_exclude():
    from circovcir.separated_residual import check_separated_residual, propose_separated_residual

    # The origin disk covers radius 1; arbitrary outer sectors are irrelevant.
    polar = [((Q(3), Q(4)), (Q(0), Q(1)))]
    leaf = propose_separated_residual(polar, Q(1), seed_limit=12, rounds=2)
    assert leaf["status"] == "unresolved"
    assert not check_separated_residual(polar, Q(1), leaf)
    assert check_separated_two_disks(leaf["points"], leaf["decision"])


def test_bad_positive_certificate_rejected():
    points = [(0, 0), (3, 0)]
    cert = separated_two_disks(points)
    cert["centers"] = [["100", "0"], ["100", "0"]]
    assert not check_separated_two_disks(points, cert)
