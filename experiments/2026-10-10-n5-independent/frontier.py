"""Right-pair Pareto frontier for n=5 (step 1 of the left/right gluing plan).

Setting: Cn = D(0,R), C1 = D((0,d),1). Right corner T = dCn cap dC1 (x>0).
A-arc (dCn not covered by C1), angle psi from bottom (0,-R) toward T: A(psi) = R(sin psi, -cos psi).
B-arc (back boundary of C1 inside Cn), angle phi from C1's bottom (0,d-1): B(phi) = (sin phi, d - cos phi).
Right pair {D2, D3} must cover A on [psi_e, psiT] and B on [phi_e, phiT].
G(phi_e) := min psi_e (smaller = longer covered arcs: L_A = R(psiT-psi_e), L_B = phiT-phi_e).

  structural: D3 through A(psi_e), B(phi_e); D2 has T and X_A antipodal
              => 2*pc(D3) - psi_e = psiT - 2 asin(1/R)
  brute:      SLSQP multistart over (c2, c3) with interval-coverage constraints (no structural assumption)
Gluing: right reaches (psi_R, phi_R), mirrored left (psi_L, phi_L); need psi_R+psi_L<=0, phi_R+phi_L<=0.
G decreasing => symmetric gluing is WLOG iff G(phi)+G(-phi) >= 2 G(0) (even-convexity).
"""
import numpy as np
from scipy.optimize import brentq, minimize

R5 = 1.6410044636036157006508328240594
D5 = 0.95315494724913008525948079077139


def corner(R, d):
    yT = (R * R + d * d - 1) / (2 * d)
    T = np.array([np.sqrt(R * R - yT * yT), yT])
    return T, np.arctan2(T[0], -T[1]), np.arctan2(T[0], d - T[1])


def A(R, p):
    return R * np.array([np.sin(p), -np.cos(p)])


def B(d, p):
    return np.array([np.sin(p), d - np.cos(p)])


def polar_from_bottom(c):
    return np.arctan2(c[0], -c[1])


def a_interval(R, c):
    r = np.hypot(*c)
    w = np.arccos(np.clip((R * R + r * r - 1) / (2 * R * r), -1, 1))
    pc = polar_from_bottom(c)
    return pc - w, pc + w


def b_interval(d, c):
    q = c - np.array([0, d])
    w = np.arccos(np.clip(np.hypot(*q) / 2, -1, 1))
    pc = np.arctan2(q[0], -q[1])
    return pc - w, pc + w


def struct_G(R, d, phi_e):
    _, psiT, _ = corner(R, d)
    target = psiT - 2 * np.arcsin(1 / R)

    def f(psi_e):
        P, Q = A(R, psi_e), B(d, phi_e)
        v = Q - P
        L = np.hypot(*v)
        n = np.array([v[1], -v[0]]) / L  # right-hand normal of P->Q
        c3 = (P + Q) / 2 + np.sqrt(1 - L * L / 4) * n
        return 2 * polar_from_bottom(c3) - psi_e - target

    return brentq(f, -1.2, 1.2, xtol=1e-15)


def brute_G(R, d, phi_e, starts=40, seed=0):
    T, _, _ = corner(R, d)
    rng = np.random.default_rng(seed)

    def cons(z):
        c2, c3 = z[:2], z[2:4]
        a2, a3 = a_interval(R, c2), a_interval(R, c3)
        b2, b3 = b_interval(d, c2), b_interval(d, c3)
        return np.array([1 - np.sum((c2 - T) ** 2), a3[1] - a2[0], b3[1] - b2[0], phi_e - b3[0]])

    _, psiT, phiT = corner(R, d)

    def covers(z, psi_e, tol=1e-7):
        # independent check by sampling: every sampled arc point within 1+tol of c2 or c3
        cs = [z[:2], z[2:4]]
        pts = [A(R, t) for t in np.linspace(psi_e, psiT, 400)] + [B(d, t) for t in np.linspace(phi_e, phiT, 400)]
        return all(min(np.hypot(*(q - c)) for c in cs) <= 1 + tol for q in pts)

    best = np.inf
    for _ in range(starts):
        z0 = np.array([1.2, 0.4, 0.6, -0.85]) + rng.normal(0, 0.15, 4)
        res = minimize(lambda z: a_interval(R, z[2:4])[0], z0, method="SLSQP",
                       constraints=[{"type": "ineq", "fun": cons}], options={"ftol": 1e-14, "maxiter": 500})
        if res.success and np.all(cons(res.x) > -1e-10) and covers(res.x, res.fun):
            best = min(best, res.fun)
    return best


if __name__ == "__main__":
    T, psiT, phiT = corner(R5, D5)
    print(f"R5={R5:.16f} d*={D5:.16f} psiT={psiT:.12f} phiT={phiT:.12f}")
    print(" phi_e     G_struct          G_brute        diff")
    for ph in [-0.3, -0.2, -0.1, -0.05, 0.0, 0.05, 0.1, 0.2, 0.3]:
        gs, gb = struct_G(R5, D5, ph), brute_G(R5, D5, ph)
        print(f"{ph:+.2f}  {gs:+.12f}  {gb:+.12f}  {gs - gb:+.1e}")
    print("even-convexity min_phi [G(phi)+G(-phi)-2G(0)]:")
    for Rt, dt in [(R5, D5), (R5, D5 - 0.05), (R5, D5 + 0.03), (1.62, 0.93)]:
        g0 = struct_G(Rt, dt, 0.0)
        vals, pmax = [], 0.0
        for p in np.linspace(0.005, 0.4, 80):
            try:
                vals.append(struct_G(Rt, dt, p) + struct_G(Rt, dt, -p) - 2 * g0); pmax = p
            except ValueError:
                break
        vb = min(brute_G(Rt, dt, p, starts=20) + brute_G(Rt, dt, -p, starts=20) - 2 * brute_G(Rt, dt, 0.0, starts=20)
                 for p in np.linspace(0.05, 0.6, 12))
        print(f"  R={Rt:.4f} d={dt:.4f}: G(0)={g0:+.3e}  min even-gap struct (phi<={pmax:.3f})={min(vals):+.3e}  brute (phi<=0.6)={vb:+.3e}")
