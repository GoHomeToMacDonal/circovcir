#!/usr/bin/env wolframscript
(* n=25 exact configuration, identified from the float optimum (structured search, layers
   [16, 8, 1]) which turned out to be D8-symmetric:
     1 disk at O;
     8 at radius a = Sqrt[2+Sqrt[2]] = 2 cos(pi/8), angles k pi/4;
     8 at radius 2 + Sqrt[2],                angles pi/8 + k pi/4;
     8 at radius 2a,                         angles k pi/4.
   Checks ExactCoverQ at R = Sqrt[6] + Sqrt[3] (True) and R + 10^-20 (False), and writes
   data/configs/25/20261009-d8-exact.json (never overwrites).
   usage: wolframscript -file experiments/2026-10-09-structured-12-25/n25_exact.wls *)
root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
a = Sqrt[2 + Sqrt[2]]; pol[r_, t_] := r {Cos[t], Sin[t]};
pts = Join[{{0, 0}}, Table[pol[a, k Pi/4], {k, 0, 7}],
   Table[pol[2 + Sqrt[2], Pi/8 + k Pi/4], {k, 0, 7}], Table[pol[2 a, k Pi/4], {k, 0, 7}]];
pts = Map[RootReduce[FunctionExpand[#]] &, pts, {2}];
R = Sqrt[6] + Sqrt[3];
dec[x_] := ToString[N[x, 60], InputForm, NumberMarks -> False];
out = FileNameJoin[{root, "data", "configs", "25", "20261009-d8-exact.json"}];
If[! FileExistsQ[out],
  Export[out, <|"n" -> 25, "R" -> dec[R], "centers" -> Map[dec, pts, {2}],
    "status" -> "candidate",
    "source" -> "D8-symmetric 1 + 8 + 16 configuration identified from structured search (experiments/2026-10-09-structured-12-25); reproduces Jeremy Tan 2018 record Sqrt[6]+Sqrt[3]",
    "provenance" -> "experiments/2026-10-09-structured-12-25/n25_exact.wls",
    "R_wl" -> "Sqrt[6] + Sqrt[3]", "centers_wl" -> ToString[pts, InputForm]|>, "RawJSON"]];
Print["n = ", Length[pts]];
Print["ExactCoverQ[pts, Sqrt[6]+Sqrt[3]]          = ", ExactCoverQ[pts, R]];
Print["ExactCoverQ[pts, Sqrt[6]+Sqrt[3] + 10^-20] = ", ExactCoverQ[pts, R + 10^-20]];
