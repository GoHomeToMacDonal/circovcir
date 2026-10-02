#!/usr/bin/env wolframscript
(* R5 exact: the math.stackexchange degree-8 poly (q/2651575, mislabeled "six disks")
   has a root x0 ~ 0.60938 with 1/x0 = 1.6410044636... = R5 (Neville 1915 value, verified
   by Bezdek 1979/1983). Derive the minimal polynomial of R5 = 1/x0 exactly and compare to
   the repo baseline R5 to full precision. No randomness. *)

P[x_] := 6^4 x^8 + 2112 x^7 - 3480 x^6 + 1360 x^5 + 1665 x^4 - 1776 x^3 + 22 x^2 - 800 x + 5^4;

(* x0 = the real root of P near 0.60938 (exact algebraic number); select BY VALUE *)
x0 = RootApproximant[First@Select[x /. NSolve[P[x] == 0, x, 60],
       Abs[Im[#]] < 10^-40 && Abs[Re[#] - 0.60938286408070965] < 10^-6 &], 8];
Print["x0 (algebraic)   = ", InputForm[N[x0, 20]]];
R5 = 1/x0;
Print["R5 = 1/x0        = ", InputForm[N[R5, 48]]];

(* minimal polynomial of R5 over the rationals *)
mp = MinimalPolynomial[R5, t];
Print["MinimalPolynomial[R5, t] = ", InputForm[mp]];
Print["degree = ", Exponent[mp, t]];

(* compare to repo baseline numeric *)
R5base = SetPrecision[1.6410044636036152, 17];
Print["baseline R5      = ", InputForm[R5base]];
Print["|R5 - baseline|  = ", InputForm[N[Abs[R5 - R5base], 5]]];

(* is R5 the golden-ratio symmetric value phi^2 ~ 2.618? NO: Neville's symmetric r is larger;
   check the oft-quoted symmetric five-disk value for contrast *)
Print["phi^2 = ", InputForm[N[GoldenRatio^2, 10]], "  (symmetric 5-disk is NOT the optimum)"];
