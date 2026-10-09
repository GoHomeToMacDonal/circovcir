r10 = 1 + 2 Cos[2 Pi/9];
Print["a(C10) = pi r10^2 = ", N[Pi r10^2, 15], "   (FT uses 20.1422 as lower bound)"];
Print["  > 20.1422 ? ", TrueQ[Pi r10^2 > 20.1422]];
(* f and F from FT section 2 (repo methods): f(a)=2 arcsin(sin(a/2)/R), F(a)=(R^2/2)(f-sin f)+sin(a)/2 *)
R = r10;
f[a_] := 2 ArcSin[Sin[a/2]/R];
F[a_] := (R^2/2)(f[a] - Sin[f[a]]) + Sin[a]/2;
finv[y_] := a /. FindRoot[f[a] == y, {a, 2.0}, WorkingPrecision->40];
(* (13) Case 1: 8 F( finv( (pi - asin(1/r10))/4 ) ) *)
a13 = finv[(Pi - ArcSin[1/r10])/4];
v13 = 8 F[a13];
Print["(13)  8 F(finv((pi-asin(1/r10))/4)) = ", N[v13,12], "   FT 4.92397937"];
(* (13') Case 2: 7 F( finv( (2pi - 4 asin(1/r10))/7 ) ) *)
a13b = finv[(2 Pi - 4 ArcSin[1/r10])/7];
v13b = 7 F[a13b];
Print["(13') 7 F(finv((2pi-4asin(1/r10))/7)) = ", N[v13b,12], "   FT 4.332295377"];
(* f^{-1} lower bounds printed: 2.028453422 and 1.948256547 *)
Print["finv((pi-asin(1/r10))/4) = ", N[a13,12], "   FT 2.028453422"];
Print["finv((2pi-4asin(1/r10))/7)=", N[a13b,12], "  FT 1.948256547"];
(* Case 1 total: a(P1)<=8sin(pi/4), a(P2)<=2.284572282, a(S1)<=0.27675335, sumQi<=7, sumRi<=4.92397937 *)
c1 = 8 Sin[Pi/4] + 2.284572282 + 0.27675335 + 7 + v13;
Print["Case 1 total <= ", N[c1,10], "   FT 20.14216  (<20.1422<a(C10)?) ", TrueQ[c1 < Pi r10^2]];
(* Case 2 total: 7 sin(2pi/7)+2*pent+2*seg+5+ v13b *)
c2 = 7 Sin[2 Pi/7] + 4.5691944564 + 0.533506699 + 5 + v13b;
Print["Case 2 total <= ", N[c2,10], "   FT 20  (<20.1422<a(C10)?) ", TrueQ[c2 < Pi r10^2]];
