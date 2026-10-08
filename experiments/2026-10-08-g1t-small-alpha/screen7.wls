#!/usr/bin/env wolframscript
(* Cycle 6 collar prototype: grad M(ring)=0 exact + Hessian PSD (M convex) at shrinking delta0. *)
$MaxExtraPrecision = 600; PREC = 40; OUT = 10^-30;
outward[iv_Interval] := Interval[{Floor[N[Min[iv], PREC], OUT], Ceiling[N[Max[iv], PREC], OUT]}];
outward[x_?NumericQ] := outward[Interval[{x, x}]];
Do[Module[{k = n - 1, R, abar, fbar, fp, T, cosA, M, gM, hM, sstar, tstar, gRing, gExact},
  R = 1 + 2 Cos[2 Pi/k]; abar = 6 Pi/k; fbar = 2 ArcSin[Sin[abar/2]/R];
  fp = Cos[abar/2]/Sqrt[R^2 - Sin[abar/2]^2]; T[a_] := fbar + fp (a - abar);
  cosA[s_, t1_, t2_] := Module[{u1 = {R Cos[t1] - s, R Sin[t1]}, u2 = {R Cos[t2] - s, R Sin[t2]}},
    (u1.u2)/(Sqrt[u1.u1] Sqrt[u2.u2])];
  M[s_, t1_, t2_] := Cos[t2 - t1] - Cos[T[ArcCos[cosA[s, t1, t2]]]];
  sstar = 2 Cos[Pi/k]; tstar = Pi/k;
  gM = D[M[s, t1, t2], {{s, t1, t2}}];
  gRing = Quiet[RootReduce[gM /. {s -> sstar, t1 -> -tstar, t2 -> tstar}]];
  gExact = AllTrue[gRing, (# === 0) &];
  Print["n=", n, ": grad M(ring) RootReduce = ", gRing, "  all-zero=", gExact];
  hM = D[M[s, t1, t2], {{s, t1, t2}, 2}];
  Do[Module[{d0 = dd, box, Hiv, mid, radM, emin, rrad, ok, msym},
    box = {Interval[{sstar - d0, sstar + d0}], Interval[{-tstar - d0, -tstar + d0}],
           Interval[{tstar - d0, tstar + d0}]};
    Hiv = hM /. {s -> box[[1]], t1 -> box[[2]], t2 -> box[[3]]};
    Hiv = Map[If[Head[#] === Interval, outward[#], outward[Interval[{#, #}]]] &, Hiv, {2}];
    If[! MatrixQ[Hiv, (Head[#] === Interval) &],
      Print["  d0=", N[d0, 4], ": H not interval matrix"],
      mid = Map[(Min[#] + Max[#])/2 &, Hiv, {2}];
      radM = Map[(Max[#] - Min[#])/2 &, Hiv, {2}];
      msym = (mid + Transpose[mid])/2;
      emin = Min[Eigenvalues[N[msym, PREC]]];
      rrad = Max[Total /@ Abs[radM]];
      ok = emin - rrad > 0;
      Print["  d0=", N[d0, 5], ": min eig(mid)=", N[emin, 6], "  radBound=", N[rrad, 6],
            "  PSD(M convex)=", ok]]
   ], {dd, {1/20, 1/40, 1/100, 1/200, 1/500}}];
 ], {n, {8, 9, 10}}];
