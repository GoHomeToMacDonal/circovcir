#!/usr/bin/env wolframscript
(* Certificate 10i for proofs/10-n6-half.md section 8: closed form of R6.

   Claim.  R6^2 is the unique root in (3.2359, 3.2360) of the irreducible polynomial
     f9(t) = 3072 t^9 + 54016 t^8 - 746832 t^7 + 5156603 t^6 - 19376280 t^5 + 41451480 t^4
             - 63156942 t^3 + 62607492 t^2 - 33449976 t + 7841367,
   so R6 has minimal polynomial f9(t^2) (degree 18); a6, b6 have the degree-18 minimal polynomials
   fa, fb below.

   Gates.
     (E0) f9, f9(t^2), fa, fb irreducible over Q                                               [exact]
     (E1) Rs := the real root of f9(t^2), as, bs := real roots of fa, fb, each selected by exact
          comparison to lie in the Krawczyk box X of certificate 10h (m +- 10^-50, same m)     [exact]
     (E2) F(Rs, as, bs) = 0 exactly, F = {G, G_a, G_b} built from 10lib-n6.wl exactly as in 10h;
          every radicand and every denominator is checked nonzero / positive first             [RootReduce]
     (E3) negative control: replacing as by the other positive real root of fa gives F != 0    [exact]
   Conclusion.  10h K1 says F has exactly one zero in X, and it is (R6, a6, b6) (10h + proofs/10 s7,
   Lemma K).  (Rs, as, bs) is a zero of F in X, hence (Rs, as, bs) = (R6, a6, b6).
   The polynomials were FOUND by integer relations on a 2200-digit value
   (experiments/2026-10-11-n6-minpoly/identify.wls); that search is evidence only, the proof is E0-E2.
   Exit 1 on failure; last line "CERTIFICATE OK". *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "10lib-n6.wl"}]];
fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];

f9 = 3072 t^9 + 54016 t^8 - 746832 t^7 + 5156603 t^6 - 19376280 t^5 + 41451480 t^4 -
   63156942 t^3 + 62607492 t^2 - 33449976 t + 7841367;
fR = f9 /. t -> t^2;
fa = 27648 t^18 - 73728 t^16 - 745200 t^14 + 18999873 t^12 - 115513074 t^10 + 294885435 t^8 -
   376630082 t^6 + 387335989 t^4 - 198038624 t^2 + 7200000;
fb = 3072 t^18 + 47872 t^16 - 190480 t^14 + 265969 t^12 - 1826874 t^10 - 1008837 t^8 +
   1854 t^6 + 2174045 t^4 + 380416 t^2 + 327680;

(* E0 *)
gate["E0 f9, f9(t^2), fa, fb irreducible", And @@ (IrreduciblePolynomialQ /@ {f9, fR, fa, fb})];

(* the Krawczyk box of 10h: same centre construction (Newton wp 200, rationalised), r = 10^-50 *)
Gf[R_, a_, b_] := n6circR2[n6V[a, b], n6T2[R, b], n6X0[R, a]] - 1;
vars = {R, a, b};
Gs = Gf[R, a, b];
Fs = {Gs, D[Gs, a], D[Gs, b]};
sol = FindRoot[Fs, Transpose[{vars,
     {17988678275775543711457935637452760440966/10^40, 9354854282012050973201937283428477342650/10^40,
      10105813367281855307975567223444460778468/10^40}}],
   WorkingPrecision -> 200, AccuracyGoal -> 180, PrecisionGoal -> 180, MaxIterations -> 100];
m = Rationalize[N[vars /. sol, 90], 10^-85];
r = 10^-50;

(* E1: exact selection of the roots inside X (Less on algebraic numbers is decided exactly) *)
realRoots[f_] := Select[Table[Root[Function @@ {t, f}, k], {k, Exponent[f, t]}], Element[#, Reals] &];
inX[x_, i_] := TrueQ[m[[i]] - r < x < m[[i]] + r];
Print["  m = ", N[m, 20]];
sel = MapThread[Select[realRoots[#1], Function[x, inX[x, #2]]] &, {{fR, fa, fb}, {1, 2, 3}}];
Print["  #roots in box ", Length /@ sel];
gate["E1 exactly one real root of each polynomial in the 10h box", Length /@ sel === {1, 1, 1}];
{Rs, as, bs} = First /@ sel;
gate["E1' Rs^2 is a root of f9 in (3.2359, 3.2360)", RootReduce[f9 /. t -> Rs^2] === 0 && 32359/10^4 < Rs^2 < 32360/10^4];
Print["  R6 = ", N[Rs, 60]];

(* E2: radicands > 0 and denominators != 0, then exact zero test *)
ex = Thread[vars -> {Rs, as, bs}];
y1e = n6y1[Rs, as]; y2e = n6y2[Rs, bs];
rads = {Rs^2 - y1e^2, Rs^2 - y2e^2, 1 - ((as + bs)/2)^2, Rs^2 - 1};
gate["E2a radicands > 0 (T1, T2, V, sin 2alpha)", And @@ (TrueQ[RootReduce[#] > 0] & /@ rads)];
P = {n6V[as, bs], n6T2[Rs, bs], n6X0[Rs, as]};
crs = RootReduce[n6cross[P[[2]] - P[[1]], P[[3]] - P[[1]]]];
gate["E2b nondegenerate triangle (cross != 0), a, b, R != 0", crs =!= 0 && TrueQ[crs != 0] && as > 0 && bs > 0 && Rs > 0];
Fex = Fs /. ex;
Do[{tm, z} = AbsoluteTiming[RootReduce[Fex[[k]]]];
  Print["  F", k, " RootReduce -> ", z, "  (", Round[tm], " s)"];
  gate["E2 F" <> ToString[k] <> " = 0 exactly", z === 0], {k, 3}];

(* E3 negative control: another positive real root of fa.  (RootReduce there needs a degree-1008
   field and is refused by $MaxRootDegree -- the collapse to small degree at the true point is
   itself the non-generic event; the control is a certified-precision numerical value.) *)
aOther = SelectFirst[realRoots[fa], # > 0 && # =!= as &];
zc = N[Fs[[1]] /. Thread[vars -> {Rs, aOther, bs}], 30];
Print["  control: a = ", N[aOther, 10], "  G = ", zc, "  precision ", Precision[zc]];
gate["E3 control (other root of fa): G != 0", Precision[zc] >= 20 && Abs[zc] > 10^-10];

Print["  R6^2 minimal polynomial: ", InputForm[f9]];
Print["CERTIFICATE OK"];
