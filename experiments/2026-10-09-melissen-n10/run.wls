#!/usr/bin/env wolframscript
(* Single entry point for experiments/2026-10-09-melissen-n10.
   Reproduces every computational assertion of the [FT] 2005 section 3 n=10
   Melissen distance lemma, with first-principles h(theta).  This is the
   exploratory driver; the gated version lives in
   proofs/certificates/05c-melissen-n10.wls.

   Run (repo root):
     wolframscript -file experiments/2026-10-09-melissen-n10/run.wls ; echo "EXIT=$?"
*)
Off[General::munfl]; Off[FindRoot::lstol]; Off[FindRoot::precw];
r10 = 1 + 2 Cos[2 Pi/9];
asin = ArcSin;
Print["r10 = 1 + 2 Cos[2 Pi/9] = ", N[r10, 25], "  (= n=10 covering radius R_10)"];
Print["  NOTE: 'r10 ~ 1.7988' sometimes attached to this lemma is the n=6 record r_6,"];
Print["        NOT the radius here.  The lemma's C_10 has radius 1+2cos(2pi/9)."];

(* ---- h(theta) FIRST PRINCIPLES (branch validated against FT printed numbers) ---- *)
w = r10;
cx = w Cos[th/4]^2 - Cos[th/4] Sqrt[1 - w^2 Sin[th/4]^2];
cy = w Sin[th/4] Cos[th/4] - Sin[th/4] Sqrt[1 - w^2 Sin[th/4]^2];
h  = cx - Sqrt[1 - cy^2];
th0    = Pi - 4 asin[1/r10];
psimin = 2 Pi - 2 asin[2/r10] - 6 asin[1/r10];
ximin  = 2 Pi - 2 asin[2/r10] - 4 asin[1/r10];
Print["\n--- distance bounds (reproduce FT) ---"];
Print["h(th0) = ", N[h /. th -> th0, 20]];
Print["|p p+3| = 2 h sin(psimin/2) = ", N[2 (h /. th -> th0) Sin[psimin/2], 15], "  FT 2.02349  >2"];
Print["|p p+4| = 2 h sin(ximin/2)  = ", N[2 (h /. th -> th0) Sin[ximin/2], 15],  "  FT 2.357538 >2"];

Print["\n--- h increasing & convex on (0, 4 asin(1/r10)) via Interval B&B ---"];
hp = D[h, th]; hpp = D[h, {th, 2}];
wN = SetPrecision[r10, 80]; dom = 4 ArcSin[1/wN];
g1 = 1 - w^2 Sin[th/4]^2; g2 = 1 - cy^2;
bb[expr_] := Module[{stack = {{SetPrecision[10^-5, 80], dom - SetPrecision[10^-7, 80], 0}},
                     nL = 0, wst = Infinity, deep = 0},
  While[stack =!= {},
   Module[{t = First[stack], a, b, dep, iv, l1, l2, lv},
    stack = Rest[stack]; {a, b, dep} = t; iv = Interval[{a, b}];
    l1 = Min[g1 /. w -> wN /. th -> iv]; l2 = Min[g2 /. w -> wN /. th -> iv];
    lv = Min[expr /. w -> wN /. th -> iv];
    If[TrueQ[l1 > 0] && TrueQ[l2 > 0] && TrueQ[lv > 0],
     nL++; wst = Min[wst, lv],
     If[dep >= 46, deep++, Module[{m = (a + b)/2},
       stack = Join[{{a, m, dep + 1}, {m, b, dep + 1}}, stack]]]]]];
  {nL, deep, wst}];
r1 = bb[hp];  Print["h'  > 0 : leaves=", r1[[1]], " deep=", r1[[2]], " min=", N[r1[[3]], 10]];
r2 = bb[hpp]; Print["h'' > 0 : leaves=", r2[[1]], " deep=", r2[[2]], " min=", N[r2[[3]], 10]];

Print["\n--- area bounds (9)-(13) + final contradiction ---"];
R = r10; f[a_] := 2 ArcSin[Sin[a/2]/R]; F[a_] := R^2/2 (f[a] - Sin[f[a]]) + Sin[a]/2;
finv[y_] := a /. FindRoot[f[a] == y, {a, 2.0}, WorkingPrecision -> 40];
seg = R^2 (ArcSin[1/R] - (1/2) Sin[2 ArcSin[1/R]]);
rp = r /. FindRoot[4 ArcSin[1/(2 r)] + ArcSin[1/r] == Pi, {r, 1.07}, WorkingPrecision -> 40];
pent = 4 ((1/2) rp^2 Sin[2 ArcSin[1/(2 rp)]]) + (1/2) rp^2 Sin[2 ArcSin[1/rp]];
v13 = 8 F[finv[(Pi - ArcSin[1/R])/4]]; v13b = 7 F[finv[(2 Pi - 4 ArcSin[1/R])/7]];
Print["a(C10)=pi r10^2 = ", N[Pi R^2, 15], " > 20.1422"];
Print["(9) 8sin(pi/4)=", N[8 Sin[Pi/4], 12], "  (9') 7sin(2pi/7)=", N[7 Sin[2 Pi/7], 12]];
Print["(10) pentagon (true max) = ", N[pent, 12], " <= FT 2.284572282 (ours tighter)"];
Print["(11) segment = ", N[seg, 12], "  FT 0.27675335"];
Print["(13) 8F=", N[v13, 12], "  (13') 7F=", N[v13b, 12]];
Print["Case 1 total = ", N[8 Sin[Pi/4] + 2.284572282 + seg + 7 + v13, 12], " < a(C10)  FT 20.14216"];
Print["Case 2 total = ", N[7 Sin[2 Pi/7] + 4.5691944564 + 2 seg + 5 + v13b, 12], " < a(C10) FT <=20"];
Print["\nDONE (exploratory). Gated certificate: proofs/certificates/05c-melissen-n10.wls"];
