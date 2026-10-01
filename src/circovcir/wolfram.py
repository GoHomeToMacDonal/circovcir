"""Thin bridge to the local Wolfram Engine (Mathematica 14.3) via ``wolframscript``."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

from .configio import REPO_ROOT

WL_DIR = REPO_ROOT / "wl"
_FALLBACK = Path.home() / "Wolfram/Mathematica/14.3/Executables/wolframscript"


def find_wolframscript() -> str | None:
    env = os.environ.get("WOLFRAMSCRIPT")
    if env and Path(env).exists():
        return env
    return shutil.which("wolframscript") or (str(_FALLBACK) if _FALLBACK.exists() else None)


def _ws() -> str:
    ws = find_wolframscript()
    if ws is None:
        raise RuntimeError("wolframscript not found; set WOLFRAMSCRIPT=/path/to/wolframscript")
    return ws


def run_code(code: str, timeout: float = 300) -> str:
    """Evaluate WL code with the CirCovCir` package preloaded; return stdout."""
    # A single `-code` string is parsed before `Get` runs, so package symbols would land in
    # Global`. A script file is read statement by statement, which avoids that.
    pkg = (WL_DIR / "CirCovCir.wl").as_posix()
    with tempfile.NamedTemporaryFile("w", suffix=".wls", delete=False) as f:
        f.write(f'Get["{pkg}"];\n{code};\n')
        script = f.name
    try:
        r = subprocess.run([_ws(), "-file", script], capture_output=True, text=True,
                           timeout=timeout, check=False)
    finally:
        os.unlink(script)
    if r.returncode != 0:
        raise RuntimeError(f"wolframscript exited {r.returncode}: {r.stderr or r.stdout}")
    return r.stdout.strip()


def run_file(script: str | Path, *args: str, timeout: float = 600) -> str:
    r = subprocess.run([_ws(), "-file", str(script), *args], capture_output=True, text=True,
                       timeout=timeout, check=False, cwd=REPO_ROOT)
    if r.returncode != 0:
        raise RuntimeError(f"{script} exited {r.returncode}: {r.stderr or r.stdout}")
    return r.stdout.strip()


def verify_config(path: str | Path, working_precision: int = 40) -> dict:
    """Independent Wolfram check of a config file (see wl/scripts/verify_config.wls)."""
    out = run_file(WL_DIR / "scripts" / "verify_config.wls", str(path), str(working_precision))
    # the JSON object is the last stdout line; earlier lines would be kernel messages
    return json.loads(out.splitlines()[-1])
