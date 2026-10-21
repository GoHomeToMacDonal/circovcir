"""Leaf-test L-a closure rate on random small b=10 parameter boxes (L1 statistics,
each closed box carries an exact certificate checked by check_b10_exclusion).

usage: uv run python experiments/2026-10-11-n11-symmetry-census/b10_boxes.py [n] [halfwidth]
"""
from __future__ import annotations

import sys
import time
from fractions import Fraction as Q

import numpy as np

from circovcir.b10_exclusion import check_b10_exclusion, propose_b10_exclusion
from circovcir.ordered_arcs_b import ordered_center_boxes

R = Q(26316907726198082, 10**16)


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    h = Q(sys.argv[2]) if len(sys.argv) > 2 else Q(1, 200)
    rng = np.random.default_rng(11)
    closed = empty = 0
    t0 = time.time()
    pts = [np.r_[np.full(10, 0.1), np.zeros(10)]] + [rng.dirichlet(np.ones(20)) for _ in range(n)]
    for i, x in enumerate(pts):
        k = int(np.argmax(x[:10]))
        x[0], x[k] = x[k], x[0]
        box = [(max(Q(0), Q(float(t)) - h), Q(float(t)) + h) for t in x]
        boxes = ordered_center_boxes(R, 10, box, dps=40)
        if boxes is None:
            empty += 1
            continue
        cert = propose_b10_exclusion(boxes, R)
        ok = cert is not None and check_b10_exclusion(boxes, R, cert)
        closed += ok
        if i == 0:
            print("ring box closed by L-a:", ok)
    print(f"h={h}: {closed}/{len(pts)} closed, {empty} empty, {time.time() - t0:.0f}s")


if __name__ == "__main__":
    main()
