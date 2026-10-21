"""Regression tests for exact box exclusions; no positive coverage claims."""

import copy
import json
from fractions import Fraction as Q
from pathlib import Path

import numpy as np
import pytest

from circovcir.branchbound import (
    b9_global_charts,
    exclude_chart_domain,
    replay_chart_exclusion,
)
from circovcir.exclusion import (
    box_distance2,
    chart_box,
    check_b9_exclusion,
    check_two_disk_obstruction,
    check_witness,
    distance2,
    propose_b9_exclusion,
    propose_witness,
    rational_direction,
    rational_inside,
    two_disk_obstruction,
    unit_disk_conflict,
)


@pytest.mark.parametrize("n", [1, 3, 4, 7])
def test_known_covers_not_excluded_and_enlarged_disks_are(n):
    """Boxes enclose the exact known centers, not just rounded approximations."""
    path = Path(__file__).parents[1] / f"data/configs/{n:02d}/known.json"
    data = json.loads(path.read_text())
    centers = [[Q(x) for x in p] for p in data["centers"]]
    eps = Q(1, 10**35)  # much larger than the stored decimal truncation error
    boxes = [(tuple(x-eps for x in p), tuple(x+eps for x in p)) for p in centers]
    # Stay below the exact radius by more than its stored decimal error.
    radius = Q(data["R"]) - eps
    assert propose_witness(boxes, radius, limit=None) is None
    witness = propose_witness(boxes, Q(data["R"])+Q(1, 10000))
    assert witness is not None
    assert check_witness(boxes, Q(data["R"])+Q(1, 10000), witness.point) == witness


def test_strict_inequality_and_target_membership():
    boxes = [((0, 0), (0, 0))]
    assert check_witness(boxes, 2, (1, 0)) is None
    assert check_witness(boxes, 2, (Q(3, 2), 0)).margin2 == Q(5, 4)
    assert check_witness(boxes, 1, (Q(3, 2), 0)) is None
    with pytest.raises(ValueError):
        check_witness([((1, 0), (0, 1))], 1, (0, 0))
    with pytest.raises(ValueError):
        check_witness([], 1, (0, 0))
    with pytest.raises(ValueError):
        propose_witness(boxes, 0)


def test_box_distance_is_minimum_not_midpoint():
    box = ((Q(0), Q(-1)), (Q(2), Q(1)))
    assert box_distance2((Q(1), Q(0)), box) == 0
    assert box_distance2((Q(3), Q(2)), box) == 2
    # Midpoint misses this point, but a center at the upper x endpoint covers it.
    assert check_witness([box], 4, (Q(5, 2), 0)) is None


def test_inward_rounding_is_exact():
    rng = np.random.default_rng(20261010)
    for p in rng.normal(size=(100, 2))*5:
        q = rational_inside(p, Q(13, 5))
        assert distance2(q, (Q(0), Q(0))) <= Q(13, 5)**2


def test_pair_triangle_and_degenerate_conflicts():
    assert unit_disk_conflict([(0, 0), (Q(2000001, 1000000), 0)])
    assert not unit_disk_conflict([(0, 0), (2, 0)])
    assert not unit_disk_conflict([(0, 0), (1, 0), (2, 0)])
    assert not unit_disk_conflict([(-1, 0), (1, 0), (0, 1)])  # radius exactly 1
    assert unit_disk_conflict([(-1, 0), (1, 0), (0, Q(6, 5))])
    assert not unit_disk_conflict([(0, 0), (0, 0), (1, 0)])


def test_two_center_obstruction_and_independent_replay():
    p = [(0, 0), (3, 0), (0, 3)]  # three pair conflicts: an odd cycle
    cert = two_disk_obstruction(p)
    assert cert is not None
    assert check_two_disk_obstruction(p, cert)
    corrupt = copy.deepcopy(cert)
    corrupt["edges"][0] = [0, 0]
    assert not check_two_disk_obstruction(p, corrupt)
    corrupt = copy.deepcopy(cert)
    corrupt["tree"]["forced"][0][1] = 0
    assert not check_two_disk_obstruction(p, corrupt)
    assert not check_two_disk_obstruction(p, {"edges": [], "tree": {"conflict": 0}})
    assert two_disk_obstruction([(0, 0), (1, 0), (4, 0), (5, 0)]) is None


def test_two_center_helly_edges_requiring_branching():
    # Random rational points: test the full solver against all 2-colorings.
    rng = np.random.default_rng(3)
    from itertools import combinations, product
    for _ in range(15):
        points = [tuple(Q(int(x), 4) for x in p) for p in rng.integers(-8, 9, (7, 2))]
        feasible = False
        for rest in product((0, 1), repeat=6):
            colors = (0, *rest)
            if all(not unit_disk_conflict([points[i] for i in e])
                   for k in (2, 3) for e in combinations(range(7), k)
                   if len({colors[i] for i in e}) == 1):
                feasible = True
                break
        cert = two_disk_obstruction(points)
        assert (cert is None) == feasible
        if cert is not None:
            assert check_two_disk_obstruction(points, cert)


def test_rational_chart_encloses_samples():
    base = rational_direction(Q(3, 4))
    box = chart_box((Q(3, 2), 2), (Q(-1, 8), Q(3, 8)), base)
    for j in range(17):
        t = Q(-1, 8)+Q(j, 32)
        x, y = rational_direction(t)
        for s in (Q(3, 2), Q(7, 4), Q(2)):
            p = (s*(base[0]*x-base[1]*y), s*(base[1]*x+base[0]*y))
            assert box_distance2(p, box) == 0
    exact = chart_box((2, 2), (0, 0), base)
    assert exact[0] == exact[1] == tuple(2*x for x in base)


def test_budget_and_tree_replay_fail_closed():
    center_at_origin = [{"radial": ["0", "0"], "tangent": ["0", "0"],
                         "base": ["1", "0"]}]
    result = exclude_chart_domain(center_at_origin, Q(11, 10), budget=1)
    assert result["closed"]
    assert replay_chart_exclusion(center_at_origin, Q(11, 10), result["tree"])
    assert not replay_chart_exclusion(center_at_origin, 1, result["tree"])
    # This domain includes a covering configuration, so it must not close.
    broad = [{"radial": ["0", "1/2"], "tangent": ["-1", "1"], "base": ["1", "0"]}]
    result = exclude_chart_domain(broad, 1, budget=3)
    assert not result["closed"]
    assert result["stats"]["unresolved"] > 0
    assert not replay_chart_exclusion(broad, 1, result["tree"])


def test_global_b9_root_charts_cover_both_semicircles():
    radius = Q("2.7")
    roots = b9_global_charts(radius)
    assert len(roots) == 9
    for left_count, charts in enumerate(roots):
        assert len(charts) == 9
        assert charts[0]["tangent"] == ["0", "0"]
        assert Q(charts[0]["radial"][1]) == 2
        assert sum(c["base"][0] == "-1" for c in charts) == left_count
        upper = Q(charts[-1]["radial"][1])
        assert upper**2 >= radius**2-1
        assert (upper-Q(1, 2**40))**2 < radius**2-1
    for j in range(-40, 41):
        point = rational_direction(Q(j, 10))
        # Right semicircle uses t=y/(1+x); left uses a pi-shifted point.
        sign = 1 if point[0] >= 0 else -1
        x, y = sign*point[0], sign*point[1]
        t = y/(1+x)
        assert -1 <= t <= 1
        assert tuple(sign*v for v in rational_direction(t)) == point


def test_b9_residual_proves_impossible_for_any_two_extra_disks():
    # Nine outer centers near radius 2.5 leave a radius-1.5 central hole.
    boxes = []
    for t in (Q(-4), Q(-2), Q(-1), Q(-1, 2), Q(0), Q(1, 2), Q(1), Q(2), Q(4)):
        base = rational_direction(t)
        boxes.append(chart_box((Q(5, 2), Q(5, 2)), (0, 0), base))
    # Three points in the central hole with all pair distances greater than two.
    residual = [(Q(7, 5), 0), (Q(-4, 5), Q(11, 10)),
                (Q(-4, 5), Q(-11, 10))]
    conflict = two_disk_obstruction(residual)
    cert = {"residual_points": [[str(x) for x in p] for p in residual],
            "two_disk_conflict": conflict}
    assert check_b9_exclusion(boxes, Q(27, 10), cert)
    corrupt = copy.deepcopy(cert)
    corrupt["residual_points"][0] = ["10", "0"]  # outside target
    assert not check_b9_exclusion(boxes, Q(27, 10), corrupt)
    # No boundary exclusion is allowed to use a point merely close to the circle.
    assert not check_b9_exclusion(boxes, Q(27, 10), {"boundary_point": ["0", "0"]})
    proposed = propose_b9_exclusion(boxes, Q(27, 10))
    assert proposed is not None and check_b9_exclusion(boxes, Q(27, 10), proposed)
