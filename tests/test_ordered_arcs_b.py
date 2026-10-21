from fractions import Fraction as Q

import numpy as np
import pytest

from circovcir import ordered_arcs as oa
from circovcir import ordered_arcs_b as ob

R9 = Q(263169077, 100000000)


def random_box(rng, n, width=Q(1, 20)):
    lows = [Q(int(rng.integers(0, 60)), 1000) for _ in range(n)]
    return [(lo, lo + width) for lo in lows]


@pytest.mark.parametrize("seed", range(6))
def test_b9_matches_ordered_arcs_exactly(seed):
    rng = np.random.default_rng(seed)
    box = random_box(rng, 18)
    assert ob.contract_simplex(box, 9) == oa.contract_simplex(box)
    got = ob.ordered_center_boxes(R9, 9, box, dps=40)
    want = oa.ordered_center_boxes(R9, box, dps=40)
    assert got == want


@pytest.mark.parametrize("seed", range(4))
def test_b9_decode_matches(seed):
    x = np.random.default_rng(seed).dirichlet(np.ones(18))
    assert np.array_equal(ob.decode_float(2.65, 9, x), oa.decode_float(2.65, x))


def test_b10_ring_decode_is_regular():
    R = 2.6316907726198082
    c = ob.decode_float(R, 10, np.r_[np.full(10, 0.1), np.zeros(10)])
    r = np.linalg.norm(c, axis=1)
    assert np.allclose(r, r[0])
    ang = np.unwrap(np.arctan2(c[:, 1], c[:, 0]))
    assert np.allclose(np.diff(ang), 2 * np.pi / 10)


def test_b10_boxes_contain_sampled_points():
    rng = np.random.default_rng(7)
    R = Q(2635, 1000)
    for _ in range(5):
        x = rng.dirichlet(np.ones(20))
        k = int(np.argmax(x[:10]))
        x[0], x[k] = x[k], x[0]          # anchor condition u_0 = max u
        box = [(max(Q(0), Q(float(t)) - Q(1, 200)), Q(float(t)) + Q(1, 200)) for t in x]
        boxes = ob.ordered_center_boxes(R, 10, box, dps=40)
        assert boxes is not None
        c = ob.decode_float(float(R), 10, x)
        for (lo, hi), p in zip(boxes, c, strict=True):
            assert float(lo[0]) - 1e-12 <= p[0] <= float(hi[0]) + 1e-12
            assert float(lo[1]) - 1e-12 <= p[1] <= float(hi[1]) + 1e-12
