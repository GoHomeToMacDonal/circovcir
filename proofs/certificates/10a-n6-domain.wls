#!/usr/bin/env wolframscript
(* Certificate 10a for proofs/10-n6-half.md: domain facts for the n=6 half-problem.
   Domain Dom:  R in [Rlo, Rhi],  a, b >= R - 1,  a + b <= 2   (Rlo = 1.798867827575 < R6).
   Gates (F1,F2 interval B&B over (R,a,b), machine Interval arithmetic, outward rounded):
     (F1) |T1 - T2|^2 > 4         => no unit disk contains both corner points T1, T2
     (F2) |V|^2 < R^2             => V lies in the interior of Cn
     (F3) a, b <= 3 - Rlo < 1 + Rlo, and R - 1 < 1 < R + 1 (exact): dC1, dC2 meet dCn in two points
     (F4) Rlo > 1/Sin[Pi/5] (exact):  10 alpha < 2 Pi, used by the counting lemma H1
   Exit 1 on failure; last line "CERTIFICATE OK". *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "10lib-n6.wl"}]];
fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];
Off[General::munfl];

Rlo = 1798867827575/10^12; Rhi = Rlo + 1/1000;
amin = Rlo - 1; amax = 3 - Rlo;

skipQ[{{r1_, r2_}, {a1_, a2_}, {b1_, b2_}}] := a2 < r1 - 1 || b2 < r1 - 1 || a1 + b1 > 2;

mk[f_] := Function[box, If[skipQ[box], "skip",
    With[{RI = N[Interval[box[[1]]]], aI = N[Interval[box[[2]]]], bI = N[Interval[box[[3]]]]},
     ivMin[f[RI, aI, bI]] > 0]]];

preds = <|
   "F1 |T1-T2|^2 > 4" -> Function[{R, a, b}, n6sq[n6T1[R, a] - n6T2[R, b]] - 4],
   "F2 |V|^2 < R^2" -> Function[{R, a, b}, R^2 - n6sq[n6V[a, b]]]|>;

box0 = {{Rlo, Rhi}, {amin, amax}, {amin, amax}};
scale = {Rhi - Rlo, amax - amin, amax - amin};
KeyValueMap[Function[{name, f}, n6boxes = 0;
   Module[{t, r}, {t, r} = AbsoluteTiming[n6prove[mk[f], box0, scale, 40]];
    Print["  ", name, ": boxes ", n6boxes, ", ", Round[t, 0.1], " s"]; gate[name, r]]], preds];

gate["F3 circle intersections exist", amax < 1 + Rlo && Rlo - 1 < 1];
(* F4 (counting, proofs/10 Lemma H1): 10 alpha(R) < 2 Pi for R >= Rlo, i.e. Rlo > 1/Sin[Pi/5] *)
gate["F4 Rlo > 1/Sin[Pi/5]  (=> 2Pi - 2 alpha > 8 alpha)", Reduce[Rlo > 1/Sin[Pi/5]]];
(* negative control: a false claim must NOT be certified *)
n6boxes = 0;
gate["C0 control (|T1-T2|^2 > 16 is false somewhere: not certified)",
  ! n6prove[mk[Function[{R, a, b}, n6sq[n6T1[R, a] - n6T2[R, b]] - 16]], box0, scale, 12]];
Print["CERTIFICATE OK"];
