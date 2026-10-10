#!/usr/bin/env wolframscript
(* n=5 optimum: rotate so the origin-covering disk is on +y, list tight points & classify *)
PrependTo[$Path, FileNameJoin[{DirectoryName[$InputFileName], "..", "..", "wl"}]];
Needs["CirCovCir`"];
a = LoadConfig[FileNameJoin[{DirectoryName[$InputFileName], "..", "..", "data/configs/05/20261001-baseline.json"}]];
c = N[a["Centers"], 30]; R = N[a["RValue"], 30];
k = First@Ordering[Norm /@ c, 1]; th = Pi/2 - ArcTan @@ c[[k]];
rot = {{Cos[th], -Sin[th]}, {Sin[th], Cos[th]}};
cr = (rot . #) & /@ c; cr = cr[[Join[{k}, Complement[Range[5], {k}]]]];
cr = SortBy[cr, {Norm[#] > 1, -#[[1]]} &];
Print["centers (C1 first): ", NumberForm[Chop[cr, 10^-12], 10]];
Print["|c|: ", N[Norm /@ cr, 10]];
tp = TightPoints[cr, R, 10^-6];
Print[Column[{N[#[[1]], 10], N[Norm[#[[1]]], 10], #[[2]]} & /@ tp]];
Export[FileNameJoin[{DirectoryName[$InputFileName], "out", "rot_centers.m"}], {cr, R}];
