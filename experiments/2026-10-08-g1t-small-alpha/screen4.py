"""Cycle 4 (corrected): the face-reduction lemma in the REAL variables.

|u_j| is pinned by (s,t_j); the boundary face |u1|=|u2|=1 is |t_j|=h(s). The right claim:
for every fixed s, G(s,t1,t2)=theta-T(alpha) attains its max over the t-box
{t1,t2 in [-h(s),h(s)], t1<=t2, alpha<=abar} on the boundary |t_j|=h(s).

A clean sufficient condition: G is monotone NONDECREASING as t2 increases toward +h(s) and
as t1 decreases toward -h(s) (i.e. widening the cell toward the face). Then the max is at
t1=-h(s), t2=+h(s) -> the symmetric boundary face -> theta=f(alpha)<=T (BF+P1). We test the
signs of dG/dt2 (want >=0) and dG/dt1 (want <=0) over all of Omega with alpha<=abar.

Also directly: does the symmetric face point at each s dominate every interior point at that s?

Reproduce: uv run python experiments/2026-10-08-g1t-small-alpha/screen4.py
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
    def h(s): return np.arccos(np.clip((R * R + s * s - 1) / (2 * R * s), -1, 1))
    def T(a): return fbar + fp * (a - abar)
    def aT(s, t1, t2):
        o = np.array([s, 0.0])
        u1 = R * np.array([np.cos(t1), np.sin(t1)]) - o
        u2 = R * np.array([np.cos(t2), np.sin(t2)]) - o
        a = np.arccos(np.clip(u1 @ u2 / (np.linalg.norm(u1) * np.linalg.norm(u2)), -1, 1))
        return a, t2 - t1
    def G(s, t1, t2):
        a, th = aT(s, t1, t2); return th - T(a)
    return dict(k=k, R=R, abar=abar, smax=smax, smin=smin, h=h, T=T, G=G, aT=aT)


def probe(n, N=600000):
    m = mk(n)
    R, abar, smin, smax, h, G, aT = (m[x] for x in ("R", "abar", "smin", "smax", "h", "G", "aT"))
    d = 1e-7
    bad_t2 = bad_t1 = 0
    min_dGdt2 = np.inf; max_dGdt1 = -np.inf
    face_viol = 0; max_face_viol = -np.inf
    for _ in range(N):
        s = rng.uniform(smin, smax); hh = h(s)
        t1, t2 = np.sort(rng.uniform(-hh, hh, 2))
        a, th = aT(s, t1, t2)
        if a > abar:
            continue
        g = G(s, t1, t2)
        # dG/dt2 (want >=0): push t2 up toward +hh
        if t2 + d <= hh:
            dGdt2 = (G(s, t1, t2 + d) - g) / d
            min_dGdt2 = min(min_dGdt2, dGdt2)
            if dGdt2 < -1e-6: bad_t2 += 1
        # dG/dt1 (want <=0): push t1 down toward -hh
        if t1 - d >= -hh:
            dGdt1 = (G(s, t1 - d, t2) - g) / d
            max_dGdt1 = max(max_dGdt1, dGdt1)
            if dGdt1 > 1e-6: bad_t1 += 1
        # face dominance at this s: symmetric face point t=+-hh
        gf = G(s, -hh, hh)
        if g > gf + 1e-9:
            face_viol += 1; max_face_viol = max(max_face_viol, g - gf)
    print(f"n={n}: min dG/dt2={min_dGdt2:+.3e} (want>=0, viol={bad_t2}) | "
          f"max dG/dt1={max_dGdt1:+.3e} (want<=0, viol={bad_t1})")
    print(f"      face dominance viol (interior g > face g): {face_viol}  max excess={max_face_viol:+.3e}")


if __name__ == "__main__":
    for n in (8, 9, 10):
        probe(n)
