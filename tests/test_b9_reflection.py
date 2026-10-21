import numpy as np
import pytest

from circovcir.b9_rank import (
    rank_cases,
    rank_orbit_representatives,
    reflect_parameters,
    reflect_rank,
)
from circovcir.ordered_arcs import decode_float


def test_orbits_halve_rank_cases():
    reps = rank_orbit_representatives()
    assert len(reps) == 28
    assert set(reps) | {reflect_rank(r) for r in reps} == set(rank_cases())
    assert all(reflect_rank(reflect_rank(r)) == r for r in rank_cases())
    assert all(reflect_rank(r) != r for r in rank_cases())


@pytest.mark.parametrize("seed", range(5))
def test_reflected_parameters_decode_to_mirror_image(seed):
    rng = np.random.default_rng(seed)
    x = rng.dirichlet(np.ones(18))
    c = decode_float(2.65, x)
    cr = decode_float(2.65, reflect_parameters(x))
    mirror = c * np.array([1.0, -1.0])
    assert np.allclose(cr[0], c[0])
    d = np.linalg.norm(cr[:, None, :] - mirror[None, :, :], axis=2)
    assert np.allclose(d.min(axis=1), 0.0, atol=1e-12)


@pytest.mark.parametrize("seed", range(5))
def test_rank_case_maps_under_reflection(seed):
    rng = np.random.default_rng(100 + seed)
    u = rng.dirichlet(np.ones(9))
    u = np.r_[u.max(), np.delete(u, np.argmax(u))]
    x = np.r_[u, np.zeros(9)]
    rest = np.argsort(-x[1:9]) + 1
    rank = (int(rest[0]), int(rest[1]))
    xr = np.array(reflect_parameters(x))
    rest_r = np.argsort(-xr[1:9]) + 1
    assert (int(rest_r[0]), int(rest_r[1])) == reflect_rank(rank)
