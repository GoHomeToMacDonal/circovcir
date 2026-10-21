#!/usr/bin/env wolframscript
(* Computational gates for proofs/11-n11-global-reduction.md.
   This is NOT a certificate of global optimality. No randomness.
   Exact input intervals are converted using N[Interval[...], 70], so both
   endpoints enclose the exact inputs before subsequent interval operations. *)
root = DirectoryName[DirectoryName[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
wp = 70;
iv[x_] := N[Interval[{x, x}], wp];
box[x_, y_] := N[Interval[{x, y}], wp];
gates = <||>;
gate[name_, test_] := (gates[name] = TrueQ[test]; Print[name, " : ", gates[name]]);
r0 = 263169/100000;
r = iv[r0]; pi = iv[Pi];
oneArc = CirCovCir`MaxCoveredArc[r0];
commonArc = CirCovCir`MaxCoveredArcTriple[r0];
a = iv[oneArc]/2; b = iv[commonArc]/2;

(* The single-disk arc formula is sharp at n=3,4,7. No new coverage verifier. *)
gate["calibration_arc_n3_n4_n7", And @@ Table[
  TrueQ[FullSimplify[CirCovCir`MaxCoveredArc[1/Sin[Pi/k]] == 2 Pi/k]],
  {k, {3, 4, 6}}]];
gate["C1_radius_above_two", r0 > 2];
gate["C2_eight_arcs_insufficient", Max[8 a] < Min[pi]];
gate["C3_nine_with_common_four_insufficient", Max[b + 5 a] < Min[pi]];
gate["C4_nine_with_two_disjoint_triples_insufficient", Max[2 b + 3 a] < Min[pi]];
gate["C5_ten_with_common_five_insufficient", Max[b + 5 a] < Min[pi]];
gate["C6_ten_with_three_disjoint_triples_insufficient", Max[3 b + a] < Min[pi]];
Print["C2 margin = ", InputForm[pi - 8 a]];
Print["C3/C5 margin = ", InputForm[pi - b - 5 a]];
Print["C4 margin = ", InputForm[pi - 2 b - 3 a]];
Print["C6 margin = ", InputForm[pi - 3 b - a]];

(* These weaker tests fail; they must NOT be used as exclusions. *)
gate["D1_one_triple_arc_test_does_not_exclude_b9", Min[b + 6 a - pi] > 0];
gate["D2_two_triples_arc_test_does_not_exclude_b10", Min[2 b + 4 a - pi] > 0];
Print["D1 excess = ", InputForm[b + 6 a - pi]];
Print["D2 excess = ", InputForm[2 b + 4 a - pi]];

(* Conditional area exclusion of the ten-spoke Voronoi wheel.
   F(alpha) = circular segment + the maximal unit triangle.
   Only concavity on [Pi/3, Pi] is needed. For smaller alpha use alpha/2. *)
(* The fixed-chord circular segment decreases with target radius. *)
segexpr = rr^2 ArcSin[s/rr] - s Sqrt[rr^2 - s^2];
gate["W0_segment_radius_derivative", TrueQ[FullSimplify[
  D[segexpr, rr] == 2 rr (ArcSin[s/rr] - s/Sqrt[rr^2 - s^2]), rr > s > 0]]];
gate["W0_segment_monotonicity_identity", TrueQ[FullSimplify[
  D[u/Sqrt[1 - u^2] - ArcSin[u], u] == u^2/(1 - u^2)^(3/2), 0 < u < 1]]];
fexpr = 2 ArcSin[Sin[alpha/2]/rr];
Fexpr = rr^2/2 (fexpr - Sin[fexpr]) + Sin[alpha]/2;
Fp = D[Fexpr, alpha];
Fpp = FullSimplify[D[Fexpr, {alpha, 2}], rr > 2 && 0 < alpha < Pi];
F[x_] := Fexpr /. {alpha -> x, rr -> r};
t0 = 21/10;
F0 = F[iv[t0]];
slopeF = Fp /. {alpha -> iv[t0], rr -> r};
np = 1024;
curv = Table[Fpp /. {rr -> r, alpha -> box[Pi/3 + (2 Pi/3) j/np,
    Pi/3 + (2 Pi/3) (j + 1)/np]}, {j, 0, np - 1}];
gate["W1_F_strictly_concave_on_large_angles", And @@ (TrueQ[Max[#] < 0] & /@ curv)];
Print["W1 worst upper = ", Max[Max /@ curv]];
gate["W2_tangent_slope_below_half", Max[slopeF] < 1/2];
smallGap = F0 + slopeF (pi/3 - iv[t0]) - pi/6;
gate["W3_tangent_above_small_angle_sector", Min[smallGap] > 0];
beta0 = 9 pi/10 - iv[t0]/2;
slopeG = slopeF - Cos[beta0]/2;
upper = 10 (Sin[pi/5] + Sin[beta0] + F0 + pi Abs[slopeG]);
gap = pi r^2 - upper;
gate["W4_wheel_area_strictly_insufficient", Min[gap] > 0];
Print["W3 margin = ", InputForm[smallGap]];
Print["W4 area bound = ", InputForm[upper]];
Print["W4 area gap = ", InputForm[gap]];

If[And @@ Values[gates],
  Print["CERTIFICATE OK (L3): n=11 arc reductions and CONDITIONAL wheel exclusion; global optimum NOT proved"];
  Exit[0], Print["CERTIFICATE FAILED"]; Exit[1]];
