#!/usr/bin/env wolframscript
(* b=9 order-statistic capacity bound. Geometric central-disk reduction is in
   proofs/15-n11-b9-localization.md. No b=10 assertion is made here. *)
wp=90;enc[x_]:=N[Interval[{x,x}],wp];
gates=<||>;gate[k_,v_]:=(gates[k]=TrueQ[v];Print[k," : ",gates[k]];If[!gates[k],Exit[1]]);
w[r_,s_]:=ArcCos[(r^2+s^2-1)/(2r s)];
a[r_]:=ArcSin[1/r];
smax={2,1+2/Sqrt[3],1+Sqrt[2]};
f[r_]:=Total[w[r,#]&/@(enc/@smax)]+6a[r]-enc[Pi];
r0=263169/100000;lo=2786784686983/10^12;hi=2786784686984/10^12;
gate["S1_small_cover_arc_bounds",FullSimplify[2ArcSin[1/(2/Sqrt[3])]==2Pi/3]&&
 FullSimplify[2ArcSin[1/Sqrt[2]]==Pi/2]];
gate["S2_radial_caps_inside_inward_branch",Max[enc[Last[smax]]]<Min[Sqrt[enc[r0]^2-1]]];
(* dw/dR<0: derivative of cosine argument has numerator R^2-s^2+1>0.
   dw/ds>0 on s^2<R^2-1; this justifies assigning s_(1..3) their caps. *)
gate["S3_radius_monotonicity",Min[enc[r0]^2-enc[Last[smax]]^2+1]>0];
gate["S4_unique_bound_root_bracket",Min[f[enc[lo]]]>0&&Max[f[enc[hi]]]<0];
gate["S5_nonvacuous_lower_endpoint",Min[f[enc[r0]]]>0];
Print["b9 capacity root in [",lo,",",hi,"]"];
Print["f(lo) = ",InputForm[f[enc[lo]]],"; f(hi) = ",InputForm[f[enc[hi]]]];
(* Verification of stable radial inverse in ordered_arcs.py, d=a-w.
   R cos(a)=sqrt(R^2-1), R sin(a)=1. *)
x=Cos[dd]-tt Sin[dd];
gate["S6_stable_radicand_identity",TrueQ[FullSimplify[
 (2Sin[dd/2]^2+tt Sin[dd]) (1+Cos[dd]-tt Sin[dd])==1-x^2]]];
Print["ALL ORDER STATISTIC: ",gates];
Print["CERTIFICATE OK (L3): all b9 R < 2.786784686984, conditional on central-disk reduction; sharp Rstar bound NOT proved"];
Exit[0];
