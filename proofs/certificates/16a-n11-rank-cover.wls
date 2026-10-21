#!/usr/bin/env wolframscript
(* Independent replay: all 56 rank cases per radius panel, exact LP duals,
   independent interval center sectors, and exact pair/triple conflict trees.
   No Python contractor, optimizer or success flag is trusted. *)
root=DirectoryName[DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]]];
file=FileNameJoin[{root,"experiments","2026-10-11-n11-b9-rank","results","rank-cover.json"}];
data=Import[file,"RawJSON"];wp=90;
parse[x_String]:=ToExpression[x];parse[x_]:=x;
iv[x_]:=N[Interval[{x,x}],wp];ivb[p_]:=N[Interval[p],wp];
rat[x_]:=Rationalize[x,0];
gates=<||>;gate[k_,v_]:=(gates[k]=TrueQ[v];Print[k," : ",gates[k]];If[!gates[k],Exit[1]]);
expected=Select[Tuples[Range[1,8],2],#[[1]]!=#[[2]]&];
rrs=(parse/@#["radii"])&/@data["panels"];
gate["R1_complete_radius_panels",Length[rrs]>0&&First[rrs][[1]]==69/25&&
 Last[rrs][[2]]==2786784686984/10^12&&And@@(#[[1]]<#[[2]]&/@rrs)&&
 And@@Table[rrs[[k,2]]==rrs[[k+1,1]],{k,Length[rrs]-1}]];

planes[f_,rank_]:=Module[{i=rank[[1]]+1,j=rank[[2]]+1,edges,mat},
 edges=Join[{{1,i},{i,j}},({j,#}&/@Complement[Range[2,9],{i,j}])];
 mat=Join[({#,0}&/@IdentityMatrix[18]),{{ConstantArray[1,18],1},{ConstantArray[-1,18],-1}},
   ({UnitVector[18,#[[1]]]-UnitVector[18,#[[2]]],0}&/@edges),
   MapThread[{UnitVector[18,#1],#2}&,{{1,i,j},f}]];mat];
dualOK[b_,f_,rank_,duals_]:=Catch[Module[{ps=planes[f,rank],ids,weights,lhs,rhs,k,side,sg},
 If[Length[duals]!=36,Throw[False]];
 Do[k=Quotient[n-1,2]+1;side=Mod[n-1,2]+1;sg=If[side==1,1,-1];
 ids=duals[[n,All,1]]+1;weights=parse/@duals[[n,All,2]];
 If[!And@@(IntegerQ[#]&&1<=#<=Length[ps]&/@ids)||!And@@(#>=0&/@weights),Throw[False]];
 lhs=weights.ps[[ids,1]];rhs=weights.ps[[ids,2]];
 If[lhs!=sg UnitVector[18,k]||rhs<sg b[[k,side]],Throw[False]],{n,36}];True]];
linRange[b_,co_]:=Module[{ext},ext[reverse_]:=Module[{x=b[[All,1]],spare,order,take},
 spare=1-Total[x];order=Ordering[co];If[reverse,order=Reverse[order]];
 Do[take=Min[spare,b[[k,2]]-x[[k]]];x[[k]]+=take;spare-=take,{k,order}];
 If[spare!=0,Return[$Failed]];co.x];{ext[False],ext[True]}];
sectorCalc[rr_,b_]:=Module[{r=ivb[rr],a,dd,t,radials,uv,loss,ff,ss,rads,rad,co,mass,angle,out={}},
 a=ArcSin[1/r];dd=9a-iv[Pi];t=Sqrt[r^2-1];
 Do[rads=Table[loss=dd iv[uv];
   ff=2Sin[loss/2]^2+t Sin[loss];ss=1+Cos[loss]-t Sin[loss];
   ff=ivb[{Max[0,rat[Min[ff]]],Min[1,rat[Max[ff]]]}];
   ss=ivb[{Max[1,rat[Min[ss]]],Min[2,rat[Max[ss]]]}];
   t Cos[loss]+Sin[loss]-Sqrt[ff ss],{uv,b[[j]]}];
 rad={Max[rr[[1]]-1,rat[Min[rads[[2]]]]],Min[rat[Max[t]],rat[Max[rads[[1]]]]]};
 If[j==1,angle={0,0},
   co=ConstantArray[0,18];co[[1]]=co[[j]]=1;
   Do[co[[i]]=2,{i,2,j-1}];Do[co[[9+i]]=2,{i,1,j-1}];
   mass=ivb[linRange[b,co]];angle=2(j-1)a-dd mass;angle={rat[Min[angle]],rat[Max[angle]]}];
 AppendTo[out,{rad,angle}],{j,9}];out];
distSector[p_,s_]:=Module[{nn=p.p,proj,m,closest},
 If[nn==0,Return[s[[1,1]]^2]];
 proj=Sqrt[iv[nn]] Cos[ivb[s[[2]]]-ArcTan[iv[p[[1]]],iv[p[[2]]]]];
 m=rat[Max[proj]];closest=Min[s[[1,2]],Max[s[[1,1]],m]];
 Max[0,nn+closest^2-2closest m]];
conflict[p_]:=Module[{ls,abc,cr},ls=(#.#&[(p[[#[[1]]]]-p[[#[[2]]]])])&/@Subsets[Range[Length[p]],{2}];
 If[Max[ls]>4,Return[True]];If[Length[p]==2,Return[False]];
 abc=Sort[ls];If[abc[[1]]+abc[[2]]<=abc[[3]],Return[False]];
 cr=Det[{p[[2]]-p[[1]],p[[3]]-p[[1]]}];Times@@abc>4cr^2];
conflictReplay[points_,certificate_]:=Module[{edges=certificate["edges"]+1,walk,col},
 If[!And@@(Length[#]>=2&&Length[#]<=3&&Length[DeleteDuplicates[#]]==Length[#]&&
    And@@(IntegerQ[#]&&1<=#<=Length[points]&/@#)&&conflict[points[[#]]]&/@edges),Return[False]];
 walk[node_,colors_]:=Catch[Module[{cc=colors,i,v,j,e,split,child},
   Do[{i,v,j}=step;i++;j++;
     If[!(1<=i<=Length[points]&&MemberQ[{0,1},v]&&1<=j<=Length[edges]),Throw[False]];
     e=edges[[j]];If[cc[[i]]!=-1||!MemberQ[e,i]||!And@@(cc[[#]]==1-v&/@DeleteCases[e,i]),Throw[False]];
     cc[[i]]=v,{step,node["forced"]}];
   If[KeyExistsQ[node,"conflict"],j=node["conflict"]+1;
     Throw[1<=j<=Length[edges]&&Length[DeleteDuplicates[cc[[edges[[j]]]]]]==1&&cc[[First[edges[[j]]]]]!=-1]];
   split=node["split"]+1;
   If[!(1<=split<=Length[points]&&cc[[split]]==-1&&Length[node["children"]]==2),Throw[False]];
   And@@Table[child=cc;child[[split]]=k;walk[node["children"][[k+1]],child],{k,0,1}]]];
 col=ConstantArray[-1,Length[points]];col[[1]]=0;TrueQ[walk[certificate["tree"],col]]];

count=0;minMargin=Infinity;
Do[rr=rrs[[pn]];panel=data["panels"][[pn]];
 gate["R2_rank_coverage_panel_"<>ToString[pn],(#["rank"]&/@panel["cases"])===expected];
 (* Recompute interval deficit floors independently, with a decimal-rational downward margin. *)
 r=ivb[rr];a=ArcSin[1/r];dd=9a-iv[Pi];
 caps={iv[2],1+2/Sqrt[iv[3]],1+Sqrt[iv[2]]};
 ff=Table[ww=Table[ArcCos[(iv[re]^2+cap^2-1)/(2iv[re]cap)],{re,rr}];
   width=ivb[{rat[Min[ww[[2]]]],rat[Max[ww[[1]]]]}];
   Max[0,rat[Min[(a-width)/dd]]],{cap,caps}];
 Do[b=Map[parse,entry["bounds"],{2}];f=parse/@entry["floors"];rank=entry["rank"];
   If[!TrueQ[And@@Thread[f<=ff]&&And@@(0<=#[[1]]<=#[[2]]<=1&/@b)&&
     dualOK[b,f,rank,entry["duals"]]],Print["FAIL dual ",pn," ",rank];Exit[1]];
   pol=Map[parse,entry["polar"],{3}];computed=sectorCalc[rr,b];
   If[!TrueQ[And@@Flatten[Table[pol[[i,j,1]]<=computed[[i,j,1]]<=computed[[i,j,2]]<=pol[[i,j,2]],
      {i,9},{j,2}]]],Print["FAIL sector enclosure ",pn," ",rank];Exit[1]];
   pts=Map[parse,entry["leaf"]["points"],{2}];
   margins=Flatten[Table[distSector[p,s]-1,{p,pts},{s,pol}]];
   If[!TrueQ[And@@(#.#<=rr[[1]]^2&/@pts)&&Min[margins]>0&&
     conflictReplay[pts,entry["leaf"]["conflict"]]],Print["FAIL residual ",pn," ",rank];Exit[1]];
   minMargin=Min[minMargin,Min[margins]];count++,{entry,panel["cases"]}];
 Print["panel ",pn," : 56 exact dual/sector/conflict leaves OK"],{pn,Length[rrs]}];
gate["R3_all_280_domains",count==280];
(* Loop failures must escape the full checker, not just terminate a Do. *)
lastEntry=Last[Last[data["panels"]]["cases"]];
neg=lastEntry["duals"];neg[[1,1,2]]="-1";
gate["R4_negative_rank_dual_rejected",!TrueQ[dualOK[b,f,rank,neg]]];
neg=lastEntry["leaf"]["conflict"];nt=neg["tree"];
nt["forced"]=Prepend[nt["forced"],{0,1,0}];neg["tree"]=nt;
gate["R5_reassigning_seed_rejected",!TrueQ[conflictReplay[pts,neg]]];
Print["minimum squared-distance residual margin >= ",N[minMargin,20]];
Print["CERTIFICATE OK (L3): all b9 rank domains excluded for 2.76<=R<=2.786784686984; combine 15b for R<2.76; sharp bound NOT proved"];
If[!TrueQ[$N11RankCertificateNoExit],Exit[0]];
