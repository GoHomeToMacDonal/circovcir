#!/usr/bin/env wolframscript
(* Independent exact event-chamber enumeration, no Python order trusted. *)
root=DirectoryName[DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]]];
$N11SlicedCertificateNoExit=True;
Get[FileNameJoin[{root,"proofs","certificates","18a-n11-sliced-cover.wls"}]];
file=FileNameJoin[{root,"experiments","2026-10-11-n11-b9-separation","results","separated-cover.json"}];
data=Import[file,"RawJSON"];
separatedReplay[input_,cert_]:=Catch[Module[{pts=Sort[DeleteDuplicates[input]],edges,
 chambers,events,slopes,order,pos,pair,aa,bb},
 If[cert["kind"]=="covered",
   If[Length[cert["centers"]]!=2,Throw[False]];
   cc=Map[parse,cert["centers"],{2}];
   Throw[And@@Table[Min[(#.#& /@ ((p-#)& /@ cc))]<=1,{p,pts}]]];
 If[Sort[Keys[cert]]!={"chambers","edges","kind"}||cert["kind"]!="excluded"||Length[pts]==0,
   Throw[False]];
 edges=cert["edges"]+1;chambers=cert["chambers"]+1;
 If[Length[edges]==0||!And@@(MemberQ[{2,3},Length[#]]&&
 Length[DeleteDuplicates[#]]==Length[#]&&And@@(IntegerQ[#]&&1<=#<=Length[pts]&/@#)&&
 conflict[pts[[#]]]&/@edges),Throw[False]];
 events=Sort[DeleteDuplicates[Cases[Table[
 If[pts[[i,2]]==pts[[j,2]],Nothing,-(pts[[i,1]]-pts[[j,1]])/(pts[[i,2]]-pts[[j,2]])],
 {i,Length[pts]},{j,i+1,Length[pts]}]//Flatten,_Integer|_Rational]]];
 slopes=If[events=={},{0},Join[{First[events]-1},
 Table[(events[[k]]+events[[k+1]])/2,{k,Length[events]-1}],{Last[events]+1}]];
 If[Length[chambers]!=Length[slopes],Throw[False]];
 Do[order=Ordering[(#[[1]]+slopes[[k]]#[[2]])&/@pts];pos=Ordering[order];pair=chambers[[k]];
 If[Length[pair]!=2||!And@@(IntegerQ[#]&&1<=#<=Length[edges]&/@pair),Throw[False]];
 {aa,bb}=edges[[pair]];
 If[Max[pos[[aa]]]>Min[pos[[bb]]],Throw[False]],{k,Length[slopes]}];True]];
rrs=(parse/@#["radii"])&/@data["panels"];
gate["D1_contiguous_radius_coverage",Length[rrs]==1&&First[rrs][[1]]==109/40&&
 Last[rrs][[2]]==273/100&&And@@(#[[1]]<#[[2]]&/@rrs)];
count=0;chamberCount=0;pointCount=0;
Do[rr=rrs[[pn]];panel=data["panels"][[pn]];
 gate["D2_all_ranks_panel_"<>ToString[pn],(#["domain"]["root"]["rank"]&/@panel["cases"])===expected];
 r=ivb[rr];a=ArcSin[1/r];dd=9a-iv[Pi];caps={iv[2],1+2/Sqrt[iv[3]],1+Sqrt[iv[2]]};
 ff=Table[ww=Table[ArcCos[(iv[re]^2+cap^2-1)/(2iv[re]cap)],{re,rr}];
 width=ivb[{rat[Min[ww[[2]]]],rat[Max[ww[[1]]]]}];Max[0,rat[Min[(a-width)/dd]]],{cap,caps}];
 Do[pol=slicedReplay[rr,entry["domain"],ff];leaf=entry["leaf"];
 If[pol===$Failed,Print["FAIL domain ",entry["domain"]["root"]["rank"]];Exit[1]];
 pts=Map[parse,leaf["points"],{2}];
 If[!TrueQ[leaf["status"]=="excluded"&&leaf["decision"]["kind"]=="excluded"&&
 And@@(insideResidual[#,pol,rr[[1]]]&/@pts)&&separatedReplay[pts,leaf["decision"]]],
 Print["FAIL separated leaf ",entry["domain"]["root"]["rank"]];Exit[1]];
 count++;chamberCount+=Length[leaf["decision"]["chambers"]];pointCount+=Length[pts],
 {entry,panel["cases"]}];Print["separated panel ",pn," : 56 domains OK"],{pn,Length[rrs]}];
gate["D3_all_56_domains",count==56];
last=Last[Last[data["panels"]]["cases"]]["leaf"];
bad=last["decision"];bad["chambers"]=Most[bad["chambers"]];
gate["D4_missing_chamber_rejected",!TrueQ[separatedReplay[Map[parse,last["points"],{2}],bad]]];
bad=last["decision"];ee=bad["edges"];ee[[1]]={0,0};bad["edges"]=ee;
gate["D5_fake_conflict_rejected",!TrueQ[separatedReplay[Map[parse,last["points"],{2}],bad]]];
(* Positive finite cover is also checked directly, never confused with exclusion. *)
gate["D6_exact_tangent_finite_cover",separatedReplay[{{0,0},{2,0},{4,0}},
 <|"kind"->"covered","centers"->{{"1","0"},{"3","0"}}|>]];
gate["D7_fake_positive_cover_rejected",!TrueQ[separatedReplay[{{0,0},{3,0}},
 <|"kind"->"covered","centers"->{{"100","0"},{"100","0"}}|>]]];
diag=Import[FileNameJoin[{root,"experiments","2026-10-11-n11-b9-separation","results",
 "finite-covered-diagnostics.json"}],"RawJSON"];
gate["D8_nine_positive_finite_diagnostics",Length[diag["records"]]==9&&And@@Table[
 dl=rec["leaf"];dl["status"]=="unresolved"&&dl["decision"]["kind"]=="covered"&&
 separatedReplay[Map[parse,dl["points"],{2}],dl["decision"]],{rec,diag["records"]}]];
Print["total certified points = ",pointCount,"; exact chambers = ",chamberCount];
Print["CERTIFICATE OK (L3): all b9 R < 2.725; 18a/17a/16a replayed, combine separately rerun 15b; sharp Rstar NOT proved"];
If[!TrueQ[$N11SeparatedCertificateNoExit],Exit[0]];
