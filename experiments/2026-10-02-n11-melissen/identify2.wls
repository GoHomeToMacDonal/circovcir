#!/usr/bin/env wolframscript
(* Honest algebraic identification: a GENUINE algebraic number of low degree has a minimal
   polynomial with SMALL integer coefficients. RootApproximant will always return *a* rational
   / algebraic that matches to the given precision, but if its coefficients are astronomically
   large that is a spurious lattice fit, NOT a closed form. So we use FindIntegerNullVector on
   the power basis {1,x,...,x^deg} at HIGH precision and REPORT the max |coefficient|: accept
   only when it is small (say < 10^9) AND the relation holds to near full precision.

   Reads the high-precision R and coords by re-solving the tight system (same as identify.wls).
   Usage: identify2.wls [wp] [maxdeg] [heightcap_log10] *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
wp     = If[Length[args] >= 1, ToExpression[args[[1]]], 160];
maxdeg = If[Length[args] >= 2, ToExpression[args[[2]]], 10];
hcap   = If[Length[args] >= 3, ToExpression[args[[3]]], 12];  (* accept |coeff| < 10^hcap *)

u2f0 = 1.7727361647947986; v2f0 = -0.9363224068547157;
solveAt[U_, V_, prec_] := Module[
  {a,b,g,u1,v1,u3,v3,u4,v4,R,xA,yA,xB,yB,xC,yC,xD,yD,yE,xF,yF,xG,yG,xH,yH,xI,yI,yJ,
   S0,S1,S2,p1,p2,p3,p4,sq,F,unk,seed,sol},
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
  seed={-0.393250,0.718392,2.348841,1.575353,1.620626,1.827510,0.249580,0.785217,-2.012470,
     2.6316908,0.83,0.17,0.99,-0.30,0.57,1.54,0.99,0.81,-1.39,0.98,2.44,2.40,1.07,2.60,-0.37,1.79,-1.93,-2.63};
  sol=Quiet@FindRoot[Thread[F==0],Transpose[{unk,seed}],WorkingPrecision->prec,
     MaxIterations->600,AccuracyGoal->prec-10,PrecisionGoal->prec-10];
  <|"R"->(R/.sol),"params"->({a,b,g,u1,v1,u3,v3,u4,v4}/.sol)|>];
RofHP[U_?NumericQ,V_?NumericQ]:=solveAt[SetPrecision[U,wp],SetPrecision[V,wp],wp]["R"];

mx = FindMaximum[RofHP[uu,vv], {{uu,u2f0,u2f0+10^-6},{vv,v2f0,v2f0+10^-6}},
   WorkingPrecision->wp, MaxIterations->120, PrecisionGoal->wp/2, AccuracyGoal->wp/2];
{Uopt,Vopt}={uu,vv}/.Last[mx];
res = solveAt[Uopt,Vopt,wp]; R = res["R"]; params = res["params"];

(* integer-relation minimal polynomial with height report *)
idf[x_, name_] := Module[{v=N[x,wp-20], rel, cmax, pol, chk, deg},
  Do[
    rel = Quiet@FindIntegerNullVector[Table[v^k, {k,0,deg}]];
    If[ListQ[rel] && Length[rel]==deg+1,
      cmax = Max[Abs[rel]];
      pol = Sum[rel[[k+1]] X^k, {k,0,deg}];
      chk = Abs[N[(pol /. X->v), 20]];
      If[cmax < 10^hcap && chk < 10^(-(wp-40)),
        Print[name, ": deg ", deg, "  max|coeff|=", cmax, "  check=", InputForm[chk]];
        Print["   minpoly: ", InputForm[pol]];
        rr = Quiet@Select[X /. Solve[pol==0, X], Abs[#-v]<10^-20 &];
        If[rr=!={}, Print["   radicals: ", InputForm[Quiet@ToRadicals[RootReduce[First[rr]]]]]];
        Return[pol, Module]]],
    {deg,1,maxdeg}];
  Print[name, ": NO low-height match (deg<=", maxdeg, ", |coeff|<10^", hcap, ") -> not a modest algebraic number"];
  $Failed];

Print["R ~ ", InputForm[N[R,40]]];
Print["\n=== R^2 ==="]; idf[R^2,"R^2"];
Print["=== R ===";]; idf[R,"R"];
Print["=== params ==="];
MapThread[idf[#1,#2]&, {params, {"a","b","g","u1","v1","u3","v3","u4","v4"}}];
idf[Uopt,"u2"]; idf[Vopt,"v2"];
