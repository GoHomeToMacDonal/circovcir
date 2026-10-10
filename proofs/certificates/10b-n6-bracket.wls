#!/usr/bin/env wolframscript
(* Certificate 10b for proofs/10-n6-half.md: the threshold R6 of lemma H3 lies in (Rlo, Rhi).
   G(R,a,b) := circumradius^2(V, T2, X0) - 1  on  N3 = [Rlo,Rhi] x [a*-rho,a*+rho] x [b*-rho,b*+rho].
   m(R) := min_{(a,b) in Na x Nb} G(R,a,b).
     (B1) G(Rlo, a~, b~) < 0 at one rational point (interval eval)          => m(Rlo) < 0
     (B2) G(Rhi, a, b) > 0 for all (a,b) in Na x Nb   (2D interval B&B)       => m(Rhi) > 0
   With 10c (L3: dG/dR > 0, L4: G strictly convex in (a,b)), m is continuous and strictly increasing,
   so R6 := the unique root of m in (Rlo, Rhi) is well defined, and for R = R6 the minimiser
   (a6, b6) of G(R6, .) is unique.
     (B3) EVIDENCE (not used by the proof): Newton at wp 80 on {G, G_a, G_b} = 0 from the stored
          approximation; reports R6, a6, b6 and that (a6, b6) is interior to the 10c core (radius rc = rho/32).
   Exit 1 on failure; last line "CERTIFICATE OK". *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "10lib-n6.wl"}]];
fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];
Off[General::munfl];

Rlo = 1798867827575/10^12; Rhi = Rlo + 1/1000;
ast = 9354854282012051/10^16; bst = 10105813367281855/10^16;
rho = 1/40;

Gf[R_, a_, b_] := n6circR2[n6V[a, b], n6T2[R, b], n6X0[R, a]] - 1;

(* B1: one interval point evaluation *)
g1 = Gf[N[Interval[{Rlo, Rlo}]], N[Interval[{ast, ast}]], N[Interval[{bst, bst}]]];
Print["  G(Rlo, a~, b~) in ", g1];
gate["B1 G(Rlo,a~,b~) < 0", ivMax[g1] < 0];

(* B2: 2D B&B at R = Rhi *)
pred = Function[box, With[{aI = N[Interval[box[[1]]]], bI = N[Interval[box[[2]]]]},
    ivMin[Gf[N[Interval[{Rhi, Rhi}]], aI, bI]] > 0]];
n6boxes = 0;
{t, r} = AbsoluteTiming[n6prove[pred, {{ast - rho, ast + rho}, {bst - rho, bst + rho}}, {1, 1}, 40]];
Print["  B2: boxes ", n6boxes, ", ", Round[t, 0.1], " s"];
gate["B2 G(Rhi,.,.) > 0 on Na x Nb", r];

(* negative control: G(Rlo,.,.) > 0 must NOT be certifiable *)
n6boxes = 0;
predC = Function[box, With[{aI = N[Interval[box[[1]]]], bI = N[Interval[box[[2]]]]},
    ivMin[Gf[N[Interval[{Rlo, Rlo}]], aI, bI]] > 0]];
gate["C0 control (G(Rlo,.,.) > 0 not certified)",
  ! n6prove[predC, {{ast - rho, ast + rho}, {bst - rho, bst + rho}}, {1, 1}, 14]];

(* B3: evidence -- high-precision critical point *)
Gs = Gf[R, a, b];
sol = FindRoot[{Gs, D[Gs, a], D[Gs, b]},
   {{R, 17988678275775543711457935637452760440966/10^40},
    {a, 9354854282012050973201937283428477342650/10^40},
    {b, 10105813367281855307975567223444460778468/10^40}},
   WorkingPrecision -> 80, AccuracyGoal -> 70, PrecisionGoal -> 70, MaxIterations -> 50];
res = {Gs, D[Gs, a], D[Gs, b]} /. sol;
Print["  R6 = ", N[R /. sol, 45]];
Print["  a6 = ", N[a /. sol, 45]];
Print["  b6 = ", N[b /. sol, 45]];
Print["  residual = ", N[Max[Abs[res]], 5]];
gate["B3 Newton residual < 10^-60", Max[Abs[res]] < 10^-60];
gate["B3 (R6,a6,b6) interior: Rlo < R6 < Rhi, |a6-a~|,|b6-b~| < rc/10 = rho/320 (inside the 10c core)",
  Rlo < (R /. sol) < Rhi && Abs[(a /. sol) - ast] < rho/320 && Abs[(b /. sol) - bst] < rho/320];
Print["CERTIFICATE OK"];
