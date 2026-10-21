#!/usr/bin/env wolframscript
(* Outward-rounded constants for the ordered nine-arc simplex.
   Cyclic-interval combinatorics are proved in proofs/13-n11-technical-route.md. *)
wp=80; enc[x_]:=N[Interval[{x,x}],wp];
gates=<||>;gate[k_,v_]:=(gates[k]=TrueQ[v];Print[k," : ",gates[k]]);
r0=263169/100000;r1=141/50;
a0=ArcSin[1/enc[r0]];a1=ArcSin[1/enc[r1]];
D0=9a0-enc[Pi];D1=9a1-enc[Pi];
gate["A1_eight_arcs_insufficient",Max[8a0]<Min[enc[Pi]]];
gate["A2_deficit_positive_through_search_domain",Min[D1]>0];
gate["A3_angular_gaps_positive",Min[2enc[Pi]-16a0]>0];
gate["A4_triple_boundary_overlap_redundant_geometry",Max[4a0]<Min[enc[Pi]]];
gate["A5_two_nonadjacent_arcs_fit_line_chart",Max[8a0]<Min[enc[Pi]]];
Print["a(r0) = ",InputForm[a0],"; D(r0) = ",InputForm[D0]];
Print["global overlap budget <= ",InputForm[2D0]];
Print["each ordered angular gap >= ",InputForm[2enc[Pi]-16a0]];
(* Algebraic closure for d_i=D u_i, o_i=2D v_i. *)
u=Array[uu,9];v=Array[vv,9];
gaps=Table[2aa-dd(u[[i]]+u[[Mod[i,9]+1]]+2v[[i]]),{i,9}];
gate["A6_gap_sum_identity",Expand[Total[gaps]-(18aa-2dd Total[Join[u,v]])]===0];
gate["A7_domain_dimension",Length[Join[u,v]]-1==17];
(* Inward center branch solves s^2-2R cos(w)s+R^2-1=0. *)
s=rr Cos[ww]-Sqrt[1-rr^2 Sin[ww]^2];
gate["A8_radial_inverse_identity",TrueQ[FullSimplify[s^2-2rr Cos[ww]s+rr^2-1==0]]];
If[And@@Values[gates],Print["CERTIFICATE OK (L3): ordered-arc arithmetic; global localization NOT proved"];Exit[0],Exit[1]];
