"""Case 2 closed-form tests (float exploration, L1 only).  See case2_explore.py for notation.

For a right disk O5 holding V*:  its arc I5 must contain an end-portion of A_R of length >= gR.
  (i)  2 * theta(min(1 + |V*|, d*)) < gR           (arc too short)
  (ii) J(V*) = {p in dD : |p - V*| <= 2} contains neither end-portion   (arc in the wrong place)
Excluded iff (i) or (ii).  Print the worst margins over a fine grid of the budget-feasible set.
"""
import case2_explore as c2
import case3_exact as m
import numpy as np

R, al = m.R, m.al


def J_arc(v):
    r = np.linalg.norm(v)
    if r <= 2 - R:
        return None  # whole circle
    cb = (R * R + r * r - 4) / (2 * R * r)
    if cb <= -1:
        return None
    return (np.arctan2(v[1], v[0]), np.arccos(cb))


def contains(arc, s, L):
    """does arc (centre, half) contain the ccw interval [s, s+L]?"""
    c, h = arc
    d0 = (s - (c - h)) % m.TWOPI
    return d0 + L <= 2 * h


rows = []
na = 41
for a in np.linspace(R - 1 + 1e-4, 1, na):
    q = np.array([0.0, a - 1])
    for x2 in np.linspace(0, 1, 101):
        for y2 in np.linspace(-2.2, 0, 221):
            cP = np.array([x2, y2])
            if np.linalg.norm(cP - q) > 1 or np.linalg.norm(cP - m.B) > 1:
                continue
            AL, AR, (h1, h2) = c2.arcs_LR(a, x2, y2)
            if 2 * h1 + 2 * h2 + 8 * al < 2 * np.pi:
                continue
            gL, gR = AL[1] - 2 * al, AR[1] - 2 * al
            v = c2.vstar(a, y2)
            t5 = m.theta(min(1 + np.linalg.norm(v), m.DSTAR))
            mi = gR - 2 * t5
            J = J_arc(v)
            if J is None:
                mii = -1.0
            else:
                ok1 = contains(J, AR[0], gR)
                ok2 = contains(J, (AR[0] + AR[1] - gR) % m.TWOPI, gR)
                mii = -1.0 if (ok1 or ok2) else 1.0
            rows.append((a, x2, y2, gL, gR, mi, mii, h1, h2))
rows = np.array(rows)
print("feasible", len(rows), "a-range", rows[:, 0].min(), rows[:, 0].max(),
      "x2 max", rows[:, 1].max(), "y2 range", rows[:, 2].min(), rows[:, 2].max())
print("min gL", rows[:, 3].min(), "min gR", rows[:, 4].min())
bad = rows[(rows[:, 5] <= 0) & (rows[:, 6] <= 0)]
print("points with neither (i) nor (ii):", len(bad))
print("min (i)-margin", rows[:, 5].min(), "; among (ii)-failures min (i)-margin",
      rows[rows[:, 6] <= 0, 5].min() if (rows[:, 6] <= 0).any() else None)
