"""Scope the domain of the n=5 proof chain (proofs/09) numerically (L1 evidence only).

For R = R5 (and R5+1e-3) over the admissible d range, print:
  d_min   : smallest d with 2 psiT <= 8 alpha (L2 counting)
  m       : 2 psiT - 6 alpha (must be > 0)
  w_P     : 4 alpha - psiT (half-width of the P range, L2c)
  phi*    : lower bound of D2's reach on B, given D2 contains T_R and A(psiT - m) (L3)
  case3   : c - E(w_P, -phi*)  (must be > 0 to exclude L6(iii))
"""
import numpy as np
from scipy.optimize import brentq, minimize_scalar

R5 = 1.6410044636036157006508328240594


def psiT(R, d):
    yT = (R * R + d * d - 1) / (2 * d)
    return np.pi - np.arccos(yT / R)


def A(R, p):
    return R * np.array([np.sin(p), -np.cos(p)])


def B(d, p):
    return np.array([np.sin(p), d - np.cos(p)])


def ang_bottom(v):
    return np.arctan2(v[0], -v[1])


def right_center(P, Q):
    """Centre of the unit circle through P, Q lying to the right of P->Q."""
    v = Q - P
    L = np.hypot(*v)
    n = np.array([v[1], -v[0]]) / L
    return (P + Q) / 2 + np.sqrt(1 - L * L / 4) * n


def E(R, d, psi, phi):
    c = right_center(A(R, psi), B(d, phi))
    return 2 * ang_bottom(c) - psi


def b_low(d, c):
    """Lower (smallest-phi) end of the B-arc covered by the unit disk at c."""
    q = c - np.array([0, d])
    return np.arctan2(q[0], -q[1]) - np.arccos(min(1.0, np.hypot(*q) / 2))


def phi_star(R, d):
    """min over centres in Lens(T_R, A(psiT-m)) of the lower B-end (boundary scan: the
    objective is checked on the lens boundary and on a coarse interior grid)."""
    pt = psiT(R, d)
    m = 2 * pt - 6 * np.arcsin(1 / R)
    P1, P2 = A(R, pt), A(R, pt - m)
    best = np.inf
    for s in np.linspace(-1, 1, 801):
        for (X, Y) in ((P1, P2), (P2, P1)):
            # points of the lens boundary: arcs of unit circles around X inside D(Y,1)
            th0 = np.arctan2(*(Y - X)[::-1])
            half = np.arccos(np.hypot(*(Y - X)) / 2)
            c = X + np.array([np.cos(th0 + s * half), np.sin(th0 + s * half)])
            best = min(best, b_low(d, c))
    return best


if __name__ == "__main__":
    for R in (R5, R5 + 1e-3):
        al = np.arcsin(1 / R)
        dmin = brentq(lambda d: 2 * psiT(R, d) - 8 * al, R - 1 + 1e-9, 1.0)
        print(f"R={R:.10f} alpha={al:.10f} d_min={dmin:.6f} (d range [{dmin:.6f}, 1])")
        print("    d        m       w_P      phi*     case3(c-E)")
        for d in np.linspace(dmin, 1.0, 9):
            pt = psiT(R, d)
            m, wP = 2 * pt - 6 * al, 4 * al - pt
            ps = phi_star(R, d)
            cval = pt - 2 * al
            case3 = cval - E(R, d, wP, -ps) if ps > 0 else float("nan")
            print(f"  {d:.5f}  {m:+.5f}  {wP:+.5f}  {ps:+.5f}  {case3:+.5f}")
