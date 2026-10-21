#!/usr/bin/env wolframscript
(* Centerwise slice-union certificates: exact supports + independent intervals.
   Reexecute previous full 17a/16a certificates, not their summary flags. *)
root=DirectoryName[DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]]];
$N11PropagationCertificateNoExit=True;
Get[FileNameJoin[{root,"proofs","certificates","17a-n11-propagation-cover.wls"}]];
file=FileNameJoin[{root,"experiments","2026-10-11-n11-b9-correlation","results","sliced-cover.json"}];
data=Import[file,"RawJSON"];
coeff[j_]:=Module[{co=ConstantArray[0,18]},co[[1]]=co[[j+1]]=1;
 Do[co[[i+1]]=2,{i,1,j-1}];Do[co[[10+i]]=2,{i,0,j-1}];co];
supportOK[ps_,co_,cert_]:=Catch[Module[{ran,d,ids,weights,lhs,rhs,sg},
 If[Sort[Keys[cert]]!={"duals","range"},Throw[False]];
 ran=parse/@cert["range"];
 If[Length[ran]!=2||ran[[1]]>ran[[2]]||Length[cert["duals"]]!=2,Throw[False]];
 Do[sg=If[n==1,1,-1];d=cert["duals"][[n]];
 ids=d[[All,1]]+1;weights=parse/@d[[All,2]];
 If[!And@@(IntegerQ[#]&&1<=#<=Length[ps]&/@ids)||!And@@(#>=0&/@weights),Throw[False]];
 lhs=weights.ps[[ids,1]];rhs=weights.ps[[ids,2]];
 If[lhs!=sg co||rhs<sg ran[[n]],Throw[False]],{n,2}];True]];
angleRange[rr_,j_,mass_]:=Module[{aa=ArcSin[1/ivb[rr]],vals},
 vals=Flatten[Table[(2j-9iv[m])iv[av]+iv[Pi]iv[m],
   {av,{rat[Min[aa]],rat[Max[aa]]}},{m,mass}]];
 {Min[rat[Min[#]]&/@vals],Max[rat[Max[#]]&/@vals]}];
radialRange[rr_,param_]:=Module[{r=ivb[rr],a,dd,t,rads,loss,ff,ss},
 a=ArcSin[1/r];dd=9a-iv[Pi];t=Sqrt[r^2-1];
 rads=Table[loss=dd iv[uv];
 ff=2Sin[loss/2]^2+t Sin[loss];ss=1+Cos[loss]-t Sin[loss];
 ff=ivb[{Max[0,rat[Min[ff]]],Min[1,rat[Max[ff]]]}];
 ss=ivb[{Max[1,rat[Min[ss]]],Min[2,rat[Max[ss]]]}];
 t Cos[loss]+Sin[loss]-Sqrt[ff ss],{uv,param}];
 {Max[rr[[1]]-1,rat[Min[rads[[2]]]]],Min[rat[Max[t]],rat[Max[rads[[1]]]]]}];
contained[saved_,computed_]:=Dimensions[saved]=={2,2}&&And@@Table[
 saved[[k,1]]<=computed[[k,1]]<=computed[[k,2]]<=saved[[k,2]],{k,2}];
intersect[s_,t_]:=Table[{Max[s[[k,1]],t[[k,1]]],Min[s[[k,2]],t[[k,2]]]},{k,2}];
slicedReplay[rr_,dom_,floors_]:=Catch[Module[{base=dom["root"],f,ps,sup,co,b,pol,computed,
 original,lo,hi,prev,pair,pp,sp,mass,sec,saved,result={},j,k},
 f=parse/@base["floors"];
 If[Length[f]!=3||!And@@Thread[0<=f]||!And@@Thread[f<=floors],Throw[$Failed]];
 ps=planes[f,base["rank"]];sup=base["supports"];
 If[Length[sup]!=26||Length[dom["pieces"]]!=9,Throw[$Failed]];
 Do[co=If[k<=18,UnitVector[18,k],coeff[k-18]];
 If[!TrueQ[supportOK[ps,co,sup[[k]]]],Throw[$Failed]],{k,26}];
 b=(parse/@#["range"])&/@Take[sup,18];
 If[!And@@(0<=#[[1]]<=#[[2]]<=1&/@b),Throw[$Failed]];
 pol=Map[parse,base["polar"],{3}];computed=sectorCalc[rr,b];
 Do[computed[[j+1,2]]=intersect[{{0,0},computed[[j+1,2]]},
   {{0,0},angleRange[rr,j,parse/@sup[[18+j]]["range"]]}][[2]],{j,1,8}];
 If[Dimensions[pol]!={9,2,2}||!And@@MapThread[contained,{pol,computed}],Throw[$Failed]];
 Do[{lo,hi}=b[[j+1]];prev=lo;
 If[Length[dom["pieces"][[j+1]]]<1,Throw[$Failed]];
 Do[pair=parse/@piece["parameter"];
 If[Length[pair]!=2||pair[[1]]!=prev||!(pair[[1]]<pair[[2]]<=hi),Throw[$Failed]];
 prev=pair[[2]];
 If[j==0,If[piece["support"]=!=Null,Throw[$Failed]];mass={0,0},
 pp=Join[ps,{{UnitVector[18,j+1],pair[[1]]},{-UnitVector[18,j+1],-pair[[2]]}}];
 sp=piece["support"];
 If[!TrueQ[supportOK[pp,coeff[j],sp]],Throw[$Failed]];mass=parse/@sp["range"]];
 sec={radialRange[rr,pair],If[j==0,{0,0},angleRange[rr,j,mass]]};
 sec=intersect[sec,pol[[j+1]]];saved=Map[parse,piece["sector"],{2}];
 If[!TrueQ[contained[saved,sec]],Throw[$Failed]];
 AppendTo[result,saved],{piece,dom["pieces"][[j+1]]}];
 If[prev!=hi,Throw[$Failed]],{j,0,8}];result]];

rrs=(parse/@#["radii"])&/@data["panels"];
gate["C1_contiguous_radius_coverage",Length[rrs]==2&&First[rrs][[1]]==273/100&&
 Last[rrs][[2]]==137/50&&And@@(#[[1]]<#[[2]]&/@rrs)&&
 And@@Table[rrs[[k,2]]==rrs[[k+1,1]],{k,Length[rrs]-1}]];
count=0;pieceCount=0;forceCount=0;
Do[rr=rrs[[pn]];panel=data["panels"][[pn]];
 gate["C2_all_ranks_panel_"<>ToString[pn],(#["domain"]["root"]["rank"]&/@panel["cases"])===expected];
 r=ivb[rr];a=ArcSin[1/r];dd=9a-iv[Pi];caps={iv[2],1+2/Sqrt[iv[3]],1+Sqrt[iv[2]]};
 ff=Table[ww=Table[ArcCos[(iv[re]^2+cap^2-1)/(2iv[re]cap)],{re,rr}];
 width=ivb[{rat[Min[ww[[2]]]],rat[Max[ww[[1]]]]}];Max[0,rat[Min[(a-width)/dd]]],{cap,caps}];
 Do[pol=slicedReplay[rr,entry["domain"],ff];
 If[pol===$Failed,Print["FAIL slice enclosure ",pn," ",entry["domain"]["root"]["rank"]];Exit[1]];
 If[!TrueQ[propReplay[pol,rr[[1]],entry["leaf"]]],Print["FAIL leaf ",pn];Exit[1]];
 count++;pieceCount+=Length[pol];forceCount+=Count[Keys/@entry["leaf"]["steps"],{"force"}],
 {entry,panel["cases"]}];Print["correlated panel ",pn," : 56 domains OK"],{pn,Length[rrs]}];
gate["C3_all_112_domains",count==112];
lastEntry=Last[Last[data["panels"]]["cases"]];
bad=lastEntry["domain"];bad["pieces"]=ReplacePart[bad["pieces"],2->{}];
gate["C4_missing_center_partition_rejected",slicedReplay[Last[rrs],bad,ff]===$Failed];
bad=lastEntry["domain"];base=bad["root"];ss=base["supports"];s=ss[[19]];ddx=s["duals"];
ddx[[1,1,2]]="-1";s["duals"]=ddx;ss[[19]]=s;base["supports"]=ss;bad["root"]=base;
gate["C5_negative_angular_dual_rejected",slicedReplay[Last[rrs],bad,ff]===$Failed];
bad=lastEntry["domain"];parts=bad["pieces"];part=parts[[2,1]];
pr=parse/@part["parameter"];part["parameter"]={ToString[InputForm[pr[[1]]+1/10^6]],
 ToString[InputForm[pr[[2]]]]};parts[[2,1]]=part;bad["pieces"]=parts;
gate["C6_radial_partition_gap_rejected",slicedReplay[Last[rrs],bad,ff]===$Failed];
bad=lastEntry["domain"];parts=bad["pieces"];part=parts[[2,1]];
part["sector"]={{"0","0"},{"0","0"}};parts[[2,1]]=part;bad["pieces"]=parts;
gate["C7_false_slice_sector_rejected",slicedReplay[Last[rrs],bad,ff]===$Failed];
Print["total sector pieces = ",pieceCount,"; forced points = ",forceCount];
Print["CERTIFICATE OK (L3): all b9 R < 2.73; 17a/16a replayed, combine separately rerun 15b; sharp Rstar NOT proved"];
If[!TrueQ[$N11SlicedCertificateNoExit],Exit[0]];
