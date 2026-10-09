w = 1 + 2 Cos[2 Pi/9];
(* CORRECT branch (signs -1,-1,-1), reproduces FT 2.02349/2.357538 *)
cx = w Cos[th/4]^2 - Cos[th/4] Sqrt[1 - w^2 Sin[th/4]^2];
cy = w Sin[th/4] Cos[th/4] - Sin[th/4] Sqrt[1 - w^2 Sin[th/4]^2];
h  = cx - Sqrt[1 - cy^2];
hp = D[h, th]; hpp = D[h, {th, 2}];
arg0 = Pi - 4 ArcSin[1/w];
psimin = 2 Pi - 2 ArcSin[2/w] - 6 ArcSin[1/w];
ximin  = 2 Pi - 2 ArcSin[2/w] - 4 ArcSin[1/w];
Print["=== h cross-check ==="];
Print["h(arg0)   = ", N[h/.th->arg0, 20]];
d3 = 2 (h/.th->arg0) Sin[psimin/2];
d4 = 2 (h/.th->arg0) Sin[ximin/2];
Print["|pp+3| = ", N[d3,15], "  FT 2.02349   >2? ", TrueQ[d3>2]];
Print["|pp+4| = ", N[d4,15], "  FT 2.357538  >2? ", TrueQ[d4>2]];

Print["=== interval monotone + convex on (0, 4 asin(1/r10)) ==="];
wN = SetPrecision[w,80]; dom = 4 ArcSin[1/wN];
arg1 = 1 - w^2 Sin[th/4]^2;
arg2 = 1 - cy^2;
sub = {w->wN};
evalIV[e_,iv_]:= e /. sub /. th->iv;
lo0=SetPrecision[10^-5,80]; hi0=dom-SetPrecision[10^-7,80]; maxDepth=45;
Module[{stack={{lo0,hi0,0}}, nLeaf=0, wHp=Infinity, wHpp=Infinity, wArg=Infinity, deep=0},
 While[stack=!={},
  Module[{t=First[stack],a,b,dep,iv,l1,l2,lhp,lhpp},
   stack=Rest[stack]; {a,b,dep}=t; iv=Interval[{a,b}];
   l1=Min[evalIV[arg1,iv]]; l2=Min[evalIV[arg2,iv]];
   lhp=Min[evalIV[hp,iv]]; lhpp=Min[evalIV[hpp,iv]];
   If[TrueQ[l1>0]&&TrueQ[l2>0]&&TrueQ[lhp>0]&&TrueQ[lhpp>0],
    nLeaf++; wHp=Min[wHp,lhp]; wHpp=Min[wHpp,lhpp]; wArg=Min[wArg,l1,l2],
    If[dep>=maxDepth, deep++,
     Module[{m=(a+b)/2}, stack=Join[{{a,m,dep+1},{m,b,dep+1}},stack]]]]]];
 Print["closed leaves=",nLeaf,"  deep-hit=",deep];
 Print["min lower(h')  = ",N[wHp,12], "   h'>0 proven: ", TrueQ[wHp>0]&&deep==0];
 Print["min lower(h'') = ",N[wHpp,12],"   h''>0 proven: ", TrueQ[wHpp>0]&&deep==0];
 Print["min lower(sqrt args) = ",N[wArg,12]];
]
