(* Identify minimal polynomials of S6 = R6^2, R6, a6, b6 from the 2200-digit critical point
   (integer relations; EVIDENCE only, exact verification is in exact.wls).
   Run: wolframscript -file identify.wls  (writes out/minpolys.m) *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "sys.wl"}]];
crit = Get[critFile]; Rv = R /. crit; Sv = Rv^2; av = a /. crit; bv = b /. crit;
mp[x_, dmax_] := Module[{v, pol, fs},
  v = FindIntegerNullVector[x^Range[0, dmax], WorkingPrecision -> 2150];
  pol = FromDigits[Reverse[v], t];
  fs = Select[First /@ FactorList[pol], Exponent[#, t] > 0 && Abs[# /. t -> x] < 10^-1500 &];
  fs[[1]]];
res = Association[];
Do[
  f = mp[x[[2]], 24];
  Print[x[[1]], ": deg ", Exponent[f, t], "  log10 height ", N[Log10[Max[Abs[CoefficientList[f, t]]]], 4],
   "  log10|f(x)| ", N[Log10[Abs[f /. t -> x[[2]]] + 10^-2190], 5], "  irreducible ", IrreduciblePolynomialQ[f]];
  Print["   ", InputForm[f]];
  res[x[[1]]] = f,
  {x, {{"S", Sv}, {"R", Rv}, {"a", av}, {"b", bv}}}];
Print["R poly = S poly(t^2)? ", Expand[res["R"] - (res["S"] /. t -> t^2)] === 0 || Expand[res["R"] + (res["S"] /. t -> t^2)] === 0];
Print["real roots of S poly: ", N[Sort[t /. NSolve[res["S"] == 0, t, Reals, WorkingPrecision -> 40]], 20]];
Print["Galois group of S poly: ", TimeConstrained[GaloisGroup[res["S"], t], 300]];
Put[res, FileNameJoin[{DirectoryName[$InputFileName], "out", "minpolys.m"}]];
