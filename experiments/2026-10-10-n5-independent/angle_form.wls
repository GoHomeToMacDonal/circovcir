#!/usr/bin/env wolframscript
(* Angle form of the reduced right-half condition (psi measured from the bottom point (0,-R)):
   psiT(R,d) <= 2 ArcSin[1/R] + 2 psi3(R,d)
   psiT = Pi - ArcCos[(R^2+d^2-1)/(2 d R)]                    (corner T = dCn ∩ dC1)
   psi3 = ArcTan[(R+1-d)/2, Sqrt[1-((R+d-1)/2)^2]]            (polar angle of D3 centre from bottom)
   Checks: (1) max_d gives R5 (octic root), (2) B-arc slack at optimum, (3) D3-lemma numerically. *)
psiT[R_, d_] := Pi - ArcCos[(R^2 + d^2 - 1)/(2 d R)];
psi3[R_, d_] := ArcTan[(R + 1 - d)/2, Sqrt[1 - ((R + d - 1)/2)^2]];
gap[R_, d_] := 2 ArcSin[1/R] + 2 psi3[R, d] - psiT[R, d];
octic = 625 t^8 - 800 t^7 + 22 t^6 - 1776 t^5 + 1665 t^4 + 1360 t^3 - 3480 t^2 + 2112 t + 1296;
R5 = t /. FindRoot[octic == 0, {t, 16/10}, WorkingPrecision -> 80]; Print["R5 = ", N[R5, 30]];
(* (1) at R5, max_d gap = 0 *)
mx = FindMaximum[gap[R5, d], {d, 0.95}, WorkingPrecision -> 50];
Print["(1) max_d gap(R5,d) = ", N[mx[[1]], 5], " at d = ", N[d /. mx[[2]], 25]];
dstar = d /. mx[[2]];
Print["    max_d gap(R5+1e-6,d) = ", N[First@FindMaximum[gap[R5 + 10^-6, d], {d, 0.95}, WorkingPrecision -> 40], 5]];
(* (2) B-arc coverage: B(phi) = (Sin phi, d - Cos phi), phi in [0, phiT] right side *)
Module[{R = R5, d = dstar, yT, T, c3, XA, c2, phiT, distB, cov},
  yT = (R^2 + d^2 - 1)/(2 d); T = {Sqrt[R^2 - yT^2], yT};
  c3 = {Sqrt[1 - ((R + d - 1)/2)^2], (d - 1 - R)/2};
  XA = 2 (c3 . {0, -R}) c3/(c3 . c3) - {0, -R}; c2 = (T + XA)/2;
  phiT = ArcTan[d - yT, T[[1]]];
  (* angular B-intervals (about centre (0,d), phi from bottom) covered by D2, D3 *)
  cov = Function[c, Module[{q = c - {0, d}, pc, w}, pc = ArcTan[-q[[2]], q[[1]]]; w = ArcCos[Norm[q]/2]; {pc - w, pc + w}]];
  Print["(2) right B-arc = [0, ", N[phiT, 12], "];  D3 covers ", N[cov[c3], 12], ";  D2 covers ", N[cov[c2], 12]];
  Print["    B-junction overlap (D3 upper - D2 lower) = ", N[cov[c3][[2]] - cov[c2][[1]], 12], "  (>0 => B constraint slack)"];
  Print["    c2 = ", N[c2, 12], "  c3 = ", N[c3, 12], "  |c2-c3| = ", N[Norm[c2 - c3], 10]];
  Print["    region check: CoveringRadius of mirrored 5-config on D(0,R5): "];
  PrependTo[$Path, FileNameJoin[{DirectoryName[$InputFileName], "..", "..", "wl"}]]; Needs["CirCovCir`"];
  cfg = {{0, d}, c2, c3, {-1, 1} c3, {-1, 1} c2};
  Print["    ", N[CirCovCir`CoveringRadius[cfg, R, WorkingPrecision -> 40], 20]];
];
(* (3) D3 lemma: among unit disks containing (0,-R) and (0,d-1), max upper A-reach psi_c + w (with psi_c - w <= 0)
   is attained with both points on the boundary -> reach = 2 psi3 *)
Module[{R = R5, d = dstar, reach, sol},
  reach[x_?NumericQ, y_?NumericQ] := Module[{r = Norm[{x, y}], pc, w},
    pc = ArcTan[-y, x]; w = ArcCos[Clip[(R^2 + r^2 - 1)/(2 R r), {-1, 1}]]; pc + w];
  sol = NMaximize[{reach[x, y], x^2 + (y + R)^2 <= 1, x^2 + (y - d + 1)^2 <= 1, x >= 0}, {x, y},
    Method -> "DifferentialEvolution", WorkingPrecision -> 20];
  Print["(3) max reach = ", N[sol[[1]], 12], " vs 2 psi3 = ", N[2 psi3[R, d], 12], " at ", N[{x, y} /. sol[[2]], 10]];
];
