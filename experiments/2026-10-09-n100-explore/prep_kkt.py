"""Active set of a large-n config (Delaunay candidates, fast.py) in the JSON format kkt.wls reads.

usage: uv run python experiments/2026-10-09-n100-explore/prep_kkt.py CONFIG.json OUT.json [tol=1e-8]
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
from fast import _bisector_circle, _circumcenters, candidate_values, structure  # noqa: E402


def main() -> None:
    cfg = json.loads(Path(sys.argv[1]).read_text())
    out = Path(sys.argv[2])
    tol = float(sys.argv[3]) if len(sys.argv) > 3 else 1e-8
    C = np.array(cfg["centers"], dtype=float)
    R = float(cfg["R"])
    c = C / R
    tri, edges, signs = structure(c)
    vT, vB, vA = candidate_values(c, tri, edges, signs)
    top = max(vT.max(), vB.max(), vA.max())
    act = []
    for k in np.flatnonzero(vT >= top - tol):
        i, j, m = (int(x) for x in tri[k])
        p = _circumcenters(c[[i]], c[[j]], c[[m]])[0] * R
        act.append({"type": "T", "idx": [i + 1, j + 1, m + 1], "p": p.tolist()})
    for k in np.flatnonzero(vB >= top - tol):
        i, j = (int(x) for x in edges[k])
        p = _bisector_circle(c[[i]], c[[j]], np.array([signs[k]]))[0] * R
        act.append({"type": "B", "idx": [i + 1, j + 1], "p": p.tolist()})
    assert not (vA >= top - tol).any(), "antipodal candidate active: kkt.wls does not model it"
    allv = np.concatenate([vT, vB, vA])
    gap = top - allv[allv < top - tol].max()
    print(f"n={len(C)} R={R!r} active={len(act)} (T={sum(a['type'] == 'T' for a in act)}) "
          f"next_gap={gap:.2e}")
    out.write_text(json.dumps({"n": len(C), "R": repr(R),
                               "centers": [[repr(float(x)), repr(float(y))] for x, y in C],
                               "active": act}))


if __name__ == "__main__":
    main()
