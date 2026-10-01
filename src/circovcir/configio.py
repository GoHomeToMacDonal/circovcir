"""Read/write ``data/configs/NN/*.json`` (schema: ``data/configs/README.md``)."""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import mpmath
import numpy as np

REPO_ROOT = Path(__file__).resolve().parents[2]
CONFIG_DIR = REPO_ROOT / "data" / "configs"


@dataclass
class Config:
    n: int
    R: str                          # decimal string, as many digits as known
    centers: list[list[str]]        # decimal strings
    status: str = "candidate"       # candidate | verified-numeric | verified-exact | proved-optimal
    source: str = ""
    provenance: str = ""
    extra: dict[str, Any] = field(default_factory=dict)  # R_wl, centers_wl, checks, ...

    @property
    def centers_float(self) -> np.ndarray:
        return np.array([[float(x), float(y)] for x, y in self.centers])

    @property
    def R_float(self) -> float:
        return float(self.R)

    def centers_mp(self, dps: int = 50) -> list[tuple[mpmath.mpf, mpmath.mpf]]:
        with mpmath.workdps(dps):
            return [(mpmath.mpf(x), mpmath.mpf(y)) for x, y in self.centers]

    def to_json(self) -> dict[str, Any]:
        d = {"n": self.n, "R": self.R, "centers": self.centers, "status": self.status,
             "source": self.source, "provenance": self.provenance}
        d.update(self.extra)
        return d


def load(path: str | Path) -> Config:
    raw = json.loads(Path(path).read_text())
    keys = {"n", "R", "centers", "status", "source", "provenance"}
    cfg = Config(n=int(raw["n"]), R=str(raw["R"]),
                 centers=[[str(x), str(y)] for x, y in raw["centers"]],
                 status=raw.get("status", "candidate"), source=raw.get("source", ""),
                 provenance=raw.get("provenance", ""),
                 extra={k: v for k, v in raw.items() if k not in keys})
    if len(cfg.centers) != cfg.n:
        raise ValueError(f"{path}: n={cfg.n} but {len(cfg.centers)} centers")
    return cfg


def save(cfg: Config, path: str | Path) -> Path:
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(cfg.to_json(), indent=2, ensure_ascii=False) + "\n")
    return p


def _dec(x: float) -> str:
    """Shortest round-trip decimal, never in exponent notation (WL-friendly)."""
    return np.format_float_positional(float(x), unique=True, trim="-")


def from_floats(centers: np.ndarray, R: float, **kw: Any) -> Config:
    return Config(n=len(centers), R=_dec(R), centers=[[_dec(x), _dec(y)] for x, y in centers],
                  **kw)


def config_path(n: int, name: str) -> Path:
    return CONFIG_DIR / f"{n:02d}" / f"{name}.json"
