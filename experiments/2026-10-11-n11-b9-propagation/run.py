#!/usr/bin/env python3
"""b9 forced-inner-center propagation: complete rank panels plus replay."""
from __future__ import annotations

import json
import os
import subprocess
from fractions import Fraction as Q
from math import ceil, floor
from pathlib import Path

from circovcir.b9_rank import contract_ranked, rank_cases
from circovcir.exclusion import two_disk_obstruction
from circovcir.ordered_arcs import global_simplex, ordered_polar_bounds
from circovcir.rank_duals import check_rank_duals, propose_rank_duals, replay_rank_cover_payload
from circovcir.residual_propagation import check_propagation, propose_propagation
from circovcir.sector_exclusion import (
    check_sector_exclusion,
    propose_sector_exclusion,
    sector_candidates,
)

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
RESULTS, OUT = HERE / "results", HERE / "out"


def outward(pair):
    return (Q(floor(pair[0]*10**24), 10**24), Q(ceil(pair[1]*10**24), 10**24))


def main():
    RESULTS.mkdir(exist_ok=True)
    OUT.mkdir(exist_ok=True)
    cuts = list(map(Q, ["2.74", "2.741", "2.742", "2.743", "2.745", "2.75", "2.755", "2.76"]))
    panels, stats = [], []
    for lo, hi in zip(cuts[:-1], cuts[1:], strict=True):
        rr = (lo, hi)
        records = []
        counts = {"residual": 0, "propagation": 0, "forced_points": 0}
        for rank in rank_cases():
            b = contract_ranked(rr, global_simplex(rr), rank)
            b = tuple((max(Q(0), a), min(Q(1), z)) for a, z in map(outward, b))
            polar = [[outward(p) for p in s] for s in ordered_polar_bounds(rr, b)]
            leaf = propose_sector_exclusion(rr, b, limit=18)
            kind = "residual"
            if leaf is None:
                kind = "propagation"
                leaf = propose_propagation(polar, rr[0])
                assert leaf is not None, (rr, rank)
                assert check_propagation(polar, rr[0], leaf)
                counts["forced_points"] += sum("force" in step for step in leaf["steps"])
            else:
                assert check_sector_exclusion(rr, b, leaf)
            dual = propose_rank_duals(rr, rank, b)
            assert dual is not None
            floors = [Q(floor(Q(x)*10**30), 10**30) for x in dual["floors"]]
            assert check_rank_duals(floors, rank, b, dual["duals"])
            records.append({"rank": rank, "bounds": b, "floors": floors,
                            "duals": dual["duals"], "polar": polar,
                            "leaf_type": kind, "leaf": leaf})
            counts[kind] += 1
        panels.append({"radii": rr, "cases": records})
        stats.append({"radii": [str(x) for x in rr], **counts})
        print(stats[-1], flush=True)
    payload = {"lower": cuts[0], "upper": cuts[-1], "panels": panels}
    path = RESULTS / "propagation-cover.json"
    path.write_text(json.dumps(payload, default=str, separators=(",", ":"))+"\n")
    assert replay_rank_cover_payload(json.loads(path.read_text()))
    ablation = {"propagation_leaves": 0, "same_24_seed_points_already_impossible": 0,
                "genuine_extension_cases": []}
    for panel in panels:
        for entry in panel["cases"]:
            if entry["leaf_type"] != "propagation":
                continue
            ablation["propagation_leaves"] += 1
            seeds = sector_candidates(entry["polar"], panel["radii"][0], limit=24)
            direct = two_disk_obstruction(seeds) is not None
            ablation["same_24_seed_points_already_impossible"] += direct
            if not direct:
                assert any("force" in s for s in entry["leaf"]["steps"])
                ablation["genuine_extension_cases"].append({"radii": panel["radii"],
                                                            "rank": entry["rank"]})
    (RESULTS / "ablation.json").write_text(json.dumps(ablation, default=str, indent=2)+"\n")
    exe = os.environ.get("WOLFRAMSCRIPT", str(Path.home() /
        "Wolfram/Mathematica/14.3/Executables/wolframscript"))
    for name, log in [("15b-n11-radial-order.wls", "previous-upper.log"),
                      ("17a-n11-propagation-cover.wls", "propagation-cover.log")]:
        proc = subprocess.run([exe, "-file", str(ROOT / "proofs/certificates" / name)],
                              capture_output=True, text=True, check=False)
        (RESULTS / log).write_text(proc.stdout+"\nSTDERR:\n"+proc.stderr)
        marker = ("CERTIFICATE OK (L3): all b9 domains excluded for 2.74" if name.startswith("17a")
                  else "CERTIFICATE OK (L3): all b9 R < 2.786784686984")
        assert proc.returncode == 0 and marker in proc.stdout, name
        print(name, "OK", flush=True)
    (RESULTS / "summary.json").write_text(json.dumps({
        "level": "L3 complete b9 coarse bound; geometric reductions await review",
        "strict_b9_upper": "2.74", "panels": stats,
        "previous_certificate_16_replayed": True,
        "sharp_Rstar_bound_proved": False, "b10_touched": False}, indent=2)+"\n")
    print("DONE: b9 R<2.74; sharp Rstar bound OPEN", flush=True)


if __name__ == "__main__":
    main()
