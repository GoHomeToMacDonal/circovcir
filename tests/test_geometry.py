import math

import numpy as np
import pytest

from circovcir import configio, geometry, records


def ring(k, rad, phase=0.0):
    t = phase + 2 * np.pi * np.arange(k) / k
    return np.column_stack([rad * np.cos(t), rad * np.sin(t)])


KNOWN = {
    1: (np.zeros((1, 2)), 1.0),
    3: (ring(3, 1 / math.sqrt(3)), 2 / math.sqrt(3)),
    4: (ring(4, 1.0, math.pi / 4), math.sqrt(2)),
    7: (np.vstack([[0, 0], ring(6, math.sqrt(3))]), 2.0),
}


@pytest.mark.parametrize("n", sorted(KNOWN))
def test_max_covered_radius_known(n):
    c, R = KNOWN[n]
    assert geometry.max_covered_radius(c) == pytest.approx(R, abs=1e-10)


@pytest.mark.parametrize("n", sorted(KNOWN))
def test_tight_at_optimum(n):
    c, R = KNOWN[n]
    assert geometry.is_covered(c, R)
    assert not geometry.is_covered(c, R * (1 + 1e-6))
    assert geometry.tight_points(c, R)


def test_brute_force_agrees():
    """Candidate-set maximum == dense-sampling maximum (sampling can only under-estimate)."""
    rng = np.random.default_rng(1)
    for _ in range(20):
        c = rng.uniform(-1, 1, (6, 2))
        R = 1.3
        rho = geometry.covering_radius(c, R)
        t = np.linspace(0, 2 * np.pi, 4000)
        rr = np.sqrt(rng.uniform(0, 1, 20000)) * R
        tt = rng.uniform(0, 2 * np.pi, 20000)
        X = np.vstack([np.column_stack([R * np.cos(t), R * np.sin(t)]),
                       np.column_stack([rr * np.cos(tt), rr * np.sin(tt)])])
        sampled = geometry.nearest_distances(X, c).max()
        assert sampled <= rho + 1e-12
        assert sampled >= rho - 5e-3


@pytest.mark.parametrize("path", sorted(configio.CONFIG_DIR.glob("*/*.json")), ids=str)
def test_stored_configs_cover_their_R(path):
    cfg = configio.load(path)
    assert geometry.covering_radius(cfg.centers_float, cfg.R_float) <= 1 + 1e-9
    rec = records.record_R(cfg.n)
    if rec is not None and cfg.status != "candidate":
        assert cfg.R_float >= rec - 1e-9


@pytest.mark.slow
def test_search_recovers_n7():
    from circovcir import optimize
    res = optimize.search(7, starts=6, seed=0)
    assert res.R == pytest.approx(2.0, abs=1e-9)
