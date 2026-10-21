#!/usr/bin/env wolframscript
(* 22a-n11-b9-hand-constants.wls
   Rigorous re-check of every numerical hand inequality / constant used by the
   HAND parts of experiments/2026-10-20-siege-n11-b9/out/proof.md (lines 1-1280).
   Computations C1/C2 themselves are certified separately (22b/22c).

   Method.
   - R = r_1 = 26317/10000 exactly.
   - Numerical claims are decided with precision-50 bignum Interval arithmetic
     (outward rounded).  Every decision converts interval endpoints to exact
     rationals (SetPrecision[., Infinity]) and compares them with exact rationals.
     No machine-precision Interval is used anywhere.
   - Identities are decided exactly (Together / Expand / FullSimplify).
   - Range / monotonicity claims are decided by Reduce on an exact sign condition
     ("Reduce"), or by a bignum-Interval subdivision ("subdiv"); stated per claim.
   - Kinds of lines:
       VAL  a printed decimal value  x = v  (k decimals).  Accepted iff |x - v| <= 10^-k
            (one unit in the last printed digit: hand values are rounded or truncated),
            unless the document states its own error bound (then that bound).
            "rnd=True" additionally says v is the correctly rounded value.
       INEQ a load-bearing inequality / exact statement, decided exactly as written.
   One line per claim: id | location | kind | claim | value(s) | True/False.
   The main list keeps the claims AS ORIGINALLY WRITTEN (audit trail: 29 slips, each with a documented
   consequence in `conseq`); section V re-checks the replacement statements now in proof.md.
   Exit 0 iff every section-V claim is True and every False original claim is documented. *)

$HistoryLength = 0;
prec = 50; eps = 10^-45;

(* ---------- exact data ---------- *)
Rx = 26317/10000;

(* ---------- bignum interval primitives ---------- *)
ivr[q_] := Interval[{SetPrecision[q - eps, prec], SetPrecision[q + eps, prec]}];  (* encloses the exact rational q *)
RI = ivr[Rx];
PI = Interval[{SetPrecision[N[Pi, 70] - eps, prec], SetPrecision[N[Pi, 70] + eps, prec]}];
If[! (SetPrecision[Min[RI], Infinity] < Rx < SetPrecision[Max[RI], Infinity] &&
      SetPrecision[Min[PI], Infinity] < Pi < SetPrecision[Max[PI], Infinity]),
  Print["FATAL: base enclosures wrong"]; Exit[2]];

exQ[x_] := NumericQ[x] && Precision[x] === Infinity;
toI[x_Interval] := x;
toI[x_Integer | x_Rational] := Interval[{x, x}];       (* only exact RATIONALS are accepted as point values *)
tI[x_Interval] := x;
tI[x_Integer | x_Rational] := ivr[x];
tI[x_] := (Print["FATAL: non-rational argument ", x]; Exit[2]);
qi[s_String] := ivr[dec[s][[1]]];
toI[x_] := (Print["FATAL: non-interval value ", x]; Exit[2]);
lo[x_] := Module[{m = Min[toI[x]]}, If[NumericQ[m], SetPrecision[m, Infinity], -Infinity]];
hi[x_] := Module[{m = Max[toI[x]]}, If[NumericQ[m], SetPrecision[m, Infinity], Infinity]];

(* rigorous decisions on enclosures *)
LT[x_, y_] := hi[x] < lo[y];
LE[x_, y_] := hi[x] <= lo[y];
GT[x_, y_] := LT[y, x];
GE[x_, y_] := LE[y, x];
WITHIN[x_, v_, tol_] := (lo[x] >= v - tol) && (hi[x] <= v + tol);
width[x_] := hi[x] - lo[x];
mid[x_] := (lo[x] + hi[x])/2;
v12[x_] := Module[{y = N[mid[x], 20], me},
  If[y == 0, "0", If[Abs[y] >= 10^-4, ToString[NumberForm[y, 12]],
    me = MantissaExponent[y]; ToString[NumberForm[10 me[[1]], 12]] <> "e" <> ToString[me[[2]] - 1]]]];

(* ---------- the functions of the document (interval versions) ---------- *)
aI = ArcSin[1/RI];                 (* a = arcsin(1/R) *)
dI = ArcSin[2/RI];                 (* d = arcsin(2/R) *)
BI = 12 aI - 2 PI + 2 dI;          (* bridge budget B *)
deltaI = 9 aI - PI;                (* delta = 9a - pi *)
rhoW[w_] := RI Cos[w] - Sqrt[1 - RI^2 Sin[w]^2];   (* inner-branch centre radius for half-width w *)
rhoD[dd_] := rhoW[aI - dd];                        (* ... for deficit dd *)
zI[t0_] := With[{t = tI[t0]}, Sqrt[4 - (RI - t)^2]/(RI + t)];
gsymI[t_] := 2 ArcTan[zI[t]];
CI[t_] := 2 aI - gsymI[t];
clampAC[x_] := IntervalIntersection[toI[x], Interval[{-1, 1}]];
AI[t0_, u0_] := With[{t = tI[t0], u = tI[u0]}, ArcCos[clampAC[(t^2 + u^2 - 1)/(2 t u)]]];  (* used only where |t-u| <= 1 <= t+u *)
rI[t_] := ArcSin[1/tI[t]];
(* exact rational arguments of transcendental functions are first enclosed in bignum intervals *)

(* ---------- reporting ---------- *)
results = {};
emit[id_, loc_, kind_, txt_, vals_List, ok_] := Module[{b = TrueQ[ok]},
  AppendTo[results, {id, loc, kind, txt, b}];
  Print[id, " | ", loc, " | ", kind, " | ", txt, " | ", StringRiffle[vals, ", "], " | ", b]];
vv[name_, x_] := name <> "=" <> v12[x];
ineq[id_, loc_, txt_, vals_List, ok_] := emit[id, loc, "INEQ", txt, vals, ok];
(* decimal string -> exact rational, and number of decimals *)
dec[s_String] := Module[{neg = StringStartsQ[s, "-"], s1, ip, fp},
  s1 = StringDelete[s, "-"]; {ip, fp} = If[StringContainsQ[s1, "."], StringSplit[s1, "."], {s1, ""}];
  {(If[neg, -1, 1]) (FromDigits[ip] + If[fp == "", 0, FromDigits[fp]/10^StringLength[fp]]), StringLength[fp]}];
val[id_, loc_, name_, x_, s_String, tol_: Automatic] := Module[{v, k, tl, rnd},
  {v, k} = dec[s]; tl = If[tol === Automatic, 10^-k, tol];
  rnd = WITHIN[x, v, 1/2 10^-k];
  emit[id, loc, "VAL", name <> " = " <> s <> " (tol " <> tolS[tl] <> ")",
    {"true=" <> v12[x], "rnd=" <> ToString[rnd]}, WITHIN[x, v, tl]]];
reduceTrue[stmt_] := TrueQ[Reduce[stmt, Reals]];
tolS[x_] := Module[{e = Log10[x]}, If[IntegerQ[e], "1e" <> ToString[e], ToString[N[x, 3]]]];

Print["22a: R = ", Rx, ", working precision ", prec, " (bignum Interval); width(B) = ", N[width[BI], 3]];

(* independent sanity check of the enclosures: exact expressions evaluated by N[., 80] must lie inside *)
Module[{chk = {{aI, ArcSin[1/Rx]}, {dI, ArcSin[2/Rx]}, {BI, 12 ArcSin[1/Rx] - 2 Pi + 2 ArcSin[2/Rx]},
     {CI[1085/1000], 2 ArcSin[1/Rx] - 2 ArcTan[Sqrt[4 - (Rx - 1085/1000)^2]/(Rx + 1085/1000)]},
     {rhoD[BI/2], Rx Cos[ArcSin[1/Rx] - (12 ArcSin[1/Rx] - 2 Pi + 2 ArcSin[2/Rx])/2] - Sqrt[1 - Rx^2 Sin[ArcSin[1/Rx] - (12 ArcSin[1/Rx] - 2 Pi + 2 ArcSin[2/Rx])/2]^2]},
     {AI[136/100, 3683/10000], ArcCos[(136^2/100^2 + 3683^2/10^8 - 1)/(2 136/100 3683/10^4)]}}},
  ineq["Z01", "enclosure sanity", "N[exact, 80] of a, d, B, C(1.085), rho(B/2), A(1.36,0.3683) lies in the bignum intervals; widths < 1e-40", {"6 quantities"},
    And @@ ((lo[#[[1]]] <= SetPrecision[N[#[[2]], 80], Infinity] <= hi[#[[1]]] && width[#[[1]]] < 10^-40) & /@ chk)]];

(* ================= Notation ================= *)
val["N01", "Notation", "a", aI, "0.3897774"];
val["N02", "Notation", "2a", 2 aI, "0.7795548"];
ineq["N03", "Notation", "2a < pi/2", {vv["2a", 2 aI]}, LT[2 aI, PI/2]];
val["N04", "Notation", "pi - 8a", PI - 8 aI, "0.0233735"];
val["N05", "Notation", "delta = 9a - pi", deltaI, "0.3664040"];
val["N06", "Notation", "d", dI, "0.863259"];
val["N07", "Notation", "B = 12a - 2pi + 2d", BI, "0.1206621"];
val["N08", "Notation", "sqrt(R^2-1)", Sqrt[RI^2 - 1], "2.4343058"];

(* ================= Section 1: Lemmas R1-R3 ================= *)
val["R1a", "Lemma R1 step2", "16a", 16 aI, "6.23644"];
ineq["R1b", "Lemma R1 step2 / Lemma A0", "16a < 2pi (eight arcs cannot cover S_R)", {vv["2pi-16a", 2 PI - 16 aI]}, LT[16 aI, 2 PI]];
ineq["R1c", "Lemma R1 step3", "r_1 > 2", {"exact"}, Rx > 2];
ineq["R1d", "Lemma R1 step4", "r_1 >= 2.63169 (so T10(ii) excludes ten boundary disks)", {"exact"}, Rx >= 263169/100000];
ineq["R2a", "Lemma R2(c)", "R - 1 < sqrt(R^2-1)", {vv["sqrt(R^2-1)-(R-1)", Sqrt[RI^2 - 1] - RI + 1]}, LT[RI - 1, Sqrt[RI^2 - 1]]];
ineq["R2b", "Lemma R2(c)", "f(R-1) = 2R(R-1)(1-cos w), f(r) = r^2 - 2Rr cos w + R^2 - 1 (identity)", {"exact"},
  TrueQ[Expand[((Rx - 1)^2 - 2 Rx (Rx - 1) cw + Rx^2 - 1) - 2 Rx (Rx - 1) (1 - cw)] == 0]];
ineq["R2c", "Lemma R2(c)", "R - 1 > 0 (so 1 - 2t(m-s) <= 1)", {"exact"}, Rx - 1 > 0];
ineq["R3a", "Lemma R3(3)", "4a < 2pi (only consecutive lifted arcs meet)", {vv["4a", 4 aI]}, LT[4 aI, 2 PI]];

(* ================= Part A ================= *)
val["A01", "Part A header", "sin(0.863259)", Sin[ivr[863259/10^6]], "0.759965"];
val["A02", "Part A header", "2/r_1", 2/RI, "0.759965"];
ineq["A03", "Lemma A4(1)", "12a - 2pi + 2d <= 0.12066 at r_1 (as written)", {vv["B", BI]}, LE[BI, 12066/10^5]];
ineq["A04", "Lemma A4(1)", "Sum_{m not in T} d_m <= B/2 <= 0.0604", {vv["B/2", BI/2]}, LE[BI/2, 604/10^4]];
val["A05", "Lemma A4(1)", "12a", 12 aI, "4.677329"];
val["A06", "Lemma A4(1)", "2pi", 2 PI, "6.283185"];
val["A07", "Lemma A4(1)", "2d", 2 dI, "1.726518"];
val["A08", "Lemma A4(1)", "12a - 2pi + 2d", BI, "0.120662"];
val["A09", "Lemma A4", "2pi - 10a", 2 PI - 10 aI, "2.38541"];
val["A10", "Lemma A4", "2d", 2 dI, "1.72652"];
ineq["A11", "Lemma A4", "2pi - 10a > 2d", {vv["2pi-10a-2d", 2 PI - 10 aI - 2 dI]}, GT[2 PI - 10 aI, 2 dI]];
ineq["A12", "Lemma A4, N1, N2, N3 (R > r_1)", "a(R), d(R), 12a+2d, 4d+6a strictly decrease for R > 2 (Reduce on derivatives)", {"Reduce"},
  reduceTrue[ForAll[r, r > 2, D[ArcSin[1/r], r] < 0 && D[ArcSin[2/r], r] < 0 &&
    D[12 ArcSin[1/r] + 2 ArcSin[2/r], r] < 0 && D[4 ArcSin[2/r] + 6 ArcSin[1/r], r] < 0]]];
val["A13", "Lemma A4(2)", "pi - 6a", PI - 6 aI, "0.802928"];
val["A14", "Lemma A4(2)", "cos(pi - 6a)", Cos[PI - 6 aI], "0.694603"];
Module[{b = 2 RI Cos[PI - 6 aI], disc, r1, r2},
  disc = Sqrt[b^2 - 4 (RI^2 - 4)]; r1 = (b - disc)/2; r2 = (b + disc)/2;
  val["A15", "Lemma A4(2) (not load-bearing)", "2R cos(pi-6a)", b, "3.655976"];
  val["A16", "Lemma A4(2) (not load-bearing)", "sqrt((2R cos)^2 - 4(R^2-4))", disc, "1.289488"];
  ineq["A17", "Lemma A4(2) (not load-bearing)", "1.1832 <= root_- and root_+ <= 2.4728", {vv["root-", r1], vv["root+", r2]},
    LE[11832/10^4, r1] && LE[r2, 24728/10^4]]];
val["A18", "Lemma A4(3) / N3", "4d", 4 dI, "3.453036"];
val["A19", "Lemma A4(3) / N3", "6a", 6 aI, "2.338664"];
val["A20", "Lemma A4(3) / N3", "4d + 6a", 4 dI + 6 aI, "5.791700"];
ineq["A21", "Lemma A4(3) / N3", "4d + 6a < 2pi, margin >= 0.49", {vv["2pi-4d-6a", 2 PI - 4 dI - 6 aI]}, GE[2 PI - 4 dI - 6 aI, 49/100]];
ineq["A22", "Lemma A5", "|c_E| <= 1 < R - 1", {"exact"}, Rx - 1 > 1];

(* ================= Part B section 1 ================= *)
val["B01", "Lemma N1", "10a", 10 aI, "3.897774"];
val["B02", "Lemma N1", "2pi - 10a", 2 PI - 10 aI, "2.385411"];
val["B03", "Lemma N1", "2d", 2 dI, "1.726518"];
val["B04", "Lemma N2", "B", BI, "0.120662"];
ineq["B05", "Lemma N2", "2pi - 2a > 2d", {vv["2pi-2a-2d", 2 PI - 2 aI - 2 dI]}, GT[2 PI - 2 aI, 2 dI]];
ineq["B06", "Lemma S", "4(t^2-1) <= t^4 for all t (=> arccos(t/2) <= arcsin(1/t), t >= sqrt2) (Reduce)", {"Reduce"},
  reduceTrue[ForAll[t, 4 (t^2 - 1) <= t^4]]];

(* ================= Part D ================= *)
val["D01", "Part D budget", "18a - 2pi = 2 delta", 18 aI - 2 PI, "0.732808"];
ineq["D02", "Lemma G", "(R+t)^2 - 4 + (R-t)^2 = 2(R^2+t^2-2) (identity)", {"exact"},
  TrueQ[Expand[(r + t)^2 - 4 + (r - t)^2 - 2 (r^2 + t^2 - 2)] == 0]];
ineq["D03", "Lemma G", "s > t > 0, s^2+t^2 > 2 => s^2+t^2-2 < 2s(s+t) (Reduce)", {"Reduce"},
  reduceTrue[ForAll[{s, t}, t > 0 && s > t && s^2 + t^2 > 2, s^2 + t^2 - 2 < 2 s (s + t)]]];
ineq["D04", "Lemma G", "log-derivative of f(s) < 0 for t > 0, t < s < t+2, s^2+t^2 > 2 (Reduce)", {"Reduce"},
  reduceTrue[ForAll[{s, t}, t > 0 && s > t && s < t + 2 && s^2 + t^2 > 2,
    -(s - t)/(4 - (s - t)^2) + 1/(s + t) - 2 s/(s^2 + t^2 - 2) < 0]]];
With[{h = (4 - (Rx - t)^2)/(Rx + t)^2},
 With[{dh = Together[D[h, t]]},
  ineq["D05", "Part D remark", "h'(t) = 2(2R(R-t)-4)/(R+t)^3 for h = z^2 (identity)", {"exact"},
    TrueQ[Together[dh - 2 (2 Rx (Rx - t) - 4)/(Rx + t)^3] == 0]];
  ineq["D06", "Part D remark / Lemma 1.3", "h' > 0 on (R-2, R-2/R), h >= 0 on [R-2, R-2/R]: g_sym increasing, C decreasing there (Reduce)", {"Reduce"},
    reduceTrue[ForAll[t, Rx - 2 < t < Rx - 2/Rx, dh > 0]] && reduceTrue[ForAll[t, Rx - 2 <= t <= Rx - 2/Rx, h >= 0]]];
  ineq["D07", "Part D remark", "z(t*)^2 = 1/(R^2-1) and g_sym(t*) = 2a exactly, t* = R - 2/R", {"exact"},
    TrueQ[Together[(h /. t -> Rx - 2/Rx) - 1/(Rx^2 - 1)] == 0] && TrueQ[FullSimplify[ArcTan[Sqrt[1/(Rx^2 - 1)]] == ArcSin[1/Rx]]]]]];
val["D08", "Part D remark", "t* = R - 2/R", RI - 2/RI, "1.871735"];
ineq["D09", "Part D / Lemma 1.3", "1.8717 <= R - 2/R; R - 2 <= 0.8 (table inside monotone range start)", {vv["R-2/R", RI - 2/RI]},
  LE[18717/10^4, RI - 2/RI] && LE[RI - 2, 8/10]];
Module[{ts = {"0.8", "0.9", "1.0", "1.1", "1.2", "1.3", "1.4", "1.5", "1.7"},
    gs = {"0.4597", "0.5522", "0.6166", "0.6638", "0.6990", "0.7255", "0.7452", "0.7595", "0.7757"},
    cs = {"0.3198", "0.2274", "0.1630", "0.1158", "0.0806", "0.0541", "0.0344", "0.0201", "0.0038"}},
  Do[With[{t0 = dec[ts[[i]]][[1]]},
     val["D10." <> ToString[i], "Part D table (doc error < 1e-4)", "g_sym(" <> ts[[i]] <> ")", gsymI[t0], gs[[i]], 10^-4];
     val["D11." <> ToString[i], "Part D table (doc error < 1e-4)", "C(" <> ts[[i]] <> ")", CI[t0], cs[[i]], 10^-4]], {i, Length[ts]}]];

(* ================= Part E ================= *)
ineq["E01", "Lemma E2.1/E2.2", "rho_0 = R-2 = 0.6317, 1-rho_0 = 0.3683, rho_0^2 = 0.39904489, 1-rho_0^2 = 0.60095511 (exact)", {"exact"},
  Rx - 2 == 6317/10000 && 3 - Rx == 3683/10000 && (Rx - 2)^2 == 39904489/10^8 && 1 - (Rx - 2)^2 == 60095511/10^8];
val["E02", "Lemma E2.2", "u* = sqrt(1-rho_0^2)", Sqrt[1 - (RI - 2)^2], "0.775213"];
val["E03", "Lemma E2.2", "sqrt(0.60095511)", Sqrt[1 - (RI - 2)^2], "0.7752129"];
ineq["E04", "Lemma E2.2", "u* <= 0.77522 (rounded up)", {vv["u*", Sqrt[1 - (RI - 2)^2]]}, LE[Sqrt[1 - (RI - 2)^2], 77522/10^5]];
ineq["E05", "Lemma E2.2", "u > u* => rho_0^2 + u^2 - 1 > 0 (Reduce)", {"Reduce"},
  reduceTrue[ForAll[u, u > Sqrt[1 - (Rx - 2)^2], (Rx - 2)^2 + u^2 - 1 > 0]]];
ineq["E06", "Lemma E2.2 (reach)", "1 + u* <= 1.77522", {vv["1+u*", 1 + Sqrt[1 - (RI - 2)^2]]}, LE[1 + Sqrt[1 - (RI - 2)^2], 177522/10^5]];
With[{w = aI - BI/2},
  val["E07", "Lemma E3.1", "w = a - B/2", w, "0.3294464"];
  val["E08", "Lemma E3.1", "sin w", Sin[w], "0.3235192"];
  val["E09", "Lemma E3.1", "cos w", Cos[w], "0.9462215"];
  val["E10", "Lemma E3.1", "R cos w", RI Cos[w], "2.4901711"];
  val["E11", "Lemma E3.1", "1 - R^2 sin^2 w", 1 - RI^2 Sin[w]^2, "0.2751086"];
  val["E12", "Lemma E3.1", "sqrt(1 - R^2 sin^2 w)", Sqrt[1 - RI^2 Sin[w]^2], "0.5245082"];
  val["E13", "Lemma E3.1", "rho(a - B/2)", rhoW[w], "1.965663"];
  ineq["E14", "Lemma E3.1", "rho_lo = 1.9656 <= rho(a - B/2)", {vv["rho", rhoW[w]]}, LE[19656/10^4, rhoW[w]]]];
val["E15", "Lemma E3.1", "2a - B", 2 aI - BI, "0.6588928"];
ineq["E16", "Lemma E3.1", "A(R,rho) increasing in rho on [R-1, sqrt(R^2-1)]: d/drho of cos = (rho^2-R^2+1)/(2R rho^2) < 0 (Reduce)", {"Reduce"},
  TrueQ[Together[D[(Rx^2 + p^2 - 1)/(2 Rx p), p] - (p^2 - Rx^2 + 1)/(2 Rx p^2)] == 0] &&
  reduceTrue[ForAll[p, Rx - 1 <= p < Sqrt[Rx^2 - 1], (p^2 - Rx^2 + 1)/(2 Rx p^2) < 0]]];
val["E17", "Lemma E3.2", "sin(2a - B)", Sin[2 aI - BI], "0.6122416"];
val["E18", "Lemma E3.2", "1.9656 sin(2a - B)", 19656/10^4 Sin[2 aI - BI], "1.2034"];
ineq["E19", "Lemma E3.2", "rho_lo sin(2a - B) > 1 (and g in [2a-B, 2a] subset (0, pi/2), so sin g >= sin(2a-B))", {vv["1.9656 sin(2a-B)", 19656/10^4 Sin[2 aI - BI]]},
  GT[19656/10^4 Sin[2 aI - BI], 1] && GT[2 aI - BI, 0] && LT[2 aI, PI/2]];
ineq["E20", "Part M soundness / Lemma 1.4 / 3.1(c)", "rho(w) increasing in w on [0,a] (dρ/dw >= 0 <=> R^2 >= 1; Reduce in s = sin w)", {"Reduce"},
  reduceTrue[ForAll[sv, 0 <= sv <= 1/Rx, Rx^2 (1 - sv^2) >= 1 - Rx^2 sv^2]]];

(* ================= Part M section 1 ================= *)
(* rigorous upper bound of f on [t0,t1] by bignum-Interval subdivision into n pieces *)
supSub[f_, t0_, t1_, n_] := Max[Table[hi[f[Interval[{SetPrecision[t0 + (t1 - t0) i/n - eps, prec],
      SetPrecision[t0 + (t1 - t0) (i + 1)/n + eps, prec]}]]], {i, 0, n - 1}]];
infSub[f_, t0_, t1_, n_] := Min[Table[lo[f[Interval[{SetPrecision[t0 + (t1 - t0) i/n - eps, prec],
      SetPrecision[t0 + (t1 - t0) (i + 1)/n + eps, prec]}]]], {i, 0, n - 1}]];
q[s_String] := dec[s][[1]];
m0I[t_] := AI[t, q["1.9656"]];

val["M01", "Lemma 1.3", "2a", 2 aI, "0.779555"];
val["M02", "Lemma 1.3", "z(1.085) = sqrt(4-(R-1.085)^2)/(R+1.085)", zI[q["1.085"]], "0.341152"];
val["M03", "Lemma 1.3", "2 arctan z(1.085)", gsymI[q["1.085"]], "0.657542"];
val["M04", "Lemma 1.3 (doc: series error < 1e-6)", "C(1.085)", CI[q["1.085"]], "0.122013", 10^-6];
val["M05", "Section 13 (tightest margin)", "C(1.085) - B", CI[q["1.085"]] - BI, "0.00135"];
ineq["M06", "Lemma 1.3", "R - 2 <= 1.085 <= 1.8717 and C(1.085) > B (with D06: t_i <= 1.085 => C(t_i) >= C(1.085) > B >= kappa_i)",
  {vv["C(1.085)-B", CI[q["1.085"]] - BI]}, Rx - 2 <= q["1.085"] <= q["1.8717"] && GT[CI[q["1.085"]], BI]];
val["M07", "Lemma 1.4 / Repair M3", "sqrt(1.965663^2 + 1)", Sqrt[ivr[q["1.965663"]^2 + 1]], "2.2054"];
ineq["M08", "Lemma 1.4", "t <= 2.2054 => t^2 <= rho*(kappa)^2 + 1 (2.2054^2 <= rho(a-B/2)^2 + 1, rho* >= rho(a-B/2))",
  {vv["rho(a-B/2)^2+1-2.2054^2", rhoW[aI - BI/2]^2 + 1 - q["2.2054"]^2]}, LE[q["2.2054"]^2, rhoW[aI - BI/2]^2 + 1]];
ineq["M09", "Lemma 1.4", "d/drho (t^2+rho^2-1)/(2 t rho) = (rho^2-t^2+1)/(2 t rho^2), > 0 for rho^2 > t^2-1 (identity + Reduce)", {"Reduce"},
  TrueQ[Together[D[(t^2 + p^2 - 1)/(2 t p), p] - (p^2 - t^2 + 1)/(2 t p^2)] == 0] &&
  reduceTrue[ForAll[{t, p}, t > 0 && p > 0 && p^2 > t^2 - 1, (p^2 - t^2 + 1)/(2 t p^2) > 0]]];
ineq["M10", "Lemma 1.4 / Lemma S", "A(t,rho) <= arcsin(1/rho): (t^2+rho^2-1)/(2 t rho) >= sqrt(rho^2-1)/rho for rho > 1, t > 0 (Reduce)", {"Reduce"},
  reduceTrue[ForAll[{t, p}, t > 0 && p > 1, (t^2 + p^2 - 1)/(2 t p) >= Sqrt[p^2 - 1]/p]]];
val["M11", "Lemma 1.4", "arcsin(1/1.9656)", rI[q["1.9656"]], "0.53374"];
ineq["M12", "Lemma 1.4", "arcsin(1/rho*(kappa)) <= arcsin(1/1.9656) <= 0.53374", {vv["arcsin(1/1.9656)", rI[q["1.9656"]]]},
  LE[rI[q["1.9656"]], q["0.53374"]] && LE[q["1.9656"], rhoW[aI - BI/2]]];
ineq["M13", "Lemma 1.4", "lambda >= 2a - kappa - 0.53374 >= 0.24581 - kappa", {vv["2a-0.53374", 2 aI - q["0.53374"]]}, GE[2 aI - q["0.53374"], q["0.24581"]]];

(* ================= Part M section 2 ================= *)
val["M14", "Section 2 angle bookkeeping", "10a", 10 aI, "3.89777"];
val["M15", "Section 2 angle bookkeeping", "2 r(1.085)", 2 rI[q["1.085"]], "2.34466"];
val["M16", "Section 2 angle bookkeeping", "2pi - 3.89777", 2 PI - q["3.89777"], "2.38541"];
ineq["M17", "Section 2 angle bookkeeping", "2pi - 10a > 2 r(1.085) (circular distance = real difference)", {vv["2pi-10a-2r(1.085)", 2 PI - 10 aI - 2 rI[q["1.085"]]]},
  GT[2 PI - 10 aI, 2 rI[q["1.085"]]]];
Module[{ts = {"1.085", "1.1", "1.15", "1.2", "1.25", "1.3", "1.35", "1.45"},
    cs = {"0.122013", "0.1158", "0.096917", "0.080557", "0.066373", "0.054103", "0.043497", "0.026631"},
    rs = {"1.172329", "1.141095", "1.054319", "0.985111", "0.927295", "0.876298", "0.834172", "0.761013"},
    ms = {"0.3255", "0.3434", "", "0.42201", "0.4499", "0.4705", "0.48865", ""}, tl},
  tl[s_] := Max[10^-5, 10^-dec[s][[2]]];   (* doc: error < 1e-5; entries with fewer digits: one last unit *)
  Do[With[{t0 = q[ts[[i]]]},
     val["M18." <> ToString[i], "Section 2 table (doc error < 1e-5)", "C(" <> ts[[i]] <> ")", CI[t0], cs[[i]], tl[cs[[i]]]];
     val["M19." <> ToString[i], "Section 2 table (doc error < 1e-5)", "r(" <> ts[[i]] <> ")", rI[t0], rs[[i]], tl[rs[[i]]]];
     If[ms[[i]] =!= "", val["M20." <> ToString[i], "Section 2 table (doc error < 1e-5)", "m0(" <> ts[[i]] <> ") = A(t,1.9656)", m0I[t0], ms[[i]], tl[ms[[i]]]]]],
    {i, Length[ts]}]];
ineq["M21", "Section 2 example", "R - 1.2 = 1.4317, R + 1.2 = 3.8317 (exact)", {"exact"}, Rx - q["1.2"] == q["1.4317"] && Rx + q["1.2"] == q["3.8317"]];
val["M22", "Section 2 example (table error < 1e-5)", "z(1.2)", zI[q["1.2"]], "0.364462", 10^-5];
val["M23", "Section 2 example (table error < 1e-5)", "arctan z(1.2)", ArcTan[zI[q["1.2"]]], "0.349499", 10^-5];
val["M24", "Section 2 example (table error < 1e-5)", "2 arctan z(1.2)", gsymI[q["1.2"]], "0.698998", 10^-5];
val["M25", "Section 2 example (table error < 1e-5)", "C(1.2)", CI[q["1.2"]], "0.080557", 10^-5];
(* Lemma 2.1 *)
val["M26", "Lemma 2.1", "10a", 10 aI, "3.897774"];
val["M27", "Lemma 2.1", "10a - B - 1.06748", 10 aI - BI - q["1.06748"], "2.70963"];
ineq["M28", "Lemma 2.1 / Lemma 4.1(S)", "10a - B - 2*0.53374 > 2 r(1.085) (true r)", {vv["diff", 10 aI - BI - q["1.06748"] - 2 rI[q["1.085"]]]},
  GT[10 aI - BI - 2 q["0.53374"], 2 rI[q["1.085"]]]];
(* Lemma 2.2 *)
val["M29", "Lemma 2.2", "8a - B", 8 aI - BI, "2.997557"];
ineq["M30", "Lemma 2.2", "t <= 1.35 => t^2 <= 1.9656^2 + 1", {"exact"}, q["1.35"]^2 <= q["1.9656"]^2 + 1];
val["M31", "Lemma 2.2", "sqrt(1.9656^2 - 1)", Sqrt[ivr[q["1.9656"]^2 - 1]], "1.692"];
ineq["M32", "Lemma 2.2", "m0 increasing in t on [1.085, 1.35]: d/dt cos = (t^2-rho^2+1)/(2t^2 rho) < 0 for t^2 < rho^2-1, rho = 1.9656; and |t-rho| <= 1 there (Reduce)", {"Reduce"},
  TrueQ[Together[D[(t^2 + p^2 - 1)/(2 t p), t] - (t^2 - p^2 + 1)/(2 t^2 p)] == 0] &&
  reduceTrue[ForAll[t, q["1.085"] <= t <= q["1.35"], (t^2 - q["1.9656"]^2 + 1)/(2 t^2 q["1.9656"]) < 0 && Abs[t - q["1.9656"]] <= 1 <= t + q["1.9656"]]]];
ineq["M33", "Lemma 2.2", "r(t) = arcsin(1/t) decreasing for t > 1 (Reduce)", {"Reduce"}, reduceTrue[ForAll[t, t > 1, D[ArcSin[1/t], t] < 0]]];
val["M34", "Lemma 2.2", "r(1.085) + m0(1.2)", rI[q["1.085"]] + m0I[q["1.2"]], "1.59434"];
val["M35", "Lemma 2.2", "r(1.2) + m0(1.35)", rI[q["1.2"]] + m0I[q["1.35"]], "1.47376"];
val["M36", "Lemma 2.2", "r(1.35) + 0.53374", rI[q["1.35"]] + q["0.53374"], "1.36791"];
ineq["M37", "Lemma 2.2", "h <= 1.59434 on [1.085,1.2] (monotone endpoints AND subdiv 400)", {vv["endpt", rI[q["1.085"]] + m0I[q["1.2"]]],
   "subdiv sup=" <> ToString[N[supSub[rI[#] + m0I[#] &, q["1.085"], q["1.2"], 400], 12]]},
  LE[rI[q["1.085"]] + m0I[q["1.2"]], q["1.59434"]] && supSub[rI[#] + m0I[#] &, q["1.085"], q["1.2"], 400] <= q["1.59434"]];
ineq["M38", "Lemma 2.2", "h <= 1.47376 on [1.2,1.35] (monotone endpoints AND subdiv 400)", {vv["endpt", rI[q["1.2"]] + m0I[q["1.35"]]],
   "subdiv sup=" <> ToString[N[supSub[rI[#] + m0I[#] &, q["1.2"], q["1.35"], 400], 12]]},
  LE[rI[q["1.2"]] + m0I[q["1.35"]], q["1.47376"]] && supSub[rI[#] + m0I[#] &, q["1.2"], q["1.35"], 400] <= q["1.47376"]];
ineq["M39", "Lemma 2.2", "h <= r(1.35) + 0.53374 <= 1.36791 on [1.35, oo) (as written)", {vv["r(1.35)+0.53374", rI[q["1.35"]] + q["0.53374"]]},
  LE[rI[q["1.35"]] + q["0.53374"], q["1.36791"]]];
ineq["M39c", "Lemma 2.2 (corrected M39)", "h <= r(1.35) + arcsin(1/1.9656) <= 1.36791 on [1.35, oo)", {vv["r(1.35)+arcsin(1/1.9656)", rI[q["1.35"]] + rI[q["1.9656"]]]},
  LE[rI[q["1.35"]] + rI[q["1.9656"]], q["1.36791"]]];
val["M40", "Lemma 2.2", "C(1.2) + C(1.35)", CI[q["1.2"]] + CI[q["1.35"]], "0.124054"];
ineq["M41", "Lemma 2.2", "C(1.2) + C(1.35) > B (and C(1.2) >= C(1.35))", {vv["C(1.2)+C(1.35)-B", CI[q["1.2"]] + CI[q["1.35"]] - BI]},
  GT[CI[q["1.2"]] + CI[q["1.35"]], BI] && GE[CI[q["1.2"]], CI[q["1.35"]]]];
ineq["M42", "Lemma 2.2", "max(1.59434+1.36791, 2*1.47376) = 2.96225 < 8a - B", {vv["8a-B-2.96225", 8 aI - BI - q["2.96225"]]},
  Max[q["1.59434"] + q["1.36791"], 2 q["1.47376"]] == q["2.96225"] && LT[q["2.96225"], 8 aI - BI]];
ineq["M43", "Lemma 2.2", "all remaining case pairs with true sup bounds < 8a - B", {vv["worst", rI[q["1.085"]] + m0I[q["1.2"]] + rI[q["1.35"]] + q["0.53374"]]},
  LT[rI[q["1.085"]] + m0I[q["1.2"]] + rI[q["1.35"]] + q["0.53374"], 8 aI - BI] &&
  LT[2 (rI[q["1.2"]] + m0I[q["1.35"]]), 8 aI - BI] && LT[rI[q["1.2"]] + m0I[q["1.35"]] + rI[q["1.35"]] + q["0.53374"], 8 aI - BI] &&
  LT[2 (rI[q["1.35"]] + q["0.53374"]), 8 aI - BI]];

(* ================= Part M section 3: Lemma 3.1 ================= *)
ineq["M44", "Lemma 3.1", "rho' >= R - 1 = 1.6317 (exact)", {"exact"}, Rx - 1 == q["1.6317"]];
val["M45", "Lemma 3.1(a)", "2pi - 16a = 2(pi - 8a)", 2 PI - 16 aI, "0.046747"];
val["M46", "Lemma 3.1(c)", "3a + (pi - 8a) = pi - 5a", PI - 5 aI, "1.1927057"];
ineq["M47", "Lemma 3.1(c)", "Theta <= 3a + w' <= 4a < pi/2", {vv["pi/2-4a", PI/2 - 4 aI]}, LT[4 aI, PI/2]];
ineq["M48", "Lemma 3.1(c)", "pi - 8a >= 0.023374 (2d_t <= w' - 0.023374)", {vv["pi-8a", PI - 8 aI]}, GE[PI - 8 aI, q["0.023374"]]];
ineq["M48c", "Lemma 3.1(c) (corrected M48)", "pi - 8a >= 0.0233734 (2d_t <= w' - 0.0233734); the bound is not used later (case split uses d_t <= B/2)", {vv["pi-8a", PI - 8 aI]}, GE[PI - 8 aI, q["0.0233734"]]];
val["M49", "Lemma 3.1(c)", "B/2", BI/2, "0.060331"];
ineq["M50", "Lemma 3.1(c)/(d)", "d_t <= B/2 <= 0.060331 (upper end of the second case [0.03, 0.060331], as written)", {vv["B/2", BI/2]}, LE[BI/2, q["0.060331"]]];
ineq["M51", "Lemma 3.1(c)", "rho_t >= rho(B/2) >= 1.965663", {vv["rho(B/2)", rhoD[BI/2]]}, GE[rhoD[BI/2], q["1.965663"]]];
ineq["M52", "Lemma 3.1(d)", "rho_t <= sqrt(R^2-1) <= 2.4344, and 1.1927 <= pi - 5a (cos Theta <= cos 1.1927, Theta in [0, pi/2))", {vv["pi-5a-1.1927", PI - 5 aI - q["1.1927"]]},
  LE[Sqrt[RI^2 - 1], q["2.4344"]] && LE[q["1.1927"], PI - 5 aI]];
val["M53", "Lemma 3.1(d)", "cos(1.1927)", Cos[qi["1.1927"]], "0.3692"];
ineq["M54", "Lemma 3.1(d)", "2.4344 cos(1.1927) < 0.90 < 1.6317 <= rho'", {vv["2.4344cos(1.1927)", q["2.4344"] Cos[qi["1.1927"]]]},
  LT[q["2.4344"] Cos[qi["1.1927"]], q["0.90"]] && q["0.90"] < Rx - 1];
ineq["M55", "Lemma 3.1(d)", "cos(1.1927) <= 0.3692, 2.4344*0.3692 < 0.9 < 1.9656 <= rho_t", {vv["cos(1.1927)", Cos[qi["1.1927"]]]},
  LE[Cos[qi["1.1927"]], q["0.3692"]] && q["2.4344"] q["0.3692"] < q["0.9"] && q["0.9"] < q["1.9656"] && LE[q["1.9656"], rhoD[BI/2]]];
(* case d_t in [0, 0.03] *)
val["M56", "Lemma 3.1(d) case 1", "rho(0.03)", rhoD[q["0.03"]], "2.086994"];
val["M57", "Lemma 3.1(d) case 1", "cos(1.1927057)", Cos[qi["1.1927057"]], "0.369147"];
val["M58", "Lemma 3.1(d) case 1", "rho(0.03)^2", rhoD[q["0.03"]]^2, "4.355544"];
val["M59", "Lemma 3.1(d)", "1.6317^2", toI[q["1.6317"]^2], "2.662445"];
val["M60", "Lemma 3.1(d) case 1", "2*1.6317*rho(0.03)", 2 q["1.6317"] rhoD[q["0.03"]], "6.810660"];
val["M61", "Lemma 3.1(d) case 1", "G lower bound (doc formula, cos(1.1927057))",
  rhoD[q["0.03"]]^2 + q["1.6317"]^2 - 2 q["1.6317"] rhoD[q["0.03"]] Cos[qi["1.1927057"]], "4.5038"];
With[{G1 = rhoD[q["0.03"]]^2 + (RI - 1)^2 - 2 (RI - 1) rhoD[q["0.03"]] Cos[PI - 5 aI]},
  ineq["M62", "Lemma 3.1(d) case 1", "G >= rho(0.03)^2 + (R-1)^2 - 2(R-1) rho(0.03) cos(pi-5a) > 4 (rigorous Theta_lo = pi-5a)", {vv["G1", G1]}, GT[G1, 4]]];
(* case d_t in [0.03, B/2] *)
val["M63", "Lemma 3.1(d) case 2", "cos(1.2227057)", Cos[qi["1.2227057"]], "0.341104"];
val["M64", "Lemma 3.1(d) case 2", "1.9656^2", toI[q["1.9656"]^2], "3.863583"];
val["M65", "Lemma 3.1(d) case 2", "2*1.6317*1.9656", toI[2 q["1.6317"] q["1.9656"]], "6.414537"];
val["M66", "Lemma 3.1(d) case 2", "G lower bound (doc formula)", toI[q["1.9656"]^2 + q["1.6317"]^2] - 2 q["1.6317"] q["1.9656"] Cos[qi["1.2227057"]], "4.3380"];
With[{G2 = q["1.9656"]^2 + (RI - 1)^2 - 2 (RI - 1) q["1.9656"] Cos[PI - 5 aI + q["0.03"]]},
  ineq["M67", "Lemma 3.1(d) case 2", "G >= 1.9656^2 + (R-1)^2 - 2(R-1)1.9656 cos(pi-5a+0.03) > 4, valid for all d_t in [0.03, B/2] (1.9656 <= rho(B/2))",
    {vv["G2", G2]}, GT[G2, 4] && LE[q["1.9656"], rhoD[BI/2]]]];
ineq["M68", "Lemma 3.1(d)", "margins: G1 - 4 >= 0.50 and G2 - 4 >= 0.33", {"see M62/M67"},
  GE[rhoD[q["0.03"]]^2 + (RI - 1)^2 - 2 (RI - 1) rhoD[q["0.03"]] Cos[PI - 5 aI] - 4, q["0.50"]] &&
  GE[q["1.9656"]^2 + (RI - 1)^2 - 2 (RI - 1) q["1.9656"] Cos[PI - 5 aI + q["0.03"]] - 4, q["0.33"]]];

(* ================= Part M section 4 ================= *)
ineq["M69", "Lemma 4.2", "1 + (3 - R) = 4 - R = 1.3683; R + (4-R) = 4; R - (4-R) = 1.2634 (exact)", {"exact"},
  4 - Rx == q["1.3683"] && Rx - (4 - Rx) == q["1.2634"]];
val["M70", "Lemma 4.2", "z(1.3683) = sqrt(4-1.2634^2)/4", zI[q["1.3683"]], "0.3876065"];
val["M71", "Lemma 4.2", "z(1.3683)", zI[q["1.3683"]], "0.387607"];
val["M72", "Lemma 4.2", "2 arctan z(1.3683)", gsymI[q["1.3683"]], "0.739555"];
ineq["M73", "Lemma 4.2", "C(1.3683) >= 0.039999", {vv["C(1.3683)", CI[q["1.3683"]]]}, GE[CI[q["1.3683"]], q["0.039999"]]];
val["M74", "Lemma 4.2", "B - 2*0.039999", BI - 2 q["0.039999"], "0.040664"];
ineq["M75", "Lemma 4.2", "B - 2*0.039999 <= 0.040664 (as written: C(t_i) <= 0.040664)", {vv["B-0.079998", BI - 2 q["0.039999"]]}, LE[BI - 2 q["0.039999"], q["0.040664"]]];
val["M76", "Lemma 4.2", "arctan z(1.36)", ArcTan[zI[q["1.36"]]], "0.3689961"];
val["M77", "Lemma 4.2", "C(1.36)", CI[q["1.36"]], "0.041563"];
ineq["M78", "Lemma 4.2", "C(1.36) > 0.040664 and C(1.36) > B - 2 C(1.3683) (rigorous form)", {vv["C(1.36)-(B-2C(1.3683))", CI[q["1.36"]] - BI + 2 CI[q["1.3683"]]]},
  GT[CI[q["1.36"]], q["0.040664"]] && GT[CI[q["1.36"]], BI - 2 CI[q["1.3683"]]]];
ineq["M79", "Lemma 4.2", "A(t,u) decreasing in t (0 < u <= 1 < t) and increasing in u for u^2 <= t^2-1 (signs of exact partials; Reduce)", {"Reduce"},
  TrueQ[Together[D[(t^2 + u^2 - 1)/(2 t u), t] - (t^2 - u^2 + 1)/(2 t^2 u)] == 0] &&
  TrueQ[Together[D[(t^2 + u^2 - 1)/(2 t u), u] - (u^2 - t^2 + 1)/(2 t u^2)] == 0] &&
  reduceTrue[ForAll[{t, u}, 0 < u <= 1 && t > 1, (t^2 - u^2 + 1)/(2 t^2 u) > 0]] &&
  reduceTrue[ForAll[{t, u}, u > 0 && t > 1 && u^2 < t^2 - 1, (u^2 - t^2 + 1)/(2 t u^2) < 0]]];
ineq["M80", "Lemma 4.2", "sqrt(t^2-1) > 0.42 >= 0.3683 for t >= 1.36; and A(1.36,0.3683) defined (1.36-0.3683 <= 1)", {vv["sqrt(1.36^2-1)", Sqrt[ivr[q["1.36"]^2 - 1]]]},
  q["1.36"]^2 - 1 > q["0.42"]^2 && q["0.42"] >= q["0.3683"] && q["1.36"] - q["0.3683"] <= 1];
val["M81", "Lemma 4.2", "1.36^2 + 0.3683^2 - 1", toI[q["1.36"]^2 + q["0.3683"]^2 - 1], "0.98524889"];
val["M82", "Lemma 4.2", "2*1.36*0.3683", toI[2 q["1.36"] q["0.3683"]], "1.001776"];
val["M83", "Lemma 4.2", "ratio", toI[(q["1.36"]^2 + q["0.3683"]^2 - 1)/(2 q["1.36"] q["0.3683"])], "0.98350"];
ineq["M84", "Lemma 4.2", "A(1.36, 0.3683) < 0.183", {vv["A(1.36,0.3683)", AI[q["1.36"], q["0.3683"]]]}, LT[AI[q["1.36"], q["0.3683"]], q["0.183"]]];
val["M85", "Lemma 4.2", "6a - B - 2*0.53374", 6 aI - BI - q["1.06748"], "1.1505"];
ineq["M86", "Lemma 4.2", "2*0.183 < 6a - B - 2*0.53374 (contradiction)", {vv["6a-B-1.06748", 6 aI - BI - q["1.06748"]]}, LT[2 q["0.183"], 6 aI - BI - q["1.06748"]]];
val["M87", "Section 4 (NEAR-Y)", "2 C(4 - R)", 2 CI[4 - Rx], "0.0800"];
ineq["M88", "Lemma 4.1(S) proof", "D >= 2.70963 - 2.34466 > 0 (true: 10a - B - 2*0.53374 - 2r(1.085) > 0)", {vv["diff", 10 aI - BI - q["1.06748"] - 2 rI[q["1.085"]]]},
  GT[10 aI - BI - q["1.06748"] - 2 rI[q["1.085"]], 0] && q["2.70963"] > q["2.34466"]];
ineq["M89", "Section 4 Addendum (remark, not load-bearing)", "three corners at radius <= 1.38 cost more than B: 3 C(1.38) > B", {vv["3C(1.38)", 3 CI[q["1.38"]]]}, GT[3 CI[q["1.38"]], BI]];
ineq["M90", "Repair M1", "1 + rho_0 = R - 1 (exact)", {"exact"}, 1 + (Rx - 2) == Rx - 1];
(* Repair M2 *)
ineq["M91", "Repair M2", "r(1.085) < 1.1724 (every A(t,.) <= r(t) <= r(1.085) for t > 1.085)", {vv["r(1.085)", rI[q["1.085"]]]}, LT[rI[q["1.085"]], q["1.1724"]]];
ineq["M92", "Repair M2", "6a < 2.3387, 2.3387 + 1.1724 = 3.5111, 2pi - 1.1724 > 3.5111, -2pi + 1.1724 < -1.1724", {vv["6a", 6 aI], vv["2pi-1.1724", 2 PI - q["1.1724"]]},
  LT[6 aI, q["2.3387"]] && q["2.3387"] + q["1.1724"] == q["3.5111"] && GT[2 PI - q["1.1724"], q["3.5111"]] && LT[q["1.1724"] - 2 PI, -q["1.1724"]]];
val["M93", "Repair M2", "2pi - 1.1724", 2 PI - q["1.1724"], "5.111"];
ineq["M94", "Repair M2 (Y side)", "4a < 1.5592, -1.5592 - 1.1724 >= -2.732, 2pi - 1.1724 > 1.1724, -2pi + 1.1724 < -2.732", {vv["4a", 4 aI]},
  LT[4 aI, q["1.5592"]] && -q["1.5592"] - q["1.1724"] >= -q["2.732"] && GT[2 PI - q["1.1724"], q["1.1724"]] && LT[q["1.1724"] - 2 PI, -q["2.732"]]];
(* Repair M3 *)
val["M95", "Repair M3", "sqrt(1.085^2 - 1)", Sqrt[ivr[q["1.085"]^2 - 1]], "0.420981"];
val["M96", "Repair M3", "r(1.085) = pi/2 - arctan(0.420981...)", PI/2 - ArcTan[Sqrt[ivr[q["1.085"]^2 - 1]]], "1.172334"];
val["M97", "Repair M3", "2 r(1.085)", 2 rI[q["1.085"]], "2.34467"];
ineq["M98", "Repair M3", "r(1.085) = pi/2 - arctan(sqrt(1.085^2-1)) (identity)", {"exact"},
  TrueQ[FullSimplify[ArcSin[1/q["1.085"]] == Pi/2 - ArcTan[Sqrt[q["1.085"]^2 - 1]]]]];
(* where the false remark M89 would become true: 3 C(t) = B *)
Module[{tq = t /. FindRoot[3 (2 ArcSin[1/Rx] - 2 ArcTan[Sqrt[4 - (Rx - t)^2]/(Rx + t)]) == 12 ArcSin[1/Rx] - 2 Pi + 2 ArcSin[2/Rx], {t, 1.36}, WorkingPrecision -> 30]},
  Print["   info (not a claim): 3 C(t) = B at t = ", ToString[NumberForm[tq, 10]], "; 3 C(4-R) = ", v12[3 CI[4 - Rx]], " vs B = ", v12[BI]]];

(* ================= Part M section 5 (hand facts used in the soundness argument of C1) ================= *)
ineq["S01", "Section 5 soundness (isqrt)", "4 - (R-t)^2 > 0 for 1 <= t <= R (Reduce)", {"Reduce"},
  reduceTrue[ForAll[t, 1 <= t <= Rx, 4 - (Rx - t)^2 > 0]]];
ineq["S02", "Section 5 soundness (isqrt)", "1 - R^2 sin^2 w >= 0 for 0 <= sin w <= sin a = 1/R (Reduce)", {"Reduce"},
  reduceTrue[ForAll[sv, 0 <= sv <= 1/Rx, 1 - Rx^2 sv^2 >= 0]]];
ineq["S03", "Section 5 soundness (C_lo, M_up)", "1 > R - 2; sqrt(rho^2+1) < rho + 1 for rho > 0 (Reduce)", {"Reduce"},
  1 > Rx - 2 && reduceTrue[ForAll[p, p > 0, Sqrt[p^2 + 1] < p + 1]]];

(* ================= Part W and section 11 (hand facts, not the computation C2) ================= *)
ineq["W01", "Part W (angle polytope)", "2pi < 7", {vv["2pi", 2 PI]}, LT[2 PI, 7]];
ineq["W02", "Lemma W step 1", "R-1 <= rho <= sqrt(R^2-1) => (R-rho)^2 <= 1; cos w >= sqrt(R^2-1)/R (AM-GM) (Reduce)", {"Reduce"},
  reduceTrue[ForAll[p, Rx - 1 <= p <= Sqrt[Rx^2 - 1], (Rx - p)^2 <= 1 && (Rx^2 + p^2 - 1)/(2 Rx p) >= Sqrt[Rx^2 - 1]/Rx]]];
ineq["W03", "Corollary W1 / half-plane lemma", "box width 3/2 < pi/2", {vv["pi/2", PI/2]}, LT[3/2, PI/2]];
ineq["W04", "Lemma M35", "rho_max <= 2.45, R < 2.64, 2.45+1 = 3.45 <= 7/2, 1+1 = 2, 2+1 = 3 <= 7/2", {vv["rho_max", Sqrt[RI^2 - 1]]},
  LE[Sqrt[RI^2 - 1], q["2.45"]] && Rx < q["2.64"] && q["2.45"] + 1 <= 7/2 && 3 <= 7/2];
ineq["W05", "Lemma M35 (RHO used by C2)", "RHO = sqrt_up(R^2-1) (K = 2^64) <= 2.45", {"exact"},
  Module[{K = 2^64, num = Numerator[Rx^2 - 1], den = Denominator[Rx^2 - 1], rho},
    rho = (Floor[Sqrt[num den K^2]] + 1)/(den K); rho >= Sqrt[Rx^2 - 1] && rho <= q["2.45"]]];
ineq["W06", "Section 11.1 (sincos)", "Lagrange remainder 8^80/80! ~ 1e-47 (in [1e-47, 1e-46]); root box [0,7] and 2pi within [0,8]", {"8^80/80!=" <> v12[8^80/80!]},
  10^-47 <= 8^80/80! <= 10^-46 && LT[2 PI, 8]];
ineq["W07", "Section 11.2 (count arithmetic)", "3272+824 = 4096; 4900 = 4096+2*402, 3272+1226 = 4498 = 4096+402; 5384 = 4096+2*644, 3272+1468 = 4740 = 4096+644", {"exact"},
  3272 + 824 == 4096 && 4900 == 4096 + 2 402 && 3272 + 1226 == 4498 == 4096 + 402 && 5384 == 4096 + 2 644 && 3272 + 1468 == 4740 == 4096 + 644];

(* ================= meta-claims ================= *)
ineq["X01", "Part A header (meta)", "every load-bearing numeric inequality of Part A has margin >= 0.06 (2pi-10a-2d, 2pi-4d-6a)",
  {vv["2pi-10a-2d", 2 PI - 10 aI - 2 dI], vv["2pi-4d-6a", 2 PI - 4 dI - 6 aI]},
  GE[2 PI - 10 aI - 2 dI, 6/100] && GE[2 PI - 4 dI - 6 aI, 6/100]];
Module[{mg = {{"C(1.085)-B (L1.3)", CI[q["1.085"]] - BI}, {"C(1.2)+C(1.35)-B (L2.2)", CI[q["1.2"]] + CI[q["1.35"]] - BI},
     {"8a-B-2.96225 (L2.2)", 8 aI - BI - q["2.96225"]}, {"10a-B-1.06748-2r(1.085) (L2.1)", 10 aI - BI - q["1.06748"] - 2 rI[q["1.085"]]},
     {"C(1.36)-(B-2C(1.3683)) (L4.2)", CI[q["1.36"]] - BI + 2 CI[q["1.3683"]]}, {"C(1.36)-0.040664 (L4.2 as written)", CI[q["1.36"]] - q["0.040664"]},
     {"6a-B-1.06748-0.366 (L4.2)", 6 aI - BI - q["1.06748"] - q["0.366"]}, {"G2-4 (L3.1)", q["1.9656"]^2 + (RI - 1)^2 - 2 (RI - 1) q["1.9656"] Cos[PI - 5 aI + q["0.03"]] - 4},
     {"2pi-10a-2r(1.085) (M2)", 2 PI - 10 aI - 2 rI[q["1.085"]]}, {"rho_lo sin(2a-B)-1 (E3.2)", q["1.9656"] Sin[2 aI - BI] - 1}}},
  ineq["X02", "Section 13 (meta)", "every hand inequality has margin >= 1e-3 (tightest claimed: C(1.085)-B = 0.00135)",
    (#[[1]] <> "=" <> v12[#[[2]]]) & /@ mg, And @@ (GE[#[[2]], 10^-3] & /@ mg)]];

(* ================= V: the corrected text =================
   proof.md was corrected after the first run of this certificate (2026-10-21; every slip listed in
   `conseq` below).  The claims above are kept AS ORIGINALLY WRITTEN, as an audit trail; the claims
   below are the replacement statements now in proof.md, and every one of them must be True. *)
vIds0 = Length[results];
val["A03v", "Lemma A4(1) (corrected)", "12a - 2pi + 2d = B", BI, "0.1206621"];
Module[{b = 2 RI Cos[PI - 6 aI], disc},
  disc = Sqrt[b^2 - 4 (RI^2 - 4)];
  val["A15v", "Lemma A4(2) (corrected)", "2R cos(pi-6a)", b, "3.655974"];
  val["A16v", "Lemma A4(2) (corrected)", "sqrt((2R cos)^2 - 4(R^2-4))", disc, "1.289483"]];
val["A18v", "Lemma A4(3) / N3 (corrected, twice)", "4d", 4 dI, "3.453037"];
val["A20v", "Lemma A4(3) / N3 (corrected, twice)", "4d + 6a", 4 dI + 6 aI, "5.791702"];
With[{w = aI - BI/2},
  val["E09v", "Lemma E3.1 (corrected)", "cos w", Cos[w], "0.9462216"];
  val["E10v", "Lemma E3.1 (corrected)", "R cos w", RI Cos[w], "2.4901714"];
  val["E11v", "Lemma E3.1 (corrected)", "1 - R^2 sin^2 w", 1 - RI^2 Sin[w]^2, "0.2751088"]];
ineq["E15v", "Lemma E3.1 (corrected)", "2a - B >= 0.6588926 (printed truncated, '0.6588926...')", {vv["2a-B", 2 aI - BI]}, GE[2 aI - BI, q["0.6588926"]]];
Module[{ts = {"1.085", "1.1", "1.15", "1.2", "1.25", "1.3", "1.35", "1.45"},
    rs = {"1.172335", "1.141097", "1.054321", "0.985111", "0.927295", "0.877636", "0.834172", "0.761013"},
    ms = {"0.32592", "0.34220", "", "0.42201", "0.44940", "0.47122", "0.48863", ""}},
  Do[With[{t0 = q[ts[[i]]]},
     val["M19v." <> ToString[i], "Section 2 table (corrected)", "r(" <> ts[[i]] <> ")", rI[t0], rs[[i]]];
     If[ms[[i]] =!= "", val["M20v." <> ToString[i], "Section 2 table (corrected)", "m0(" <> ts[[i]] <> ") = A(t,1.9656)", m0I[t0], ms[[i]]]]],
    {i, Length[ts]}]];
ineq["M20v.7u", "Section 2 table (corrected)", "m0(1.35) <= 0.48863 (upper bound)", {vv["m0(1.35)", m0I[q["1.35"]]]}, LE[m0I[q["1.35"]], q["0.48863"]]];
ineq["M35v", "Lemma 2.2 (corrected)", "r(1.2) + m0(1.35) <= 1.47374", {vv["r(1.2)+m0(1.35)", rI[q["1.2"]] + m0I[q["1.35"]]]}, LE[rI[q["1.2"]] + m0I[q["1.35"]], q["1.47374"]]];
ineq["M39v", "Lemma 2.2 (corrected)", "r(1.35) + 0.53374 <= 1.367913", {vv["r(1.35)+0.53374", rI[q["1.35"]] + q["0.53374"]]}, LE[rI[q["1.35"]] + q["0.53374"], q["1.367913"]]];
val["M40v", "Lemma 2.2 (corrected)", "C(1.2) + C(1.35)", CI[q["1.2"]] + CI[q["1.35"]], "0.124052"];
ineq["M42v", "Lemma 2.2 (corrected)", "max(1.59434 + 1.367913, 2*1.47374) = 2.962253 < 8a - B = 2.997557",
  {vv["8a-B-2.962253", 8 aI - BI - q["2.962253"]]},
  Max[q["1.59434"] + q["1.367913"], 2 q["1.47374"]] == q["2.962253"] && LT[toI[q["2.962253"]], 8 aI - BI]];
val["M50v", "Lemma 3.1(c) (corrected)", "B/2", BI/2, "0.0603311"];
val["M56v", "Lemma 3.1(d) case 1 (corrected)", "rho(0.03)", rhoD[q["0.03"]], "2.0869896"];
ineq["M57v", "Lemma 3.1(d) case 1 (corrected)", "cos(pi - 5a) <= 0.369147", {vv["cos(pi-5a)", Cos[PI - 5 aI]]}, LE[Cos[PI - 5 aI], q["0.369147"]]];
ineq["M58v", "Lemma 3.1(d) case 1 (corrected)", "rho(0.03)^2 >= 4.355525 (lower bound used in G)", {vv["rho(0.03)^2", rhoD[q["0.03"]]^2]}, GE[rhoD[q["0.03"]]^2, q["4.355525"]]];
ineq["M60v", "Lemma 3.1(d) case 1 (corrected)", "2*1.6317*rho(0.03) <= 6.810682 (upper bound used in G)", {vv["2*1.6317*rho(0.03)", 2 q["1.6317"] rhoD[q["0.03"]]]}, LE[2 q["1.6317"] rhoD[q["0.03"]], q["6.810682"]]];
val["M61v", "Lemma 3.1(d) case 1 (corrected)", "4.355525 + 2.662445 - 6.810682*0.369147", toI[q["4.355525"] + q["2.662445"] - q["6.810682"] q["0.369147"]], "4.5038"];
ineq["M63v", "Lemma 3.1(d) case 2 (corrected)", "cos(pi - 5a + 0.03) <= 0.341104", {vv["cos(pi-5a+0.03)", Cos[PI - 5 aI + q["0.03"]]]}, LE[Cos[PI - 5 aI + q["0.03"]], q["0.341104"]]];
val["M65v", "Lemma 3.1(d) case 2 (corrected)", "2*1.6317*1.9656", toI[2 q["1.6317"] q["1.9656"]], "6.414539"];
val["M66v", "Lemma 3.1(d) case 2 (corrected)", "3.863583 + 2.662445 - 6.414539*0.341104", toI[q["3.863583"] + q["2.662445"] - q["6.414539"] q["0.341104"]], "4.3380"];
val["M72v", "Lemma 4.2 (corrected)", "2 arctan z(1.3683)", gsymI[q["1.3683"]], "0.7395537"];
val["M72v.C", "Lemma 4.2 (corrected)", "C(1.3683)", CI[q["1.3683"]], "0.0400011"];
ineq["M75v", "Lemma 4.2 (corrected)", "B - 2C(1.3683) <= B - 2*0.039999 <= 0.0406642", {vv["B-0.079998", BI - 2 q["0.039999"]]},
  GE[CI[q["1.3683"]], q["0.039999"]] && LE[BI - 2 q["0.039999"], q["0.0406642"]]];
val["M76v", "Lemma 4.2 (corrected)", "arctan z(1.36)", ArcTan[zI[q["1.36"]]], "0.3689962"];
val["M77v", "Lemma 4.2 (corrected)", "C(1.36)", CI[q["1.36"]], "0.0415625"];
ineq["M77v.g", "Lemma 4.2 (corrected)", "C(1.36) > 0.0406642, margin >= 8.9e-4", {vv["C(1.36)-0.0406642", CI[q["1.36"]] - q["0.0406642"]]},
  GE[CI[q["1.36"]] - q["0.0406642"], q["0.00089"]]];
val["M81v", "Lemma 4.2 (corrected)", "1.36^2 + 0.3683^2 - 1", toI[q["1.36"]^2 + q["0.3683"]^2 - 1], "0.98524489"];
val["M89v", "Section 4 Addendum (corrected remark)", "C(4 - R)", CI[4 - Rx], "0.0400"];
Module[{mg = {{"C(1.085)-B (L1.3)", CI[q["1.085"]] - BI}, {"C(1.2)+C(1.35)-B (L2.2)", CI[q["1.2"]] + CI[q["1.35"]] - BI},
     {"8a-B-2.962253 (L2.2)", 8 aI - BI - q["2.962253"]}, {"10a-B-1.06748-2r(1.085) (L2.1)", 10 aI - BI - q["1.06748"] - 2 rI[q["1.085"]]},
     {"C(1.36)-(B-2C(1.3683)) (L4.2)", CI[q["1.36"]] - BI + 2 CI[q["1.3683"]]}, {"C(1.36)-0.0406642 (L4.2)", CI[q["1.36"]] - q["0.0406642"]},
     {"6a-B-1.06748-0.366 (L4.2)", 6 aI - BI - q["1.06748"] - q["0.366"]}, {"G2-4 (L3.1)", q["1.9656"]^2 + (RI - 1)^2 - 2 (RI - 1) q["1.9656"] Cos[PI - 5 aI + q["0.03"]] - 4},
     {"2pi-10a-2r(1.085) (M2)", 2 PI - 10 aI - 2 rI[q["1.085"]]}, {"rho_lo sin(2a-B)-1 (E3.2)", q["1.9656"] Sin[2 aI - BI] - 1}}},
  ineq["X02v", "Section 13 (meta, corrected)", "every hand inequality has margin >= 8e-4 (tightest: L4.2 0.00089, L1.3 0.00135)",
    (#[[1]] <> "=" <> v12[#[[2]]]) & /@ mg, And @@ (GE[#[[2]], 8/10^4] & /@ mg)]];
vRes = Drop[results, vIds0];

(* ================= summary ================= *)
(* For each claim that may come out False: where the corrected / downstream statement is checked (by id). *)
conseq = <|
  "A03" -> "typo (B = 0.1206621 > 0.12066); the only use, Sum d <= B/2 <= 0.0604, holds: A04",
  "A15" -> "not load-bearing; the stated range 1.1832 <= |q| <= 2.4728 holds with the true roots: A17",
  "A16" -> "not load-bearing; see A17",
  "A18" -> "printed 4d slightly off (true 3.4530373); 4d+6a < 2pi with margin 0.4915 holds: A21",
  "A20" -> "printed sum off (true 5.7917017); conclusion holds: A21",
  "E09" -> "last-digit slip; final rho(a-B/2) = 1.965663 is correct (E13) and rho_lo = 1.9656 valid (E14)",
  "E10" -> "last-digit slip (true 2.4901714); final rho value correct: E13, E14",
  "E11" -> "last-digit slip (true 0.2751088); final rho value correct: E13, E14",
  "E15" -> "last-digit slip (true 0.65889265); E3.2 inequality holds with true value: E19",
  "M20.1" -> "table entry unused (true 0.32592); only m0(1.2), m0(1.35) are used: M37, M38, M43",
  "M20.2" -> "table entry unused (true 0.34220); see M37, M38, M43",
  "M20.5" -> "table entry unused (true 0.44940); see M37, M38, M43",
  "M19.6" -> "table entry unused (true 0.877636); no lemma uses r(1.3)",
  "M20.6" -> "table entry unused (true 0.47122); see M37, M38, M43",
  "M20.7" -> "m0(1.35) printed 0.48865 >= true 0.488622 (safe upper bound); M38 and M43 hold",
  "M35" -> "printed 1.47376 >= true 1.473733 (safe upper bound): M38, M42, M43",
  "M39" -> "r(1.35)+0.53374 = 1.3679123 > 1.36791 by 2.3e-6; with the sharper valid bound arcsin(1/1.9656) it holds (M39c), and Lemma 2.2 holds with true bounds (M43)",
  "M40" -> "printed sum off by 1.7e-6 (true 0.1240523); C(1.2)+C(1.35) > B holds: M41",
  "M48" -> "pi-8a = 0.02337345 < 0.023374 by 5.5e-7; corrected M48c holds; this bound is not used afterwards",
  "M50" -> "B/2 = 0.06033107 > 0.060331, so the case split [0,0.03] u [0.03,0.060331] misses (0.060331, B/2]; case 2 holds on the whole [0.03, B/2]: M67",
  "M56" -> "rho(0.03) printed 2.086994 > true 2.0869896 (not a lower bound); case 1 holds with the true value: M62 (G1 = 4.5038)",
  "M58" -> "follows M56; see M62",
  "M60" -> "follows M56; see M62",
  "M65" -> "arithmetic slip (true 6.41453904); case 2 holds: M67 (G2 = 4.3380)",
  "M72" -> "printed 0.739555 vs true 0.7395537; C(1.3683) >= 0.039999 holds: M73",
  "M75" -> "B - 0.079998 = 0.04066415 > 0.040664; the step holds in rigorous form C(1.36) > B - 2C(1.3683): M78 (margin 9.0e-4)",
  "M81" -> "typo 0.98524889 for 0.98524489; ratio and A(1.36,0.3683) < 0.183 hold: M83, M84",
  "M89" -> "explanatory remark, not load-bearing: 3C(t) = B only at t = 1.3671 < 1.38 (even 3C(4-R) = 0.12000 < B); (Q2) itself is proved and used only inside C1",
  "X02" -> "Lemma 4.2's step C(1.36) > B - 2C(1.3683) has margin 9.0e-4 < 1e-3 (still ~1e40 times the enclosure width)"|>;
Print[];
consIds = {"A04", "A17", "A21", "E13", "E14", "E19", "M37", "M38", "M39c", "M41", "M42", "M43", "M48c", "M62", "M67", "M73", "M78", "M83", "M84"};
Module[{st = Association[(#[[1]] -> #[[5]]) & /@ results]},
  Print["22a consequence checks (", StringRiffle[consIds, ","], "): ",
    If[And @@ (TrueQ[Lookup[st, #, False]] & /@ consIds), "ALL TRUE", "NOT ALL TRUE: " <> StringRiffle[Select[consIds, ! TrueQ[Lookup[st, #, False]] &], ","]]]];
Module[{bad = Select[results, ! #[[5]] &], nI = Count[results, {_, _, "INEQ", _, _}], nV = Count[results, {_, _, "VAL", _, _}],
    vBad = Select[vRes, ! #[[5]] &], undoc},
  Print["22a: ", Length[results], " claims checked (", nI, " INEQ, ", nV, " VAL); ", Length[results] - Length[bad], " True, ", Length[bad], " False."];
  If[bad =!= {},
    Print["22a FALSE CLAIMS OF THE ORIGINAL TEXT (id | location | kind | claim  ==> consequence):"];
    Scan[Print["  ", #[[1]], " | ", #[[2]], " | ", #[[3]], " | ", #[[4]], "\n      ==> ", Lookup[conseq, #[[1]], "NO CONSEQUENCE ANALYSIS RECORDED"]] &, bad]];
  undoc = Select[bad[[All, 1]], ! KeyExistsQ[conseq, #] &];
  Print["22a corrected-text claims (section V): ", Length[vRes], ", False: ", vBad[[All, 1]], ";  undocumented false claims: ", undoc];
  If[vBad === {} && undoc === {},
    Print["22a ALL HAND CONSTANTS VERIFIED (corrected text; every original slip documented)"]; Exit[0],
    Print["22a FAILED"]; Exit[1]]];
