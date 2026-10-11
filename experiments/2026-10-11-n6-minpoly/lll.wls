(* Integer-relation search for the minimal polynomial of S6 = R6^2 using the 2200-digit value.
   Run: wolframscript -file lll.wls d1 d2 ... ; a hit is accepted only if it is re-verified
   at full precision with a residual far below the precision implied by its height. *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "sys.wl"}]];
crit = Get[critFile]; Sv = (R /. crit)^2;
degs = ToExpression /@ Rest[$ScriptCommandLine];
Do[
  {tm, v} = AbsoluteTiming[TimeConstrained[Quiet@Check[FindIntegerNullVector[Sv^Range[0, d], WorkingPrecision -> 2150], $Failed], 3000]];
  If[ListQ[v],
    h = N[Log10[Max[Abs[v]]], 4];
    res = N[Log10[Abs[v . (Sv^Range[0, d])] + 10^-2190], 5];
    pol = FromDigits[Reverse[v], t];
    Print["deg ", d, " time ", tm, " log10 height ", h, " log10|res| ", res, " factor degs ", Exponent[#[[1]], t] & /@ FactorList[pol]],
    Print["deg ", d, " time ", tm, " -> ", v]],
  {d, degs}];
