"""n=11, class "1 inner + 10 outer": brute-force witness-point search at fixed R.

Class C10(R): 11 unit disks c_0..c_10 with |c_i| >= R-1 for i=1..10 (the 10 outer disks
all reach the boundary circle |x|=R); c_0 is free (it must then cover the origin, since
R-1 > 1).  Witness relaxation: for a finite W subset of D(0,R),

    t(c) = max_{w in W} min_i |w - c_i|,      W-feasible  <=>  t(c) <= 1.

If C10(R) contains a covering of D(0,R) then min_{c in C10} t(c) <= 1 for EVERY W. So a
search that, over many starts, never reaches t <= 1 on a small W is (numerical, L1)
evidence that C10(R) has no covering. It is NOT a proof (local search is not exhaustive).

Per start: (1) smooth log-sum-exp surrogate + outer-ring penalty, L-BFGS with annealing;
(2) SLP minimax polish (LP via HiGHS) on W with linearised ring constraints and a shrinking
trust region; (3) report t on W and the exact covering radius of the full disk
(candidate-point theorem, circovcir.geometry) as a cross-check.

Usage:
  uv run python experiments/2026-10-11-n11-b10-witness/run.py --nb 48 --ni 120 --starts 64
"""

from __future__ import annotations

import argparse
import json
import os
import time
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

os.environ.setdefault("OMP_NUM_THREADS", "1")
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")

import numpy as np  # noqa: E402
from scipy.optimize import linprog, minimize  # noqa: E402

from circovcir.geometry import covering_radius  # noqa: E402
from circovcir.optimize import _active_candidates, _cand_point, smooth_objective  # noqa: E402

N = 11
HERE = Path(__file__).resolve().parent


def witnesses(R: float, nb: int, ni: int) -> np.ndarray:
    """nb equally spaced boundary points (random phase irrelevant: rotation-invariant
    class) + ni sunflower interior points of D(0,R)."""
    t = 2 * np.pi * np.arange(nb) / nb
    bd = R * np.column_stack([np.cos(t), np.sin(t)])
    if ni == 0:
        return bd
    k = np.arange(ni) + 0.5
    rad = R * np.sqrt(k / ni)
    th = k * np.pi * (3 - np.sqrt(5))
    return np.vstack([bd, np.column_stack([rad * np.cos(th), rad * np.sin(th)])])


def t_value(c: np.ndarray, W: np.ndarray) -> float:
    d = np.sqrt(((W[:, None, :] - c[None, :, :]) ** 2).sum(-1))
    return float(d.min(1).max())


def ring_violation(c: np.ndarray, R: float) -> float:
    return float(np.maximum(0.0, (R - 1) - np.linalg.norm(c[1:], axis=1)).max())


def seed(rng: np.random.Generator, R: float) -> np.ndarray:
    """Even seeds: random annulus layout. Odd seeds: regular 10-ring (radius 2cos(pi/10))
    + inner at origin, perturbed with noise sigma ~ U(0.02, 0.4)."""
    c = np.empty((N, 2))
    if rng.integers(2):
        sig = rng.uniform(0.02, 0.4)
        ang = 2 * np.pi * np.arange(10) / 10
        c[0] = 0.0
        c[1:] = 2 * np.cos(np.pi / 10) * np.column_stack([np.cos(ang), np.sin(ang)])
        return c + rng.normal(0, sig, c.shape)
    r0 = 0.5 * np.sqrt(rng.random())
    a0 = 2 * np.pi * rng.random()
    c[0] = r0 * np.array([np.cos(a0), np.sin(a0)])
    ang = 2 * np.pi * (np.arange(10) + rng.uniform(-0.35, 0.35, 10)) / 10
    rad = rng.uniform(R - 1, R - 0.3, 10)
    c[1:] = np.column_stack([rad * np.cos(ang), rad * np.sin(ang)])
    return c


def smooth_stage(c: np.ndarray, W: np.ndarray, R: float) -> np.ndarray:
    x = c.ravel().copy()
    for a, b, mu in [(20, 20, 50), (60, 60, 200), (200, 200, 1000), (600, 600, 5000)]:
        def f(z, a=a, b=b, mu=mu):
            F, g = smooth_objective(z, W, a, b)
            cc = z.reshape(-1, 2)
            nr = np.linalg.norm(cc[1:], axis=1) + 1e-18
            v = np.maximum(0.0, (R - 1) - nr)
            F += mu * float((v**2).sum())
            gg = g.reshape(-1, 2)
            gg[1:] += (-2 * mu * v / nr)[:, None] * cc[1:]
            return F, gg.ravel()
        x = minimize(f, x, jac=True, method="L-BFGS-B", options={"maxiter": 400}).x
    return x.reshape(-1, 2)


def slp_stage(c: np.ndarray, W: np.ndarray, R: float, iters: int = 200,
              step: float = 0.05, band: float = 0.15) -> np.ndarray:
    """min t s.t. |w-c_j(w)| + grad.dc_j <= t for witnesses w within `band` of the current
    max (j(w) = nearest center, reassigned every iteration); |c_i|+u_i.dc_i >= R-1;
    |dc|_inf <= step. Accept only if the true t (with ring feasibility) improves."""
    c = c.copy()
    # project outer centers onto the feasible annulus first
    nr = np.linalg.norm(c[1:], axis=1)
    c[1:] *= (np.maximum(nr, R - 1) / np.maximum(nr, 1e-12))[:, None]
    best = t_value(c, W)
    nv = 2 * N + 1
    for _ in range(iters):
        d = np.sqrt(((W[:, None, :] - c[None, :, :]) ** 2).sum(-1))
        m = d.min(1)
        rows, rhs = [], []
        jmin = d.argmin(1)
        for k in np.flatnonzero(m >= best - band):
            j = jmin[k]                       # assignment to the nearest center
            g = (c[j] - W[k]) / max(d[k, j], 1e-12)
            row = np.zeros(nv)
            row[2 * j: 2 * j + 2] = g
            row[-1] = -1.0
            rows.append(row)
            rhs.append(-d[k, j])
        for i in range(1, N):
            ni_ = np.linalg.norm(c[i])
            u = c[i] / ni_
            row = np.zeros(nv)
            row[2 * i: 2 * i + 2] = -u
            rows.append(row)
            rhs.append(ni_ - (R - 1))
        cost = np.zeros(nv)
        cost[-1] = 1.0
        bounds = [(-step, step)] * (2 * N) + [(None, None)]
        res = linprog(cost, A_ub=np.array(rows), b_ub=np.array(rhs), bounds=bounds,
                      method="highs")
        if res.status != 0:
            step *= 0.5
            if step < 1e-9:
                break
            continue
        cn = c + res.x[:-1].reshape(-1, 2)
        nr = np.linalg.norm(cn[1:], axis=1)
        cn[1:] *= (np.maximum(nr, R - 1) / nr)[:, None]   # exact re-projection
        tn = t_value(cn, W)
        if tn < best - 1e-13:
            c, best = cn, tn
            step = min(step * 1.5, 0.1)
        else:
            step *= 0.5
            if step < 1e-9:
                break
    return c


def polish_ring(c: np.ndarray, R: float, rounds: int = 300, delta: float = 2e-2,
                step: float = 0.05, tol: float = 1e-13) -> np.ndarray:
    """Exact active-set minimax of rho(c, R) over C10(R) (the circovcir.optimize.polish
    scheme, with the ring constraints |c_i| >= R-1, i>=1, added to the SLSQP step).
    Works in scaled coordinates x = c/R (unit target disk), so rho(c,R) = R*rho(x,1)."""
    x = c / R
    q = (R - 1) / R
    nr = np.linalg.norm(x[1:], axis=1)
    x[1:] *= (np.maximum(nr, q) / nr)[:, None]
    r = covering_radius(x, 1.0)
    n2 = x.size
    for _ in range(rounds):
        act = _active_candidates(x, delta)
        if not act:
            break

        def cons(z, act=act):
            cc = z[:n2].reshape(-1, 2)
            out = []
            for t in act:
                p = _cand_point(t, cc)
                out.append(z[-1] - (np.linalg.norm(p - cc[t[1]]) if p is not None else 0.0))
            out += list((cc[1:] ** 2).sum(1) - q * q)
            return np.array(out)

        z0 = np.append(x.ravel(), r)
        bounds = [(v - step, v + step) for v in x.ravel()] + [(0, None)]
        res = minimize(lambda z: z[-1], z0, jac=lambda z: np.eye(len(z))[-1], method="SLSQP",
                       bounds=bounds, constraints=[{"type": "ineq", "fun": cons}],
                       options={"maxiter": 200, "ftol": 1e-15})
        xn = res.x[:n2].reshape(-1, 2).copy()
        nr = np.linalg.norm(xn[1:], axis=1)
        xn[1:] *= (np.maximum(nr, q) / nr)[:, None]          # exact feasibility
        r_new = covering_radius(xn, 1.0)
        if r_new < r - tol:
            x, r = xn, r_new
        else:
            step *= 0.5
            delta *= 0.5
            if step < 1e-9:
                break
    return x * R


def one_start(args: tuple) -> dict:
    s, R, nb, ni, do_polish = args
    rng = np.random.default_rng(s)
    W = witnesses(R, nb, ni)
    c = slp_stage(smooth_stage(seed(rng, R), W, R), W, R)
    out = {
        "seed": int(s),
        "t_W": t_value(c, W),                       # witness relaxation value
        "ring_violation": ring_violation(c, R),
        "rho_full": covering_radius(c, R),          # exact max-min over all of D(0,R)
        "inner_norm": float(np.linalg.norm(c[0])),
        "centers": c.tolist(),
    }
    if do_polish:
        cp = polish_ring(c, R)
        out.update(rho_exact=covering_radius(cp, R), ring_violation_exact=ring_violation(cp, R),
                   t_W_exact=t_value(cp, W), centers_exact=cp.tolist())
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("-R", type=float, default=2.631)
    ap.add_argument("--nb", type=int, default=48, help="boundary witnesses")
    ap.add_argument("--ni", type=int, default=120, help="interior witnesses")
    ap.add_argument("--starts", type=int, default=64)
    ap.add_argument("--seed0", type=int, default=0)
    ap.add_argument("--no-polish", action="store_true",
                    help="skip the exact (full-disk) active-set polish")
    ap.add_argument("--workers", type=int, default=max(1, (os.cpu_count() or 2) - 2))
    ap.add_argument("--time-limit", type=float, default=290.0, help="seconds; stop submitting")
    ap.add_argument("--out", type=Path, default=None)
    a = ap.parse_args()

    t0 = time.time()
    jobs = [(a.seed0 + s, a.R, a.nb, a.ni, not a.no_polish) for s in range(a.starts)]
    results = []
    with ProcessPoolExecutor(a.workers) as ex:
        futs = [ex.submit(one_start, j) for j in jobs]
        for f in futs:
            left = a.time_limit - (time.time() - t0)
            if left <= 0:
                f.cancel()
                continue
            try:
                results.append(f.result(timeout=left))
            except Exception as e:  # timeout or worker error: record, don't hide
                results.append({"seed": None, "error": repr(e)})
        for f in futs:
            f.cancel()
    ok = [r for r in results if "t_W" in r]
    ok.sort(key=lambda r: r["t_W"])
    feas = [r for r in ok if r["t_W"] <= 1 + 1e-9 and r["ring_violation"] <= 1e-9]
    el = time.time() - t0
    print(f"R={a.R} |W|={a.nb}+{a.ni} starts done={len(ok)}/{a.starts} time={el:.1f}s")
    print(f"W-feasible (t_W<=1): {len(feas)}")
    for r in ok[:8]:
        print(f"  seed={r['seed']:5d} t_W={r['t_W']:.9f} ring_viol={r['ring_violation']:.1e} "
              f"rho_full={r['rho_full']:.6f} |c0|={r['inner_norm']:.3f}"
              + (f" rho_exact={r['rho_exact']:.9f}" if "rho_exact" in r else ""))
    if ok:
        ts = np.array([r["t_W"] for r in ok])
        if not a.no_polish:
            rl = np.array([r["rho_exact"] for r in ok])
            bi = int(rl.argmin())
            # c/rho is in C10(R/rho) (rho>1 keeps |c_i|/rho >= R/rho - 1) and covers D(0,R/rho)
            Rb = a.R / rl.min()
            print(f"exact polish rho(c, R) over C10: min {rl.min():.12f} (seed {ok[bi]['seed']})"
                  f"  #covering(rho<=1): {(rl <= 1 + 1e-9).sum()}"
                  f"  => C10 lower bound R/rho = {Rb:.12f}")
            tb = min(ts.min(), min(r["t_W_exact"] for r in ok))
            print(f"min t_W over witness + polished configs: {tb:.9f}"
                  f"  ({'W NOT excluded' if tb <= 1 + 1e-9 else 'no config found covering W'})")
        print(f"t_W quantiles min/10%/50%: {ts.min():.6f} {np.quantile(ts, .1):.6f} "
              f"{np.median(ts):.6f}")
    out = a.out or HERE / "out" / f"R{a.R}-nb{a.nb}-ni{a.ni}-s{a.seed0}-{a.starts}.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps({"args": {k: str(v) for k, v in vars(a).items()},
                               "elapsed": el, "n_feasible": len(feas),
                               "results": ok, "errors": [r for r in results if "error" in r]},
                              indent=1))
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
