(* Shared helpers for the H0 certificates 10f, 10g (proofs/10b-n6-H0.md).  Loads 10lib-n6.wl.
   Frame: Cn = D(0,R); O1 = D((0,a),1) holds the origin, a in [R-1,1]; q = (0,a-1); b = (0,-R);
   P = D(cP,1), cP = (x,y), x >= 0, a disk != O1 holding q.
   Boundary arcs are angle intervals (ccw); I1 = [Pi/2 - th1, Pi/2 + th1],
   IP = [phP - thP, phP + thP], phP = ArcSin[y/|cP|] in [-Pi/2, Pi/2] (x >= 0).
   Gaps:  gA (left, ccw from I1 to IP) = 3Pi/2 + phP - thP - th1,
          gB (right, ccw from IP to I1) = Pi/2 - phP - thP - th1.
   All quantities are machine Interval enclosures (outward rounded). *)

Get[FileNameJoin[{DirectoryName[$InputFileName], "10lib-n6.wl"}]];

(* theta(d) = half-angle of D(c,1) cap dCn for |c| = d (0 if they do not meet).  thIv returns an
   enclosure of theta over the interval d (and over the R interval). *)
h0clamp[x_Interval] := IntervalIntersection[x, Interval[{-1, 1}]];
thIv[RI_, dI_] := Module[{arg = (RI^2 + dI^2 - 1)/(2 RI dI), c},
   c = h0clamp[arg];
   Which[c === Interval[], Interval[{0, 0}],      (* arg > 1 or < -1 everywhere *)
    Max[arg] > 1, IntervalUnion[ArcCos[c], Interval[{0, 0}]],
    True, ArcCos[c]]];
thUp[RI_, dI_] := Max[thIv[RI, dI]];

h0norm[v_] := Sqrt[IntervalIntersection[v[[1]]^2 + v[[2]]^2, Interval[{0, Infinity}]]];

(* phP for x >= 0 *)
h0phi[cP_] := ArcSin[h0clamp[cP[[2]]/h0norm[cP]]];

h0pt[RI_, ang_] := {RI Cos[ang], RI Sin[ang]};

(* crossing points of dD(c1,1), dD(c2,1) (interval enclosures; clamped where tangent) *)
h0cross[c1_, c2_] := Module[{u = c2 - c1, D2, h, n, m = (c1 + c2)/2},
   D2 = u[[1]]^2 + u[[2]]^2;
   h = Sqrt[IntervalIntersection[1 - D2/4, Interval[{0, 1}]] /. Interval[] -> Interval[{0, 0}]];
   n = {-u[[2]], u[[1]]}/Sqrt[D2];
   {m + h n, m - h n}];
(* feasibility of covering by arcs {L,L,L,s}; inputs are Intervals; returns True if the cover is
   NOT excluded (possible), False if certified impossible *)
coverPossibleQ[gA_, gB_, th1_, thP_, L_, s_] := Module[{tot = 3 L + s, splits},
   If[Min[gA] > 0 && Min[gB] > 0,
    splits = Flatten[Table[{k L + e s, (3 - k) L + (1 - e) s}, {k, 0, 3}, {e, 0, 1}], 1];
    Or[AnyTrue[splits, Max[#[[1]]] >= Min[gA] && Max[#[[2]]] >= Min[gB] &],
     Max[tot] >= Min[2 Pi - 2 Max[th1, thP]]],
    Max[tot] >= Min[2 Pi - 2 th1 - 2 thP]]];

case3Pred[RI_][box_] := Module[{aI, xI, yI, q, b, cP, th1, thP, ph, gA, gB, al, L, dst, ws, cands},
   {aI, xI, yI} = N[Interval[#]] & /@ box;
   q = {0, aI - 1}; b = {0, -RI}; cP = {xI, yI};
   (* outside the case-3 domain:  P must hold q;  P must not hold b *)
   If[Min[n6sq[cP - q]] > 1 || Max[n6sq[cP - b]] <= 1 || Max[aI] < Min[RI] - 1, Return["skip"]];
   al = ArcSin[1/RI]; L = 2 al;
   th1 = Interval[{0, thUp[RI, aI]}];
   thP = Interval[{0, thUp[RI, h0norm[cP]]}];
   ph = h0phi[cP];
   gA = 3 Pi/2 + ph - thP - th1; gB = Pi/2 - ph - thP - th1;
   dst = Min[Sqrt[RI^2 - 1]];
   ws = {{0 xI, yI - n6sqrt[1 - xI^2]}};
   cands = Select[h0cross[{0, aI}, cP], Max[n6sq[#]] < Min[RI^2] &];
   ws = Join[ws, cands];
   AnyTrue[ws, Function[w, Module[{dq = Max[1 + h0norm[w]], s},
      s = If[dq >= dst, L, 2 Interval[{0, thUp[RI, Interval[{dq, dq}]]}]];
      ! coverPossibleQ[gA, gB, th1, thP, L, s]]]]];
