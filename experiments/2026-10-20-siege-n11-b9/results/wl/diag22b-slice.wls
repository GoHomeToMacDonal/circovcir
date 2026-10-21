(* diagnostic helper (not a certificate): where the time goes in a hard 22b slice *)
src = Import["/home/skim/projects/research/circovcir/proofs/certificates/22b-n11-b9-nobridge.wls", "Text"];
pre = First[StringSplit[src, "Print[\"22b: R = "]];
pre = StringReplace[pre, "args = Rest[$ScriptCommandLine];" -> "args = {};"];
ToExpression[pre];
i = ToExpression[$ScriptCommandLine[[-1]]];
kl = Bhi i/48; kh = Bhi (i + 1)/48; ky = Bhi - kl;
(* counting copy of refute: returns {proved, boxes} *)
refuteN[ev_, root_, K_, scale_, which_, T_, cap_] := Module[{st = {root}, box, w, n = 0},
  While[st =!= {}, box = Last[st]; st = Most[st]; n++;
    If[n > cap, Return[{False, n}, Module]];
    If[Mod[n, 200000] == 0, ClearSystemCache[]];
    w = ev[box, K];
    If[MissingQ[w] || w[[which]] < T, Continue[]];
    If[Max[(box[[All, 2]] - box[[All, 1]])/scale] < wMin, Return[{False, n, "wMin"}, Module]];
    st = Join[st, splitBox[box, scale]]];
  {True, n}];
Print["slice ", i, " K_X in ", N[{kl, kh}, 6]];
{t, uy} = AbsoluteTiming[upperBound[evalY, yRootFar, ky, scaleY, 20000]];
Print["  U_Y = ", N[uy, 8], "  (", Round[t], " s);  T = 2pi - U_Y = ", N[twoPiLo - uy, 8]];
{t, r} = AbsoluteTiming[refuteN[evalX, xRoot, kh, scaleX, 1, twoPiLo - uy, 4*10^6]];
Print["  FAR refute X obj < T: ", r, " (", Round[t], " s)"];
{t, r} = AbsoluteTiming[refuteN[evalY, yRootNear, ky, scaleY, 2, 0, 4*10^6]];
Print["  NEAR: Y near empty: ", r, " (", Round[t], " s)"];
{t, r} = AbsoluteTiming[refuteN[evalX, xRoot, kh, scaleX, 2, 0, 4*10^6]];
Print["  NEAR: X far empty: ", r, " (", Round[t], " s)"];
