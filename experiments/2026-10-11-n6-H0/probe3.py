"""Probe one (a, cP) point of case3_arcs with fine discretisation; print the minimising cQ."""
import sys

import case3_arcs as m
import numpy as np

a, x, y = map(float, sys.argv[1:4])
q = np.array([0.0, a - 1])
cP = np.array([x, y])
print("|cP|", np.hypot(x, y), "witnesses", [w.round(4).tolist() for w in m.witnesses(a, cP)])
base = m.covered(np.array([[0.0, a], [x, y]])).any(axis=0)
for w in m.witnesses(a, cP):
    CQ = m.K_samples(w, q, 300)
    cov = base[None, :] | m.covered(CQ)
    G = ~cov
    lenG = G.sum(axis=1) * m.DPHI
    holdsb = np.linalg.norm(CQ - m.B, axis=1) <= 1
    Gr = np.roll(G, -m.IB, axis=1)
    allg = Gr.all(axis=1)
    lead = np.where(allg, m.NG, np.argmax(~Gr, axis=1))
    trail = np.where(allg, 0, np.argmax(~Gr[:, ::-1], axis=1))
    g0 = np.where(Gr[:, 0], np.minimum(lead + trail, m.NG), 0) * m.DPHI
    d = np.where(holdsb, lenG - 6 * m.al, lenG - np.minimum(2 * m.al, g0) - 4 * m.al)
    k = np.argmin(d)
    print("w", w.round(5), "min deficit", d[k], "cQ", CQ[k].round(4), "|cQ|", np.linalg.norm(CQ[k]),
          "holds b", holdsb[k], "|G|", lenG[k], "G0", g0[k])
