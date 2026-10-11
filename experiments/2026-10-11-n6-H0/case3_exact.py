"""Case 3 exact-arc predicate (float exploration, L1 evidence only).

Given (a, cP) and witness w, Q's center lies in K(w) = disk(w,1) \\ int lens(b,q).
Only Q's boundary arc matters and for fixed direction phi a larger half-angle dominates,
so Q ranges over arcs [phi - thmax(phi), phi + thmax(phi)].
Excluded iff for every phi:  G = circle \\ (I1 u IP u IQ) cannot be covered by 3 arcs of length 2 alpha.
margin(a,cP) = max_w min_phi ( Lmin(G) - 2 alpha ),  Lmin = least L s.t. 3 arcs of length L cover G.
"""
import os

import numpy as np
from scipy.optimize import minimize

R = float(os.environ.get("RR", 1.798867827575))
al = np.arcsin(1 / R)
DSTAR = np.sqrt(R * R - 1)
B = np.array([0.0, -R])
TWOPI = 2 * np.pi


def theta(d):
    if d < R - 1 or d > R + 1:
        return 0.0
    return float(np.arccos(np.clip((R * R + d * d - 1) / (2 * R * d), -1, 1)))


def arc_of(c):
    d = float(np.hypot(*c))
    th = theta(d)
    return (float(np.arctan2(c[1], c[0])), th)


def complement(arcs):
    """arcs: list of (center, half) ; return list of (start, length) of uncovered intervals."""
    iv = []
    for c, h in arcs:
        if h <= 0:
            continue
        if h >= np.pi:
            return []
        s = (c - h) % TWOPI
        iv.append((s, 2 * h))
    if not iv:
        return [(0.0, TWOPI)]
    # unroll on [s0, s0+2pi)
    iv.sort()
    merged = []
    for s, L in iv:
        e = s + L
        if merged and s <= merged[-1][1]:
            merged[-1][1] = max(merged[-1][1], e)
        else:
            merged.append([s, e])
    # wrap: merge last with first if overlapping across 2pi
    if len(merged) > 1 and merged[-1][1] >= merged[0][0] + TWOPI:
        merged[0][0] = merged[-1][0] - TWOPI
        merged[0][1] = max(merged[0][1], merged[-1][1] - TWOPI)
        merged.pop()
    if merged[0][1] - merged[0][0] >= TWOPI:
        return []
    gaps = []
    for i in range(len(merged)):
        e = merged[i][1]
        s_next = merged[(i + 1) % len(merged)][0] + (TWOPI if i + 1 == len(merged) else 0)
        if s_next > e:
            gaps.append((e, s_next - e))
    return gaps


def cover_count(gaps, L):
    """min #arcs of length L covering union of disjoint closed gaps on the circle (greedy,
    started at the left end of each gap in turn)."""
    if not gaps:
        return 0
    if L <= 0:
        return 10 ** 9
    n = len(gaps)
    best = 10 ** 9
    for i in range(n):
        seq = [(gaps[(i + k) % n][0] + (TWOPI if (i + k) >= n else 0), gaps[(i + k) % n][1]) for k in range(n)]
        pos = -np.inf
        cnt = 0
        for s, ln in seq:
            e = s + ln
            if e <= pos:
                continue
            st = max(s, pos)
            m = int(np.ceil((e - st) / L - 1e-15))
            m = max(m, 1)
            cnt += m
            pos = st + m * L
            if cnt >= best:
                break
        best = min(best, cnt)
    return best


def lmin(gaps, k=3):
    if cover_count(gaps, 0.0) == 0:
        return 0.0
    lo, hi = 0.0, TWOPI
    for _ in range(50):
        mid = (lo + hi) / 2
        if cover_count(gaps, mid) <= k:
            hi = mid
        else:
            lo = mid
    return hi


def circ_cross(c1, c2):
    d = np.linalg.norm(c2 - c1)
    if d < 1e-15 or d > 2:
        return []
    m = (c1 + c2) / 2
    h = np.sqrt(max(1 - d * d / 4, 0))
    n = np.array([-(c2 - c1)[1], (c2 - c1)[0]]) / d
    return [m + h * n, m - h * n]


def witnesses(a, cP):
    tP = cP[1] - np.sqrt(1 - cP[0] ** 2)
    ws = [np.array([0.0, tP])]
    for v in circ_cross(np.array([0.0, a]), cP):
        if np.linalg.norm(v) < R:
            ws.append(v)
    return ws


def ray_interval(u, c, r=1.0):
    """t-interval with |t u - c| <= r (t real), or None."""
    bq = u @ c
    disc = bq * bq - (c @ c - r * r)
    if disc < 0:
        return None
    s = np.sqrt(disc)
    return (bq - s, bq + s)


def thmax(phi, w, q):
    u = np.array([np.cos(phi), np.sin(phi)])
    I = ray_interval(u, w)
    if I is None or I[1] <= 0:
        return None
    t1, t2 = max(I[0], 0.0), I[1]
    Ib, Iq = ray_interval(u, B), ray_interval(u, q)
    pieces = [(t1, t2)]
    if Ib is not None and Iq is not None:
        l0, l1 = max(Ib[0], Iq[0]), min(Ib[1], Iq[1])
        if l0 < l1:  # open lens interval removed
            pieces = [(t1, min(t2, l0)), (max(t1, l1), t2)]
            pieces = [p for p in pieces if p[0] <= p[1]]
    best = None
    for s, e in pieces:
        t = min(max(DSTAR, s), e)
        th = theta(t)
        best = th if best is None else max(best, th)
    return best


NPHI = int(os.environ.get("NPHI", 720))
PHIS = np.linspace(-np.pi, np.pi, NPHI, endpoint=False)


def margin(a, x, y, detail=False):
    q = np.array([0.0, a - 1])
    cP = np.array([x, y])
    if np.linalg.norm(cP - q) > 1 or np.linalg.norm(cP - B) <= 1 or abs(x) > 1:
        return np.inf
    base = [arc_of(np.array([0.0, a])), arc_of(cP)]
    best = -np.inf
    info = None
    for w in witnesses(a, cP):
        worst = np.inf
        wphi = None
        for phi in PHIS:
            th = thmax(phi, w, q)
            if th is None:
                continue
            g = complement(base + [(phi, th)])
            v = lmin(g) - 2 * al
            if v < worst:
                worst, wphi = v, (phi, th)
        if worst > best:
            best, info = worst, (w, wphi)
    return (best, info) if detail else best


if __name__ == "__main__":
    import sys
    import time
    t0 = time.time()
    na = int(sys.argv[1]) if len(sys.argv) > 1 else 9
    res = []
    for a in np.linspace(R - 1 + 1e-3, 1, na):
        for x in np.linspace(0, 1, 21):
            for y in np.linspace(a - 2, a, 21):
                s = margin(a, x, y)
                if np.isfinite(s):
                    res.append((s, a, x, y))
    res.sort()
    print("R", R, "evals", len(res), "time", round(time.time() - t0, 1))
    for r in res[:8]:
        print("  ", r)
    for s0 in res[:3]:
        out = minimize(lambda z: margin(*z), s0[1:], method="Nelder-Mead",
                       options={"maxiter": 300, "xatol": 1e-6, "fatol": 1e-7})
        print("refined", out.fun, out.x, margin(*out.x, detail=True)[1])
