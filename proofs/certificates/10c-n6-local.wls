#!/usr/bin/env wolframscript
(* Certificate 10c for proofs/10-n6-half.md (local part of lemma H3):
   On N4 = [Rlo,Rhi] x [a*-rho,a*+rho] x [b*-rho,b*+rho] x [0,w1]  (R,a,b,w), with
   c2(R,a,b,w) := circumradius^2(V, T2, X(w)),  G(R,a,b) := c2(R,a,b,0) - 1:
     (L1) triangle V, T2, X(w) acute: three dot products > 0          [4D]
     (L2) d c2 / d w > 0                                            [4D]
     (L3) d G / d R > 0                                              [3D, w = 0]
     (L4) on the small core Ncore = [Rlo,Rhi] x [a*-rc,a*+rc] x [b*-rc,b*+rc], rc = rho/32 = 1/1280:
          G_aa > 0  and  G_aa G_bb - G_ab^2 > 0  (Hessian in (a,b) positive definite)   [3D]
     (L5) G(Rlo, a, b) > 0 for (a,b) in N_ab minus the core                              [2D]
   (L3)+(L5): for R >= Rlo every non-positive value of G(R,.,.) on N_ab lies in the core, where
   G(R,.,.) is strictly convex by (L4).  (A Hessian bound on all of N_ab needs ~10^5 boxes of width
   1e-4 because of interval dependency; the core + (L5) split avoids it.)
   Interval B&B, machine Interval arithmetic (outward rounded); rational box edges converted with
   N[Interval[...]].  N lies inside the domain (a*+b*+2 rho < 2, a*-rho > Rhi-1): checked exactly.
   Exit 1 on failure; last line "CERTIFICATE OK". *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "10lib-n6.wl"}]];
fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];
Off[General::munfl];

Rlo = 1798867827575/10^12; Rhi = Rlo + 1/1000;
ast = 9354854282012051/10^16; bst = 10105813367281855/10^16;
rho = 1/40; w1 = 1/20; rc = 1/1280;   (* = rho/32: dyadic in the B&B split grid of N_ab *)
gate["N inside domain", ast + bst + 2 rho < 2 && Min[ast, bst] - rho > Rhi - 1];

(* symbolic expressions; on N every radicand is > 0 (domain interior), so plain Sqrt is exact *)
Vs = n6V[a, b]; T2s = n6T2[R, b]; Xs = n6X[R, a, w];
c2s = n6circR2[Vs, T2s, Xs];
acute = {(T2s - Vs) . (Xs - Vs), (Vs - T2s) . (Xs - T2s), (Vs - Xs) . (T2s - Xs)};
dws = D[c2s, w];
Gs = (c2s /. w -> 0) - 1;
GR = D[Gs, R]; Gaa = D[Gs, a, a]; Gab = D[Gs, a, b]; Gbb = D[Gs, b, b];

f4 = Function[{R, a, b, w}, Evaluate[#]] &;
f3 = Function[{R, a, b}, Evaluate[#]] &;
mk4[e_] := With[{f = f4[e]}, Function[box, ivMin[f @@ (N[Interval[#]] & /@ box)] > 0]];
mk3[e_] := With[{f = f3[e]}, Function[box, ivMin[f @@ (N[Interval[#]] & /@ box)] > 0]];
mkDet = With[{fa = f3[Gaa], fb = f3[Gbb], fc = f3[Gab]},
   Function[box, With[{iv = N[Interval[#]] & /@ box},
     With[{A = fa @@ iv, B = fb @@ iv, C = fc @@ iv}, ivMin[A] > 0 && ivMin[A B - C^2] > 0]]]];

N4 = {{Rlo, Rhi}, {ast - rho, ast + rho}, {bst - rho, bst + rho}, {0, w1}};
N3 = Most[N4];
sc4 = #[[2]] - #[[1]] & /@ N4; sc3 = Most[sc4];

run[name_, pred_, box_, sc_] := (n6boxes = 0;
   Module[{t, r}, {t, r} = AbsoluteTiming[n6prove[pred, box, sc, 40]];
    Print["  ", name, ": boxes ", n6boxes, ", ", Round[t, 0.1], " s"]; gate[name, r]]);

run["L1a acute at V", mk4[acute[[1]]], N4, sc4];
run["L1b acute at T2", mk4[acute[[2]]], N4, sc4];
run["L1c acute at X", mk4[acute[[3]]], N4, sc4];
run["L2 dc2/dw > 0", mk4[dws], N4, sc4];
run["L3 dG/dR > 0", mk3[GR], N3, sc3];
Ncore = {{Rlo, Rhi}, {ast - rc, ast + rc}, {bst - rc, bst + rc}};
run["L4 Hessian_(a,b) G positive definite on the core", mkDet, Ncore, #[[2]] - #[[1]] & /@ Ncore];
G0 = Function[{a, b}, Evaluate[Gs /. R -> Rlo]];
G0a = Function[{a, b}, Evaluate[D[Gs, a] /. R -> Rlo]];
G0b = Function[{a, b}, Evaluate[D[Gs, b] /. R -> Rlo]];
inCoreQ[{{a1_, a2_}, {b1_, b2_}}] := a1 >= ast - rc && a2 <= ast + rc && b1 >= bst - rc && b2 <= bst + rc;
(* mean-value form, all in Interval arithmetic: G(x) in G(m) + grad G(box) . (box - m)  (G is smooth
   on N: every radicand > 0 there).  The naive enclosure is kept as a fallback disjunct. *)
predL5 = Function[box, If[inCoreQ[box], "skip",
    Module[{iv = N[Interval[#]] & /@ box, m = N[Interval[{#, #}]] & /@ (Mean /@ box)},
     ivMin[G0 @@ m + (G0a @@ iv) (iv[[1]] - m[[1]]) + (G0b @@ iv) (iv[[2]] - m[[2]])] > 0 ||
      ivMin[G0 @@ iv] > 0]]];
run["L5 G(Rlo,.,.) > 0 on N_ab minus the core", predL5, Rest[N3], {1, 1}];

(* negative control: G itself is NOT positive on N3 (it vanishes at the optimum, < 0 for R < R6) *)
n6boxes = 0;
gate["C0 control (G > 0 on N3 is not certified)", ! n6prove[mk3[Gs], N3, sc3, 10]];
Print["CERTIFICATE OK"];
