#!/usr/bin/env wolframscript
(* The contact system has 2 DOF, and R varies over the family (solve_tight3: pinning p2 at
   the float value gave R=2.63145 < baseline). So the record config is the member that
   MAXIMISES R. We treat the 2 free coords (u2,v2)=p2 as the family parameters: for given
   (u2,v2) the remaining 28x28 tight system fixes R(u2,v2); maximise R over (u2,v2).
   This pins the 2 DOF by optimality and yields a unique high-precision config. Usage: [wp] *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
wp = If[Length[args] >= 1, ToExpression[args[[1]]], 50];

(* solve the square tight system for a given numeric (U,V)=p2; return <|R, params, centers|> *)
Clear[solveAt];
solveAt[U_?NumericQ, V_?NumericQ, prec_] := Module[
  {S0,S1,S2,p1,p2,p3,p4,sq,F,unk,seed,sol,
   a,b,g,u1,v1,u3,v3,u4,v4,R,xA,yA,xB,yB,xC,yC,xD,yD,yE,xF,yF,xG,yG,xH,yH,xI,yI,yJ},
  S0={0,a};S1={0,b};S2={0,g};p1={u1,v1};p2={U,V};p3={u3,v3};p4={u4,v4};
  sq[u_,c_]:=(u-c).(u-c);
  F={sq[{xA,yA},S0]-1,sq[{xA,yA},S1]-1,sq[{xA,yA},p3]-1,
     sq[{xB,yB},S0]-1,sq[{xB,yB},p2]-1,sq[{xB,yB},p3]-1,
     sq[{xC,yC},S1]-1,sq[{xC,yC},S2]-1,sq[{xC,yC},p1]-1,
     sq[{xD,yD},S1]-1,sq[{xD,yD},p1]-1,sq[{xD,yD},p3]-1,
     sq[{0,yE},S0]-1,sq[{0,yE},p4]-1,
     sq[{xF,yF},S2]-1,sq[{xF,yF},p1]-1,{xF,yF}.{xF,yF}-R^2,
     sq[{xG,yG},p1]-1,sq[{xG,yG},p3]-1,{xG,yG}.{xG,yG}-R^2,
     sq[{xH,yH},p2]-1,sq[{xH,yH},p3]-1,{xH,yH}.{xH,yH}-R^2,
     sq[{xI,yI},p2]-1,sq[{xI,yI},p4]-1,{xI,yI}.{xI,yI}-R^2,
     sq[{0,yJ},p4]-1,{0,yJ}.{0,yJ}-R^2};
  unk={a,b,g,u1,v1,u3,v3,u4,v4,R,xA,yA,xB,yB,xC,yC,xD,yD,yE,xF,yF,xG,yG,xH,yH,xI,yI,yJ};
  seed={-0.393246,0.718386,2.348821,1.568570,1.627192,1.826451,0.257212,0.793616,-2.009173,
     2.6316908,0.8306,0.1660,0.9975,-0.3021,0.5727,1.5360,0.9928,0.8096,-1.3932,
     0.9860,2.4400,2.4022,1.0748,2.6056,-0.3696,1.7904,-1.9288,-2.6317};
  sol=Quiet@FindRoot[Thread[F==0],Transpose[{unk,seed}],WorkingPrecision->prec,
     MaxIterations->400,AccuracyGoal->prec-8,PrecisionGoal->prec-8];
  <|"R"->(R/.sol),
    "centers"->({{0,a},{0,b},{0,g},{u1,v1},{-u1,v1},{U,V},{-U,V},
       {u3,v3},{-u3,v3},{u4,v4},{-u4,v4}}/.sol)|>];

Rof[U_?NumericQ, V_?NumericQ] := solveAt[U, V, MachinePrecision]["R"];

(* maximise R over the 2 DOF (p2 coords), seeded at the float p2 *)
mx = FindMaximum[Rof[uu, vv],
   {{uu, 1.7766, 1.7780}, {vv, -0.9289, -0.9270}},
   MaxIterations -> 200];
{Uopt, Vopt} = {uu, vv} /. Last[mx];
Print["max R (machine) = ", InputForm[First[mx]], "  at p2=(", InputForm[Uopt], ",", InputForm[Vopt], ")"];

res = solveAt[SetPrecision[Uopt, wp], SetPrecision[Vopt, wp], wp];
Rval = res["R"]; centers = res["centers"];
rho = CoveringRadius[centers, Rval, WorkingPrecision -> wp];
Print["final R = ", InputForm[N[Rval, 30]]];
Print["CoveringRadius(c,R) = ", InputForm[N[rho, 30]], "  (want 1)"];

dec[x_] := StringReplace[ToString[N[x,40],InputForm,NumberMarks->False], "*^"->"e"];
out = <|"R"->dec[Rval], "rho_at_R"->dec[rho],
   "p2_opt"->{dec[Uopt],dec[Vopt]}, "centers"->Map[dec,centers,{2}]|>;
Export[FileNameJoin[{DirectoryName[ExpandFileName[$InputFileName]],"tight_optimal.json"}], out, "RawJSON","Compact"->False];
Export["!cat", out, "RawJSON","Compact"->True];
