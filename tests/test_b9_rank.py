"""Rank coverage, exact LP dual replay, and polar residual lower bounds."""
import copy
import json
from fractions import Fraction as Q
from pathlib import Path

import numpy as np
import pytest
from scipy.optimize import linprog

from circovcir.b9_rank import contract_ranked, rank_cases
from circovcir.b9_search import replay_ranked_cover
from circovcir.exclusion import box_distance2, distance2
from circovcir.ordered_arcs import global_simplex, radial_order_floors
from circovcir.rank_duals import (
    check_rank_duals,
    propose_rank_duals,
    rank_planes,
    replay_rank_cover_payload,
)
from circovcir.sector_exclusion import sector_distance2

ROOT = Path(__file__).parents[1]


@pytest.mark.parametrize("n", [1, 3, 4, 7])
def test_sector_distance_never_rejects_known_centers(n):
    data = json.loads((ROOT / f"data/configs/{n:02d}/known.json").read_text())
    for center in data["centers"]:
        c = np.array(center, float)
        radius, angle = float(np.linalg.norm(c)), float(np.arctan2(c[1], c[0]))
        sector = ((max(Q(0), Q(radius)-Q(1, 10**12)), Q(radius)+Q(1, 10**12)),
                  (Q(angle)-Q(1, 10**12), Q(angle)+Q(1, 10**12)))
        for v in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
            p = tuple(Q(a)+Q(999, 1000)*b for a, b in zip(center, v, strict=True))
            assert sector_distance2(p, sector) < 1


def test_sector_separates_what_rectangle_loses():
    sector = ((Q(2), Q(2)), (Q(0), Q(1)))
    assert sector_distance2((0, 0), sector) == 4
    # The coarse rectangle [1,2]x[0,2] admits a fictitious radius-1 center.
    assert box_distance2((Q(0), Q(0)), ((Q(1), Q(0)), (Q(2), Q(2)))) == 1
    assert sector_distance2((1, 0), ((2, 2), (0, 0))) <= 1
    with pytest.raises(ValueError):
        sector_distance2((0, 0), ((2, 1), (0, 1)))
    rng = np.random.default_rng(1616)
    for _ in range(20):
        p = tuple(Q(int(v), 5) for v in rng.integers(-12, 13, 2))
        sector = ((Q(3, 2), Q(5, 2)), (Q(-1, 2), Q(1, 2)))
        lower = sector_distance2(p, sector)
        for s in (1.5, 2.0, 2.5):
            for theta in np.linspace(-0.5, 0.5, 9):
                c = (Q(float(s*np.cos(theta))), Q(float(s*np.sin(theta))))
                assert float(lower) <= float(distance2(p, c))+1e-14


def test_rank_contractor_checked_against_lp_all_cases_and_ties():
    rr = (Q("2.76"), Q("2.765"))
    floors = radial_order_floors(rr)
    for rank in rank_cases():
        b = contract_ranked(rr, global_simplex(rr), rank)
        assert b is not None
        cert = propose_rank_duals(rr, rank, b)
        assert cert is not None and check_rank_duals(floors, rank, b, cert["duals"])
    # Independently test non-root boxes: the proposed contraction must enclose
    # every LP feasible extreme of the exact input planes and box.
    rng = np.random.default_rng(16)
    for _ in range(8):
        rank = (4, 6)
        b = list(global_simplex(rr))
        for k in range(18):
            b[k] = (Q(0), min(b[k][1], Q(int(rng.integers(1, 10)), 10)))
        ps = rank_planes(floors, rank)
        matrix = -np.array([p[0] for p in ps], float)
        rhs = -np.array([p[1] for p in ps], float)
        contracted = contract_ranked(rr, b, rank)
        for k in (0, 4, 6, 10):
            for sign in (1, -1):
                cost = np.zeros(18)
                cost[k] = sign
                solve = linprog(cost, A_ub=matrix, b_ub=rhs,
                                bounds=[(float(a), float(z)) for a, z in b], method="highs")
                if solve.success:
                    assert contracted is not None
                    assert float(contracted[k][0])-1e-12 <= solve.x[k]
                    assert solve.x[k] <= float(contracted[k][1])+1e-12
    # Tie case: all three largest deficits equal. No strict order is allowed.
    x = [Q(0)]*18
    x[0] = x[4] = x[6] = Q(1, 3)
    assert contract_ranked(Q("2.64"), [(v, v) for v in x], (4, 6)) is not None
    assert contract_ranked(Q("2.64"), [(v, v) for v in x], (6, 4)) is not None
    with pytest.raises(ValueError):
        contract_ranked(rr, b, (4, 4))


def payload():
    path = ROOT / "experiments/2026-10-11-n11-b9-rank/results/rank-cover.json"
    return json.loads(path.read_text())


def test_full_saved_certificate_and_corrupt_duals():
    data = payload()
    assert replay_rank_cover_payload(data)
    entry = data["panels"][0]["cases"][0]
    assert check_rank_duals(entry["floors"], entry["rank"], entry["bounds"], entry["duals"])
    bad = copy.deepcopy(entry["duals"])
    bad[0][0][1] = "-1"
    assert not check_rank_duals(entry["floors"], entry["rank"], entry["bounds"], bad)


@pytest.mark.parametrize("change", ["rank_gap", "duplicate_rank", "radius_gap", "point", "floor"])
def test_full_cover_rejects_missing_domains_and_false_points(change):
    data = payload()
    if change == "rank_gap":
        data["panels"][0]["cases"].pop()
    elif change == "duplicate_rank":
        data["panels"][0]["cases"][0]["rank"] = [1, 3]
    elif change == "radius_gap":
        data["panels"][0]["radii"][0] = "2.761"
    elif change == "point":
        data["panels"][0]["cases"][0]["leaf"]["points"][0] = ["100", "0"]
    else:
        data["panels"][0]["cases"][0]["floors"][0] = "1"
    assert not replay_rank_cover_payload(data)
    assert not replay_ranked_cover({"radii": ["2.76", "2.77"], "cases": []}, {})
