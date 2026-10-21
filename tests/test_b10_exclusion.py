from fractions import Fraction as Q

import numpy as np

from circovcir.b10_exclusion import check_b10_exclusion, propose_b10_exclusion
from circovcir.ordered_arcs_b import ordered_center_boxes

R = Q(26316907726198082, 10**16)


def _boxes(x, h):
    k = int(np.argmax(x[:10]))
    x = x.copy()
    x[0], x[k] = x[k], x[0]
    box = [(max(Q(0), Q(float(t)) - h), Q(float(t)) + h) for t in x]
    return ordered_center_boxes(R, 10, box, dps=40)


def test_random_far_box_gets_valid_certificate():
    x = np.random.default_rng(11).dirichlet(np.ones(20))
    boxes = _boxes(x, Q(1, 400))
    cert = propose_b10_exclusion(boxes, R)
    assert cert is not None
    assert check_b10_exclusion(boxes, R, cert)


def test_forged_certificates_rejected():
    x = np.random.default_rng(11).dirichlet(np.ones(20))
    boxes = _boxes(x, Q(1, 400))
    # a point inside an outer disk box center is covered -> not a witness
    c = boxes[3]
    mid = tuple(str((a + b) / 2) for a, b in zip(c[0], c[1], strict=True))
    assert not check_b10_exclusion(boxes, R, {"points": [mid, ("0", "0")]})
    assert not check_b10_exclusion(boxes, R, {"points": [("0", "0")]})
    # two witnesses that are close together fit in one unit disk
    cert = propose_b10_exclusion(boxes, R)
    p = cert["points"][0]
    assert not check_b10_exclusion(boxes, R, {"points": [p, p]})


def test_regular_ring_box_not_closed_by_La():
    ring = np.r_[np.full(10, 0.1), np.zeros(10)]
    boxes = _boxes(ring, Q(1, 1000))
    cert = propose_b10_exclusion(boxes, R)
    assert cert is None or check_b10_exclusion(boxes, R, cert)
