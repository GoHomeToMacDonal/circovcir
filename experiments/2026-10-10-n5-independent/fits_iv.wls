#!/usr/bin/env wolframscript
(* Prototype/timing for the IG' sweep (proofs/09 §6'). Not a certificate. *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "..", "proofs", "certificates", "09lib-n5.wl"}]];
iv[a_, b_] := Interval[{N[a], N[b]}];
(* sanity: fitsFalseQ on point data *)
Print["fits test, should be False (fits) at optimum-ish: ",
  fitsFalseQ[{n5A[iv[1.6, 1.6], iv[0, 0]], n5B[iv[0.95, 0.95], iv[0, 0]], n5A[iv[1.6, 1.6], iv[1.0, 1.0]]}]];
Print["fits test, should be True (far apart): ",
  fitsFalseQ[{n5A[iv[1.6, 1.6], iv[0, 0]], n5B[iv[0.95, 0.95], iv[0, 0]], n5A[iv[1.6, 1.6], iv[2.0, 2.0]]}]];
Do[
  Module[{t, r},
   {t, r} = AbsoluteTiming[igBoxQ[iv[1.642, 1.6425], iv[0.95 - h, 0.95 + h], iv[-h, h], 2.1, 400]];
   Print["h=", h, "  certified=", r, "  time=", t]], {h, {0.02, 0.01, 0.005, 0.002}}];
(* control: at R slightly below R5, around the optimum, must NOT certify *)
Print["control (R<R5, should be False): ", igBoxQ[iv[1.6409, 1.6409], iv[0.9531, 0.9532], iv[-0.0001, 0.0001], 2.1, 400]];
