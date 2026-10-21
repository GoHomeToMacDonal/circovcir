#!/usr/bin/env wolframscript
(* Independent replay of forced inner-center propagation. The previous full
   rank-cover certificate is executed, not taken on faith from a printed bound. *)
root=DirectoryName[DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]]];
$N11RankCertificateNoExit=True;
Get[FileNameJoin[{root,"proofs","certificates","16a-n11-rank-cover.wls"}]];
file=FileNameJoin[{root,"experiments","2026-10-11-n11-b9-propagation","results","propagation-cover.json"}];
data=Import[file,"RawJSON"];
gates=<||>;gate[k_,v_]:=(gates[k]=TrueQ[v];Print[k," : ",gates[k]];If[!gates[k],Exit[1]]);
rrs=(parse/@#["radii"])&/@data["panels"];
gate["P1_complete_new_radius_panels",Length[rrs]==7&&First[rrs][[1]]==137/50&&
 Last[rrs][[2]]==69/25&&And@@(#[[1]]<#[[2]]&/@rrs)&&
 And@@Table[rrs[[k,2]]==rrs[[k+1,1]],{k,Length[rrs]-1}]];
boxDist[p_,box_]:=Sum[Max[box[[1,k]]-p[[k]],p[[k]]-box[[2,k]],0]^2,{k,2}];
insideResidual[p_,pol_,rmin_]:=p.p<=rmin^2&&And@@(distSector[p,#]>1&/@pol);
centerDualCheck[pts_,cert_]:=Catch[Module[{ref,box,ps,d,ids,weights,lhs,rhs,k,sg},
 If[Sort[Keys[cert]]!={"box","duals","reference"},Throw[False]];
 ref=parse/@cert["reference"];box=Map[parse,cert["box"],{2}];
 If[Length[pts]<1||Dimensions[box]!={2,2}||Length[ref]!=2||
   !And@@Thread[box[[1]]<=box[[2]]]||Length[cert["duals"]]!=4,Throw[False]];
 ps=Join[{{{1,0},pts[[1,1]]-1},{{-1,0},-pts[[1,1]]-1},
          {{0,1},pts[[1,2]]-1},{{0,-1},-pts[[1,2]]-1}},
          {2(#-ref),#.#-ref.ref-1}&/@pts];
 Do[k=If[n==1||n==3,1,2];sg=If[n<=2,1,-1];d=cert["duals"][[n]];
   ids=d[[All,1]]+1;weights=parse/@d[[All,2]];
   If[!And@@(IntegerQ[#]&&1<=#<=Length[ps]&/@ids)||!And@@(#>=0&/@weights),Throw[False]];
   lhs=weights.ps[[ids,1]];rhs=weights.ps[[ids,2]];
   If[lhs!=sg UnitVector[2,k]||rhs<sg box[[If[sg==1,1,2],k]],Throw[False]],{n,4}];True]];
propReplay[pol_,rmin_,cert_]:=Catch[Module[{seeds,colors,assigned,boxes={None,None},steps,
 i,j,k,p,idx,step,c,ids},
 If[Sort[Keys[cert]]!={"seed_points","seed_tree","steps"},Throw[False]];
 seeds=Map[parse,cert["seed_points"],{2}];
 If[Length[seeds]<2||!And@@(insideResidual[#,pol,rmin]&/@seeds),Throw[False]];
 colors=ConstantArray[-1,Length[seeds]];colors[[1]]=0;
 Do[{i,j}=edge+1;
   If[!(IntegerQ[i]&&IntegerQ[j]&&1<=i<=Length[seeds]&&1<=j<=Length[seeds]&&
     colors[[i]]==-1&&colors[[j]]>=0&&(seeds[[i]]-seeds[[j]]).(seeds[[i]]-seeds[[j]])>4),Throw[False]];
   colors[[i]]=1-colors[[j]],{edge,cert["seed_tree"]}];
 If[Sort[DeleteDuplicates[colors]]!={0,1},Throw[False]];
 assigned=Table[Pick[seeds,colors,k],{k,0,1}];steps=cert["steps"];
 Do[step=steps[[idx]];
 Which[
   Keys[step]=={"bound"},
     k=step["bound"]["color"]+1;c=step["bound"]["certificate"];
     If[!MemberQ[{1,2},k]||!TrueQ[centerDualCheck[assigned[[k]],c]],Throw[False]];
     boxes[[k]]=Map[parse,c["box"],{2}],
   Keys[step]=={"force"},
     k=step["force"]["excluded"]+1;p=parse/@step["force"]["point"];
     If[!MemberQ[{1,2},k]||boxes[[k]]===None||!insideResidual[p,pol,rmin]||boxDist[p,boxes[[k]]]<=1,
       Throw[False]];
     AppendTo[assigned[[3-k]],p],
   Keys[step]=={"hole"},
     p=parse/@step["hole"];
     Throw[TrueQ[idx==Length[steps]&&FreeQ[boxes,None]&&insideResidual[p,pol,rmin]&&
       And@@(boxDist[p,#]>1&/@boxes)]],
   Keys[step]=={"conflict"},
     k=step["conflict"]["color"]+1;ids=step["conflict"]["indices"]+1;
     If[idx!=Length[steps]||!MemberQ[{1,2},k]||!MemberQ[{2,3},Length[ids]]||
       Length[DeleteDuplicates[ids]]!=Length[ids]||
       !And@@(IntegerQ[#]&&1<=#<=Length[assigned[[k]]]&/@ids),Throw[False]];
     Throw[TrueQ[conflict[assigned[[k,ids]]]]],
   True,Throw[False]],{idx,Length[steps]}];False]];

count=0;propCount=0;forcedCount=0;example=None;
Do[rr=rrs[[pn]];panel=data["panels"][[pn]];
 gate["P2_rank_coverage_panel_"<>ToString[pn],(#["rank"]&/@panel["cases"])===expected];
 r=ivb[rr];a=ArcSin[1/r];dd=9a-iv[Pi];
 caps={iv[2],1+2/Sqrt[iv[3]],1+Sqrt[iv[2]]};
 ff=Table[ww=Table[ArcCos[(iv[re]^2+cap^2-1)/(2iv[re]cap)],{re,rr}];
   width=ivb[{rat[Min[ww[[2]]]],rat[Max[ww[[1]]]]}];Max[0,rat[Min[(a-width)/dd]]],{cap,caps}];
 Do[b=Map[parse,entry["bounds"],{2}];f=parse/@entry["floors"];rank=entry["rank"];
   If[!TrueQ[And@@Thread[f<=ff]&&And@@(0<=#[[1]]<=#[[2]]<=1&/@b)&&
     dualOK[b,f,rank,entry["duals"]]],Print["FAIL parameter dual ",pn," ",rank];Exit[1]];
   pol=Map[parse,entry["polar"],{3}];computed=sectorCalc[rr,b];
   If[!TrueQ[And@@Flatten[Table[pol[[i,j,1]]<=computed[[i,j,1]]<=computed[[i,j,2]]<=pol[[i,j,2]],
      {i,9},{j,2}]]],Print["FAIL sector ",pn," ",rank];Exit[1]];
   Which[entry["leaf_type"]=="residual",
     pts=Map[parse,entry["leaf"]["points"],{2}];
     leafOK=And@@(insideResidual[#,pol,rr[[1]]]&/@pts)&&conflictReplay[pts,entry["leaf"]["conflict"]],
   entry["leaf_type"]=="propagation",
     leafOK=propReplay[pol,rr[[1]],entry["leaf"]];propCount++;
     forcedCount+=Count[Keys/@entry["leaf"]["steps"],{"force"}];
     If[example===None&&MemberQ[Keys/@entry["leaf"]["steps"],{"force"}],
       example=entry["leaf"];examplePolar=pol;exampleFloor=rr[[1]]],
   True,leafOK=False];
   If[!TrueQ[leafOK],Print["FAIL leaf ",pn," ",rank];Exit[1]];
   count++,{entry,panel["cases"]}];
 Print["new panel ",pn," : all 56 dual/sector/propagation leaves OK"],{pn,Length[rrs]}];
gate["P3_all_392_domains",count==392];
gate["P4_genuine_propagation_used",propCount==29&&forcedCount==201];
(* Negative controls are part of the WL run, not just Python tests. *)
bad=example;bad["steps"]=Most[bad["steps"]];
gate["P5_unfinished_derivation_rejected",!TrueQ[propReplay[examplePolar,exampleFloor,bad]]];
bad=example;st=bad["steps"];pos=First@First@Position[Keys/@st,{"bound"}];
bs=st[[pos]]["bound"];bc=bs["certificate"];ds=bc["duals"];ds[[1,1,2]]="-1";
bc["duals"]=ds;bs["certificate"]=bc;st[[pos]]=<|"bound"->bs|>;bad["steps"]=st;
gate["P6_negative_center_dual_rejected",!TrueQ[propReplay[examplePolar,exampleFloor,bad]]];
Print["propagation leaves = ",propCount,"; forced-point steps = ",forcedCount];
Print["CERTIFICATE OK (L3): all b9 domains excluded for 2.74<=R<=2.76; 16a replayed; combine 15b for R<2.74; sharp Rstar NOT proved"];
If[!TrueQ[$N11PropagationCertificateNoExit],Exit[0]];
