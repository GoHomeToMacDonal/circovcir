"""b=10 with a triple point: best R found (L1 screen, NOT an exclusion).

Model (unit target disk, disks of radius r; R = 1/r):
  disks 1..10 must reach the boundary:  |c_k| >= 1 - r
  disks 1,2,3 share a point p:          |p - c_i| <= r
  all 11 disks cover D(0,1).
Minimise r_eff = max(cover radius, max |p-c_i|, max (1-|c_k|)) by smooth LSE
annealing; report exact r_eff at the end.  Mode 'free' drops both constraints
(calibration: should reproduce Melissen 2.63169...).

usage: uv run python experiments/2026-10-11-n11-symmetry-census/b10_triple.py [mode] [starts] [seed]
"""
from __future__ import annotations

import sys

import numpy as np
from scipy.optimize import minimize

from circovcir.geometry import covering_radius
from circovcir.optimize import _lse, disk_samples, polish, smooth_objective

N = 11
TRIPLE = (1, 2, 3)
TRIPLE2 = (4, 5, 6)
OUTER = tuple(range(1, 11))


def extra_terms(c, p, mode):
    """List of (value, d value/d c (N,2), d value/d p (2,)) for constraint terms."""
    out = []
    if mode == "free":
        return out
    groups = [(TRIPLE, 0)] + ([(TRIPLE2, 2)] if mode == "triple2" else [])
    for grp, off in groups:
        q = p[off:off + 2]
        for i in grp:
            v = q - c[i]
            d = np.linalg.norm(v) + 1e-18
            gc = np.zeros_like(c)
            gc[i] = -v / d
            gp = np.zeros_like(p)
            gp[off:off + 2] = v / d
            out.append((d, gc, gp))
    if mode in ("triple", "triple2", "b10", "nonwheel"):
        for k in OUTER:
            nk = np.linalg.norm(c[k]) + 1e-18
            gc = np.zeros_like(c)
            gc[k] = -c[k] / nk
            out.append((1 - nk, gc, np.zeros_like(p)))
    if mode in ("b10", "nonwheel"):
        out = out[3:]
    return out


def circ(a, b, c):
    d = 2 * (a[0] * (b[1] - c[1]) + b[0] * (c[1] - a[1]) + c[0] * (a[1] - b[1]))
    aa, bb, cc = a @ a, b @ b, c @ c
    return np.array([aa * (b[1] - c[1]) + bb * (c[1] - a[1]) + cc * (a[1] - b[1]),
                     aa * (c[0] - b[0]) + bb * (a[0] - c[0]) + cc * (b[0] - a[0])]) / d


def nonwheel_ineq(c, e):
    """>=0 iff circumcenter q of disks 1,2,3 lies in the target disk and is at least as
    close to them as to every other center (an outer-triple Voronoi vertex)."""
    q = circ(c[1], c[2], c[3])
    rq = np.linalg.norm(q - c[1])
    others = [k for k in range(N) if k not in TRIPLE]
    return np.array([1 - np.linalg.norm(q)] + [np.linalg.norm(q - c[k]) - rq for k in others])


def nonwheel_penalty(c, p, a):
    """Quadratic hinge penalty mu*sum(max(0,-g)^2) on nonwheel_ineq, finite-difference grad."""
    mu = 0.5 * a
    def pen(cc):
        g = nonwheel_ineq(cc, p)
        return mu * float(np.sum(np.minimum(g, 0.0) ** 2))
    v = pen(c)
    gc = np.zeros_like(c)
    eps = 1e-7
    for k in range(N):
        for ax in range(2):
            cc = c.copy()
            cc[k, ax] += eps
            gc[k, ax] = (pen(cc) - v) / eps
    return v, gc


def objective(x, X, a, mode):
    if mode == "nonwheel":
        f, g = _objective(x, X, a, "b10")
        v, gc = nonwheel_penalty(x[: 2 * N].reshape(N, 2), x[2 * N:], a)
        g = g.copy()
        g[: 2 * N] += gc.ravel()
        return f + v, g
    return _objective(x, X, a, mode)


def _objective(x, X, a, mode):
    c = x[: 2 * N].reshape(N, 2)
    p = x[2 * N:]
    F0, g0 = smooth_objective(c.ravel(), X, a, a)
    terms = extra_terms(c, p, mode)
    if not terms:
        return F0, np.concatenate([g0, np.zeros_like(p)])
    vals = np.array([F0] + [t[0] for t in terms])
    lse, w = _lse(a * vals[:, None], axis=0)
    w = w.ravel()
    gc = w[0] * g0.reshape(N, 2)
    gp = np.zeros_like(p)
    for wt, t in zip(w[1:], terms, strict=True):
        gc = gc + wt * t[1]
        gp = gp + wt * t[2]
    return float(lse[0] / a), np.concatenate([gc.ravel(), gp])


def r_eff(x, mode):
    c = x[: 2 * N].reshape(N, 2)
    p = x[2 * N:]
    vals = [covering_radius(c, 1.0)] + [t[0] for t in extra_terms(c, p, mode)]
    if mode == "nonwheel" and np.min(nonwheel_ineq(c, p)) < -1e-8:
        return np.inf
    return max(vals)


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "triple"
    starts = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    seed = int(sys.argv[3]) if len(sys.argv) > 3 else 1
    rng = np.random.default_rng(seed)
    X = disk_samples(4000, 2000)
    best = []
    rows = []
    for s in range(starts):
        rad = np.sqrt(rng.uniform(0, 1, N)) * 0.9
        th = rng.uniform(0, 2 * np.pi, N)
        c = np.column_stack([rad * np.cos(th), rad * np.sin(th)])
        c[1:] *= 0.85 / np.maximum(np.linalg.norm(c[1:], axis=1, keepdims=True), 1e-9)
        p = c[list(TRIPLE)].mean(0)
        if mode == "triple2":
            p = np.concatenate([p, c[list(TRIPLE2)].mean(0)])
        x = np.concatenate([c.ravel(), p])
        for a in (20, 60, 200, 600, 2000, 6000, 20000):
            x = minimize(objective, x, args=(X, a, mode), jac=True, method="L-BFGS-B",
                         options={"maxiter": 600}).x
        c = x[: 2 * N].reshape(N, 2)
        if mode == "free":
            c = polish(c)
            x = np.concatenate([c.ravel(), x[2 * N:]])
        else:
            def extra(cc, ee):
                return np.array([t[0] for t in extra_terms(cc, ee, mode)])
            c, e = polish(c, extra=extra, e0=x[2 * N:],
                          ineq=nonwheel_ineq if mode == "nonwheel" else None)
            x = np.concatenate([c.ravel(), e])
        r = r_eff(x, mode)
        best.append(1 / r)
        rows.append({"start": s, "R": 1 / r, "x": x.tolist()})
        print(f"{mode} start {s}: R = {1 / r:.8f}", flush=True)
    print(f"{mode}: max R over {starts} starts = {max(best):.8f}")
    import json
    from pathlib import Path
    out = Path(__file__).resolve().parent / "out"
    out.mkdir(exist_ok=True)
    (out / f"b10-{mode}-{seed}-{starts}.json").write_text(json.dumps(rows))


if __name__ == "__main__":
    main()
