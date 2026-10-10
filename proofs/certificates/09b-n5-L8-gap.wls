#!/usr/bin/env wolframscript
(* Certificate 09b for proofs/09-n5-independent.md, Lemma L8:
     gap(R,d) := 2 ArcSin[1/R] + 2 psi3(R,d) - psiT(R,d) < 0   for all R in (R5, Rhi], d in [dlo, 1],
   psiT = Pi - ArcCos[(R^2+d^2-1)/(2 d R)],  psi3 = ArcTan[(R+1-d)/2, Sqrt[1-((R+d-1)/2)^2]].
   Argument (proofs/09 §6, L8):
     (B1) gap < 0 on [R5lo,Rhi] x ([dlo,d1] ∪ [d2,1])                      [interval B&B]
     (B2) d/dd gap > 0 on [R5lo,Rhi] x {d1},  d/dd gap < 0 on [R5lo,Rhi] x {d2}  [interval B&B]
     (B3) gap(Rhi, d) < 0 on [d1, d2]                                           [interval B&B]
     (B4) every real (R,d) with gap = 0 = d/dd gap is a zero of the eliminant e(R) obtained by
          Groebner elimination of the polynomialised system |T - X_A|^2 = 4, d/dd(...) = 0      [exact]
          (gap=0 <=> |T-X_A|^2=4 and d/dd gap=0 <=> d/dd |T-X_A|^2=0 since |T-X_A| = 2R sin((psiT-2psi3)/2),
           0 < psiT - 2 psi3 < Pi; checked on the domain by gate B4b)
     (B5) e has exactly one real root in [R5lo, Rhi], namely R5                                 [exact]
   Then: if gap(R',d') >= 0 with R' > R5, by B1 d' in [d1,d2]; H(R) := max_{[d1,d2]} gap(R,.) is
   continuous, H(R') >= 0 > H(Rhi) (B3) => H(R'') = 0 for some R'' in [R', Rhi); the maximiser is interior
   by B2, so gap = d/dd gap = 0 there => e(R'') = 0 with R'' > R5, contradicting B5.
   Exit 1 on failure; last line "CERTIFICATE OK". *)

fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];

octic[t_] := 625 t^8 - 800 t^7 + 22 t^6 - 1776 t^5 + 1665 t^4 + 1360 t^3 - 3480 t^2 + 2112 t + 1296;
R5lo = 1641004/1000000; Rhi = 1643/1000; dlo = 845/1000; d1 = 93/100; d2 = 975/1000;
gate["R5 in (R5lo, R5lo + 10^-6)", octic[R5lo] octic[R5lo + 10^-6] < 0];

psiT[R_, d_] := Pi - ArcCos[(R^2 + d^2 - 1)/(2 d R)];
(* psi3 = angle of (a, -(R+1-d)/2) from the bottom direction = ArcTan[2a/(R+1-d)], a = Sqrt[1-((R+d-1)/2)^2] *)
psi3[R_, d_] := ArcTan[2 Sqrt[1 - ((R + d - 1)/2)^2]/(R + 1 - d)];
gapF[R_, d_] := 2 ArcSin[1/R] + 2 psi3[R, d] - psiT[R, d];
dgapF[R_, d_] = D[gapF[RR, dd], dd] /. {RR -> R, dd -> d};

(* sanity: numeric optimum *)
Module[{dstar = dd /. FindMaximum[gapF[N[R5lo, 40], dd], {dd, 95/100}, WorkingPrecision -> 40][[2]]},
  Print["  d* ~ ", N[dstar, 15], "   max_d gap(R5lo,.) = ", N[gapF[R5lo, dstar], 6]]];

(* adaptive interval prover: sign[f] on box {{r0,r1},{x0,x1}} *)
proveNeg[f_, {r0_, r1_}, {x0_, x1_}, depth_] := Module[{v = N[f[Interval[{r0, r1}], Interval[{x0, x1}]], 25]},
  Which[Max[v] < 0, True, depth == 0, (Print["  stuck at ", N[{r0, r1, x0, x1}]]; False),
   True, Module[{rm = (r0 + r1)/2, xm = (x0 + x1)/2},
     And @@ (proveNeg[f, ##, depth - 1] & @@@ {{{r0, rm}, {x0, xm}}, {{rm, r1}, {x0, xm}}, {{r0, rm}, {xm, x1}}, {{rm, r1}, {xm, x1}}})]]];
gate["B1a gap < 0 on [R5lo,Rhi] x [dlo,d1]", proveNeg[gapF, {R5lo, Rhi}, {dlo, d1}, 16]];
gate["B1b gap < 0 on [R5lo,Rhi] x [d2,1]", proveNeg[gapF, {R5lo, Rhi}, {d2, 1}, 16]];
gate["B2a dgap > 0 at d = d1", proveNeg[-dgapF[#1, #2] &, {R5lo, Rhi}, {d1, d1}, 12]];
gate["B2b dgap < 0 at d = d2", proveNeg[dgapF, {R5lo, Rhi}, {d2, d2}, 12]];
gate["B3 gap(Rhi, .) < 0 on [d1,d2]", proveNeg[gapF, {Rhi, Rhi}, {d1, d2}, 16]];
gate["B4b 0 < psiT - 2 psi3 < Pi on domain",
  proveNeg[2 psi3[#1, #2] - psiT[#1, #2] &, {R5lo, Rhi}, {dlo, 1}, 10] &&
  proveNeg[psiT[#1, #2] - 2 psi3[#1, #2] - Pi &, {R5lo, Rhi}, {dlo, 1}, 10]];

(* negative control: the prover must NOT certify gap < 0 at R5lo (< R5) around d*, where gap > 0 *)
gate["C0 control: prover refuses false claim", ! proveNeg[gapF, {R5lo, R5lo}, {d1, d2}, 10]];

(* B4: polynomial elimination (same system as experiments/2026-10-10-n5-independent/reduced.wls) *)
Module[{yT, h, c3, v, XA, f, rX, rA, dX, dA, df, eqs, gb, e},
  yT = (R^2 + d^2 - 1)/(2 d); h = (d - 1 - R)/2; c3 = {Aa, h}; v = {0, -R};
  XA = 2 (c3 . v) c3/(c3 . c3) - v;
  f = (X - XA[[1]])^2 + (yT - XA[[2]])^2;
  rX = X^2 - (R^2 - yT^2); rA = Aa^2 - (1 - ((R + d - 1)/2)^2);
  dX = -D[rX, d]/D[rX, X]; dA = -D[rA, d]/D[rA, Aa];
  df = D[f, d] + D[f, X] dX + D[f, Aa] dA;
  eqs = Numerator[Together[#]] & /@ {f - 4, df, rX, rA};
  gb = TimeConstrained[GroebnerBasis[eqs, {R}, {X, Aa, d}, MonomialOrder -> EliminationOrder], 1500];
  If[! ListQ[gb] || Length[gb] != 1, fail["B4 elimination did not return a single eliminant"]];
  e = First[gb];
  Print["  eliminant degree ", Exponent[e, R], "; factors ", {Exponent[#[[1]], R], #[[2]]} & /@ FactorList[e]];
  gate["B4 octic divides eliminant", PolynomialRemainder[e, octic[R], R] === 0];
  gate["B5 eliminant has exactly one real root in [R5lo, Rhi]", CountRoots[e, {R, R5lo, Rhi}] == 1]];

Print["CERTIFICATE OK"];
