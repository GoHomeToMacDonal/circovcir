#!/usr/bin/env wolframscript
(* Reduced right-half problem for n=5 (mirror-symmetric gluing).
   C1 = D((0,d),1). T = right point of dCn ∩ dC1. D3 passes through (0,-R) and (0,d-1);
   X_A = second point of dD3 ∩ dCn (reflection of (0,-R) in line O-c3).
   D2 must contain T and X_A  <=>  |T - X_A| <= 2.
   R* = max R s.t. min_d |T-X_A|^2 <= 4. Eliminate d exactly -> polynomial in R. *)
yT = (R^2 + d^2 - 1)/(2 d);
h = (d - 1 - R)/2; c3 = {A, h};          (* A = Sqrt[1-((R+d-1)/2)^2] *)
v = {0, -R}; XA = 2 (c3 . v) c3/(c3 . c3) - v;
f = (X - XA[[1]])^2 + (yT - XA[[2]])^2;   (* X = Sqrt[R^2 - yT^2] *)
rX = X^2 - (R^2 - yT^2); rA = A^2 - (1 - ((R + d - 1)/2)^2);
(* implicit derivatives dX/dd, dA/dd *)
dX = -D[rX, d]/D[rX, X]; dA = -D[rA, d]/D[rA, A];
df = D[f, d] + D[f, X] dX + D[f, A] dA;
eqs = Numerator[Together[#]] & /@ {f - 4, df, rX, rA};
gb = TimeConstrained[GroebnerBasis[eqs, {R}, {X, A, d}, MonomialOrder -> EliminationOrder], 1500];
octic = 625 t^8 - 800 t^7 + 22 t^6 - 1776 t^5 + 1665 t^4 + 1360 t^3 - 3480 t^2 + 2112 t + 1296;
Print["GB size: ", Length[gb]];
fac = FactorList[First[gb] /. R -> t];
Print["factors (deg): ", {Exponent[#[[1]], t], #[[2]]} & /@ fac];
Print["octic among factors: ", MemberQ[Expand[First /@ fac], Expand[octic]] || MemberQ[Expand[-First /@ fac], Expand[octic]]];
Print["octic root: ", N[Root[octic /. t -> #, 2] &, 30], "  ", N[t /. NSolve[octic == 0 && 1.6 < t < 1.7, t, WorkingPrecision -> 40], 35]];
Put[gb, FileNameJoin[{DirectoryName[$InputFileName], "out", "reduced_gb.m"}]];
