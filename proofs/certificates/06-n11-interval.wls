(* 06-n11-interval.wls -- L3 exact scaling certificate for n=11 (Melissen record). *)
(* Re-run: wolframscript -file proofs/certificates/06-n11-interval.wls ; expect exit 0. *)
root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
cs = {{0, -393249576150477/1000000000000000}, {0, 718392312612297/1000000000000000}, {0, 587210308044291/250000000000000}, {787676322171637/500000000000000, 64825035452723/40000000000000}, {-787676322171637/500000000000000, 64825035452723/40000000000000}, {1772736164794799/1000000000000000, -234080601713679/250000000000000}, {-1772736164794799/1000000000000000, -234080601713679/250000000000000}, {456877388304909/250000000000000, 49916096430851/200000000000000}, {-456877388304909/250000000000000, 49916096430851/200000000000000}, {19630426808941/25000000000000, -1006235087192571/500000000000000}, {-19630426808941/25000000000000, -1006235087192571/500000000000000}};
Rr = 52633/20000;
cps = CandidatePoints[cs, Rr];
rho2 = RootReduce[Max[Function[p, Min[(p - #) . (p - #) & /@ cs]] /@ cps]];
Rcert = RootReduce[Rr/Sqrt[rho2]];
E1 = (RootReduce[Rcert - 2631/1000] > 0);   (* R_certified > printed record 2.631 *)
E2 = (RootReduce[Rcert - 26316/10000] > 0);  (* stronger: > 2.6316 *)
Print["R_certified ~ ", InputForm[N[Rcert, 20]]];
Print["E1 (>2.631)=", E1, "  E2 (>2.6316)=", E2];
If[E1 && E2, Print["n=11 L3 certificate OK"]; Exit[0], Print["FAIL"]; Exit[1]];
