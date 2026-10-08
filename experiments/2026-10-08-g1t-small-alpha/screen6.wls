#!/usr/bin/env wolframscript
(* Cycle 6 prototype: centered-form vs naive interval lower bound of
     M(s,t1,t2) = cos(t2-t1) - cos(T(ArcCos[cosAlpha]))
   on representative boxes (interior + near-ring), n=8,9,10. Outward rounded.
   Goal: confirm centered form tightens lower(M) from negative (overestimate) to >=0.
   Run: wolframscript -file experiments/2026-10-08-g1t-small-alpha/screen6.wls *)
$MaxExtraPrecision = 400;
PREC = 40; OUT = 10^-30;
outward[iv_Interval] := Interval[{Floor[N[Min[iv], PREC], OUT], Ceiling[N[Max[iv], PREC], OUT]}];
outward[x_?NumericQ] := outward[Interval[{x, x}]];

Do[Module[{k = n - 1, R, abar, fbar, fp, T, cosA, M, gM, sstar, tstar, boxes, lbl},
  R = 1 + 2 Cos[2 Pi/k]; abar = 6 Pi/k;
  fbar = 2 ArcSin[Sin[abar/2]/R]; fp = Cos[abar/2]/Sqrt[R^2 - Sin[abar/2]^2];
  T[a_] := fbar + fp (a - abar);
  cosA[s_, t1_, t2_] := Module[{u1 = {R Cos[t1] - s, R Sin[t1]}, u2 = {R Cos[t2] - s, R Sin[t2]}},
    (u1.u2)/(Sqrt[u1.u1] Sqrt[u2.u2])];
  M[s_, t1_, t2_] := Cos[t2 - t1] - Cos[T[ArcCos[cosA[s, t1, t2]]]];
  gM = D[M[s, t1, t2], {{s, t1, t2}}];
  sstar = 2 Cos[Pi/k]; tstar = Pi/k;

  Print["==== n=", n, "  R=", N[R, 12], "  ring=(", N[sstar, 8], ",", N[-tstar, 8], ",", N[tstar, 8], ") ===="];
  (* calibration: M(ring)=0 *)
  Print["  calib M(ring) = ", N[M[sstar, -tstar, tstar], 12]];

  (* representative boxes: {center, radius, label}; include near-ring at shrinking radius *)
  boxes = {
    {{N[sstar, PREC], N[-tstar, PREC], N[tstar, PREC]}, N[5/100, PREC], "ring r=0.05"},
    {{N[sstar, PREC], N[-tstar, PREC], N[tstar, PREC]}, N[2/100, PREC], "ring r=0.02"},
    {{N[sstar, PREC], N[-tstar, PREC], N[tstar, PREC]}, N[1/100, PREC], "ring r=0.01"},
    {{N[sstar, PREC], N[-tstar, PREC], N[tstar, PREC]}, N[1/1000, PREC], "ring r=0.001"},
    {{N[21/10, PREC], N[-35/100, PREC], N[-10/100, PREC]}, N[2/100, PREC], "interior A r=0.02"},
    {{N[18/10, PREC], N[-30/100, PREC], N[20/100, PREC]}, N[2/100, PREC], "interior B r=0.02"}};

  Do[Module[{cen = b[[1]], rad = b[[2]], boxI, Mnaive, Mc, gBox, corr, cLo},
    boxI = {Interval[{cen[[1]] - rad, cen[[1]] + rad}], Interval[{cen[[2]] - rad, cen[[2]] + rad}],
            Interval[{cen[[3]] - rad, cen[[3]] + rad}]};
    (* naive *)
    Mnaive = outward[M[boxI[[1]], boxI[[2]], boxI[[3]]]];
    (* centered form: M_lo = M(c) - Sum rad * max|dM/dx_i|(box) *)
    Mc = N[M @@ cen, PREC];
    gBox = outward /@ (gM /. {s -> boxI[[1]], t1 -> boxI[[2]], t2 -> boxI[[3]]});
    corr = Sum[rad Max[Abs[Min[gBox[[i]]]], Abs[Max[gBox[[i]]]]], {i, 3}];
    cLo = Mc - corr;
    Print["  ", b[[3]], ":  naive lower=", PaddedForm[N[Min[Mnaive], 6], {8, 6}],
          "   centered lower=", PaddedForm[N[cLo, 6], {8, 6}],
          "   M(c)=", PaddedForm[N[Mc, 6], {8, 6}]];
  ], {b, boxes}];
], {n, {8, 9, 10}}];
