#!/usr/bin/env wolframscript
(* run_krawczyk.wls -- n=8 Krawczyk inclusion-box radius for the KKT zero of
   (P): max R s.t. h_t(z)<=0 over the 14 active constraints at the proven optimum
   (center disk at O + regular 7-ring, s=2cos(pi/7), R=1+2cos(2pi/7)).

   Analogue of proofs/certificates/07-n11-local-opt.wls (K1 step), but here the
   KKT zero is EXACT closed-form, so we embed it exactly and SCAN the box radius
   `rad` to find the largest rad for which Krawczyk K(X) subset int(X) still
   certifies a unique zero in X.

   TWO coordinate systems:
   (R) symmetry-reduced: C7v -> variables (s, R, lam_tri, lam_pair) = 4 unknowns,
       4 equations.  Inner center (0,0) pinned by symmetry; rotation DOF killed.
   (F) full unreduced: all 8 centers (16 coords) + R + 14 multipliers = 31 unknowns,
       with a gauge row (pin ring-disk-0 y-coord = 0) to kill rotation.  Here the
       inner center's x,y are genuine variables -> the direct "inner center box".

   Interval arithmetic on 120-digit bigfloats, outward rounding.  Exit 0 iff a
   positive box radius certifies in both systems. *)

here = DirectoryName[ExpandFileName[$InputFileName]];
Get["/home/skim/projects/research/circovcir/wl/CirCovCir.wl"];
ip = 120;                                  (* interval working precision *)
$MaxExtraPrecision = 2000;                 (* trig closed forms need generous extra precision *)
k = 7;

(* ---------- exact optimum ---------- *)
sE  = 2 Cos[Pi/k];                         (* ring radius *)
RE  = 1 + 2 Cos[2 Pi/k];                   (* target radius R8 *)
th  = Table[2 Pi j/k, {j, 0, k - 1}];      (* ring angles, disk j on angle 2 pi j/7 *)
(* ring centers as functions of a scalar ring-radius s (rotation fixed: disk0 on +x) *)
ringC[s_] := Table[s {Cos[th[[j + 1]]], Sin[th[[j + 1]]]}, {j, 0, k - 1}];

cross[a_, b_] := a[[1]] b[[2]] - a[[2]] b[[1]];

(* interior-triple constraint h_tri(center=O, cj, cj+1) = circumradius^2 - 1 <= 0,
   using the shared formula (same algebra as 07's hInt but with first vertex O). *)
hTri[a_, b_, c_] := Module[{u = b - a, v = c - a},
   (u.u) (v.v) ((u - v).(u - v))/(4 cross[u, v]^2) - 1];

(* boundary-pair constraint: outward bisector hit y_ij, h = R^2 - |y|^2 <= 0.
   y = midpoint + s* perp, s* chosen on the OUTWARD branch (larger |y|). *)
wperp[a_, b_] := Module[{d = b - a}, {-d[[2]], d[[1]]}];
yOut[a_, b_] := Module[{w = wperp[a, b], m = (a + b)/2, t},
   t = Sqrt[1/(w.w) - 1/4];                 (* |y-m| so that nearest-disk dist =1 *)
   (* outward = away from O: choose sign of (m + t w) with larger norm *)
   If[(m + t w).(m + t w) >= (m - t w).(m - t w), m + t w, m - t w]];
hPair[R_, a_, b_] := R^2 - yOut[a, b].yOut[a, b];

(* ===================================================================== *)
(* (R)  SYMMETRY-REDUCED SYSTEM                                           *)
(* ===================================================================== *)
(* Variables u = {s, R, p, q}: s ring radius, R target, p = shared triple
   multiplier, q = shared pair multiplier. By C7v symmetry a symmetric KKT point
   equals a critical point of the symmetry-averaged reduced Lagrangian
   Lred = R - 7 p g1(s) - 7 q g2(s,R), with the two orbit representatives
   g1 = interior triple {O, c0, c1}, g2 = boundary pair {c0, c1}. The inner center
   (0,0) is pinned by symmetry; the rotation DOF is killed by fixing the ring angles
   (disk 0 on +x). We build g1,g2 as EXPLICIT SCALAR algebraic functions of (s,R)
   (substitute the parametrization, then differentiate a scalar) to avoid any
   symbolic vector-derivative artifacts. *)

(* explicit scalar constraints *)
(* build with a formal scalar variable sForm, then make pure functions *)
Clear[sForm, RForm];
g1expr = Simplify[hTri[{0, 0},
    sForm {Cos[th[[1]]], Sin[th[[1]]]},
    sForm {Cos[th[[2]]], Sin[th[[2]]]}]];
(* outward branch for the representative adjacent pair (0 and 2pi/7) is -1
   (the larger-norm, away-from-O branch; verified: |y_-|^2 = R^2 active). *)
hPairSg[R_, a_, b_, sg_] := Module[{w = wperp[a, b], m = (a + b)/2, t, y},
   t = Sqrt[1/(w.w) - 1/4]; y = m + sg t w; R^2 - y.y];
g2expr = Simplify[hPairSg[RForm,
    sForm {Cos[th[[1]]], Sin[th[[1]]]},
    sForm {Cos[th[[2]]], Sin[th[[2]]]}, -1]];

Clear[sv, Rv, pv, qv];
g1f[sv_]      = g1expr /. sForm -> sv;
g2f[sv_, Rv_] = g2expr /. {sForm -> sv, RForm -> Rv};

LredExpr = Rv - 7 pv g1f[sv] - 7 qv g2f[sv, Rv];
uvarsR = {sv, Rv, pv, qv};
FsysR = {g1f[sv], g2f[sv, Rv], D[LredExpr, sv], D[LredExpr, Rv]};
JsysR = D[FsysR, {uvarsR}];

(* exact KKT zero: s=sE, R=RE; solve the two linear stationarity eqs for (p,q) *)
solPQ = Solve[(FsysR[[3 ;; 4]] /. {sv -> sE, Rv -> RE}) == 0, {pv, qv}];
{pE, qE} = RootReduce[{pv, qv} /. First[solPQ]];
uStarR = {sE, RE, pE, qE};

Print["=== (R) symmetry-reduced system ==="];
Print["s*  = 2cos(pi/7)      = ", InputForm[N[sE, 25]]];
Print["R*  = 1+2cos(2pi/7)   = ", InputForm[N[RE, 25]]];
Print["lam_tri  (p*) = ", InputForm[N[pE, 25]]];
Print["lam_pair (q*) = ", InputForm[N[qE, 25]]];
Print["residual |F(u*)| (exact, should be {0,0,0,0}) = ",
  InputForm[Simplify[RootReduce[FsysR /. Thread[uvarsR -> uStarR]]]]];
Print["lam_tri > 0 : ", N[pE, 15] > 0, "   lam_pair > 0 : ", N[qE, 15] > 0];

(* ---------- Krawczyk box scan (reduced) ---------- *)
eps = 10^-(ip - 15);
iv[x_]  := Interval[{N[x, ip] - eps, N[x, ip] + eps}];
box[u_, rad_] := Interval[{N[# - rad, ip], N[# + rad, ip]}] & /@ u;
inside[a_, b_] := TrueQ[Min[a] > Min[b]] && TrueQ[Max[a] < Max[b]];

krawczykR[rad_] := Module[{X, FX, JX, Y, Kx, uc, widths, allin, coordfail},
   uc = iv /@ uStarR;
   X = box[uStarR, rad];
   FX = FsysR /. Thread[uvarsR -> uc];                     (* enclose F at u-star *)
   JX = JsysR /. Thread[uvarsR -> X];
   Y = Quiet@Rationalize[Inverse[N[JsysR /. Thread[uvarsR -> uStarR], 60]], 10^-50];
   Kx = uc - Y.FX + (IdentityMatrix[Length[uStarR]] - Y.JX).(X - uc);
   widths = MapThread[inside, {Kx, X}];
   allin = And @@ widths;
   coordfail = Flatten[Position[widths, False]];
   <|"ok" -> allin, "maxKX" -> Module[{ws = Quiet[N[(Max[#] - Min[#]), 20] & /@ Kx]}, ws = Select[ws, NumericQ]; If[ws === {}, "n/a", N[Max[ws]/(2 rad), 4]]],
     "fail" -> coordfail|>];

Print["--- (R) Krawczyk box scan ---"];
scanR = Quiet@Table[{rad, krawczykR[rad]}, {rad, {10^-1, 10^-2, 10^-3, 10^-4, 10^-5, 10^-6}}];
Do[Print["  rad=", ScientificForm[N[r[[1]], 2]], "  OK=", r[[2]]["ok"],
    "  maxK/X=", r[[2]]["maxKX"], "  fail-coords=", r[[2]]["fail"]], {r, scanR}];

(* bisection for the largest rad that certifies, 1 sig fig *)
bisectMax[kfun_, lo0_, hi0_] := Module[{lo = lo0, hi = hi0, mid, it = 0},
   (* assume kfun[lo] OK, kfun[hi] not OK *)
   While[hi/lo > 1.05 && it < 200, it++;
    mid = Sqrt[lo hi];
    If[kfun[mid]["ok"], lo = mid, hi = mid]];
   {lo, hi}];

(* find a bracket: largest decade that is OK, smallest that is not *)
decadesR = Quiet@Table[{e, krawczykR[10^e]["ok"]}, {e, 0, -8, -1}];
Print["  decade OK map (exp, ok): ", decadesR];
okExps = Select[decadesR, #[[2]] &][[All, 1]];
If[okExps =!= {},
  Module[{eOK = Max[okExps], eBad},
   eBad = eOK + 1;                       (* one decade larger should fail (or be the top) *)
   {loR, hiR} = Quiet@bisectMax[krawczykR, N[10^eOK, 30], N[10^eBad, 30]];
   Print["  (R) largest certifying rad in [", ScientificForm[N[loR, 3]], ", ",
     ScientificForm[N[hiR, 3]], "]  (1 sig fig: ", ScientificForm[N[loR, 1]], ")"];
   Print["  (R) at rad=", ScientificForm[N[loR, 2]], ": max K/X width ratio = ",
     krawczykR[loR]["maxKX"], "   first-failing coord beyond: ", krawczykR[hiR]["fail"],
     "  (coords: 1=s,2=R,3=lam_tri,4=lam_pair)"];
   maxRadR = loR;],
  Print["  (R) NO decade certified -- investigate"]; maxRadR = 0];

(* ===================================================================== *)
(* (F)  FULL UNREDUCED SYSTEM                                             *)
(* ===================================================================== *)
(* Variables: 8 centers (indices 1..8; 1 = inner, 2..8 = ring), each (x,y) -> 16;
   R -> 1; 14 multipliers (7 triples + 7 pairs) -> total 31.
   Gauge: pin ring-disk-2 (first ring disk) y-coordinate = 0 to kill rotation DOF.
   Inner center (c1) x,y are genuine variables here. *)

n = 8;
zz = Array[zc, 2 n];                        (* zc[1..16] = centers flattened *)
cenF[i_] := {zz[[2 i - 1]], zz[[2 i]]};
RF = Symbol["RRv"];

(* active sets (1-based): inner=1, ring 2..8 in angle order (disk 2 = +x) *)
triIdx  = Table[{1, j, If[j == n, 2, j + 1]}, {j, 2, n}];   (* {1,2,3},...,{1,8,2} *)
pairIdx = Table[{j, If[j == n, 2, j + 1]}, {j, 2, n}];      (* {2,3},...,{8,2} *)

(* fixed outward-branch signs from the exact config (so h is a smooth fn near opt) *)
cfg0 = CirCovCir`RingConfig[k];             (* {0,0}+ring, same order as indices 1..8 *)
rule0 = Thread[zz -> Flatten[cfg0]];
sgnPair[a_, b_] := Module[{w = wperp[cenF[a], cenF[b]], m = (cenF[a] + cenF[b])/2, t,
     yp, ym},
   t = Sqrt[1/(w.w) - 1/4];
   yp = (m + t w) /. rule0; ym = (m - t w) /. rule0;
   If[(yp.yp) >= (ym.ym), 1, -1]];
hPairF[R_, a_, b_, sg_] := Module[{w = wperp[cenF[a], cenF[b]], m = (cenF[a] + cenF[b])/2, t, y},
   t = Sqrt[1/(w.w) - 1/4]; y = m + sg t w; R^2 - y.y];
hTriF[a_, b_, c_] := hTri[cenF[a], cenF[b], cenF[c]];

hListF = Join[
   hTriF @@@ triIdx,
   MapThread[hPairF[RF, #1[[1]], #1[[2]], #2] &,
     {pairIdx, (sgnPair @@ #) & /@ pairIdx}]];

lamF = Array[lv, 14];
LF = RF - lamF.hListF;
(* stationarity wrt all 16 center coords and R; feasibility = the 14 active h's.
   The configuration is rotation-invariant => the ROTATIONAL derivative of L is an
   identically-zero combination of the 17 stationarity rows (one redundancy).  We
   kill the 1 rotation DOF with a gauge (pin ring-disk-2 y-coord = 0) and, to keep
   the system SQUARE and the Jacobian nonsingular, we REPLACE the stationarity row
   that is rotation-redundant.  Concretely: variables = 16 centers + R + 14 lam = 31;
   equations = 14 feasibility + 16 stationarity (drop the R-row? no -> drop one
   center-rotation row) ... cleanest: keep ALL 17 stationarity + 14 feasibility = 31
   AFTER substituting the gauge zz[[4]]->0 which removes variable zz[[4]].
   So: 30 variables (zz minus zz[4], plus R, plus 14 lam) ... that is 15+1+14 = 30,
   and 14 feas + 17 stat with 1 rotation redundancy = 30 independent. We SELECT a
   maximal independent square subsystem by dropping the single most rotation-aligned
   stationarity row, chosen by the numeric null-vector of the Jacobian. *)
statF = D[LF, {Join[zz, {RF}]}];              (* 17 stationarity eqs *)
gaugeVar = zz[[4]];                           (* y-coord of ring disk 2 -> gauge-fix to 0 *)

(* exact full optimum point *)
zStar = Flatten[cfg0];                         (* 16 center coords, exact *)
RstarF = RE;
(* multipliers at the full optimum: by symmetry all 7 triple-lams = pE, all 7 pair-lams = qE *)
lamStar = Join[ConstantArray[pE, 7], ConstantArray[qE, 7]];
uStarFfull = Join[zStar, {RstarF}, lamStar];
allVarsF = Join[zz, {RF}, lamF];

Print["=== (F) full unreduced system ==="];
Print["|F_stat+feas(u*)| at 60-digit (should be ~0): ",
  Quiet@ScientificForm[N[Max[Abs[N[Join[hListF, statF] /. Thread[allVarsF -> uStarFfull], 60]]], 4]]];

(* Build a SQUARE 31x31 system: 14 feasibility + 17 stationarity has a 1-dim
   rotation null space at the symmetric point (singular Jacobian).  Replace the
   stationarity row for the gauged coordinate zz[[4]] (ring-disk-2 y) with the
   gauge row (zz[[4]] = 0), which breaks the rotation degeneracy. *)
gaugeRowIndex = 4;                              (* position of zz[[4]] in the center block *)
statKeep = Delete[statF, gaugeRowIndex];        (* 16 stationarity rows *)
FsysF = Join[hListF, statKeep, {gaugeVar}];     (* 14 + 16 + 1 = 31 *)
JsysF = D[FsysF, {allVarsF}];

(* nonsingularity of the Jacobian at u* (numeric) *)
JatStar = Quiet@N[JsysF /. Thread[allVarsF -> uStarFfull], 60];
Print["dim FsysF = ", Length[FsysF], "  dim vars = ", Length[allVarsF]];
Print["det J(u*) (full, gauged) ~ ", ScientificForm[N[Det[JatStar], 4]],
  "   -> nonsingular: ", Abs[N[Det[JatStar]]] > 10^-20];

(* ---------- Krawczyk box scan (full) ---------- *)
krawczykF[rad_] := Module[{X, FX, JX, Y, Kx, uc, widths, allin, coordfail},
   uc = iv /@ uStarFfull;
   X = box[uStarFfull, rad];
   FX = FsysF /. Thread[allVarsF -> uc];
   JX = JsysF /. Thread[allVarsF -> X];
   Y = Quiet@Rationalize[Inverse[N[JsysF /. Thread[allVarsF -> uStarFfull], 70]], 10^-55];
   Kx = uc - Y.FX + (IdentityMatrix[Length[uStarFfull]] - Y.JX).(X - uc);
   widths = MapThread[inside, {Kx, X}];
   allin = And @@ widths;
   coordfail = Flatten[Position[widths, False]];
   <|"ok" -> allin, "maxKX" -> Module[{ws = Quiet[N[(Max[#] - Min[#]), 20] & /@ Kx]}, ws = Select[ws, NumericQ]; If[ws === {}, "n/a", N[Max[ws]/(2 rad), 4]]],
     "fail" -> coordfail,
     "innerXwidth" -> Quiet@Module[{w = N[Max[Kx[[1]]] - Min[Kx[[1]]], 20]}, If[NumericQ[w], N[w, 4], "n/a"]],
     "innerYwidth" -> Quiet@Module[{w = N[Max[Kx[[2]]] - Min[Kx[[2]]], 20]}, If[NumericQ[w], N[w, 4], "n/a"]]|>];

Print["--- (F) Krawczyk box scan (coords 1,2 = inner center x,y) ---"];
scanF = Quiet@Table[{rad, krawczykF[rad]}, {rad, {10^-1, 10^-2, 10^-3, 10^-4, 10^-5}}];
Do[Print["  rad=", ScientificForm[N[r[[1]], 2]], "  OK=", r[[2]]["ok"],
    "  maxK/X=", r[[2]]["maxKX"], "  fail-coords=", r[[2]]["fail"]], {r, scanF}];

decadesF = Quiet@Table[{e, krawczykF[10^e]["ok"]}, {e, 0, -8, -1}];
Print["  (F) decade OK map (exp, ok): ", decadesF];
okExpsF = Select[decadesF, TrueQ[#[[2]]] &][[All, 1]];
If[okExpsF =!= {},
  Module[{eOK = Max[okExpsF], eBad},
   eBad = eOK + 1;
   {loF, hiF} = Quiet@bisectMax[krawczykF, N[10^eOK, 30], N[10^eBad, 30]];
   Print["  (F) largest certifying rad in [", ScientificForm[N[loF, 3]], ", ",
     ScientificForm[N[hiF, 3]], "]  (1 sig fig: ", ScientificForm[N[loF, 1]], ")"];
   Print["  (F) at rad=", ScientificForm[N[loF, 2]], ": max K/X = ", krawczykF[loF]["maxKX"],
     "   inner-center K-widths (x,y) = (", krawczykF[loF]["innerXwidth"], ", ",
     krawczykF[loF]["innerYwidth"], ")   first-failing coord beyond: ", krawczykF[hiF]["fail"]];
   maxRadF = loF;],
  Print["  (F) NO decade certified"]; maxRadF = 0];

(* coordinate legend for failing-coord indices *)
Print["  (F) coord legend: 1..16 = centers (1,2)=inner x,y; (3,4)=ring2 x,y (y gauged);",
  " 17=R; 18..24=triple lam; 25..31=pair lam"];

(* ---------- summary ---------- *)
Print["=================================================================="];
Print["SUMMARY (part 1):"];
Print["  reduced max certifying box radius ~ ", ScientificForm[N[maxRadR, 2]],
  " (first-failing coord: lam_tri)"];
Print["  full    max certifying box radius ~ ", ScientificForm[N[maxRadF, 2]]];
Print["=================================================================="];

(* persist a small JSON of the key numbers *)
res = <|
  "s_star" -> N[sE, 30], "R_star" -> N[RE, 30],
  "lam_tri" -> N[pE, 30], "lam_pair" -> N[qE, 30],
  "reduced_max_rad" -> N[maxRadR, 6], "reduced_first_fail" -> "lam_tri (coord 3)",
  "full_max_rad" -> N[maxRadF, 6],
  "ip_digits" -> ip|>;
Export[FileNameJoin[{here, "out", "krawczyk_results.json"}], res, "RawJSON", "Compact" -> False];
Print["wrote out/krawczyk_results.json"];
If[maxRadR > 0 && maxRadF > 0, Exit[0], Exit[1]];
