#!/usr/bin/env wolframscript
(* High-precision (wp given) recompute of the R-maximising tight member, then try to identify
   R and each coordinate as an algebraic number via RootApproximant at increasing degree.
   The 2 DOF are fixed by d R / d(p2) = 0; we locate that stationary p2 at high precision by
   solving the enlarged system {28 contacts} U {dR/du2 = 0, dR/dv2 = 0} with FindRoot, where
   R and p2 are all unknowns (30 eqs, 30 unknowns -> square, rigid at the optimum).
   Usage: identify.wls [wp] [maxdeg] *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
wp = If[Length[args] >= 1, ToExpression[args[[1]]], 120];
maxdeg = If[Length[args] >= 2, ToExpression[args[[2]]], 12];

(* unknowns: 11 params + R + 18 tight-pt coords = 30 ; equations: 28 contacts + 2 stationarity.
   Stationarity dR/d p2 = 0: at the optimum, perturbing p2 keeps R critical. We encode it as
   the Lagrange condition that the gradient of the "min contact" is balanced -- but simplest &
   robust: add the two equations that the two BND points touching p2 (H: p2,p3 and I: p2,p4)
   are SYMMETRIC in a way forcing stationarity is hard to write directly. Instead we get the
   stationary p2 numerically by the outer max (as before) at HIGH precision, then solve the
   28x28 inner system at wp for clean digits. *)

u2f0 = 1.7727361647947986; v2f0 = -0.9363224068547157;  (* machine optimum from solve_tight_opt *)

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
     2.6316908,0.83,0.17,0.99,-0.30,0.57,1.54,0.99,0.81,-1.39,
     0.98,2.44,2.40,1.07,2.60,-0.37,1.79,-1.93,-2.63};
  sol=Quiet@FindRoot[Thread[F==0],Transpose[{unk,seed}],WorkingPrecision->prec,
     MaxIterations->600,AccuracyGoal->prec-10,PrecisionGoal->prec-10];
  <|"R"->(R/.sol),"p2"->{U,V},
    "centers"->({{0,a},{0,b},{0,g},{u1,v1},{-u1,v1},{U,V},{-U,V},
       {u3,v3},{-u3,v3},{u4,v4},{-u4,v4}}/.sol),
    "params"->({a,b,g,u1,v1,u3,v3,u4,v4}/.sol)|>];

RofHP[U_?NumericQ, V_?NumericQ] := solveAt[SetPrecision[U,wp], SetPrecision[V,wp], wp]["R"];

(* refine the optimum p2 at high precision: dR/dU = dR/dV = 0 by FindMaximum restarted hi-prec *)
mx = FindMaximum[RofHP[uu, vv], {{uu, u2f0, u2f0 + 10^-6}, {vv, v2f0, v2f0 + 10^-6}},
   WorkingPrecision -> wp, MaxIterations -> 100, PrecisionGoal -> wp/2, AccuracyGoal -> wp/2];
{Uopt, Vopt} = {uu, vv} /. Last[mx];
res = solveAt[Uopt, Vopt, wp];
R = res["R"]; params = res["params"]; centers = res["centers"];
Print["R (", wp, " digits) = "]; Print[InputForm[N[R, wp - 10]]];

(* identify helper: try RootApproximant at degrees 1..maxdeg, accept when residual < 10^-(wp/2) *)
idf[x_, name_] := Module[{val = N[x, wp - 15], r, res2, deg},
  Do[
    r = Quiet@RootApproximant[val, deg];
    res2 = Quiet@N[Abs[r - val], 20];
    If[NumericQ[res2] && res2 < 10^(-(wp - 30)),
       Print[name, ": deg ", deg, "  residual ", InputForm[res2]];
       Print["   minpoly: ", InputForm[MinimalPolynomial[r, X]]];
       Print["   radicals: ", InputForm[Quiet@ToRadicals[r]]];
       Return[r, Module]],
    {deg, 1, maxdeg}];
  Print[name, ": no algebraic match up to deg ", maxdeg, " (residual stays > 10^-", wp-30, ")"];
  $Failed];

Print["\n=== identify R^2 (often cleaner than R) ==="];
idf[R^2, "R^2"];
Print["\n=== identify R ==="];
idf[R, "R"];
Print["\n=== identify params (a,b,g,u1,v1,u3,v3,u4,v4, p2) ==="];
names = {"a(c0y)","b(c8y)","g(c9y)","u1","v1","u3","v3","u4","v4"};
MapThread[idf[#1, #2] &, {params, names}];
idf[Uopt, "u2"]; idf[Vopt, "v2"];
