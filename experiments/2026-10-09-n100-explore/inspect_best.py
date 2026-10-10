"""Describe a configuration: boundary disks b, radial shells, and an extra-long polish.

usage: uv run python experiments/2026-10-09-n100-explore/inspect_best.py out/n100-s0.json [rounds]
"""

from __future__ import annotations

import os

os.environ.setdefault("OMP_NUM_THREADS", "1")

import json  # noqa: E402
import sys  # noqa: E402
from pathlib import Path  # noqa: E402

import numpy as np  # noqa: E402

sys.path.insert(0, str(Path(__file__).parent))
from fast import fast_radius, polish  # noqa: E402

from circovcir.geometry import covering_radius  # noqa: E402


def describe(C: np.ndarray, R: float) -> str:
    r = np.hypot(*C.T)
    b = int((r > R - 1).sum())
    hist = np.histogram(r, bins=np.arange(0, R + 0.5, 0.5))[0]
    return f"b={b}  |c| histogram (0.5 bins): {hist.tolist()}"


def main() -> None:
    f = Path(sys.argv[1])
    rounds = int(sys.argv[2]) if len(sys.argv) > 2 else 3000
    d = json.loads(f.read_text())[0]
    C = np.array(d["centers"])
    R = d["R"]
    print(f"{d['fam']} s={d['s']}  R={R:.12f}  {describe(C, R)}")
    c = polish(C / R, rounds=rounds)
    r = fast_radius(c)
    print(f"after {rounds} more rounds: R={1 / r:.12f}  (reference geometry R="
          f"{1 / covering_radius(c, 1.0):.12f})  {describe(c / r, 1 / r)}")
    out = f.with_name(f.stem + "-polished.json")
    out.write_text(json.dumps({"n": len(c), "R": 1 / r, "centers": (c / r).tolist()}))
    print(out)


if __name__ == "__main__":
    main()
