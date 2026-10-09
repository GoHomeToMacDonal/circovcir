"""Pick the best float config for n from out/nNN-*.json and extract its active set.

Active set (scaled frame, target D(0,1), radius r): candidate points whose nearest-center
distance is within ``tol`` of r.  'T' (i,j,k) = interior triple point (circumcenter),
'B' (i,j) = boundary point equidistant from c_i, c_j.  Also prints the gap to the next
non-active candidate so the cut is visibly clean.

usage: uv run python experiments/2026-10-09-structured-12-25/prep.py N [tol]
"""

from __future__ import annotations

import glob
import json
import sys
from itertools import combinations
from pathlib import Path

import numpy as np

from circovcir.optimize import _cand_point, _cand_value

OUT = Path(__file__).parent / "out"


def main() -> None:
    n = int(sys.argv[1])
    tol = float(sys.argv[2]) if len(sys.argv) > 2 else 1e-8
    best = None
    for f in glob.glob(str(OUT / f"n{n:02d}-s*.json")):
        for d in json.loads(Path(f).read_text()):
            if best is None or d["R"] > best["R"]:
                best = d
    assert best is not None
    C = np.array(best["centers"])
    R = best["R"]
    c = C / R
    cands = [("T", i, j, k) for i, j, k in combinations(range(n), 3)]
    cands += [("B", i, j, s) for i, j in combinations(range(n), 2) for s in (1.0, -1.0)]
    cands += [("A", i) for i in range(n)]
    vals = sorted(((v, t) for t in cands if (v := _cand_value(t, c)) is not None),
                  key=lambda x: -x[0])
    top = vals[0][0]
    act = [(v, t) for v, t in vals if v >= top - tol]
    rest = [v for v, t in vals if v < top - tol]
    print(f"n={n} R={R:.15f} spec={best['spec']} active={len(act)} "
          f"spread={top - act[-1][0]:.2e} next_gap={(top - rest[0]) if rest else float("nan"):.2e}")
    assert all(t[0] != "A" for _, t in act)
    active = []
    for _, t in act:
        p = (_cand_point(t, c) * R).tolist()
        if t[0] == "T":
            active.append({"type": "T", "idx": [t[1] + 1, t[2] + 1, t[3] + 1], "p": p})
        else:
            active.append({"type": "B", "idx": [t[1] + 1, t[2] + 1], "p": p})
    # sanity: a B point lying on |p|=R must be an intersection of the two unit circles
    (OUT / f"n{n:02d}-float.json").write_text(json.dumps(
        {"n": n, "R": repr(float(R)), "spec": best["spec"],
         "centers": [[repr(float(x)), repr(float(y))] for x, y in C], "active": active}, indent=1))


if __name__ == "__main__":
    main()
