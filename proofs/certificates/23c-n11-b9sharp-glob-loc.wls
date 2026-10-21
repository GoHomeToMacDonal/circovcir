#!/usr/bin/env wolframscript
(* proofs/certificates/23c -- independent Wolfram re-implementation of computations GLOB and LOC of
   experiments/2026-10-21-siege-n11-b9-sharp/out/proof.md (sec.1 Steps 2-4, Appendix C sec.1, sec.3.1-3.2,
   Appendix E sec.0, sec.3.1-3.2; Part W of Appendix A).

   CLAIM.  J = [Rlo, Rhi], Rlo = Rbar = 263169077261980820552/10^20, Rhi = 2631692/10^6.
   (G) For every split label m = 1..8 there is a finite box tree whose leaves tile the root [0,7]^8
       exactly, and every leaf B is
         empty   -- exact propagation of 0 <= phi_k - phi_{k-1} <= A (phi_0 = 0, phi_9 in [TPL,TPH] ∋ 2 Pi,
                    A >= 2 ArcSin[1/Rlo]) shows B ∩ Phi_A = {} ;
         cert    -- an exact Lemma D' certificate V < 0 (M = 7/2) for P~_m(B';J), B' = propagated B ;
         local   -- (m = 5 only) B' ⊆ U, (m = 4 only) B' ⊆ U',  U = prod_k [phibar_k - 1/1024, phibar_k + 1/1024].
   (L) For m = 5 with (U, Q, lambda) and m = 4 with (U', Q', lambda') each of the 44 systems
         P~_m(U;J) + { e((Q c_v)_iota - cbar_{lambda(v),iota}) >= delta1 },  delta1 = 3/1000,
       v in {cE, cF, c_1..c_9}, iota in {x,y}, e = +-1, has an exact Lemma D' certificate V < 0 (M = 7/2).
   With Corollary W1_J, Lemma M35_J, Lemma D' and Lemma LOC this gives Steps 3 and 4 of proof.md.

   METHOD.  Written from the mathematical statements (Part W, Appendix C sec.1, sec.3.2), extending our own
   22c certificate (single radius) to the R-interval; NOT a translation of wit_exact_J.py.  Data taken from
   the statement: phibar (m=5), phibar' (m=4, defined from phibar), eta, Q (tau), Q' (tau'), lambda,
   lambda', delta1, the F5 centres cbar (out/problem.md); all checked below where checkable.
     * P~_m(B;J): sigma_k (k<=8) with |sigma_k| <= Rhi, nhat_k.sigma_k >= Rlo u_k, u_k a rational lower
       bound of nhat_k.e(t) at both ends of the k-th interval (bignum Interval, precision 30), u_k > 0;
       sigma_9 with |sigma_9| <= Rhi, sigma_9.(1,0) >= Rlo; |cE| <= 1, |c_k| <= RHO = sqrt_up(Rhi^2-1);
       pairs (P2)-(P4) of Theorem C.  Box widths <= 3/2 are checked exactly before use.
     * tree: unpropagated boxes, bisected (both children exact halves of the parent at a rational cut
       s strictly inside) at the midpoint of the widest coordinate of the PROPAGATED box; every leaf
       records its path (cut coordinate, cut point, side); tiling is re-checked exactly at the end
       (path reconstruction, prefix-freeness + cut consistency => disjoint interiors, exact volume sum).
     * multipliers: dual SOCP of P~ (objective = V of Lemma D' with the net forces g_v as free variables
       priced at M = 7/2, sum mu = 1), SecondOrderConeOptimization Method -> "CSDP" (floats only);
       load-bearing check V < 0 in exact rationals with self-verified integer square-root upper bounds.
     * a box that is neither empty, certified nor (m=4,5) inside U, and whose propagated width is
       < 10^-9, is a hard FAIL (never dropped); so is a budget overrun.
   TRUST BASE.  Exact rational/integer arithmetic of Mathematica 14.3; its bignum (precision 30) Interval
   Cos, Sin, ArcSin and N[Interval[{Pi,Pi}],30] (sanity-tested against 60-digit values); correct execution
   of this script.  No machine-precision Interval is used anywhere (it is not outward rounded in 14.3).
   USAGE.  wolframscript -file 23c-n11-b9sharp-glob-loc.wls [mode] [nkernels]
     mode = all (default; the certificate) | sanity | loc | glob:<m-list> | pilot:<m>:<nroots>
   Prints '23c GLOB+LOC VERIFIED' as last line and exits 0 iff (sanity, data, controls, LOC, GLOB) all hold. *)

Internal`$EqualTolerance = 0;
args = Rest[$ScriptCommandLine];
mode = If[Length[args] >= 1, args[[1]], "all"];
nKer = If[Length[args] >= 2, ToExpression[args[[2]]], 8];
T0 = AbsoluteTime[];
say[x__] := (Print[x]; Null);

defs = Hold[
  Internal`$EqualTolerance = 0;
  ex[x_] := SetPrecision[x, Infinity];
  lo[x_Interval] := ex[Min[x]]; hi[x_Interval] := ex[Max[x]];
  (* precision-30 interval containing the rational t (containment checked exactly) *)
  rI[t_] := Module[{iv = N[Interval[{t, t}], 30]},
    If[!(Precision[iv] >= 29 && lo[iv] <= t <= hi[iv]), Print["rI enclosure failure ", t]; Abort[]]; iv];
  isqrtFloor[n_Integer] := Module[{s = Floor[Sqrt[n]]},
    While[s^2 > n, s--]; While[(s + 1)^2 <= n, s++]; s];
  sqrtUp[q_] := If[q == 0, 0, With[{a = Numerator[q], b = Denominator[q], K = 2^64},
     (isqrtFloor[a b K^2] + 1)/(b K)]];
  M35 = 7/2;
  (* ---- the R-interval J and its constants (exact rationals) ---- *)
  setJ[rl_, rh_] := Module[{piI = N[Interval[{Pi, Pi}], 30]},
    Rlo = rl; Rhi = rh;
    TPL = lo[2 piI]; TPH = hi[2 piI];                                 (* TPL <= 2 Pi <= TPH *)
    Aup = hi[2 ArcSin[rI[1/Rlo]]];                                   (* Aup >= 2 a(Rlo) >= 2 a(R), R in J *)
    RHO = sqrtUp[Rhi^2 - 1]];                                         (* RHO >= sqrt(R^2-1), R in J *)
  (* ---- unknown points: 1 cE, 2 cF, 2+k c_k, 11+k p_k, 21 t_1, 22 t_{m+1}, 22+k sigma_k ---- *)
  iE = 1; iF = 2; ic[k_] := 2 + k; ip[k_] := 11 + k; iT1 = 21; iT2 = 22; is[k_] := 22 + k; nPts = 31;
  pairsFor[m_] := Join[
    Flatten[Table[{{ic[k], is[If[k == 1, 9, k - 1]]}, {ic[k], is[k]}}, {k, 9}], 1],
    Flatten[Table[{{ip[k], ic[k]}, {ip[k], ic[Mod[k, 9] + 1]}, {ip[k], If[k <= m, iE, iF]}}, {k, 9}], 1],
    {{iT1, ic[1]}, {iT1, iE}, {iT1, iF}, {iT2, ic[m + 1]}, {iT2, iE}, {iT2, iF}}];
  (* anchors |x_v| <= r: cE <= 1, c_k <= RHO, sigma_k <= Rhi (k = 1..9) *)
  anchors[] := Join[{{iE, 1}}, Table[{ic[k], RHO}, {k, 9}], Table[{is[k], Rhi}, {k, 9}]];

  (* ---- propagation of 0 <= phi_k - phi_{k-1} <= Aup (phi_0 = 0, phi_9 in [TPL,TPH]) ---- *)
  propagate[{l0_, h0_}] := Module[{l = Join[{0}, l0, {TPL}], h = Join[{0}, h0, {TPH}], old = Null, it = 0},
    While[{l, h} =!= old && it < 200, old = {l, h}; it++;
      Do[l[[k]] = Max[l[[k]], l[[k - 1]]]; h[[k]] = Min[h[[k]], h[[k - 1]] + Aup], {k, 2, 10}];
      Do[h[[k]] = Min[h[[k]], h[[k + 1]]]; l[[k]] = Max[l[[k]], l[[k + 1]] - Aup], {k, 9, 1, -1}];
      If[Or @@ Thread[l > h], Return[$Empty, Module]]];
    If[Or @@ Thread[l > h], $Empty, {l[[2 ;; 9]], h[[2 ;; 9]]}]];

  (* ---- half-plane data of P~_m(B;J): {point, nhat, h} with h = Rlo*u_k ---- *)
  halfplanes[{l_, h_}] := Module[{res = {}, mid, n, u},
    Do[If[!(h[[k]] - l[[k]] <= 3/2), Return[$Failed, Module]];
      mid = N[(l[[k]] + h[[k]])/2]; n = ex[{Cos[mid], Sin[mid]}];
      u = Min[Table[With[{tI = rI[t]}, lo[n[[1]] Cos[tI] + n[[2]] Sin[tI]]], {t, {l[[k]], h[[k]]}}]];
      u = Floor[u 2^80]/2^80;
      If[!(u > 0), Return[$Failed, Module]];
      AppendTo[res, {is[k], n, Rlo u}], {k, 8}];
    Append[res, {is[9], {1, 0}, Rlo}]];

  (* ---- dual SOCP structure; nMu = number of half-planes (9 for GLOB, 10 for LOC) ---- *)
  setupM[m_, nmu_] := Module[{pr = pairsFor[m], an = anchors[], rows},
    curM = m; pairs = pr; anch = an; nE = Length[pr]; nJ = Length[an]; nYZ = 2 (nE + nJ); nMu = nmu; nS = nE + nJ;
    oG = nYZ + nMu + nS; oSG = oG + 2 nPts; nVar = oSG + nPts;
    rows = Join[
      Flatten[Table[With[{a = pr[[e, 1]], b = pr[[e, 2]]},
        {{2 a - 1, 2 e - 1} -> 1., {2 a, 2 e} -> 1., {2 b - 1, 2 e - 1} -> -1., {2 b, 2 e} -> -1.}], {e, nE}], 1],
      Flatten[Table[With[{v = an[[j, 1]], c = 2 nE + 2 j}, {{2 v - 1, c - 1} -> 1., {2 v, c} -> 1.}], {j, nJ}], 1]];
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

  (* dual SOCP: minimise sum|y_e| + sum r_j|z_j| - sum mu_i h_i + M sum|g_v|, g = net force, sum mu = 1 *)
  solveDual[hp_] := Module[{Amu, G, eqCons, cvec, sol},
    If[Length[hp] =!= nMu, Print["nMu mismatch"]; Abort[]];
    Amu = SparseArray[Flatten[Table[{{2 hp[[i, 1]] - 1, i} -> -N[hp[[i, 2, 1]]], {2 hp[[i, 1]], i} -> -N[hp[[i, 2, 2]]]}, {i, nMu}], 1], {2 nPts, nMu}];
    G = ArrayFlatten[{{Ayz, Amu, SparseArray[{}, {2 nPts, nS}], -IdentityMatrix[2 nPts, SparseArray],
        SparseArray[{}, {2 nPts, nPts}]}}];
    eqCons = Join[Table[{zeroRow, {}, G[[r]], 0.}, {r, 2 nPts}], Table[{zeroRow, {}, -G[[r]], 0.}, {r, 2 nPts}]];
    cvec = Join[Table[0., nYZ], -N[hp[[All, 3]]], N[rList], Table[0., 2 nPts], Table[N[M35], nPts]];
    (* ::inac etc. are not failures: any multipliers are admissible in Lemma D'; only V < 0 below counts *)
    sol = Quiet[SecondOrderConeOptimization[cvec, Join[coneCons, muCons, eqCons], Method -> "CSDP"]];
    If[!VectorQ[sol, NumericQ], sol = Quiet[SecondOrderConeOptimization[cvec, Join[coneCons, muCons, eqCons]]]];
    If[!VectorQ[sol, NumericQ], Return[$Failed]];
    sol];

  (* exact upper bound of V of Lemma D' (rationals of the float multipliers; mu clipped at 0) *)
  vExact[sol_, hp_] := Module[{yz = ex[sol[[1 ;; nYZ]]], mu = Max[0, #] & /@ ex[sol[[nYZ + 1 ;; nYZ + nMu]]], g, tot = 0, y},
    g = Table[0, 2 nPts];
    Do[y = yz[[2 e - 1 ;; 2 e]]; tot += sqrtUp[y . y];
      With[{a = pairs[[e, 1]], b = pairs[[e, 2]]}, g[[2 a - 1 ;; 2 a]] += y; g[[2 b - 1 ;; 2 b]] -= y], {e, nE}];
    Do[y = yz[[2 nE + 2 j - 1 ;; 2 nE + 2 j]]; tot += anch[[j, 2]] sqrtUp[y . y];
      With[{v = anch[[j, 1]]}, g[[2 v - 1 ;; 2 v]] += y], {j, nJ}];
    Do[tot -= mu[[i]] hp[[i, 3]];
      With[{v = hp[[i, 1]]}, g[[2 v - 1 ;; 2 v]] -= mu[[i]] hp[[i, 2]]], {i, nMu}];
    tot + M35 Sum[sqrtUp[g[[2 v - 1]]^2 + g[[2 v]]^2], {v, nPts}]];
  certQ[hp_] := Module[{sol}, If[hp === $Failed, Return[False]];
    sol = solveDual[hp]; If[sol === $Failed, Return[False]]; TrueQ[vExact[sol, hp] < 0]];

  (* ---- local cube (set per m; None for m not in {4,5}) ---- *)
  insideU[{l_, h_}] := ListQ[Ucube] && And @@ Thread[Ucube[[1]] <= l] && And @@ Thread[h <= Ucube[[2]]];
  MINW = 10^-9;
  (* classify a box: {type, propagated box}; type in empty | local | cert | open | fail *)
  testBox[box_] := Module[{pb = propagate[box]},
    If[pb === $Empty, Return[{"empty", box}]];
    If[insideU[pb], Return[{"local", pb}]];
    If[certQ[halfplanes[pb]], Return[{"cert", pb}]];
    If[Max[pb[[2]] - pb[[1]]] < MINW, {"fail", pb}, {"open", pb}]];
  (* cut the ORIGINAL box at the midpoint s of the widest coordinate of its propagated box; l_k < s < h_k *)
  cutBox[{l_, h_}, pb_] := Module[{k = First[Ordering[pb[[2]] - pb[[1]], -1]], s},
    s = (pb[[1, k]] + pb[[2, k]])/2;
    If[!(l[[k]] < s < h[[k]]), Print["cut failure"]; Abort[]];
    {k, s, {l, ReplacePart[h, k -> s]}, {ReplacePart[l, k -> s], h}}];
  (* DFS over one root box; leaves {path, type, box}; path = list of {k, s, side} *)
  runTree[{box0_, path0_}, budget_] := Module[{st = {{box0, path0}}, b, p, r, c, n = 0, ns = 0, cnt, fails = {}, leaves = {}},
    cnt = <|"empty" -> 0, "local" -> 0, "cert" -> 0|>;
    (* after `budget` tested boxes the unprocessed stack is RETURNED (re-queued by the driver), never dropped *)
    While[st =!= {} && n < budget, {b, p} = Last[st]; st = Most[st]; n++;
      r = testBox[b];
      Switch[r[[1]],
        "empty" | "local" | "cert", cnt[r[[1]]]++; AppendTo[leaves, {p, r[[1]], b}],
        "fail", AppendTo[fails, {"MINWIDTH-OPEN", N[r[[2]], 12]}]; AppendTo[leaves, {p, "FAIL", b}],
        _, c = cutBox[b, r[[2]]]; ns++;
           st = Join[st, {{c[[4]], Append[p, {c[[1]], c[[2]], 1}]}, {c[[3]], Append[p, {c[[1]], c[[2]], 0}]}}]]];
    {n, cnt["empty"], cnt["cert"], cnt["local"], ns, fails, leaves, st}];
];
ReleaseHold[defs];

(* ================= data from the statement ================= *)
Rl0 = 263169077261980820552/10^20; Rh0 = 2631692/10^6;
Istar = {26316907726198082055215011595056961051671168478238/10^49, 26316907726198082055215011595056961051671168478239/10^49};
cbar = Module[{h = {{0, -39324960179250027086/10^20}, {0, 71839227931685877597/10^20}, {0, 234884120097565953729/10^20},
     {157535264004342806580/10^20, 162062588642691912838/10^20}, Null,
     {177273616280974093118/10^20, -93632239910290244643/10^20}, Null,
     {182750955295212993964/10^20, 24958048504283922431/10^20}, Null,
     {78521708246826346764/10^20, -201247018720615423819/10^20}, Null}},
   Do[h[[i + 1]] = {-h[[i, 1]], h[[i, 2]]}, {i, {4, 6, 8, 10}}]; h];
phibar5 = {561643842893/10^12, 124332997298/10^11, 198734721294/10^11, 27313644529/10^10,
   3413050582987/10^12, 397469442588/10^11, 4740718468893/10^12, 5517161264167/10^12};
eta = 1/1024; delta1 = 3/1000;
lam5 = {1, 2, 9, 7, 11, 10, 6, 8, 4, 3, 5};          (* witness (E,F,D1..D9) -> F5 disk *)
lam4 = {2, 1, 8, 4, 3, 5, 9, 7, 11, 10, 6};
tau5 = 1331857233103593/2^48; tau4 = -68511808261983/942727686399593;
setJ[Rl0, Rh0];
(* phibar' (m = 4): phibar'_k = round_{1e-15}(phibar_{k+5} - phibar_5), phibar_{9+j} = phibar_j + 2 Pi
   (Appendix E sec.0.2 / 3.1); the 1e-15 rounding is done with an enclosure of 2 Pi *)
round15[x_Interval] := With[{a = Round[lo[x] 10^15], b = Round[hi[x] 10^15]}, If[a =!= b, Abort[]]; a/10^15];
phibar4 = Module[{p = Join[{0}, phibar5], twoPi = 2 N[Interval[{Pi, Pi}], 30]},
   Table[If[k + 5 <= 8, p[[k + 6]] - p[[6]], round15[If[k + 5 == 9, twoPi, p[[k + 5 - 9 + 1]] + twoPi] - p[[6]]]], {k, 8}]];
qrot[tau_] := With[{c = (1 - tau^2)/(1 + tau^2), s = 2 tau/(1 + tau^2)}, {{c, -s}, {s, c}}];
frames = <|5 -> <|"phib" -> phibar5, "lam" -> lam5, "Q" -> qrot[tau5]|>, 4 -> <|"phib" -> phibar4, "lam" -> lam4, "Q" -> qrot[tau4]|>|>;
cube[phib_] := {phib - eta, phib + eta};
wit = Join[{iE, iF}, ic /@ Range[9]];                  (* witness points in label order (E,F,D1..D9) *)

(* ================= sanity S1, S2, data checks D ================= *)
s1 = TPL <= 2 Pi <= TPH && TPH - TPL < 10^-25 && Aup >= 2 ArcSin[1/Rlo] && Aup - 2 ArcSin[1/Rlo] < 10^-25 &&
   RHO >= Sqrt[Rhi^2 - 1] && RHO <= 245/100 && Rhi < 264/100 && 2 < Rlo < Rhi &&
   And @@ Table[With[{q = RandomInteger[{1, 10^30}]/RandomInteger[{1, 10^20}]}, sqrtUp[q] >= Sqrt[q] && sqrtUp[q] - Sqrt[q] < 10^-18], {300}] &&
   And @@ Table[With[{t = RandomInteger[{0, 7*10^20}]/10^20},
     lo[Cos[rI[t]]] <= N[Cos[t], 60] <= hi[Cos[rI[t]]] && lo[Sin[rI[t]]] <= N[Sin[t], 60] <= hi[Sin[rI[t]]] &&
     hi[Cos[rI[t]]] - lo[Cos[rI[t]]] < 10^-25], {500}] &&
   And @@ Table[With[{t = RandomInteger[{10^19, 10^20}]/10^20},
     lo[ArcSin[rI[t]]] <= N[ArcSin[t], 60] <= hi[ArcSin[rI[t]]]], {200}];
cS = ic /@ Range[9]; pS = ip /@ Range[9]; sS = is /@ Range[9];
s2 = And @@ Table[With[{p = pairsFor[m]}, Length[p] == 51 && DuplicateFreeQ[Sort /@ p] &&
      Count[p, {a_, b_} /; MemberQ[cS, a] && MemberQ[sS, b]] == 18 &&
      Count[p, {a_, _} /; MemberQ[pS, a]] == 27 && Count[p, {a_, iE} /; MemberQ[pS, a]] == m &&
      Count[p, {a_, iF} /; MemberQ[pS, a]] == 9 - m && Count[p, {iT1 | iT2, _}] == 6 &&
      MemberQ[p, {iT2, ic[m + 1]}] && MemberQ[p, {iT1, ic[1]}] && MemberQ[p, {iT1, iF}] &&
      And @@ Table[MemberQ[p, {ip[k], ic[k]}] && MemberQ[p, {ip[k], ic[Mod[k, 9] + 1]}] &&
          MemberQ[p, {ip[k], If[k <= m, iE, iF]}], {k, 9}] &&
      And @@ Table[MemberQ[p, {ic[k], is[If[k == 1, 9, k - 1]]}] && MemberQ[p, {ic[k], is[k]}], {k, 9}]], {m, 8}] &&
   Length[anchors[]] == 19 && Sort[anchors[][[All, 1]]] == Sort[Join[{iE}, cS, sS]];
say["S1 J-constants / sqrtUp / Cos-Sin-ArcSin enclosures: ", s1, ";  S2 Theorem C constraint lists m=1..8 + 19 anchors: ", s2];
say["J = [", N[Rlo, 25], ", ", N[Rhi, 10], "],  A = ", N[Aup, 20], ",  RHO = ", N[RHO, 15], ",  TPH-TPL = ", N[TPH - TPL, 3]];

(* reference witness angles from the F5 centres (Lemma W step 2, midpoint choice), our own 22c routine *)
refPhi[Rv_, order_] := Module[{th, w, phi, pts = cbar[[order]]},
  th = N[ArcTan @@@ pts, 40]; w = N[ArcCos[(Rv^2 + (Norm /@ pts)^2 - 1)/(2 Rv Norm /@ pts)], 40];
  Do[While[th[[k]] <= th[[k - 1]], th[[k]] += 2 Pi], {k, 2, 9}];
  th = Append[th, th[[1]] + 2 Pi]; w = Append[w, w[[1]]];
  phi = Table[{Max[th[[k]], th[[k + 1]] - w[[k + 1]]], Min[th[[k]] + w[[k]], th[[k + 1]]]}, {k, 9}];
  {N[phi[[1 ;; 8, 1]] - (phi[[9, 2]] - 2 Pi), 30], N[phi[[1 ;; 8, 2]] - (phi[[9, 1]] - 2 Pi), 30], phi}];
dataChecks = Table[Module[{fr = frames[m], Q, lamv, ph, rf, dev, devE, ordD, mx},
    Q = fr["Q"]; lamv = fr["lam"]; ph = fr["phib"];
    ordD = lamv[[3 ;; 11]];
    rf = refPhi[Rlo, ordD];
    (* frame check: Q^T cbar_{lambda(D_k)} is at distance 1 from Rbar e(phibar_{k-1}), Rbar e(phibar_k) *)
    mx = Table[With[{cc = Transpose[Q] . cbar[[lamv[[2 + k]]]], pp = Join[{0}, ph, {2 Pi}]},
        Max[Table[Abs[N[Norm[cc - Rlo {Cos[pp[[j + 1]]], Sin[pp[[j + 1]]]}], 40] - 1], {j, {k - 1, k}}]]], {k, 9}];
    devE = N[Norm[Transpose[Q] . cbar[[lamv[[1]]]]], 20];
    <|"m" -> m,
      "Q orthogonal exactly" -> (Transpose[Q] . Q == IdentityMatrix[2] && Det[Q] == 1),
      "lambda bijection onto 1..11, E,F inner" -> (Sort[lamv] == Range[11] && Sort[lamv[[1 ;; 2]]] == {1, 2}),
      "F5 disk 3 = D_8 (m=5) / D_3 (m=4)" -> (lamv[[2 + If[m == 5, 8, 3]]] == 3),
      "D_1..D_9 counter-clockwise in F5" -> (Module[{a = Mod[N[ArcTan @@@ cbar[[ordD]], 30] - N[ArcTan @@ cbar[[ordD[[1]]]], 30], N[2 Pi, 30]]}, OrderedQ[a] && Max[a] < 2 Pi]),
      "phibar in Phi_A (exact)" -> (With[{d = Differences[Join[{0}, ph, {TPL}]], d2 = Differences[Join[{0}, ph, {TPH}]]}, Min[d] >= 0 && Max[d2] <= Aup]),
      "U widths <= 3/2, U in root" -> (2 eta <= 3/2 && Min[ph - eta] >= 0 && Max[ph + eta] <= 7),
      "frame deviation (40 digits)" -> N[Max[mx], 3],
      "|phibar - refPhi interval| (F5 witness interval)" -> N[Max[Max[rf[[1]] - ph, 0], Max[ph - rf[[2]], 0]], 3],
      "tau vs tan(theta0/2)" -> N[fr["Q"][[1, 1]] - Cos[If[m == 5, Pi/2 - (phibar5[[7]] + phibar5[[8]])/2 + 2 Pi, Pi/2 - (phibar5[[7]] + phibar5[[8]])/2 + phibar5[[5]]]], 3],
      "|Q^T cbar_E|" -> devE|>], {m, {5, 4}}];
Scan[say["D m=", #["m"], ": ", Normal[KeyDrop[#, "m"]]] &, dataChecks];
d0 = Rlo < Istar[[1]] && Rhi > Istar[[2]] + 10^-6 && Rlo == 263169077261980820552/10^20 &&
   (* App. E sec.0.2 prints phibar' to 12 decimals; the data (1e-15 grid) must round to those *)
   Max[Abs[phibar4 - {561643842893/10^12, 1327667885906/10^12, 2104110681180/10^12, 2870134724193/10^12,
     3431778567086/10^12, 4113464697173/10^12, 4857481937133/10^12, 5601499177093/10^12}]] <= 5/10^13 &&
   And @@ (IntegerQ[# 10^15] & /@ phibar4);
dOK = d0 && And @@ Table[With[{d = dataChecks[[i]]}, d["Q orthogonal exactly"] && d["lambda bijection onto 1..11, E,F inner"] &&
      d["F5 disk 3 = D_8 (m=5) / D_3 (m=4)"] && d["D_1..D_9 counter-clockwise in F5"] && d["phibar in Phi_A (exact)"] &&
      d["U widths <= 3/2, U in root"] && d["frame deviation (40 digits)"] < 10^-9 &&
      d["|phibar - refPhi interval| (F5 witness interval)"] < 10^-9 && Abs[d["tau vs tan(theta0/2)"]] < 10^-12], {i, 2}];
say["D0 Rlo < I_*, Rhi > I_*+1e-6, phibar' = App.E 0.2 decimals: ", d0, ";  data checks all: ", dOK];

(* ================= LOC ================= *)
locSystems[m_, dl_] := Module[{fr = frames[m], U, hp0},
  U = cube[fr["phib"]]; hp0 = halfplanes[U];
  If[hp0 === $Failed, Print["LOC halfplanes failed"]; Abort[]];
  Flatten[Table[With[{v = wit[[iv]], cb = cbar[[fr["lam"][[iv]]]]},
      {iv, io, e, Append[hp0, {v, e fr["Q"][[io]], e cb[[io]] + dl}]}], {iv, 11}, {io, 2}, {e, {1, -1}}], 2]];
runLOC[m_, dl_] := Module[{sys = locSystems[m, dl]},
  setupM[m, 10];
  Table[{s[[1 ;; 3]], certQ[s[[4]]]}, {s, sys}]];

(* ================= negative / positive controls ================= *)
controls[] := Module[{n1, n2, n3, l5, l4},
  (* N1: Melissen witness box of small half-width must NOT certify on J (P~ is feasible there) *)
  n1 = Table[Module[{ph = frames[m]["phib"]}, setupM[m, 9]; Table[certQ[halfplanes[{ph - h, ph + h}]], {h, {10^-6, 10^-5}}]], {m, {5, 4}}];
  n2 = Module[{rf = refPhi[Rlo, lam5[[3 ;; 11]]], c}, setupM[5, 9];
    c = Rationalize[(rf[[1]] + rf[[2]])/2, 10^-25]; certQ[halfplanes[{c - 10^-6, c + 10^-6}]]];
  (* N3: LOC systems at delta = 1e-6 must NOT certify *)
  l5 = runLOC[5, 10^-6]; l4 = runLOC[4, 10^-6];
  say["N1 phibar/phibar' cube half 1e-6,1e-5 certified? (must be all False): ", n1,
    ";  N2 F5 witness box half 1e-6 certified? ", n2,
    ";  N3 LOC delta=1e-6 certified count (must be 0): m=5 ", Count[l5[[All, 2]], True], "/44, m=4 ", Count[l4[[All, 2]], True], "/44"];
  FreeQ[n1, True] && !TrueQ[n2] && FreeQ[l5[[All, 2]], True] && FreeQ[l4[[All, 2]], True]];

(* ================= GLOB driver ================= *)
root = {Table[0, 8], Table[7, 8]};
rootVol = 7^8;
(* breadth-first split (same cut rule) to obtain parallel roots; boxes are kept with their paths *)
makeRoots[depth_] := Module[{lst = {{root, {}}}, nxt, pb, c},
  Do[nxt = {};
    Do[pb = propagate[bp[[1]]];
      If[pb === $Empty, AppendTo[nxt, bp], c = cutBox[bp[[1]], pb];
        nxt = Join[nxt, {{c[[3]], Append[bp[[2]], {c[[1]], c[[2]], 0}]}, {c[[4]], Append[bp[[2]], {c[[1]], c[[2]], 1}]}}]], {bp, lst}];
    lst = nxt, {depth}]; lst];
(* exact tiling check of a leaf list {path, type, box} against root *)
tilingCheck[leaves_] := Module[{rec, ok = True, nodes = <||>, leafKeys, bits, key, vol = 0},
  Do[Module[{b = root, p = lf[[1]], kk, s, sd},
      bits = 0;
      Do[{kk, s, sd} = p[[i]];
        key = {i - 1, bits};
        If[KeyExistsQ[nodes, key], If[nodes[key] =!= {kk, s}, ok = False], nodes[key] = {kk, s}];
        If[!(b[[1, kk]] < s < b[[2, kk]]), ok = False];
        b = If[sd == 0, {b[[1]], ReplacePart[b[[2]], kk -> s]}, {ReplacePart[b[[1]], kk -> s], b[[2]]}];
        bits = 2 bits + sd, {i, Length[p]}];
      If[b =!= lf[[3]], ok = False];
      vol += Times @@ (b[[2]] - b[[1]])], {lf, leaves}];
  leafKeys = Table[{Length[lf[[1]]], FromDigits[lf[[1]][[All, 3]], 2]}, {lf, leaves}];
  {ok && DuplicateFreeQ[leafKeys] && !Or @@ (KeyExistsQ[nodes, #] & /@ leafKeys), vol == rootVol, Length[nodes]}];

runGLOB[m_, rootsDepth_, sample_] := Module[{roots, res, tot, fails, leaves, tc, t0 = AbsoluteTime[], U, items, round},
  U = If[m == 5 || m == 4, cube[frames[m]["phib"]], None];
  roots = makeRoots[rootsDepth];
  If[IntegerQ[sample], roots = Take[SortBy[roots, Function[r, If[ListQ[U], N[Max[Join[r[[1, 1]] - U[[2]], U[[1]] - r[[1, 2]], {0}]]], 0]]], UpTo[sample]]];
  With[{UU = U, mm = m, a1 = Rlo, a2 = Rhi}, ParallelEvaluate[setJ[a1, a2]; Ucube = UU; setupM[mm, 9]]];
  Ucube = U;
  (* rounds: each task processes <= 400 boxes; unprocessed stacks are re-queued as new tasks *)
  items = roots; tot = Table[0, 5]; fails = {}; leaves = {}; round = 0;
  While[items =!= {} && tot[[1]] < 3*10^6,
    round++;
    res = ParallelMap[runTree[#, 400] &, items, Method -> "FinestGrained"];
    tot += Total[res[[All, 1 ;; 5]]]; fails = Join[fails, Join @@ res[[All, 6]]]; leaves = Join[leaves, Join @@ res[[All, 7]]];
    items = Join @@ res[[All, 8]];
    say["  round ", round, ": tasks ", Length[res], ", boxes so far ", tot[[1]], ", requeued ", Length[items], ", fails ", Length[fails], ", ", Round[AbsoluteTime[] - t0], " s"]];
  If[items =!= {}, AppendTo[fails, {"BUDGET 3e6 boxes", Length[items]}]];
  tc = If[IntegerQ[sample], {"n/a (pilot)"}, tilingCheck[Join[leaves, Select[{}, False &]]]];
  say["GLOB m=", m, ": roots ", Length[roots], ", boxes tested ", tot[[1]], ", leaves ", Length[leaves], " (empty ", tot[[2]],
    ", cert ", tot[[3]], ", local ", tot[[4]], "), splits ", tot[[5]], ", fails ", Length[fails],
    ", tiling {paths consistent & prefix-free, exact volume = 7^8, interior nodes} ", tc, ", ", Round[AbsoluteTime[] - t0], " s"];
  If[fails =!= {}, say["  first failures: ", Take[fails, UpTo[5]]]];
  If[tot[[4]] > 0, Module[{loc = Select[leaves, #[[2]] == "local" &]},
     say["  local leaves: ", Length[loc], ", all inside U exactly: ", And @@ (insideU[propagate[#[[3]]]] & /@ loc)]]];
  {fails === {} && (IntegerQ[sample] || (tc[[1]] && tc[[2]])) && (m == 4 || m == 5 || tot[[4]] == 0), tot, Length[leaves]}];

(* ================= main ================= *)
okAll = s1 && s2 && dOK;
If[!okAll, say["23c SANITY/DATA FAILED"]; Exit[2]];
If[mode === "sanity", say["controls: ", controls[]]; say["sanity done ", Round[AbsoluteTime[] - T0], " s"]; Exit[0]];

locOK = True;
If[mode === "all" || mode === "loc",
  Do[Module[{t0 = AbsoluteTime[], r = runLOC[m, delta1]},
     say["LOC m=", m, " eta=1/1024 delta1=3/1000: certified ", Count[r[[All, 2]], True], "/", Length[r],
       If[FreeQ[r[[All, 2]], False], "", {" open:", Select[r, !#[[2]] &][[All, 1]]}], "  (", Round[AbsoluteTime[] - t0], " s)"];
     If[!(Length[r] == 44 && FreeQ[r[[All, 2]], False]), locOK = False]], {m, {5, 4}}];
  ctrlOK = controls[]; say["controls OK: ", ctrlOK]; locOK = locOK && ctrlOK];
If[mode === "loc", say[If[locOK, "23c LOC part OK (not the full certificate)", "23c FAILED"]]; Exit[If[locOK, 0, 1]]];

globOK = True;
LaunchKernels[nKer];
ParallelEvaluate[ReleaseHold[defs]];
Which[
  mode === "all", Do[globOK = globOK && runGLOB[m, 9, All][[1]], {m, {1, 2, 3, 6, 7, 8, 5, 4}}],
  StringStartsQ[mode, "glob:"], Do[globOK = globOK && runGLOB[m, 9, All][[1]], {m, ToExpression["{" <> StringDrop[mode, 5] <> "}"]}],
  StringStartsQ[mode, "pilot:"], With[{pp = ToExpression /@ StringSplit[StringDrop[mode, 6], ":"]}, globOK = runGLOB[pp[[1]], 9, pp[[2]]][[1]]]];
say["total time ", Round[AbsoluteTime[] - T0], " s"];
Print[Which[!(locOK && globOK), "23c FAILED", mode === "all", "23c GLOB+LOC VERIFIED", True, "23c partial run OK (not the full certificate)"]];
Exit[If[locOK && globOK, 0, 1]];
