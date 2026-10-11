"""Case 3 with a phi-free bound for Q (float exploration, L1 only).

Q's arc half-angle <= thQ := max over cQ in K(w) of theta(|cQ|); its position is free.
Excluded iff G0 = circle \\ (I1 u IP) cannot be covered by three arcs of length 2 alpha and one
arc of length 2 thQ.  margin = least extra length e such that arcs (2alpha+e, x3) and (2thQ+e)
cover G0  (bisection on e).
"""

import case3_exact as m
import numpy as np
from scipy.optimize import minimize

R, al = m.R, m.al


def cover_seq(gaps, lens):
    """Can arcs with lengths `lens` (used in this cyclic order, any rotation) cover the gaps?"""
    n = len(gaps)
    if n == 0:
        return True
    k = len(lens)
    for r in range(k):
        seq_l = lens[r:] + lens[:r]
        for i in range(n):
            seq = [(gaps[(i + j) % n][0] + (m.TWOPI if (i + j) >= n else 0), gaps[(i + j) % n][1])
                   for j in range(n)]
            pos = -np.inf
            used = 0
            ok = True
            for s, ln in seq:
                e = s + ln
                while e > pos:
                    if used == k:
                        ok = False
                        break
                    st = max(s, pos)
                    pos = st + seq_l[used]
                    used += 1
                if not ok:
                    break
            if ok:
                return True
    return False


def thQ_max(w, q):
    best = 0.0
    for phi in np.linspace(-np.pi, np.pi, 1440, endpoint=False):
        t = m.thmax(phi, w, q)
        if t is not None and t > best:
            best = t
    return best


def margin(a, x, y, detail=False):
    if not (R - 1 <= a <= 1):
        return np.inf
    q = np.array([0.0, a - 1])
    cP = np.array([x, y])
    if np.linalg.norm(cP - q) > 1 or np.linalg.norm(cP - m.B) <= 1 or abs(x) > 1:
        return np.inf
    G0 = m.complement([m.arc_of(np.array([0.0, a])), m.arc_of(cP)])
    best, info = -np.inf, None
    for w in m.witnesses(a, cP):
        th = thQ_max(w, q)
        lo, hi = -1.0, 1.0
        for _ in range(40):
            e = (lo + hi) / 2
            if cover_seq(G0, [2 * al + e] * 3 + [max(2 * th + e, 0)]):
                hi = e
            else:
                lo = e
        if hi > best:
            best, info = hi, (w, th)
    return (best, info) if detail else best


if __name__ == "__main__":
    import sys
    na = int(sys.argv[1]) if len(sys.argv) > 1 else 9
    res = []
    for a in np.linspace(R - 1 + 1e-3, 1, na):
        for x in np.linspace(0, 1, 21):
            for y in np.linspace(a - 2, a, 21):
                s = margin(a, x, y)
                if np.isfinite(s):
                    res.append((s, a, x, y))
    res.sort()
    print("R", R, "evals", len(res))
    for r in res[:6]:
        print("  ", r)
    seen = []
    for s0 in res[:12]:
        out = minimize(lambda z: margin(*z), s0[1:], method="Nelder-Mead",
                       options={"maxiter": 300, "xatol": 1e-7, "fatol": 1e-8})
        print("refined", round(out.fun, 6), out.x.round(5))
