"""Tests for necessary center localization, not a new positive cover verifier."""
import copy
import json
from fractions import Fraction as Q
from pathlib import Path

import numpy as np
import pytest

from circovcir.exclusion import box_distance2, distance2, rational_direction
from circovcir.lifting import (
    center_box,
    center_box_certificate,
    center_polygon,
    check_center_box_certificate,
    check_two_center_lift,
    square_box,
)

ROOT = Path(__file__).parents[1]


@pytest.mark.parametrize("n", [1, 3, 4, 7])
def test_known_centers_survive_assigned_point_bounds(n):
    """Rational enclosure contains exact known centers despite decimal truncation.

    Points are rational and slightly INSIDE disks; decimal center error is much
    smaller than their inward offset. Contractor must not delete the known root.
    """
    data = json.loads((ROOT / f"data/configs/{n:02d}/known.json").read_text())
    for p in data["centers"]:
        c = tuple(map(Q, p))
        points = [tuple(a+Q(999, 1000)*u for a, u in zip(c, v, strict=True))
                  for v in [(1, 0), (0, 1), (-1, 0), (0, -1)]]
        cert = center_box_certificate(points, c)
        box = check_center_box_certificate(points, cert)
        assert box is not None
        # Test all corners of a rigorously generous enclosure of decimal error.
        for signx in [-1, 1]:
            for signy in [-1, 1]:
                exact_enclosure_corner = (c[0]+signx*Q(1, 10**35), c[1]+signy*Q(1, 10**35))
                assert box_distance2(exact_enclosure_corner, box) == 0


def test_support_bound_is_global_not_reference_neighborhood():
    points = [(Q(3, 5), Q(4, 5)), (-1, 0), (0, -1)]
    for reference in [(0, 0), (5, -9), (100, 100), (-7, -2)]:
        cert = center_box_certificate(points, reference)
        box = check_center_box_certificate(points, cert)
        assert box is not None and box_distance2((Q(0), Q(0)), box) == 0
    cert = center_box_certificate([(1, 0), (-1, 0), (0, 1), (0, -1)], (0, 0))
    assert check_center_box_certificate([(1, 0), (-1, 0), (0, 1), (0, -1)], cert) == (
        (0, 0), (0, 0))
    assert center_box([(-1, 0), (1, 0)], (0, 0)) == ((0, -1), (0, 1))
    line_cert = center_box_certificate([(-1, 0), (1, 0)], (0, 0))
    assert check_center_box_certificate([(-1, 0), (1, 0)], line_cert) == ((0, -1), (0, 1))
    assert center_polygon([(2, 0), (-2, 0)], (0, 0)) == ()
    assert center_box([(2, 0), (-2, 0)], (0, 0)) is None
    assert center_box_certificate([(2, 0), (-2, 0)], (0, 0)) is None
    with pytest.raises(ValueError):
        center_box([], (0, 0))
    with pytest.raises(ValueError):
        square_box((0, 0), -1)


def test_rational_feasible_centers_preserved_for_arbitrary_reference():
    rng = np.random.default_rng(1414)
    for _ in range(15):
        c = tuple(Q(int(x), 4) for x in rng.integers(-8, 9, 2))
        ref = tuple(Q(int(x), 2) for x in rng.integers(-8, 9, 2))
        points = [tuple(x+Q(4, 5)*y for x, y in zip(c, rational_direction(t), strict=True))
                  for t in [Q(-3), Q(-1), Q(0), Q(1), Q(3)]]
        assert all(distance2(p, c) <= 1 for p in points)
        cert = center_box_certificate(points, ref)
        box = check_center_box_certificate(points, cert)
        assert box is not None and box_distance2(c, box) == 0


def test_dual_replay_rejects_tampering_and_accepts_outward_widening():
    p = [(Q(9, 10), 0), (0, Q(9, 10)), (Q(-9, 10), 0), (0, Q(-9, 10))]
    original = center_box_certificate(p, (0, 0))
    assert check_center_box_certificate(p, original) is not None
    for change in ["negative_weight", "index", "tightened_box", "wrong_normal", "missing_face"]:
        cert = copy.deepcopy(original)
        if change == "negative_weight":
            cert["duals"][0][0][1] = "-1"
        elif change == "index":
            cert["duals"][0][0][0] = -1
        elif change == "tightened_box":
            cert["box"][0][0] = str(Q(cert["box"][0][0])+Q(1, 1000000))
        elif change == "wrong_normal":
            cert["duals"][0] = cert["duals"][1]
        else:
            cert["duals"].pop()
        assert check_center_box_certificate(p, cert) is None, change
    wide = copy.deepcopy(original)
    wide["box"] = [["-2", "-2"], ["2", "2"]]
    assert check_center_box_certificate(p, wide) == ((-2, -2), (2, 2))
    assert check_center_box_certificate(p, {}) is None


def saved_lift():
    path = ROOT / "experiments/2026-10-11-n11-inner-lift/results/lift.json"
    return json.loads(path.read_text())


def test_saved_n11_lift_exact_replay_and_enlarged_domain_failure():
    data = saved_lift()
    checked = check_two_center_lift(data["outer_boxes"], data["radius_floor"], data["certificate"])
    assert checked is not None
    for i, box in enumerate(checked[:2]):
        anchor = tuple(map(Q, data["anchor_centers"][i]))
        assert all(abs(box[j][k]-anchor[k]) < Q(1, 500000) for j in (0, 1) for k in (0, 1))
    broad = [square_box(tuple(map(Q, p)), Q(1, 1000)) for p in data["anchor_centers"][2:]]
    assert check_two_center_lift(broad, data["radius_floor"], data["certificate"]) is None


@pytest.mark.parametrize("change", ["outside_target", "not_residual", "missing_edge", "false_edge",
                                    "negative_dual", "wrong_extra", "wrong_radius"])
def test_lift_replay_fail_closed(change):
    data = saved_lift()
    cert = data["certificate"]
    if change == "outside_target":
        cert["points"][0] = ["10", "10"]
    elif change == "not_residual":
        cert["points"][0] = data["anchor_centers"][2]
    elif change == "missing_edge":
        cert["color_tree"].pop()
    elif change == "false_edge":
        cert["color_tree"][0] = [1, 1]
    elif change == "negative_dual":
        cert["first_bound"]["duals"][0][0][1] = "-1"
    elif change == "wrong_extra":
        cert["second_points"][0] = data["anchor_centers"][0]
    else:
        cert["radius_point"] = ["0", "0"]
    assert check_two_center_lift(data["outer_boxes"], data["radius_floor"], cert) is None
