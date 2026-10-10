#!/usr/bin/env wolframscript
(* Plot the best configuration in a run.py / ils.py JSON file (first entry or the object).
   Disks meeting the target circle (|c| > R-1) in orange, interior disks in blue; target
   circle in red; centers as dots.
   usage: wolframscript -file plot.wls out/n100-s0-ils.json out/n100.png </dev/null *)
args = Rest[$ScriptCommandLine];
{in, png} = args[[1 ;; 2]];
js = Import[in, "RawJSON"];
d = If[ListQ[js], First[js], js];
c = d["centers"]; R = d["R"]; n = Length[c];
bnd = Select[c, Norm[#] > R - 1 &]; inr = Select[c, Norm[#] <= R - 1 &];
g = Graphics[{
    {FaceForm[Opacity[0.12, Blue]], EdgeForm[{Thin, Blue}], Disk[#, 1] & /@ inr},
    {FaceForm[Opacity[0.15, Orange]], EdgeForm[{Thin, Darker[Orange]}], Disk[#, 1] & /@ bnd},
    {Red, Thick, Circle[{0, 0}, R]},
    {Black, PointSize[0.006], Point[c]}},
   PlotLabel -> StringForm["n = ``,  R = ``,  b = `` boundary disks", n,
     NumberForm[R, 10], Length[bnd]], ImageSize -> 900];
Export[png, g];
Print[png, "  n=", n, " R=", R, " b=", Length[bnd]];
