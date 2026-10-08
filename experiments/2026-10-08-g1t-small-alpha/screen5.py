"""Cycle 5: cos-space formulation screen.

Claim equivalent form: since T is increasing on [0,pi] and theta,T(alpha) in [0,pi],
    theta <= T(alpha)   <=>   cos(theta) >= cos(T(alpha)).
Define  M(s,t1,t2) = cos(theta) - cos(T(alpha)),  want M >= 0 on Omega (alpha<=abar).
    cos(theta) = cos(t2 - t1).
    cos(alpha) = (u1.u2)/(|u1||u2|),  |u_j|^2 = R^2+s^2-2 R s cos(t_j).
    alpha = arccos(cos(alpha)) in [0,pi] (clean monotone), T(alpha), then cos(T(alpha)).

Screen:
  (0) |u_j| lower bound over Omega (must be > 0, away from 0, so 1/(|u1||u2|) doesn't wrap).
  (1) M >= 0 everywhere on alpha<=abar? min M and where.
  (2) touch order at the ring point in cos-space: M vs box half-width eps (eps, eps^2).
  (3) calibration: M -> 0 at the ring point.

Reproduce: uv run python experiments/2026-10-08-g1t-small-alpha/screen5.py
"""
from __future__ import annotations
import numpy as np

rng = np.random.default_rng(20261008)


def mk(n):
    k = n - 1
    R = 1 + 2 * np.cos(2 * np.pi / k)
    abar = 6 * np.pi / k
    smax = np.sqrt(R * R - 1); smin = R - 1
    fbar = 2 * np.arcsin(np.sin(abar / 2) / R)
    fp = np.cos(abar / 2) / np.sqrt(R * R - np.sin(abar / 2) ** 2)
    sstar = 2 * np.cos(np.pi / k); tstar = np.pi / k
    def h(s): return np.arccos(np.clip((R * R + s * s - 1) / (2 * R * s), -1, 1))
    def T(a): return fbar + fp * (a - abar)
    def cosalpha(s, t1, t2):
        o = np.array([s, 0.0])
        u1 = R * np.array([np.cos(t1), np.sin(t1)]) - o
        u2 = R * np.array([np.cos(t2), np.sin(t2)]) - o
        l1 = np.linalg.norm(u1); l2 = np.linalg.norm(u2)
        return (u1 @ u2) / (l1 * l2), l1, l2
    def M(s, t1, t2):
        ca, l1, l2 = cosalpha(s, t1, t2)
        a = np.arccos(np.clip(ca, -1, 1))
        return np.cos(t2 - t1) - np.cos(T(a)), a, l1, l2
    return dict(k=k, R=R, abar=abar, smax=smax, smin=smin, h=h, T=T, M=M, sstar=sstar, tstar=tstar)


def screen(n, N=800000):
    m = mk(n)
    R, abar, smin, smax, h, M = (m[x] for x in ("R", "abar", "smin", "smax", "h", "M"))
    lmin = np.inf; mmin = np.inf; arg = None
    for _ in range(N):
        s = rng.uniform(smin, smax); hh = h(s)
        t1, t2 = np.sort(rng.uniform(-hh, hh, 2))
        mm, a, l1, l2 = M(s, t1, t2)
        lmin = min(lmin, l1, l2)
        if a <= abar and mm < mmin:
            mmin = mm; arg = (s, t1, t2, a, l1, l2)
    s, t1, t2, a, l1, l2 = arg
    print(f"n={n} R={R:.6f} abar={abar:.6f}")
    print(f"  |u_j| min over Omega sample = {lmin:.6f}  (want >0, away from 0)")
    print(f"  min M=cos(theta)-cos(T) over alpha<=abar = {mmin:+.4e}")
    print(f"    at s={s:.6f} t1={t1:.6f} t2={t2:.6f} alpha={a:.6f} |u1|={l1:.4f} |u2|={l2:.4f}")


def touch(n):
    m = mk(n)
    R, M, sstar, tstar, abar = (m[x] for x in ("R", "M", "sstar", "tstar", "abar"))
    # calibration
    m0, a0, _, _ = M(sstar, -tstar, tstar)
    print(f"n={n}: calibration M(ring)={m0:+.3e} alpha-abar={a0-abar:+.3e}")
    for eps in (1e-1, 3e-2, 1e-2, 3e-3, 1e-3):
        worst = np.inf
        for _ in range(300000):
            s = sstar + rng.uniform(-eps, eps)
            s = min(max(s, R - 1), np.sqrt(R * R - 1))
            hh = np.arccos(np.clip((R * R + s * s - 1) / (2 * R * s), -1, 1))
            t1 = np.clip(-tstar + rng.uniform(-eps, eps), -hh, hh)
            t2 = np.clip(tstar + rng.uniform(-eps, eps), -hh, hh)
            if t1 > t2: t1, t2 = t2, t1
            mm, a, _, _ = M(s, t1, t2)
            worst = min(worst, mm)
        print(f"   eps={eps:.0e}: min M near ring={worst:+.3e}  /eps={worst/eps:+.3e} /eps^2={worst/eps**2:+.3e}")


if __name__ == "__main__":
    for n in (8, 9, 10):
        screen(n)
    print("--- touch order (cos-space) ---")
    for n in (8, 9, 10):
        touch(n)
