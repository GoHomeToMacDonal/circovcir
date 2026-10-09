r10 = 1 + 2 Cos[2 Pi/9];
(* r solves 4 asin(1/(2r)) + asin(1/r) = pi; r0=1.07326 is FT's upper bound for r *)
rp = r /. FindRoot[4 ArcSin[1/(2 r)] + ArcSin[1/r] == Pi, {r, 1.07}, WorkingPrecision->50];
Print["pentagon circumradius r = ", N[rp,15], "  (FT upper bd r0=1.07326)"];
(* central angles: four sides length1 -> 2 asin(1/(2r)); one side length2 -> 2 asin(1/r);
   area = sum of (1/2) r^2 sin(central angle) over 5 triangles *)
areaPent[rr_] := 4 ((1/2) rr^2 Sin[2 ArcSin[1/(2 rr)]]) + (1/2) rr^2 Sin[2 ArcSin[1/rr]];
Print["pentagon area (exact r) = ", N[areaPent[rp],15], "   FT 2.284572282"];
(* FT uses r0=1.07326 as an UPPER bound and the area is increasing in r on this range,
   so evaluate at r0=1.07326 too *)
Print["pentagon area at r0=1.07326 = ", N[areaPent[1.07326],15]];
Print["match FT? ", Abs[N[areaPent[rp]] - 2.284572282] < 1*^-6];
Print["(10)  a(P2) <= ", N[areaPent[rp],12], "  <= 2.284572282 ? ", TrueQ[areaPent[rp] <= 2.2845723]];
Print["(10') a(P2)+a(P3) <= 2x = ", N[2 areaPent[rp],12], "  FT 4.5691944564"];
