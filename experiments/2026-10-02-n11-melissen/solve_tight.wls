#!/usr/bin/env wolframscript
(* n=11 Melissen cover, L3-aimed EXACT polish via the tight-contact equation system.

   No optimization (which is scale-degenerate for rho(c,1)); instead solve the rigidity
   system with FindRoot at high precision, seeded from the float optimum.

   Symmetric centers (vertical mirror x -> -x), 11 scalar params:
     S0=(0,a) S1=(0,b) S2=(0,g);  p1=(u1,v1) p2=(u2,v2) p3=(u3,v3) p4=(u4,v4)
     and their mirrors (-u,v).

   Distinct tight contacts (right half + on-axis), each pins a tight point X at distance 1:
     INT (3 generators, circumcenter): {S0,S1,p3},{S0,p2,p3},{S1,S2,p1},{S1,p1,p3},
                                       and on-axis {S0,p4,p4'}
     BND (2 generators, on |x|=R):     {S2,p1},{p1,p3},{p2,p3},{p2,p4}, and on-axis {p4,p4'}

   Unknowns: 11 params + R + for every distinct tight point its (x,y) = 2 each.
   Equations per INT point P with generators A,B,C:
       |P-A|^2=1, |P-B|^2=1, |P-C|^2=1               (3 eq, 2 coords + shared)
   Equations per BND point P with generators A,B:
       |P-A|^2=1, |P-B|^2=1, |P|^2=R^2                (3 eq)
   The three-generator INT points are over-determined by design (circumcenter at dist 1):
   that extra equation per interior vertex is what pins R and the shape rigidly.

   Usage: solve_tight.wls [wp]
*)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
wp = If[Length[args] >= 1, ToExpression[args[[1]]], 60];

(* --- symbolic centers --- *)
S0 = {0, a}; S1 = {0, b}; S2 = {0, g};
p1 = {u1, v1}; p1m = {-u1, v1};
p2 = {u2, v2}; p2m = {-u2, v2};
p3 = {u3, v3}; p3m = {-u3, v3};
p4 = {u4, v4}; p4m = {-u4, v4};

(* tight-point unknown coords *)
(* INT: 4 generic (right) + 1 on-axis *)
XiA = {xA, yA};  (* S0,S1,p3 *)
XiB = {xB, yB};  (* S0,p2,p3 *)
XiC = {xC, yC};  (* S1,S2,p1 *)
XiD = {xD, yD};  (* S1,p1,p3 *)
XiE = {0, yE};   (* S0,p4,p4m  on-axis *)
(* BND: 4 generic (right) + 1 on-axis bottom *)
XbF = {xF, yF};  (* S2,p1 *)
XbG = {xG, yG};  (* p1,p3 *)
XbH = {xH, yH};  (* p2,p3 *)
XbI = {xI, yI};  (* p2,p4 *)
XbJ = {0, yJ};   (* p4,p4m on-axis bottom *)

sq[u_, c_] := (u - c) . (u - c);
Rfix = SetPrecision[26316907726198076/10^16, wp];  (* fix the scale at the record R; removes R as unknown *)
R = Rfix;
eqs = {
  (* INT A: S0,S1,p3  -- drop p3 eq (redundant surplus) *)
  sq[XiA, S0] == 1, sq[XiA, S1] == 1,
  (* INT B: S0,p2,p3 *)
  sq[XiB, S0] == 1, sq[XiB, p2] == 1, sq[XiB, p3] == 1,
  (* INT C: S1,S2,p1  -- drop p1 eq (redundant surplus) *)
  sq[XiC, S1] == 1, sq[XiC, S2] == 1,
  (* INT D: S1,p1,p3 *)
  sq[XiD, S1] == 1, sq[XiD, p1] == 1, sq[XiD, p3] == 1,
  (* INT E on-axis: S0,p4 *)
  sq[XiE, S0] == 1, sq[XiE, p4] == 1,
  (* BND F: S2,p1 on |x|=R *)
  sq[XbF, S2] == 1, sq[XbF, p1] == 1, XbF . XbF == R^2,
  (* BND G: p1,p3 *)
  sq[XbG, p1] == 1, sq[XbG, p3] == 1, XbG . XbG == R^2,
  (* BND H: p2,p3 *)
  sq[XbH, p2] == 1, sq[XbH, p3] == 1, XbH . XbH == R^2,
  (* BND I: p2,p4 *)
  sq[XbI, p2] == 1, sq[XbI, p4] == 1, XbI . XbI == R^2,
  (* BND J on-axis bottom: p4 *)
  sq[XbJ, p4] == 1, XbJ . XbJ == R^2
};

(* --- seed from the relabeled float optimum + its tight points --- *)
seed = {
  a -> -0.393246176, b -> 0.718386013, g -> 2.348820709,
  u1 -> 1.568569790, v1 -> 1.627191748,
  u2 -> 1.776631584, v2 -> -0.928909771,
  u3 -> 1.826451141, v3 -> 0.257211541,
  u4 -> 0.793616027, v4 -> -2.009172889,
  R -> 2.6316907726,
  xA -> 0.8306, yA -> 0.1660, xB -> 0.9975, yB -> -0.3021,
  xC -> 0.5727, yC -> 1.5360, xD -> 0.9928, yD -> 0.8096,
  yE -> -1.3932,
  xF -> 0.9860, yF -> 2.4400, xG -> 2.4022, yG -> 1.0748,
  xH -> 2.6056, yH -> -0.3696, xI -> 1.7904, yI -> -1.9288,
  yJ -> -2.6317
};
unk = seed[[All, 1]];
Print["#eqs = ", Length[eqs], "   #unknowns = ", Length[unk]];

sol = Quiet@FindRoot[eqs, Transpose[{unk, seed[[All, 2]]}],
   WorkingPrecision -> wp, MaxIterations -> 400, AccuracyGoal -> wp - 5, PrecisionGoal -> wp - 5];

paramVals = {a, b, g, u1, v1, u2, v2, u3, v3, u4, v4} /. sol;
Rval = R /. sol;
Print["solved R = ", InputForm[N[Rval, 30]]];

centers = {{0, a}, {0, b}, {0, g}, {u1, v1}, {-u1, v1}, {u2, v2}, {-u2, v2},
   {u3, v3}, {-u3, v3}, {u4, v4}, {-u4, v4}} /. sol;

(* verify: covering radius at this R should be exactly 1 *)
rho = CoveringRadius[centers, Rval, WorkingPrecision -> wp];
Print["CoveringRadius(c,R) = ", InputForm[N[rho, 30]], "   (want 1)"];
resid = Max[Abs[(Subtract @@@ eqs) /. sol]];
Print["max |eq residual| = ", InputForm[N[resid, 5]]];

dec[x_] := StringReplace[ToString[N[x, 40], InputForm, NumberMarks -> False], "*^" -> "e"];
out = <|"R" -> dec[Rval], "rho_at_R" -> dec[rho], "max_residual" -> dec[resid],
   "centers" -> Map[dec, centers, {2}], "params" -> Map[dec, paramVals]|>;
Export["!cat", out, "RawJSON", "Compact" -> True];
