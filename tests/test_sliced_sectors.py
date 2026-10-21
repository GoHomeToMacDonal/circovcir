"""Exact support certificates and complete per-center sector-union replay."""
import copy
import json
from fractions import Fraction as Q
from pathlib import Path

import numpy as np
import pytest
from scipy.optimize import linprog

from circovcir.correlated_sectors import (
    angle_coefficients,
    check_correlated_domain,
    propose_correlated_domain,
    propose_support,
    support_check,
)
from circovcir.ordered_arcs import radial_bounds, simplex_linear_range
from circovcir.rank_duals import rank_planes
from circovcir.residual_propagation import propose_propagation
from circovcir.sliced_sectors import check_sliced_domain, replay_sliced_cover

ROOT = Path(__file__).parents[1]


def payload():
    return json.loads((ROOT / "experiments/2026-10-11-n11-b9-correlation/results/"
                      "sliced-cover.json").read_text())


@pytest.mark.parametrize("n", [1, 3, 4, 7])
def test_known_covers_safe_with_sector_unions(n):
    data = json.loads((ROOT / f"data/configs/{n:02d}/known.json").read_text())
    sectors = []
    for center in data["centers"][2:]:
        c = np.array(center, float)
        r, a = Q(float(np.linalg.norm(c))), Q(float(np.arctan2(c[1], c[0])))
        eps = Q(1, 10**10)
        # A union contains the known center even if some pieces do not.
        for lo, hi in [(a-eps, a), (a, a+eps), (a+eps, a+2*eps)]:
            sectors.append(((max(0, r-eps), r+eps), (lo, hi)))
    assert propose_propagation(sectors, Q(data["R"])-Q(1, 10**10),
                               rounds=2, seed_limit=12, extra_limit=6) is None


def test_support_and_angular_correlation_against_lp():
    rr, rank = (Q("2.72"), Q("2.725")), (4, 6)
    domain = propose_correlated_domain(rr, rank)
    assert check_correlated_domain(rr, domain) is not None
    ps = rank_planes(domain["floors"], rank)
    b = [s["range"] for s in domain["supports"][:18]]
    improvements = []
    for j in range(1, 9):
        co = angle_coefficients(j)
        cert = domain["supports"][18+j-1]
        assert support_check(ps, co, cert)
        lo, hi = cert["range"]
        boxlo, boxhi = simplex_linear_range(b, co)
        improvements.append(float(boxhi-boxlo-(hi-lo)))
        for side, sign in enumerate((1, -1)):
            solve = linprog(sign*np.array(co, float),
                            A_ub=-np.array([p[0] for p in ps], float),
                            b_ub=-np.array([p[1] for p in ps], float),
                            bounds=[(None, None)]*18, method="highs")
            assert solve.success
            assert abs(float(cert["range"][side])-sign*solve.fun) < 1e-12
    # Root angular supports need not improve the box+sum bound; in this rank
    # they coincide. The useful gain is conditional on radial slicing.
    assert max(abs(v) for v in improvements) < 1e-12
    entry = next(e for e in payload()["panels"][0]["cases"]
                 if len(e["domain"]["pieces"][1]) > 1)
    dom = entry["domain"]
    conditional_gains = []
    for j in range(1, 9):
        rlo, rhi = map(Q, dom["root"]["supports"][17+j]["range"])
        for piece in dom["pieces"][j]:
            mlo, mhi = map(Q, piece["support"]["range"])
            conditional_gains.append(rhi-rlo-(mhi-mlo))
    assert max(conditional_gains) > Q(1, 2)
    bad = copy.deepcopy(cert)
    bad["duals"][0][0][1] = "-1"
    assert not support_check(ps, co, bad)
    bad = copy.deepcopy(cert)
    bad["duals"][0][0][1] = "100"
    assert not support_check(ps, co, bad)
    # Explicit exact support of the interval [0,1].
    ps = [([Q(1)], Q(0)), ([Q(-1)], Q(-1))]
    cert = propose_support(ps, [Q(2)])
    assert cert["range"] == [0, 2] and support_check(ps, [2], cert)
    with pytest.raises(ValueError):
        angle_coefficients(0)
    with pytest.raises(ValueError):
        radial_bounds(rr, 0, (Q(-1), Q(1)))


def test_full_sliced_cover_replay():
    assert replay_sliced_cover(payload())


@pytest.mark.parametrize("change", ["missing_center", "missing_slice", "slice_gap",
                                    "slice_overlap", "angular_dual", "empty_slice",
                                    "root_dual", "root_floor", "small_sector", "fake_anchor"])
def test_corrupt_domain_fails_closed(change):
    panel = payload()["panels"][0]
    domain = copy.deepcopy(next(e["domain"] for e in panel["cases"]
                                if len(e["domain"]["pieces"][1]) > 1))
    if change == "missing_center":
        domain["pieces"].pop()
    elif change == "missing_slice":
        domain["pieces"][1].pop()
    elif change == "slice_gap":
        part = domain["pieces"][1][1]
        part["parameter"][0] = str(Q(part["parameter"][0])+Q(1, 10**6))
    elif change == "slice_overlap":
        part = domain["pieces"][1][1]
        part["parameter"][0] = "0"
    elif change == "angular_dual":
        domain["pieces"][1][0]["support"]["duals"][0][0][1] = "-1"
    elif change == "empty_slice":
        part = domain["pieces"][1][0]
        part["parameter"][1] = part["parameter"][0]
    elif change == "root_dual":
        domain["root"]["supports"][18]["duals"][0][0][1] = "-1"
    elif change == "root_floor":
        domain["root"]["floors"][0] = "1"
    elif change == "small_sector":
        domain["pieces"][1][0]["sector"] = [["0", "0"], ["0", "0"]]
    else:
        domain["pieces"][0][0]["support"] = domain["pieces"][1][0]["support"]
    assert check_sliced_domain(panel["radii"], domain) is None


@pytest.mark.parametrize("change", ["rank_gap", "duplicate_rank", "radius_gap", "leaf"])
def test_corrupt_manifest_fails_closed(change):
    data = payload()
    if change == "rank_gap":
        data["panels"][0]["cases"].pop()
    elif change == "duplicate_rank":
        data["panels"][0]["cases"][0] = data["panels"][0]["cases"][1]
    elif change == "radius_gap":
        data["panels"][0]["radii"][0] = "2.731"
    else:
        data["panels"][0]["cases"][0]["leaf"]["steps"].pop()
    assert not replay_sliced_cover(data)
