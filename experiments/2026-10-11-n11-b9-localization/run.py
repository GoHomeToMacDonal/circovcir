#!/usr/bin/env python3
"""b9-only: interval-radius localization interface and radial-order capacity."""
from __future__ import annotations

import json
import os
import subprocess
from fractions import Fraction as Q
from pathlib import Path

from circovcir.b9_search import localize_b9, replay_b9_localization

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
RESULTS = HERE / "results"
OUT = HERE / "out"


def main():
    RESULTS.mkdir(exist_ok=True)
    OUT.mkdir(exist_ok=True)
    exe = os.environ.get("WOLFRAMSCRIPT", str(Path.home() /
        "Wolfram/Mathematica/14.3/Executables/wolframscript"))

    def wolfram(name, log):
        proc = subprocess.run([exe, "-file", str(ROOT / "proofs/certificates" / name)],
                              capture_output=True, text=True, check=False)
        (RESULTS / log).write_text(proc.stdout+"\nSTDERR:\n"+proc.stderr)
        assert proc.returncode == 0 and "CERTIFICATE OK (L3)" in proc.stdout, name
        print(name, "OK", flush=True)

    # Explicit dependencies: never treat a user-supplied target JSON as a theorem.
    wolfram("14a-n11-inner-lift.wls", "lift.log")
    wolfram("13b-n11-explicit-collar.wls", "collar.log")
    wolfram("15a-n11-ordered-root.wls", "root.log")
    wolfram("15b-n11-radial-order.wls", "order-statistic.log")
    root = json.loads((RESULTS / "root-ordered.json").read_text())
    target = json.loads((ROOT /
        "experiments/2026-10-11-n11-inner-lift/results/lift.json").read_text())
    eps = Q(1, 10**11)
    bounds = [(max(Q(0), Q(lo)-eps), min(Q(1), Q(hi)+eps)) for lo, hi in root["bounds"]]
    radii = (Q(root["radius"][0])-eps, Q(root["radius"][1])+eps)
    local = localize_b9(radii, target, bounds, budget=1)
    assert local["closed_to_target"] and local["stats"]["localized"] == 1
    (RESULTS / "local-tree.json").write_text(json.dumps(local, indent=2)+"\n")
    saved = json.loads((RESULTS / "local-tree.json").read_text())
    assert replay_b9_localization(saved, target)
    wolfram("15c-n11-localization-leaf.wls", "leaf.log")

    runs = []
    for lo, hi in [("2.786784686984", "2.7868"), ("2.7868", "2.787"),
                   ("2.78", "2.781"), ("2.7", "2.701"),
                   (str(Q(target["radius_floor"])), "2.786784686984")]:
        result = localize_b9((Q(lo), Q(hi)), target, budget=127, max_depth=100)
        replay = replay_b9_localization(result, target)
        assert replay == result["closed_to_target"]
        destination = RESULTS if replay else OUT
        name = f"domain-{len(runs)}.json"
        (destination / name).write_text(json.dumps(result, indent=2)+"\n")
        runs.append({"radii": result["radii"], "closed_to_target": replay,
                     "stats": result["stats"], "file": str((destination / name).relative_to(HERE))})
        print(runs[-1], flush=True)
    summary = {"level": "L3 specified leaves and coarse b9 bound; global sharp bound NOT proved",
               "coarse_b9_upper": "2.786784686984", "local_parameter_padding": str(eps),
               "local_tree": local["stats"], "runs": runs,
               "global_sharp_bound_proved": False, "b10_touched": False}
    (RESULTS / "summary.json").write_text(json.dumps(summary, indent=2)+"\n")
    print("DONE: b9 coarse bound and localization interface only; global sharp proof OPEN")


if __name__ == "__main__":
    main()
