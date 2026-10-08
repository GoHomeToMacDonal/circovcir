"""Cycle 2 float screen for S3b, corrected parametrization + touch-structure probe.

Clean domain (no period ambiguity):
    s   in [R-1, sqrt(R^2-1)]
    t_j in [-h(s), h(s)],  h(s) = arccos((R^2+s^2-1)/(2 R s))   <=> |u_j| <= 1
    t1 <= t2,   theta = t2 - t1  in [0, 2 h(s)]
    u_j = R(cos t_j, sin t_j) - (s,0),   alpha = angle(u1, o, u2).
Margin  D(s,t1,t2) = T(alpha) - theta,   T(a) = f(abar) + f'(abar)(a-abar).

Checks:
  (1) CALIBRATION: at the regular ring (|u_j|=1, i.e. t_j=+-h(s*) with the ring's s*,
      alpha=abar) margin -> 0 and theta -> f(abar).  s* = 2 cos(pi/k) (ring center dist).
  (2) margin >= 0 everywhere on alpha<=abar (direction).
  (3) TOUCH STRUCTURE: scan a 1-D slice through the ring touch to see whether D grows
      linearly or quadratically in (abar - alpha); report min D on alpha <= abar - delta
      for a grid of delta -> tells us the analytic collar width needed.

Reproduce: uv run python experiments/2026-10-08-g1t-small-alpha/screen2.py
"""

from __future__ import annotations

import numpy as np
from scipy.optimize import minimize

SEED = 20261008


def mk(n):
    k = n - 1
    R = 1 + 2 * np.cos(2 * np.pi / k)
    abar = 6 * np.pi / k
    smax = np.sqrt(R * R - 1)
    smin = R - 1
    fp = np.cos(abar / 2) / np.sqrt(R * R - np.sin(abar / 2) ** 2)
    fbar = 2 * np.arcsin(np.sin(abar / 2) / R)

    def h(s):
        return np.arccos(np.clip((R * R + s * s - 1) / (2 * R * s), -1, 1))

    def T(a):
        return fbar + fp * (a - abar)

    def geom(s, t1, t2):
        o = np.array([s, 0.0])
        u1 = R * np.array([np.cos(t1), np.sin(t1)]) - o
        u2 = R * np.array([np.cos(t2), np.sin(t2)]) - o
        l1, l2 = np.linalg.norm(u1), np.linalg.norm(u2)
        alpha = np.arccos(np.clip(u1 @ u2 / (l1 * l2), -1, 1))
        theta = t2 - t1
        return alpha, theta, l1, l2

    return dict(k=k, R=R, abar=abar, smax=smax, smin=smin, fp=fp, fbar=fbar,
                h=h, T=T, geom=geom)


def calibrate(n):
    m = mk(n)
    R, k, abar = m["R"], m["k"], m["abar"]
    sstar = 2 * np.cos(np.pi / k)  # ring center distance
    # ring cell: the two vertices are the midpoints to neighbours; on Gamma_R the cell
    # spans an arc of 2pi/k, symmetric about the x-axis => t_j = -+ pi/k.
    t1, t2 = -np.pi / k, np.pi / k
    a, th, l1, l2 = m["geom"](sstar, t1, t2)
    print(f"  CALIB n={n}: s*={sstar:.9f}  alpha={a:.9f} (abar={abar:.9f}) "
          f"theta={th:.9f}  |u1|={l1:.9f} |u2|={l2:.9f}  margin T-theta={m['T'](a)-th:+.3e}")


def collar(n, rng, starts=6000):
    m = mk(n)
    R, abar, smin, smax = m["R"], m["abar"], m["smin"], m["smax"]
    T, geom, h = m["T"], m["geom"], m["h"]

    def margin(v):
        s, t1, t2 = v
        a, th, l1, l2 = geom(s, t1, t2)
        return T(a) - th

    # For a grid of collar widths delta, minimize margin over {alpha <= abar - delta}.
    deltas = [0.0, 1e-4, 1e-3, 1e-2, 3e-2, 1e-1, 3e-1]
    out = {}
    for delta in deltas:
        cons = [
            {"type": "ineq", "fun": lambda v: 1 - geom(*v)[2] ** 2},
            {"type": "ineq", "fun": lambda v: 1 - geom(*v)[3] ** 2},
            {"type": "ineq", "fun": lambda v: v[0] - smin},
            {"type": "ineq", "fun": lambda v: smax - v[0]},
            {"type": "ineq", "fun": lambda v: v[2] - v[1]},               # t1<=t2
            {"type": "ineq", "fun": lambda v: (abar - delta) - geom(*v)[0]},  # alpha<=abar-delta
        ]
        best = np.inf
        bv = None
        for _ in range(starts // len(deltas) + 50):
            s0 = rng.uniform(smin, smax)
            h0 = h(s0)
            tt = np.sort(rng.uniform(-h0, h0, 2))
            r = minimize(margin, [s0, tt[0], tt[1]], method="SLSQP", constraints=cons,
                         options={"ftol": 1e-15, "maxiter": 600})
            if r.success and all(c["fun"](r.x) >= -1e-9 for c in cons):
                if r.fun < best:
                    best, bv = r.fun, r.x
        if bv is not None:
            a, th, l1, l2 = geom(*bv)
            out[delta] = (best, a, bv)
    print(f"n={n}  R={m['R']:.12f}  abar={abar:.9f}")
    for delta, (best, a, bv) in out.items():
        print(f"  collar alpha<=abar-{delta:<5g}: min(T-theta)={best:+.6e}  at alpha={a:.6f} "
              f"s={bv[0]:.6f} t1={bv[1]:.6f} t2={bv[2]:.6f}")


if __name__ == "__main__":
    rng = np.random.default_rng(SEED)
    print("== calibration on the regular ring ==")
    for n in (8, 9, 10):
        calibrate(n)
    print("== collar scan: min margin on alpha <= abar - delta ==")
    for n in (8, 9, 10):
        collar(n, rng)
