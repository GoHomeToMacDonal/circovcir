(* Shared helpers for the n=5 certificates 09d.. (proofs/09-n5-independent.md §6').
   All quantities are evaluated on Interval inputs (machine-precision Interval arithmetic, outward
   rounded by the Wolfram kernel).  Geometry:
     A(R,psi) = R (Sin psi, -Cos psi),  B(d,phi) = (Sin phi, d - Cos phi),
     T_R = (Sqrt[R^2 - yT^2], yT),  yT = (R^2 + d^2 - 1)/(2 d),  psiT = Pi - ArcCos[yT/R],
     alpha = ArcSin[1/R],  c = psiT - 2 alpha.
   fitsFalseQ[{p1,p2,p3}] == True certifies: NO unit disk contains p1, p2, p3 (for every point
   choice inside the interval boxes).  Criterion (proofs/09 §6'): three congruent unit disks
   D(p_i,1) have a common point iff all pairwise distances <= 2 and some vertex of some pairwise
   lens lies within distance 1 of the third centre.  Vertices use Sqrt[Max[0, 1 - L^2/4]]: when a
   pair is at distance > 2 the triple is empty anyway, so clamping keeps the test sound. *)

n5A[R_, p_] := R {Sin[p], -Cos[p]};
n5B[d_, p_] := {Sin[p], d - Cos[p]};
n5yT[R_, d_] := (R^2 + d^2 - 1)/(2 d);
n5TR[R_, d_] := With[{y = n5yT[R, d]}, {Sqrt[R^2 - y^2], y}];
n5TL[R_, d_] := With[{y = n5yT[R, d]}, {-Sqrt[R^2 - y^2], y}];
n5psiT[R_, d_] := Pi - ArcCos[n5yT[R, d]/R];
n5al[R_] := ArcSin[1/R];

ivMin[x_Interval] := Min[x];
ivMin[x_?NumericQ] := x;
ivMax[x_Interval] := Max[x];
ivMax[x_?NumericQ] := x;
sq[v_] := v[[1]]^2 + v[[2]]^2;

lensVerts[pi_, pj_] := Module[{m = (pi + pj)/2, u = pj - pi, L2, h, n},
   L2 = sq[u];
   h = Sqrt[IntervalIntersection[Interval[{0, 1}], 1 - L2/4] /. Interval[] -> Interval[{0, 0}]];
   n = {u[[2]], -u[[1]]}/Sqrt[L2];
   {m + h n, m - h n}];

fitsFalseQ[{p1_, p2_, p3_}] := Module[{prs = {{p1, p2, p3}, {p2, p3, p1}, {p3, p1, p2}}},
   Or[
    AnyTrue[prs, ivMin[sq[#[[1]] - #[[2]]]] > 4 &],
    AllTrue[prs, Function[t, AllTrue[lensVerts[t[[1]], t[[2]]], ivMin[sq[# - t[[3]]]] > 1 &]]]]];

(* IG' on an (R,d,psi) box with an inner phi sweep over [-phimax, phimax] in nc cells.
   Returns True if certified: every cell possibly in S4 lies strictly left of every cell possibly in S3. *)
igBoxQ[RI_, dI_, psI_, phimax_, nc_] := Module[{al, c, P, cuts, s3, s4, cellsS3, cellsS4},
   al = n5al[RI]; c = n5psiT[RI, dI] - 2 al; P = n5A[RI, psI];
   cuts = Table[-phimax + 2 phimax k/nc, {k, 0, nc}];
   cellsS3 = {}; cellsS4 = {};
   Do[With[{Q = n5B[dI, Interval[{cuts[[k]], cuts[[k + 1]]}]]},
      If[! fitsFalseQ[{P, Q, n5A[RI, c]}], AppendTo[cellsS3, k]];
      If[! fitsFalseQ[{P, Q, n5A[RI, -c]}], AppendTo[cellsS4, k]]], {k, nc}];
   Which[cellsS3 === {} || cellsS4 === {}, True, True, Max[cellsS4] < Min[cellsS3]]];
