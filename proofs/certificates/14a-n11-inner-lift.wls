#!/usr/bin/env wolframscript
(* G3: independent exact-rational replay of arbitrary TWO-center lifting.
   Strict box-uniform residual points, conflict tree, and LP duals are checked.
   No assumed positions, symmetry or contacts for the two unknown centers. *)
root=DirectoryName[DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]]];
file=FileNameJoin[{root,"experiments","2026-10-11-n11-inner-lift","results","lift.json"}];
raw=Import[file,"RawJSON"];
parse[x_String]:=ToExpression[x];parse[x_]:=x;
gates=<||>;gate[k_,v_]:=(gates[k]=TrueQ[v];Print[k," : ",gates[k]];If[!gates[k],Exit[1]]);
outer=Map[parse,raw["outer_boxes"],{3}];floor= parse[raw["radius_floor"]];
anchors=Map[parse,raw["anchor_centers"],{2}];ar= parse[raw["anchor_radius"]];
cert=raw["certificate"];points=Map[parse,cert["points"],{2}];
extra=Map[parse,cert["second_points"],{2}];rp=parse/@cert["radius_point"];ru=parse[cert["radius_upper"]];
boxDist[p_,box_]:=Sum[Max[box[[1,k]]-p[[k]],p[[k]]-box[[2,k]],0]^2,{k,2}];
missed[p_,boxes_,rr_]:=p.p<=rr^2&&And@@(boxDist[p,#]>1&/@boxes);
gate["G1_exact_input_domain",Length[outer]==9&&Length[anchors]==11&&floor==ar-10^-7&&ru==ar+10^-7&&
 parse[raw["outer_half_width"]]==1/125000000&&floor>0&&
 FreeQ[{outer,anchors,ar,floor,points,extra,rp,ru},_Real]&&
 And@@Flatten[Table[outer[[i,1,k]]==anchors[[i+2,k]]-1/125000000&&
 outer[[i,2,k]]==anchors[[i+2,k]]+1/125000000,{i,9},{k,2}]]];
gate["G2_strict_outer_residual",And@@(missed[#,outer,floor]&/@points)];
colors=ConstantArray[-1,Length[points]];colors[[1]]=0;treeOK=True;
Do[i=edge[[1]]+1;j=edge[[2]]+1;
 If[!TrueQ[1<=i<=Length[points]&&1<=j<=Length[points]&&colors[[i]]==-1&&colors[[j]]>=0&&
    (points[[i]]-points[[j]]).(points[[i]]-points[[j]])>4],treeOK=False;Break[]];
 colors[[i]]=1-colors[[j]],{edge,cert["color_tree"]}];
gate["G3_connected_conflicts_fix_assignments",treeOK&&Sort[DeleteDuplicates[colors]]=={0,1}];
assigned=Table[Pick[points,colors,k],{k,0,1}];

(* Supporting half-plane: 2(p-a).c >= |p|^2-|a|^2-1.
   Each box face is a nonnegative rational combination of these planes. *)
dualCheck[pts_,c_]:=Module[{ref,box,planes,d,weights,indices,lhs,rhs,target,good=True,k,sg,j},
 ref=parse/@c["reference"];box=Map[parse,c["box"],{2}];
 planes=Join[{{{1,0},pts[[1,1]]-1},{{-1,0},-pts[[1,1]]-1},
              {{0,1},pts[[1,2]]-1},{{0,-1},-pts[[1,2]]-1}},
             {2(#-ref),#.#-ref.ref-1}&/@pts];
 If[Length[c["duals"]]!=4||!And@@Thread[box[[1]]<=box[[2]]],Return[False]];
 Do[k=If[j==1||j==3,1,2];sg=If[j<=2,1,-1];d=c["duals"][[j]];
   indices=d[[All,1]]+1;weights=parse/@d[[All,2]];
   If[!And@@(1<=#<=Length[planes]&/@indices)||!And@@(#>=0&/@weights),Return[False]];
   lhs=weights.planes[[indices,1]];rhs=weights.planes[[indices,2]];
   target=sg UnitVector[2,k];
   good=good&&lhs===target&&rhs>=sg box[[If[sg==1,1,2],k]],{j,4}];good];
gate["G4_first_center_global_dual_bound",dualCheck[assigned[[1]],cert["first_bound"]]];
first=Map[parse,cert["first_bound"]["box"],{2}];
gate["G5_second_stage_strict_residual",And@@(missed[#,Append[outer,first],floor]&/@extra)];
gate["G6_second_center_global_dual_bound",dualCheck[Join[assigned[[2]],extra],cert["second_bound"]]];
second=Map[parse,cert["second_bound"]["box"],{2}];
allBoxes=Join[{first,second},outer];
gate["G7_radius_ceiling",rp.rp==ru^2&&missed[rp,allBoxes,ru]];
Print["first center max deviation <= ",N[Max[Abs[first-{anchors[[1]],anchors[[1]]}]],20]];
Print["second center max deviation <= ",N[Max[Abs[second-{anchors[[2]],anchors[[2]]}]],20]];
Print["minimum outer residual margin2 = ",N[Min[Flatten[Table[boxDist[p,b]-1,{p,points},{b,outer}]]],20]];
Print["minimum stage2 margin2 = ",N[Min[Flatten[Table[boxDist[p,b]-1,{p,extra},{b,Append[outer,first]}]]],20]];

(* Connect the rational anchor to the actual checked KKT root and 13b box. *)
$N11CertificateNoExit=True;
Get[FileNameJoin[{root,"proofs","certificates","07-n11-local-opt.wls"}]];
zc=(Round[10^20 Rationalize[(Min[#]+Max[#])/2,0]]/10^20)&/@zX;
gate["G8_same_collar_anchor",Append[Flatten[anchors],ar]===zc];
gate["G9_root_inside_lifting_domain",Min[RX]>floor&&Max[RX]<ru&&
 And@@Flatten[Table[outer[[i,1,k]]<Min[cX[[i+2,k]]]&&
 Max[cX[[i+2,k]]]<outer[[i,2,k]],{i,9},{k,2}]]];

(* Small legal rotation removes gauge; all 11 centers rotate together.
   T=1/|q| {{qy,-qx},{qx,qy}} sends the third center q to (0,|q|). *)
bIV=Table[N[Interval[{allBoxes[[i,1,k]],allBoxes[[i,2,k]]}],100],{i,11},{k,2}];
qTop=bIV[[3]];norm=Sqrt[qTop.qTop];
rot={{qTop[[2]],-qTop[[1]]},{qTop[[1]],qTop[[2]]}}/norm;
rotated=(rot.#)&/@bIV;
rotated[[3]]={0,norm};
rrIV=N[Interval[{floor,ru}],100];
newZ=Append[Flatten[rotated],rrIV];
gate["G10_rotated_whole_domain_inside_collar",Min[qTop[[2]]]>0&&
 And@@Table[Min[newZ[[i]]]>zc[[i]]-1/500000&&Max[newZ[[i]]]<zc[[i]]+1/500000,{i,23}]&&
 Max[Max[Abs[#]]&/@(newZ-zc)]<16839259/10^13];
Print["rotation-inclusive max deviation <= ",N[Max[Max[Abs[#]]&/@(newZ-zc)],20]];
Print["ALL LIFT: ",gates];
If[And@@Values[gates],
 Print["CERTIFICATE OK (L3): G3 lifting for outer half-width 8e-9; combine 13b for sharp conditional bound; global localization NOT proved"];Exit[0],Exit[1]];
