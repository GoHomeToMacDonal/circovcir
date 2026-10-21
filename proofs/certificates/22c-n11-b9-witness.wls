#!/usr/bin/env wolframscript
(* proofs/22 certificate 22c -- independent Wolfram re-check of computation C2 (sec.11, Corollary W2)
   of experiments/2026-10-20-siege-n11-b9/out/proof.md: for every split label m = 1..8 the system
   Sigma_m has no solution at R = 26317/10000.

   Written from Part W (angle polytope Phi, Theorem C, relaxed system P~_m(B), half-plane lemma,
   Lemma M35, Lemma D'), NOT from wit_exact.py / ms5_witness.py.  Independent choices:
     * own branch-and-bound tree (root [0,7]^8, exact constraint propagation, bisection of the
       widest coordinate, own root split);
     * multipliers found by solving the DUAL of P~_m(B) directly as a second-order-cone program
       (minimise sum|y_e| + sum r_j|z_j| - sum mu_i h_i + M sum_v |g_v|  s.t.  sum mu = 1, mu >= 0,
       g_v the net force at v) with SecondOrderConeOptimization -- i.e. the exact objective V of
       Lemma D' (the residual g is NOT forced to 0; Lemma D' charges it at M = 7/2 per unit);
     * load-bearing check V < 0 of Lemma D' in exact rational arithmetic: rationals of the floats,
       exact net forces g_v, norms bounded above by self-verified integer square roots, M = 7/2;
     * half-plane offsets h_k: rigorous lower bounds of R (n.s(t)) at both ends, from precision-30
       bignum Interval evaluation of Cos/Sin at the exact rational endpoints (sanity-tested below).
   Trust base: exactness of Mathematica rational/integer arithmetic, correctness of its bignum
   Interval Cos/Sin/ArcSin and of N[Interval[{Pi,Pi}],30]; floats only choose certificate data.
   Usage: wolframscript -file 22c-n11-b9-witness.wls [m-list|pilot] [nkernels]
   Prints "22c ALL m CERTIFIED" and exits 0 on success. *)

Internal`$EqualTolerance = 0;
args = Rest[$ScriptCommandLine];
mode = If[Length[args] >= 1, args[[1]], "all"];
nKer = If[Length[args] >= 2, ToExpression[args[[2]]], 16];

defs = Hold[
  Internal`$EqualTolerance = 0;
  ex[x_] := SetPrecision[x, Infinity];
  lo[x_Interval] := ex[Min[x]]; hi[x_Interval] := ex[Max[x]];
  (* rational upper bound of Sqrt[q], q >= 0 rational: integer square root, verified exactly *)
  isqrtFloor[n_Integer] := Module[{s = Floor[Sqrt[n]]},
    While[s^2 > n, s--]; While[(s + 1)^2 <= n, s++]; s];
  sqrtUp[q_] := If[q == 0, 0, With[{a = Numerator[q], b = Denominator[q], K = 2^64},
     (isqrtFloor[a b K^2] + 1)/(b K)]];
  M35 = 7/2;
  (* ---- data depending on R (exact rational) ---- *)
  setR[Rv_] := (
    Rex = Rv;
    TPL = lo[N[Interval[{2 Pi, 2 Pi}], 30]]; TPH = hi[N[Interval[{2 Pi, 2 Pi}], 30]];   (* TPL <= 2Pi <= TPH *)
    Aup = hi[N[Interval[{2 ArcSin[1/Rv], 2 ArcSin[1/Rv]}], 30]];                         (* Aup >= 2a *)
    RHO = sqrtUp[Rv^2 - 1]);                                                             (* RHO >= rho_max *)
  (* ---- unknown points: 1 cE, 2 cF, 2+k c_k, 11+k p_k, 21 t_1, 22 t_{m+1}, 22+k sigma_k ---- *)
  iE = 1; iF = 2; ic[k_] := 2 + k; ip[k_] := 11 + k; iT1 = 21; iT2 = 22; is[k_] := 22 + k; nPts = 31;
  (* Theorem C, transcribed: (P2) (c_k, s(phi_{k-1})), (c_k, s(phi_k)) with s(phi_0) = s(phi_9) = sigma_9;
     (P3) (p_k, c_k), (p_k, c_{k+1}), (p_k, X_k), X_k = cE for k <= m else cF;
     (P4) (t_1, c_1), (t_1, cE), (t_1, cF), (t_{m+1}, c_{m+1}), (t_{m+1}, cE), (t_{m+1}, cF) *)
  pairsFor[m_] := Join[
    Flatten[Table[{{ic[k], is[If[k == 1, 9, k - 1]]}, {ic[k], is[k]}}, {k, 9}], 1],
    Flatten[Table[{{ip[k], ic[k]}, {ip[k], ic[Mod[k, 9] + 1]}, {ip[k], If[k <= m, iE, iF]}}, {k, 9}], 1],
    {{iT1, ic[1]}, {iT1, iE}, {iT1, iF}, {iT2, ic[m + 1]}, {iT2, iE}, {iT2, iF}}];
  (* anchors |x_v| <= r: cE <= 1, c_k <= RHO, sigma_k <= R *)
  anchors[] := Join[{{iE, 1}}, Table[{ic[k], RHO}, {k, 9}], Table[{is[k], Rex}, {k, 9}]];

  (* ---- propagation of 0 <= phi_k - phi_{k-1} <= 2a on a box (phi_0 = 0, phi_9 in [TPL,TPH]) ---- *)
  propagate[{l0_, h0_}] := Module[{l = Join[{0}, l0, {TPL}], h = Join[{0}, h0, {TPH}], old = Null, it = 0},
    While[{l, h} =!= old && it < 60, old = {l, h}; it++;
      Do[l[[k]] = Max[l[[k]], l[[k - 1]]]; h[[k]] = Min[h[[k]], h[[k - 1]] + Aup], {k, 2, 10}];
      Do[h[[k]] = Min[h[[k]], h[[k + 1]]]; l[[k]] = Max[l[[k]], l[[k + 1]] - Aup], {k, 9, 1, -1}];
      If[Or @@ Thread[l > h], Return[$Empty, Module]]];
    If[Or @@ Thread[l > h], $Empty, {l[[2 ;; 9]], h[[2 ;; 9]]}]];

  (* ---- half-plane data: n_k = (cos mid, sin mid) (dyadic), h_k <= R n_k.s(t) at t = lo, hi ---- *)
  halfplanes[{l_, h_}] := Module[{res = {}, mid, n, v},
    Do[If[h[[k]] - l[[k]] > 3/2, Return[$Failed, Module]];
      mid = N[(l[[k]] + h[[k]])/2]; n = ex[{Cos[mid], Sin[mid]}];
      v = Min[Table[lo[Rex (n[[1]] Cos[N[Interval[{t, t}], 30]] + n[[2]] Sin[N[Interval[{t, t}], 30]])],
          {t, {l[[k]], h[[k]]}}]];
      v = Floor[v 2^80]/2^80;
      If[!(v > 0), Return[$Failed, Module]];
      AppendTo[res, {is[k], n, v}], {k, 8}];
    Append[res, {is[9], {1, 0}, Rex}]];      (* sigma_9 = s(0) = (R, 0): n = (1,0), h = R *)

  (* ---- structure for the dual SOCP (fixed per m) ---- *)
  (* variables: y_e (2 each, 51), z_j (2 each, 19) = 140, then mu_i (9), then norm bounds s (70),
     then the residual forces g_v (2 each, 31 points) and their norm bounds sg (31) *)
  setupM[m_] := Module[{pr = pairsFor[m], an = anchors[], rows},
    pairs = pr; anch = an; nE = Length[pr]; nJ = Length[an]; nYZ = 2 (nE + nJ); nMu = 9; nS = nE + nJ;
    oG = nYZ + nMu + nS; oSG = oG + 2 nPts;
    nVar = oSG + nPts;
    (* Ayz: g_v (coords 2v-1, 2v) = sum_{a(e)=v} y_e - sum_{b(e)=v} y_e + sum_{v(j)=v} z_j *)
    rows = Join[
      Flatten[Table[With[{a = pr[[e, 1]], b = pr[[e, 2]]},
        {{2 a - 1, 2 e - 1} -> 1., {2 a, 2 e} -> 1., {2 b - 1, 2 e - 1} -> -1., {2 b, 2 e} -> -1.}], {e, nE}], 1],
      Flatten[Table[With[{v = an[[j, 1]], c = 2 nE + 2 j},
        {{2 v - 1, c - 1} -> 1., {2 v, c} -> 1.}], {j, nJ}], 1]];
    Ayz = SparseArray[rows, {2 nPts, nYZ}];
    zeroRow = SparseArray[{}, {0, nVar}];
    coneCons = Join[
      Table[{SparseArray[{{1, 2 i - 1} -> 1., {2, 2 i} -> 1.}, {2, nVar}], {0., 0.},
        SparseArray[{nYZ + nMu + i -> 1.}, nVar], 0.}, {i, nS}],
      Table[{SparseArray[{{1, oG + 2 v - 1} -> 1., {2, oG + 2 v} -> 1.}, {2, nVar}], {0., 0.},
        SparseArray[{oSG + v -> 1.}, nVar], 0.}, {v, nPts}]];
    muCons = Join[Table[{zeroRow, {}, SparseArray[{nYZ + i -> 1.}, nVar], 0.}, {i, nMu}],
      {{zeroRow, {}, SparseArray[Table[nYZ + i -> 1., {i, nMu}], nVar], -1.},
       {zeroRow, {}, SparseArray[Table[nYZ + i -> -1., {i, nMu}], nVar], 1.}}];
    rList = Join[Table[1, nE], an[[All, 2]]]];

  (* dual SOCP for the given half-planes; returns float vector or $Failed *)
  solveDual[hp_] := Module[{Amu, G, eqCons, cvec, sol},
    Amu = SparseArray[Flatten[Table[{{2 hp[[i, 1]] - 1, i} -> -N[hp[[i, 2, 1]]], {2 hp[[i, 1]], i} -> -N[hp[[i, 2, 2]]]}, {i, nMu}], 1], {2 nPts, nMu}];
    (* g (variables oG+1 .. oG+2 nPts) equals the net force Ayz.yz + Amu.mu *)
    G = ArrayFlatten[{{Ayz, Amu, SparseArray[{}, {2 nPts, nS}], -IdentityMatrix[2 nPts, SparseArray],
        SparseArray[{}, {2 nPts, nPts}]}}];
    eqCons = Join[Table[{zeroRow, {}, G[[r]], 0.}, {r, 2 nPts}], Table[{zeroRow, {}, -G[[r]], 0.}, {r, 2 nPts}]];
    cvec = Join[Table[0., nYZ], -N[hp[[All, 3]]], N[rList], Table[0., 2 nPts], Table[N[M35], nPts]];
    (* a solver warning (e.g. ::inac, tolerance not reached) is NOT a failure: any multipliers are
       admissible in Lemma D', and the exact check V < 0 below is the only load-bearing step.
       Method "CSDP": the default interior-point method stops ~1e-3 above the optimum on near-tight
       boxes (diagnosed in judge/wl/diag22c-solver.wls); CSDP reaches it.  Default kept as fallback. *)
    sol = Quiet[SecondOrderConeOptimization[cvec, Join[coneCons, muCons, eqCons], Method -> "CSDP"]];
    If[!VectorQ[sol, NumericQ], sol = Quiet[SecondOrderConeOptimization[cvec, Join[coneCons, muCons, eqCons]]]];
    If[!VectorQ[sol, NumericQ], Return[$Failed]];
    sol];

  (* exact upper bound of V of Lemma D' for the multipliers in sol (rationals of the floats) *)
  vExact[sol_, hp_] := Module[{yz = ex[sol[[1 ;; nYZ]]], mu = Max[0, #] & /@ ex[sol[[nYZ + 1 ;; nYZ + nMu]]], g, tot = 0, y},
    g = Table[0, 2 nPts];
    Do[y = yz[[2 e - 1 ;; 2 e]]; tot += sqrtUp[y . y];
      With[{a = pairs[[e, 1]], b = pairs[[e, 2]]}, g[[2 a - 1 ;; 2 a]] += y; g[[2 b - 1 ;; 2 b]] -= y], {e, nE}];
    Do[y = yz[[2 nE + 2 j - 1 ;; 2 nE + 2 j]]; tot += anch[[j, 2]] sqrtUp[y . y];
      With[{v = anch[[j, 1]]}, g[[2 v - 1 ;; 2 v]] += y], {j, nJ}];
    Do[tot -= mu[[i]] hp[[i, 3]];
      With[{v = hp[[i, 1]]}, g[[2 v - 1 ;; 2 v]] -= mu[[i]] hp[[i, 2]]], {i, nMu}];
    tot + M35 Sum[sqrtUp[g[[2 v - 1]]^2 + g[[2 v]]^2], {v, nPts}]];

  (* box test: $Empty | "cert" | "open" *)
  testBox[box_] := Module[{pb = propagate[box], hp, sol},
    If[pb === $Empty, Return[{$Empty, box}]];
    hp = halfplanes[pb]; If[hp === $Failed, Return[{"open", pb}]];
    sol = solveDual[hp]; If[sol === $Failed, Return[{"open", pb}]];
    If[vExact[sol, hp] < 0, {"cert", pb}, {"open", pb}]];
  bisect[{l_, h_}] := Module[{k = First[Ordering[h - l, -1]], m},
    m = (l[[k]] + h[[k]])/2; {{l, ReplacePart[h, k -> m]}, {ReplacePart[l, k -> m], h}}];
  (* DFS over one root box; every leaf is empty or certified, or the run records a failure *)
  runTree[box0_, budget_] := Module[{st = {box0}, b, r, n = 0, ne = 0, nc = 0, fails = {}},
    While[st =!= {}, b = Last[st]; st = Most[st]; n++;
      If[n > budget, AppendTo[fails, {"BUDGET", N[b]}]; Break[]];
      r = testBox[b];
      Switch[r[[1]], $Empty, ne++, "cert", nc++,
        _, If[Max[r[[2, 2]] - r[[2, 1]]] < 10^-7, AppendTo[fails, {"OPEN", N[r[[2]]]}],
             st = Join[st, bisect[r[[2]]]]]]];
    {n, ne, nc, fails}];
];
ReleaseHold[defs];

(* ---------------- sanity tests ---------------- *)
setR[26317/10000];
s1 = Pi > 0 && TPL <= 2 Pi <= TPH && Aup >= 2 ArcSin[1/Rex] && RHO >= Sqrt[Rex^2 - 1] && RHO <= 245/100 &&
   And @@ Table[With[{q = RandomInteger[{1, 10^30}]/RandomInteger[{1, 10^20}]}, sqrtUp[q] >= Sqrt[q] && sqrtUp[q] - Sqrt[q] < 10^-18], {200}] &&
   And @@ Table[With[{t = RandomInteger[{0, 7*10^20}]/10^20},
     lo[Cos[N[Interval[{t, t}], 30]]] <= N[Cos[t], 60] <= hi[Cos[N[Interval[{t, t}], 30]]] &&
     lo[Sin[N[Interval[{t, t}], 30]]] <= N[Sin[t], 60] <= hi[Sin[N[Interval[{t, t}], 30]]]], {500}];
(* constraint list: 51 pairs, each Theorem C class counted *)
cS = ic /@ Range[9]; pS = ip /@ Range[9]; sS = is /@ Range[9];
s2 = And @@ Table[With[{p = pairsFor[m]}, Length[p] == 51 && DuplicateFreeQ[Sort /@ p] &&
      Count[p, {a_, b_} /; MemberQ[cS, a] && MemberQ[sS, b]] == 18 &&
      Count[p, {a_, _} /; MemberQ[pS, a]] == 27 && Count[p, {a_, iE} /; MemberQ[pS, a]] == m &&
      Count[p, {a_, iF} /; MemberQ[pS, a]] == 9 - m && Count[p, {iT1 | iT2, _}] == 6 &&
      MemberQ[p, {iT2, ic[m + 1]}] && MemberQ[p, {iT1, ic[1]}] &&
      (* every c_k is joined to the sigmas of phi_{k-1} and phi_k (sigma_9 standing for phi_0 and phi_9) *)
      And @@ Table[MemberQ[p, {ic[k], is[If[k == 1, 9, k - 1]]}] && MemberQ[p, {ic[k], is[k]}], {k, 9}]], {m, 8}];
Print["S1 constants/sqrtUp/Cos-Sin enclosures: ", s1, ";  S2 constraint lists (m=1..8): ", s2];

(* reference witness angles of the F5 configuration (Lemma W), relabelled D_1..D_9 = disks 9,7,11,10,6,8,4,3,5 *)
ref = {{0, -39324960179250027086/10^20}, {0, 71839227931685877597/10^20}, {0, 234884120097565953729/10^20},
   {157535264004342806580/10^20, 162062588642691912838/10^20}, {-157535264004342806580/10^20, 162062588642691912838/10^20},
   {177273616280974093118/10^20, -93632239910290244643/10^20}, {-177273616280974093118/10^20, -93632239910290244643/10^20},
   {182750955295212993964/10^20, 24958048504283922431/10^20}, {-182750955295212993964/10^20, 24958048504283922431/10^20},
   {78521708246826346764/10^20, -201247018720615423819/10^20}, {-78521708246826346764/10^20, -201247018720615423819/10^20}};
refPhi[Rv_, order_] := Module[{th, w, phi},
  th = N[ArcTan @@@ ref[[order]], 30]; w = N[ArcCos[(Rv^2 + (Norm /@ ref[[order]])^2 - 1)/(2 Rv Norm /@ ref[[order]])], 30];
  Do[While[th[[k]] <= th[[k - 1]], th[[k]] += 2 Pi], {k, 2, 9}];
  th = Append[th, th[[1]] + 2 Pi]; w = Append[w, w[[1]]];
  phi = Table[(Max[th[[k]], th[[k + 1]] - w[[k + 1]]] + Min[th[[k]] + w[[k]], th[[k + 1]]])/2, {k, 9}];
  N[phi[[1 ;; 8]] - (phi[[9]] - 2 Pi), 20]];
refBox[Rv_, order_, half_] := With[{p = Rationalize[refPhi[Rv, order], 10^-18]}, {p - half, p + half}];
ord5 = {9, 7, 11, 10, 6, 8, 4, 3, 5};
(* T1 (must stay open): R = 2.6316 < R_*, m = 5, the Melissen witness box of half-width 1e-6, 1e-4 *)
setR[26316/10000]; setupM[5];
t1 = Table[First[testBox[refBox[26316/10000, ord5, h]]], {h, {10^-6, 10^-4}}];
(* T2 (power check): R = 2.6317, m = 5, half-width 1e-3 around the same witness vector *)
setR[26317/10000]; setupM[5];
t2 = runTree[refBox[26316/10000, ord5, 10^-3], 2000];
Print["T1 R=2.6316 reference boxes (must be open): ", t1, ";  T2 R=2.6317 half 1e-3 tree {boxes,empty,cert,fails}: ", t2[[1 ;; 3]], " ", Length[t2[[4]]]];
If[!(s1 && s2 && FreeQ[t1, "cert"] && t2[[4]] === {}), Print["22c SANITY FAILED"]; Exit[2]];

(* ---------------- main run ---------------- *)
ms = Which[mode === "all", Range[8], mode === "pilot", {5}, True, ToExpression["{" <> mode <> "}"]];
LaunchKernels[nKer];
ParallelEvaluate[ReleaseHold[defs]];
allOK = True;
Do[
  setR[26317/10000];
  root = propagate[{Table[0, 8], Table[7, 8]}];
  (* own root split: breadth-first bisection into 512 boxes covering the propagated root *)
  roots = Nest[Join @@ (bisect /@ #) &, {root}, 9];
  If[mode === "pilot", roots = RandomSample[roots, 32]];
  ParallelEvaluate[setR[26317/10000]; setupM[m]];
  t0 = AbsoluteTime[];
  res = ParallelMap[runTree[#, 10^6] &, roots, Method -> "FinestGrained"];
  tot = Total[res[[All, 1 ;; 3]]]; fails = Join @@ res[[All, 4]];
  Print["m=", m, ": roots ", Length[roots], ", boxes ", tot[[1]], ", empty ", tot[[2]], ", certified ", tot[[3]],
    ", failures ", Length[fails], ", ", Round[AbsoluteTime[] - t0], " s"];
  If[fails =!= {}, allOK = False; Print["  first failures: ", Take[fails, UpTo[5]]]];
  , {m, ms}];
Print[If[allOK, If[mode === "all", "22c ALL m CERTIFIED", "22c pilot/partial run OK (not the full certificate)"], "22c FAILED"]];
Exit[If[allOK, 0, 1]];
