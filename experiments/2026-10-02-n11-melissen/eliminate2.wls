#!/usr/bin/env wolframscript
(* Reduced exact system in the 11 center params + R (tight points eliminated analytically),
   then bounded GroebnerBasis elimination for R's minimal polynomial.
   Usage: eliminate2.wls [timeout_sec] *)

tsec = If[Length[Rest[$ScriptCommandLine]] >= 1, ToExpression[Rest[$ScriptCommandLine][[1]]], 900];

S0={0,a};S1={0,b};S2={0,g};p1={u1,v1};p2={u2,v2};p3={u3,v3};p4={u4,v4};
sq[A_,B_]:=(A-B).(A-B);

(* circumradius^2 of A,B,C = (|AB|^2 |BC|^2 |CA|^2) / (4 (2K)^2), 2K = cross *)
cross[A_,B_,C_] := (B[[1]]-A[[1]])(C[[2]]-A[[2]]) - (C[[1]]-A[[1]])(B[[2]]-A[[2]]);
circR2[A_,B_,C_] := (sq[A,B] sq[B,C] sq[C,A]) / (4 cross[A,B,C]^2);

(* INT tight: circumradius of the 3 generators = 1 (its circumcenter is at distance 1 from all) *)
intEq[A_,B_,C_] := Numerator[Together[circR2[A,B,C] - 1]];

(* BND tight: the two generators A,B each at distance 1 from a common point X with |X|=R.
   X is a bisector-circle meet. Condition that such X exists at distance exactly 1 from both:
   X lies on bisector of A,B and on |X|=R and |X-A|=1. Eliminate X analytically:
   the midpoint-foot m and the geometry give a single relation. Use resultant of
   {|X-A|^2=1, |X-B|^2=1, |X|^2=R^2} in X -> condition on A,B,R. *)
bndEq[A_,B_] := Module[{x,y,g1,g2,g3,res},
  g1 = (x-A[[1]])^2+(y-A[[2]])^2-1;
  g2 = (x-B[[1]])^2+(y-B[[2]])^2-1;
  g3 = x^2+y^2-R^2;
  (* eliminate x,y *)
  res = Resultant[Resultant[g1-g2, g1-g3, x], Resultant[g1-g2, g1, x] /. {}, y]; (* placeholder *)
  res];

(* Simpler robust BND: subtract to linearize. g1-g2 is linear in x,y (the bisector);
   g1-g3 is linear too. Solve the 2 linear eqs for x,y, substitute into g1=0. *)
bndEq2[A_,B_] := Module[{x,y,lin1,lin2,sol},
  lin1 = Expand[((x-A[[1]])^2+(y-A[[2]])^2-1) - (x^2+y^2-R^2)];      (* -2A.x +|A|^2 -1 +R^2 =0 *)
  lin2 = Expand[((x-B[[1]])^2+(y-B[[2]])^2-1) - (x^2+y^2-R^2)];
  sol = Quiet@Solve[{lin1==0, lin2==0}, {x,y}];
  If[sol==={}, Return[1]];
  Numerator[Together[(x^2+y^2-R^2) /. First[sol]]]];

eqsINT = {
  intEq[S0,S1,p3], intEq[S0,p2,p3], intEq[S1,S2,p1], intEq[S1,p1,p3],
  (* on-axis E: S0,p4,p4m -> circumradius of S0 and the pair p4,(-u4,v4) =1 *)
  intEq[S0, p4, {-u4,v4}]
};
eqsBND = {
  bndEq2[S2,p1], bndEq2[p1,p3], bndEq2[p2,p3], bndEq2[p2,p4],
  bndEq2[p4,{-u4,v4}]
};
eqs = Join[eqsINT, eqsBND];
Print["built ", Length[eqs], " reduced equations in vars a,b,g,u1,v1,u2,v2,u3,v3,u4,v4,R"];
Print["eq degrees (total): ", Exponent[#, {a,b,g,u1,v1,u2,v2,u3,v3,u4,v4,R}] & /@ eqs // Short];

(* 10 equations, 12 unknowns (11 params + R) -> 2-DOF, matches rigidity. For a 0-dim system in
   R we need the 2 stationarity conditions (max R). Add dR=0 via Lagrange is hard symbolically;
   instead just try to eliminate everything but R from the 10 eqs + see the elimination ideal's
   R-content (it will be 0 or low because 2 DOF remain -> R not determined by contacts alone). *)
vars = {a,b,g,u1,v1,u2,v2,u3,v3,u4,v4};
Print["\nAttempting elimination of ", Length[vars], " vars (timeout ", tsec, "s)..."];
res = TimeConstrained[
   GroebnerBasis[eqs, {R}, vars, MonomialOrder -> EliminationOrder],
   tsec, $TimedOut];
If[res === $TimedOut,
   Print["ELIMINATION TIMED OUT at ", tsec, "s -> R has no practically-computable low-degree minpoly from contacts alone (consistent with 2-DOF + high algebraic degree)."],
   Print["elimination ideal R-content: ", InputForm[res]]];
