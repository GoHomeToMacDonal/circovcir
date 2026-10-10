(* Try to eliminate the n=6 half-problem critical system to a univariate polynomial in R.
   Run: wolframscript -file elim.wls  (writes out/elim.m) *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "poly.wl"}]];
eqs = Numerator[Together[#]] & /@ Join[defs, {Hraw, tot[Hraw, a], tot[Hraw, b]}];
Print["degrees: ", Exponent[#, {a, b, R, x1, x2, xv, r1}] & /@ eqs];
{t, gb} = AbsoluteTiming[TimeConstrained[
    GroebnerBasis[eqs, {R}, {a, b, x1, x2, xv, r1}, MonomialOrder -> EliminationOrder,
     Method -> "GroebnerWalk"], 5400]];
Print["time ", t];
If[ListQ[gb], Print["factors: ", Exponent[#, R] & /@ (First /@ FactorList[First[gb]])];
  Put[gb, FileNameJoin[{DirectoryName[$InputFileName], "out", "elim.m"}]], Print["no result: ", gb]];
