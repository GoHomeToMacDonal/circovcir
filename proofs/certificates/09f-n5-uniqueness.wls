#!/usr/bin/env wolframscript
(* Certificate 09f for proofs/09-n5-independent.md §10 (equality case R = R5: uniqueness + mirror symmetry).
   The equality argument re-uses 09a/09b(B1,B2,B4b)/09d/09e, whose domains all contain R5 (gate U0).
   New facts needed here:
     (U0) R5 in (R5lo, R5lo + 10^-6) with R5lo = 1641004/10^6, the common lower end of 09b/09d/09e
          (09a uses [1641/1000, 1643/1000])                                                   [exact]
     (U1) d^2/dd^2 gap(R,d) < 0 on [R5lo, R5lo+10^-6] x [d1,d2], d1 = 93/100, d2 = 975/1000
          => gap(R5, .) strictly concave on [d1,d2]                                           [interval B&B]
     (U2) dstar (root of the 09c d-eliminant factor, minimal polynomial in proofs/09 §9) lies in (d1,d2) and
          |T - X_A|^2 = 4 exactly at (R5, dstar)  => gap(R5, dstar) = 0 (equivalence via 09b B4b)        [exact]
     (U3) the forced configuration of §10 (c1 = (0,dstar); c3 = right vertex of Lens((0,-R5),(0,dstar-1));
          X_A = A(E(0,0)) = reflection of (0,-R5) in line O c3; c2 = mid(T, X_A); c4, c5 mirrors) satisfies
          |c3 - X_A| = 1, |c2 - T| = |c2 - X_A| = 1, and is invariant under x -> -x;
          it coincides with the configuration certified by 09c (exact_config.m) as a set       [exact]
     (U4) acute triangle P,Q,X_A (09d D4 at the window point (R5,dstar,0,0)) re-checked exactly here
   Prerequisite: run 09c first (it writes experiments/2026-10-10-n5-independent/out/exact_config.m, git-ignored).
     (C0) control: the interval prover refuses the false claim gap'' > 0 on the same box.
   Exit 1 on failure; last line "CERTIFICATE OK". *)

fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];

octic[t_] := 625 t^8 - 800 t^7 + 22 t^6 - 1776 t^5 + 1665 t^4 + 1360 t^3 - 3480 t^2 + 2112 t + 1296;
dpoly[x_] := 1875 x^8 - 11800 x^7 + 28194 x^6 - 21608 x^5 - 29345 x^4 + 76984 x^3 - 66608 x^2 + 25344 x - 3072;
R5lo = 1641004/1000000; R5hi = R5lo + 1/1000000; d1 = 93/100; d2 = 975/1000;

(* U0 *)
gate["U0 octic has exactly one root in (R5lo, R5lo+10^-6)",
  CountRoots[octic[t], {t, R5lo, R5hi}] == 1 && octic[R5lo] octic[R5hi] < 0];
R5 = Root[octic[#] &, Select[Range[8], Abs[N[Root[octic[#] &, #]] - 1.641] < 10^-3 &][[1]]];
gate["U0b R5 is that root", R5lo < R5 < R5hi];

(* U1: strict concavity in d *)
psiT[R_, d_] := Pi - ArcCos[(R^2 + d^2 - 1)/(2 d R)];
psi3[R_, d_] := ArcTan[2 Sqrt[1 - ((R + d - 1)/2)^2]/(R + 1 - d)];
gapF[R_, d_] := 2 ArcSin[1/R] + 2 psi3[R, d] - psiT[R, d];
g2F[R_, d_] = D[gapF[RR, dd], {dd, 2}] /. {RR -> R, dd -> d};
proveNeg[f_, {r0_, r1_}, {x0_, x1_}, depth_] := Module[{v = N[f[Interval[{r0, r1}], Interval[{x0, x1}]], 25]},
  Which[Max[v] < 0, True, depth == 0, (Print["  stuck at ", N[{r0, r1, x0, x1}]]; False),
   True, Module[{xm = (x0 + x1)/2},
     proveNeg[f, {r0, r1}, {x0, xm}, depth - 1] && proveNeg[f, {r0, r1}, {xm, x1}, depth - 1]]]];
gate["U1 gap_dd < 0 on [R5lo,R5lo+1e-6] x [d1,d2]", proveNeg[g2F, {R5lo, R5hi}, {d1, d2}, 8]];
gate["C0 control: prover refuses gap_dd > 0", ! proveNeg[-g2F[#1, #2] &, {R5lo, R5hi}, {d1, d2}, 6]];

(* U2: dstar and gap(R5,dstar) = 0 *)
dstar = Root[dpoly[#] &, Select[Range[8], Abs[N[Root[dpoly[#] &, #]] - 0.9531549472491301] < 10^-10 &][[1]]];
gate["U2a dstar in (d1,d2), unique dpoly root there", d1 < dstar < d2 && CountRoots[dpoly[x], {x, d1, d2}] == 1];
Module[{a, h, c1, c3, c4, XA, yT, T, c2, c5, mine, ref, refR, key},
  a = Sqrt[1 - ((R5 + dstar - 1)/2)^2]; h = (dstar - 1 - R5)/2;
  c1 = {0, dstar}; c3 = {a, h}; c4 = {-a, h};
  XA = 2 (c3 . {0, -R5}) c3/(c3 . c3) - {0, -R5};
  yT = (R5^2 + dstar^2 - 1)/(2 dstar); T = {Sqrt[R5^2 - yT^2], yT};
  gate["U2b |T - X_A|^2 = 4 exactly at (R5,dstar)", RootReduce[(T - XA) . (T - XA) - 4] === 0];
  Print["  gap(R5,dstar) numerically: ", Quiet[N[gapF[R5, dstar], 30]]];
  (* U3 *)
  c2 = (T + XA)/2; c5 = {-c2[[1]], c2[[2]]};
  gate["U3a c3 is a lens vertex: |c3-P| = |c3-Q| = 1",
    RootReduce[c3 . c3 - 2 c3 . {0, -R5} + R5^2 - 1] === 0 && RootReduce[(c3 - {0, dstar - 1}) . (c3 - {0, dstar - 1}) - 1] === 0];
  gate["U3b |c3 - X_A| = 1, |X_A| = R5", RootReduce[(c3 - XA) . (c3 - XA) - 1] === 0 && RootReduce[XA . XA - R5^2] === 0];
  gate["U3c |c2 - T| = |c2 - X_A| = 1", RootReduce[(c2 - T) . (c2 - T) - 1] === 0 && RootReduce[(c2 - XA) . (c2 - XA) - 1] === 0];
  Module[{P = {0, -R5}, Q = {0, dstar - 1}},
    gate["U4 triangle P, Q, X_A acute (exact)",
      AllTrue[{(Q - P) . (XA - P), (P - Q) . (XA - Q), (P - XA) . (Q - XA)}, RootReduce[#] > 0 &]]];
  mine = RootReduce /@ {c1, c2, c3, c4, c5};
  gate["U3d configuration invariant under x -> -x",
    Sort[N[mine, 30]] == Sort[N[{-#[[1]], #[[2]]} & /@ mine, 30]] &&
    RootReduce[mine[[3, 1]] + mine[[4, 1]]] === 0 && RootReduce[mine[[2, 1]] + mine[[5, 1]]] === 0 && mine[[1, 1]] === 0];
  (* exact_config.m is written by 09c (experiments/*/out/ is git-ignored): run 09c first *)
  With[{file = FileNameJoin[{DirectoryName[$InputFileName], "..", "..", "experiments",
      "2026-10-10-n5-independent", "out", "exact_config.m"}]},
    If[! FileExistsQ[file], fail["U3e needs " <> file <> " -- run 09c-n5-existence.wls first"]];
    {refR, ref} = Get[file]];
  gate["U3e coincides with 09c configuration (exact)",
    RootReduce[refR - R5] === 0 && Length[ref] == 5 &&
    AllTrue[mine, Function[p, AnyTrue[ref, RootReduce[(p - #) . (p - #)] === 0 &]]]];
  Print["  centres ~ ", N[mine, 15]]];

Print["CERTIFICATE OK"];
