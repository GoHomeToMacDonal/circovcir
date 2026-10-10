#!/usr/bin/env wolframscript
(* Certificate 10d for proofs/10-n6-half.md (global sweep of lemma H3):
   For every (R,a,b,w) with R in [Rlo,Rhi], a,b >= R-1, a+b <= 2, w in [0, 2 alpha(R)],
   OUTSIDE the local window  N = [a*-rho, a*+rho] x [b*-rho, b*+rho] x [0, w1]  (in (a,b,w)),
   no closed unit disk contains the three points V, T2, X(w).
   Interval B&B (machine Interval arithmetic, outward rounded) with the fits criterion of
   10lib-n6.wl.  Boxes are skipped only when (i) they lie outside the domain, or (ii) they lie
   inside N (handled by certificate 10c).  Exit 1 on failure; last line "CERTIFICATE OK". *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "10lib-n6.wl"}]];
fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];
Off[General::munfl];

Rlo = 1798867827575/10^12; Rhi = Rlo + 1/1000;
amin = Rlo - 1; amax = 3 - Rlo;
ast = 9354854282012051/10^16; bst = 10105813367281855/10^16;   (* rational approximations of a*, b* *)
rho = 1/40; w1 = 1/20;   (* a*+b*+2 rho < 2: N lies inside the domain *)
wbar = 1179/1000;   (* >= 2 alpha(Rlo) = 1.178903..., checked below *)
gate["wbar >= 2 alpha(Rlo)", N[2 ArcSin[1/Rlo], 30] < wbar];

inNQ[{{r1_, r2_}, {a1_, a2_}, {b1_, b2_}, {w1l_, w2_}}] :=
  a1 >= ast - rho && a2 <= ast + rho && b1 >= bst - rho && b2 <= bst + rho && w2 <= w1;
outQ[{{r1_, r2_}, {a1_, a2_}, {b1_, b2_}, {w1l_, w2_}}] :=
  a2 < r1 - 1 || b2 < r1 - 1 || a1 + b1 > 2 || w1l > ivMax[2 ArcSin[1/Interval[{r1, r1}]]];

box0 = {{Rlo, Rhi}, {amin, amax}, {amin, amax}, {0, wbar}};
scale = {Rhi - Rlo, amax - amin, amax - amin, wbar};
(* box edges stay exact rationals (exact N-test); they become machine numbers only inside Interval *)
pred2 = Function[box, If[outQ[box] || inNQ[box], "skip",
    With[{RI = N[Interval[box[[1]]]], aI = N[Interval[box[[2]]]], bI = N[Interval[box[[3]]]], wI = N[Interval[box[[4]]]]},
     n6fitsFalseQ[{n6V[aI, bI], n6T2[RI, bI], n6X[RI, aI, wI]}]]]];

n6boxes = 0;
{t, r} = AbsoluteTiming[n6prove[pred2, box0, scale, 60]];
Print["  H3 sweep: boxes ", n6boxes, ", ", Round[t, 0.1], " s"];
If[! r, Print["  first stuck box: ", N[First[n6stuck], 12]]];
gate["H3 sweep outside N", r];

(* negative control: at R slightly BELOW R6 near the optimum the triple fits, so a sweep that does
   not exclude N must fail there *)
n6boxes = 0; n6stuck = {};
ctrl = Function[box, With[{RI = N[Interval[box[[1]]]], aI = N[Interval[box[[2]]]], bI = N[Interval[box[[3]]]], wI = N[Interval[box[[4]]]]},
    n6fitsFalseQ[{n6V[aI, bI], n6T2[RI, bI], n6X[RI, aI, wI]}]]];
gate["C0 control (window around optimum at R = R6 - 10^-4 is NOT certified)",
  ! n6prove[ctrl, {{Rlo - 1/10^4, Rlo - 1/10^4}, {ast - 1/10^3, ast + 1/10^3}, {bst - 1/10^3, bst + 1/10^3}, {0, 1/10^3}},
     {1, 1, 1, 1}, 16]];
Print["CERTIFICATE OK"];
