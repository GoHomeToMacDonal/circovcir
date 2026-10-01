#!/usr/bin/env wolframscript
(* Self-tests for CirCovCir`. Exit code 0 iff all pass.
   Usage (repo root):  wolframscript -file wl/tests/run_tests.wls *)

Get[FileNameJoin[{ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]], "CirCovCir.wl"}]];

ring[k_, rad_, ph_ : 0] := Table[rad {Cos[ph + 2 Pi j/k], Sin[ph + 2 Pi j/k]}, {j, 0, k - 1}];
c3 = ring[3, 1/Sqrt[3]];
c4 = ring[4, 1, Pi/4];
c7 = Join[{{0, 0}}, ring[6, Sqrt[3]]];

tests = {
  VerificationTest[ExactCoverQ[c3, 2/Sqrt[3]], True, TestID -> "n3 exact cover at optimum"],
  VerificationTest[ExactCoverQ[c3, 2/Sqrt[3] + 10^-20], False, TestID -> "n3 not covered beyond"],
  VerificationTest[ExactCoverQ[c4, Sqrt[2]], True, TestID -> "n4 exact cover"],
  VerificationTest[ExactCoverQ[c7, 2], True, TestID -> "n7 exact cover"],
  VerificationTest[ExactCoverQ[c7, 2 + 10^-30], False, TestID -> "n7 tight"],
  VerificationTest[Abs[MaxCoveredRadius[c7, WorkingPrecision -> 40] - 2] < 10^-30, True,
   TestID -> "n7 high-precision R"],
  VerificationTest[Abs[MaxCoveredRadius[c3, WorkingPrecision -> MachinePrecision] - 2/Sqrt[3]] < 10^-9,
   True, TestID -> "n3 machine R"],
  VerificationTest[CoveringRadius[{{0, 0}}, 1], 1., TestID -> "n1 radius"],
  VerificationTest[CirCovCir`Private`parseDecimal["1.5e-05"], 3/200000, TestID -> "parse exponent"],
  VerificationTest[Abs[CirCovCir`Private`parseDecimal["0.12345678901234567890123456789012345"] -
     12345678901234567890123456789012345/10^35] < 10^-40, True, TestID -> "parse keeps digits"],
  VerificationTest[CoveredArc[1, 1], 2 Pi/3, TestID -> "arc unit circle d=1"],
  VerificationTest[CoveredArc[1/3, 1/2], 2 Pi, TestID -> "arc whole circle"],
  VerificationTest[CoveredArc[3, 1], 0, TestID -> "arc disjoint"],
  VerificationTest[FullSimplify[CoveredArc[2, Sqrt[3]] - MaxCoveredArc[2]], 0,
   TestID -> "arc max at d=sqrt(r^2-1)"],
  VerificationTest[Table[FullSimplify[RingAlpha[2 Pi/k, RingRadius[k]] - 2 Pi/k], {k, 6, 9}],
   {0, 0, 0, 0}, TestID -> "ring fixed point alpha=beta=2pi/k"],
  VerificationTest[Table[ExactCoverQ[RingConfig[k], RingRadius[k]], {k, {6, 7, 8, 9}}],
   {True, True, True, True}, TestID -> "ring exact cover n=7..10"],
  VerificationTest[ExactCoverQ[RingConfig[8], RingRadius[8] + 10^-30], False,
   TestID -> "ring n=9 tight"],
  VerificationTest[IdentifyClosedForm[N[Sqrt[6] + Sqrt[3], 60], 4]["radicals"] // FullSimplify,
   Sqrt[3] + Sqrt[6], SameTest -> (FullSimplify[#1 - #2] == 0 &), TestID -> "identify sqrt6+sqrt3"]
};

report = TestReport[tests];
Print["passed: ", report["TestsSucceededCount"], "  failed: ", report["TestsFailedCount"]];
Scan[Print["FAILED ", #["TestID"], "  got ", #["ActualOutput"]] &,
  Flatten[Values /@ Values[report["TestsFailed"]]]];
Exit[If[report["TestsFailedCount"] == 0, 0, 1]];
