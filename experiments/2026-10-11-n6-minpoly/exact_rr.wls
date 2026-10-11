(* Exact check (attempt 1, RootReduce): plug exact algebraic S6, a6, b6 into the critical system.
   Run: wolframscript -file exact_rr.wls *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "sys.wl"}]];
crit = Get[critFile]; Rv = R /. crit; av = a /. crit; bv = b /. crit;
mins = Get[FileNameJoin[{DirectoryName[$InputFileName], "out", "minpolys.m"}]];
pick[f_, x_] := Module[{rs = Table[Root[Function @@ {t, f}, k], {k, Exponent[f, t]}]},
   First[SortBy[Select[rs, Element[#, Reals] &], Abs[N[# - x, 60]] &]]];
Se = pick[mins["S"], Rv^2]; ae = pick[mins["a"], av]; be = pick[mins["b"], bv];
Print[N[{Se - Rv^2, ae - av, be - bv}, 5]];
ex = {S -> Se, a -> ae, b -> be};
y1e = y1 /. ex; y2e = y2 /. ex;
auxe = {x1 -> Sqrt[Se - y1e^2], x2 -> Sqrt[Se - y2e^2], xv -> Sqrt[1 - ((ae + be)/2)^2], r1 -> Sqrt[Se - 1]};
Do[{tm, r} = AbsoluteTiming[TimeConstrained[RootReduce[(aux /. auxe)[[k]]], 600]];
  Print[aux[[k]], " time ", tm, " degree ", If[Head[r] === Root, Exponent[r[[1]][t], t], r]], {k, 4}];
Do[{tm, r} = AbsoluteTiming[TimeConstrained[RootReduce[e /. ex /. auxe], 1800]];
  Print["eq time ", tm, " -> ", Short[r, 3]], {e, {Hraw, tot[Hraw, a], tot[Hraw, b]}}];
