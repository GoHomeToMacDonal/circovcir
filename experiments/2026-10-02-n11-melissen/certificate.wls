#!/usr/bin/env wolframscript
(* L3 EXACT scaling certificate for n=11 (Melissen record).

   docs/methods.md: the rigorous numeric certificate for a float-optimised cover is the SCALING
   certificate -- if rho = rho(c,R) is the covering radius, then UNIT disks at c/rho cover
   D(0, R/rho) EXACTLY. With rational centers and rational R, every candidate point is an
   algebraic number, so rho^2 is computed by exact algebraic arithmetic (RootReduce), and the
   inequality R/rho > 2.631 is decided by exact sign. No floating point enters the proof.

   Output: prints the certificate and writes proofs/certificates/06-n11-interval.wls (re-runnable)
   plus data/configs/11/20261002-melissen-exact.json (status verified-exact).
   Usage: certificate.wls [denomDigits] [R_numer/1e5]
*)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
dd  = If[Length[args] >= 1, ToExpression[args[[1]]], 15];
Rnum = If[Length[args] >= 2, ToExpression[args[[2]]], 263165];   (* R = Rnum/10^5 *)

cfg = LoadConfig[FileNameJoin[{root, "data", "configs", "11", "20261002-melissen-tight.json"}]];
csHi = cfg["Centers"]; Rhi = cfg["RValue"];
cs = Map[Round[# 10^dd]/10^dd &, N[csHi, dd + 25], {2}];   (* exact rationals *)
Rr = Rnum/10^5;                                            (* exact rational R *)
Print["centers: exact rationals, denominator 10^", dd];
Print["R_rational = ", InputForm[Rr], " = ", InputForm[N[Rr, 15]]];

(* exact covering radius squared over the finite candidate set *)
cps = CandidatePoints[cs, Rr];
Print["candidate points: ", Length[cps], " (all algebraic)"];
nd2 = Function[p, Min[(p - #).(p - #) & /@ cs]] /@ cps;
rho2 = RootReduce[Max[nd2]];
rho = Sqrt[rho2];
Rcert = RootReduce[Rr/rho];
Print["rho^2 (exact)      ~ ", InputForm[N[rho2, 25]]];
Print["R_certified = R/rho ~ ", InputForm[N[Rcert, 25]]];

(* exact sign decisions *)
gt2631  = RootReduce[Rcert - 2631/1000]  > 0;
gt26316 = RootReduce[Rcert - 26316/10000] > 0;
Print["EXACT: R_certified > 2.631   -> ", gt2631];
Print["EXACT: R_certified > 2.6316  -> ", gt26316];

If[gt2631 === True,
  Print["\n*** L3 SCALING CERTIFICATE ESTABLISHED ***"];
  Print["Unit disks at the exact rational centers c/rho cover D(0, R_certified) exactly,"];
  Print["with R_certified > 2.631 proved by exact sign determination (no floating point)."];
  (* re-runnable certificate script *)
  certBody = StringJoin[
    "(* 06-n11-interval.wls -- L3 exact scaling certificate for n=11 (Melissen record). *)\n",
    "(* Re-run: wolframscript -file proofs/certificates/06-n11-interval.wls ; expect exit 0. *)\n",
    "root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];\n",
    "Get[FileNameJoin[{root, \"wl\", \"CirCovCir.wl\"}]];\n",
    "cs = ", ToString[cs, InputForm], ";\n",
    "Rr = ", ToString[Rr, InputForm], ";\n",
    "cps = CandidatePoints[cs, Rr];\n",
    "rho2 = RootReduce[Max[Function[p, Min[(p - #) . (p - #) & /@ cs]] /@ cps]];\n",
    "Rcert = RootReduce[Rr/Sqrt[rho2]];\n",
    "E1 = (RootReduce[Rcert - 2631/1000] > 0);   (* R_certified > printed record 2.631 *)\n",
    "E2 = (RootReduce[Rcert - 26316/10000] > 0);  (* stronger: > 2.6316 *)\n",
    "Print[\"R_certified ~ \", InputForm[N[Rcert, 20]]];\n",
    "Print[\"E1 (>2.631)=\", E1, \"  E2 (>2.6316)=\", E2];\n",
    "If[E1 && E2, Print[\"n=11 L3 certificate OK\"]; Exit[0], Print[\"FAIL\"]; Exit[1]];\n"];
  Export[FileNameJoin[{root, "proofs", "certificates", "06-n11-interval.wls"}], certBody, "Text"];
  Print["wrote proofs/certificates/06-n11-interval.wls"];
  (* certificate config *)
  dec[x_] := StringReplace[ToString[N[x, 30], InputForm, NumberMarks -> False], {"*^" -> "e", "`" ~~ ___ ~~ "." -> "", "`" ~~ ___ -> ""}];
  out = <|"n" -> 11,
    "R" -> dec[Rcert],
    "R_wl" -> ToString[Rcert, InputForm],
    "centers" -> Map[dec[#/rho] &, cs, {2}],
    "centers_wl" -> ToString[cs/rho, InputForm],
    "status" -> "verified-exact",
    "source" -> "Hans Melissen 1997 (record); exact scaling certificate",
    "provenance" -> "experiments/2026-10-02-n11-melissen/certificate.wls : tight centers -> rational (denom 10^"<>ToString[dd]<>"), exact rho^2 via RootReduce over finite candidate set, R_certified=R/rho, exact sign R_certified>2.631",
    "checks" -> <|"method" -> "exact scaling certificate (finite candidate set, RootReduce)",
       "rho2_N" -> dec[rho2],
       "R_certified_N" -> dec[Rcert],
       "R_certified_gt_2631" -> True, "R_certified_gt_2.6316" -> (gt26316 === True),
       "certificate_script" -> "proofs/certificates/06-n11-interval.wls"|>
    |>;
  Export[FileNameJoin[{root, "data", "configs", "11", "20261002-melissen-exact.json"}], out, "RawJSON", "Compact" -> False];
  Print["wrote data/configs/11/20261002-melissen-exact.json (status verified-exact)"],
  Print["\nR_certified not > 2.631 at this denominator/R -- adjust and retry."]];
