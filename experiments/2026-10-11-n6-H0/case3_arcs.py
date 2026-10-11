"""Case 3, refined boundary-arc test (float exploration, L1 evidence only).

Setup as in case3_explore.py.  For given (a, cP) and a witness w (a point of D near which
D \\ (O1 u P) is non-empty), the disk Q covering w has center cQ in
    K(w) = disk(w,1) \\ int(lens(b,q)),  b = (0,-R)   (case 3: no disk holds both q and b).
Boundary arcs I1, IP, IQ are exact.  G := circle \\ (I1 u IP u IQ).
  - if Q holds b: the other 3 disks must cover G:            need |G| <= 6 alpha
  - else a 4th disk O2 holds b, its arc contains -pi/2:     need |G| - min(2 alpha, |G0|) <= 4 alpha
    (G0 = component of G containing -pi/2).
deficit(cQ) = lhs - rhs; the configuration is excluded iff deficit > 0 for every cQ in K(w).
We search for (a, cP) where min_{cQ} deficit <= 0 (= not excluded) for EVERY witness.
"""
import sys

import numpy as np
from scipy.optimize import minimize

R = float(__import__("os").environ.get("RR", 1.798867827575))
al = np.arcsin(1 / R)
B = np.array([0.0, -R])
NG = int(__import__("os").environ.get("NG", 1440))                                   # boundary discretisation for |G|
PHI = np.linspace(-np.pi, np.pi, NG, endpoint=False) + np.pi / NG
BPTS = R * np.column_stack([np.cos(PHI), np.sin(PHI)])
DPHI = 2 * np.pi / NG
IB = np.argmin(np.abs(PHI + np.pi / 2))


def covered(c):
    """Boolean mask of boundary samples inside D(c,1); c shape (k,2) -> (k,NG)."""
    c = np.atleast_2d(c)
    return ((BPTS[None, :, 0] - c[:, None, 0]) ** 2 + (BPTS[None, :, 1] - c[:, None, 1]) ** 2) <= 1


def circ_cross(c1, c2):
    d = np.linalg.norm(c2 - c1)
    if d < 1e-15 or d > 2:
        return []
    m = (c1 + c2) / 2
    h = np.sqrt(max(1 - d * d / 4, 0))
    n = np.array([-(c2 - c1)[1], (c2 - c1)[0]]) / d
    return [m + h * n, m - h * n]


def comp_len(mask, i):
    """Length of the run of True in cyclic mask containing index i."""
    if not mask[i]:
        return 0.0
    if mask.all():
        return 2 * np.pi
    n = len(mask)
    j = i
    k = 0
    while mask[(j - 1) % n]:
        j -= 1
        k += 1
    j = i
    while mask[(j + 1) % n]:
        j += 1
        k += 1
    return (k + 1) * DPHI


def K_samples(w, q, m=60):
    rr = np.sqrt(np.linspace(0, 1, m // 3 + 1))
    tt = np.linspace(0, 2 * np.pi, m, endpoint=False)
    P = w + np.concatenate([np.column_stack([r * np.cos(tt), r * np.sin(tt)]) for r in rr])
    lens = (np.linalg.norm(P - B, axis=1) < 1) & (np.linalg.norm(P - q, axis=1) < 1)
    return P[~lens]


def witnesses(a, cP):
    q = np.array([0.0, a - 1])
    tP = cP[1] - np.sqrt(1 - cP[0] ** 2)
    ws = [np.array([0.0, tP])]
    for v in circ_cross(np.array([0.0, a]), cP):
        if np.linalg.norm(v) < R:
            ws.append(v)
    return ws


def score(a, x, y):
    """max over witnesses of min over cQ of deficit (>0 means excluded)."""
    q = np.array([0.0, a - 1])
    cP = np.array([x, y])
    if np.linalg.norm(cP - q) > 1 or np.linalg.norm(cP - B) <= 1 or abs(x) > 1:
        return np.inf
    base = covered(np.array([[0.0, a], [x, y]])).any(axis=0)
    best = -np.inf
    for w in witnesses(a, cP):
        CQ = K_samples(w, q)
        cov = base[None, :] | covered(CQ)
        G = ~cov
        lenG = G.sum(axis=1) * DPHI
        holdsb = np.linalg.norm(CQ - B, axis=1) <= 1
        # run of G through IB: rotate so IB is index 0
        Gr = np.roll(G, -IB, axis=1)
        allg = Gr.all(axis=1)
        lead = np.where(allg, NG, np.argmax(~Gr, axis=1))
        trail = np.where(allg, 0, np.argmax(~Gr[:, ::-1], axis=1))
        g0 = np.where(Gr[:, 0], np.minimum(lead + trail, NG), 0) * DPHI
        d = np.where(holdsb, lenG - 6 * al, lenG - np.minimum(2 * al, g0) - 4 * al)
        best = max(best, d.min())
    return best


if __name__ == "__main__":
    import time
    t0 = time.time()
    res = []
    for a in np.linspace(R - 1 + 1e-3, 1, int(sys.argv[2]) if len(sys.argv) > 2 else 13):
        for x in np.linspace(0, 1, 26):
            for y in np.linspace(a - 2, a, 26):
                s = score(a, x, y)
                if np.isfinite(s):
                    res.append((s, a, x, y))
    print("evals", len(res), "time", round(time.time() - t0, 1))
    res.sort()
    print("R", R, "lowest scores (score<=0 => not excluded):")
    for r in res[:10]:
        print("  ", r)
    s0 = res[0]
    out = minimize(lambda z: score(*z), s0[1:], method="Nelder-Mead", options={"maxiter": 400})
    print("refined", out.fun, out.x)
