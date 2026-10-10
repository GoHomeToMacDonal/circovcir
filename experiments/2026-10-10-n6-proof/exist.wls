(* n=6: build the mirror-symmetric configuration at the half-problem threshold R6 (cert 10b, B3)
   and write it as data/configs/06/20261011-half-critical.json (status candidate; upgraded after
   `make verify`).  Run from the repo root:
     wolframscript -file experiments/2026-10-10-n6-proof/exist.wls *)
root = ParentDirectory[ParentDirectory[DirectoryName[$InputFileName]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
Get[FileNameJoin[{root, "proofs", "certificates", "10lib-n6.wl"}]];
wp = 80;
Gs = n6circR2[n6V[a, b], n6T2[R, b], n6X0[R, a]] - 1;
sol = FindRoot[{Gs, D[Gs, a], D[Gs, b]},
   {{R, 17988678275775543711457935637452760440966/10^40},
    {a, 9354854282012050973201937283428477342650/10^40},
    {b, 10105813367281855307975567223444460778468/10^40}},
   WorkingPrecision -> wp, AccuracyGoal -> 70, PrecisionGoal -> 70, MaxIterations -> 50];
{R6, a6, b6} = {R, a, b} /. sol;
V = n6V[a6, b6]; T1 = n6T1[R6, a6]; T2 = n6T2[R6, b6]; X0 = n6X0[R6, a6];
c3 = (T1 + X0)/2;
circumcenter[p_, q_, s_] := Module[{d = 2 n6cross[q - p, s - p]},
   p + {(s - p)[[2]] n6sq[q - p] - (q - p)[[2]] n6sq[s - p],
        (q - p)[[1]] n6sq[s - p] - (s - p)[[1]] n6sq[q - p]}/d];
c4 = circumcenter[V, T2, X0];
mir[p_] := {-p[[1]], p[[2]]};
centers = {{0, a6}, {0, -b6}, c3, c4, mir[c3], mir[c4]};
Print["|c4 - V|-1 = ", N[Norm[c4 - V] - 1, 5], "   |c3-T1|-1 = ", N[Norm[c3 - T1] - 1, 5]];
Rcov = MaxCoveredRadius[centers, WorkingPrecision -> 50];
Print["R6       = ", N[R6, 45]];
Print["MaxCoveredRadius(wp50) = ", Rcov, "   diff = ", N[Rcov - R6, 5]];
tp = TightPoints[centers, R6, 10^-30];
Print["tight points: ", Length[tp]];
Scan[Print["  ", N[#[[1]], 12], "  ", #[[2]]] &, tp];
str[x_] := ToString[N[x, 45], InputForm, NumberMarks -> False];
cfg = <|"n" -> 6, "R" -> str[R6], "centers" -> Map[str, centers, {2}], "status" -> "candidate",
   "source" -> "n=6 half-problem threshold (proofs/10-n6-half.md, experiments/2026-10-10-n6-proof)",
   "provenance" -> "wolframscript -file experiments/2026-10-10-n6-proof/exist.wls (FindRoot wp 80 on G = G_a = G_b = 0; C3 = midpoint(T1,X0), C4 = circumcenter(V,T2,X0), mirror in the y-axis)",
   "checks" -> <|"wl_MaxCoveredRadius_wp50" -> ToString[N[Rcov, 40], InputForm, NumberMarks -> False],
     "tight_points_tol1e-30" -> Length[tp]|>|>;
out = FileNameJoin[{root, "data", "configs", "06", "20261011-half-critical.json"}];
If[FileExistsQ[out], Print["exists, not overwriting: ", out], SaveConfig[out, cfg]; Print["wrote ", out]];
