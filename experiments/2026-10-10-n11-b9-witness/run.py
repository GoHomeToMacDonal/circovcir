#!/usr/bin/env python3
"""Deterministic rotation stress test and exact local chart-box exclusions.

This script is not a global b=9 proof. It exports replayable exact rational
witness leaves for explicit domains, plus an honest budget-limited broad probe.
"""

from __future__ import annotations

import json
import os
import subprocess
from fractions import Fraction as Q
from pathlib import Path

import numpy as np

from circovcir.branchbound import (
    b9_global_charts,
    exclude_chart_domain,
    replay_chart_exclusion,
)
from circovcir.exclusion import (
    chart_box,
    check_b9_exclusion,
    check_two_disk_obstruction,
    check_witness,
    propose_b9_exclusion,
    propose_witness,
    rational_direction,
    two_disk_obstruction,
)
from circovcir.geometry import nearest_distances

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = HERE / "out"
RESULTS = HERE / "results"
OUT.mkdir(exist_ok=True)
RESULTS.mkdir(exist_ok=True)


def read_config():
    data = json.loads((ROOT / "data/configs/11/20261008-melissen-kkt.json").read_text())
    return data, np.array(data["centers"], dtype=float)


def charts_about(centers, width):
    """Explicit rational neighborhoods; no claim of exact KKT containment."""
    charts = []
    for x, y in centers:
        angle = np.arctan2(y, x)
        base = rational_direction(Q(float(np.tan(angle/2))).limit_denominator(10**9))
        radial = Q(float(np.hypot(x, y))).limit_denominator(10**9)
        charts.append({"base": [str(v) for v in base],
                       "radial": [str(max(Q(0), radial-width)), str(radial+width)],
                       "tangent": [str(-width), str(width)]})
    return charts


def rotation_test(centers, radius):
    boundary_t = np.arange(720)*2*np.pi/720
    boundary = float(radius)*np.column_stack([np.cos(boundary_t), np.sin(boundary_t)])
    k = np.arange(2500)+0.5
    inner_t = k*np.pi*(3-np.sqrt(5))
    interior = float(radius)*np.sqrt(k/2500)[:, None]*np.column_stack(
        [np.cos(inner_t), np.sin(inner_t)])
    fixed = np.vstack([boundary, interior])
    rows = []
    witnesses = []
    for j in range(36):
        # Rational orthogonal rotations: exact reproducibility of the checked boxes.
        u, v = rational_direction(Q(j, 36))
        rational_centers = [[Q(str(x))*u-Q(str(y))*v, Q(str(x))*v+Q(str(y))*u]
                            for x, y in centers]
        boxes = [(tuple(p), tuple(p)) for p in rational_centers]
        c = np.array(rational_centers, dtype=float)
        sampled = float(nearest_distances(fixed, c).max())
        witness = propose_witness(boxes, radius)
        assert witness is not None
        assert check_witness(boxes, radius, witness.point) == witness
        rows.append({"rotation_t": str(Q(j, 36)), "sampled_rho_float": sampled,
                     "sampled_accepts_float": sampled <= 1,
                     "exact_witness_margin2": str(witness.margin2)})
        witnesses.append({"t": str(Q(j, 36)), "point": [str(x) for x in witness.point]})
    return {"radius": str(radius),
            "base_centers": [[str(Q(str(x))) for x in p] for p in centers],
            "sample_size": len(fixed),
            "rotations": len(rows), "sampled_accept_count": sum(r["sampled_accepts_float"]
                                                                      for r in rows),
            "exact_reject_count": len(witnesses), "rows": rows,
            "witnesses": witnesses}


def replay_saved_results():
    """Replay saved finite certificates using only rational arithmetic."""
    stress = json.loads((RESULTS / "rotation.json").read_text())
    base = [[Q(x) for x in p] for p in stress["base_centers"]]
    for row in stress["witnesses"]:
        u, v = rational_direction(row["t"])
        centers = [(x*u-y*v, x*v+y*u) for x, y in base]
        boxes = [(p, p) for p in centers]
        assert check_witness(boxes, stress["radius"], row["point"]) is not None
    for path in sorted(RESULTS.glob("chart-*.json")):
        data = json.loads(path.read_text())
        assert replay_chart_exclusion(data["charts"], data["radius"], data["tree"])
    for path in sorted(RESULTS.glob("global-root-*.json")):
        data = json.loads(path.read_text())
        assert replay_chart_exclusion(data["charts"], data["radius"], data["tree"], b9=True)
    for path in sorted(RESULTS.glob("residual-*.json")):
        data = json.loads(path.read_text())
        assert check_b9_exclusion(data["boxes"], data["radius"], data["certificate"])
    print("SAVED CERTIFICATES: exact replay OK")


def main():
    data, centers = read_config()
    radius = Q("2.631691")
    # Stress test at a radius only 2.27e-7 above the known stationary value.
    stress = rotation_test(centers, radius)
    print("rotation stress:", stress["sampled_accept_count"], "sample passes /",
          stress["exact_reject_count"], "exact exclusions")
    (RESULTS / "rotation.json").write_text(json.dumps(stress, indent=2)+"\n")

    runs = []
    for delta, width, budget in [(Q(1, 1000), Q(1, 100000), 100),
                                  (Q(1, 1000000), Q(1, 100000000), 100),
                                  (Q(1, 1000), Q(1, 100), 255)]:
        # Decimal KKT data is only the center of the test family, never assumed exact.
        target = Q(data["R"])+delta
        charts = charts_about(centers, width)
        result = exclude_chart_domain(charts, target, budget=budget, max_depth=100)
        replay = replay_chart_exclusion(charts, target, result["tree"])
        assert replay == result["closed"]
        index = len(runs)
        payload = {"charts": charts, "radius": str(target), **result}
        destination = RESULTS if result["closed"] else OUT
        (destination / f"chart-{index}.json").write_text(json.dumps(payload, indent=2)+"\n")
        runs.append({"delta": str(delta), "width": str(width),
                     "closed": result["closed"], "replay": replay, "stats": result["stats"]})
        print("chart:", runs[-1])

    # Residual obstructions: nine outer disks only, two extra disks unrestricted.
    residual_runs = []
    for radius_text in ("2.631691", "2.7", "2.8"):
        target = Q(radius_text)
        outer_charts = []
        for j in range(9):
            base = rational_direction(Q(float(np.tan(np.pi*j/9))).limit_denominator(10**10))
            d = Q(float(np.sqrt(float(target)**2-1))).limit_denominator(10**10)
            width = Q(1, 100000)
            outer_charts.append({"base": [str(x) for x in base],
                                 "radial": [str(d-width), str(d+width)],
                                 "tangent": [str(-width), str(width)]})
        boxes = [chart_box(c["radial"], c["tangent"], c["base"]) for c in outer_charts]
        cert = propose_b9_exclusion(boxes, target)
        assert cert is not None and "residual_points" in cert
        assert check_b9_exclusion(boxes, target, cert)
        payload = {"boxes": [[[str(x) for x in p] for p in b] for b in boxes],
                   "radius": str(target), "certificate": cert}
        (RESULTS / f"residual-{radius_text}.json").write_text(json.dumps(payload, indent=2)+"\n")
        residual_runs.append({"radius": radius_text, "point_count": len(cert["residual_points"]),
                              "exact_replay": True})
    # A b9 parameter family around Melissen's OUTER circles. The two omitted
    # centers are completely unrestricted, unlike the earlier 11-center probes.
    outer_charts = charts_about(centers[2:], Q(1, 1000))
    b9_result = exclude_chart_domain(outer_charts, Q("2.6327"), budget=127, b9=True)
    b9_replay = replay_chart_exclusion(outer_charts, Q("2.6327"), b9_result["tree"], b9=True)
    assert b9_replay == b9_result["closed"]
    (OUT / "b9-tree.json").write_text(json.dumps(
        {"charts": outer_charts, "radius": "2.6327", **b9_result}, indent=2)+"\n")
    print("b9 outer-only probe:", b9_result["closed"], b9_result["stats"])

    global_probes = []
    for index, charts in enumerate(b9_global_charts(Q("2.82"))):
        result = exclude_chart_domain(charts, Q("2.82"), budget=1, b9=True)
        replay = replay_chart_exclusion(charts, Q("2.82"), result["tree"], b9=True)
        assert replay == result["closed"]
        if result["closed"]:
            (RESULTS / f"global-root-{index}.json").write_text(json.dumps(
                {"charts": charts, "radius": "2.82", "tree": result["tree"]}, indent=2)+"\n")
        global_probes.append({"root": index, "closed": result["closed"],
                              "stats": result["stats"]})
    print("global b9 roots:", len(global_probes), "closed:",
          sum(r["closed"] for r in global_probes))

    # Minimal exact calibration of the residual two-center conflict approach.
    residual = [(0, 0), (3, 0), (0, 3)]
    cert = two_disk_obstruction(residual)
    assert cert is not None and check_two_disk_obstruction(residual, cert)
    summary = {"level": "L3 exact exclusion of explicitly listed boxes only",
               "global_b9_bound_proved": False,
               "rotation_exact_exclusions": stress["exact_reject_count"],
               "fixed_sample_accepts_float": stress["sampled_accept_count"], "chart_runs": runs,
               "residual_runs": residual_runs, "global_root_probes": global_probes,
               "b9_probe": {"closed": b9_result["closed"], "replay": b9_replay,
                            "stats": b9_result["stats"]}}
    exe = os.environ.get("WOLFRAMSCRIPT", str(Path.home() /
        "Wolfram/Mathematica/14.3/Executables/wolframscript"))
    proc = subprocess.run([exe, "-file", str(ROOT / "proofs/certificates/12a-n11-b9-domain.wls")],
                          capture_output=True, text=True, check=False)
    (RESULTS / "domain.log").write_text(proc.stdout+"\nSTDERR:\n"+proc.stderr)
    assert proc.returncode == 0 and "CERTIFICATE OK (L3)" in proc.stdout
    summary["wolfram_domain_certificate"] = True
    (RESULTS / "summary.json").write_text(json.dumps(summary, indent=2)+"\n")
    replay_saved_results()
    print("DONE: global b=9 sharp bound NOT proved")


if __name__ == "__main__":
    main()
