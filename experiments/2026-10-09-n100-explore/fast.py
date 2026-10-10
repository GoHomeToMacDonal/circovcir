"""Fast covering radius + LP minimax polish for large n (Delaunay candidate set).

Frame: target D(0,1), centers c (n,2); r(c) = max_{x in D} min_i |x - c_i|.
r is attained at (T) Voronoi vertices inside D (= circumcenters of Delaunay triangles),
(B) Voronoi edges meeting the circle (bisector of a Delaunay edge (i,j) at |x|=1, valid when
i,j are its nearest centers) or (A) the point of the circle farthest from c_i (valid when c_i
is its nearest).  Using Delaunay instead of all triples makes one evaluation O(n log n)
instead of O(n^3); `geometry.covering_radius` stays the reference (checked in run.py).

polish: sequential LP on the near-active candidates (each candidate's value is a smooth
function of <= 3 centers; gradients by central differences), trust region in L_inf,
accept only if the FAST exact radius decreases.
"""

from __future__ import annotations

import numpy as np
from scipy.optimize import linprog
from scipy.spatial import Delaunay


def _circumcenters(a, b, c):
    d = 2 * (a[:, 0] * (b[:, 1] - c[:, 1]) + b[:, 0] * (c[:, 1] - a[:, 1])
             + c[:, 0] * (a[:, 1] - b[:, 1]))
    aa, bb, cc = (a * a).sum(1), (b * b).sum(1), (c * c).sum(1)
    ux = (aa * (b[:, 1] - c[:, 1]) + bb * (c[:, 1] - a[:, 1]) + cc * (a[:, 1] - b[:, 1])) / d
    uy = (aa * (c[:, 0] - b[:, 0]) + bb * (a[:, 0] - c[:, 0]) + cc * (b[:, 0] - a[:, 0])) / d
    return np.column_stack([ux, uy])


def _bisector_circle(a, b, s):
    """Point(s) of |x|=1 equidistant from a and b; s = +-1 picks the branch. NaN if none."""
    v = b - a
    l2 = (v * v).sum(1)
    p = v * (((b * b).sum(1) - (a * a).sum(1)) / (2 * l2))[:, None]
    h2 = 1 - (p * p).sum(1)
    h = np.sqrt(np.where(h2 >= 0, h2, np.nan))
    u = np.column_stack([-v[:, 1], v[:, 0]]) / np.sqrt(l2)[:, None]
    return p + (s * h)[:, None] * u


def structure(c: np.ndarray):
    """Candidate generators: triangles (k,3), edge branches (m,2)+sign, singles (n,)."""
    tri = Delaunay(c).simplices
    e = np.vstack([tri[:, [0, 1]], tri[:, [1, 2]], tri[:, [0, 2]]])
    e = np.unique(np.sort(e, axis=1), axis=0)
    edges = np.vstack([e, e])
    signs = np.concatenate([np.ones(len(e)), -np.ones(len(e))])
    return tri, edges, signs


def candidate_values(c, tri, edges, signs, check=True):
    """(values, kinds) for all candidates; invalid candidates get -inf."""
    pts_T = _circumcenters(c[tri[:, 0]], c[tri[:, 1]], c[tri[:, 2]])
    vT = np.linalg.norm(pts_T - c[tri[:, 0]], axis=1)
    vT[(pts_T * pts_T).sum(1) > 1] = -np.inf
    pts_B = _bisector_circle(c[edges[:, 0]], c[edges[:, 1]], signs)
    vB = np.linalg.norm(pts_B - c[edges[:, 0]], axis=1)
    vB[~np.isfinite(vB)] = -np.inf
    nrm = np.linalg.norm(c, axis=1)
    pts_A = -c / np.maximum(nrm, 1e-15)[:, None]
    vA = nrm + 1.0
    if check:  # generator must be (among) the nearest centers
        for pts, v in ((pts_B, vB), (pts_A, vA)):
            ok = np.isfinite(v)
            if ok.any():
                q = pts[ok]
                dmin = np.sqrt(((q[:, None, :] - c[None, :, :]) ** 2).sum(-1).min(1))
                vv = v[ok]
                vv[vv > dmin + 1e-12] = -np.inf
                v[ok] = vv
    return vT, vB, vA


def fast_radius(c: np.ndarray) -> float:
    tri, edges, signs = structure(c)
    vT, vB, vA = candidate_values(c, tri, edges, signs)
    return float(max(vT.max(), vB.max(), vA.max()))


def _active(c, delta):
    tri, edges, signs = structure(c)
    vT, vB, vA = candidate_values(c, tri, edges, signs)
    top = max(vT.max(), vB.max(), vA.max())
    act = []
    for k in np.flatnonzero(vT >= top - delta):
        act.append(("T", tuple(tri[k])))
    for k in np.flatnonzero(vB >= top - delta):
        act.append(("B", tuple(edges[k]), signs[k]))
    for k in np.flatnonzero(vA >= top - delta):
        act.append(("A", (k,)))
    return act, top


def _value(t, c):
    if t[0] == "T":
        i, j, k = t[1]
        p = _circumcenters(c[[i]], c[[j]], c[[k]])[0]
        return float(np.linalg.norm(p - c[i]))
    if t[0] == "B":
        i, j = t[1]
        p = _bisector_circle(c[[i]], c[[j]], np.array([t[2]]))[0]
        return float(np.linalg.norm(p - c[i]))
    return float(np.linalg.norm(c[t[1][0]]) + 1)


def polish(c: np.ndarray, rounds: int = 400, step: float | None = None,
           tol: float = 1e-14, verbose: bool = False) -> np.ndarray:
    """Trust-region SLP.  The active set is every candidate within 3*step of the max: a
    candidate moves by at most ~3*step under an L_inf step (|grad| <= ~1.5 per center), so
    nothing outside it can become the max -- shrinking it independently of the step makes
    the LP zigzag between 1-2 constraints (observed: n=25 stalls at 4.058 < 4.1815)."""
    c = c.copy()
    n = len(c)
    r = fast_radius(c)
    step_max = 0.2 * r
    step = 0.05 * r if step is None else step
    h = 1e-7
    for it in range(rounds):
        act, _ = _active(c, 3 * step + 1e-12)
        A = np.zeros((len(act), 2 * n + 1))
        b = np.zeros(len(act))
        for q, t in enumerate(act):
            v0 = _value(t, c)
            for i in t[1]:
                for d in range(2):
                    cp = c.copy()
                    cp[i, d] += h
                    cm = c.copy()
                    cm[i, d] -= h
                    A[q, 2 * i + d] = (_value(t, cp) - _value(t, cm)) / (2 * h)
            A[q, -1] = -1.0
            b[q] = -v0          # v0 + g.dx - t <= 0
        cost = np.zeros(2 * n + 1)
        cost[-1] = 1
        bounds = [(-step, step)] * (2 * n) + [(None, None)]
        res = linprog(cost, A_ub=A, b_ub=b, bounds=bounds, method="highs")
        if res.status != 0:
            step *= 0.5
            continue
        cand = c + res.x[:-1].reshape(-1, 2)
        try:
            r_new = fast_radius(cand)
        except Exception:
            r_new = np.inf
        if r_new < r - tol:
            c, r = cand, r_new
            step = min(step * 1.5, step_max)
        else:
            step *= 0.5
        if verbose and it % 20 == 0:
            print(it, len(act), f"{1 / r:.10f}", f"{step:.1e}")
        if step < 1e-10:
            break
    return c
