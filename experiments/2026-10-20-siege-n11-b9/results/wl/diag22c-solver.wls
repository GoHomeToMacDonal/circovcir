(* diagnostic helper (not a certificate): solver objective vs exact V on open boxes of the hard m = 4 root *)
src = Import["/home/skim/projects/research/circovcir/proofs/certificates/22c-n11-b9-witness.wls", "Text"];
pre = First[StringSplit[src, "(* ---------------- sanity tests"]];
pre = StringReplace[pre, "args = Rest[$ScriptCommandLine];" -> "args = {};"];
ToExpression[pre];
setR[26317/10000]; setupM[4];
root = propagate[{Table[0, 8], Table[7, 8]}];
roots = Nest[Join @@ (bisect /@ #) &, {root}, 9];
st = {roots[[31]]}; k = 0; opens = {};
While[st =!= {} && Length[opens] < 12, b = Last[st]; st = Most[st];
  r = testBox[b]; If[r[[1]] === "open", AppendTo[opens, r[[2]]]; st = Join[st, bisect[r[[2]]]]]];
solveWith[hp_, opts___] := Module[{Amu, G, eqCons, cvec, sol, msgs},
  Amu = SparseArray[Flatten[Table[{{2 hp[[i, 1]] - 1, i} -> -N[hp[[i, 2, 1]]], {2 hp[[i, 1]], i} -> -N[hp[[i, 2, 2]]]}, {i, nMu}], 1], {2 nPts, nMu}];
  G = ArrayFlatten[{{Ayz, Amu, SparseArray[{}, {2 nPts, nS}], -IdentityMatrix[2 nPts, SparseArray], SparseArray[{}, {2 nPts, nPts}]}}];
  eqCons = Join[Table[{zeroRow, {}, G[[r]], 0.}, {r, 2 nPts}], Table[{zeroRow, {}, -G[[r]], 0.}, {r, 2 nPts}]];
  cvec = Join[Table[0., nYZ], -N[hp[[All, 3]]], N[rList], Table[0., 2 nPts], Table[N[M35], nPts]];
  ed = Quiet[EvaluationData[SecondOrderConeOptimization[cvec, Join[coneCons, muCons, eqCons], opts]]];
  sol = ed["Result"]; msgs = ed["MessagesNames"];
  If[!VectorQ[sol, NumericQ], {"fail", msgs}, {cvec . sol, N[vExact[sol, hp]], msgs, ed["AbsoluteTiming"]}]];
Do[hp = halfplanes[propagate[b]];
  Print["maxw ", N[Max[b[[2]] - b[[1]]], 3],
    " default ", solveWith[hp],
    " SCS ", Quiet@Check[solveWith[hp, Method -> "SCS"], "err"],
    " CSDP ", Quiet@Check[solveWith[hp, Method -> "CSDP"], "err"],
    " Tol ", Quiet@Check[solveWith[hp, Tolerance -> 10^-11], "err"]], {b, opens}];
