#!/usr/bin/env python3
"""Complete coverage-feedback experiment; no assumptions on the two inner centers."""
from __future__ import annotations

import json
import os
import subprocess
from collections import Counter
from fractions import Fraction as Q
from pathlib import Path

from circovcir.b9_rank import rank_cases
from circovcir.coverage_feedback import (
    propose_feedback,
    replay_feedback,
    replay_feedback_cover,
)
from circovcir.sliced_sectors import check_sliced_domain, propose_sliced_domain

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
RESULTS, OUT = HERE / "results", HERE / "out"


def diagnostics():
    records = []
    for lo, hi, ranks in [("2.7", "2.705", [(1, 5), (4, 5), (5, 4)]),
                           ("2.64", "2.641", [(1, 5), (4, 5), (5, 4)])]:
        rr = tuple(map(Q, (lo, hi)))
        for rank in ranks:
            domain = propose_sliced_domain(rr, rank, slices=8)
            assert check_sliced_domain(rr, domain) is not None
            groups = [[p["sector"] for p in g] for g in domain["pieces"]]
            params = [[p["parameter"] for p in g] for g in domain["pieces"]]
            leaf = propose_feedback(groups, rr[0], parameters=params, rank=rank, rounds=6)
            result = replay_feedback(groups, rr[0], leaf, parameters=params, rank=rank)
            assert leaf["status"] == "unresolved"
            assert result is not None or leaf.get("reason") == "no_seed_component"
            records.append({"radii": rr, "domain": domain, "leaf": leaf})
            print("lower diagnostic", lo, rank, "steps", len(leaf.get("steps", [])),
                  leaf.get("reason", "valid_prefix"), flush=True)
    (RESULTS / "lower-diagnostics.json").write_text(json.dumps(
        {"records": records, "coverage_or_exclusion_claimed": False},
        default=str, separators=(",", ":"))+"\n")


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--proposal-only", action="store_true")
    args = parser.parse_args()
    RESULTS.mkdir(exist_ok=True)
    OUT.mkdir(exist_ok=True)
    rr = (Q("2.72"), Q("2.725"))
    cases, unresolved = [], []
    for rank in rank_cases():
        domain = propose_sliced_domain(rr, rank, slices=8)
        assert check_sliced_domain(rr, domain) is not None
        groups = [[p["sector"] for p in g] for g in domain["pieces"]]
        parameters = [[p["parameter"] for p in g] for g in domain["pieces"]]
        leaf = propose_feedback(groups, rr[0], parameters=parameters, rank=rank, rounds=6)
        replay = replay_feedback(groups, rr[0], leaf, parameters=parameters, rank=rank)
        if replay is None or not replay[0]:
            leaf = propose_feedback(groups, rr[0], parameters=parameters, rank=rank,
                                    rounds=8, seed_limit=96)
            replay = replay_feedback(groups, rr[0], leaf, parameters=parameters, rank=rank)
        if replay is None or not replay[0]:
            unresolved.append(rank)
        cases.append({"domain": domain, "leaf": leaf})
        print(rank, leaf["status"], Counter(next(iter(s)) for s in leaf.get("steps", [])),
              flush=True)
        (OUT / "partial.json").write_text(json.dumps({"radii": rr, "cases": cases,
            "unresolved": unresolved}, default=str)+"\n")
    if unresolved:
        print("INCOMPLETE", unresolved, "no new bound", flush=True)
        return
    payload = {"radii": rr, "cases": cases}
    (RESULTS / "feedback-cover.json").write_text(json.dumps(
        payload, default=str, separators=(",", ":"))+"\n")
    assert replay_feedback_cover(json.loads((RESULTS / "feedback-cover.json").read_text()))
    print("Python all rank roots closed", flush=True)
    diagnostics()
    if args.proposal_only:
        return
    exe = os.environ.get("WOLFRAMSCRIPT", str(Path.home() /
        "Wolfram/Mathematica/14.3/Executables/wolframscript"))
    for name, log, marker in [
        ("15b-n11-radial-order.wls", "previous-upper.log",
         "CERTIFICATE OK (L3): all b9 R < 2.786784686984"),
        ("20a-n11-feedback-cover.wls", "feedback-cover.log",
         "CERTIFICATE OK (L3): all b9 R < 2.72")]:
        proc = subprocess.run([exe, "-file", str(ROOT / "proofs/certificates" / name)],
                              capture_output=True, text=True, check=False)
        (RESULTS / log).write_text(proc.stdout+"\nSTDERR:\n"+proc.stderr)
        assert proc.returncode == 0 and marker in proc.stdout, name
        print(name, "OK", flush=True)
    stats = Counter(next(iter(s)) for e in cases for s in e["leaf"]["steps"])
    (RESULTS / "summary.json").write_text(json.dumps({
        "level": "L3 computations; geometric reductions await review",
        "strict_b9_upper": "2.72", "domains": len(cases), "steps": stats,
        "sharp_Rstar_bound_proved": False, "b10_touched": False}, indent=2)+"\n")


if __name__ == "__main__":
    main()
