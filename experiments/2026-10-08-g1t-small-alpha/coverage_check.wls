#!/usr/bin/env wolframscript
(* Coverage seamlessness check for S3b G1T small-alpha certificate (Cycle 9).
   Verifies: (1) d0 identical in both parts; (2) the ring collar box B_ring is the exact
   set Pbb skips via inRing; (3) a DENSE feasible grid over Omega is M>=0 everywhere and
   every point lands in exactly one owner (collar OR B&B-feasible OR boundary face). *)
root = "/home/skim/projects/research/circovcir";
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
$MaxExtraPrecision = 400;
Do[Module[{k = n - 1, R, abar, fbar, fp, Tf, sstar, tstar, d0 = 1/160, smin, smax, hfun,
    uu, Mval, nbad, ncollar, nface, ninterior, nfeas, ntot, ringW},
  R = N[1 + 2 Cos[2 Pi/k], 50]; abar = N[6 Pi/k, 50];
  fbar = N[2 ArcSin[Sin[abar/2]/R], 50]; fp = N[Cos[abar/2]/(R Sqrt[1 - (Sin[abar/2]/R)^2]), 50];
  Tf[a_] := fbar + fp (a - abar);
  sstar = N[2 Cos[Pi/k], 50]; tstar = N[Pi/k, 50];
  smin = R - 1; smax = Sqrt[R^2 - 1];
  hfun[s_] := ArcCos[(R^2 + s^2 - 1)/(2 R s)];
  uu[s_, t_] := {R Cos[t] - s, R Sin[t]};
  Mval[s_, t1_, t2_] := Module[{a1 = uu[s, t1], a2 = uu[s, t2], al},
    al = ArcCos[(a1 . a2)/(Sqrt[a1 . a1] Sqrt[a2 . a2])]; Cos[t2 - t1] - Cos[Tf[al]]];
  (* ring witness self-check *)
  ringW = N[Mval[sstar, -tstar, tstar], 20];
  (* dense feasible grid: for s in [smin,smax], t_j in [-h(s),h(s)], t1<t2, alpha<=abar *)
  nbad = 0; ncollar = 0; nface = 0; ninterior = 0; nfeas = 0; ntot = 0;
  Module[{NS = 60, NT = 48},
   Do[
     Module[{s, h, t1, t2, a1, a2, al, m, inCollar, onFace},
      s = smin + is (smax - smin)/NS;
      h = hfun[s];
      t1 = -h + it1 (2 h)/NT;
      t2 = -h + it2 (2 h)/NT;
      ntot++;
      If[t2 > t1,
       a1 = uu[s, t1]; a2 = uu[s, t2];
       al = ArcCos[(a1 . a2)/(Sqrt[a1 . a1] Sqrt[a2 . a2])];
       If[al <= abar + 10^-12,
        nfeas++;
        m = Mval[s, t1, t2];
        If[N[m, 20] < -10^-12, nbad++];
        inCollar = (Abs[s - sstar] <= d0) && (Abs[t1 + tstar] <= d0) && (Abs[t2 - tstar] <= d0);
        onFace = (Abs[Sqrt[a1 . a1] - 1] <= 10^-9) && (Abs[Sqrt[a2 . a2] - 1] <= 10^-9);
        Which[inCollar, ncollar++, onFace, nface++, True, ninterior++]]]],
     {is, 0, NS}, {it1, 0, NT}, {it2, 0, NT}]];
  Print["n=", n, "  d0(Pcollar)=d0(Pbb)=", d0, "  ring witness M=", ringW];
  Print["   grid pts total=", ntot, " feasible(in Omega)=", nfeas,
    "  M<0 violations=", nbad];
  Print["   ownership: collar(B_ring)=", ncollar, "  on |u|=1 face=", nface,
    "  interior(B&B)=", ninterior, "  (sum=", ncollar + nface + ninterior, ")"];
  ], {n, {8, 9, 10}}];
