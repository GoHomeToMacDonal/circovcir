#!/usr/bin/env wolframscript
(* Certificate 10g for proofs/10b-n6-H0.md, case 2:  some disk P = D((x,y),1) holds both
   q = (0,a-1) and b = (0,-R);  x >= 0 after a mirror.  R in [Rlo, Rlo + 10^-10].
   Notation: 10lib-H0.wl.  A_L / A_R = boundary arcs left / right of I1 u IP, lengths gA / gB.
   C2s = D((0,y),1),  b' = -y,  Vs = (-Sqrt[1-s^2], (a-b')/2), s = (a+b')/2  (left crossing of
   dO1, dC2s).  T1 = dO1 cap dCn (x>0), X0 = T1 rotated clockwise by 2 alpha (10lib-n6),
   T2P = ccw end of IP (angle phP + thP), Y = T2P rotated ccw by 2 alpha.
   Gates, on every box of (a,x,y) meeting the case-2 domain
       {a in [R-1,1], x in [0,1], |cP-q| <= 1, |cP-b| <= 1, 2 th1 + 2 thP + 8 alpha >= 2 Pi}:
     (G2)  gA > 2 alpha  and  gB > 2 alpha      (each side needs two of the four other disks)
     (V2)  no closed unit disk contains {Vs, T2P, X0}, and none contains {Vs, T1, Y}
           (a disk whose arc covers an end-portion of A_R of length gB - 2 alpha cannot hold Vs)
   (C2) negative control: at the optimum (x = 0), the right-hand triple {V, T2, X0} DOES fit.
   Interval B&B, machine Interval arithmetic.  Exit 1 on failure; last line "CERTIFICATE OK". *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "10lib-H0.wl"}]];
fail[msg_] := (Print["FAIL: ", msg]; Exit[1]);
gate[name_, ok_] := If[TrueQ[ok], Print["PASS ", name], fail[name]];
Off[General::munfl];

Rlo = 1798867827575/10^12; RhiH = Rlo + 1/10^10;
RI0 = N[Interval[{Rlo, RhiH}]];

case2Geo[RI_, box_] := Module[{aI, xI, yI, cP, al, th1, thP, ph, bb, s},
   {aI, xI, yI} = N[Interval[#]] & /@ box;
   cP = {xI, yI}; al = ArcSin[1/RI];
   th1 = thIv[RI, aI]; thP = thIv[RI, h0norm[cP]]; ph = h0phi[cP];
   bb = -yI; s = (aI + bb)/2;
   <|"a" -> aI, "cP" -> cP, "al" -> al, "th1" -> th1, "thP" -> thP, "ph" -> ph,
     "gA" -> 3 Pi/2 + ph - thP - th1, "gB" -> Pi/2 - ph - thP - th1,
     "Vs" -> {-n6sqrt[1 - s^2], (aI - bb)/2},
     "T1" -> n6T1[RI, aI], "X0" -> n6X0[RI, aI],
     "T2P" -> h0pt[RI, ph + thP], "Y" -> h0pt[RI, ph + thP + 2 al]|>];

outQ[RI_, box_] := Module[{aI, xI, yI, cP, q, b, al},
   {aI, xI, yI} = N[Interval[#]] & /@ box;
   cP = {xI, yI}; q = {0, aI - 1}; b = {0, -RI}; al = ArcSin[1/RI];
   Min[n6sq[cP - q]] > 1 || Min[n6sq[cP - b]] > 1 || Max[aI] < Min[RI] - 1 ||
    Max[2 thUp[RI, aI] + 2 thUp[RI, h0norm[cP]] + 8 al] < Min[2 Pi + 0 al]];

predG = Function[box, If[outQ[RI0, box], "skip",
    With[{g = case2Geo[RI0, box]}, Min[g["gA"]] > Max[2 g["al"]] && Min[g["gB"]] > Max[2 g["al"]]]]];
predV = Function[box, If[outQ[RI0, box], "skip",
    With[{g = case2Geo[RI0, box]},
     n6fitsFalseQ[{g["Vs"], g["T2P"], g["X0"]}] && n6fitsFalseQ[{g["Vs"], g["T1"], g["Y"]}]]]];

box0 = {{Rlo - 1, 1}, {0, 1}, {-14/5, 1/4}};
sc = {1/5, 1, 3};
run[name_, pred_] := (n6boxes = 0; n6stuck = {};
   Module[{t, r}, {t, r} = AbsoluteTiming[n6prove[pred, box0, sc, 60]];
    Print["  ", name, ": boxes ", n6boxes, ", ", Round[t, 0.1], " s"];
    If[! r, Print["  first stuck box: ", N[First[n6stuck], 12]]];
    gate[name, r]]);
run["G2 both side gaps longer than 2 alpha", predG];
run["V2 a disk holding Vs cannot serve A_R", predV];

(* (C2) negative control at the optimum: right-hand triple V, T2, X0 fits a unit disk *)
With[{a6 = 93548542820120509732/10^20, b6 = 101058133672818553080/10^20, e = 1/10^8},
  Module[{RIc = N[Interval[{Rlo, RhiH}]], aI = N[Interval[{a6 - e, a6 + e}]], bI = N[Interval[{b6 - e, b6 + e}]]},
   gate["C2 control (optimum's {V,T2,X0} not certified as non-fitting)",
    ! n6fitsFalseQ[{n6V[aI, bI], n6T2[RIc, bI], n6X0[RIc, aI]}]]]];
Print["CERTIFICATE OK"];
