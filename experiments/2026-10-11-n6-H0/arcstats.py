"""Inspect boundary-arc structure of n=6 configs (float, L1 diagnostics only)."""
import json
import sys

import numpy as np

for f in sys.argv[1:]:
    d = json.load(open(f))
    R = float(d["R"])
    C = np.array(d["centers"], float)
    al = np.arcsin(1 / R)
    print(f, "R=", R, "2alpha=", 2 * al, "12a-2pi=", 12 * al - 2 * np.pi)
    tot = 0.0
    for c in C:
        r = np.hypot(*c)
        th = np.arccos(np.clip((R * R + r * r - 1) / (2 * R * r), -1, 1)) if r >= R - 1 else 0.0
        tot += 2 * th
        print(f"  c=({c[0]:+.4f},{c[1]:+.4f}) |c|={r:.4f} dir={np.degrees(np.arctan2(c[1], c[0])):7.2f} "
              f"halfarc={np.degrees(th):6.2f} loss={2 * al - 2 * th:.4f} origin_in={r <= 1}")
    print("  sum arcs - 2pi =", tot - 2 * np.pi)
