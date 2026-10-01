#!/usr/bin/env wolframscript
(* Certificate for proofs/01-ring-symmetry.md.
   Checks, for k = 6..9 (n = k+1 = 7..10), every computational step of the proof:
     (E0) f(m) = m at Rs = 1 + 2 Cos[2Pi/k], m = 2Pi/k          [exact, FullSimplify]
     (E1) slope s = f'(m) = (1 - 2C)/(1 + 2C) <= 0, C = Cos[2Pi/k] [exact]
     (E2) beta0 <= m < beta1                                     [certified numerics, 50 digits]
     (E3) L(0) >= Amax  (L = tangent line at m)                  [exact for k=6, else certified]
     (E4) L(Pi) >= 0   (covers disks with alpha = 0, 0 < d < 2) [certified numerics]
     (E5) regular ring covers D(0,Rs) exactly, not D(0,Rs+1e-30)  [ExactCoverQ]
   and records why the method stops at k = 10 ((E3) fails; (E4) fails from k = 11).
   Usage (repo root): wolframscript -file proofs/certificates/01-ring-symmetry.wls
   Exit 0 iff every check for k = 6..9 passes. *)

Get[FileNameJoin[{DirectoryName[ExpandFileName[$InputFileName]], "..", "..", "wl", "CirCovCir.wl"}]];

x[u_, R_] := (R^2 - 1 + 4 Cos[u]^2)/(4 R Cos[u]);       (* cos(alpha/2), u = beta/2 *)
f[b_, R_] := 2 ArcCos[x[b/2, R]];
pos[e_] := Module[{v = N[e, 50]}, Precision[v] > 20 && v > 0];   (* certified strict sign *)

check[k_] := Module[{R = RingRadius[k], m = 2 Pi/k, C = Cos[2 Pi/k], s, b0, b1, Amax, L0, r},
  s = D[f[b, R], b] /. b -> m;
  b0 = 2 ArcCos[Min[1, Sqrt[R^2 - 1]/2]];
  b1 = 2 ArcCos[(R - 1)/2];
  Amax = MaxCoveredArc[R];
  L0 = m - s m;
  r = <|
    "E0 f(m)=m" -> (FullSimplify[f[m, R] - m] === 0),
    "E1 s=(1-2C)/(1+2C)" -> (FullSimplify[s - (1 - 2 C)/(1 + 2 C)] === 0),
    "E1 s<=0" -> (k == 6 && FullSimplify[s] === 0 || pos[-s]),
    "E2 b0<=m" -> (FullSimplify[b0 - m] === 0 || pos[m - b0]),
    "E2 m<b1" -> pos[b1 - m],
    "E3 L(0)>=Amax" -> (FullSimplify[L0 - Amax] === 0 || pos[L0 - Amax]),
    "E4 L(Pi)>=0" -> pos[m + s (Pi - m)],
    "E5 covers R*" -> ExactCoverQ[RingConfig[k], R],
    "E5 tight" -> ! ExactCoverQ[RingConfig[k], R + 10^-30]|>;
  Print["k=", k, " (n=", k + 1, ")  R*=", N[R, 20], "  s=", N[s, 12],
   "  L(0)-Amax=", N[L0 - Amax, 12], "  ", If[AllTrue[r, TrueQ], "ALL PASS", r]];
  AllTrue[r, TrueQ]];

ok = AllTrue[Range[6, 9], check];

(* k = 10: the tangent-line bound fails, so the argument cannot reach n = 11 (record 2.631 > Rs) *)
With[{R = RingRadius[10], m = Pi/5},
  Print["k=10: L(0)-Amax = ",
   N[m - (D[f[b, R], b] /. b -> m) m - MaxCoveredArc[R], 12], "  (negative => method stops)"]];

Print[If[ok, "CERTIFICATE OK", "CERTIFICATE FAILED"]];
Exit[If[ok, 0, 1]];
