#!/usr/bin/env wolframscript
(* Cycle 8: KKT collar -- verify the FIRST-ORDER sign structure of grad M over the whole
   collar box B_ring (not just at the ring), by OUTWARD-rounded interval gradient.
   If over B_ring:  dM/dt1 >= a > 0  AND  dM/dt2 <= -a < 0  (a a positive lower/upper bound),
   then M is increasing in t1 and decreasing in t2 throughout B_ring.
   The ring is the feasible point with the LARGEST t1 (= h(s), |u1|=1) and SMALLEST t2
   (= -h(s), |u2|=1) in its area; every other feasible point in B_ring has t1 <= ring-t1 and
   t2 >= ring-t2 is NOT generally true -- so we must check the real feasible geometry.
   Here: just measure the interval enclosures of dM/dt1 and dM/dt2 over B_ring at a few d0,
   and whether they are sign-definite (>0 and <0). Run via wolframscript. *)
$MaxExtraPrecision = 600; PREC = 50; OUT = 10^-35;
outward[iv_Interval] := Interval[{Floor[N[Min[iv], PREC], OUT], Ceiling[N[Max[iv], PREC], OUT]}];
outward[x_?NumericQ] := outward[Interval[{x, x}]];
Do[Module[{k = n - 1, R, abar, fbar, fp, T, w, M, dMdt1, dMdt2, dMds, sstar, tstar},
  R = 1 + 2 Cos[2 Pi/k]; abar = 6 Pi/k; fbar = 2 ArcSin[Sin[abar/2]/R];
  fp = Cos[abar/2]/Sqrt[R^2 - Sin[abar/2]^2]; T[a_] := fbar + fp (a - abar);
  sstar = 2 Cos[Pi/k]; tstar = Pi/k;
  w = ({R Cos[t1] - s, R Sin[t1]}.{R Cos[t2] - s, R Sin[t2]})/
      (Sqrt[{R Cos[t1] - s, R Sin[t1]}.{R Cos[t1] - s, R Sin[t1]}]
       Sqrt[{R Cos[t2] - s, R Sin[t2]}.{R Cos[t2] - s, R Sin[t2]}]);
  M = Cos[t2 - t1] - Cos[T[ArcCos[w]]];
  dMds = D[M, s]; dMdt1 = D[M, t1]; dMdt2 = D[M, t2];
  Print["==== n=", n, " ===="];
  Do[Module[{d0 = dd, box, g1, g2, gs},
    box = {s -> Interval[{sstar - d0, sstar + d0}], t1 -> Interval[{-tstar - d0, -tstar + d0}],
           t2 -> Interval[{tstar - d0, tstar + d0}]};
    g1 = outward[dMdt1 /. box]; g2 = outward[dMdt2 /. box]; gs = outward[dMds /. box];
    Print["  d0=", N[d0, 6], ": dM/dt1=", N[g1, 5], "  dM/dt2=", N[g2, 5], "  dM/ds=", N[gs, 5]];
    Print["      dM/dt1>0? ", Min[g1] > 0, "   dM/dt2<0? ", Max[g2] < 0]];
   , {dd, {1/20, 1/40, 1/80, 1/160}}];
 ], {n, {8, 9, 10}}];
