#!/usr/bin/env wolframscript
(* Independent continuous interval check of the saved localization leaf.
   Uses direct original trig formula and no Python interval implementation.
   Its slightly larger bounds must STILL fit the G3 box after rational rotation. *)
root=DirectoryName[DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]]];
dir=FileNameJoin[{root,"experiments","2026-10-11-n11-b9-localization","results"}];
data=Import[FileNameJoin[{dir,"local-tree.json"}],"RawJSON"];
rdata=Import[FileNameJoin[{dir,"root-ordered.json"}],"RawJSON"];
target=Import[FileNameJoin[{root,"experiments","2026-10-11-n11-inner-lift","results","lift.json"}],"RawJSON"];
parse[x_]:=ToExpression[x];iv[{lo_,hi_}]:=N[Interval[{lo,hi}],90];
b=Map[parse,data["bounds"],{2}];rr=parse/@data["radii"];
gates=<||>;gate[k_,v_]:=(gates[k]=TrueQ[v];Print[k," : ",gates[k]];If[!gates[k],Exit[1]]);
rb=Map[parse,rdata["bounds"],{2}];rroot=parse/@rdata["radius"];
gate["P1_root_enclosure_strictly_in_leaf",rr[[1]]<rroot[[1]]<=rroot[[2]]<rr[[2]]&&
 And@@Table[b[[i,1]]<=rb[[i,1]]<=rb[[i,2]]<=b[[i,2]],{i,18}]];
r=iv[rr];xx=iv/@b;a=ArcSin[1/r];dd=9a-N[Interval[{Pi,Pi}],90];
w=a-dd Take[xx,9];rad=r Cos[w]-Sqrt[1-r^2 Sin[w]^2];
theta=Table[If[j==1,0,2(j-1)a-dd(xx[[1]]+xx[[j]]+
2If[j==2,0,Total[Take[xx,{2,j-1}]]]+2Total[Take[xx,{10,8+j}]] )],{j,9}];
centers=MapThread[#1 {Cos[#2],Sin[#2]}&,{rad,theta}];
leaf=data["tree"]["localization"];v=parse/@leaf["rotation"];perm=leaf["permutation"]+1;
gate["P2_exact_rotation_and_permutation",v.v==1&&Sort[perm]==Range[9]];
rot={{v[[1]],-v[[2]]},{v[[2]],v[[1]]}};
centers=(rot.#)&/@centers;
dest=Map[parse,target["outer_boxes"],{3}];
gate["P3_entire_radius_interval_above_target_floor",rr[[1]]>=parse[target["radius_floor"]]];
gate["P4_continuous_image_inside_G3",And@@Flatten[Table[
 Min[centers[[perm[[i]],k]]]>=dest[[i,1,k]]&&
 Max[centers[[perm[[i]],k]]]<=dest[[i,2,k]],{i,9},{k,2}]]];
Print["ALL LEAF: ",gates];
Print["CERTIFICATE OK (L3): radius-interval ordered leaf enters G3 after exact rotation; global NOT proved"];
Exit[0];
