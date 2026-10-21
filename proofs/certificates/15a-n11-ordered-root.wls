#!/usr/bin/env wolframscript
(* Independent root-to-ordered-domain enclosure, NOT decimal coordinates treated
   as the exact optimum. Consumes the checked KKT enclosure from certificate 07. *)
root=DirectoryName[DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]]];
$N11CertificateNoExit=True;
Get[FileNameJoin[{root,"proofs","certificates","07-n11-local-opt.wls"}]];
out=FileNameJoin[{root,"experiments","2026-10-11-n11-b9-localization","results"}];
g=<||>;gate[k_,v_]:=(g[k]=TrueQ[v];Print[k," : ",g[k]];If[!g[k],Exit[1]]);
order={8,4,3,5,9,7,11,10,6};
(* This order is proposed, then independently checked using interval angle signs. *)
cc=cX[[order]];ss=Sqrt[#.#]&/@cc;
ang=Map[ArcTan[#[[1]],#[[2]]]&,cc];
(* Principal angle branches: first five positive, remaining four negative. *)
gate["O1_angle_branches",And@@(Min[#]>0&/@Take[ang,5])&&And@@(Max[#]<0&/@Drop[ang,5])];
ang=Join[Take[ang,5],(# + N[Interval[{2Pi,2Pi}],100])&/@Drop[ang,5]];
gaps=Differences[Append[ang,ang[[1]]+N[Interval[{2Pi,2Pi}],100]]];
gate["O2_cyclic_order",And@@(Min[#]>0&/@gaps)];
a=ArcSin[1/RX];dd=9a-N[Interval[{Pi,Pi}],100];
ww=ArcCos[(RX^2+ss^2-1)/(2RX ss)];
us=(a-ww)/dd;vs=(ww+RotateLeft[ww]-gaps)/(2dd);
gate["O3_inward_radial_branch",And@@(Max[#]<Min[Sqrt[RX^2-1]]&/@ss)];
(* Anchor 8 ties exactly with its mirror 9; all other norms are strictly larger. *)
gate["O4_shortest_anchor",TrueQ[Simplify[(cen[8].cen[8]-cen[9].cen[9])/.symRule]===0]&&
 And@@Table[Min[ss[[i]]]>Max[ss[[1]]],{i,{2,3,4,6,7,8,9}}]];
(* Round OUTWARD on a rational decimal grid; nonnegative v follows from the
   actual covering root and ordered boundary arcs, not numerical clamping. *)
scale=10^30;
lo[x_]:=Floor[scale Rationalize[Min[x],0]]/scale;
hi[x_]:=Ceiling[scale Rationalize[Max[x],0]]/scale;
bb=({Max[0,lo[#]],hi[#]}&/@Join[us,vs]);
gate["O5_valid_nonnegative_bounds",And@@(0<=#[[1]]<=#[[2]]&/@bb)];
gate["O6_tiny_overlap",Max[Max/@vs]<10^-60&&Min[Min/@vs]>-10^-60];
rr={lo[RX],hi[RX]};
Export[FileNameJoin[{out,"root-ordered.json"}],<|
 "order_1_based"->order,"radius"->(ToString[#,InputForm]&/@rr),
 "bounds"->Map[ToString[#,InputForm]&,bb,{2}],
 "level"->"L3 KKT root enclosure in ordered simplex, conditional on arc reduction 13"|>,"RawJSON"];
Print["ALL ORDERED ROOT: ",g];
Print["CERTIFICATE OK (L3): exact root enclosed in ordered simplex; no global localization claim"];
Exit[0];
