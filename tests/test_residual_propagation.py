"""Regression for forced residual assignment; failure never asserts coverage."""
import copy
import json
from fractions import Fraction as Q
from pathlib import Path

import numpy as np
import pytest

from circovcir.rank_duals import replay_rank_cover_payload
from circovcir.residual_propagation import (
    check_propagation,
    conflict_component,
    propose_propagation,
)

ROOT = Path(__file__).parents[1]


def data():
    path = ROOT / "experiments/2026-10-11-n11-b9-propagation/results/propagation-cover.json"
    return json.loads(path.read_text())


def genuine_leaf():
    for panel in data()["panels"]:
        for entry in panel["cases"]:
            if entry["leaf_type"] == "propagation" and any(
                    "force" in s for s in entry["leaf"]["steps"]):
                return entry["polar"], Q(panel["radii"][0]), entry["leaf"]
    raise AssertionError("expected an actual forced-assignment derivation")


@pytest.mark.parametrize("n", [1, 3, 4, 7])
def test_known_covers_not_excluded_after_removing_two_centers(n):
    # The remaining sectors enclose the exact known outer centers. Up to two
    # removed disks still cover the residual, so propagation must not exclude.
    known = json.loads((ROOT / f"data/configs/{n:02d}/known.json").read_text())
    polar = []
    for point in known["centers"][2:]:
        p = np.array(point, float)
        s, t = float(np.linalg.norm(p)), float(np.arctan2(p[1], p[0]))
        eps = Q(1, 10**10)  # safely larger than float/stored decimal error
        polar.append(((max(0, Q(s)-eps), Q(s)+eps), (Q(t)-eps, Q(t)+eps)))
    radius = Q(known["R"])-Q(1, 10**10)
    assert propose_propagation(polar, radius, rounds=2, seed_limit=12, extra_limit=6) is None


def test_connected_component_includes_only_forced_vertices():
    p = [(0, 0), (3, 0), (Q(3, 2), 0)]
    chosen, tree = conflict_component(p)
    assert len(chosen) == 2 and tree == [[1, 0]]
    assert conflict_component([(0, 0)]) is None
    assert conflict_component([(0, 0), (2, 0)]) is None  # exact tangency is NOT conflict


def test_full_propagation_cover_replay():
    assert replay_rank_cover_payload(data())
    polar, radius, leaf = genuine_leaf()
    assert check_propagation(polar, radius, leaf)
    # Successful prefix bounds are not a contradiction.
    unfinished = copy.deepcopy(leaf)
    unfinished["steps"].pop()
    assert not check_propagation(polar, radius, unfinished)


@pytest.mark.parametrize("change", ["outside_seed", "tree_gap", "wrong_edge", "negative_dual",
                                    "fake_force", "wrong_color", "trailing", "no_terminal"])
def test_propagation_corruption_fails_closed(change):
    polar, radius, leaf = genuine_leaf()
    leaf = copy.deepcopy(leaf)
    if change == "outside_seed":
        leaf["seed_points"][0] = ["10", "10"]
    elif change == "tree_gap":
        leaf["seed_tree"].pop()
    elif change == "wrong_edge":
        leaf["seed_tree"][0] = [1, 1]
    elif change == "negative_dual":
        step = next(s for s in leaf["steps"] if "bound" in s)
        step["bound"]["certificate"]["duals"][0][0][1] = "-1"
    elif change == "fake_force":
        step = next(s for s in leaf["steps"] if "force" in s)
        step["force"]["point"] = ["0", "0"]
    elif change == "wrong_color":
        step = next(s for s in leaf["steps"] if "force" in s)
        step["force"]["excluded"] = 3
    elif change == "trailing":
        leaf["steps"].append(leaf["steps"][0])
    else:
        leaf["steps"] = [s for s in leaf["steps"] if "bound" in s]
    assert not check_propagation(polar, radius, leaf)


def test_cover_manifest_rejects_unknown_leaf_type():
    payload = data()
    payload["panels"][0]["cases"][0]["leaf_type"] = "success_by_budget"
    assert not replay_rank_cover_payload(payload)
