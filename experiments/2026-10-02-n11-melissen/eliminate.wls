#!/usr/bin/env wolframscript
(* Exact elimination attempt for R. The tight points can be eliminated analytically: an INT
   point is the circumcenter of its 3 generators; a BND point is a bisector-circle meet. So
   each contact reduces to a polynomial relation purely among the 11 center params + R. We
   build those reduced relations and try GroebnerBasis elimination to get R's minimal poly.
   Heavy: run with a wall timeout; if it doesn't finish, that itself is the finding (R is a
   high-degree algebraic number with no practical radical form). Usage: eliminate.wls [sec] *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
tsec = If[Length[Rest[$ScriptCommandLine]] >= 1, ToExpression[Rest[$ScriptCommandLine][[1]]], 600];

(* params *)
S0={0,a};S1={0,b};S2={0,g};p1={u1,v1};p2={u2,v2};p3={u3,v3};p4={u4,v4};
sq[u_,c_]:=(u-c).(u-c);

(* A circumcenter X of A,B,C satisfies |X-A|^2=|X-B|^2=|X-C|^2; being tight adds =1.
   Eliminating X from these 3 gives: the circumradius of A,B,C equals 1, i.e. the three
   pairwise relations. The condition "circumradius=1" is a single polynomial in A,B,C:
     with D = 2*area, circumR^2 = (|AB|^2 |BC|^2 |CA|^2)/(2 D)^2 ... use that = 1. *)
circR2[A_,B_,C_] := Module[{ab,bc,ca,area2},
  ab=sq[A,B]; bc=sq[B,C]; ca=sq[C,A];
  area2 = ((B[[1]]-A[[1]])(C[[2]]-A[[2]]) - (C[[1]]-A[[1]])(B[[2]]-A[[2]]));  (* 2*signed area *)
  (ab bc ca)/(area2^2)];              (* = (2 circumR)^2 ... actually circumR^2 = ab bc ca/(2 area2^2)? *)
(* circumradius^2 = (a b c / (4 K))^2 with sides a,b,c and area K; here ab=side^2 etc.
   R_circ^2 = (|AB|^2|BC|^2|CA|^2) / ( (2*area2)^2 ) /4 ... derive carefully below numerically. *)

(* To avoid a formula slip, verify circR2 on a known triangle numerically *)
tri = {{0,0},{2,0},{0,2}}; (* right isoceles, circumradius = sqrt2 -> R^2=2 *)
Print["circR2 formula check (want 2): ", N[circR2 @@ tri]];
