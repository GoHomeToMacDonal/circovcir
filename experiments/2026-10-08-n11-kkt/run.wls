#!/usr/bin/env wolframscript
(* n=11 Melissen cover: KKT multiplier system for  max R  s.t.  h_t(c,R) <= 0,
   t over the 18 active tight points (9 interior Voronoi vertices, 9 boundary points).
   h_t > 0 <=> a hole opens at tight point t:
     interior (i,j,k): circumradius^2(c_i,c_j,c_k) - 1
     boundary (i,j)  : R^2 - |y_ij|^2, y_ij = outer intersection of unit circles at c_i,c_j
   Steps: (1) first-order KKT in FULL coordinates (no symmetry assumed) at the stored
   40-digit config; (2) square symmetric KKT system (22x22) solved by FindRoot at wp;
   (3) recheck lambda signs, uniqueness, and 2nd-order condition on the tangent space.
   Usage: wolframscript -file run.wls [wp=80] *)

here = DirectoryName[ExpandFileName[$InputFileName]];
root = ParentDirectory[ParentDirectory[here]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
wp = If[Length[args] >= 1, ToExpression[args[[1]]], 80];

js = Import[FileNameJoin[{root, "experiments", "2026-10-02-n11-melissen", "tight_optimal.json"}], "RawJSON"];
c0 = Map[SetPrecision[ToExpression[#], 60] &, js["centers"], {2}];
R0 = SetPrecision[ToExpression[js["R"]], 60];

(* centers order: 1 S0, 2 S1, 3 S2, 4 p1, 5 p1', 6 p2, 7 p2', 8 p3, 9 p3', 10 p4, 11 p4' *)
zv = Array[z, 23];                       (* z[2i-1],z[2i] = center i ; z[23] = R *)
cen[i_] := {zv[[2 i - 1]], zv[[2 i]]};
RR = zv[[23]];
cross[a_, b_] := a[[1]] b[[2]] - a[[2]] b[[1]];
hInt[i_, j_, k_] := Module[{a = cen[j] - cen[i], b = cen[k] - cen[i]},
   (a.a) (b.b) ((a - b).(a - b))/(4 cross[a, b]^2) - 1];
yOut[i_, j_, s_] := Module[{d = cen[j] - cen[i], w, m},
   w = {-d[[2]], d[[1]]}; m = (cen[i] + cen[j])/2;
   m + s Sqrt[1/(w.w) - 1/4] w];
z0 = Append[Flatten[c0], R0];
rule0 = Thread[zv -> z0];
pickS[i_, j_] := If[(#.# &[yOut[i, j, 1] /. rule0]) > (#.# &[yOut[i, j, -1] /. rule0]), 1, -1];
hBnd[i_, j_] := Module[{y = yOut[i, j, pickS[i, j]]}, RR^2 - y.y];

(* active set; mirror twins listed adjacently, tag = representative name *)
cons = {
  {"A", hInt[1, 2, 8]}, {"A'", hInt[1, 2, 9]},
  {"B", hInt[1, 6, 8]}, {"B'", hInt[1, 7, 9]},
  {"C", hInt[2, 3, 4]}, {"C'", hInt[2, 3, 5]},
  {"D", hInt[2, 4, 8]}, {"D'", hInt[2, 5, 9]},
  {"E", hInt[1, 10, 11]},
  {"F", hBnd[3, 4]}, {"F'", hBnd[3, 5]},
  {"G", hBnd[4, 8]}, {"G'", hBnd[5, 9]},
  {"H", hBnd[6, 8]}, {"H'", hBnd[7, 9]},
  {"I", hBnd[6, 10]}, {"I'", hBnd[7, 11]},
  {"J", hBnd[10, 11]}};
names = cons[[All, 1]]; h = cons[[All, 2]];
Ghess = D[h, {zv}];                       (* 18 x 23 symbolic Jacobian *)

report[zz_, tag_] := Module[{r = Thread[zv -> zz], G, eR, lam, res, nul, hv},
  hv = h /. r; G = N[Ghess /. r, wp/2];
  eR = UnitVector[23, 23];
  lam = LeastSquares[Transpose[G], eR];
  res = Norm[Transpose[G].lam - eR];
  nul = NullSpace[Transpose[G], Tolerance -> 10^-(wp/4)];
  Print["--- ", tag, " ---"];
  Print["max|h_t|            = ", ScientificForm[N[Max[Abs[hv]], 4]]];
  Print["rank G (18 rows)    = ", MatrixRank[G, Tolerance -> 10^-(wp/4)]];
  Print["KKT residual |G^T lam - e_R| = ", ScientificForm[N[res, 4]]];
  Print["dim null(G^T) (lambda non-uniqueness) = ", Length[nul]];
  Print["lambda: ", StringRiffle[MapThread[#1 <> "=" <> ToString[NumberForm[N[#2], 8]] &, {names, lam}], "  "]];
  lam];

lam0 = report[z0, "stored config (R from machine-precision FindMaximum)"];

(* ---- square symmetric KKT system ---- *)
q = {qa, qb, qg, qu1, qv1, qu2, qv2, qu3, qv3, qu4, qv4};
symz = Join[{0, qa, 0, qb, 0, qg, qu1, qv1, -qu1, qv1, qu2, qv2, -qu2, qv2,
    qu3, qv3, -qu3, qv3, qu4, qv4, -qu4, qv4}, {qR}];
reps = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J"};
lv = Array[l, 10];
lamFull = (lv[[First@First@Position[reps, StringDelete[#, "'"]]]]) & /@ names;
Lag = RR - lamFull.h;                     (* stationarity of the Lagrangian *)
symRule = Thread[zv -> symz];
hrep = Pick[h, StringFreeQ[#, "'"] & /@ names] /. symRule;
gradL = D[Lag /. symRule, {Append[q, qR]}];
eqs = Join[hrep, gradL];
Print["symmetric KKT: #eqs = ", Length[eqs], "  #unknowns = ", Length[q] + 1 + 10];
qseed = {z0[[2]], z0[[4]], z0[[6]], z0[[7]], z0[[8]], z0[[11]], z0[[12]], z0[[15]], z0[[16]],
   z0[[19]], z0[[20]], R0};
lseed = Table[lam0[[First@First@Position[names, reps[[k]]]]], {k, 10}];
sol = FindRoot[eqs, Transpose[{Join[Append[q, qR], lv], SetPrecision[Join[qseed, lseed], wp]}],
   WorkingPrecision -> wp, MaxIterations -> 200, AccuracyGoal -> wp - 10, PrecisionGoal -> wp - 10];
zK = symz /. sol;
Print["max |KKT eq| at solution = ", ScientificForm[N[Max[Abs[eqs /. sol]], 4]]];
Print["R_KKT    = ", N[qR /. sol, 60]];
Print["R_stored = ", N[R0, 40]];
Print["R_KKT - R_stored = ", ScientificForm[N[(qR /. sol) - R0, 4]]];
lamK = report[zK, "KKT solution (full coordinates, no symmetry assumed)"];

(* ---- 2nd order: Hessian of Lagrangian on tangent space of active set, rotation removed ---- *)
rK = Thread[zv -> zK];
HL = N[D[RR - lamK.h, {zv, 2}] /. rK, wp/2];
GK = N[Ghess /. rK, wp/2];
T = NullSpace[GK, Tolerance -> 10^-(wp/4)];
rot = Append[Flatten[{-#[[2]], #[[1]]} & /@ Partition[Most[zK], 2]], 0];
Print["dim tangent space = ", Length[T], "  (rotation in it: residual ",
  ScientificForm[N[Norm[GK.rot], 3]], ")"];
Tp = Orthogonalize[Prepend[T, N[rot, wp/2]]][[2 ;;]];
Tp = Select[Tp, Norm[#] > 10^-(wp/4) &];
ev = Sort[Eigenvalues[Tp.HL.Transpose[Tp]]];
Print["2nd-order eigenvalues on tangent space / rotation (want all < 0 for strict local max): ",
  NumberForm[N[ev], 8]];

(* ---- independent coverage check of the KKT configuration ---- *)
cK = Partition[Most[zK], 2]; RK = Last[zK];
Print["CoveringRadius(c_KKT, R_KKT) = ", N[CoveringRadius[cK, RK, WorkingPrecision -> wp], 30]];

dec[x_] := ToString[N[x, 60], InputForm, NumberMarks -> False];
Export[FileNameJoin[{here, "kkt_solution.json"}],
  <|"R" -> dec[RK], "centers" -> Map[dec, cK, {2}],
    "lambda" -> AssociationThread[names, dec /@ lamK], "second_order_eigs" -> (dec /@ ev),
    "wp" -> wp|>, "RawJSON", "Compact" -> False];
