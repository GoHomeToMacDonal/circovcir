#!/usr/bin/env wolframscript
(* Certificate for proofs/03-n7-optimal.md : R_3 = 2/Sqrt[3], R_4 = Sqrt[2], R_7 = 2
   (all UNCONDITIONAL, arc-counting method). Checks every computational step:
     (E_max)    sup_d omega(R,d) = A(R) = 2 ArcSin[1/R] for R>1, attained at d=Sqrt[R^2-1]  [exact]
     (E_dec)    A'(R) < 0 on R>1  (so R > R_n => A(R) < A(R_n))                              [exact]
     (E_hit)    A(2/Sqrt3)=2Pi/3, A(Sqrt2)=Pi/2, A(2)=Pi/3  (= 2Pi/n for n=3,4; 2Pi/6 for n=7) [exact]
     (E_cover3) known n=3 config covers D(0,2/Sqrt3) exactly, not +1e-30                      [ExactCoverQ]
     (E_cover4) known n=4 config covers D(0,Sqrt2)  exactly, not +1e-30                       [ExactCoverQ]
     (E_cover7) RingConfig[6] covers D(0,2) exactly, not +1e-30; RingRadius[6]==2             [ExactCoverQ]
     (E_step2)  (n=7 only) a disk touching Gamma_R with R>2 has d>1, so it misses O           [exact]
   Usage (repo root): wolframscript -file proofs/certificates/03-n7-optimal.wls
   Exit 0 iff all checks pass. *)

root = FileNameJoin[{DirectoryName[ExpandFileName[$InputFileName]], "..", ".."}];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];

omega[R_, d_] := 2 ArcCos[(R^2 + d^2 - 1)/(2 R d)];
A[R_] := 2 ArcSin[1/R];

(* E_max : stationary at d*=Sqrt[R^2-1]; value equals A(R).
   arccos(Sqrt[R^2-1]/R) = arcsin(1/R): prove via equal sine AND cosine on R>1. *)
dstar = Sqrt[R^2 - 1];
eMaxStat = FullSimplify[(D[omega[R, d], d] /. d -> dstar), R > 1] === 0;
eMaxArg  = FullSimplify[(R^2 + dstar^2 - 1)/(2 R dstar) - Sqrt[R^2 - 1]/R, R > 1] === 0;
eMaxVal  = FullSimplify[Sin[ArcCos[Sqrt[R^2 - 1]/R]] - Sin[ArcSin[1/R]], R > 1] === 0 &&
           FullSimplify[Cos[ArcCos[Sqrt[R^2 - 1]/R]] - Cos[ArcSin[1/R]], R > 1] === 0;
eMax = eMaxStat && eMaxArg && eMaxVal;

(* E_dec : A'(R) < 0 for R>1 *)
Aprime = FullSimplify[D[A[R], R], R > 1];        (* = -2/(R Sqrt[R^2-1]) *)
eDec = TrueQ[Simplify[Aprime < 0, R > 1]];

(* E_hit : the three exact landings *)
eHit3 = FullSimplify[A[2/Sqrt[3]] - 2 Pi/3] === 0;   (* 2Pi/n, n=3 *)
eHit4 = FullSimplify[A[Sqrt[2]] - Pi/2] === 0;        (* 2Pi/n, n=4 *)
eHit7 = FullSimplify[A[2] - Pi/3] === 0;              (* 2Pi/6, n=7 center-adjusted *)
eHit = eHit3 && eHit4 && eHit7;

(* E_cover3/4 : exact coverage by the known small configs, tight *)
cfg[n_] := LoadConfig[FileNameJoin[{root, "data", "configs",
   StringPadLeft[ToString[n], 2, "0"], "known.json"}]];
coverTight[a_] := Module[{c = a["Centers"], R = a["RValue"]},
  ExactCoverQ[c, R] && ! ExactCoverQ[c, R + 10^-30]];
eCover3 = coverTight[cfg[3]];
eCover4 = coverTight[cfg[4]];

(* E_cover7 : exact coverage by the n=7 regular ring, tight, R*=2 *)
eCover7 = RingRadius[6] === 2 && ExactCoverQ[RingConfig[6], RingRadius[6]] &&
          ! ExactCoverQ[RingConfig[6], 2 + 10^-30];

(* E_step2 : {R>2, |d-R|<1, d>0} => d-1>0  (disk touching Gamma_R misses O) *)
eStep2 = TrueQ[Reduce[Implies[R > 2 && Abs[d - R] < 1 && d > 0, d - 1 > 0], {R, d}, Reals]];

all = eMax && eDec && eHit && eCover3 && eCover4 && eCover7 && eStep2;

Print["E_max    (sup omega = 2 ArcSin[1/R]) : ", eMax, "   [stat=", eMaxStat, " arg=", eMaxArg, " val=", eMaxVal, "]"];
Print["E_dec    (A'(R) < 0, R>1)            : ", eDec, "   A'(R)=", Aprime];
Print["E_hit    (A(R_n) landings)           : ", eHit, "   [n3=", eHit3, " n4=", eHit4, " n7=", eHit7, "]"];
Print["E_cover3 (n=3 config, tight)         : ", eCover3];
Print["E_cover4 (n=4 config, tight)         : ", eCover4];
Print["E_cover7 (ring covers D(0,2), tight) : ", eCover7];
Print["E_step2  (touch Gamma_R => d>1)      : ", eStep2];
Print["A: n=3 ", N[A[2/Sqrt[3]], 12], "=2Pi/3 ", N[2 Pi/3, 12],
  " | n=4 ", N[A[Sqrt[2]], 12], "=Pi/2 ", N[Pi/2, 12],
  " | n=7 ", N[A[2], 12], "=Pi/3 ", N[Pi/3, 12]];
Print[If[all, "CERTIFICATE OK", "CERTIFICATE FAILED"]];
Exit[If[all, 0, 1]];
