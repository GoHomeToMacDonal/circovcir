#!/usr/bin/env wolframscript
(* Scale-PINNED symmetric polish. The scale degeneracy of min rho(c,1) is removed by FIXING
   the top on-axis center g = c9_y at its seed value; the other 10 symmetric params are free.
   Minimising rho(c,1) at fixed scale lands in the Melissen basin, not the trivial collapse.
   Then rescale so UNIT disks cover D(0,R), R = g_fixed_scale / rho... reported via rho.
   Usage: polish_pinned.wls [wp] *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
wp = If[Length[args] >= 1, ToExpression[args[[1]]], 50];

(* g (c9_y) is FIXED; free params: a,b, u1,v1,u2,v2,u3,v3,u4,v4 (10) *)
gFix = 2.3488207091;
centersOf[{a_, b_, u1_, v1_, u2_, v2_, u3_, v3_, u4_, v4_}] := {
   {0, a}, {0, b}, {0, gFix},
   { u1, v1}, {-u1, v1}, { u2, v2}, {-u2, v2},
   { u3, v3}, {-u3, v3}, { u4, v4}, {-u4, v4}};

seed = {-0.3932461761, 0.7183860132,
         1.5753389003, 1.6206117513, 1.7727207014, -0.9363142301,
         1.8274936095, 0.2495783087, 0.7852102347, -2.0124526346};

vars = Array[Symbol["q" <> ToString[#]] &, 10];
objM[v__?NumericQ] := CoveringRadius[centersOf[{v}], 1., WorkingPrecision -> MachinePrecision];
box = And @@ MapThread[#1 - 0.08 <= #2 <= #1 + 0.08 &, {seed, vars}];
nm = NMinimize[{objM @@ vars, box}, Transpose[{vars, seed - 0.01, seed + 0.01}],
   Method -> {"NelderMead", "RandomSeed" -> 3}, MaxIterations -> 8000,
   PrecisionGoal -> 12, AccuracyGoal -> 12];
pM = vars /. Last[nm];
Print["machine: rho = ", InputForm[First[nm]]];

objHP[v__?NumericQ] := CoveringRadius[centersOf[{v}], 1, WorkingPrecision -> wp];
hp = Quiet@FindMinimum[objHP @@ vars, Transpose[{vars, SetPrecision[pM, wp]}],
     Method -> "PrincipalAxis", WorkingPrecision -> wp,
     MaxIterations -> 8000, PrecisionGoal -> wp/2 - 3, AccuracyGoal -> wp/2 - 3];
pHP = vars /. Last[hp];
If[! VectorQ[pHP, NumericQ], pHP = SetPrecision[pM, wp]];

rhoF = CoveringRadius[centersOf[pHP], 1, WorkingPrecision -> wp];
R = gFix/rhoF;                     (* fixed-scale g rescales to R *)
Cs = centersOf[pHP]/rhoF;

dec[x_] := StringReplace[ToString[N[x, 30], InputForm, NumberMarks -> False], "*^" -> "e"];
Print["final:   R = ", dec[R], "   rho_unit = ", dec[rhoF]];
out = <|"R" -> dec[R], "rho_unit" -> dec[rhoF],
   "centers" -> Map[dec, Cs, {2}], "params" -> Map[dec, Prepend[pHP, 0] (* placeholder *)]|>;
Export["!cat", out, "RawJSON", "Compact" -> True];
