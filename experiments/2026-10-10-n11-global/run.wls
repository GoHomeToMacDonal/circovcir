#!/usr/bin/env wolframscript
(* Deterministic entry point; no numerical search and no random seed needed. *)
here = DirectoryName[ExpandFileName[$InputFileName]];
root = DirectoryName[DirectoryName[here]];
exe = Environment["WOLFRAMSCRIPT"];
If[!StringQ[exe] || exe == "", exe = FileNameJoin[{$HomeDirectory, "Wolfram",
  "Mathematica", "14.3", "Executables", "wolframscript"}]];
If[!FileExistsQ[exe], Print["WolframScript executable not found: ", exe]; Exit[1]];
results = FileNameJoin[{here, "results"}];
If[!DirectoryQ[results], CreateDirectory[results]];
cases = {
  {"07-n11-local-opt.wls", "n=11 local-optimality certificate OK", "local-certificate.log"},
  {"11a-n11-global-reduction.wls", "CERTIFICATE OK (L3): n=11 arc reductions and CONDITIONAL wheel exclusion; global optimum NOT proved", "reduction.log"}
};
allOK = True;
Do[
  res = RunProcess[{exe, "-file", FileNameJoin[{root, "proofs", "certificates", spec[[1]]}]},
    ProcessDirectory -> root];
  good = AssociationQ[res] && res["ExitCode"] === 0 &&
    StringContainsQ[res["StandardOutput"], spec[[2]]];
  If[AssociationQ[res], Export[FileNameJoin[{results, spec[[3]]}],
    "exit=" <> ToString[res["ExitCode"]] <> "\n" <> res["StandardOutput"] <>
      "\nSTDERR:\n" <> res["StandardError"], "Text"]];
  Print[spec[[1]], " : ", good];
  allOK = allOK && TrueQ[good],
  {spec, cases}];
If[allOK, Print["REPRODUCTION OK: partial results only; global optimality remains unproved"]; Exit[0], Exit[1]];
