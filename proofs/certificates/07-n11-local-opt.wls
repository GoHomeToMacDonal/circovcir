#!/usr/bin/env wolframscript
(* 07-n11-local-opt.wls -- self-contained; re-run: wolframscript -file proofs/certificates/07-n11-local-opt.wls ; expect exit 0.
   Embedded data = approximate KKT point from experiments/2026-10-08-n11-kkt/run.wls (any nearby point is admissible).
   n=11: interval (Krawczyk) certificate that the Melissen configuration is a strict local
   maximum (mod rotation) of the coverable radius.  All enclosures use Mathematica Interval
   arithmetic on 100-digit bigfloats (outward rounding); final definiteness test is exact
   rational.  Steps:
   K1  Krawczyk: unique zero u_star of the symmetric 22x22 KKT system F(u)=0 in box X.
   K2  every multiplier interval lambda_t > 0 (strict complementarity).
   K3  SOSC via Finsler: H_L - rho B^T B negative definite on all of X, B = [G ; e_gauge].
   K4  local-equivalence margins: each active tight point x_t keeps the 8 non-generators at
       distance > 1, interior ones lie inside D(0,R), boundary ones are on the outward branch.
   K5  coverage of z_star: every finite-candidate point (methods.md) is either one of the 18 active
       ones (f = 1 exactly, by F(u_star)=0 + K4) or certified f < 1 / outside K. => rho(c_star,R_star)=1. *)

here = DirectoryName[ExpandFileName[$InputFileName]];
ip = 100;                                  (* interval working precision *)
rad = 10^-45;                              (* Krawczyk box radius *)
ok = <||>;

js = <|"R" -> "2.631690772619808205521501159505696105167116847823853445969749",
  "centers" -> {{"0", "-0.3932496017925002708635378870188585597148384006557298789320946"},
    {"0", "0.7183922793168587759691262844044318355475831452396019248041889"},
    {"0", "2.348841200975659537285727839271986587928833666553898573930836"},
    {"1.575352640043428065802449496337887161298862911092924554982755", "1.620625886426919128381784381608080980742336716062781971424765"},
    {"-1.575352640043428065802449496337887161298862911092924554982755", "1.620625886426919128381784381608080980742336716062781971424765"},
    {"1.772736162809740931177046015998214109212326186477577487596963", "-0.9363223991029024464318732156284408335803267749070746950471178"},
    {"-1.772736162809740931177046015998214109212326186477577487596963", "-0.9363223991029024464318732156284408335803267749070746950471178"},
    {"1.827509552952129939636798208010455137158416369370672494617501", "0.2495804850428392243071515184626584069205006824579677449932997"},
    {"-1.827509552952129939636798208010455137158416369370672494617501", "0.2495804850428392243071515184626584069205006824579677449932997"},
    {"0.7852170824682634676403880931417250144222803359426211372316482", "-2.012470187206154238192519523262277332440977624239791662450922"},
    {"-0.7852170824682634676403880931417250144222803359426211372316482", "-2.012470187206154238192519523262277332440977624239791662450922"}},
  "lambda" -> <|"A" -> "0.038199292134613654316986049596371638181139", "A'" -> "0.038199292134613654316986049596371638181139", "B" -> "0.16713165234526830863419534376097062609608", "B'" -> "0.16713165234526830863419534376097062609608", "C" -> "0.013019895240547427071221088241436135174514", "C'" -> "0.013019895240547427071221088241436135174514", "D" -> "0.040261139386120925259422269398164584524185", "D'" -> "0.040261139386120925259422269398164584524185", "E" -> "0.068298856783088065953955195337686462885521", "F" -> "0.014037982755703957208566163648025883503112", "F'" -> "0.014037982755703957208566163648025883503112", "G" -> "0.029441349306237969408043430251911650182347", "G'" -> "0.029441349306237969408043430251911650182347", "H" -> "0.024681052807444056600730263015663272586225", "H'" -> "0.024681052807444056600730263015663272586225", "I" -> "0.020808319769022077190428682971193135339662", "I'" -> "0.020808319769022077190428682971193135339662", "J" -> "0.012054517283103224045593723294458723931666"|>|>;
cS = Map[Rationalize[ToExpression[#], 0] &, js["centers"], {2}];
RS = Rationalize[ToExpression[js["R"]], 0];
lamS = Rationalize[ToExpression[#], 0] & /@ js["lambda"];

zv = Array[z, 23]; cen[i_] := {zv[[2 i - 1]], zv[[2 i]]}; RR = zv[[23]];
cross[a_, b_] := a[[1]] b[[2]] - a[[2]] b[[1]];
ccenter[i_, j_, k_] := Module[{a = cen[i], b = cen[j], c = cen[k], d},
   d = 2 cross[b - a, c - a];
   a + {(c - a)[[2]] ((b - a).(b - a)) - (b - a)[[2]] ((c - a).(c - a)),
        (b - a)[[1]] ((c - a).(c - a)) - (c - a)[[1]] ((b - a).(b - a))}/d];
hInt[i_, j_, k_] := Module[{a = cen[j] - cen[i], b = cen[k] - cen[i]},
   (a.a) (b.b) ((a - b).(a - b))/(4 cross[a, b]^2) - 1];
wperp[i_, j_] := Module[{d = cen[j] - cen[i]}, {-d[[2]], d[[1]]}];
yOut[i_, j_, s_] := Module[{w = wperp[i, j]}, (cen[i] + cen[j])/2 + s Sqrt[1/(w.w) - 1/4] w];
z0 = Append[Flatten[cS], RS]; rule0 = Thread[zv -> z0];
sgn[i_, j_] := If[(#.# &[yOut[i, j, 1] /. rule0]) > (#.# &[yOut[i, j, -1] /. rule0]), 1, -1];
act = {{"A", {1, 2, 8}}, {"A'", {1, 2, 9}}, {"B", {1, 6, 8}}, {"B'", {1, 7, 9}},
   {"C", {2, 3, 4}}, {"C'", {2, 3, 5}}, {"D", {2, 4, 8}}, {"D'", {2, 5, 9}}, {"E", {1, 10, 11}},
   {"F", {3, 4}}, {"F'", {3, 5}}, {"G", {4, 8}}, {"G'", {5, 9}}, {"H", {6, 8}}, {"H'", {7, 9}},
   {"I", {6, 10}}, {"I'", {7, 11}}, {"J", {10, 11}}};
names = act[[All, 1]];
h = If[Length[#[[2]]] == 3, hInt @@ #[[2]],
      Module[{y = yOut[#[[2, 1]], #[[2, 2]], sgn @@ #[[2]]]}, RR^2 - y.y]] & /@ act;

(* symmetric KKT system *)
q = {qa, qb, qg, qu1, qv1, qu2, qv2, qu3, qv3, qu4, qv4};
symz = {0, qa, 0, qb, 0, qg, qu1, qv1, -qu1, qv1, qu2, qv2, -qu2, qv2,
   qu3, qv3, -qu3, qv3, qu4, qv4, -qu4, qv4, qR};
reps = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J"};
lv = Array[l, 10];
tie = (First@First@Position[reps, StringDelete[#, "'"]]) & /@ names;
lamFull = lv[[tie]];
symRule = Thread[zv -> symz];
uvars = Join[q, {qR}, lv];
Fsys = Join[Pick[h, StringFreeQ[#, "'"] & /@ names] /. symRule,
   D[(RR - lamFull.h) /. symRule, {Append[q, qR]}]];
Jsys = D[Fsys, {uvars}];
ut = Join[{cS[[1, 2]], cS[[2, 2]], cS[[3, 2]], cS[[4, 1]], cS[[4, 2]], cS[[6, 1]], cS[[6, 2]],
    cS[[8, 1]], cS[[8, 2]], cS[[10, 1]], cS[[10, 2]], RS}, lamS /@ reps];   (* exact rationals *)

(* refine the approximate point by Newton at high precision (any u~ is admissible) *)
Do[Module[{u = N[ut, 150]}, ut = Rationalize[u - LinearSolve[Jsys /. Thread[uvars -> u],
      Fsys /. Thread[uvars -> u]], 10^-140]], {3}];
Print["|F(u~)| (float) = ", ScientificForm[N[Max[Abs[Fsys /. Thread[uvars -> N[ut, 150]]]], 3]]];
eps = 10^-(ip - 10);
iv[x_] := Interval[{N[x, ip] - eps, N[x, ip] + eps}];   (* encloses the exact number x *)
X = Interval[{N[# - rad, ip], N[# + rad, ip]}] & /@ ut;
FX = Fsys /. Thread[uvars -> (iv /@ ut)];           (* rigorous enclosure of F(u~) *)
JX = Jsys /. Thread[uvars -> X];
Y = Rationalize[Inverse[N[Jsys /. Thread[uvars -> ut], 60]], 10^-50];   (* exact rational approx. inverse *)
Kx = (iv /@ ut) - Y.FX + (IdentityMatrix[22] - Y.JX).(X - (iv /@ ut));
inside[a_, b_] := Min[a] > Min[b] && Max[a] < Max[b];
ok["K1_krawczyk"] = And @@ MapThread[inside, {Kx, X}];
Print["K1 Krawczyk K(X) in int X: ", ok["K1_krawczyk"],
  "   max width K/X = ", ScientificForm[N[Max[(Max[#] - Min[#]) & /@ Kx]/(2 rad), 3]]];
XK = MapThread[IntervalIntersection, {Kx, X}];      (* tighter enclosure of u_star *)
lamX = XK[[13 ;; 22]];
ok["K2_lambda_pos"] = And @@ (Min[#] > 0 &) /@ lamX;
Print["K2 all lambda > 0: ", ok["K2_lambda_pos"], "   min lower = ",
  N[Min[Min /@ lamX], 8]];

(* full-coordinate enclosures *)
zX = symz /. Thread[uvars -> XK];
lamFX = (lv /. Thread[lv -> lamX])[[tie]];
fullRule = Thread[zv -> zX];

(* K3: Finsler with gauge row e5 (x-coordinate of top centre S2) *)
GX = D[h, {zv}] /. fullRule;
HX = D[RR - lamFX.h, {zv, 2}] /. fullRule;
B = Append[GX, UnitVector[23, 5]];
rhoF = 1;
MX = -(HX - rhoF Transpose[B].B);                   (* want positive definite *)
mid = Map[Rationalize[(Min[#] + Max[#])/2, 0] &, MX, {2}];
mid = (mid + Transpose[mid])/2;
radM = Map[(Max[#] - Min[#]) &, MX, {2}];
(* |M_true - mid|_ij <= max entry width (+ rationalisation error << 1e-80), so
   ||M_true - mid||_2 <= ||.||_F <= 23 * dmax <= dF *)
dmax = Max[Flatten[radM]];
dF = 10^-30;
ok["K3_width"] = 23 dmax + 10^-80 < dF;
ev = Eigenvalues[N[mid, 30]];
ok["K3_sosc"] = PositiveDefiniteMatrixQ[mid - dF IdentityMatrix[23]] &&
   And @@ Table[Det[(mid - dF IdentityMatrix[23])[[;; k, ;; k]]] > 0, {k, 23}];   (* exact Sylvester *)
Print["K3 SOSC (Finsler rho=", rhoF, "): ", ok["K3_sosc"], "   lambda_min(mid) = ",
  N[Min[ev], 8], "   max entry width = ", ScientificForm[N[dmax, 3]], "  (bound dF=1e-30 valid: ", ok["K3_width"], ")"];

(* K4: margins at active tight points *)
pt[t_] := Module[{g = act[[t, 2]]}, If[Length[g] == 3, ccenter @@ g,
    yOut[g[[1]], g[[2]], sgn @@ g]]];
dist2[p_, i_] := (p - cen[i]).(p - cen[i]);
marg = Table[Module[{g = act[[t, 2]], p, others, c1, c2},
    p = pt[t] /. fullRule; others = Complement[Range[11], g];
    c1 = Min[Min /@ ((dist2[p, #] /. fullRule) & /@ others)] - 1;      (* want > 0 *)
    c2 = If[Length[g] == 3, Min[(RR^2 - p.p) /. fullRule],            (* inside K *)
      Min[(sgn @@ g) (p.wperp @@ g) /. fullRule]];                   (* outward branch *)
    {act[[t, 1]], c1, c2}], {t, 18}];
ok["K4_margins"] = And @@ ((#[[2]] > 0 && #[[3]] > 0) & /@ marg);
Print["K4 margins: ", ok["K4_margins"], "   min other-centre margin = ",
  N[Min[marg[[All, 2]]], 6], "   min geometric margin = ", N[Min[marg[[All, 3]]], 6]];

(* K5: full finite candidate set at the enclosed z_star *)
cX = Table[cen[i] /. fullRule, {i, 11}]; RX = RR /. fullRule;
fUpper[p_] := Min[Max[(p - #).(p - #)] & /@ cX];
actTri = Sort /@ Select[act[[All, 2]], Length[#] == 3 &];
actPair = Sort /@ Select[act[[All, 2]], Length[#] == 2 &];
bad = {}; nAct = 0; nSkip = 0; nStrict = 0;
nColl = 0;
Do[Module[{p},
   If[Simplify[(cross[cen[tr[[2]]] - cen[tr[[1]]], cen[tr[[3]]] - cen[tr[[1]]]] /. symRule)] === 0,
    nColl++; Continue[]];                           (* exactly collinear (S0,S1,S2): no circumcentre *)
   p = ccenter @@ tr /. fullRule;
   Which[MemberQ[actTri, tr], nAct++,
    Min[p.p - RX^2] > 0, nSkip++,
    fUpper[p] < 1, nStrict++,
    True, AppendTo[bad, {"T", tr}]]], {tr, Subsets[Range[11], {3}]}];
(* On-axis candidates, exact by mirror symmetry of z_star (x-coords of S0,S1,S2 are exactly 0 and
   mirror pairs (4,5),(6,7),(8,9),(10,11) are exact reflections): the bisector of a mirror pair is
   the y-axis, so its two hits are exactly (0,+R_star) and (0,-R_star); the antipode of an on-axis centre
   (0,t) is (0,-R_star sign t).  (0,-R_star) is exactly the active boundary point J (on the axis, |J|=R_star),
   whose value f=1 is certified by F(u_star)=0 + K4.  (0,+R_star) is certified f<1 directly. *)
mirror = {{4, 5}, {6, 7}, {8, 9}, {10, 11}};
top = {0, RX}; nCoin = 0;
If[fUpper[top] < 1, nStrict += 3, AppendTo[bad, {"axis-top", {}}]];   (* 3 pair top hits, same point *)
nCoin += 3;                                         (* pairs 4-5,6-7,8-9 bottom hits = J *)
Do[If[Min[cX[[i, 2]]] > 0, nCoin++,                 (* antipode of S1,S2 = J *)
    If[Max[cX[[i, 2]]] < 0, If[fUpper[top] < 1, nStrict++, AppendTo[bad, {"A", i}]],
     AppendTo[bad, {"A-sign", i}]]], {i, 1, 3}];
Do[Module[{i = pr[[1]], j = pr[[2]], m, w, A2, B1, C0, disc, pts, yA},
   If[MemberQ[Most[mirror], pr], Continue[]];       (* handled exactly above *)
   m = (cen[i] + cen[j])/2 /. fullRule; w = wperp[i, j] /. fullRule;
   A2 = w.w; B1 = 2 m.w; C0 = m.m - RX^2; disc = B1^2 - 4 A2 C0;
   Which[Max[disc] < 0, nSkip += 2,
    Min[disc] <= 0, AppendTo[bad, {"B-disc", pr}],
    True,
    pts = (m + ((-B1 + # Sqrt[disc])/(2 A2)) w) & /@ {1, -1};
    yA = If[MemberQ[actPair, pr], yOut[i, j, sgn[i, j]] /. fullRule, None];
    Do[Which[
      yA =!= None && Max[Abs[Max[#] - Min[#]] & /@ (p - yA)] < 10^-30 &&
        Max[Abs /@ (Max /@ (p - yA))] < 10^-30, nAct++,
      fUpper[p] < 1, nStrict++,
      True, AppendTo[bad, {"B", pr}]], {p, pts}]]], {pr, Subsets[Range[11], {2}]}];
Do[Module[{p = -RX cX[[i]]/Sqrt[cX[[i]].cX[[i]]]},
   If[fUpper[p] < 1, nStrict++, AppendTo[bad, {"A", i}]]], {i, 4, 11}];
nTot = nAct + nStrict + nSkip + nCoin + nColl;
Print["K5 accounted ", nTot, " of ", 165 + 2*55 + 11, " candidates (", nColl, " exactly collinear triple)"];
ok["K5_coverage"] = (bad === {}) && nAct == 18 && nTot == 165 + 2*55 + 11;
Print["K5 candidates: active=", nAct, " strict(f<1)=", nStrict, " outside=", nSkip, " coincide-with-J=", nCoin,
  " unresolved=", bad, "  => ", ok["K5_coverage"]];

Print["R* in ", InputForm[N[XK[[12]], 50]]];
Print["ALL: ", ok];
(* Consumer certificates may set $N11CertificateNoExit=True before Get to reuse
   the checked enclosure. Failure always exits nonzero; standalone behavior is unchanged. *)
If[And @@ Values[ok],
 Print["n=11 local-optimality certificate OK"];
 If[!TrueQ[$N11CertificateNoExit], Exit[0]], Exit[1]];
