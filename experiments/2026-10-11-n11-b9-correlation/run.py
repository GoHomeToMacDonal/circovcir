#!/usr/bin/env python3
"""Deterministic b9 sector-union support certificates; proposals are not proofs."""
from __future__ import annotations

import json
import os
import subprocess
from fractions import Fraction as Q
from pathlib import Path

from circovcir.b9_rank import rank_cases
from circovcir.residual_propagation import check_propagation, propose_propagation
from circovcir.sliced_sectors import (
    check_sliced_domain,
    propose_sliced_domain,
    replay_sliced_cover,
)

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
RESULTS, OUT = HERE / "results", HERE / "out"


def ablate(payload):
    rows = []
    for panel in payload["panels"]:
        for entry in panel["cases"]:
            domain = entry["domain"]
            slices = len(domain["pieces"][1])
            if slices == 1:
                continue
            polar = [[tuple(map(Q, p)) for p in s] for s in domain["root"]["polar"]]
            closed = False
            for seeds in (24, 48):
                leaf = propose_propagation(polar, Q(panel["radii"][0]), seed_limit=seeds)
                if leaf is not None:
                    assert check_propagation(polar, Q(panel["radii"][0]), leaf)
                    closed = True
                    break
            rows.append({"radii": panel["radii"], "rank": domain["root"]["rank"],
                         "slices": slices, "unsliced_24_or_48_closed": closed})
    result = {"rows": rows, "still_unresolved_without_slicing":
              sum(not row["unsliced_24_or_48_closed"] for row in rows)}
    (RESULTS / "ablation.json").write_text(json.dumps(result, default=str, indent=2)+"\n")
    print("unsliced 24/48 control still unresolved:",
          result["still_unresolved_without_slicing"], flush=True)


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--cuts", nargs="+", default=["2.73", "2.735", "2.74"])
    parser.add_argument("--proposal-only", action="store_true")
    args = parser.parse_args()
    RESULTS.mkdir(exist_ok=True)
    OUT.mkdir(exist_ok=True)
    cuts = list(map(Q, args.cuts))
    panels, unresolved, stats = [], [], []
    for lo, hi in zip(cuts[:-1], cuts[1:], strict=True):
        rr = (lo, hi)
        records, counts = [], {}
        for rank in rank_cases():
            leaf = None
            for slices in (1, 4, 8):
                domain = propose_sliced_domain(rr, rank, slices=slices)
                assert domain is not None, (rr, rank, slices)
                polar = check_sliced_domain(rr, domain)
                assert polar is not None
                leaf = propose_propagation(polar, rr[0])
                if leaf is None and slices == 8:
                    leaf = propose_propagation(polar, rr[0], seed_limit=48)
                if leaf is not None:
                    assert check_propagation(polar, rr[0], leaf)
                    break
            if leaf is None:
                unresolved.append((rr, rank))
                print("UNRESOLVED", rr, rank, flush=True)
            else:
                records.append({"domain": domain, "leaf": leaf})
                counts[slices] = counts.get(slices, 0)+1
            print([str(x) for x in rr], rank, "slices", slices,
                  "closed", leaf is not None, flush=True)
        panels.append({"radii": rr, "cases": records})
        stats.append({"radii": rr, "slice_counts": counts})
        (OUT / "partial.json").write_text(json.dumps(
            {"panels": panels, "unresolved": unresolved}, default=str)+"\n")
    if unresolved:
        print("INCOMPLETE", len(unresolved), "domains; no new bound", flush=True)
        return
    payload = {"lower": cuts[0], "upper": cuts[-1], "panels": panels}
    path = RESULTS / "sliced-cover.json"
    path.write_text(json.dumps(payload, default=str, separators=(",", ":"))+"\n")
    assert replay_sliced_cover(json.loads(path.read_text()))
    print("Python exact replay passed", flush=True)
    ablate(payload)
    if args.proposal_only:
        return
    exe = os.environ.get("WOLFRAMSCRIPT", str(Path.home() /
        "Wolfram/Mathematica/14.3/Executables/wolframscript"))
    for name, log, marker in [
        ("15b-n11-radial-order.wls", "previous-upper.log",
         "CERTIFICATE OK (L3): all b9 R < 2.786784686984"),
        ("18a-n11-sliced-cover.wls", "sliced-cover.log",
         "CERTIFICATE OK (L3): all b9 R < 2.73")]:
        proc = subprocess.run([exe, "-file", str(ROOT / "proofs/certificates" / name)],
                              capture_output=True, text=True, check=False)
        (RESULTS / log).write_text(proc.stdout+"\nSTDERR:\n"+proc.stderr)
        assert proc.returncode == 0 and marker in proc.stdout, name
        print(name, "OK", flush=True)
    (RESULTS / "summary.json").write_text(json.dumps({
        "level": "L3 computations; geometric reductions await review",
        "strict_b9_upper": str(cuts[0]), "panels": stats,
        "sharp_Rstar_bound_proved": False, "b10_touched": False}, default=str, indent=2)+"\n")


if __name__ == "__main__":
    main()
