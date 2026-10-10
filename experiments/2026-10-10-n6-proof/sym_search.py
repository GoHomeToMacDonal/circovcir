"""n=6 search in the mirror family: C1=(0,y1), C2=(0,y2) on the y-axis, pairs (+-x3,y3), (+-x4,y4).

Objective: max covered radius (exact candidate-set geometry, no symmetry assumed in scoring).
Seed fixed. Usage: uv run python sym_search.py [starts]
"""

import json
import sys

import numpy as np
from scipy.optimize import minimize

from circovcir.geometry import max_covered_radius, tight_points


def centers(p):
    y1, y2, x3, y3, x4, y4 = p
    return np.array([[0, y1], [0, y2], [x3, y3], [-x3, y3], [x4, y4], [-x4, y4]], float)


def f(p):
    return -max_covered_radius(centers(p), tol=1e-11)


def main():
    starts = int(sys.argv[1]) if len(sys.argv) > 1 else 200
    rng = np.random.default_rng(20261010)
    best = (0.0, None)
    for _ in range(starts):
        p0 = np.array([rng.uniform(0, 1.5), rng.uniform(-1.5, 0), rng.uniform(0.3, 1.5),
                       rng.uniform(-1.2, 1.2), rng.uniform(0.3, 1.5), rng.uniform(-1.2, 1.2)])
        r = minimize(f, p0, method="Nelder-Mead",
                     options=dict(xatol=1e-12, fatol=1e-13, maxiter=6000, maxfev=12000))
        r = minimize(f, r.x, method="Nelder-Mead",
                     options=dict(xatol=1e-13, fatol=1e-14, maxiter=6000, maxfev=12000))
        if -r.fun > best[0]:
            best = (-r.fun, r.x)
            print(f"{-r.fun:.12f}", np.round(r.x, 6).tolist(), flush=True)
    R, p = best
    c = centers(p)
    R = max_covered_radius(c)
    tp = tight_points(c, R, tol=1e-6)
    print("R =", repr(R), "tight:", len(tp))
    for pt, idx in tp:
        print(np.round(pt, 6).tolist(), idx)
    json.dump({"R": repr(R), "params": p.tolist()}, open("out/sym_best.json", "w"), indent=1)


if __name__ == "__main__":
    main()
