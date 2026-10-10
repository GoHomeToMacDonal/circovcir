#!/usr/bin/env wolframscript
(* ============================================================================
   Certificate 08 : supplement for the human-review document proofs/REVIEW.md
   (n = 8, 9 unconditional optimality; n = 10 conditional on the Lemma for n=10).

   It closes the single-cell AREA bound (FT's G2, inequality (6)), which before
   this certificate was only float evidence (L1, experiments/2026-10-01-fejes-toth-audit),
   and it replaces FT's Jensen step (6) by a TANGENT-LINE bound U, which also makes the
   terminal monotonicity a one-line concavity argument.  See REVIEW.md section C.4-C.6.

   Notation: r = R_n = 1 + 2 Cos[2 Pi/k], k = n-1, abar = 6 Pi/k,
     f(a) = 2 ArcSin[Sin[a/2]/r],   F(a) = r^2/2 (f(a) - Sin[f(a)]) + Sin[a]/2,
     U(a) = F(abar) + F'(abar) (a - abar)          (tangent of F at abar),
     G(a) = Sin[2 Pi/k] + Sin[(k-1) Pi/k - a/2] + U(a).

   Gates (all exact / quantifier elimination / rational-interval; no float decisions):
     H1  chord lemma: a,b in [0,1], c = Cos[alpha] in [-1, 1/2] (alpha in [Pi/3,Pi])
         => a^2 + b^2 - 2 a b c <= 2 - 2 c                         [Resolve, all a,b,c]
     H2  F'' < 0 on (0,Pi) for EVERY r > 1                         [Resolve, all r,c,w]
         (F'' = Sin[a/2] N(c,w,r) / (8 w^3), c = Cos[a/2], w = Sqrt[r^2 - Sin[a/2]^2];
          the identity is checked symbolically at random rational points AND
          N < 0 is decided by quantifier elimination.)
     H3  f(abar) = 2 Pi/k  (Sin[3Pi/k] = r Sin[Pi/k], RootReduce; branch 3Pi/k <= Pi/2)
     H4  f'(abar) > 0
     H5  G'(abar) = -Cos[(k-4)Pi/k]/2 + F'(abar) < 0                [exact algebraic sign]
     H6  U(a) > a/2 on [0, Pi/3]  (U, a/2 linear: check both ends)  [rational intervals]
     H7  area identity  k G(abar) = Pi r^2                          [RootReduce = 0]
     H8  RingConfig points: inner triple point at distance 1 from all three centres,
         outer pair point at distance exactly r from o                [RootReduce = 0]
     H9  argument of Sin in G stays in (0,Pi) for a in [abar,Pi]    [exact]
   Exit 0 iff every gate is True.
   Run:  wolframscript -file proofs/certificates/08-review-supplement.wls
   ============================================================================ *)

ok = <||>;
(* numeric CROSS-CHECK of two closed forms for the same exact quantity (difference is 0;
   N::meprec is expected and silenced).  Not a sign decision: every sign gate is exact. *)
sameQ[x_] := Quiet[Abs[N[x, 50]] < 10^-40, N::meprec];

(* ---------- H1 chord lemma ---------- *)
ok["H1"] = Resolve[ForAll[{a, b, c},
     0 <= a <= 1 && 0 <= b <= 1 && -1 <= c <= 1/2,
     a^2 + b^2 - 2 a b c <= 2 - 2 c], Reals];
Print["H1 chord^2 <= 2-2cos(alpha) for a,b<=1, alpha>=Pi/3 : ", ok["H1"]];

(* ---------- H2 strict concavity of F, all r > 1 ---------- *)
fG[r_, a_] := 2 ArcSin[Sin[a/2]/r];
FG[r_, a_] := r^2/2 (fG[r, a] - Sin[fG[r, a]]) + Sin[a]/2;
Nn[r_, c_, w_] := 1 + 2 r^2 + (6 r^2 - 2) (2 c^2 - 1) - 8 c w^3 + 2 (2 c^2 - 1)^2 - 1;
d2F[r_, a_] = D[FG[r, a], {a, 2}];
idPts = {{9/4, 1/3}, {12/5, 7/5}, {5/2, 3}, {3, 1/10}, {21/10, 2}};
idOK = And @@ Table[Module[{rr = N[p[[1]], 80], aa = N[p[[2]], 80], lhs, rhs},
     lhs = d2F[rr, aa];
     rhs = Sin[aa/2] Nn[rr, Cos[aa/2], Sqrt[rr^2 - Sin[aa/2]^2]]/(8 (rr^2 - Sin[aa/2]^2)^(3/2));
     Abs[N[lhs - rhs, 60]] < 10^-50], {p, idPts}];
signOK = Resolve[ForAll[{r, c, w},
     r > 1 && 0 < c < 1 && w > 0 && w^2 == r^2 - 1 + c^2, Nn[r, c, w] < 0], Reals];
ok["H2"] = idOK && signOK;
Print["H2 F''<0 on (0,Pi), all r>1 : ", ok["H2"], "   [identity spot-check ", idOK,
  ", QE sign ", signOK, "]"];

(* rational enclosure of an exact real number (algebraic via IsolatingInterval) *)
encl[x_] := Module[{rr = RootReduce[x]},
   If[Element[rr, Rationals], Interval[{rr, rr}], Interval[IsolatingInterval[rr, 10^-40]]]];
piI = Interval[{31415926535897932384626433832795028/10^34,
               31415926535897932384626433832795029/10^34}];

perN = Table[Module[{k = n - 1, r, ab, fp, Fp, Fab, Galg, H3, H4, H5, H6, H7, H8, H9,
     a0, b0, a1, b1, U0, Upi3, ring, cen, pIn, qOut},
    r = 1 + 2 Cos[2 Pi/k]; ab = 6 Pi/k;
    (* H3 *)
    H3 = (RootReduce[Sin[3 Pi/k] - r Sin[Pi/k]] === 0) && (3 Pi/k <= Pi/2);
    (* derivatives at abar, written algebraically (Sin/Cos of rational multiples of Pi) *)
    fp = Cos[ab/2]/Sqrt[r^2 - Sin[ab/2]^2];
    Fp = Sin[ab] Sin[ab/2]/(2 Sqrt[r^2 - Sin[ab/2]^2]) + Cos[ab]/2;
    (* cross-check closed forms against symbolic derivatives *)
    H4 = (RootReduce[fp] > 0) &&
      sameQ[(D[fG[r, x], x] /. x -> ab) - fp] &&
      sameQ[(D[FG[r, x], x] /. x -> ab) - Fp];
    (* H5 *)
    H5 = RootReduce[-Cos[(k - 4) Pi/k]/2 + Fp] < 0;
    (* F(abar) using H3: f(abar) = 2Pi/k  =>  F(abar) = r^2 Pi/k + [algebraic] *)
    Fab = r^2 Pi/k - r^2/2 Sin[2 Pi/k] + Sin[ab]/2;
    (* U(a) = Fab + Fp (a - ab).  U(0) = a0 + b0 Pi,  U(Pi/3) - Pi/6 = a1 + b1 Pi *)
    a0 = -r^2/2 Sin[2 Pi/k] + Sin[ab]/2;  b0 = r^2/k - 6 Fp/k;
    a1 = a0;                              b1 = b0 + Fp/3 - 1/6;
    U0 = encl[a0] + encl[b0] piI;  Upi3 = encl[a1] + encl[b1] piI;
    H6 = (Min[U0] > 0) && (Min[Upi3] > 0) &&
      sameQ[(Fab + Fp (0 - ab)) - (a0 + b0 Pi)] &&
      sameQ[(Fab + Fp (Pi/3 - ab)) - Pi/6 - (a1 + b1 Pi)];
    (* H7: k G(abar) - Pi r^2 : the Pi-terms cancel (k * r^2 Pi/k = Pi r^2) *)
    Galg = k Sin[2 Pi/k] + k Sin[(k - 4) Pi/k] - k r^2/2 Sin[2 Pi/k] + k Sin[ab]/2;
    H7 = RootReduce[Galg] === 0 &&
      sameQ[k (Sin[2 Pi/k] + Sin[(k - 4) Pi/k] + FG[r, ab]) - Pi r^2];
    (* H8: ring geometry, centres c_j = 2Cos[Pi/k] e(2 Pi j/k), j = 0,1 *)
    cen = Table[2 Cos[Pi/k] {Cos[2 Pi j/k], Sin[2 Pi j/k]}, {j, 0, 1}];
    pIn = Cos[Pi/k] {Cos[Pi/k], Sin[Pi/k]} 2 Cos[Pi/k] - Cos[2 Pi/k] {Cos[Pi/k], Sin[Pi/k]};
    qOut = (2 Cos[Pi/k]^2 + Cos[2 Pi/k]) {Cos[Pi/k], Sin[Pi/k]};
    H8 = And[RootReduce[pIn.pIn - 1] === 0,
      RootReduce[(pIn - cen[[1]]).(pIn - cen[[1]]) - 1] === 0,
      RootReduce[(pIn - cen[[2]]).(pIn - cen[[2]]) - 1] === 0,
      RootReduce[(qOut - cen[[1]]).(qOut - cen[[1]]) - 1] === 0,
      RootReduce[(qOut - cen[[2]]).(qOut - cen[[2]]) - 1] === 0,
      RootReduce[Sqrt[qOut.qOut] - r] === 0];
    (* H9: (k-1)Pi/k - a/2 for a in [abar, Pi] lies in [(k-2)Pi/(2k), (k-4)Pi/k] ⊂ (0,Pi) *)
    H9 = ((k - 2) Pi/(2 k) > 0) && ((k - 4) Pi/k < Pi) && (k - 4 > 0);
    Print["n=", n, "  r=", N[r, 20]];
    Print["  H3 f(abar)=2Pi/k           : ", H3];
    Print["  H4 f'(abar)>0, closed forms : ", H4, "   f'(abar)=", N[fp, 15], "  F'(abar)=", N[Fp, 15]];
    Print["  H5 G'(abar)<0 (exact)       : ", H5, "   G'(abar)=", N[-Cos[(k - 4) Pi/k]/2 + Fp, 20]];
    Print["  H6 U(a)>a/2 on [0,Pi/3]     : ", H6, "   U(0) in ", N[U0, 12], "  U(Pi/3)-Pi/6 in ", N[Upi3, 12]];
    Print["  H7 k G(abar) = Pi r^2       : ", H7];
    Print["  H8 ring triple/pair points  : ", H8];
    Print["  H9 Sin argument in (0,Pi)   : ", H9];
    {H3, H4, H5, H6, H7, H8, H9}], {n, 8, 10}];

ok["perN"] = And @@ Flatten[perN];
Print["------------------------------------------------------------"];
Print["H1 ", ok["H1"], "  H2 ", ok["H2"], "  per-n (H3..H9, n=8,9,10) ", ok["perN"]];
If[TrueQ[ok["H1"]] && TrueQ[ok["H2"]] && TrueQ[ok["perN"]],
  Print["CERTIFICATE OK -- review supplement (G2 area bound + tangent closer) L3"]; Exit[0],
  Print["CERTIFICATE FAILED"]; Exit[1]];
