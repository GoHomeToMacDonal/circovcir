"""Iterated local search (basin hopping) from the best configurations of run.py.

Each chain: x <- best; repeat: perturb (Gaussian kick on all centers, or a local kick on the
disks near the current worst hole), LP-polish, accept if R improves.  Fixed seeds.

usage: uv run python experiments/2026-10-09-n100-explore/ils.py IN.json [iters=40] [chains=30]
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
from fast import _active, fast_radius, polish  # noqa: E402


def kick(c: np.ndarray, rng: np.random.Generator) -> np.ndarray:
    r = fast_radius(c)
    c = c.copy()
    if rng.uniform() < 0.5:                      # global kick
        c += rng.normal(0, rng.choice([0.1, 0.25, 0.5]) * r, c.shape)
    else:                                        # local kick around a worst candidate
        act, _ = _active(c, 1e-9)
        idx = list(act[rng.integers(len(act))][1])
        p = c[idx].mean(0)
        near = np.argsort(np.linalg.norm(c - p, axis=1))[: rng.integers(4, 15)]
        c[near] += rng.normal(0, 0.6 * r, (len(near), 2))
    return np.clip(c, -1, 1)


def chain(args):
    c0, R0, iters, s = args
    rng = np.random.default_rng([1009, s])
    c = np.array(c0) / R0
    r = fast_radius(c)
    hist = [1 / r]
    for _ in range(iters):
        cand = polish(kick(c, rng), rounds=500)
        rc = fast_radius(cand)
        if rc < r - 1e-13:
            c, r = cand, rc
        hist.append(1 / r)
    return {"s": s, "R": 1 / r, "centers": (c / r).tolist(), "hist": hist}


def main() -> None:
    f = Path(sys.argv[1])
    iters = int(sys.argv[2]) if len(sys.argv) > 2 else 40
    chains = int(sys.argv[3]) if len(sys.argv) > 3 else 30
    starts = json.loads(f.read_text())
    jobs = [(starts[k % len(starts)]["centers"], starts[k % len(starts)]["R"], iters, k)
            for k in range(chains)]
    with Pool(min(30, chains)) as p:
        res = p.map(chain, jobs, chunksize=1)
    res.sort(key=lambda d: -d["R"])
    for d in res[:8]:
        print(f"chain {d['s']:3d}  start {d['hist'][0]:.10f} -> {d['R']:.10f}")
    out = f.with_name(f.stem + "-ils.json")
    out.write_text(json.dumps([{"fam": "ils", "s": d["s"], "R": d["R"], "centers": d["centers"]}
                               for d in res[:10]]))
    print(out)


if __name__ == "__main__":
    main()
