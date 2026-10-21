#!/usr/bin/env wolframscript
(* Arithmetic certificate for the b=9 reductions in proofs/12-n11-b9-witness.md.
   All decisive comparisons use outward-rounded exact-input intervals.
   This does NOT prove the sharp Melissen upper bound. *)
wp=80;
iv[x_]:=N[Interval[{x,x}],wp];
gates=<||>;
gate[k_,v_]:=(gates[k]=TrueQ[v];Print[k," : ",gates[k]]);
r0=263169/100000;
a=ArcSin[1/iv[r0]];
gate["B1_eight_arcs_insufficient",Max[8a]<Min[iv[Pi]]];
Print["minimum individual full arc = ",InputForm[2iv[Pi]-16a]];

(* If all nine boundary centers had norm >2, a target subdisk of radius
   rho>1 close enough to 1 would be disjoint from all nine boundary disks.
   Two unit disks cannot cover D(0,rho): each covers less than a semicircle.
   Thus at least one boundary center has norm <=2. *)
w[r_,s_]:=ArcCos[(r^2+s^2-1)/(2r s)];
lo=2819987/1000000; hi=2819988/1000000;
q[r_]:=w[r,2]+8ArcSin[1/r]-Pi;
qlo=q[iv[lo]];qhi=q[iv[hi]];
gate["B2_upper_root_lower_endpoint",Min[qlo]>0];
gate["B3_upper_root_upper_endpoint",Max[qhi]<0];
Print["root bracket = ",{lo,hi}];
Print["q(lo) = ",InputForm[qlo]," q(hi) = ",InputForm[qhi]];
(* Derivative sign via the elementary arguments of acos and asin. *)
gate["B4_acos_argument_increasing",TrueQ[FullSimplify[
 D[(r^2+3)/(4r),r]==(r^2-3)/(4r^2),r>0]]];
gate["B5_radius_domain",lo>Sqrt[5]&&hi<3];
(* One-point calibration of the more conservative stated rational upper bound. *)
upper=141/50;
gate["B6_global_rational_upper",Max[q[iv[upper]]]<0];
Print["capacity gap at 2.82 = ",InputForm[-q[iv[upper]]]];

If[And@@Values[gates],Print["CERTIFICATE OK (L3): b9 arithmetic only; sharp bound NOT proved"];Exit[0],Exit[1]];
