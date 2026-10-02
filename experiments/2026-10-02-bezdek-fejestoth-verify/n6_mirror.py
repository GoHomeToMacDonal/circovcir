#!/usr/bin/env python
"""n=6 optimum attempt with MIRROR-SYMMETRIC seeds.

Csikos (Fields slides) + Fejes Toth (2005): the optimal n=5,6 configuration has ONLY a
mirror symmetry (reflection across one axis), not rotational symmetry. The repo baseline
(random starts) stalls at R=1.7906; a wider random sweep reached 1.7953; the record is
r6 = 1.7988... So we restrict the search to mirror-symmetric configurations about the
x-axis and optimize the reduced DOF, then score with the EXACT candidate-set covering
radius from circovcir.geometry (no symmetry assumed in scoring).

A mirror-symmetric 6-config about the x-axis: either
  (A) 3 pairs {(x_i, +-y_i)}            -> 6 free (x1,y1,x2,y2,x3,y3)
  (B) 2 pairs + 2 on-axis {(x,0)}       -> 4+2 = 6 free
We sweep many seeds of BOTH families, L-BFGS on the smooth surrogate restricted to the
symmetric parametrization, then exact-polish the full (unconstrained) config.

Fixed seed. Scratch -> experiment out/. Usage:
  uv run python experiments/2026-10-02-bezdek-fejestoth-verify/n6_mirror.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np
from scipy.optimize import minimize

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "src"))
from circovcir.geometry import covering_radius  # noqa: E402
from circovcir.optimize import disk_samples, polish, smooth_objective  # noqa: E402

SEED = 20261002
OUT = Path(__file__).resolve().parent / "out"
OUT.mkdir(exist_ok=True)


def expand_A(p: np.ndarray) -> np.ndarray:
    """3 mirror pairs: p = [x1,y1,x2,y2,x3,y3] -> 6 centers."""
    xy = p.reshape(3, 2)
    return np.vstack([xy, xy * np.array([1.0, -1.0])])


def expand_B(p: np.ndarray) -> np.ndarray:
    """2 mirror pairs + 2 on-axis: p = [x1,y1,x2,y2,ax1,ax2] -> 6 centers."""
    xy = p[:4].reshape(2, 2)
    axis = np.column_stack([p[4:6], np.zeros(2)])
    return np.vstack([xy, xy * np.array([1.0, -1.0]), axis])


def run(expand, ndof: int, rng: np.random.Generator, X: np.ndarray, starts: int):
    best_r, best_c = np.inf, None
    for _ in range(starts):
        p = rng.uniform(-0.9, 0.9, ndof)

        def obj(pp, a):
            c = expand(pp)
            # finite-difference-free: use smooth_objective on the full expanded config,
            # projecting the gradient back onto the symmetric DOF numerically is overkill;
            # just optimize the full config but SEED it symmetric, then let polish refine.
            return smooth_objective(c.ravel(), X, a, a)[0]

        for a in (20, 60, 200, 600, 2000):
            r = minimize(obj, p, args=(a,), method="Nelder-Mead",
                         options={"maxiter": 2000, "xatol": 1e-9, "fatol": 1e-12})
            p = r.x
        c = expand(p)
        c = polish(c)  # exact active-set polish, full (unconstrained) DOF
        r = covering_radius(c, 1.0)
        if r < best_r:
            best_r, best_c = r, c
    return best_r, best_c


def main() -> int:
    rng = np.random.default_rng(SEED)
    X = disk_samples()
    rA, cA = run(expand_A, 6, rng, X, starts=120)
    rB, cB = run(expand_B, 6, rng, X, starts=120)
    r, c = (rA, cA) if rA < rB else (rB, cB)
    R = 1.0 / r
    print(f"family A: R={1/rA:.12f}   family B: R={1/rB:.12f}")
    print(f"BEST n=6: R={R:.12f}  (record 1.7988, baseline 1.790593, wide 1.795281)")
    out = {
        "n": 6, "R": f"{R:.16f}",
        "centers": [[f"{x:.16f}" for x in row] for row in (c / r).tolist()],
        "status": "candidate",
        "source": "mirror-symmetric search (n6_mirror.py)",
        "provenance": f"n6_mirror.py seed {SEED}, families A(3 pairs)+B(2 pairs+2 axis), 120 ea",
        "note": "attempt to reach record r6=1.7988 via mirror symmetry",
    }
    (OUT / "n6-mirror.json").write_text(json.dumps(out, indent=2))
    print("saved", OUT / "n6-mirror.json")
    return 0


if __name__ == "__main__":
    sys.exit(main())
