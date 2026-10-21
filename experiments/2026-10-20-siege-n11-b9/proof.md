# Eleven unit disks, exactly nine meeting the boundary circle: proof that R < 2.6317

## Theorem

Let c_1, …, c_11 be points of the plane and R > 0 with D_R ⊆ D(c_1,1) ∪ … ∪ D(c_11,1), and suppose exactly nine of the eleven disks D(c_i,1) meet S_R. Then R < r_1 = 26317/10000.

## Status (read this first)

This is a proof by hand plus two finite computations. It relies on the following, and on nothing else.

- **(T10), the ten-disk result quoted in the problem's context paragraph.** It says: (i) when R > 2, at most ten of eleven unit disks covering D_R meet S_R; (ii) every covering of D_R by eleven unit disks in which exactly ten disks meet S_R has R < 2.63169. The problem states it as already proved, but it is not among F1–F6. It is used in exactly two places: Lemma R1 (to fix R = r_1) and Lemma A5 (an inner disk cannot cover the whole hole). Lemma A5 then feeds Lemma C1 (c_E ≠ c_F) and Corollary K1 (m ∉ {0, 9}).
- **The problem's facts F1 and F3**, used as stated. F2 is used only for terminology. F4, F5 and F6 are not used by the proof. F5 appears only in sanity tests of the programs.
- **Computation C1, `nb_check.py` (Part M §5, program text in Appendix 1).** It is used only for the finite step of the No-Bridge theorem (Part M). It is a floating-point interval program. Its soundness assumes IEEE-754 double arithmetic with correctly rounded + − × ÷ √, and libm `asin`, `acos`, `atan`, `sin`, `cos` accurate to within 10⁻¹² on the arguments used (it widens every libm value by 10⁻¹²; glibc is accurate to about 10⁻¹⁶). **This assumption is removed by certificate 22b (§13a):** an independent Mathematica re-implementation of the same finite check, written from the statements of Part M §4 rather than from the code, using arbitrary-precision (20-digit) outward-rounded intervals and exact rational decisions. 22b proves (FAR) and (NEAR-Y) infeasible on its own. With 22b, no IEEE or libm assumption remains in the proof; the trusted base of C1 becomes the correctness of Mathematica 14.3's bignum `Interval` functions and rational arithmetic.
- **Computation C2, the exact checker `wit_exact_m.py`, run for m = 1, …, 8 (§11, program texts in Appendices 2–4).** It uses only exact rational arithmetic: Python `Fraction`, `math.isqrt`, rigorous Taylor enclosures of sin and cos, and a Machin enclosure of π. Floats are used only to choose certificate data, and any choice is admissible. Every run printed `EXACT RESULT R=2.6317: ALL BOXES CERTIFIED`. Certificate 22c (§13a) is an independent Mathematica re-implementation of C2 (own tree, own dual multipliers, exact rational decisions); it also certifies every m = 1, …, 8.
- The logs of C1 and C2 are taken to be faithful records of executions of the program texts reproduced here. C2 was run three times for m = 5 and twice for each other m, on the same machine, with identical box counts. The programs were not run by a third party.

Apart from these items, every step is proved in full below. The program texts are given verbatim, so the computations can be re-run (see §11.4 and Appendix 1 for commands).

## Plan of the proof

Assume, for a contradiction, a covering of the claim's type with R ≥ r_1.

1. §1. Reduce to R = r_1 exactly, with all nine boundary centres on the "inner branch" R − 1 ≤ |c_k| ≤ √(R² − 1) (Lemmas R1, R2). Derive the angular order and the overlaps of the nine arcs (Lemma R3).
2. Parts A, B, D, E and M. Establish the structure of such a covering:
   - inner and outer corners of consecutive boundary disks (Part A);
   - bridges D_j ∩ D_{j+2} ≠ ∅ and their consequences (Part B, §1);
   - the gap–depth lemma (Part D) and geometry of nearly full chains (Part E);
   - the **No-Bridge theorem**: D_j ∩ D_{j+2} = ∅ for all j (Part M, hand proof plus computation C1).
3. Part B (§2). Under No-Bridge, the uncovered hole H is the Jordan domain bounded by nine arcs through the inner corners q_1, …, q_9, and H ⊂ conv{q_k}. Hence neither inner disk contains all nine corners.
4. Part O. The corners in the inner disk E ∋ 0 form a cyclic interval of indices, and the others lie in the second inner disk F.
5. Part N. Each of the two transition disks meets E ∩ F.
6. §9. Hence the configuration solves an explicit system Σ_m for some split label m ∈ {1, …, 8}.
7. Part W. A solution of Σ_m yields a feasible point of a convex second-order-cone system P_m(φ), for some vector φ of eight angles in an explicit polytope. Infeasibility of the relaxed system over an angle box is certified by an explicit dual inequality (Lemma D′).
8. §11. Computation C2 covers the whole angle polytope by boxes, for each m ∈ {1, …, 8}. Every box is either empty or certified infeasible in exact arithmetic. So Σ_m has no solution at R = r_1. Contradiction.

## Notation (used throughout)

- D(c) = D(c,1) is a closed unit disk, ∂D(c) its circle, and s(φ) = R(cos φ, sin φ).
- a = a(R) = arcsin(1/R) and d = d(R) = arcsin(2/R).
- δ = 9a − π and B = 12a − 2π + 2d (the "bridge budget").
- Numerical values at R = r_1 = 2.6317, checked independently by hand series and in double precision:
  - a = 0.3897774, 2a = 0.7795548 < π/2, π − 8a = 0.0233735, δ = 0.3664040;
  - d = 0.863259, B = 0.1206621;
  - √(R² − 1) = 2.4343058.
- Indices of boundary disks are taken mod 9.
- "Part A, B, D, E, M, O, N, W" are parts of **this** document. Lemma numbers inside a part are local to it; lemmas of Part E carry an "E" prefix.

## 1. Reductions, standing hypotheses, and the order of the arcs

A "covering of the claim's type" means: c_1, …, c_11 and R with D_R ⊆ ⋃ D(c_i,1), and exactly nine disks meeting S_R.

A unit disk D(c) meets S_ρ iff ρ − 1 ≤ |c| ≤ ρ + 1.

### Lemma R1 (fix R = r_1)
If a covering of the claim's type exists with some R ≥ r_1, then the same eleven centres form a covering of the claim's type with R = r_1.

*Proof.*
1. The same disks cover D_{r_1} ⊆ D_R.
2. Each unit disk meets S_{r_1} in an arc of measure ≤ 2a(r_1) (F1). Since 16a(r_1) = 6.23644 < 2π, eight arcs cannot cover S_{r_1}. But S_{r_1} ⊂ D_{r_1} is covered, so at least nine disks meet S_{r_1}.
3. At most ten meet S_{r_1}, by (T10)(i), since r_1 > 2.
4. If exactly ten met it, (T10)(ii) would give r_1 < 2.63169, which is false.

So exactly nine meet S_{r_1}. ∎

From now on, **R = r_1**. So F1 and F3 apply at R. The nine disks meeting S_R are the *boundary disks*; the other two are the *inner disks*.

### Lemma R2 (inner-branch normalisation)
Let D(c) be a boundary disk. Its arc on S_R has half-width w ∈ (0, a]. Here w > 0 by F3, since every arc has a private open sub-arc, and w ≤ a by F1. Write:
- u = c/|c|, m = R cos w, h = R sin w (≤ 1, since w ≤ a; if h = 1 then s = 0 and c′ = c), s = √(1 − h²);
- c′ := (m − s)u.

Then:
- (a) D(c′) ∩ S_R = D(c) ∩ S_R;
- (b) D(c) ∩ D_R ⊆ D(c′);
- (c) R − 1 ≤ m − s ≤ √(R² − 1).

Hence replacing every boundary centre by its partner c′ keeps the covering of D_R, the nine arcs, and the set of disks meeting S_R (the inner disks are untouched).

*Proof.* The arc endpoints P, Q are the points of S_R at angles ±w from u. Then |P − c| = 1 means R² + ρ² − 2Rρ cos w = 1 with ρ = |c|. This quadratic has roots m ± s, whose product is R² − 1. Both centres (m ± s)u are at distance 1 from P and Q, and they are mirror images of each other in the chord line ℓ = {x : ⟨x,u⟩ = m}.

(a) The arc of D((m ± s)u) on S_R is the set of angles φ with cos(φ − arg u) ≥ cos w, in both cases.

(c) Put f(ρ) = ρ² − 2Rρ cos w + R² − 1. Then f(R − 1) = 2R(R − 1)(1 − cos w) ≥ 0. Also R − 1 < √(R² − 1), the geometric mean of the roots, so R − 1 ≤ m − s ≤ √(R² − 1).

(b) Let x ∈ D(c) ∩ D_R. If c = c′ there is nothing to prove, so let c = (m + s)u.
- If ⟨x,u⟩ ≤ m, then x is on the side of ℓ containing c′. Since c′ is the reflection of c in ℓ, |x − c′| ≤ |x − c| ≤ 1.
- If ⟨x,u⟩ = m + t with t ≥ 0, write x = (m + t)u + yv with v ⊥ u. From |x|² ≤ R² = m² + h² we get y² ≤ h² − 2mt − t². Hence |x − c′|² = (s + t)² + y² ≤ s² + h² + 2t(s − m) = 1 − 2t(m − s) ≤ 1, since m − s ≥ R − 1 > 0. ∎

### Standing hypotheses (SH)
From now on we fix:
- R = r_1;
- c_1, …, c_11 with D_R ⊆ ⋃ D(c_i);
- exactly nine boundary disks, each with centre on the inner branch R − 1 ≤ |c| ≤ √(R² − 1).

By Lemmas R1 and R2, a covering of the claim's type with R ≥ r_1 yields such a configuration.

Further notation under (SH):
- **Boundary disks.** They are D_k = D(c_k), k ∈ ℤ_9, with circles C_k = ∂D_k. Write ρ_k = |c_k| and θ_k = arg c_k (c_k ≠ 0).
- **Arcs.** A_k = D_k ∩ S_R = [s_k, e_k] (start and end in counter-clockwise order), with half-width w_k. Put d_k = a − w_k ≥ 0 (the deficit) and let o_k be the angular measure of A_k ∩ A_{k+1}.
- **Numbering.** The boundary disks are numbered as in F3. If F3's cyclic numbering is clockwise, we first reflect the plane in a line through 0. Every hypothesis and every statement below is invariant under this reflection, so we may assume the numbering is counter-clockwise.
- **Inner disks.** The origin lies in no boundary disk, since |c_k| ≥ R − 1 > 1, so it lies in an inner disk. Call it E = D(c_E), so |c_E| ≤ 1. If both inner disks contain 0, choose either. Call the other inner disk F = D(c_F). Both inner disks miss S_R by definition.
- **Gaps.** g_k := θ_{k+1} − θ_k, for lifted angles as in Lemma R3.

### Lemma R3 (order and overlaps of the arcs)
Under (SH):
1. 0 < w_k ≤ a. For every φ, s(φ) ∈ D_k iff the angular distance from φ to θ_k is ≤ w_k. Moreover cos w_k = (R² + ρ_k² − 1)/(2Rρ_k).
2. The polar angles lift to θ_1 < θ_2 < … < θ_9 < θ_1 + 2π =: θ_10, and θ_{k+1} − θ_k ≤ w_k + w_{k+1} for k = 1, …, 9 (with w_10 := w_1).
3. 0 < g_k ≤ 2a, and Σ_k g_k = 2π. Also o_k = w_k + w_{k+1} − g_k ≥ 0, and A_k ∩ A_{k+1} is the lifted interval [θ_{k+1} − w_{k+1}, θ_k + w_k]. Consequently Σ_k 2w_k − Σ_k o_k = 2π, i.e. Σ d_k + ½ Σ o_k = δ. Also 2a − g_k = d_k + d_{k+1} + o_k.

*Proof.*

(1) We have |s(φ) − c_k|² = R² + ρ_k² − 2Rρ_k cos(φ − θ_k), so s(φ) ∈ D_k iff cos(φ − θ_k) ≥ (R² + ρ_k² − 1)/(2Rρ_k). The right-hand side lies in (0, 1], since (R − ρ_k)² ≤ 1. Call it cos w_k. By AM–GM, R² − 1 + ρ_k² ≥ 2ρ_k√(R² − 1), so cos w_k ≥ √(R² − 1)/R = cos a, i.e. w_k ≤ a. Finally w_k > 0 by F3.

(2) Put σ_k = θ_k − w_k and ε_k = θ_k + w_k (lifted start and end).
- Starts. By F3 the starts occur in counter-clockwise cyclic order, and they are distinct (equal starts would make one arc contain the other). Lift them to σ_1 < σ_2 < … < σ_9 < σ_1 + 2π =: σ_10.
- Ends, inside one turn. If ε_{k+1} ≤ ε_k for some k ≤ 8, then [σ_{k+1}, ε_{k+1}] ⊂ [σ_k, ε_k], so A_{k+1} ⊆ A_k, which F3 excludes. So ε_1 < … < ε_9.
- Ends, across the turn. If ε_9 ≥ ε_1 + 2π, then [σ_1 + 2π, ε_1 + 2π] ⊂ [σ_9, ε_9], i.e. A_1 ⊆ A_9, again excluded. So ε_9 < ε_1 + 2π.
- Midpoints. Hence the midpoints θ_k = (σ_k + ε_k)/2 satisfy θ_1 < … < θ_9 < θ_1 + 2π.
- Forward overlap. Suppose σ_{k+1} > ε_k for some k ∈ {1, …, 9}, and take φ ∈ (ε_k, σ_{k+1}). No 2π-translate of any lifted arc [σ_j, ε_j] contains φ:
  - for j ≤ k: ε_j ≤ ε_k < φ, and σ_j + 2π ≥ σ_10 ≥ σ_{k+1} > φ;
  - for k < j ≤ 9: σ_j ≥ σ_{k+1} > φ, and ε_j − 2π < ε_1 ≤ ε_k < φ.

  So s(φ) lies in no boundary arc. But s(φ) ∈ D_R is covered, and the inner disks miss S_R. Contradiction. Hence σ_{k+1} ≤ ε_k, i.e. θ_{k+1} − θ_k ≤ w_k + w_{k+1}.

(3) We have g_k > 0 by (2), and g_k ≤ w_k + w_{k+1} ≤ 2a. Also Σ g_k = θ_10 − θ_1 = 2π. The lifted intervals satisfy σ_k < σ_{k+1} ≤ ε_k < ε_{k+1}, so they meet in [σ_{k+1}, ε_k]. No other translates meet, because ε_{k+1} − σ_k ≤ 4a < 2π. So o_k = ε_k − σ_{k+1} = w_k + w_{k+1} − g_k. Summing over k gives Σ 2w_k − Σ o_k = 2π. The last identity is 2a − g_k = (a − w_k) + (a − w_{k+1}) + o_k. ∎

All the results below are proved under (SH). Every constant is evaluated at R = r_1.

## Part A — Inner and outer corners, the hole, and redundancy

Throughout this part (SH) holds. The words "free", "corner" and "hole" are defined here. Lemma A5 uses (T10).

Numerical values (hand-computed by series, checked independently; error < 2·10⁻⁷): a(r_1) = 0.3897774, δ(r_1) = 0.3664040, π − 8a(r_1) = 0.0233735, d(r_1) = 0.863259 (check: sin 0.863259 = 0.759965 = 2/r_1). Every load-bearing inequality below has a margin of at least 0.06, so this precision is ample.

### (a) The inner corners and the hole

**Lemma A0 (positive arcs, strict depth).** Every boundary disk has w_k > 0, so |c_k| > R − 1 and its circle C_k = ∂D_k meets S_R in exactly the two distinct points s_k ≠ e_k, transversally.

Proof. Suppose w_k = 0. Then A_k is a single point x. The other eight closed arcs cover S_R \ {x}, so by closedness they cover S_R. This contradicts F1 (eight arcs never cover S_R for R ≥ r_1). A unit circle and S_R (with R > 2) meet in at most two points. If they meet in exactly two, the crossings are transversal, because two distinct circles that are tangent meet in only one point. ∎

**Lemma A1 (third-disk principle).** Let z be a point of D_R lying on two distinct circles ∂D(c,1), ∂D(c',1) of the family, which cross at z (they meet in two points), and assume z ∈ int D_R. Then z lies in a third disk of the family.

Proof. Near a transversal crossing z, the complement of D(c,1) ∪ D(c',1) contains an open wedge with vertex z, namely the vertical angle of the lens. So there are points z_n → z with z_n ∉ D(c,1) ∪ D(c',1), and z_n ∈ D_R for n large because z is interior. Each z_n lies in one of the other nine disks. One of those disks contains infinitely many z_n, and since it is closed it contains z. ∎

**Lemma A2 (inner and outer corners).** For each k:
- |c_k − c_{k+1}| < 2, so C_k and C_{k+1} meet in exactly two points p_k ≠ q_k.
- One can label them so that |p_k| ≥ R > |q_k|.
- |p_k| = R holds exactly when o_k = 0, and then p_k = e_k = s_{k+1}.

Here q_k is the inner corner and p_k the outer corner.

Proof. By F3, A_k and A_{k+1} intersect, so D_k ∩ D_{k+1} ≠ ∅ and |c_k − c_{k+1}| ≤ 2. Let L = D_k ∩ D_{k+1}, which is a lens or a point.

Case o_k > 0. By F3 (no arc contains another, ends in cyclic order), A_k ∩ A_{k+1} = [s_{k+1}, e_k] is a nondegenerate arc. Moreover:
- e_k is not an endpoint of A_{k+1}, so e_k ∈ int D_{k+1}. Likewise s_{k+1} ∈ int D_k.
- s_k ∉ D_{k+1}, otherwise A_{k+1} ⊇ A_k or A_k ∪ A_{k+1} = S_R.
- Likewise e_{k+1} ∉ D_k.

So L is a genuine lens with corners p and q. Its boundary consists of two arcs: β ⊂ C_k (the part inside D_{k+1}) and β' ⊂ C_{k+1}. Since C_k ∩ S_R = {s_k, e_k} (Lemma A0) and s_k ∉ D_{k+1}, we get β ∩ S_R = {e_k}. Likewise β' ∩ S_R = {s_{k+1}}. Hence ∂L \ {e_k, s_{k+1}} has exactly two components, one containing each corner. Each component lies entirely in int D_R or entirely outside D_R.

C_k crosses S_R transversally at e_k, and near e_k the circle C_k lies in ∂L (because e_k ∈ int D_{k+1}). So ∂L has points on both sides of S_R near e_k. Therefore one component, say the one containing q, is in int D_R, and the other, containing p, is outside D_R. Then |q| < R < |p|.

Case o_k = 0. Then A_k ∩ A_{k+1} = [s_{k+1}, e_k] (Lemma R3(3)) is the single point x := e_k = s_{k+1}, so x ∈ D_k ∩ D_{k+1} = L and |x| = R. Since w_k, w_{k+1} > 0 (Lemma A0), A_k = [s_k, x] and A_{k+1} = [x, e_{k+1}] are nondegenerate arcs lying on the two sides of x on S_R, and s_k ≠ x ≠ e_{k+1}. Also s_k ∉ D_{k+1} (else s_k ∈ A_k ∩ A_{k+1} = {x}) and likewise e_{k+1} ∉ D_k.

Step 1 (D_k ∪ D_{k+1} is a neighbourhood of x in D_R). Suppose not. Then there are z_n ∈ D_R \ (D_k ∪ D_{k+1}) with z_n → x. Each z_n lies in one of the other nine disks, so one of them, D′, contains infinitely many z_n; D′ is closed, so x ∈ D′. Then D′ meets S_R, so it is a boundary disk D_j with j ∉ {k, k+1}, and x lies in the three arcs A_j, A_k, A_{k+1}, which F3 forbids. So there is r_0 > 0 with D_R ∩ D(x, r_0) ⊆ D_k ∪ D_{k+1}.

Step 2 (L ∩ D_R contains points other than x, arbitrarily close to x). Let 0 < r ≤ r_0 with r < |s_k − x| and r < |e_{k+1} − x|. Put K := D_R ∩ D(x, r) and N := K \ {x}.
- N is connected. K is convex with non-empty interior, and x ∈ ∂K because |x| = R. Fix y ∈ int K. For z ∈ K the points of the segment [y, z) lie in int K, hence differ from x. So for z ∈ N the whole segment [y, z] lies in N, and N is star-shaped about y.
- N = (N ∩ D_k) ∪ (N ∩ D_{k+1}) by Step 1, and both sets are closed in N.
- Both sets are non-empty: the points of A_k (resp. A_{k+1}) at distance in (0, r) from x lie in N ∩ D_k (resp. N ∩ D_{k+1}).

Since N is connected, the two sets meet: there is y ∈ L ∩ D_R with 0 < |y − x| < r. In particular L ≠ {x}. So |c_k − c_{k+1}| < 2, and L is a lens whose two corners are x and a second point q ≠ x.

Step 3 (|q| < R). The set ∂L \ {x} is connected (a simple closed curve minus one point). It does not meet S_R: indeed ∂L ⊂ C_k ∪ C_{k+1}, C_k ∩ S_R = {s_k, x}, C_{k+1} ∩ S_R = {x, e_{k+1}} (Lemma A0), and s_k, e_{k+1} ∉ L. Hence ∂L \ {x} lies entirely in int D_R or entirely in ℝ² \ D_R. Suppose the latter. The function z ↦ |z|² is strictly convex, so it has a unique minimiser z_0 on the compact convex set L. The point z_0 is not in int L, since an interior minimiser would be a critical point, i.e. z_0 = 0, and 0 ∉ D_k (|c_k| > 1). So z_0 ∈ ∂L. Every point of ∂L \ {x} has modulus > R = |x|, so z_0 = x and min_L |z| = R. But then every y ∈ L ∩ D_R has |y| ≤ R = min_L |z|, so y is a minimiser and y = x. Thus L ∩ D_R = {x}, contradicting Step 2. Therefore ∂L \ {x} ⊂ int D_R. In particular |q| < R, and p := x has |p| = R. ∎

**Corollary A3.** Every inner corner q_k lies in int D_R and in a third disk D_j, j ∉ {k, k+1}: either an inner disk or a third boundary disk (Lemma A1 applied to C_k, C_{k+1} at q_k). Call q_k *free* if it lies in no third boundary disk. A free corner lies in E ∪ F.

**Lemma A4 (which corners can lie in a third boundary disk).** If q_k ∈ D_j for a boundary index j ∉ {k, k+1}, then j ∈ {k−1, k+2}. Let T be the corresponding triple, {k−1,k,k+1} or {k,k+1,k+2}. Then:
1. the arc I := A_{T} (the union of the three consecutive arcs) has |I| ≤ 2d(R), and so Σ_{m∉T} 2d_m + (the five overlaps internal to the chain of the other six arcs) ≤ 12a − 2π + 2d. At r_1 this equals B = 0.1206621…, so Σ_{m∉T} d_m ≤ B/2 ≤ 0.0604.
2. |q_k| satisfies (R² + |q_k|² − 4)/(2R|q_k|) ≤ cos(π − 6a(R)). At R = r_1 this means 1.1832 ≤ |q_k| ≤ 2.4728 (4-decimal hand evaluation; not load-bearing).
3. Take two such triples T, T' coming from two corners lying in third boundary disks. Then T ∩ T' ≠ ∅. Consequently all triple corners have their triples inside a window of 5 consecutive indices.

Proof. D_k, D_{k+1}, D_j share the point q_k, so they lie in D(q_k, 2). By F1, the set S_R ∩ D(q_k,2) =: J is a single arc with |J| ≤ 2d. J contains the connected arc A_k ∪ A_{k+1} and also A_j. Being connected, it contains one of the two stretches of S_R between them.

Suppose j ∉ {k−1, k+2}. Then either stretch, together with A_k ∪ A_{k+1} ∪ A_j, contains at least 4 consecutive whole arcs. The complement S_R \ J is covered by the remaining ≤ 5 arcs, so |J| ≥ 2π − 10a. But 2π − 10a(r_1) = 2.38541 > 1.72652 = 2d(r_1), a contradiction. For R > r_1, a and d both decrease, so the left side grows and the right side shrinks; the inequality persists.

So j ∈ {k−1, k+2}. The long stretch would contain all nine arcs, giving J = S_R, which is impossible. Hence J ⊇ I.

(1): the other six arcs form a chain covering S_R \ J, so their union has length ≥ 2π − 2d. Its length is 12a − Σ_{m∉T} 2d_m − (internal overlaps). That gives the inequality, and 12a(r_1) − 2π + 2d(r_1) = 4.677329 − 6.283185 + 1.726518 = 0.120662. (The quantity 12a − 2π + 2d decreases in R.)

(2): |J| ≥ |I| ≥ 2π − 12a. The arc of D(p,2) on S_R has half-angle β with cos β = (R² + |p|² − 4)/(2R|p|) when this is in [−1,1]. Requiring β ≥ π − 6a gives the quadratic |p|² − 2R cos(π−6a)|p| + R² − 4 ≤ 0. At r_1: cos(0.802928) = 0.694603, so the roots are (3.655974 ± 1.289483)/2.

(3): if T ∩ T' = ∅, the two triple-unions have total length ≤ 4d, and the remaining three arcs have length ≤ 6a. But 4d + 6a = 3.453037 + 2.338664 = 5.791702 < 2π (margin 0.49, and both terms decrease in R), so S_R would not be covered, a contradiction. Consecutive triples in Z_9 that pairwise intersect have starting indices pairwise within cyclic distance ≤ 2, so all starts lie in {t, t+1, t+2}. ∎

**The boundary of the hole.** Put U = D_R ∩ ⋃_{k=1}^9 D_k and H = D_R \ U (open in D_R). Since U ⊇ S_R:
- H ⊂ int D_R.
- ∂H ⊂ ⋃_k (C_k ∩ int D_R).
- Every point of ∂H lies in E ∪ F (closedness).

Along the arc C_k ∩ D_R from s_k to e_k, the points of D_{k−1} form an initial segment from s_k to q_{k−1}, and the points of D_{k+1} form a final segment from q_k to e_k. (These sets are C_k ∩ D_{k−1} ∩ D_R = the lens edge from the outer side to q_{k−1}, and similarly for k+1. In detail: C_k ∩ D_{k−1} is the arc of C_k from p_{k−1} to q_{k−1} (an edge of the lens L_{k−1} of Lemma A2). It contains s_k, because s_k ∈ A_{k−1} ∩ A_k. It meets S_R only at s_k, because C_k ∩ S_R = {s_k, e_k} (Lemma A0) and e_k ∉ D_{k−1}: by Lemma R3(3), A_{k−1} ∩ A_k is the arc [s_k, e_{k−1}], which does not contain e_k since the ends occur in strictly increasing order. Since p_{k−1} ∉ int D_R and q_{k−1} ∈ int D_R, its part in D_R is the sub-arc from s_k to q_{k−1}.)

These two segments are disjoint unless q_{k−1} ∈ D_{k+1} or q_k ∈ D_{k−1}, that is, unless a corner lies in a third boundary disk (Lemma A4). When both corners are free, let γ_k be the sub-arc of C_k from q_{k−1} to q_k. Then ∂H ∩ C_k ⊂ γ_k. If no point of any γ_k lies in a non-neighbouring boundary disk, then ∂H = Γ := γ_1 ∪ … ∪ γ_9, a closed curve through q_1, …, q_9 in this order, and H is the region it bounds.

The inclusion ∂H ∩ C_k ⊂ γ_k is immediate from the above. The equality ∂H = Γ and the Jordan property are proved in Part B, Theorem J, under the No-Bridge property (NB) established in Part M.

**Lemma A5 (redundancy).** H ⊄ E and H ⊄ F. In particular F ⊂ int D_R and E ⊂ int D_R, and H ≠ ∅.

Proof. Suppose H ⊂ E. Translate F so that its centre lies on S_R. The covering persists, E still misses S_R (|c_E| ≤ 1 < R − 1), and now exactly ten disks meet S_R. The already-proved ten-disk case (cited in the problem's context) gives R < 2.63169 < r_1, a contradiction.

Suppose H ⊂ F. The same argument works with E moved, after relabelling: the moved disk meets S_R and F misses S_R, so again exactly ten disks meet S_R.

Since F meets H ⊂ D_R, F is connected and misses S_R; hence F ⊂ int D_R. Also H ≠ ∅, because H = ∅ is the case H ⊂ E. ∎

**Lemma C1 (the split is by a line).** If c_E = c_F, then E = F and H ⊂ E, which contradicts Lemma A5. So c_E ≠ c_F. Let ℓ be the perpendicular bisector of [c_E, c_F], P_E = {z : |z − c_E| ≤ |z − c_F|} and P_F the other closed half-plane. Then:
1. (E ∪ F) ∩ P_E ⊂ E and (E ∪ F) ∩ P_F ⊂ F. Hence H ∩ P_E ⊂ E and H ∩ P_F ⊂ F, and every point of H ∩ ℓ lies in E ∩ F, i.e. in the common chord σ of E and F.
2. Every free inner corner q_k in the open half-plane int P_E lies in E (and similarly for F). A free corner on ℓ lies in E ∩ F.
3. Suppose |c_E − c_F| < 2. Then the two points ∂E ∩ ∂F lie in int D_R (Lemma A5), and each lies in some boundary disk (Lemma A1; no other disk is available).

Proof. (1) If z ∈ F and |z − c_E| ≤ |z − c_F| ≤ 1, then z ∈ E.

(2) A free corner q_k is not in any boundary disk other than D_k, D_{k+1}. These are closed, so all points of the wedge of Lemma A1 close enough to q_k lie in H. If q_k ∈ int P_E, those hole points lie in P_E, hence in E, and so does q_k (E is closed). If q_k ∈ ℓ, then q_k ∈ E ∪ F (Corollary A3), and by (1) it lies in both.

(3) is Lemma A1. ∎

## Part B — Bridges

### 1. Bridges

**Lemma N1.** Let j ≠ l be boundary indices with D_j ∩ D_l ≠ ∅ and l ∉ {j−1, j+1}. Then
l ∈ {j−2, j+2}.

Proof. Let x ∈ D_j ∩ D_l. Both disks lie in D(x,2), so (F1) J := S_R ∩ D(x,2) is one arc with
|J| ≤ 2d. J is connected and contains A_j and A_l, so it contains one of the two arcs of S_R from A_j
to A_l, and with it (start and end points are in the same cyclic order, F3) every A_i with i in the
corresponding cyclic index interval [j..l] or [l..j]. If that interval has n indices, the remaining
9 − n arcs cover S_R \ J, so 2π − |J| ≤ 2a(9 − n). If the cyclic distance between j and l is ≥ 3,
then n ≥ 4 for both intervals, so |J| ≥ 2π − 10a. At r_1, 2π − 10a = 6.283185 − 3.897774 = 2.385411
> 1.726518 = 2d(r_1). Contradiction (and the gap only widens for larger R). ∎

**Lemma N2 (bridge budget).** If (k, k+2) is a bridge, then J ⊇ A_k ∪ A_{k+1} ∪ A_{k+2}, and the six
"other" disks k+3, …, k+8 satisfy

  2(d_{k+3} + … + d_{k+8}) + (o_{k+3} + … + o_{k+7}) ≤ B := 12a − 2π + 2d,  B(r_1) = 0.120662.

Proof. As in N1, J contains the arcs of one of the index intervals [k..k+2] (3 indices) or
[k+2..k] (8 indices). In the second case 2π − |J| ≤ 2a, i.e. |J| ≥ 2π − 2a > 2d. So J ⊇ A_k ∪
A_{k+1} ∪ A_{k+2}, and the six other arcs cover S_R \ J, which has length ≥ 2π − 2d. These six
arcs are consecutive; only consecutive arcs meet and no point is triply covered (F3), so the length
of their union is Σ 2w − (five internal overlaps) = 12a − 2Σd − Σo. ∎
(This is A4(1) of Part A, which only needs a common point of D_k and D_{k+2}.)

**Lemma N3.** Two bridges (k, k+2), (k', k'+2) have intersecting index triples
{k,k+1,k+2} ∩ {k',k'+1,k'+2} ≠ ∅. So all bridge starts lie in a window {t_0, t_0+1, t_0+2}.

Proof. Otherwise the two J-arcs (total ≤ 4d) and the remaining three arcs (≤ 6a) cover S_R, but
4d + 6a = 3.453037 + 2.338664 = 5.791702 < 2π at r_1. ∎

**Lemma N4 (what bridges control).**
(a) If an inner corner q_k lies in a third boundary disk D_j, then (k−1, k+1) or (k, k+2) is a
bridge (j = k−1, resp. j = k+2).
(b) Let γ_k denote the sub-arc of C_k ∩ D_R between q_{k−1} and q_k (defined when both are free,
see Part B §2). If some point of C_k ∩ D_R lies in a boundary disk D_j with j ∉ {k−1, k, k+1}, then
(k−2, k) or (k, k+2) is a bridge.
(c) Hence, if no bridge exists, every inner corner is free and the separation property
(G′) holds: D_k ∩ D_j = ∅ whenever j ∉ {k−1, k, k+1}.

Proof. (a) q_k ∈ D_j ∩ D_k ∩ D_{k+1}, so by N1 j is at index distance ≤ 2 from both k and k+1, and
j ∉ {k, k+1}: j ∈ {k−1, k+2}. Then D_{k−1} ∩ D_{k+1} ∋ q_k, respectively D_k ∩ D_{k+2} ∋ q_k.
(b) D_k ∩ D_j ≠ ∅ with j not adjacent to k, so N1 gives j = k ± 2. (c) is (a) + (b). ∎

So **freeness of all corners and (G′) are both implied by (NB)** := "D_j ∩ D_{j+2} = ∅ for all j". Also, by N3, if there are bridges, the non-free corners
are among q_{t_0}, …, q_{t_1+1} (t_0 ≤ t_1 ≤ t_0 + 2 the extreme bridge starts), so at least
7 − (t_1 − t_0) ≥ 5 cyclically consecutive corners q_{t_1+2}, …, q_{t_0+8} are free.



### Lemma S (used in Part M)

**Lemma S (angular capacity of a unit disk).** Let |z| = t > 1 and z ∈ D(c, 1). Then the angle between
z and c (seen from 0) is at most σ(t) := arcsin(1/t). If moreover |c| ≤ 1 and t ≥ √2, it is at most
σ_E(t) := arccos(t/2) (≤ σ(t)).

Proof. Since |z| = t > 1, z ∉ D(0,1), so c ≠ 0. With φ ∈ [0, π] the angle and x = |c| > 0:
1 ≥ |z − c|² = t² + x² − 2tx cos φ, so cos φ ≥ (t² − 1 + x²)/(2tx) ≥ √(t² − 1)/t (AM–GM), i.e.
φ ≤ arcsin(1/t) (the right-hand side is positive, so φ < π/2). For fixed t the function
x ↦ (t² − 1 + x²)/(2tx) has derivative (x² − t² + 1)/(2tx²) and so decreases on (0, √(t²−1)]. If
t ≥ √2 and x ≤ 1 ≤ √(t²−1), its minimum over (0, 1] is its value t/2 at x = 1, so cos φ ≥ t/2 and
φ ≤ arccos(t/2). Finally arccos(t/2) ≤ arcsin(1/t), because cos(arcsin(1/t)) = √(t²−1)/t ≤ t/2 is
equivalent to 4(t² − 1) ≤ t⁴, i.e. (t² − 2)² ≥ 0. (Only the first bound, φ ≤ arcsin(1/t), is used
later.) ∎

## Part D — The gap–depth lemma

**Budget per corner.** Since g_k = w_k + w_{k+1} − o_k and d_k = a − w_k,

  2a − g_k = d_k + d_{k+1} + o_k ≥ 0,  and  Σ_k (2a − g_k) = 18a − 2π = 2δ = 0.732808 (at r_1).

So the deficit budget is the same thing as the gaps falling short of 2a. Call κ_k := 2a − g_k the *cost* of corner q_k.

**Lemma G (gap–depth).** Let R > 2 and let D(c,1), D(c',1) be unit disks whose circles meet in two points q, p, with |q| = t < R ≤ |p|. Let g ∈ (0, π/2) be the angle ∠c0c'. Then

  tan g ≤ √(4 − (R−t)²)·(R+t) / (R² + t² − 2),

equivalently g ≤ g_sym(t) := 2·arctan( √(4 − (R−t)²) / (R+t) ). Equality holds iff 0, q, p are collinear and |p| = R (the symmetric configuration).

Proof. c and c' are the two intersection points of the unit circles about q and p. Put N = (p+q)/2, ℓ = |p−q|/2 ∈ (0,1), e = (p−q)/(2ℓ), and v = √(1−ℓ²)·ie, so that c, c' = N ± v. Write P = |p|².

For the angle subtended at 0 by the segment [N−v, N+v], put w = −N. The vectors from 0 to the two points are −w + v and −w − v. Their cross product has modulus 2|w×v| = 2√(1−ℓ²)·X, where X = |⟨N, e⟩|, and their dot product is |N|² − (1−ℓ²). Hence

  tan g = 2√(1−ℓ²)X / (|N|² − 1 + ℓ²)  whenever g < π/2.

Now P − t² = |N+ℓe|² − |N−ℓe|² = 4ℓ⟨N,e⟩, so X = (P − t²)/(4ℓ). Also |N|² = (P + t²)/2 − ℓ² (parallelogram law), which gives |N|² − 1 + ℓ² = (P + t² − 2)/2 > 0. Therefore

  tan g = (√(1−ℓ²)/ℓ) · (P − t²)/(P + t² − 2).

The first factor decreases in ℓ. By the triangle inequality 2ℓ = |p − q| ≥ √P − t, so with s := √P ≥ R,

  tan g ≤ f(s) := √(4 − (s−t)²)·(s+t)/(s² + t² − 2).

Its logarithmic derivative is −(s−t)/(4 − (s−t)²) + 1/(s+t) − 2s/(s²+t²−2). The first term is < 0. The sum of the other two is < 0, because s² + t² − 2 < 2s(s+t). So f decreases for s > t, and tan g ≤ f(R).

The closed form follows from tan(2 arctan z) = 2z/(1−z²) with z = √(4−(R−t)²)/(R+t). Indeed (R+t)² − 4 + (R−t)² = 2(R² + t² − 2), which gives 2z/(1−z²) = f(R). Equality needs 2ℓ = √P − t (so q lies on the segment 0p) and s = R. ∎

**Remarks.**
- In a covering the hypotheses hold for every consecutive pair (k, k+1): q = q_k, p = p_k with |p_k| ≥ R (Lemma A2), and 0 < g_k ≤ 2a < π/2 (Lemma R3(3)). So **g_k ≤ g_sym(|q_k|) and κ_k ≥ C(|q_k|) := 2a − g_sym(|q_k|)**. The lemma needs no condition on ρ_k.
- g_sym(t) increases on [R−2, R − 2/R]. For h = z², the sign of h′ is the sign of 2R(R−t) − 4. At r_1 the maximum is at t* = R − 2/R = 1.871735. There (R − t*)² = 4/R², so z² = (4 − 4/R²)/(2R − 2/R)² = 1/(R² − 1), i.e. z = tan a, and g_sym(t*) = 2a exactly. So C is decreasing on [R−2, R − 2/R] ⊃ [R−2, 1.8717], and C(t) ≥ C(t*) = 0 there, with equality only at t = t*. Only the monotonicity is used below.
- Values at R = r_1 (hand series for arctan, error < 10⁻⁴):

| t | 0.8 | 0.9 | 1.0 | 1.1 | 1.2 | 1.3 | 1.4 | 1.5 | 1.7 |
|---|---|---|---|---|---|---|---|---|---|
| g_sym(t) | 0.4597 | 0.5522 | 0.6166 | 0.6638 | 0.6990 | 0.7255 | 0.7452 | 0.7595 | 0.7757 |
| C(t) = 2a − g_sym | 0.3198 | 0.2274 | 0.1630 | 0.1158 | 0.0806 | 0.0541 | 0.0344 | 0.0201 | 0.0038 |

## Part E — Inner disks near the origin, and geometry of a nearly full chain

The notation A(t,u), α(u) introduced here is also used in Part M. §3 of this part assumes that a bridge exists; it is used only inside the proof by contradiction of Part M.

### 2. The inner disks must cover D(0, R−2)

**Lemma E2.1.** D(0, ρ_0) ⊆ E ∪ F, where ρ_0 := R − 2 = 0.6317.

Proof. Every boundary centre has |c| ≥ R − 1 (SH). If |z| < R − 2 then |z − c| ≥ |c| − |z| > 1, so z is
in no boundary disk, hence in E ∪ F. Closedness gives the closed disk. ∎

Notation. For t, u > 0 put
  A(t,u) := the angle at 0 of a triangle with sides |0P| = t, |0C| = u, |PC| = 1, i.e.
  A(t,u) = arccos((t² + u² − 1)/(2tu)) when |t − u| ≤ 1 ≤ t + u, A(t,u) = π when t + u ≤ 1,
  and A(t,u) = −∞ ("impossible") when |t − u| > 1.
Then a point of polar coordinates (t, φ) lies in the unit disk with centre (u, θ) iff
|φ − θ| ≤ A(t,u) (angles mod 2π, |·| the angular distance in [0, π]). In particular the half-width of the
arc that a disk with centre at distance ρ cuts on S_R is w(ρ) = A(R, ρ).

**Lemma E2.2 (coupling of the inner disks).** Write u_E = |c_E|, u_F = |c_F| and let Δ ∈ [0, π] be the
angle between c_E and c_F (seen from 0). Put α(u) := A(ρ_0, u). Then either min(u_E, u_F) ≤ 1 − ρ_0
= 0.3683 (that disk alone contains D(0, ρ_0)), or

  α(u_E) + α(u_F) ≥ 2π − Δ ≥ π.        (E2.1)

In every case min(u_E, u_F) ≤ u* := sqrt(1 − ρ_0²) = 0.775213 (rounded up 0.77522).

Proof. Each disk meets S_{ρ_0} in a closed arc centred at the direction of its centre, of half-width
α(u) (all of S_{ρ_0} if u ≤ 1 − ρ_0). By Lemma E2.1 the two arcs cover S_{ρ_0}. The complement of the
first arc is an open arc of half-width π − α(u_E) centred at the antipode of c_E; it must lie in the
second arc, whose centre is at angular distance π − Δ from that antipode; so
α(u_F) ≥ π − α(u_E) + (π − Δ). For the last claim: if u > u* then (ρ_0² + u² − 1) > 0, so α(u) < π/2,
and two closed arcs of length < π cannot cover a circle. ∎
(ρ_0² = 0.39904489, 1 − ρ_0² = 0.60095511, sqrt = 0.7752129.)

Call an inner disk with |centre| ≤ u* a *near* disk; by Lemma E2.2 at least one exists, and its reach
is ≤ 1 + u* = 1.77522: it contains no point z with |z| > 1.77522.

### 3. Geometry of the good chain (under the assumption that a bridge exists)

Fix a bridge (k, k+2). The six disks k+3, …, k+8 are called *good* for this bridge. By N2,
2(d_{k+3}+…+d_{k+8}) + (o_{k+3}+…+o_{k+7}) ≤ B.

**Lemma E3.1 (depth and gaps of good disks).** For good j: d_j ≤ B/2, hence ρ_j := |c_j| ≥ ρ_lo :=
1.9656 (rounded down; exact value at w = a − B/2 is 1.965663). For consecutive good j, j+1:
g_j = θ_{j+1} − θ_j ≥ 2a − B = 0.6588926…, and g_j ≤ 2a.

Proof. d_j ≤ B/2 is immediate. w = A(R, ρ) is increasing in ρ on [R−1, sqrt(R²−1)] and ≥ a − B/2
forces ρ ≥ R cos w − sqrt(1 − R² sin² w) at w = a − B/2 = 0.3294464 (sin w = 0.3235192,
cos w = 0.9462216, R cos w = 2.4901714, sqrt(1 − R² sin² w) = sqrt(0.2751088) = 0.5245082); on the outer
branch ρ ≥ sqrt(R²−1) is larger anyway. Next 2a − g_j = d_j + d_{j+1} + o_j ≤ 2d_j + 2d_{j+1} + o_j ≤ B
(identity: o_j = w_j + w_{j+1} − g_j, Lemma R3(3)). ∎

**Lemma E3.2 (sector lemma for corners).** For consecutive good j, j+1 the inner corner q_j lies in the
open angular sector between the rays of c_j and c_{j+1}. Consequently, with t_j := |q_j|,

  arg q_j = θ_j + A(t_j, ρ_j) = θ_{j+1} − A(t_j, ρ_{j+1}),   g_j = A(t_j, ρ_j) + A(t_j, ρ_{j+1}),   (E3.1)

and for three consecutive good disks j−1, j, j+1 the angular separation of q_{j−1} and q_j is

  σ_j := arg q_j − arg q_{j−1} = A(t_{j−1}, ρ_j) + A(t_j, ρ_j).                              (E3.2)

Proof. The distance from c_{j+1} to the line through 0 and c_j is ρ_{j+1} sin g_j ≥ ρ_lo sin(2a−B)
= 1.9656 · 0.6122416 = 1.2034 > 1 (g_j ∈ [2a−B, 2a] ⊂ (0, π/2)). So D_{j+1} lies strictly on the
counter-clockwise side of that line; likewise D_j lies strictly on the clockwise side of the line
through 0 and c_{j+1}; and D_j lies in the half-plane {Re(z e^{−iθ_j}) ≥ ρ_j − 1 > 0}. The intersection
of the three regions is the open sector between the two rays, and it contains q_j ∈ D_j ∩ D_{j+1}. The
angle at 0 between q_j and c_j is A(t_j, ρ_j) by the law of cosines (|q_j − c_j| = 1), and since q_j is
counter-clockwise of c_j within the sector, arg q_j = θ_j + A(t_j, ρ_j); similarly for c_{j+1}. (E3.2)
follows by subtracting. ∎

**Corollary E3.3 (cost identity).** For consecutive good j, j+1 define the *cost* κ_j := 2a − g_j
= d_j + d_{j+1} + o_j. Then
  κ_j = 2a − A(t_j, ρ_j) − A(t_j, ρ_{j+1}) ≥ 0,   κ_j ≥ d(ρ_j) + d(ρ_{j+1}),   (E3.3)
where d(ρ) = a − A(R, ρ), and
  Σ_{j=k+3}^{k+7} κ_j + d_{k+3} + d_{k+8} = 2Σ_{good} d + Σ_{internal} o ≤ B.            (E3.4)
(κ_j ≥ d_j + d_{j+1} is o_j ≥ 0.) Hence for every set K of good inner corners,
Σ_{j∈K} K(t_j) ≤ B, where K(t) := inf over ρ, ρ' ∈ [ρ_lo, R] of
max(2a − A(t,ρ) − A(t,ρ'), d(ρ) + d(ρ')).

Remark. In the symmetric zero-overlap case ρ_j = ρ_{j+1} = ρ the corner radius is t = (ρ² − 1)/R
(power of 0 with respect to C_j: the ray through q_j meets C_j at q_j and at p_j ∈ S_R), and κ = 2d(ρ).
For full disks t = R − 2/R = 1.871735.

## Part M — The No-Bridge theorem

A *bridge* is a pair (j, j+2) with D_j ∩ D_{j+2} ≠ ∅.

**Theorem NB.** Under (SH), D_j ∩ D_{j+2} = ∅ for every j ∈ ℤ_9.

The proof is by contradiction. Assume a bridge (k, k+2) exists.
- §§1–4 (by hand) reduce this to two explicit finite systems of inequalities, (FAR) and (NEAR-Y), in 4 + 4 variables plus a budget split.
- §5 shows both systems are infeasible, by the interval computation C1.

The proof uses Parts A, B §1 (Lemmas N1–N4 and Lemma S), D (Lemma G) and E. Repairs M1–M4, written after §4, are part of the proof.
Notation (as in Part E): A(t,u) = arccos((t² + u² − 1)/(2tu)) is the angle at 0 between a point
at radius t and a unit-disk centre at radius u when the point is on the circle; a point (t, φ)
lies in the unit disk centred at (u, φ_X) iff the angular distance |φ − φ_X| ≤ A(t,u) (A := π if
t + u ≤ 1, and the point is in no such disk if |t − u| > 1). α(u) := A(R − 2, u).
Constants at R = r_1: a = 0.3897774, 2a = 0.7795548, B = 0.120662, ρ_0 = R − 2 = 0.6317.

### 1. Set-up for a bridge

Assume a bridge (k, k+2) exists. Good disks G_i := D_{k+2+i}, i = 1..6, centres (ρ_i, θ_i);
good corners Q_i := q_{k+2+i} = inner corner of G_i, G_{i+1}, i = 1..5, polar (t_i, φ_i);
cost κ_i := 2a − g_i = d(G_i) + d(G_{i+1}) + o(G_i,G_{i+1}) ≥ 0, and by N2 (and (E3.4) of Part E)

  κ_1 + … + κ_5 ≤ 2Σ_{i=1}^6 d(G_i) + Σ o_internal − d(G_1) − d(G_6) ≤ B.          (1.1)

**Lemma 1.2 (which good corners are free). PROVED.** Q_2, Q_3, Q_4 are always free. Q_1 is free
unless (k+2, k+4) is a bridge; Q_5 is free unless (k+7, k) is a bridge. Consequently, if the
set S of bridge starts is not exactly of the form {t, t+2}, the bridge (k, k+2) can be chosen
so that all five good corners are free.

Proof. By N4(a) a non-free q_j forces a bridge with start s ∈ {j−1, j}. By N3 its triple meets
{k, k+1, k+2}, i.e. s ∈ {k−2, …, k+2} (mod 9). For j = k+2+i (1 ≤ i ≤ 5), s = j−1 ∈ {k+2..k+6}
meets this set only for s = k+2 (i = 1), and s = j ∈ {k+3..k+7} only for s = k+7 (i = 5).
By N3, S lies in a window {t, t+1, t+2}. If |S| = 1 take k ∈ S. If t+1 ∈ S take k = t+1
(then k+2 = t+3 ∉ S and k+7 = t−1 ∉ S). If S = {t, t+1} take k = t (k+2 = t+2 ∉ S,
k+7 = t−2 ∉ S). The only remaining case is S = {t, t+2}. ∎

Free corners lie in E ∪ F (Corollary A3).

**Lemma 1.3 (corner radius). PROVED.** Every good corner has t_i > 1.085, and C(t_i) ≤ κ_i,
where C(t) = 2a − g_sym(t) (Lemma G).

Proof. Lemma G gives g_i ≤ g_sym(t_i), i.e. κ_i ≥ C(t_i). t_i ≥ R − 2
(boundary disks miss the open disk of radius R − 2: a point of D_j has radius ≥ ρ_j − 1 ≥ R − 2). C is decreasing on [R−2, 1.8717]
(Part D), and C(1.085) = 0.779555 − 2·arctan(0.341152) = 0.779555 − 0.657542 = 0.122013
(series, error < 10⁻⁶) > B ≥ κ_i. So t_i > 1.085. ∎

**Lemma 1.4 (half-angles of a good corner). PROVED.** For each good corner Q_i put
ρ*(κ) := the inner-branch centre radius with deficit min(κ, B/2), i.e.
ρ*(κ) = R cos w − √(1 − R² sin² w), w = a − min(κ, B/2), and

  M(t, κ) := max{ A(t,ρ) : ρ*(κ) ≤ ρ ≤ √(R²−1) },   λ(t, κ) := 2a − κ − M(t, κ).

M(t,κ) = A(t, ρ*(κ)) whenever t² ≤ ρ*(κ)² + 1 (in particular whenever t ≤ 2.2054, i.e. t ≤ √(ρ_lo² + 1) with ρ_lo = 1.965663), because the
ρ-derivative of the cosine (t² + ρ² − 1)/(2tρ) is (ρ² − t² + 1)/(2tρ²), positive for ρ² > t² − 1,
so ρ ↦ A(t,ρ) is decreasing there. Always M(t,κ) ≤ arcsin(1/ρ*(κ)) ≤ arcsin(1/1.9656) = 0.53374.

Then both A(t_i, ρ_i) and A(t_i, ρ_{i+1}) lie in [λ(t_i,κ_i), M(t_i,κ_i)], and they add up to
g_i = 2a − κ_i. In particular λ(t,κ) ≥ 0.24581 − κ.

Proof. Lemma E3.2: A(t_i,ρ_i) + A(t_i,ρ_{i+1}) = g_i. Each of d(G_i), d(G_{i+1}) is
≤ κ_i and ≤ B/2, and on the inner branch the centre radius is a decreasing function of the
deficit, so ρ_i, ρ_{i+1} ∈ [ρ*(κ_i), √(R²−1)]. Hence each half-angle is ≤ M, and the other one is
≥ g_i − M = λ. A(t,ρ) ≤ arcsin(1/ρ) (the angle under which a unit disk centred at distance ρ is
seen from 0). ∎

**Angular positions.** By Lemma E3.2, for a < b:
  φ_b − φ_a = A(t_a, ρ_{a+1}) + g_{a+1} + … + g_{b−1} + A(t_b, ρ_b),               (1.2)
so φ_b − φ_a ≥ λ_a + Σ_{a<i<b} (2a − κ_i) + λ_b, and φ_{a+1} − φ_a ≤ M_a + M_{a+1}.
A point at radius t > 1 lies in a unit disk only within angle arcsin(1/t) =: r(t) of the
direction of its centre (Lemma S). So if an inner disk X covers Q_a and Q_b then
φ_b − φ_a ≤ A(t_a,u_X) + A(t_b,u_X) ≤ r(t_a) + r(t_b).


### 2. Case analysis when the five good corners are free

Standing assumption in this section (case FIVE): Q_1, …, Q_5 are free (by Lemma 1.2 this can be
arranged unless the bridge starts are exactly {t, t+2}). Each Q_i lies in E or F. Let X be an
inner disk containing Q_1 and Y the other one (if Q_1 lies in both, take X = either).

Angle bookkeeping. All φ_i lie in (θ_1, θ_6) and θ_6 − θ_1 = Σ g_i ≤ 10a = 3.89777. A disk
covering Q_a and Q_b forces circular distance ≤ A_a + A_b ≤ 2 r(1.085) = 2.34466 (Lemma 1.3, and
A(t,u) ≤ r(t)); since 2π − 3.89777 = 2.38541 > 2.34466, the circular distance is the real
difference φ_b − φ_a. So: X ⊇ {Q_a, Q_b} ⇒ φ_b − φ_a ≤ A(t_a,u_X) + A(t_b,u_X).

Tables used (R = r_1; arctan / arcsin by series, error < 10⁻⁵, rounded so that the inequalities
below hold with the stated margins):

| t | 1.085 | 1.1 | 1.15 | 1.2 | 1.25 | 1.3 | 1.35 | 1.45 |
|---|---|---|---|---|---|---|---|---|
| C(t) | 0.122013 | 0.1158 | 0.096917 | 0.080557 | 0.066373 | 0.054103 | 0.043497 | 0.026631 |
| r(t) = arcsin(1/t) | 1.172335 | 1.141097 | 1.054321 | 0.985111 | 0.927295 | 0.877636 | 0.834172 | 0.761013 |
| m0(t) = A(t, 1.9656) | 0.32592 | 0.34220 | | 0.42201 | 0.44940 | 0.47122 | 0.48863 | |

(C via g_sym, e.g. t = 1.2: z = √(4 − 1.4317²)/3.8317 = 0.364462, arctan z = 0.349499,
C = 0.779555 − 0.698998 = 0.080557.)

**Lemma 2.1 (X cannot hold Q_1 and Q_5). PROVED.** By (1.2) and Lemma 1.4,
φ_5 − φ_1 = (g_1 − A(t_1,ρ_1)) + g_2 + g_3 + g_4 + (g_5 − A(t_5,ρ_6)) ≥ 10a − B − 2·0.53374
= 3.897774 − 0.120662 − 1.06748 = 2.70963, while A(t_1,u) + A(t_5,u) ≤ 2r(1.085) = 2.34466. ∎

**Lemma 2.2 (no inner disk holds two good corners three apart). PROVED.** If an inner disk holds
Q_a and Q_{a+3} (a ∈ {1,2}), then contradiction.

Proof. As above φ_{a+3} − φ_a ≥ g_a + g_{a+1} + g_{a+2} + g_{a+3} − A(t_a,ρ_a) − A(t_{a+3},ρ_{a+4})
≥ 8a − B − m(t_a) − m(t_{a+3}), where m(t) := m0(t) = A(t,1.9656) for t ≤ 1.35 and
m(t) := 0.53374 for t > 1.35 (valid upper bounds for A(t,ρ), ρ ≥ 1.9656, by Lemma 1.4; for
t ≤ 1.35, t² ≤ 1.9656² + 1). 8a − B = 2.997557. So h(t_a) + h(t_{a+3}) ≥ 2.997557 with
h := r + m. On [1.085, 1.2], h ≤ r(1.085) + m0(1.2) = 1.59434 (r decreasing, m0 increasing in t
for t ≤ √(1.9656² − 1) = 1.692); on [1.2, 1.35], h ≤ r(1.2) + m0(1.35) ≤ 1.47374; on [1.35, ∞),
h ≤ r(1.35) + 0.53374 ≤ 1.367913. Two corners both below 1.2, or one below 1.2 and one in
[1.2, 1.35], would cost C ≥ C(1.2) + C(1.35) = 0.124052 > B (κ_a + κ_{a+3} ≤ B, κ ≥ C). In all
remaining cases h(t_a) + h(t_{a+3}) ≤ max(1.59434 + 1.367913, 2·1.47374) = 2.962253 < 2.997557. ∎

**Corollary 2.3 (the only surviving pattern). PROVED.** In case FIVE, up to the reflection that
reverses the chain (Q_i ↔ Q_{6−i}) and renaming X ↔ Y: X ⊇ {Q_1, Q_3} and Y ⊇ {Q_4, Q_5}.

Proof. Q_5 ∉ X (Lemma 2.1), so Q_5 ∈ Y. If Q_3 ∈ Y, reflect and rename. So Q_3 ∈ X.
Q_4 ∈ X would put Q_1, Q_4 in X (Lemma 2.2). So Q_4 ∈ Y. ∎


### 3. Two bridges with a common middle disk are impossible (PROVED, by hand)

**Lemma 3.1 (no double bridge).** There are no two bridges (t, t+2) and (t+2, t+4).
Consequently the set S of bridge starts is a single index {k} or two consecutive indices
{k, k+1}, and by Lemma 1.2 the bridge (k, k+2) can be chosen so that all five good corners are
free: **case FIVE (§2) is the only case.**

Proof. Write D' = D_{t+2}, w' its half-width, ρ' = |c_{t+2}| ≥ R − 1 = 1.6317.
(a) Arc count (F3: only consecutive arcs overlap, no triple points):
Σ_j 2w_j − Σ_j o_j = 2π, so with w_j = a − d_j (j ≠ t+2):
  T := 2w' − (2π − 16a) = 2Σ_{j≠t+2} d_j + Σ_j o_j ≥ X1 + X2 + d_t + d_{t+4},
where X1 := d_t + 2d_{t+1} + o_t + o_{t+1}, X2 := d_{t+4} + 2d_{t+3} + o_{t+2} + o_{t+3}, and
2π − 16a = 0.046747 (= 2(π − 8a)).
(b) θ_{t+2} − θ_t = g_t + g_{t+1} = w_t + 2w_{t+1} + w' − o_t − o_{t+1} = 3a + w' − X1, and
symmetrically θ_{t+4} − θ_{t+2} = 3a + w' − X2.
(c) Put b_1 = X1 + d_t, b_2 = X2 + d_{t+4}; b_1 + b_2 ≤ T, so one of them, say b_1 (the other case
is the mirror image), is ≤ T/2 = w' − (π − 8a). Then X1 ≤ w' − (π − 8a) − d_t and
  Θ := θ_{t+2} − θ_t ≥ 3a + (π − 8a) + d_t = 1.1927057 + d_t,
while Θ ≤ 3a + w' < π/2 (w' ≤ a). Also 2d_t ≤ b_1 ≤ w' − (π − 8a) (this bound is not used below), and d_t ≤ B/2 = 0.0603311
because D_t is a good disk of the bridge (t+2, t+4). So ρ_t = ρ(d_t) ≥ 1.965663 (the
inner-branch radius ρ(d) is decreasing in d).
(d) |c_t − c_{t+2}|² = G := ρ_t² + ρ'² − 2ρ_tρ' cos Θ. ∂G/∂ρ' = 2(ρ' − ρ_t cos Θ) > 0 since
ρ_t cos Θ ≤ 2.4344·cos(1.1927) < 0.90 < ρ'; ∂G/∂ρ_t = 2(ρ_t − ρ' cos Θ) > 0 since ρ' ≤ ρ(a −
w')|_{w' ≤ a} ≤ √(R²−1) gives ρ' cos Θ ≤ 2.4344·0.3692 < 0.9 < ρ_t. So, on d_t ∈ [d_1, d_2],
G ≥ ρ(d_2)² + 1.6317² − 2·1.6317·ρ(d_2)·cos(1.1927057 + d_1).
  d_t ∈ [0, 0.03]: ρ(0.03) = 2.0869896, cos(π − 5a) ≤ 0.369147:
     G ≥ 4.355525 + 2.662445 − 6.810682·0.369147 = 4.5038 > 4.
  d_t ∈ [0.03, B/2]: ρ ≥ 1.9656, cos(π − 5a + 0.03) ≤ 0.341104:
     G ≥ 3.863583 + 2.662445 − 6.414539·0.341104 = 4.3380 > 4.
(Values of ρ(d) = R cos(a−d) − √(1 − R² sin²(a−d)) computed with 6–7 digits; the margins
0.33, 0.50 dwarf all rounding.) So |c_t − c_{t+2}| > 2 and D_t ∩ D_{t+2} = ∅, contradicting the
bridge (t, t+2). ∎

Remark. The bound uses only arc counting and the two bridges; no inner disk enters.


### 4. The surviving pattern: reduction to a finite system

By Lemma 3.1 we are in case FIVE; by Corollary 2.3, after reflection/renaming,
X ⊇ {Q_1, Q_3}, Y ⊇ {Q_4, Q_5}. Moreover **Q_2 ∈ X**: otherwise Y ⊇ {Q_2, Q_5}, three apart,
contradicting Lemma 2.2. Write u = |c_X|, v = |c_Y|, K_X = κ_1 + κ_2 + κ_3, K_Y = κ_4 + κ_5,
K_X + K_Y ≤ B (1.1); C(t_i) ≤ κ_i (Lemma 1.3); M_i := M(t_i, κ_i), λ_i := 2a − κ_i − M_i.

**Lemma 4.1 (necessary conditions). PROVED.**
 (X) 6a − K_X − M_1 − M_3 ≤ A(t_1,u) + A(t_3,u)      [φ_3 − φ_1 = A(t_1,ρ_2) + g_2 + A(t_3,ρ_3)
                                                    ≥ λ_1 + (2a − κ_2) + λ_3];
 (Y) 4a − K_Y − M_4 − M_5 ≤ A(t_4,v) + A(t_5,v)      [φ_5 − φ_4 = A(t_4,ρ_5) + A(t_5,ρ_5)];
 (S) if u > 3 − R and v > 3 − R:
     α(u) + A(t_3,u) + M_3 + α(v) + A(t_4,v) + M_4 ≥ 2π.
 (Also t_i ≤ 1 + u for i = 1,2,3 and t_i ≤ 1 + v for i = 4,5.)

Proof of (S). By Lemma E2.1, the arcs of S_{ρ_0} (ρ_0 = R − 2) cut by X and Y, of
half-widths α(u), α(v), cover S_{ρ_0}; for u, v > 3 − R = 1 − ρ_0 both are proper arcs, and
covering forces α(u) + α(v) ≥ 2π − Δ, Δ = circular distance of the centre directions
(the complement of the X-arc, of half-width π − α(u), must fit in the Y-arc).
Take lifts with |φ_X − φ_3| ≤ A(t_3,u), |φ_Y − φ_4| ≤ A(t_4,v) (possible since X ∋ Q_3, Y ∋ Q_4;
the circular distance equals the real one as in §2). D := φ_Y − φ_X satisfies
D ≤ (φ_4 − φ_3) + A(t_3,u) + A(t_4,v) ≤ M_3 + M_4 + A(t_3,u) + A(t_4,v) (Lemma 1.4, (1.2)),
and D ≥ (φ_5 − φ_1) − A(t_1,u) − A(t_5,v) ≥ 2.70963 − 2.34466 > 0 (as in Lemma 2.1, using
|φ_X − φ_1| ≤ A(t_1,u), |φ_Y − φ_5| ≤ A(t_5,v)). Hence Δ ≤ D and (S) follows. ∎

**Lemma 4.2 (X is not near the origin). PROVED.** u ≤ 3 − R is impossible.

Proof. Then t_1, t_2, t_3 ≤ 1 + u ≤ 4 − R = 1.3683. C(1.3683) = 2a − 2 arctan(0.3876065)
= 0.7795548 − 0.7395537 = 0.0400011 ≥ 0.039999 (R + t = 4 exactly; z = √(4 − 1.2634²)/4 = 0.3876065), so
each C(t_i) ≥ C(1.3683) and hence each C(t_i) ≤ B − 2C(1.3683) ≤ B − 2·0.039999 = 0.0406642. Since
C(1.36) = 2a − 2·0.3689962 = 0.0415625 > 0.0406642 (margin 8.9·10⁻⁴) and C decreases, t_1, t_3 ∈ (1.36, 1.3683].
A(t,u) decreases in t (u ≤ 1) and increases in u for u ≤ √(t² − 1) (> 0.42), so
A(t_i, u) ≤ A(1.36, 0.3683) = arccos(0.98524489/1.001776) = arccos(0.98350) < 0.183.
But (X) and Lemma 1.4 give A(t_1,u) + A(t_3,u) ≥ 6a − B − 2·0.53374 = 1.1505. ∎

So it remains to exclude:
 (FAR)  u, v ∈ (3 − R, R − 1], with (X), (Y), (S), (C), K_X + K_Y ≤ B;
 (NEAR-Y) v ≤ 3 − R (so t_4, t_5 ≤ 4 − R and K_Y ≥ 2C(4−R) = 0.0800), with (X), (Y), (C),
         K_X + K_Y ≤ B.
These are finite-dimensional (variables u, t_1, κ_1, t_3, κ_3 for X; v, t_4, κ_4, t_5, κ_5 for Y;
the budget K_X is the only coupling besides (S)). M(t,κ) is increasing in κ and only upper
bounds of M are used, so every inequality is monotone in the "safe" direction for a
branch-and-bound.

**Addendum to Lemma 4.1 (reach of X to Q_2). PROVED.** Since Q_2 ∈ X, t_2 ≤ 1 + u, and
κ_2 ≥ C(t_2) ≥ C(1 + u) whenever 1 + u ≤ R − 2/R = 1.871735 (C is decreasing on
[R − 2, R − 2/R]: for h = z², h′ has the sign of 2R(R − t) − 4, Part D). So in (X) the budget
satisfies κ_1 + κ_3 + C(min(1+u, ·)) ≤ K_X, i.e.

 (Q2) κ_1 + κ_3 + C(1 + u) ≤ K_X   if 1 + u ≤ R − 2/R.

This is what kills the high-α region (u slightly above 3 − R): there t_2 ≤ 1 + u is close to
4 − R, so (Q2) charges almost C(4 − R) = 0.0400 on top of κ_1 + κ_3. (Explanatory remark only;
C1 uses (Q2) itself, not this remark.)

Reduction used by the program (all proved above):
* κ_1 only enters through the budget and through M_1 (favourably, M increasing in κ), so it is
  replaced by its largest possible value κ_1 ≤ K_X − κ_3 − C(1+u) [via (Q2)]; similarly κ_5 is
  replaced by K_Y − κ_4. This is a relaxation (necessary conditions only).
* X-box variables (u, t_1, t_3, κ_3); Y-box variables (v, t_4, κ_4, t_5).
* For a slice K_X ∈ [K_lo, K_hi] of [0, B]: X has budget ≤ K_hi, Y has budget ≤ B − K_lo.
  (FAR) is excluded on the slice if U_Y := (upper bound of α(v) + A(t_4,v) + M_4 over the
  Y-feasible far set) and the X far set satisfies α(u) + A(t_3,u) + M_3 < 2π − U_Y everywhere.
  (NEAR-Y) is excluded on the slice if the Y-near set (v ≤ 3 − R) is empty, or the X far set
  (u > 3 − R; u ≤ 3 − R is Lemma 4.2) is empty, both without (S).
* Slices are bisected on failure (depth ≤ 9).

Soundness. Interval arithmetic with outward rounding: +, −, ×, ÷, √ are IEEE correctly rounded,
so widening each result by one ulp (math.nextafter) encloses the exact value. asin, acos, atan,
sin, cos are monotone on the arguments used; each libm value is widened by 10⁻¹² (assumption:
the platform libm is accurate to better than 10⁻¹³ on these functions — glibc/macOS/MSVC are
accurate to ~1 ulp ≈ 2·10⁻¹⁶). Every quantity is used only in the direction in which an
upper/lower bound is valid: A(t,u) ≤ arccos(lower bound of (t²+u²−1)/(2tu)); M(t,κ) ≤ A(t, ρ_L)
when t² ≤ ρ_L² + 1, else ≤ arcsin(1/t), with ρ_L a lower bound of the inner-branch radius at
deficit min(κ_max, B/2) (ρ(w) = R cos w − √(1 − R² sin² w) is increasing in w, since
dρ/dw = R sin w (R cos w/√(1 − R² sin² w) − 1) ≥ 0 ⇔ R² ≥ 1); C(t) ≥ 2a − 2 arctan(upper bound
of z). A box is discarded only if a necessary condition fails on the whole box. The best-first
upper bound returns the largest box bound still in the heap, which encloses all feasible points.
Boxes of the far domain start at a rounded-down 3 − R; at points with u ≤ 3 − R the use of (S)
is not justified, but those points belong to Lemma 4.2 (u) or to (NEAR-Y) (v), which are
treated separately, so nothing is lost.

### Repairs and supplements to §§1–4 (part of the proof)

**Repair M1 (u, v < R − 1).** The domain of (FAR) uses u, v ≤ R − 1, and (S) needs both arcs of S_{ρ_0} to be non-empty, i.e. u, v ≤ 1 + ρ_0 = R − 1.
- X contains Q_1, which lies in int D_R (Lemma A2).
- X misses S_R (it is an inner disk) and is connected, so X ⊂ int D_R and u = |c_X| < R − 1.
- The same argument with Q_4 ∈ Y gives v < R − 1.

**Repair M2 (the lifts in the proof of (S)).** The proof of (S) says the chosen lift of φ_X is also within A(t_1,u) of φ_1 "as in §2". §2's argument does not apply literally. The correct argument is below. Recall that Q_i lies strictly between the rays of the centres of G_i and G_{i+1} (Lemma E3.2), and that every A(t, ·) ≤ r(1.085) < 1.1724 for t > 1.085.
- The X side.
  - φ_3 − φ_1 ∈ (0, θ_4 − θ_1) ⊂ (0, 6a) = (0, 2.3387), where θ_i are the angles of the centres of the G_i.
  - With φ_X chosen so that |φ_X − φ_3| ≤ A(t_3,u), this gives φ_X − φ_1 ∈ (−1.1724, 3.5111).
  - Since X ∋ Q_1, some translate φ_X − φ_1 + 2πn lies in [−A(t_1,u), A(t_1,u)] ⊂ [−1.1724, 1.1724].
  - Every n ≠ 0 is incompatible with the interval above, because 2π − 1.1724 = 5.111 > 3.5111. So |φ_X − φ_1| ≤ A(t_1,u).
- The Y side.
  - φ_5 − φ_4 ∈ (0, θ_6 − θ_4) ⊂ (0, 4a) = (0, 1.5592).
  - With |φ_Y − φ_4| ≤ A(t_4,v), this gives φ_Y − φ_5 ∈ (−2.732, 1.1724).
  - The same reasoning gives |φ_Y − φ_5| ≤ A(t_5,v).
- Conclusion. D = φ_Y − φ_X satisfies D ≥ (φ_5 − φ_1) − A(t_1,u) − A(t_5,v) > 0. Hence Δ ≤ D, and (S) follows as written.

**Repair M3 (numerical slips without load).**
- In Lemma 1.4 the threshold is t ≤ √(1.965663² + 1) = 2.2054, not 2.2069; this is corrected in the text. The hand lemmas use the ρ-monotonicity only for t ≤ 1.35, and the program tests t² ≤ ρ_L² + 1 directly.
- r(1.085) = π/2 − arctan(0.420981) = 1.172334, not 1.172329. Then 2r(1.085) = 2.34467, and every margin is unaffected.

**Supplement M4 (completeness of the case analysis).**
- *Bridge starts.* Let S be the set of bridge starts. By N3, S lies in a window {t, t+1, t+2}. A set containing both t and t+2 is excluded by Lemma 3.1. So S = {k} or S = {k, k+1}.
- *Choice of bridge.* Lemma 1.2, with k ∈ S if |S| = 1 and k = t if S = {t, t+1}, makes all five good corners free.
- *A second bridge (k+1, k+3).* This involves G_1 = D_{k+3}. None of the lemmas used assumes that G_1 is in no other bridge. They use only:
  - the N2 budget of the bridge (k, k+2);
  - the bounds g ∈ [2a − B, 2a] and ρ ≥ 1.9656 (Lemma E3.1);
  - freeness of Q_1, …, Q_5.
- *The pattern.* In Corollary 2.3 and in "Q_2 ∈ X" of §4, only memberships are used, together with "a free corner not in X lies in Y" (free corners lie in E ∪ F, Corollary A3). So corners in both inner disks cause no problem.
- *The reflection.* The reflection z ↦ z̄ with reversed numbering maps bridges to bridges and good disks to good disks, and preserves the budget, (SH) and freeness.
- *X ≠ Y.* By Lemma 2.1, Q_1 ∈ X and Q_5 ∉ X. So X and Y are the two different inner disks, as (S) requires.
- *Exhaustive cases.* The remaining cases are u ≤ 3 − R (Lemma 4.2), u, v > 3 − R (FAR), and u > 3 − R ≥ v (NEAR-Y).
- *The label (C).* In (FAR) and (NEAR-Y), "(C)" denotes the cost bounds C(t_i) ≤ κ_i of Lemma 1.3.

### 5. The finite check of (FAR) and (NEAR-Y): computation C1


The program is `nb_check.py`, reproduced verbatim in Appendix 1. Its function-by-function soundness is as follows.

**Interval kernel.**
- The basic operations +, −, ×, ÷ and sqrt are IEEE correctly rounded, then widened by one ulp with
  nextafter. Each result therefore encloses the exact value.
- float(Fraction) is correctly rounded.
- math.pi < π < nextafter(math.pi), so PI and TWO_PI are valid enclosures (doubling is exact).
- asin, atan, sin, cos are used only on their monotone ranges (sin/cos on [0, 1.5] are asserted) and widened
  by 10⁻¹². acos is applied to a lower bound of the cosine and widened upwards.
- isqrt clips negative lower ends. This is valid, because every argument it receives is a quantity known to
  be ≥ 0:
  - 4 − (R−t)² > 0 for t ≥ 1;
  - 1 − R² sin² w ≥ 0 for w ≤ a.

**A_up(t,u): valid upper bound of A over the box.**
- Lower bound of the cosine N/D:
  - if N.lo > 0, it is N.lo/D.hi (correct even if D.lo = 0, as happens for v near 0 in Y_root_near);
  - if N.lo ≤ 0 and D.lo > 0, it is N.lo/D.lo;
  - otherwise the function returns π.
- It returns None only when the cosine lower bound is > 1 on the whole box, i.e. |t−u| > 1 everywhere. In
  that case the point is in no disk centred at radius u, so None is legitimate.

**C_lo.**
- It is a direct interval enclosure of 2a − 2 arctan z and uses no monotonicity.
- It never returns None, since t ≥ 1 > R−2.

**rho_lo(dmax).**
- It evaluates ρ at the point w_l = (a − dmax).lo ≤ a − dmax. Since ρ is increasing in w, this is a lower
  bound of the inner-branch radius for every deficit ≤ dmax.

**M_up(t,kmax).**
- kmax < 0 → None. This is correct, because κ ≥ 0.
- dmax = min(kmax, B.hi/2) is ≥ min(κ, B/2).
- If t².hi ≤ ρ_L² + 1, then every admissible ρ ≥ ρ_L has ρ² ≥ t² − 1. So M ≤ A(t, ρ_L), and A_up encloses
  that.
- The None branch of A_up in this call is legitimate:
  - since t ≤ √(ρ_L²+1) < ρ_L + 1, None can only mean ρ_L − t > 1 on the box;
  - then every true radius ρ_i ≥ ρ_L gives ρ_i − t > 1, and the corner cannot lie on C_i.
- Otherwise M_up returns arcsin(1/t), which bounds every A(t,ρ) (Lemma S).

**C2_lo(u).**
- With t_h = up(1+u.hi) ≤ T*.lo, it returns max(0, C_lo(t_h)) ≤ C(t_2). This uses t_2 ≤ 1+u ≤ t_h and the
  fact that C is decreasing on [R−2, R−2/R].
- Otherwise it returns 0.

**eval_X / eval_Y.**
- Each None comes from a necessary condition violated on the whole box:
  - κ_3 ≥ C(t_3);
  - κ_1 ≥ 0;
  - κ_1 ≥ C(t_1);
  - membership (A_up None);
  - M None;
  - (X), with its left side bounded below using K_X ≤ Khi, M_1 ≤ M_up(t_1, k1max) and
    M_3 ≤ M_up(t_3, k3.hi).
- The analogous list holds for Y, with κ_5 ≤ K_Y − κ_4 ≤ KY − k4.lo.
- The "obj" value is a valid upper bound of α + A + M.
- An al = None (u > 1 + ρ0 by rounding) would raise a TypeError, not a silent pass. Since the run completed
  with every slice True, this did not occur.

**Relaxation of κ_1 and κ_5. Legitimate.**
- κ_1 enters (X) only through −K_X, which the program replaces by −Khi, and through −M_1, where M is
  monotone in κ.
- κ_1 is bounded by k1max = Khi − k3.lo − C2_lo(u), which is ≥ K_X − κ_3 − κ_2. The constraint
  C(t_1) ≤ κ_1 ≤ k1max is retained.
- The same holds for κ_5. Dropping constraints only enlarges the set being refuted.

**Slices.**
- The edges cover [0, B.hi] ⊇ [0, B] ∋ K_X. Adjacent slices, and the two halves after bisection, share
  identical float endpoints.
- On a slice: K_X ≤ Khi, and K_Y ≤ B − K_X ≤ B.hi − Klo ≤ KY.
- verify() returns True only if every leaf sub-slice has check_slice(...) = None.

**upper_bound.**
- Invariant: the boxes in the heap, together with the discarded boxes (which are infeasible), cover the
  root.
- So the maximum heap key bounds the objective at every feasible point. Hitting the cap still returns a
  valid, merely looser, bound.
- An empty heap gives −∞, meaning no feasible point.

**refute.**
- It discards a box only if the box is infeasible or its bound is < T.
- Hitting the cap returns False, which is the conservative outcome.

**check_slice. Logic correct.**
- (FAR): T = dn(2π.lo − U_Y) ≤ 2π − U_Y. If X-obj < T on all feasible X-points, then X-obj + Y-obj < 2π,
  which contradicts (S). If U_Y = −∞, the Y far set is empty.
- (NEAR-Y): the case is excluded if (Y) is infeasible for v ≤ 3−R (root v ∈ [0, (3−R).hi]), or if (X) is
  infeasible for u ∈ [(3−R).lo, (R−1).hi].
- The roots contain every configuration of the corresponding case:
  - t ∈ (1.085, R) ⊂ [1, R);
  - κ_3, κ_4 ∈ [0, B];
  - u, v ≤ R−1 (by Repair M1 above).
- The X root extends one ulp below 3−R. That is harmless (a superset), and those points are in any case
  excluded by Lemma 4.2.

**The run.**
- *Environment.* `nb_check.py` (Appendix 1) was run under CPython 3.12 (IEEE double, glibc libm) on Linux.
- *Driver.* The driver `nb_par.py` (also in Appendix 1) imports the program and calls its own `verify(edges[i], edges[i+1], 0)` on each of the 24 top-level K_X slices. It uses the same 24 edges as `main()`, in parallel processes.
- *Result.* Every slice returned True, and the driver printed `ALL CASES VERIFIED`. Single slices took between 17 s and 47 min.
- *Equivalent sequential run.* `python3 nb_check.py` performs the same checks one after the other.
- *Location on the machine where it was run:* `/home/skim/projects/research/circovcir/experiments/2026-10-20-siege-n11-b9/out/judge/r5/` (files `nb_check.py`, `nb_par.py`, log `nb_par.log`).
- *Independent float search (not part of the proof).* A float search over 4·10⁵ samples was written from the lemma statements, not from the code. Under (X), (Y), (Q2), the budget and κ ≥ C(t), the largest value of [α(u) + A(t_3,u) + M_3] + [α(v) + A(t_4,v) + M_4] it found was 5.51, against 2π = 6.283. It found no feasible NEAR-Y point.

**Conclusion of Part M.** Assume (i) IEEE-754 double arithmetic with correctly rounded + − × ÷ √, and (ii) libm asin, acos, atan, sin and cos accurate to within 10⁻¹² on the arguments used. Then the run proves that (FAR) and (NEAR-Y) are infeasible. With §§1–4 and Repairs M1–M4, this proves Theorem NB.

**Independent re-check without floating-point assumptions (certificate 22b, §13a).** The same finite statement — (FAR) and (NEAR-Y) infeasible for every K_X ∈ [0, B] — was re-proved in Mathematica, from the mathematical statements of §4 (not by translating `nb_check.py`). All transcendental values are 20-digit bignum `Interval` enclosures; box endpoints and budgets are exact rationals and every decision is an exact rational comparison. It used 48 top-level K_X slices (one of which was bisected once, 49 leaves); every leaf returned OK, and the leaves tile [0, B.hi] exactly with B.hi ≥ B. Hence Theorem NB holds with no IEEE or libm assumption, the trusted base being Mathematica's arbitrary-precision interval and rational arithmetic. The conclusion above, under assumptions (i)–(ii), is kept as a second, independent implementation.

## Part B (continued) — The hole under No-Bridge

From here on, (NB) holds by Theorem NB. The statements below cite "(NB)" for it.

Recall from Part A (Lemma A2 and the paragraph "The boundary of the hole"):
C_k ∩ D_R is the arc of C_k from s_k to e_k, meeting S_R only at s_k, e_k; along it the points of
D_{k−1} form an initial segment [s_k, q_{k−1}] (its points other than q_{k−1} lie in int D_{k−1},
because C_k ∩ D_{k−1} is an arc of C_k with end points p_{k−1}, q_{k−1}), and the points of D_{k+1}
form a final segment [q_k, e_k]. Also H = int D_R \ ⋃_k D_k is open in the plane and
∂H ⊂ ⋃_k (C_k ∩ int D_R).

**Theorem J.** Assume (NB). Then:
1. every q_k is free, the segments [s_k, q_{k−1}] and [q_k, e_k] of C_k ∩ D_R are disjoint, and
   γ_k := the closed sub-arc of C_k between q_{k−1} and q_k is a non-degenerate arc in int D_R;
2. ∂H = Γ := γ_1 ∪ … ∪ γ_9;
3. Γ is a simple closed curve passing through q_1, …, q_9 in this cyclic order;
4. H is the bounded component (interior domain) of R² \ Γ; in particular H ≠ ∅ and H̄ = H ∪ Γ is a
   closed topological disk.

Proof. (1) Free: N4(c). The two segments intersect only if q_{k−1} ∈ D_{k+1} or q_k ∈ D_{k−1}, which
would give a bridge (k−1, k+1). So γ_k is non-degenerate, and it avoids s_k, e_k, so γ_k ⊂ int D_R.

(2) "⊂": let y ∈ ∂H. Then y ∈ C_k ∩ int D_R for some k and y lies in no int D_j. Not lying in
int D_{k−1} or int D_{k+1}, y is on C_k ∩ D_R outside [s_k, q_{k−1}) and (q_k, e_k], i.e. y ∈ γ_k.
"⊃": let x ∈ γ_k. By (G′) (N4(c)) x ∉ D_j for j ∉ {k−1,k,k+1}; and x ∉ D_{k±1} unless x is an end
point of γ_k. For x in the relative interior of γ_k, all points near x outside D_k lie in int D_R and
in no boundary disk, i.e. in H; so x ∈ H̄ \ H = ∂H. The end points then lie in ∂H by closedness.

(3) For non-adjacent k, l, γ_k ⊂ D_k and γ_l ⊂ D_l are disjoint by (G′). For adjacent k, k+1:
γ_k ∩ γ_{k+1} ⊂ C_k ∩ C_{k+1} = {p_k, q_k} and p_k ∉ int D_R, so γ_k ∩ γ_{k+1} = {q_k}. Each γ_k is
a simple arc from q_{k−1} to q_k; concatenating gives a simple closed curve.

(4) Let Ω be a component of R² \ Γ. Since ∂H ∩ Ω = ∅, H ∩ Ω is open and closed in Ω, so Ω ⊂ H or
Ω ∩ H = ∅. The unbounded component contains S_R (Γ ⊂ int D_R), and S_R ∩ H = ∅; so it misses H.
Since H ⊂ R² \ Γ (H is open and Γ = ∂H) and H ≠ ∅ (points next to the interior of γ_k lie in H), H is
the bounded component. Schoenflies gives the disk statement. ∎

Remark. Theorem J uses neither the minor-arc condition nor the inner-branch normalisation.

**Lemma K.** Under the conclusion of Theorem J, H ⊂ conv{q_1, …, q_9}.

Proof. Let P be the closed polygon q_1 q_2 … q_9 q_1 (possibly self-intersecting) and h ∈ H. As
1-cycles, Γ − P = Σ_k (γ_k − [q_{k−1}, q_k]), and each closed curve γ_k ∪ [q_k, q_{k−1}] lies in the
convex set D_k, which does not contain h (H ∩ D_k = ∅). A closed curve inside a convex set not
containing h has winding number 0 about h. Hence wind(P, h) = wind(Γ, h) = ±1 (Jordan curve, h
inside). A closed curve contained in a convex set K winds 0 about every point outside K; P ⊂
conv{q_k}, so h ∈ conv{q_k}. ∎

**Corollary K1 (no one-disk split).** Assume (NB) (or just the conclusion of Theorem J). Then
neither E nor F contains all nine inner corners. Proof: if E ⊇ {q_k}, then E ⊇ conv{q_k} ⊇ H by
Lemma K, contradicting Lemma A5 (which rests on the quoted result that ten-boundary-disk
coverings have R < 2.63169). Same for F. ∎
So m ∈ {0, 9} is excluded with no minor-arc condition; the remaining splits are 1 ≤ m ≤ 8.

## Part O — The corners in E form a cyclic interval

Assume (SH) and (NB). The naming of the inner disks is that of (SH): E contains 0, and F is the other inner disk. The only property of E used below is that it misses S_R (this enters in Proposition P(3)). For the symmetric statements about F, the corresponding property of F is used, and F also misses S_R. So the argument is symmetric in E and F, and it is valid with the naming of (SH).

**Lemma L1 (spindle).** Let t_1 ≠ t_2 with |t_1 − t_2| < 2. Let m, m′ be the centres of the two unit circles through t_1 and t_2; they are mirror images in the line t_1t_2. Put L(t_1,t_2) := D(m,1) ∩ D(m′,1). Then every closed unit disk D(c,1) containing t_1 and t_2 contains L(t_1,t_2).

*Proof.*
1. **Arc measure.** For z ≠ y with |z − y| = d, the set C(y,1) ∩ D(z,1) is empty or a single closed arc. Its measure is 2 arccos(d/2) < π, because the condition is cos(φ − φ_0) ≥ d/2.
2. **Set-up.** Let z ∈ L(t_1,t_2). We must show c ∈ D(z,1). We know c ∈ L′ := D(t_1,1) ∩ D(t_2,1). The circles C(t_1,1) and C(t_2,1) meet exactly in m and m′. So ∂L′ = α_1 ∪ α_2, where α_1 is the arc of C(t_1,1) inside D(t_2,1). That arc has endpoints m, m′ and measure < π by step 1. The arc α_2 is defined symmetrically.
3. **α_1 ⊂ D(z,1).** Since z ∈ L(t_1,t_2), we have m, m′ ∈ D(z,1). If z = t_1, then α_1 ⊂ C(t_1,1) ⊂ D(z,1). Otherwise β := C(t_1,1) ∩ D(z,1) is one arc of measure < π that contains m and m′. Suppose α_1 ⊄ β. Then β, being connected and containing both endpoints of α_1, contains the complementary arc. That arc has measure > π, which is a contradiction. So α_1 ⊂ D(z,1), and likewise α_2 ⊂ D(z,1).
4. **Conclusion.** L′ is the convex hull of ∂L′, so L′ ⊂ D(z,1). In particular c ∈ D(z,1). ∎

**Lemma L2 (crossing).** Let K̂ be a closed topological disk on the sphere with boundary Jordan curve Γ. Let x_1, x_2, x_3, x_4 ∈ Γ be distinct and in this cyclic order. Let α be an arc from x_1 to x_3 and β an arc from x_2 to x_4, both with interiors in int K̂. Then α ∩ β ≠ ∅.

*Proof.* We use two standard theorems: the Jordan curve theorem in the strong form "the complement of a Jordan curve J in ℝ² has exactly two components, int J (bounded) and ext J, and every point of J is a boundary point of both", and the Schoenflies theorem, by which there is a homeomorphism of K̂ onto the closed unit disk 𝔻̄ carrying Γ onto the unit circle S¹ (and hence int K̂ onto the open disk 𝔻). Transport everything by this homeomorphism; intersections are preserved. So assume K̂ = 𝔻̄, Γ = S¹, and α°, β° ⊂ 𝔻, where α°, β° denote the arcs without their endpoints. Suppose α ∩ β = ∅.

The points x_1, x_3 cut S¹ into two open arcs; by the cyclic order, one of them, κ_2, contains x_2 and the other, κ_4, contains x_4. Put J := α ∪ κ̄_2. It is a Jordan curve (α meets S¹ only at x_1, x_3). Note x_4 ∉ J.
1. int J ⊂ 𝔻. The set ℝ² \ 𝔻̄ is connected, unbounded and disjoint from J, so it lies in ext J. Hence int J ⊂ 𝔻̄, and int J, being open, lies in the interior 𝔻 of 𝔻̄.
2. Points of 𝔻 near x_2 lie in int J. Choose an open disk B about x_2 that misses the compact set α ∪ κ̄_4 (it does not contain x_2). Then B ∩ J = B ∩ S¹, and B \ S¹ consists of B ∩ 𝔻 and B \ 𝔻̄, each convex, hence connected, and each disjoint from J. B \ 𝔻̄ lies in ext J by step 1. Since x_2 ∈ J is a boundary point of int J, int J meets B \ J, hence meets B ∩ 𝔻; as B ∩ 𝔻 is connected and misses J, B ∩ 𝔻 ⊂ int J.
3. β° ⊂ int J. The set β° is connected and misses J (it misses α by assumption, and κ̄_2 ⊂ S¹ while β° ⊂ 𝔻). So β° lies in one component of ℝ² \ J. Points of β° close to x_2 lie in B ∩ 𝔻 ⊂ int J by step 2. So β° ⊂ int J.
4. Contradiction. x_4 is a limit of points of β°, so x_4 ∈ cl(int J) ⊂ int J ∪ J. Since x_4 ∉ J, x_4 ∈ int J ⊂ 𝔻 by step 1. But |x_4| = 1.

Hence α ∩ β ≠ ∅. ∎

---

### 2. Set-up for the run property

Hypotheses: (SH) and (NB) (Part M). By Theorem J of Part B:
* all corners are free;
* Γ = ∂H is a Jordan curve through q_1, …, q_9 in this order;
* H̄ = H ∪ Γ ⊂ int D_R.

Let ℓ, P_E, P_F and σ = E ∩ F ∩ ℓ be as in Lemma C1. Here c_E ≠ c_F, c_E ∈ int P_E, and F is the mirror image of E in ℓ.

**Facts used.**
* (f1) Γ ⊂ E ∪ F, because H̄ ⊂ E ∪ F (closedness). Hence H̄ ∩ ℓ ⊂ σ: a point x ∈ ℓ ∩ E has |x − c_F| = |x − c_E| ≤ 1. The bounded components ("gaps") of ℓ \ H̄ have both endpoints in H̄ ∩ ℓ ⊂ σ, so they lie in the segment σ. If E ∩ F is empty or a point, there are no gaps.
* (f2) O := ℝ² \ H̄ is the exterior domain. By Schoenflies on the sphere, Ō ∪ {∞} is a closed disk with boundary Γ. Moreover:
  * int D_k ∩ H̄ = ∅ for every boundary disk, and ℝ² \ D_R ⊂ O;
  * if o_k ≥ 0, then int L_k ⊂ O, where L_k = D_k ∩ D_{k+1};
  * int A_k ⊂ int D_k, and int A_k ≠ ∅ (Lemma A0).
* (f3) Classify each corner q_k as one of:
  * **E-only**: q_k ∈ int P_E, hence q_k ∈ E (C1(2));
  * **F-only**: q_k ∈ int P_F, hence q_k ∈ F;
  * **central**: q_k ∈ ℓ, hence q_k ∈ E ∩ F.

**The components W_∞^E and W(q).** Put U_E := O ∩ int P_E.
* int P_E \ D_R ⊂ U_E is connected. In coordinates with ℓ = {y = y_0} and P_E = {y > y_0}, a point can be moved horizontally with |x| increasing (so |z| increases) until |x| > R, and from there it moves freely.
* Let W_∞^E be the component of U_E containing int P_E \ D_R.
* For an E-only corner q = q_a, choose r with B(q,r) ⊂ int P_E. The set int L_a ∩ B(q,r) is convex, nonempty and contained in U_E. Let W(q) be the component of U_E containing it. Call q **good** if W(q) = W_∞^E and **pocketed** otherwise.
* F-side objects are defined symmetrically.

**Ray lemma.** Let ρ be an unbounded component of ℓ \ H̄. Then every point of U_E sufficiently close to a point of ρ lies in W_∞^E.

*Proof.*
1. For y ∈ ρ choose ε_y > 0 with B(y,ε_y) ⊂ O. The half-ball B(y,ε_y) ∩ int P_E is convex, so it lies in a single component C(y) of U_E.
2. For y′ near y the half-balls overlap, so C(y) is locally constant. Since ρ is connected, C(y) is constant on ρ.
3. Points of ρ far out have half-balls meeting int P_E \ D_R. So C ≡ W_∞^E. ∎

---

### 3. Theorem O2

### Proposition P (pocketed corners lie in E ∩ F)

Let q_a be a pocketed E-only corner, and let k ∈ {a, a+1}. Put V_k := int D_k ∩ int P_E. Then:
1. V_k ⊂ W(q_a) and V_k ∩ (ℝ² \ D_R) = ∅.
2. D_k ∩ ℓ is a nondegenerate segment τ_k = [t_1,t_2] ⊂ σ.
3. c_k ∈ int P_F.
4. D_k ∩ P_E ⊂ L(t_1,t_2) ⊂ E ∩ F. In particular q_a ∈ E ∩ F.

The symmetric statement holds for pocketed F-only corners.

*Proof.*

(1) V_k is convex and contained in U_E. It contains int L_a ∩ B(q_a,r), so V_k ⊂ W(q_a). If V_k met ℝ² \ D_R, it would meet W_∞^E, giving W(q_a) = W_∞^E. That contradicts the assumption that q_a is pocketed.

(2) **Nondegenerate.** Suppose |D_k ∩ ℓ| ≤ 1. Then int D_k ∩ ℓ = ∅, so int D_k lies in one open half-plane. It has points near q_a ∈ int P_E, so int D_k ⊂ int P_E and V_k = int D_k. Take x ∈ int A_k. Then x ∈ int D_k, so (1 + t)x ∈ V_k \ D_R for small t > 0. This contradicts (1). Hence τ_k is a nondegenerate chord, and its relative interior τ_k° lies in int D_k ⊂ O.

**Contained in σ.** Suppose a point x ∈ τ_k° lay on an unbounded component of ℓ \ H̄. Points of V_k near x lie in W(q_a), and by the Ray lemma also in W_∞^E. That is a contradiction. So τ_k° lies in the union of the gaps, and by (f1) it lies in σ. Hence τ_k ⊂ σ.

(3) **c_k ∉ ℓ.** If c_k ∈ ℓ, then |τ_k| = 2 > |σ|. Indeed σ, a chord of E, has length 2 only if c_E ∈ ℓ, which is false.

**c_k ∉ int P_E.** Suppose c_k ∈ int P_E, and let c_k′ be its mirror image in ℓ. For z ∈ P_F we have |z − c_k′| ≤ |z − c_k|. So D_k ∩ P_F ⊂ D(c_k,1) ∩ D(c_k′,1) = L(t_1,t_2). The centres c_k, c_k′ are those of the unit circles through t_1, t_2. By Lemma L1 (with t_1, t_2 ∈ σ ⊂ E), L(t_1,t_2) ⊂ E.

So A_k ∩ P_F ⊂ E ∩ S_R = ∅, using |c_E| ≤ 1 < R − 1. Then A_k ⊂ int P_E, so int A_k ⊂ V_k. Pushing a point of int A_k outward contradicts (1). Hence c_k ∈ int P_F.

(4) The argument of (3) with the sides exchanged gives D_k ∩ P_E ⊂ L(t_1,t_2). Lemma L1 applied to E and to F (both contain t_1, t_2 ∈ σ) gives L(t_1,t_2) ⊂ E ∩ F. Finally q_a ∈ D_a ∩ P_E. ∎

### Theorem O2

Under (SH) and (NB), there is a cyclic interval I ⊆ ℤ_9 with q_k ∈ E for k ∈ I and q_k ∈ F for k ∉ I.

*Proof.*

**Partition the corners.** Let G_E be the good E-only corners and G_F the good F-only corners. Every other corner is central or pocketed, and so lies in E ∩ F by (f3) and Proposition P.

**Claim: G_E and G_F do not interleave.** Suppose q_a, q_c, q_b, q_d occur in this cyclic order on Γ, with q_a, q_b ∈ G_E and q_c, q_d ∈ G_F.
1. Join q_a to a fixed base point b_E ∈ int P_E \ D_R. Start with a segment from q_a to a point of int L_a ∩ B(q_a,r); its points other than q_a lie in int L_a ⊂ O. Then continue by a path in the open connected set W(q_a) = W_∞^E.
2. Do the same for q_b and concatenate. This gives a path from q_a to q_b. Every point except the endpoints lies in W_∞^E ⊂ O ∩ int P_E, since the endpoints lie on Γ ⊄ O.
3. Extract an arc α from this path. Construct β from q_c to q_d in the same way, with interior in O ∩ int P_F.
4. The arcs α and β are disjoint: their interiors lie in disjoint open half-planes, and their endpoints are four distinct points of Γ ⊂ int P_E ∪ int P_F.
5. This contradicts Lemma L2 in the closed disk Ō ∪ {∞}, whose boundary is Γ.

**Build I.**
* If G_E = ∅, put I = ∅.
* If G_F = ∅, put I = ℤ_9.
* Otherwise G_E lies in a single maximal cyclic run of ℤ_9 \ G_F. If two elements of G_E lay in different runs, they would be separated on both sides by elements of G_F, which is interleaving. Let I be that run.

**Check I.**
* For k ∈ I: q_k ∉ G_F, so q_k ∈ G_E ∪ (E ∩ F) ⊂ E.
* For k ∉ I: q_k ∉ G_E, so q_k ∈ G_F ∪ (E ∩ F) ⊂ F. ∎

## Part N — The transition disks meet E ∩ F

**Theorem N.** Assume (SH) and (NB). Let m ∈ {1, …, 8}, and suppose the boundary disks are numbered so that q_k ∈ E for 1 ≤ k ≤ m and q_k ∈ F for m + 1 ≤ k ≤ 9. Then D_1 ∩ E ∩ F ≠ ∅ and D_{m+1} ∩ E ∩ F ≠ ∅.

*Proof.* Let T ∈ {1, m+1}; call D_T a transition disk. Its two corners q_{T−1} and q_T (indices mod 9) lie one in E and the other in F:
- for T = 1: q_9 ∈ F, since 9 ≥ m + 1, and q_1 ∈ E, since 1 ≤ m;
- for T = m + 1: q_m ∈ E and q_{m+1} ∈ F, since m + 1 ≤ 9.

1. *The arc γ_T.* By Theorem J(1), γ_T is the closed sub-arc of C_T between q_{T−1} and q_T, and it lies in int D_R. Along C_T ∩ D_R, the points of D_{T−1} form the initial segment [s_T, q_{T−1}] and the points of D_{T+1} form the final segment [q_T, e_T] (Part A, "The boundary of the hole"). These segments are disjoint (Theorem J(1)). Hence no point of the relative interior γ_T° lies in D_{T−1} ∪ D_{T+1}. By (G′) (Lemma N4(c) under (NB)), γ_T ⊂ D_T meets no D_j with j ∉ {T−1, T, T+1}.
2. *γ_T° ⊂ E ∪ F.* Let y ∈ γ_T° and suppose y ∉ E ∪ F. The set K := E ∪ F ∪ ⋃_{j≠T} D_j is closed and misses y, and y ∈ int D_R. So some open disk N around y lies in int D_R and misses K. For small t > 0 the point y_t := c_T + (1 + t)(y − c_T) lies in N, and it is not in D_T, since |y_t − c_T| = 1 + t. So y_t ∈ D_R lies in none of the eleven disks, which contradicts the covering.
3. *γ_T ⊂ E ∪ F.* By step 2 and closedness of E ∪ F.
4. *Conclusion.* γ_T is connected and contains a point of E and a point of F. If γ_T ∩ E ∩ F were empty, γ_T would be the union of the two disjoint non-empty closed sets γ_T ∩ E and γ_T ∩ F, which is impossible. Hence γ_T ∩ E ∩ F ≠ ∅, so D_T ∩ E ∩ F ≠ ∅. ∎

## 9. The configuration solves a system Σ_m

**Definition (Σ_m).** For m ∈ {1, …, 8}, Σ_m is the following system at R = r_1.
- *Unknowns:* points c_E, c_F, c_1, …, c_9 of the plane. Put E = D(c_E), F = D(c_F), D_k = D(c_k), with indices mod 9.
- (P0) |c_E| ≤ 1.
- (a) R − 1 ≤ |c_k| ≤ √(R² − 1) for k = 1, …, 9.
- (b) The polar angles lift to θ_1 < θ_2 < … < θ_9 < θ_1 + 2π, with θ_{k+1} − θ_k ≤ w_k + w_{k+1} for k = 1, …, 9. Here θ_10 := θ_1 + 2π, w_10 := w_1, and w_k ∈ [0, π] is defined by cos w_k = (R² + |c_k|² − 1)/(2R|c_k|).
- (c) D_k ∩ D_{k+1} ∩ E ≠ ∅ for 1 ≤ k ≤ m, and D_k ∩ D_{k+1} ∩ F ≠ ∅ for m + 1 ≤ k ≤ 9.
- (d) D_1 ∩ E ∩ F ≠ ∅ and D_{m+1} ∩ E ∩ F ≠ ∅.

**Proposition 9.1.** Assume a covering of the claim's type with R ≥ r_1 exists. Then for some m ∈ {1, …, 8}, Σ_m has a solution.

*Proof.*
1. *Normalise.* By Lemmas R1 and R2 there is a configuration satisfying (SH). This gives (a), and the naming of (SH) gives (P0).
2. *Order.* By Lemma R3(1)–(2) (after the reflection fixed in (SH), if needed), (b) holds with the w_k of Lemma R3(1).
3. *Two runs.* (NB) holds by Theorem NB. By Theorem O2 there is a cyclic interval I ⊆ ℤ_9 with q_k ∈ E for k ∈ I and q_k ∈ F for k ∉ I.
4. *m is not 0 or 9.* By Corollary K1, neither inner disk contains all nine corners. So I ≠ ℤ_9 (else E would contain all of them) and I ≠ ∅ (else F would). Put m := |I| ∈ {1, …, 8}.
5. *Renumber.* Shift the indices of the boundary disks cyclically so that I = {1, …, m}. Re-lift the angles so that θ_1 is the angle of the new D_1. All of (SH), (NB), Lemma R3 and the results of Parts A, B, N are invariant under a cyclic shift of the indices, so (a) and (b) still hold.
6. *(c).* By Lemma A2, q_k ∈ ∂D_k ∩ ∂D_{k+1} ⊂ D_k ∩ D_{k+1}. Also q_k ∈ E for k ≤ m and q_k ∈ F for k ≥ m + 1.
7. *(d).* By Theorem N.

So (c_E, c_F, c_1, …, c_9) solves Σ_m. ∎

Remark. Proposition 9.1 uses the covering hypothesis many times. Σ_m itself only records consequences of it.

## Part W — Witness angles: reduction of Σ_m to convex systems

Notation: R = r_1, a = arcsin(1/R), ρ_max = √(R² − 1), and s(φ) = R(cos φ, sin φ).

**The angle polytope.** Φ is the set of vectors φ = (φ_0, …, φ_9) with
- φ_0 = 0 and φ_9 = 2π;
- 0 ≤ Δ_k := φ_k − φ_{k−1} ≤ 2a for k = 1, …, 9.

Every φ ∈ Φ has 0 ≤ φ_1 ≤ … ≤ φ_8 ≤ 2π < 7.

### Lemma W (outer witness points)
Let (c_E, c_F, c_1, …, c_9) solve Σ_m. Then, after a rotation of the whole configuration about 0, there is φ ∈ Φ with

  |c_k − s(φ_{k−1})| ≤ 1 and |c_k − s(φ_k)| ≤ 1 for k = 1, …, 9.

*Proof.*
1. *Half-widths.* By (a), (R − |c_k|)² ≤ 1, so the w_k of (b) are well defined. As in Lemma R3(1), cos w_k ≥ √(R² − 1)/R by AM–GM, so 0 ≤ w_k ≤ a. Moreover s(ψ) ∈ D_k whenever the angular distance between ψ and θ_k is ≤ w_k.
2. *Choice of φ_k.* Use the lifted angles of (b), with θ_{k+9} = θ_k + 2π and w_{k+9} = w_k. For k = 1, …, 9 choose

   φ_k ∈ [max(θ_k, θ_{k+1} − w_{k+1}), min(θ_k + w_k, θ_{k+1})].

   This interval is non-empty, because each lower end is ≤ each upper end: θ_{k+1} − w_{k+1} ≤ θ_k + w_k is (b), θ_k < θ_{k+1} is (b), and w ≥ 0.
3. *Witness property.* Put φ_0 := φ_9 − 2π. Since φ_9 ∈ [max(θ_10 − w_10, θ_9), θ_10], we get φ_0 ∈ [θ_1 − w_1, θ_1]. For every k = 1, …, 9:
   - φ_{k−1} ∈ [θ_k − w_k, θ_k], by the choice of φ_{k−1} (for k = 1, from φ_0 ∈ [θ_1 − w_1, θ_1]);
   - φ_k ∈ [θ_k, θ_k + w_k], by the choice of φ_k.

   Hence s(φ_{k−1}), s(φ_k) ∈ D_k, and 0 ≤ Δ_k ≤ 2w_k ≤ 2a. Also Σ_{k=1}^{9} Δ_k = φ_9 − φ_0 = 2π.
4. *Rotation.* Rotating the whole configuration by −φ_0 subtracts φ_0 from all angles, giving φ_0 = 0 and φ_9 = 2π. All conditions of Σ_m are invariant under rotation about 0. ∎

### Theorem C (convex reduction)
For φ ∈ Φ, let P_m(φ) be the system in the 24 unknown points c_E, c_F, c_1, …, c_9, p_1, …, p_9, t_1, t_{m+1} ∈ ℝ² below. Indices are mod 9, and X_k := c_E for k ≤ m, X_k := c_F for k ≥ m + 1.
- (P1) |c_E| ≤ 1; |c_k| ≤ ρ_max for k = 1, …, 9.
- (P2) |c_k − s(φ_{k−1})| ≤ 1 and |c_k − s(φ_k)| ≤ 1 for k = 1, …, 9 (note s(φ_0) = s(φ_9) = (R, 0)).
- (P3) |p_k − c_k| ≤ 1, |p_k − c_{k+1}| ≤ 1, |p_k − X_k| ≤ 1 for k = 1, …, 9.
- (P4) |t_j − c_j| ≤ 1, |t_j − c_E| ≤ 1, |t_j − c_F| ≤ 1 for j ∈ {1, m+1}.

If Σ_m has a solution, then P_m(φ) is feasible for some φ ∈ Φ.

*Proof.* Rotate as in Lemma W. Then:
- (P1) is (P0) together with the upper half of (a);
- (P2) is Lemma W;
- (P3) holds with p_k a common point of D_k ∩ D_{k+1} ∩ X_k, which exists by (c);
- (P4) holds with t_j a common point of D_j ∩ E ∩ F, which exists by (d).

Note that m + 1 ∈ {2, …, 9} never equals 1. The lower half of (a) and the order conditions of (b) are simply dropped; dropping constraints only enlarges the feasible set. ∎

Every constraint of P_m(φ) has the form "norm of an affine function of the unknowns ≤ constant", so P_m(φ) is a convex (second-order-cone) feasibility system. The only non-convex data are the witness angles φ.

### The relaxed box system P̃_m(B)
Let B = Π_{k=1}^{8} [α_k, β_k] be a box of angles with β_k − α_k ≤ 3/2.

For each k = 1, …, 8 fix a vector n̂_k ∈ ℝ² (any vector) and a number h_k > 0 such that

  h_k ≤ n̂_k · s(α_k) and h_k ≤ n̂_k · s(β_k).

P̃_m(B) is the system P_m(φ), with each s(φ_k) (k = 1, …, 8) replaced by a new unknown point σ_k, and s(φ_0) = s(φ_9) replaced by one unknown σ_9, subject to:
- |σ_k| ≤ R and n̂_k · σ_k ≥ h_k (k = 1, …, 8);
- |σ_9| ≤ R and σ_9 · (1, 0) ≥ R.

The two constraints on σ_9 force σ_9 = (R, 0). In (P2), c_1 is joined to σ_9 (as s(φ_0)) and to σ_1, and c_9 is joined to σ_8 and to σ_9 (as s(φ_9)). The anchor bound |c_k| ≤ ρ_max may be replaced by |c_k| ≤ ρ′ for any ρ′ ≥ ρ_max; this only relaxes the system further.

**Half-plane lemma.** Let n̂ ≠ 0, let f(ψ) = n̂ · s(ψ), and let β − α ≤ π/2. If f(α) > 0 and f(β) > 0, then min_{[α,β]} f = min(f(α), f(β)).

*Proof.* f(ψ) = |n̂| R cos(ψ − ψ_0), where ψ_0 is the polar angle of n̂. On [α, β], an interior minimum of f can only occur at ψ ≡ ψ_0 + π, where f < 0. Suppose such a point ψ* lies in (α, β). Then α − ψ* ∈ (−π/2, 0), so f(α) = −|n̂| R cos(α − ψ*) < 0, a contradiction. ∎

(If n̂ = 0, no h_k > 0 can satisfy h_k ≤ n̂ · s(α_k), so the hypothesis excludes this case.)

**Corollary W1.** If φ ∈ Φ ∩ B (that is, (φ_1, …, φ_8) ∈ B) and P_m(φ) is feasible, then P̃_m(B) is feasible.

*Proof.* Put σ_k := s(φ_k) for k ≤ 8 and σ_9 := (R, 0). Then |σ_k| = R. Since 3/2 < π/2, the half-plane lemma gives n̂_k · s(φ_k) ≥ min(n̂_k · s(α_k), n̂_k · s(β_k)) ≥ h_k. ∎

**Lemma M35 (a-priori bound).** Every solution of P̃_m(B) has |x_v| ≤ 7/2 for each of its 31 unknown points x_v, when the anchor bound is any ρ′ ≤ 2.45.

*Proof.* We bound each unknown in turn:
- |c_E| ≤ 1;
- |c_k| ≤ ρ′ ≤ 2.45;
- |σ_k| ≤ R < 2.64;
- |p_k| ≤ |c_k| + 1 ≤ 3.45;
- |t_j| ≤ |c_E| + 1 ≤ 2;
- |c_F| ≤ |t_1| + 1 ≤ 3, using the constraint |t_1 − c_F| ≤ 1, which is present for every m. ∎

### Lemma D′ (dual certificate of infeasibility)
Consider a system in unknown points x_v ∈ ℝ² consisting of:
- pair constraints |x_{a(e)} − x_{b(e)}| ≤ 1 (e ∈ 𝓔);
- anchor constraints |x_{v(j)}| ≤ r_j (r_j ≥ 0, j ∈ 𝓙);
- half-plane constraints n_i · x_{v(i)} ≥ h_i (i ∈ 𝓘).

Assume every solution satisfies |x_v| ≤ M for all v. Take any vectors y_e, z_j ∈ ℝ² and scalars μ_i ≥ 0. Put

  g_v = Σ_{e: a(e)=v} y_e − Σ_{e: b(e)=v} y_e + Σ_{j: v(j)=v} z_j − Σ_{i: v(i)=v} μ_i n_i,

  V := Σ_e |y_e| + Σ_j r_j |z_j| − Σ_i μ_i h_i + M Σ_v |g_v|.

If V < 0, the system has no solution.

*Proof.* Let x be a solution. By Cauchy–Schwarz:
- y_e · (x_{a(e)} − x_{b(e)}) ≤ |y_e|;
- z_j · x_{v(j)} ≤ r_j |z_j|;
- −μ_i n_i · x_{v(i)} ≤ −μ_i h_i, since μ_i ≥ 0.

Summing, Σ_v g_v · x_v ≤ Σ|y_e| + Σ r_j|z_j| − Σ μ_i h_i. On the other hand Σ_v g_v · x_v ≥ −M Σ_v |g_v|. Together these give V ≥ 0. ∎

The multipliers need not be optimal or come from any particular solver. In the computation they are read off an approximate minimiser x of the penalty

  ½Σ(|x_a − x_b| − 1)₊² + ½Σ(|x_v| − r_j)₊² + ½Σ(h_i − n_i · x_v)₊²,

as its partial gradients.

**Corollary W2 (what the computation must show).** Fix m. Suppose there is a finite family of boxes such that:
- the boxes cover the set {(φ_1, …, φ_8) : φ ∈ Φ};
- for each box B, either no φ ∈ Φ has (φ_1, …, φ_8) ∈ B, or there are data n̂_k, h_k as above and multipliers with V < 0 for P̃_m(B) (with M = 7/2).

Then Σ_m has no solution.

*Proof.* Combine Theorem C, Corollary W1, Lemma M35 and Lemma D′. ∎

## 11. Computation C2: no Σ_m has a solution at R = 26317/10000

### 11.1 The exact checker
The checker is `wit_exact_m.py` (Appendix 3). It imports `ms5_witness_m.py` (Appendix 2) as `W`, and uses `W` for exactly four things:
- the index layout of the 31 unknown points;
- the constraint list `W.static_constraints` (pairs of indices only, no numbers);
- the starting point `W.initial_x`;
- the float penalty minimiser `W.minimize`.

The split label m is read from the environment variable `MSPLIT`.

**Unknowns and constraints.** The unknown points are numbered: c_E = 0, c_F = 1, c_k = 1 + k, p_k = 10 + k, t_1 = 20, t_{m+1} = 21 (named `T6` in the code), σ_k = 21 + k. The pair constraints for MSPLIT = m are exactly those of Theorem C:
- (P2): (c_k, σ_{k−1}) with σ_0 ≡ σ_9, and (c_k, σ_k);
- (P3): (p_k, c_k), (p_k, c_{k+1}), and (p_k, c_E) if k ≤ m, else (p_k, c_F);
- (P4): (t_1, c_1), (t_1, c_E), (t_1, c_F), (t_{m+1}, c_{m+1}), (t_{m+1}, c_E), (t_{m+1}, c_F).

That is 51 pairs. In addition, the exact checker uses these anchors and half-planes:
- |c_E| ≤ 1;
- |c_k| ≤ RHO, where RHO is a rational upper bound of √(R² − 1);
- |σ_k| ≤ R, for k = 1, …, 9;
- the half-planes of P̃_m(B).

The driver `run_exact_m.py` (Appendix 4) re-transcribes the 51 pairs independently from Theorem C for the given m. It compares them with `W.static_constraints`, refuses to run under `python -O` (assertions are load-bearing), checks 1 ≤ MSPLIT ≤ 8, prints MSPLIT, and then calls the checker's `main()` unchanged.

**Exact arithmetic.** Every load-bearing quantity is an exact rational (`fractions.Fraction`). Specifically:
- R = 26317/10000 exactly.
- *π.* An enclosure PI_LO ≤ π ≤ PI_HI from Machin's formula π = 16 arctan(1/5) − 4 arctan(1/239). The alternating series are summed exactly, and the first omitted term bounds the error, so the width is < 10⁻⁸⁵. Then TPL = 2·PI_LO ≤ 2π ≤ TPH = 2·PI_HI. As a separate check, PI_LO ≤ π ≤ PI_HI was confirmed against 100 decimals of π (π − PI_LO ≈ 6.9·10⁻⁸⁶, PI_HI − π ≈ 1.3·10⁻⁸⁷). The header line of each log prints `float(PI_LO)`, `float(PI_HI)`; both are the double 3.14159265358979311… This printout is cosmetic only and not used.
- *sin and cos.* Rigorous enclosures at rational t ∈ [0, 8] (`sincos`):
  - Taylor polynomial of degree 79;
  - each term tⁿ/n! enclosed by floor/ceiling to 2⁻²⁰⁰ (valid since t ≥ 0);
  - Lagrange remainder bounded by t⁸⁰/80! (≈ 10⁻⁴⁷ at t = 8).
- *a.* A := 2a′, where a′ is a rational with sin a′ > 1/R (checked with the lower Taylor bound) and a′ < PI_LO/2. Since a′ ∈ (0, π/2), this gives a′ > arcsin(1/R) and A ≥ 2a.
- *Square roots.* `sqrt_up(q)` = (isqrt(abK²) + 1)/(bK) ≥ √q for q = a/b, with K = 2⁶⁴. RHO = sqrt_up(R² − 1) ≥ ρ_max. M = 7/2.

**Branch and bound.**
- *Root.* The root box is φ_1, …, φ_8 ∈ [0, 7], with φ_0 = 0 and φ_9 ∈ [TPL, TPH]. It contains every φ ∈ Φ.
- *Propagation.* Each box is first propagated exactly. The updates are:
  - lo_k ← max(lo_k, lo_{k−1}) and hi_k ← min(hi_k, hi_{k−1} + A), for k = 1, …, 8;
  - hi_k ← min(hi_k, hi_{k+1}) and lo_k ← max(lo_k, lo_{k+1} − A), for k = 8, …, 1;
  - four sweeps.

  Each update keeps every φ ∈ Φ in the box. The box is declared **empty** if, for some k ∈ {1, …, 9}, lo_k > hi_k, or lo_k > hi_{k−1} + A, or hi_k < lo_{k−1}. Each of these is impossible for φ ∈ Φ.
- *Root splitting.* The propagated root is bisected (widest coordinate, exact midpoint) into 4096 root boxes, which together cover it.
- *Box test.* Each box is propagated and then either:
  - declared **empty**; or
  - **certified**, if all of the following hold: every width is ≤ 3/2; for k = 1, …, 8, with n̂_k the rational value of the float vector (cos m_k, sin m_k) (m_k the float midpoint), the number h_k = min over t ∈ {lo_k, hi_k} of R·(min(n_x·clo, n_x·chi) + min(n_y·slo, n_y·shi)) is > 0 (here [clo, chi] ∋ cos t and [slo, shi] ∋ sin t are the rigorous enclosures), so h_k ≤ n̂_k·s(t) at both ends; and V of Lemma D′, computed exactly (`V_exact`), is < 0. In `V_exact`:
    - the multipliers y_e, z_j, μ_i are the rationals of floats read off the float penalty minimiser;
    - each |y| is replaced by an exact upper bound `sqrt_up(|y|²)`;
    - the net forces g_v are accumulated exactly, with the signs of Lemma D′;
    - the term M|g_v| is replaced by (7/2)·`sqrt_up(|g_v|²)`;

  so the computed number is ≥ V; or
  - otherwise **bisected** at the exact midpoint of its widest coordinate. The two children cover the parent.
- *Failure.* A box narrower than 10⁻⁷ that is still open, or exceeding the box budget, is recorded as a failure.
- *Success line.* `EXACT RESULT R=…: ALL BOXES CERTIFIED` is printed only if no failure was recorded in any of the 4096 subtrees. A worker exception aborts the run before this line.

**Soundness.** Suppose a run prints the success line for MSPLIT = m. Then the leaves of the 4096 trees cover the propagated root, and every leaf is empty or certified. By Corollary W2, Σ_m has no solution. The argument uses only:
- the exactness of Python's integer and `Fraction` arithmetic and of `math.isqrt`;
- correct execution of the program text.

Floats are used only to choose n̂_k, the multipliers, the starting point and the minimiser. Lemma D′ and the half-plane lemma admit every such choice, and non-finite floats make `Fraction(…)` raise, which aborts the run. **No IEEE or libm assumption enters.**

### 11.2 Results
All runs used CPython 3.12.9 on Linux.

The command was `MSPLIT=m python3 run_exact_m.py 2.6317 <nproc> 4096`. Here `run_exact_m.py` lives in `judge/r13/`, and it imports `wit_exact_m.py` and `ms5_witness_m.py` from `../r12/` relative to itself (its `sys.path` line). The equivalent direct command is `MSPLIT=m python3 wit_exact_m.py 2.6317 <nproc> 4096`.

| m | boxes | empty | certified | failures | final line |
|---|---|---|---|---|---|
| 1, 2, 3, 6, 7, 8 (each) | 4096 | 3272 | 824 | 0 | EXACT RESULT R=2.6317: ALL BOXES CERTIFIED (exact rational check) |
| 4 | 5384 | 3272 | 1468 | 0 | same |
| 5 | 4900 | 3272 | 1226 | 0 | same |

Each run's first line printed `JUDGE-R13 MSPLIT=m optimize=0; constraint list = Theorem C for m=m (51 pairs); E-links 1..m, T6 on D_{m+1}`.

The counts are consistent with complete bisection trees. For m = 5: 4900 = 4096 + 2·402 boxes, and 3272 + 1226 = 4498 = 4096 + 402 leaves. For m = 4: 5384 = 4096 + 2·644 boxes, and 4740 = 4096 + 644 leaves.

Every run was repeated with identical counts: an earlier run of `wit_exact(_m).py` for every m, and a third run for m = 5.

Log files on the machine where the runs were made, all under `/home/skim/projects/research/circovcir/experiments/2026-10-20-siege-n11-b9/out/judge/`:
- `r13/exact_m1.log` … `r13/exact_m8.log`;
- `r12/witm_exact_m*.log` and `r12/wit_exact_26317.log` (earlier runs);
- `r12/orch/re_exact_m5.log` (third run for m = 5).

The programs are in `r12/` (`ms5_witness.py`, `ms5_witness_m.py`, `wit_exact.py`, `wit_exact_m.py`) and `r13/run_exact_m.py`.

### 11.3 Cross-checks (not part of the proof)
- **Float program.** The float program `ms5_witness.py` (m = 5) and `ms5_witness_m.py` (other m) independently printed `RESULT R=2.6317: ALL BOXES CERTIFIED` for every m ∈ {1, …, 8}. It uses outward-rounded floats and assumes libm sin and cos accurate to 10⁻¹⁵. It runs the same kind of tree with different root splits.
- **Sanity below R_*.** Below R_* the Melissen configuration (F5) solves Σ_m (with m = 5 in the naming E = F5 disk 1, and with m = 4 in the swapped naming E = F5 disk 2). So no box containing its witness vector may be certified there.
  - The exact box test left boxes of half-width 10⁻⁹, 10⁻⁶ and 10⁻⁴ about the reference witness vector open, at R = 2.6316 and R = 2.63169, for m = 5 and for the swapped naming with m = 4.
  - The full float branch and bound over the half-width-0.02 box about the reference ended NOT CERTIFIED at R = 2.6316 and R = 2.63169, as it must.
  - At r_1 = 2.6317 the float program certifies the half-width-10⁻³ box about the same point in a single test.
- **Independent exact re-implementation (certificate 22c, §13a).** A Mathematica program written from Part W (not from `wit_exact.py`) certifies Σ_m infeasible at R = 26317/10000 for every m = 1, …, 8, with zero failures; its sanity tests reproduce the two items above (the Melissen boxes stay open at R = 2.6316; the half-width-10⁻³ box is certified at R = 2.6317 in one test).

### 11.4 How to re-run
1. Save Appendix 2 as `ms5_witness.py`. Create `ms5_witness_m.py` from it by applying the diff in Appendix 2.
2. Save Appendix 3 as `wit_exact.py`. Create `wit_exact_m.py` from it by changing `import ms5_witness as W` to `import ms5_witness_m as W`.
3. For m = 1, …, 8 run `MSPLIT=m python3 wit_exact_m.py 2.6317 <nproc> 4096`, or the driver of Appendix 4 with its `sys.path` line adjusted. The run for m = 4 took about 9–13 minutes on 4 processes; the others took 2.5–6 minutes.

Only the Python 3 standard library is needed.

## 12. Conclusion

Suppose some covering of the claim's type had R ≥ r_1. Then:
1. By Proposition 9.1, Σ_m has a solution for some m ∈ {1, …, 8}.
2. By §11 (computation C2, through Corollary W2), Σ_m has no solution for any m ∈ {1, …, 8}.

This is a contradiction. Hence every covering of D_R by eleven unit disks with exactly nine of them meeting S_R has R < r_1 = 2.6317. ∎

**What the argument rests on, restated:**
- *Ten-disk result.* (T10), used in Lemma R1 and Lemma A5.
- *Problem facts.* F1 and F3.
- *Computation C1.* For Theorem NB: certificate 22b (Mathematica bignum intervals, exact rational decisions, no IEEE/libm assumption); independently `nb_check.py` under IEEE and libm-accuracy assumptions.
- *Computation C2.* The exact checker, run for m = 1, …, 8; independently certificate 22c.
- *Faithfulness of the runs.* That the logged runs executed the programs reproduced in the appendices.
- *Standard topology.* The Jordan curve theorem and the Schoenflies theorem (cited as standard theorems), used in Parts B and O; the crossing Lemma L2 is derived from them in Part O.

Two earlier independent verifications re-derived the whole chain step by step and found no fatal gap, only the slips repaired above:
- the forward-overlap step, now proved in Lemma R3(2);
- the "same centres" wording of the R = r_1 reduction, now Lemma R1;
- Repairs M1–M3 of Part M.

An adversarial audit of the witness programs found no soundness defect. Its process remarks (MSPLIT not logged; assertions disabled under −O; constraint list not independently checked; no m ≠ 5 sanity test) are closed by the driver of Appendix 4 and by the sanity runs of §11.3.

## 13. Gaps and caveats (honest list)

1. **Dependency (T10).** The ten-disk result is quoted from the problem's context, not proved here. Without it, two steps fail:
   - Lemma R1 (the reduction to R = r_1);
   - Lemma A5, and with it Corollary K1 (m ∉ {0, 9}) and c_E ≠ c_F in Lemma C1, both needed by Part O.
2. **Floating-point assumption in Theorem NB — closed.** `nb_check.py` alone is sound only if (i) IEEE double arithmetic is correctly rounded for + − × ÷ √, and (ii) libm asin, acos, atan, sin, cos are accurate to within 10⁻¹² on the arguments used. Certificate 22b (§13a) re-proves the same finite statement without either assumption. What remains is trust in software: Mathematica 14.3's bignum `Interval` (22a–22c) and CPython (C1, C2).
3. **Runs not independently re-executed by a third party.** C1 was run once in Python; 22b once in Mathematica. C2 was run two or three times per m, and 22c twice, by the same party on the same machine, with identical counts.
4. **Lemma L2** (crossing of interleaved cross-cuts in a closed topological disk) is a standard topological fact, cited rather than proved.

No other gap is known. Every hand inequality has a margin of at least 8·10⁻⁴; the tightest are Lemma 4.2 of Part M, C(1.36) − 0.0406642 = 0.00089, and Lemma 1.3 of Part M, C(1.085) − B = 0.00135. Each is far larger than the error of the hand series used, and every one is re-checked in 50-digit interval arithmetic by certificate 22a (§13a). While this document was written, the following constants were recomputed in double precision and agree with the text: a, d, B, π − 8a, 2π − 10a, 4d + 6a, C(1.085), C(1.2) + C(1.35), C(1.36), C(1.3683), ρ(B/2), ρ(0.03), the two G-bounds of Lemma 3.1, the bounds of Lemmas 2.1, 2.2 and 4.2 of Part M, ρ_lo·sin(2a − B) in Lemma E3.2, and u* in Lemma E2.2.

## 13a. Independent Mathematica verification (certificates 22a–22c)

Three Wolfram Language certificates, written from the mathematical statements of this document and not by translating the Python programs, re-check every computational ingredient. Scripts: `proofs/certificates/22a-n11-b9-hand-constants.wls`, `22b-n11-b9-nobridge.wls`, `22c-n11-b9-witness.wls` in the repository; logs in `experiments/2026-10-20-siege-n11-b9/results/wl/`; write-up `proofs/22-n11-b9-wl-recheck.md`. R = 26317/10000 exactly throughout.

- **22a — hand constants.** All 223 numerical claims of the original text (values, inequalities, identities) were decided in 50-digit interval arithmetic with exact rational comparisons. 194 held as written; 29 were slips in the last printed digit or wording, none load-bearing. The text above has been corrected (21 edits, no change of argument), and the 46 corrected statements were re-checked: all true. The three notable corrections: the case split of Lemma 3.1(d) now covers the whole [0.03, B/2] (B/2 = 0.06033107 > 0.060331); the tightest hand margin is 8.98·10⁻⁴ (Lemma 4.2 of Part M), not ≥ 10⁻³; the explanatory remark "three corners at radius ≤ 1.38 cost more than B" in the §4 Addendum was false (3C(1.38) < B) and has been rewritten — it is not used. Run: ~7 s, `22a ALL HAND CONSTANTS VERIFIED`.
- **22b — computation C1 (Theorem NB).** 20-digit bignum `Interval` for √, arcsin, arccos, arctan, sin, cos; exact rational box endpoints and decisions (machine-precision `Interval` is deliberately not used: in Mathematica 14.3 its ArcCos/ArcTan are not outward-rounded). Self-tests: 2000 random boxes × 8 functions plus 500 arctan arguments against 50-digit values; reference values of B, C(1.085), ρ(B/2); two negative controls that must fail (and do). 48 K_X slices, one bisected once; all 49 leaves OK; leaves tile [0, B.hi]. A surviving box of width < 10⁻¹⁰ is reported as "not refuted" (conservative). Run: 45.6 min on 6 subkernels, `22b ALL SLICES VERIFIED`.
- **22c — computation C2 (Σ_m, m = 1, …, 8).** Own branch-and-bound tree on [0,7]⁸ with exact constraint propagation, 512 root boxes per m; multipliers from the dual SOCP of Lemma D′ (residual g charged at M = 7/2); V < 0 decided in exact rationals, with half-plane offsets from 30-digit bignum Cos/Sin rounded down to a 2⁻⁸⁰ grid. Every m certified with zero failures (m = 4: 1468 boxes, m = 5: 1046, others 512). Sanity: the Melissen witness boxes (half-width 10⁻⁶, 10⁻⁴) stay open at R = 2.6316; the half-width-10⁻³ box is certified at R = 2.6317. Run: 3.4 min on 3 subkernels, `22c ALL m CERTIFIED`; a second run gave identical counts.

Consequence: each finite computation of the proof now has two independent implementations. For C1, 22b uses no floating-point assumption; for C2, both implementations (`wit_exact_m.py` and 22c) are exact. The hand argument itself is not checked by these certificates.

## 14. Other routes (recorded, not used)

- **Local results around Melissen's configuration.**
  - Theorem B, an outward-rounded interval reduction (independently audited). It shows that no covering with R ≥ r_1 has all centres within 6·10⁻⁴ of the F5 decimals, after symmetry.
  - Theorem LT, a second-order tube bound (not audited). It gives the same conclusion within 1.25·10⁻³.

  Neither is needed by the witness route.
- **Excluding the splits m ≠ 5 by hand and by corner relaxations.** Before the witness reduction, other splits were excluded as follows:
  - m ≤ 4 by a cone inequality (Theorem Q) together with the naming lemma (|c_F| > 1 when m ≤ 4);
  - m = 7, 8 by a gap–depth lemma (Lemma H: an inner disk with centre modulus ≤ 0.12 / 0.16 cannot hold 7 / 8 consecutive corners) plus corner-relaxation interval runs;
  - m = 6 by exact-edge interval runs.

  Those programs were not audited, and the witness route makes them unnecessary.
- **The dual route.** This was a separable angle-form Lagrangian duality for split 5 with interface-dependent multipliers (Conjecture D). It produced certified exclusions on parts of the interface space, but no complete proof. Its fixed-multiplier variant (negative definiteness of the Lagrangian Hessian at λ^A) is false: float runs show an eigenvalue +0.0212.
- **Refuted statements (dead ends).**
  - "In a chain of nearly full boundary disks, free corners two apart are more than 2 apart." This is false: an explicit configuration within the bridge budget has distance ≈ 1.941.
  - A one-dimensional monotone-state chain reduction of split 5.
  - "arg q_k lies between θ_k and θ_{k+1}" in general. (It is true for good corners of a nearly full chain, Lemma E3.2.)
  - The "tight-face" conjecture that all 18 link slacks vanish near the reference.
- **The F6 route** (localising every covering to within 8·10⁻⁹ of F5) was not completed. The global localisation programs designed for it were sound on paper but far too slow.

---

# Appendices: program texts (verbatim)

The following files were executed. Comments inside the programs mention labels of the internal work log of this attempt (e.g. "round4_q3", "judge r13"). They are bookkeeping only; nothing in the proof depends on them, and the programs are reproduced unchanged so that they can be re-run byte for byte. Appendix 2 is `ms5_witness.py`; `ms5_witness_m.py` differs from it only by the diff shown. Appendix 3 is `wit_exact.py`; `wit_exact_m.py` differs only in its import line.

## Appendix 1 — `nb_check.py` (computation C1) and its driver `nb_par.py`

```python
#!/usr/bin/env python3
"""nb_check.py -- round4_q3 (MS-NB), check of cases (FAR) and (NEAR-Y) of Section 4.
Standard library only, Python >= 3.9 (math.nextafter). Prints 'ALL CASES VERIFIED' on success."""
import math, heapq, sys, time
from fractions import Fraction

INF = math.inf
def dn(x): return math.nextafter(x, -INF)
def up(x): return math.nextafter(x, INF)
LIBM = 1e-12  # widening of libm results (assumed libm error < 1e-13)

class Iv:
    __slots__ = ("lo", "hi")
    def __init__(self, lo, hi):
        if not (lo <= hi):
            raise ValueError("bad interval %r %r" % (lo, hi))
        self.lo = lo; self.hi = hi
    def __repr__(self):
        return "[%.17g, %.17g]" % (self.lo, self.hi)

def P(x): return Iv(x, x)                     # exactly representable float
def from_fraction(fr):
    f = float(fr)                             # correctly rounded
    return Iv(dn(f), up(f))
def add(a, b): return Iv(dn(a.lo + b.lo), up(a.hi + b.hi))
def sub(a, b): return Iv(dn(a.lo - b.hi), up(a.hi - b.lo))
def mul(a, b):
    p = (a.lo * b.lo, a.lo * b.hi, a.hi * b.lo, a.hi * b.hi)
    return Iv(dn(min(p)), up(max(p)))
def div(a, b):
    if not b.lo > 0.0: raise ValueError("div")
    p = (a.lo / b.lo, a.lo / b.hi, a.hi / b.lo, a.hi / b.hi)
    return Iv(dn(min(p)), up(max(p)))
def sqr(a):
    if a.lo >= 0.0: return Iv(dn(a.lo * a.lo), up(a.hi * a.hi))
    if a.hi <= 0.0: return Iv(dn(a.hi * a.hi), up(a.lo * a.lo))
    return Iv(0.0, up(max(a.lo * a.lo, a.hi * a.hi)))
def isqrt(a):
    if a.hi < 0.0: return None
    lo = max(a.lo, 0.0)
    return Iv(max(0.0, dn(math.sqrt(lo))), up(math.sqrt(a.hi)))
def iasin(a):
    lo = max(a.lo, -1.0); hi = min(a.hi, 1.0)
    return Iv(math.asin(lo) - LIBM, math.asin(hi) + LIBM)
def iatan(a): return Iv(math.atan(a.lo) - LIBM, math.atan(a.hi) + LIBM)
def isin_q1(a):
    assert 0.0 <= a.lo and a.hi <= 1.5
    return Iv(math.sin(a.lo) - LIBM, math.sin(a.hi) + LIBM)
def icos_q1(a):
    assert 0.0 <= a.lo and a.hi <= 1.5
    return Iv(math.cos(a.hi) - LIBM, math.cos(a.lo) + LIBM)

# ---------------- constants ----------------
R = from_fraction(Fraction(26317, 10000))
ONE, TWO, THREE, FOUR = P(1.0), P(2.0), P(3.0), P(4.0)
PI = Iv(math.pi, up(math.pi))                  # math.pi < pi < nextafter(math.pi)
TWO_PI = Iv(2.0 * math.pi, 2.0 * up(math.pi))
A_ = iasin(div(ONE, R))                        # a(R)
D_ = iasin(div(TWO, R))                        # d(R)
B_ = add(sub(mul(P(12.0), A_), TWO_PI), mul(TWO, D_))
BHI = B_.hi                                    # upper bound of the bridge budget B
BHALF = BHI / 2.0
SIXA = mul(P(6.0), A_); FOURA = mul(FOUR, A_); TWOA = mul(TWO, A_)
RHO0 = sub(R, TWO)                             # R - 2
U0 = sub(THREE, R)                             # 3 - R = 1 - rho0
RM1 = sub(R, ONE)                              # R - 1
TSTAR = sub(R, div(TWO, R))                    # R - 2/R
TMIN, TMAX = 1.0, dn(R.lo)

# ---------------- geometric bounds ----------------
def A_up(t, u):
    """Upper bound over the box of A(t,u) = arccos((t^2+u^2-1)/(2tu)); None if no point of the
    box has |t-u| <= 1 (then the point at radius t is in no unit disk centred at radius u)."""
    N = sub(add(sqr(t), sqr(u)), ONE)
    D = mul(mul(TWO, t), u)
    Dlo = D.lo if D.lo > 0.0 else 0.0
    if N.lo > 0.0:
        if not D.hi > 0.0: return None
        c = dn(N.lo / D.hi)
    elif Dlo > 0.0:
        c = dn(N.lo / Dlo)
    else:
        return PI.hi
    if c > 1.0: return None
    if c <= -1.0: return PI.hi
    return min(PI.hi, math.acos(c) + LIBM)

def C_lo(t):
    """Lower bound of C(t) = 2a - 2 arctan( sqrt(4-(R-t)^2)/(R+t) ) over the box."""
    q = sub(FOUR, sqr(sub(R, t)))
    s = isqrt(q)
    if s is None: return None
    z = div(s, add(R, t))
    return sub(TWOA, mul(TWO, iatan(z))).lo

def rho_lo(dmax):
    """Lower bound of the inner-branch centre radius for all deficits d <= dmax."""
    wl = max(sub(A_, P(dmax)).lo, 0.0)
    W = P(wl)
    s = isin_q1(W); c = icos_q1(W)
    inner = sub(ONE, mul(sqr(R), sqr(s)))
    sq = isqrt(inner)
    if sq is None: return None
    return sub(mul(R, c), sq).lo

def M_up(t, kmax):
    """Upper bound of M(t,kappa) for kappa <= kmax; None if infeasible."""
    if kmax < 0.0: return None
    dmax = min(kmax, BHALF)
    rl = rho_lo(dmax)
    if rl is None: return None
    RL = P(rl)
    if sqr(t).hi <= add(sqr(RL), ONE).lo:
        return A_up(t, RL)
    return iasin(div(ONE, t)).hi

def C2_lo(u):
    """Lower bound of the cost of Q2 (t2 <= 1+u)."""
    th = up(1.0 + u.hi)
    if th <= TSTAR.lo:
        c = C_lo(P(th))
        return max(0.0, c) if c is not None else 0.0
    return 0.0

# ---------------- evaluators ----------------
def eval_X(box, Khi, want):
    u, t1, t3, k3 = box
    c3 = C_lo(t3)
    if c3 is None or c3 > k3.hi: return None
    c2 = C2_lo(u)
    k1max = up(up(Khi - k3.lo) - c2)
    if k1max < 0.0: return None
    c1 = C_lo(t1)
    if c1 is None or c1 > k1max: return None
    A1 = A_up(t1, u)
    if A1 is None: return None
    A3 = A_up(t3, u)
    if A3 is None: return None
    M1 = M_up(t1, k1max)
    if M1 is None: return None
    M3 = M_up(t3, k3.hi)
    if M3 is None: return None
    lhs = dn(dn(dn(SIXA.lo - Khi) - M1) - M3)
    rhs = up(A1 + A3)
    if lhs > rhs: return None
    if want == "slack": return up(rhs - lhs)
    al = A_up(RHO0, u)
    return up(up(al + A3) + M3)

def eval_Y(box, KY, want):
    v, t4, k4, t5 = box
    c4 = C_lo(t4)
    if c4 is None or c4 > k4.hi: return None
    k5max = up(KY - k4.lo)
    if k5max < 0.0: return None
    c5 = C_lo(t5)
    if c5 is None or c5 > k5max: return None
    A4 = A_up(t4, v)
    if A4 is None: return None
    A5 = A_up(t5, v)
    if A5 is None: return None
    M4 = M_up(t4, k4.hi)
    if M4 is None: return None
    M5 = M_up(t5, k5max)
    if M5 is None: return None
    lhs = dn(dn(dn(FOURA.lo - KY) - M4) - M5)
    rhs = up(A4 + A5)
    if lhs > rhs: return None
    if want == "slack": return up(rhs - lhs)
    al = A_up(RHO0, v)
    return up(up(al + A4) + M4)

SCALE_X = (1.0, 1.0, 1.0, 0.1)     # u, t1, t3, k3
SCALE_Y = (1.0, 1.0, 0.1, 1.0)     # v, t4, k4, t5
def split(box, scale):
    j = max(range(len(box)), key=lambda i: (box[i].hi - box[i].lo) / scale[i])
    m = 0.5 * (box[j].lo + box[j].hi)
    l = list(box); r = list(box)
    l[j] = Iv(box[j].lo, m); r[j] = Iv(m, box[j].hi)
    return tuple(l), tuple(r)

def upper_bound(evalf, root, K, scale, cap):
    """Valid upper bound of the objective over the feasible part of root (-inf if empty)."""
    v = evalf(root, K, "obj")
    if v is None: return -INF
    heap = [(-v, 0, root)]; cnt = 0
    for _ in range(cap):
        if not heap: return -INF
        _, _, box = heapq.heappop(heap)
        for ch in split(box, scale):
            w = evalf(ch, K, "obj")
            if w is not None:
                cnt += 1; heapq.heappush(heap, (-w, cnt, ch))
    return -heap[0][0] if heap else -INF

def refute(evalf, root, K, scale, want, T, cap):
    """True if proved that no feasible point of root has value >= T."""
    stack = [root]; n = 0
    while stack:
        box = stack.pop(); n += 1
        if n > cap: return False
        v = evalf(box, K, want)
        if v is None or v < T: continue
        stack.extend(split(box, scale))
    return True

def X_root(): return (Iv(U0.lo, RM1.hi), Iv(TMIN, TMAX), Iv(TMIN, TMAX), Iv(0.0, BHI))
def Y_root_far(): return (Iv(U0.lo, RM1.hi), Iv(TMIN, TMAX), Iv(0.0, BHI), Iv(TMIN, TMAX))
def Y_root_near(): return (Iv(0.0, U0.hi), Iv(TMIN, TMAX), Iv(0.0, BHI), Iv(TMIN, TMAX))

CAP_UB, CAP_REF, MAXDEPTH = 60000, 3000000, 9

def check_slice(Klo, Khi):
    KY = up(BHI - Klo)
    # (FAR): u, v > 3 - R, condition (S)
    UY = upper_bound(eval_Y, Y_root_far(), KY, SCALE_Y, CAP_UB)
    if UY > -INF:
        T = dn(TWO_PI.lo - UY)
        if not refute(eval_X, X_root(), Khi, SCALE_X, "obj", T, CAP_REF):
            return "FAR (U_Y=%.6f)" % UY
    # (NEAR-Y): v <= 3 - R, no (S)
    if not refute(eval_Y, Y_root_near(), KY, SCALE_Y, "slack", 0.0, CAP_REF):
        if not refute(eval_X, X_root(), Khi, SCALE_X, "slack", 0.0, CAP_REF):
            return "NEAR-Y"
    return None

def verify(Klo, Khi, depth):
    bad = check_slice(Klo, Khi)
    if bad is None:
        print("ok   K_X in [%.6f, %.6f]" % (Klo, Khi)); sys.stdout.flush()
        return True
    if depth >= MAXDEPTH:
        print("FAIL K_X in [%.8f, %.8f]: %s" % (Klo, Khi, bad)); sys.stdout.flush()
        return False
    m = 0.5 * (Klo + Khi)
    r1 = verify(Klo, m, depth + 1)
    r2 = verify(m, Khi, depth + 1)
    return r1 and r2

def main():
    t0 = time.time()
    print("a =", A_, " B =", B_, " 3-R =", U0)
    n0 = 24
    edges = [BHI * i / n0 for i in range(n0)] + [BHI]
    edges[0] = 0.0
    ok = True
    for i in range(n0):
        ok = verify(edges[i], edges[i + 1], 0) and ok
    print("time %.1f s" % (time.time() - t0))
    print("ALL CASES VERIFIED" if ok else "SOME CASES FAILED")

if __name__ == "__main__":
    main()
```

Driver `nb_par.py` (run as `python3 nb_par.py <nproc>` in the directory of `nb_check.py`):

```python
# parallel driver for nb_check.py (round4_q3): runs verify() on each of the 24 top-level K_X slices
# exactly as nb_check.main() does, in separate processes; prints per-slice results.
import sys, time, io, contextlib, multiprocessing as mp
import nb_check as N


def job(i):
    n0 = 24
    edges = [N.BHI * j / n0 for j in range(n0)] + [N.BHI]
    edges[0] = 0.0
    buf = io.StringIO()
    t0 = time.time()
    with contextlib.redirect_stdout(buf):
        ok = N.verify(edges[i], edges[i + 1], 0)
    return i, ok, time.time() - t0, buf.getvalue()


if __name__ == "__main__":
    print("a =", N.A_, " B =", N.B_, " 3-R =", N.U0, flush=True)
    nproc = int(sys.argv[1]) if len(sys.argv) > 1 else 12
    allok = True
    with mp.Pool(nproc) as p:
        for i, ok, dt, out in p.imap_unordered(job, range(24)):
            allok = allok and ok
            print(f"slice {i}: {'OK' if ok else 'FAILED'} ({dt:.0f}s)", flush=True)
            sys.stdout.write(out)
            sys.stdout.flush()
    print("ALL CASES VERIFIED" if allok else "SOME CASES FAILED", flush=True)
```

## Appendix 2 — `ms5_witness.py`, and the diff giving `ms5_witness_m.py`

```python
#!/usr/bin/env python3
"""Witness-angle branch and bound for MS-Sigma5 (round11_q4).

Branches on the 8 free witness angles phi_1..phi_8 (phi_0 = 0, phi_9 = 2*pi fixed).
For each box, the relaxed system P~(B) is convex.  It is solved by a penalty Newton method,
and its infeasibility is certified by Lemma D' with outward rounding.
"""
import math, sys, time
import multiprocessing as mp
from collections import deque

INF = float('inf')
def ru(x): return math.nextafter(x, INF)
def rd(x): return math.nextafter(x, -INF)

WID = 1e-15     # ASSUMED: |math.cos(t)-cos(t)|, |math.sin(t)-sin(t)| <= 1e-15 for |t| <= 8
M_BOUND = 3.5   # a-priori bound |x_v| <= 3.5 on the feasible set (see answer file)
MINW = 1e-7     # uncertified boxes narrower than this are reported as failures

def iadd(a, b): return (rd(a[0] + b[0]), ru(a[1] + b[1]))
def imul(a, b):
    p = (a[0]*b[0], a[0]*b[1], a[1]*b[0], a[1]*b[1])
    return (rd(min(p)), ru(max(p)))
def icos(t):
    c = math.cos(t); return (rd(c - WID), ru(c + WID))
def isin(t):
    s = math.sin(t); return (rd(s - WID), ru(s + WID))
def nrm_up(ax, ay):
    return ru(math.sqrt(ru(ru(ax*ax) + ru(ay*ay))))

class Params:
    def __init__(self, Rs):
        Rf = float(Rs)
        self.Rf = Rf
        self.RLO, self.RHI = rd(Rf), ru(Rf)          # RLO < R < RHI for the decimal R
        a_hi = math.asin(1.0 / Rf) + 1e-12
        inv_hi = ru(1.0 / self.RLO)                   # >= 1/R
        assert a_hi < 1.5 and rd(math.sin(a_hi) - WID) > inv_hi, "a_hi check failed"
        self.TWO_A_HI = ru(2.0 * a_hi)                # >= 2 arcsin(1/R)
        self.RHOMAX_UP = ru(math.sqrt(ru(ru(self.RHI*self.RHI) - 1.0)))
        self.TWO_PI_LO = 2.0 * math.pi                # float pi < pi; doubling exact
        self.TWO_PI_HI = ru(2.0 * math.pi)            # > 2 pi

# unknown points: cE, cF, c_1..c_9, p_1..p_9, t_1, t_6, sigma_1..sigma_9
NE, NF, T1, T6 = 0, 1, 20, 21
def C(k): return 1 + k        # 2..10
def P(k): return 10 + k       # 11..19
def S(k): return 21 + k       # 22..30
NV = 31
N = 2 * NV

def static_constraints(par):
    pairs = []
    for k in range(1, 10):
        km1 = 9 if k == 1 else k - 1
        pairs.append((C(k), S(km1)))
        pairs.append((C(k), S(k)))
    for k in range(1, 10):
        kp1 = 1 if k == 9 else k + 1
        X = NE if k <= 5 else NF
        pairs += [(P(k), C(k)), (P(k), C(kp1)), (P(k), X)]
    pairs += [(T1, C(1)), (T1, NE), (T1, NF), (T6, C(6)), (T6, NE), (T6, NF)]
    anchors = [(NE, 1.0)] + [(C(k), par.RHOMAX_UP) for k in range(1, 10)] \
        + [(S(k), par.RHI) for k in range(1, 10)]
    return pairs, anchors

def halfplanes(par, lo, hi):
    RI = (par.RLO, par.RHI)
    hs = []
    for k in range(1, 9):
        al, be = lo[k], hi[k]
        if not (be - al <= 1.5):
            return None
        m = 0.5 * (al + be)
        nx, ny = math.cos(m), math.sin(m)
        vals = []
        for t in (al, be):
            X = imul(RI, icos(t)); Y = imul(RI, isin(t))
            v = iadd(imul((nx, nx), X), imul((ny, ny), Y))
            vals.append(v[0])
        if min(vals) <= 0.0:
            return None
        hs.append((S(k), nx, ny, min(vals)))
    hs.append((S(9), 1.0, 0.0, par.RLO))
    return hs

def propagate(par, lo, hi):
    lo[0] = hi[0] = 0.0
    lo[9] = par.TWO_PI_LO; hi[9] = par.TWO_PI_HI
    A = par.TWO_A_HI
    for _ in range(4):
        for k in range(1, 9):
            lo[k] = max(lo[k], lo[k-1]); hi[k] = min(hi[k], ru(hi[k-1] + A))
        for k in range(8, 0, -1):
            hi[k] = min(hi[k], hi[k+1]); lo[k] = max(lo[k], rd(lo[k+1] - A))
        for k in range(1, 10):
            if lo[k] > hi[k] or lo[k] > ru(hi[k-1] + A) or hi[k] < lo[k-1]:
                return False
    return True

def initial_x(par, lo, hi):
    R = par.Rf
    x = [0.0] * N
    ang = [0.0] + [0.5 * (lo[k] + hi[k]) for k in range(1, 9)] + [2 * math.pi]
    for k in range(1, 10):
        v = S(k); x[2*v], x[2*v+1] = R * math.cos(ang[k]), R * math.sin(ang[k])
    for k in range(1, 10):
        t = 0.5 * (ang[k-1] + ang[k]); v = C(k)
        x[2*v], x[2*v+1] = (R - 0.75) * math.cos(t), (R - 0.75) * math.sin(t)
    for k in range(1, 10):
        kp1 = 1 if k == 9 else k + 1
        a, b, v = C(k), C(kp1), P(k)
        x[2*v] = 0.3 * (x[2*a] + x[2*b]); x[2*v+1] = 0.3 * (x[2*a+1] + x[2*b+1])
    return x

def evaluate(x, pairs, anchors, halves, want_h):
    g = [0.0] * N
    H = [[0.0] * N for _ in range(N)] if want_h else None
    f = 0.0
    def blk(i, j, sg, hxx, hxy, hyy):
        r0 = H[2*i]; r1 = H[2*i+1]
        r0[2*j] += sg*hxx; r0[2*j+1] += sg*hxy
        r1[2*j] += sg*hxy; r1[2*j+1] += sg*hyy
    for (a, b) in pairs:
        dx = x[2*a] - x[2*b]; dy = x[2*a+1] - x[2*b+1]
        L = math.hypot(dx, dy)
        if L > 1.0:
            w = L - 1.0; f += 0.5 * w * w
            ux, uy = dx / L, dy / L
            g[2*a] += w*ux; g[2*a+1] += w*uy; g[2*b] -= w*ux; g[2*b+1] -= w*uy
            if want_h:
                c = w / L; e = 1.0 - c
                hxx, hxy, hyy = c + e*ux*ux, e*ux*uy, c + e*uy*uy
                blk(a, a, 1.0, hxx, hxy, hyy); blk(b, b, 1.0, hxx, hxy, hyy)
                blk(a, b, -1.0, hxx, hxy, hyy); blk(b, a, -1.0, hxx, hxy, hyy)
    for (v, r) in anchors:
        dx, dy = x[2*v], x[2*v+1]
        L = math.hypot(dx, dy)
        if L > r:
            w = L - r; f += 0.5 * w * w
            ux, uy = dx / L, dy / L
            g[2*v] += w*ux; g[2*v+1] += w*uy
            if want_h:
                c = w / L; e = 1.0 - c
                blk(v, v, 1.0, c + e*ux*ux, e*ux*uy, c + e*uy*uy)
    for (v, nx, ny, h) in halves:
        s = h - (nx * x[2*v] + ny * x[2*v+1])
        if s > 0.0:
            f += 0.5 * s * s
            g[2*v] -= s * nx; g[2*v+1] -= s * ny
            if want_h:
                blk(v, v, 1.0, nx*nx, nx*ny, ny*ny)
    return f, g, H

def chol_solve(A, b):
    n = len(A)
    L = [row[:] for row in A]
    for j in range(n):
        Lj = L[j]
        s = Lj[j] - sum(Lj[k] * Lj[k] for k in range(j))
        if not (s > 0.0):
            return None
        d = math.sqrt(s); Lj[j] = d
        for i in range(j + 1, n):
            Li = L[i]
            Li[j] = (Li[j] - sum(Li[k] * Lj[k] for k in range(j))) / d
    y = [0.0] * n
    for i in range(n):
        Li = L[i]
        y[i] = (b[i] - sum(Li[k] * y[k] for k in range(i))) / Li[i]
    z = [0.0] * n
    for i in range(n - 1, -1, -1):
        z[i] = (y[i] - sum(L[k][i] * z[k] for k in range(i + 1, n))) / L[i][i]
    return z

def minimize(x, pairs, anchors, halves, maxit=300):
    f, g, H = evaluate(x, pairs, anchors, halves, True)
    for _ in range(maxit):
        if f < 1e-28:
            break
        gsum = sum(abs(t) for t in g)
        if 4.0 * M_BOUND * gsum < 0.05 * f:
            break
        gmax = max(abs(t) for t in g)
        lam = max(1e-12, min(1e-6, 1e-3 * gmax))
        for i in range(N):
            H[i][i] += lam
        d = chol_solve(H, [-t for t in g])
        if d is None:
            d = [-t for t in g]
        slope = sum(gi * di for gi, di in zip(g, d))
        if not (slope < 0.0):
            d = [-t for t in g]; slope = -sum(t * t for t in g)
        step = 1.0
        while True:
            xn = [xi + step * di for xi, di in zip(x, d)]
            fn = evaluate(xn, pairs, anchors, halves, False)[0]
            if fn <= f + 1e-4 * step * slope or step < 1e-14:
                break
            step *= 0.5
        if not (fn < f):
            break
        x = xn
        f, g, H = evaluate(x, pairs, anchors, halves, True)
    return x, f

def certificate_upper(x, pairs, anchors, halves):
    """Rigorous upper bound of V in Lemma D' for the multipliers read off x."""
    glo = [0.0] * N; ghi = [0.0] * N
    tot = 0.0
    def acc(i, val):               # val is an exact float
        glo[i] = rd(glo[i] + val); ghi[i] = ru(ghi[i] + val)
    for (a, b) in pairs:
        dx = x[2*a] - x[2*b]; dy = x[2*a+1] - x[2*b+1]
        L = math.hypot(dx, dy)
        if L > 1.0:
            w = L - 1.0; yx = w * dx / L; yy = w * dy / L
            tot = ru(tot + nrm_up(yx, yy))
            acc(2*a, yx); acc(2*a+1, yy); acc(2*b, -yx); acc(2*b+1, -yy)
    for (v, r) in anchors:
        dx, dy = x[2*v], x[2*v+1]
        L = math.hypot(dx, dy)
        if L > r:
            w = L - r; zx = w * dx / L; zy = w * dy / L
            tot = ru(tot + ru(r * nrm_up(zx, zy)))
            acc(2*v, zx); acc(2*v+1, zy)
    for (v, nx, ny, h) in halves:
        s = h - (nx * x[2*v] + ny * x[2*v+1])
        if s > 0.0:
            mu = s
            tot = ru(tot - rd(mu * h))
            for (i, nc) in ((2*v, nx), (2*v+1, ny)):
                p = -mu * nc
                glo[i] = rd(glo[i] + rd(p)); ghi[i] = ru(ghi[i] + ru(p))
    for v in range(NV):
        ax = max(abs(glo[2*v]), abs(ghi[2*v])); ay = max(abs(glo[2*v+1]), abs(ghi[2*v+1]))
        tot = ru(tot + ru(M_BOUND * nrm_up(ax, ay)))
    return tot

def try_box(par, pairs, anchors, lo, hi, x0):
    """Returns (status, x, f); status in {'empty', 'cert', 'open'}. lo, hi modified in place."""
    if not propagate(par, lo, hi):
        return 'empty', x0, None
    hs = halfplanes(par, lo, hi)
    if hs is None:
        return 'open', x0, None
    x = x0 if x0 is not None else initial_x(par, lo, hi)
    x, f = minimize(x, pairs, anchors, hs)
    if f > 0.0 and certificate_upper(x, pairs, anchors, hs) < 0.0:
        return 'cert', x, f
    return 'open', x, f

def process(par, pairs, anchors, lo, hi, maxboxes):
    stats = {'boxes': 0, 'empty': 0, 'cert': 0, 'minw': INF}
    fails = []
    stack = [(lo[:], hi[:], None)]
    while stack:
        lo, hi, x0 = stack.pop()
        stats['boxes'] += 1
        if stats['boxes'] > maxboxes:
            fails.append(('BUDGET', lo, hi)); break
        st, x, f = try_box(par, pairs, anchors, lo, hi, x0)
        if st == 'empty':
            stats['empty'] += 1; continue
        if st == 'cert':
            stats['cert'] += 1
            stats['minw'] = min(stats['minw'], max(hi[j] - lo[j] for j in range(1, 9)))
            continue
        k = max(range(1, 9), key=lambda j: hi[j] - lo[j])
        if hi[k] - lo[k] < MINW:
            fails.append(('OPEN', lo, hi, f)); continue
        m = 0.5 * (lo[k] + hi[k])
        h1 = hi[:]; h1[k] = m
        l2 = lo[:]; l2[k] = m
        stack.append((lo[:], h1, x)); stack.append((l2, hi[:], x))
    return stats, fails

def worker(args):
    Rs, lo, hi, maxboxes = args
    par = Params(Rs); pairs, anchors = static_constraints(par)
    t0 = time.time()
    st, fl = process(par, pairs, anchors, lo, hi, maxboxes)
    return st, fl, time.time() - t0

def split_roots(lo, hi, target):
    q = deque([(lo, hi)])
    while len(q) < target:
        a, b = q.popleft()
        k = max(range(1, 9), key=lambda j: b[j] - a[j])
        m = 0.5 * (a[k] + b[k])
        b1 = b[:]; b1[k] = m; a2 = a[:]; a2[k] = m
        q.append((a, b1)); q.append((a2, b))
    return list(q)

def run(Rs, lo, hi, nproc, nroots, maxboxes=10**9):
    par = Params(Rs)
    lo = lo[:]; hi = hi[:]
    if not propagate(par, lo, hi):
        print("root box empty: certified"); return True
    roots = split_roots(lo, hi, nroots)
    tot = {'boxes': 0, 'empty': 0, 'cert': 0, 'minw': INF}; fails = []
    t0 = time.time()
    with mp.Pool(nproc) as pool:
        for i, (st, fl, dt) in enumerate(pool.imap_unordered(
                worker, [(Rs, a, b, maxboxes) for a, b in roots])):
            for key in ('boxes', 'empty', 'cert'):
                tot[key] += st[key]
            tot['minw'] = min(tot['minw'], st['minw'])
            fails += fl
            if (i + 1) % 64 == 0 or i + 1 == len(roots):
                print("roots %d/%d boxes %d cert %d empty %d minw %.3g fails %d  %.0fs"
                      % (i + 1, len(roots), tot['boxes'], tot['cert'], tot['empty'],
                         tot['minw'], len(fails), time.time() - t0), flush=True)
    for fl in fails[:50]:
        print("FAIL", fl)
    ok = not fails
    print("RESULT R=%s: %s" % (Rs, "ALL BOXES CERTIFIED" if ok else "NOT CERTIFIED (%d failures)" % len(fails)))
    return ok

# ---------------- reference (F5), relabelled as in the task -----------------
REF = {1: (0.0, -0.39324960179250027086), 2: (0.0, 0.71839227931685877597),
       3: (0.0, 2.34884120097565953729),
       4: (1.57535264004342806580, 1.62062588642691912838),
       5: (-1.57535264004342806580, 1.62062588642691912838),
       6: (1.77273616280974093118, -0.93632239910290244643),
       7: (-1.77273616280974093118, -0.93632239910290244643),
       8: (1.82750955295212993964, 0.24958048504283922431),
       9: (-1.82750955295212993964, 0.24958048504283922431),
       10: (0.78521708246826346764, -2.01247018720615423819),
       11: (-0.78521708246826346764, -2.01247018720615423819)}
ORDER = [9, 7, 11, 10, 6, 8, 4, 3, 5]      # D_1..D_9; E = disk 1, F = disk 2

def reference_angles(R):
    """Witness angles of Lemma W for the reference at radius R, rotated so phi_9 = 2 pi (float)."""
    th, w = [], []
    for j in ORDER:
        cx, cy = REF[j]; rho = math.hypot(cx, cy)
        th.append(math.atan2(cy, cx))
        w.append(math.acos((R*R + rho*rho - 1.0) / (2.0*R*rho)))
        assert R - 1.0 <= rho <= math.sqrt(R*R - 1.0)
    for k in range(1, 9):
        while th[k] <= th[k-1]:
            th[k] += 2 * math.pi
    assert th[8] < th[0] + 2 * math.pi
    th.append(th[0] + 2 * math.pi); w.append(w[0])
    phi = []
    for k in range(9):
        a = max(th[k], th[k+1] - w[k+1]); b = min(th[k] + w[k], th[k+1])
        assert a <= b, "reference violates (b) at this R"
        phi.append(0.5 * (a + b))
    shift = phi[8] - 2 * math.pi
    return [0.0] + [p - shift for p in phi[:8]] + [2 * math.pi]

def ref_box(half):
    ref = reference_angles(2.6316)
    return ([0.0] + [p - half for p in ref[1:9]] + [0.0],
            [0.0] + [p + half for p in ref[1:9]] + [0.0])

def test():
    ok = True
    # T1 (must fail to refute): R = 2.6316 < R_*, tiny box around the reference witnesses.
    par = Params("2.6316"); pairs, anchors = static_constraints(par)
    lo, hi = ref_box(1e-6)
    st, x, f = try_box(par, pairs, anchors, lo, hi, None)
    print("T1 R=2.6316 reference box: status", st, "Phi_min", f)
    if st == 'cert':
        print("T1 FAILED: certified infeasibility of a feasible box"); ok = False
    # T2 (should certify, power check): R = 2.75 > 2.725 (F4), same box.
    par = Params("2.75"); pairs, anchors = static_constraints(par)
    lo, hi = ref_box(1e-6)
    st, x, f = try_box(par, pairs, anchors, lo, hi, None)
    print("T2 R=2.75 reference box: status", st, "Phi_min", f, "(expected cert or empty)")
    # T3 (power check at r_1): box of half-width 1e-3 around the reference at R = 2.6317.
    par = Params("2.6317"); pairs, anchors = static_constraints(par)
    lo, hi = ref_box(1e-3)
    st2, fl = process(par, pairs, anchors, lo, hi, 2000)
    print("T3 R=2.6317 half-width 1e-3:", st2, "failures", len(fl))
    print("TEST", "PASSED (soundness sanity)" if ok else "FAILED")
    return ok

if __name__ == '__main__':
    mode = sys.argv[1] if len(sys.argv) > 1 else 'test'
    if mode == 'test':
        sys.exit(0 if test() else 1)
    elif mode == 'pilot':
        half = float(sys.argv[2]); nproc = int(sys.argv[3]) if len(sys.argv) > 3 else 32
        lo, hi = ref_box(half)
        sys.exit(0 if run("2.6317", lo, hi, nproc, 256) else 1)
    elif mode == 'full':
        nproc = int(sys.argv[2]) if len(sys.argv) > 2 else 32
        lo = [0.0] * 10; hi = [7.0] * 10
        sys.exit(0 if run("2.6317", lo, hi, nproc, 4096) else 1)
```

Diff `ms5_witness.py` → `ms5_witness_m.py` (output of `diff`; nothing else differs):

```
15a16,17
> import os
> MSPLIT = int(os.environ.get("MSPLIT", "5"))   # judge: split label m (E-run D_1..D_m); 5 = original
60c62
<         X = NE if k <= 5 else NF
---
>         X = NE if k <= MSPLIT else NF
62c64
<     pairs += [(T1, C(1)), (T1, NE), (T1, NF), (T6, C(6)), (T6, NE), (T6, NF)]
---
>     pairs += [(T1, C(1)), (T1, NE), (T1, NF), (T6, C(MSPLIT + 1)), (T6, NE), (T6, NF)]
```

## Appendix 3 — `wit_exact.py` (computation C2); `wit_exact_m.py` differs only in the import line

```python
#!/usr/bin/env python3
"""Judge's independent exact re-verification of the witness-angle branch and bound (round11_q4).

Re-runs the same bisection tree over the 8 free witness angles, but every load-bearing quantity is
evaluated in exact rational arithmetic (fractions.Fraction) with rigorous Taylor enclosures of
sin/cos and of pi; no libm result and no float rounding is trusted.  The float penalty minimiser of
ms5_witness.py is used only to *choose* the multipliers (any choice is admissible in Lemma D').

Load-bearing checks per leaf box B = prod [lo_k, hi_k] (k = 1..8; phi_0 = 0, phi_9 = 2 pi):
  (i)  'empty': exact propagation of 0 <= phi_k - phi_{k-1} <= A, A >= 2 arcsin(1/R) rigorous,
       phi_9 = 2 pi enclosed by [TPL, TPH];
  (ii) 'cert':  V < 0 in Lemma D' for the relaxed system P~(B), with exact rational multipliers
       y_e, z_j, mu_i read off the float point x, exact upper bounds of Euclidean norms, and
       half-plane offsets h_k that are rigorous lower bounds of n.s(phi) at both ends of [lo_k, hi_k].
Usage: python3 wit_exact.py R nproc nroots
"""
import sys, time, math
from fractions import Fraction as Fr
from math import isqrt
import multiprocessing as mp
import ms5_witness as W

P = 200                                   # dyadic precision for Taylor enclosures
SC = 1 << P
def fl(x):  # floor to dyadic 2^-P
    return Fr((x.numerator * SC) // x.denominator, SC)
def ce(x):
    return Fr(-((-x.numerator * SC) // x.denominator), SC)

def sincos(t):
    """rigorous enclosures (lo, hi) of sin t and cos t for rational 0 <= t <= 8 (Taylor, 80 terms,
    terms rounded outward to 2^-P, Lagrange remainder t^80/80!)"""
    t = Fr(t); N = 80
    assert 0 <= t <= 8
    s_lo = s_hi = c_lo = c_hi = Fr(0)
    tl = th = Fr(1)                        # enclosure of t^n / n!
    for n in range(N):
        if n > 0:
            tl = fl(tl * t / n); th = ce(th * t / n)
        sign = 1 if (n // 2) % 2 == 0 else -1
        if n % 2 == 0:
            if sign > 0: c_lo += tl; c_hi += th
            else: c_lo -= th; c_hi -= tl
        else:
            if sign > 0: s_lo += tl; s_hi += th
            else: s_lo -= th; s_hi -= tl
    rem = ce(t ** N / math.factorial(N))
    return (s_lo - rem, s_hi + rem), (c_lo - rem, c_hi + rem)

def pi_enclosure():
    # Machin: pi = 16 atan(1/5) - 4 atan(1/239), alternating series with exact bounds
    def atan_inv(n, terms):
        x = Fr(1, n); s = Fr(0); lo = hi = None
        acc = Fr(0)
        for k in range(terms):
            acc += Fr((-1) ** k, 2 * k + 1) * x ** (2 * k + 1)
        tail = x ** (2 * terms + 1) / (2 * terms + 1)
        return acc - tail, acc + tail
    a5 = atan_inv(5, 60); a239 = atan_inv(239, 30)
    return 16 * a5[0] - 4 * a239[1], 16 * a5[1] - 4 * a239[0]

PI_LO, PI_HI = pi_enclosure()
TPL, TPH = 2 * PI_LO, 2 * PI_HI

def sqrt_up(q):
    """rational upper bound of sqrt(q), q >= 0 rational"""
    if q == 0: return Fr(0)
    K = 1 << 64
    a, b = q.numerator, q.denominator
    s = isqrt(a * b * K * K) + 1
    return Fr(s, b * K)
def sqrt_dn(q):
    K = 1 << 64
    a, b = q.numerator, q.denominator
    return Fr(isqrt(a * b * K * K), b * K)

class EP:
    def __init__(self, Rs):
        self.R = Fr(Rs)
        self.Rf = float(self.R)
        # A >= 2 arcsin(1/R): take a float candidate a, check sin(a) > 1/R and a < pi/2 rigorously
        a = Fr(math.asin(1.0 / self.Rf) + 1e-12)
        (slo, shi), _ = sincos(a)
        assert slo > 1 / self.R and a < PI_LO / 2, "arcsin bound failed"
        self.A = 2 * a
        self.RHO = sqrt_up(self.R * self.R - 1)     # >= sqrt(R^2 - 1)
        self.M = Fr(7, 2)

def propagate(ep, lo, hi):
    lo[0] = hi[0] = Fr(0); lo[9] = TPL; hi[9] = TPH
    A = ep.A
    for _ in range(4):
        for k in range(1, 9):
            lo[k] = max(lo[k], lo[k - 1]); hi[k] = min(hi[k], hi[k - 1] + A)
        for k in range(8, 0, -1):
            hi[k] = min(hi[k], hi[k + 1]); lo[k] = max(lo[k], lo[k + 1] - A)
        for k in range(1, 10):
            if lo[k] > hi[k] or lo[k] > hi[k - 1] + A or hi[k] < lo[k - 1]:
                return False
    return True

def halfplanes(ep, lo, hi):
    """returns list (v, nx, ny, h) with nx, ny rationals of floats and h a rigorous lower bound of
    min over phi in [lo, hi] of n.s(phi), s(phi) = R (cos phi, sin phi); None if not certifiable."""
    hs = []
    for k in range(1, 9):
        al, be = lo[k], hi[k]
        if not (be - al <= Fr(3, 2)): return None
        m = float((al + be) / 2)
        nx, ny = Fr(math.cos(m)), Fr(math.sin(m))
        vals = []
        for t in (al, be):
            (slo, shi), (clo, chi) = sincos(t)
            # lower bound of R (nx cos t + ny sin t)
            a1 = min(nx * clo, nx * chi); a2 = min(ny * slo, ny * shi)
            vals.append(ep.R * (a1 + a2))
        h = min(vals)
        if not h > 0: return None
        hs.append((W.S(k), nx, ny, h))
    hs.append((W.S(9), Fr(1), Fr(0), ep.R))      # sigma_9 = s(0) = (R, 0) exactly
    return hs

def anchors_exact(ep):
    return [(W.NE, Fr(1))] + [(W.C(k), ep.RHO) for k in range(1, 10)] + [(W.S(k), ep.R) for k in range(1, 10)]

def V_exact(ep, x, pairs, anchors, halves):
    """exact rational upper bound of V of Lemma D' for multipliers read off the float point x"""
    N = W.N
    g = [Fr(0)] * N
    tot = Fr(0)
    X = [Fr(v) for v in x]
    for (a, b) in pairs:
        dx = x[2*a] - x[2*b]; dy = x[2*a+1] - x[2*b+1]
        L = math.hypot(dx, dy)
        if L > 1.0:
            w = L - 1.0
            yx, yy = Fr(w * dx / L), Fr(w * dy / L)
            tot += sqrt_up(yx * yx + yy * yy)
            g[2*a] += yx; g[2*a+1] += yy; g[2*b] -= yx; g[2*b+1] -= yy
    for (v, r) in anchors:
        dx, dy = x[2*v], x[2*v+1]
        L = math.hypot(dx, dy)
        if L > float(r):
            w = L - float(r)
            zx, zy = Fr(w * dx / L), Fr(w * dy / L)
            tot += r * sqrt_up(zx * zx + zy * zy)
            g[2*v] += zx; g[2*v+1] += zy
    for (v, nx, ny, h) in halves:
        s = float(h) - (float(nx) * x[2*v] + float(ny) * x[2*v+1])
        if s > 0.0:
            mu = Fr(s)
            tot -= mu * h
            g[2*v] -= mu * nx; g[2*v+1] -= mu * ny
    for v in range(W.NV):
        tot += ep.M * sqrt_up(g[2*v] ** 2 + g[2*v+1] ** 2)
    return tot

def try_box(ep, par, pairs_f, anch_f, pairs, anch, lo, hi, x0):
    if not propagate(ep, lo, hi):
        return 'empty', x0
    hs = halfplanes(ep, lo, hi)
    if hs is None:
        return 'open', x0
    hsf = [(v, float(nx), float(ny), float(h)) for (v, nx, ny, h) in hs]
    flo = [float(t) for t in lo]; fhi = [float(t) for t in hi]
    x = x0 if x0 is not None else W.initial_x(par, flo, fhi)
    x, f = W.minimize(x, pairs_f, anch_f, hsf)
    if f > 0.0 and V_exact(ep, x, pairs, anch, hs) < 0:
        return 'cert', x
    return 'open', x

def process(Rs, lo, hi, maxboxes):
    ep = EP(Rs); par = W.Params(Rs)
    pairs_f, anch_f = W.static_constraints(par)
    pairs = pairs_f; anch = anchors_exact(ep)
    st = {'boxes': 0, 'empty': 0, 'cert': 0}; fails = []
    stack = [(lo[:], hi[:], None)]
    MINW = Fr(1, 10**7)
    while stack:
        lo, hi, x0 = stack.pop(); st['boxes'] += 1
        if st['boxes'] > maxboxes:
            fails.append(('BUDGET', [float(t) for t in lo], [float(t) for t in hi])); break
        s, x = try_box(ep, par, pairs_f, anch_f, pairs, anch, lo, hi, x0)
        if s == 'empty': st['empty'] += 1; continue
        if s == 'cert': st['cert'] += 1; continue
        k = max(range(1, 9), key=lambda j: hi[j] - lo[j])
        if hi[k] - lo[k] < MINW:
            fails.append(('OPEN', [float(t) for t in lo], [float(t) for t in hi])); continue
        m = (lo[k] + hi[k]) / 2
        h1 = hi[:]; h1[k] = m; l2 = lo[:]; l2[k] = m
        stack.append((lo[:], h1, x)); stack.append((l2, hi[:], x))
    return st, fails

def worker(args):
    Rs, lo, hi, mb = args
    t0 = time.time(); st, fl_ = process(Rs, lo, hi, mb)
    return st, fl_, time.time() - t0

def split_roots(lo, hi, target):
    from collections import deque
    q = deque([(lo, hi)])
    while len(q) < target:
        a, b = q.popleft()
        k = max(range(1, 9), key=lambda j: b[j] - a[j])
        m = (a[k] + b[k]) / 2
        b1 = b[:]; b1[k] = m; a2 = a[:]; a2[k] = m
        q.append((a, b1)); q.append((a2, b))
    return list(q)

def main():
    Rs = sys.argv[1]; nproc = int(sys.argv[2]); nroots = int(sys.argv[3])
    mb = int(sys.argv[4]) if len(sys.argv) > 4 else 10**9
    ep = EP(Rs)
    print("R =", Rs, " pi in [%.25f, %.25f]" % (float(PI_LO), float(PI_HI)), " A =", float(ep.A), flush=True)
    # sanity of the Taylor enclosures against libm (informative)
    for t in (0.3, 1.7, 4.4, 6.9):
        (sl, sh), (cl, ch) = sincos(Fr(t))
        assert sl <= Fr(math.sin(t)) + Fr(1, 10**15) and Fr(math.sin(t)) - Fr(1, 10**15) <= sh
        assert sh - sl < Fr(1, 10**40)
    lo = [Fr(0)] * 10; hi = [Fr(7)] * 10
    if not propagate(ep, lo, hi):
        print("root empty"); return
    roots = split_roots(lo, hi, nroots)
    tot = {'boxes': 0, 'empty': 0, 'cert': 0}; fails = []; t0 = time.time()
    with mp.Pool(nproc) as pool:
        for i, (st, fl_, dt) in enumerate(pool.imap_unordered(worker, [(Rs, a, b, mb) for a, b in roots])):
            for k in tot: tot[k] += st[k]
            fails += fl_
            if (i + 1) % 256 == 0 or i + 1 == len(roots):
                print("roots %d/%d %s fails %d %.0fs" % (i + 1, len(roots), tot, len(fails), time.time() - t0), flush=True)
    for f in fails[:20]: print("FAIL", f)
    print("EXACT RESULT R=%s: %s" % (Rs, "ALL BOXES CERTIFIED (exact rational check)" if not fails
                                     else "NOT CERTIFIED (%d failures)" % len(fails)), flush=True)

if __name__ == "__main__":
    main()
```

Diff `wit_exact.py` → `wit_exact_m.py`:

```
21c21
< import ms5_witness as W
---
> import ms5_witness_m as W
```

## Appendix 4 — driver `run_exact_m.py` (self-certifying run of computation C2)

```python
# judge r13 (repairs D2/D3/D4 of round12_q3): self-certifying exact run of wit_exact_m.py for split label m.
# Usage: MSPLIT=m python run_exact_m.py R nproc nroots   (runs ../r12/wit_exact_m.py's main() unchanged)
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "r12"))
m = int(os.environ["MSPLIT"])
if not (1 <= m <= 8): raise SystemExit("MSPLIT out of range")
if sys.flags.optimize: raise SystemExit("refusing to run under -O (load-bearing asserts)")
import ms5_witness_m as W, wit_exact_m as E
if W.MSPLIT != m: raise SystemExit("module MSPLIT mismatch")
# independent transcription of the constraint list of P_m(phi) (Theorem C), compared with W.static_constraints
NE, NF = 0, 1
C = lambda k: 1 + k; P = lambda k: 10 + k; T1, T6 = 20, 21; S = lambda k: 21 + k
exp = set()
for k in range(1, 10):
    exp.add((C(k), S(9 if k == 1 else k - 1))); exp.add((C(k), S(k)))               # (P2)
    exp |= {(P(k), C(k)), (P(k), C(1 if k == 9 else k + 1)), (P(k), NE if k <= m else NF)}  # (P3)
exp |= {(T1, C(1)), (T1, NE), (T1, NF), (T6, C(m + 1)), (T6, NE), (T6, NF)}          # (P4)
assert (W.NE, W.NF, W.C(1), W.C(9), W.P(1), W.P(9), W.T1, W.T6, W.S(1), W.S(9), W.NV) == \
       (0, 1, 2, 10, 11, 19, 20, 21, 22, 30, 31), "index layout differs"
par = W.Params(sys.argv[1]); pairs, anchors = W.static_constraints(par)
got = set(pairs)
if got != exp or len(pairs) != len(exp): raise SystemExit("constraint list differs from Theorem C: %s / %s" % (got ^ exp, len(pairs)))
anc = sorted((v, r) for v, r in anchors)
assert [v for v, r in anc] == [NE] + [C(k) for k in range(1, 10)] + [S(k) for k in range(1, 10)]
print("JUDGE-R13 MSPLIT=%d optimize=%d; constraint list = Theorem C for m=%d (%d pairs); E-links 1..%d, T6 on D_%d"
      % (m, sys.flags.optimize, m, len(pairs), m, m + 1), flush=True)
sys.argv = [sys.argv[0]] + sys.argv[1:]
E.main()
print("JUDGE-R13 END MSPLIT=%d" % m, flush=True)
```
