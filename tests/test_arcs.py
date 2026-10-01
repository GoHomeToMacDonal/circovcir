import math

import numpy as np
import pytest

from circovcir import arcs, geometry, records


def sampled_arc(r, d, m=200_000):
    t = np.linspace(0, 2 * np.pi, m, endpoint=False)
    inside = (r * np.cos(t) - d) ** 2 + (r * np.sin(t)) ** 2 <= 1
    return 2 * np.pi * inside.mean()


@pytest.mark.parametrize("r,d", [(1.0, 0.3), (1.0, 1.7), (2.0, 1.5), (2.4, 2.2), (0.4, 0.5),
                                 (0.2, 0.3), (3.0, 1.5), (2.0, 3.2)])
def test_covered_arc_matches_sampling(r, d):
    assert arcs.covered_arc(r, d) == pytest.approx(sampled_arc(r, d), abs=1e-4)


def test_unit_circle_special_case():
    for d in np.linspace(0.05, 1.95, 20):
        assert arcs.covered_arc(1.0, d) == pytest.approx(2 * math.acos(d / 2), abs=1e-14)


@pytest.mark.parametrize("r", [1.2, 2.0, 2.5, 4.0])
def test_max_covered_arc(r):
    ds = np.linspace(r - 1 + 1e-9, r + 1 - 1e-9, 20001)
    best = max(arcs.covered_arc(r, d) for d in ds)
    assert best == pytest.approx(arcs.max_covered_arc(r), abs=1e-7)
    assert arcs.covered_arc(r, math.sqrt(r * r - 1)) == pytest.approx(arcs.max_covered_arc(r))


@pytest.mark.parametrize("k", [6, 7, 8, 9])
def test_ring_fixed_point(k):
    """At R* the regular ring has alpha = beta = 2pi/k, slope (1-2C)/(1+2C), C = cos(2pi/k)."""
    R, m = arcs.ring_radius(k), 2 * math.pi / k
    assert arcs.ring_alpha(m, R) == pytest.approx(m, abs=1e-12)
    C = math.cos(m)
    assert arcs.ring_alpha_slope(m, R) == pytest.approx((1 - 2 * C) / (1 + 2 * C), abs=1e-10)


@pytest.mark.parametrize("R", [2.0, 2.25, 2.414, 2.6, 2.9])
def test_ring_alpha_decreasing_concave(R):
    b0 = 2 * math.acos(min(1.0, math.sqrt(R * R - 1) / 2))
    b1 = 2 * math.acos((R - 1) / 2)
    b = np.linspace(b0 + 1e-3, b1 - 1e-3, 400)
    a = np.array([arcs.ring_alpha(x, R) for x in b])
    assert np.all(np.diff(a) < 0)
    assert np.all(np.diff(a, 2) < 0)  # strictly concave (second differences)


@pytest.mark.parametrize("k", [6, 7, 8, 9])
def test_ring_config_attains_record(k):
    c, R = arcs.ring_config(k), arcs.ring_radius(k)
    # exact-tight configs leave ~1e-16 float holes, so test cover / no-cover, not bisection
    assert geometry.covering_radius(c, R) <= 1 + 1e-12
    assert not geometry.is_covered(c, R * (1 + 1e-7))
    assert R >= records.record_R(k + 1) - 1e-9


def test_ring_radius_closed_forms():
    assert arcs.ring_radius(6) == pytest.approx(2.0)
    assert arcs.ring_radius(8) == pytest.approx(1 + math.sqrt(2))
    assert arcs.ring_radius(7) == pytest.approx(1 / (2 * math.sin(math.pi / 14)))
