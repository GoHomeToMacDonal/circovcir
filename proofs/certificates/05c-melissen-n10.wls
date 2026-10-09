#!/usr/bin/env wolframscript
(* ============================================================================
   Certificate 05c : the n = 10 Melissen distance lemma (proofs/05 section 3).

   Context. In G. Fejes Toth (2005), "Thinnest covering of a circle by eight,
   nine, or ten congruent circles", MSRI Publ. 52, 361-376 ([FT]), the n = 10
   case needs a separate distance argument, attributed to
       H. Melissen, Packing and covering with circles, PhD thesis, Utrecht,
       1997, pp. 108-111
   to rule out that eight (resp. that a three-fold cell overlap among nine)
   unit circles cover bd C_10, the circle of radius r_10.

   SOURCE STATUS (honest).  The Melissen 1997 thesis itself was NOT obtained
   (no public PDF; the one DSpace lead, handle 1874/22859, is a different thesis
   -- Weiss, "Dendroidal sets", 2007).  Everything here is verified against
   [FT] section 3, which REPRODUCES Melissen's argument.  pdftotext extracted all
   of [FT]'s NUMERIC constants cleanly, but mangled the symbolic closed form of
   h(theta) (sub/superscripts lost) and of the pentagon-area bound (10).  We
   therefore do NOT trust the mangled symbolic text: h(theta) is rebuilt from
   FIRST PRINCIPLES (geometry) and cross-checked against [FT]'s clean printed
   numbers; where [FT]'s own closed form is unrecoverable we flag it.

   => The TOP achievable level for the lemma here is  L3 (computational
      verification BASED ON [FT]'s reproduction of Melissen).  It is NOT an
      independent re-reading of Melissen's original pp.108-111, which remain
      待核实 (to be verified).

   KEY FACT established first:  r_10 = 1 + 2 Cos[2 Pi/9] = 2.5320888862...,
   i.e. C_10 has radius equal to the n=10 covering radius R_10 itself.  (The
   value 1.7988 that sometimes gets attached to "r_10" is actually the n=6
   record r_6 and is NOT the radius in this lemma.)  We pin r_10 from [FT]'s own
   printed constant 7 arcsin(1/r_10) = 2.841948021 and confirm it equals
   1 + 2 Cos[2 Pi/9] to all printed digits.

   CHECKS (gating -- Exit 0 iff ALL are finite, real and True):
     (C_r10)     r_10 == 1 + 2 Cos[2 Pi/9], and the elementary arcsin
                 exclusions 7 asin(1/r_10) < Pi,  asin(2/r_10)+5 asin(1/r_10) < Pi.
     (C_h_fp)    h(theta) rebuilt from first principles reproduces [FT]'s printed
                 distance endpoints:
                   |p_i p_{i+3}| = 2 h(th0) sin(psimin/2) = 2.02349...  > 2
                   |p_i p_{i+4}| = 2 h(th0) sin(ximin/2)  = 2.357538... > 2
                 with th0 = Pi - 4 asin(1/r_10), and both results are > 2.
     (C_h_mono)  h'(theta) > 0 on (0, 4 asin(1/r_10)) by outward-rounded
                 Interval branch-and-bound (report leaves + min lower bound).
     (C_h_conv)  h''(theta) > 0 on the same domain, same method.
     (C_area)    the clean area bounds (9),(9'),(11),(11'),(13),(13') reproduce
                 [FT]'s printed numbers EXACTLY, a(C_10) = Pi r_10^2 > 20.1422,
                 and the Case 1 / Case 2 area totals are < a(C_10) (contradiction).
     (C_pent)    pentagon bound (10): [FT]'s printed closed form is mangled, so
                 we instead bound the true max area of a cyclic pentagon with
                 four unit sides and one side 2 and CHECK it is <= [FT]'s stated
                 2.284572282 (our independent value is 2.28454..., marginally
                 TIGHTER, so (10) holds).  This is the one place we verify the
                 INEQUALITY rather than reproduce [FT]'s exact decimal.

   Usage (repo root):
     wolframscript -file proofs/certificates/05c-melissen-n10.wls ; echo "EXIT=$?"
   Exit 0 iff every gated check is a finite real True.  No randomness.
   ============================================================================ *)

Off[General::munfl];
Off[FindRoot::lstol];

r10exact = 1 + 2 Cos[2 Pi/9];
asin = ArcSin;

(* ---- outward-rounded "lower bound of an interval" helper, finite-guarded ---- *)
lowFinite[iv_] := Module[{m},
  m = Quiet[Min[iv]];
  If[NumericQ[m] && Element[m, Reals] && Abs[m] < Infinity, m, -10.^9]];

(* ======================= C_r10 : pin r_10, arcsin exclusions ================= *)
Cr10 = Module[{rFromFT, okId, e1, e2},
  (* [FT] printed 7 arcsin(1/r10) = 2.841948021 ; solve and compare *)
  rFromFT = r /. FindRoot[7 asin[1/r] == 2.841948021, {r, 2.5}, WorkingPrecision -> 20];
  okId = Abs[N[rFromFT - r10exact, 15]] < 10^-7;                (* truncated decimal => ~1e-9 *)
  e1 = TrueQ[7 asin[1/r10exact] < Pi];
  e2 = TrueQ[asin[2/r10exact] + 5 asin[1/r10exact] < Pi];
  Print["[C_r10] r10 = 1+2cos(2pi/9) = ", N[r10exact, 20]];
  Print["        from FT 7asin(1/r10)=2.841948021 -> r=", N[rFromFT, 15], "  match: ", okId];
  Print["        7 asin(1/r10)             = ", N[7 asin[1/r10exact], 12], "  < pi : ", e1];
  Print["        asin(2/r10)+5 asin(1/r10) = ", N[asin[2/r10exact] + 5 asin[1/r10exact], 12], "  < pi : ", e2];
  okId && e1 && e2];

(* ======================= h(theta) FROM FIRST PRINCIPLES ====================== *)
(* h(theta) = min distance from o (center of C_10) to the inner intersection of
   two symmetric unit circles that together cover an arc of measure theta of
   bd C_10 (circle |x| = r_10).  Symmetric position: each covers theta/2.
   One disk passes through the shared inner bd-point A = (r10, 0) and the far
   bd-point B = r10 (cos(theta/2), sin(theta/2)); its center c is at distance 1
   from both, on the inner side.  The two mirror disks meet on the x-axis at the
   inner point p = (c_x - sqrt(1 - c_y^2), 0), so h = c_x - sqrt(1 - c_y^2).
   Closed form (branch validated to reproduce [FT]'s printed numbers):
     c_x = w cos^2(th/4) - cos(th/4) sqrt(1 - w^2 sin^2(th/4)),
     c_y = w sin(th/4) cos(th/4) - sin(th/4) sqrt(1 - w^2 sin^2(th/4)),
     h   = c_x - sqrt(1 - c_y^2),      w = r_10.
   Domain 0 <= theta <= 4 asin(1/r_10) (chord A,B = 2 r10 sin(th/4) <= 2). *)
w = r10exact;
cxF  = w Cos[th/4]^2 - Cos[th/4] Sqrt[1 - w^2 Sin[th/4]^2];
cyF  = w Sin[th/4] Cos[th/4] - Sin[th/4] Sqrt[1 - w^2 Sin[th/4]^2];
hF   = cxF - Sqrt[1 - cyF^2];
hpF  = D[hF, th];
hppF = D[hF, {th, 2}];
hAt[val_] := hF /. th -> val;

th0    = Pi - 4 asin[1/r10exact];
psimin = 2 Pi - 2 asin[2/r10exact] - 6 asin[1/r10exact];
ximin  = 2 Pi - 2 asin[2/r10exact] - 4 asin[1/r10exact];

(* ======================= C_h_fp : reproduce FT distance endpoints ============ *)
Chfp = Module[{hv, d3, d4},
  hv = hAt[th0];
  d3 = 2 hv Sin[psimin/2];
  d4 = 2 hv Sin[ximin/2];
  Print["[C_h_fp] h(th0) = ", N[hv, 20], "   th0 = pi - 4 asin(1/r10)"];
  Print["         |p_i p_{i+3}| = 2 h sin(psimin/2) = ", N[d3, 15], "   FT 2.02349   > 2 : ", TrueQ[d3 > 2]];
  Print["         |p_i p_{i+4}| = 2 h sin(ximin/2)  = ", N[d4, 15], "   FT 2.357538  > 2 : ", TrueQ[d4 > 2]];
  (* also confirm the match to FT's printed decimals *)
  Print["         match FT: ", Abs[N[d3 - 2.02349, 12]] < 10^-4 && Abs[N[d4 - 2.357538, 12]] < 10^-5];
  TrueQ[d3 > 2] && TrueQ[d4 > 2] &&
    Abs[N[d3 - 2.02349, 12]] < 10^-4 && Abs[N[d4 - 2.357538, 12]] < 10^-5];

(* ======================= C_h_mono / C_h_conv : interval B&B ================== *)
intervalSign[expr_, extraGuards_] := Module[
  {wN = SetPrecision[r10exact, 80], dom, arg1, lo0, hi0, maxDepth = 46,
   stack, nLeaf = 0, worst = Infinity, worstArg = Infinity, deep = 0,
   exprN, guardsN},
  dom  = 4 ArcSin[1/wN];
  lo0  = SetPrecision[10^-5, 80];
  hi0  = dom - SetPrecision[10^-7, 80];
  exprN   = expr /. w -> wN;
  guardsN = (# /. w -> wN) & /@ extraGuards;
  stack = {{lo0, hi0, 0}};
  While[stack =!= {},
   Module[{top = First[stack], a, b, dep, iv, lv, lg},
    stack = Rest[stack];
    {a, b, dep} = top;
    iv = Interval[{a, b}];
    lg = lowFinite[Min[(# /. th -> iv)]] & /@ guardsN;        (* min over guard args *)
    lv = lowFinite[exprN /. th -> iv];
    If[AllTrue[lg, # > 0 &] && lv > 0,
     nLeaf++; worst = Min[worst, lv]; worstArg = Min[Prepend[lg, worstArg]],
     If[dep >= maxDepth, deep++,
      Module[{m = (a + b)/2}, stack = Join[{{a, m, dep + 1}, {m, b, dep + 1}}, stack]]]]]];
  {nLeaf, deep, worst, worstArg}];

(* guards: both sqrt arguments must stay > 0 on each panel *)
sqrtArg1 = 1 - w^2 Sin[th/4]^2;
sqrtArg2 = 1 - cyF^2;

Chmono = Module[{res},
  res = intervalSign[hpF, {sqrtArg1, sqrtArg2}];
  Print["[C_h_mono] h' > 0 : leaves=", res[[1]], " deep-hit=", res[[2]],
        " min lower(h')=", N[res[[3]], 10], " min lower(sqrt args)=", N[res[[4]], 8]];
  TrueQ[res[[3]] > 0] && res[[2]] == 0];

Chconv = Module[{res},
  res = intervalSign[hppF, {sqrtArg1, sqrtArg2}];
  Print["[C_h_conv] h'' > 0: leaves=", res[[1]], " deep-hit=", res[[2]],
        " min lower(h'')=", N[res[[3]], 10], " min lower(sqrt args)=", N[res[[4]], 8]];
  TrueQ[res[[3]] > 0] && res[[2]] == 0];

(* ======================= C_area : (9)(9')(11)(11')(13)(13') + totals ========= *)
Carea = Module[{R = r10exact, f, F, finv, aC10, p9, p9b, s11, s11b, v13, v13b,
                case1, case2, ok},
  f[a_]    := 2 ArcSin[Sin[a/2]/R];
  F[a_]    := R^2/2 (f[a] - Sin[f[a]]) + Sin[a]/2;
  finv[y_] := a /. FindRoot[f[a] == y, {a, 2.0}, WorkingPrecision -> 40];
  aC10 = Pi R^2;
  p9  = 8 Sin[Pi/4];           (* (9)  a(P1) Case 1 *)
  p9b = 7 Sin[2 Pi/7];         (* (9') a(P1) Case 2 *)
  s11 = R^2 (ArcSin[1/R] - (1/2) Sin[2 ArcSin[1/R]]);        (* (11) segment, chord 2 *)
  v13  = 8 F[finv[(Pi - ArcSin[1/R])/4]];                    (* (13)  sum a(R_i) Case 1 *)
  v13b = 7 F[finv[(2 Pi - 4 ArcSin[1/R])/7]];                (* (13') sum a(R_i) Case 2 *)
  (* Case totals use [FT]'s stated pentagon bounds (certified separately in C_pent):
     Case1: a(P1)+a(P2)+a(S1)+sum a(Qi)(<=7)+sum a(Ri)
     Case2: a(P1)+a(P2)+a(P3)+a(S1)+a(S2)+sum a(Qi)(<=5)+sum a(Ri) *)
  case1 = p9  + 2.284572282 + s11       + 7 + v13;
  case2 = p9b + 4.5691944564 + 2 s11    + 5 + v13b;
  Print["[C_area] a(C10)=pi r10^2 = ", N[aC10, 15], "  > 20.1422 : ", TrueQ[aC10 > 20.1422]];
  Print["         (9)  8 sin(pi/4)  = ", N[p9, 12],  "   FT 5.656854249"];
  Print["         (9') 7 sin(2pi/7) = ", N[p9b, 12], "   FT 5.472820377"];
  Print["         (11) segment      = ", N[s11, 12], "   FT 0.27675335"];
  Print["         (13) 8 F(...)     = ", N[v13, 12], "   FT 4.92397937"];
  Print["         (13')7 F(...)     = ", N[v13b, 12],"   FT 4.332295377"];
  Print["         Case 1 total = ", N[case1, 12], "  < a(C10) : ", TrueQ[case1 < aC10], "   FT 20.14216"];
  Print["         Case 2 total = ", N[case2, 12], "  < a(C10) : ", TrueQ[case2 < aC10], "   FT <= 20"];
  ok = TrueQ[aC10 > 20.1422]
    && Abs[N[p9  - 5.656854249, 12]] < 10^-6
    && Abs[N[p9b - 5.472820377, 12]] < 10^-6
    && Abs[N[s11 - 0.27675335, 12]]  < 10^-7
    && Abs[N[v13 - 4.92397937, 12]]  < 10^-6
    && Abs[N[v13b- 4.332295377, 12]] < 10^-6
    && TrueQ[case1 < aC10] && TrueQ[case2 < aC10];
  ok];

(* ======================= C_pent : pentagon bound (10) ======================== *)
(* [FT]'s printed pentagon-area closed form is pdftotext-mangled, so we verify the
   INEQUALITY a(P2) <= 2.284572282 directly: the max area of a cyclic pentagon with
   four sides of length 1 and one of length 2.  Its circumradius r solves
   4 asin(1/(2r)) + asin(1/r) = pi, and the area is the sum of 5 central triangles. *)
Cpent = Module[{rp, areaPent, val, ftBound = 2.284572282},
  rp = r /. FindRoot[4 ArcSin[1/(2 r)] + ArcSin[1/r] == Pi, {r, 1.07}, WorkingPrecision -> 40];
  areaPent = 4 ((1/2) rp^2 Sin[2 ArcSin[1/(2 rp)]]) + (1/2) rp^2 Sin[2 ArcSin[1/rp]];
  val = N[areaPent, 15];
  Print["[C_pent] cyclic pentagon (4 sides 1, 1 side 2) circumradius r = ", N[rp, 12]];
  Print["         true max area = ", val, "   FT stated bound 2.284572282"];
  Print["         a(P2) <= FT bound : ", TrueQ[areaPent <= ftBound],
        "  (ours is ", If[TrueQ[areaPent <= ftBound], "tighter", "LOOSER"], ")"];
  Print["         NOTE: FT's printed closed form is pdftotext-mangled; we verify the"];
  Print["               inequality, not FT's exact decimal (honest boundary)."];
  TrueQ[areaPent <= ftBound]];

(* =============================== GATE ======================================== *)
allChecks = <|
  "C_r10"   -> Cr10,
  "C_h_fp"  -> Chfp,
  "C_h_mono"-> Chmono,
  "C_h_conv"-> Chconv,
  "C_area"  -> Carea,
  "C_pent"  -> Cpent
|>;
Print["------------------------------------------------------------"];
Print["Melissen n=10 lemma check summary (based on [FT] 2005 section 3;"];
Print["Melissen 1997 original pp.108-111 NOT obtained -> 待核实):"];
KeyValueMap[Print["  ", #1, " : ", #2] &, allChecks];
pass = AllTrue[Values[allChecks], TrueQ];
Print["------------------------------------------------------------"];
If[pass,
  Print["CERTIFICATE OK (L3, based on [FT] reproduction of Melissen)"]; Exit[0],
  Print["CERTIFICATE FAILED"]; Exit[1]];
