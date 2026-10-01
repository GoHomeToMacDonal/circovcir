#!/usr/bin/env wolframscript
(* Independent verification of one configuration file. Prints ONE line of JSON.
   Usage:  wolframscript -file wl/scripts/verify_config.wls data/configs/07/known.json [wp] *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];

args = Rest[$ScriptCommandLine];
If[Length[args] < 1, Print["usage: verify_config.wls <config.json> [workingPrecision]"]; Exit[2]];
file = First[args];
wp = If[Length[args] >= 2, ToExpression[args[[2]]], 40];

cfg = LoadConfig[file];
cs = cfg["Centers"]; r = cfg["RValue"];
rnum = MaxCoveredRadius[cs, WorkingPrecision -> wp];
exactQ = If[KeyExistsQ[cfg, "centers_wl"] && KeyExistsQ[cfg, "R_wl"], ExactCoverQ[cs, r], Null];
covNum = CoveringRadius[cs, r, WorkingPrecision -> wp];
(* scale certificate: unit disks at cs/covNum cover D(0, r/covNum) exactly as disks of radius
   covNum at cs cover D(0, r). So R_certified is a valid radius for the rescaled configuration. *)
rcert = If[covNum <= 1, r, r/covNum];

dec[x_] := StringReplace[ToString[N[x, 30], InputForm, NumberMarks -> False], "*^" -> "e"];
out = <|
  "file" -> file, "n" -> Length[cs], "wp" -> wp,
  "R_recorded" -> dec[r],
  "R_max_numeric" -> dec[rnum],
  "R_gap" -> dec[rnum - r],
  "covering_radius_at_R" -> dec[covNum],
  "R_certified" -> dec[rcert],
  "R_cert_gap" -> dec[rcert - r],
  "exact_cover" -> exactQ,
  "tight_points" -> Length[TightPoints[cs, r, 10^-8]]
  |>;
Print[ExportString[out, "RawJSON", "Compact" -> True]];
