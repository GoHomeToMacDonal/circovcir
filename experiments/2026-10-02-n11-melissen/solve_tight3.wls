#!/usr/bin/env wolframscript
(* n=11 tight-contact solve. rigidity_check.wls established the contact system is full-rank
   with exactly 2 internal DOF (the record cover is FLEXIBLE, not rigid). So we pin 2 DOF
   (p2 = (u2,v2) held at float values) and solve the remaining square 28x28 system for the
   other 9 params + R + 18 tight-point coords, giving a high-precision exact-tight member of
   the 2-DOF family. Usage: solve_tight3.wls [wp] *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
wp = If[Length[args] >= 1, ToExpression[args[[1]]], 60];

u2f = SetPrecision[17766315841744449/10^16, wp];   (* p2 pinned *)
v2f = SetPrecision[-9289097708348152/10^16, wp];

S0 = {0, a}; S1 = {0, b}; S2 = {0, g};
p1 = {u1, v1}; p2 = {u2f, v2f}; p3 = {u3, v3}; p4 = {u4, v4};
sq[u_, c_] := (u - c) . (u - c);
XiA={xA,yA};XiB={xB,yB};XiC={xC,yC};XiD={xD,yD};XiE={0,yE};
XbF={xF,yF};XbG={xG,yG};XbH={xH,yH};XbI={xI,yI};XbJ={0,yJ};

F = {
  sq[XiA,S0]-1, sq[XiA,S1]-1, sq[XiA,p3]-1,
  sq[XiB,S0]-1, sq[XiB,p2]-1, sq[XiB,p3]-1,
  sq[XiC,S1]-1, sq[XiC,S2]-1, sq[XiC,p1]-1,
  sq[XiD,S1]-1, sq[XiD,p1]-1, sq[XiD,p3]-1,
  sq[XiE,S0]-1, sq[XiE,p4]-1,
  sq[XbF,S2]-1, sq[XbF,p1]-1, XbF.XbF-R^2,
  sq[XbG,p1]-1, sq[XbG,p3]-1, XbG.XbG-R^2,
  sq[XbH,p2]-1, sq[XbH,p3]-1, XbH.XbH-R^2,
  sq[XbI,p2]-1, sq[XbI,p4]-1, XbI.XbI-R^2,
  sq[XbJ,p4]-1, XbJ.XbJ-R^2
};
unk = {a,b,g,u1,v1,u3,v3,u4,v4,R,
   xA,yA,xB,yB,xC,yC,xD,yD,yE,xF,yF,xG,yG,xH,yH,xI,yI,yJ};
seed = {-0.393246176,0.718386013,2.348820709,
   1.568569790,1.627191748,1.826451141,0.257211541,0.793616027,-2.009172889,2.6316907726,
   0.8306,0.1660,0.9975,-0.3021,0.5727,1.5360,0.9928,0.8096,-1.3932,
   0.9860,2.4400,2.4022,1.0748,2.6056,-0.3696,1.7904,-1.9288,-2.6317};
Print["#eqs=", Length[F], "  #unk=", Length[unk]];
If[Length[F] =!= Length[unk], Print["NOT SQUARE -- abort"]; Exit[1]];

sol = Quiet@FindRoot[Thread[F == 0], Transpose[{unk, seed}],
   WorkingPrecision -> wp, MaxIterations -> 500,
   AccuracyGoal -> wp - 8, PrecisionGoal -> wp - 8];
If[Head[sol] =!= List || ! AllTrue[sol, MatchQ[#, _ -> _?NumericQ] &],
   Print["FindRoot did not return numeric rules -- abort"]; Exit[1]];

resid = Max[Abs[F /. sol]];
pv = {a,b,g,u1,v1,u3,v3,u4,v4} /. sol;  Rval = R /. sol;
centers = {{0,a},{0,b},{0,g},{u1,v1},{-u1,v1},{u2f,v2f},{-u2f,v2f},
   {u3,v3},{-u3,v3},{u4,v4},{-u4,v4}} /. sol;
rho = CoveringRadius[centers, Rval, WorkingPrecision -> wp];
Print["solved R = ", InputForm[N[Rval,30]]];
Print["CoveringRadius(c,R) = ", InputForm[N[rho,30]], "  (want exactly 1)"];
Print["max |contact residual| = ", InputForm[N[resid,5]]];

dec[x_] := StringReplace[ToString[N[x,40],InputForm,NumberMarks->False], "*^"->"e"];
out = <|"R"->dec[Rval], "rho_at_R"->dec[rho], "max_residual"->dec[resid],
   "centers"->Map[dec,centers,{2}]|>;
Export[FileNameJoin[{DirectoryName[ExpandFileName[$InputFileName]],"tight_solution.json"}], out, "RawJSON","Compact"->False];
Export["!cat", out, "RawJSON","Compact"->True];
