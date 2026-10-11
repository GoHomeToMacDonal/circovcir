(* Sanity: both systems vanish at the known critical point; then time modular elimination.
   Run: wolframscript -file check.wls *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "sys.wl"}]];
crit = Get[critFile];
Print["keys: ", Keys[crit]];
pt0 = Association[crit];
Ru = R /. crit; av = a /. crit; bv = b /. crit;
Print["precision R: ", Precision[Ru]];
num = {S -> Ru^2, a -> av, b -> bv};
yv1 = y1 /. num; yv2 = y2 /. num;
auxv = {x1 -> Sqrt[Ru^2 - yv1^2], x2 -> Sqrt[Ru^2 - yv2^2], xv -> Sqrt[1 - ((av + bv)/2)^2], r1 -> Sqrt[Ru^2 - 1]};
nH = Join[num, auxv];
Print["H residuals: ", N[Abs[eqsH /. nH], 5]];
(* circumcentre for (L) *)
P1 = V /. nH; P2 = T2 /. nH; P3 = X0 /. nH;
cen = Module[{m}, m = {{2 (P2 - P1)}, {2 (P3 - P1)}}; LinearSolve[{2 (P2 - P1), 2 (P3 - P1)}, {P2 . P2 - P1 . P1, P3 . P3 - P1 . P1}]];
nL0 = Join[nH, {p -> cen[[1]], q -> cen[[2]]}];
Jn = JL /. nL0;
ns = NullSpace[Transpose[Jn], Tolerance -> 10^-1000];
Print["left nullspace dim: ", Length[ns]];
lv = ns[[1]]/ns[[1, -1]];
nL = Join[nL0, Thread[lam -> lv]];
Print["L residuals: ", N[Max[Abs[eqsL /. nL]], 5]];
Print["L multipliers: ", N[lv, 8]];
