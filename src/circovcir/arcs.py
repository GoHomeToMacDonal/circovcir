"""Arc-coverage primitives and the central-disk + regular-ring construction.

Same formulas as the ``Arcs`` section of ``wl/CirCovCir.wl``; derivations and the
symmetry proof are in ``proofs/01-ring-symmetry.md``.

covered_arc(r, d)
    Angular measure omega of the arc of the circle |x| = r that lies in a unit disk whose
    center is at distance d from the origin:

        omega(r, d) = 2 arccos( (r^2 + d^2 - 1) / (2 r d) ),   argument clamped to [-1, 1]

    (clamp at -1 <=> r + d <= 1: whole circle; clamp at +1 <=> |r - d| >= 1: nothing).
    For fixed r > 1 it is maximal at d = sqrt(r^2 - 1), where omega = 2 arcsin(1/r).

ring_alpha(beta, R)
    A disk that covers an arc of angle beta in (0, pi] of the UNIT circle sits at
    d = 2 cos(beta/2) (since omega(1, d) = 2 arccos(d/2)); the arc it then covers on |x| = R is

        cos(alpha/2) = (R^2 - 1 + 4 cos^2(beta/2)) / (4 R cos(beta/2)).

    It is decreasing and strictly concave in beta on [beta0, beta1] with
    beta0 = 2 arccos(min(1, sqrt(R^2-1)/2)) and beta1 = 2 arccos((R-1)/2).
"""

from __future__ import annotations

import math

import numpy as np
from numpy.typing import NDArray


def _clamp(x: float) -> float:
    return max(-1.0, min(1.0, x))


def covered_arc(r: float, d: float) -> float:
    """Angle (radians, in [0, 2pi]) of the arc of |x| = r inside a unit disk at distance d."""
    if r < 0 or d < 0:
        raise ValueError("r and d must be non-negative")
    if r + d <= 1:
        return 2 * math.pi
    if abs(r - d) >= 1:
        return 0.0
    return 2 * math.acos(_clamp((r * r + d * d - 1) / (2 * r * d)))


def max_covered_arc(r: float) -> float:
    """sup_d covered_arc(r, d) = 2 arcsin(1/r) for r >= 1 (attained at d = sqrt(r^2 - 1))."""
    if r < 1:
        return 2 * math.pi
    return 2 * math.asin(1 / r)


def ring_alpha(beta: float, R: float) -> float:
    """Arc on |x| = R covered by the unit disk that covers exactly an arc beta of |x| = 1."""
    if not 0 < beta <= math.pi:
        raise ValueError("beta must be in (0, pi]")
    return covered_arc(R, 2 * math.cos(beta / 2))


def ring_alpha_slope(beta: float, R: float) -> float:
    """d alpha / d beta of :func:`ring_alpha` (interior of its support, 0 < alpha)."""
    u = beta / 2
    a, b = (R * R - 1) / (4 * R), 1 / R
    x = a / math.cos(u) + b * math.cos(u)
    dx = math.sin(u) * (a / math.cos(u) ** 2 - b)
    return -dx / math.sqrt(1 - x * x)


def ring_radius(k: int) -> float:
    """R* = 1 + 2 cos(2pi/k): disk at O plus k disks on the regular ring (k >= 6)."""
    return 1 + 2 * math.cos(2 * math.pi / k)


def ring_config(k: int) -> NDArray[np.float64]:
    """Centers: origin + k points at distance 2 cos(pi/k), angles 2 pi j / k. (n = k + 1)."""
    t = 2 * np.pi * np.arange(k) / k
    rho = 2 * math.cos(math.pi / k)
    return np.vstack([[0.0, 0.0], np.column_stack([rho * np.cos(t), rho * np.sin(t)])])
