#!/usr/bin/env wolframscript
(* n=19 exact configuration: hexagonal lattice of spacing Sqrt[3] (unit disks' deep holes are
   exactly triple points), 19 lattice points with |x| <= 2 Sqrt[3] (shells 1 + 6 + 6 + 6).
   Writes data/configs/19/20261009-hex-exact.json and checks ExactCoverQ at R = Sqrt[13]
   (True) and at Sqrt[13] + 10^-20 (False).
   usage: wolframscript -file experiments/2026-10-09-structured-12-25/n19_exact.wls *)
root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
a = Sqrt[3]; e1 = {a, 0}; e2 = {a/2, 3/2};
pts = SortBy[Select[Flatten[Table[i e1 + j e2, {i, -4, 4}, {j, -4, 4}], 1],
    Norm[#] <= 2 Sqrt[3] + 10^-9 &], {Norm, ArcTan @@ (# + {10^-9, 0}) &}];
dec[x_] := ToString[N[x, 60], InputForm, NumberMarks -> False];
out = FileNameJoin[{root, "data", "configs", "19", "20261009-hex-exact.json"}];
If[! FileExistsQ[out],
  Export[out, <|"n" -> 19, "R" -> dec[Sqrt[13]], "centers" -> Map[dec, pts, {2}],
    "status" -> "candidate",
    "source" -> "hexagonal lattice patch (spacing Sqrt[3]): 1 + 6 + 12 lattice points with |x| <= 2 Sqrt[3]; reproduces Jeremy Tan 2018 record Sqrt[13] (experiments/2026-10-09-structured-12-25)",
    "provenance" -> "experiments/2026-10-09-structured-12-25/n19_exact.wls",
    "R_wl" -> "Sqrt[13]", "centers_wl" -> ToString[pts, InputForm]|>, "RawJSON"]];
Print["n = ", Length[pts]];
Print["ExactCoverQ[pts, Sqrt[13]]          = ", ExactCoverQ[pts, Sqrt[13]]];
Print["ExactCoverQ[pts, Sqrt[13] + 10^-20] = ", ExactCoverQ[pts, Sqrt[13] + 10^-20]];
