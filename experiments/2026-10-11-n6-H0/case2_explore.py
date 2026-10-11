"""Case 2 of the H0 reduction (one disk P covers S = [-R, a-1]); float exploration, L1 only.

O1 = D((0,a),1), P = D((x2,y2),1) with q=(0,a-1), b=(0,-R) in P, x2 >= 0 (mirror).
A_L / A_R = boundary arcs left / right of the axis not covered by O1 u P.
C2* = D((0,y2),1);  V* = left crossing of dO1 and dC2*.
Reports, over a grid of feasible (a, x2, y2):
  gL = |A_L| - 2 alpha, gR = |A_R| - 2 alpha       (want > 0: each side needs >= 2 disks)
  budget = |I1 u IP| + 8 alpha - 2 pi              (must be >= 0 for a cover to exist)
  vR = min over c5 in disk(V*,1) of [ Lmin_1(A_R \\ I5) - 2 alpha ]   (want > 0: a disk holding V*
       cannot be one of the two A_R disks)
"""
import os

import case3_exact as m
import numpy as np

R, al = m.R, m.al
B = m.B


def arcs_LR(a, x2, y2):
    """Return A_L, A_R as (start, length) ccw intervals.  O1 arc is centred at pi/2."""
    c1, h1 = m.arc_of(np.array([0.0, a]))
    c2, h2 = m.arc_of(np.array([x2, y2]))
    # ccw from O1's left end (pi/2 + h1) to P's ccw-start (c2 - h2), mod 2 pi
    sL = c1 + h1
    eL = (c2 - h2) % m.TWOPI
    lenL = (eL - sL) % m.TWOPI
    sR = c2 + h2
    eR = (c1 - h1) % m.TWOPI
    lenR = (eR - sR) % m.TWOPI
    return (sL, lenL), (sR % m.TWOPI, lenR), (h1, h2)


def vstar(a, y2):
    bb = -y2
    s = (a + bb) / 2
    return np.array([-np.sqrt(max(1 - s * s, 0)), (a - bb) / 2])


def lmin1(iv_list):
    """least L such that ONE arc of length L covers the given intervals (they lie in an arc < 2pi)."""
    if not iv_list:
        return 0.0
    return m.lmin(iv_list, k=1)


def subtract(interval, arc):
    """interval (s, len) minus arc (centre, half) -> list of (s, len)."""
    s, L = interval
    c, h = arc
    if h <= 0:
        return [interval]
    a0 = (c - h - s) % m.TWOPI
    a1 = a0 + 2 * h
    out = []
    # arc occupies [a0, a1] relative to s (maybe wrapping past 2pi -> also [a0-2pi, a1-2pi])
    occ = [(a0, a1), (a0 - m.TWOPI, a1 - m.TWOPI)]
    pieces = [(0.0, L)]
    for o0, o1 in occ:
        new = []
        for p0, p1 in pieces:
            if o1 <= p0 or o0 >= p1:
                new.append((p0, p1))
            else:
                if o0 > p0:
                    new.append((p0, o0))
                if o1 < p1:
                    new.append((o1, p1))
        pieces = new
    return [(s + p0, p1 - p0) for p0, p1 in pieces if p1 - p0 > 1e-15]


def v_margin(a, x2, y2, AR, n=40):
    v = vstar(a, y2)
    best = np.inf
    rr = np.sqrt(np.linspace(0, 1, n // 2 + 1))
    tt = np.linspace(0, 2 * np.pi, n, endpoint=False)
    for r in rr:
        for t in tt:
            c5 = v + r * np.array([np.cos(t), np.sin(t)])
            rest = subtract(AR, m.arc_of(c5))
            val = lmin1(rest) - 2 * al
            best = min(best, val)
    return best


if __name__ == "__main__":
    import sys
    na = int(sys.argv[1]) if len(sys.argv) > 1 else 9
    rows = []
    for a in np.linspace(R - 1 + 1e-3, 1, na):
        q = np.array([0.0, a - 1])
        for x2 in np.linspace(0, 1, 21):
            for y2 in np.linspace(-2.2, 0, 23):
                c2 = np.array([x2, y2])
                if np.linalg.norm(c2 - q) > 1 or np.linalg.norm(c2 - B) > 1:
                    continue
                AL, AR, (h1, h2) = arcs_LR(a, x2, y2)
                cov = m.complement([m.arc_of(np.array([0.0, a])), m.arc_of(c2)])
                budget = 8 * al - sum(g[1] for g in cov)
                if budget < 0:
                    continue
                gL, gR = AL[1] - 2 * al, AR[1] - 2 * al
                vR = v_margin(a, x2, y2, AR) if os.environ.get("VM", "1") == "1" else np.nan
                rows.append((a, x2, y2, budget, gL, gR, vR))
    rows = np.array(rows)
    print("feasible grid points", len(rows))
    for k, name in [(4, "gL"), (5, "gR"), (6, "vR")]:
        i = np.nanargmin(rows[:, k])
        print(f"min {name} = {rows[i, k]:.5f} at a,x2,y2 = {rows[i, :3].round(4)} budget {rows[i, 3]:.4f}")
