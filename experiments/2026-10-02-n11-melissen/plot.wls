#!/usr/bin/env wolframscript
root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
cfg = LoadConfig[FileNameJoin[{root, "data", "configs", "11", "20261002-melissen-baseline.json"}]];
cs = cfg["Centers"]; r = cfg["RValue"];
g = CoverPlot[cs, r, ImageSize -> 520];
out = FileNameJoin[{DirectoryName[ExpandFileName[$InputFileName]], "cover_n11.png"}];
Export[out, g];
Print[out];
