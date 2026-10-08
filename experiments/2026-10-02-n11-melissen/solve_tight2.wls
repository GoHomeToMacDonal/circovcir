#!/usr/bin/env wolframscript
(* The contact system has 2 internal DOF (rigidity_check.wls: rank 28, unknowns 30).
   So we PIN 2 shape params to float values and solve the remaining square system exactly
   at fixed R, yielding a high-precision representative of the 2-DOF record family, with all
   28 contacts tight. Pinned: v2 (p2 height) and v3 (p3 height). Usage: solve_tight2.wls [wp] *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
wp = If[Length[args] >= 1, ToExpression[args[[1]]], 60];

v2fix = SetPrecision[-9289097708348152/10^16, wp];   (* p2 y, pinned *)
v3fix = SetPrecision[2572115408013349/10^16, wp];    (* p3 y, pinned *)

S0 = {0, a}; S1 = {0, b}; S2 = {0, g};
p1 = {u1, v1}; p2 = {u2, v2fix}; p3 = {u3, v3fix}; p4 = {u4, v4};
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
unk = {a,b,g,u1,v1,u2,u3,u4,v4,R,
   xA,yA,xB,yB,xC,yC,xD,yD,yE,xF,yF,xG,yG,xH,yH,xI,yI,yJ};
seed = {-0.393246176,0.718386013,2.348820709,
   1.568569790,1.627191748,1.776631584,
   1.826451141,0.793616027,-2.009172889,2.6316907726,
   0.8306,0.1660,0.9975,-0.3021,0.5727,1.5360,0.9928,0.8096,-1.3932,
   0.9860,2.4400,2.4022,1.0748,2.6056,-0.3696,1.7904,-1.9288,-2.6317};
Print["#eqs=",Length[F],"  #unk=",Length[unk]];

sol = Quiet@FindRoot[Thread[F == 0], Transpose[{unk, seed}],
   WorkingPrecision -> wp, MaxIterations -> 500,
   AccuracyGoal -> wp - 8, PrecisionGoal -> wp - 8];
resid = Max[Abs[F /. sol]];
Print["max |contact residual| = ", InputForm[N[resid, 5]]];

centers = {{0, a}, {0, b}, {0, g}, {u1, v1}, {-u1, v1},
   {u2, v2fix}, {-u2, v2fix}, {u3, v3fix}, {-u3, v3fix}, {u4, v4}, {-u4, v4}} /. sol;
rho = CoveringRadius[centers, R, WorkingPrecision -> wp];
Print["R = ", InputForm[N[R, 20]]];
Print["CoveringRadius(c,R) = ", InputForm[N[rho, 30]], "   (want exactly 1)"];

dec[x_] := StringReplace[ToString[N[x, 40], InputForm, NumberMarks -> False], "*^" -> "e"];
out = <|"R" -> dec[R], "rho_at_R" -> dec[rho], "max_residual" -> dec[resid],
   "centers" -> Map[dec, centers, {2}]|>;
Export[FileNameJoin[{DirectoryName[ExpandFileName[$InputFileName]], "tight_solution.json"}], out, "RawJSON", "Compact" -> False];
Export["!cat", out, "RawJSON", "Compact" -> True];
