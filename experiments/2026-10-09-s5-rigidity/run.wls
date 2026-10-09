#!/usr/bin/env wolframscript
(* Single entry point for experiment 2026-10-09-s5-rigidity.
   Runs the S5 equality=>congruence rigidity certificate and echoes its exit code.
   The certificate itself lives (and is version-reviewed) in proofs/certificates/ per
   AGENTS.md; this script only drives it so the experiment is reproducible from one call.

   Reproduce (repo root):
     wolframscript -file experiments/2026-10-09-s5-rigidity/run.wls
   or run the certificate directly:
     wolframscript -file proofs/certificates/05d-s5-equality-rigidity.wls ; echo "EXIT=$?"
*)
root = FileNameJoin[{DirectoryName[ExpandFileName[$InputFileName]], "..", ".."}];
cert = FileNameJoin[{root, "proofs", "certificates", "05d-s5-equality-rigidity.wls"}];
Print["Running S5 rigidity certificate: ", cert];
code = Run["\"" <> First[$CommandLine] <> "\" -file \"" <> cert <> "\""];
Print["certificate exit code = ", code];
Exit[code];
