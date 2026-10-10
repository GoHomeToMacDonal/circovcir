#!/usr/bin/env wolframscript
(* ============================================================================
   Certificate 05g : self-contained proof of the n = 10 structure lemma
   (proofs/06 P2, path (b)) -- every computational step of
   proofs/08-p2-n10-selfcontained.md, WITHOUT relying on Melissen 1997 and
   WITHOUT [FT]'s unproved h-symmetry claim or its (false in general) bound G1.

   R = r_10 = 1 + 2 Cos[2 Pi/9].  All gates are exact identities, outward-rounded
   point enclosures, or outward-rounded interval branch-and-bound (WL Interval,
   precision 30).  Section labels match proofs/08.

   (N)  elementary angle inequalities used by the counting arguments, and the
        Z_8 index-set count (N7).
   (B)  h-lemma.  For p = (rho,0) let beta_rho(x) be the END angle of the unit disk
        through p whose arc on bd C_10 STARTS at R e^{ix}.  Gates:
          B0  2 beta(0) == H(rho) := 4 ArcTan[2 Sqrt[1-(R-rho)^2/4]/(R+rho)]  (exact)
          B1  tau-family b(t) (disk centre p + e^{it}): b'(t) > 0 on [-tB, tB - delta tB],
              b''(t) < 0 on [tB - delta tB, tB]   (rho in [3/4, 349/200])
          B2  phi(x) = beta(x)+beta(-x): phi''<0 on [0,1/16], phi'<0 on [1/16, sstar(rho)],
              with guards |X-p|<2 and "X is the start" at +-x
          B3  H'' < 0 on [3/4, 349/200];  H' > 0 on [3/4, 59/50]
          B0p H(rho_top) = 4 asin(1/R) exactly; B4 H(59/50) < Pi - 4 asin(1/R);
              2 amax(3/4) < 2Pi - 12 asin(1/R);  R-2 < 3/4 < Sqrt[R^2-4]
          B5  2 (59/50) sin(psimin/2) > 2,  2 (59/50) sin(ximin/2) > 2
   (L)  Lagrangian replacement of [FT] (13),(13'):  mu = -F'(astar)/f'(astar) > 0,
        f'' < 0 and F'' < 0 on [Pi/3, Pi], small-alpha branch
        seg(thc) + mu thc + Sqrt[3]/4 < F(astar) + mu f(astar), for astar = a0 (Case 1, 8 cells)
        and astar = b0 (Case 2, 7 cells).  Yields sum a(R_i) <= 8 F(a0), resp. 7 F(b0).
   (P)  pentagon (10): max of  sin(u)cos(u) + sin(w)cos(w) + T2  <= 2.28458
        over [0,Pi/2]^2 (T2 = 2 sin u sin w, or Heron(2sin u, 2sin w, 2) when
        sin^2u+sin^2w >= 1), interval B&B with mean-value form.
   (T)  Case 1 and Case 2 area totals < Pi R^2.

   Usage (repo root):
     wolframscript -file proofs/certificates/05g-p2-n10-selfcontained.wls ; echo "EXIT=$?"
   Exit 0 iff every gate is True and every B&B tree closed.  No randomness.
   ============================================================================ *)

$bbPrec = 30;
encl[x_] := Module[{c = SetPrecision[x, $bbPrec + 10], e},
  e = 10^(-$bbPrec + 5) (1 + Abs[c]);
  Interval[{SetPrecision[c - e, $bbPrec], SetPrecision[c + e, $bbPrec]}]];
ivOf[{lo_, hi_}] := Interval[{SetPrecision[lo, $bbPrec], SetPrecision[hi, $bbPrec]}];
finiteQ[x_] := NumericQ[x] && Element[x, Reals] && Abs[x] < Infinity;
loOf[iv_] := Module[{m = Quiet[Min[iv]]}, If[finiteQ[m], m, -Infinity]];
hiOf[iv_] := Module[{m = Quiet[Max[iv]]}, If[finiteQ[m], m, Infinity]];
posQ[iv_] := Module[{l = loOf[iv]}, finiteQ[l] && l > 0];
negQ[iv_] := Module[{h = hiOf[iv]}, finiteQ[h] && h < 0];
realIvQ[iv_] := Head[iv] === Interval && finiteQ[loOf[iv]] && finiteQ[hiOf[iv]];
ltQ[a_, b_] := Module[{x = encl[a], y = encl[b]}, finiteQ[hiOf[x]] && hiOf[x] < loOf[y]];
bb[test_, box0_, maxDepth_, maxBoxes_] := Module[
  {stack = {{box0, 0}}, nOk = 0, nDrop = 0, nDeep = 0, nBox = 0, box, dep, res, k, m},
  While[stack =!= {} && nBox < maxBoxes,
   {box, dep} = First[stack]; stack = Rest[stack]; nBox++;
   res = Quiet[test[box]];
   Switch[res, "ok", nOk++, "drop", nDrop++, _,
    If[dep >= maxDepth, nDeep++,
     k = First[Ordering[(#[[2]] - #[[1]]) & /@ box, -1]];
     m = (box[[k, 1]] + box[[k, 2]])/2;
     stack = Join[{{ReplacePart[box, k -> {box[[k, 1]], m}], dep + 1},
                   {ReplacePart[box, k -> {m, box[[k, 2]]}], dep + 1}}, stack]]]];
  <|"boxes" -> nBox, "ok" -> nOk, "drop" -> nDrop, "deep" -> nDeep,
    "closed" -> (stack === {} && nDeep == 0)|>];
bbOK[res_] := TrueQ[res["closed"]];

Rx = 1 + 2 Cos[2 Pi/9]; Ri = encl[Rx];
asin1 = ArcSin[1/Rx]; asin2 = ArcSin[2/Rx];
psimin = 2 Pi - 2 asin2 - 6 asin1;  ximin = 2 Pi - 2 asin2 - 4 asin1;
rhoLo = 3/4; rhoTop = 349/200; rhoT = 59/50;
gates = <||>;
gate[name_, val_] := (gates[name] = TrueQ[val]; Print["  ", name, " : ", TrueQ[val]]);

(* ================================ (N) ======================================== *)
Print["(N) elementary angle inequalities, R = ", N[Rx, 20]];
gate["N1  7 asin(1/R) < Pi  (>= 8 disks meet bd)", ltQ[7 asin1, Pi]];
gate["N2  asin(2/R)+5asin(1/R) < Pi  (no triple point; (8))", ltQ[asin2 + 5 asin1, Pi]];
gate["N3  4asin(2/R)+6asin(1/R) < 2Pi  (two disjoint triples)", ltQ[4 asin2 + 6 asin1, 2 Pi]];
gate["N4  psimin > Pi/2", ltQ[Pi/2, psimin]];
gate["N5  ximin > Pi/2", ltQ[Pi/2, ximin]];
gate["N6  asin(2/R) + 2 asin(1/R) < Pi  (step sums are minor angles)", ltQ[asin2 + 2 asin1, Pi]];
Print["      psimin = ", N[psimin, 12], "   ximin = ", N[ximin, 12]];
(* N7: a subset of Z_8 whose pairwise cyclic distances avoid {3,4} has size <= 3,
   so two unit disks cannot contain all of p_1..p_8 (exhaustive over 2^8 subsets). *)
cycd[i_, j_] := Min[Mod[i - j, 8], Mod[j - i, 8]];
okSets = Select[Subsets[Range[0, 7]], AllTrue[Subsets[#, {2}], cycd @@ # <= 2 &] &];
gate["N7  max index set in one disk has size 3 (< 4 = 8/2)", Max[Length /@ okSets] == 3];

(* ================================ (B) ======================================== *)
Print["(B) h-lemma via beta_rho"];
Hf[rr_] := 4 ArcTan[2 Sqrt[1 - (RR - rr)^2/4]/(RR + rr)];
(* x-family *)
vX = {RR Cos[x] - r, RR Sin[x]}; l2 = vX . vX;
cX = ({r, 0} + {RR Cos[x], RR Sin[x]})/2 + Sqrt[1/l2 - 1/4] {-vX[[2]], vX[[1]]};
argP = (cX[[1]] D[cX[[2]], x] - cX[[2]] D[cX[[1]], x])/(cX . cX);
betaP = 2 argP - 1; betaPP = D[betaP, x];
crossX = RR Cos[x] cX[[2]] - RR Sin[x] cX[[1]];
phiP = betaP - (betaP /. x -> -x);  phiPP = betaPP + (betaPP /. x -> -x);
(* B0: at x = 0 the centre is ((r+R)/2, Sqrt[1-(R-r)^2/4]) and beta(0) = 2 arg c *)
c0 = cX /. x -> 0;
gate["B0  2 beta(0) == H(rho)  (exact)",
  FullSimplify[c0 - {(r + RR)/2, Sqrt[1 - (RR - r)^2/4]}, Assumptions -> 0 < r < RR < r + 2] === {0, 0}];
(* rho_top: symmetric config with both arcs maximal (each disk through Q=(R,0) and a
   point at angular distance thm = 2 asin(1/R), chord 2 => centre = chord midpoint). *)
thm = 2 ArcSin[1/Rx];
cTop = {Rx (1 + Cos[thm])/2, Rx Sin[thm]/2};
rhoTopX = cTop[[1]] - Sqrt[1 - cTop[[2]]^2];
gate["B0' H(rho_top) == 4 asin(1/R) exactly (RootReduce of quarter-angle tangents), rho_top < 349/200",
  (RootReduce[(2 Sqrt[1 - (Rx - rhoTopX)^2/4]/(Rx + rhoTopX)) - 1/Sqrt[Rx^2 - 1]] == 0) &&
  ltQ[rhoTopX, rhoTop] && ltQ[rhoLo, rhoTopX]];
Print["      rho_top = ", N[rhoTopX, 20]];
(* tau-family *)
n2T = r^2 + 1 + 2 r Cos[t]; wT = (RR^2 + n2T - 1)/(2 RR Sqrt[n2T]);
bpT = (1 + r Cos[t])/n2T - D[wT, t]/Sqrt[1 - wT^2]; bppT = D[bpT, t];
tB = ArcCos[(RR^2 - r^2 - 4)/(4 r)];
sStar = Module[{ct = (RR^2 - r^2 - 4)/(4 r), st, n2s},
   st = Sqrt[1 - ct^2]; n2s = r^2 + 1 + 2 r ct;
   ArcTan[st/(r + ct)] - ArcCos[(RR^2 + n2s - 1)/(2 RR Sqrt[n2s])]];
mk[e_, vars_] := Function @@ {vars, e /. RR -> Ri};
fBp = mk[bpT /. t -> u tB, {r, u}]; fBpp = mk[bppT /. t -> u tB, {r, u}];
fW = mk[1 - wT^2 /. t -> u tB, {r, u}];
fPhiP = mk[phiP, {r, x}]; fPhiPP = mk[phiPP, {r, x}];
fL2 = mk[{4 - l2, 4 - (l2 /. x -> -x)}, {r, x}];
fCross = mk[{crossX, crossX /. x -> -x}, {r, x}];
fS = mk[sStar, {r}];
(* sanity (not a gate of the proof, a gate of the code): b'(tB) = 0 numerically *)
bpAtTB = Quiet[N[(bpT /. t -> tB) /. {RR -> Rx, r -> 6/5}, 25]];
Print["      sanity b'(tB) at rho=6/5 : ", bpAtTB];
delta = 1/16; x1 = 1/16;
testB1[box_] := Module[{ri = ivOf[box[[1]]], ui = ivOf[box[[2]]]},
  If[! posQ[fW[ri, ui]], Return["split"]];
  If[box[[2, 2]] <= 1 - delta, If[posQ[fBp[ri, ui]], "ok", "split"],
   If[box[[2, 1]] >= 1 - delta, If[negQ[fBpp[ri, ui]], "ok", "split"], "split"]]];
testB2[box_] := Module[{ri = ivOf[box[[1]]], xi = ivOf[box[[2]]], s},
  s = fS[ri];
  If[! realIvQ[s], Return["split"]];
  If[box[[2, 1]] > hiOf[s], Return["drop"]];
  If[! (AllTrue[fL2[ri, xi], posQ] && AllTrue[fCross[ri, xi], posQ]), Return["split"]];
  If[box[[2, 2]] <= x1, If[negQ[fPhiPP[ri, xi]], "ok", "split"],
   If[box[[2, 1]] >= x1, If[negQ[fPhiP[ri, xi]], "ok", "split"], "split"]]];
resB1 = bb[testB1, {{rhoLo, rhoTop}, {-1, 1}}, 40, 200000]; Print["      B1 tree: ", resB1];
gate["B1  b'>0 on [-tB,(1-1/16)tB], b''<0 on [(1-1/16)tB,tB]", bbOK[resB1] && Abs[bpAtTB] < 10^-20];
resB2 = bb[testB2, {{rhoLo, rhoTop}, {0, 1}}, 40, 200000]; Print["      B2 tree: ", resB2];
gate["B2  phi''<0 on [0,1/16], phi'<0 on [1/16,s*]", bbOK[resB2]];
Hp = mk[D[Hf[r], r], {r}]; Hpp = mk[D[Hf[r], {r, 2}], {r}];
resB3a = bb[Function[box, If[negQ[Hpp[ivOf[box[[1]]]]], "ok", "split"]], {{rhoLo, rhoTop}}, 30, 10000];
resB3b = bb[Function[box, If[posQ[Hp[ivOf[box[[1]]]]], "ok", "split"]], {{rhoLo, rhoT}}, 30, 10000];
gate["B3  H''<0 on [3/4,349/200], H'>0 on [3/4,59/50]", bbOK[resB3a] && bbOK[resB3b]];
HR[rr_] := Hf[rr] /. RR -> Rx;
amaxF[rr_] := ArcCos[(Rx^2 + rr^2 - 4)/(2 Rx rr)];
gate["B4  H(59/50)<Pi-4asin(1/R), 2amax(3/4)<2Pi-12asin(1/R), R-2<3/4<Sqrt[R^2-4]",
  ltQ[HR[rhoT], Pi - 4 asin1] &&
  ltQ[2 amaxF[rhoLo], 2 Pi - 12 asin1] && ltQ[Rx - 2, rhoLo] && ltQ[rhoLo, Sqrt[Rx^2 - 4]]];
Print["      Pi-4asin-H(59/50) = ", N[Pi - 4 asin1 - HR[rhoT], 6]];
gate["B5  2(59/50)sin(psimin/2)>2, 2(59/50)sin(ximin/2)>2",
  ltQ[2, 2 rhoT Sin[psimin/2]] && ltQ[2, 2 rhoT Sin[ximin/2]]];
Print["      |p_i p_i+3| >= ", N[2 rhoT Sin[psimin/2], 10], "   |p_i p_i+4| >= ", N[2 rhoT Sin[ximin/2], 10]];

(* ================================ (L) ======================================== *)
Print["(L) Lagrangian replacement of (13), (13')"];
fx[a_] := 2 ArcSin[Sin[a/2]/Rx]; Fx[a_] := Rx^2/2 (fx[a] - Sin[fx[a]]) + Sin[a]/2;
seg[th_] := Rx^2/2 (th - Sin[th]);
fppI = Function @@ {{al}, D[2 ArcSin[Sin[al/2]/RR], {al, 2}] /. RR -> Ri};
FppI = Function @@ {{al}, D[RR^2/2 (2 ArcSin[Sin[al/2]/RR] - Sin[2 ArcSin[Sin[al/2]/RR]]) + Sin[al]/2, {al, 2}] /. RR -> Ri};
resL0 = bb[Function[box, With[{ai = ivOf[box[[1]] Pi]}, If[negQ[fppI[ai]] && negQ[FppI[ai]], "ok", "split"]]],
   {{1/3, 1}}, 30, 10000];
gate["L0  f''<0 and F''<0 on [Pi/3, Pi]", bbOK[resL0]];
thc = 2 ArcSin[1/(2 Rx)];
lag[ncell_, xmax_] := Module[{phiT, as, fp, Fp, mu, ok},
  phiT = (2 Pi - xmax)/ncell;                       (* f(astar) = phiT *)
  as = 2 ArcSin[Rx Sin[phiT/2]];
  fp = D[fx[a], a] /. a -> as; Fp = D[Fx[a], a] /. a -> as;
  mu = -Fp/fp;
  ok = ltQ[0, fp] && ltQ[Fp, 0] && ltQ[Pi/3, as] && ltQ[as, Pi] &&
       ltQ[seg[thc] + mu thc + Sqrt[3]/4, Fx[as] + mu fx[as]] &&
       ltQ[0, phiT] && ltQ[phiT, Pi] && ltQ[Rx Sin[phiT/2], 1];  (* f(as) = phiT by construction *)
  Print["      cells=", ncell, "  a*=", N[as, 12], "  mu=", N[mu, 8],
        "  small-alpha slack=", N[Fx[as] + mu fx[as] - seg[thc] - mu thc - Sqrt[3]/4, 6],
        "  bound=", N[ncell Fx[as], 12]];
  {ok, ncell Fx[as]}];
{okL1, sumR1} = lag[8, 2 asin1];
{okL2, sumR2} = lag[7, 4 asin1];
gate["L1  Case 1: sum a(R_i) <= 8 F(a0)", okL1];
gate["L2  Case 2: sum a(R_i) <= 7 F(b0)", okL2];

(* ================================ (P) ======================================== *)
Print["(P) pentagon bound (10)"];
Gq = 1/2 Sin[2 u] + 1/2 Sin[2 w] + 2 Sin[u] Sin[w];
dd1 = 2 Sin[u]; dd2 = 2 Sin[w];
Gh = 1/2 Sin[2 u] + 1/2 Sin[2 w] +
   1/4 Sqrt[(dd1 + dd2 + 2) (-dd1 + dd2 + 2) (dd1 - dd2 + 2) (dd1 + dd2 - 2)];
sub = {u -> Pi/2 s1, w -> Pi/2 s2};
fGq = Function @@ {{s1, s2}, Gq /. sub}; fGh = Function @@ {{s1, s2}, Gh /. sub};
fQ = Function @@ {{s1, s2}, dd1^2 + dd2^2 - 4 /. sub};
gGq = Function @@ {{s1, s2}, {D[Gq /. sub, s1], D[Gq /. sub, s2]}};
gGh = Function @@ {{s1, s2}, {D[Gh /. sub, s1], D[Gh /. sub, s2]}};
Bp = 228458/100000;
mvHi[f_, g_, box_] := Module[{m = Mean /@ box, iv = ivOf /@ box, fm, gr},
  fm = f @@ (ivOf[{#, #}] & /@ m); gr = g @@ iv;
  Min[hiOf[f @@ iv], hiOf[fm + Total[gr (iv - m)]]]];
tP[box_] := Module[{q = fQ @@ (ivOf /@ box), hb},
  hb = mvHi[fGq, gGq, box];
  If[loOf[q] >= 0, hb = Min[hb, mvHi[fGh, gGh, box]]];
  If[finiteQ[hb] && hb < Bp, "ok", "split"]];
resP = bb[tP, {{0, 1}, {0, 1}}, 40, 400000]; Print["      P tree: ", resP];
gate["P   a(P_2) <= 2.28458", bbOK[resP]];

(* ================================ (T) ======================================== *)
Print["(T) area totals"];
aC = Pi Rx^2; sg = seg[2 asin1];
case1 = 8 Sin[Pi/4] + Bp + sg + 7 + sumR1;
case2 = 7 Sin[2 Pi/7] + 2 Bp + 2 sg + 5 + sumR2;
Print["      a(C10) = ", N[aC, 12], "  Case1 = ", N[case1, 12], "  (slack ", N[aC - case1, 6],
      ")  Case2 = ", N[case2, 12], "  (slack ", N[aC - case2, 6], ")"];
gate["T1  Case 1 total < Pi R^2", ltQ[case1, aC]];
gate["T2  Case 2 total < Pi R^2", ltQ[case2, aC]];

Print["------------------------------------------------------------"];
If[AllTrue[Values[gates], TrueQ],
  Print["CERTIFICATE OK (L3): all ", Length[gates], " gates of proofs/08 (P2 path b) hold."]; Exit[0],
  Print["CERTIFICATE FAILED: ", Keys[Select[gates, ! # &]]]; Exit[1]];
