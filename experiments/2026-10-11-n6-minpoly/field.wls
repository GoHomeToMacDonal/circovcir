(* Which of the critical-point coordinates lie in Q(theta) for theta in {R, r1, a, b}?
   Integer relation on {1, theta, ..., theta^(d-1), z}; EVIDENCE only. *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "sys.wl"}]];
crit = Get[critFile]; Rv = R /. crit; av = a /. crit; bv = b /. crit;
num = {S -> Rv^2, a -> av, b -> bv}; yv1 = y1 /. num; yv2 = y2 /. num;
vals = <|"R" -> Rv, "a" -> av, "b" -> bv, "x1" -> Sqrt[Rv^2 - yv1^2], "x2" -> Sqrt[Rv^2 - yv2^2],
   "xv" -> Sqrt[1 - ((av + bv)/2)^2], "r1" -> Sqrt[Rv^2 - 1]|>;
mins = Get[FileNameJoin[{DirectoryName[$InputFileName], "out", "minpolys.m"}]];
Do[
  th = vals[thn]; d = 18;
  row = Table[
    v = FindIntegerNullVector[Append[th^Range[0, d - 1], vals[zn]], WorkingPrecision -> 2150];
    If[v[[-1]] == 0, zn -> "rel-without-z",
     zn -> Round[N[Log10[Max[Abs[v]]]]]], {zn, Keys[vals]}];
  Print["theta=", thn, " : log10 height of relation ", row],
  {thn, {"R", "r1", "a", "b"}}];
