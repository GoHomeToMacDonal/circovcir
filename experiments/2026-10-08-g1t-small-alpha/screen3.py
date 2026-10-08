"""Cycle 4: test route (a) -- is max_Omega(theta - T) attained on the face |u1|=|u2|=1?

Real variables (s, t1, t2). |u_j|^2 = R^2 + s^2 - 2 R s cos(t_j) is DEPENDENT.
On Gamma_R the vertex q_j sits at polar angle t_j; the FT constraint is |u_j| <= 1.
h(s) = arccos((R^2+s^2-1)/(2 R s)) is the |t_j| at which |u_j| = 1 (boundary face).

We probe several candidate monotonicities to find the one that proves the reduction:
  (M1) fix s, fix t1 at -h(s) (|u1|=1), vary t2 in (0, h(s)]: does theta-T increase toward t2=h(s)?
  (M2) fix s, scale BOTH t_j inward from +-h(s): does the face (|t|=h) dominate?
  (M3) the clean radial one: parametrize q_j = o + rho_j * dir_j with dir_j the direction
       o->(R at angle t_j), rho_j in (0,1], and q_j NOT required on Gamma_R -- this is the
       abstract cell (o, q1, q2) with the ONLY constraints rho_j<=1 and theta=angle at O.
       In FT's area argument the cell angle theta at O and alpha at o are what matter; the
       vertices need |o q_j|<=1 and lie on Gamma_R. Test dalpha/drho_j sign at fixed theta.

Reproduce: uv run python experiments/2026-10-08-g1t-small-alpha/screen3.py
"""

from __future__ import annotations

import numpy as np

SEED = 20261008
rng = np.random.default_rng(SEED)


def mk(n):
    k = n - 1
    R = 1 + 2 * np.cos(2 * np.pi / k)
    abar = 6 * np.pi / k
    smax = np.sqrt(R * R - 1)
    smin = R - 1
    fbar = 2 * np.arcsin(np.sin(abar / 2) / R)
    fp = np.cos(abar / 2) / np.sqrt(R * R - np.sin(abar / 2) ** 2)

    def h(s):
        return np.arccos(np.clip((R * R + s * s - 1) / (2 * R * s), -1, 1))

    def T(a):
        return fbar + fp * (a - abar)

    def alpha_theta(s, t1, t2):
        o = np.array([s, 0.0])
        u1 = R * np.array([np.cos(t1), np.sin(t1)]) - o
        u2 = R * np.array([np.cos(t2), np.sin(t2)]) - o
        a = np.arccos(np.clip(u1 @ u2 / (np.linalg.norm(u1) * np.linalg.norm(u2)), -1, 1))
        return a, t2 - t1, np.linalg.norm(u1), np.linalg.norm(u2)

    return dict(k=k, R=R, abar=abar, smax=smax, smin=smin, h=h, T=T, aT=alpha_theta, fp=fp)


def test_face_dominates(n, N=400000):
    """For random interior points, is there always a boundary-face point with the SAME theta
    and LARGER-or-equal (theta-T)? Equivalently: does reducing |u| (at fixed theta) reduce
    theta-T? We realize 'fixed theta, vary |u|' by: fix (t1,t2) hence theta, vary s. Reducing
    s moves centers; track how |u_j| and (theta-T) co-move."""
    m = mk(n)
    R, abar, smin, smax, h, T, aT = (m[x] for x in ("R", "abar", "smin", "smax", "h", "T", "aT"))
    # Candidate lemma M-s: at FIXED (t1,t2) (=> fixed theta), theta-T is monotone in s, and the
    # extreme feasible s is where some |u_j|=1 (boundary face). Check sign of d(theta-T)/ds.
    bad = 0
    worst_interior_excess = -np.inf
    for _ in range(N):
        s = rng.uniform(smin, smax)
        hh = h(s)
        t1, t2 = np.sort(rng.uniform(-hh, hh, 2))
        a, th, l1, l2 = aT(s, t1, t2)
        if a > abar:
            continue
        g = th - T(a)
        # numeric d g / ds at fixed t1,t2
        ds = 1e-7
        a2, th2, _, _ = aT(s + ds, t1, t2)
        dgds = (th2 - T(a2) - g) / ds
        # also compare to the boundary-face point at same theta: slide s so that max|u_j|=1
        # (the face). Does g at the face >= g here? find s_face with |u_j|=1 for the binding j.
        # |u_j|=1 => R^2+s^2-2Rs cos t_j =1 => s = R cos t_j - sqrt(1-R^2 sin^2 t_j) (near root)
        def s_face(t):
            disc = 1 - R * R * np.sin(t) ** 2
            if disc < 0:
                return None
            return R * np.cos(t) - np.sqrt(disc)
        # keep theta fixed means keep (t1,t2); the face at these angles needs a specific s per
        # vertex -- generally can't have BOTH |u|=1 at arbitrary (t1,t2). So M-s with fixed
        # (t1,t2) cannot reach the symmetric face. Record dgds sign instead.
        worst_interior_excess = max(worst_interior_excess, g)
    m2 = mk(n)
    print(f"n={n}: max(theta-T) over sampled interior (alpha<=abar) = {worst_interior_excess:+.4e}")


def test_dalpha_drho(n, N=400000):
    """Clean abstract cell: o at origin-of-cell, two vertices at distances rho1,rho2 in (0,1]
    and directions phi1,phi2; alpha = phi2-phi1 is the angle at o (DIRECTIONS fixed), so alpha
    does NOT depend on rho at all in the abstract cell! The dependence enters because q_j must
    lie on Gamma_R: fixing the O-angle t_j fixes the LINE O->q_j, and |o q_j| and the DIRECTION
    o->q_j both move as q_j slides along that line. So the right statement couples t_j, s, rho_j.
    Here we test: fix s and the O-angles t1,t2 (=> theta fixed). The vertices are forced onto
    Gamma_R so |u_j| is DETERMINED -- there is no free rho. Hence 'inward slide at fixed theta'
    is NOT a motion within Omega. Confirm Omega has no such freedom: |u_j| is a function of (s,t_j).
    """
    m = mk(n)
    R = m["R"]
    # demonstrate |u_j| is pinned by (s,t_j): no residual freedom
    s = 0.5 * (m["smin"] + m["smax"])
    t = 0.3
    u = R * np.array([np.cos(t), np.sin(t)]) - np.array([s, 0.0])
    print(f"n={n}: |u| at (s={s:.4f}, t={t}) = {np.linalg.norm(u):.6f}  (pinned; no rho freedom in Omega)")


if __name__ == "__main__":
    for n in (8, 9, 10):
        test_face_dominates(n)
    print("---")
    for n in (8, 9, 10):
        test_dalpha_drho(n)
