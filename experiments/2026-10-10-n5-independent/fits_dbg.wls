#!/usr/bin/env wolframscript
(* Debug: list S3/S4 candidate cells for one box; graded cells (fine near 0). *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "..", "proofs", "certificates", "09lib-n5.wl"}]];
iv[a_, b_] := Interval[{N[a], N[b]}];
Off[General::munfl];
dbg[RI_, dI_, psI_, cuts_] := Module[{al, c, P, s3 = {}, s4 = {}},
  al = n5al[RI]; c = n5psiT[RI, dI] - 2 al; P = n5A[RI, psI];
  Do[With[{Q = n5B[dI, Interval[{cuts[[k]], cuts[[k + 1]]}]]},
     If[! fitsFalseQ[{P, Q, n5A[RI, c]}], AppendTo[s3, cuts[[k ;; k + 1]]]];
     If[! fitsFalseQ[{P, Q, n5A[RI, -c]}], AppendTo[s4, cuts[[k ;; k + 1]]]]], {k, Length[cuts] - 1}];
  Print["  S3 cells: ", Length[s3], " range ", If[s3 === {}, {}, {Min[s3], Max[s3]}],
   "   S4 cells: ", Length[s4], " range ", If[s4 === {}, {}, {Min[s4], Max[s4]}]]];
cuts = Union[Join[Table[x, {x, -2.1, 2.1, 0.05}], Table[x, {x, -0.1, 0.1, 0.0005}]]];
Do[Print["h=", h]; dbg[iv[1.642, 1.642], iv[0.9532 - h, 0.9532 + h], iv[-h, h], cuts], {h, {0, 0.001, 0.003}}];
Print["point (R5+1e-3, d*, 0):"]; dbg[iv[1.642, 1.642], iv[0.9532, 0.9532], iv[0, 0], cuts];
