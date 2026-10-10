"""Scan the number b of outer (boundary) disks for n=100.

Seed for given b (target radius Rg): outer ring of b unit disks at the depth where adjacent
disks meet exactly on |x|=Rg,  d = Rg cos(pi/b) - sqrt(1 - Rg^2 sin^2(pi/b))  (needs
Rg sin(pi/b) <= 1, i.e. b >= 28 for Rg ~ 8.66), random phase; core = the n-b points of a
spacing-sqrt3 hex lattice (random offset) nearest O.  Then LP polish + short basin hopping
(ils.kick / accept-if-better).  The final b is re-measured: polish may push disks in/out.

usage: uv run python experiments/2026-10-09-n100-explore/bscan.py [n=100] [bmin=28] [bmax=38]
       [seeds=6] [iters=10]
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

sys.path.insert(0, str(Path(__file__).parent))
from fast import fast_radius, polish  # noqa: E402
from ils import kick  # noqa: E402
from run import hex_points, ring  # noqa: E402

OUT = Path(__file__).parent / "out"


def seed(n: int, b: int, Rg: float, rng: np.random.Generator) -> np.ndarray:
    d = Rg * np.cos(np.pi / b) - np.sqrt(1 - (Rg * np.sin(np.pi / b)) ** 2)
    outer = ring(b, d, rng.uniform(0, 2 * np.pi))
    core = hex_points(n - b, rng.uniform(0, 1, 2) * [1, np.sqrt(3) / 2], 1.0)
    return np.vstack([outer, core]) / Rg          # scaled frame: target D(0,1)


def job(args):
    n, b, s, iters = args
    rng = np.random.default_rng([n, b, s])
    Rg = rng.uniform(8.60, 8.70)
    c = polish(seed(n, b, Rg, rng) + rng.normal(0, 0.002 / Rg, (n, 2)), rounds=600)
    r = fast_radius(c)
    R_polish = 1 / r
    for _ in range(iters):
        cand = polish(kick(c, rng), rounds=500)
        rc = fast_radius(cand)
        if rc < r - 1e-13:
            c, r = cand, rc
    C = c / r
    b_final = int((np.hypot(*C.T) > 1 / r - 1).sum())
    res = {"n": n, "b_seed": b, "s": s, "R_polish": R_polish, "R": 1 / r, "b": b_final,
           "centers": C.tolist()}
    with open(OUT / f"bscan-n{n}.jsonl", "a") as f:
        f.write(json.dumps({k: v for k, v in res.items() if k != "centers"}) + "\n")
    return res


def main() -> None:
    a = [int(x) for x in sys.argv[1:]] + [None] * 5
    n, bmin, bmax, seeds, iters = [v if v is not None else dflt for v, dflt in
                                   zip(a[:5], (100, 28, 38, 6, 10), strict=True)]
    OUT.mkdir(exist_ok=True)
    jobs = [(n, b, s, iters) for b in range(bmin, bmax + 1) for s in range(seeds)]
    with Pool(30) as p:
        res = p.map(job, jobs, chunksize=1)
    print(f"n={n}  b_seed  best R (final b)   median R")
    for b in range(bmin, bmax + 1):
        rs = [d for d in res if d["b_seed"] == b]
        best = max(rs, key=lambda d: d["R"])
        print(f"  {b:3d}   {best['R']:.10f} ({best['b']})   {np.median([d['R'] for d in rs]):.6f}")
    res.sort(key=lambda d: -d["R"])
    (OUT / f"bscan-n{n}-best.json").write_text(json.dumps(res[:10]))
    print(OUT / f"bscan-n{n}-best.json")


if __name__ == "__main__":
    main()
