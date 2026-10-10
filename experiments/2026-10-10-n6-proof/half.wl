(* n=6 half-problem: reduced function and its critical point.
   C1=D((0,a),1), C2=D((0,-b),1), Cn=D(0,R). Right side x>0.
   T1 = dC1 cap dCn (x>0), T2 = dC2 cap dCn (x>0), V = dC1 cap dC2 (x>0),
   X0 = T1 rotated clockwise by 2 alpha (sin alpha = 1/R), i.e. |T1 X0| = 2, |X0| = R.
   G(a,b,R) := circumradius(V,T2,X0)^2 - 1. *)
pts[a_, b_, R_] := Module[{y1, y2, T1, T2, V, s, c2, s2, X0},
  y1 = (R^2 + a^2 - 1)/(2 a); y2 = -(R^2 + b^2 - 1)/(2 b);
  T1 = {Sqrt[R^2 - y1^2], y1}; T2 = {Sqrt[R^2 - y2^2], y2};
  s = (a + b)/2; V = {Sqrt[1 - s^2], (a - b)/2};
  c2 = 1 - 2/R^2; s2 = 2 Sqrt[R^2 - 1]/R^2;
  X0 = {{c2, s2}, {-s2, c2}} . T1;
  {T1, T2, V, X0}];
circR2[P_, Q_, S_] := Module[{u = Q - P, v = S - P, w = S - Q, cr},
  cr = u[[1]] v[[2]] - u[[2]] v[[1]];
  (u . u) (v . v) (w . w)/(4 cr^2)];
G[a_, b_, R_] := Module[{T1, T2, V, X0}, {T1, T2, V, X0} = pts[a, b, R]; circR2[V, T2, X0] - 1];
