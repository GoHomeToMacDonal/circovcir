"""Command line: ``uv run circovcir {records,verify,search}``."""

from __future__ import annotations

import argparse
import json
import sys

from . import configio, geometry, records


def _cmd_records(_: argparse.Namespace) -> int:
    for r in records.load_records():
        print(f"n={r['n']:>2}  R={r['R']:<22} {r['status']:<15} {r['credit']}")
    return 0


def _cmd_verify(a: argparse.Namespace) -> int:
    cfg = configio.load(a.config)
    c = cfg.centers_float
    R_py = geometry.max_covered_radius(c)
    rho = geometry.covering_radius(c, cfg.R_float)
    out = {"file": a.config, "n": cfg.n, "R_recorded": cfg.R, "python_R_max": R_py,
           "python_gap": R_py - cfg.R_float, "python_rho_at_R": rho,
           "python_tight_points": len(geometry.tight_points(c, cfg.R_float, 1e-7))}
    ok = rho <= 1 + 1e-9
    if a.wolfram:
        from . import wolfram
        w = wolfram.verify_config(a.config, a.wp)
        out["wolfram"] = w
        # Consistent iff the high-precision scale-certified radius agrees with the recorded R
        # to 1e-12 relative (float-optimised configs carry ~1e-16 holes; see docs/methods.md).
        ok = ok and float(w["R_certified"]) >= cfg.R_float * (1 - 1e-12)
        if w.get("exact_cover") is not None:
            ok = ok and bool(w["exact_cover"])
    out["ok"] = ok
    print(json.dumps(out, indent=2))
    return 0 if ok else 1


def _cmd_search(a: argparse.Namespace) -> int:
    from . import optimize
    res = optimize.search(a.n, starts=a.starts, seed=a.seed)
    rec = records.record_R(a.n)
    print(f"n={a.n}  best R={res.R:.12f}  record={rec}  "
          f"gap={res.R - rec if rec else float('nan'):+.3e}")
    if a.out:
        cfg = configio.from_floats(res.centers, res.R, status="candidate",
                                   provenance=f"circovcir search -n {a.n} --starts {a.starts} "
                                              f"--seed {a.seed}")
        print("saved", configio.save(cfg, a.out))
    return 0


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(prog="circovcir")
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("records", help="print the known-record table").set_defaults(fn=_cmd_records)
    v = sub.add_parser("verify", help="verify a config (python float, optionally Wolfram)")
    v.add_argument("config")
    v.add_argument("--wolfram", action="store_true", help="also run the independent WL check")
    v.add_argument("--wp", type=int, default=40, help="Wolfram working precision")
    v.set_defaults(fn=_cmd_verify)
    s = sub.add_parser("search", help="baseline multistart search")
    s.add_argument("-n", type=int, required=True)
    s.add_argument("--starts", type=int, default=20)
    s.add_argument("--seed", type=int, default=0)
    s.add_argument("--out", help="write the best config JSON here")
    s.set_defaults(fn=_cmd_search)
    a = p.parse_args(argv)
    return a.fn(a)


if __name__ == "__main__":
    sys.exit(main())
