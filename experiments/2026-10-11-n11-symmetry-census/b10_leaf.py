"""b=10 leaf-test feasibility (L1): how often is a random ordered-arc point excluded?

Parameterisation as proofs/13 §2 with b=10: u_0..u_9, v_0..v_9 >= 0, sum 1,
D = 10 a - pi.  For each sample: decode 10 outer centers, take a fine grid of
D(0,R), keep points not covered by the 10 outer unit disks, and test whether a
single unit disk can cover them (minimum enclosing circle radius <= 1).
Excluded at a POINT is necessary for, but much weaker than, excluding a box.

usage: uv run python experiments/2026-10-11-n11-symmetry-census/b10_leaf.py [samples] [R]
"""
from __future__ import annotations

import sys

import numpy as np


def decode(R, x, b=10):
    a = np.arcsin(1 / R)
    D = b * a - np.pi
    u, v = x[:b], x[b:]
    width = a - D * u
    radial = R * np.cos(width) - np.sqrt(np.maximum(0, 1 - R**2 * np.sin(width) ** 2))
    gaps = 2 * a - D * (u + np.roll(u, -1) + 2 * v)
    ang = np.r_[0.0, np.cumsum(gaps[:-1])]
    return radial[:, None] * np.column_stack([np.cos(ang), np.sin(ang)])


def mec_radius(P):
    """Minimum enclosing circle radius (Welzl-free: exact via scipy-free brute force on hull)."""
    from scipy.spatial import ConvexHull
    if len(P) <= 1:
        return 0.0
    try:
        P = P[ConvexHull(P).vertices]
    except Exception:
        pass
    best = np.inf
    n = len(P)
    cands = []
    for i in range(n):
        for j in range(i + 1, n):
            cands.append(((P[i] + P[j]) / 2, np.linalg.norm(P[i] - P[j]) / 2))
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                A, B, C = P[i], P[j], P[k]
                d = 2 * (A[0] * (B[1] - C[1]) + B[0] * (C[1] - A[1]) + C[0] * (A[1] - B[1]))
                if abs(d) < 1e-14:
                    continue
                aa, bb, cc = A @ A, B @ B, C @ C
                o = np.array([aa * (B[1] - C[1]) + bb * (C[1] - A[1]) + cc * (A[1] - B[1]),
                              aa * (C[0] - B[0]) + bb * (A[0] - C[0]) + cc * (B[0] - A[0])]) / d
                cands.append((o, np.linalg.norm(A - o)))
    for o, r in cands:
        if r < best and np.all(np.linalg.norm(P - o, axis=1) <= r + 1e-12):
            best = r
    return best


def rho_star(R, c, G, iters=14):
    """Largest center displacement rho such that points with dist > 1+rho to every
    center still cannot be covered by one unit disk (bisection, L1)."""
    d = np.min(np.linalg.norm(G[:, None, :] - c[None, :, :], axis=2), axis=1)
    lo, hi = 0.0, 0.5
    if mec_radius(G[d > 1]) <= 1:
        return -1.0
    for _ in range(iters):
        mid = (lo + hi) / 2
        res = G[d > 1 + mid]
        if len(res) and mec_radius(res) > 1:
            lo = mid
        else:
            hi = mid
    return lo


def main():
    samples = int(sys.argv[1]) if len(sys.argv) > 1 else 2000
    R = float(sys.argv[2]) if len(sys.argv) > 2 else 2.6316907726198082
    mode = sys.argv[3] if len(sys.argv) > 3 else "mec"
    rng = np.random.default_rng(1)
    g = np.linspace(-R, R, 241)
    G = np.array([(x, y) for x in g for y in g if x * x + y * y <= R * R])
    ring = np.r_[np.full(10, 0.1), np.zeros(10)]
    xs = [ring] + [rng.dirichlet(np.ones(20)) for _ in range(samples)]
    if mode == "rho":
        rh = np.array([rho_star(R, decode(R, x), G) for x in xs])
        print(f"R={R}: ring rho* = {rh[0]:.5f}")
        r = rh[1:]
        print(f"random {samples}: rho* min={r.min():.4f} quantiles 1/5/50% = "
              f"{np.quantile(r, [.01, .05, .5]).round(4)}")
        return
    rads = []
    for x in xs:
        c = decode(R, x)
        d = np.min(np.linalg.norm(G[:, None, :] - c[None, :, :], axis=2), axis=1)
        res = G[d > 1]
        rads.append(mec_radius(res))
    rads = np.array(rads)
    print(f"R={R}: ring residual MEC radius = {rads[0]:.6f}")
    r = rads[1:]
    print(f"random {samples}: excluded (MEC>1) fraction = {np.mean(r > 1):.4f}; "
          f"min MEC = {r.min():.4f}; quantiles 1/5/50% = {np.quantile(r, [.01, .05, .5]).round(4)}")


if __name__ == "__main__":
    main()
