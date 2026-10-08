#!/usr/bin/env wolframscript
(* Local symmetric polish of the n=11 cover, seeded at the symmetrized float params.
   Stays in a tiny box so it cannot leave the Melissen basin. Numeric-guarded objective.
   Prints JSON {R, rho_unit, centers, params}. Usage: polish_sym.wls [wp] *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
wp = If[Length[args] >= 1, ToExpression[args[[1]]], 50];

centersOf[{a_, b_, g_, u1_, v1_, u2_, v2_, u3_, v3_, u4_, v4_}] := {
   {0, a}, {0, b}, {0, g},
   { u1, v1}, {-u1, v1}, { u2, v2}, {-u2, v2},
   { u3, v3}, {-u3, v3}, { u4, v4}, {-u4, v4}};

seed = {-0.3932461761, 0.7183860132, 2.3488207091,
         1.5753389003, 1.6206117513, 1.7727207014, -0.9363142301,
         1.8274936095, 0.2495783087, 0.7852102347, -2.0124526346};

vars = Array[Symbol["q" <> ToString[#]] &, 11];
(* machine objective: 11 explicit numeric scalar args (NMinimize/FindMinimum idiom) *)
objM[v__?NumericQ] := CoveringRadius[centersOf[{v}], 1., WorkingPrecision -> MachinePrecision];
(* tiny box: cannot leave the basin *)
box = And @@ MapThread[#1 - 0.03 <= #2 <= #1 + 0.03 &, {seed, vars}];
nm = NMinimize[{objM @@ vars, box},
   Transpose[{vars, seed - 0.004, seed + 0.004}],
   Method -> {"NelderMead", "RandomSeed" -> 7}, MaxIterations -> 6000,
   PrecisionGoal -> 11, AccuracyGoal -> 11];
pM = vars /. Last[nm];
Print["machine: rho = ", InputForm[First[nm]], "  R = ", InputForm[1/First[nm]]];

(* high-precision quasi-Newton refine from the machine optimum *)
objHP[v__?NumericQ] := CoveringRadius[centersOf[{v}], 1, WorkingPrecision -> wp];
hp = Quiet@FindMinimum[objHP @@ vars, Transpose[{vars, SetPrecision[pM, wp]}],
     Method -> "PrincipalAxis", WorkingPrecision -> wp,
     MaxIterations -> 6000, PrecisionGoal -> wp/2 - 3, AccuracyGoal -> wp/2 - 3];
pHP = vars /. Last[hp];
If[! VectorQ[pHP, NumericQ], pHP = SetPrecision[pM, wp]];

rhoF = CoveringRadius[centersOf[pHP], 1, WorkingPrecision -> wp];
R = 1/rhoF;
Cs = centersOf[pHP]/rhoF;

dec[x_] := StringReplace[ToString[N[x, 30], InputForm, NumberMarks -> False], "*^" -> "e"];
Print["final:   R = ", dec[R], "   rho_unit = ", dec[rhoF]];
out = <|"R" -> dec[R], "rho_unit" -> dec[rhoF],
   "centers" -> Map[dec, Cs, {2}], "params" -> Map[dec, pHP]|>;
Export["!cat", out, "RawJSON", "Compact" -> True];
