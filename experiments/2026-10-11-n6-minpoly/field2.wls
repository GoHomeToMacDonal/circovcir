(* Express a6^2, b6/a6 (and the aux squares) in K = Q(S6), S6 = R6^2.  EVIDENCE (integer relations);
   the exact check in exact.wls is what certifies them.  Writes out/field.m.
   Run: wolframscript -file field2.wls *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "sys.wl"}]];
crit = Get[critFile]; Rv = R /. crit; av = a /. crit; bv = b /. crit; Sv = Rv^2;
inK[z_] := Module[{v = FindIntegerNullVector[Append[Sv^Range[0, 8], z], WorkingPrecision -> 2150], h},
   h = N[Log10[Max[Abs[v]]], 4];
   If[v[[-1]] != 0 && h < 200, {h, -(Most[v] . s^Range[0, 8])/v[[-1]]}, {h, $Failed}]];
tests = <|"a^2" -> av^2, "b^2" -> bv^2, "a b" -> av bv, "b/a" -> bv/av|>;
out = Association[];
KeyValueMap[(r = inK[#2]; Print[#1, ": log10 height ", r[[1]], If[r[[2]] === $Failed, "  NOT in K", "  in K"]];
    out[#1] = r[[2]]) &, tests];
Put[out, FileNameJoin[{DirectoryName[$InputFileName], "out", "field.m"}]];
