"""Float quick-screen for S3b: locate the tightest point of the G1T inequality
    theta(s,t1,t2) <= T(alpha(s,t1,t2))
on the SMALL-alpha side (alpha < abar, esp. alpha < pi/3), for n = 8, 9, 10.

Geometry (exact per experiments/2026-10-01-fejes-toth-audit/run.py `cell`):
  one boundary Dirichlet cell with disk center o = (s, 0), s in [R-1, sqrt(R^2-1)]
  (radical-axis same-side convention, S0). The cell's two boundary vertices sit on
  Gamma_R = {|x| = R} at polar angles t1, t2:  q_j = R*(cos t_j, sin t_j).
  Vectors from the disk center:  u_j = q_j - o,  with the Dirichlet-gap constraint
  |u_j| <= 1 (NOT = 1; this is the G1 gap, 02 Sec.25).
      alpha = angle(u1, o, u2)      = arccos( (u1.u2)/(|u1||u2|) )     [angle at o]
      theta = angle(q1, O, q2)      = |t2 - t1|  (mod, in [0,pi])      [angle at O]
  Patch bound:  T(a) = f(abar) + f'(abar) (a - abar),  f(a) = 2 asin(sin(a/2)/R),
      abar = 6 pi / (n-1),  R = 1 + 2 cos(2 pi/(n-1)).

Claim to certify (S3b): theta <= T(alpha) STRICTLY on the small-alpha side.
Margin  M(s,t1,t2) = T(alpha) - theta.  We maximize theta - T (= minimize M) to find
the tightest point. Equality (M=0) is attained at the regular ring (|u_j|=1, alpha=abar).

Reproduce: uv run python experiments/2026-10-08-g1t-small-alpha/screen.py
"""

from __future__ import annotations

import numpy as np
from scipy.optimize import minimize

SEED = 20261008


def geom(R, s, t1, t2):
    """Return (alpha, theta, |u1|, |u2|) for a cell at o=(s,0) with vertices at t1,t2."""
    o = np.array([s, 0.0])
    q1 = R * np.array([np.cos(t1), np.sin(t1)])
    q2 = R * np.array([np.cos(t2), np.sin(t2)])
    u1, u2 = q1 - o, q2 - o
    l1, l2 = np.linalg.norm(u1), np.linalg.norm(u2)
    alpha = np.arccos(np.clip(u1 @ u2 / (l1 * l2), -1, 1))
    theta = np.arccos(np.clip(np.cos(t2 - t1), -1, 1))
    return alpha, theta, l1, l2


def screen(n, rng, starts=4000):
    k = n - 1
    R = 1 + 2 * np.cos(2 * np.pi / k)
    abar = 6 * np.pi / k
    smax = np.sqrt(R * R - 1)

    def f(a):
        return 2 * np.arcsin(np.sin(a / 2) / R)

    fp = np.cos(abar / 2) / np.sqrt(R * R - np.sin(abar / 2) ** 2)

    def T(a):
        return f(abar) + fp * (a - abar)

    def margin(v):
        s, t1, t2 = v
        a, th, l1, l2 = geom(R, s, t1, t2)
        return T(a) - th  # want to find the minimum of this (tightest)

    # We minimize `margin` directly (SLSQP minimizes); constraints keep us feasible.
    cons = [
        {"type": "ineq", "fun": lambda v: 1 - geom(R, v[0], v[1], v[2])[2] ** 2},  # |u1|<=1
        {"type": "ineq", "fun": lambda v: 1 - geom(R, v[0], v[1], v[2])[3] ** 2},  # |u2|<=1
        {"type": "ineq", "fun": lambda v: smax - v[0]},
        {"type": "ineq", "fun": lambda v: v[0] - (R - 1)},
        {"type": "ineq", "fun": lambda v: abar - geom(R, v[0], v[1], v[2])[0]},  # alpha<=abar
    ]

    best_m, best_v, best_info = np.inf, None, None
    for _ in range(starts):
        s0 = rng.uniform(R - 1, smax)
        h0 = np.arccos(min(1.0, (R * R + s0 * s0 - 1) / (2 * R * s0)))
        tc = rng.uniform(-np.pi, np.pi)
        v0 = [s0, tc - rng.uniform(0, h0), tc + rng.uniform(0, h0)]
        r = minimize(margin, v0, method="SLSQP", constraints=cons,
                     options={"ftol": 1e-14, "maxiter": 500})
        if r.success and all(c["fun"](r.x) >= -1e-9 for c in cons):
            if r.fun < best_m:
                a, th, l1, l2 = geom(R, *r.x)
                best_m, best_v, best_info = r.fun, r.x, (a, th, l1, l2)

    a, th, l1, l2 = best_info
    print(f"n={n}  R={R:.15f}  abar={abar:.9f}  f'(abar)={fp:.9f}")
    print(f"  tightest small-alpha margin  min(T-theta) = {best_m:+.6e}")
    print(f"    at s={best_v[0]:.9f}  t1={best_v[1]:.9f}  t2={best_v[2]:.9f}")
    print(f"    alpha={a:.9f} (abar={abar:.6f})  theta={th:.9f}  |u1|={l1:.9f} |u2|={l2:.9f}")
    # also report the alpha<pi/3 sub-region tightness
    print(f"    alpha/pi = {a/np.pi:.6f}   (pi/3 -> 0.3333)")
    return best_m


if __name__ == "__main__":
    rng = np.random.default_rng(SEED)
    for n in (8, 9, 10):
        screen(n, rng)
