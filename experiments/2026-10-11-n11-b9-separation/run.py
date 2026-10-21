#!/usr/bin/env python3
"""Deterministic finite-line partitions and adaptive residual exclusion."""
from __future__ import annotations

import argparse
import json
import os
import subprocess
from fractions import Fraction as Q
from pathlib import Path

from circovcir.b9_rank import rank_cases
from circovcir.sector_exclusion import check_sector_points
from circovcir.separated_residual import (
    check_separated_residual,
    propose_separated_residual,
    replay_separated_cover,
)
from circovcir.sliced_sectors import check_sliced_domain, propose_sliced_domain
from circovcir.two_disk_separation import check_separated_two_disks

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
RESULTS, OUT = HERE / "results", HERE / "out"


def diagnostics():
    records = []
    for lo, hi in [("2.72", "2.725"), ("2.7", "2.705"), ("2.64", "2.641")]:
        rr = tuple(map(Q, (lo, hi)))
        for rank in [(1, 5), (4, 5), (5, 4)]:
            domain = propose_sliced_domain(rr, rank, slices=8)
            polar = check_sliced_domain(rr, domain)
            assert polar is not None
            leaf = propose_separated_residual(polar, rr[0])
            assert leaf["status"] == "unresolved" and leaf["decision"]["kind"] == "covered"
            assert check_sector_points(polar, rr[0], leaf["points"])
            assert check_separated_two_disks(leaf["points"], leaf["decision"])
            records.append({"radii": rr, "domain": domain, "leaf": leaf})
            print("finite-covered diagnostic", lo, rank, len(leaf["points"]), flush=True)
    (RESULTS / "finite-covered-diagnostics.json").write_text(json.dumps(
        {"records": records, "full_target_coverage_claimed": False},
        default=str, separators=(",", ":"))+"\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cuts", nargs="+", default=["2.725", "2.73"])
    parser.add_argument("--proposal-only", action="store_true")
    args = parser.parse_args()
    RESULTS.mkdir(exist_ok=True)
    OUT.mkdir(exist_ok=True)
    cuts = list(map(Q, args.cuts))
    panels, unresolved = [], []
    for lo, hi in zip(cuts[:-1], cuts[1:], strict=True):
        rr = lo, hi
        cases = []
        for rank in rank_cases():
            closed = False
            for slices in (1, 4, 8):
                domain = propose_sliced_domain(rr, rank, slices=slices)
                assert domain is not None
                polar = check_sliced_domain(rr, domain)
                assert polar is not None
                leaf = propose_separated_residual(polar, rr[0])
                closed = check_separated_residual(polar, rr[0], leaf)
                if closed:
                    break
            entry = {"domain": domain, "leaf": leaf}
            cases.append(entry)
            if not closed:
                unresolved.append((rr, rank))
            print([str(x) for x in rr], rank, "slices", slices, "closed", closed,
                  "points", len(leaf["points"]), "history", leaf["history"], flush=True)
        panels.append({"radii": rr, "cases": cases})
        (OUT / "partial.json").write_text(json.dumps({"panels": panels,
            "unresolved": unresolved}, default=str)+"\n")
    if unresolved:
        print("INCOMPLETE", unresolved, "no new bound", flush=True)
        return
    payload = {"lower": cuts[0], "upper": cuts[-1], "panels": panels}
    path = RESULTS / "separated-cover.json"
    path.write_text(json.dumps(payload, default=str, separators=(",", ":"))+"\n")
    assert replay_separated_cover(json.loads(path.read_text()))
    print("Python exact full replay passed", flush=True)
    diagnostics()
    if args.proposal_only:
        return
    exe = os.environ.get("WOLFRAMSCRIPT", str(Path.home() /
        "Wolfram/Mathematica/14.3/Executables/wolframscript"))
    for name, log, marker in [
        ("15b-n11-radial-order.wls", "previous-upper.log",
         "CERTIFICATE OK (L3): all b9 R < 2.786784686984"),
        ("19a-n11-separated-cover.wls", "separated-cover.log",
         "CERTIFICATE OK (L3): all b9 R < 2.725")]:
        proc = subprocess.run([exe, "-file", str(ROOT / "proofs/certificates" / name)],
                              capture_output=True, text=True, check=False)
        (RESULTS / log).write_text(proc.stdout+"\nSTDERR:\n"+proc.stderr)
        assert proc.returncode == 0 and marker in proc.stdout, name
        print(name, "OK", flush=True)
    entries = [e for panel in panels for e in panel["cases"]]
    summary = {"level": "L3 computations; geometric reductions await review",
               "strict_b9_upper": str(cuts[0]), "domains": len(entries),
               "point_counts": [len(e["leaf"]["points"]) for e in entries],
               "chambers": sum(len(e["leaf"]["decision"]["chambers"]) for e in entries),
               "adaptive_domains": sum(len(e["leaf"]["history"]) > 1 for e in entries),
               "sharp_Rstar_bound_proved": False, "b10_touched": False}
    (RESULTS / "summary.json").write_text(json.dumps(summary, indent=2)+"\n")


if __name__ == "__main__":
    main()
