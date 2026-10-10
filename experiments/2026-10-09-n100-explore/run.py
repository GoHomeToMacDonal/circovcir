"""n=100 exploration: hex-lattice baseline + layered / hex-core seeds -> anneal -> LP polish.

usage: uv run python experiments/2026-10-09-n100-explore/run.py [n=100] [starts=8] [seed=0]
Writes out/n{n}-best.json (top 10, unit-disk frame) and prints a per-family summary.
"""

from __future__ import annotations

import os

for _v in ("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS"):
    os.environ.setdefault(_v, "1")

import json  # noqa: E402
import sys  # noqa: E402
from multiprocessing import Pool  # noqa: E402
from pathlib import Path  # noqa: E402

import numpy as np  # noqa: E402
from scipy.optimize import minimize  # noqa: E402

sys.path.insert(0, str(Path(__file__).parent))
from fast import fast_radius, polish  # noqa: E402

from circovcir.optimize import disk_samples, smooth_objective  # noqa: E402

OUT = Path(__file__).parent / "out"
FAMS = ["hex", "hexcore", "rings", "random"]
HEX_DENSITY_R = lambda n: np.sqrt(n * 3 * np.sqrt(3) / 2 / np.pi)  # noqa: E731


def hex_points(n: int, offset, r: float) -> np.ndarray:
    """n points of the covering hex lattice (spacing sqrt(3) r) nearest the origin."""
    a = np.sqrt(3) * r
    m = int(np.sqrt(n)) + 4
    i, j = np.meshgrid(np.arange(-m, m + 1), np.arange(-m, m + 1))
    P = np.column_stack([(i + j / 2).ravel() * a, (j * np.sqrt(3) / 2).ravel() * a])
    P = P + np.asarray(offset) * a
    return P[np.argsort((P * P).sum(1))[:n]]


def ring(k: int, rho: float, ph: float) -> np.ndarray:
    t = ph + 2 * np.pi * np.arange(k) / k
    return rho * np.column_stack([np.cos(t), np.sin(t)])


def seed(fam: str, n: int, rng: np.random.Generator) -> np.ndarray:
    r = 1 / (HEX_DENSITY_R(n) * rng.uniform(0.90, 0.95))
    if fam == "hex":
        return hex_points(n, rng.uniform(0, 1, 2) * [1, np.sqrt(3) / 2], r)
    if fam == "hexcore":   # outer ring of b + hex core
        b = int(round(rng.uniform(0.95, 1.1) * 2 * np.pi / (1.65 * r)))
        out = ring(b, 1 - r * rng.uniform(0.35, 0.6), rng.uniform(0, 6.3))
        core = hex_points(n - b, rng.uniform(0, 1, 2), r)
        return np.vstack([out, core])
    if fam == "rings":     # concentric rings, counts ~ circumference / (sqrt3 r)
        pts, rho, left = [], 1 - r * rng.uniform(0.35, 0.6), n
        first = True
        while left > 0:
            k = int(round(2 * np.pi * rho / ((1.65 if first else np.sqrt(3)) * r)))
            k = max(1, min(k, left)) if rho > 0.5 * r else left
            pts.append(ring(k, rho if k > 1 else 0.0, rng.uniform(0, 6.3)))
            left -= k
            rho -= 1.5 * r * rng.uniform(0.95, 1.05)
            first = False
        return np.vstack(pts)
    u = rng.uniform(0, 1, (n, 2))   # "random": uniform in D(0, 0.95)
    return 0.95 * np.sqrt(u[:, :1]) * np.column_stack([np.cos(2 * np.pi * u[:, 1]),
                                                        np.sin(2 * np.pi * u[:, 1])])


def run_one(args):
    n, fam, s = args
    rng = np.random.default_rng([n, FAMS.index(fam), s])
    c = seed(fam, n, rng) + rng.normal(0, 0.002, (n, 2))
    r0 = fast_radius(c)
    X = disk_samples(8000, 2400)
    x = c.ravel()
    for a in (3e3, 1e4, 3e4, 1e5):
        x = minimize(smooth_objective, x, args=(X, a, a), jac=True, method="L-BFGS-B",
                     options={"maxiter": 600}).x
    c1 = x.reshape(-1, 2)
    r1 = fast_radius(c1)
    if r0 < r1:      # annealing hurt (e.g. a good lattice seed): polish the seed instead
        c1, r1 = c, r0
    c2 = polish(c1, rounds=600)
    r2 = fast_radius(c2)
    return {"n": n, "fam": fam, "s": s, "R_seed": 1 / r0, "R_anneal": 1 / r1, "R": 1 / r2,
            "centers": (c2 / r2).tolist()}


def main() -> None:
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    starts = int(sys.argv[2]) if len(sys.argv) > 2 else 8
    base = int(sys.argv[3]) if len(sys.argv) > 3 else 0
    fams = FAMS
    jobs = [(n, f, base + s) for f in fams for s in range(starts)]
    OUT.mkdir(exist_ok=True)
    with Pool(min(30, len(jobs))) as p:
        res = p.map(run_one, jobs, chunksize=1)
    res.sort(key=lambda d: -d["R"])
    print(f"n={n}  hex-density upper heuristic sqrt(n*3sqrt3/(2pi)) = {HEX_DENSITY_R(n):.6f}")
    for f in fams:
        rs = [d for d in res if d["fam"] == f]
        best = max(rs, key=lambda d: d["R"])
        print(f"  {f:8s} best R={best['R']:.10f}  (seed {best['R_seed']:.4f}, anneal "
              f"{best['R_anneal']:.4f})  median={np.median([d['R'] for d in rs]):.6f}")
    (OUT / f"n{n}-s{base}.json").write_text(json.dumps(res[:10]))


if __name__ == "__main__":
    main()
