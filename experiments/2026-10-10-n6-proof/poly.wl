(* Polynomial form of the n=6 half-problem critical system.  Aux variables:
   x1 = Sqrt[R^2 - y1^2], x2 = Sqrt[R^2 - y2^2], xv = Sqrt[1 - s^2], r1 = Sqrt[R^2 - 1]. *)
y1 = (R^2 + a^2 - 1)/(2 a); y2 = -(R^2 + b^2 - 1)/(2 b); s = (a + b)/2;
T1 = {x1, y1}; T2 = {x2, y2}; V = {xv, (a - b)/2};
c2 = 1 - 2/R^2; s2 = 2 r1/R^2;
X0 = {{c2, s2}, {-s2, c2}} . T1;
u = T2 - V; v = X0 - V; w = X0 - T2;
cr = u[[1]] v[[2]] - u[[2]] v[[1]];
Hraw = (u . u) (v . v) (w . w) - 4 cr^2;
defs = {x1^2 - (R^2 - y1^2), x2^2 - (R^2 - y2^2), xv^2 - (1 - s^2), r1^2 - (R^2 - 1)};
aux = {x1, x2, xv, r1};
(* implicit derivatives of aux wrt a, b, R from defs *)
dAux[t_] := Module[{J = D[defs, {aux}], g = D[defs, t]}, -Inverse[J] . g];
tot[expr_, t_] := D[expr, t] + D[expr, {aux}] . dAux[t];
