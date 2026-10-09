#!/usr/bin/env wolframscript
(* Generic high-precision KKT solve for "max R s.t. n unit disks cover D(0,R)" on a FIXED
   active set (from prep.py).  POLYNOMIAL formulation (each active candidate carries its
   own point variable p_t, so every equation is quadratic):
     T (i,j,k): |p-c_i|^2 = |p-c_j|^2 = |p-c_k|^2 = 1          (triple point)
     B (i,j)  : |p|^2 = R^2, |p-c_i|^2 = |p-c_j|^2 = 1          (boundary point)
   KKT:  g = 0,  grad_{z,p} (R - mu.g) = 0,  plus rotation gauge cross(c1_0, c1) = 0.
   Gauss-Newton with LeastSquares steps (tolerates redundant / degenerate active sets).
   Then an INDEPENDENT check: MaxCoveredRadius at wp must reproduce R (nothing missed).
   usage: wolframscript -file kkt.wls in.json out.json [wp=60] </dev/null *)

root = ParentDirectory[ParentDirectory[DirectoryName[ExpandFileName[$InputFileName]]]];
Get[FileNameJoin[{root, "wl", "CirCovCir.wl"}]];
args = Rest[$ScriptCommandLine];
{in, out} = args[[1 ;; 2]];
wp = If[Length[args] >= 3, ToExpression[args[[3]]], 60];
wq = 2 wp + 20;

num[s_String] := Rationalize[ToExpression[StringReplace[s, {"e" -> "*^", "E" -> "*^"}]], 0];
num[x_?NumericQ] := Rationalize[x, 0];
js = Import[in, "RawJSON"];
n = js["n"]; c0 = Map[num, js["centers"], {2}]; R0 = num[js["R"]];
act = js["active"]; m = Length[act];

zv = Array[z, 2 n + 1]; cen[i_] := zv[[2 i - 1 ;; 2 i]]; RR = zv[[-1]];
pv = Array[p, {m, 2}];
cross[a_, b_] := a[[1]] b[[2]] - a[[2]] b[[1]];
sq[v_] := v.v;
g = Flatten@Table[With[{t = act[[q]], P = pv[[q]]},
     If[t["type"] == "T", sq[P - cen[#]] - 1 & /@ t["idx"],
      Join[{sq[P] - RR^2}, sq[P - cen[#]] - 1 & /@ t["idx"]]]], {q, m}];
mv = Array[mu, Length[g]];
xv = Join[zv, Flatten[pv]];
gauge = cross[c0[[1]], cen[1]];
F = Join[g, D[RR - mv.g, {xv}], {gauge}];
uv = Join[xv, mv];
J = D[F, {uv}];
sv = Table[Symbol["vv" <> ToString[k]], {k, Length[uv]}];
Ff = Function @@ {sv, F /. Thread[uv -> sv]}; Jf = Function @@ {sv, J /. Thread[uv -> sv]};
ap[f_, u_] := f @@ u;

(* initial point: float centers, float candidate points, least-squares multipliers *)
x0 = Join[Flatten[c0], {R0}, Flatten[Map[num, act[[All, "p"]], {2}]]];
G0 = N[D[g, {xv}] /. Thread[xv -> x0], 30];
mu0 = LeastSquares[Transpose[G0], UnitVector[Length[xv], 2 n + 1]];
u = SetPrecision[Join[x0, mu0], wq];
res[u_] := Max[Abs[ap[Ff, u]]];
Print["n=", n, " m=", m, " eqs=", Length[F], " unk=", Length[uv], " |F0|=", N[res[u], 3]];
Do[
  u = SetPrecision[u - LeastSquares[ap[Jf, u], ap[Ff, u]], wq];
  Print["  it ", it, " |F|=", N[res[u], 3]];
  If[res[u] < 10^-(wp + 5), Break[]], {it, 40}];

zs = u[[1 ;; 2 n + 1]]; ms = u[[Length[xv] + 1 ;;]];
cs = Partition[Most[zs], 2]; Rk = Last[zs];
rankJ = MatrixRank[N[ap[Jf, u], wp], Tolerance -> 10^-(wp/2)];
(* one multiplier per active candidate: lambda_t = multiplier of the R-dependent / first eq;
   report the sign of the R-gradient contribution instead: dL/dR uses only B eqs *)
Rmax = MaxCoveredRadius[cs, WorkingPrecision -> wp];
dec[x_, d_] := StringReplace[ToString[N[x, d], InputForm, NumberMarks -> False], "*^" -> "e"];
Print["R_kkt   = ", N[Rk, wp]];
Print["R_cover = ", N[Rmax, wp], "   diff = ", N[Rmax - Rk, 3]];
Print["rank J = ", rankJ, " / ", Length[uv]];
Export[out, <|"n" -> n, "R" -> dec[Rk, wp], "centers" -> Map[dec[#, wp] &, cs, {2}],
   "mu" -> (dec[#, 20] & /@ ms), "R_cover_wp" -> dec[Rmax, wp], "wp" -> wp,
   "residual" -> dec[res[u], 5], "rankJ" -> rankJ, "nU" -> Length[uv],
   "m" -> m, "active" -> act|>, "RawJSON"];
