(* diagnostic helper (not a certificate): size of the hardest m = 4 root tree (root 31) *)
src = Import["/home/skim/projects/research/circovcir/proofs/certificates/22c-n11-b9-witness.wls", "Text"];
pre = First[StringSplit[src, "(* ---------------- sanity tests"]];
pre = StringReplace[pre, "args = Rest[$ScriptCommandLine];" -> "args = {};"];
ToExpression[pre];
setR[26317/10000]; setupM[4];
root = propagate[{Table[0, 8], Table[7, 8]}];
roots = Nest[Join @@ (bisect /@ #) &, {root}, 9];
st = {roots[[31]]}; n = 0; ne = 0; nc = 0; minw = 1; t0 = AbsoluteTime[];
While[st =!= {} && n < 200000, b = Last[st]; st = Most[st]; n++;
  r = testBox[b];
  Switch[r[[1]], $Empty, ne++, "cert", nc++,
    _, minw = Min[minw, Max[r[[2, 2]] - r[[2, 1]]]];
       If[Max[r[[2, 2]] - r[[2, 1]]] < 10^-7, Print["OPEN at 1e-7: ", N[r[[2]]]]; Break[]];
       st = Join[st, bisect[r[[2]]]]];
  If[Mod[n, 2000] == 0, Print[n, " boxes, ", Round[AbsoluteTime[] - t0], " s, stack ", Length[st], ", min open width ", N[minw, 3]]]];
Print["root 31 done: boxes ", n, " empty ", ne, " cert ", nc, " stack ", Length[st], " ", Round[AbsoluteTime[] - t0], " s"];
