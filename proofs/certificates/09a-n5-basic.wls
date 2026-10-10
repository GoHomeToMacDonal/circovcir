#!/usr/bin/env wolframscript
(* Certificate 09a for proofs/09-n5-independent.md: basic lemmas L1, L2 and the admissible domain.

   Domain convention for all 09x certificates:
     R in RR := [1641/1000, 1643/1000]   (contains (R5, R5 + 1/1000])
     d in DD := [dlo, 1] with dlo = 845/1000
   Gates:
     (G1) the octic has exactly one real root in [1641/1000, 1642/1000] and R5 lies there;  [exact]
     (G2) L1: Sqrt[2] < 1641/1000, so "C1 misses dCn" (=> 8 alpha >= 2 Pi <=> R <= Sqrt2) is impossible; [exact]
     (G3) y_T(R,d) = (R^2+d^2-1)/(2d) is strictly decreasing in d on (0, Sqrt[R^2-1]) and 1 < Sqrt[R^2-1] on RR,
          hence psiT = Pi - ArcCos[y_T/R] is strictly decreasing in d on DD;                [exact Resolve]
     (G4) m = 2 psiT - 6 alpha > 0 at d = 1 for all R in RR (=> m > 0 on DD by G3);         [interval]
     (G5) 2 psiT - 8 alpha > 0 at d = dlo for all R in RR (=> admissible d >= dlo, by G3 and L2); [interval]
     (G6) w := 4 alpha - psiT <= wmax := 9/100 on DD (max at d = 1, by G3);                    [interval]
     (G7) C1 really has corners: R - 1 < dlo (so d + 1 > R on DD)                              [exact]
   alpha = ArcSin[1/R].  Interval gates subdivide RR into 200 pieces (outward-rounded Interval arithmetic).
   Exit code 1 on any failure; last line "CERTIFICATE OK" on success. *)

fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];

octic[t_] := 625 t^8 - 800 t^7 + 22 t^6 - 1776 t^5 + 1665 t^4 + 1360 t^3 - 3480 t^2 + 2112 t + 1296;
Rlo = 1641/1000; Rhi = 1643/1000; dlo = 845/1000; wmax = 9/100;

(* G1 *)
gate["G1 unique octic root in [1641/1000,1642/1000]",
  CountRoots[octic[t], {t, 1641/1000, 1642/1000}] == 1 && octic[1641/1000] octic[1642/1000] < 0];
R5 = t /. FindRoot[octic[t] == 0, {t, 1641/1000}, WorkingPrecision -> 60];
Print["  R5 = ", N[R5, 30]];

(* G2, G7 *)
gate["G2 Sqrt[2] < 1641/1000", Sqrt[2] < 1641/1000];
gate["G7 R - 1 < dlo on RR", Rhi - 1 < dlo];

(* G3 *)
gate["G3 dyT/dd < 0 for 0 < d <= 1, R in RR",
  Resolve[ForAll[{R, d}, Rlo <= R <= Rhi && 0 < d <= 1, D[(R^2 + d^2 - 1)/(2 d), d] < 0], Reals]];

(* interval helpers *)
psiTI[R_, d_] := Pi - ArcCos[(R^2 + d^2 - 1)/(2 d R)];
alI[R_] := ArcSin[1/R];
pieces = Table[Interval[{Rlo + k (Rhi - Rlo)/200, Rlo + (k + 1) (Rhi - Rlo)/200}], {k, 0, 199}];
minOver[f_] := Min[Min /@ (N[f[#], 30] & /@ pieces)];
maxOver[f_] := Max[Max /@ (N[f[#], 30] & /@ pieces)];

(* G4 *)
mlo = minOver[Function[RI, 2 psiTI[RI, 1] - 6 alI[RI]]];
Print["  min m(d=1) over RR >= ", N[mlo, 8]];
gate["G4 m > 0 on DD", mlo > 0];

(* G5 *)
g5 = minOver[Function[RI, 2 psiTI[RI, dlo] - 8 alI[RI]]];
Print["  min (2 psiT - 8 alpha)(d=dlo) >= ", N[g5, 8]];
gate["G5 admissible d >= dlo", g5 > 0];

(* G6 *)
g6 = maxOver[Function[RI, 4 alI[RI] - psiTI[RI, 1]]];
Print["  max w(d=1) <= ", N[g6, 8]];
gate["G6 w <= 9/100", g6 <= wmax];

Print["CERTIFICATE OK"];
