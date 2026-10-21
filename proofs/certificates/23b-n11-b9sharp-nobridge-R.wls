#!/usr/bin/env wolframscript
(* proofs/23 certificate 23b -- C1_R: certificate 22b re-run on the R-INTERVAL [Rlo, Rhi] =
   [263169/100000, 1315846/500000] = [2.63169, 2.631692], as required by Step 1 / Theorem C1_R of
   experiments/2026-10-21-siege-n11-b9-sharp/out/proof.md (Appendix B sec.4).  The three edits are:
     (E1) R -> Interval[{Rlo, Rhi}] everywhere R enters (a, d, B, 6a, 4a, 2a, R-2, C(t), rho(w)), and
          every R-dependent exact rational threshold is replaced by its value in the SOUND direction:
          u in [3-Rhi, Rhi-1] (far), v in [0, 3-Rlo] (near), tStar = Rlo - 2/Rlo (R-2/R increasing),
          B.hi = upper end of the interval enclosure of B over the R-interval (B decreasing in R);
     (E2) t-range upper end tMax = Rhi;
     (E3) an undefined alpha(u) = A(R-2,u) (|R'-2-u| > 1 on the whole box for every R' in the
          interval, i.e. u > R-1) is treated as INFEASIBLE (Repair M1), instead of alpha := 0.
   Every interval computed from RI encloses the value of the same expression at each fixed
   R in [Rlo, Rhi] (independent occurrences of R only widen the enclosure), so each discarded box
   contains no solution of the system at that R.  Below: original 22b header.

   22b -- independent Wolfram re-check of computation C1 (Theorem NB, Part M sec.5)
   of experiments/2026-10-20-siege-n11-b9/out/proof.md.

   Written from the mathematical statement of Part M sec.4 (systems (FAR) and (NEAR-Y), Lemma 1.4,
   Addendum (Q2), the reduction rules), NOT by translating nb_check.py.  Every bound is computed with
   precision-20 BIGNUM Wolfram Interval arithmetic (Sqrt, ArcSin, ArcCos, ArcTan, Sin, Cos); constants
   are enclosed by N[Interval[{x,x}], 20] of the exact values.  Machine-precision Interval is NOT used:
   in Mathematica 14.3 machine Interval ArcCos/ArcTan are not outward rounded (test T1 below).
   Every decision is taken on exact rationals: interval endpoints are converted with
   SetPrecision[., Infinity] and box endpoints / budgets are exact rationals.
   No libm assumption of the kind used by nb_check.py enters; the trust base is the correctness of
   Mathematica's bignum Interval arithmetic (spot-checked against 50-digit evaluation in T1).
   Internal`$EqualTolerance = 0 is kept so that no comparison is tolerance-fuzzed.

   Claim checked (for every R in [Rlo,Rhi]; budget B = 12a - 2Pi + 2d):
     for every K_X in [0,B] (cut into slices [Klo,Khi]):
       (FAR)    no X in the far set (u in [3-R, R-1]) with budget Khi and Y in the far set with budget
                B - Klo satisfy  objX + objY >= 2 Pi  (objX = alpha(u)+A(t3,u)+M3, objY likewise);
       (NEAR-Y) the near Y set (v in [0, 3-R]) with budget B - Klo is empty, or the far X set with
                budget Khi is empty.
   The variables, constraints and relaxations are those of Part M sec.4 (see comments below).
   Usage: wolframscript -file 22b-n11-b9-nobridge.wls [nslices] [nkernels]
   Prints "22b ALL SLICES VERIFIED" and exits 0 on success. *)

Internal`$EqualTolerance = 0;
args = Rest[$ScriptCommandLine];
nSlices = If[Length[args] >= 1, ToExpression[args[[1]]], 48];
nKer = If[Length[args] >= 2, ToExpression[args[[2]]], 16];

(* ---------------- shared definitions (also sent to subkernels) ---------------- *)
defs = Hold[
  Internal`$EqualTolerance = 0;
  prec = 20;                       (* working precision of the bignum intervals (about 66 bits) *)
  Rlo = 263169/100000; Rhi = 1315846/500000;
  ex[x_] := SetPrecision[x, Infinity];
  (* every decision is taken on exact rationals: lo/hi return the exact value of an interval endpoint *)
  lo[x_Interval] := ex[Min[x]]; hi[x_Interval] := ex[Max[x]];
  pt[x_] := N[Interval[{x, x}], prec];          (* enclosure of an exact real number *)
  encl[x_] := N[Interval[{x, x}], prec];
  ivb[{l_, h_}] := N[Interval[{ex[l], ex[h]}], prec];
  (* (E1) interval R; the functions of R are evaluated on the bignum interval (outward rounded) *)
  RI = N[Interval[{Rlo, Rhi}], prec];
  aI = ArcSin[1/RI]; dI = ArcSin[2/RI]; piI = encl[Pi];
  BI = 12 ArcSin[1/RI] - 2 piI + 2 ArcSin[2/RI];
  Bhi = hi[BI];
  sixA = 6 aI; fourA = 4 aI; twoA = 2 aI; twoPiLo = lo[2 piI]; piHi = hi[piI];
  rho0I = RI - 2; tStar = Rlo - 2/Rlo;           (* R - 2/R is increasing: min over the interval *)
  uFarLo = 3 - Rhi; uNearHi = 3 - Rlo; uHi = Rhi - 1;  (* supersets of (3-R, R-1] and [0, 3-R] *)
  tMin = 1; tMax = Rhi;                          (* (E2) *)
  nonneg = Interval[{0, Infinity}];

  (* lower bound over the box of cos A(t,u) = (t^2+u^2-1)/(2tu); t > 0, u >= 0 *)
  cosLo[t_, u_] := Module[{n = t^2 + u^2 - 1, d = 2 t u},
    Which[lo[n] >= 0, If[hi[d] <= 0, Infinity, lo[n]/hi[d]],
          lo[d] > 0, lo[n]/lo[d],
          True, -Infinity]];
  (* upper bound of A(t,u) over the box; Missing if |t-u| > 1 on the whole box (point in no such disk);
     A = Pi when t + u <= 1 is covered by the clip c <= -1.  c is an exact rational. *)
  aUp[t_, u_] := With[{c = cosLo[t, u]},
    Which[c > 1, Missing[], c <= -1, piHi, True, Min[piHi, hi[ArcCos[pt[c]]]]]];
  (* C(t) = 2a - 2 ArcTan[Sqrt[4-(R-t)^2]/(R+t)]: lower bound over t-box (t in [1,R], so 4-(R-t)^2 > 0) *)
  cLo[t_] := lo[twoA - 2 ArcTan[Sqrt[IntervalIntersection[4 - (RI - t)^2, nonneg]]/(RI + t)]];
  (* inner-branch radius rho(w) = R cos w - Sqrt[1 - R^2 sin^2 w], increasing in w, at w = a - dmax:
     lower bound of the radius of every boundary disk with deficit <= dmax (true w <= a, so the
     square-root argument is >= 0 and the clip is valid) *)
  rhoLo[dmax_] := Module[{w = aI - pt[dmax]},
    lo[RI Cos[w] - Sqrt[IntervalIntersection[1 - RI^2 Sin[w]^2, nonneg]]]];
  (* upper bound of M(t,kappa) = max{A(t,rho): rho*(kappa) <= rho <= Sqrt[R^2-1]} for all kappa <= kmax
     (Lemma 1.4: rho*(kappa) is the inner-branch radius at deficit min(kappa, B/2));
     Missing if infeasible.  Valid bounds used: arcsin(1/t) (Lemma S), arcsin(1/rho_L) (Lemma 1.4),
     and A(t, rho_L) when t^2 <= rho_L^2 + 1 (then rho -> A(t,rho) decreases for rho >= rho_L, and
     |t - rho_L| > 1 can only mean rho_L > t + 1, so then every admissible rho_i misses the corner). *)
  mUp[t_, kmax_] := Module[{rl, RL, b1, b2, a0},
    If[kmax < 0, Return[Missing[]]];
    rl = rhoLo[Min[kmax, Bhi/2]]; RL = pt[rl];
    b1 = hi[ArcSin[1/t]]; b2 = hi[ArcSin[1/RL]];
    If[hi[t^2] <= rl^2 + 1,
      a0 = aUp[t, RL]; If[MissingQ[a0], Missing[], Min[a0, b1, b2]],
      Min[b1, b2]]];

  (* X side: box {u, t1, t3, k3}, budget K (upper bound of K_X).  Returns Missing (a necessary condition
     fails on the whole box) or {obj, slack}.
     kappa_2 >= C(t_2) >= C(1+u) when 1+u <= R-2/R (Addendum (Q2)); kappa_1 <= K - kappa_3 - kappa_2;
     C(t_i) <= kappa_i (Lemma 1.3); (X): 6a - K_X - M1 - M3 <= A(t1,u) + A(t3,u). *)
  evalX[box_, K_] := Module[{u, t1, t3, k3, c2, k1max, a1, a3, m1, m3, lhs, rhs, al},
    {u, t1, t3, k3} = ivb /@ box;
    If[cLo[t3] > hi[k3], Return[Missing[]]];
    c2 = If[hi[1 + u] <= tStar, cLo[1 + u], 0];
    k1max = K - lo[k3] - c2;
    If[k1max < 0, Return[Missing[]]];
    If[cLo[t1] > k1max, Return[Missing[]]];
    a1 = aUp[t1, u]; If[MissingQ[a1], Return[Missing[]]];
    a3 = aUp[t3, u]; If[MissingQ[a3], Return[Missing[]]];
    m1 = mUp[t1, k1max]; If[MissingQ[m1], Return[Missing[]]];
    m3 = mUp[t3, hi[k3]]; If[MissingQ[m3], Return[Missing[]]];
    lhs = lo[sixA] - K - m1 - m3; rhs = a1 + a3;
    If[lhs > rhs, Return[Missing[]]];
    al = aUp[rho0I, u]; If[MissingQ[al], Return[Missing[]]];   (* (E3): u > R-1 on the box, Repair M1 *)
    {al + a3 + m3, rhs - lhs}];
  (* Y side: box {v, t4, k4, t5}, budget KY (upper bound of K_Y); kappa_5 <= KY - kappa_4;
     (Y): 4a - K_Y - M4 - M5 <= A(t4,v) + A(t5,v). *)
  evalY[box_, KY_] := Module[{v, t4, k4, t5, k5max, a4, a5, m4, m5, lhs, rhs, al},
    {v, t4, k4, t5} = ivb /@ box;
    If[cLo[t4] > hi[k4], Return[Missing[]]];
    k5max = KY - lo[k4];
    If[k5max < 0, Return[Missing[]]];
    If[cLo[t5] > k5max, Return[Missing[]]];
    a4 = aUp[t4, v]; If[MissingQ[a4], Return[Missing[]]];
    a5 = aUp[t5, v]; If[MissingQ[a5], Return[Missing[]]];
    m4 = mUp[t4, hi[k4]]; If[MissingQ[m4], Return[Missing[]]];
    m5 = mUp[t5, k5max]; If[MissingQ[m5], Return[Missing[]]];
    lhs = lo[fourA] - KY - m4 - m5; rhs = a4 + a5;
    If[lhs > rhs, Return[Missing[]]];
    al = aUp[rho0I, v]; If[MissingQ[al], Return[Missing[]]];   (* (E3) *)
    {al + a4 + m4, rhs - lhs}];

  (* bisection of the widest scaled coordinate; the midpoint is a machine number strictly inside *)
  splitBox[box_, scale_] := Module[{j, m},
    j = First[Ordering[(box[[All, 2]] - box[[All, 1]])/scale, -1]];
    m = (box[[j, 1]] + box[[j, 2]])/2;
    {ReplacePart[box, {j, 2} -> m], ReplacePart[box, {j, 1} -> m]}];
  scaleX = {1, 1, 1, 1/10}; scaleY = {1, 1, 1/10, 1};
  (* roots: u, v <= R-1 (Repair M1); t in [1, R] contains (1.085, R); kappa in [0, B] *)
  xRoot = {{uFarLo, uHi}, {tMin, tMax}, {tMin, tMax}, {0, Bhi}};
  yRootFar = {{uFarLo, uHi}, {tMin, tMax}, {0, Bhi}, {tMin, tMax}};
  yRootNear = {{0, uNearHi}, {tMin, tMax}, {0, Bhi}, {tMin, tMax}};

  (* valid upper bound of obj over the feasible part of root: best-first, every discarded box is
     infeasible, so the largest key left in the queue bounds every feasible point *)
  upperBound[ev_, root_, K_, scale_, cap_] := Module[{q, r, box, it = 0, ch, w},
    r = ev[root, K]; If[MissingQ[r], Return[-Infinity]];
    q = CreateDataStructure["PriorityQueue"]; q["Push", {r[[1]], root}];
    While[!q["EmptyQ"] && it < cap, it++;
      box = q["Pop"][[2]];
      Do[w = ev[ch, K]; If[!MissingQ[w], q["Push", {w[[1]], ch}]], {ch, splitBox[box, scale]}]];
    If[q["EmptyQ"], -Infinity, q["Peek"][[1]]]];
  (* True iff proved: no feasible point of root has component `which` (1 = obj, 2 = slack) >= T.
     A surviving box of scaled width < wMin returns False at once (conservative: nothing is
     discarded).  Without this cutoff a search around a genuinely feasible point would descend
     forever, because exact rational box endpoints never saturate the way floats do. *)
  wMin = 10^-10;
  refute[ev_, root_, K_, scale_, which_, T_, cap_] := Module[{st = {root}, box, w, n = 0},
    While[st =!= {},
      box = Last[st]; st = Most[st]; n++;
      If[n > cap, Return[False, Module]];
      w = ev[box, K];
      If[MissingQ[w] || w[[which]] < T, Continue[]];
      If[Max[(box[[All, 2]] - box[[All, 1]])/scale] < wMin, Return[False, Module]];
      st = Join[st, splitBox[box, scale]]];
    True];
  (* slack >= 0 is the feasibility test of (X)/(Y): "no point with slack >= 0" = "set empty" *)
  checkSlice[{klo_, khi_}] := Module[{ky = Bhi - klo, uy, T, far, near},
    uy = upperBound[evalY, yRootFar, ky, scaleY, 20000];
    far = If[uy === -Infinity, True,
      T = twoPiLo - uy; refute[evalX, xRoot, khi, scaleX, 1, T, 2*10^6]];
    (* NEAR-Y: either set may be the empty one; try both with growing box budgets (a failed
       attempt proves nothing and is simply retried with a larger budget) *)
    near = False;
    Do[If[refute[evalY, yRootNear, ky, scaleY, 2, 0, cap] || refute[evalX, xRoot, khi, scaleX, 2, 0, cap],
        near = True; Break[]], {cap, {2*10^3, 2*10^4, 2*10^5, 2*10^6}}];
    {far, near, uy}];
  verifySlice[s_, depth_] := Module[{r = checkSlice[s], m},
    If[r[[1]] && r[[2]], {{s, depth, r[[3]]}},
      If[depth >= 10, {{s, depth, "FAIL", r}},
        m = (s[[1]] + s[[2]])/2;
        Join[verifySlice[{s[[1]], m}, depth + 1], verifySlice[{m, s[[2]]}, depth + 1]]]]];
];
ReleaseHold[defs];

Print["23b: R in [", Rlo, ", ", Rhi, "], a in ", InputForm[aI], ", B in ", InputForm[BI], ", 3-R >= ", InputForm[uFarLo]];

(* ---------------- T: sanity tests ---------------- *)
(* T1 outward rounding of the precision-20 interval functions used, against 50-digit values.
   (Machine-precision Interval ArcCos/ArcTan/Exp in Mathematica 14.3 are NOT outward rounded --
   about a third of point evaluations exclude the true value by ~1e-16 -- which is why this
   certificate uses bignum intervals.) *)
SeedRandom[22];
fns = {ArcCos, ArcSin, ArcTan, Sqrt, Cos, Sin, 1/# &, #^2 &};
t1ok = And @@ Flatten@Table[
   With[{e = Rationalize[RandomReal[{0.01, 0.99}], 0], w = RandomReal[{0, 10^-3}]},
     Table[With[{iv = f[N[Interval[{e, e + w}], prec]]},
        ex[lo[iv]] <= Min[N[f[e], 50], N[f[e + w], 50]] && Max[N[f[e], 50], N[f[e + w], 50]] <= ex[hi[iv]]],
       {f, fns}]], {2000}];
t1ok = t1ok && And @@ Table[With[{e = Rationalize[RandomReal[{1, 3}], 0]},
     With[{iv = ArcTan[pt[e]]}, lo[iv] <= N[ArcTan[e], 50] <= hi[iv]]], {500}];
inI[iv_, x_] := lo[iv] <= N[x, 50] <= hi[iv];
Bfun[r_] := 12 ArcSin[1/r] - 2 Pi + 2 ArcSin[2/r];
t1ok = t1ok && inI[piI, Pi] && And @@ Table[inI[aI, ArcSin[1/r]] && inI[BI, Bfun[r]] && inI[RI, r] &&
     inI[rho0I, r - 2] && inI[dI, ArcSin[2/r]] && (Rlo - 2/Rlo <= r - 2/r), {r, {Rlo, (Rlo + Rhi)/2, Rhi}}];
(* the interval is inside [r_0, r_1] and contains (R_*, R_* + 10^-6]: R_* <= Rbar + 1.502e-21 *)
rbar = 263169077261980820552/10^20;
t1ok = t1ok && 263169/100000 <= Rlo <= rbar && rbar + 1502/10^24 + 10^-6 <= Rhi <= 26317/10000;
Print["T1 enclosures (2000 random boxes x 8 functions, 500 ArcTan args in [1,3], constants): ", t1ok];
(* T2 reference numbers quoted in Part M: B = 0.120662, C(1.085) = 0.122013, rho(B/2) = 1.965663 *)
t2 = {N[lo[BI]], N[cLo[pt[1085/1000]]], N[rhoLo[Bhi/2]]};
(* sanity only (r_1 reference values; the R-interval widens them by O(1e-4)) *)
t2ok = Abs[t2[[1]] - 0.1206621] < 10^-4 && Abs[t2[[2]] - 0.122013] < 2 10^-4 && Abs[t2[[3]] - 1.965663] < 2 10^-4;
Print["T2 B, C(1.085), rho(B/2) = ", t2, ": ", t2ok];
(* T3 negative controls: the far X set is NOT empty at full budget, and objX is NOT < 1.2 on it *)
t3far = refute[evalX, xRoot, Bhi, scaleX, 1, 6/5, 20000];
t3x = refute[evalX, xRoot, Bhi, scaleX, 2, 0, 20000];
Print["T3 negative controls (both must be False): objX<1.2 refuted? ", t3far, ";  far X empty at K=B? ", t3x];
If[!(t1ok && t2ok && !t3far && !t3x), Print["23b SANITY FAILED"]; Exit[2]];

(* ---------------- main run ---------------- *)
If[nSlices === pilot,
  Do[Print["pilot slice ", N[s], ": ", AbsoluteTiming[verifySlice[s, 0]]], {s, {{0, Bhi/48}, {Bhi 8/48, Bhi 9/48}}}];
  Exit[0]];
edges = Table[Bhi i/nSlices, {i, 0, nSlices}];
slices = Partition[edges, 2, 1];
cover = edges[[1]] == 0 && edges[[-1]] == Bhi && And @@ Thread[Most[edges] < Rest[edges]];
Print["slices: ", Length[slices], ", cover [0, B.hi] contiguously: ", cover];

LaunchKernels[nKer];
ParallelEvaluate[ReleaseHold[defs]];
t0 = AbsoluteTime[];
res = ParallelMap[(# -> AbsoluteTiming[verifySlice[#, 0]]) &, slices, Method -> "FinestGrained"];
Do[Print["slice ", N[r[[1]], 8], ": ", Round[r[[2, 1]]], " s, leaves ", Length[r[[2, 2]]],
   If[FreeQ[r[[2, 2]], "FAIL"], " OK", " FAIL"], ", max U_Y ", N[Max[Cases[r[[2, 2]], {_, _, x_?NumericQ} :> x]], 8]], {r, res}];
leaves = Join @@ res[[All, 2, 2]];
leafOK = FreeQ[leaves, "FAIL"];
(* the leaf sub-slices tile [0, B.hi] exactly (exact rational endpoints) *)
ls = Sort[leaves[[All, 1]]];
tile = ls[[1, 1]] == 0 && ls[[-1, 2]] == Bhi && And @@ Table[ls[[i, 2]] == ls[[i + 1, 1]], {i, Length[ls] - 1}];
Print["leaf sub-slices: ", Length[ls], ", tile [0,B.hi]: ", tile, ", B.hi >= B(Rlo) = max B: ", Bhi >= N[Bfun[Rlo], 50],
  ", time ", Round[AbsoluteTime[] - t0], " s"];
ok = cover && leafOK && tile;
Print[If[ok, "23b ALL SLICES VERIFIED (R in [2.63169, 2.631692])", "23b SOME SLICES FAILED"]];
Exit[If[ok, 0, 1]];
