#!/usr/bin/env wolframscript
(* 23a-n11-b9sharp-hand-constants.wls
   Rigorous re-check, ON THE R-INTERVALS THE STATEMENTS NAME, of every numerical hand assertion of
   experiments/2026-10-21-siege-n11-b9-sharp/out/proof.md that the sharp theorem (R <= Rstar) uses in
     - section 1, Notation, Step 0, Step 1, Step 5;
     - Appendix B section 1 (RED), section 2 ((D1)-(D6)), section 3 (UNI lemma by lemma), section 5;
     - the Step 5 transfer constants (Appendix C section 3.3, Appendix E section 0.4, F5 decimals).
   Analogue of 22a (which checked the F7 text at R = r_1 only).

   Method.
   - Rstar enclosure: taken from certificate 07 itself (Get with $N11CertificateNoExit = True; the
     Krawczyk box XK[[12]], 100-digit outward-rounded Interval).  Nothing about Rstar is typed in.
   - Every R-dependent claim is decided over its interval:  JJ = [r_0, r_1],  JS = [Rstar, r_1],
     J0 = (Rstar, Rstar + 10^-6]  (enclosed by [Rstarlo, Rstarhi + 10^-6]),  or a point (r_1, r_0, Rstar).
     R is a precision-50 bignum Interval; the interval is subdivided into n pieces (n stated per
     claim) and the hull of the piecewise enclosures is used.  NO machine-precision Interval.
   - Pi is replaced by a precision-50 Interval enclosing Pi before any evaluation.
   - Every decision converts interval endpoints to exact rationals (SetPrecision[., Infinity]) and
     compares them with exact rationals.  Identities: Together/FullSimplify.  Monotonicity: the
     symbolic R-derivative is enclosed on every subinterval and its sign decided, or Reduce.
   - Kinds:  VAL   printed decimal; true iff |x - v| <= one unit of the last printed digit (or the
                   document's own stated tolerance).
             INEQ  inequality / exact statement, decided as written.
             APPROX a margin written "about x" / "x": true iff the rigorous margin is
                   >= x - (half a unit of its last printed digit).
     Each claim carries LB = load-bearing (True/False).  Section V holds the corrected
     replacement statements.  Exit 0 iff every load-bearing claim is True or is False with a
     documented consequence AND a True replacement, and every False claim is documented. *)

$HistoryLength = 0;
t0clock = AbsoluteTime[];

(* ---------- Rstar from certificate 07 (must come first: 07 defines many Global-looking names) ---------- *)
$N11CertificateNoExit = True;
Begin["c07`"];
Get[FileNameJoin[{DirectoryName[$InputFileName], "07-n11-local-opt.wls"}]];
End[];
If[! (And @@ Values[c07`ok]), Print["FATAL: certificate 07 did not pass"]; Exit[2]];
RsLo = SetPrecision[Min[c07`XK[[12]]], Infinity];
RsHi = SetPrecision[Max[c07`XK[[12]]], Infinity];
Print["23a: R_* enclosure from certificate 07: R_* - Rbar in [", N[RsLo - 263169077261980820552/10^20, 12], ", ",
  N[RsHi - 263169077261980820552/10^20, 12], "], width ", N[RsHi - RsLo, 3]];

prec = 50; eps = 10^-45;

(* ---------- exact data ---------- *)
r1 = 26317/10000; r0 = 263169/100000;
Rbar = 263169077261980820552/10^20;
Rhi = 2631692/10^6;                     (* J = [Rbar, 2.631692]; also NB_RHI = 1315846/500000 *)
IstarLo = 26316907726198082055215011595056961051671168478238/10^49;
IstarHi = 26316907726198082055215011595056961051671168478239/10^49;
JJ = {r0, r1}; JS = {RsLo, r1}; J0 = {RsLo, RsHi + 10^-6};
If[1315846/500000 != Rhi, Print["FATAL: NB_RHI"]; Exit[2]];

(* ---------- bignum interval primitives (as in 22a) ---------- *)
box[x_, y_] := Interval[{SetPrecision[x - eps, prec], SetPrecision[y + eps, prec]}];  (* encloses [x,y], x,y exact *)
ivr[q_] := box[q, q];
PI = Interval[{SetPrecision[N[Pi, 70] - eps, prec], SetPrecision[N[Pi, 70] + eps, prec]}];
If[! (SetPrecision[Min[PI], Infinity] < Pi < SetPrecision[Max[PI], Infinity]), Print["FATAL: PI"]; Exit[2]];
toI[x_Interval] := x;
toI[x_Integer | x_Rational] := Interval[{x, x}];
toI[x_] := (Print["FATAL: non-interval value ", x]; Exit[2]);
lo[x_] := Module[{m = Min[toI[x]]}, If[NumericQ[m], SetPrecision[m, Infinity], -Infinity]];
hi[x_] := Module[{m = Max[toI[x]]}, If[NumericQ[m], SetPrecision[m, Infinity], Infinity]];
clampAC[x_] := IntervalIntersection[toI[x], Interval[{-1, 1}]];

(* ---------- symbolic objects in the variable R (and t, w, u where stated) ---------- *)
ClearAll[R, t, w, u, s, p];
aS = ArcSin[1/R]; dS = ArcSin[2/R];
BS = 12 aS - 2 Pi + 2 dS;
wS = Pi - 5 aS - dS;                                  (* = a - B/2 *)
rhoS[ww_] := R Cos[ww] - Sqrt[1 - R^2 Sin[ww]^2];      (* inner-branch centre radius, half-width ww *)
rhoLoS = rhoS[wS];
CS[tt_] := 2 aS - 2 ArcTan[Sqrt[4 - (R - tt)^2]/(R + tt)];
c4S = 2 aS - 2 ArcTan[Sqrt[4 - (2 R - 4)^2]/4];
G1S = rhoS[aS - 3/100]^2 + (R - 1)^2 - 2 (R - 1) rhoS[aS - 3/100] Cos[Pi - 5 aS];
G2S = (19656/10000)^2 + (R - 1)^2 - 2 (R - 1) (19656/10000) Cos[Pi - 5 aS + 3/100];
AS[tt_, uu_] := ArcCos[(tt^2 + uu^2 - 1)/(2 tt uu)];

(* evaluation of a symbolic expression with R (and optional other symbols) replaced by intervals *)
acI[x_Interval] := ArcCos[clampAC[x]];
acI[x_Integer | x_Rational] := ArcCos[clampAC[ivr[x]]];
ivX[x_] := Interval[{SetPrecision[N[x, 70] - eps, prec], SetPrecision[N[x, 70] + eps, prec]}];   (* exact real constant -> enclosure *)
ev[expr_, rules_List] := Module[{v = expr /. ArcCos -> acI /. Pi -> PI /. rules},
  Which[Head[v] === Interval, v, MatchQ[v, _Integer | _Rational], Interval[{v, v}],
    NumericQ[v] && Precision[v] === Infinity, ivX[v], True, (Print["FATAL: eval ", InputForm[v]]; Exit[2])]];
(* hull over R in [l, h], n pieces *)
rngR[expr_, {l_, h_}, n_: 32, extra_List: {}] := Module[{ps},
  ps = Table[ev[expr, Join[{R -> box[l + (h - l) i/n, l + (h - l) (i + 1)/n]}, extra]], {i, 0, n - 1}];
  {Min[lo /@ ps], Max[hi /@ ps]}];
(* hull over R in [l,h] x X in [xl, xh], nr x nx pieces *)
rng2[expr_, {l_, h_}, X_, {xl_, xh_}, nr_, nx_] := Module[{ps},
  ps = Flatten[Table[ev[expr, {R -> box[l + (h - l) i/nr, l + (h - l) (i + 1)/nr], X -> box[xl + (xh - xl) j/nx, xl + (xh - xl) (j + 1)/nx]}],
    {i, 0, nr - 1}, {j, 0, nx - 1}]];
  {Min[lo /@ ps], Max[hi /@ ps]}];
infR[e_, J_, n_: 32] := rngR[e, J, n][[1]];
supR[e_, J_, n_: 32] := rngR[e, J, n][[2]];
atP[e_, x_] := ev[e, {R -> ivr[x]}];                          (* enclosure at a point R = x (exact) *)
atRs[e_] := ev[e, {R -> box[RsLo, RsHi]}];                      (* enclosure at Rstar *)
(* monotonicity on J by derivative sign on n pieces: sgn = +1 increasing, -1 decreasing *)
monoQ[e_, J_, sgn_, n_: 32] := Module[{r = rngR[D[e, R], J, n]}, If[sgn > 0, r[[1]] > 0, r[[2]] < 0]];
reduceTrue[stmt_] := TrueQ[Reduce[stmt, Reals]];
dR[e_] := FullSimplify[D[e, R], R > 2];      (* simplified symbolic R-derivative (R > 2) *)

(* ---------- decimal strings ---------- *)
dec[str_String] := Module[{neg = StringStartsQ[str, "-"], s1, ip, fp, mant, ex = 0},
  s1 = If[neg, StringDrop[str, 1], str];
  If[StringContainsQ[s1, "e"], {s1, ex} = {StringSplit[s1, "e"][[1]], ToExpression[StringSplit[s1, "e"][[2]]]}];
  {ip, fp} = If[StringContainsQ[s1, "."], StringSplit[s1, "."], {s1, ""}];
  mant = FromDigits[ip] + If[fp == "", 0, FromDigits[fp]/10^StringLength[fp]];
  {(If[neg, -1, 1]) mant 10^ex, StringLength[fp] - ex}];
q[str_String] := dec[str][[1]];
ulp[str_String] := 10^-dec[str][[2]];

(* ---------- reporting ---------- *)
results = {};
nf[x_] := Module[{y, me}, If[! NumericQ[x], ToString[x], y = N[x, 20];
    If[y == 0, "0", me = MantissaExponent[y]; ToString[NumberForm[N[10 me[[1]], 20], 9]] <> "e" <> ToString[me[[2]] - 1]]]];
emit[id_, loc_, kind_, J_, txt_, vals_List, ok_, lb_] := Module[{b = TrueQ[ok]},
  AppendTo[results, {id, loc, kind, txt, b, lb, J}];
  Print[id, " | ", loc, " | ", kind, If[lb, " LB", " nlb"], " | ", J, " | ", txt, " | ", StringRiffle[vals, ", "], " | ", b]];
Jn[J_] := Which[J === JJ, "JJ=[r0,r1]", J === JS, "JS=[R*,r1]", J === J0, "J0=(R*,R*+1e-6]", True, ToString[J]];
(* inequality over an interval: expr >= c  (op "GE") or expr <= c ("LE"), strict variants "GT","LT" *)
ineqR[id_, loc_, txt_, e_, op_, c_, J_, n_: 32, lb_: True] := Module[{r = rngR[e, J, n], ok, mg},
  {ok, mg} = Switch[op, "GE", {r[[1]] >= c, r[[1]] - c}, "GT", {r[[1]] > c, r[[1]] - c},
    "LE", {r[[2]] <= c, c - r[[2]]}, "LT", {r[[2]] < c, c - r[[2]]}];
  emit[id, loc, "INEQ", Jn[J], txt, {"range=[" <> nf[r[[1]]] <> ", " <> nf[r[[2]]] <> "]", "margin=" <> nf[mg]}, ok, lb];
  mg];
ineqX[id_, loc_, txt_, ok_, vals_List: {"exact"}, lb_: True, J_: "-"] := emit[id, loc, "INEQ", J, txt, vals, ok, lb];
valP[id_, loc_, txt_, e_, x_, str_String, tol_: Automatic, lb_: False] := Module[{v = q[str], tl, I1},
  tl = If[tol === Automatic, ulp[str], tol]; I1 = If[x === "Rs", atRs[e], atP[e, x]];
  emit[id, loc, "VAL", If[x === "Rs", "R*", ToString[x, InputForm]], txt <> " = " <> str <> " (tol " <> nf[tl] <> ")",
    {"true=" <> nf[(lo[I1] + hi[I1])/2]}, lo[I1] >= v - tl && hi[I1] <= v + tl, lb]];
approx[id_, loc_, txt_, actualLo_, str_String, J_] := Module[{v = q[str]},
  emit[id, loc, "APPROX", J, txt <> " (stated " <> str <> ")", {"rigorous>=" <> nf[actualLo]}, actualLo >= v - ulp[str]/2, False]];

Print["23a: working precision ", prec, " (bignum Interval); JJ=[", r0, ",", r1, "], JS=[R*,r1], J0=(R*,R*+1e-6]"];

(* independent sanity check: N[exact, 80] lies inside the interval enclosures at R = r1 and R = r0 *)
Module[{chk = {{aS, ArcSin[1/R]}, {BS, BS}, {rhoLoS, rhoLoS}, {CS[1085/1000], CS[1085/1000]}, {c4S, c4S}, {G1S, G1S}}},
  ineqX["Z01", "enclosure sanity", "N[exact,80] of a, B, rho_lo, C(1.085), c4, G1 at r0 and r1 lie in the bignum enclosures; widths < 1e-40",
    And @@ Flatten[Table[With[{I1 = atP[c[[1]], x], ex = SetPrecision[N[c[[2]] /. R -> x, 80], Infinity]},
        lo[I1] <= ex <= hi[I1] && hi[I1] - lo[I1] < 10^-40], {c, chk}, {x, {r0, r1}}]], {"12 enclosures"}]];

(* ================= section 1: Notation and Step 0 ================= *)
ineqX["N1", "Notation l.49 / Step 5", "0 < R_* - Rbar <= 1.502e-21", RsLo - Rbar > 0 && RsHi - Rbar <= q["1.502e-21"],
  {"R*-Rbar in [" <> nf[RsLo - Rbar] <> ", " <> nf[RsHi - Rbar] <> "]"}];
ineqX["N2", "Notation l.49 (mid_cert A0 margin)", "R_* - Rbar >= 1.50116e-21 (as written)", RsLo - Rbar >= q["1.50116e-21"],
  {"R*-Rbar>=" <> nf[RsLo - Rbar]}, False];
ineqX["N3", "Notation (I_*)", "certificate-07 enclosure of R_* lies in I_* of the problem statement", RsLo >= IstarLo && RsHi <= IstarHi, {"exact"}, False];
ineqX["N4", "Notation l.50 / App.B 1 / App.B 4", "R_* + 1e-6 < 2.6316918 < R_hi = 2.631692 < r1", RsHi + 10^-6 < q["2.6316918"] < Rhi < r1];
ineqX["S0a", "Step 0 / App.B 1 step 2", "R_* > 2.61313 > 1/sin(pi/8)", RsLo > q["2.61313"] && hi[1/Sin[PI/8]] < q["2.61313"],
  {"1/sin(pi/8)<=" <> nf[hi[1/Sin[PI/8]]]}];
ineqR["S0b", "Step 0 / App.B 1 step 2 (F1)", "8a(R') < pi, i.e. pi - 8a > 0, on J0 (also > 0.02336 as F1 states at R_*)", Pi - 8 aS, "GT", q["0.02336"], J0, 8];
ineqR["S0c", "F1 (used via (SH)/F3)", "9a(R) - pi > 0.3664 on J0", 9 aS - Pi, "GT", q["0.3664"], J0, 8];
ineqX["S0d", "Step 0 / App.B 1 steps 3-4", "R' > 2 (F4(i)) and R' > R_* > r0 (F4(ii) excludes ten)", RsLo > 2 && RsLo > r0];
ineqX["S0e", "Step 0 last line", "R' in [2.63169, 2.631692] subset JJ, and R' in J = [Rbar, 2.631692]", r0 <= RsLo && RsHi + 10^-6 <= Rhi && Rhi <= r1 && Rbar <= RsLo];

(* ================= Appendix B section 1 (RED) ================= *)
ineqX["RED1", "App.B 1 step 7", "R^2 cos^2 w - (R^2-1) = 1 - (R sin w)^2; (m-s)(m+s) = R^2-1 for m=R cos w, s=sqrt(1-h^2); f(R-1)=2R(R-1)(1-cos w) (identities, symbolic R, w)",
  TrueQ[FullSimplify[R^2 Cos[w]^2 - (R^2 - 1) == 1 - (R Sin[w])^2]] &&
  TrueQ[FullSimplify[(R Cos[w])^2 - (1 - R^2 Sin[w]^2) == R^2 - 1]] &&
  TrueQ[Expand[((R - 1)^2 - 2 R (R - 1) Cos[w] + R^2 - 1) - 2 R (R - 1) (1 - Cos[w])] == 0], {"exact"}];
ineqX["RED2", "App.B 1 step 7 / R2(c)", "R - 1 < sqrt(R^2-1) and R - 1 > 0 for every R > 1 (Reduce)",
  reduceTrue[ForAll[R, R > 1, R - 1 < Sqrt[R^2 - 1] && R - 1 > 0]], {"Reduce"}];
ineqX["RED3", "App.B 1 step 5", "h = R sin w <= 1 for 0 <= w <= a(R): R sin a = 1 and sin increasing on [0, pi/2] (a < pi/2 for R > 1) (Reduce in s = sin w)",
  reduceTrue[ForAll[{R, s}, R > 1 && 0 <= s <= 1/R, R s <= 1]], {"Reduce"}];
ineqX["RED4", "App.B 1 remarks", "R_* + 1e-6 < 2.6316918 < r1", RsHi + 10^-6 < q["2.6316918"] < r1];

(* ================= Appendix B section 2 ================= *)
(* D1 *)
ineqX["D1a", "App.B (D1)", "a'(R) = -1/(R sqrt(R^2-1)), d'(R) = -2/(R sqrt(R^2-4)) (R > 2)",
  TrueQ[FullSimplify[D[aS, R] == -1/(R Sqrt[R^2 - 1]), R > 2]] && TrueQ[FullSimplify[D[dS, R] == -2/(R Sqrt[R^2 - 4]), R > 2]], {"exact"}];
ineqX["D1b", "App.B (D1)", "|a'| and |d'| decrease in R for R > 2 (Reduce on the derivatives of 1/(R sqrt(R^2-1)), 2/(R sqrt(R^2-4)))",
  reduceTrue[ForAll[R, R > 2, D[1/(R Sqrt[R^2 - 1]), R] < 0 && D[2/(R Sqrt[R^2 - 4]), R] < 0]], {"Reduce"}];
ineqX["D1c", "App.B (D1)", "r0^2 = 6.92579226 (exact 6.9257922561; tol 1e-8)", Abs[r0^2 - q["6.92579226"]] <= 10^-8, {"r0^2=" <> ToString[N[r0^2, 12]]}, False];
valP["D1d", "App.B (D1)", "sqrt(r0^2-1)", Sqrt[R^2 - 1], r0, "2.434295"];
valP["D1e", "App.B (D1)", "sqrt(r0^2-4)", Sqrt[R^2 - 4], r0, "1.710495"];
ineqR["D1f", "App.B (D1)", "|a'| <= 0.1561 on JJ", 1/(R Sqrt[R^2 - 1]), "LE", q["0.1561"], JJ, 4];
ineqR["D1g", "App.B (D1)", "|d'| <= 0.4443 on JJ", 2/(R Sqrt[R^2 - 4]), "LE", q["0.4443"], JJ, 4];
(* D2 *)
ineqX["D2a", "App.B (D2)", "B decreasing in R for R > 2 (B' = -12/(R sqrt(R^2-1)) - 4/(R sqrt(R^2-4)) by FullSimplify; < 0 by Reduce)",
  TrueQ[FullSimplify[D[BS, R] == -12/(R Sqrt[R^2 - 1]) - 4/(R Sqrt[R^2 - 4]), R > 2]] && reduceTrue[ForAll[R, R > 2, -12/(R Sqrt[R^2 - 1]) - 4/(R Sqrt[R^2 - 4]) < 0]], {"FullSimplify+Reduce"}];
ineqX["D2b", "App.B (D2)", "12*0.1561 + 2*0.4443 <= 2.762 (exact)", 12 q["0.1561"] + 2 q["0.4443"] <= q["2.762"], {"=" <> ToString[N[12 q["0.1561"] + 2 q["0.4443"]]]}];
ineqR["D2c", "App.B (D2)", "|B'| <= 2.762 on JJ (direct)", -D[BS, R], "LE", q["2.762"], JJ, 4];
valP["D2d", "App.B (D2)", "B(r1)", BS, r1, "0.1206621"];
ineqR["D2e", "App.B (D2) / Step 1", "B(R) <= 0.1206898 on JJ", BS, "LE", q["0.1206898"], JJ, 16];
ineqR["D2f", "App.B (D2) / Step 1 / 3 Lemma N2", "B(R) < 0.12069 on JJ", BS, "LT", q["0.12069"], JJ, 16];
ineqR["D2g", "App.B (D2) / 3 A4(1), E3.1, 3.1", "B/2 <= 0.0603449 on JJ", BS/2, "LE", q["0.0603449"], JJ, 16];
(* D3 *)
Module[{Nn = Sqrt[4 - (R - t)^2], zz = Sqrt[4 - (R - t)^2]/(R + t)},
  ineqX["D3a", "App.B (D3)", "dz/dR = -[(R^2-t^2)/N + N]/(R+t)^2, N = sqrt(4-(R-t)^2) (identity)",
    TrueQ[Together[D[zz, R] + ((R^2 - t^2)/Nn + Nn)/(R + t)^2] == 0], {"exact"}];
  ineqX["D3b", "App.B (D3)", "|R - t| <= r1 - 1 = 1.6317 for t in [1,R], R in JJ; N >= sqrt(4 - 1.6317^2) = 1.15653 (as written)",
    r1 - 1 == q["1.6317"] && lo[Sqrt[ivr[4 - q["1.6317"]^2]]] >= q["1.15653"], {"sqrt(4-1.6317^2)=" <> nf[lo[Sqrt[ivr[4 - q["1.6317"]^2]]]]}];
  ineqX["D3c", "App.B (D3)", "0 <= R^2 - t^2 <= r1^2 - 1 = 5.92584 (as written)", r1^2 - 1 <= q["5.92584"], {"r1^2-1=" <> ToString[N[r1^2 - 1, 12]]}];
  ineqX["D3d", "App.B (D3)", "(R+t)^2 >= (r0+1)^2 = 13.1892 (as written)", (r0 + 1)^2 >= q["13.1892"], {"(r0+1)^2=" <> ToString[N[(r0 + 1)^2, 12]]}];
  ineqX["D3e", "App.B (D3)", "(5.92584/1.15653 + 2)/13.1892 <= 0.5402 (exact arithmetic of the printed numbers)",
    (q["5.92584"]/q["1.15653"] + 2)/q["13.1892"] <= q["0.5402"], {"=" <> ToString[N[(q["5.92584"]/q["1.15653"] + 2)/q["13.1892"], 8]]}];
  With[{rr = rng2[Abs[D[zz, R]], JJ, t, {1, r1}, 2, 256]},
    ineqX["D3f", "App.B (D3)", "sup |dz/dR| <= 0.5402 over t in [1, r1], R in JJ (direct, 2 x 256 boxes)", rr[[2]] <= q["0.5402"], {"sup<=" <> nf[rr[[2]]]}]];
  ineqX["D3g", "App.B (D3)", "2*0.1561 + 2*0.5402 = 1.3926 <= 1.4 (printed 1.393)", 2 q["0.1561"] + 2 q["0.5402"] <= q["1.4"] && Abs[2 q["0.1561"] + 2 q["0.5402"] - q["1.393"]] <= 10^-3, {"=1.3926"}];
  With[{rr = rng2[Abs[D[CS[t], R]], JJ, t, {1, r1}, 2, 256]},
    ineqX["D3h", "App.B (D3) / Step 1", "sup |dC_R(t)/dR| <= 1.4 over t in [1, r1] (superset of [1,R]), R in JJ (direct)", rr[[2]] <= q["1.4"], {"sup<=" <> nf[rr[[2]]]}];
    ineqX["D3i", "App.B (D3) / Step 1 'C-table +-1.4e-5'", "|C_R(t) - C_r1(t)| <= 1.4e-5 for t in [1,R], R in JJ (mean value: |R - r1| <= 1e-5 times sup)", rr[[2]] 10^-5 <= q["1.4e-5"], {"bound=" <> nf[rr[[2]] 10^-5]}]]];
valP["D3j", "App.B (D3)", "r0 - 2/r0", R - 2/R, r0, "1.8717221"];
ineqR["D3k", "App.B (D3) / 3 Part D", "R - 2/R > 1.8717 on JJ (so [R-2, 1.8717] is inside the decreasing range)", R - 2/R, "GT", q["1.8717"], JJ, 4];
With[{h = (4 - (R - t)^2)/(R + t)^2},
  ineqX["D3l", "App.B (D3) / Part D (G)", "for every R > 2: h = z^2 has h' = 2(2R(R-t)-4)/(R+t)^3 > 0 on (R-2, R-2/R) and h >= 0 on [R-2, R-2/R], so C_R decreasing there (Reduce, symbolic R)",
    TrueQ[Together[D[h, t] - 2 (2 R (R - t) - 4)/(R + t)^3] == 0] &&
    reduceTrue[ForAll[{R, t}, R > 2 && R - 2 < t < R - 2/R, 2 (2 R (R - t) - 4)/(R + t)^3 > 0]] &&
    reduceTrue[ForAll[{R, t}, R > 2 && R - 2 <= t <= R - 2/R, h >= 0]], {"Reduce"}]];
(* D4 *)
Module[{rw = rhoS[w]},
  ineqX["D4a", "App.B (D4)", "d rho/dw = R sin w (R cos w / sqrt(1-R^2 sin^2 w) - 1); d rho/dR = cos w + R sin^2 w / sqrt(1-R^2 sin^2 w) (identities)",
    TrueQ[FullSimplify[D[rw, w] - R Sin[w] (R Cos[w]/Sqrt[1 - R^2 Sin[w]^2] - 1) == 0]] &&
    TrueQ[FullSimplify[D[rw, R] - (Cos[w] + R Sin[w]^2/Sqrt[1 - R^2 Sin[w]^2]) == 0]], {"exact"}];
  ineqX["D4b", "App.B (D4) / Part M 5 item 4", "for R > 1, 0 <= sin w <= 1/R, cos w = sqrt(1 - sin^2 w): R cos w >= sqrt(R^2-1) >= 1 >= sqrt(1-R^2 sin^2 w) when R^2 >= 2, hence d rho/dw >= 0; and d rho/dR > 0 (Reduce in s = sin w, c = sqrt(1-s^2))",
    reduceTrue[ForAll[{R, s}, R >= Sqrt[2] && 0 <= s <= 1/R, R Sqrt[1 - s^2] >= Sqrt[R^2 - 1] >= 1 >= Sqrt[1 - R^2 s^2]]] &&
    reduceTrue[ForAll[{R, s}, R > 1 && 0 <= s < 1/R, Sqrt[1 - s^2] + R s^2/Sqrt[1 - R^2 s^2] > 0]], {"Reduce"}]];
(* D5 *)
ineqX["D5a", "App.B (D5)", "a - B/2 = pi - 5a - d (identity)", TrueQ[Simplify[aS - BS/2 == wS]], {"exact"}];
ineqX["D5b", "App.B (D5)", "w(R) = pi - 5a - d increasing in R on JJ (derivative enclosure)", monoQ[wS, JJ, +1, 4], {"deriv>0"}];
ineqX["D5c", "App.B (D5) / Step 1", "rho_lo(R) = rho_R(w(R)) increasing in R on JJ (enclosure of d/dR rho_lo on 64 pieces)", monoQ[rhoLoS, JJ, +1, 64],
  {"min deriv=" <> nf[infR[D[rhoLoS, R], JJ, 64]]}];
ineqX["D5d", "App.B (D5)", "5*0.1561 + 0.4443 = 1.2248 (exact)", 5 q["0.1561"] + q["0.4443"] == q["1.2248"]];
ineqX["D5e", "App.B (D5)", "w(r0) >= w(r1) - 1.2248e-5", lo[atP[wS, r0] - atP[wS, r1]] >= -q["1.2248e-5"], {"w(r0)-w(r1)=" <> nf[lo[atP[wS, r0] - atP[wS, r1]]]}];
ineqX["D5e2", "App.B (D5)", "w(r0) >= w(r1) - 1.3e-5 (the rectangle contains every (w(R), R), R in JJ)", lo[atP[wS, r0] - atP[wS, r1]] >= -q["1.3e-5"]];
Module[{wl = lo[atP[wS, r1]] - q["1.3e-5"], wh = hi[atP[wS, r1]], rect},
  rect[e_] := rng2[e, JJ, w, {wl, wh}, 4, 4];
  ineqX["D5f", "App.B (D5) rectangle", "R sin w <= 0.851405 on [w(r1)-1.3e-5, w(r1)] x JJ", rect[R Sin[w]][[2]] <= q["0.851405"], {"sup<=" <> nf[rect[R Sin[w]][[2]]]}];
  ineqX["D5g", "App.B (D5) rectangle", "sqrt(1 - R^2 sin^2 w) >= 0.524508 on the rectangle", rect[Sqrt[1 - R^2 Sin[w]^2]][[1]] >= q["0.524508"], {"inf>=" <> nf[rect[Sqrt[1 - R^2 Sin[w]^2]][[1]]]}];
  ineqX["D5h", "App.B (D5) rectangle", "R cos w <= 2.49019 on the rectangle", rect[R Cos[w]][[2]] <= q["2.49019"], {"sup<=" <> nf[rect[R Cos[w]][[2]]]}];
  ineqX["D5i", "App.B (D5) rectangle", "sin w <= 0.3236 on the rectangle (used in d rho/dR)", rect[Sin[w]][[2]] <= q["0.3236"], {"sup<=" <> nf[rect[Sin[w]][[2]]]}];
  ineqX["D5j", "App.B (D5)", "0.851405*(2.49019/0.524508 - 1) <= 3.20 and 1 + 0.851405*0.3236/0.524508 <= 1.53 (exact)",
    q["0.851405"] (q["2.49019"]/q["0.524508"] - 1) <= q["3.20"] && 1 + q["0.851405"] q["0.3236"]/q["0.524508"] <= q["1.53"],
    {"=" <> ToString[N[q["0.851405"] (q["2.49019"]/q["0.524508"] - 1), 6]] <> ", " <> ToString[N[1 + q["0.851405"] q["0.3236"]/q["0.524508"], 6]]}];
  ineqX["D5k", "App.B (D5) rectangle (direct)", "d rho/dw <= 3.20 and d rho/dR <= 1.53 on the rectangle (direct enclosure)",
    rect[D[rhoS[w], w]][[2]] <= q["3.20"] && rect[D[rhoS[w], R]][[2]] <= q["1.53"], {"sup dw<=" <> nf[rect[D[rhoS[w], w]][[2]]], "sup dR<=" <> nf[rect[D[rhoS[w], R]][[2]]]}]];
ineqX["D5l", "App.B (D5)", "3.20*1.2248e-5 + 1.53e-5 <= 5.45e-5 (exact)", q["3.20"] q["1.2248e-5"] + q["1.53e-5"] <= q["5.45e-5"], {"=" <> nf[q["3.20"] q["1.2248e-5"] + q["1.53e-5"]]}];
ineqX["D5m", "App.B (D5)", "rho_lo(r1) - rho_lo(r0) <= 5.45e-5 (direct)", hi[atP[rhoLoS, r1]] - lo[atP[rhoLoS, r0]] <= q["5.45e-5"], {"diff<=" <> nf[hi[atP[rhoLoS, r1]] - lo[atP[rhoLoS, r0]]]}];
valP["D5n", "App.B (D5) (F7 component)", "R cos w at r1", R Cos[wS], r1, "2.4901714"];
valP["D5o", "App.B (D5) (F7 component)", "sqrt(1 - R^2 sin^2 w) at r1", Sqrt[1 - R^2 Sin[wS]^2], r1, "0.5245082"];
valP["D5p", "App.B (D5)", "rho_lo(r1)", rhoLoS, r1, "1.9656632"];
valP["D5q", "App.B (D5) (re-derived)", "d(r1)", dS, r1, "0.8632593"];
valP["D5r", "App.B (D5) (re-derived)", "w(r1)", wS, r1, "0.3294464"];
ineqX["D5s", "App.B (D5)", "|rho_lo(r1) - 1.9656632| <= 1.5e-6", lo[atP[rhoLoS, r1]] >= q["1.9656632"] - q["1.5e-6"] && hi[atP[rhoLoS, r1]] <= q["1.9656632"] + q["1.5e-6"],
  {"rho_lo(r1)=" <> nf[lo[atP[rhoLoS, r1]]]}];
ineqX["D5t", "App.B (D5)", "1.9656632 - 1.5e-6 - 5.45e-5 >= 1.965607 (exact)", q["1.9656632"] - q["1.5e-6"] - q["5.45e-5"] >= q["1.965607"]];
mgRho = ineqR["D5u", "App.B (D5) / Step 1", "rho_lo(R) >= 1.965607 on JJ (direct, 256 pieces)", rhoLoS, "GE", q["1.965607"], JJ, 256];
mgRhoJ = ineqR["D5v", "App.B (D5) / Step 1 / 3 E3.1, 1.4, 3.1", "rho_lo(R) > 1.9656 on JJ (direct, 256 pieces)", rhoLoS, "GT", q["1.9656"], JJ, 256];
mgRhoS = ineqR["D5w", "Step 1 / 3 (claimed range)", "rho_lo(R) > 1.9656 on JS = [R_*, r1] (direct, 256 pieces)", rhoLoS, "GT", q["1.9656"], JS, 256];
approx["D5x", "App.B (D5) / Step 1", "margin rho_lo - 1.9656 about 7e-6 on JJ", infR[rhoLoS, JJ, 256] - q["1.9656"], "7e-6", "JJ"];
approx["D5y", "App.B (D5) / Step 1", "margin rho_lo - 1.9656 about 1.1e-5 on [R_*, r1]", infR[rhoLoS, JS, 256] - q["1.9656"], "1.1e-5", "JS"];
ineqX["D5z", "App.B (D5)", "on [R_*, r1] the drop rho_lo(r1) - rho_lo(R) <= 5.0e-5 (direct)", hi[atP[rhoLoS, r1]] - lo[atRs[rhoLoS]] <= q["5.0e-5"],
  {"drop<=" <> nf[hi[atP[rhoLoS, r1]] - lo[atRs[rhoLoS]]]}, False];
ineqX["D5z2", "App.B (D5)", "the hand route gives the [R_*,r1] drop <= 5.0e-5: (r1 - R_*)(3.20*1.2248 + 1.53) <= 5.0e-5", (r1 - RsLo) (q["3.20"] q["1.2248"] + q["1.53"]) <= q["5.0e-5"],
  {"=" <> nf[(r1 - RsLo) (q["3.20"] q["1.2248"] + q["1.53"])]}, False];
valP["D5aa", "App.B (D5) (estimate)", "rho_lo(r0) 'estimate 1.96561'", rhoLoS, r0, "1.96561"];
valP["S1v1", "Step 1 (60-digit corroboration)", "rho_lo(r0)", rhoLoS, r0, "1.9656095"];
valP["S1v2", "Step 1 (60-digit corroboration)", "rho_lo(R_*)", rhoLoS, "Rs", "1.9656136"];
valP["S1v3", "Step 1 (60-digit corroboration)", "rho_lo(r1)", rhoLoS, r1, "1.9656633"];
approx["S1fb", "Step 1 / App.B (D5) fallback", "fallback rho_lo = 1.9655: margin about 1.1e-4 on JJ", infR[rhoLoS, JJ, 64] - q["1.9655"], "1.1e-4", "JJ"];
ineqR["S1fb2", "Step 1 / App.B (D5) fallback", "rho_lo(R) > 1.9655 on JJ", rhoLoS, "GT", q["1.9655"], JJ, 64, False];
(* D6 *)
ineqX["D6a", "App.B (D6)", "R - 2, 3 - R, 4 - R, R - 1 within 1e-5 of their r1 values on JJ (r1 - r0 = 1e-5)", r1 - r0 == 10^-5];
ineqX["D6b", "App.B (D6)", "sqrt(R^2-1) increasing (Reduce)", reduceTrue[ForAll[R, R > 1, D[Sqrt[R^2 - 1], R] > 0]], {"Reduce"}];
ineqR["D6c", "App.B (D6)", "sqrt(R^2-1) <= 2.4343058 on JJ", Sqrt[R^2 - 1], "LE", q["2.4343058"], JJ, 4];
ineqR["D6d", "App.B (D6) / 3 E2.2 (not used downstream)", "u* = sqrt(1-(R-2)^2) <= 0.77523 on JJ", Sqrt[1 - (R - 2)^2], "LE", q["0.77523"], JJ, 4, False];
ineqR["D6e", "App.B 3 E2.2 (not used downstream)", "reach 1 + u* <= 1.77523 on JJ", 1 + Sqrt[1 - (R - 2)^2], "LE", q["1.77523"], JJ, 4, False];
ineqX["D6f", "App.B (D6) (G)", "A(t,u), r(t) = arcsin(1/t), m0(t) = A(t, 1.9656) contain no R (structural)",
  FreeQ[AS[t, u], R] && FreeQ[ArcSin[1/t], R] && FreeQ[AS[t, 19656/10000], R]];

(* ================= Appendix B section 3 (UNI), lemma by lemma ================= *)
(* section 1 / Part A *)
ineqR["U01", "App.B 3 Lemma R3 (G)", "2pi - 4a > 0 on JJ", 2 Pi - 4 aS, "GT", 0, JJ, 4];
ineqX["U02", "App.B 3 Lemma A0 / 5 (Prop. P, Thm J(1))", "R > 2.61313 for R in [R_*, r1] (eight arcs never cover)", RsLo > q["2.61313"]];
ineqX["U03", "App.B 3 A4 / N1", "2pi - 10a - 2d increasing in R on JJ (derivative enclosure)", monoQ[-10 aS - 2 dS, JJ, +1, 4], {"deriv>0 on JJ"}];
valP["U04", "App.B 3 A4", "2pi - 10a - 2d at r1", 2 Pi - 10 aS - 2 dS, r1, "0.658893"];
ineqR["U05", "App.B 3 A4 / E3.1 / Step 1", "2pi - 10a - 2d = 2a - B >= 0.658868 on JJ", 2 Pi - 10 aS - 2 dS, "GE", q["0.658868"], JJ, 16];
ineqX["U05i", "App.B 3 E3.1", "2a - B = 2pi - 10a - 2d (identity)", TrueQ[Simplify[2 aS - BS == 2 Pi - 10 aS - 2 dS]]];
ineqX["U06", "App.B 3 A4(3) / N3", "2pi - 4d - 6a increasing in R on JJ (derivative enclosure)", monoQ[-4 dS - 6 aS, JJ, +1, 4], {"deriv>0 on JJ"}];
valP["U07", "App.B 3 A4(3)", "2pi - 4d - 6a at r1", 2 Pi - 4 dS - 6 aS, r1, "0.491483"];
ineqR["U08", "App.B 3 A4(3) / N3", "2pi - 4d - 6a >= 0.491456 on JJ", 2 Pi - 4 dS - 6 aS, "GE", q["0.491456"], JJ, 8];
ineqX["U09", "App.B 3 A5 / 5 K1 / Step 1", "R >= r0 on [R_*, r1] (F4(ii) threshold)", RsLo >= r0];
ineqX["U10", "App.B 3 A5 / 5 Prop. P", "|c_E| <= 1 < R - 1 on JJ (R > 2)", r0 > 2];
(* Part B section 1 *)
ineqR["U11", "App.B 3 N2", "2pi - 2a - 2d > 0 on JJ", 2 Pi - 2 aS - 2 dS, "GT", 0, JJ, 4];
valP["U12", "App.B 3 N2", "2pi - 2a - 2d at r1", 2 Pi - 2 aS - 2 dS, r1, "3.7771"];
ineqX["U13", "App.B 3 Lemma S (G)", "4(t^2-1) <= t^4 for all t (R-free; Reduce)", reduceTrue[ForAll[t, 4 (t^2 - 1) <= t^4]], {"Reduce"}];
(* Part D *)
ineqX["U14", "App.B 3 Lemma G (G)", "s > t > 0, s^2+t^2 > 2 => s^2+t^2-2 < 2s(s+t); log-derivative < 0 (R-free; Reduce)",
  reduceTrue[ForAll[{s, t}, t > 0 && s > t && s^2 + t^2 > 2, s^2 + t^2 - 2 < 2 s (s + t)]] &&
  reduceTrue[ForAll[{s, t}, t > 0 && s > t && s < t + 2 && s^2 + t^2 > 2, -(s - t)/(4 - (s - t)^2) + 1/(s + t) - 2 s/(s^2 + t^2 - 2) < 0]], {"Reduce"}];
ineqX["U15", "App.B 3 Part D identity (G)", "z(t*)^2 = 1/(R^2-1) at t* = R - 2/R, and arctan(1/sqrt(R^2-1)) = arcsin(1/R), symbolic R > 2",
  TrueQ[Together[((4 - (R - t)^2)/(R + t)^2 /. t -> R - 2/R) - 1/(R^2 - 1)] == 0] && TrueQ[FullSimplify[ArcTan[1/Sqrt[R^2 - 1]] == ArcSin[1/R], R > 2]], {"exact"}];
(* C-table on JJ: the derivative claim and the literal 'tabulated +- 1.4e-5' *)
Module[{tabs = {{"D", "1.0", "0.1630"}, {"D", "1.1", "0.1158"}, {"D", "1.2", "0.0806"}, {"D", "1.3", "0.0541"}, {"D", "1.4", "0.0344"},
     {"D", "1.5", "0.0201"}, {"D", "1.7", "0.0038"}, {"M2", "1.085", "0.122013"}, {"M2", "1.1", "0.1158"}, {"M2", "1.15", "0.096917"},
     {"M2", "1.2", "0.080557"}, {"M2", "1.25", "0.066373"}, {"M2", "1.3", "0.054103"}, {"M2", "1.35", "0.043497"}, {"M2", "1.45", "0.026631"},
     {"L4.2", "1.36", "0.0415625"}, {"L4.2", "1.3683", "0.0400011"}}, k = 0, bad = {}, worst = 0, badLit = {}},
  Do[With[{tt = q[e[[2]]], v = q[e[[3]]]},
     Module[{dlt = rngR[CS[tt] - (CS[tt] /. R -> r1), JJ, 8], lit = rngR[CS[tt], JJ, 8]},
       worst = Max[worst, Abs[dlt[[1]]], Abs[dlt[[2]]]];
       If[Max[Abs[dlt[[1]]], Abs[dlt[[2]]]] > q["1.4e-5"], AppendTo[bad, e]];
       If[! (lit[[1]] >= v - q["1.4e-5"] && lit[[2]] <= v + q["1.4e-5"]), AppendTo[badLit, e[[1]] <> ":" <> e[[2]]]]]], {e, tabs}];
  ineqX["U16", "App.B 3 Part D table / Step 1", "|C_R(t) - C_r1(t)| <= 1.4e-5 on JJ for all 17 tabulated t >= 1 (direct)", bad === {}, {"worst=" <> nf[worst]}];
  ineqX["U16L", "App.B 3 Part D 'each C value within 1.4e-5 of the tabulated one' (literal)", "tabulated - 1.4e-5 <= C_R(t) <= tabulated + 1.4e-5 on JJ for all 17 entries",
    badLit === {}, {"fail: " <> StringRiffle[badLit, " "]}, False]];
(* Part E *)
ineqX["U17", "App.B 3 E2.1 / E2.2 (G)", "rho_0 = R - 2, 1 - rho_0 = 3 - R; u > u* => rho_0^2 + u^2 - 1 > 0 (symbolic R in JJ; Reduce)",
  reduceTrue[ForAll[{R, u}, r0 <= R <= r1 && u > Sqrt[1 - (R - 2)^2], (R - 2)^2 + u^2 - 1 > 0]], {"Reduce"}];
ineqX["U18", "App.B 3 E3.1 (G)", "A(R, rho) increasing in rho on [R-1, sqrt(R^2-1)) for every R in JJ (Reduce, symbolic R)",
  reduceTrue[ForAll[{R, p}, r0 <= R <= r1 && R - 1 <= p < Sqrt[R^2 - 1], (p^2 - R^2 + 1)/(2 R p^2) < 0]], {"Reduce"}];
ineqX["U19", "App.B 3 E3.2", "sin(0.658868) >= 0.612222", lo[Sin[ivr[q["0.658868"]]]] >= q["0.612222"], {"sin=" <> nf[lo[Sin[ivr[q["0.658868"]]]]]}];
ineqX["U20", "App.B 3 E3.2", "1.9656 * 0.612222 >= 1.20339 (as written '= 1.20339' used as a lower bound)", q["1.9656"] q["0.612222"] >= q["1.20339"],
  {"=" <> ToString[N[q["1.9656"] q["0.612222"], 10]]}];
ineqR["U21", "App.B 3 E3.2 (direct)", "1.9656 sin(2a - B) > 1 on JJ (and 2a - B > 0)", 19656/10000 Sin[2 Pi - 10 aS - 2 dS], "GT", 1, JJ, 8];
ineqR["U22", "App.B 3 E3.2", "2a <= 0.77957 on JJ", 2 aS, "LE", q["0.77957"], JJ, 4];
ineqX["U23", "App.B 3 E3.2", "0.77957 < pi/2", q["0.77957"] < lo[PI/2]];
(* Part M section 1 *)
ineqX["U24", "App.B 3 Lemma 1.3", "0.122013 - 1.4e-5 = 0.121999 > 0.12069 (exact)", q["0.122013"] - q["1.4e-5"] == q["0.121999"] && q["0.121999"] > q["0.12069"]];
ineqR["U25", "App.B 3 Lemma 1.3 (direct)", "C_R(1.085) >= 0.121999 on JJ", CS[1085/1000], "GE", q["0.121999"], JJ, 8];
ineqR["U26", "App.B 3 Lemma 1.3 (direct)", "C_R(1.085) - B(R) > 0 on JJ", CS[1085/1000] - BS, "GT", 0, JJ, 8];
approx["U27", "App.B 3 Lemma 1.3", "margin C_R(1.085) - B about 1.3e-3 on JJ", infR[CS[1085/1000] - BS, JJ, 8], "1.3e-3", "JJ"];
ineqX["U28", "App.B 3 Lemma 1.3", "R - 2 <= 1.085 <= 1.8717 on JJ", r1 - 2 <= q["1.085"] <= q["1.8717"]];
ineqX["U29", "App.B 3 Lemma 1.4 (R-free)", "arcsin(1/1.9656) <= 0.53374", hi[ArcSin[1/ivr[q["1.9656"]]]] <= q["0.53374"], {"=" <> nf[hi[ArcSin[1/ivr[q["1.9656"]]]]]}];
valP["U30", "App.B 3 Lemma 1.4", "sqrt(1.9656^2 + 1)", Sqrt[(19656/10000)^2 + 1] + 0 R, r1, "2.2054"];
ineqR["U31", "App.B 3 Lemma 1.4 (threshold used as written)", "t <= 2.2054 => t^2 <= rho*^2 + 1: 2.2054^2 <= rho_lo(R)^2 + 1 on [R_*, r1]", rhoLoS^2 + 1 - q["2.2054"]^2, "GE", 0, JS, 64, False];
ineqR["U32", "App.B 3 Lemma 1.4", "2a(R) - 0.53374 >= 0.24581 on [R_*, r1] (a(R) >= a(r1))", 2 aS - q["0.53374"], "GE", q["0.24581"], JS, 4];
ineqX["U33", "App.B 3 Lemma 1.4 fallback", "arcsin(1/1.9655) <= 0.53378", hi[ArcSin[1/ivr[q["1.9655"]]]] <= q["0.53378"], {"=" <> nf[hi[ArcSin[1/ivr[q["1.9655"]]]]]}, False];
ineqR["U34", "App.B 3 Lemma 1.4 fallback", "2a(R) - 0.53378 >= 0.24577 on [R_*, r1]", 2 aS - q["0.53378"], "GE", q["0.24577"], JS, 4, False];
Module[{dA = Abs[D[AS[t, u], u]], rr, dd},
  rr = Max[Table[hi[ev[dA, {t -> box[1085/1000 + (135/100 - 1085/1000) i/512, 1085/1000 + (135/100 - 1085/1000) (i + 1)/512], u -> box[q["1.9655"], q["1.9656"]]}]], {i, 0, 511}]];
  dd = rr 10^-4;   (* mean value theorem in u over [1.9655, 1.9656] *)
  ineqX["U35", "App.B 3 Lemma 1.4 fallback", "|dA/du| <= 0.65 for t in [1.085, 1.35], u in [1.9655, 1.9656]; m0 increases by <= 7e-5", rr <= q["0.65"] && dd <= q["7e-5"],
    {"sup|dA/du|<=" <> nf[rr], "increase<=" <> nf[dd]}, False]];
(* Part M section 2 *)
ineqR["U36", "App.B 3 M2 bookkeeping", "2pi - 10a >= 2.385395 on JJ", 2 Pi - 10 aS, "GE", q["2.385395"], JJ, 4];
ineqX["U37", "App.B 3 M2 bookkeeping (R-free)", "2 r(1.085) <= 2.34467 < 2.385395", hi[2 ArcSin[1/ivr[q["1.085"]]]] <= q["2.34467"] && q["2.34467"] < q["2.385395"],
  {"2r(1.085)=" <> nf[hi[2 ArcSin[1/ivr[q["1.085"]]]]]}];
ineqX["U38", "App.B 3 Lemma 2.1", "10a - B - 1.06748 = 2pi - 2a - 2d - 1.06748 (identity); increasing in R on JJ",
  TrueQ[Simplify[10 aS - BS == 2 Pi - 2 aS - 2 dS]] && monoQ[-2 aS - 2 dS, JJ, +1, 4], {"exact + deriv>0 on JJ"}];
valP["U39", "App.B 3 Lemma 2.1", "10a - B - 1.06748 at r1", 10 aS - BS - q["1.06748"], r1, "2.70963"];
ineqR["U40", "App.B 3 Lemma 2.1 / 4.1(S)", "10a - B - 1.06748 >= 2.70962 on JJ", 10 aS - BS - q["1.06748"], "GE", q["2.70962"], JJ, 4];
ineqX["U41", "App.B 3 Lemma 2.1 / 4.1", "2.70962 > 2.34467 (exact)", q["2.70962"] > q["2.34467"]];
ineqX["U42", "App.B 3 Lemma 2.2", "8a - B = 2pi - 4a - 2d (identity); increasing in R on JJ",
  TrueQ[Simplify[8 aS - BS == 2 Pi - 4 aS - 2 dS]] && monoQ[-4 aS - 2 dS, JJ, +1, 4], {"exact + deriv>0 on JJ"}];
ineqX["U43", "App.B 3 Lemma 2.2", "1e-5 (4*0.1561 + 2*0.4443) <= 1.51e-5 (as written)", 10^-5 (4 q["0.1561"] + 2 q["0.4443"]) <= q["1.51e-5"],
  {"=" <> nf[10^-5 (4 q["0.1561"] + 2 q["0.4443"])]}];
ineqX["U44", "App.B 3 Lemma 2.2", "2.997557 - 1.51e-5 = 2.997542 (exact) ", q["2.997557"] - q["1.51e-5"] == q["2.997542"]];
ineqR["U45", "App.B 3 Lemma 2.2 (direct)", "8a - B >= 2.997542 on JJ", 8 aS - BS, "GE", q["2.997542"], JJ, 4];
ineqX["U46", "App.B 3 Lemma 2.2", "2.962253 < 2.997542, margin 0.0353 (2.962253 is R-free: built from r, m0 only; 22a M42v)",
  q["2.962253"] < q["2.997542"] && Abs[q["2.997542"] - q["2.962253"] - q["0.0353"]] <= 10^-4/2];
ineqX["U47", "App.B 3 Lemma 2.2", "0.124052 - 2.8e-5 = 0.124024 > 0.12069; margin 3.3e-3 (exact)", q["0.124052"] - q["2.8e-5"] == q["0.124024"] && q["0.124024"] > q["0.12069"] &&
  Abs[q["0.124024"] - q["0.12069"] - q["3.3e-3"]] <= 10^-4/2];
ineqR["U48", "App.B 3 Lemma 2.2 (direct)", "C_R(1.2) + C_R(1.35) >= 0.124024 on JJ", CS[12/10] + CS[135/100], "GE", q["0.124024"], JJ, 8];
ineqR["U48b", "App.B 3 Lemma 2.2 (direct)", "C_R(1.2) + C_R(1.35) - B(R) > 0 on JJ, and C_R(1.2) >= C_R(1.35)", CS[12/10] + CS[135/100] - BS, "GT", 0, JJ, 8];
ineqR["U48c", "App.B 3 Lemma 2.2 (direct)", "C_R(1.2) - C_R(1.35) >= 0 on JJ", CS[12/10] - CS[135/100], "GE", 0, JJ, 8];
(* Part M section 3 (Lemma 3.1) *)
ineqR["U49", "App.B 3 Lemma 3.1", "pi - 8a >= 0.0233610 on JJ", Pi - 8 aS, "GE", q["0.0233610"], JJ, 8, False];
ineqR["U49b", "App.B 3 Lemma 3.1 (a)", "pi - 8a > 0 on JJ", Pi - 8 aS, "GT", 0, JJ, 8];
ineqR["U50", "App.B 3 Lemma 3.1 (c)", "pi - 5a >= 1.1926976 on JJ (increasing in R)", Pi - 5 aS, "GE", q["1.1926976"], JJ, 8];
ineqX["U50m", "App.B 3 Lemma 3.1 (c)", "pi - 5a increasing in R on JJ (derivative enclosure)", monoQ[-5 aS, JJ, +1, 4], {"deriv>0 on JJ"}];
ineqR["U51", "App.B 3 Lemma 3.1 (c) / Repair M2", "4a <= 1.55912 on JJ", 4 aS, "LE", q["1.55912"], JJ, 4];
ineqX["U52", "App.B 3 Lemma 3.1", "1.55912 < pi/2; R - 1 >= 1.63169 on JJ (exact)", q["1.55912"] < lo[PI/2] && r0 - 1 >= q["1.63169"]];
valP["U53", "App.B 3 Lemma 3.1 (re-derived)", "R cos(a - 0.03) at r1", R Cos[aS - 3/100], r1, "2.463206"];
valP["U54", "App.B 3 Lemma 3.1 (re-derived)", "sqrt(1 - R^2 sin^2(a - 0.03)) at r1", Sqrt[1 - R^2 Sin[aS - 3/100]^2], r1, "0.376216"];
ineqX["U55", "App.B 3 Lemma 3.1", "2.463206 - 0.376216 = 2.086990 (exact)", q["2.463206"] - q["0.376216"] == q["2.086990"]];
valP["U56", "App.B 3 Lemma 3.1 (F7, corrected 22a M56v)", "rho_r1(a - 0.03)", rhoS[aS - 3/100], r1, "2.0869896"];
Module[{rw = rhoS[w]},
  With[{dw = rng2[Abs[D[rw, w]], JJ, w, {lo[atP[aS, r1]] - 3/100, hi[atP[aS, r0]] - 3/100}, 4, 16],
        dR = rng2[Abs[D[rw, R]], JJ, w, {lo[atP[aS, r1]] - 3/100, hi[atP[aS, r0]] - 3/100}, 4, 16]},
    ineqX["U57", "App.B 3 Lemma 3.1", "|d_w rho| <= 5.15 and |d_R rho| <= 1.81 at w = a(R) - 0.03, R in JJ (direct box)", dw[[2]] <= q["5.15"] && dR[[2]] <= q["1.81"],
      {"sup|dw|<=" <> nf[dw[[2]]], "sup|dR|<=" <> nf[dR[[2]]]}]]];
ineqX["U58", "App.B 3 Lemma 3.1", "5.15*0.1561 + 1.81 <= 2.7 (exact)", q["5.15"] q["0.1561"] + q["1.81"] <= q["2.7"]];
ineqR["U58b", "App.B 3 Lemma 3.1 (direct)", "|d/dR rho_R(a(R) - 0.03)| <= 2.7 on JJ", Abs[D[rhoS[aS - 3/100], R]], "LE", q["2.7"], JJ, 8];
ineqX["U59", "App.B 3 Lemma 3.1", "2.0869896 - 2.7e-5 >= 2.086962 (exact)", q["2.0869896"] - q["2.7e-5"] >= q["2.086962"]];
ineqR["U60", "App.B 3 Lemma 3.1 (direct)", "rho_R(a - 0.03) >= 2.086962 on JJ", rhoS[aS - 3/100], "GE", q["2.086962"], JJ, 16];
ineqX["U61", "App.B 3 Lemma 3.1 (d)", "cos(1.1926976) <= 0.36916, 2.4344*0.36916 < 0.9 < 1.63169, 0.9 < 1.9656", hi[Cos[ivr[q["1.1926976"]]]] <= q["0.36916"] &&
  q["2.4344"] q["0.36916"] < q["0.9"] < q["1.63169"] && q["0.9"] < q["1.9656"], {"cos=" <> nf[hi[Cos[ivr[q["1.1926976"]]]]]}];
ineqR["U62", "App.B 3 Lemma 3.1 (d)", "rho_t, rho' <= sqrt(R^2-1) <= 2.4344 on JJ", Sqrt[R^2 - 1], "LE", q["2.4344"], JJ, 4];
ineqX["U63", "App.B 3 Lemma 3.1 (d)", "cos(1.1926976) - cos(pi - 5a(r1)) <= 7.9e-6 and cos(1.2226976) - cos(pi - 5a(r1) + 0.03) <= 7.9e-6",
  hi[Cos[ivr[q["1.1926976"]]] - atP[Cos[Pi - 5 aS], r1]] <= q["7.9e-6"] && hi[Cos[ivr[q["1.2226976"]]] - atP[Cos[Pi - 5 aS + 3/100], r1]] <= q["7.9e-6"],
  {"d1=" <> nf[hi[Cos[ivr[q["1.1926976"]]] - atP[Cos[Pi - 5 aS], r1]]], "d2=" <> nf[hi[Cos[ivr[q["1.2226976"]]] - atP[Cos[Pi - 5 aS + 3/100], r1]]]}];
ineqX["U64", "App.B 3 Lemma 3.1 (d)", "cos(1.1926976) <= 0.369155 and cos(1.2226976) <= 0.341112 (cos decreasing on [0, pi/2])",
  hi[Cos[ivr[q["1.1926976"]]]] <= q["0.369155"] && hi[Cos[ivr[q["1.2226976"]]]] <= q["0.341112"]];
ineqR["U64b", "App.B 3 Lemma 3.1 (d) (direct)", "cos(pi - 5a(R)) <= 0.369155 on JJ", Cos[Pi - 5 aS], "LE", q["0.369155"], JJ, 8];
ineqR["U64c", "App.B 3 Lemma 3.1 (d) (direct)", "cos(pi - 5a(R) + 0.03) <= 0.341112 on JJ", Cos[Pi - 5 aS + 3/100], "LE", q["0.341112"], JJ, 8];
ineqX["U65", "App.B 3 Lemma 3.1 case 1", "2.086962^2 >= 4.355402, 1.63169^2 >= 2.662412, 2*1.63169*2.086962*0.369155 <= 2.514152 (directions used)",
  q["2.086962"]^2 >= q["4.355402"] && q["1.63169"]^2 >= q["2.662412"] && 2 q["1.63169"] q["2.086962"] q["0.369155"] <= q["2.514152"],
  {"2.086962^2=" <> ToString[N[q["2.086962"]^2, 10]], "prod=" <> ToString[N[2 q["1.63169"] q["2.086962"] q["0.369155"], 10]]}];
ineqX["U65v", "App.B 3 Lemma 3.1 case 1 (VAL)", "the printed values 4.355402, 2.662412, 2.514152 are within 1e-6 of the exact products",
  Abs[q["2.086962"]^2 - q["4.355402"]] <= 10^-6 && Abs[q["1.63169"]^2 - q["2.662412"]] <= 10^-6 && Abs[2 q["1.63169"] q["2.086962"] q["0.369155"] - q["2.514152"]] <= 10^-6,
  {"2.086962^2-4.355402=" <> nf[q["2.086962"]^2 - q["4.355402"]]}, False];
ineqX["U66", "App.B 3 Lemma 3.1 case 1", "4.355402 + 2.662412 - 2.514152 = 4.5037 (4 decimals) > 4; and the exact hand chain 2.086962^2 + 1.63169^2 - 2*1.63169*2.086962*0.369155 > 4",
  Abs[q["4.355402"] + q["2.662412"] - q["2.514152"] - q["4.5037"]] <= 10^-4/2 && q["2.086962"]^2 + q["1.63169"]^2 - 2 q["1.63169"] q["2.086962"] q["0.369155"] > 4];
mgG1 = ineqR["U67", "App.B 3 Lemma 3.1 case 1 (direct)", "G1(R) = rho_R(a-0.03)^2 + (R-1)^2 - 2(R-1) rho_R(a-0.03) cos(pi-5a) > 4 on JJ", G1S, "GT", 4, JJ, 16];
ineqX["U68", "App.B 3 Lemma 3.1 case 2", "1.9656^2 >= 3.863583; 2*1.63169*1.9656*0.341112 <= 2.188063; 3.863583 + 2.662412 - 2.188063 = 4.3379 > 4; exact hand chain > 4",
  q["1.9656"]^2 >= q["3.863583"] && 2 q["1.63169"] q["1.9656"] q["0.341112"] <= q["2.188063"] &&
  Abs[q["3.863583"] + q["2.662412"] - q["2.188063"] - q["4.3379"]] <= 10^-4/2 && q["1.9656"]^2 + q["1.63169"]^2 - 2 q["1.63169"] q["1.9656"] q["0.341112"] > 4,
  {"prod=" <> ToString[N[2 q["1.63169"] q["1.9656"] q["0.341112"], 10]]}];
mgG2 = ineqR["U69", "App.B 3 Lemma 3.1 case 2 (direct)", "G2(R) = 1.9656^2 + (R-1)^2 - 2(R-1) 1.9656 cos(pi-5a+0.03) > 4 on JJ", G2S, "GT", 4, JJ, 16];
ineqX["U70", "App.B 3 Lemma 3.1 (d) monotone-in-rho_t/rho' conditions", "rho_t cos Theta <= 2.4344*0.369155 < 1.63169 <= rho' and rho' cos Theta <= 2.4344*0.369155 < 1.9656 <= rho_t (exact)",
  q["2.4344"] q["0.369155"] < q["1.63169"] && q["2.4344"] q["0.369155"] < q["1.9656"]];
(* Part M section 4 *)
ineqX["U71", "App.B 3 Lemma 4.2", "c4(R) := C_R(4-R) = 2a - 2 arctan(sqrt(4-(2R-4)^2)/4) (identity)", TrueQ[Simplify[(CS[t] /. t -> 4 - R) == c4S]]];
ineqR["U72", "App.B 3 Lemma 4.2", "(2R-4)/sqrt(4-(2R-4)^2) <= 0.815 on JJ (the arctan part of |c4'|)", (2 R - 4)/Sqrt[4 - (2 R - 4)^2], "LE", q["0.815"], JJ, 4];
ineqX["U73", "App.B 3 Lemma 4.2", "2*0.1561 = 0.3122; 0.3122 + 0.815 <= 1.13 (exact)", 2 q["0.1561"] == q["0.3122"] && q["0.3122"] + q["0.815"] <= q["1.13"]];
ineqR["U74", "App.B 3 Lemma 4.2 (direct)", "|c4'(R)| <= 1.13 on JJ", Abs[D[c4S, R]], "LE", q["1.13"], JJ, 8];
valP["U75", "App.B 3 Lemma 4.2 (F7 corrected value)", "c4(r1) = C(1.3683)", c4S, r1, "0.0400011"];
ineqX["U76", "App.B 3 Lemma 4.2", "0.0400011 - 1.13e-5 >= 0.039989 (exact)", q["0.0400011"] - q["1.13e-5"] >= q["0.039989"]];
mgC4 = ineqR["U77", "App.B 3 Lemma 4.2 / Step 1 (direct)", "c4(R) >= 0.039989 on JJ", c4S, "GE", q["0.039989"], JJ, 16];
ineqX["U78", "App.B 3 Lemma 4.2", "0.12069 - 2*0.039989 = 0.040712 (exact)", q["0.12069"] - 2 q["0.039989"] == q["0.040712"]];
ineqR["U79", "App.B 3 Lemma 4.2 (direct)", "B(R) - 2 c4(R) <= 0.040712 on JJ", BS - 2 c4S, "LE", q["0.040712"], JJ, 16];
ineqX["U80", "App.B 3 Lemma 4.2", "0.0415625 - 1.4e-5 = 0.0415485 > 0.040712; margin 8.4e-4 (exact)", q["0.0415625"] - q["1.4e-5"] == q["0.0415485"] &&
  q["0.0415485"] > q["0.040712"] && Abs[q["0.0415485"] - q["0.040712"] - q["8.4e-4"]] <= 10^-5/2];
ineqR["U81", "App.B 3 Lemma 4.2 (direct)", "C_R(1.36) >= 0.0415485 on JJ", CS[136/100], "GE", q["0.0415485"], JJ, 8];
mgL42 = ineqR["U82", "App.B 3 Lemma 4.2 (direct, rigorous form)", "C_R(1.36) - (B(R) - 2 c4(R)) > 0 on JJ", CS[136/100] - BS + 2 c4S, "GT", 0, JJ, 16];
approx["U82a", "App.B 3 Lemma 4.2", "margin 8.9e-4 at r1", lo[atP[CS[136/100] - BS + 2 c4S, r1]], "8.9e-4", "r1"];
approx["U82b", "App.B 3 Lemma 4.2 / Step 1 / caveat 2", "margin about 8.4e-4 on JJ (rigorous form)", infR[CS[136/100] - BS + 2 c4S, JJ, 16], "8.4e-4", "JJ"];
ineqX["U83", "App.B 3 Lemma 4.2", "4 - R <= 1.36831 on JJ, and 4 - R <= R - 2/R (inside the decreasing range of C)", 4 - r0 <= q["1.36831"] && 4 - r0 <= lo[atP[R - 2/R, r0]]];
ineqX["U84", "App.B 3 Lemma 4.2", "1.36^2 + 0.36831^2 - 1 = 0.985252, 2*1.36*0.36831 = 1.001803 (6 decimals; 3 - r0 = 0.36831)",
  3 - r0 == q["0.36831"] && Abs[q["1.36"]^2 + q["0.36831"]^2 - 1 - q["0.985252"]] <= 10^-6 && Abs[2 q["1.36"] q["0.36831"] - q["1.001803"]] <= 10^-6, {"exact"}, False];
ineqX["U85", "App.B 3 Lemma 4.2", "A(1.36, 3 - r0) < 0.183; A increasing in u for u <= sqrt(1.36^2-1) and 3 - R <= 3 - r0 on JJ; 1.36 - 0.36831 <= 1",
  hi[ArcCos[clampAC[(ivr[q["1.36"]]^2 + ivr[3 - r0]^2 - 1)/(2 ivr[q["1.36"]] ivr[3 - r0])]]] < q["0.183"] && (3 - r0)^2 <= q["1.36"]^2 - 1 && q["1.36"] - (3 - r0) <= 1,
  {"A=" <> nf[hi[ArcCos[clampAC[(ivr[q["1.36"]]^2 + ivr[3 - r0]^2 - 1)/(2 ivr[q["1.36"]] ivr[3 - r0])]]]]}];
ineqX["U86", "App.B 3 Lemma 4.2", "6a - B - 1.06748 = 2pi - 6a - 2d - 1.06748 (identity)", TrueQ[Simplify[6 aS - BS == 2 Pi - 6 aS - 2 dS]]];
ineqR["U87", "App.B 3 Lemma 4.2 (direct)", "6a - B - 1.06748 >= 1.15048 on JJ", 6 aS - BS - q["1.06748"], "GE", q["1.15048"], JJ, 4];
ineqX["U88", "App.B 3 Lemma 4.2", "2*0.183 < 1.15048", 2 q["0.183"] < q["1.15048"]];
ineqR["U89", "App.B 3 Repair M2", "6a <= 2.33870 on JJ", 6 aS, "LE", q["2.33870"], JJ, 4];
ineqX["U90", "App.B 3 Repair M2 (R-free part)", "r(1.085) < 1.1724; 2.3387 + 1.1724 = 3.5111 < 2pi - 1.1724; -2pi + 1.1724 < -1.1724; -1.5592 - 1.1724 >= -2.732; 2pi - 1.1724 > 1.1724; -2pi + 1.1724 < -2.732",
  hi[ArcSin[1/ivr[q["1.085"]]]] < q["1.1724"] && q["2.3387"] + q["1.1724"] == q["3.5111"] && q["3.5111"] < lo[2 PI] - q["1.1724"] &&
  q["1.1724"] - lo[2 PI] < -q["1.1724"] && -q["1.5592"] - q["1.1724"] >= -q["2.732"] && hi[2 PI] - q["1.1724"] > q["1.1724"] && q["1.1724"] - lo[2 PI] < -q["2.732"]];
ineqX["U91", "App.B 3 Lemma 4.1(S)", "D >= 2.70962 - 2.34467 > 0 (exact)", q["2.70962"] - q["2.34467"] > 0];
ineqX["U92", "App.B 3 Part M 5 soundness (G, symbolic R)", "4 - (R-t)^2 > 0 for 1 <= t <= R, R in JJ; 1 - R^2 sin^2 w >= 0 for 0 <= sin w <= 1/R (Reduce)",
  reduceTrue[ForAll[{R, t}, r0 <= R <= r1 && 1 <= t <= R, 4 - (R - t)^2 > 0]] && reduceTrue[ForAll[{R, s}, r0 <= R <= r1 && 0 <= s <= 1/R, 1 - R^2 s^2 >= 0]], {"Reduce"}];
(* fallback rho_lo = 1.9655: every dependent margin >= 0.03 *)
Module[{rr = 19655/10000, h1, h2, h3, hb, m2, mE, m21, m31, m42},
  h1 = Max[Table[hi[ev[ArcSin[1/t] + AS[t, rr], {t -> box[1085/1000 + (12/10 - 1085/1000) i/128, 1085/1000 + (12/10 - 1085/1000) (i + 1)/128]}]], {i, 0, 127}]];
  h2 = Max[Table[hi[ev[ArcSin[1/t] + AS[t, rr], {t -> box[12/10 + (135/100 - 12/10) i/128, 12/10 + (135/100 - 12/10) (i + 1)/128]}]], {i, 0, 127}]];
  h3 = hi[ArcSin[1/ivr[135/100]]] + hi[ArcSin[1/ivr[rr]]];
  m2 = infR[8 aS - BS, JJ, 4] - Max[h1 + h3, 2 h2];
  mE = infR[rr Sin[2 Pi - 10 aS - 2 dS], JJ, 4] - 1;
  m21 = infR[10 aS - BS, JJ, 4] - 2 hi[ArcSin[1/ivr[rr]]] - hi[2 ArcSin[1/ivr[1085/1000]]];
  m31 = infR[rr^2 + (R - 1)^2 - 2 (R - 1) rr Cos[Pi - 5 aS + 3/100], JJ, 8] - 4;
  m42 = infR[6 aS - BS, JJ, 4] - 2 hi[ArcSin[1/ivr[rr]]] - 2 q["0.183"];
  ineqX["U93", "App.B (D5)/3 Lemma 1.4 fallback", "with rho_lo = 1.9655 all margins using rho_lo are >= 0.03 (E3.2, L2.1, L2.2 (true sup of r + A(.,1.9655)), L3.1 case 2, L4.2)",
    Min[m2, mE, m21, m31, m42] >= 3/100, {"L2.2=" <> nf[m2], "E3.2=" <> nf[mE], "L2.1=" <> nf[m21], "L3.1=" <> nf[m31], "L4.2=" <> nf[m42]}, False]];

(* ================= Appendix B section 5 ================= *)
ineqX["P5a", "App.B 5 (K1 via A5/F4(ii); Prop. P, Thm J(1) via A0/F3)", "for R in [R_*, r1]: R >= r0, R > 2.61313, R > 2", RsLo >= r0 && RsLo > q["2.61313"] && RsLo > 2];

(* ================= Step 5 transfer constants (App. C 3.3, App. E 0.4, F5) ================= *)
Module[{F5, ybar3, d1 = 3/1000, bmax, t1, t2, t3, tot, maxY, maxX, maxN, bnd},
  F5 = {{0, q["-0.39324960179250027086"]}, {0, q["0.71839227931685877597"]}, {0, q["2.34884120097565953729"]},
    {q["1.57535264004342806580"], q["1.62062588642691912838"]}, {-q["1.57535264004342806580"], q["1.62062588642691912838"]},
    {q["1.77273616280974093118"], q["-0.93632239910290244643"]}, {-q["1.77273616280974093118"], q["-0.93632239910290244643"]},
    {q["1.82750955295212993964"], q["0.24958048504283922431"]}, {-q["1.82750955295212993964"], q["0.24958048504283922431"]},
    {q["0.78521708246826346764"], q["-2.01247018720615423819"]}, {-q["0.78521708246826346764"], q["-2.01247018720615423819"]}};
  ybar3 = F5[[3, 2]];
  bmax = d1/(ybar3 - d1);
  t1 = (1 + bmax) d1; t2 = q["2.0125"] bmax; t3 = q["1.18"] bmax^2; tot = t1 + t2 + t3;
  maxY = Max[Abs[F5[[Complement[Range[11], {3}], 2]]]]; maxX = Max[Abs[F5[[All, 1]]]];
  bnd[dd_] := Module[{b = dd/(ybar3 - dd)}, (1 + b) dd + q["2.0125"] b + q["1.18"] b^2];
  ineqX["T01", "Step 5 / App.C 3.3", "ybar_3 = 2.34884120... (F5) and ybar_3 - delta1 > 0; x(c3bar) = 0", F5[[3, 1]] == 0 && Floor[ybar3 10^8] == 234884120 && ybar3 - d1 > 0];
  ineqX["T02", "Step 5", "beta_max = delta1/(ybar_3 - delta1) = 1.27886e-3 (5 digits; exact rational)", Abs[bmax - q["1.27886e-3"]] <= q["1e-8"], {"=" <> nf[bmax]}, False];
  ineqX["T03", "Step 5", "(1+beta)delta1 = 3.00384e-3, 2.0125 beta = 2.57370e-3, 1.18 beta^2 = 0.00193e-3 (printed digits)",
    Abs[t1 - q["3.00384e-3"]] <= q["1e-8"] && Abs[t2 - q["2.57370e-3"]] <= q["1e-8"] && Abs[t3 - q["0.00193e-3"]] <= q["1e-8"], {nf[t1], nf[t2], nf[t3]}, False];
  ineqX["T04", "Step 5 / App.C 3.3 / App.E 0.4", "(1+beta)delta1 + 2.0125 beta + 1.18 beta^2 = 5.57947e-3 (printed) and < 7e-3 (exact)",
    Abs[tot - q["5.57947e-3"]] <= q["1e-8"] && tot < 7/1000, {"=" <> nf[tot]}];
  ineqX["T05", "Step 5 / App.C 3.3", "max_{v!=3} |ybar_v| = 2.01247018... (disks 10, 11) <= 2.0125", maxY <= q["2.0125"] && Floor[maxY 10^8] == 201247018 &&
    Abs[F5[[10, 2]]] == maxY, {"=" <> ToString[N[maxY, 12]]}];
  ineqX["T06", "Step 5 / App.C 3.3", "max_v |xbar_v| = 1.82750955... <= 1.8276", maxX <= q["1.8276"] && Floor[maxX 10^8] == 182750955, {"=" <> ToString[N[maxX, 12]]}];
  ineqX["T07", "App.C 3.3", "every |cbar_v| <= 2.3489", And @@ (#.# <= q["2.3489"]^2 & /@ F5), {"max |c|^2=" <> ToString[N[Max[#.# & /@ F5], 10]]}, False];
  ineqX["T08", "App.C 3.3", "1.18 >= max(max|xbar|, max_{v!=3}|ybar|)/2 = 1.00624 (printed); 2.0125 >= 1.8276 (so both coordinates share the bound)",
    q["1.18"] >= Max[maxX, maxY]/2 && Abs[Max[maxX, maxY]/2 - q["1.00624"]] <= 10^-5 && q["2.0125"] >= q["1.8276"]];
  (* the elementary inequalities on |beta| <= beta_max (rigorous on that range by bignum-Interval subdivision) *)
  ineqX["T09", "App.C 3.3", "|sin b| <= |b|, 1 - cos b <= b^2/2, |cos b| + |sin b| <= 1 + |b| (|b| <= 1/2), sqrt(d^2+(y+d)^2) <= y + d + d^2/(2y), d^2/(2y) <= d^2 for y > 1/2 (Reduce)",
    reduceTrue[ForAll[b, b >= 0, Sin[b] <= b]] && reduceTrue[ForAll[b, b >= 0, -Sin[b] <= b]] && reduceTrue[ForAll[b, 1 - Cos[b] <= b^2/2]] &&
    reduceTrue[ForAll[b, -1/2 <= b <= 1/2, Abs[Cos[b]] + Abs[Sin[b]] <= 1 + Abs[b]]] && bmax < 1/2 &&
    reduceTrue[ForAll[{y, dd}, y > 1/2 && dd > 0, Sqrt[dd^2 + (y + dd)^2] <= y + dd + dd^2/(2 y) && dd^2/(2 y) <= dd^2]], {"Reduce"}];
  ineqX["T09b", "App.C 3.3", "|beta| <= |x(u3)|/y(u3) < delta/(ybar3 - delta) (|arctan s| <= |s|; y(u3) > ybar3 - delta > 0)",
    reduceTrue[ForAll[s, s >= 0, ArcTan[s] <= s]] && ybar3 - d1 > 0, {"Reduce"}];
  ineqX["T10", "App.C 3.3 (v = 3)", "delta1 + delta1^2 <= 5.57947e-3 (v = 3 bound is smaller)", d1 + d1^2 <= tot];
  ineqX["T11", "Step 5 / App.C 3.3", "0 < R' - Rbar <= 1e-6 + 1.502e-21 < 7e-3 for R' in (R_*, R_*+1e-6]", RsLo - Rbar > 0 && RsHi + 10^-6 - Rbar <= 10^-6 + q["1.502e-21"] &&
    10^-6 + q["1.502e-21"] < 7/1000];
  ineqX["T12", "App.E 0.4", "|R - Rbar| <= 1e-6 + 2e-21 (alternative statement)", RsHi + 10^-6 - Rbar <= 10^-6 + 2 10^-21, {"exact"}, False];
  (* App. E 0.4 table rows not used by the proof *)
  ineqX["T13", "App.E 0.4 table (not used)", "delta1 = 1.5e-3: beta_max = 6.3902e-4, bound 2.7875e-3",
    Abs[(15/10000)/(ybar3 - 15/10000) - q["6.3902e-4"]] <= q["1e-8"] && Abs[bnd[15/10000] - q["2.7875e-3"]] <= q["1e-7"], {nf[(15/10000)/(ybar3 - 15/10000)], nf[bnd[15/10000]]}, False];
  ineqX["T14", "App.E 0.4 table (not used)", "delta1 = 3e-4: beta_max = 1.2774e-4, bound 5.572e-4",
    Abs[(3/10000)/(ybar3 - 3/10000) - q["1.2774e-4"]] <= q["1e-8"] && Abs[bnd[3/10000] - q["5.572e-4"]] <= q["1e-7"], {nf[(3/10000)/(ybar3 - 3/10000)], nf[bnd[3/10000]]}, False];
  ineqX["T15", "App.E 0.4 table (not used)", "delta1 = 2.5e-4: bound 4.643e-4; 'delta1 must be <= 2.69e-4' for rho_A = 5e-4",
    Abs[bnd[25/100000] - q["4.643e-4"]] <= q["1e-7"] && bnd[269/1000000] <= 5/10000 && bnd[270/1000000] > 5/10000, {nf[bnd[25/100000]], nf[bnd[269/1000000]]}, False];
  ineqX["T16", "Step 6 hand-off (not in scope; trivial)", "tau = 8.591e-10 < 8.6e-10 < 1/500000; 5.57947e-3 <= rho_A = 7/1000", q["8.591e-10"] < q["8.6e-10"] < 1/500000 && tot <= 7/1000, {"exact"}, False];
];

(* ================= meta-claims ================= *)
Module[{mg = {{"C(1.085)-B L1.3", infR[CS[1085/1000] - BS, JJ, 8]}, {"C(1.2)+C(1.35)-B L2.2", infR[CS[12/10] + CS[135/100] - BS, JJ, 8]},
     {"8a-B-2.962253 L2.2", infR[8 aS - BS, JJ, 4] - q["2.962253"]}, {"10a-B-1.06748-2r(1.085) L2.1", infR[10 aS - BS, JJ, 4] - q["1.06748"] - hi[2 ArcSin[1/ivr[1085/1000]]]},
     {"C(1.36)-(B-2c4) L4.2", infR[CS[136/100] - BS + 2 c4S, JJ, 16]}, {"6a-B-1.06748-0.366 L4.2", infR[6 aS - BS, JJ, 4] - q["1.06748"] - q["0.366"]},
     {"G1-4 L3.1", infR[G1S, JJ, 16] - 4}, {"G2-4 L3.1", infR[G2S, JJ, 16] - 4},
     {"2pi-10a-2r(1.085) M2", infR[2 Pi - 10 aS, JJ, 4] - hi[2 ArcSin[1/ivr[1085/1000]]]}, {"1.9656 sin(2a-B)-1 E3.2", infR[19656/10000 Sin[2 Pi - 10 aS - 2 dS], JJ, 8] - 1},
     {"2pi-10a-2d A4", infR[2 Pi - 10 aS - 2 dS, JJ, 4]}, {"2pi-4d-6a A4(3)", infR[2 Pi - 4 dS - 6 aS, JJ, 4]}}},
  thin = SortBy[mg, #[[2]] &];
  ineqX["X01", "App.B 3 Summary / caveat 2", "apart from rho_lo, every hand margin on JJ is >= 8.4e-4 (rounded rule: >= 8.35e-4)",
    And @@ (#[[2]] >= q["8.35e-4"] & /@ mg), (#[[1]] <> "=" <> nf[#[[2]]]) & /@ Take[thin, 4], False]];

(* ================= V: corrected statements (replacements for the False claims of the text) ================= *)
vIds0 = Length[results];
ineqX["N2v", "Notation l.49 (corrected)", "R_* - Rbar >= 1.50115e-21 (mid_cert A0 prints the margin 1.5011595e-21 to 6 digits)", RsLo - Rbar >= q["1.50115e-21"]];
ineqX["D3bv", "App.B (D3) (corrected)", "N >= sqrt(4 - 1.6317^2) >= 1.15652", lo[Sqrt[ivr[4 - q["1.6317"]^2]]] >= q["1.15652"]];
ineqX["D3cv", "App.B (D3) (corrected)", "R^2 - t^2 <= r1^2 - 1 <= 5.925845", r1^2 - 1 <= q["5.925845"]];
ineqX["D3dv", "App.B (D3) (corrected)", "(R+t)^2 >= (r0+1)^2 >= 13.18917", (r0 + 1)^2 >= q["13.18917"]];
ineqX["D3ev", "App.B (D3) (corrected)", "(5.925845/1.15652 + 2)/13.18917 <= 0.5402", (q["5.925845"]/q["1.15652"] + 2)/q["13.18917"] <= q["0.5402"],
  {"=" <> ToString[N[(q["5.925845"]/q["1.15652"] + 2)/q["13.18917"], 8]]}];
ineqX["U20v", "App.B 3 E3.2 (corrected)", "1.9656 * 0.612222 >= 1.20338 > 1", q["1.9656"] q["0.612222"] >= q["1.20338"] && q["1.20338"] > 1];
ineqR["U31v", "App.B 3 Lemma 1.4 (corrected threshold)", "t <= 2.2053 => t^2 <= rho*^2 + 1 on JJ (2.2053^2 <= 1.9656^2 + 1 <= rho_lo(R)^2 + 1)", rhoLoS^2 + 1 - q["2.2053"]^2, "GE", 0, JJ, 64];
ineqX["U31w", "App.B 3 Lemma 1.4 (corrected threshold, R-free)", "2.2053^2 <= 1.9656^2 + 1 (so 'sqrt(1.9656^2+1) >= 2.2053' is R-free given (D5))", q["2.2053"]^2 <= q["1.9656"]^2 + 1];
ineqX["U43v", "App.B 3 Lemma 2.2 (corrected)", "1e-5 (4*0.1561 + 2*0.4443) = 1.5130e-5 <= 1.52e-5 and 2.997557 - 1.52e-5 = 2.9975418 >= 2.962253 + 0.035",
  10^-5 (4 q["0.1561"] + 2 q["0.4443"]) <= q["1.52e-5"] && q["2.997557"] - q["1.52e-5"] >= q["2.962253"] + q["0.035"]];
ineqR["U45v", "App.B 3 Lemma 2.2 (direct, corrected constant)", "8a - B >= 2.9975418 on JJ", 8 aS - BS, "GE", q["2.9975418"], JJ, 4];
ineqX["D5z2v", "App.B (D5) (corrected)", "on [R_*, r1] the hand drop bound is (r1 - R_*)(3.20*1.2248 + 1.53) <= 5.1e-5, so the margin is >= 1.965663 - 1.5e-6 - 5.1e-5 - 1.9656 >= 1.0e-5",
  (r1 - RsLo) (q["3.20"] q["1.2248"] + q["1.53"]) <= q["5.1e-5"] && q["1.9656632"] - q["1.5e-6"] - q["5.1e-5"] - q["1.9656"] >= q["1.0e-5"]];
Module[{wl = lo[atP[wS, r1]] - q["1.3e-5"], wh = hi[atP[wS, r1]]},
  ineqX["D5fv", "App.B (D5) rectangle (corrected)", "R sin w <= 0.8514055 on [w(r1)-1.3e-5, w(r1)] x JJ", rng2[R Sin[w], JJ, w, {wl, wh}, 4, 4][[2]] <= q["0.8514055"]];
  ineqX["D5jv", "App.B (D5) (corrected)", "0.8514055*(2.49019/0.524508 - 1) <= 3.20 and 1 + 0.8514055*0.3236/0.524508 <= 1.53 (exact)",
    q["0.8514055"] (q["2.49019"]/q["0.524508"] - 1) <= q["3.20"] && 1 + q["0.8514055"] q["0.3236"]/q["0.524508"] <= q["1.53"]]];
ineqR["D6cv", "App.B (D6) (corrected)", "sqrt(R^2-1) <= 2.4343059 on JJ", Sqrt[R^2 - 1], "LE", q["2.4343059"], JJ, 4];
ineqR["U40v", "App.B 3 Lemma 2.1 (corrected)", "10a - B - 1.06748 >= 2.709619 on JJ", 10 aS - BS - q["1.06748"], "GE", q["2.709619"], JJ, 4];
ineqX["U41v", "App.B 3 Lemma 2.1 / 4.1(S) (corrected)", "2.709619 - 2.34467 > 0", q["2.709619"] - q["2.34467"] > 0];
vRes = Drop[results, vIds0];

(* ================= summary ================= *)
(* consequence analysis for every claim that may come out False; filled in after the first run *)
conseq = <|
  "N2" -> "NOT load-bearing. R_* - Rbar = 1.5011595057e-21 (cert 07) < 1.50116e-21: the text read the 6-significant-digit margin printed by mid_cert line A0 ('margin=1.50116e-21', a rounding of 1.5011595e-21) as a lower bound. mid_cert A0 itself checks Rbar < I_*lo exactly, and the proof uses only 0 < R_* - Rbar <= 1.502e-21 (N1, T11). Correct statement N2v: R_* - Rbar >= 1.50115e-21.",
  "D3b" -> "derivation step of (D3), rounding slip: sqrt(4 - 1.6317^2) = 1.1565271 < 1.15653. Harmless: with 1.15652 (D3bv) the chain still gives |dz/dR| <= 0.5402 (D3ev), and the conclusion |dC/dR| <= 1.4 holds directly (D3h, true sup 0.55).",
  "D3c" -> "derivation step of (D3), rounding slip: r1^2 - 1 = 5.92584489 > 5.92584. Harmless: D3cv/D3ev, and the direct D3f/D3h.",
  "D3d" -> "derivation step of (D3), rounding slip in the wrong direction: (r0+1)^2 = 13.1891722 < 13.1892 (a lower bound was rounded up). Harmless: D3dv/D3ev, and direct D3f/D3h.",
  "U16L" -> "NOT load-bearing as literally read: the Part D table entries carry the F7 table error (< 1e-4 by the F7 text) on top of the 1.4e-5 R-transfer. What the transfer actually claims, |C_R(t) - C_r1(t)| <= 1.4e-5, holds for every entry (U16). The load-bearing C values (1.085, 1.2+1.35, 1.36, c4) are verified directly on JJ (U25, U48, U81, U77).",
  "U20" -> "rounding slip in the wrong direction: 1.9656*0.612222 = 1.2033836 < 1.20339 (used as a lower bound). Harmless: >= 1.20338 > 1 (U20v); the direct inequality 1.9656 sin(2a - B) > 1 holds on JJ (U21).",
  "U31" -> "NOT load-bearing (as Repair M3 already says: the hand lemmas use the rho-monotonicity only for t <= 1.35, and C1_R tests t^2 <= rho_L^2 + 1 directly). As a threshold, 't <= 2.2054' is false near R_*: rho_lo(R_*) = 1.9656136 gives sqrt(rho_lo^2+1) = 2.2053681 < 2.2054; even 1.9656 gives 2.2053535. Correct threshold: t <= 2.2053 (U31v on JJ, U31w R-free).",
  "U30" -> "printed value sqrt(1.9656^2+1) = 2.2053535 rounds to 2.2054 correctly (VAL), but see U31 for its misuse as a threshold.",
  "U43" -> "derivation arithmetic slip: 1e-5(4*0.1561 + 2*0.4443) = 1.5130e-5 > 1.51e-5. Harmless: the corrected chain 2.997557 - 1.52e-5 = 2.9975418 still leaves margin >= 0.035 over 2.962253 (U43v), and directly 8a - B >= 2.9975418 on JJ (U45v).",
  "U65v" -> "printed intermediate values in Lemma 3.1 case 1 are off in the 6th decimal (2.086962^2 = 4.3554104, printed 4.355402), but every one is off in the SAFE direction (U65) and the exact chain is > 4 (U66); direct G1 > 4 on JJ (U67).",
  "D5z" -> "true drop on [R_*,r1] is checked directly; see value.",
  "D5z2" -> "derivation slip: with the (D5) constants the hand bound of the drop on [R_*, r1] is (r1 - R_*)(3.20*1.2248 + 1.53) = 5.03e-5 > 5.0e-5, so the text's '<= 5.0e-5' does not follow from its own constants (the true drop 4.97e-5 is <= 5.0e-5, D5z). Not load-bearing: only rho_lo > 1.9656 on [R_*, r1] is used, verified directly (D5w), and with 5.1e-5 the hand margin is still >= 1.0e-5 (D5z2v).",
  "U49" -> "not load-bearing (only pi - 8a > 0 is used, U49b).",
  "T07" -> "not load-bearing remark.",
  "X01" -> "meta-claim, see value.",
  "D5f" -> "derivation step of (D5), rounding slip: sup R sin w on the rectangle is r1 sin w(r1) = 0.85140543 > 0.851405. Harmless: with 0.8514055 (D5fv) the hand bounds 3.20 and 1.53 still follow (D5jv), they hold directly (D5k), and rho_lo > 1.9656 on JJ is verified directly (D5v).",
  "D6c" -> "rounding slip: sqrt(r1^2 - 1) = 2.43430583 > 2.4343058 (the F7 7-digit value was rounded down and then used as an upper bound). Harmless: no lemma uses 2.4343058; Lemma 3.1 uses 2.4344 (U62), and sqrt(R^2-1) <= 2.4343059 (D6cv).",
  "U40" -> "the transferred bound is off by 1.6e-7: min over JJ of 10a - B - 1.06748 is 2.7096198 < 2.70962 (2.70963185 at r1 minus 1.2e-5). Harmless: it is compared with 2.34467 (margin 0.365): >= 2.709619 holds (U40v, U41v).",
  "U44" -> "arithmetic slip: 2.997557 - 1.51e-5 = 2.9975419, not 2.997542 (and see U43). Harmless: see U45.",
  "U45" -> "the transferred bound is off by 7.8e-8: min over JJ of 8a - B = 2.99754192 < 2.997542. Harmless: it is compared with 2.962253 (margin 0.0353): 8a - B >= 2.9975418 on JJ (U45v) and the margin over 2.962253 is still >= 0.035 (U43v).",
  "U35" -> "NOT load-bearing (fallback only, and the fallback is not needed since rho_lo > 1.9656 is verified, D5v/D5w). The constant is false: |dA/du| at u ~ 1.966 is 1.37 at t = 1.085 (0.62 only near t = 1.35), so m0 values move by up to 1.4e-4, not 7e-5. The fallback conclusion still holds: with rho_lo = 1.9655 every dependent margin is >= 0.03, computed directly with A(., 1.9655) (U93)."
  |>;
(* replacement ids that must be True for each load-bearing False claim *)
repl = <|"D3b" -> {"D3bv", "D3ev", "D3f", "D3h"}, "D3c" -> {"D3cv", "D3ev", "D3f", "D3h"}, "D3d" -> {"D3dv", "D3ev", "D3f", "D3h"},
  "U20" -> {"U20v", "U21"}, "U43" -> {"U43v", "U45v"},
  "D5f" -> {"D5fv", "D5jv", "D5k", "D5v"}, "D6c" -> {"D6cv", "U62"}, "U40" -> {"U40v", "U41v"}, "U44" -> {"U43v", "U45v"}, "U45" -> {"U45v", "U43v"}|>;

Print[];
Module[{st = Association[(#[[1]] -> #[[5]]) & /@ results], bad = Select[results, ! #[[5]] &], lbBad, nlbBad, undoc, unrepl, vBad,
    nI = Count[results, {_, _, "INEQ", __}], nV = Count[results, {_, _, "VAL", __}], nA = Count[results, {_, _, "APPROX", __}], orig = Take[results, vIds0]},
  Print["23a: ", Length[orig], " claims of the text checked (", Count[orig, {_, _, "INEQ", __}], " INEQ, ", Count[orig, {_, _, "VAL", __}], " VAL, ",
    Count[orig, {_, _, "APPROX", __}], " APPROX; ", Count[orig, {__, True, _}], " load-bearing); ",
    Count[orig, {_, _, _, _, True, __}], " True, ", Count[orig, {_, _, _, _, False, __}], " False."];
  lbBad = Select[Take[results, vIds0], ! #[[5]] && #[[6]] &]; nlbBad = Select[Take[results, vIds0], ! #[[5]] && ! #[[6]] &];
  If[bad =!= {},
    Print["23a FALSE CLAIMS OF THE TEXT (id | LB? | location | claim  ==> consequence):"];
    Scan[Print["  ", #[[1]], " | ", If[#[[6]], "LB", "nlb"], " | ", #[[2]], " | ", #[[4]], "\n      ==> ", Lookup[conseq, #[[1]], "NO CONSEQUENCE ANALYSIS RECORDED"]] &,
      Take[bad, All]]];
  undoc = Select[Join[lbBad, nlbBad][[All, 1]], ! KeyExistsQ[conseq, #] &];
  unrepl = Select[lbBad[[All, 1]], Function[id, ! (KeyExistsQ[repl, id] && And @@ (TrueQ[Lookup[st, #, False]] & /@ repl[id]))]];
  vBad = Select[vRes, ! #[[5]] &];
  Print["23a load-bearing false: ", lbBad[[All, 1]], "; non-load-bearing false: ", nlbBad[[All, 1]]];
  Print["23a corrected statements (section V): ", Length[vRes], ", False: ", vBad[[All, 1]], "; undocumented false: ", undoc, "; load-bearing false without verified replacement: ", unrepl];
  Print["23a thinnest margins on JJ: rho_lo-1.9656 = ", nf[mgRhoJ], " (on [R*,r1]: ", nf[mgRhoS], "); ", StringRiffle[(#[[1]] <> " = " <> nf[#[[2]]]) & /@ Take[thin, 4], "; "]];
  Print["23a time ", Round[AbsoluteTime[] - t0clock], " s"];
  If[vBad === {} && undoc === {} && unrepl === {},
    Print["23a ALL HAND CONSTANTS VERIFIED"]; Exit[0],
    Print["23a FAILED"]; Exit[1]]];
