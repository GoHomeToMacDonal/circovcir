"""Adaptive bisection for b=10 at fixed R=R* on one starting box (L1 cost probe;
every closed leaf has an exact L-a certificate or an exact empty simplex).

usage: uv run python experiments/2026-10-11-n11-symmetry-census/b10_tree.py [seed] [h] [budget]
"""
from __future__ import annotations

import sys
import time
from fractions import Fraction as Q

import numpy as np

from circovcir.b10_exclusion import check_b10_exclusion, propose_b10_exclusion
from circovcir.ordered_arcs_b import contract_simplex, ordered_center_boxes

R = Q(26316907726198082, 10**16)


def run(box, budget):
    stack = [box]
    stats = {"visits": 0, "La": 0, "empty": 0, "open": 0}
    while stack:
        if stats["visits"] >= budget:
            stats["open"] += len(stack)
            break
        b = stack.pop()
        stats["visits"] += 1
        b = contract_simplex(b, 10)
        if b is None:
            stats["empty"] += 1
            continue
        boxes = ordered_center_boxes(R, 10, b, dps=40)
        if boxes is None:
            stats["empty"] += 1
            continue
        cert = propose_b10_exclusion(boxes, R)
        if cert is not None and check_b10_exclusion(boxes, R, cert):
            stats["La"] += 1
            continue
        k = max(range(20), key=lambda i: b[i][1] - b[i][0])
        lo, hi = b[k]
        mid = (lo + hi) / 2
        for half in ((lo, mid), (mid, hi)):
            nb = list(b)
            nb[k] = half
            stack.append(nb)
    return stats


def main():
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 0
    h = Q(sys.argv[2]) if len(sys.argv) > 2 else Q(1, 20)
    budget = int(sys.argv[3]) if len(sys.argv) > 3 else 2000
    x = np.random.default_rng(seed).dirichlet(np.ones(20))
    k = int(np.argmax(x[:10]))
    x[0], x[k] = x[k], x[0]
    box = [(max(Q(0), Q(float(t)) - h), Q(float(t)) + h) for t in x]
    t0 = time.time()
    s = run(box, budget)
    print(f"seed={seed} h={h}: {s} ({time.time() - t0:.0f}s)")


if __name__ == "__main__":
    main()
