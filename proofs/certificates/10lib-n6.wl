(* Shared helpers for the n=6 half-problem certificates 10a..10d (proofs/10-n6-half.md).
   Geometry (right half x >= 0):
     Cn = D(0,R),  C1 = D((0,a),1),  C2 = D((0,-b),1),  alpha = ArcSin[1/R].
     T1 = dC1 cap dCn (x>0),  T2 = dC2 cap dCn (x>0),  V = dC1 cap dC2 (x>=0).
     X(w) = Rot(-(2 alpha - w)) . T1,  w in [0, 2 alpha]  (the arc point at angular
     distance 2 alpha - w clockwise from T1;  w = 0 <=> |T1 X| = 2).
   Domain:  a, b >= R - 1,  a + b <= 2.
   Square roots use n6sqrt = Sqrt[Max[0, .]] (interval-intersected with [0, oo)) so that a box
   straddling the domain edge stays real; on the domain the clamp is the identity. *)

n6sqrt[x_Interval] := Sqrt[IntervalIntersection[x, Interval[{0, Infinity}]] /. Interval[] -> Interval[{0, 0}]];
n6sqrt[x_?NumericQ] := Sqrt[Max[0, x]];
n6sqrt[x_] := Sqrt[x];   (* symbolic: used only where the radicand is provably > 0 *)

n6y1[R_, a_] := (R^2 + a^2 - 1)/(2 a);
n6y2[R_, b_] := -(R^2 + b^2 - 1)/(2 b);
n6T1[R_, a_] := With[{y = n6y1[R, a]}, {n6sqrt[R^2 - y^2], y}];
n6T2[R_, b_] := With[{y = n6y2[R, b]}, {n6sqrt[R^2 - y^2], y}];
n6V[a_, b_] := {n6sqrt[1 - ((a + b)/2)^2], (a - b)/2};
n6al[R_] := ArcSin[1/R];
n6rot[t_, p_] := {Cos[t] p[[1]] + Sin[t] p[[2]], -Sin[t] p[[1]] + Cos[t] p[[2]]};  (* clockwise by t *)
n6X[R_, a_, w_] := n6rot[2 n6al[R] - w, n6T1[R, a]];

(* exact-algebraic X0 = X(0): cos(2 alpha) = 1 - 2/R^2, sin(2 alpha) = 2 Sqrt[R^2-1]/R^2 *)
n6X0[R_, a_] := With[{c = 1 - 2/R^2, s = 2 Sqrt[R^2 - 1]/R^2, T = n6T1[R, a]},
   {c T[[1]] + s T[[2]], -s T[[1]] + c T[[2]]}];

n6sq[v_] := v[[1]]^2 + v[[2]]^2;
n6cross[u_, v_] := u[[1]] v[[2]] - u[[2]] v[[1]];
(* circumradius^2 of triangle P,Q,S *)
n6circR2[P_, Q_, S_] := n6sq[Q - P] n6sq[S - P] n6sq[S - Q]/(4 n6cross[Q - P, S - P]^2);

ivMin[x_Interval] := Min[x];
ivMin[x_?NumericQ] := x;
ivMax[x_Interval] := Max[x];
ivMax[x_?NumericQ] := x;

(* fitsFalseQ[{p1,p2,p3}] == True certifies: NO closed unit disk contains p1, p2, p3 (for every
   choice of points in the interval boxes).  Same criterion as 09lib-n5.wl (proofs/09 §6'):
   D(p1,1), D(p2,1), D(p3,1) have a common point iff all pairwise distances <= 2 and some vertex of
   some pairwise lens is within distance 1 of the third centre.  Clamped Sqrt keeps the test sound. *)
n6lensVerts[pi_, pj_] := Module[{m = (pi + pj)/2, u = pj - pi, L2, h, n},
   L2 = n6sq[u];
   h = Sqrt[IntervalIntersection[Interval[{0, 1}], 1 - L2/4] /. Interval[] -> Interval[{0, 0}]];
   n = {u[[2]], -u[[1]]}/Sqrt[L2];
   {m + h n, m - h n}];
n6fitsFalseQ[{p1_, p2_, p3_}] := Module[{prs = {{p1, p2, p3}, {p2, p3, p1}, {p3, p1, p2}}},
   Or[
    AnyTrue[prs, ivMin[n6sq[#[[1]] - #[[2]]]] > 4 &],
    AllTrue[prs, Function[t, AllTrue[n6lensVerts[t[[1]], t[[2]]], ivMin[n6sq[# - t[[3]]]] > 1 &]]]]];

(* Generic bisection prover.  pred[box] -> True (certified on the whole box), False (undecided),
   or "skip" (box lies outside the domain).  Splits the widest coordinate (relative to scale).
   Returns True iff every leaf certified within maxDepth.  Counts boxes in n6boxes. *)
n6boxes = 0; n6stuck = {};
n6prove[pred_, box_, scale_, depth_] := Module[{v},
   n6boxes++;
   v = Quiet[pred[box]];
   Which[v === True || v === "skip", True,
    depth == 0, (AppendTo[n6stuck, box]; False),
    True, Module[{k = Ordering[(#[[2]] - #[[1]]) & /@ box / scale, -1][[1]], m, lo, hi},
     m = (box[[k, 1]] + box[[k, 2]])/2;
     lo = ReplacePart[box, k -> {box[[k, 1]], m}]; hi = ReplacePart[box, k -> {m, box[[k, 2]]}];
     n6prove[pred, lo, scale, depth - 1] && n6prove[pred, hi, scale, depth - 1]]]];
