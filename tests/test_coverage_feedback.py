"""Coverage feedback preserves all assignments; corruption must fail closed."""
import copy
import json
from fractions import Fraction as Q
from pathlib import Path

import numpy as np
import pytest
from scipy.optimize import linprog

from circovcir.b9_rank import rank_edges
from circovcir.coverage_feedback import (
    _rank_impossible,
    propose_feedback,
    replay_feedback,
    replay_feedback_cover,
    replay_feedback_domain,
)

ROOT = Path(__file__).parents[1]


def data():
    return json.loads((ROOT / "experiments/2026-10-11-n11-b9-feedback/results/"
                      "feedback-cover.json").read_text())


def genuine_entry():
    payload = data()
    entry = next(e for e in payload["cases"] if e["domain"]["root"]["rank"] == [1, 5])
    return payload["radii"], entry


@pytest.mark.parametrize("n", [1, 3, 4, 7])
def test_known_cover_calibration(n):
    known = json.loads((ROOT / f"data/configs/{n:02d}/known.json").read_text())
    groups = []
    for center in known["centers"][2:]:
        c = np.array(center, float)
        r, a = Q(float(np.linalg.norm(c))), Q(float(np.arctan2(c[1], c[0])))
        eps = Q(1, 10**10)
        groups.append([((max(0, r-eps), r+eps), (a-eps, a+eps))])
    # Pad to the API's nine outer labels by unused distant disks. Cover remains.
    while len(groups) < 9:
        groups.append([((Q(10), Q(11)), (Q(0), Q(1)))])
    rr = Q(known["R"])-Q(1, 10**10)
    leaf = propose_feedback(groups, rr, rounds=2, seed_limit=12)
    assert leaf["status"] == "unresolved"
    if "steps" in leaf:
        checked = replay_feedback(groups, rr, leaf)
        assert checked is not None and not checked[0]


def test_all_saved_domains_replay():
    assert replay_feedback_cover(data())


@pytest.mark.parametrize("change", ["missing_seed_edge", "false_seed", "wrong_owner",
                                    "no_inner_conflict", "fake_inner_conflict", "unforced_prune",
                                    "duplicate_prune", "fake_rank_prune", "fake_mass",
                                    "trailing_step", "missing_terminal", "fake_sector_link"])
def test_corrupt_feedback_rejected(change):
    radii, entry = genuine_entry()
    entry = copy.deepcopy(entry)
    leaf = entry["leaf"]
    if change == "missing_seed_edge":
        leaf["seed_tree"].pop()
    elif change == "false_seed":
        leaf["seed_points"][0] = ["100", "0"]
    elif change == "wrong_owner":
        next(s["force"] for s in leaf["steps"] if "force" in s)["owner"] = 12
    elif change == "no_inner_conflict":
        next(s["force"] for s in leaf["steps"] if "force" in s)["inner_conflicts"] = []
    elif change == "fake_inner_conflict":
        next(s["force"] for s in leaf["steps"] if "force" in s)["inner_conflicts"] = [
            [9, [0, 0]], [10, [0, 0]]]
    elif change == "unforced_prune":
        leaf["steps"] = [next(s for s in leaf["steps"] if "prune" in s)]
    elif change == "duplicate_prune":
        obj = next(s["prune"] for s in leaf["steps"] if "prune" in s)
        obj["pieces"].append(obj["pieces"][0])
    elif change == "fake_rank_prune":
        leaf["steps"] = [{"rank_prune": {"owner": 0, "piece": 0}}]
    elif change == "fake_mass":
        leaf["steps"] = [{"mass": True}]
    elif change == "trailing_step":
        leaf["steps"].append(leaf["steps"][0])
    elif change == "missing_terminal":
        leaf["steps"].pop()
    else:
        entry["domain"]["pieces"][0][0]["parameter"] = ["1", "1"]
    assert replay_feedback_domain(radii, entry) is None


def test_prefix_is_contraction_not_exclusion():
    radii, entry = genuine_entry()
    entry = copy.deepcopy(entry)
    leaf = entry["leaf"]
    idx = next(i for i, s in enumerate(leaf["steps"]) if "prune" in s)
    leaf["steps"] = leaf["steps"][:idx+1]
    leaf["status"] = "unresolved"
    result = replay_feedback_domain(radii, entry)
    assert result is not None and not result[0]
    assert sum(map(len, result[1])) < 72
    payload = data()
    payload["cases"][0] = entry
    assert not replay_feedback_cover(payload)


def test_rank_pruning_against_independent_linear_program():
    radii, entry = genuine_entry()
    params = [[tuple(map(Q, p["parameter"])) for p in g] for g in entry["domain"]["pieces"]]
    rng = np.random.default_rng(2020)
    rank = (1, 5)
    matrix = [np.ones(9)]
    for a, b in rank_edges(rank):
        row = np.zeros(9)
        row[b], row[a] = 1, -1
        matrix.append(row)
    for _ in range(20):
        active = [sorted(rng.choice(8, size=int(rng.integers(1, 9)), replace=False).tolist())
                  for j in range(9)]
        owner = int(rng.integers(9))
        piece = active[owner][0]
        if not _rank_impossible(params, active, rank, owner, piece):
            continue
        bounds = [(min(params[j][k][0] for k in ids), max(params[j][k][1] for k in ids))
                  for j, ids in enumerate(active)]
        bounds[owner] = params[owner][piece]
        lp = linprog(np.zeros(9), A_ub=matrix, b_ub=[1]+[0]*8,
                     bounds=np.array(bounds, float), method="highs")
        assert lp.status == 2


@pytest.mark.parametrize("change", ["missing_rank", "duplicate_rank", "unsupported_radius"])
def test_incomplete_cover_manifest_rejected(change):
    payload = data()
    if change == "missing_rank":
        payload["cases"].pop()
    elif change == "duplicate_rank":
        payload["cases"][0] = payload["cases"][1]
    else:
        payload["radii"] = ["2", "3"]
    assert not replay_feedback_cover(payload)
