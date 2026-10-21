from fractions import Fraction as Q

import numpy as np
import pytest
from scipy.optimize import linprog

from circovcir.branchbound import exclude_ordered_domain, replay_ordered_exclusion
from circovcir.ordered_arcs import (
    contract_simplex,
    decode_float,
    global_simplex,
    ordered_center_boxes,
    simplex_linear_range,
)


def test_simplex_empty_and_anchor_constraints():
    assert contract_simplex([(Q(1, 10), 1)]*18) is None
    assert contract_simplex([(0, Q(1, 100))]*18) is None
    b = [(0, 1)]*18
    b[2] = (Q(1, 2), Q(3, 4))
    result = contract_simplex(b)
    assert result[0][0] >= Q(1, 2)
    assert result[0][1] <= Q(1, 2)
    assert result[2] == (Q(1, 2), Q(1, 2))
    assert all(result[i] == (0, 0) for i in range(18) if i not in (0, 2))


def test_simplex_lp_range_against_independent_solver():
    rng = np.random.default_rng(13)
    for _ in range(12):
        upper = [Q(int(v), 100) for v in rng.integers(6, 25, 18)]
        b = [(0, u) for u in upper]
        c = [int(v) for v in rng.integers(-3, 5, 18)]
        lower, higher = simplex_linear_range(b, c)
        for sign, exact in [(1, lower), (-1, -higher)]:
            res = linprog(sign*np.array(c), A_eq=np.ones((1, 18)), b_eq=[1],
                          bounds=[(0, float(u)) for u in upper], method="highs")
            assert res.success
            assert float(exact) == pytest.approx(res.fun, abs=1e-12)


def test_global_ordered_boxes_contain_diagnostic_points():
    root = global_simplex(Q("2.63169"))
    boxes = ordered_center_boxes(Q("2.63169"), root)
    assert len(boxes) == 9
    assert boxes[0][0][1] == boxes[0][1][1] == 0
    rng = np.random.default_rng(1313)
    tested = 0
    for _ in range(100):
        x = rng.dirichlet(np.ones(18))
        x[:9] = np.sort(x[:9])[::-1]
        if x[0] < float(root[0][0]):
            continue
        c = decode_float(2.63169, x)
        assert all(float(lo[k]) <= p[k] <= float(hi[k])
                   for p, (lo, hi) in zip(c, boxes, strict=True) for k in range(2))
        tested += 1
    assert tested > 0


def test_small_boxes_and_invalid_radius():
    x = [Q(1, 5)]+[Q(1, 10)]*8+[Q(0)]*9
    boxes = ordered_center_boxes(Q("2.65"), [(v-Q(1, 10**7), v+Q(1, 10**7)) for v in x])
    c = decode_float(2.65, x)
    assert all(float(lo[k]) <= p[k] <= float(hi[k])
               for p, (lo, hi) in zip(c, boxes, strict=True) for k in range(2))
    with pytest.raises(ValueError):
        global_simplex(3)


def test_ordered_tree_replay_and_budget_failure():
    x = [Q(1, 5)]+[Q(1, 10)]*8+[Q(0)]*9
    bounds = [(max(0, v-Q(1, 10**5)), min(1, v+Q(1, 10**5))) for v in x]
    result = exclude_ordered_domain(Q("2.7"), bounds, budget=1)
    assert result["closed"]
    assert replay_ordered_exclusion(Q("2.7"), result["bounds"], result["tree"])
    assert not replay_ordered_exclusion(Q("2.7"), result["bounds"], {"unresolved": "budget"})
    broad = exclude_ordered_domain(Q("2.64"), budget=1)
    assert not broad["closed"]
    assert not replay_ordered_exclusion(Q("2.64"), broad["bounds"], broad["tree"])
