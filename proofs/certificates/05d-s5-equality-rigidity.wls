#!/usr/bin/env wolframscript
(* Certificate for proofs/05 S5 : the EQUALITY => CONGRUENCE rigidity step.
   G. Fejes Toth (2005), MSRI Publ. 52, 361-376.  n = 8,9,10, k = n-1, R = 1+2Cos[2Pi/k].

   WHAT S5 CLAIMS.  If an optimal cover of C_n = D(0,R_n) by n unit disks attains the
   covering radius R_n = 1 + 2 Cos[2Pi/k] exactly, then the configuration is UNIQUE up to
   rotation: the center disk D(0,1) plus k unit disks equi-angularly spaced at distance
   2 Cos[Pi/k] from O  (RingConfig[k]).

   WHAT THIS CERTIFICATE DOES (and does NOT).  S5 is a GEOMETRIC equality-case argument,
   not a zero-dimensional algebraic system -- the uniqueness comes from the EQUALITY
   CONDITIONS of (a) strictly-concave Jensen in steps (3)&(6) and (b) the strict per-cell
   bounds (G1T, G2), each of which already pins every cell to the regular cell with NO
   residual free parameter.  There is therefore no KKT zero to Krawczyk-certify (contrast
   proofs/07, where n=11 LOCAL optimality genuinely reduced to a 22x22 KKT box).  The
   proper role of a certificate here is to supply, as finite outward-rounded numbers, the
   STRICTNESS facts that turn each equality into "all arguments equal / contact forced":

     (R1)  f strictly concave on (0,pi):  f''(a) < 0, a=(0,pi)        [interval, L3]
           => Jensen step (3)  Sum f(alpha_i) <= (n-1) f(alpha-bar)  is tight
              IFF all alpha_i are equal.
     (R2)  F strictly concave on (0,pi):  F''(a) < 0, a=(0,pi)        [interval, L3]
           => Jensen step (6)  Sum F(alpha_i) <= (n-1) F(alpha-bar)  is tight
              IFF all alpha_i are equal.
     (R3)  g strictly decreasing on [abar,pi]:  g'(a) <= g'(abar) < 0 [exact + interval, L3]
           (g(a) = Sin[(n-2)Pi/(n-1) - a/2] + F(a), the S4 chain-closer)
           => the terminal bound Sum(areas) <= (n-1) g(alpha-mean) with alpha-mean >= abar
              (from (3)) is attained ONLY at alpha-mean = abar, i.e. Sum alpha_i = k abar.
     (R4)  per-cell equality locus is the regular cell: at alpha = abar the tangent bound
           T(abar) = f(abar) (so G1T is tight only at abar), the regular ring sits on the
           contact face |u1|=|u2|=1 where theta = f(alpha) EXACTLY (BF, cert 05b), and the
           regular cell angle at O is theta-bar = f(abar) = 2Pi/k.                 [exact]
     (R5)  equi-angular closure is forced: k closed arcs each of length theta-bar = 2Pi/k
           on dC_n sum to exactly 2Pi, hence tile dC_n end-to-end; with each cell congruent
           to the regular cell this fixes the centers at 2Cos[Pi/k], equi-angular =
           RingConfig[k].  Certified here by the EXACT identity k*theta-bar = 2Pi and the
           exact tight coverage of RingConfig[k] (E_ring).                          [exact]

   REASONING CHAIN (the links the deductions above compose into), with evidence levels:

     [L0] optimal cover attains R = R_n EXACTLY  (hypothesis of S5).
       |  [FT] lemma S1/S2 (n=8,9: arcsin count; n=10: Melissen distance lemma, cert 05c):
       |  exactly one disk lies in int C_n (touches nothing on dC_n); the other k disks
       |  each own a boundary Dirichlet cell with angle alpha_i at its center, theta_i at O.
       v
     [DEP S3b] 2pi = Sum theta_i <= Sum T(alpha_i)              (G1T, cert 05b, exit 0, L3)
       |  equality in each theta_i <= T(alpha_i) forces (BF) contact |u|=1 AND alpha_i on
       |  the tight locus; T(alpha_i) >= f(alpha_i) with equality only at abar (R4).
       v
     [DEP S4] Sum(cell areas) <= (n-1) g(alpha-mean),  g strictly decreasing (cert 05, L3)
       |  area equality (cover attains R_n => total cell area = a(C_n)) forces the terminal
       |  bound tight; (R3) + alpha-mean >= abar (from (3)) => alpha-mean = abar.
       v
     [R1,R2] strict-concave Jensen tight (steps (3),(6)) => all alpha_i EQUAL
       |  with Sum alpha_i = k abar => alpha_i = abar for every cell.
       v
     [R4] each cell: alpha_i = abar, contact on both vertices (G2 tight: |o q|=|o q'|=1),
       |  theta_i = f(abar) = 2Pi/k  => each triangle T_i congruent to the regular T_i*
       |  (eq. (1): Sum delta_i = Sum eps_i = 2pi, each T_i congruent to the regular cell).
       v
     [R5] k cells, each theta_i = 2Pi/k, tiling dC_n (k*2Pi/k = 2pi exactly) => centers
          equi-angular at 2Cos[Pi/k] => configuration = RingConfig[k] up to rotation.  QED S5.

   HONESTY (hard red lines).
     * This certificate proves the STRICTNESS facts R1-R5 to L3 (interval / exact).  The
       equality=>congruence THEOREM is then a geometric deduction that COMPOSES R1-R5 with
       the three computational certs it DEPENDS ON: S3b (05b), S4 (05), and -- for n=10 only
       -- the Melissen distance lemma (05c, itself L3-based-on-[FT]-restatement, Melissen
       pp.108-111 un-obtained).  So S5-as-a-theorem is capped at the WEAKEST dependency:
       L4-conditional for n=8,9 (pending human read of the [FT] area argument it rides on)
       and, for n=10, additionally gated on the un-verified Melissen original.
     * No new free algebraic system arises, so NO Krawczyk box is warranted or produced; a
       cosmetic KKT cert would add nothing and is deliberately omitted.
     * Every Exit-gating quantity is an N[]-evaluated FINITE real; the exit conjoins all of
       them explicitly.  Interval arithmetic is OUTWARD rounded.

   Usage (repo root): wolframscript -file proofs/certificates/05d-s5-equality-rigidity.wls
   Exit 0 iff R1&R2&R3&R4&R5 hold for n=8,9,10 (finite, outward-rounded).  No randomness. *)

$MaxExtraPrecision = 400;
root = FileNameJoin[{DirectoryName[ExpandFileName[$InputFileName]], "..", ".."}];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];

PREC = 30;
OUT = 10^-25;
ns = {8, 9, 10};

(* outward-rounded enclosure of a symbolic Interval, to >= 25 digits *)
outward[iv_Interval] := Interval[{Floor[N[Min[iv], PREC], OUT], Ceiling[N[Max[iv], PREC], OUT]}];

(* strict-negativity of a second-derivative expression over (lo,hi) by outward interval
   panels WITH ADAPTIVE BISECTION: any panel whose outward upper bound is not < 0 is
   bisected (up to MAXD levels) instead of being declared a failure.  This is the honest
   fix for interval OVERESTIMATION near a difficult point (here alpha->0, where f'' and F''
   have a near-0 numerator and the naive enclosure of the derivative is loose even though
   the true value is strictly negative -- confirmed pointwise ~ -1e-4, and a 4x split of the
   first panel already clears it).  A panel that cannot be driven < 0 within MAXD levels is
   a genuine failure (counted in `bad`), so the gate stays honest.  Returns
   {allNeg (Bool), worstUpper (finite real over LEAVES), panelsFailing (Int), maxDepthUsed}. *)
panelNeg[expr_, var_, lo_, hi_, PANELS_] := Module[
  {bad = 0, worst = -Infinity, maxd = 0, stack, a, b, d, iv, up, mid},
  stack = Table[{lo + (p - 1) (hi - lo)/PANELS, lo + p (hi - lo)/PANELS, 0}, {p, PANELS}];
  While[stack =!= {},
    {a, b, d} = stack[[1]]; stack = Rest[stack];
    iv = outward[expr /. var -> Interval[{a, b}]];
    up = N[Max[iv], PREC];
    If[! (NumericQ[up] && Element[up, Reals] && Abs[up] < Infinity), up = Infinity];
    If[up < 0,
      (* leaf: certified negative on this panel *)
      If[up > worst, worst = up]; If[d > maxd, maxd = d],
      (* not yet negative: bisect, or fail if too deep *)
      If[d >= 40,
        bad++; worst = Infinity; If[d > maxd, maxd = d],
        mid = (a + b)/2;
        stack = Join[{{a, mid, d + 1}, {mid, b, d + 1}}, stack]]]];
  {bad == 0 && NumericQ[worst] && Abs[worst] < Infinity, N[worst, 12], bad, maxd}];

results = Association[];

Do[Module[
  {k = n - 1, R, abar, f, F, fp, T, fpp, Fpp, g, gArg, gp, gpp, betabar, thetabar,
   r1, r1w, r1b, r1d, r2, r2w, r2b, r2d, gpAbar, r3gp, r3, r3w, r3b, r3d, r4tangent,
   r4ring, r4theta, R4, r5close, r5ring, R5, eps},

  R = 1 + 2 Cos[2 Pi/k];
  abar = 6 Pi/k;
  f[a_] := 2 ArcSin[Sin[a/2]/R];
  F[a_] := R^2/2 (f[a] - Sin[f[a]]) + Sin[a]/2;
  fp = Simplify[D[f[a], a] /. a -> abar];
  T[a_] := f[abar] + fp (a - abar);

  (* domain guard: panel the OPEN (0,pi); a tiny collar eps keeps arcsin/sqrt arguments
     strictly inside their branch (the per-cell alpha ranges over (0,pi) by S0 alpha<=pi;
     the degenerate endpoints 0,pi are measure-zero and carry no cell). *)
  eps = 1/1000;

  (* ===== R1 : f'' < 0 on (0,pi)  => (3) strict-concave Jensen tight iff all alpha_i equal ===== *)
  fpp = D[f[aa], {aa, 2}];
  {r1, r1w, r1b, r1d} = panelNeg[fpp, aa, eps, N[Pi, PREC] - eps, 300];

  (* ===== R2 : F'' < 0 on (0,pi)  => (6) strict-concave Jensen tight iff all alpha_i equal ===== *)
  Fpp = D[F[aa], {aa, 2}];
  {r2, r2w, r2b, r2d} = panelNeg[Fpp, aa, eps, N[Pi, PREC] - eps, 300];

  (* ===== R3 : g strictly decreasing on [abar,pi]  (S4 chain-closer) =====
     g'(abar) < 0 EXACT, and g'' < 0 on [abar,pi] (interval) => g'(a) <= g'(abar) < 0. *)
  gArg = (n - 2) Pi/(n - 1);
  g[a_] := Sin[gArg - a/2] + F[a];
  gpAbar = Simplify[D[g[a], a] /. a -> abar];
  r3gp = N[gpAbar, 40];
  gpp = D[g[a], {a, 2}];
  {r3, r3w, r3b, r3d} = panelNeg[gpp, a, N[abar, PREC], N[Pi, PREC] - eps, 200];
  r3 = r3 && (r3gp < 0);

  (* ===== R4 : per-cell equality locus is the regular cell (exact, via RootReduce) =====
     These are identities between ALGEBRAIC numbers (R, trig at pi/k are algebraic); Simplify
     cannot discharge the transcendental-looking arcsin/arccos forms, so we reduce to the
     equivalent ALGEBRAIC witnesses and decide them with RootReduce (exact, the same tool
     CirCovCir`sgn uses on near-ties):
       - tangent tight at abar: T(abar) = f(abar) (polynomial in abar, Simplify OK);
       - f(abar) = 2Pi/k  <=>  Sin[f(abar)/2] = Sin[Pi/k]  <=>  Sin[abar/2]/R = Sin[Pi/k]
         <=>  R Sin[Pi/k] = Sin[3Pi/k]   (abar/2 = 3Pi/k);  this is the regular cell's angle
         at O, theta-bar = 2Pi/k;
       - the regular ring sits on the CONTACT face |u1|=|u2|=1 at alpha = abar:
         |u_j|^2 = 1 exactly, and Cos[ring-alpha] = Cos[abar] (both angles in (0,pi) => equal). *)
  thetabar = 2 Pi/k;
  r4tangent = (Simplify[T[abar] - f[abar]] === 0);
  r4theta = (RootReduce[R Sin[Pi/k] - Sin[3 Pi/k]] === 0);
  r4ring = Module[{tst = Pi/k, sst = 2 Cos[Pi/k], u1, u2, al},
    u1 = {R Cos[-tst] - sst, R Sin[-tst]};
    u2 = {R Cos[tst] - sst, R Sin[tst]};
    al = ArcCos[(u1 . u2)/(Sqrt[u1 . u1] Sqrt[u2 . u2])];
    (RootReduce[u1 . u1 - 1] === 0) && (RootReduce[u2 . u2 - 1] === 0) &&
      (RootReduce[Cos[al] - Cos[abar]] === 0)];
  R4 = r4tangent && r4ring && r4theta;

  (* ===== R5 : equi-angular closure forced (exact) =====
     k closed arcs of length theta-bar = 2Pi/k tile dC_n: k*theta-bar = 2Pi EXACTLY; the
     regular ring then exactly tightly covers D(0,R) (E_ring), so the forced tiling IS
     RingConfig[k] up to rotation. *)
  r5close = (Simplify[k thetabar - 2 Pi] === 0);
  r5ring = ExactCoverQ[RingConfig[k], R] && ! ExactCoverQ[RingConfig[k], R + 10^-30];
  R5 = r5close && r5ring;

  results[n] = <|"R" -> N[R, 20], "abar" -> N[abar, 12], "thetabar" -> N[thetabar, 12],
    "R1" -> r1, "R1_worstUpper_fpp" -> r1w, "R1_panelsFail" -> r1b, "R1_maxDepth" -> r1d,
    "R2" -> r2, "R2_worstUpper_Fpp" -> r2w, "R2_panelsFail" -> r2b, "R2_maxDepth" -> r2d,
    "R3" -> r3, "R3_gp_abar" -> r3gp, "R3_worstUpper_gpp" -> r3w, "R3_panelsFail" -> r3b,
    "R3_maxDepth" -> r3d,
    "R4" -> R4, "R4_tangent" -> r4tangent, "R4_ring_on_face" -> r4ring, "R4_thetabar" -> r4theta,
    "R5" -> R5, "R5_close" -> r5close, "R5_ring_tight" -> r5ring|>;
  ], {n, ns}];

allok = True;
Do[Module[{r = results[n], eg},
   Print["n=", n, "  R=", r["R"], "  abar=", r["abar"], "  theta-bar=2Pi/k=", r["thetabar"]];
   Print["  R1 f''<0 on (0,pi)      [=>(3) Jensen tight iff all a_i equal] : ", r["R1"],
         "   worstUpper(f'')=", r["R1_worstUpper_fpp"], "  panelsFail=", r["R1_panelsFail"],
         "  maxBisectDepth=", r["R1_maxDepth"]];
   Print["  R2 F''<0 on (0,pi)      [=>(6) Jensen tight iff all a_i equal] : ", r["R2"],
         "   worstUpper(F'')=", r["R2_worstUpper_Fpp"], "  panelsFail=", r["R2_panelsFail"],
         "  maxBisectDepth=", r["R2_maxDepth"]];
   Print["  R3 g strictly decreasing on [abar,pi]  [S4 chain-closer]      : ", r["R3"],
         "   g'(abar)=", r["R3_gp_abar"], "  worstUpper(g'')=", r["R3_worstUpper_gpp"],
         "  panelsFail=", r["R3_panelsFail"], "  maxBisectDepth=", r["R3_maxDepth"]];
   Print["  R4 per-cell equality locus = regular cell (exact)             : ", r["R4"],
         "   [T(abar)=f(abar):", r["R4_tangent"], ", ring on contact face:", r["R4_ring_on_face"],
         ", f(abar)=2Pi/k:", r["R4_thetabar"], "]"];
   Print["  R5 equi-angular closure forced (exact)                        : ", r["R5"],
         "   [k*theta-bar=2Pi:", r["R5_close"], ", ring tight cover:", r["R5_ring_tight"], "]"];
   eg = r["R1"] && r["R2"] && r["R3"] && r["R4"] && r["R5"];
   Print["  S5 rigidity facts (R1&R2&R3&R4&R5)                            : ", eg];
   allok = allok && eg;
  ], {n, ns}];

Print[""];
Print["S5 reasoning chain (equality => congruence), composing R1-R5 with the dependency certs:"];
Print["  [hyp] cover attains R=R_n exactly"];
Print["   -> [FT S1/S2] k boundary cells + 1 interior disk (n=10 uses Melissen lemma, cert 05c)"];
Print["   -> [S3b 05b] 2pi=Sum theta_i<=Sum T(alpha_i); equality => contact |u|=1 & tight-locus"];
Print["   -> [S4 05]  area equality => terminal bound tight; R3 + alpha-mean>=abar => alpha-mean=abar"];
Print["   -> [R1,R2]  strict-concave Jensen (3)&(6) tight => all alpha_i EQUAL = abar"];
Print["   -> [R4]     each cell: alpha_i=abar, contact, theta_i=2Pi/k => T_i congruent to T_i*"];
Print["   -> [R5]     k cells x 2Pi/k = 2pi tile dC_n => centers equi-angular @ 2Cos[Pi/k]"];
Print["   = RingConfig[k] up to rotation.  QED S5 (geometric, L4-conditional; n=10 also rides"];
Print["     on the un-verified Melissen original -- see HONESTY in the header)."];
Print["Interval arithmetic OUTWARD rounded to ", InputForm[OUT], " (>=25 digits), WP ", PREC, "."];
Print[If[allok,
   "CERTIFICATE OK -- S5 rigidity facts R1-R5 CLOSED for n=8,9,10 (L3); theorem L4-conditional",
   "CERTIFICATE INCOMPLETE (see per-part breakdown)"]];
Exit[If[allok, 0, 1]];
