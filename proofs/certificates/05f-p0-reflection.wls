#!/usr/bin/env wolframscript
(* ============================================================================
   Certificate 05f : the reflection convention (proofs/06 P0 ; [FT] section 2, S0).

   Setting.  C_n = D(o, R), o = origin, R > 1 (we use R = R_n > 2).  C_i a closed
   unit disk meeting bd C_n.  By rotation symmetry put its centre on the positive
   y-axis:  o_i = (0, d), d > 0  (d = 0 would force R = 1).
     radical axis of C_i, C_n :   |x-o_i|^2 - 1 = |x|^2 - R^2   <=>   y = h,
                                  h = (d^2 + R^2 - 1)/(2 d)  (> 0) ;
     o sits below the axis (0 < h) ; o_i is on the SAME side iff d <= h
                                  <=>  d^2 <= R^2 - 1  ("opposite" iff d^2 > R^2 - 1) ;
     mirror of o_i in the axis :  o_i' = (0, d'),  d' = 2h - d = (R^2 - 1)/d .

   P0a (reflection keeps the covering).  If d^2 > R^2 - 1 then
            C_i  ∩ C_n  ⊆  C_i' ∩ C_n ,     C_i' = D(o_i', 1).
     Proof (hand; every identity is gated below).
       * Below the axis (y <= h):  |p-o_i'|^2 - |p-o_i|^2 = 2 (d - d') (y - h) <= 0
         because d > d'  (d > sqrt(R^2-1) > d').  So p ∈ C_i  =>  p ∈ C_i'.
       * Above the axis (y >= h):  C_n ∩ {y >= h} is a circular segment = convex
         hull of its arc  A = bd C_n ∩ {y >= h};  C_i' is convex, so it suffices
         that A ⊆ C_i'.  For p = (x,y) on bd C_n:
                |p - o_i'|^2 - 1 = R^2 - 2 d' y + d'^2 - 1 = -2 d' (y - h)
         (the right side vanishes at y = h: the two chord endpoints lie on both
         circles and on the axis, hence are fixed by the mirror and lie on bd C_i').
         With d' > 0 and y >= h this is <= 0.                                 QED
     Hence replacing each such C_i by C_i' (independently: the axis of C_i depends
     only on C_i and C_n) yields a covering in which every boundary-meeting disk
     satisfies the convention, d' = (R^2-1)/d < sqrt(R^2-1).  The disk C_0 ⊆ int C_n
     is never reflected.
     Gate Q-a additionally checks the whole inclusion by quantifier elimination:
     for R > 1, d > 0 it holds for ALL (x,y) iff d >= sqrt(R^2-1).

   P0b (same side  =>  alpha_i <= Pi).  Let d^2 <= R^2 - 1.
       * D_i ⊆ C_i: a point x of D_i is covered by some C_j, and |x-o_i| <= |x-o_j| <= 1.
         So the arc q_i q_{i+1} of D_i lies in  C_i ∩ bd C_n = bd C_n ∩ {y >= h}
         (by the identity  |p-o_i|^2 - 1 = -2 d (y - h)  on bd C_n).
       * h >= d, so every arc point p satisfies  p_y - d >= 0 : seen from o_i, all
         directions to the arc lie in the closed upper half-plane.
       * o_i ∈ int C_n (d <= sqrt(R^2-1) < R), so the direction from o_i to a point
         running along bd C_n turns strictly monotonically; the angle swept by the
         arc q_i -> q_{i+1}, i.e. alpha_i = ∠ q_i o_i q_{i+1} measured through the
         cell, is therefore <= Pi.  Equality forces q_i, q_{i+1} on the line y = d,
         i.e. d = h, d^2 = R^2 - 1, and the arc is the whole cap.               QED
       (Converse, showing the convention is needed: if d^2 > R^2-1 the cap endpoints
        have y = h < d, so the full cap subtends > Pi at o_i.)

   P0c (uniqueness survives the normalisation).  The target theorem asserts
     uniqueness up to rotation of the ORIGINAL covering, not only of the reflected
     one.  Suppose the normalised covering is RingConfig[k] (centre disk + ring at
     distance s = 2 Cos[Pi/k]) and some ring disk, WLOG C_1 with centre c_1 = (s,0),
     was obtained by reflection from an original disk with centre c_1^o = ((R^2-1)/s, 0).
     Un-reflecting only shrinks C_j ∩ C_n (P0a), so it suffices to exhibit points of
     C_n missed by C_1^o and by every other RingConfig disk.  Take the inner triple
     point p = (Cos[Pi/k], -Sin[Pi/k]) of C_0, C_1, C_k (|p| = |p-c_1| = |p-c_k| = 1).
       |p - c_1^o| > 1 (strict) and |p - c_j| > 1 for j ∉ {1,k} (strict);
       pick v with v·p > 0 and v·(p - c_k) > 0 (exists: p - o and p - c_k are
       not antiparallel, gate checks they are linearly independent);
       then for small e > 0 the point p + e v is in int C_n (|p| = 1 < R) and outside
       C_0, C_k (first-order growth of the distance) and outside C_1^o and every
       other C_j (continuity).  So the original family did not cover: contradiction.
     Also gated: s^2 < R^2 - 1, i.e. RingConfig itself already obeys the convention.

   CHECKS (gating -- Exit 0 iff ALL True):
     I1  2h - d - d' == 0
     I2  |p-o_i'|^2 - |p-o_i|^2 - 2(d-d')(y-h) == 0
     I3  on bd C_n: |p-o_i'|^2 - 1 + 2 d'(y-h) == 0, and |p-o_i|^2 - 1 + 2 d (y-h) == 0
     Q-a Resolve: R>1, d^2>R^2-1  => (p ∈ C_n ∩ C_i => p ∈ C_i')   for all p   (True)
     Q-a' Reduce characterisation of (R,d) with R>1, d>0 : d >= sqrt(R^2-1)
     Q-b Resolve: R>1, 0<d, d^2<=R^2-1, p ∈ bd C_n ∩ C_i  =>  p_y >= h >= d      (True)
     Q-b' Resolve: R>1, d^2>R^2-1 => h < d   (cap endpoints below o_i: converse)
     U   k = 7, 8, 9 (n = 8, 9, 10): exact  s^2 < R^2-1, |p|=|p-c_1|=|p-c_k|=1,
         |p-c_1^o|^2 > 1, min_{j ∉ {1,k}} |p-c_j|^2 > 1, det(p, p-c_k) != 0,
         R > 1.  All by RootReduce / exact sign decisions.

   Usage (repo root):
     wolframscript -file proofs/certificates/05f-p0-reflection.wls ; echo "EXIT=$?"
   No randomness, no numerics: every gate is a symbolic / exact-algebraic decision.
   ============================================================================ *)

ClearAll[x, y, d, R];
h  = (d^2 + R^2 - 1)/(2 d);
dp = (R^2 - 1)/d;
distSq[{a_, b_}, {c_, e_}] := (a - c)^2 + (b - e)^2;

(* ---------------- identities ----------------------------------------------- *)
I1 = TrueQ[Simplify[2 h - d - dp] === 0];
I2 = TrueQ[Simplify[distSq[{x, y}, {0, dp}] - distSq[{x, y}, {0, d}] - 2 (d - dp) (y - h)] === 0];
I3 = TrueQ[Simplify[(distSq[{x, y}, {0, dp}] - 1 + 2 dp (y - h)) /. x^2 -> R^2 - y^2] === 0] &&
     TrueQ[Simplify[(distSq[{x, y}, {0, d}] - 1 + 2 d (y - h)) /. x^2 -> R^2 - y^2] === 0];
Print["[I1] mirror centre d' = 2h-d = (R^2-1)/d : ", I1];
Print["[I2] power difference 2(d-d')(y-h)       : ", I2];
Print["[I3] boundary identities                  : ", I3];

(* polynomial forms (multiply through by d > 0 / d^2 > 0) *)
inCn[x_, y_]  := x^2 + y^2 <= R^2;
onCn[x_, y_]  := x^2 + y^2 == R^2;
inCi[x_, y_]  := x^2 + (y - d)^2 <= 1;
inCip[x_, y_] := d^2 x^2 + (d y - (R^2 - 1))^2 <= d^2;     (* p ∈ D((0,d'),1) *)

(* ---------------- Q-a : P0a by quantifier elimination ----------------------- *)
Qa = TimeConstrained[
   Resolve[ForAll[{R, d, x, y},
     Implies[R > 1 && d > 0 && d^2 > R^2 - 1 && inCn[x, y] && inCi[x, y], inCip[x, y]]],
    Reals], 600, $Aborted];
Qa = TrueQ[Qa];
Print["[Q-a] P0a  C_i ∩ C_n ⊆ C_i'  (all R>1, d^2>R^2-1) : ", Qa];

QaRed = TimeConstrained[
   Reduce[R > 1 && d > 0 &&
     ForAll[{x, y}, Implies[inCn[x, y] && inCi[x, y], inCip[x, y]]], {R, d}, Reals],
   600, $Aborted];
QaChar = TrueQ[Resolve[ForAll[{R, d},
     Implies[R > 1 && d > 0, Equivalent[QaRed, d >= Sqrt[R^2 - 1]]]], Reals]];
Print["[Q-a'] inclusion holds  <=>  d >= sqrt(R^2-1) : ", QaChar, "   (Reduce: ", QaRed, ")"];

(* ---------------- Q-b : P0b ------------------------------------------------- *)
Qb = TrueQ[TimeConstrained[
    Resolve[ForAll[{R, d, x, y},
      Implies[R > 1 && d > 0 && d^2 <= R^2 - 1 && onCn[x, y] && inCi[x, y],
       2 d y >= d^2 + R^2 - 1 && d^2 + R^2 - 1 >= 2 d^2]], Reals], 600, $Aborted]];
Print["[Q-b] same side: arc of C_i on bd C_n has y >= h >= d : ", Qb];
Qb2 = TrueQ[Resolve[ForAll[{R, d},
     Implies[R > 1 && d > 0 && d^2 > R^2 - 1, d^2 + R^2 - 1 < 2 d^2]], Reals]];
Print["[Q-b'] opposite side: h < d (cap subtends > Pi)       : ", Qb2];

(* ---------------- U : uniqueness after un-reflection ------------------------ *)
ringCheck[k_] := Module[{Rk, s, c, p, co, others, chk},
  Rk = 1 + 2 Cos[2 Pi/k]; s = 2 Cos[Pi/k];
  c[j_] := s {Cos[2 Pi (j - 1)/k], Sin[2 Pi (j - 1)/k]};   (* ring disks C_1..C_k, c_1 = (s,0) *)
  p = {Cos[Pi/k], -Sin[Pi/k]};
  co = {(Rk^2 - 1)/s, 0};
  others = Range[2, k - 1];
  chk = <|
    "R>1"            -> TrueQ[Rk > 1],
    "s^2<R^2-1"      -> TrueQ[RootReduce[Rk^2 - 1 - s^2] > 0],
    "|p|=1"          -> TrueQ[RootReduce[p.p - 1] == 0],
    "|p-c1|=1"       -> TrueQ[RootReduce[distSq[p, c[1]] - 1] == 0],
    "|p-c_k|=1"  -> TrueQ[RootReduce[distSq[p, c[k]] - 1] == 0],
    "|p-c1o|>1"      -> TrueQ[RootReduce[distSq[p, co] - 1] > 0],
    "others>1"       -> AllTrue[others, TrueQ[RootReduce[distSq[p, c[#]] - 1] > 0] &],
    "independent"    -> TrueQ[RootReduce[Det[{p, p - c[k]}]] != 0]
  |>;
  Print["[U k=", k, "] ", chk, "   |p-c1o|^2-1 = ", N[distSq[p, co] - 1, 12]];
  AllTrue[Values[chk], TrueQ]];
U = AllTrue[{7, 8, 9}, ringCheck];

(* =============================== GATE ======================================== *)
allChecks = <|"I1" -> I1, "I2" -> I2, "I3" -> I3, "Q-a" -> Qa, "Q-a'" -> QaChar,
   "Q-b" -> Qb, "Q-b'" -> Qb2, "U (k=7,8,9)" -> U|>;
Print["------------------------------------------------------------"];
Print["P0 reflection convention check summary  [FT 2005 section 2, S0]:"];
KeyValueMap[Print["  ", #1, " : ", #2] &, allChecks];
Print["------------------------------------------------------------"];
If[AllTrue[Values[allChecks], TrueQ],
  Print["CERTIFICATE OK (L3): P0a, P0b, P0c closed."]; Exit[0],
  Print["CERTIFICATE FAILED"]; Exit[1]];
