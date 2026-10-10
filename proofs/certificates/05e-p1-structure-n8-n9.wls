#!/usr/bin/env wolframscript
(* ============================================================================
   Certificate 05e : the n = 8, 9 structure lemma (proofs/06 P1 ; [FT] section 2).

   Lemma ([FT] 2005, "Thinnest covering of a circle by eight, nine, or ten
   congruent circles", MSRI Publ. 52, 361-376, section 2).  Let n in {8,9},
   k = n-1, R_n = 1 + 2 Cos[2 Pi/k], and let n closed unit disks C_0..C_{n-1}
   cover C_n = D(o, R_n).  Then
      (i)  exactly one C_i is contained in int C_n ;
      (ii) no three of the disks meeting bd C_n have a common point.

   [FT] section 2 writes the n=8,9 argument out in full; the only gaps left for
   this repo (see proofs/06 section 3.2) are purely mechanical:
     (A) elementary proofs of the two arc-length upper bounds, and
     (B) an OUTWARD-ROUNDED interval recheck of the four arcsin inequalities.
   This certificate closes both.  (n=10 needs a different argument -- Melissen /
   areas -- handled by certificate 05c ; NOT touched here.)

   --------------------------------------------------------------------------
   (A) The two arc-length upper bounds (elementary geometry; proved here, then
       reused from wl/CirCovCir.wl as MaxCoveredArc / MaxCoveredArcTriple).

   L-arc1 (single unit disk).  An arc of bd C_n (radius r = R_n) covered by one
   unit disk spans at o an angle <= 2 ArcSin[1/r].
       Proof.  bd C_n meets the closed unit disk in an arc whose endpoints a,b
       both lie in that disk, so the chord |a-b| <= diam = 2.  A chord of length
       L of a circle of radius r subtends a central angle 2 ArcSin[L/(2 r)];
       this is increasing in L, so the covered arc's central angle is at most
       2 ArcSin[2/(2 r)] = 2 ArcSin[1/r].  (This is exactly CirCovCir`MaxCoveredArc,
       whose chord/radius derivation already sits beside CoveredArc[r,d].)   QED

   L-arc2 (three unit disks with a common point).  An arc of bd C_n covered by
   three unit disks that share a common point p spans at o an angle <= 2 ArcSin[2/r].
       Proof.  p lies in all three disks, so |p - center_j| <= 1 for each disk j.
       Any covered boundary point x lies in some disk j, so |x - center_j| <= 1,
       whence by the triangle inequality |x - p| <= |x - center_j| + |center_j - p|
       <= 1 + 1 = 2.  Thus every covered point of bd C_n lies in the disk D(p, 2);
       the two extreme covered points a,b satisfy |a-p|,|b-p| <= 2, so the chord
       |a-b| <= |a-p| + |p-b| <= 4.  By the same chord/central-angle law the arc's
       central angle at o is <= 2 ArcSin[4/(2 r)] = 2 ArcSin[2/r].  (This is
       CirCovCir`MaxCoveredArcTriple.)   QED

   The two bounds reduce (i),(ii) to the four numeric inequalities below:
     (i)  if every C_i (i>=1) meets bd C_n then only C_0 is interior; a single
          interior disk exists because r_n > 2.  "Every C_i meets bd C_n" follows
          because k-1 single-disk arcs cannot cover bd C_n:
             6 ArcSin[1/R_8] < Pi ,   7 ArcSin[1/R_9] < Pi .
     (ii) three disks with a common point cover an arc <= 2 ArcSin[2/r], and the
          remaining boundary would need (k-1) further single-disk arcs; the
          totals stay below the full turn because
             4 ArcSin[1/R_8] + ArcSin[2/R_8] < Pi ,
             5 ArcSin[1/R_9] + ArcSin[2/R_9] < Pi .
     (All four are the HALF-TURN forms [FT] prints; < Pi is what the argument uses.)

   --------------------------------------------------------------------------
   (B) OUTWARD-ROUNDED interval recheck (AGENTS.md section 4).

   Each quantity is of the form  m*ArcSin[1/r] (+ ArcSin[2/r]),  r = R_n an exact
   algebraic real.  We enclose each term in a WL Interval (interval arithmetic is
   outward-rounding by construction) built at high working precision, take the
   UPPER endpoint of the LHS enclosure and the LOWER endpoint of a Pi enclosure,
   and require  LHS_upper < Pi_lower  (strict, outward-rounded).  ArcSin is
   monotone increasing, so ArcSin[Interval[...]] is a valid enclosure.

   HONEST NOTE on [FT]'s printed decimals.  Three of the four match [FT] to all
   printed digits (2.989550105, 2.942412903, 3.111686536).  The FIRST, which [FT]
   prints as "6 arcsin(1/r8) = 2.76326081", actually evaluates to 2.767326081...
   -- a digit transposition in the paper ("76326" <-> "767326").  Both the paper's
   typo'd value and the true value are < Pi, so the conclusion is unaffected; we
   certify the TRUE value and record the typo rather than reproduce the misprint.

   CHECKS (gating -- Exit 0 iff ALL are finite real True):
     L-arc1 / L-arc2 symbolic identities to the reused library functions ;
     four inequalities, outward-rounded, strictly < Pi, for n = 8 and n = 9.

   Usage (repo root):
     wolframscript -file proofs/certificates/05e-p1-structure-n8-n9.wls ; echo "EXIT=$?"
   Exit 0 iff every gated check is a finite real True.  No randomness.
   ============================================================================ *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];

$MaxExtraPrecision = 2000;
prec = 80;

R8 = 1 + 2 Cos[2 Pi/7];   (* k = 7 *)
R9 = 1 + 2 Cos[2 Pi/8];   (* k = 8 *)

(* ---- outward-rounded enclosure helpers -------------------------------------- *)
(* Enclose an exact algebraic real x by a tiny Interval that provably contains it.
   SetPrecision to `prec` then widen by a generous pad each way guarantees
   containment of the exact value; ArcSin (monotone) then propagates outward. *)
encl[x_] := Module[{c = SetPrecision[x, prec], w},
  w = 10^(-prec + 2);                     (* generous outward pad, >> rounding error *)
  Interval[{c - Abs[c] w - w, c + Abs[c] w + w}]];
asinIv[x_] := ArcSin[encl[x]];            (* valid enclosure: ArcSin increasing *)
piIv = Interval[{SetPrecision[Pi, prec] - 10^(-prec + 2),
                 SetPrecision[Pi, prec] + 10^(-prec + 2)}];
piLower = Min[piIv];
realFiniteQ[x_] := NumericQ[x] && Element[x, Reals] && Abs[x] < Infinity;

ineqCheck[label_, lhsInterval_] := Module[{u = Max[lhsInterval], pl = piLower, ok, margin},
  ok = realFiniteQ[u] && realFiniteQ[pl] && TrueQ[u < pl];
  margin = If[realFiniteQ[u] && realFiniteQ[pl], N[pl - u, 10], Indeterminate];
  Print["  ", label];
  Print["      LHS_upper (outward) = ", N[u, 18]];
  Print["      Pi_lower  (outward) = ", N[pl, 18]];
  Print["      strict LHS<Pi : ", ok, "   margin = ", margin];
  ok];

(* ======================= L-arc1 / L-arc2 symbolic identities ================= *)
Larc1 = Module[{id8, id9},
  id8 = TrueQ[FullSimplify[MaxCoveredArc[R8] - 2 ArcSin[1/R8]] == 0];
  id9 = TrueQ[FullSimplify[MaxCoveredArc[R9] - 2 ArcSin[1/R9]] == 0];
  Print["[L-arc1] single-disk arc <= 2 ArcSin[1/r]  (= CirCovCir`MaxCoveredArc)"];
  Print["         identity r=R8: ", id8, "   r=R9: ", id9];
  id8 && id9];

Larc2 = Module[{id8, id9, pos8, pos9},
  id8 = TrueQ[FullSimplify[MaxCoveredArcTriple[R8] - 2 ArcSin[2/R8]] == 0];
  id9 = TrueQ[FullSimplify[MaxCoveredArcTriple[R9] - 2 ArcSin[2/R9]] == 0];
  (* r_n > 2 so 2/r_n < 1 and the arcsin is a real angle, bound is non-vacuous *)
  pos8 = TrueQ[R8 > 2]; pos9 = TrueQ[R9 > 2];
  Print["[L-arc2] triple-cover arc <= 2 ArcSin[2/r]  (= CirCovCir`MaxCoveredArcTriple)"];
  Print["         identity r=R8: ", id8, "   r=R9: ", id9, "   (r_n>2: ", pos8 && pos9, ")"];
  id8 && id9 && pos8 && pos9];

(* ======================= four inequalities, n = 8 and n = 9 ================== *)
Print["[ineq n=8] (i) 6 asin(1/R8) < pi ;  (ii) 4 asin(1/R8)+asin(2/R8) < pi"];
i8a = ineqCheck["6 ArcSin[1/R8] < Pi            (FT prints 2.76326081, true 2.767326081)",
     6 asinIv[1/R8]];
i8b = ineqCheck["4 ArcSin[1/R8] + ArcSin[2/R8] < Pi   (FT 2.942412903)",
     4 asinIv[1/R8] + asinIv[2/R8]];

Print["[ineq n=9] (i) 7 asin(1/R9) < pi ;  (ii) 5 asin(1/R9)+asin(2/R9) < pi"];
i9a = ineqCheck["7 ArcSin[1/R9] < Pi            (FT 2.989550105)",
     7 asinIv[1/R9]];
i9b = ineqCheck["5 ArcSin[1/R9] + ArcSin[2/R9] < Pi   (FT 3.111686536)",
     5 asinIv[1/R9] + asinIv[2/R9]];

(* =============================== GATE ======================================== *)
n8ok = i8a && i8b;
n9ok = i9a && i9b;
allok = TrueQ[Larc1] && TrueQ[Larc2] && TrueQ[n8ok] && TrueQ[n9ok];

allChecks = <|
  "L-arc1 (single)"            -> Larc1,
  "L-arc2 (triple)"            -> Larc2,
  "n=8  6 asin(1/R8)<pi"       -> i8a,
  "n=8  4 asin(1/R8)+asin(2/R8)<pi" -> i8b,
  "n=9  7 asin(1/R9)<pi"       -> i9a,
  "n=9  5 asin(1/R9)+asin(2/R9)<pi" -> i9b
|>;
Print["------------------------------------------------------------"];
Print["P1 structure lemma (n=8,9) check summary  [FT 2005 section 2]:"];
KeyValueMap[Print["  ", #1, " : ", #2] &, allChecks];
Print["  n=8 all ok : ", n8ok, "    n=9 all ok : ", n9ok];
Print["------------------------------------------------------------"];
If[allok,
  Print["CERTIFICATE OK (L3): P1 for n=8 and n=9 closed."]; Exit[0],
  Print["CERTIFICATE FAILED"]; Exit[1]];
