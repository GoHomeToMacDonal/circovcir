#!/usr/bin/env wolframscript
(* Diagnose rigidity: build the full tight-contact system F(params, R, tightpts)=0 and
   compute the Jacobian rank at the float seed. If #indep eqs = #unknowns the cover is
   rigid (isolated, exact FindRoot exists); if short by k, the record cover has k internal
   DOF -> no exact square contact system without added criticality conditions. *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];

S0 = {0, a}; S1 = {0, b}; S2 = {0, g};
p1 = {u1, v1}; p2 = {u2, v2}; p3 = {u3, v3}; p4 = {u4, v4};
sq[u_, c_] := (u - c) . (u - c);
XiA={xA,yA};XiB={xB,yB};XiC={xC,yC};XiD={xD,yD};XiE={0,yE};
XbF={xF,yF};XbG={xG,yG};XbH={xH,yH};XbI={xI,yI};XbJ={0,yJ};

F = {
  sq[XiA,S0]-1, sq[XiA,S1]-1, sq[XiA,p3]-1,
  sq[XiB,S0]-1, sq[XiB,p2]-1, sq[XiB,p3]-1,
  sq[XiC,S1]-1, sq[XiC,S2]-1, sq[XiC,p1]-1,
  sq[XiD,S1]-1, sq[XiD,p1]-1, sq[XiD,p3]-1,
  sq[XiE,S0]-1, sq[XiE,p4]-1,
  sq[XbF,S2]-1, sq[XbF,p1]-1, XbF.XbF-R^2,
  sq[XbG,p1]-1, sq[XbG,p3]-1, XbG.XbG-R^2,
  sq[XbH,p2]-1, sq[XbH,p3]-1, XbH.XbH-R^2,
  sq[XbI,p2]-1, sq[XbI,p4]-1, XbI.XbI-R^2,
  sq[XbJ,p4]-1, XbJ.XbJ-R^2
};
unk = {a,b,g,u1,v1,u2,v2,u3,v3,u4,v4,R,
   xA,yA,xB,yB,xC,yC,xD,yD,yE,xF,yF,xG,yG,xH,yH,xI,yI,yJ};
seed = {-0.393246176,0.718386013,2.348820709,
   1.568569790,1.627191748,1.776631584,-0.928909771,
   1.826451141,0.257211541,0.793616027,-2.009172889, 2.6316907726,
   0.8306,0.1660,0.9975,-0.3021,0.5727,1.5360,0.9928,0.8096,-1.3932,
   0.9860,2.4400,2.4022,1.0748,2.6056,-0.3696,1.7904,-1.9288,-2.6317};
rule = Thread[unk -> seed];
J = D[F, {unk}] /. rule;
Print["F length (eqs)   = ", Length[F]];
Print["unknowns         = ", Length[unk]];
Print["Jacobian rank    = ", MatrixRank[N[J, 30], Tolerance -> 10^-6]];
Print["=> DOF (unknowns - rank) = ", Length[unk] - MatrixRank[N[J, 30], Tolerance -> 10^-6]];
Print["residual |F| at seed = ", InputForm[N[Max[Abs[F /. rule]], 4]]];
