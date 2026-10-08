#!/usr/bin/env wolframscript
(* n=11 symmetric polish, numerically guarded.
   Objective is defined ONLY on numeric input (NumericQ guard on EVERY arg), so the
   optimizer can never substitute symbols into CoveringRadius and blow the expression up.
   Prints JSON {R, rho_unit, centers, params}. Usage: solve_sym.wls [wp] *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
wp = If[Length[args] >= 1, ToExpression[args[[1]]], 50];

centersOf[{a_, b_, g_, u1_, v1_, u2_, v2_, u3_, v3_, u4_, v4_}] := {
   {0, a}, {0, b}, {0, g},
   { u1, v1}, {-u1, v1}, { u2, v2}, {-u2, v2},
   { u3, v3}, {-u3, v3}, { u4, v4}, {-u4, v4}};

seed = {-0.393246176, 0.718386013, 2.348820709,
         1.568569790, 1.627191748, 1.826451141, 0.257211541,
         1.776631584, -0.928909771, 0.793616027, -2.009172889};

(* STRICTLY numeric objective: all 11 args must be real numbers or it returns a large penalty *)
ClearAll[rho];
rho[p_List] := CoveringRadius[centersOf[N[p, MachinePrecision]], 1., WorkingPrecision -> MachinePrecision];
objN[p_ /; VectorQ[p, NumericQ]] := rho[p];
objN[_] := 10.^6;

(* 1) machine Nelder-Mead polish via NMinimize over a tight box around the seed *)
vars = Array[Symbol["q" <> ToString[#]] &, 11];
box = MapThread[{#1 - 0.25 <= #2 <= #1 + 0.25} &, {seed, vars}] // Flatten;
nm = NMinimize[{objN[vars], And @@ box}, Transpose[{vars, seed - 0.05, seed + 0.05}],
   Method -> {"NelderMead", "ShrinkRatio" -> 0.9, "ContractRatio" -> 0.6,
     "ReflectRatio" -> 1.1, "RandomSeed" -> 1}, MaxIterations -> 3000];
pM = vars /. Last[nm];
Print["machine rho = ", InputForm[First[nm]], "  R = ", InputForm[1/First[nm]]];

(* 2) high-precision polish: FindMinimum (quasi-Newton) at WorkingPrecision wp, numeric guard
      keeps it from going symbolic; start from the machine optimum. *)
rhoHP[p_ /; VectorQ[p, NumericQ]] := CoveringRadius[centersOf[p], 1, WorkingPrecision -> wp];
rhoHP[_] := 10^6;
startHP = Transpose[{vars, SetPrecision[pM, wp]}];
hp = Quiet@FindMinimum[rhoHP[vars], startHP, Method -> "PrincipalAxis",
     WorkingPrecision -> wp, MaxIterations -> 4000, PrecisionGoal -> wp/2 - 2,
     AccuracyGoal -> wp/2 - 2];
pHP = vars /. Last[hp];
If[! VectorQ[pHP, NumericQ], pHP = SetPrecision[pM, wp]];  (* fall back if HP step failed *)

rhoFinal = CoveringRadius[centersOf[pHP], 1, WorkingPrecision -> wp];
R = 1/rhoFinal;
Cs = centersOf[pHP]/rhoFinal;      (* scaled so UNIT disks cover D(0,R) *)

dec[x_] := StringReplace[ToString[N[x, 30], InputForm, NumberMarks -> False], "*^" -> "e"];
Print["final  R = ", dec[R], "   rho_unit = ", dec[rhoFinal]];
out = <|"R" -> dec[R], "rho_unit" -> dec[rhoFinal],
   "centers" -> Map[dec, Cs, {2}], "params" -> Map[dec, pHP]|>;
Export["!cat", out, "RawJSON", "Compact" -> True];
