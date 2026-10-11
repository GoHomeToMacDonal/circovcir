(* Modular elimination: degree of the eliminant in S = R^2 over F_p.
   Run: wolframscript -file modp.wls H|L [prime] *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "sys.wl"}]];
form = If[Length[$ScriptCommandLine] >= 2, $ScriptCommandLine[[2]], "L"];
pr = If[Length[$ScriptCommandLine] >= 3, ToExpression[$ScriptCommandLine[[3]]], 2147483647];
sat = z a b S x1 x2 xv r1 - 1;  (* saturate away the cleared denominators *)
{eqs, vars} = If[form === "H", {Append[eqsH, sat], Append[varsH, z]}, {Append[eqsL, sat], Append[varsL, z]}];
Print["form ", form, " p=", pr, " #eqs ", Length[eqs], " total degrees ", Exponent[# /. Thread[Append[vars, S] -> t Append[vars, S]], t] & /@ eqs];
{tm, gb} = AbsoluteTiming[TimeConstrained[
    GroebnerBasis[eqs, {S}, vars, MonomialOrder -> EliminationOrder, Modulus -> pr], 3600]];
Print["time ", tm];
If[ListQ[gb],
  Print["#gb ", Length[gb], "  degS ", Exponent[#, S] & /@ gb];
  If[Length[gb] > 0, Print["factor degrees mod p: ", Sort[Exponent[#[[1]], S] & /@ FactorList[First[gb], Modulus -> pr]]]];
  Put[gb, FileNameJoin[{DirectoryName[$InputFileName], "out", "elim-" <> form <> "-" <> ToString[pr] <> ".m"}]],
  Print["no result: ", gb]];
