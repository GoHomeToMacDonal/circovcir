#!/usr/bin/env wolframscript
(* explore.wls -- confirm the n=8 active set and geometry at the proven optimum. *)
Get["/home/skim/projects/research/circovcir/wl/CirCovCir.wl"];

k = 7;                                     (* ring size; n = 8 *)
s0 = 2 Cos[Pi/k];                          (* ring radius (center-to-ring distance) *)
R8 = 1 + 2 Cos[2 Pi/k];                    (* = RingRadius[7] *)
cfg = CirCovCir`RingConfig[k];             (* {0,0} + 7-ring, disk 0 on +x axis *)

Print["s0 = 2cos(pi/7)      = ", InputForm[N[s0, 25]]];
Print["R8 = 1+2cos(2pi/7)   = ", InputForm[N[R8, 25]]];
Print["ExactCoverQ          = ", CirCovCir`ExactCoverQ[cfg, R8]];

(* tight points *)
tp = CirCovCir`TightPoints[cfg, R8, 10^-10];
Print["#tight points        = ", Length[tp]];
Do[Print["  pt ", InputForm[N[p[[1]], 8]], "  nearest idx (1-based) = ", p[[2]]], {p, tp}];

(* classify: interior triple {center=1, j, j+1} circumradius^2, boundary pair |y|^2 = R^2 *)
Print["--- interior triples {1, j, j+1}: circumradius^2 (want =1) ---"];
Do[Module[{tri = cfg[[{1, j, Mod[j, k] + 2}]], cc, r2},
   cc = CirCovCir`Private`circumcenter[tri];
   r2 = (cc - tri[[1]]).(cc - tri[[1]]);
   Print["  {1,", j, ",", Mod[j, k] + 2, "}  circumcenter=", InputForm[N[cc, 8]],
     "  r^2=", InputForm[N[RootReduce[r2], 12]], "  |cc|=", InputForm[N[Sqrt[cc.cc], 8]]];
   ], {j, 2, k + 1}];
