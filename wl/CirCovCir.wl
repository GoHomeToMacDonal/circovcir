(* ::Package:: *)
(* CirCovCir` -- n unit disks covering the largest disk D(0,R).

   Core fact (see docs/methods.md): for centers c_1..c_n, the covering radius
       rho(c, R) = max_{x in D(0,R)} min_i |x - c_i|
   is attained at one of finitely many CANDIDATE points:
     (T) circumcenters of center triples lying in D(0,R)   [interior Voronoi vertices]
     (B) intersections of pair bisectors with the circle |x| = R
     (A) antipodal boundary points -R c_i/|c_i|  (plus {R,0} for c_i = 0)
   D(0,R) is covered by the unit disks  <=>  rho(c, R) <= 1.
   rho is nondecreasing in R, so R_max(c) = sup{R : rho(c,R) <= 1} by bisection.

   Load:  Get["wl/CirCovCir.wl"]  (from the repo root)
*)

BeginPackage["CirCovCir`"];

CandidatePoints::usage =
  "CandidatePoints[centers, R] returns the finite candidate set (T, B, A) in D(0,R) on which \
the covering radius is attained. Works for exact or approximate input.";
CoveringRadius::usage =
  "CoveringRadius[centers, R, opts] = max over D(0,R) of the distance to the nearest center. \
Option WorkingPrecision (default MachinePrecision).";
MaxCoveredRadius::usage =
  "MaxCoveredRadius[centers, opts] = largest R with D(0,R) covered by unit disks at centers. \
Option WorkingPrecision (default 30).";
ExactCoverQ::usage =
  "ExactCoverQ[centers, R] decides with exact arithmetic (numeric screening + RootReduce on \
near-ties) whether unit disks at the exact centers cover D(0,R).";
TightPoints::usage =
  "TightPoints[centers, R, tol] lists {point, nearestIndices} for candidates whose nearest \
distance is within tol of 1 -- the active constraints of a (locally) optimal cover.";
CoverPlot::usage = "CoverPlot[centers, R] draws the unit disks and the target circle.";
IdentifyClosedForm::usage =
  "IdentifyClosedForm[x, maxDegree] tries RootApproximant on a high-precision real and \
returns <|\"root\", \"radicals\", \"residual\"|>.";
LoadConfig::usage =
  "LoadConfig[file] reads a data/configs JSON file; returns the association with \"Centers\" \
and \"RValue\" parsed (exact *_wl fields win over decimal strings).";
SaveConfig::usage = "SaveConfig[file, assoc] writes a config association as JSON.";
OptimizeCover::usage =
  "OptimizeCover[n, opts] baseline global search (NMinimize, DifferentialEvolution) for n \
centers minimising the covering radius of the unit disk. Returns <|\"R\", \"Centers\"|> \
scaled to unit disks.";

CoveredArc::usage =
  "CoveredArc[r, d] = angle of the arc of the circle |x| = r inside a unit disk whose center \
is at distance d from O: 2 ArcCos[(r^2+d^2-1)/(2 r d)] (clamped; 2Pi if r+d<=1, 0 if \
|r-d|>=1). Exact for exact input. Twin of circovcir.arcs.covered_arc.";
MaxCoveredArc::usage = "MaxCoveredArc[r] = 2 ArcSin[1/r] (r >= 1), the sup over d of CoveredArc[r, d].";
MaxCoveredArcTriple::usage =
  "MaxCoveredArcTriple[r] = 2 ArcSin[2/r] (r >= 2), an upper bound (sup) for the angle at O \
of the arc of the circle |x| = r covered by three unit disks that share a common point p. \
Proof: a common point p lies in all three disks, so every covered point x satisfies \
|x - p| <= |x - center| + |center - p| <= 1 + 1 = 2; the covered boundary points thus lie \
in the disk of radius 2 about p, whose chord on |x| = r has length <= 4, subtending a \
central angle <= 2 ArcSin[(4/2)/r] = 2 ArcSin[2/r]. Twin bound of MaxCoveredArc (single disk, \
chord <= 2 => 2 ArcSin[1/r]); see proofs/06 P1 (L-arc1/L-arc2).";
RingAlpha::usage =
  "RingAlpha[beta, R] = arc covered on |x| = R by the unit disk covering an arc beta of the \
unit circle (d = 2 Cos[beta/2]): cos(alpha/2) = (R^2-1+4Cos[beta/2]^2)/(4 R Cos[beta/2]).";
RingRadius::usage = "RingRadius[k] = 1 + 2 Cos[2Pi/k]: disk at O plus a regular ring of k disks.";
RingConfig::usage =
  "RingConfig[k] = exact centers {0,0} plus k points at distance 2 Cos[Pi/k] (n = k+1).";

Begin["`Private`"];

(* ---------- sign / comparison helpers (exact-safe) ---------- *)

exactQ[x_] := NumericQ[x] && Precision[x] === Infinity;

(* sign of x: exact via certified numerics, RootReduce only on near-zero *)
sgn[x_?exactQ] := Module[{v = Quiet[N[x, 40], {N::meprec}]},
  If[Abs[v] > 10^-30, Sign[v], Sign[RootReduce[x]]]];
sgn[x_] := Sign[x];

(* sqrt of a quantity known to be >= 0 up to rounding: never produce complex output *)
sqrtNN[x_?exactQ] := Sqrt[x];
sqrtNN[x_] := Sqrt[Max[x, 0]];

geq0[x_?exactQ] := sgn[x] >= 0;
geq0[x_] := x >= -10^(-Min[Precision[x], 30]/2);   (* tolerant for approximate input *)

zeroQ[x_?exactQ] := sgn[x] == 0;
zeroQ[x_] := Abs[x] < 10^(-Min[Precision[x], 30]/2);

(* ---------- candidate points ---------- *)

circumcenter[{a_, b_, c_}] := Module[{d},
  d = 2 (a[[1]] (b[[2]] - c[[2]]) + b[[1]] (c[[2]] - a[[2]]) + c[[1]] (a[[2]] - b[[2]]));
  If[zeroQ[d], Nothing,
   {(a . a (b[[2]] - c[[2]]) + b . b (c[[2]] - a[[2]]) + c . c (a[[2]] - b[[2]]))/d,
    (a . a (c[[1]] - b[[1]]) + b . b (a[[1]] - c[[1]]) + c . c (b[[1]] - a[[1]]))/d}]];

bisectorHits[{a_, b_}, R_] := Module[{v = b - a, l2, p, h2, u},
  l2 = v . v;
  If[zeroQ[l2], Return[{}, Module]];
  p = v (b . b - a . a)/(2 l2);          (* foot of the bisector on the line through 0 *)
  h2 = R^2 - p . p;
  If[! geq0[h2], Return[{}, Module]];
  u = {-v[[2]], v[[1]]}/Sqrt[l2];
  {p + sqrtNN[h2] u, p - sqrtNN[h2] u}];

antipodes[c_List, R_] := Join[
   If[zeroQ[# . #], Nothing, -R #/Sqrt[# . #]] & /@ c,
   {{R, 0}}];

CandidatePoints[c_List, R_] := Module[{tri, bis},
  tri = If[Length[c] >= 3, circumcenter /@ Subsets[c, {3}], {}];
  tri = Select[tri, geq0[R^2 - # . #] &];
  bis = Join @@ (bisectorHits[#, R] & /@ Subsets[c, {2}]);
  Join[tri, bis, antipodes[c, R]]];

(* ---------- covering radius ---------- *)

Options[CoveringRadius] = {WorkingPrecision -> MachinePrecision};
CoveringRadius[c_List, R_, OptionsPattern[]] := Module[{wp = OptionValue[WorkingPrecision], cc, rr},
  cc = N[c, wp]; rr = N[R, wp];
  Sqrt@Max[Min[Total[(# - Transpose[cc])^2]] & /@ CandidatePoints[cc, rr]]];

Options[MaxCoveredRadius] = {WorkingPrecision -> 30};
MaxCoveredRadius[c_List, OptionsPattern[]] := Module[
  {wp = OptionValue[WorkingPrecision], cm, lo, hi, mid, g, it = 0},
  cm = N[c];
  g[r_, p_] := CoveringRadius[c, r, WorkingPrecision -> p];
  If[g[0, MachinePrecision] > 1, Return[0]];
  lo = 0.; hi = Max[Norm /@ cm] + 1.;
  (* machine-precision bracket *)
  While[hi - lo > 10^-11 && it < 200, it++;
   mid = (lo + hi)/2; If[g[mid, MachinePrecision] <= 1, lo = mid, hi = mid]];
  If[wp <= MachinePrecision, Return[lo]];
  (* high-precision refinement on a validated bracket *)
  lo = SetPrecision[lo - 10^-9, wp]; hi = SetPrecision[hi + 10^-9, wp];
  If[lo < 0, lo = SetPrecision[0, wp]];
  (* machine bracket can be wrong when the configuration has a hole below machine resolution
     (e.g. an interior Voronoi vertex at distance 1+1e-16): then restart from 0 *)
  If[g[lo, wp] > 1, lo = SetPrecision[0, wp]];
  If[g[lo, wp] > 1, Return[lo]];
  it = 0;
  While[hi - lo > 10^(-wp + 3) && it < 10 wp, it++;
   mid = (lo + hi)/2; If[g[mid, wp] <= 1, lo = mid, hi = mid]];
  lo];

ExactCoverQ[c_List, R_] := AllTrue[CandidatePoints[c, R],
   Function[p, AnyTrue[c, geq0[1 - (p - #) . (p - #)] &]]];

TightPoints[c_List, R_, tol_ : 10^-8] := Module[{cc = N[c, 30], rr = N[R, 30]},
  Select[
   Function[p, Module[{d = Sqrt[Total[(p - Transpose[cc])^2]], m},
      m = Min[d]; {p, Flatten@Position[d, x_ /; Abs[x - m] < tol], m}]] /@
    CandidatePoints[cc, rr],
   Abs[#[[3]] - 1] < tol &][[All, ;; 2]]];

(* ---------- arcs (proofs/01-ring-symmetry.md) ---------- *)

CoveredArc[r_, d_] := Which[
   geq0[1 - (r + d)^2], 2 Pi,                 (* r + d <= 1: whole circle *)
   geq0[(r - d)^2 - 1], 0,                    (* |r - d| >= 1: disjoint *)
   True, 2 ArcCos[(r^2 + d^2 - 1)/(2 r d)]];

MaxCoveredArc[r_] := If[geq0[1 - r] && ! zeroQ[1 - r], 2 Pi, 2 ArcSin[1/r]];

(* Twin of MaxCoveredArc for three unit disks sharing a common point: the covered
   boundary points all lie within distance 2 of the common point (triangle ineq,
   each disk radius 1 and the common point in every disk), so the chord is <= 4 and
   the central angle at O is <= 2 ArcSin[2/r].  Intended domain r >= 2 (r_8, r_9 > 2),
   where 2/r <= 1 and the bound is a genuine angle in (0, Pi]. *)
MaxCoveredArcTriple[r_] := 2 ArcSin[2/r];

RingAlpha[beta_, R_] := CoveredArc[R, 2 Cos[beta/2]];

RingRadius[k_Integer] := 1 + 2 Cos[2 Pi/k];

RingConfig[k_Integer] := Join[{{0, 0}},
   Table[2 Cos[Pi/k] {Cos[2 Pi j/k], Sin[2 Pi j/k]}, {j, 0, k - 1}]];

(* ---------- presentation / identification ---------- *)

CoverPlot[c_List, R_, opts___] := Graphics[{
   {EdgeForm[{Thin, GrayLevel[.4]}], Opacity[.12], Hue[.6], Disk[#, 1] & /@ N[c]},
   {Red, Thick, Circle[{0, 0}, N[R]]},
   {Black, PointSize[Small], Point[N[c]]},
   MapIndexed[Text[Style[First[#2], 8], #1, {-1.5, -1.5}] &, N[c]]},
  opts, Axes -> False, PlotRange -> All, ImageSize -> 500];

IdentifyClosedForm[x_?NumericQ, deg_Integer : 4] := Module[{r},
  r = Quiet@RootApproximant[x, deg];
  <|"root" -> r, "radicals" -> Quiet@ToRadicals[r],
    "residual" -> N[Abs[N[r, Precision[x]] - x], 5]|>];

(* ---------- I/O (data/configs schema, see data/configs/README.md) ---------- *)

(* decimal string -> exact WL number carrying ALL digits of the string (never machine-truncated);
   accepts "1.5e-05" / "1.5E-05". Decimal strings are treated as exact values. *)
parseDecimal[s_String] := Module[{t = StringTrim[s], m, e, ip, fp},
  {m, e} = Replace[StringSplit[t, "e" | "E"], {{a_} :> {a, "0"}, {a_, b_} :> {a, b}}];
  {ip, fp} = Replace[StringSplit[m, ".", All], {{a_} :> {a, ""}, {a_, b_} :> {a, b}}];
  If[ip === "" || ip === "-" || ip === "+", ip = ip <> "0"];
  (* exact: integer digits / 10^(#fraction digits) * 10^exponent; sign carried by ip *)
  (If[StringStartsQ[ip, "-"], -1, 1] (FromDigits[StringDelete[ip, "-" | "+"] <> fp])/
     10^StringLength[fp]) 10^ToExpression[e]];
parseDecimal[x_?NumericQ] := x;

LoadConfig[file_String] := Module[{a = Import[file, "RawJSON"], cs, r},
  cs = If[KeyExistsQ[a, "centers_wl"], ToExpression[a["centers_wl"]],
    Map[parseDecimal, a["centers"], {2}]];
  r = If[KeyExistsQ[a, "R_wl"], ToExpression[a["R_wl"]], parseDecimal[a["R"]]];
  Join[a, <|"Centers" -> cs, "RValue" -> r|>]];

SaveConfig[file_String, a_Association] :=
  Export[file, KeyDrop[a, {"Centers", "RValue"}], "RawJSON", "Compact" -> False];

(* ---------- baseline optimizer ---------- *)

Options[OptimizeCover] = {MaxIterations -> 300, RandomSeeding -> 1};
OptimizeCover[n_Integer?Positive, OptionsPattern[]] := Module[{xs, ys, f, sol, cs, rho},
  xs = Array[Unique["x"] &, n]; ys = Array[Unique["y"] &, n];
  f[v__?NumericQ] := CoveringRadius[Partition[{v}, 2], 1.];
  sol = NMinimize[{f @@ Riffle[xs, ys], And @@ Thread[xs^2 + ys^2 <= 1]},
    Riffle[xs, ys], Method -> "DifferentialEvolution",
    MaxIterations -> OptionValue[MaxIterations], RandomSeeding -> OptionValue[RandomSeeding]];
  rho = First[sol]; cs = Transpose[{xs, ys}] /. Last[sol];
  <|"R" -> 1/rho, "Centers" -> cs/rho|>];

End[];
EndPackage[];
