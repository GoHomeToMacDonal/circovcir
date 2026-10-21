(* profiling helper (not a certificate): load the definitions of 22c and time the box test *)
src = Import["/home/skim/projects/research/circovcir/proofs/certificates/22c-n11-b9-witness.wls", "Text"];
pre = First[StringSplit[src, "(* ---------------- sanity tests"]];
pre = StringReplace[pre, "args = Rest[$ScriptCommandLine];" -> "args = {};"];
ToExpression[pre];
setR[26317/10000]; setupM[5];
root = propagate[{Table[0, 8], Table[7, 8]}];
roots = Nest[Join @@ (bisect /@ #) &, {root}, 9];
SeedRandom[1];
smp = RandomSample[roots, 12];
Do[
  pb = propagate[b];
  If[pb === $Empty, Print["empty"]; Continue[]];
  {t1, hp} = AbsoluteTiming[halfplanes[pb]];
  If[hp === $Failed, Print["hp failed, widths ", N[pb[[2]] - pb[[1]]]]; Continue[]];
  {t2, sol} = AbsoluteTiming[solveDual[hp]];
  {t3, v} = If[sol === $Failed, {0, "fail"}, AbsoluteTiming[vExact[sol, hp]]];
  Print["maxw ", N[Max[pb[[2]] - pb[[1]]], 3], " hp ", t1, " s; socp ", t2, " s; vExact ", t3, " s; V = ", N[v]], {b, smp}];
Do[{tt, r} = AbsoluteTiming[runTree[smp[[i]], 2000]];
  Print["runTree sample ", i, ": ", tt, " s ", r[[1 ;; 3]], " fails ", Length[r[[4]]]], {i, 3}];
