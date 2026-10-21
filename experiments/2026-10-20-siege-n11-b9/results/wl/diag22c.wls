(* diagnostic helper (not a certificate): m = 4, which of the 512 root trees are expensive, and why boxes stay open *)
src = Import["/home/skim/projects/research/circovcir/proofs/certificates/22c-n11-b9-witness.wls", "Text"];
pre = First[StringSplit[src, "(* ---------------- sanity tests"]];
pre = StringReplace[pre, "args = Rest[$ScriptCommandLine];" -> "args = {};"];
ToExpression[pre];
mm = ToExpression[Last[$ScriptCommandLine]];
setR[26317/10000]; setupM[mm];
why[box_] := Module[{pb = propagate[box], hp, sol, v},
  If[pb === $Empty, Return["empty"]];
  hp = halfplanes[pb]; If[hp === $Failed, Return["hp-failed"]];
  sol = solveDual[hp]; If[sol === $Failed, Return["socp-failed"]];
  v = vExact[sol, hp]; If[v < 0, "cert", {"V", N[v, 4]}]];
root = propagate[{Table[0, 8], Table[7, 8]}];
roots = Nest[Join @@ (bisect /@ #) &, {root}, 9];
t0 = AbsoluteTime[];
Do[
  r = runTree[roots[[i]], 300];
  If[r[[1]] > 1 || r[[4]] =!= {},
    Print["root ", i, ": boxes ", r[[1]], " empty ", r[[2]], " cert ", r[[3]], " fails ", Length[r[[4]]],
      "  root status ", why[roots[[i]]], "  width ", N[Max[roots[[i, 2]] - roots[[i, 1]]], 3]];
    If[r[[4]] =!= {}, Module[{st = {roots[[i]]}, b, k = 0, w},
      (* sample statuses of the first 6 boxes down the DFS to see what keeps them open *)
      While[st =!= {} && k < 40, b = Last[st]; st = Most[st]; k++; w = why[b];
        If[k <= 40 && (k <= 6 || Mod[k, 8] == 0), Print["    box ", k, " maxw ", N[Max[b[[2]] - b[[1]]], 3], " ", w]];
        If[!MemberQ[{"empty", "cert"}, w], st = Join[st, bisect[If[propagate[b] === $Empty, b, propagate[b]]]]]]]]],
  {i, Length[roots]}];
Print["done m=", mm, " in ", Round[AbsoluteTime[] - t0], " s"];
