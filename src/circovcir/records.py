"""Known records from Erich Friedman's Packing Center (data/records.json)."""

from __future__ import annotations

import json
from functools import cache

from .configio import REPO_ROOT

RECORDS_FILE = REPO_ROOT / "data" / "records.json"


@cache
def load_records() -> tuple[dict, ...]:
    return tuple(json.loads(RECORDS_FILE.read_text())["records"])


def record_R(n: int) -> float | None:
    """Best known R for n (float of the decimal lower bound), or None if not tabulated."""
    for r in load_records():
        if r["n"] == n:
            return float(r["R"])
    return None
