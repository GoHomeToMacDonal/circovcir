"""Structured-seed search for n = 12..25 (reproduce Friedman records).

Seeds follow the layer structure read off the record pictures / user hints:
  b outer disks meeting the target circle, then inner rings (outside -> in), e.g.
  n=19: [12, 6, 1].  Each seed = concentric rings with random radii/phases, then the
  baseline pipeline of optimize.py (smooth anneal started HOT so the layer structure
  survives, then exact active-set polish).  Everything is in the scaled frame
  (target D(0,1), disk radius r = 1/R); reported R = 1/r.

usage: uv run python experiments/2026-10-09-structured-12-25/search.py N [starts] [seed]
"""

from __future__ import annotations

import os

# 30 pool workers x multi-threaded BLAS oversubscribes the host (load ~400 observed)
for _v in ("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS"):
    os.environ.setdefault(_v, "1")

import json  # noqa: E402
import sys  # noqa: E402
from multiprocessing import Pool  # noqa: E402
from pathlib import Path  # noqa: E402

import numpy as np  # noqa: E402
from scipy.optimize import minimize  # noqa: E402

from circovcir.geometry import covering_radius  # noqa: E402
from circovcir.optimize import disk_samples, polish, smooth_objective  # noqa: E402
from circovcir.records import record_R  # noqa: E402

OUT = Path(__file__).parent / "out"

# layer specs (outer ring first).  Outer count b from the hints; inner variants enumerated.
SPECS: dict[int, list[list[int]]] = {
    12: [[9, 3]],
    13: [[10, 3]],
    14: [[10, 4], [10, 3, 1]],
    15: [[11, 4], [11, 3, 1]],
    16: [[12, 4], [12, 3, 1]],
    17: [[12, 5], [12, 4, 1]],
    18: [[12, 6], [12, 5, 1], [12, 4, 2], [12, 3, 3]],
    19: [[12, 6, 1]],
    20: [[13, 6, 1], [13, 7]],
}


def specs_for(n: int) -> list[list[int]]:
    if n in SPECS:
        return SPECS[n]
    out = []
    for b in range(12, 18):
        m = n - b
        for inner in ([m], [m - 1, 1]):
            out.append([b] + inner)
        for k in range(3, m // 2 + 1):
            out.append([b, m - k, k])
            if m - k - 1 >= k:
                out.append([b, m - k - 1, k, 1][: 4] if k > 1 else [b, m - 1, 1])
    return out


def seed_config(spec: list[int], r: float, rng: np.random.Generator) -> np.ndarray:
    pts = []
    rho = 1 - r * rng.uniform(0.25, 0.85)
    for li, k in enumerate(spec):
        if k == 1 and li == len(spec) - 1:
            pts.append(rng.normal(0, 0.05 * r, 2))
            continue
        ph = rng.uniform(0, 2 * np.pi)
        for j in range(k):
            t = ph + 2 * np.pi * j / k
            pts.append(rho * np.array([np.cos(t), np.sin(t)]) + rng.normal(0, 0.04 * r, 2))
        rho = max(rho - r * rng.uniform(1.3, 1.9), 0.6 * r if k > 1 else 0)
    return np.array(pts)


def run_one(args):
    n, spec, s = args
    rng = np.random.default_rng(1000003 * n + s)
    Rrec = record_R(n)
    r0 = 1 / Rrec * rng.uniform(0.99, 1.02)
    c = seed_config(spec, r0, rng)
    X = disk_samples(3000, 1200)
    x = c.ravel()
    for a in (300, 1000, 3000, 10000):
        x = minimize(smooth_objective, x, args=(X, a, a), jac=True, method="L-BFGS-B",
                     options={"maxiter": 500}).x
    c = polish(x.reshape(-1, 2), rounds=400)
    rr = covering_radius(c, 1.0)
    return {"n": n, "spec": spec, "s": s, "R": 1 / rr, "centers": (c / rr).tolist()}


def main() -> None:
    n = int(sys.argv[1])
    starts = int(sys.argv[2]) if len(sys.argv) > 2 else 32
    base = int(sys.argv[3]) if len(sys.argv) > 3 else 0
    jobs = [(n, sp, base + s) for sp in specs_for(n) for s in range(starts)]
    OUT.mkdir(exist_ok=True)
    with Pool(30) as p:
        res = p.map(run_one, jobs, chunksize=1)
    res.sort(key=lambda d: -d["R"])
    Rrec = record_R(n)
    print(f"n={n} record={Rrec}  jobs={len(jobs)}")
    by_spec: dict[str, float] = {}
    for d in res:
        by_spec[str(d["spec"])] = max(by_spec.get(str(d["spec"]), 0), d["R"])
    for k, v in sorted(by_spec.items(), key=lambda kv: -kv[1]):
        print(f"  {k:20s} best R={v:.12f}  gap={v - Rrec:+.3e}")
    (OUT / f"n{n:02d}-s{base}.json").write_text(json.dumps(res[:10], indent=1))


if __name__ == "__main__":
    main()
