(* Polynomial systems for the n=6 critical point (R6, a6, b6), see proofs/10-n6-half.md section 3.
   S = R^2. Aux: x1 = Sqrt[S - y1^2], x2 = Sqrt[S - y2^2], xv = Sqrt[1 - s^2], r1 = Sqrt[S - 1].
   Two formulations:
   (H) "hraw": circumradius^2(V,T2,X0) = 1 written as |u|^2|v|^2|w|^2 - 4 cross^2 = 0, plus its
       total a- and b-derivatives (critical point of G in (a,b)).
   (L) "lagrange": explicit centre c4 = (p,q) with |c4-P|^2 = 1 for P in {V,T2,X0}; critical
       point of S on that variety <=> 7x8 Jacobian w.r.t. (a,b,p,q,x1,x2,xv,r1) is rank deficient,
       encoded with a multiplier vector lam (lam . J = 0, lam normalised by an affine chart). *)
y1 = (S + a^2 - 1)/(2 a); y2 = -(S + b^2 - 1)/(2 b); s = (a + b)/2;
T1 = {x1, y1}; T2 = {x2, y2}; V = {xv, (a - b)/2};
c2 = 1 - 2/S; s2 = 2 r1/S;
X0 = {{c2, s2}, {-s2, c2}} . T1;
defs = {x1^2 - (S - y1^2), x2^2 - (S - y2^2), xv^2 - (1 - s^2), r1^2 - (S - 1)};
aux = {x1, x2, xv, r1};
numer[e_] := Numerator[Together[e]];

(* (H) *)
uu = T2 - V; vv = X0 - V; ww = X0 - T2;
cr = uu[[1]] vv[[2]] - uu[[2]] vv[[1]];
Hraw = (uu . uu) (vv . vv) (ww . ww) - 4 cr^2;
dAux[t_] := Module[{J = D[defs, {aux}], g = D[defs, t]}, -Inverse[J] . g];
tot[expr_, t_] := D[expr, t] + D[expr, {aux}] . dAux[t];
eqsH = numer /@ Join[defs, {Hraw, tot[Hraw, a], tot[Hraw, b]}];
varsH = {a, b, x1, x2, xv, r1};

(* (L) *)
cc = {p, q};
gL = {(cc - V) . (cc - V) - 1, (cc - T2) . (cc - T2) - 1, (cc - X0) . (cc - X0) - 1};
consL = numer /@ Join[defs, gL];
xL = {a, b, p, q, x1, x2, xv, r1};
lam = Array[l, Length[consL]];
JL = D[consL, {xL}];
eqsL = Join[consL, lam . JL, {lam[[-1]] - 1}];
varsL = Join[xL, lam];

(* numeric critical point at high precision (2200 digits) from the earlier run *)
critFile = FileNameJoin[{DirectoryName[$InputFileName], "..", "2026-10-10-n6-proof", "out", "crit2200.m"}];
