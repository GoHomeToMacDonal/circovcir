#!/usr/bin/env wolframscript
(* Certificate 09e for proofs/09-n5-independent.md: global sweep (fits predicate, §6').
   Outer domain (R, d, psi) in [R5lo, Rhi] x [dlo, 1] x [-w0, w0]  (w0 = 9/100 >= w by 09a G6).
   Inner variable phi / t over [-phimax, phimax], phimax = 5/2 (>= phiT on the domain, gate F0).
   With P = A(psi), c = psiT - 2 alpha:
     (F1) IG-outside:  fits(P, B(phi), A(c))  is false for all phi in [-phimax, -Phi0]
                       fits(P, B(phi), A(-c)) is false for all phi in [Phi0, phimax]       (Phi0 = 15/100)
          => S3 ⊆ (-Phi0, ..], S4 ⊆ [.., Phi0): together with 09d this closes the good case G.
     (F2) case (a):    for all t: fits(T_R, B(t), A(psi + 2 alpha)) false  or  fits(P, B(t), A(-c)) false
     (F3) case (a0):   fits(T_R, T_L, A(psi + 2 alpha)) false
     (F4) case (c):    for all t: fits(T_R, B(t), A(psi + 2 alpha)) false  or  fits(T_L, B(t), A(psi - 2 alpha)) false
   Boxes with |psi| > w(R,d) everywhere are vacuous (L2c).
   Each outer box is accepted when every inner cell passes (inner cells are bisected up to 6 times);
   otherwise the outer box is bisected along its relatively widest side.
   (C0) negative control: the sweep must refuse "fits(P,B(phi),A(c)) false for phi in [-phimax, 1/10]"
        at the optimum, which is false.
   Exit 1 on failure; last line "CERTIFICATE OK". *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "09lib-n5.wl"}]];
fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];
Off[General::munfl];

R5lo = 1641004/1000000; Rhi = 1643/1000; dlo = 845/1000; w0 = 9/100; Phi0 = 15/100; phimax = 5/2;
ivl[{a_, b_}] := Interval[N[{a, b}]];

(* F0: phiT <= phimax.  phiT = angle at C1's centre: cos(pi - phiT) = (yT - d) *)
gate["F0 phiT <= phimax", Max[N[Pi - ArcCos[n5yT[ivl[{R5lo, Rhi}], ivl[{dlo, 1}]] - ivl[{dlo, 1}]]]] <= phimax];

(* inner sweep: pred[cellInterval] must return True (certified) for every cell of [a,b] *)
sweepQ[pred_, {a_, b_}, n_, depth_] := AllTrue[Partition[Subdivide[N[a], N[b], n], 2, 1],
   Function[cl, cellQ[pred, cl, depth]]];
cellQ[pred_, {u_, v_}, depth_] := pred[Interval[{u, v}]] ||
   (depth > 0 && With[{m = (u + v)/2}, cellQ[pred, {u, m}, depth - 1] && cellQ[pred, {m, v}, depth - 1]]);

boxChecks[{RB_, dB_, sB_}] := Module[{RI = ivl[RB], dI = ivl[dB], sI = ivl[sB], al, c, P, TR, TL, X2p, X2m},
   al = n5al[RI]; c = n5psiT[RI, dI] - 2 al; P = n5A[RI, sI]; TR = n5TR[RI, dI]; TL = n5TL[RI, dI];
   X2p = n5A[RI, sI + 2 al]; X2m = n5A[RI, sI - 2 al];
   (* vacuous box: |psi| > w = 4 alpha - psiT everywhere in the box (L2c: psi_P in [-w, w]) *)
   If[Min[N[Abs[sI]]] > Max[N[4 al - n5psiT[RI, dI]]], Return[True, Module]];
   And[
    sweepQ[fitsFalseQ[{P, n5B[dI, #], n5A[RI, c]}] &, {-phimax, -Phi0}, 40, 6],
    sweepQ[fitsFalseQ[{P, n5B[dI, #], n5A[RI, -c]}] &, {Phi0, phimax}, 40, 6],
    sweepQ[(fitsFalseQ[{TR, n5B[dI, #], X2p}] || fitsFalseQ[{P, n5B[dI, #], n5A[RI, -c]}]) &, {-phimax, phimax}, 80, 6],
    fitsFalseQ[{TR, TL, X2p}],
    sweepQ[(fitsFalseQ[{TR, n5B[dI, #], X2p}] || fitsFalseQ[{TL, n5B[dI, #], X2m}]) &, {-phimax, phimax}, 80, 6]]];

scale = {Rhi - R5lo, 1 - dlo, 2 w0};
nBoxes = 0; maxDepth = 0;
proveBox[box_, depth_] := (nBoxes++;
   If[boxChecks[box], True,
    If[depth == 0, (Print["  stuck at ", N[box]]; False),
     Module[{k = Ordering[(#[[2]] - #[[1]]) & /@ box / scale, -1][[1]], m},
      m = (box[[k, 1]] + box[[k, 2]])/2;
      maxDepth = Max[maxDepth, 30 - depth + 1];
      proveBox[ReplacePart[box, k -> {box[[k, 1]], m}], depth - 1] &&
       proveBox[ReplacePart[box, k -> {m, box[[k, 2]]}], depth - 1]]]]);

(* C0 negative control at the optimum point box *)
Module[{RI = ivl[{1641005/1000000, 1641005/1000000}], dI = ivl[{953/1000, 953/1000}], P, c},
  c = n5psiT[RI, dI] - 2 n5al[RI]; P = n5A[RI, Interval[{0., 0.}]];
  gate["C0 control: sweep refuses a false claim",
   ! sweepQ[fitsFalseQ[{P, n5B[dI, #], n5A[RI, c]}] &, {-phimax, 1/10}, 40, 6]]];

{t, ok} = AbsoluteTiming[proveBox[{{R5lo, Rhi}, {dlo, 1}, {-w0, w0}}, 30]];
Print["  outer boxes ", nBoxes, ", max split depth ", maxDepth, ", ", Round[t, 0.1], " s"];
gate["F1-F4 on the whole domain", ok];
Print["CERTIFICATE OK"];
