import pytest

from circovcir import configio, wolfram

pytestmark = [
    pytest.mark.wolfram,
    pytest.mark.skipif(wolfram.find_wolframscript() is None, reason="wolframscript not found"),
]


def test_kernel_runs():
    assert wolfram.run_code('Print[CoveringRadius[{{0, 0}}, 1]]') == "1."


def test_verify_n7_exact():
    out = wolfram.verify_config(configio.config_path(7, "known"))
    assert out["exact_cover"] is True
    assert abs(float(out["R_gap"])) < 1e-30
