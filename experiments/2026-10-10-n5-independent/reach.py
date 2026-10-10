"""Assumption-free reach functions + the three case checks of the revised chain (proofs/09 §6').

Reach is computed via the minimal-enclosing-circle (MEC) test: a unit disk containing a point set S
and the point A(psi) exists  <=>  MEC radius of S ∪ {A(psi)} <= 1.  Bisection on psi.

  E(psi_P, phi)  = max right A-end of a unit disk containing P=A(psi_P) and B(phi)          (D3 bound)
  E2(t)          = min left A-end of a unit disk containing T_R and B(t)                      (D2 bound)
Case checks for given (R, d)   [w := 4 alpha - psiT, c := psiT - 2 alpha]:
  good : max_{|psi|<=w, phi} min(E(psi,phi), E(-psi,-phi)) - c        (< 0 wanted for R > R5)
  (a)  : max_{|psi|<=w, t}   min(psi + 2 alpha - E2(t), E(-psi,-t) - c) (< 0 wanted)
  (a0) : w + 2 alpha - E2(-phiT)                                        (< 0 wanted; J4 empty)
  (c)  : min_t E2(t) + E2(-t) - 4 alpha                                 (> 0 wanted)
"""
import itertools

import numpy as np

R5 = 1.6410044636036157006508328240594
D5 = 0.95315494724913008525948079077139


def circ2(a, b):
    return (a + b) / 2, np.hypot(*(a - b)) / 2


def circ3(a, b, c):
    ax, ay = a
    bx, by = b
    cx, cy = c
    dd = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    if abs(dd) < 1e-15:
        return None
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / dd
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / dd
    u = np.array([ux, uy])
    return u, np.hypot(*(a - u))


def mec_radius(pts):
    """Exact MEC radius for a handful of points (brute force over pairs / triples)."""
    best = np.inf
    cands = [circ2(a, b) for a, b in itertools.combinations(pts, 2)]
    cands += [x for x in (circ3(*t) for t in itertools.combinations(pts, 3)) if x is not None]
    for u, r in cands:
        if all(np.hypot(*(p - u)) <= r * (1 + 1e-12) + 1e-12 for p in pts):
            best = min(best, r)
    return best


def A(R, p):
    return R * np.array([np.sin(p), -np.cos(p)])


def B(d, p):
    return np.array([np.sin(p), d - np.cos(p)])


def corner(R, d):
    yT = (R * R + d * d - 1) / (2 * d)
    T = np.array([np.sqrt(R * R - yT * yT), yT])
    return T, np.arctan2(T[0], -T[1]), np.arctan2(T[0], d - T[1])


def fits(pts):
    return mec_radius(pts) <= 1.0


def E(R, d, psi, phi, al):
    P, Q = A(R, psi), B(d, phi)
    if not fits([P, Q]):
        return -np.inf
    lo, hi = psi, psi + 2 * al
    if fits([P, Q, A(R, hi)]):
        return hi
    for _ in range(55):
        mid = (lo + hi) / 2
        lo, hi = (mid, hi) if fits([P, Q, A(R, mid)]) else (lo, mid)
    return lo


def E2(R, d, t, al):
    T, psiT, _ = corner(R, d)
    Q = B(d, t)
    if not fits([T, Q]):
        return np.inf
    lo, hi = psiT - 2 * al, psiT
    if fits([T, Q, A(R, lo)]):
        return lo
    for _ in range(55):
        mid = (lo + hi) / 2
        lo, hi = (lo, mid) if fits([T, Q, A(R, mid)]) else (mid, hi)
    return hi


def checks(R, d, nps=9, nph=61):
    al = np.arcsin(1 / R)
    T, psiT, phiT = corner(R, d)
    w, c = 4 * al - psiT, psiT - 2 * al
    psis = np.linspace(-w, w, nps) if w > 0 else np.array([0.0])
    phis = np.linspace(-phiT, phiT, nph)
    good = max(min(E(R, d, p, f, al), E(R, d, -p, -f, al)) - c for p in psis for f in phis)
    e2v = [E2(R, d, f, al) for f in phis]
    a = max(min(p + 2 * al - e2v[i], E(R, d, -p, -f, al) - c) for p in psis for i, f in enumerate(phis))
    a0 = w + 2 * al - e2v[0]
    cc = min(e2v[i] + e2v[-1 - i] for i in range(len(phis))) - 4 * al
    return w, good, a, a0, cc


if __name__ == "__main__":
    al = np.arcsin(1 / R5)
    print("sanity E(0,0) at (R5,d*) vs c:", E(R5, D5, 0.0, 0.0, al), corner(R5, D5)[1] - 2 * al)
    for R in (R5, R5 + 1e-3):
        print(f"R={R:.10f}:   d      w        good       (a)        (a0)       (c)")
        for d in np.linspace(0.85, 1.0, 11):
            w, g, a, a0, cc = checks(R, d)
            print(f"           {d:.4f} {w:+.4f}  {g:+.2e}  {a:+.2e}  {a0:+.2e}  {cc:+.2e}")
