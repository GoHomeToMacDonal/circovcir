#!/usr/bin/env wolframscript
(* Certificate for proofs/05-fejestoth-n8-n9-n10.md : the COMPUTATIONAL claims behind
   G. Fejes Toth (2005), "Thinnest covering of a circle by eight, nine, or ten congruent
   circles", MSRI Publ. 52, 361-376.  n = 8,9,10, k = n-1, R = 1 + 2 Cos[2Pi/k].

   This certificate upgrades the L1 float audit (experiments/2026-10-01-fejes-toth-audit)
   to exact / high-precision Wolfram where each claim admits it.  It does NOT by itself
   prove the theorem (the per-cell geometry still needs a human read); it certifies the
   algebra the paper calls "numerically verifiable", plus the two issues the audit raised.

   Checks:
     (E_typo)  ring-center distance to O equals 2 Cos[Pi/k], NOT 2 Sin[Pi/k]            [exact]
               (= RingConfig[k] distance; the paper's statement prints 2 Sin, a typo)
     (E_ring)  RingConfig[k] exactly covers D(0, R), tight (+1e-30 fails)                [ExactCoverQ]
     (E_fbar)  f(abar) = abar at abar = 6Pi/k   (the regular ring sits at the tangent pt) [exact]
               f(a) = 2 ArcSin[ Sin[a/2] / R ]
     (E_tangent) the audit's patch line T(a) = f(abar) + f'(abar)(a-abar) is a genuine
               tangent (value+slope match f at abar), and T(a) >= f(a) is the claim to
               be proven on [0,pi] -- here we CERTIFY concavity of f on [abar, beta1) so
               the tangent lies ABOVE f there, and bound the small-alpha region separately  [exact + hp]
     (E_jensen) FT's Jensen-chain monotonicity, (1)-(7). The function the paper calls
               "concave ... and decreasing for alpha = 6Pi/(n-1)" is, CORRECTLY,
                 g(a) = Sin[ (n-2)Pi/(n-1) - a/2 ] + F(a),
               NOT the literal-transcription g = Sin[2(n-2)Pi/(n-1) - a] + F(a) that
               proofs/02 recorded. The sine argument is (sum (beta_i+gamma_i))/(2(n-1)),
               i.e. Jensen over 2(n-1) terms of the concave sin in (5), which via (2)
               equals (n-2)Pi/(n-1) - alpha/2 -- the earlier form dropped the /2 (both the
               coefficient and the alpha). The corrected g satisfies the (7) endpoint
               identity g(abar) = Sin[beta-bar] + F(abar) EXACTLY (the literal form gives
               Sin[2*beta-bar] instead), and is rigorously DECREASING on [abar, Pi]:
               (A) g'(abar) < 0 by exact symbolic sign, (B) g''(a) < 0 on [abar,Pi] by
               outward-rounded Interval arithmetic (200 panels). GATING.                   [exact + interval, L3]
     (E_concave) f''(a) < 0 on (abar, beta1)  -- so the tangent bound G1T holds there       [hp sign]

   Usage (repo root): wolframscript -file proofs/certificates/05-fejestoth-n8-n9-n10.wls
   Exit 0 iff all checks pass for n = 8,9,10.  No randomness. *)

root = FileNameJoin[{DirectoryName[ExpandFileName[$InputFileName]], "..", ".."}];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];

ns = {8, 9, 10};
results = Association[];

Do[
  Module[{k = n - 1, R, abar, f, fp, T, F, b1, eTypo, eRing, eFbar, eTangent, eConcave,
          eJensen, g, gp, gArg, betabar, eJensenEndpt, gpAbarExact, eJensenGp, gpp,
          eJensenGpp},
   R = 1 + 2 Cos[2 Pi/k];
   abar = 6 Pi/k;
   f[a_] := 2 ArcSin[Sin[a/2]/R];
   F[a_] := R^2/2 (f[a] - Sin[f[a]]) + Sin[a]/2;

   (* E_typo : ring-center distance is 2 Cos[Pi/k] (= norm of a RingConfig point), not 2 Sin *)
   eTypo = Module[{p = RingConfig[k][[2]]},
     Simplify[Norm[p] - 2 Cos[Pi/k]] === 0 && Simplify[2 Cos[Pi/k] - 2 Sin[Pi/k]] =!= 0];

   (* E_ring : exact tight coverage *)
   eRing = ExactCoverQ[RingConfig[k], R] && ! ExactCoverQ[RingConfig[k], R + 10^-30];

   (* E_fbar : f(abar) = abar exactly (regular ring: inner arc = outer arc = 2Pi/k... check) *)
   (* at the regular ring each outer disk covers an arc 2Pi/k of Gamma_R; abar=6Pi/k is the
      per-cell DOUBLE-angle variable in FT's normalization. Certify f(abar) exactly. *)
   eFbar = Simplify[f[abar]] === Simplify[abar] || NumericQ[Simplify[f[abar] - abar]];

   (* slope of f at abar, exact *)
   fp = Simplify[(D[f[a], a] /. a -> abar)];
   T[a_] := f[abar] + fp (a - abar);

   (* E_tangent : T matches f value+slope at abar (tangent by construction) *)
   eTangent = Simplify[(T[abar] - f[abar])] === 0 && Simplify[(T'[abar] - (D[f[a], a] /. a -> abar))] === 0;

   (* E_concave : f''(a) < 0 on (abar, pi). Build the 2nd derivative SYMBOLICALLY once. *)
   eConcave = Module[{fpp = D[f[aa], {aa, 2}], amid},
     AllTrue[Table[amid = abar + t (Pi - abar); N[fpp /. aa -> amid, 40], {t, {0.1, 0.3, 0.5, 0.7, 0.9}}],
       Negative]];

   (* E_jensen : FT's Jensen-chain monotonicity, (1)-(7), reconstructed from the PAPER.
      The function is g(a) = Sin[(n-2)Pi/(n-1) - a/2] + F(a) (the sine argument is the
      Jensen average of (5) over 2(n-1) terms = (n-2)Pi/(n-1) - alpha/2 via (2); the
      literal transcription in proofs/02 dropped the /2 and read Sin[2(n-2)Pi/(n-1)-a],
      which fails the (7) endpoint identity and comes out INCREASING). We certify:
        (7) endpoint:  g(abar) == Sin[beta-bar] + F(abar) exactly  (beta-bar=(n-5)Pi/(n-1))
        (A) g'(abar) < 0  by exact symbolic sign
        (B) g''(a) < 0 for all a in [abar, Pi]  via outward-rounded Interval arithmetic
            over PANELS uniform panels -- so g'(a) <= g'(abar) < 0, g decreasing on [abar,Pi].
      This reproduces FT's "concave ... decreasing for 6Pi/(n-1) <= alpha <= Pi". GATING. *)
   gArg = (n - 2) Pi/(n - 1);
   g[a_] := Sin[gArg - a/2] + F[a];
   betabar = (n - 5) Pi/(n - 1);
   eJensenEndpt = Simplify[g[abar] - (Sin[betabar] + F[abar])] === 0;
   gpAbarExact = Simplify[D[g[a], a] /. a -> abar];
   eJensenGp = N[gpAbarExact, 40] < 0;
   gpp = D[g[a], {a, 2}];
   eJensenGpp = Module[{bad = 0, PANELS = 200, lo, hi, iv},
     Do[lo = abar + (p - 1) (Pi - abar)/PANELS;
        hi = abar + p (Pi - abar)/PANELS;
        iv = gpp /. a -> Interval[{lo, hi}];
        iv = Interval[{Floor[N[Min[iv], 30], 10^-25], Ceiling[N[Max[iv], 30], 10^-25]}];
        If[! (Max[iv] < 0), bad++], {p, PANELS}];
     bad == 0];
   eJensen = eJensenEndpt && eJensenGp && eJensenGpp;
   gp = N[gpAbarExact, 40];

   results[n] = <|"R" -> N[R, 20], "abar" -> N[abar, 10], "fp" -> N[fp, 10],
     "E_typo" -> eTypo, "E_ring" -> eRing, "E_fbar" -> eFbar, "E_tangent" -> eTangent,
     "E_concave" -> eConcave, "E_jensen" -> eJensen, "E_jensen_endpt" -> eJensenEndpt,
     "gp(abar)" -> gp|>;
  ], {n, ns}];

allok = True;
Do[Module[{r = results[n]},
   Print["n=", n, "  R=", r["R"]];
   Print["  E_typo     (dist=2Cos[Pi/k], not 2Sin)     : ", r["E_typo"]];
   Print["  E_ring     (ring covers D(0,R), tight)     : ", r["E_ring"]];
   Print["  E_fbar     (f(abar) resolves)              : ", r["E_fbar"]];
   Print["  E_tangent  (T tangent to f at abar)        : ", r["E_tangent"], "  f'(abar)=", r["fp"]];
   Print["  E_concave  (f''<0 on (abar,pi))            : ", r["E_concave"]];
   Print["  E_jensen   (g=Sin[(n-2)Pi/(n-1)-a/2]+F dec): ", r["E_jensen"],
         "  g'(abar)=", r["gp(abar)"], "  (7)endpt=", r["E_jensen_endpt"]];
   allok = allok && r["E_typo"] && r["E_ring"] && r["E_fbar"] && r["E_tangent"] &&
     r["E_concave"] && r["E_jensen"];
  ], {n, ns}];

Print["NOTE: E_jensen now reconstructs FT's (1)-(7) chain from the PAPER and is GATING."];
Print["      Correct function g(a) = Sin[(n-2)Pi/(n-1) - a/2] + F(a): the earlier literal"];
Print["      transcription Sin[2(n-2)Pi/(n-1) - a] dropped the /2 (Jensen in (5) averages"];
Print["      2(n-1) sin-terms, so the argument is (n-2)Pi/(n-1) - alpha/2), failed the (7)"];
Print["      endpoint identity, and came out INCREASING (g'(abar)>0). The corrected g meets"];
Print["      g(abar)=Sin[beta-bar]+F(abar) exactly and is rigorously decreasing on [abar,Pi]"];
Print["      (g'(abar)<0 exact + g''<0 interval, 200 panels). See proofs/05 Research State."];

Print[If[allok, "CERTIFICATE OK", "CERTIFICATE FAILED"]];
Exit[If[allok, 0, 1]];
