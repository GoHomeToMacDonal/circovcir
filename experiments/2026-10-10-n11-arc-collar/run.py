#!/usr/bin/env python3
"""Deterministic ordered-arc experiments and Wolfram certificates 13a/13b."""

from __future__ import annotations

import json
import os
import subprocess
from fractions import Fraction as Q
from pathlib import Path

import numpy as np

from circovcir.branchbound import exclude_ordered_domain, replay_ordered_exclusion
from circovcir.ordered_arcs import contract_simplex, decode_float, ordered_center_boxes

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = HERE / "out"
RESULTS = HERE / "results"


def encode_diagnostic():
    data = json.loads((ROOT / "data/configs/11/20261008-melissen-kkt.json").read_text())
    c = np.array(data["centers"], float)[2:]
    radius = float(data["R"])
    radial = np.linalg.norm(c, axis=1)
    anchor = int(np.argmin(radial))
    theta = (np.arctan2(c[:, 1], c[:, 0])-np.arctan2(c[anchor, 1], c[anchor, 0])) % (2*np.pi)
    order = np.argsort(theta)
    radial, theta = radial[order], theta[order]
    a = np.arcsin(1/radius)
    deficit = 9*a-np.pi
    w = np.arccos((radius**2+radial**2-1)/(2*radius*radial))
    gaps = np.diff(np.r_[theta, 2*np.pi])
    overlap = w+np.roll(w, -1)-gaps
    u = (a-w)/deficit
    v = overlap/(2*deficit)
    points = decode_float(radius, np.r_[u, v])
    expected = radial[:, None]*np.column_stack([np.cos(theta), np.sin(theta)])
    return {"level": "L1 diagnostic only", "radius": data["R"],
            "original_1_based_outer_order": (order+3).tolist(),
            "u": u.tolist(), "v": v.tolist(), "sum": float(sum(u)+sum(v)),
            "decode_error": float(np.max(np.abs(points-expected)))}


# Python/WL ordered-box spot check uses the same rational input rectangle.

def main():
    OUT.mkdir(exist_ok=True)
    RESULTS.mkdir(exist_ok=True)
    diagnostic = encode_diagnostic()
    (RESULTS / "melissen-simplex.json").write_text(json.dumps(diagnostic, indent=2)+"\n")
    print("L1 Melissen simplex sum / max overlap:", diagnostic["sum"], max(diagnostic["v"]))

    # Explicit interior simplex neighborhood, no KKT-root identification is needed.
    x = [Q(1, 5)]+[Q(1, 10)]*8+[Q(0)]*9
    initial = [(max(0, q-Q(1, 10**5)), min(1, q+Q(1, 10**5))) for q in x]
    bounds = contract_simplex(initial)
    radius = Q("2.7")
    result = exclude_ordered_domain(radius, bounds, budget=63)
    replay = replay_ordered_exclusion(radius, result["bounds"], result["tree"])
    assert replay == result["closed"]
    destination = RESULTS if result["closed"] else OUT
    (destination / "simplex-local-tree.json").write_text(json.dumps(
        {"radius": str(radius), **result}, indent=2)+"\n")
    print("ordered local:", result["closed"], result["stats"])

    # Independent WL checks all rational enclosures for one fixed interval box.
    boxes = ordered_center_boxes(radius, bounds)
    (OUT / "interval-crosscheck.json").write_text(json.dumps({
        "radius": str(radius), "bounds": [[str(x) for x in b] for b in bounds],
        "boxes": [[[str(x) for x in p] for p in b] for b in boxes]}, indent=2)+"\n")

    runs = []
    for target in (Q("2.7"), Q("2.64")):
        tree = exclude_ordered_domain(target, budget=127, max_depth=80)
        replay = replay_ordered_exclusion(target, tree["bounds"], tree["tree"])
        assert replay == tree["closed"]
        (OUT / f"global-{target.numerator}-{target.denominator}.json").write_text(
            json.dumps({"radius": str(target), **tree}, indent=2))
        runs.append({"radius": str(target), "closed": tree["closed"], "stats": tree["stats"]})
        print("ordered GLOBAL:", runs[-1])

    exe = os.environ.get("WOLFRAMSCRIPT", str(Path.home() /
        "Wolfram/Mathematica/14.3/Executables/wolframscript"))
    cross_script = '''
    js=Import["%s","RawJSON"];
    b=Map[ToExpression,js["bounds"],{2}];r=ToExpression[js["radius"]];
    bb=Map[ToExpression,js["boxes"],{3}];
    (* Nine explicit simplex points, one per perturbed pair of deficit variables. *)
    center={1/5,1/10,1/10,1/10,1/10,1/10,1/10,1/10,1/10,0,0,0,0,0,0,0,0,0};
    enc[x_]:=N[Interval[{x,x}],90];a=ArcSin[1/enc[r]];dd=9a-enc[Pi];
    good=True;
    Do[x=center;If[k>0,x[[1]]+=1/1000000;x[[k+1]]-=1/1000000];
     widths=a-dd Take[x,9];radial=enc[r] Cos[widths]-Sqrt[1-enc[r]^2 Sin[widths]^2];
     gaps=Table[2a-dd(x[[i]]+x[[Mod[i,9]+1]]+2x[[9+i]]),{i,9}];
     angles=Prepend[Accumulate[Most[gaps]],0];
     points=MapThread[#1 {Cos[#2],Sin[#2]}&,{radial,angles}];
     good=good&&And@@Flatten[Table[Min[points[[i,j]]]>=bb[[i,1,j]]&&
       Max[points[[i,j]]]<=bb[[i,2,j]],{i,9},{j,2}]],{k,0,8}];
    Print["CROSSCHECK explicit samples: ",good];If[TrueQ[good],Exit[0],Exit[1]];
    ''' % (OUT / "interval-crosscheck.json")
    (OUT / "crosscheck.wls").write_text(cross_script)
    result = subprocess.run([exe, "-file", str(OUT / "crosscheck.wls")],
                            capture_output=True, text=True, check=False)
    (RESULTS / "crosscheck.log").write_text(result.stdout+"\nSTDERR:\n"+result.stderr)
    assert result.returncode == 0 and "CROSSCHECK explicit samples: True" in result.stdout

    for filename, log in [("13a-n11-ordered-arcs.wls", "arcs.log"),
                          ("13b-n11-explicit-collar.wls", "collar.log")]:
        result = subprocess.run([exe, "-file", str(ROOT / "proofs/certificates" / filename)],
                                capture_output=True, text=True, check=False)
        (RESULTS / log).write_text(result.stdout+"\nSTDERR:\n"+result.stderr)
        assert result.returncode == 0 and "CERTIFICATE OK (L3)" in result.stdout
        print(filename, "OK")
    (RESULTS / "summary.json").write_text(json.dumps({
        "global_sharp_bound_proved": False, "ordered_global_runs": runs,
        "collar_radius": "1/500000", "strong_concavity_mu": "7/500",
        "certificate_13a": True, "certificate_13b": True}, indent=2)+"\n")
    print("DONE: explicit local collar certified; global localization NOT proved")


if __name__ == "__main__":
    main()
