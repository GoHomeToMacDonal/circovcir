#!/usr/bin/env wolframscript
(* Single entry point for the 2026-10-09 P1 structure-lemma (n=8,9) experiment.
   Delegates to the sealed certificate so there is ONE source of truth.
   Reproduce (repo root):
     wolframscript -file experiments/2026-10-09-p1-structure/run.wls ; echo "EXIT=$?"
   Exit code mirrors the certificate: 0 iff all checks pass. *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
cert = FileNameJoin[{root, "proofs", "certificates", "05e-p1-structure-n8-n9.wls"}];
Print["Running certificate: ", cert];
Print["============================================================"];
(* Run in a subprocess so its Exit[] becomes this script's exit code too.
   Resolve the wolframscript binary from $CommandLine, else the known 14.3 path. *)
wsExe = SelectFirst[$CommandLine, StringContainsQ[#, "wolframscript"] &,
   FileNameJoin[{$HomeDirectory, "Wolfram", "Mathematica", "14.3", "Executables", "wolframscript"}]];
code = RunProcess[{wsExe, "-file", cert}, "ExitCode"];
Print["============================================================"];
Print["certificate EXIT=", code];
Exit[code];
