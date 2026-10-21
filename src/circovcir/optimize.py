"""Baseline numerical search: n centers minimising the covering radius of the unit disk.

Scale invariance: unit disks at c cover D(0,R)  <=>  disks of radius r = 1/R at c/R cover
D(0,1). So we minimise r(c) = rho(c, 1) over c in R^{2n} and report R = 1/r, centers c/r.

Method (deliberately simple -- a baseline for experiments/ to beat):
  1. smooth surrogate on a fixed sample X of the unit disk (dense on the boundary):
        F(c) = softmax_a over x in X of  softmin_b over i of |x - c_i|
     with analytic gradient, minimised by L-BFGS while annealing (a, b) upward;
  2. the result is scored by the EXACT candidate-point covering radius (geometry.py);
  3. multistart, keep the best.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations

import numpy as np
from scipy.optimize import minimize

from .geometry import covering_radius


def disk_samples(n_interior: int = 2500, n_boundary: int = 720) -> np.ndarray:
    """Sunflower (Vogel) interior sample + uniform boundary sample of the unit disk."""
    k = np.arange(n_interior) + 0.5
    rad = np.sqrt(k / n_interior)
    th = k * np.pi * (3 - np.sqrt(5))
    inner = np.column_stack([rad * np.cos(th), rad * np.sin(th)])
    t = np.linspace(0, 2 * np.pi, n_boundary, endpoint=False)
    return np.vstack([inner, np.column_stack([np.cos(t), np.sin(t)])])


def _lse(z: np.ndarray, axis: int) -> tuple[np.ndarray, np.ndarray]:
    """log-sum-exp and softmax weights along ``axis``, numerically stable."""
    m = z.max(axis=axis, keepdims=True)
    e = np.exp(z - m)
    s = e.sum(axis=axis, keepdims=True)
    return (m + np.log(s)).squeeze(axis), e / s


def smooth_objective(
    flat: np.ndarray, X: np.ndarray, a: float, b: float
) -> tuple[float, np.ndarray]:
    c = flat.reshape(-1, 2)
    diff = X[:, None, :] - c[None, :, :]                  # (K, n, 2)
    d = np.sqrt((diff**2).sum(-1) + 1e-18)                # (K, n)
    lse_b, w = _lse(-b * d, axis=1)                        # softmin over centers
    s = -lse_b / b                                         # (K,)
    lse_a, v = _lse(a * s, axis=0)                         # softmax over samples
    F = lse_a / a
    # dF/dc_i = sum_k v_k w_ki (c_i - x_k)/d_ki
    coef = v[:, None] * w / d                              # (K, n)
    grad = -(coef[:, :, None] * diff).sum(0)
    return float(F), grad.ravel()


def _active_candidates(c: np.ndarray, delta: float) -> list[tuple]:
    """Candidate points (R=1) whose nearest distance is within ``delta`` of the max, each
    tagged by the centers that generate it: ('T', i, j, k) | ('B', i, j, sign) | ('A', i)."""
    n = len(c)
    out: list[tuple] = []
    for i, j, k in combinations(range(n), 3):
        out.append(("T", i, j, k))
    for i, j in combinations(range(n), 2):
        out += [("B", i, j, 1.0), ("B", i, j, -1.0)]
    out += [("A", i) for i in range(n)]
    vals = [(_cand_value(t, c), t) for t in out]
    vals = [(v, t) for v, t in vals if v is not None]
    if not vals:
        return []
    top = max(v for v, _ in vals)
    return [t for v, t in vals if v >= top - delta]


def _cand_point(t: tuple, c: np.ndarray) -> np.ndarray | None:
    if t[0] == "T":
        a, b, cc = c[t[1]], c[t[2]], c[t[3]]
        d = 2 * (a[0] * (b[1] - cc[1]) + b[0] * (cc[1] - a[1]) + cc[0] * (a[1] - b[1]))
        if abs(d) < 1e-12:
            return None
        aa, bb, c2 = a @ a, b @ b, cc @ cc
        x = np.array([aa * (b[1] - cc[1]) + bb * (cc[1] - a[1]) + c2 * (a[1] - b[1]),
                      aa * (cc[0] - b[0]) + bb * (a[0] - cc[0]) + c2 * (b[0] - a[0])]) / d
        return x if x @ x <= 1 + 1e-12 else None
    if t[0] == "B":
        a, b = c[t[1]], c[t[2]]
        v = b - a
        l2 = v @ v
        if l2 < 1e-12:
            return None
        p = v * (b @ b - a @ a) / (2 * l2)
        h2 = 1 - p @ p
        if h2 < 0:
            return None
        return p + t[3] * np.sqrt(h2) * np.array([-v[1], v[0]]) / np.sqrt(l2)
    nrm = np.linalg.norm(c[t[1]])
    return None if nrm < 1e-12 else -c[t[1]] / nrm


def _cand_value(t: tuple, c: np.ndarray) -> float | None:
    """Nearest-center distance at the candidate, or None if it is not a valid candidate or
    its generators are not (among) its nearest centers."""
    x = _cand_point(t, c)
    if x is None:
        return None
    d = np.linalg.norm(c - x, axis=1)
    g = d[t[1]]
    return float(g) if g <= d.min() + 1e-9 else None


def polish(c: np.ndarray, rounds: int = 300, delta: float = 2e-2, step: float = 0.1,
           tol: float = 1e-13, extra=None, e0=None, ineq=None):
    """Active-set minimax refinement of rho(c, 1) on the EXACT candidate set.

    Each round fixes the near-maximal candidates (with their generating centers), and solves
        min t  s.t.  |x_q(c) - c_gen(q)| <= t   for every active q
    by SLSQP inside a box trust region; accept only if the exact covering radius drops.

    Optional ``extra(c, e) -> array`` adds side constraints ``extra <= t`` with auxiliary
    variables ``e`` (initial ``e0``); the objective becomes max(rho, max extra) and the
    function then returns ``(c, e)`` instead of ``c``.  Optional ``ineq(c, e) -> array``
    adds hard constraints ``ineq >= 0`` (checked with tolerance on acceptance).
    """
    c = c.copy()
    e = np.zeros(0) if e0 is None else np.asarray(e0, float).copy()
    ne = e.size

    def reff(cc, ee):
        r0 = covering_radius(cc, 1.0)
        return max(r0, float(np.max(extra(cc, ee)))) if extra is not None else r0

    r = reff(c, e)
    for _ in range(rounds):
        act = _active_candidates(c, max(delta, 0.0))
        if not act:
            break
        n2 = c.size

        def cons(z, act=act, n2=n2):
            cc = z[:n2].reshape(-1, 2)
            out = []
            for t in act:
                x = _cand_point(t, cc)
                out.append(z[-1] - (np.linalg.norm(x - cc[t[1]]) if x is not None else 0.0))
            if extra is not None:
                out.extend(z[-1] - np.asarray(extra(cc, z[n2:n2 + ne])))
            if ineq is not None:
                out.extend(np.asarray(ineq(cc, z[n2:n2 + ne])))
            return np.array(out)

        z0 = np.concatenate([c.ravel(), e, [r]])
        bounds = [(v - step, v + step) for v in np.concatenate([c.ravel(), e])] + [(0, None)]
        res = minimize(lambda z: z[-1], z0, jac=lambda z: np.eye(len(z))[-1], method="SLSQP",
                       bounds=bounds, constraints=[{"type": "ineq", "fun": cons}],
                       options={"maxiter": 200, "ftol": 1e-15})
        cand = res.x[:n2].reshape(-1, 2)
        ecand = res.x[n2:n2 + ne]
        r_new = reff(cand, ecand)
        feas = ineq is None or float(np.min(ineq(cand, ecand))) >= -1e-10
        if feas and r_new < r - tol:
            c, e, r = cand, ecand, r_new
        else:
            step *= 0.5
            delta *= 0.5
            if step < 1e-9:
                break
    return (c, e) if extra is not None else c


@dataclass
class SearchResult:
    n: int
    R: float
    centers: np.ndarray      # scaled so that UNIT disks cover D(0, R)
    r_unit: float            # covering radius of the unit disk at the unscaled centers
    seed: int


def search(n: int, starts: int = 20, seed: int = 0,
           schedule: tuple[float, ...] = (20, 60, 200, 600, 2000),
           X: np.ndarray | None = None, do_polish: bool = True) -> SearchResult:
    rng = np.random.default_rng(seed)
    X = disk_samples() if X is None else X
    best: SearchResult | None = None
    for s in range(starts):
        rad = np.sqrt(rng.uniform(0, 1, n)) * 0.9
        th = rng.uniform(0, 2 * np.pi, n)
        x = np.column_stack([rad * np.cos(th), rad * np.sin(th)]).ravel()
        for a in schedule:
            res = minimize(smooth_objective, x, args=(X, a, a), jac=True, method="L-BFGS-B",
                           options={"maxiter": 400})
            x = res.x
        c = x.reshape(-1, 2)
        if do_polish:
            c = polish(c)
        r = covering_radius(c, 1.0)
        if best is None or r < best.r_unit:
            best = SearchResult(n=n, R=1 / r, centers=c / r, r_unit=r, seed=seed * 100003 + s)
    assert best is not None
    return best
