"""Audit the per-cell inequalities of G. Fejes Toth (2005), Sec. 2, for n = 8, 9, 10.

Setting (one boundary cell): o_i = (s, 0) with R-1 <= s <= sqrt(R^2-1) (o, o_i on the same side
of the radical axis); q, q' on |x| = R with |o_i q|, |o_i q'| <= 1; alpha = angle q o_i q',
theta = angle q o q'. R = 1 + 2cos(2pi/(n-1)), abar = 6pi/(n-1).

  G1   theta <= f(alpha),     f(a) = 2 asin(sin(a/2)/R)              [paper; claimed for all alpha]
  G1T  theta <= T(alpha),     T = tangent line of f at abar           [proposed patch]
  G2   area(o_i, q, q', arc) <= F(alpha) = R^2/2 (f - sin f) + sin(alpha)/2

Evidence level: L1 (random sampling + SLSQP maxima, float64). Seed fixed.
Usage: uv run python experiments/2026-10-01-fejes-toth-audit/run.py
"""

import numpy as np
from scipy.optimize import minimize

SEED = 20261001


def cell(R, s, t1, t2):
    s = np.asarray(s, dtype=float)
    o = np.stack([s, np.zeros_like(s)], -1)
    q1 = R * np.stack([np.cos(t1), np.sin(t1)], -1) - o
    q2 = R * np.stack([np.cos(t2), np.sin(t2)], -1) - o
    l1, l2 = np.linalg.norm(q1, axis=-1), np.linalg.norm(q2, axis=-1)
    a = np.arccos(np.clip((q1 * q2).sum(-1) / l1 / l2, -1, 1))
    th = np.arccos(np.clip(np.cos(np.asarray(t2) - np.asarray(t1)), -1, 1))
    tri = 0.5 * np.abs(q1[..., 0] * q2[..., 1] - q1[..., 1] * q2[..., 0])
    return a, th, l1, l2, tri + R * R / 2 * (th - np.sin(th))


def audit(n, rng, N=2_000_000, starts=1500):
    R = 1 + 2 * np.cos(2 * np.pi / (n - 1))
    ab, smax = 6 * np.pi / (n - 1), np.sqrt(R * R - 1)

    def f(a):
        return 2 * np.arcsin(np.sin(a / 2) / R)

    fp = np.cos(ab / 2) / np.sqrt(R * R - np.sin(ab / 2) ** 2)

    def T(a):
        return f(ab) + fp * (a - ab)

    def F(a):
        return R * R / 2 * (f(a) - np.sin(f(a))) + np.sin(a) / 2

    s = rng.uniform(R - 1, smax, N)
    h = np.arccos(np.clip((R * R + s * s - 1) / (2 * R * s), -1, 1))
    a, th, _, _, area = cell(R, s, rng.uniform(-1, 1, N) * h, rng.uniform(-1, 1, N) * h)
    small = a < np.pi / 3
    print(f"n={n}  R={R:.12f}  abar={ab:.6f}")
    print(f"  G1  max(theta-f), alpha<pi/3 : {np.max((th - f(a))[small]):+.3e}   <-- paper gap")
    print(f"  G1  max(theta-f), alpha>=pi/3: {np.max((th - f(a))[~small]):+.3e}")
    print(f"  G2  max(area-F)              : {np.max(area - F(a)):+.3e}")
    print(f"  G1T max(theta-T), sampled    : {np.max(th - T(a)):+.3e}")

    def neg(v):
        a, th, *_ = cell(R, v[0], v[1], v[2])
        return -(th - T(a))

    cons = [{"type": "ineq", "fun": lambda v, j=j: 1 - cell(R, v[0], v[1], v[2])[2 + j] ** 2}
            for j in (0, 1)]
    cons += [{"type": "ineq", "fun": lambda v: smax - v[0]},
             {"type": "ineq", "fun": lambda v: v[0] - (R - 1)}]
    best = -np.inf
    for _ in range(starts):
        s0 = rng.uniform(R - 1, smax)
        h0 = np.arccos(min(1.0, (R * R + s0 * s0 - 1) / (2 * R * s0)))
        r = minimize(neg, [s0, rng.uniform(-h0, h0), rng.uniform(-h0, h0)], method="SLSQP",
                     constraints=cons, options={"ftol": 1e-13, "maxiter": 300})
        if r.success and all(c["fun"](r.x) >= -1e-9 for c in cons):
            best = max(best, -r.fun)
    print(f"  G1T max(theta-T), SLSQP      : {best:+.3e}   (0 = equality at the ring)")


if __name__ == "__main__":
    rng = np.random.default_rng(SEED)
    for n in (8, 9, 10):
        audit(n, rng)
