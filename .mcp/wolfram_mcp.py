# /// script
# requires-python = ">=3.10"
# dependencies = ["mcp>=1.2,<2"]
# ///
"""
Wolfram / Mathematica MCP server (stdio).

Wraps the local `wolframscript` binary (Mathematica 14.3) and exposes it as
MCP tools. Self-contained PEP-723 single-file script -- run with
`uv run wolfram_mcp.py`; uv resolves `mcp` into an ephemeral env.

Tools:
  - wolfram_eval:  evaluate a Wolfram Language expression, return InputForm text
  - wolfram_plot:  evaluate a plotting expression, export a PNG, return its path
  - wolfram_info:  report kernel $Version / $InstallationDirectory

Config via environment:
  WOLFRAMSCRIPT   path to the wolframscript binary (default: auto-detect on PATH
                  then the known 14.3 install path)
  WOLFRAM_TIMEOUT default per-call timeout in seconds (default 120)
"""
from __future__ import annotations

import asyncio
import os
import shutil
import tempfile
from pathlib import Path

from mcp.server.fastmcp import FastMCP

_DEFAULT_WS = "/home/skim/Wolfram/Mathematica/14.3/Executables/wolframscript"


def _resolve_wolframscript() -> str:
    env = os.environ.get("WOLFRAMSCRIPT")
    if env and Path(env).exists():
        return env
    found = shutil.which("wolframscript")
    if found:
        return found
    if Path(_DEFAULT_WS).exists():
        return _DEFAULT_WS
    raise RuntimeError(
        "wolframscript not found. Set the WOLFRAMSCRIPT env var to its full path."
    )


def _timeout() -> float:
    try:
        return float(os.environ.get("WOLFRAM_TIMEOUT", "120"))
    except ValueError:
        return 120.0


mcp = FastMCP("wolfram")


async def _run_ws(code: str, timeout: float | None = None) -> str:
    """Run a WL snippet through `wolframscript -code` and return combined output."""
    ws = _resolve_wolframscript()
    to = timeout if timeout is not None else _timeout()
    proc = await asyncio.create_subprocess_exec(
        ws,
        "-code",
        code,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    try:
        out, err = await asyncio.wait_for(proc.communicate(), timeout=to)
    except asyncio.TimeoutError:
        proc.kill()
        await proc.communicate()
        raise RuntimeError(f"wolframscript timed out after {to:g}s")
    stdout = out.decode("utf-8", "replace")
    # wolframscript -code echoes the value of the final expression; our WriteString
    # calls return Null, which prints as a trailing "Null". Strip exactly that.
    if stdout.rstrip().endswith("Null"):
        stdout = stdout.rstrip()[: -len("Null")]
    stdout = stdout.strip()
    stderr = err.decode("utf-8", "replace").strip()
    if proc.returncode not in (0, None):
        detail = stderr or stdout or "(no output)"
        raise RuntimeError(f"wolframscript exited {proc.returncode}: {detail}")
    if stderr:
        return f"{stdout}\n[stderr] {stderr}".strip()
    return stdout


@mcp.tool()
async def wolfram_eval(expression: str, timeout_seconds: float | None = None) -> str:
    """Evaluate a Wolfram Language expression and return the result as text.

    The expression is wrapped so the result is returned in InputForm (plain,
    copy-pasteable text). Example: "Integrate[Sin[x]^2, x]".
    """
    code = f'WriteString["stdout", ToString[({expression}), InputForm]]'
    return await _run_ws(code, timeout_seconds)


@mcp.tool()
async def wolfram_plot(
    expression: str,
    width: int = 800,
    height: int = 600,
    timeout_seconds: float | None = None,
) -> str:
    """Evaluate a plotting/graphics expression, export a PNG, and return its path.

    `expression` must produce a graphic, e.g. "Plot[Sin[x], {x, 0, 2 Pi}]".
    The PNG is written to a temp file; the returned text is the absolute path.
    """
    out_dir = os.environ.get("TMPDIR") or tempfile.gettempdir()
    fd, png_path = tempfile.mkstemp(suffix=".png", prefix="wolfram_", dir=out_dir)
    os.close(fd)
    png_wl = png_path.replace("\\", "\\\\").replace('"', '\\"')
    code = (
        f'Export["{png_wl}", '
        f"Rasterize[({expression}), ImageSize -> {{{int(width)}, {int(height)}}}]"
        f'];WriteString["stdout", "{png_wl}"]'
    )
    result = await _run_ws(code, timeout_seconds)
    return result or png_path


@mcp.tool()
async def wolfram_info() -> str:
    """Report the Wolfram kernel version and installation directory."""
    code = (
        'WriteString["stdout", StringJoin["$Version: ", $Version, '
        '"\\n$InstallationDirectory: ", $InstallationDirectory]]'
    )
    return await _run_ws(code, 60)


if __name__ == "__main__":
    mcp.run()
