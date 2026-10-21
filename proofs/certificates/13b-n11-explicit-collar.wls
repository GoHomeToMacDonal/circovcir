#!/usr/bin/env wolframscript
(* Explicit full-coordinate collar, not just a KKT root box.
   The augmented objective P = R - lambda.h - (h.h)/2 - gauge^2/2 is
   strongly concave on a fixed rational box. For feasible h<=0, |h|<2lambda
   and gauge=0, P>=R. This proves R <= Rstar in the entire box. *)
root=DirectoryName[DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]]];
$N11CertificateNoExit=True;
Get[FileNameJoin[{root,"proofs","certificates","07-n11-local-opt.wls"}]];
collarOK=<||>;
gate[k_,v_]:=(collarOK[k]=TrueQ[v];Print[k," : ",collarOK[k]]);
enc[x_]:=N[Interval[{x,x}],100];
absup[x_]:=Max[Abs[x]];
(* Fixed rational center rounded to 20 decimal places, independent of display precision. *)
zc=(Round[10^20 Rationalize[(Min[#]+Max[#])/2,0]]/10^20)&/@zX;
boxRadius=1/500000;
Z=Table[N[Interval[{zc[[i]]-boxRadius,zc[[i]]+boxRadius}],100],{i,23}];
ruleZ=Thread[zv->Z];
gate["L1_root_strictly_inside_collar",And@@MapThread[inside,{zX,Z}]];
gate["L2_fixed_gauge_at_root",zc[[5]]==0&&Min[zX[[5]]]==0&&Max[zX[[5]]]==0];

(* Exact matrix comparison: K3 midpoint minus eta I is positive definite. *)
eta=1/25;
gate["L3_exact_reference_margin",PositiveDefiniteMatrixQ[mid-eta IdentityMatrix[23]]&&
 And@@Table[Det[(mid-eta IdentityMatrix[23])[[;;k,;;k]]]>0,{k,23}]];
Pexpr=RR-lamFX.h-Total[h^2]/2-zv[[5]]^2/2;
HP=D[Pexpr,{zv,2}]/.ruleZ;
err=Max[Table[Sum[Rationalize[absup[HP[[i,j]]+enc[mid[[i,j]]]],0],{j,23}],{i,23}]];
(* A deliberately rational margin, checked over every point of the box. *)
mu=7/500;
gate["L4_uniform_strong_concavity",TrueQ[err<eta-mu]];
Print["L4 row-sum perturbation bound (rounded display) = ",InputForm[N[err,40]],"; certified mu = ",mu];
hZ=h/.ruleZ;
gate["L5_feasible_penalty_sign",And@@Table[absup[hZ[[i]]]<2Min[lamFX[[i]]],{i,18}]];
Print["L5 max absolute constraint = ",InputForm[Max[absup/@hZ]]];

(* Geometry for COVERAGE => h<=0 over the whole collar, not just at the root.
   Interior circumcenters and boundary bisector-circle intersections must be
   in the target disk and separated from all nongenerating centers. *)
interiorChecks={};boundaryChecks={};
Do[
 g=act[[t,2]];
 If[Length[g]==3,
   tri=cross[cen[g[[2]]]-cen[g[[1]]],cen[g[[3]]]-cen[g[[1]]]]/.ruleZ;
   p=ccenter@@g/.ruleZ;
   others=Complement[Range[11],g];
   AppendTo[interiorChecks,Min[Abs[tri]]>0&&Min[(RR^2-p.p)/.ruleZ]>0&&
     And@@Table[Min[dist2[p,i]/.ruleZ]>1,{i,others}]],
   (* e points along the outer half of the perpendicular bisector; X lies
      EXACTLY on the target circle for every real configuration in the box. *)
   i=g[[1]];j=g[[2]];sg=sgn[i,j];
   m=(cen[i]+cen[j])/2;ww=wperp[i,j];
   ee=sg ww/Sqrt[ww.ww];tt=m.ee;
   disc=tt^2+RR^2-m.m;
   kk=-tt+Sqrt[disc];xx=m+kk ee;
   ll2=(cen[i]-cen[j]).(cen[i]-cen[j]);
   others=Complement[Range[11],g];
   pairChecks={Min[ll2/.ruleZ]>0,Max[ll2/.ruleZ]<4,
     Min[disc/.ruleZ]>0,Min[kk/.ruleZ]>0,
     Min[(tt+Sqrt[1-ll2/4])/.ruleZ]>0,
     And@@Table[Min[dist2[xx,k]/.ruleZ]>1,{k,others}]};
   AppendTo[boundaryChecks,And@@pairChecks]
 ],{t,18}];
gate["L6_all_interior_coverage_implications",And@@interiorChecks];
gate["L7_all_boundary_coverage_implications",And@@boundaryChecks];
Print["collar center (exact rational) = ",InputForm[zc]];
Print["collar coordinate radius = ",boxRadius];
Print["ALL COLLAR: ",collarOK];
If[And@@Values[collarOK],Print["CERTIFICATE OK (L3): explicit 23-coordinate collar, R <= Rstar; global localization NOT proved"];Exit[0],Exit[1]];
