#!/usr/bin/env wolframscript
(* Numeric study of the closed-form reach E(psi,phi) on the local window (proofs/09 §6', local part).
   E = 2 ang(c) - psi, c = centre of the unit circle through P=A(psi), Q=B(phi) on the right of P->Q,
   ang(v) = ArcTan[-v2, v1] (polar angle from the bottom direction).
   Reports over a grid: max eigenvalue of Hess_{psi,phi} E, min dE/dphi, min angle-slack of triangle
   P,Q,X* (acute <=> all angles < Pi/2), min d/dy circumradius(P,Q,A(y)) at y = E. *)
Off[General::munfl];
A[R_, p_] := R {Sin[p], -Cos[p]};
B[d_, p_] := {Sin[p], d - Cos[p]};
cR[P_, Q_] := Module[{v = Q - P, L}, L = Sqrt[v . v]; (P + Q)/2 + Sqrt[1 - L^2/4] {v[[2]], -v[[1]]}/L];
ang[v_] := ArcTan[-v[[2]], v[[1]]];
Esym = Module[{c = cR[A[R, s], B[d, f]]}, 2 ang[c] - s];
H = D[Esym, {{s, f}, 2}];
dEf = D[Esym, f];
circR[p1_, p2_, p3_] := Module[{a = Norm[p2 - p3], b = Norm[p1 - p3], cc = Norm[p1 - p2], ar},
   ar = Abs[Det[{p2 - p1, p3 - p1}]]/2; a b cc/(4 ar)];
maxAngle[p1_, p2_, p3_] := Module[{angAt},
   angAt[x_, y_, z_] := VectorAngle[y - x, z - x]; Max[angAt[p1, p2, p3], angAt[p2, p3, p1], angAt[p3, p1, p2]]];
R5 = 1.6410044636036157; dst = 0.95315494724913;
study[{d1_, d2_}, w_, Phi0_] := Module[{pts, vals},
  pts = Flatten[Table[{RR, dd, ss, ff}, {RR, {R5, 1.643}}, {dd, Subdivide[d1, d2, 4]},
     {ss, Subdivide[-w, w, 6]}, {ff, Subdivide[-Phi0, Phi0, 8]}], 3];
  vals = Function[{RR, dd, ss, ff}, Module[{rule = {R -> RR, d -> dd, s -> ss, f -> ff}, P, Q, Ev, X, eig, rad},
       P = A[RR, ss]; Q = B[dd, ff]; Ev = Esym /. rule; X = A[RR, Ev];
       eig = Max[Eigenvalues[H /. rule]];
       rad = (circR[P, Q, A[RR, Ev + 10^-6]] - circR[P, Q, A[RR, Ev - 10^-6]])/(2 10^-6);
       {eig, dEf /. rule, Pi/2 - maxAngle[P, Q, X], rad}]] @@@ pts;
  Print["window d=", {d1, d2}, " |psi|<=", w, " |phi|<=", Phi0, ":  max eig H = ", Max[vals[[All, 1]]],
   "  min dE/dphi = ", Min[vals[[All, 2]]], "  min acute slack = ", Min[vals[[All, 3]]],
   "  min dcircR/dy = ", Min[vals[[All, 4]]]]];
(* convexity of phi3(psi) (E(psi,phi3)=c): phi3'' = -Qn/Ef^3, Qn = Ess Ef^2 - 2 Esf Es Ef + Eff Es^2 *)
Es = D[Esym, s]; Ef = dEf; Ess = D[Esym, s, s]; Esf = D[Esym, s, f]; Eff = D[Esym, f, f];
Qn = Ess Ef^2 - 2 Esf Es Ef + Eff Es^2;
conv[{d1_, d2_}, w_, Phi0_] := Module[{v = Flatten[Table[{Qn, Ef} /. {R -> RR, d -> dd, s -> ss, f -> ff},
      {RR, {R5, 1.643}}, {dd, Subdivide[d1, d2, 6]}, {ss, Subdivide[-w, w, 8]}, {ff, Subdivide[-Phi0, Phi0, 6]}], 3]},
   Print["d=", {d1, d2}, " |phi|<=", Phi0, ": max Qn = ", Max[v[[All, 1]]], "  min Ef = ", Min[v[[All, 2]]]]];
conv[{0.93, 0.975}, 0.09, 0.05];
conv[{0.93, 0.975}, 0.09, 0.15];
conv[{0.90, 1.0}, 0.09, 0.15];
study[{0.93, 0.975}, 0.09, 0.15];
