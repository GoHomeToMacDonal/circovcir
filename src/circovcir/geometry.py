"""Covering radius of n points w.r.t. the disk D(0, R), and the largest coverable R.

Same algorithm as ``wl/CirCovCir.wl`` (see ``docs/methods.md``), in float64:

    rho(c, R) = max_{x in D(0,R)} min_i |x - c_i|

is attained on the finite candidate set
    (T) circumcenters of center triples that lie in D(0,R),
    (B) intersections of pair bisectors with the circle |x| = R,
    (A) antipodal boundary points -R c_i/|c_i|   (and (R, 0) for robustness).
Unit disks at c cover D(0,R)  <=>  rho(c, R) <= 1.

This module is the FAST float screen. Claims of a record need the Wolfram
high-precision / exact check as well (AGENTS.md, "Verification ladder").
"""

from __future__ import annotations

from itertools import combinations

import numpy as np
from numpy.typing import ArrayLike, NDArray

_EPS = 1e-12


def _as_centers(centers: ArrayLike) -> NDArray[np.float64]:
    c = np.asarray(centers, dtype=np.float64)
    if c.ndim != 2 or c.shape[1] != 2:
        raise ValueError(f"centers must have shape (n, 2), got {c.shape}")
    return c


def candidate_points(centers: ArrayLike, R: float) -> NDArray[np.float64]:
    """Return the (m, 2) candidate set on which the covering radius is attained."""
    c = _as_centers(centers)
    n = len(c)
    parts: list[NDArray[np.float64]] = []

    # (T) circumcenters of triples
    if n >= 3:
        idx = np.array(list(combinations(range(n), 3)))
        a, b, cc = c[idx[:, 0]], c[idx[:, 1]], c[idx[:, 2]]
        d = 2 * (a[:, 0] * (b[:, 1] - cc[:, 1]) + b[:, 0] * (cc[:, 1] - a[:, 1])
                 + cc[:, 0] * (a[:, 1] - b[:, 1]))
        ok = np.abs(d) > _EPS
        a, b, cc, d = a[ok], b[ok], cc[ok], d[ok]
        aa, bb, c2 = (a * a).sum(1), (b * b).sum(1), (cc * cc).sum(1)
        ux = (aa * (b[:, 1] - cc[:, 1]) + bb * (cc[:, 1] - a[:, 1]) + c2 * (a[:, 1] - b[:, 1])) / d
        uy = (aa * (cc[:, 0] - b[:, 0]) + bb * (a[:, 0] - cc[:, 0]) + c2 * (b[:, 0] - a[:, 0])) / d
        tri = np.column_stack([ux, uy])
        inside = (tri * tri).sum(1) <= R * R * (1 + 1e-12)
        parts.append(tri[inside])

    # (B) bisector ∩ circle
    if n >= 2:
        idx = np.array(list(combinations(range(n), 2)))
        a, b = c[idx[:, 0]], c[idx[:, 1]]
        v = b - a
        l2 = (v * v).sum(1)
        ok = l2 > _EPS
        a, b, v, l2 = a[ok], b[ok], v[ok], l2[ok]
        p = v * (((b * b).sum(1) - (a * a).sum(1)) / (2 * l2))[:, None]
        h2 = R * R - (p * p).sum(1)
        ok = h2 >= -1e-12
        p, v, l2, h = p[ok], v[ok], l2[ok], np.sqrt(np.clip(h2[ok], 0, None))
        u = np.column_stack([-v[:, 1], v[:, 0]]) / np.sqrt(l2)[:, None]
        parts += [p + h[:, None] * u, p - h[:, None] * u]

    # (A) antipodes
    norms = np.linalg.norm(c, axis=1)
    nz = norms > _EPS
    parts.append(-R * c[nz] / norms[nz, None])
    parts.append(np.array([[R, 0.0]]))
    return np.concatenate(parts, axis=0)


def nearest_distances(points: ArrayLike, centers: ArrayLike) -> NDArray[np.float64]:
    """min_i |x_k - c_i| for every point x_k."""
    x = np.asarray(points, dtype=np.float64)
    c = _as_centers(centers)
    d2 = ((x[:, None, :] - c[None, :, :]) ** 2).sum(-1)
    return np.sqrt(d2.min(axis=1))


def covering_radius(centers: ArrayLike, R: float) -> float:
    """max over D(0,R) of the distance to the nearest center."""
    return float(nearest_distances(candidate_points(centers, R), centers).max())


def is_covered(centers: ArrayLike, R: float, tol: float = 1e-12) -> bool:
    """Float screen: do unit disks at ``centers`` cover D(0,R)?"""
    return covering_radius(centers, R) <= 1 + tol


def max_covered_radius(centers: ArrayLike, tol: float = 1e-13) -> float:
    """Largest R such that unit disks at ``centers`` cover D(0,R) (bisection; rho ↑ in R)."""
    c = _as_centers(centers)
    if np.linalg.norm(c, axis=1).min() > 1:
        return 0.0
    lo, hi = 0.0, float(np.linalg.norm(c, axis=1).max()) + 1.0
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if covering_radius(c, mid) <= 1.0:
            lo = mid
        else:
            hi = mid
    return lo


def tight_points(
    centers: ArrayLike, R: float, tol: float = 1e-8
) -> list[tuple[NDArray, list[int]]]:
    """Candidates at distance ≈1 from their nearest center(s): the active constraints."""
    c = _as_centers(centers)
    pts = candidate_points(c, R)
    d = np.sqrt(((pts[:, None, :] - c[None, :, :]) ** 2).sum(-1))
    m = d.min(1)
    out = []
    for k in np.flatnonzero(np.abs(m - 1) < tol):
        out.append((pts[k], [int(i) for i in np.flatnonzero(np.abs(d[k] - m[k]) < tol)]))
    return out
