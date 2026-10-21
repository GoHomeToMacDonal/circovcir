#!/usr/bin/env wolframscript
(* Independent re-check of Lemma L (siege run 2026-10-20, n=11 class b=10).
   Written from the mathematical statement in out/proof.md §2-3, not from lemL.py.
   Claim per row (ea,eb,lam,k,j): for all e in [ea,eb], r0-1 <= r <= 3-e, |r-s| <= e,
     F = lam*I + (1-lam)*Theta(r) < Pi/10,
   I = phi - k sin(phi) cos(psi) + (j/2) sin(2phi) cos(2psi), phi = ArcCos[min(s,2)/2],
   cos(psi) = (r^2-s^2-e^2)/(2 e s), Theta(r) = ArcCos[(r^2+r0^2-1)/(2 r r0)] for r<=rc, ArcSin[1/r0] beyond.
   Underflow near 0 (General::munfl) can lose at most ~1e-307 per operation; the test
   f + 10^-12 < Pi/10 absorbs it with huge room.
   Box endpoints are exact rationals; evaluation uses Wolfram Interval arithmetic on
   machine intervals obtained by outward rounding (N[Interval[...]]), so every enclosure is rigorous.
   Row parameters are the exact decimals of the table (rationals), and w >= 0 is checked exactly. *)

r0 = 263169/100000; rc = Sqrt[r0^2 - 1];
aR0 = ArcSin[1/r0];
pi10 = Pi/10;

iv[a_, b_] := N[Interval[{a, b}]];   (* outward-rounded machine interval *)
hi[x_Interval] := Max[x]; lo[x_Interval] := Min[x];

(* sanity: N[Interval] really rounds outward *)
If[!(lo[iv[1/3, 1/3]] < 1/3 < hi[iv[1/3, 1/3]] || lo[iv[1/3,1/3]] <= 1/3 <= hi[iv[1/3,1/3]]),
  Print["outward rounding check FAILED"]; Exit[2]];

(* Theta is nondecreasing: bound on [r1,r2] by Theta(r2), evaluated as an interval *)
thetaHi[r2_] := If[r2 >= rc, hi[N[Interval[{aR0, aR0}]]],
   hi[ArcCos[(iv[r2, r2]^2 + iv[r0, r0]^2 - 1)/(2 iv[r2, r2] iv[r0, r0])]]];

weightNonneg[k_, j_] := Module[{c = {1 + j - k, 1 + j + k}},
  If[j > 0 && Abs[k] <= 4 j, AppendTo[c, 1 - j - k^2/(8 j)]]; Min[c] >= 0];

(* upper bound of F on a box, or "empty" if the box has no admissible point *)
fHi[{e1_, e2_}, {r1_, r2_}, {s1_, s2_}, lam_, k_, j_] := Module[
  {E, Rr, S, Sm, phi, sphi, s2phi, cps, c2ps, I},
  If[s1 > r2 + e2 || s2 < r1 - e2 || r2 < r0 - 1 || r1 > 3 - e1, Return["empty"]];
  Rr = iv[r1, r2]; S = iv[s1, s2];
  Sm = iv[Min[s1, 2], Min[s2, 2]];
  phi = ArcCos[IntervalIntersection[Sm/2, Interval[{-1, 1}]]];
  sphi = Sqrt[IntervalIntersection[1 - Sm^2/4, Interval[{0, 1}]]];
  s2phi = Sm sphi;                                (* sin 2phi = 2 sin phi cos phi, cos phi = min(s,2)/2 *)
  If[k == 0 && j == 0,
    I = phi,
    E = iv[e1, e2];
    cps = IntervalIntersection[(Rr^2 - S^2 - E^2)/(2 E S), Interval[{-1, 1}]];
    If[cps === Interval[], Return["empty"]];
    c2ps = 2 cps^2 - 1;
    I = phi - k sphi cps + (j/2) s2phi c2ps];
  With[{v = hi[lam I + (1 - lam) iv[thetaHi[r2], thetaHi[r2]]]}, If[NumericQ[v], v, Infinity]]];

checkRow[{ea_, eb_, lam_, k_, j_}] := Module[
  {stack, box, f, n = 0, maxF = -Infinity, w, i, b, mid},
  If[!(0 <= lam <= 1 && weightNonneg[k, j]), Return[{"BADPARAM", 0}]];
  If[ea == 0 && (k != 0 || j != 0), Return[{"E0-NEEDS-K0", 0}]];
  stack = {{{ea, eb}, {r0 - 1, 3 - ea}, {r0 - 1 - eb, 3 - ea + eb}}};
  While[stack =!= {},
    box = Last[stack]; stack = Most[stack]; n++;
    If[n > 3*10^6, Return[{"BUDGET", n}]];
    f = fHi[box[[1]], box[[2]], box[[3]], lam, k, j];
    If[f === "empty", Continue[]];
    If[f + 10^-12 < pi10, maxF = Max[maxF, f]; Continue[]];
    w = {4 (box[[1, 2]] - box[[1, 1]]), box[[2, 2]] - box[[2, 1]], box[[3, 2]] - box[[3, 1]]};
    If[Max[w] < 10^-7, Return[{"TOOSMALL", n}]];
    i = First[Ordering[w, -1]]; b = box[[i]];
    mid = Rationalize[N[(b[[1]] + b[[2]])/2], 0];   (* any exact split point inside works *)
    If[!(b[[1]] < mid < b[[2]]), mid = (b[[1]] + b[[2]])/2];
    stack = Join[stack, {ReplacePart[box, i -> {b[[1]], mid}], ReplacePart[box, i -> {mid, b[[2]]}]}]];
  {"OK", n, N[pi10 - maxF]}];

rows = {
 {0, 5/1000, 21/100, 0, 0}, {5/1000, 15/1000, 2065/10000, 507/10000, -101/10000},
 {15/1000, 25/1000, 2066/10000, 995/10000, -84/10000}, {25/1000, 35/1000, 2147/10000, 1373/10000, -78/10000},
 {35/1000, 45/1000, 2085/10000, 1939/10000, -27/10000}, {45/1000, 55/1000, 208/1000, 241/1000, 43/10000},
 {55/1000, 65/1000, 2151/10000, 2771/10000, 82/10000}, {65/1000, 75/1000, 2092/10000, 3401/10000, 155/10000},
 {75/1000, 85/1000, 21/100, 3837/10000, 227/10000}, {85/1000, 95/1000, 2178/10000, 4135/10000, 314/10000},
 {95/1000, 105/1000, 2208/10000, 4592/10000, 516/10000}, {105/1000, 115/1000, 2139/10000, 5211/10000, 553/10000},
 {115/1000, 125/1000, 2169/10000, 5675/10000, 675/10000}, {125/1000, 135/1000, 2157/10000, 6247/10000, 827/10000},
 {135/1000, 145/1000, 2186/10000, 6632/10000, 1015/10000}, {145/1000, 155/1000, 2211/10000, 7008/10000, 1122/10000},
 {155/1000, 165/1000, 221/1000, 756/1000, 1319/10000}, {165/1000, 175/1000, 2281/10000, 7444/10000, 1207/10000},
 {175/1000, 185/1000, 2269/10000, 8281/10000, 1646/10000}, {185/1000, 195/1000, 2267/10000, 9021/10000, 2062/10000},
 {195/1000, 205/1000, 2313/10000, 9091/10000, 2007/10000}, {205/1000, 215/1000, 2316/10000, 9566/10000, 2193/10000},
 {215/1000, 225/1000, 2364/10000, 9769/10000, 2326/10000}, {225/1000, 235/1000, 2401/10000, 1034/1000, 2795/10000},
 {235/1000, 245/1000, 239/1000, 10748/10000, 2851/10000}, {245/1000, 255/1000, 2393/10000, 11103/10000, 2939/10000},
 {255/1000, 265/1000, 2401/10000, 11894/10000, 3485/10000}, {265/1000, 275/1000, 2473/10000, 11833/10000, 3553/10000},
 {275/1000, 285/1000, 2457/10000, 12576/10000, 3913/10000}, {285/1000, 295/1000, 2504/10000, 12857/10000, 4197/10000},
 {295/1000, 305/1000, 2579/10000, 12879/10000, 4392/10000}, {305/1000, 315/1000, 2576/10000, 13238/10000, 4503/10000},
 {315/1000, 325/1000, 2619/10000, 13633/10000, 4854/10000}, {325/1000, 335/1000, 2719/10000, 13201/10000, 4774/10000},
 {335/1000, 345/1000, 2644/10000, 14002/10000, 4958/10000}, {345/1000, 355/1000, 2719/10000, 13954/10000, 5128/10000},
 {355/1000, 365/1000, 2831/10000, 1387/1000, 5304/10000}, {365/1000, 3684/10000, 2831/10000, 1387/1000, 5304/10000}};

(* coverage of [0, 3 - r0] by consecutive rows *)
cover = rows[[1, 1]] == 0 && And @@ Table[rows[[i, 2]] == rows[[i + 1, 1]], {i, Length[rows] - 1}] &&
   rows[[-1, 2]] >= 3 - r0;
Print["row chain covers [0, 3-r0]: ", cover];

res = Table[With[{o = checkRow[row]}, Print[N[row[[1 ;; 2]]], " ", o]; o], {row, rows}];
ok = cover && AllTrue[res, First[#] === "OK" &];
Print["boxes total: ", Total[res[[All, 2]]], "  min margin: ", Min[Cases[res, {"OK", _, m_} :> m]]];
Print[If[ok, "ALL OK", "FAILED"]];

(* negative control: perturbing a row's lambda must make it fail *)
neg = checkRow[{0, 5/1000, 50/100, 0, 0}];
Print["negative control (lam=0.5 on row 1): ", neg];
Exit[If[ok && First[neg] =!= "OK", 0, 1]];
