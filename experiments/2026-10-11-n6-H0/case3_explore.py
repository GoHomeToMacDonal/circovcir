"""Case 3 of the H0 reduction (no single disk covers S = [-R, a-1] on the y-axis).

Float exploration only (L1 evidence).  Notation:
  O1 = D((0,a),1) covers the origin, a in [R-1, 1];  q = (0, a-1) bottom of O1's chord.
  P  = a disk != O1 containing q; case 3 => P does not contain (0,-R).
  Budget: sum_k loss(|c_k|) <= Lam(R) = 12 alpha - 2 pi, loss(d) = 2 alpha - 2 theta(d).
  Witnesses forcing a third disk Q (Q != O1, P):
    w1 = (0, t_P), t_P = bottom of P's chord on the y-axis (> -R in case 3);
    w2, w3 = crossing points of dO1 and dP lying inside D.
  F(a, cP) = loss(a) + loss(|cP|) + loss(1 + min |w|)   (third term with 1+|w| capped).
We report min F - Lam over a fine grid + local refinement.  F > Lam everywhere => case 3 impossible.
"""
import sys

import numpy as np
from scipy.optimize import minimize

R = float(sys.argv[1]) if len(sys.argv) > 1 else 1.798867827575
al = np.arcsin(1 / R)
Lam = 12 * al - 2 * np.pi
dstar = np.sqrt(R * R - 1)


def theta(d):
    d = np.asarray(d, float)
    with np.errstate(invalid="ignore", divide="ignore"):
        c = (R * R + d * d - 1) / (2 * R * d)
    return np.where((d >= R - 1) & (d <= R + 1), np.arccos(np.clip(c, -1, 1)), 0.0)


def loss(d):
    return 2 * al - 2 * theta(d)


def circ_cross(c1, c2):
    d = np.linalg.norm(c2 - c1)
    if d < 1e-15 or d > 2:
        return []
    m = (c1 + c2) / 2
    h = np.sqrt(max(1 - d * d / 4, 0))
    n = np.array([-(c2 - c1)[1], (c2 - c1)[0]]) / d
    return [m + h * n, m - h * n]


def F(a, x, y, detail=False):
    q = np.array([0.0, a - 1])
    cP = np.array([x, y])
    if np.linalg.norm(cP - q) > 1 or np.linalg.norm(cP - np.array([0, -R])) <= 1 or abs(x) > 1:
        return np.inf
    tP = y - np.sqrt(1 - x * x)
    ws = [np.array([0.0, tP])]
    for v in circ_cross(np.array([0.0, a]), cP):
        if np.linalg.norm(v) < R:
            ws.append(v)
    # Q contains w and (case 3) not both q and b=(0,-R): c_Q in disk(w,1) minus int(lens(b,q)).
    dq = max(qmax(w, q) for w in ws) if REFINE else 1 + min(np.linalg.norm(w) for w in ws)
    val = loss(a) + loss(np.hypot(x, y)) + loss(min(dq, dstar)) if not REFINE else \
        loss(a) + loss(np.hypot(x, y)) + max(lossmin_Q(w, q) for w in ws)
    if detail:
        return float(val), ws
    return float(val)


TH = np.linspace(0, 2 * np.pi, 721)
UNIT = np.column_stack([np.cos(TH), np.sin(TH)])
B = np.array([0.0, -R])
REFINE = True


def region_pts(w, q):
    """Boundary sample of disk(w,1) minus int(lens(B,q))."""
    pts = [w + UNIT]
    for c0 in (B, q):
        pts.append(c0 + UNIT)
    P = np.vstack(pts)
    inw = np.linalg.norm(P - w, axis=1) <= 1 + 1e-12
    inlens = (np.linalg.norm(P - B, axis=1) < 1 - 1e-12) & (np.linalg.norm(P - q, axis=1) < 1 - 1e-12)
    return P[inw & ~inlens]


def qmax(w, q):
    P = region_pts(w, q)
    return np.max(np.linalg.norm(P, axis=1))


def lossmin_Q(w, q):
    """min loss over admissible centers (loss is not monotone beyond dstar; take min over samples)."""
    P = region_pts(w, q)
    return float(np.min(loss(np.linalg.norm(P, axis=1))))


best = (np.inf, None)
for a in np.linspace(R - 1, 1, 41):
    for x in np.linspace(0, 1, 81):          # mirror symmetry x -> -x
        for y in np.linspace(a - 2, a, 81):
            v = F(a, x, y)
            if v < best[0]:
                best = (v, (a, x, y))
print("R", R, "Lam", Lam, "grid min F", best[0], "at", best[1], "margin", best[0] - Lam)
res = minimize(lambda z: F(*z), best[1], method="Nelder-Mead",
               options={"xatol": 1e-10, "fatol": 1e-12, "maxiter": 20000})
print("refined min F", res.fun, "at", res.x, "margin", res.fun - Lam)
print("detail", F(*res.x, detail=True))
