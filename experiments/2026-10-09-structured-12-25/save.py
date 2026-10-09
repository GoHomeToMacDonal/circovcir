"""Write a KKT solution (out/nNN-kkt.json) as a repository config data/configs/NN/<name>.json.

status stays 'candidate' here; it is upgraded to 'verified-numeric' only after
`uv run circovcir verify <file> --wolfram` passes (done by the caller, recorded in checks).

usage: uv run python experiments/2026-10-09-structured-12-25/save.py N [name]
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from circovcir.records import record_R

HERE = Path(__file__).parent
ROOT = HERE.parents[1]


def main() -> None:
    n = int(sys.argv[1])
    name = sys.argv[2] if len(sys.argv) > 2 else "20261009-structured-kkt"
    k = json.loads((HERE / "out" / f"n{n:02d}-kkt.json").read_text())
    fl = json.loads((HERE / "out" / f"n{n:02d}-float.json").read_text())
    nT = sum(a["type"] == "T" for a in k["active"])
    nB = len(k["active"]) - nT
    cfg = {
        "n": n, "R": k["R"], "centers": k["centers"], "status": "candidate",
        "source": f"structured-seed search, layers {fl['spec']} "
                  f"(experiments/2026-10-09-structured-12-25); reproduces Friedman record "
                  f"{record_R(n)}",
        "provenance": f"search.py {n} -> prep.py {n} 1e-8 -> "
                      f"wolframscript -file kkt.wls out/n{n:02d}-float.json out/n{n:02d}-kkt.json "
                      f"{k['wp']} -> save.py {n}",
        "checks": {"kkt": f"{len(k['active'])} active candidates ({nT} triple, {nB} boundary); "
                          f"square KKT system rank {k['rankJ']}/{k['nU']}, Newton residual "
                          f"{k['residual']} at wp={k['wp']}; independent MaxCoveredRadius(wp="
                          f"{k['wp']}) = {k['R_cover_wp'][:40]}"},
    }
    out = ROOT / "data" / "configs" / f"{n:02d}" / f"{name}.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    assert not out.exists(), f"refusing to overwrite {out}"
    out.write_text(json.dumps(cfg, indent=1) + "\n")
    print(out)


if __name__ == "__main__":
    main()
