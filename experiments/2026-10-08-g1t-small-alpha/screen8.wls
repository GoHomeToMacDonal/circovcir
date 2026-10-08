#!/usr/bin/env wolframscript
(* Cycle 7 diagnosis: locate the Interval[-inf,inf] in M's symbolic Hessian, and test an
   ArcCos-free Hessian via the composition  M = cos(theta) - cos(T(alpha)),  alpha=ArcCos[w],
   w = cosAlpha(s,t1,t2).  d/dx cos(T(alpha)) = -sin(T) T' * alpha'(w) * w',
   alpha'(w) = -1/Sqrt[1-w^2].  The blow-up is 1/Sqrt[1-w^2] when w -> +-1 (|u|->1, the ring!).
   At the ring w=cos(abar) and 1-w^2 = sin(abar)^2 > 0, so it is NOT 1-w^2 that vanishes.
   Hunt the real culprit. Run: wolframscript -file experiments/2026-10-08-g1t-small-alpha/screen8.wls *)
$MaxExtraPrecision = 400; PREC = 40; OUT = 10^-30;
outward[iv_Interval] := Interval[{Floor[N[Min[iv], PREC], OUT], Ceiling[N[Max[iv], PREC], OUT]}];
outward[x_?NumericQ] := outward[Interval[{x, x}]];
Module[{n = 10, k, R, abar, fbar, fp, T, w, sstar, tstar, box, d0 = 1/40,
   cosAlpha, Mexpr, parts},
  k = n - 1; R = 1 + 2 Cos[2 Pi/k]; abar = 6 Pi/k;
  fbar = 2 ArcSin[Sin[abar/2]/R]; fp = Cos[abar/2]/Sqrt[R^2 - Sin[abar/2]^2];
  T[a_] := fbar + fp (a - abar);
  sstar = 2 Cos[Pi/k]; tstar = Pi/k;
  cosAlpha[s_, t1_, t2_] := Module[{u1 = {R Cos[t1] - s, R Sin[t1]}, u2 = {R Cos[t2] - s, R Sin[t2]}},
    (u1.u2)/(Sqrt[u1.u1] Sqrt[u2.u2])];
  box = {Interval[{sstar - d0, sstar + d0}], Interval[{-tstar - d0, -tstar + d0}],
         Interval[{tstar - d0, tstar + d0}]};
  (* evaluate the sub-pieces of the Hessian on the box, one at a time, to find the inf *)
  w = cosAlpha[s, t1, t2];
  Print["n=10 ring box d0=", N[d0, 4]];
  (* w on box *)
  Print["  w=cosAlpha on box: ", N[outward[w /. {s -> box[[1]], t1 -> box[[2]], t2 -> box[[3]]}], 8]];
  (* 1 - w^2 on box: is it bounded away from 0? *)
  Print["  1-w^2 on box     : ", N[outward[(1 - w^2) /. {s -> box[[1]], t1 -> box[[2]], t2 -> box[[3]]}], 8]];
  (* |u1|^2, |u2|^2 on box *)
  Print["  |u1|^2 on box    : ", N[outward[({R Cos[t1] - s, R Sin[t1]}.{R Cos[t1] - s, R Sin[t1]}) /. {s -> box[[1]], t1 -> box[[2]]}], 8]];
  (* second derivative of w wrt s on box (symbolic D, but just w not M) *)
  Module[{wss = D[w, {s, 2}], wst = D[w, s, t1]},
    Print["  d2w/ds2 head after box subst: ", Head[outward[wss /. {s -> box[[1]], t1 -> box[[2]], t2 -> box[[3]]}]]];
    Print["  d2w/dsdt1 head             : ", Head[outward[wst /. {s -> box[[1]], t1 -> box[[2]], t2 -> box[[3]]}]]]];
  (* now the full d2 M / ds2 symbolic, piecewise *)
  Mexpr = Cos[t2 - t1] - Cos[T[ArcCos[w]]];
  Module[{Mss = D[Mexpr, {s, 2}], iv},
    iv = Mss /. {s -> box[[1]], t1 -> box[[2]], t2 -> box[[3]]};
    Print["  d2M/ds2 raw head: ", Head[iv], "  (if Interval, min/max:)"];
    If[Head[iv] === Interval, Print["    ", N[iv, 6]], Print["    NOT a bare interval -> contains ", Cases[iv, Interval[{-Infinity | DirectedInfinity[_], _}] | DirectedInfinity[_], Infinity] // Short]]];
]
