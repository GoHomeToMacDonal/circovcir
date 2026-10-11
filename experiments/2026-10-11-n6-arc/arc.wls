(* n=6 arc-length formulation (user approach, 2026-10-11).
   Target D(0,r); C1 center (-p,0), C2 center (q,0), r-1<p,q<r, p+q<=2 (premise H0).
   Upper half: Q1=dC1 cap dD, Q2=dC2 cap dD, P=dC1 cap dC2 (y>0).
   C3 contains Q1,P.  Extremal C3: unit circle through Q1 and P, so that Q1 is the
   counterclockwise endpoint of its arc on dD -> new arc 2*beta3 (no overlap with C1's arc).
   F := theta1+theta2+2 beta3 + 2 alpha - Pi  (remaining arc must be <= 2 alpha for C4).
   Output: threshold r where max_{p,q} F = 0, compared with R6 of proofs/10 (L2 numerics). *)
wp = 50;
th[r_, p_] := ArcCos[(r^2 + p^2 - 1)/(2 r p)];
geo[r_, p_, q_] := Module[{t1 = th[r, p], Q1, P, s = (p + q)/2, M, d, nrm, c3, b3},
  Q1 = r {Cos[Pi - t1], Sin[Pi - t1]}; P = {(q - p)/2, Sqrt[1 - s^2]};
  M = (Q1 + P)/2; d = Sqrt[(P - Q1) . (P - Q1)]; nrm = {{0, 1}, {-1, 0}} . (P - Q1)/d;
  (* the other unit circle through Q1,P is dC1 itself (center M + nrm h); take the second one *)
  c3 = M - nrm Sqrt[1 - d^2/4];
  b3 = ArcCos[(r^2 + c3 . c3 - 1)/(2 r Sqrt[c3 . c3])];
  <|"Q1" -> Q1, "P" -> P, "c3" -> c3, "b3" -> b3, "t1" -> t1, "t2" -> th[r, q],
    "endpointCheck" -> ArcTan @@ c3 + b3 - (Pi - t1)|>];
F[r_?NumericQ, p_?NumericQ, q_?NumericQ] := Module[{g = geo[r, p, q]},
  g["t1"] + g["t2"] + 2 g["b3"] + 2 ArcSin[1/r] - Pi];
(* critical system F = dF/dp = dF/dq = 0 *)
Fs[r_, p_, q_] := Module[{g = geo[r, p, q]}, g["t1"] + g["t2"] + 2 g["b3"] + 2 ArcSin[1/r] - Pi];
sol = FindRoot[{Fs[r, p, q] == 0, D[Fs[r, p, q], p] == 0, D[Fs[r, p, q], q] == 0},
   {{r, 18/10}, {p, 101/100}, {q, 935/1000}}, WorkingPrecision -> wp, MaxIterations -> 200];
Print["critical point: ", N[sol, 25]];
R6ref = 1.79886782757755437114579356374527604409660111`45;
Print["r - R6(proofs/10) = ", N[(r /. sol) - R6ref, 5]];
g = geo @@ ({r, p, q} /. sol);
X = (r /. sol) {Cos[Pi - g["t1"] - 2 g["b3"]], Sin[Pi - g["t1"] - 2 g["b3"]]};
Q2 = (r /. sol) {Cos[g["t2"]], Sin[g["t2"]]};
Print["endpoint check (Q1 is ccw end of C3 arc): ", N[g["endpointCheck"], 5]];
Print["|X Q2| (should be 2): ", N[Sqrt[(X - Q2) . (X - Q2)], 20]];
tri = {g["Q1"], g["P"], X};
ang = Table[With[{u = tri[[Mod[i + 1, 3, 1]]] - tri[[i]], v = tri[[Mod[i + 2, 3, 1]]] - tri[[i]]}, ArcCos[u . v/Sqrt[(u . u) (v . v)]]], {i, 3}];
Print["triangle Q1,P,X angles (deg, acute?): ", N[ang/Degree, 8]];
(* local maximality: Hessian of F in (p,q) at fixed r *)
H = D[Fs[rr, pp, qq], {{pp, qq}, 2}] /. {rr -> r, pp -> p, qq -> q} /. sol;
Print["Hessian eigenvalues (should be <0): ", N[Eigenvalues[H], 8]];
(* naive objective (user's literal l1/2+l2/2+l3, l3<=2 r alpha): threshold *)
rn = r /. FindRoot[2 ArcCos[r/2] + 4 ArcSin[1/r] == Pi, {r, 185/100}, WorkingPrecision -> 30];
Print["naive bound (overlap of C3 with C1 allowed): r <= ", N[rn, 15]];
(* coarse global grid at r = R6 + 1e-3 (evidence only) *)
r1 = R6ref + 10^-3;
gr = Max[Table[If[p + q <= 2 && With[{g0 = geo[r1, p, q]}, (g0["P"] - g0["Q1"]) . (g0["P"] - g0["Q1"]) <= 4], F[r1, p, q], -10],
    {p, r1 - 1 + 0.002, 1.25, 0.004}, {q, r1 - 1 + 0.002, 1.25, 0.004}]];
Print["grid max F at R6+1e-3: ", gr];
