#!/usr/bin/env wolframscript
(* Certificate 10f for proofs/10b-n6-H0.md, case 3:  NO six-disk cover of D(0,R),
   R in [Rlo, Rlo + 10^-10], in which no single disk holds both q = (0,a-1) and b = (0,-R).
   Frame and notation: 10lib-H0.wl.  Hand steps (proofs/10b §3): every disk meets dCn; the
   disk O1 = D((0,a),1) holding the origin has a in [R-1, 1]; P = D((x,y),1) != O1 holds q;
   x >= 0 after a mirror; case 3 => |cP - b| > 1.  A witness w (a point of Cn near which
   Cn \ (O1 u P) is nonempty) lies in a third disk Q, |cQ| <= 1 + |w|, so Q's boundary arc has
   half-angle <= thQ := theta(min(1 + |w|, Sqrt[R^2-1])).  Witnesses used:
     w1 = (0, y - Sqrt[1-x^2])            (bottom of P's chord; always valid in case 3)
     w2, w3 = crossing points of dO1, dP  (valid when |w| < R).
   The other three disks have arcs <= 2 alpha.  G0 = dCn \ (I1 u IP) must be covered by arcs of
   lengths {2alpha, 2alpha, 2alpha, 2thQ}.  For two gaps gA, gB separated by I1, IP this is possible
   only if  (split) some sub-multiset sums >= gA and the rest >= gB,  or  (bridge) the total
   >= 2Pi - max(|I1|, |IP|);  for one gap only if the total >= gA + gB.
   Gate:  (S3) on every box of (a,x,y) meeting the case-3 domain, some valid witness makes the
               cover impossible.                                  [interval B&B, 3D]
          (C3) negative control: the 3-fold config (R = 1.79528 < R6, a = 1, cP = (Sqrt3/2,-1/2))
               must NOT be certified.
   Exit 1 on failure; last line "CERTIFICATE OK". *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "10lib-H0.wl"}]];
fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];
Off[General::munfl];

Rlo = 1798867827575/10^12; RhiH = Rlo + 1/10^10;


n6boxes = 0; n6stuck = {};
box0 = {{Rlo - 1, 1}, {0, 1}, {-121/100, 1}};
RI0 = N[Interval[{Rlo, RhiH}]];
{t, r} = AbsoluteTiming[n6prove[case3Pred[RI0], box0, {1/5, 1, 11/5}, 60]];
Print["  S3 sweep: boxes ", n6boxes, ", ", Round[t, 0.1], " s"];
If[! r, Print["  first stuck box: ", N[First[n6stuck], 12]]];
gate["S3 case 3 excluded on [Rlo, Rlo+1e-10]", r];

(* (C3) negative control at the 3-fold configuration (a genuine cover at R = 1.79528...) *)
n6boxes = 0; n6stuck = {};
With[{RIc = N[Interval[{179528/100000, 179528/100000}]], e = 1/10^6},
  gate["C3 control (3-fold cover at R=1.79528 not excluded)",
   ! n6prove[case3Pred[RIc], {{1 - e, 1}, {866025/10^6 - e, 866025/10^6 + e}, {-1/2 - e, -1/2 + e}},
      {1, 1, 1}, 12]]];
Print["CERTIFICATE OK"];
