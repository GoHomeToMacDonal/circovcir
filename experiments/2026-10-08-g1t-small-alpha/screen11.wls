#!/usr/bin/env wolframscript
(* Cycle 8: fast centered-form B&B prototype for Pbb (Omega \ B_ring). Precompute symbolic
   gradient ONCE, evaluate per box via Function (not /. each time). Measure boxes + min margin
   + whether it closes for n=8,9,10. Outward rounded. Run via wolframscript. *)
$MaxExtraPrecision = 400; PREC = 30; OUT = 10^-25;
outward[iv_Interval] := Interval[{Floor[N[Min[iv], PREC], OUT], Ceiling[N[Max[iv], PREC], OUT]}];
outward[x_?NumericQ] := outward[Interval[{x, x}]];

run[n_, MAXBOX_, maxDepth_] := Module[
  {k = n - 1, R, abar, fbar, fp, T, sstar, tstar, d0 = 1/160, smin, smax, H0,
   Mcos, gs, gt1, gt2, Mlo, inRing, stack, box, depth, cnt = 0, nb = 0, worst = Infinity,
   collar = 0, off = 0, closedAll = True, sN, tN, abarN, Tcos},
  R = 1 + 2 Cos[2 Pi/k]; abar = 6 Pi/k; fbar = 2 ArcSin[Sin[abar/2]/R];
  fp = Cos[abar/2]/Sqrt[R^2 - Sin[abar/2]^2]; T[a_] := fbar + fp (a - abar);
  sstar = 2 Cos[Pi/k]; tstar = Pi/k; smin = R - 1; smax = Sqrt[R^2 - 1];
  sN = N[sstar, PREC]; tN = N[tstar, PREC]; abarN = N[abar, PREC];
  (* cos T(alpha) with alpha=ArcCos[w]; keep as function of (s,t1,t2) *)
  With[{wex = (({R Cos[t1] - s, R Sin[t1]}).({R Cos[t2] - s, R Sin[t2]}))/
       (Sqrt[({R Cos[t1] - s, R Sin[t1]}).({R Cos[t1] - s, R Sin[t1]})]
        Sqrt[({R Cos[t2] - s, R Sin[t2]}).({R Cos[t2] - s, R Sin[t2]})])},
    Mcos = Cos[t2 - t1] - Cos[T[ArcCos[wex]]]];
  gs = D[Mcos, s]; gt1 = D[Mcos, t1]; gt2 = D[Mcos, t2];
  (* interval lower bound of M on a box via centered form + naive, take max *)
  Mlo[si_, t1i_, t2i_] := Module[
    {a1, a2, dot, l1sq, l2sq, cosv, aLo, thHi, naive, sc, t1c, t2c, rs, r1, r2, bx, Gs, G1, G2, corr, Mc, cen},
    a1 = {R Interval[{Min[Cos[t1i]], Max[Cos[t1i]]}] - si, R Interval[{Min[Sin[t1i]], Max[Sin[t1i]]}]};
    a2 = {R Interval[{Min[Cos[t2i]], Max[Cos[t2i]]}] - si, R Interval[{Min[Sin[t2i]], Max[Sin[t2i]]}]};
    dot = outward[a1[[1]] a2[[1]] + a1[[2]] a2[[2]]];
    l1sq = outward[a1[[1]]^2 + a1[[2]]^2]; l2sq = outward[a2[[1]]^2 + a2[[2]]^2];
    cosv = outward[dot/(Sqrt[l1sq] Sqrt[l2sq])]; cosv = Interval[{Max[-1, Min[cosv]], Min[1, Max[cosv]]}];
    aLo = Min[outward[ArcCos[cosv]]]; thHi = Max[t2i] - Min[t1i];
    naive = Min[outward[Cos[Interval[{thHi, thHi}]]]] - Max[outward[Cos[T[Interval[{aLo, aLo}]]]]];
    sc = (Min[si] + Max[si])/2; t1c = (Min[t1i] + Max[t1i])/2; t2c = (Min[t2i] + Max[t2i])/2;
    rs = (Max[si] - Min[si])/2; r1 = (Max[t1i] - Min[t1i])/2; r2 = (Max[t2i] - Min[t2i])/2;
    bx = {s -> si, t1 -> t1i, t2 -> t2i};
    Gs = outward[gs /. bx]; G1 = outward[gt1 /. bx]; G2 = outward[gt2 /. bx];
    Mc = N[Mcos /. {s -> sc, t1 -> t1c, t2 -> t2c}, PREC];
    corr = rs Max[Abs[Min[Gs]], Abs[Max[Gs]]] + r1 Max[Abs[Min[G1]], Abs[Max[G1]]] + r2 Max[Abs[Min[G2]], Abs[Max[G2]]];
    cen = Mc - corr;
    {Max[naive, cen], aLo}];
  inRing[si_, t1i_, t2i_] := (Min[si] >= sN - d0) && (Max[si] <= sN + d0) &&
     (Min[t1i] >= -tN - d0) && (Max[t1i] <= -tN + d0) && (Min[t2i] >= tN - d0) && (Max[t2i] <= tN + d0);
  H0 = N[ArcCos[(R^2 + smax^2 - 1)/(2 R smax)], PREC];
  stack = {{Interval[{N[smin, PREC], N[smax, PREC]}], Interval[{-H0, H0}], Interval[{-H0, H0}], 0}};
  While[stack =!= {} && cnt < MAXBOX, cnt++;
    {box, depth} = {Most[stack[[1]]], Last[stack[[1]]]}; stack = Rest[stack];
    Module[{si = box[[1]], t1i = box[[2]], t2i = box[[3]], lb, aLo},
      If[Min[t1i] > Max[t2i], Continue[]];
      {lb, aLo} = Mlo[si, t1i, t2i];
      If[N[aLo, PREC] > abarN, off++; Continue[]];
      If[inRing[si, t1i, t2i], collar++; Continue[]];
      worst = Min[worst, lb];
      If[lb >= 0, nb++; Continue[]];
      If[depth >= maxDepth, closedAll = False; nb++; Continue[]];
      Module[{w = {Max[si] - Min[si], Max[t1i] - Min[t1i], Max[t2i] - Min[t2i]}, ax, mid},
        ax = First[Ordering[w, -1]];
        Switch[ax, 1, mid = (Min[si] + Max[si])/2;
          stack = Join[{{Interval[{Min[si], mid}], t1i, t2i, depth + 1}, {Interval[{mid, Max[si]}], t1i, t2i, depth + 1}}, stack],
          2, mid = (Min[t1i] + Max[t1i])/2;
          stack = Join[{{si, Interval[{Min[t1i], mid}], t2i, depth + 1}, {si, Interval[{mid, Max[t1i]}], t2i, depth + 1}}, stack],
          3, mid = (Min[t2i] + Max[t2i])/2;
          stack = Join[{{si, t1i, Interval[{Min[t2i], mid}], depth + 1}, {si, t1i, Interval[{mid, Max[t2i]}], depth + 1}}, stack]]]]];
  {n, cnt, nb, collar, off, N[worst, 8], stack === {}, closedAll, cnt < MAXBOX}];

Do[Module[{t0 = AbsoluteTime[], r}, r = run[n, 20000, 36];
   Print["n=", r[[1]], " boxes=", r[[2]], " discharged=", r[[3]], " collar=", r[[4]], " off=", r[[5]],
     " min_lowerM=", r[[6]], " stackEmpty=", r[[7]], " closedAll=", r[[8]], " underBudget=", r[[9]],
     "  time=", Round[AbsoluteTime[] - t0], "s"]], {n, {8, 9, 10}}];
