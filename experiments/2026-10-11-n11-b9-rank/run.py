#!/usr/bin/env python3
"""Complete b9 rank-case exclusions; independent LP/trig replay with Wolfram."""
from __future__ import annotations

import json
import os
import subprocess
from fractions import Fraction as Q
from math import ceil, floor
from pathlib import Path

from circovcir.b9_rank import contract_ranked, rank_cases
from circovcir.b9_search import localize_b9, replay_b9_localization
from circovcir.ordered_arcs import global_simplex, ordered_polar_bounds
from circovcir.rank_duals import check_rank_duals, propose_rank_duals, replay_rank_cover_payload
from circovcir.sector_exclusion import check_sector_exclusion

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT, RESULTS = HERE / "out", HERE / "results"


def outward(pair):
    return (Q(floor(pair[0]*10**24), 10**24), Q(ceil(pair[1]*10**24), 10**24))


def main():
    OUT.mkdir(exist_ok=True)
    RESULTS.mkdir(exist_ok=True)
    target = json.loads((ROOT /
        "experiments/2026-10-11-n11-inner-lift/results/lift.json").read_text())
    # Adjacent closed intervals cover [2.76, old certified upper].
    cuts = list(map(Q, ["2.76", "2.765", "2.77", "2.775", "2.78", "2.786784686984"]))
    panels = []
    for lo, hi in zip(cuts[:-1], cuts[1:], strict=True):
        rr = (lo, hi)
        records = []
        for rank in rank_cases():
            tree = localize_b9(rr, target, rank=rank, sectors=True, budget=1)
            assert tree["closed_to_target"] and "sector_residual" in tree["tree"]
            assert replay_b9_localization(tree, target)
            # Relax root domain on a decimal rational grid for independent WP90 replay.
            b = contract_ranked(rr, global_simplex(rr), rank)
            b = tuple((max(Q(0), a), min(Q(1), z)) for a, z in map(outward, b))
            dual = propose_rank_duals(rr, rank, b)
            assert dual is not None
            # Floors rounded down on a coarser grid leave an independent-WL margin.
            floors = [Q(floor(Q(x)*10**30), 10**30) for x in dual["floors"]]
            assert check_rank_duals(floors, rank, b, dual["duals"])
            leaf = tree["tree"]["sector_residual"]
            assert check_sector_exclusion(rr, b, leaf)
            polar = [[outward(p) for p in s] for s in ordered_polar_bounds(rr, b)]
            records.append({"rank": rank, "bounds": b, "floors": floors,
                            "duals": dual["duals"], "polar": polar, "leaf": leaf})
        panels.append({"radii": rr, "cases": records})
        print("L3 proposed/replayed panel", float(lo), float(hi), "56/56", flush=True)
    payload = {"lower": cuts[0], "upper": cuts[-1], "panels": panels}
    (RESULTS / "rank-cover.json").write_text(json.dumps(payload, default=str,
                                                       separators=(",", ":"))+"\n")
    assert replay_rank_cover_payload(json.loads((RESULTS / "rank-cover.json").read_text()))
    # Honest near-target diagnostic, not part of the global upper certificate.
    partial = []
    for rank in [(1, 2), (4, 5), (4, 6)]:
        tree = localize_b9((Q("2.64"), Q("2.641")), target, rank=rank,
                           sectors=True, budget=15, max_depth=60)
        assert not tree["closed_to_target"]
        assert not replay_b9_localization(tree, target)
        (OUT / f"partial-{rank[0]}-{rank[1]}.json").write_text(json.dumps(tree, indent=2))
        partial.append({"rank": rank, "stats": tree["stats"]})
    exe = os.environ.get("WOLFRAMSCRIPT", str(Path.home() /
        "Wolfram/Mathematica/14.3/Executables/wolframscript"))
    for name, log in [("15b-n11-radial-order.wls", "previous-upper.log"),
                      ("16a-n11-rank-cover.wls", "rank-cover.log")]:
        proc = subprocess.run([exe, "-file", str(ROOT / "proofs/certificates" / name)],
                              capture_output=True, text=True, check=False)
        (RESULTS / log).write_text(proc.stdout+"\nSTDERR:\n"+proc.stderr)
        assert proc.returncode == 0 and "CERTIFICATE OK (L3)" in proc.stdout, name
        print(name, "OK", flush=True)
    (RESULTS / "summary.json").write_text(json.dumps({
        "level": "L3 complete b9 coarse bound with geometric reductions awaiting review",
        "b9_upper_strict": "2.76", "panels": len(panels), "rank_cases_per_panel": 56,
        "excluded_root_domains": len(panels)*56, "partial_near_target": partial,
        "sharp_Rstar_bound_proved": False, "b10_touched": False}, indent=2)+"\n")
    print("DONE: b9 R<2.76; sharp Rstar bound still OPEN", flush=True)


if __name__ == "__main__":
    main()
