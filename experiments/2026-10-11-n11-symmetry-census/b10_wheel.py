"""Hybrid leaf test L-b feasibility (L1): how far can centers move and stay W10?

For outer centers c_1..c_10 (cyclic order by angle) and inner c_0, the W10 wheel
type (proofs/11 §2.1, items 1-2) holds if for every i the circumcenter p_i of
(c_0, c_i, c_{i+1}) has an empty circumcircle (all other centers strictly
farther) and lies inside D(0,R).  The inner center is localised by coverage:
c_0 must lie within 1 of every point that is uncovered by all outer disks.

For a base configuration we sample perturbations of size <= rho (outer) and
c_0 in that localisation region, and report the largest rho at which every
sample is still W10.  Sampling only: L1 evidence for designing the leaf test.

usage: uv run python experiments/2026-10-11-n11-symmetry-census/b10_wheel.py
"""
from __future__ import annotations

import json
from pathlib import Path

import numpy as np

from b10_leaf import decode

HERE = Path(__file__).resolve().parent
RS = 2.6316907726198082


def circ(a, b, c):
    d = 2 * (a[0] * (b[1] - c[1]) + b[0] * (c[1] - a[1]) + c[0] * (a[1] - b[1]))
    aa, bb, cc = a @ a, b @ b, c @ c
    return np.array([aa * (b[1] - c[1]) + bb * (c[1] - a[1]) + cc * (a[1] - b[1]),
                     aa * (c[0] - b[0]) + bb * (a[0] - c[0]) + cc * (b[0] - a[0])]) / d


def wheel_margin(c0, outer, R):
    """min over i of empty-circle margin at p_i; negative => not W10."""
    order = np.argsort(np.arctan2(outer[:, 1], outer[:, 0]))
    o = outer[order]
    allc = np.vstack([c0, o])
    m = np.inf
    for i in range(len(o)):
        j = (i + 1) % len(o)
        p = circ(c0, o[i], o[j])
        r = np.linalg.norm(p - c0)
        d = np.linalg.norm(allc - p, axis=1)
        others = np.delete(d, [0, i + 1, j + 1])
        m = min(m, others.min() - r, R - np.linalg.norm(p))
    return m


def localisation(outer, R, rho, G):
    d = np.min(np.linalg.norm(G[:, None, :] - outer[None, :, :], axis=2), axis=1)
    return G[d > 1 + rho]


def max_rho(outer, R, G, rng, samples=40):
    best = 0.0
    for rho in [0.002, 0.005, 0.01, 0.02, 0.04, 0.08, 0.16]:
        res = localisation(outer, R, rho, G)
        if len(res) == 0:
            break
        # candidate inner centers: grid points within 1 of all residual points
        ok = np.all(np.linalg.norm(G[:, None, :] - res[None, :, :], axis=2) <= 1, axis=1)
        K = G[ok]
        if len(K) == 0:
            best = rho          # L-a already excludes: no inner centre possible
            continue
        fine = True
        for _ in range(samples):
            pert = outer + rng.uniform(-rho, rho, outer.shape) / np.sqrt(2)
            c0 = K[rng.integers(len(K))]
            if wheel_margin(c0, pert, R) <= 0:
                fine = False
                break
        if not fine:
            break
        best = rho
    return best


def main():
    rng = np.random.default_rng(3)
    g = np.linspace(-RS, RS, 161)
    G = np.array([(x, y) for x in g for y in g if x * x + y * y <= RS * RS])
    ring = decode(RS, np.r_[np.full(10, 0.1), np.zeros(10)])
    t = np.load(HERE / "out" / "triple-best.npy")
    Rt = 2.6093987583744807
    outer_t = t[np.linalg.norm(t, axis=1) > Rt - 1 - 1e-9] * RS / Rt
    for name, o in [("ring", ring), ("W10-2.6094", outer_t)]:
        c0 = np.zeros(2) if name == "ring" else t[np.linalg.norm(t, axis=1) < Rt - 1][0] * RS / Rt
        print(name, "nominal wheel margin", round(wheel_margin(c0, o, RS), 4),
              "max rho (all samples W10 or no inner possible)", max_rho(o, RS, G, rng))


if __name__ == "__main__":
    main()
