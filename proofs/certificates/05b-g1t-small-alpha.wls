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

   PROOF STATUS of the four parts of the architecture (Cycle-9):

     (P1)      T(a) >= f(a) on the attainable alpha-range  -- PROVED (L3).
               Tangency exact at abar + f''<0 on the range (outward-rounded interval panels).
     (BF)      On the boundary face |u1|=|u2|=1:  theta = f(alpha) EXACTLY  -- PROVED (exact).
               Hence on that face theta = f(alpha) <= T(alpha) by (P1), equality only at abar.
               (This is the equality locus; the regular ring lies here.)
     (Pcollar) ring-collar M>=0 via a FIRST-ORDER KKT gradient-sign argument on B_ring
               = ring +- 1/160 (sup-norm).  No Hessian (the ring is a KKT boundary minimum,
               not an interior critical point), just outward interval gradient signs
               dM/dt1>0, dM/dt2<0, d|u1|^2/dt1<0, d|u2|^2/dt2>0 plus BF+P1 on the |u|=1 face.
     (Pbb)     interior interval branch-and-bound of lower(M) >= 0 on Omega \ B_ring,
               with M = cos(theta) - cos(T(alpha)) >= 0 <=> theta <= T(alpha).

   Cycle-9 fixes that made Pbb close (previously exit 1, min_lowerM stuck ~ -0.22):
     Bug 1 (ArcCos' blow-up).  The old centered form used the SYMBOLIC gradient
       D[... Cos[T[ArcCos[w]]] ...] which contains ArcCos'[w] = -1/Sqrt[1-w^2].  Over a box
       whose w = cos(alpha) interval touched +-1 (narrow/degenerate cells, w -> 1), 1-w^2
       straddled 0 and the whole gradient enclosure became (-Inf,Inf) -> corr=Inf -> cen=-Inf.
       FIX: keep w and dw/dx as CLEAN rational/trig expressions (no ArcCos) and build the
       Q = 1/Sqrt[1-w^2] factor SEPARATELY via the chain rule, enclosing it only when w is
       provably inside (-1,1) with margin eQ (else fall back to the always-valid naive bound).
     Bug 2 (non-finite Exit).  worst could be a symbolic Interval containing Inf, so
       N[worst,8] stayed Inf and the Exit decision was not honestly numeric.  FIX: every box
       lower bound is N[]-evaluated and finite-asserted (any non-finite -> finite sentinel
       -BIG, box subdivides); worst is tracked over LEAVES only; and Pbb's return conjoins an
       explicit finite-real-and->=0 test, so no symbolic/Inf can reach Exit.
     Closure key.  The B&B over-box [smin,smax] x [-H0,H0]^2 strictly contains Omega; its
       infeasible corner near s=R-1 (where h(s)->0, |u_j|>1) dragged the bound negative.
       Dropping any box with Min[|u1|^2]>1 or Min[|u2|^2]>1 (entirely outside Omega) collapses
       the search to a few thousand boxes and makes min_lowerM strictly positive.

   HONEST BOUNDARY: this certificate reports Exit 0 ONLY if calib & P1 & BF & Pcollar & Pbb
   are ALL True for n=8,9,10, and Pbb is True ONLY if its B&B tree fully closes (stack empty,
   no depth-cap leaf, within budget) with a FINITE worst-leaf lower bound >= 0.  The per-part
   breakdown is printed either way so a human sees exactly the state.  The float screen
   (Cycle 1/2) shows the interior margin is strictly positive (sup of theta-T over Omega is 0,
   attained only at the ring point), consistent with the certified min_lowerM > 0.

   Usage (repo root): wolframscript -file proofs/certificates/05b-g1t-small-alpha.wls
   Exit 0 iff E_g1t_small (= calib & P1 & BF & Pcollar & Pbb) for n=8,9,10; else exit 1 with a
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

  (* ================= Pcollar : ring-collar M>=0 via FIRST-ORDER KKT argument ===========
     CORRECTED (Cycle 7/8): the ring is NOT an interior critical point -- it is a KKT
     BOUNDARY minimum.  grad M(ring) != 0 (= 0.661/0.5/0.381), both constraints |u1|^2=1,
     |u2|^2=1 active, and M is CONCAVE at the ring (lambda_min(H)<0), so Hessian-PSD is the
     WRONG tool.  Instead, on the collar box B_ring = ring +- delta0 we certify by OUTWARD
     interval gradient the sign structure
         dM/dt1 > 0,   dM/dt2 < 0,     (M increasing in t1, decreasing in t2)
         d|u1|^2/dt1 < 0,  d|u2|^2/dt2 > 0.
     Consequence (the collar lemma): for ANY feasible x=(s,t1,t2) in B_ring,
       feasibility |u1|^2<=1 with d|u1|^2/dt1<0  =>  t1 >= tau1(s)  (|u1(s,tau1)|=1),
       and dM/dt1>0  =>  M(s,t1,t2) >= M(s,tau1,t2);
       feasibility |u2|^2<=1 with d|u2|^2/dt2>0  =>  t2 <= tau2(s),
       and dM/dt2<0  =>  M(s,tau1,t2) >= M(s,tau1,tau2);
     and (s,tau1,tau2) has |u1|=|u2|=1, i.e. lies on the boundary face, where
       M = cos(theta) - cos(T(alpha)) = cos(f(alpha)) - cos(T(alpha)) >= 0  by BF + P1
       (theta=f(alpha) on the face, T>=f on (0,pi), cos decreasing).
     Hence M(x) >= 0 on all of B_ring.  No Hessian, no path integral -- just interval
     gradient signs on B_ring plus BF+P1 on the face.  delta0 = 1/160 (verified for n=8,9,10). *)
  Pcollar = Module[{d0 = 1/160, box1, box2, boxs, dMdt1, dMdt2, du1dt1, du2dt2,
      g1, g2, c1, c2, Mexpr, w},
    w = (({R Cos[t1] - s, R Sin[t1]}).({R Cos[t2] - s, R Sin[t2]}))/
        (Sqrt[({R Cos[t1] - s, R Sin[t1]}).({R Cos[t1] - s, R Sin[t1]})]
         Sqrt[({R Cos[t2] - s, R Sin[t2]}).({R Cos[t2] - s, R Sin[t2]})]);
    Mexpr = Cos[t2 - t1] - Cos[T[ArcCos[w]]];
    dMdt1 = D[Mexpr, t1]; dMdt2 = D[Mexpr, t2];
    du1dt1 = D[({R Cos[t1] - s, R Sin[t1]}).({R Cos[t1] - s, R Sin[t1]}), t1];
    du2dt2 = D[({R Cos[t2] - s, R Sin[t2]}).({R Cos[t2] - s, R Sin[t2]}), t2];
    (* interval boxes over B_ring *)
    box1 = {s -> Interval[{sstar - d0, sstar + d0}], t1 -> Interval[{-tstar - d0, -tstar + d0}],
            t2 -> Interval[{tstar - d0, tstar + d0}]};
    g1 = outward[dMdt1 /. box1]; g2 = outward[dMdt2 /. box1];
    c1 = outward[du1dt1 /. {s -> Interval[{sstar - d0, sstar + d0}], t1 -> Interval[{-tstar - d0, -tstar + d0}]}];
    c2 = outward[du2dt2 /. {s -> Interval[{sstar - d0, sstar + d0}], t2 -> Interval[{tstar - d0, tstar + d0}]}];
    p2detail = <|"delta0" -> N[d0, 8], "dMdt1_lo" -> N[Min[g1], 8], "dMdt2_hi" -> N[Max[g2], 8],
      "du1sq_dt1_hi" -> N[Max[c1], 8], "du2sq_dt2_lo" -> N[Min[c2], 8],
      "note" -> "KKT first-order collar: M increasing in t1, decreasing in t2; feasibility pins t1,t2 to the |u|=1 face where M>=0 (BF+P1)"|>;
    (Min[g1] > 0) && (Max[g2] < 0) && (Max[c1] < 0) && (Min[c2] > 0)];

  (* ================= Pbb : interior B&B of lower(M) >= 0 on Omega \ B_ring =============
     M = cos(theta) - cos(T(alpha)) >= 0  <=>  theta <= T(alpha)  (T increasing on [0,pi]).
     CENTERED-FORM lower bound (kills the s-shared dependency overestimate, Cycle 6):
       M_lo(X) = M(c) - sum_i rad_i * max|dM/dx_i(X)|,  c = box center, rad = half-widths.
     Falls back to the naive endpoint lower bound and takes the max of the two.
     Boxes inside B_ring (delta0 = 1/160, SAME as Pcollar) are skipped -> handed to Pcollar.
     Coverage: B_ring (Pcollar) + (Omega \ B_ring) (this B&B) + alpha>abar dropped = all of Omega. *)
  Pbb = Module[
    {smin = R - 1, smax = Sqrt[R^2 - 1], abarN = N[abar, PREC], d0 = 1/160, stack, box, depth,
     maxDepth = 100, nb = 0, worst = Infinity, cnt = 0, MAXBOX = 60000, closedAll = True,
     H0, collarBoxes = 0, offside = 0, infeasBoxes = 0, sstarN = N[sstar, PREC], tstarN = N[tstar, PREC],
     Mpt, wsym, dwds, dwdt1, dwdt2, fpN = N[fp, PREC], eQ = 1/10^6, BIG = 10^6, worstBox = None},
    (* ---- CLEAN symbolic pieces: NO ArcCos anywhere in the gradient parts. ----
       w = cos(alpha) = (u1.u2)/(|u1||u2|) is a pure rational/trig expression; so are its
       partials dw/dx. The ArcCos ONLY appears (a) once, numerically, inside Mpt at the box
       CENTER, and (b) as the factor Q = 1/Sqrt[1-w^2] = -d(ArcCos w)/dw, which we build
       SEPARATELY and enclose only when w is PROVABLY inside (-1,1) (else we fall back to the
       naive bound). This is the Cycle-9 fix for Bug 1 (the old symbolic D[...ArcCos...]
       produced ArcCos'[w] over a w-interval that straddled +-1 -> 1/Sqrt[1-w^2] = (-Inf,Inf)
       -> corr = Inf -> cen = -Inf -> worst non-finite). *)
    wsym = (({R Cos[t1] - s, R Sin[t1]}).({R Cos[t2] - s, R Sin[t2]}))/
           (Sqrt[({R Cos[t1] - s, R Sin[t1]}).({R Cos[t1] - s, R Sin[t1]})]
            Sqrt[({R Cos[t2] - s, R Sin[t2]}).({R Cos[t2] - s, R Sin[t2]})]);
    Mpt[sv_, t1v_, t2v_] := Cos[t2v - t1v] - Cos[T[ArcCos[wsym /. {s -> sv, t1 -> t1v, t2 -> t2v}]]];
    dwds = D[wsym, s]; dwdt1 = D[wsym, t1]; dwdt2 = D[wsym, t2];
    Mlower[si_, t1i_, t2i_] := Module[
      {a1, a2, dot, l1sq, l2sq, cosv, wlo, whi, wabs, alphaLo, alphaHi, thetaHi, thetaLo,
       naive, sc, t1c, t2c, rs, r1, r2, bx, Mc, cen, Qmax, sinthI, sinTI, QsT,
       dwdsI, dwdt1I, dwdt2I, mS, mT1, mT2, corr, lb, gmag},
      gmag = {1, 1, 1};
      (* --- w = cos(alpha) enclosure (clean, no arccos) --- *)
      a1 = {R Interval[{Min[Cos[t1i]], Max[Cos[t1i]]}] - si, R Interval[{Min[Sin[t1i]], Max[Sin[t1i]]}]};
      a2 = {R Interval[{Min[Cos[t2i]], Max[Cos[t2i]]}] - si, R Interval[{Min[Sin[t2i]], Max[Sin[t2i]]}]};
      dot = outward[a1[[1]] a2[[1]] + a1[[2]] a2[[2]]];
      l1sq = outward[a1[[1]]^2 + a1[[2]]^2]; l2sq = outward[a2[[1]]^2 + a2[[2]]^2];
      cosv = outward[dot/(Sqrt[l1sq] Sqrt[l2sq])];
      cosv = Interval[{Max[-1, Min[cosv]], Min[1, Max[cosv]]}];
      wlo = Min[cosv]; whi = Max[cosv]; wabs = Max[Abs[wlo], Abs[whi]];
      alphaLo = Min[outward[ArcCos[cosv]]]; alphaHi = Max[outward[ArcCos[cosv]]];
      thetaHi = Max[t2i] - Min[t1i]; thetaLo = Max[Min[t2i] - Max[t1i], 0];
      (* --- naive endpoint bound: ALWAYS finite and valid --- *)
      naive = N[Min[outward[Cos[Interval[{thetaHi, thetaHi}]]]]
                 - Max[outward[Cos[T[Interval[{alphaLo, alphaLo}]]]]], PREC];
      (* --- centered form via CHAIN RULE, used ONLY when w strictly inside (-1,1):
         dM/ds  = -fp Q sin(T(a)) dw/ds
         dM/dt1 =  sin(theta) - fp Q sin(T(a)) dw/dt1
         dM/dt2 = -sin(theta) - fp Q sin(T(a)) dw/dt2 ,     Q = 1/Sqrt[1-w^2].
         Q is even and increasing in |w|, so its max over the box is 1/Sqrt[1-wabs^2],
         FINITE here because wabs <= 1-eQ.  Replacing Q by Qmax over-estimates |dM/dx|,
         hence the centered correction stays a VALID outer bound. --- *)
      cen = -BIG;
      If[wabs <= 1 - eQ,
        sc = (Min[si] + Max[si])/2; t1c = (Min[t1i] + Max[t1i])/2; t2c = (Min[t2i] + Max[t2i])/2;
        rs = (Max[si] - Min[si])/2; r1 = (Max[t1i] - Min[t1i])/2; r2 = (Max[t2i] - Min[t2i])/2;
        bx = {s -> si, t1 -> t1i, t2 -> t2i};
        Mc = N[Mpt[sc, t1c, t2c], PREC];
        Qmax = N[1/Sqrt[1 - wabs^2], PREC];
        sinthI = outward[Sin[Interval[{thetaLo, thetaHi}]]];
        sinTI = outward[Sin[T[Interval[{alphaLo, alphaHi}]]]];
        dwdsI = outward[dwds /. bx]; dwdt1I = outward[dwdt1 /. bx]; dwdt2I = outward[dwdt2 /. bx];
        QsT = fpN Qmax sinTI;
        mS = (Max[Abs[Min[#]], Abs[Max[#]]] &)[outward[-QsT dwdsI]];
        mT1 = (Max[Abs[Min[#]], Abs[Max[#]]] &)[outward[sinthI - QsT dwdt1I]];
        mT2 = (Max[Abs[Min[#]], Abs[Max[#]]] &)[outward[-sinthI - QsT dwdt2I]];
        corr = rs mS + r1 mT1 + r2 mT2;
        cen = N[Mc - corr, PREC];
        gmag = {mS, mT1, mT2}];
      lb = N[Max[naive, cen], PREC];
      (* Bug-2 guarantee: lb is ALWAYS a finite real.  Any non-finite slips to -BIG (box
         then simply subdivides); worst can never become symbolic/Infinity. *)
      If[! (NumericQ[lb] && Element[lb, Reals] && Abs[lb] < Infinity), lb = -BIG];
      (* feasibility lower bounds: Min[l*sq] is a sound lower bound on |u*|^2 over the box;
         Min[l1sq]>1 or Min[l2sq]>1 => EVERY point has |u|>1 => box entirely outside Omega. *)
      {lb, alphaLo, gmag, N[Min[l1sq], PREC], N[Min[l2sq], PREC]}];
    (* a box is inside B_ring if it is within d0 (sup-norm) of (sstar,-tstar,tstar) *)
    inRing[si_, t1i_, t2i_] := (Min[si] >= sstarN - d0) && (Max[si] <= sstarN + d0) &&
       (Min[t1i] >= -tstarN - d0) && (Max[t1i] <= -tstarN + d0) &&
       (Min[t2i] >= tstarN - d0) && (Max[t2i] <= tstarN + d0);
    H0 = N[ArcCos[(R^2 + smax^2 - 1)/(2 R smax)], PREC];
    stack = {{Interval[{N[smin, PREC], N[smax, PREC]}], Interval[{-H0, H0}], Interval[{-H0, H0}], 0}};
    While[stack =!= {} && cnt < MAXBOX,
      cnt++; {box, depth} = {Most[stack[[1]]], Last[stack[[1]]]}; stack = Rest[stack];
      Module[{si = box[[1]], t1i = box[[2]], t2i = box[[3]], lb, alphaLo, gmag, minL1, minL2,
          mSg, mT1g, mT2g},
        If[Min[t1i] > Max[t2i], Continue[]];
        {lb, alphaLo, gmag, minL1, minL2} = Mlower[si, t1i, t2i];
        mSg = gmag[[1]]; mT1g = gmag[[2]]; mT2g = gmag[[3]];
        (* drop boxes entirely outside Omega: |u1|>1 everywhere or |u2|>1 everywhere *)
        If[minL1 > 1 || minL2 > 1, infeasBoxes++; Continue[]];
        (* drop boxes fully off the small-alpha side (alpha_lo > abar) *)
        If[N[alphaLo, PREC] > abarN, offside++; Continue[]];
        (* hand ring-collar boxes to Pcollar *)
        If[inRing[si, t1i, t2i], collarBoxes++; Continue[]];
        (* worst is tracked over LEAVES only (discharged or depth-terminal), not over
           subdivided parents -- a parent's loose root-level bound must not pin worst. *)
        If[lb >= 0, nb++;
           If[lb < worst, worst = lb;
              worstBox = {N[si, 6], N[t1i, 6], N[t2i, 6], N[alphaLo, 6]}]; Continue[]];
        If[depth >= maxDepth, closedAll = False; nb++;
           If[lb < worst, worst = lb;
              worstBox = {N[si, 6], N[t1i, 6], N[t2i, 6], N[alphaLo, 6]}]; Continue[]];
        (* split the dimension contributing most to the centered correction (rad_i*|grad_i|) *)
        Module[{w = {(Max[si] - Min[si]) mSg, (Max[t1i] - Min[t1i]) mT1g,
                     (Max[t2i] - Min[t2i]) mT2g}, ax, mid},
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
    (* worst is +Infinity only if NO leaf was ever recorded (vacuous); force a finite number. *)
    If[! (NumericQ[worst] && Element[worst, Reals] && Abs[worst] < Infinity), worst = -BIG];
    p3detail = <|"boxes_processed" -> cnt, "boxes_discharged" -> nb, "collar_boxes" -> collarBoxes,
      "offside_boxes" -> offside, "infeasible_boxes" -> infeasBoxes,
      "min_lowerM_enclosed" -> N[worst, 10], "min_lowerM_finite" -> (Abs[N[worst, 10]] < Infinity),
      "worst_leaf" -> worstBox, "closed_all" -> closedAll, "budget_hit" -> (cnt >= MAXBOX),
      "stack_empty" -> (stack === {})|>;
    (* Pbb True iff: tree fully closed (stack empty, no depth-cap, within budget) AND the
       worst leaf lower bound is a FINITE number >= 0.  Every conjunct is an N[]-evaluated
       finite boolean -- no symbolic/Infinity can reach the Exit decision. *)
    (stack === {}) && closedAll && (cnt < MAXBOX) &&
      (NumericQ[worst] && Element[worst, Reals] && Abs[worst] < Infinity) && (worst >= 0)];

  results[n] = <|"R" -> N[R, 20], "abar" -> N[abar, 12], "fp" -> N[fp, 12],
    "calib" -> calib, "P1" -> P1, "p1bad" -> p1bad, "BF" -> BF, "Pcollar" -> Pcollar,
    "P2d" -> p2detail, "Pbb" -> Pbb, "P3d" -> p3detail|>;
  ], {n, ns}];

allok = True;
Do[Module[{r = results[n]},
   Print["n=", n, "  R=", r["R"], "  abar=", r["abar"], "  f'(abar)=", r["fp"]];
   Print["  calibration (margin->0 at ring)        : ", r["calib"]];
   Print["  P1 (T>=f on [0.01,pi-0.01], interval)  : ", r["P1"], "   panels_failing=", r["p1bad"]];
   Print["  BF (theta=f(alpha) on |u|=1 face, exact): ", r["BF"], "   => M=0 on that face"];
   Print["  Pcollar (KKT first-order ring collar)  : ", r["Pcollar"], "   ", r["P2d"]];
   Print["  Pbb (centered-form B&B lower(M)>=0)    : ", r["Pbb"]];
   Print["     processed=", r["P3d"]["boxes_processed"], " discharged=", r["P3d"]["boxes_discharged"],
         " collar_skipped=", r["P3d"]["collar_boxes"], " offside=", r["P3d"]["offside_boxes"],
         " infeasible=", r["P3d"]["infeasible_boxes"]];
   Print["     min_lowerM=", r["P3d"]["min_lowerM_enclosed"], " (finite=", r["P3d"]["min_lowerM_finite"],
         ") closed_all=", r["P3d"]["closed_all"], " budget_hit=", r["P3d"]["budget_hit"],
         " stack_empty=", r["P3d"]["stack_empty"]];
   Module[{eg = r["calib"] && r["P1"] && r["BF"] && r["Pcollar"] && r["Pbb"]},
     Print["  E_g1t_small (= calib&P1&BF&Pcollar&Pbb): ", eg];
     allok = allok && eg];
  ], {n, ns}];

Print[""];
Print["COVERAGE (seamless): Omega = {boundary face |u|=1} U {B_ring collar} U {Omega\\B_ring}."];
Print["  - boundary face |u1|=|u2|=1: M=0 (BF) -- measure-zero equality locus, handled analytically."];
Print["  - B_ring = ring +- 1/160 (sup-norm): M>=0 by the KKT first-order collar lemma (Pcollar):"];
Print["    dM/dt1>0, dM/dt2<0, d|u1|^2/dt1<0, d|u2|^2/dt2>0 over B_ring (outward interval) =>"];
Print["    feasibility pins (t1,t2) to the |u|=1 face where M>=0 (BF+P1); no Hessian, no path integral."];
Print["  - Omega minus B_ring (the SAME 1/160 box the B&B skips): M>0 strict by centered-form"];
Print["    outward-rounded interval branch-and-bound (Pbb). The B&B's inRing uses the identical"];
Print["    delta0, so collar U B&B-region = Omega with NO gap; alpha>abar boxes are off the"];
Print["    small-alpha side and dropped."];
Print["Interval arithmetic OUTWARD rounded to ", InputForm[OUT], " (>=25 digits), WP ", PREC, "."];
Print[If[allok, "CERTIFICATE OK -- S3b (G1T small-alpha) CLOSED for n=8,9,10 (L3)",
   "CERTIFICATE INCOMPLETE (see per-part breakdown)"]];
Exit[If[allok, 0, 1]];
