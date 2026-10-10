#!/usr/bin/env wolframscript
(* rad_scan_slope.wls -- numeric exploration (NOT a certificate).
   Krawczyk with a second-order slope enclosure instead of the naive J(X):
     F(x) - F(u~) = S(x,u~) (x-u~),  S = Int_0^1 J(u~ + t d) dt
     S in  J(u~) + 1/2 Sum_k dJ/du_k(X) * [-r_k, r_k]      (valid for x in X = u~ +- r)
   K(X) = u~ - Y F(u~) + (I - Y S)(X - u~).
   Also tries a weighted box r_k = rad * w_k (w = row-scaling from the contraction matrix). *)
SetDirectory[DirectoryName[ExpandFileName[$InputFileName]]];
ip = 120;
Get["kkt_setup.wl"];
n = Length[uvars];
Print["building dJ tensor ..."];
T = D[Jsys, {uvars}];                          (* n x n x n *)
uIv = iv /@ ut;
J0 = Jsys /. Thread[uvars -> uIv];             (* rigorous enclosure of J(u~) *)
FX = Fsys /. Thread[uvars -> uIv];
YF = Y . FX;
A0 = IdentityMatrix[n] - Y . J0;               (* ~ 0 *)

testS[r_List] := Module[{X, TX, corr, M, Kx, inside, contr},
  X = MapThread[Interval[{N[#1 - #2, ip], N[#1 + #2, ip]}] &, {ut, r}];
  TX = T /. Thread[uvars -> X];
  corr = (1/2) Sum[TX[[All, All, k]] Interval[{-r[[k]], r[[k]]}], {k, n}];
  M = A0 - Y . corr;
  Kx = uIv - YF + M . (X - uIv);
  inside = And @@ MapThread[(Min[#1] > Min[#2] && Max[#1] < Max[#2]) &, {Kx, X}];
  (* per-component: |K - u~|_max / r_k  (must be < 1) *)
  contr = MapThread[Max[Abs[{Min[#1 - #3], Max[#1 - #3]}]]/#2 &, {Kx, r, ut}];
  {inside, N[Max[contr], 6], N[contr, 4]}];

Print["\n-- uniform box, slope form --"];
Do[Module[{res = TimeConstrained[testS[ConstantArray[10^e, n]], 300, $Aborted]},
   Print["rad=10^", N[e, 3], "  in=", res[[1]], "  maxRatio=", res[[2]]]],
  {e, {-4, -3.5, -3, -2.5, -2}}];

lo = -3.5; hi = -1.5;
Do[Module[{m = (lo + hi)/2}, If[testS[ConstantArray[10^m, n]][[1]], lo = m, hi = m]], {12}];
Print["uniform slope threshold: rad = ", ScientificForm[N[10^lo, 4]]];
resU = testS[ConstantArray[10^lo, n]];
Print["per-component ratio at threshold: ", resU[[3]]];

(* weighted box: one fixed-point step, r_k proportional to how much room component k has *)
Print["\n-- weighted box --"];
w = ConstantArray[1, n];
Do[Module[{lo2 = -4., hi2 = 0., res},
   Do[Module[{m = (lo2 + hi2)/2}, If[testS[10^m w][[1]], lo2 = m, hi2 = m]], {12}];
   res = testS[10^lo2 w];
   Print["iter ", it, ": scale=", ScientificForm[N[10^lo2, 4]], "  min r_k=",
     ScientificForm[N[Min[10^lo2 w], 4]], "  max r_k=", ScientificForm[N[Max[10^lo2 w], 4]]];
   (* enlarge components with slack, shrink tight ones *)
   w = w / Sqrt[Max[#, 10^-3] & /@ res[[3]]]; w = w/Min[w]], {it, 3}];
Print["final weights (rel. to min): ", N[w, 3]];
Print["uvars order: ", uvars];
