"""Prototype of leaf test L-b (proofs/20 §16): certify the W10 wheel type on a box.

Partial: checks wheel conditions (1) empty circumcircles via the in-circle
determinant and (2) Voronoi vertices inside D(0,R), with mpmath interval
arithmetic over the ten outer-center boxes and an inner-center box K.
K is derived from exact uniform-miss witnesses w (the inner disk must contain
them, so c0 lies in the square [w-1, w+1] for every w).  Spoke ownership and the
alpha<=pi chord condition are NOT yet checked -- this measures feasibility only.

usage: uv run python experiments/2026-10-11-n11-symmetry-census/b10_wheel_iv.py
"""
from __future__ import annotations

from fractions import Fraction as Q

import numpy as np
from mpmath import iv

from circovcir.b10_exclusion import _grid_residual
from circovcir.exclusion import check_witness, rational_inside
from circovcir.ordered_arcs_b import ordered_center_boxes

R = Q(26316907726198082, 10**16)
iv.dps = 30


def ivbox(b):
    (x0, y0), (x1, y1) = b
    return (iv.mpf([float(x0), float(x1)]), iv.mpf([float(y0), float(y1)]))


def inner_box(boxes):
    P = _grid_residual(boxes, R)
    if len(P) == 0:
        return None
    lo = np.array([-10.0, -10.0])
    hi = np.array([10.0, 10.0])
    used = 0
    for p in P[np.argsort(-np.linalg.norm(P, axis=1))][:60]:
        w = rational_inside(p, R)
        if check_witness(boxes, R, w) is None:
            continue
        used += 1
        lo = np.maximum(lo, [float(w[0]) - 1, float(w[1]) - 1])
        hi = np.minimum(hi, [float(w[0]) + 1, float(w[1]) + 1])
    if used == 0 or np.any(lo > hi):
        return None
    # widen by one ulp-ish for float->interval safety
    return ((Q(lo[0]) - Q(1, 10**12), Q(lo[1]) - Q(1, 10**12)),
            (Q(hi[0]) + Q(1, 10**12), Q(hi[1]) + Q(1, 10**12)))


def incircle(a, b, c, d):
    """>0 iff d strictly inside circle(a,b,c) for counter-clockwise a,b,c."""
    rows = []
    for p in (a, b, c):
        dx, dy = p[0] - d[0], p[1] - d[1]
        rows.append((dx, dy, dx * dx + dy * dy))
    (a1, a2, a3), (b1, b2, b3), (c1, c2, c3) = rows
    return a1 * (b2 * c3 - b3 * c2) - a2 * (b1 * c3 - b3 * c1) + a3 * (b1 * c2 - b2 * c1)


def orient(a, b, c):
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def wheel_certified(boxes, K):
    c0 = ivbox(K)
    outer = [ivbox(b) for b in boxes]
    n = len(outer)
    worst = np.inf
    for i in range(n):
        a, b = outer[i], outer[(i + 1) % n]
        prev = outer[(i - 1) % n]
        if not (orient(prev, a, b).a > 0):
            return False, ("outer-polygon-not-convex", i)
        o = orient(c0, a, b)
        if not (o.a > 0):
            return False, ("orient", i)
        for k in range(n):
            if k in (i, (i + 1) % n):
                continue
            ic = incircle(c0, a, b, outer[k])
            if not (ic.b < 0):
                return False, ("incircle", i, k)
            worst = min(worst, float(-ic.b))
        # circumcenter of (c0,a,b) inside D(0,R)
        d = 2 * o
        ax, ay = a[0] - c0[0], a[1] - c0[1]
        bx, by = b[0] - c0[0], b[1] - c0[1]
        ux = (by * (ax * ax + ay * ay) - ay * (bx * bx + by * by)) / d + c0[0]
        uy = (ax * (bx * bx + by * by) - bx * (ax * ax + ay * ay)) / d + c0[1]
        if not ((ux * ux + uy * uy).b < float(R) ** 2):
            return False, ("vertex-outside", i)
    return True, worst


def main():
    pts = {"ring": np.r_[np.full(10, 0.1), np.zeros(10)]}
    for name, x in pts.items():
        for h in (Q(1, 2000), Q(1, 500), Q(1, 200), Q(1, 50)):
            box = [(max(Q(0), Q(float(t)) - h), Q(float(t)) + h) for t in x]
            boxes = ordered_center_boxes(R, 10, box, dps=40)
            K = inner_box(boxes)
            if K is None:
                print(name, h, "no inner box (L-a should apply)")
                continue
            ok, info = wheel_certified(boxes, K)
            kw = float(K[1][0] - K[0][0]), float(K[1][1] - K[0][1])
            print(name, h, "K widths", np.round(kw, 4), "wheel certified:", ok, info)


if __name__ == "__main__":
    main()
