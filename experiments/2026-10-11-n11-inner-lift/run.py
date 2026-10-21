#!/usr/bin/env python3
"""Deterministic G3 lifting certificate; floats propose, rationals alone accept."""
from __future__ import annotations

import json
import os
import subprocess
from fractions import Fraction as Q
from math import ceil
from pathlib import Path

import numpy as np

from circovcir.exclusion import check_witness, rational_inside
from circovcir.lifting import (
    center_box,
    center_box_certificate,
    check_two_center_lift,
    square_box,
)

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
RESULTS = HERE / "results"


def proposal():
    data = json.loads((ROOT / "data/configs/11/20261008-melissen-kkt.json").read_text())
    # These rational values define the domain, not unproved exact KKT coordinates.
    anchor = [tuple(Q(round(Q(x)*10**20), 10**20) for x in c) for c in data["centers"]]
    radius_anchor = Q(round(Q(data["R"])*10**20), 10**20)
    eps = Q(1, 125000000)  # 8e-9 per outer coordinate
    radius_floor = radius_anchor-Q(1, 10**7)
    radius_upper = radius_anchor+Q(1, 10**7)
    outer = [square_box(p, eps) for p in anchor[2:]]
    c = np.array(anchor, float)
    triples = {"E": (0, 9, 10), "C": (1, 2, 3), "Cp": (1, 2, 4),
               "B": (0, 5, 7), "Bp": (0, 6, 8), "D": (1, 3, 7), "Dp": (1, 4, 8),
               "A": (0, 1, 7), "Ap": (0, 1, 8)}
    nearby = {}
    for label, g in triples.items():
        a, b, d = c[list(g)]
        p = np.linalg.solve(2*np.vstack([b-a, d-a]), [b@b-a@a, d@d-a@a])
        nearby[label] = rational_inside(p, radius_floor, bits=60)

    def pushed(label, excluded, step):
        p = nearby[label]
        normal = [sum(p[k]-anchor[i][k] for i in excluded) for k in (0, 1)]
        return tuple(p[k]+step*normal[k] for k in (0, 1))

    labels = ["E", "C", "Cp", "B", "Bp", "D", "Dp"]
    points = [pushed(key, [i for i in triples[key] if i >= 2], 4*eps) for key in labels]
    assert all(check_witness(outer, radius_floor, p) is not None for p in points)
    # E--C,Cp; Cp--B; C--Bp; E--D,Dp. Opposite vertices must use different disks.
    tree = [[1, 0], [2, 0], [3, 2], [4, 1], [5, 0], [6, 0]]
    first_points = [points[i] for i in [0, 3, 4]]
    lower = center_box(first_points, anchor[0])
    lowrad = max(abs(lower[j][k]-anchor[0][k]) for j in (0, 1) for k in (0, 1))
    extras = [pushed(key, excluded, 4*lowrad)
              for key, excluded in [("A", [0, 7]), ("Ap", [0, 8])]]
    upper_points = [points[i] for i in [1, 2, 5, 6]]+extras
    cert = {"points": points, "color_tree": tree,
            "first_bound": center_box_certificate(first_points, anchor[0]),
            "second_points": extras,
            "second_bound": center_box_certificate(upper_points, anchor[1]),
            "radius_point": [Q(0), -radius_upper], "radius_upper": radius_upper}
    checked = check_two_center_lift(outer, radius_floor, cert)
    assert checked is not None
    for i, box in enumerate(checked[:2]):
        assert all(abs(box[j][k]-anchor[i][k]) < Q(1, 500000)
                   for j in (0, 1) for k in (0, 1))
    payload = {"outer_boxes": outer, "radius_floor": radius_floor,
               "outer_half_width": eps, "anchor_centers": anchor,
               "anchor_radius": radius_anchor, "certificate": cert}
    return json.loads(json.dumps(payload, default=str))


def main():
    RESULTS.mkdir(exist_ok=True)
    payload = proposal()
    path = RESULTS / "lift.json"
    path.write_text(json.dumps(payload, indent=2)+"\n")
    saved = json.loads(path.read_text())
    checked = check_two_center_lift(saved["outer_boxes"], saved["radius_floor"],
                                    saved["certificate"])
    assert checked is not None
    deviations = [max(abs(box[j][k]-Q(saved["anchor_centers"][i][k]))
                      for j in (0, 1) for k in (0, 1)) for i, box in enumerate(checked[:2])]
    print("L3 rational replay: first/second center max deviations", [float(x) for x in deviations])
    exe = os.environ.get("WOLFRAMSCRIPT", str(Path.home() /
        "Wolfram/Mathematica/14.3/Executables/wolframscript"))
    for name, log in [("14a-n11-inner-lift.wls", "lift.log"),
                      ("13b-n11-explicit-collar.wls", "collar.log")]:
        run = subprocess.run([exe, "-file", str(ROOT / "proofs/certificates" / name)],
                             capture_output=True, text=True, check=False)
        (RESULTS / log).write_text(run.stdout+"\nSTDERR:\n"+run.stderr)
        assert run.returncode == 0 and "CERTIFICATE OK (L3)" in run.stdout, name
        print(name, "OK")
    (RESULTS / "summary.json").write_text(json.dumps({
        "level": "L3 conditional lifting and collar; global localization NOT proved",
        "outer_half_width": saved["outer_half_width"],
        "center_deviation_upper_decimal": [str(Q(ceil(x*10**15), 10**15)) for x in deviations],
        "inner_bounds_exact": [saved["certificate"][key]["box"]
                               for key in ("first_bound", "second_bound")],
        "global_localization_proved": False}, indent=2)+"\n")
    print("DONE: arbitrary two inner centers lifted for specified outer box; global still OPEN")


if __name__ == "__main__":
    main()
