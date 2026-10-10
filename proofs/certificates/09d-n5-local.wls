#!/usr/bin/env wolframscript
(* Certificate 09d for proofs/09-n5-independent.md (local part of IG):
   On the window W = [R5lo,Rhi] x [dlo,1] x [-w0,w0] x [-Phi0,Phi0]  (R, d, psi, phi), with
   w0 = 9/100 (>= w by 09a G6), Phi0 = 15/100, the closed-form reach
     E(psi,phi) = 2 ang(c) - psi,  c = right centre of the unit circle through P = A(psi), Q = B(phi),
   satisfies (all strict, interval B&B):
     (D1) E_phi > 0
     (D2) E_psi > 0
     (D3) Qn := E_ss E_f^2 - 2 E_sf E_s E_f + E_ff E_s^2 < 0      (=> phi3(psi) convex, phi3'' = -Qn/E_f^3)
     (D4) triangle P, Q, X* (X* = A(E)) is acute: three dot products > 0
     (D5) d/dy [circumradius^2(P, Q, A(y))] > 0 at y = E
     (D6) |P - Q| < 2 (the right centre exists)
   D4+D5(+D6): E equals the true reach, i.e. for y in [psi, psi+2 alpha]: fits(P,Q,A(y)) <=> y <= E.
   Exit 1 on failure; last line "CERTIFICATE OK". *)

fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];
Off[General::munfl];

R5lo = 1641004/1000000; Rhi = 1643/1000; dlo = 845/1000; w0 = 9/100; Phi0 = 15/100;

A[R_, p_] := R {Sin[p], -Cos[p]};
Bp[d_, p_] := {Sin[p], d - Cos[p]};
P = A[R, s]; Q = Bp[d, f]; v = Q - P; L2 = v . v;
c = (P + Q)/2 + Sqrt[1 - L2/4] {v[[2]], -v[[1]]}/Sqrt[L2];
(* polar angle of c from the bottom direction; c lies in the lower-right quadrant region: use ArcTan of ratio *)
Esym = 2 ArcTan[c[[1]]/(-c[[2]])] - s;
Es = D[Esym, s]; Ef = D[Esym, f];
Qn = D[Esym, s, s] Ef^2 - 2 D[Esym, s, f] Es Ef + D[Esym, f, f] Es^2;
X = A[R, Esym];
acute = {(Q - P) . (X - P), (P - Q) . (X - Q), (P - X) . (Q - X)};
Xy = A[R, y]; a2 = (Q - Xy) . (Q - Xy); b2 = (P - Xy) . (P - Xy); c2 = L2;
dt = (Q - P)[[1]] (Xy - P)[[2]] - (Q - P)[[2]] (Xy - P)[[1]];
rho2 = a2 b2 c2/(4 dt^2);
drho = D[rho2, y] /. y -> Esym;

preds = <|"D1 E_phi>0" -> Ef, "D2 E_psi>0" -> Es, "D3 Qn<0" -> -Qn,
   "D4a" -> acute[[1]], "D4b" -> acute[[2]], "D4c" -> acute[[3]], "D5 drho>0" -> drho, "D6 |PQ|<2" -> 4 - L2,
   "D0 c below x-axis" -> -c[[2]]|>;
fns = Function[{R, d, s, f}, Evaluate[#]] & /@ preds;

boxes = 0;
provePos[fn_, box_, depth_] := Module[{v = Quiet@N[fn @@ (Interval /@ box)]},
   boxes++;
   Which[Head[v] === Interval && Min[v] > 0, True,
    depth == 0, (Print["  stuck ", N[box]]; False),
    True, Module[{k = Ordering[(#[[2]] - #[[1]]) / {Rhi - R5lo, 1 - dlo, 2 w0, 2 Phi0} & /@ box, -1][[1]], lo, hi, m},
     m = (box[[k, 1]] + box[[k, 2]])/2;
     lo = ReplacePart[box, k -> {box[[k, 1]], m}]; hi = ReplacePart[box, k -> {m, box[[k, 2]]}];
     provePos[fn, lo, depth - 1] && provePos[fn, hi, depth - 1]]]];

W = N[{{R5lo, Rhi}, {dlo, 1}, {-w0, w0}, {-Phi0, Phi0}}];
KeyValueMap[Function[{name, fn}, boxes = 0;
   Module[{t, r}, {t, r} = AbsoluteTiming[provePos[fn, W, 40]];
    Print["  ", name, ": boxes ", boxes, ", ", Round[t, 0.1], " s"]; gate[name, r]]], fns];

Print["CERTIFICATE OK"];
