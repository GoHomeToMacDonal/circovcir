"""n=11 local-optimum census: how symmetric are the good local optima?

Single entry point, fixed seed.  Evidence level L1 (float); a census can never
prove that no asymmetric optimum exists, only show what this method finds.

usage: uv run python experiments/2026-10-11-n11-symmetry-census/census.py [starts] [seed]
"""
from __future__ import annotations

import json
import sys
import time
from pathlib import Path

import numpy as np
from scipy.optimize import linear_sum_assignment, minimize, minimize_scalar

from circovcir.geometry import covering_radius
from circovcir.optimize import disk_samples, polish, smooth_objective

HERE = Path(__file__).resolve().parent


def reflect(c: np.ndarray, t: float) -> np.ndarray:
    """Reflect centers across the line through O at angle t."""
    m = np.array([[np.cos(2 * t), np.sin(2 * t)], [np.sin(2 * t), -np.cos(2 * t)]])
    return c @ m.T


def mismatch(c: np.ndarray, t: float) -> float:
    """Max distance in the best matching between c and its reflection."""
    r = reflect(c, t)
    d = np.linalg.norm(c[:, None, :] - r[None, :, :], axis=2)
    i, j = linear_sum_assignment(d)
    return float(d[i, j].max())


def asymmetry(c: np.ndarray) -> tuple[float, float]:
    """min over axes of the matching mismatch; returns (value, axis angle)."""
    ts = np.linspace(0, np.pi, 721)
    vals = [mismatch(c, t) for t in ts]
    k = int(np.argmin(vals))
    lo, hi = ts[k] - np.pi / 720, ts[k] + np.pi / 720
    res = minimize_scalar(lambda t: mismatch(c, t), bounds=(lo, hi),
                          method="bounded", options={"xatol": 1e-12})
    return float(min(res.fun, vals[k])), float(res.x)


def one_start(rng, X, n=11, schedule=(20, 60, 200, 600, 2000)):
    rad = np.sqrt(rng.uniform(0, 1, n)) * 0.9
    th = rng.uniform(0, 2 * np.pi, n)
    x = np.column_stack([rad * np.cos(th), rad * np.sin(th)]).ravel()
    for a in schedule:
        x = minimize(smooth_objective, x, args=(X, a, a), jac=True, method="L-BFGS-B",
                     options={"maxiter": 400}).x
    c = polish(x.reshape(-1, 2))
    r = covering_radius(c, 1.0)
    return 1 / r, c / r


def main() -> None:
    starts = int(sys.argv[1]) if len(sys.argv) > 1 else 40
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 20261011
    rng = np.random.default_rng(seed)
    X = disk_samples()
    rows = []
    t0 = time.time()
    for s in range(starts):
        R, c = one_start(rng, X)
        asym, axis = asymmetry(c)
        b = int(np.sum(np.linalg.norm(c, axis=1) > R - 1))
        rows.append({"start": s, "R": R, "asym": asym, "axis": axis, "b": b,
                     "centers": c.tolist()})
        print(f"{s:4d} R={R:.10f} b={b} asym={asym:.2e} ({time.time() - t0:.0f}s)", flush=True)
    rows.sort(key=lambda r: -r["R"])
    out = HERE / "out"
    out.mkdir(exist_ok=True)
    (out / f"census-{seed}-{starts}.json").write_text(json.dumps(rows))
    print("top 15 (R, b, asym):")
    for r in rows[:15]:
        print(f"  R={r['R']:.10f} b={r['b']} asym={r['asym']:.2e}")


if __name__ == "__main__":
    main()
