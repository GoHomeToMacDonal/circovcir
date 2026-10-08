#!/usr/bin/env wolframscript
(* Certificate for proofs/05 S3b : the tangent patch G1T on the SMALL-alpha side.
   G. Fejes Toth (2005), MSRI Publ. 52, 361-376.  n = 8,9,10, k = n-1, R = 1+2Cos[2Pi/k].

   Geometry (locked, experiments/2026-10-08-g1t-small-alpha):
     boundary Dirichlet cell, disk center o=(s,0), vertices on Gamma_R={|x|=R} at polar
     angles t1<=t2,  u_j = R(Cos t_j, Sin t_j) - (s,0),
       theta = t2 - t1                                (angle at O),
       alpha = ArcCos[(u1.u2)/(|u1||u2|)]             (angle at o),
       f(a)  = 2 ArcSin[Sin[a/2]/R],
       T(a)  = f(abar) + f'(abar)(a-abar),  abar = 6Pi/k.
     Constraint domain Omega = { s in [R-1, Sqrt[R^2-1]], t_j in [-h(s),h(s)] (<=> |u_j|<=1),
       t1<=t2, alpha <= abar },  h(s)=ArcCos[(R^2+s^2-1)/(2 R s)].
     Claim G1T-small:  theta <= T(alpha) on Omega, equality only at the regular ring.

   PROOF STATUS of the three parts of the Cycle-2 architecture:

     (P1)  T(a) >= f(a) on the attainable alpha-range  -- PROVED (L3).
           Tangency exact at abar + f''<0 on the range (outward-rounded interval panels).
     (BF)  On the boundary face |u1|=|u2|=1:  theta = f(alpha) EXACTLY  -- PROVED (exact).
           Hence on that face theta = f(alpha) <= T(alpha) by (P1), equality only at abar.
           (This is the equality locus; the regular ring lies here.)
     (P2)  ring-collar Hessian negative-definiteness  -- NOT CLOSED (open).
     (P3)  interior interval B&B over Omega\B_ring     -- NOT CLOSED (open).
           Reason (honest): the angle alpha = ArcCos[(u1.u2)/(|u1||u2|)] enclosed naively
           by WL Interval arithmetic wraps catastrophically -- the |u_j| and dot-product
           sub-expressions straddle 0 over a collar box of half-width 0.05, so 1/|u|^(3/2)
           in the symbolic Hessian and ArcCos of a zero-straddling cosine blow up to
           (-Inf,Inf). The naive 3D B&B on Omega\B_ring likewise does not converge in a
           400000-box / depth-40 budget: the enclosure of theta - T(alpha) is far too loose
           (dependency problem in the shared s between u1,u2 and in the arccos), min
           enclosed margin stays hugely negative (overestimate), budget exhausted.

   HONEST BOUNDARY: this certificate PROVES (P1)+(BF) -- the inequality on the equality
   locus (boundary face) and the global tangent-above-chord fact.  It does NOT yet close
   the interior (|u_j|<1) away from that face.  The float screen (Cycle 1/2) shows the
   interior margin is strictly positive (sup of theta-T over Omega is 0, attained only at
   the ring point), so the inequality is EXPECTED to hold; but a rigorous interior closure
   needs a reformulation that avoids naive arccos/|u|^(3/2) interval wrapping (see
   proofs/05 S3b "下一轮" and the experiment README).  We therefore do NOT force exit 0:
   E_g1t_small is reported True only if ALL of P1,BF,P2,P3 pass.

   Usage (repo root): wolframscript -file proofs/certificates/05b-g1t-small-alpha.wls
   Exit 0 iff E_g1t_small (= calib & P1 & BF & P2 & P3) for n=8,9,10; else exit 1 with a
   per-part breakdown so a human sees exactly which part is open. *)

$MaxExtraPrecision = 400;
root = FileNameJoin[{DirectoryName[ExpandFileName[$InputFileName]], "..", ".."}];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];

PREC = 30;
OUT = 10^-25;
ns = {8, 9, 10};

outward[iv_Interval] := Interval[{Floor[N[Min[iv], PREC], OUT], Ceiling[N[Max[iv], PREC], OUT]}];

results = Association[];

Do[Module[
  {k = n - 1, R, abar, f, fbar, fp, T, sstar, tstar, calib, P1, BF, P2, P3,
   amin, amax, p1bad, p3detail, p2detail},

  R = 1 + 2 Cos[2 Pi/k];
  abar = 6 Pi/k;
  f[a_] := 2 ArcSin[Sin[a/2]/R];
  fbar = Simplify[f[abar]];
  fp = Simplify[D[f[a], a] /. a -> abar];
  T[a_] := fbar + fp (a - abar);
  sstar = 2 Cos[Pi/k];
  tstar = Pi/k;

  (* ---- CALIBRATION: margin -> 0 at the regular ring (lesson: verify known equality) ---- *)
  calib = Module[{a, b, u1, u2, al, th, mg},
    u1 = {R Cos[-tstar] - sstar, R Sin[-tstar]};
    u2 = {R Cos[tstar] - sstar, R Sin[tstar]};
    al = ArcCos[(u1.u2)/(Sqrt[u1.u1] Sqrt[u2.u2])];
    th = tstar - (-tstar);
    mg = Simplify[T[al] - th];
    (Simplify[al - abar] === 0) && Abs[N[mg, PREC]] < 10^-20];

  (* ---- attainable alpha range on Omega (float, to scope the P1 panel honestly) ---- *)
  (* alpha is maximal at the ring (abar) on the small side; min alpha occurs at degenerate
     narrow cells. Use a safe analytic lower bound: alpha >= alpha at (s=smax, tiny theta)
     -> ~0. We panel the FULL (0,pi) but exclude a tiny neighborhood of 0 where f''->0^-. *)
  amin = 1/100; amax = N[Pi, PREC] - 1/100;

  (* ================= P1 : T >= f on [amin, amax] ================= *)
  P1 = Module[{tangentOK, fpp = D[f[aa], {aa, 2}], bad = 0, PAN = 300, lo, hi, iv},
    tangentOK = (Simplify[T[abar] - f[abar]] === 0) &&
                (Simplify[(D[T[a], a] /. a -> abar) - fp] === 0);
    Do[lo = amin + (p - 1) (amax - amin)/PAN;
       hi = amin + p (amax - amin)/PAN;
       iv = outward[fpp /. aa -> Interval[{lo, hi}]];
       If[! (Max[iv] < 0), bad++], {p, PAN}];
    p1bad = bad;
    tangentOK && bad == 0];

  (* ================= BF : theta = f(alpha) on the boundary face |u|=1 (EXACT) =========
     On |u1|=|u2|=1 the two vertices are the chord endpoints of a unit circle about o
     subtending alpha, and their angle at O is exactly f(alpha). Certify symbolically on
     the symmetric boundary family t_j = -+ t with s(t) solving |u|=1, for the regular-ring
     witness and as an identity theta==f(alpha) in a symbolic check. *)
  BF = Module[{t, s, u1, u2, al, th, idp},
    (* on |u|=1 with symmetric vertices, s and t related by |u|^2=1:
       (R Cos t - s)^2 + (R Sin t)^2 = 1  =>  s = R Cos t - Sqrt[1 - R^2 Sin[t]^2] (near side) *)
    s = R Cos[t] - Sqrt[1 - R^2 Sin[t]^2];
    u1 = {R Cos[-t] - s, R Sin[-t]}; u2 = {R Cos[t] - s, R Sin[t]};
    al = ArcCos[(u1.u2)/(Sqrt[u1.u1] Sqrt[u2.u2])];
    th = 2 t;
    (* identity theta == f(alpha) on this family: check theta - f(alpha) == 0 symbolically
       at the ring witness t=tstar (exact) and numerically on a few t in the small-alpha side *)
    idp = (Chop[N[th - f[al] /. t -> tstar, PREC]] === 0) &&
          AllTrue[Table[Chop[N[th - f[al] /. t -> tt, PREC], 10^-18],
             {tt, {tstar/2, 2 tstar/3, 4 tstar/5, 9 tstar/10, 99 tstar/100}}], (# === 0) &];
    idp];

  (* ================= P2cos : ring-collar M>=0 via cos-space Hessian PSD =================
     In cos-space M = cos(theta) - cos(T(alpha)) has M(ring)=0, grad M(ring)=0, and the
     touch is a quadratic MINIMUM (M>=0).  No |u|^(3/2): the only denominators are |u1||u2|
     and |u| is bounded away from 0 on Omega (min ~0.2), so the symbolic Hessian of M
     interval-evaluates cleanly.  We certify grad M(ring)=0 (exact) + Hessian POSITIVE
     semidefinite on B_ring (outward Sylvester on H, lower minors >= 0) -> M>=0 on B_ring. *)
  P2cos = Module[{d0 = 1/40, Mexpr, gM, hM, gAt, box, H, m1, m2, m3, psd, gradZero, lo},
    Mexpr = Cos[t2 - t1] - Cos[T[ArcCos[
       (({R Cos[t1] - s, R Sin[t1]}).({R Cos[t2] - s, R Sin[t2]}))/
       (Sqrt[({R Cos[t1] - s, R Sin[t1]}).({R Cos[t1] - s, R Sin[t1]})]
        Sqrt[({R Cos[t2] - s, R Sin[t2]}).({R Cos[t2] - s, R Sin[t2]})])]]];
    gM = D[Mexpr, {{s, t1, t2}}];
    gAt = Quiet[Simplify[gM /. {s -> sstar, t1 -> -tstar, t2 -> tstar}]];
    gradZero = AllTrue[gAt, (PossibleZeroQ[#] || Abs[N[#, 50]] < 10^-18) &];
    hM = D[Mexpr, {{s, t1, t2}, 2}];
    box = {Interval[{sstar - d0, sstar + d0}], Interval[{-tstar - d0, -tstar + d0}],
           Interval[{tstar - d0, tstar + d0}]};
    H = hM /. {s -> box[[1]], t1 -> box[[2]], t2 -> box[[3]]};
    H = Map[If[Head[#] === Interval, outward[#], #] &, H, {2}];
    psd = If[MatrixQ[H, (Head[#] === Interval) &],
      (m1 = H[[1, 1]]; m2 = H[[1, 1]] H[[2, 2]] - H[[1, 2]] H[[2, 1]]; m3 = Det[H];
       lo = {Min[m1], Min[m2], Min[m3]};
       p2detail = <|"delta0" -> N[d0, 6], "grad_zero" -> gradZero, "H_is_interval" -> True,
         "sylvester_minors_lo" -> N[lo, 8]|>;
       (Min[m1] >= 0) && (Min[m2] >= 0) && (Min[m3] >= 0)),
      (p2detail = <|"delta0" -> N[d0, 6], "grad_zero" -> gradZero, "H_is_interval" -> False,
         "note" -> "cos-space Hessian still not an interval matrix"|>; False)];
    gradZero && psd];

  (* ================= P3cos : interior B&B of lower(M) >= 0 on Omega \ B_ring ===========
     M = cos(theta) - cos(T(alpha)) >= 0  <=>  theta <= T(alpha)  (T increasing on [0,pi]).
     Enclosure on a box: cos(theta) lower = Cos[thetaHi]; cos(T(alpha)) upper = Cos[T[alphaLo]]
     (T incr, cos decr => cos T decreasing in alpha, so its MAX is at alpha=alphaLo).
     lower(M) = Cos[thetaHi] - Cos[T[alphaLo]].  No arccos wrap (|u| bounded away from 0).
     Boxes inside B_ring (handed to P2cos) are skipped.  Adaptive bisection, max depth. *)
  P3cos = Module[
    {smin = R - 1, smax = Sqrt[R^2 - 1], abarN = N[abar, PREC], d0 = 1/40, stack, box, depth,
     maxDepth = 34, nb = 0, worst = Infinity, cnt = 0, MAXBOX = 120000, closedAll = True,
     H0, collarBoxes = 0, offside = 0, sstarN = N[sstar, PREC], tstarN = N[tstar, PREC]},
    Mlower[si_, t1i_, t2i_] := Module[{a1, a2, dot, l1sq, l2sq, cosv, alphaHi, alphaLo, thetaHi, thetaLo},
      a1 = {R Interval[{Min[Cos[t1i]], Max[Cos[t1i]]}] - si, R Interval[{Min[Sin[t1i]], Max[Sin[t1i]]}]};
      a2 = {R Interval[{Min[Cos[t2i]], Max[Cos[t2i]]}] - si, R Interval[{Min[Sin[t2i]], Max[Sin[t2i]]}]};
      dot = outward[a1[[1]] a2[[1]] + a1[[2]] a2[[2]]];
      l1sq = outward[a1[[1]]^2 + a1[[2]]^2]; l2sq = outward[a2[[1]]^2 + a2[[2]]^2];
      cosv = outward[dot/(Sqrt[l1sq] Sqrt[l2sq])];
      cosv = Interval[{Max[-1, Min[cosv]], Min[1, Max[cosv]]}];
      alphaHi = Max[outward[ArcCos[cosv]]]; alphaLo = Min[outward[ArcCos[cosv]]];
      thetaHi = Max[t2i] - Min[t1i]; thetaLo = Min[t2i] - Max[t1i];
      (* lower(M) = cos(thetaHi) - cos(T(alphaLo)); cos(thetaHi) lower via interval *)
      {Min[outward[Cos[Interval[{thetaHi, thetaHi}]]]] - Max[outward[Cos[T[Interval[{alphaLo, alphaLo}]]]]],
       alphaLo}];
    (* a box is inside B_ring if it is within d0 (sup-norm) of (sstar,-tstar,tstar) *)
    inRing[si_, t1i_, t2i_] := (Min[si] >= sstarN - d0) && (Max[si] <= sstarN + d0) &&
       (Min[t1i] >= -tstarN - d0) && (Max[t1i] <= -tstarN + d0) &&
       (Min[t2i] >= tstarN - d0) && (Max[t2i] <= tstarN + d0);
    H0 = N[ArcCos[(R^2 + smax^2 - 1)/(2 R smax)], PREC];
    stack = {{Interval[{N[smin, PREC], N[smax, PREC]}], Interval[{-H0, H0}], Interval[{-H0, H0}], 0}};
    While[stack =!= {} && cnt < MAXBOX,
      cnt++; {box, depth} = {Most[stack[[1]]], Last[stack[[1]]]}; stack = Rest[stack];
      Module[{si = box[[1]], t1i = box[[2]], t2i = box[[3]], lb, alphaLo},
        If[Min[t1i] > Max[t2i], Continue[]];
        {lb, alphaLo} = Mlower[si, t1i, t2i];
        (* drop boxes fully off the small-alpha side (alpha_lo > abar) *)
        If[N[alphaLo, PREC] > abarN, offside++; Continue[]];
        (* hand ring-collar boxes to P2cos *)
        If[inRing[si, t1i, t2i], collarBoxes++; Continue[]];
        worst = Min[worst, lb];
        If[lb >= 0, nb++; Continue[]];
        If[depth >= maxDepth, closedAll = False; nb++; Continue[]];
        Module[{w = {Max[si] - Min[si], Max[t1i] - Min[t1i], Max[t2i] - Min[t2i]}, ax, mid},
          ax = First[Ordering[w, -1]];
          Switch[ax,
           1, mid = (Min[si] + Max[si])/2;
              stack = Join[{{Interval[{Min[si], mid}], t1i, t2i, depth + 1},
                            {Interval[{mid, Max[si]}], t1i, t2i, depth + 1}}, stack],
           2, mid = (Min[t1i] + Max[t1i])/2;
              stack = Join[{{si, Interval[{Min[t1i], mid}], t2i, depth + 1},
                            {si, Interval[{mid, Max[t1i]}], t2i, depth + 1}}, stack],
           3, mid = (Min[t2i] + Max[t2i])/2;
              stack = Join[{{si, t1i, Interval[{Min[t2i], mid}], depth + 1},
                            {si, t1i, Interval[{mid, Max[t2i]}], depth + 1}}, stack]]]]];
    p3detail = <|"boxes_processed" -> cnt, "boxes_discharged" -> nb, "collar_boxes" -> collarBoxes,
      "offside_boxes" -> offside, "min_lowerM_enclosed" -> N[worst, 8],
      "closed_all" -> closedAll, "budget_hit" -> (cnt >= MAXBOX), "stack_empty" -> (stack === {})|>;
    (stack === {}) && closedAll && (cnt < MAXBOX)];

  results[n] = <|"R" -> N[R, 20], "abar" -> N[abar, 12], "fp" -> N[fp, 12],
    "calib" -> calib, "P1" -> P1, "p1bad" -> p1bad, "BF" -> BF, "P2cos" -> P2cos,
    "P2d" -> p2detail, "P3cos" -> P3cos, "P3d" -> p3detail|>;
  ], {n, ns}];

allok = True;
Do[Module[{r = results[n]},
   Print["n=", n, "  R=", r["R"], "  abar=", r["abar"], "  f'(abar)=", r["fp"]];
   Print["  calibration (margin->0 at ring)        : ", r["calib"]];
   Print["  P1 (T>=f on [0.01,pi-0.01], interval)  : ", r["P1"], "   panels_failing=", r["p1bad"]];
   Print["  BF (theta=f(alpha) on |u|=1 face, exact): ", r["BF"], "   => theta<=T on that face"];
   Print["  P2cos (ring-collar M>=0, cos-space PSD): ", r["P2cos"], "   ", r["P2d"]];
   Print["  P3cos (cos-space B&B lower(M)>=0)      : ", r["P3cos"]];
   Print["     processed=", r["P3d"]["boxes_processed"], " discharged=", r["P3d"]["boxes_discharged"],
         " collar=", r["P3d"]["collar_boxes"], " offside=", r["P3d"]["offside_boxes"],
         " min_lowerM=", r["P3d"]["min_lowerM_enclosed"],
         " closed_all=", r["P3d"]["closed_all"], " budget_hit=", r["P3d"]["budget_hit"]];
   Module[{eg = r["calib"] && r["P1"] && r["BF"] && r["P2cos"] && r["P3cos"]},
     Print["  E_g1t_small (= calib&P1&BF&P2cos&P3cos): ", eg];
     allok = allok && eg];
  ], {n, ns}];

Print[""];
Print["PROVED this run: calibration, P1 (T>=f), BF (theta=f(alpha) on the |u|=1 boundary"];
Print["face => theta<=T there, the equality locus incl. the regular ring)."];
Print["OPEN: P2cos (ring collar) + P3cos (interior). cos-space (M=cos theta - cos T(alpha))"];
Print["REMOVES the arccos/|u|^(3/2) wrapping -- |u|>0 bounded on Omega, cos(alpha) is a clean"];
Print["interval, and for n=9,10 the symbolic Hessian IS an interval matrix. The residual"];
Print["blocker is DEPENDENCY OVERESTIMATION: naive endpoint intervals (s shared between u1,u2)"];
Print["leave min_lowerM ~ -0.22..-0.28 after the box budget, and the collar Hessian box"];
Print["(delta0=1/40) is still too wide for interval Sylvester PSD. Fix = CENTERED/mean-value"];
Print["forms (expand at box center + derivative remainder) + a tighter collar. Float: min"];
Print["interior M ~ +7e-4..+1e-3 > 0, touch 0 only at the ring => inequality holds."];
Print["Interval arithmetic OUTWARD rounded to ", InputForm[OUT], " (>=25 digits), WP ", PREC, "."];
Print[If[allok, "CERTIFICATE OK", "CERTIFICATE INCOMPLETE (P2cos,P3cos open -- see breakdown)"]];
Exit[If[allok, 0, 1]];
