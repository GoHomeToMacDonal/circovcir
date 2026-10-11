"""Case 2, Lemma V* as a three-point test (float exploration, L1 only).

A right disk O5 holding V* must contain an end-portion of A_R of length gR, hence the three
points {V*, E, E'} where E is an end of A_R and E' the point at angular distance gR inside A_R.
Excluded iff the minimal enclosing circle of each triple has radius > 1.  Also prints the
budget-feasible ranges and min gL, gR.
"""
import case2_explore as c2
import case3_exact as m
import numpy as np

R, al = m.R, m.al


def mec_radius(P):
    """radius of the minimal enclosing circle of 3 points."""
    a, b, c = P
    best = np.inf
    for u, v, w in ((a, b, c), (b, c, a), (c, a, b)):
        mid = (u + v) / 2
        r = np.linalg.norm(u - v) / 2
        if np.linalg.norm(w - mid) <= r + 1e-15:
            best = min(best, r)
    if np.isfinite(best):
        return best
    A = np.linalg.norm(b - c)
    B_ = np.linalg.norm(a - c)
    C = np.linalg.norm(a - b)
    cr = abs((b - a)[0] * (c - a)[1] - (b - a)[1] * (c - a)[0])
    return A * B_ * C / (2 * cr)


def pt(ang):
    return R * np.array([np.cos(ang), np.sin(ang)])


rows = []
for a in np.linspace(R - 1 + 1e-4, 1, 61):
    q = np.array([0.0, a - 1])
    for x2 in np.linspace(0, 1, 121):
        for y2 in np.linspace(-2.2, 0, 265):
            cP = np.array([x2, y2])
            if np.linalg.norm(cP - q) > 1 or np.linalg.norm(cP - m.B) > 1:
                continue
            AL, AR, (h1, h2) = c2.arcs_LR(a, x2, y2)
            if 2 * h1 + 2 * h2 + 8 * al < 2 * np.pi:
                continue
            gR = AR[1] - 2 * al
            v = c2.vstar(a, y2)
            s, L = AR
            r1 = mec_radius([v, pt(s), pt(s + gR)])
            r2 = mec_radius([v, pt(s + L), pt(s + L - gR)])
            rows.append((a, x2, y2, AL[1] - 2 * al, gR, r1 - 1, r2 - 1))
rows = np.array(rows)
print("feasible", len(rows), "a in", rows[:, 0].min(), rows[:, 0].max(), "x2 max", rows[:, 1].max(),
      "y2 in", rows[:, 2].min(), rows[:, 2].max())
print("min gL", rows[:, 3].min(), "min gR", rows[:, 4].min())
for k, nm in ((5, "start end (T2^P side)"), (6, "T1 end")):
    i = rows[:, k].argmin()
    print("min MEC-1 at", nm, rows[i, k], "at", rows[i, :3])
