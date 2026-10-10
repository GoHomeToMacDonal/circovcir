#!/usr/bin/env wolframscript
(* Certificate 09c for proofs/09-n5-independent.md, existence (E): 5 unit disks cover D(0,R5) exactly.
   Construction (proofs/09 §2-§3, reduced symmetric optimum):
     dstar  = exact algebraic root (near 0.95315) of the d-eliminant of the system
           |T - X_A|^2 = 4,  d/dd |T - X_A|^2 = 0   (same polynomialisation as 09b)
     c1 = (0,dstar);  c3 = (a,h), a = Sqrt[1-((R5+dstar-1)/2)^2], h = (dstar-1-R5)/2;  c4 = (-a,h)
     X_A = reflection of (0,-R5) in the line O-c3;  T = right point of dD(0,R5) ∩ dC1;
     c2 = (T + X_A)/2;  c5 = mirror of c2.
   Gates:
     (E1) (R5, dstar) satisfies the polynomial system exactly (RootReduce)            [exact]
     (E2) |c2 - T| = 1 exactly                                                    [exact]
     (E3) ExactCoverQ[{c1..c5}, R5] (CirCovCir`, exact candidate-point theorem)   [exact]
   Exit 1 on failure; last line "CERTIFICATE OK". *)

PrependTo[$Path, FileNameJoin[{DirectoryName[$InputFileName], "..", "..", "wl"}]];
Needs["CirCovCir`"];
fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];

octic[t_] := 625 t^8 - 800 t^7 + 22 t^6 - 1776 t^5 + 1665 t^4 + 1360 t^3 - 3480 t^2 + 2112 t + 1296;
R5 = Root[octic[#] &, Select[Range[8], Abs[N[Root[octic[#] &, #]] - 1.641] < 10^-3 &][[1]]];
Print["R5 = ", N[R5, 25]];

sys[R_, d_] := Module[{yT, h, c3, v, XA, f, rX, rA, dX, dA, df},
  yT = (R^2 + d^2 - 1)/(2 d); h = (d - 1 - R)/2; c3 = {Aa, h}; v = {0, -R};
  XA = 2 (c3 . v) c3/(c3 . c3) - v;
  f = (X - XA[[1]])^2 + (yT - XA[[2]])^2;
  rX = X^2 - (R^2 - yT^2); rA = Aa^2 - (1 - ((R + d - 1)/2)^2);
  dX = -D[rX, d]/D[rX, X]; dA = -D[rA, d]/D[rA, Aa];
  df = D[f, d] + D[f, X] dX + D[f, Aa] dA;
  Numerator[Together[#]] & /@ {f - 4, df, rX, rA}];

eqs = sys[R, d];
gbd = TimeConstrained[GroebnerBasis[eqs, {d}, {X, Aa, R}, MonomialOrder -> EliminationOrder], 1500];
If[! ListQ[gbd] || Length[gbd] != 1, fail["d-elimination"]];
fac = Select[First /@ FactorList[First[gbd]], Exponent[#, d] > 0 &];
dstar = Catch[Do[Do[If[Abs[N[Root[Function[d, Evaluate[p]], k], 30] - 0.9531549472491301] < 10^-12,
        Throw[Root[Function[d, Evaluate[p]], k]]], {k, Exponent[p, d]}], {p, fac}]; fail["d* not found"]];
Print["d* = ", N[dstar, 25], "  minimal polynomial degree ", Exponent[MinimalPolynomial[dstar, z], z]];

Module[{a, h, c1, c3, c4, XA, yT, T, c2, c5, cs, chk},
  a = Sqrt[1 - ((R5 + dstar - 1)/2)^2]; h = (dstar - 1 - R5)/2;
  c1 = {0, dstar}; c3 = {a, h}; c4 = {-a, h};
  XA = 2 (c3 . {0, -R5}) c3/(c3 . c3) - {0, -R5};
  yT = (R5^2 + dstar^2 - 1)/(2 dstar); T = {Sqrt[R5^2 - yT^2], yT};
  c2 = (T + XA)/2; c5 = {-c2[[1]], c2[[2]]};
  chk = eqs /. {R -> R5, d -> dstar, X -> T[[1]], Aa -> a};
  gate["E1 system holds exactly at (R5,d*)", AllTrue[chk, RootReduce[#] === 0 &]];
  gate["E2 |c2 - T| = 1", RootReduce[(c2 - T) . (c2 - T)] === 1];
  cs = RootReduce /@ {c1, c2, c3, c4, c5};
  Print["centres ~ ", N[cs, 12]];
  Print["  numeric covering radius (wp 40): ", N[CirCovCir`CoveringRadius[cs, R5, WorkingPrecision -> 40], 20]];
  gate["E3 ExactCoverQ[centres, R5]", TimeConstrained[CirCovCir`ExactCoverQ[cs, R5], 3000]];
  Put[{R5, cs}, FileNameJoin[{DirectoryName[$InputFileName], "..", "..", "experiments",
     "2026-10-10-n5-independent", "out", "exact_config.m"}]]];

Print["CERTIFICATE OK"];
