"""Radius-uniform exclusions and localization-to-target, never sample coverage."""
import copy
import json
from fractions import Fraction as Q
from pathlib import Path

import numpy as np
import pytest

from circovcir.b9_search import localize_b9, replay_b9_localization
from circovcir.branchbound import exclude_ordered_domain, replay_ordered_exclusion
from circovcir.exclusion import box_distance2, rational_direction
from circovcir.lifting import square_box
from circovcir.localization import (
    check_localization,
    check_residual_exclusion,
    propose_localization,
    rotate_boxes,
)
from circovcir.ordered_arcs import (
    contract_radial_order,
    decode_float,
    global_simplex,
    ordered_center_boxes,
    radial_order_floors,
)

ROOT = Path(__file__).parents[1]
RESULTS = ROOT / "experiments/2026-10-11-n11-b9-localization/results"


def target():
    path = ROOT / "experiments/2026-10-11-n11-inner-lift/results/lift.json"
    return json.loads(path.read_text())


@pytest.mark.parametrize("n", [1, 3, 4, 7])
def test_exact_rotation_encloses_known_center_boxes(n):
    data = json.loads((ROOT / f"data/configs/{n:02d}/known.json").read_text())
    direction = rational_direction(Q(7, 11))
    centers = [tuple(map(Q, p)) for p in data["centers"]]
    # Decimal error enclosure is retained, including all four endpoint corners.
    boxes = [square_box(p, Q(1, 10**35)) for p in centers]
    rotated = rotate_boxes(boxes, direction)
    co, si = direction
    for (lo, hi), box in zip(boxes, rotated, strict=True):
        for x in (lo[0], hi[0]):
            for y in (lo[1], hi[1]):
                assert box_distance2((co*x-si*y, si*x+co*y), box) == 0
    with pytest.raises(ValueError):
        rotate_boxes(boxes, (Q(1), Q(1, 10**20)))


def test_broad_radius_boxes_enclose_points_including_zero_deficits():
    rng = np.random.default_rng(1515)
    rr = (Q("2.63169"), Q("2.786"))
    full = [(0, 1)]*18  # no radial order pruning, testing analytic enclosures only
    boxes = ordered_center_boxes(rr, full)
    for k in range(30):
        x = rng.dirichlet(np.ones(18))
        x[:9] = np.sort(x[:9])[::-1]
        if k % 2:
            x[1:9] = 0
            x /= x.sum()
        for r in (rr[0], rr[1], (rr[0]+rr[1])/2):
            centers = decode_float(r, x)
            assert all(float(lo[j]) <= p[j] <= float(hi[j])
                       for p, (lo, hi) in zip(centers, boxes, strict=True) for j in (0, 1))
    with pytest.raises(ValueError):
        ordered_center_boxes((3, 2), full)


def test_radial_order_does_not_fix_second_and_third_labels():
    rr = Q("2.78")
    floors = radial_order_floors(rr)
    assert 1 > sum(floors) > Q(9, 10)
    # Every choice of second/third index survives (there is NO reflection gauge).
    for i in range(1, 9):
        for j in range(1, 9):
            if i == j:
                continue
            x = [Q(0)]*18
            x[i], x[j] = floors[1], floors[2]
            x[0] = 1-x[i]-x[j]
            b = [(v, v) for v in x]
            assert contract_radial_order(rr, b) is not None
    b = [(0, 1)]*18
    for i in range(1, 9):
        b[i] = (0, floors[1]/2)
    assert contract_radial_order(rr, b) is None
    assert global_simplex(Q("2.8")) is None
    assert global_simplex(Q("2.82")) is None
    empty = exclude_ordered_domain(Q("2.8"), budget=1)
    assert empty["closed"]
    assert replay_ordered_exclusion(Q("2.8"), empty["bounds"], empty["tree"])
    assert not replay_ordered_exclusion(Q("2.7"), empty["bounds"], empty["tree"])


def test_exact_target_matching_and_bad_rotation_rejected():
    t = target()
    direction = rational_direction(Q(3, 7))
    small = [square_box(p, Q(1, 10**12)) for p in t["anchor_centers"][2:]]
    rotated = rotate_boxes(small, direction)
    perm = [2, 4, 1, 8, 0, 3, 5, 7, 6]
    boxes = [rotated[i] for i in perm]
    rr = (Q(t["radius_floor"]), Q("2.64"))
    leaf = propose_localization(boxes, rr, t)
    assert leaf is not None and check_localization(boxes, rr, t, leaf)
    bad = copy.deepcopy(leaf)
    bad["rotation"][0] = str(Q(bad["rotation"][0])+Q(1, 10**30))
    assert not check_localization(boxes, rr, t, bad)
    bad = copy.deepcopy(leaf)
    bad["permutation"][0] = bad["permutation"][1]
    assert not check_localization(boxes, rr, t, bad)
    assert not check_localization(boxes, (Q("2.63169"), Q("2.64")), t, leaf)
    wide = [square_box(p, Q(1, 1000)) for p in t["anchor_centers"][2:]]
    assert propose_localization(wide, rr, t) is None


def test_saved_local_leaf_replay_and_tampered_flags():
    t = target()
    result = json.loads((RESULTS / "local-tree.json").read_text())
    assert replay_b9_localization(result, t)
    for change in ("unresolved", "missing_child", "fake_rotation"):
        bad = copy.deepcopy(result)
        if change == "unresolved":
            bad["tree"] = {"unresolved": "budget"}
            bad["closed_to_target"] = True
        elif change == "missing_child":
            bad["tree"] = {"split": 18, "children": [result["tree"]]}
        else:
            bad["tree"]["localization"]["rotation"] = ["0", "0"]
        assert not replay_b9_localization(bad, t)
    # A true binary radius split with identical local leaves is valid too.
    split = copy.deepcopy(result)
    split["tree"] = {"split": 18, "children": [result["tree"], result["tree"]]}
    assert replay_b9_localization(split, t)


def test_global_partial_tree_and_radius_boundary_shortcut_rejected():
    t = target()
    result = localize_b9((Q("2.64"), Q("2.65")), t, budget=1)
    assert not result["closed_to_target"] and not replay_b9_localization(result, t)
    assert not check_residual_exclusion([((0, 0), (0, 0))]*9, (Q("2.7"), Q("2.8")),
                                        {"boundary_point": ["27/10", "0"]})
    with pytest.raises(ValueError):
        localize_b9((Q("2.7"), Q("2.71")), t, budget=0)
    for name in ("domain-0.json", "domain-1.json"):
        result = json.loads((RESULTS / name).read_text())
        assert replay_b9_localization(result, t)
        assert result["stats"]["localized"] == 0
