#!/usr/bin/env wolframscript
(* Cycle 7: interval Hessian of M is FINITE (screen8 showed no inf at d0=1/40); the Cycle-5/6
   failures were dependency OVERESTIMATION + a buggy PSD step. Here: shrink d0, build the
   interval Hessian cleanly, and test PSD rigorously via
       lambda_min(mid_sym) - rho(radius) >= 0   (rho = Gershgorin/row-sum bound on the
   symmetric radius matrix), an OUTWARD-rounded sufficient condition for every matrix in the
   interval hull to be positive definite. Also certify grad M(ring)=0 to high precision.
   M min at ring => Hessian PSD (positive) => M >= M(ring)=0 on the collar.
   Run: wolframscript -file experiments/2026-10-08-g1t-small-alpha/screen9.wls *)
$MaxExtraPrecision = 600; PREC = 50; OUT = 10^-35;
outward[iv_Interval] := Interval[{Floor[N[Min[iv], PREC], OUT], Ceiling[N[Max[iv], PREC], OUT]}];
outward[x_?NumericQ] := outward[Interval[{x, x}]];
Do[Module[{k = n - 1, R, abar, fbar, fp, T, w, M, gM, hM, sstar, tstar, gRingN},
  R = 1 + 2 Cos[2 Pi/k]; abar = 6 Pi/k; fbar = 2 ArcSin[Sin[abar/2]/R];
  fp = Cos[abar/2]/Sqrt[R^2 - Sin[abar/2]^2]; T[a_] := fbar + fp (a - abar);
  sstar = 2 Cos[Pi/k]; tstar = Pi/k;
  w = ({R Cos[t1] - s, R Sin[t1]}.{R Cos[t2] - s, R Sin[t2]})/
      (Sqrt[{R Cos[t1] - s, R Sin[t1]}.{R Cos[t1] - s, R Sin[t1]}]
       Sqrt[{R Cos[t2] - s, R Sin[t2]}.{R Cos[t2] - s, R Sin[t2]}]);
  M = Cos[t2 - t1] - Cos[T[ArcCos[w]]];
  gM = D[M, {{s, t1, t2}}];
  hM = D[M, {{s, t1, t2}, 2}];
  gRingN = N[gM /. {s -> sstar, t1 -> -tstar, t2 -> tstar}, PREC];
  Print["==== n=", n, "  ring=(", N[sstar, 6], ",", N[-tstar, 6], ",", N[tstar, 6], ") ===="];
  Print["  |grad M(ring)| (hp numeric) = ", N[Max[Abs[gRingN]], 6], "  (want ~0)"];
  Print["  M(ring) = ", N[M /. {s -> sstar, t1 -> -tstar, t2 -> tstar}, 6]];
  Do[Module[{d0 = dd, box, H, mid, rad, msym, emin, rho, psd},
    box = {Interval[{sstar - d0, sstar + d0}], Interval[{-tstar - d0, -tstar + d0}],
           Interval[{tstar - d0, tstar + d0}]};
    H = hM /. {s -> box[[1]], t1 -> box[[2]], t2 -> box[[3]]};
    H = Map[outward, H, {2}];
    If[! MatrixQ[H, (Head[#] === Interval) &],
      Print["  d0=", N[d0, 5], ": H entry not finite interval"],
      mid = Map[(Min[#] + Max[#])/2 &, H, {2}];
      rad = Map[(Max[#] - Min[#])/2 &, H, {2}];
      msym = (mid + Transpose[mid])/2;
      emin = Min[Eigenvalues[N[msym, PREC]]];
      rho = Max[Total /@ Abs[rad]];  (* row-sum (Gershgorin) bound on ||radius matrix|| *)
      psd = emin - rho > 0;
      Print["  d0=", N[d0, 6], ": lambda_min(mid)=", N[emin, 6], "  radiusBound=", N[rho, 6],
            "  lambda_lo=", N[emin - rho, 6], "  PSD=", psd]]
   ], {dd, {1/40, 1/80, 1/160, 1/320, 1/640, 1/1280}}];
 ], {n, {8, 9, 10}}];
