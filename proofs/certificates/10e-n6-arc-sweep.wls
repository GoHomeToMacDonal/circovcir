#!/usr/bin/env wolframscript
(* Certificate 10e: arc-length form of lemma H3 (proofs/10-n6-half.md §3', user formulation
   F = theta1 + theta2 + 2 beta3 + 2 alpha - Pi of experiments/2026-10-11-n6-arc).
   Coordinates are those of 10lib-n6.wl (right half x >= 0).  Dictionary to the user's picture
   (upper half y >= 0, C1 = D((-p,0),1), C2 = D((q,0),1)):  rotate by +90 deg;
     user Q1 <-> T2,  user P12 <-> V,  user Q2 <-> T1,  p <-> b,  q <-> a,
     user "C3 contains Q1,P12" <-> "C4 contains V,T2",
     user "C4 covers the rest, chord <= 2" <-> "C3 contains T1, arc <= 2 alpha",
     user X (end of C3's new arc, F = 0 case) <-> X0 = X(0).
   Connectivity (hand step, proofs/10 §3'): the disk containing V,T2 covers the sub-arc of A_R
   from the end P of the T1-disk's arc to T2; angle(T1,P) <= 2 alpha < angle(T1,T2) (10a F1),
   so X0 lies on that sub-arc.  Hence it suffices to show that V, T2, X0 fit in no unit disk:
   the free parameter w of 10d disappears (3D sweep instead of 4D), and 10c (L1),(L2) are
   replaced by (A0) below.  In the user's terms: no unit disk contains Q1, P12, X  <=>  F < 0.
   Gates:
     (A0) on N3 = [Rlo,Rhi] x N_ab: triangle V, T2, X0 acute (three dot products > 0)  [3D]
          => inside N_ab, "fits" <=> circumradius <= 1 <=> G <= 0  (G as in 10b/10c).
     (S)  for every (R,a,b) in Dom outside N_ab: V, T2, X0 fit in no closed unit disk     [3D]
     (C0) negative control: near the optimum at R = Rlo - 10^-4 the sweep must NOT certify.
   Together with 10b (B1,B2) and 10c (L3,L4,L5) this gives theorem 10 parts 1-2 without 10d.
   Interval B&B, machine Interval arithmetic (outward rounded), rational box edges.
   Exit 1 on failure; last line "CERTIFICATE OK". *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "10lib-n6.wl"}]];
fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];
Off[General::munfl];

Rlo = 1798867827575/10^12; Rhi = Rlo + 1/1000;
amin = Rlo - 1; amax = 3 - Rlo;
ast = 9354854282012051/10^16; bst = 10105813367281855/10^16;   (* same as 10b/10c/10d *)
rho = 1/40;
gate["N_ab inside domain", ast + bst + 2 rho < 2 && Min[ast, bst] - rho > Rhi - 1];

run[name_, pred_, box_, sc_, depth_] := (n6boxes = 0; n6stuck = {};
   Module[{t, r}, {t, r} = AbsoluteTiming[n6prove[pred, box, sc, depth]];
    Print["  ", name, ": boxes ", n6boxes, ", ", Round[t, 0.1], " s"];
    If[! r && n6stuck =!= {}, Print["  first stuck box: ", N[First[n6stuck], 12]]];
    gate[name, r]]);

(* (A0) acuteness at w = 0 on N3 *)
Vs = n6V[a, b]; T2s = n6T2[R, b]; X0s = n6X0[R, a];
acute = {(T2s - Vs) . (X0s - Vs), (Vs - T2s) . (X0s - T2s), (Vs - X0s) . (T2s - X0s)};
fac = Function[{R, a, b}, Evaluate[acute]];
predA = Function[box, With[{v = fac @@ (N[Interval[#]] & /@ box)}, AllTrue[v, ivMin[#] > 0 &]]];
N3 = {{Rlo, Rhi}, {ast - rho, ast + rho}, {bst - rho, bst + rho}};
run["A0 acute triangle V,T2,X0 on N3", predA, N3, #[[2]] - #[[1]] & /@ N3, 40];

(* (S) global sweep outside N_ab *)
inNQ[{{r1_, r2_}, {a1_, a2_}, {b1_, b2_}}] :=
  a1 >= ast - rho && a2 <= ast + rho && b1 >= bst - rho && b2 <= bst + rho;
outQ[{{r1_, r2_}, {a1_, a2_}, {b1_, b2_}}] := a2 < r1 - 1 || b2 < r1 - 1 || a1 + b1 > 2;
tripleFalse[box_] := With[{RI = N[Interval[box[[1]]]], aI = N[Interval[box[[2]]]], bI = N[Interval[box[[3]]]]},
   n6fitsFalseQ[{n6V[aI, bI], n6T2[RI, bI], n6X0[RI, aI]}]];
predS = Function[box, If[outQ[box] || inNQ[box], "skip", tripleFalse[box]]];
box0 = {{Rlo, Rhi}, {amin, amax}, {amin, amax}};
run["S sweep: V,T2,X0 never fit outside N_ab", predS, box0, #[[2]] - #[[1]] & /@ box0, 60];

(* (C0) negative control *)
n6boxes = 0; n6stuck = {};
gate["C0 control (window around optimum at R = Rlo - 10^-4 is NOT certified)",
  ! n6prove[tripleFalse, {{Rlo - 1/10^4, Rlo - 1/10^4}, {ast - 1/10^3, ast + 1/10^3}, {bst - 1/10^3, bst + 1/10^3}},
     {1, 1, 1}, 16]];

(* consistency with the user's F at the optimum (evidence, not a gate on the proof chain):
   F = theta1 + theta2 + 2 beta3 + 2 alpha - Pi vanishes where G = 0, and the circumradius of
   V,T2,X0 equals 1 there *)
With[{R6 = 17988678275775543711457935637452760441/10^37, a6 = 93548542820120509732019372834284773426/10^38,
    b6 = 101058133672818553079755672234444607785/10^38},
  Print["  circumR^2(V,T2,X0) - 1 at (R6,a6,b6): ",
   N[n6circR2[n6V[a6, b6], n6T2[R6, b6], n6X0[R6, a6]] - 1, 10]]];
Print["CERTIFICATE OK"];
