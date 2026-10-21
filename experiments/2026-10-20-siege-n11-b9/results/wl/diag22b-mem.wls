(* diagnostic helper (not a certificate): memory growth of the 22b evaluators *)
src = Import["/home/skim/projects/research/circovcir/proofs/certificates/22b-n11-b9-nobridge.wls", "Text"];
pre = First[StringSplit[src, "Print[\"22b: R = "]];
pre = StringReplace[pre, "args = Rest[$ScriptCommandLine];" -> "args = {};"];
ToExpression[pre];
Print["after defs: ", MemoryInUse[]];
kl = Bhi 12/48; kh = Bhi 13/48;
Do[
  t = AbsoluteTiming[r = refute[evalX, xRoot, kh, scaleX, 2, 0, cap]][[1]];
  Print["refute X slack cap ", cap, ": ", r, " ", Round[t], " s, MemoryInUse ", MemoryInUse[], ", MaxMemoryUsed ", MaxMemoryUsed[]];
  , {cap, {2000, 20000}}];
t = AbsoluteTiming[r = upperBound[evalY, yRootFar, Bhi - kl, scaleY, 20000]][[1]];
Print["upperBound Y: ", N[r], " ", Round[t], " s, MemoryInUse ", MemoryInUse[]];
ClearSystemCache[]; Print["after ClearSystemCache: ", MemoryInUse[]];
