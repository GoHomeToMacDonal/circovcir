#!/usr/bin/env wolframscript
(* Regenerate data/configs/nNN/known.json for configurations with exact closed forms.
   Usage (repo root):  wolframscript -file wl/scripts/make_known_configs.wls *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];

ring[k_, rad_, phase_ : 0] := Table[rad {Cos[phase + 2 Pi j/k], Sin[phase + 2 Pi j/k]}, {j, 0, k - 1}];

known = {
  {1, {{0, 0}}, 1, "trivial"},
  {2, {{0, 0}, {0, 0}}, 1, "trivial (a second disk cannot help)"},
  {3, ring[3, 1/Sqrt[3]], 2/Sqrt[3], "trivial"},
  {4, ring[4, 1, Pi/4], Sqrt[2], "trivial"},
  {7, Join[{{0, 0}}, ring[6, Sqrt[3]]], 2, "trivial"}
};

dec[x_] := StringReplace[ToString[N[x, 50], InputForm, NumberMarks -> False], "*^" -> "e"];

Do[
  Module[{n, cs, r, src, dir, file, ok, rnum},
   {n, cs, r, src} = k;
   ok = ExactCoverQ[cs, r];
   rnum = MaxCoveredRadius[cs, WorkingPrecision -> 40];
   dir = FileNameJoin[{root, "data", "configs", IntegerString[n, 10, 2]}];
   Quiet@CreateDirectory[dir];
   file = FileNameJoin[{dir, "known.json"}];
   SaveConfig[file, <|
     "n" -> n,
     "R" -> dec[r],
     "R_wl" -> ToString[r, InputForm],
     "centers" -> Map[dec, N[cs, 60], {2}],
     "centers_wl" -> ToString[cs, InputForm],
     "status" -> "proved-optimal",
     "source" -> src,
     "provenance" -> "wl/scripts/make_known_configs.wls",
     "checks" -> <|"ExactCoverQ" -> ok, "MaxCoveredRadius_40" -> dec[rnum]|>
     |>];
   Print[n, "  exact cover: ", ok, "  R_num = ", ToString[N[rnum, 20], InputForm, NumberMarks -> False], "  -> ", file]],
  {k, known}];
