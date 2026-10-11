#!/usr/bin/env wolframscript
(* Certificate 10h for proofs/10-n6-half.md section 6: rigorous enclosure of R6 and an interval
   covering certificate for the extremal configuration at R = R6 exactly.

   F(R,a,b) := {G, G_a, G_b},  G(R,a,b) := circumradius^2(V, T2, X0) - 1  (same G as 10b/10c).

     (K0) the Krawczyk box X = m +- r (r = 10^-50, m rational) lies in [Rlo,Rhi] x core of 10c   [exact]
     (K1) Krawczyk: K(X) = m - Y F(m) + (I - Y J(X)) (X - m) lies in the interior of X
          => F has exactly one zero xhat = (Rhat, ahat, bhat) in X.                         [interval]
          Hand step (proofs/10 s6): 10c (L3, L4, L5) + 10b => Rhat = R6, (ahat,bhat) = (a6,b6).
     (C1) cover at xhat: centres c1 = (0,a), c2 = (0,-b), c3 = (T1+X0)/2, c4 = circumcentre(V,T2,X0),
          c5, c6 = mirrors of c3, c4 in the y-axis.  Finite candidate theorem (docs/methods.md):
          every candidate point p of (c, Rhat) satisfies min_i |p - c_i| <= 1.  Each candidate is either
            (i) strictly covered: sup |p - c_i|^2 < 1 for some i, over the whole box X, or
            (ii) identified with a tight point t in {T1,X0,T2,V and mirrors} whose owner centres are at
                 distance exactly 1 by construction (identities I1-I4 below), using uniqueness of the
                 circumcentre / the two-point bisector-circle intersection and disjoint enclosures.
     (I1-I4) the construction identities hold symbolically (T1 on dC1 & dCn; |T1 - X0| = 2 & X0 on dCn;
          V on dC1 & dC2; |c4 - V|^2 = |c4 - T2|^2 = |c4 - X0|^2 = G + 1) -- checked with exact
          simplification; at xhat, G = 0 so c4's three owners are at distance exactly 1.
     (C0) negative control: the same machinery at R = Rhat + 10^-40 must FAIL to certify.

   Interval arithmetic: Mathematica Interval with arbitrary-precision endpoints (outward rounded),
   working precision 150 digits.  Exit 1 on failure; last line "CERTIFICATE OK". *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "10lib-n6.wl"}]];
fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];
Off[General::munfl];

wp = 150;
Rlo = 1798867827575/10^12; Rhi = Rlo + 1/1000;
ast = 9354854282012051/10^16; bst = 10105813367281855/10^16; rc = 1/1280;

Gf[R_, a_, b_] := n6circR2[n6V[a, b], n6T2[R, b], n6X0[R, a]] - 1;
vars = {R, a, b};
Gs = Gf[R, a, b];
Fs = {Gs, D[Gs, a], D[Gs, b]};
Js = D[Fs, {vars}];

(* centre of the box: Newton at wp 200 (evidence only -- the proof uses K1, not this residual) *)
sol = FindRoot[Fs, Transpose[{vars,
     {17988678275775543711457935637452760440966/10^40, 9354854282012050973201937283428477342650/10^40,
      10105813367281855307975567223444460778468/10^40}}],
   WorkingPrecision -> 200, AccuracyGoal -> 180, PrecisionGoal -> 180, MaxIterations -> 100];
m = Rationalize[N[vars /. sol, 90], 10^-85];
r = 10^-50;

(* K0 *)
gate["K0 X inside [Rlo,Rhi] x core(10c)",
  Rlo < m[[1]] - r && m[[1]] + r < Rhi &&
   ast - rc < m[[2]] - r && m[[2]] + r < ast + rc && bst - rc < m[[3]] - r && m[[3]] + r < bst + rc];

iv[x_] := N[Interval[{x, x}], wp];
ivbox[x_] := N[Interval[{x - r, x + r}], wp];
X = ivbox /@ m;
subX = Thread[vars -> X];
subM = Thread[vars -> (iv /@ m)];

(* K1 Krawczyk *)
Fm = Fs /. subM;
JX = Js /. subX;
(* Y: any fixed matrix keeps K1 sound; take an approximate inverse of J at m (numeric, wp 200) *)
Y = Rationalize[Inverse[Js /. Thread[vars -> N[m, 200]]], 10^-55];
Kx = (iv /@ m) - Y . Fm + (IdentityMatrix[3] - Y . JX) . (X - (iv /@ m));
Print["  |F(m)| <= ", N[Max[Abs[Max /@ Fm], Abs[Min /@ Fm]], 5]];
Print["  K widths ", N[(Max[#] - Min[#]) & /@ Kx, 5], " vs 2r = ", N[2 r, 3]];
gate["K1 Krawczyk K(X) in int X",
  And @@ Table[Min[Kx[[i]]] > m[[i]] - r && Max[Kx[[i]]] < m[[i]] + r, {i, 3}]];
(* negative control: a box of the same radius centred 3r away from m must not pass the test *)
With[{ms = m + {3 r, 0, 0}}, Module[{Xs = ivbox /@ ms, Ks},
   Ks = (iv /@ ms) - Y . (Fs /. Thread[vars -> (iv /@ ms)]) +
     (IdentityMatrix[3] - Y . (Js /. Thread[vars -> Xs])) . (Xs - (iv /@ ms));
   gate["K1c control (shifted box not certified)",
    ! (And @@ Table[Min[Ks[[i]]] > ms[[i]] - r && Max[Ks[[i]]] < ms[[i]] + r, {i, 3}])]]];
(* printed enclosure: directed decimal rounding of the exact rational endpoints *)
dec[x_, k_, f_] := f[x 10^k]/10^k;
Print["  R6 in [", N[dec[m[[1]] - r, 52, Floor], 53], ", ", N[dec[m[[1]] + r, 52, Ceiling], 53], "]"];
gate["K2 printed decimal R6 enclosure is outward",
  dec[m[[1]] - r, 52, Floor] <= m[[1]] - r && m[[1]] + r <= dec[m[[1]] + r, 52, Ceiling]];
Print["  a6 = ", N[m[[2]], 50], " +- 1e-50;  b6 = ", N[m[[3]], 50], " +- 1e-50"];

(* I1-I4 exact construction identities (symbolic, for R > 1 and points real) *)
T1s = n6T1[R, a]; T2s = n6T2[R, b]; Vs = n6V[a, b]; X0s = n6X0[R, a];
asm = R > 1 && 0 < a < 2 && 0 < b < 2 && R^2 - n6y1[R, a]^2 > 0 && R^2 - n6y2[R, b]^2 > 0 && a + b < 2;
zeroQs[e_] := TrueQ[FullSimplify[e == 0, asm]];
gate["I1 |T1|^2 = R^2, |T1 - c1|^2 = 1, |T2|^2 = R^2, |T2 - c2|^2 = 1",
  zeroQs[n6sq[T1s] - R^2] && zeroQs[n6sq[T1s - {0, a}] - 1] &&
   zeroQs[n6sq[T2s] - R^2] && zeroQs[n6sq[T2s - {0, -b}] - 1]];
gate["I2 |X0|^2 = R^2, |X0 - T1|^2 = 4", zeroQs[n6sq[X0s] - R^2] && zeroQs[n6sq[X0s - T1s] - 4]];
gate["I3 |V - c1|^2 = |V - c2|^2 = 1", zeroQs[n6sq[Vs - {0, a}] - 1] && zeroQs[n6sq[Vs - {0, -b}] - 1]];
(* I4: c4 = circumcentre(V,T2,X0) is equidistant with squared distance = circR2 (generic algebra,
   checked on free symbols so it is the plain circumcentre identity) *)
ccen[P_, Q_, S_] := Module[{d = 2 (P[[1]] (Q[[2]] - S[[2]]) + Q[[1]] (S[[2]] - P[[2]]) + S[[1]] (P[[2]] - Q[[2]]))},
   {(n6sq[P] (Q[[2]] - S[[2]]) + n6sq[Q] (S[[2]] - P[[2]]) + n6sq[S] (P[[2]] - Q[[2]]))/d,
    (n6sq[P] (S[[1]] - Q[[1]]) + n6sq[Q] (P[[1]] - S[[1]]) + n6sq[S] (Q[[1]] - P[[1]]))/d}];
With[{P = {p1, p2}, Q = {q1, q2}, S = {s1, s2}},
  gate["I4 circumcentre identity |cc - P|^2 = |cc - Q|^2 = |cc - S|^2 = circR2(P,Q,S)",
   And @@ (TrueQ[Together[n6sq[ccen[P, Q, S] - #] - n6circR2[P, Q, S]] == 0] & /@ {P, Q, S})]];

(* ---- C1: interval cover at xhat ---- *)
mir[p_] := {-p[[1]], p[[2]]};
conf[sub_] := Module[{T1 = T1s /. sub, T2 = T2s /. sub, V = Vs /. sub, X0 = X0s /. sub, c3, c4},
   c3 = (T1 + X0)/2; c4 = ccen[V, T2, X0];
   <|"c" -> {{0, a}, {0, -b}, c3, c4, mir[c3], mir[c4]} /. sub, "R" -> (R /. sub),
     "tight" -> {{T1, {1, 3}, True}, {X0, {3, 4}, True}, {T2, {2, 4}, True}, {V, {1, 2, 4}, False},
       {mir[T1], {1, 5}, True}, {mir[X0], {5, 6}, True}, {mir[T2], {2, 6}, True}, {mir[V], {1, 2, 6}, False}}|>];
   (* {point, owner centres (distance exactly 1 by I1-I4), lies exactly on dK (I1, I2)} *)

disjQ[p_, q_] := Or @@ MapThread[IntervalIntersection[#1, #2] === Interval[] &, {p, q}];
supCoveredQ[p_, c_] := AnyTrue[c, Max[n6sq[p - #]] < 1 &];

(* returns {nCandidates, nStrict, nIdentified, failures} *)
certifyCover[cf_] := Module[{c = cf["c"], RR = cf["R"], tight = cf["tight"], cands = {}, nS = 0, nI = 0, bad = {}},
   (* (T) circumcentres of triples, kept unless certainly outside K *)
   Do[Module[{p = ccen @@ c[[s]]}, If[Min[n6sq[p]] <= Max[RR^2], AppendTo[cands, {"T", s, {p}}]]],
    {s, Subsets[Range[6], {3}]}];
   (* (B) bisector / circle: both points as a pair *)
   Do[Module[{u = c[[s[[2]]]] - c[[s[[1]]]], l2, f, h2, e},
      l2 = n6sq[u]; f = u (n6sq[c[[s[[2]]]]] - n6sq[c[[s[[1]]]]])/(2 l2); h2 = RR^2 - n6sq[f];
      Which[Max[h2] < 0, Null,
       Min[h2] > 0, (e = {-u[[2]], u[[1]]}/Sqrt[l2]; AppendTo[cands, {"B", s, {f + Sqrt[h2] e, f - Sqrt[h2] e}}]),
       True, AppendTo[bad, {"B-degenerate", s}]]],
    {s, Subsets[Range[6], {2}]}];
   (* (A) antipodes and (R,0) *)
   Do[AppendTo[cands, {"A", {i}, {-RR c[[i]]/Sqrt[n6sq[c[[i]]]]}}], {i, 6}];
   AppendTo[cands, {"A", {}, {{RR, 0 RR}}}];
   (* decide *)
   Do[Module[{kind = cd[[1]], s = cd[[2]], pts = cd[[3]], hits},
      Do[Module[{p = pts[[k]]},
         If[supCoveredQ[p, c], nS++,
          (* identification with a tight point owned by (a superset of) s *)
          hits = Select[tight, ! disjQ[p, #[[1]]] && SubsetQ[#[[2]], s] &];
          If[Length[hits] == 1 &&
            Which[kind === "T", True,
             kind === "B", hits[[1, 3]] && disjQ[pts[[3 - k]], hits[[1, 1]]],   (* the other root is a different point *)
             True, False],
           nI++, AppendTo[bad, {kind, s, k}]]]], {k, Length[pts]}]], {cd, cands}];
   {Total[Length[#[[3]]] & /@ cands], nS, nI, bad}];

res = certifyCover[conf[subX]];
Print["  candidates ", res[[1]], ": strict ", res[[2]], ", identified tight ", res[[3]], ", undecided ", res[[4]]];
gate["C1 every candidate covered at xhat (strict or identified tight)", res[[4]] === {} && res[[2]] + res[[3]] == res[[1]]];
gate["C1' exactly 8 tight identifications", res[[3]] == 8];

(* C0 negative control: the same centres (box X) with K = D(0, R + 10^-40) must not certify *)
cf0 = conf[subX]; cf0["R"] = cf0["R"] + N[Interval[{10^-40, 10^-40}], wp];
res0 = certifyCover[cf0];
Print["  control: undecided ", Length[res0[[4]]]];
gate["C0 control (radius + 1e-40 not certified)", res0[[4]] =!= {}];

Print["CERTIFICATE OK"];
