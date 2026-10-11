(* quick probe of case3Pred / B&B speed (exploration; not a certificate) *)
Get["/home/skim/projects/research/circovcir/proofs/certificates/10lib-H0.wl"];
Off[General::munfl];
Rlo = 1798867827575/10^12; RhiH = Rlo + 1/10^10;
RI0 = N[Interval[{Rlo, RhiH}]];
f[c_, w_] := case3Pred[RI0][{{c[[1]] - w, c[[1]] + w}, {c[[2]] - w, c[[2]] + w}, {c[[3]] - w, c[[3]] + w}}];
Print[{f[{0.9633, 0.8934, -0.486}, 0], f[{0.9633, 0.8934, -0.486}, 0.0005], f[{0.9633, 0.8934, -0.486}, 0.002],
   f[{0.95, 0.5, -0.9}, 0.01], f[{0.95, 0.5, -0.9}, 0.05]}];
Print["time/box ", AbsoluteTiming[Do[f[{0.9633, 0.8934, -0.486}, 0.0005], {200}]][[1]]/200];
(* small sub-sweep for timing *)
n6boxes = 0; n6stuck = {};
Print[AbsoluteTiming[n6prove[case3Pred[RI0], {{0.95, 0.97}, {0.88, 0.90}, {-0.5, -0.47}}, {1, 1, 1}, 40]], " boxes ", n6boxes];
n6boxes = 0; n6stuck = {};
RIc = N[Interval[{179528/100000, 179528/100000}]];
Print["control (expect False): ", n6prove[case3Pred[RIc], {{1 - 10^-6, 1}, {866025/10^6 - 10^-6, 866025/10^6 + 10^-6}, {-1/2 - 10^-6, -1/2 + 10^-6}}, {1, 1, 1}, 12], " boxes ", n6boxes];
