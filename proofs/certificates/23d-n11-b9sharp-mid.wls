#!/usr/bin/env wolframscript
(* ::Package:: *)
(* 23d-n11-b9sharp-mid.wls -- independent second implementation (Wolfram Language) of
   the certificate of Theorem MID(7/1000) and of the reference checks A0-A7 of Theorem A'
   (experiments/2026-10-21-siege-n11-b9-sharp/out/proof.md, Appendix D).

   CLAIM certified.  With zbar = F5 decimals (problem.md), rho_A = 7/1000:
     (A0)    lower end of I_* exceeds Rbar by >= 1.50116e-21 (so R >= R_* => R > Rbar);
     (A1-A7) the reference margins of Theorem A' at zbar, plus the numeric constants used in
             the hand proof of Theorem A' (0)-(5);
     (MID)   for the lifted quadratic problem (58 unknowns, 36 equalities, 18 inequalities)
             at a rational base point xbar, with rational multipliers lambda>0, nu, theta, mu:
             (i) all lambda_i > 0, (ii) G - kappa I positive definite (exact), (iii)
             tau = (|rhat| + sqrt(|rhat|^2 + 2 kappa eps1^+))/kappa <= 2e-6.
           By Lemma Q + Theorem MID every covering of the claim's type with R >= R_* and
           z in B(7/1000) has ||z - zbar||_inf <= |h|_2 < tau.
     Two admissible data choices are certified: run A (theta=7/10, mu_eq=3/10, corner base points
     as in the text, eta_p = 1e-30|dbar|) and run B (theta=3/4, mu_eq=1/2, own 1e-40 base points with
     a rigorously bounded eta, multipliers rounded to 1e-12, i.e. |rhat| ~ 1e-11).

   METHOD.  Written from the mathematical statements of Appendix D, not from mid_cert.py.
     * Constraints are built as polynomials in 58 displacement symbols; J_k and H_k are obtained by
       symbolic differentiation; the exact second-order identity for every c_k and for the
       Lagrangian L is checked by Expand (proof-grade, degree-2 polynomials).
     * All load-bearing inequalities: exact rationals.  Square roots: rational a,b with a^2<=x<=b^2
       checked exactly.  Corners at zbar: exact-rational Interval enclosures (no rounding).
     * G >= kappa I: exact rational LDL^T (Schur complements) of G - kappa I, all 58 pivots > 0.
     * Transcendental constants of the hand proof: Interval at precision 60 (bignum, outward
       rounded); endpoints converted with SetPrecision[., Infinity] and compared exactly.
     * Floats (precision 40-80) only choose multipliers and kappa.
   NEGATIVE CONTROLS (must FAIL): rho = 5/100; kappa = 1.02 lambda_min; one multiplier perturbed by
     1e-3 relative; one multiplier sign-flipped; tightened A-thresholds.
   TRUST BASE.  Mathematica 14.3 exact rational arithmetic, Expand/D on polynomials, Interval
     arithmetic at precision 60; the F5 decimals and I_* as stated in problem.md (I_* from
     certificate 07); F3 and F6' are used by the proof but not checked here.
   USAGE.  ~/Wolfram/Mathematica/14.3/Executables/wolframscript -file \
             proofs/certificates/23d-n11-b9sharp-mid.wls
           exit 0 and last line "23d MID VERIFIED" iff every check passes (about a minute). *)

$HistoryLength = 0;
t0 = AbsoluteTime[];
fails = {}; npass = 0;
fmt[x_] := Module[{v = N[x, 12], e}, If[v == 0, "0", e = Floor[Log10[Abs[v]]];
   If[-3 <= e <= 3, ToString[NumberForm[v, 7]], ToString[NumberForm[v/10^e, 7]] <> "e" <> ToString[e]]]];
report[name_, ok_, info_: ""] := (If[TrueQ[ok], npass++; Print["[PASS] ", name, If[info === "", "", "   " <> info]],
     AppendTo[fails, name]; Print["[FAIL] ", name, If[info === "", "", "   " <> info]]]; TrueQ[ok]);
negctl[name_, okval_, info_: ""] := report["NEG " <> name <> " -- control must fail", ! TrueQ[okval], info];
say[s__] := Print["      ", s];

(* ---------- exact decimals ---------- *)
dec[s0_String] := Module[{t = StringTrim[s0], sg = 1, ip, fp},
  If[StringStartsQ[t, "-"], sg = -1; t = StringDrop[t, 1]];
  {ip, fp} = If[StringContainsQ[t, "."], StringSplit[t, ".", All], {t, ""}];
  sg (FromDigits[ip] + If[fp === "", 0, FromDigits[fp]/10^StringLength[fp]])];

(* ---------- rigorous rational square roots ---------- *)
sLo[x_?NonNegative, p_Integer] := Module[{a = Floor[Sqrt[x] 10^p]/10^p},
  While[a^2 > x, a -= 10^-p]; If[! (a >= 0 && a^2 <= x), Throw["sLo"]]; a];
sHi[x_?NonNegative, p_Integer] := Module[{b = Ceiling[Sqrt[x] 10^p]/10^p},
  While[b^2 < x, b += 10^-p]; If[! (b^2 >= x), Throw["sHi"]]; b];
sqrtI[x_, p_] := If[Head[x] === Interval, Interval[{sLo[Min[x], p], sHi[Max[x], p]}],
   Interval[{sLo[x, p], sHi[x, p]}]];
up[x_, n_] := Ceiling[x 10^n]/10^n; dn[x_, n_] := Floor[x 10^n]/10^n;
n2[v_] := v[[1]]^2 + v[[2]]^2;
cross[a_, b_] := a[[1]] b[[2]] - a[[2]] b[[1]];
jrot[d_] := {-d[[2]], d[[1]]};
lo[x_] := Min[x]; hi[x_] := Max[x];

(* ---------- F5 data, transcribed from out/problem.md ---------- *)
cc = <||>;
cc[1] = {0, dec["-0.39324960179250027086"]}; cc[2] = {0, dec["0.71839227931685877597"]};
cc[3] = {0, dec["2.34884120097565953729"]};
cc[4] = {dec["1.57535264004342806580"], dec["1.62062588642691912838"]};
cc[6] = {dec["1.77273616280974093118"], dec["-0.93632239910290244643"]};
cc[8] = {dec["1.82750955295212993964"], dec["0.24958048504283922431"]};
cc[10] = {dec["0.78521708246826346764"], dec["-2.01247018720615423819"]};
Do[cc[k + 1] = {-cc[k][[1]], cc[k][[2]]}, {k, {4, 6, 8, 10}}];
Rbar = dec["2.63169077261980820552"];
IstarLo = dec["2.6316907726198082055215011595056961051671168478238"];
IstarHi = dec["2.6316907726198082055215011595056961051671168478239"];

Bord = {8, 4, 3, 5, 9, 7, 11, 10, 6};
pairs = Table[{Bord[[j]], Bord[[Mod[j, 9] + 1]]}, {j, 9}];
tight = <|1 -> 2, 2 -> 2, 3 -> 2, 4 -> 2, 5 -> 1, 7 -> 1, 9 -> 1|>;

Print["==== 23d: independent WL check of Appendix D (Theorem A', Lemma Q, Theorem MID) ===="];
(* evidence only: F5 decimals vs the 60-digit KKT point in data/configs/11/20261008-melissen-kkt.json *)
Module[{js = Quiet@Check[Import[FileNameJoin[{DirectoryName[ExpandFileName[$InputFileName]],
        "..", "..", "data", "configs", "11", "20261008-melissen-kkt.json"}], "RawJSON"], $Failed], dmax},
  If[AssociationQ[js],
   dmax = Max[Abs[Flatten[Table[Map[dec, js["centers"][[k]]] - cc[k], {k, 11}]]],
     Abs[dec[js["R"]] - Rbar]];
   say["info (evidence, not proof): max |F5 decimal - 60-digit KKT json| = ", fmt[dmax], " (F5 says <= 1e-20)"],
   say["info: json not found, skipped"]]];

(* ======================= Part A ======================= *)
Print["==== Part A: A0 and the reference checks of Theorem A' ===="];
report["A0  R_* - Rbar >= IstarLo - Rbar >= 1.5011595e-21 > 1e-22 (R >= R_* => R > Rbar)",
  IstarLo - Rbar >= 15011595/10^28 > 10^-22 && IstarLo <= IstarHi, "IstarLo-Rbar = " <> fmt[IstarLo - Rbar]];
say["note: IstarLo - Rbar = 1.50115959...e-21 < 1.50116e-21 (the rounded value quoted in the brief/log is rounded UP; only > 0 is used)"];
report["A1a |c1| <= 0.40", n2[cc[1]] <= (40/100)^2];
report["A1b |c2| <= 0.72", n2[cc[2]] <= (72/100)^2];
report["A1c 1.84 <= |c_k| <= 2.35, k=3..11", And @@ Table[(184/100)^2 <= n2[cc[k]] <= (235/100)^2, {k, 3, 11}],
  "min/max |c_k| = " <> fmt[Min[Table[Sqrt[N[n2[cc[k]], 30]], {k, 3, 11}]]] <> "/" <> fmt[Max[Table[Sqrt[N[n2[cc[k]], 30]], {k, 3, 11}]]]];
Do[Module[{a = cc[pr[[1]]], b = cc[pr[[2]]], cr, dt, nn},
   cr = cross[a, b]; dt = a . b; nn = n2[a] n2[b];
   report["A2  pair " <> ToString[pr] <> ": cross >= 0.57|a||b|, dot >= 0.18|a||b|",
    cr > 0 && cr^2 >= (57/100)^2 nn && dt > 0 && dt^2 >= (18/100)^2 nn,
    "step angle = " <> fmt[ArcTan[N[dt, 30], N[cr, 30]]]]], {pr, pairs}];
d0 = 99/10000;
phi2[x_] := x^2 (1 - x^2/4);
Do[Module[{dI = sqrtI[n2[cc[pr[[2]]] - cc[pr[[1]]]], 40], xm, xp},
   xm = dI - 2 d0; xp = dI + 2 d0;
   report["A3  pair " <> ToString[pr] <> ": 0<x-, x+<2, phi(x-/+) >= 0.80",
    lo[xm] > 0 && hi[xp] < 2 && lo[phi2[xm]] >= 64/100 && lo[phi2[xp]] >= 64/100,
    "phi_min ~ " <> fmt[Sqrt[N[Min[lo[phi2[xm]], lo[phi2[xp]]], 30]]]]], {pr, Append[pairs, {1, 2}]}];

(* exact reference corners p(zbar), enclosed in exact-rational Intervals *)
cornerI[a_, b_, kind_] := Module[{d = b - a, m = (a + b)/2, s2},
  s2 = 1/n2[d] - 1/4; If[! (s2 > 0), Throw["corner |d|>=2"]];
  m + If[kind === "P", -1, 1] sqrtI[s2, 60] jrot[d]];
QI = Table[cornerI[cc[pairs[[j, 1]]], cc[pairs[[j, 2]]], "Q"], {j, 9}];
PI = Table[cornerI[cc[pairs[[j, 1]]], cc[pairs[[j, 2]]], "P"], {j, 9}];
tpI = cornerI[cc[1], cc[2], "P"]; tmI = cornerI[cc[1], cc[2], "Q"];
Do[report["A4  |Q_" <> ToString[j] <> "| <= 1.70 (pair " <> ToString[pairs[[j]]] <> ")", hi[n2[QI[[j]]]] <= (170/100)^2,
   "|Q| ~ " <> fmt[Sqrt[N[hi[n2[QI[[j]]]], 30]]]], {j, 9}];
Do[Module[{X = tight[j], Y, others, dm},
   Y = 3 - X; others = Append[Complement[Bord, pairs[[j]]], Y];
   dm = Min[Table[lo[n2[QI[[j]] - cc[k]]], {k, others}]];
   report["A5  tight Q_" <> ToString[j] <> " (X=" <> ToString[X] <> "): dist >= 1.2 to c_k, k in " <> ToString[others],
    dm >= 144/100, "min dist ~ " <> fmt[Sqrt[N[dm, 30]]]]], {j, Keys[tight]}];
Do[Module[{T = tt[[1]], own = tt[[2]], nm = tt[[3]], dm},
   report["A6a |" <> nm <> "| <= 0.9", hi[n2[T]] <= 81/100, "|t| ~ " <> fmt[Sqrt[N[hi[n2[T]], 30]]]];
   dm = Min[Table[lo[n2[T - cc[k]]], {k, DeleteCases[Bord, own]}]];
   report["A6b " <> nm <> ": dist >= 1.2 to boundary c_k, k != " <> ToString[own], dm >= 144/100,
    "min dist ~ " <> fmt[Sqrt[N[dm, 30]]]]], {tt, {{tpI, 8, "t+"}, {tmI, 9, "t-"}}}];
farI[cv_] := cv (1 + 1/sqrtI[n2[cv], 40]);
Do[Module[{a = cc[pr[[1]]], b = cc[pr[[2]]], dm},
   dm = Min[lo[n2[farI[a] - b]], lo[n2[farI[b] - a]]];
   report["A7  far points, pair " <> ToString[pr] <> ": |F(a)-b|,|F(b)-a| >= 1.2", dm >= 144/100,
    "min ~ " <> fmt[Sqrt[N[dm, 30]]]]], {pr, pairs}];

(* tightness of the reference configuration (where it should be tight) *)
Module[{gO, gI, gT, inact},
  gO = Table[N[Sqrt[(lo[n2[PI[[j]]]] + hi[n2[PI[[j]]]])/2] - Rbar, 10], {j, 9}];
  gI = Table[N[Sqrt[hi[n2[QI[[j]] - cc[tight[j]]]]] - 1, 10], {j, Keys[tight]}];
  gT = {N[Sqrt[hi[n2[tpI - cc[8]]]] - 1, 10], N[Sqrt[hi[n2[tmI - cc[9]]]] - 1, 10]};
  inact = Table[Min[Table[N[Sqrt[hi[n2[QI[[j]] - cc[X]]]] - 1, 10], {X, {1, 2}}]], {j, {6, 8}}];
  say["tightness: max ||P_j|-Rbar| = ", fmt[Max[Abs[gO]]], ", max ||Q_j-c_X|-1| = ", fmt[Max[Abs[gI]]],
   ", max ||t-c|-1| = ", fmt[Max[Abs[gT]]]];
  report["TIGHT the 18 active functions vanish at zbar to < 1e-18", Max[Abs[Join[gO, gI, gT]]] < 10^-18];
  report["TIGHT inactive corners Q_6, Q_8 are strictly inside D(c1) or D(c2) (margin > 1e-3)", Max[inact] < -10^-3,
   "min_X |Q_j - c_X| - 1 = " <> ToString[fmt /@ inact]]];

(* numeric constants of the hand proof of Theorem A' (rho <= 7e-3) *)
sq2 = 141421357/10^8; rhoMax = 7/1000; delta = sq2 rhoMax;
bigI[e_] := Module[{v = N[e, 60]}, Interval[{SetPrecision[Min[v], Infinity], SetPrecision[Max[v], Infinity]}]];
report["K1  1.41421357^2 >= 2 and delta = 1.41421357*7e-3 <= 0.0099", sq2^2 >= 2 && delta <= d0, "delta = " <> fmt[delta]];
report["K2  (0): 0.40+1 <= 1.41, 0.72+1 <= 1.73 < Rbar", 140/100 <= 141/100 && 172/100 <= 173/100 < Rbar];
report["K3  (1): sin 0.606 < 0.57, cos 1.391 < 0.18, 9*1.391 <= 12.52 < 4 Pi, 9*0.606 > 0",
  hi[bigI[Sin[Interval[{606/1000, 606/1000}]]]] < 57/100 && hi[bigI[Cos[Interval[{1391/1000, 1391/1000}]]]] < 18/100 &&
   9*1391/1000 <= 1252/100 < lo[bigI[4 Pi]]];
report["K4  (1): arcsin(delta0/(1.84-delta0)) < 0.006; perturbed steps stay in (0, pi/2)",
  hi[bigI[ArcSin[Interval[{d0/(184/100 - d0), d0/(184/100 - d0)}]]]] < 6/1000 &&
   606/1000 - 12/1000 > 0 && 1391/1000 + 12/1000 < lo[bigI[Pi/2]]];
report["K5  (2): 2 d0/0.80 <= 0.0248, 1.70+0.0248 < 1.725 < Rbar", 2 d0/(80/100) <= 248/10000 && 170/100 + 248/10000 < 1725/1000 < Rbar];
report["K6  (3): (1+1/1.83) < 1.55, 1.2 - 2.55 d0 > 1", 1 + 100/183 < 155/100 && 12/10 - 255/100 d0 > 1];
report["K7  (4),(5): 2.5 d0 + d0 < 0.035, 1.2-0.035 > 1, 0.9+0.0248 <= 0.93 < Rbar",
  25/10 d0 + d0 < 35/1000 && 12/10 - 35/1000 > 1 && 9/10 + 248/10000 <= 93/100 < Rbar];

(* ======================= Part B: lifted problem ======================= *)
Print["==== Part B: lifted quadratic problem ===="];
vars = {}; newv[nm_] := (AppendTo[vars, nm]; Length[vars]);
pt = <||>;
Do[pt["c" <> ToString[k]] = If[k == 3, {0, newv["y3"]}, {newv["x" <> ToString[k]], newv["y" <> ToString[k]]}], {k, 11}];
iR = newv["R"];
cornerDefs = Join[
   Table[{"P" <> ToString[j], "c" <> ToString[pairs[[j, 1]]], "c" <> ToString[pairs[[j, 2]]], "P"}, {j, 9}],
   Table[{"Q" <> ToString[j], "c" <> ToString[pairs[[j, 1]]], "c" <> ToString[pairs[[j, 2]]], "Q"}, {j, Keys[tight]}],
   {{"tp", "c1", "c2", "P"}, {"tm", "c1", "c2", "Q"}}];
Do[pt[cd[[1]]] = {newv[cd[[1]] <> ".x"], newv[cd[[1]] <> ".y"]}, {cd, cornerDefs}];
nv = Length[vars];
report["B0  58 unknowns", nv == 58];
cons = Join[
   Flatten[Table[{<|"t" -> "d", "X" -> cd[[1]], "Y" -> cd[[2]], "s" -> 1, "eq" -> True|>,
      <|"t" -> "d", "X" -> cd[[1]], "Y" -> cd[[3]], "s" -> 1, "eq" -> True|>}, {cd, cornerDefs}], 1],
   Table[<|"t" -> "o", "P" -> "P" <> ToString[j], "eq" -> False|>, {j, 9}],
   Table[<|"t" -> "d", "X" -> "Q" <> ToString[j], "Y" -> "c" <> ToString[tight[j]], "s" -> -1, "eq" -> False|>, {j, Keys[tight]}],
   {<|"t" -> "d", "X" -> "tp", "Y" -> "c8", "s" -> -1, "eq" -> False|>,
    <|"t" -> "d", "X" -> "tm", "Y" -> "c9", "s" -> -1, "eq" -> False|>}];
nc = Length[cons]; ineq = Select[Range[nc], ! cons[[#, "eq"]] &];
report["B1  54 constraints = 36 equalities + 18 inequalities", nc == 54 && Length[ineq] == 18];
hv = Array[hh, nv];
disp[nm_] := Map[If[# > 0, hh[#], 0] &, pt[nm]];

(* the lifted problem at a base point; scheme "text": pbar = m -/+ slo J d, slo = sigma truncated at 1e-30,
   eta = 1e-30 sHi(|d|); scheme "own": pbar = exact corner rounded to the 1e-40 grid, eta = rigorous bound *)
setupBase[scheme_] := Module[{},
  val = <||>; eta = <||>;
  Do[val["c" <> ToString[k]] = cc[k]; eta["c" <> ToString[k]] = 0, {k, 11}];
  Do[Module[{a = val[cd[[2]]], b = val[cd[[3]]], d, m, s2, sg, slo, pb, exI, e2},
     d = b - a; m = (a + b)/2; s2 = 1/n2[d] - 1/4; sg = If[cd[[4]] === "P", -1, 1];
     exI = m + sg sqrtI[s2, 70] jrot[d];                       (* exact corner enclosure *)
     Switch[scheme,
      "text", slo = sLo[s2, 30]; If[! (slo^2 <= s2 <= (slo + 10^-30)^2), Throw["slo"]];
       pb = m + sg slo jrot[d]; eta[cd[[1]]] = 10^-30 sHi[n2[d], 10],
      "own", pb = Round[N[m + sg Sqrt[s2] jrot[d], 80] 10^40]/10^40; eta[cd[[1]]] = sHi[hi[n2[exI - pb]], 60]];
     e2 = hi[n2[exI - pb]];
     If[! (e2 <= eta[cd[[1]]]^2), AppendTo[etaBad, cd[[1]]]];       (* |p(zbar) - pbar| <= eta, checked *)
     val[cd[[1]]] = pb], {cd, cornerDefs}];
  val["R"] = Rbar;
  polys = Table[Module[{cn = cons[[k]]},
     If[cn["t"] === "d", cn["s"] (n2[val[cn["X"]] + disp[cn["X"]] - val[cn["Y"]] - disp[cn["Y"]]] - 1),
      n2[val[cn["P"]] + disp[cn["P"]]] - (Rbar + hh[iR])^2]], {k, nc}];
  zero = Thread[hv -> 0];
  CV = polys /. zero;
  JG = Table[D[polys[[k]], {hv}] /. zero, {k, nc}];
  HS = Table[D[polys[[k]], {hv, 2}], {k, nc}];
  (* exact second-order expansion of each constraint with q_k as stated in Appendix D section 3 *)
  qk = Table[Module[{cn = cons[[k]]}, If[cn["t"] === "d", cn["s"] n2[disp[cn["X"]] - disp[cn["Y"]]],
      n2[disp[cn["P"]]] - hh[iR]^2]], {k, nc}];
  expOK = And @@ Table[Expand[polys[[k]] - (CV[[k]] + JG[[k]] . hv + qk[[k]])] === 0 &&
      Expand[qk[[k]] - hv . HS[[k]] . hv/2] === 0, {k, nc}];
  (* weights m_kj of w_k(h) *)
  WK = Table[Module[{cn = cons[[k]], w = ConstantArray[0, nv]},
     If[cn["t"] === "d", Do[Do[If[i > 0, w[[i]] += 2], {i, pt[nm]}], {nm, {cn["X"], cn["Y"]}}],
      Do[w[[i]] += 1, {i, pt[cn["P"]]}]; w[[iR]] += 1]; w], {k, nc}];
  wOK = And @@ Table[Module[{cn = cons[[k]], wk = Total[WK[[k]] hv^2]},
      If[cn["t"] === "d", Expand[wk - 2 n2[disp[cn["X"]]] - 2 n2[disp[cn["Y"]]]] === 0,
       Expand[wk - n2[disp[cn["P"]]] - hh[iR]^2] === 0]], {k, nc}];
  ];

(* multipliers: floating least squares of e_R + sum y_k J_k = 0 (data selection only), then rounding *)
eR = UnitVector[nv, iR];
chooseY[digits_] := Module[{A = Transpose[JG], y},
  y = LeastSquares[N[A, 80], N[-eR, 80]];
  Round[y 10^digits]/10^digits];

radii[rho_] := Module[{r = <||>},
  Do[r["c" <> ToString[k]] = If[k == 3, rho, sq2 rho], {k, 11}]; r["R"] = rho;
  Catch[Do[Module[{s = r[cd[[2]]] + r[cd[[3]]], dd = n2[val[cd[[3]]] - val[cd[[2]]]], xl, xh, w0},
      xl = sLo[dd, 30] - s; xh = sHi[dd, 30] + s;
      If[! (xl > 0 && xh < 2), Throw[$Failed, "rad"]];
      w0 = sLo[Min[phi2[xl], phi2[xh]], 30];
      If[! (w0 > 0), Throw[$Failed, "rad"]];
      r[cd[[1]]] = up[s/w0 + eta[cd[[1]]], 25]], {cd, cornerDefs}]; r, "rad"]];

build[rho_, theta_, mueq_, Y_] := Module[{r = radii[rho], mu, Qk, S, Gm, Dd, eps1, H, rhat, epsL},
  If[r === $Failed, Return[$Failed]];
  rhat = eR + Y . JG; epsL = Y . CV; H = Y . HS;
  S = ConstantArray[None, nc]; mu = ConstantArray[mueq, nc]; Qk = ConstantArray[0, nc];
  Do[Module[{cn = cons[[k]]},
     Qk[[k]] = If[cn["t"] === "d", (r[cn["X"]] + r[cn["Y"]])^2, Max[r[cn["P"]]^2, rho^2]];
     If[! cn["eq"],
      S[[k]] = up[If[cn["t"] === "o",
         CV[[k]] + 2 sHi[n2[val[cn["P"]]], 30] r[cn["P"]] + 2 Rbar rho + r[cn["P"]]^2,
         CV[[k]] + 2 sHi[n2[val[cn["X"]] - val[cn["Y"]]], 30] (r[cn["X"]] + r[cn["Y"]])], 20];
      mu[[k]] = If[S[[k]] > 0 && Y[[k]] > 0, dn[Y[[k]]/S[[k]], 14], 0]]], {k, nc}];
  Dd = 2 (1/theta - 1) Sum[mu[[k]] Qk[[k]] WK[[k]], {k, nc}];
  Gm = -H + 2 (1 - theta) Sum[mu[[k]] Outer[Times, JG[[k]], JG[[k]]], {k, nc}] - 2 DiagonalMatrix[Dd];
  eps1 = epsL + 2 (1/theta - 1) Sum[mu[[k]] CV[[k]]^2, {k, nc}];
  <|"G" -> Gm, "eps1" -> eps1, "epsL" -> epsL, "rhat" -> rhat, "mu" -> mu, "S" -> S, "r" -> r, "H" -> H,
   "muOK" -> And @@ Table[mu[[k]] > 0 && mu[[k]] <= Y[[k]]/S[[k]] && S[[k]] > 0, {k, ineq}]|>];

ldlPD[M_] := Module[{A = M, n = Length[M], p, minp = Infinity},
  Do[p = A[[k, k]]; If[! (p > 0), Return[{False, k, p}, Module]]; minp = Min[minp, p];
   If[k < n, A[[k + 1 ;; n, k + 1 ;; n]] -= Outer[Times, A[[k + 1 ;; n, k]], A[[k, k + 1 ;; n]]]/p], {k, n}];
  {True, n, minp}];
lamMin[M_] := Min[Eigenvalues[N[M, 40]]];
tauHi[rhat_, kap_, eps1_] := Module[{rn2 = rhat . rhat}, (sHi[rn2, 70] + sHi[rn2 + 2 kap Max[eps1, 0], 70])/kap];

certify[tag_, rho_, theta_, mueq_, Y_, kapFrac_] := Module[{b, lm, kap, pd, tau, lagOK},
  b = build[rho, theta, mueq, Y];
  If[b === $Failed, Return[<|"ok" -> False, "why" -> "radii undefined"|>]];
  lagOK = Expand[(Rbar + hh[iR]) + Y . polys - (Rbar + b["epsL"] + b["rhat"] . hv + hv . b["H"] . hv/2)] === 0;
  lm = lamMin[b["G"]];
  kap = If[lm > 0, dn[kapFrac lm, 9], 10^-9];
  pd = ldlPD[b["G"] - kap IdentityMatrix[nv]];
  tau = tauHi[b["rhat"], kap, b["eps1"]];
  <|"ok" -> (lagOK && b["muOK"] && Min[Y[[ineq]]] > 0 && pd[[1]] && tau <= 2/10^6), "lagOK" -> lagOK,
   "muOK" -> b["muOK"], "lammin" -> Min[Y[[ineq]]], "lm" -> lm, "kap" -> kap, "pd" -> pd, "tau" -> tau,
   "b" -> b|>];

runScheme[tag_, scheme_, theta_, mueq_, ydig_] := Module[{Y, c, t1 = AbsoluteTime[], b},
  Print["---- run ", tag, ": base points '", scheme, "', theta = ", theta, ", mu_eq = ", mueq,
   ", multipliers rounded to 1e-", ydig, " ----"];
  etaBad = {};
  setupBase[scheme];
  report[tag <> " B-eta |p(zbar) - pbar| <= eta_p for all 18 corners (exact interval)", etaBad === {},
   "max eta = " <> fmt[Max[Values[eta]]]];
  report[tag <> " B-exp c_k(xbar+h) = c_k(xbar) + J_k h + q_k(h), q_k = h.H_k.h/2 (54 exact Expand)", expOK];
  report[tag <> " B-w   w_k(h) = sum m_kj h_j^2 as stated (54 exact Expand)", wOK];
  say["max |E_k(xbar)| = ", fmt[Max[Abs[CV[[Complement[Range[nc], ineq]]]]]], ", max |g_i(xbar)| = ", fmt[Max[Abs[CV[[ineq]]]]]];
  Y = chooseY[ydig];
  say["lambda (18 inequalities) = ", fmt /@ Y[[ineq]]];
  say["sum of outer lambda = ", fmt[Total[Y[[ineq[[1 ;; 9]]]]]], ", 1/(2 Rbar) = ", fmt[1/(2 Rbar)]];
  c = certify[tag, 7/1000, theta, mueq, Y, 99/100];
  b = c["b"];
  say["|rhat|_2 = ", fmt[Sqrt[N[b["rhat"] . b["rhat"], 30]]], ", eps_L = ", fmt[b["epsL"]], ", eps1 = ", fmt[b["eps1"]]];
  say["corner radii r_p in [", fmt[Min[Table[b["r"][cd[[1]]], {cd, cornerDefs}]]], ", ",
   fmt[Max[Table[b["r"][cd[[1]]], {cd, cornerDefs}]]], "]"];
  report[tag <> " L   Lagrangian identity L(xbar+h) = Rbar+eps_L+rhat.h+h.H.h/2 (exact Expand)", c["lagOK"]];
  report[tag <> " (i) all 18 lambda > 0", c["lammin"] > 0, "min lambda = " <> fmt[c["lammin"]]];
  report[tag <> " mu  0 < mu_i <= lambda_i/S_i, S_i > 0", c["muOK"]];
  report[tag <> " (ii) G - kappa I positive definite, exact LDL^T (58 pivots > 0)", c["pd"][[1]],
   "float lambda_min(G) = " <> fmt[c["lm"]] <> ", kappa = " <> ToString[c["kap"], InputForm] <> ", min pivot = " <> fmt[c["pd"][[3]]]];
  report[tag <> " (iii) tau <= 2e-6", c["tau"] <= 2/10^6, "tau <= " <> fmt[c["tau"]]];
  report[tag <> " side: tau <= 2e-6 = 1/500000 (F6' box radius)", c["tau"] <= 1/500000];
  say["run ", tag, " time ", fmt[AbsoluteTime[] - t1], " s"];
  c];

ca = runScheme["A", "text", 7/10, 3/10, 30];
report["A   Step 6 side claim: tau(run A) < 8.6e-10 < 1/500000", ca["tau"] < 86/10^11 < 1/500000];
(* the text's printed kappa, checked against our G of run A *)
report["A   G - 0.004068342 I positive definite (the value printed by mid_cert)", ldlPD[ca["b"]["G"] - 4068342/10^9 IdentityMatrix[nv]][[1]]];
Module[{t = tauHi[ca["b"]["rhat"], 4068342/10^9, ca["b"]["eps1"]]},
  report["A   tau with kappa = 0.004068342 <= 8.6e-10", t <= 86/10^11, "tau <= " <> fmt[t]]];
(* eta robustness: inflate eta to 1e-12 (vastly above 1e-30|d|) -- certificate must still pass *)
Module[{save = eta, c2}, eta = Map[10^-12 &, eta];
  c2 = certify["A-eta", 7/1000, 7/10, 3/10, chooseY[30], 99/100];
  report["A   robustness: eta_p := 1e-12 still certifies (eta_p = 1e-30|d| is far below need)", c2["ok"],
   "kappa = " <> fmt[c2["kap"]] <> ", tau = " <> fmt[c2["tau"]]]; eta = save];

Print["---- negative controls (on run A data) ----"];
Module[{Y = chooseY[30], c, Y2, b},
  report["NEG rho = 5/100 violates Theorem A' (sqrt2 rho <= 0.0099) -- control must fail", ! (sq2 5/100 <= d0)];
  c = certify["N1", 5/100, 7/10, 3/10, Y, 99/100];
  negctl["rho = 5/100: certificate", c["ok"], If[KeyExistsQ[c, "lm"], "float lambda_min(G) = " <> fmt[c["lm"]], c["why"]]];
  c = certify["N1b", 2/100, 7/10, 3/10, Y, 99/100];
  negctl["rho = 2/100: certificate", c["ok"], If[KeyExistsQ[c, "lm"], "float lambda_min(G) = " <> fmt[c["lm"]] <> ", tau = " <> fmt[c["tau"]], c["why"]]];
  b = build[7/1000, 7/10, 3/10, Y];
  negctl["kappa = 1.02 lambda_min: exact LDL^T", ldlPD[b["G"] - dn[102/100 lamMin[b["G"]], 9] IdentityMatrix[nv]][[1]]];
  Y2 = Y; Y2[[ineq[[1]]]] *= (1 + 1/1000);
  c = certify["N3", 7/1000, 7/10, 3/10, Y2, 99/100];
  negctl["lambda(O1) * (1+1e-3): certificate", c["ok"], "tau = " <> fmt[c["tau"]]];
  Y2 = Y; Y2[[ineq[[12]]]] *= -1;
  c = certify["N4", 7/1000, 7/10, 3/10, Y2, 99/100];
  negctl["lambda(I_5) sign-flipped: certificate", c["ok"], "min lambda = " <> fmt[c["lammin"]]];
  negctl["A1a tightened to |c1| <= 0.39", n2[cc[1]] <= (39/100)^2];
  (* sharpness of the A-checks: threshold raised to (observed value + 1e-3) must fail *)
  Module[{dI = sqrtI[n2[cc[2] - cc[1]], 40], ph, t},
   ph = Sqrt[N[Min[lo[phi2[dI - 2 d0]], lo[phi2[dI + 2 d0]]], 30]]; t = up[ph, 3] + 1/1000;
   negctl["A3 pair (1,2) with phi threshold " <> fmt[t] <> " (observed " <> fmt[ph] <> ")",
    lo[phi2[dI - 2 d0]] >= t^2 && lo[phi2[dI + 2 d0]] >= t^2]];
  Module[{oth = Append[Complement[Bord, pairs[[1]]], 1], dm, t},
   dm = Min[Table[lo[n2[QI[[1]] - cc[k]]], {k, oth}]]; t = up[Sqrt[N[dm, 30]], 3] + 1/1000;
   negctl["A5 Q_1 with threshold " <> fmt[t] <> " (observed " <> fmt[Sqrt[N[dm, 30]]] <> ")", dm >= t^2]];
  Module[{dm = Min[Table[lo[n2[farI[cc[9]] - cc[7]]], {1}]], t},
   t = up[Sqrt[N[dm, 30]], 3] + 1/1000;
   negctl["A7 pair (9,7) with threshold " <> fmt[t], dm >= t^2]];
  ];

cb = runScheme["B", "own", 3/4, 1/2, 12];

Print["==== Summary ===="];
Print["passed ", npass, " checks; failed: ", fails];
Print["run A: kappa = ", ToString[ca["kap"], InputForm], " (", fmt[ca["kap"]], "), tau <= ", fmt[ca["tau"]]];
Print["run B: kappa = ", ToString[cb["kap"], InputForm], " (", fmt[cb["kap"]], "), tau <= ", fmt[cb["tau"]]];
Print["total time ", fmt[AbsoluteTime[] - t0], " s"];
If[fails === {} && ca["ok"] && cb["ok"], Print["23d MID VERIFIED"]; Exit[0], Print["23d MID NOT VERIFIED"]; Exit[1]];
