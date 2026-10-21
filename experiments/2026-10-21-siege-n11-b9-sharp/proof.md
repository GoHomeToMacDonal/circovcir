# Eleven unit disks, exactly nine of which meet the boundary circle: the sharp bound R ≤ R_*

## Theorem

Let c_1, …, c_11 be points of the plane (not necessarily distinct) and R > 0, and suppose D_R ⊆ D(c_1,1) ∪ … ∪ D(c_11,1) and exactly nine of the eleven disks D(c_i,1) meet S_R. Then R ≤ R_*.

(Notation as in the problem statement: D_R = D(0,R), S_R = ∂D_R, R_* the Melissen covering radius, R_* ∈ I_*, r_0 = 2.63169, r_1 = 2.6317. F1–F8 are the facts listed in the problem statement.)

## Trust base

The theorem is proved by the argument in §1 (the verdict is in the section "Status" after §3). The argument combines hand proofs with four finite computations. The hand proofs are in §1 and Appendices A–E. The computations are reproduced verbatim in Appendices A, D, E and F, and their outputs are in Appendix G. Nothing below is conjectural. The argument rests on the following, and on nothing else:

1. **F1–F8 as stated in the problem**, and in particular:
   - the computer-assisted facts F4(i), F4(ii) and F6′;
   - the F5 decimals;
   - the lemmas of the F7 proof document. The relevant part of that document is reproduced in Appendix A. Every lemma of it that is used here is re-checked at the radii actually used (Appendix B), not only at r_1.
2. **Computation C1_R**, the No-Bridge check on R ∈ [2.63169, 2.631692]. This is an outward-rounded double-precision interval program. Like F7's C1, its soundness assumes:
   - IEEE-754 double arithmetic with correctly rounded + − × ÷ √;
   - libm asin/acos/atan/sin/cos accurate to within 10⁻¹² (the program widens every libm value by that amount).

   F7 removed this assumption for its own run at R = r_1 with an independent Mathematica certificate ("22b"). That certificate has **not** been re-run on the R-interval. So for C1_R the assumption is part of the trust base. It is a declared hypothesis of a rigorous interval computation, not a logical gap, and §3 explains how to remove it.
3. **Computations MID, GLOB and LOC** (programs `mid_cert.py` and `wit_exact_J.py` with its helper `ms5_witness_m.py`). Every load-bearing inequality in them is decided in exact rational arithmetic: Python `Fraction`, `math.isqrt`, rigorous Taylor enclosures of sin/cos, and a Machin enclosure of π. Floats and 60-digit Decimals only choose multipliers and factors, and any choice is admissible. Each program is a single implementation. Each has been desk-audited function by function against the statements it is used for.
4. The program outputs in Appendix G are faithful records of executions of the program texts reproduced here. I checked that the reproduced texts of `mid_cert.py`, `wit_exact_J.py`, `ms5_witness_m.py` and `nb_par.py` are byte-identical to the executed files. I also checked that the executed `nb_check.py` is exactly F7's `nb_check.py` (Appendix A, Appendix 1 there) with the diff of Appendix B §4 applied. Finally, I checked that the logs contain the success lines quoted in Appendix G.

The complete chain was independently checked twice (once forwards and once backwards), and the two exact programs were audited line by line. Every issue found was cosmetic. All of them are corrected in this text: in §1 directly, or in the editorial notes, which are marked **[Ed.: …]** inside the appendices.

## How this document is organised

- §1 gives the proof. It consists of Steps 0–6, with the precise hand-offs between them.
- §2 records the other routes that were tried.
- §3 lists the residual caveats.
- The appendices contain the full arguments and programs. They were written as separate documents, so they cross-refer to each other by the following names:

| Name used inside the appendices | Where it is in this document |
|---|---|
| "the F7 text", "F7 §…", "Part A/B/D/E/M/O/N/W", "§9", "Lemma R2", "Lemma D′", "Theorem C", "Lemma M35", "Appendix 1", `nb_check.py`, `nb_par.py` | Appendix A |
| "Appendix B" (the (RED)/(UNI) document), "Proposition RED", "Theorem C1_R", "Proposition 9.1_R", "§2 derivative bounds" | Appendix B |
| "Appendix C", "(C)": Part W on an R-interval, Lemma LOC, the transfer | Appendix C |
| "Appendix D": Theorem A′, Lemma Q, Theorem MID, `mid_cert.py` | Appendix D |
| "Appendix E": GLOB/LOC on J, Lemma P, `wit_exact_J.py` | Appendix E |
| `ms5_witness_m.py` (in Appendix E also called "Appendix 2 + diff of the F7 document") | Appendix F |
| outputs of all runs, and how to re-run them | Appendix G |
| "data (A)", "the float data" | Floating-point data computed during the attempt. They were used only for orientation or to choose data, and are never load-bearing. Where a statement rests on them, the text says it is heuristic. |

Some sections of the original documents are omitted here. In each case they were superseded or are not used, and an [Ed.] note at that place says so. The appendices were written **before** the computations were run, so they contain sentences such as "not run" or "the program must be run". Appendix G supersedes all of these. Comments inside the program texts contain historical tags such as `Appendix D` and `the F7 document's No-Bridge step`. These are labels only and refer to nothing outside this document. [Ed.: In the program texts, provenance tags in comments and docstrings were replaced by references to the appendices of this document; no executable line was changed.]

## Notation for §1

- R̄ = 2.63169077261980820552 is the F5 decimal radius. By I_*, 0 < R_* − R̄ ≤ 1.502·10⁻²¹. The lower bound R_* − R̄ ≥ 1.50116·10⁻²¹ is checked exactly as line A0 of `mid_cert.py`.
- J = [R_lo, R_hi] = [R̄, 2.631692]. Note R_* + 10⁻⁶ < 2.6316918 < R_hi.
- 𝒥 = [r_0, r_1] = [2.63169, 2.6317].
- z = (c_1, …, c_11, R) ∈ ℝ²³ in F5 labels, and z̄ is the F5 vector.
- 𝒱 = {x(c_3) = 0}, and B(ρ) = {z ∈ 𝒱 : ‖z − z̄‖_∞ ≤ ρ}.
- "A covering of the claim's type at radius R" means eleven unit disks covering D_R, with exactly nine of them meeting S_R.

## 1. Proof

Suppose, for a contradiction, that some covering of the claim's type has radius R > R_*.

### Step 0 (reduction RED; Appendix B §1)

Put R′ = min(R, R_* + 10⁻⁶). By Proposition RED there is a covering of the claim's type at radius R′ ∈ (R_*, R_* + 10⁻⁶] in which every boundary centre lies on the inner branch R′ − 1 ≤ |c_k| ≤ √(R′² − 1). Here "boundary" refers to S_{R′}: shrinking R to R′ can change *which* disks meet the circle (an original inner disk may meet S_{R′}, an original boundary disk may miss it), and the proof establishes only that *exactly nine* disks meet S_{R′}. Lemma R2 then moves those nine centres radially and leaves the other two disks fixed. Only this count, not the identity of the disks, is used later.

Proof outline (in full in Appendix B §1):
- D_{R′} ⊆ D_R is covered.
- At least nine disks meet S_{R′}, because 8a(R′) < π (F1; R′ > 1/sin(π/8)).
- At most ten disks meet S_{R′}, by F4(i).
- Exactly ten is impossible, by F4(ii), since R′ > R_* > r_0.
- Lemma R2 of the F7 text (Appendix A §1) is valid at every R > 1. Its proof needs 0 < w ≤ a(R′) for the half-width w of each boundary arc:
  - w > 0 holds by F3, which applies because R′ ≥ R_* (each arc has a private open sub-arc);
  - w ≤ a(R′) holds by F1.
- Lemma R2 moves each boundary centre radially onto the inner branch. This keeps D_{R′} covered and keeps the set of disks meeting S_{R′}.

The resulting configuration satisfies the standing hypotheses (SH)_{R′} of the F7 text with r_1 replaced by R′. F7's normalisation may include a reflection of the plane. Every later statement applies to any covering, and F6′ allows reflections, so a reflection is harmless.

Since R_* + 10⁻⁶ < 2.631692, we have R′ ∈ [2.63169, 2.631692] ⊂ 𝒥 and R′ ∈ J.

### Step 1 (structure UNI; Appendix B §§2–5, with the F7 text of Appendix A)

**Proposition 9.1_R** (Appendix B §5). Let R ∈ [R_*, r_1], and assume Theorem NB (No-Bridge: D_j ∩ D_{j+2} = ∅) holds at R. Then the normalised covering solves the system Σ_m(R) for some m ∈ {1, …, 8}.

Here Σ_m(R) is F7's system Σ_m of §9 with r_1 replaced by R (Appendix A). It has the following unknowns and conditions:
- unknowns: the inner centres c_E (with |c_E| ≤ 1; E is the inner disk containing 0) and c_F, and the boundary centres c_1, …, c_9 in cyclic order;
- (P0) |c_E| ≤ 1;
- (a) R − 1 ≤ |c_k| ≤ √(R² − 1);
- (b) the arc conditions;
- (c) the inner corners q_1, …, q_m lie in E and q_{m+1}, …, q_9 lie in F;
- (d) the two transition disks meet E ∩ F.

The hypotheses are met at R = R′, as follows.
- **The hand part holds on [R_*, r_1].** Appendix B §2 gives R-derivative bounds on 𝒥. Appendix B §3 goes through every hand inequality of F7's Parts A, B, D, E, M §§1–4, and checks each one either by monotonicity in R or by a margin-plus-derivative bound. The corrected constants are B ≤ 0.12069, 2a − B ≥ 0.658868, C-table ±1.4·10⁻⁵ and c₄ ≥ 0.039989.
  - The thinnest margin is ρ_lo ≥ 1.9656, where ρ_lo(R) = R cos w − √(1 − R² sin² w) with w = π − 5a(R) − d(R). Its rigorous support is the hand bound (D5) of Appendix B §2: ρ_lo is increasing in R and ρ_lo(R) ≥ 1.965607 on all of 𝒥 (margin ≈ 7·10⁻⁶; ≈ 1.1·10⁻⁵ on [R_*, r_1]). As corroboration only (not load-bearing), a 60-digit decimal evaluation gives ρ_lo(r_0) = 1.9656095, ρ_lo(R_*) = 1.9656136 and ρ_lo(r_1) = 1.9656633, consistent with (D5).
  - The fallback constant ρ_lo = 1.9655 holds with margin ≈ 1.1·10⁻⁴, and every dependent margin absorbs the change (Appendix B §3). Computation C1_R does not use the hand constant: it computes its own outward-rounded lower bound for ρ.
- **Parts B (continued), O, N and §9 are R-free** (Appendix B §5), apart from two conditions:
  - Lemma A5 and Corollary K1 use F4(ii), so they need R ≥ r_0;
  - Lemma A0 and F3 need R > 2.61313 and R ≥ R_*.

  Both conditions hold at R′.
- **Theorem NB at R′ is supplied by Theorem C1_R** (Appendix B §4). That theorem says: if F7's program `nb_check.py` (Appendix A, Appendix 1), modified by the three-line diff of Appendix B §4, prints `ALL CASES VERIFIED` for an interval [R_lo, R_hi] ⊆ 𝒥, then NB holds for every R in that interval with R ≥ R_*. The diff makes three changes:
  - R becomes an outward-rounded interval;
  - TMAX = R.hi;
  - an undefined arcsine is treated as infeasible, which is justified by Repair M1.

  The program was run on [2.63169, 2.631692] in 24 slices and printed `ALL CASES VERIFIED` (Appendix G(c)). Since R′ lies in that interval, NB holds at R′. The trust base of this step is IEEE/libm (see Trust base, item 2).

**Output of Step 1.** The covering of Step 0 solves Σ_m(R′) for some m ∈ {1, …, 8}.

### Step 2 (Part W on the interval J; Appendix C §1, with Part W of Appendix A)

The steps below use the witness-angle polytope and the relaxed system P̃_m(B; J). They are defined as follows.
- A is a rational with A ≥ 2 arcsin(1/R_lo). The program checks this exactly, and it implies A ≥ 2a(R) for every R ∈ J.
- RHO = sqrt_up(R_hi² − 1) ≤ 2.45.
- Φ_A = {φ : φ_0 = 0, φ_9 = 2π, 0 ≤ φ_k − φ_{k−1} ≤ A}.
- P_m(φ; R) is F7's convex (second-order-cone) system P_m(φ), with s replaced by s_R and ρ_max replaced by √(R² − 1).
- P̃_m(B; J) is the relaxation of P_m(φ; R) over a box B of witness angles, of width ≤ 3/2. In it each witness point s_R(φ_k) is replaced by an unknown σ_k, subject to:
  - |σ_k| ≤ R_hi and n̂_k·σ_k ≥ R_lo·u_k, where u_k > 0 is a rational lower bound of n̂_k·e(t) at both ends of the k-th interval;
  - |σ_9| ≤ R_hi and σ_9,x ≥ R_lo;
  - the anchors |c_E| ≤ 1 and |c_k| ≤ RHO;
  - the pair constraints (P2)–(P4), unchanged.

The results used are these:
- **Lemma W_J and Theorem C_J.** After a rotation about 0, the Σ_m(R′) solution has a witness vector φ ∈ Φ(R′) ⊆ Φ_A for which P_m(φ; R′) is feasible. The feasible point uses the **same centres**, and adds only the corner points p_k and t_j.
- **Corollary W1_J.** If φ ∈ B ∩ Φ_A and P_m(φ; R) is feasible for some R ∈ J, then P̃_m(B; J) is feasible. Only R ≥ R_lo is used here; R_lo = R̄ < R_* plays no other role.
- **Lemma M35_J.** Every solution of P̃_m(B; J) has all its 31 unknown points bounded by M = 7/2.
- **Lemma D′** (Appendix A, Part W). An explicit dual inequality V < 0, with M = 7/2, certifies that P̃_m(B; J) is infeasible.

### Step 3 (GLOB; program `wit_exact_J.py`, mode `glob`; soundness in Appendix E §3.2)

For each m, the program covers the root box [0, 7]⁸ ⊇ Φ_A by a bisection tree. Each leaf is of one of three kinds:
- **empty**: exact propagation of the constraints of Φ_A shows the box contains no point of Φ_A;
- **cert / cert_hp**: an exact Lemma D′ certificate shows that P̃_m(B; J) is infeasible;
- **local**: the propagated box lies inside the cube U = Π_k [φ̄_k − η, φ̄_k + η], with η = 1/1024, around the rational Melissen witness vector φ̄. For m = 4 the cube is U′, around the swapped vector φ̄′.

The runs printed the following (Appendix G(b)).
- m ∈ {1, 2, 3, 6, 7, 8}: `ALL BOXES EMPTY, CERTIFIED OR IN U (local=0, eta=none)`.
- m = 5: the same line, with local = 154. The counts are 17634 boxes, 10865 leaves and 6769 splits.
- m = 4: the same line, with local = 196. The counts are 24582 boxes, 14339 leaves and 10243 splits.

**Precise conclusion.** Fix m and R ∈ J, and let φ ∈ Φ_A be such that P_m(φ; R) is feasible. The vector φ lies in some leaf of the tree. That leaf is not empty, since φ ∈ Φ_A. It is not certified, by W1_J and D′. So it is a local leaf, and φ ∈ U (respectively φ ∈ U′).

Consequences:
- For m ∈ {1, 2, 3, 6, 7, 8}, Σ_m(R) has no solution for any R ∈ J.
- For m = 5 (respectively m = 4), every witness vector that Lemma W_J can produce lies in U (respectively U′), whatever choice is made in its step 2.

By Step 1, therefore, m ∈ {4, 5} and the witness vector of the Step 0 covering lies in U or U′.

### Step 4 (LOC; Lemma LOC of Appendix C §3.2, program mode `loc`)

Take m = 5. The LOC step uses three pieces of data:
- **λ**, the relabelling from the witness labels (E, F, D_1, …, D_9) to the F5 disks (1, 2, 9, 7, 11, 10, 6, 8, 4, 3, 5);
- **Q** = [[c, −s], [s, c]], an exactly orthogonal rational rotation, with c = (1 − τ²)/(1 + τ²), s = 2τ/(1 + τ²) and τ = 1331857233103593/2⁴⁸ (c² + s² = 1 is asserted exactly);
- **δ₁** = 3/1000.

For each of the 11 centres v, each coordinate ι ∈ {x, y} and each sign e = ±1, the program considers the system

  𝒮(v, ι, e) = P̃_5(U; J) ∪ { e·((Qc_v)_ι − c̄_{λ(v),ι}) ≥ δ₁ }.

The extra constraint is one more half-plane. Lemma D′ needs no sign condition on its offset, and M = 7/2 still applies because the solution set only shrinks.

All 44 systems were certified infeasible, for m = 5 and also for m = 4 with (U′, Q′, λ′), where λ′ = (2, 1, 8, 4, 3, 5, 9, 7, 11, 10, 6) (Appendix G(b)).

**Conclusion.** For every R ∈ J, every φ ∈ U and every solution of P_5(φ; R):

  |(Qc_v)_ι − c̄_{λ(v),ι}| < 3/1000 for all v and ι.

The same holds for m = 4 with Q′, λ′ and U′. Soundness does not depend on Q or λ being the "true" frame. The certificates prove the statement for every solution, whichever disk carries which label.

The cube U is the same object in `glob` and in `loc`: the same function `cube(frame(m)['phib'], 1/1024)`, applied to the same data.

### Step 5 (transfer to the slice coordinates; Appendix C §3.3, constant as in Appendix E §0.4)

Apply Step 4 to the configuration of Steps 0–2. Its centres are those of the P_m solution, by Theorem C_J. Put u_v = Qc_v, relabelled by λ to F5 labels, so that |u_{v,ι} − c̄_{v,ι}| < δ₁ = 3/1000.

Rotate by β = arctan(x(u_3)/y(u_3)). Then z_v := R_β u_v has x(z_3) = 0, and

  |β| < β_max := δ₁/(ȳ_3 − δ₁), with ȳ_3 = 2.34884120…

For v ≠ 3, write z_v − c̄_v = R_β(u_v − c̄_v) + (R_β − I)c̄_v. This gives

  |z_v − c̄_v|_∞ ≤ (1 + β_max)δ₁ + 2.0125·β_max + 1.18·β_max².

This uses max_{v≠3}|ȳ_v| ≤ 2.0125, max|x̄_v| ≤ 1.8276 and 1 − cos β ≤ β²/2. For v = 3, x(z_3) = 0 = x̄_3 and |y(z_3) − ȳ_3| ≤ δ₁ + δ₁².

At δ₁ = 3/1000 the values are β_max = 1.27886·10⁻³ and

  (1 + β_max)δ₁ + 2.0125β_max + 1.18β_max² = 3.00384·10⁻³ + 2.57370·10⁻³ + 0.00193·10⁻³ = 5.57947·10⁻³ < 7·10⁻³.

I evaluated this bound in exact rational arithmetic. The radius coordinate satisfies

  0 < R′ − R̄ = (R′ − R_*) + (R_* − R̄) ≤ 10⁻⁶ + 1.502·10⁻²¹.

The configuration with centres z_v, in F5 labels and with radius R′, was obtained from the covering of Step 0 by isometries fixing 0:
- the rotation of Lemma W_J;
- possibly the reflection of (SH);
- Q;
- R_β.

So it is still a covering of D_{R′} by eleven unit disks with exactly nine disks meeting S_{R′}, and R′ > R_*. Its vector z lies in 𝒱 ∩ B(7/1000).

### Step 6 (MID; Appendix D, program `mid_cert.py`)

**Theorem A′** (Appendix D §2). Let 0 < ρ ≤ 7·10⁻³. Consider a covering of the claim's type with R ≥ R_* and z ∈ B(ρ). It satisfies the following 18 inequalities:
- the nine outer conditions |P_j|² ≥ R², for the outer corners P_j;
- the seven tight inner-corner conditions;
- the two transition conditions.

Theorem A′ needs the exact reference checks A1–A7 at z̄. It also needs F3, which ensures that the arcs of consecutive boundary disks meet.

**Lemma Q** (Appendix D §3). Lift the problem by adding the 18 corner points as unknowns. Every constraint then becomes a quadratic polynomial. For any multipliers λ̂ > 0 and ν̂, any weights, and θ ∈ (0, 1), one gets exactly

  0 < R − R̄ ≤ ε₁ + r̂·h − ½hᵀGh,

with an explicit rational vector r̂, an explicit constant ε₁ and an explicit symmetric rational matrix G, all computed at the rational base point.

**Theorem MID(ρ_A).** Suppose the following hold:
- (i) every λ̂_i > 0;
- (ii) G ⪰ κI;
- (iii) τ = (|r̂| + √(|r̂|² + 2κε₁⁺))/κ ≤ 2·10⁻⁶.

Then every covering of the claim's type with R ≥ R_* and z ∈ B(ρ_A) has ‖z − z̄‖_∞ ≤ |h|₂ < τ.

The program `mid_cert.py` checks A0–A7, B2, D1, D2 and D3 exactly, with ρ_A = 7/1000, θ = 7/10 and μ_eq = 3/10. It prints all PASS lines and `CERTIFIED`, with κ = 4.068342·10⁻³ and τ = 8.591·10⁻¹⁰ (Appendix G(a)). The corner-root enclosure error the program actually uses is η_p = 10⁻³⁰·|d̄|. Appendix D has been corrected to say so; earlier drafts of it said 10⁻⁴⁰ or 10⁻⁴⁵.

Apply this to the configuration of Step 5. It is a covering of the claim's type at R′ > R_* with z ∈ B(7/1000). Hence ‖z − z̄‖_∞ < 8.6·10⁻¹⁰ < 1/500000, with x(c_3) = 0.

F6′ allows rotation, reflection and relabelling, and its hypotheses are now met. It gives R′ ≤ R_* − (7/1000)‖z − z_*‖² ≤ R_*. This contradicts R′ > R_*.

Hence no covering of the claim's type has R > R_*, which proves the theorem. ∎

**Remark (sharpness).** The Melissen configuration c_* covers D_{R_*} (F5), and, as stated in the problem's context paragraph, exactly nine of its disks meet S_{R_*}. So the bound is attained. Together with F8, the theorem shows that R_* is the largest radius of a disk that eleven unit disks can cover.

## 2. Other routes

- **Fine localisation straight into F6′.** The original plan was to localise to δ ≈ 9·10⁻⁷ by LOC certificates and then apply F6′ directly. It was abandoned because LOC turns a cube of half-width η into a localisation of about 2.5η (the measured δ*(η)/η ≈ 2.5). That would need η ≈ 3.6·10⁻⁷ and a much deeper GLOB tree. The coarse LOC (δ₁ = 3·10⁻³) together with the mid-range exclusion MID (ρ_A = 7·10⁻³) replaced it.
- **Chart route (Theorems B/M).** This route uses an inverse-function chart of the active constraints, positive chart multipliers and a negative definite reduced Hessian on a box. It was proved conditionally on a certificate that was never run. It was superseded by the lifted quadratic problem of Lemma Q, which has no third derivatives and no chart.
- **Gauge lemma and orbit form.** Orbit sup-distance ρ₀ ≤ 3.5·10⁻³ implies slice distance ≤ 2.01ρ₀. This, and the first version of Theorem A′, are proved but not needed: Step 5 lands directly in the slice ball.
- **Theorem S′.** Every solution of P_m(φ; R) with φ ∈ Φ(R) is a covering. This is proved, but not needed, because MID is applied to the actual covering.
- **Lemma I.** φ̄ is an isolated feasible witness vector at R_*. Not needed.
- **Far-disk restrictions.** An inner disk with |centre| ≥ 1 contains no run of six consecutive inner corners (margin 0.485), so |c_F| ≥ 1 forces m ≥ 4. A run of seven or more corners in one inner disk contains a corner of modulus < 1. These are proved but not needed: GLOB disposes of every m ∉ {4, 5} by computation.
- **Dead ends:**
  - The run-budget argument cannot exclude six-corner runs when both inner centres have modulus < 1. This is an obstruction, not a refutation.
  - Relaxations that drop an active constraint cannot localise.
  - A fixed-multiplier Lagrangian without a penalty fails, because its Hessian has two positive eigenvalues on the relevant space. The penalised lifted form of Lemma Q is what overcomes this.

## 3. Residual caveats (no logical gap is known)

1. **IEEE/libm trust base of C1_R** (Step 1). To remove it, re-run F7's independent Mathematica certificate 22b with the same three edits:
   - R → Interval[{263169/100000, 2631692/10⁶}];
   - the t-range extended up to R_hi;
   - an undefined α(u) treated as infeasible.

   This has not been done.
2. **Hand constants of UNI.** The derivative-bound transfers of Appendix B §§2–3 are hand arithmetic:
   - the load-bearing values were re-derived by hand during the independent checks: ρ_lo (also evaluated numerically by me, see Step 1), the bounds in (D1) and (D2), Lemma 4.2, and Lemma E3.2;
   - the remaining r_1 table values are taken from the F7 text, which the problem allows to be quoted.

   Apart from ρ_lo (hand-proved margin about 7·10⁻⁶ on 𝒥 in (D5), confirmed by a 60-digit evaluation ρ_lo(r_0) = 1.9656095, with the fallback 1.9655 available), all margins are at least 8.4·10⁻⁴. Stated table errors are at most 1.4·10⁻⁵.
3. **Single implementations.** `mid_cert.py` and `wit_exact_J.py` were each implemented once. They were desk-audited but not re-implemented independently. One load-bearing fact is checked by an `assert` that `python -O` would skip: 1.41421357 ≥ √2 and 1.41421357·0.007 ≤ 0.0099. Both facts are true. `wit_exact_J.py` refuses to run under `-O`.
4. **Inherited computer-assisted facts.** F4(ii), F6′ and the computations of F7 are used as stated in the problem. The problem itself marks the hand reductions of F4 and F7 as pending independent review.

## 3a. Independent Mathematica re-check and errata (2026-10-21, repository `proofs/23-n11-b9-sharp-wl.md`)

[Added after the siege; the text above and below is the siege's final text, unchanged except for this section. Where this section corrects a figure, this section takes precedence.]

Caveats 1 and 3 above are discharged: every computation of Steps 1–6 now has a second, independent implementation in Wolfram Language with exact rational decisions and bignum (outward-rounded) intervals only.

| Step | computation | certificate (repository `proofs/certificates/`) | result |
|---|---|---|---|
| 1 | C1_R, No-Bridge on R ∈ [2.63169, 2.631692] | `23b-n11-b9sharp-nobridge-R.wls` (22b with the three edits of Appendix B §4) | 48 slices / 49 leaves all OK, 2681 s; no IEEE/libm assumption |
| 0, 1, 5 | hand constants of Appendix B §§1–3, 5 and of Steps 0, 1, 5 on their R-intervals | `23a-n11-b9sharp-hand-constants.wls` | 206 assertions: 189 true, 17 false (all last-digit slips, none load-bearing after correction; list below) |
| 2–4 | GLOB (m = 1..8) and LOC (44 + 44 systems) on J | `23c-n11-b9sharp-glob-loc.wls` (own tree, own dual SOCP multipliers) | all leaves empty/certified/inside U (U′); m ∉ {4,5} no local leaves; LOC 44/44 for m = 5 and m = 4 |
| 6 | MID(7/1000), checks A0–A7 | `23d-n11-b9sharp-mid.wls` | CERTIFIED with θ = 7/10, μ_eq = 3/10 (κ = 559397/62500000, τ ≤ 5.80·10⁻¹⁰) and with θ = 3/4, μ_eq = 1/2 (τ ≤ 1.89·10⁻⁹) |

Errata (each corrected statement is verified in 23a/23c/23d; none changes the argument):
- Notation and Trust base: "R_* − R̄ ≥ 1.50116·10⁻²¹ … checked exactly as line A0" is false as printed: R_* − R̄ = 1.5011595…·10⁻²¹ (the A0 line prints a 6-digit rounding). Read R_* − R̄ ≥ 1.50115·10⁻²¹; only 0 < R_* − R̄ ≤ 1.502·10⁻²¹ is used.
- Appendix B (D3): N ≥ 1.15652 (not 1.15653); R² − t² ≤ 5.925845 (not 5.92584); (R+t)² ≥ 13.18917 (not 13.1892). The conclusions |∂z/∂R| ≤ 0.5402 and |∂C/∂R| ≤ 1.4 still hold.
- Appendix B (D5): R sin w ≤ 0.8514055 (not 0.851405); the drop of ρ_lo over [R_*, r_1] obtained from the (D5) constants is 5.03·10⁻⁵ (the true drop 4.96·10⁻⁵ ≤ 5.0·10⁻⁵). ρ_lo > 1.9656 holds directly with margin 9.44·10⁻⁶ on 𝒥 and 1.36·10⁻⁵ on [R_*, r_1].
- Appendix B (D6): √(R² − 1) ≤ 2.4343059 (not 2.4343058; not used later).
- Appendix B §3, E3.2: 1.9656·sin(2a − B) ≥ 1.20338 (not 1.20339).
- Appendix B §3, Lemma 2.1: 10a − B − 1.06748 ≥ 2.709619 on 𝒥 (not 2.70962).
- Appendix B §3, Lemma 2.2: 1.52·10⁻⁵ (not 1.51·10⁻⁵) and 8a − B ≥ 2.9975418 (not 2.997542).
- Appendix B §3, Lemma 1.4: the threshold √(1.9656² + 1) is 2.20535…, so read t ≤ 2.2053 (not 2.2054); not load-bearing (Repair M3).
- Appendix B §3, fallback 1.9655: |∂A/∂u| reaches 1.37 at t = 1.085 (not ≤ 0.65), so the increase is ≤ 1.4·10⁻⁴ (not 7·10⁻⁵); with A(·, 1.9655) computed directly every dependent margin stays ≥ 0.03. Not needed, since 1.9656 holds.
- Appendix B §3: π − 8a ≥ 0.0233609 on 𝒥 (not 0.0233610); only π − 8a > 0 is used. "C-table ±1.4·10⁻⁵" means |C_R(t) − C_{r_1}(t)| ≤ 1.4·10⁻⁵ (max 5.9·10⁻⁶), not agreement with the 4-digit table.
- Step 4 / Appendix G(b): the m = 4 rotation Q′ uses τ′ = −68511808261983/942727686399593 (it appeared only in the run log); φ̄′ is the 10⁻¹⁵-grid rational of the `frame` rule (Appendix E §0.2 prints 12 decimals). The LOC conclusion is for φ ∈ U ∩ Φ_A.
- Step 6 / Appendix D: at ρ_A = 7/1000, δ = 1.41421357·ρ_A = 0.009899495 ≤ δ₀ = 0.0099 with margin 5·10⁻⁷: 7/1000 is essentially the largest ρ Theorem A′ allows.

Status after the re-check: computational side L3 (two independent implementations for C1_R, GLOB, LOC, MID; no floating-point assumption in the WL ones). The hand proofs (Steps 0–6 reasoning, Appendices A–E, and the inherited hand parts of F1–F8) remain pending independent human review.

## Status

**Answer: R ≤ R_*. The main claim is fully proved,** relative to the trust base stated above: the facts F1–F8 as given; faithful execution of the four reproduced programs (outputs in Appendix G); and, for computation C1_R only, IEEE-754 double arithmetic with libm errors ≤ 10⁻¹². The full chain Step 0 → Step 6 has been checked independently three times (forwards, backwards, and step by step), and the two exact programs were audited line by line. None of these checks found a logical gap. The few misstatements they found have been corrected in this text: the statement of Proposition RED, the presentation of the ρ_lo margin, and the source of the sharpness fact. No gap in the main claim remains. Two things are not gaps but would strengthen the result: an independent second implementation of GLOB/LOC (m = 4, 5) and of MID, and a re-run of the IEEE-free certificate 22b on [2.63169, 2.631692].

---

# Appendix A. The F7 proof document: text through Part W (Lemma D′), with its Appendix 1 (computation C1)

[Ed.: This is the text of the F7 proof document (the proof of R < r_1 quoted as fact F7 in the problem), through Part W and its Appendix 1, reproduced verbatim. Below it is used only for its lemmas, quoted at the radii checked in Appendix B. In particular: Lemma R1 (reduction to R = r_1) is replaced by Proposition RED (Appendix B §1); computation C1 at r_1 is replaced by C1_R (Appendix B §4, run in Appendix G(c)); computation C2 at r_1 (its §11, with Appendices 2–4, not reproduced) is replaced by GLOB on J (Appendix E, run in Appendix G(b)). References inside this text to its §§10–13 and Appendices 2–4 concern those superseded parts; the one program from them that is still used, ms5_witness_m.py, is reproduced as Appendix F.]

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
- *Files of the run.* The program `nb_check.py` and the driver `nb_par.py` are reproduced in full in Appendix 1 below; the run is re-done by executing `python3 nb_par.py` (or `python3 nb_check.py`) with both files in one directory.
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


## Appendix 1 — `nb_check.py` (computation C1) and its driver `nb_par.py`

```python
#!/usr/bin/env python3
"""nb_check.py -- No-Bridge finite check (computation C1), cases (FAR) and (NEAR-Y) of Part M Section 4.
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
# parallel driver for nb_check.py (computation C1): runs verify() on each of the 24 top-level K_X slices
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

# Appendix B. (RED) and (UNI): the reduction, and the F7 structural chain on an R-interval

[Ed.: Written before computation C1_R was run. C1_R has since been run on [2.63169, 2.631692] (NB_RLO = 263169/100000, NB_RHI = 1315846/500000) and printed ALL CASES VERIFIED; see Appendix G(c). The open items 4 of §6 are settled by Appendices C–E. "F7 text" = Appendix A.]

Plan. §1 proves (RED). §2 gives R-derivative bounds for the basic constants on 𝒥 := [r_0, r_1] = [2.63169, 2.6317]. §3 goes through the F7 text lemma by lemma: for each numerical inequality it either proves monotonicity in R or gives a margin-plus-derivative bound. §4 states how to make C1 valid on an R-interval, gives a diff, and proves that the modified finite statement implies Theorem NB on the interval. §5 checks Parts B (cont.), O, N and §9. §6 lists what remains open.

No code was run, and no computation was made other than by hand. Numerical values "at r_1" are taken from the F7 text unless I say that I re-derived them.

Convention. For R ∈ 𝒥, write a = a(R), d = d(R), B(R) = 12a − 2π + 2d. "(SH)_R" means (SH) with r_1 replaced by R. Here R ∈ 𝒥 with R ≥ R_*, which is needed for F3, so in practice R ∈ [R_*, r_1].

## 1. (RED) — proved

**Proposition RED.** Suppose some covering of the claim's type has R > R_*. Then there is a covering of the claim's type with radius R′ ∈ (R_*, R_* + 10⁻⁶] in which every boundary centre satisfies R′ − 1 ≤ |c_k| ≤ √(R′² − 1). [Ed.: corrected. The original sentence here, "the inner disks and the set of nine disks meeting S_{R′} are those of the original covering", need not hold: shrinking R to R′ may make an original inner disk meet S_{R′} or an original boundary disk miss it. The proof below establishes only that exactly nine disks meet S_{R′}, and only this count is used.] At R′ exactly nine disks meet S_{R′}; the normalisation moves the centres of those nine radially and leaves the other two disks fixed.

*Proof.*
1. Put R′ := min(R, R_* + 10⁻⁶). Then R_* < R′ ≤ R, so D_{R′} ⊆ D_R ⊆ ⋃ D(c_i,1).
2. *At least nine disks meet S_{R′}.* Since R′ > R_* > 2.61313 > 1/sin(π/8), we have 8a(R′) < π (F1). Each unit disk meets S_{R′} in an arc of measure ≤ 2a(R′) (F1), so eight such arcs cannot cover S_{R′}. But S_{R′} ⊂ D_{R′} is covered, and only disks meeting S_{R′} contribute to its covering. Hence at least nine disks meet S_{R′}.
3. *At most ten.* This is F4(i), since R′ > 2.
4. *Not ten.* If ten disks met S_{R′}, F4(ii) would give R′ < r_0 < R_*, which is false.

   So exactly nine disks meet S_{R′}: the covering is of the claim's type at R′.
5. *Normalisation (Lemma R2 at R′).* Lemma R2 is stated and proved for an arbitrary R. Its proof uses only:
   - 0 < w ≤ a(R′);
   - h = R′ sin w ≤ 1;
   - R′ > 1, so that m − s ≥ R′ − 1 > 0.

   For a boundary disk, its arc on S_{R′} has positive measure by F3 (every arc has a private open sub-arc; F3 applies since R′ ≥ R_*), so w > 0. Also w ≤ a(R′) by F1.
6. *Parts (a), (b) of R2.* Replacing each boundary centre c by c′ = (m − s)c/|c|:
   - keeps the arc of that disk on S_{R′}, so the disk still meets S_{R′} (R2(a));
   - keeps D_{R′} covered, since D(c) ∩ D_{R′} ⊆ D(c′) (R2(b)).

   The inner disks are untouched and still miss S_{R′}. So the new family is a covering of the claim's type at R′, and by R2(c) every boundary centre lies on the inner branch.
7. *Check of R2(c).* The discriminant is R′² cos² w − (R′² − 1) = 1 − h² ≥ 0, so the roots m ± s are real, and their product is R′² − 1. Hence m − s ≤ √(R′² − 1) ≤ m + s. Since f(R′ − 1) = 2R′(R′ − 1)(1 − cos w) ≥ 0, R′ − 1 is not in the open interval (m − s, m + s). Since R′ − 1 < √(R′² − 1) ≤ m + s, this forces R′ − 1 ≤ m − s. ∎

Remarks.
- F7 is not needed. R′ = min(R, R_* + 10⁻⁶) works whether or not R ≥ r_1.
- The same proof gives, for every target R′ ∈ (r_0, R] with R′ > 2.61313 and R′ ≥ R_*, a normalised covering of the claim's type at R′.
- The configuration at R′ satisfies (SH)_{R′}. Since R_* + 10⁻⁶ < 2.6316918 < r_1, R′ ∈ 𝒥.

## 2. R-derivative bounds on 𝒥 = [r_0, r_1] (width 10⁻⁵) — proved

**(D1)** a′(R) = −1/(R√(R² − 1)) and d′(R) = −2/(R√(R² − 4)). Both |a′| and |d′| decrease in R, so their maxima on 𝒥 are at r_0:
- r_0² = 6.92579226, √(r_0² − 1) = 2.434295, √(r_0² − 4) = 1.710495;
- hence |a′| ≤ 0.1561 and |d′| ≤ 0.4443 on 𝒥.

Consequence. For F(R) = αa(R) + βd(R) + γ with constants α, β, γ, and any R ∈ 𝒥,

  |F(R) − F(r_1)| ≤ 10⁻⁵ (0.1561|α| + 0.4443|β|).

The sign is known: F is monotone, decreasing in R when α, β ≥ 0.

**(D2) Bridge budget.** B = 12a − 2π + 2d is decreasing in R, and |B′| ≤ 12·0.1561 + 2·0.4443 = 2.762. With B(r_1) = 0.1206621, on 𝒥:

  B(r_1) ≤ B(R) ≤ 0.1206898 < 0.12069,  B/2 ≤ 0.0603449.

**(D3) The cost function C_R(t) = 2a(R) − 2 arctan z, with z = √(4 − (R − t)²)/(R + t).** For t ∈ [1, R] and R ∈ 𝒥, |∂C/∂R| ≤ 1.4.

*Proof.* Put N = √(4 − (R − t)²). Then ∂z/∂R = −[(R² − t²)/N + N]/(R + t)². On this range:
- |R − t| ≤ r_1 − 1 = 1.6317, so N ≥ √(4 − 1.6317²) = 1.15653, and N ≤ 2;
- 0 ≤ R² − t² ≤ r_1² − 1 = 5.92584;
- (R + t)² ≥ (r_0 + 1)² = 13.1892.

So |∂z/∂R| ≤ (5.92584/1.15653 + 2)/13.1892 = 0.5402. Since |d arctan z/dz| ≤ 1, |∂C/∂R| ≤ 2·0.1561 + 2·0.5402 = 1.393 ≤ 1.4. ∎

Hence |C_R(t) − C_{r_1}(t)| ≤ 1.4·10⁻⁵ for t ∈ [1, R], R ∈ 𝒥. Every tabulated C value at r_1 in the F7 text, with t ≥ 1, is valid on 𝒥 after subtracting 1.4·10⁻⁵ (as a lower bound) or adding it (as an upper bound).

The monotonicity "C_R is decreasing on [R − 2, R − 2/R]" is proved in Part D for every R > 2. On 𝒥, R − 2/R ≥ r_0 − 2/r_0 = 1.8717221 > 1.8717. So "C decreasing on [R − 2, 1.8717]" holds on all of 𝒥.

**(D4) The inner-branch radius ρ_R(w) = R cos w − √(1 − R² sin² w), 0 ≤ w ≤ a(R).**
- ∂ρ/∂w = R sin w (R cos w/√(1 − R² sin² w) − 1) ≥ 0, since R cos w ≥ √(R² − 1) ≥ 1 ≥ √(1 − R² sin² w).
- ∂ρ/∂R = cos w + R sin² w/√(1 − R² sin² w) > 0.

**(D5) ρ_lo is increasing in R, and ρ_lo(R) > 1.9656 on 𝒥.** The good-disk radius bound of Lemma E3.1 is ρ_lo(R) := ρ_R(a − B/2). Since a − B/2 = π − 5a(R) − d(R) =: w(R), which is increasing in R, (D4) shows that ρ_lo is increasing in R. Its minimum on 𝒥 is at r_0.

*Bound.* From (D1), w(r_0) ≥ w(r_1) − 10⁻⁵(5·0.1561 + 0.4443) = w(r_1) − 1.2248·10⁻⁵. On the rectangle [w(r_1) − 1.3·10⁻⁵, w(r_1)] × 𝒥:
- R sin w ≤ 0.851405 and √(1 − R² sin² w) ≥ 0.524508;
- R cos w ≤ 2.49019;
- so ∂ρ/∂w ≤ 0.851405·(2.49019/0.524508 − 1) ≤ 3.20 and ∂ρ/∂R ≤ 1 + 0.851405·0.3236/0.524508 ≤ 1.53.

Hence ρ_lo(r_0) ≥ ρ_lo(r_1) − 3.20·1.2248·10⁻⁵ − 1.53·10⁻⁵ ≥ ρ_lo(r_1) − 5.45·10⁻⁵.

*The value at r_1.* The F7 text gives the components R cos w = 2.4901714 and √(…) = 0.5245082, so ρ_lo(r_1) = 1.9656632. I re-derived d(r_1) = 0.8632593 and w(r_1) = 0.3294464. The uncertainty in ρ_lo(r_1) from 7-digit inputs is ≤ 1.5·10⁻⁶. Therefore

  ρ_lo(R) ≥ 1.9656632 − 1.5·10⁻⁶ − 5.45·10⁻⁵ ≥ 1.965607 > 1.9656  for all R ∈ 𝒥.

The margin is about 7·10⁻⁶. This is the tightest constant in the whole check, and I flag it.

- On [R_*, r_1] the drop is ≤ 5.0·10⁻⁵, so the margin is about 1.1·10⁻⁵.
- A one-line outward-rounded evaluation of ρ_{r_0}(π − 5a(r_0) − d(r_0)) would settle it. I estimate the value at 1.96561.
- Cheap fallback: use ρ_lo := 1.9655. Every dependent constant then moves by ≤ 10⁻⁴ (see §3, Lemma 1.4), and all margins that use ρ_lo are ≥ 0.03.

**(D6) Other R-dependent quantities.** The following are monotone in R, and their values on 𝒥 lie within the stated distances of the r_1 values:
- ρ_0 = R − 2, 3 − R, 4 − R, R − 1: each within 10⁻⁵;
- √(R² − 1) ≤ 2.4343058 (increasing in R);
- u* = √(1 − ρ_0²) ≤ 0.77523.

The function A(t, u) does not depend on R. Neither do r(t) = arcsin(1/t) or m0(t) = A(t, 1.9656).

## 3. (UNI) — lemma by lemma, for R ∈ [R_*, r_1]

The numerical bounds below hold on all of 𝒥 = [r_0, r_1]. The structural uses need F3, which is stated for R ≥ R_*, and F4(ii), which needs R ≥ r_0. So the statements are claimed for R ∈ [R_*, r_1]. This range contains (R_*, R_* + 10⁻⁶].

The F3 proof itself only uses "eight arcs never cover", which holds for R > 2.61313. Using that, everything below would extend to [r_0, r_1], but F3 as given does not cover R < R_*.

Verdicts: **G** = valid for every R (no numerics at r_1); **M** = numerical, with the direction proved and the margin checked on 𝒥.

**§1. Reductions and order of the arcs**
- Lemma R1 is replaced by Proposition RED (§1 above).
- Lemma R2: G.
- Lemma R3: G. It uses F1, F3 and 4a < 2π.
- (SH)_R: as in the text, with R in place of r_1.

**Part A**
- Lemma A0: G. It uses only that eight arcs never cover S_R, which holds for R > 2.61313.
- Lemmas A1, A2, Corollary A3: G.
- Lemma A4: M.
  - j ∈ {k−1, k+2}: needs 2π − 10a − 2d > 0. This is increasing in R, with value 0.658893 at r_1, so it is ≥ 0.658868 on 𝒥 by (D1).
  - (1): Σ_{m∉T} d_m ≤ B/2 ≤ 0.0603449 by (D2).
  - (2): not load-bearing. The bounds 1.1832 ≤ |q_k| ≤ 2.4728 change by O(10⁻⁵) and are not used.
  - (3): 2π − 4d − 6a is increasing in R and equals 0.491483 at r_1, so it is ≥ 0.491456 on 𝒥.
- Lemma A5: uses F4(ii), whose threshold is r_0. It is valid for R ≥ r_0, and in particular on [R_*, r_1].
- Lemma C1 (split line): G.

**Part B §1 and Lemma S**
- Lemma N1: M, the same inequality as A4.
- Lemma N2: M. It needs 2π − 2a − 2d > 0 (equal to 3.7771 at r_1). The new statement reads "≤ B(R) ≤ 0.12069".
- Lemma N3: M, the same inequality as A4(3).
- Lemma N4: G.
- Lemma S: G.

**Part D**
- Lemma G: G (valid for any R > 2).
- The identity Σ(2a − g_k) = 2δ(R): G.
- Monotonicity of g_sym on [R−2, R−2/R]: G. It contains [R−2, 1.8717] for R ∈ 𝒥 (D3).
- The table: on 𝒥, each C value is within 1.4·10⁻⁵ of the tabulated one for t ≥ 1 (D3). The entries with t < 1 are not load-bearing.

**Part E**
- Lemma E2.1: G, with ρ_0 = R − 2.
- Lemma E2.2: G in form. The constants 1 − ρ_0 = 3 − R and u* = √(1 − ρ_0²) depend on R, with u* ≤ 0.77523 on 𝒥 and reach ≤ 1.77523. In the excerpt, u* and "near disk" are not used downstream: Part M uses 3 − R and 4 − R directly.
- Lemma E3.1: M.
  - ρ_lo = 1.9656 is valid on 𝒥 by (D5). This is the thin margin, about 7·10⁻⁶.
  - g_j ≥ 2a − B = 2π − 10a − 2d ≥ 0.658868 on 𝒥 (increasing in R).
  - The corrected statement reads: d_j ≤ B(R)/2 ≤ 0.0603449, ρ_j ≥ 1.9656, and g_j ∈ [0.658868, 2a(R)].
- Lemma E3.2: M. ρ_lo sin(2a − B) ≥ 1.9656·sin(0.658868) ≥ 1.9656·0.612222 = 1.20339 > 1. Also 2a ≤ 0.77957 < π/2.
- Corollary E3.3: G.

**Part M §1**
- Display (1.1) and Lemma 1.2: G.
- Lemma 1.3: M. C_R(1.085) ≥ 0.122013 − 1.4·10⁻⁵ = 0.121999 > 0.12069 ≥ B(R), with margin 1.3·10⁻³. C_R is decreasing on [R−2, 1.8717] (D3). So t_i > 1.085 on [R_*, r_1].
- Lemma 1.4: M.
  - M ≤ arcsin(1/ρ_lo) ≤ arcsin(1/1.9656) = 0.53374. This is R-free given (D5).
  - The threshold t ≤ √(1.9656² + 1) = 2.2054 is R-free.
  - λ ≥ 2a(R) − κ − 0.53374 ≥ 0.24581 − κ, because a(R) ≥ a(r_1) for R ≤ r_1.
  - If the fallback ρ_lo = 1.9655 is used: arcsin(1/1.9655) ≤ 0.53378, λ ≥ 0.24577 − κ, and m0 values increase by ≤ 7·10⁻⁵ (|∂A/∂u| ≤ 0.65 at u ≈ 1.966, t ≤ 1.35).
- Angular positions (1.2): G.

**Part M §2**
- Bookkeeping: needs 2π − 10a > 2r(1.085) = 2.34467. Here 2π − 10a ≥ 2.385395 on 𝒥 (increasing in R).
- Lemma 2.1: M. 10a − B − 2·0.53374 = 2π − 2a − 2d − 1.06748 is increasing in R. Its value is 2.70963 at r_1, so it is ≥ 2.70962 on 𝒥, which is > 2.34467.
- Lemma 2.2: M.
  - 8a − B = 2π − 4a − 2d is increasing in R, so it is ≥ 2.997557 − 1.51·10⁻⁵ = 2.997542 on 𝒥.
  - It is compared with 2.962253. That quantity is built from r and m0 only, so it is R-free. Margin 0.0353.
  - Cost step: C(1.2) + C(1.35) ≥ 0.124052 − 2.8·10⁻⁵ = 0.124024 > 0.12069 ≥ B. Margin 3.3·10⁻³.
- Corollary 2.3: G.

**Part M §3 (Lemma 3.1): M.**
- π − 8a ≥ 0.0233610 > 0 on 𝒥.
- Θ ≥ π − 5a(R) + d_t ≥ 1.1926976 + d_t, since π − 5a is increasing in R.
- Θ ≤ 4a ≤ 1.55912 < π/2.
- ρ′ ≥ R − 1 ≥ 1.63169.
- d_t ≤ B/2 ≤ 0.0603449.
- ρ_t ≥ ρ_lo ≥ 1.9656 (D5).
- ρ_R(a − 0.03) ≥ 2.0869896 − 2.7·10⁻⁵ ≥ 2.086962. I re-derived the r_1 value: 2.463206 − 0.376216 = 2.086990. The derivative bound is |dρ/dR| ≤ |∂_wρ||a′| + |∂_Rρ| ≤ 5.15·0.1561 + 1.81 ≤ 2.7.
- The monotonicity of G in ρ_t, ρ′ still holds: ρ_t cos Θ ≤ 2.4344·0.36916 < 0.9 < ρ′, and ρ′ cos Θ < 0.9 < ρ_t.
- Recomputed bounds on 𝒥, using cos Θ ≤ cos(1.1926976 + d_1) ≤ (value at r_1) + 7.9·10⁻⁶:
  - d_t ∈ [0, 0.03]: G ≥ 2.086962² + 1.63169² − 2·1.63169·2.086962·0.369155 = 4.355402 + 2.662412 − 2.514152 = 4.5037 > 4.
  - d_t ∈ [0.03, B/2]: G ≥ 1.9656² + 1.63169² − 2·1.63169·1.9656·0.341112 = 3.863583 + 2.662412 − 2.188063 = 4.3379 > 4.

**Part M §4**
- Lemma 4.1 (X), (Y), (S): G in form. The lower bound D ≥ 2.70962 − 2.34467 > 0 holds by the Lemma 2.1 line above.
- Lemma 4.2: M. This is the tightest hand margin.
  - Put c₄(R) := C_R(4 − R) = 2a − 2 arctan(√(4 − (2R − 4)²)/4). Its derivative satisfies |c₄′| ≤ 2·0.1561 + 2·(2R − 4)/(2√(4 − (2R − 4)²)) ≤ 0.3122 + 0.815 ≤ 1.13. So c₄ ≥ 0.0400011 − 1.13·10⁻⁵ ≥ 0.039989 on 𝒥.
  - Hence each C(t_i) ≤ B − 2c₄ ≤ 0.12069 − 0.079978 = 0.040712.
  - But C_R(1.36) ≥ 0.0415625 − 1.4·10⁻⁵ = 0.0415485. Margin 8.4·10⁻⁴ (it was 8.9·10⁻⁴ at r_1).
  - So t_1, t_3 ∈ (1.36, 4 − R]. The range 4 − R ≤ 1.36831 lies inside the decreasing range of C.
  - Then A(t_i, u) ≤ A(1.36, 3 − r_0) = arccos(0.985252/1.001803) < 0.183. This is far below the left side 6a − B − 1.06748 = 2π − 6a − 2d − 1.06748 ≥ 1.15048 on 𝒥.
- Addendum (Q2): G. It needs 1 + u ≤ R − 2/R, which is a hypothesis of (Q2) itself.
- Repair M1: G.
- Repair M2: M. It uses 6a ≤ 2.33870 and 4a ≤ 1.55912 on 𝒥; the margins (5.111 vs 3.511, etc.) are huge.
- Repair M3 and Supplement M4: G.
- The finite systems (FAR) and (NEAR-Y) are defined with R-dependent data:
  - a, B, 3 − R, R − 1, ρ_0;
  - C_R and ρ_R.

  The reduction to them is valid at every R ∈ [R_*, r_1]. Their infeasibility is the content of C1; see §4.

**Summary of (UNI).** Every hand inequality of the excerpt up to the end of Part M §4 holds on 𝒥, with corrected constants. These are:
- B ≤ 0.12069 and B/2 ≤ 0.0603449;
- ρ_lo = 1.9656, the thin margin;
- 2a − B ≥ 0.658868;
- C values within 1.4·10⁻⁵ of the table;
- c₄ ≥ 0.039989;
- the 3.1 bounds 4.5037 and 4.3379.

The smallest margins are about 7·10⁻⁶ (ρ_lo, fixable by the fallback 1.9655 at no cost) and 8.4·10⁻⁴ (Lemma 4.2). The only computational input still at r_1 only is C1.

## 4. Computation C1 on an R-interval

**Method: interval R.** Replace the point enclosure of r_1 by an enclosure of a whole interval [R_lo, R_hi] ⊆ 𝒥, and check that every place where R enters is used in a sound direction. I do not try to prove monotonicity of (FAR) and (NEAR-Y) in R. A clean monotonicity argument does not seem available: B increases while a and 3 − R move in different directions.

**Diff against `nb_check.py` (Appendix 1).**

```diff
--- nb_check.py
+++ nb_check_R.py
@@ imports
-import math, heapq, sys, time
+import math, heapq, sys, time, os
@@ constants
-R = from_fraction(Fraction(26317, 10000))
+R_LO_FR = Fraction(os.environ.get("NB_RLO", "263169/100000"))
+R_HI_FR = Fraction(os.environ.get("NB_RHI", "26317/10000"))
+assert Fraction(263169, 100000) <= R_LO_FR <= R_HI_FR <= Fraction(26317, 10000)
+R = Iv(dn(float(R_LO_FR)), up(float(R_HI_FR)))   # encloses every R in [R_LO_FR, R_HI_FR]
@@
-TMIN, TMAX = 1.0, dn(R.lo)
+TMIN, TMAX = 1.0, R.hi            # t < R <= R_hi for every admissible R (superset)
@@ def eval_X(box, Khi, want):
     if want == "slack": return up(rhs - lhs)
     al = A_up(RHO0, u)
+    if al is None: return None    # u > R-1 for every R in the interval: excluded by Repair M1
     return up(up(al + A3) + M3)
@@ def eval_Y(box, KY, want):
     if want == "slack": return up(rhs - lhs)
     al = A_up(RHO0, v)
+    if al is None: return None    # v > R-1 for every R in the interval: excluded by Repair M1
     return up(up(al + A4) + M4)
@@ def main():
-    print("a =", A_, " B =", B_, " 3-R =", U0)
+    print("R =", R, " a =", A_, " B =", B_, " 3-R =", U0)
```

`nb_par.py` needs no change: it imports the module and the constants are module-level. Rename the module, or keep the file name `nb_check.py`.

Run commands:
- `NB_RLO=263169/100000 NB_RHI=26317/10000 python3 nb_par.py 12`
- If that fails on some slice, first try `NB_RHI=1315846/500000`, i.e. the interval [2.63169, 2.631692]. It contains (R_*, R_* + 10⁻⁶], because R_* + 10⁻⁶ < 2.6316918.
- Alternatively, partition [R_lo, R_hi] into subintervals and run each one. The conclusion for the union follows.

The same three edits apply to the Mathematica certificate 22b:
- R → Interval[{R_lo, R_hi}];
- the upper end of the t-range set to R_hi;
- an undefined α(u) treated as infeasible.

[Ed.: The modified program was run on [2.63169, 2.631692]; output in Appendix G(c).]

How the margins should behave. Widening R to 10⁻⁵ adds an overestimate of order |∂/∂R| · 10⁻⁵ ≲ 3·10⁻⁵ to each bound, by the derivative bounds of §2. In the earlier float search the FAR objective peaked at 5.51 against 2π. The failure risk is therefore mainly extra box splitting near constraint boundaries, not a genuine failure. This is a heuristic expectation, not a proof.

**Theorem C1_R.** Suppose the modified program prints `ALL CASES VERIFIED` with interval [R_lo, R_hi] ⊆ 𝒥. Then for every R ∈ [R_lo, R_hi], (FAR) and (NEAR-Y), with the data at R, have no solution. Hence Theorem NB holds under (SH)_R for every R ∈ [R_lo, R_hi] ∩ [R_*, r_1].

*Proof.* Fix R ∈ [R_lo, R_hi]. The interval R contains it, since dn(float(R_LO)) ≤ R_LO and up(float(R_HI)) ≥ R_HI.

By the fundamental theorem of interval arithmetic, applied with the same outward-rounding kernel and libm assumption as in F7 §5, every interval the program computes from R encloses the value of the same expression at the fixed R. This covers:
- A_, D_, B_, SIXA, FOURA, TWOA;
- RHO0, U0, RM1, TSTAR;
- the R-dependent sub-expressions inside C_lo and rho_lo.

Now go through the soundness list of F7 §5 with "R" read as the fixed R. Each item stays valid; these are the places where R enters:
1. *Roots.* The true u ranges over (3 − R, R − 1] ⊆ [U0.lo, RM1.hi], by Lemma 4.2 and Repair M1 at R. The true v in NEAR-Y satisfies v ≤ 3 − R ≤ U0.hi. The true t satisfies t ∈ (1.085, R) ⊆ [1, R.hi] = [TMIN, TMAX]; this is the reason TMAX had to change, since the old value dn(R.lo) would cut off t ∈ [R_lo, R). The true κ_3, κ_4 satisfy κ ≤ B(R) ≤ B_.hi = BHI.
2. *Slices.* They cover [0, BHI] ⊇ [0, B(R)]. And KY = up(BHI − Klo) ≥ B(R) − K_X ≥ K_Y.
3. *C_lo(t).* It returns a lower bound of C_R(t) over the box, because it is an enclosure over (R, t). So κ ≥ C_R(t) ≥ C_lo is a valid necessary condition.
4. *rho_lo(dmax).*
   - wl = (A_ − dmax).lo ≤ a(R) − dmax, and wl ≥ 0 because dmax ≤ BHI/2 < a.
   - The true deficit of a good disk is ≤ min(κ, B(R)/2) ≤ dmax, so its true radius is ≥ ρ_R(a(R) − dmax) ≥ ρ_R(wl). This uses (D4) at R; the domain condition holds since wl ≤ a(R).
   - The returned value (R·cos wl − √(1 − R² sin² wl)).lo is ≤ ρ_R(wl), using only R.lo for the first term and the upper end of the root for the second.
   - The isqrt clipping affects only the lower end of the root, which is not used.
5. *M_up.* The test sqr(t).hi ≤ RL² + 1 uses RL ≤ the true radius bound, so its implication at R is as in F7. The arcsin(1/t) branch is R-free.
6. *C2_lo(u).* If th ≤ TSTAR.lo ≤ R − 2/R, then R − 2 ≤ t_2 ≤ 1 + u ≤ th lies in the decreasing range of C_R (D3/Part D at R). So C_R(t_2) ≥ C_R(th) ≥ C_lo(P(th)).
7. *(X) and (Y).* The left sides use SIXA.lo ≤ 6a(R) and FOURA.lo ≤ 4a(R).
8. *(S).* α(u) = A(R − 2, u) ≤ A_up(RHO0, u), which is an enclosure over the (R, u) box. If A_up(RHO0, u) is None, then u − (R′ − 2) > 1 for every R′ in the interval and every u in the box. In particular u > R − 1, which is impossible by Repair M1. So returning None (infeasible) is sound. Without this line the program would raise a TypeError rather than pass silently, so the change matters only for completeness.
9. *Decisions.* Every remaining decision is a comparison of R-free quantities: 2π, A_up(t, u) with t and u box variables, and iasin(1/t).

Hence each box the program discards contains no solution of the R-system. The covering and best-first invariants of F7 §5 are unchanged. So `ALL CASES VERIFIED` implies that (FAR) and (NEAR-Y) are infeasible at R. Combined with §§1–4 of Part M, valid at R by §3 above, this proves Theorem NB at R. ∎

## 5. Parts B (continued), O, N and §9

**Theorem J and Lemma K.** These use only (SH)_R, (NB), Lemma A2 and N4(c), so they are G. Theorem J(1) uses N4(c), which is G.

**Corollary K1.** It uses Lemma A5, hence F4(ii). This is the one R-dependence here: it needs R ≥ r_0, which holds.

**Part O.**
- Lemmas L1 and L2: pure geometry and topology.
- §2 set-up (f1)–(f3), the components W, and the Ray lemma: G.
- Proposition P uses:
  - Lemma A0 (int A_k ≠ ∅), which holds for R > 2.61313;
  - |c_E| ≤ 1 < R − 1, i.e. R > 2;
  - |σ| < 2, from c_E ∉ ℓ.
- Theorem O2: G.

**Part N, Theorem N.** G.

**§9.**
- Definition of Σ_m: replace "at R = r_1" by "at R". This affects ρ_max = √(R² − 1) in (a) and the w_k in (b).
- Proposition 9.1 at R: step 1 uses Proposition RED in place of Lemmas R1 and R2. Steps 2–7 are G, given F3 at R (R ≥ R_*), Theorem NB at R, and Corollary K1 (R ≥ r_0).

So, beyond (SH) and (NB), the only R-dependent lemmas in these parts are:
- Corollary K1, through Lemma A5 and F4(ii): needs R ≥ r_0;
- Proposition P and Theorem J(1), through Lemma A0 and F3: need R > 2.61313, and R ≥ R_* for F3 as stated.

**Proposition 9.1_R.** Let R ∈ [R_*, r_1], and assume Theorem NB holds at R, for example via Theorem C1_R. If a covering of the claim's type with radius R exists, then its normalisation (Proposition RED) solves Σ_m(R) for some m ∈ {1, …, 8}.

In particular, if there is a counterexample to the claim and the modified C1 passes on an interval containing (R_*, R_* + 10⁻⁶], then Σ_m(R′) is solvable for some R′ ∈ (R_*, R_* + 10⁻⁶] and some m ∈ {1, …, 8}.

## 6. Status

**Proved here.**
- (RED), in full (§1).
- The R-derivative bounds of §2.
- (UNI) for every hand lemma of the F7 excerpt through Part M §4, and for Parts B (cont.), O, N and §9 at every R ∈ [R_*, r_1], with corrected constants as in §3.
- Theorem C1_R: the modified program's success on [R_lo, R_hi] implies Theorem NB on that interval.

**Conditional / not done.**
1. **The modified C1 has not been run.** Theorem NB on the R-interval, and hence Proposition 9.1_R, is conditional on the run printing `ALL CASES VERIFIED`. Fallbacks: the narrower interval [2.63169, 2.631692], or a partition into subintervals. [Ed.: Done: the narrower interval [2.63169, 2.631692] was run and printed ALL CASES VERIFIED (Appendix G(c)).]
2. **ρ_lo = 1.9656 has a margin of only about 7·10⁻⁶ on 𝒥.**
   - The bound is based on the 7-digit r_1 components quoted in F7 and on my derivative bounds.
   - It should be confirmed by one outward-rounded evaluation of ρ_{r_0}(π − 5a(r_0) − d(r_0)), or replaced by 1.9655 (§3, Lemma 1.4 line). Every downstream margin absorbs that change.
3. Hand values at r_1 copied from the F7 text are trusted. I re-derived only d(r_1), w(r_1), ρ_R(a − 0.03) and the derivative bounds.
4. Out of scope and still open:
   - excluding Σ_m uniformly in R on (R_*, R_* + 10⁻⁶] (Part W/C2 at an R-interval);
   - the analysis near the Melissen configuration (F6′).
5. For R ∈ [r_0, R_*), the chain would also need F3 below R_*. Its proof only uses "eight arcs never cover", but F3 as given does not cover that range. This range is not needed for the claim.



# Appendix C. Part W on an R-interval, Lemma LOC, and the transfer to the slice coordinates

[Ed.: §§1 and 3.1–3.3 of the original document. Omitted as superseded or unused: §1.1 (a diff against the r_1 program; the complete program actually run is given in Appendix E §3); the end of §3.3 (a conclusion for the abandoned value δ = 9·10⁻⁷, replaced below by the conclusion at δ₁ = 3/1000 actually run); §3.4 (a conditional chain via "downward closure", replaced by §1 Steps 0–6 of this document); §3.5 and §§4–6 (heuristics, predictions); §2 (Theorem S, Theorem S′ and Lemma I, not used, since MID is applied to the actual covering). The "high-precision minimiser of §4.6" mentioned in §3.2 is the 60-digit Levenberg–Marquardt refinement of Appendix E §2; how multipliers are chosen never affects soundness.]

Plan (written first; the sections below are filled in order):
1. Rigorous R-interval version of Part W (P̃_m(B; J), J = [R_lo, R_hi]) with proofs, plus concrete program changes. [§1]
2. Check of Theorem S, and a variant S′ that applies directly to solutions of P_m(φ). [§2]
3. LOC lemma (localisation certificates ⇒ centres within δ), and the transfer to the F6′ normalisation, with explicit constants. Includes the η–δ relation. [§3]
4. Degeneration analysis near φ̄: linear vs quadratic directions, box-size scaling, termination, box counts, precision floor, reformulations. [§4]
5. Splits m ≠ 4, 5. [§5]
6. Status: what is proved, what is heuristic, what is open. [§6]

No code was run in this task: I had no code execution. Every statement about what a computation "would" print is a prediction, and is marked as one.

---

## §1. Part W on an R-interval

Fix rationals 2 < R_lo ≤ R_hi. Put J = [R_lo, R_hi]. For R ∈ J, Σ_m(R) is Σ_m with r_1 replaced by R: (P0), (a) with R − 1 ≤ |c_k| ≤ √(R² − 1), (b) with w_k computed at R, and (c), (d) unchanged. That Σ_m(R) holds for some m is the job of the structural chain, which is re-checked separately. Here I use only its conclusion. Write s_R(ψ) = R(cos ψ, sin ψ) and e(ψ) = (cos ψ, sin ψ).

Constants:
- A: a rational with A ≥ 2·arcsin(1/R_lo). Since arcsin(1/R) decreases in R, A ≥ 2a(R) for every R ∈ J.
- RHO: a rational with RHO ≥ √(R_hi² − 1). Then RHO ≥ √(R² − 1) for every R ∈ J.
- M = 7/2. This requires RHO ≤ 2.45 and R_hi < 2.64.

Φ_A is the polytope {φ_0 = 0, φ_9 = 2π, 0 ≤ Δ_k ≤ A}. It contains Φ(R), the polytope with bound 2a(R), for every R ∈ J.

**Lemma W_J.** Let R ∈ J and suppose (c_E, c_F, c_1, …, c_9) solves Σ_m(R). Then, after a rotation about 0, there is φ ∈ Φ(R) ⊆ Φ_A with |c_k − s_R(φ_{k−1})| ≤ 1 and |c_k − s_R(φ_k)| ≤ 1 for all k.

*Proof.* This is the proof of Lemma W word for word, with r_1 replaced by R. Step 1 uses only (R − |c_k|)² ≤ 1 and the AM–GM inequality R² − 1 + ρ² ≥ 2ρ√(R² − 1), which holds for every R > 1. It gives w_k ≤ a(R). Steps 2–4 do not use the value of R. ∎

**Theorem C_J.** If Σ_m(R) has a solution for some R ∈ J, then P_m(φ; R) is feasible for some φ ∈ Φ(R). Here P_m(φ; R) is P_m(φ) with s replaced by s_R and ρ_max replaced by √(R² − 1).

*Proof.* Same as Theorem C. ∎

**The relaxed system P̃_m(B; J).** Let B = Π_{k=1}^{8} [α_k, β_k] with β_k − α_k ≤ 3/2. For k = 1, …, 8 choose a vector n̂_k and a rational u_k > 0 with u_k ≤ n̂_k·e(α_k) and u_k ≤ n̂_k·e(β_k). Put h_k := R_lo·u_k.

P̃_m(B; J) is P_m(φ) with:
- s(φ_k) replaced by an unknown σ_k (k = 1, …, 8), and s(φ_0) = s(φ_9) replaced by one unknown σ_9;
- constraints |σ_k| ≤ R_hi and n̂_k·σ_k ≥ h_k (k ≤ 8);
- constraints |σ_9| ≤ R_hi and (1, 0)·σ_9 ≥ R_lo;
- anchors |c_E| ≤ 1 and |c_k| ≤ RHO;
- the pair constraints (P2)–(P4), unchanged.

Every constraint is a pair, anchor or half-plane constraint of Lemma D′. Unlike the single-R case, σ_9 is no longer forced to one point. It ranges over the convex cap {|σ| ≤ R_hi, σ_x ≥ R_lo}, and Lemma D′ handles this without change.

**Corollary W1_J.** If R ∈ J, φ ∈ Φ_A ∩ B and P_m(φ; R) is feasible, then P̃_m(B; J) is feasible.

*Proof.* Put σ_k := s_R(φ_k) for k ≤ 8 and σ_9 := (R, 0). Then:
- |σ_k| = R ≤ R_hi, and σ_9·(1, 0) = R ≥ R_lo.
- By the half-plane lemma with R = 1 (β_k − α_k ≤ 3/2 < π/2, both end values ≥ u_k > 0), n̂_k·e(φ_k) ≥ u_k. Hence n̂_k·σ_k = R·n̂_k·e(φ_k) ≥ R·u_k ≥ R_lo·u_k = h_k. This step uses u_k > 0 and R ≥ R_lo.
- The anchor bounds hold because √(R² − 1) ≤ RHO.
- The pair constraints are those of P_m(φ; R). ∎

**Lemma M35_J.** If RHO ≤ 2.45 and R_hi < 2.64, every solution of P̃_m(B; J) has |x_v| ≤ 7/2.

*Proof.* The proof of M35 goes through unchanged: |σ_k| ≤ R_hi < 2.64, |c_k| ≤ 2.45, |p_k| ≤ 3.45, |t_j| ≤ 2 and |c_F| ≤ 3. ∎

**Corollary W2_J.** Fix m. Suppose a finite family of boxes covers {(φ_1, …, φ_8) : φ ∈ Φ_A}, and every box is either propagation-empty (with A as above) or certified by Lemma D′ for P̃_m(B; J) with M = 7/2. Then Σ_m(R) has no solution for any R ∈ J.

*Proof.* Combine Theorem C_J, Corollary W1_J, Lemma M35_J and Lemma D′. The propagation keeps Φ_A ⊇ Φ(R) for every R ∈ J. ∎

Variant with an excluded set: suppose the leaves are allowed to be empty, certified, or contained in a fixed box U. Then the conclusion is: for every R ∈ J, every solution of Σ_m(R) gives (after the rotation of Lemma W_J) some φ ∈ U with P_m(φ; R) feasible.

Concrete choice of J for the task:
- R_lo = R̄ = 263169077261980820552/10²⁰. By I_*, R̄ < R_* (R_* − R̄ ≈ 1.5·10⁻²¹).
- R_hi = 2631692/10⁶. This exceeds R_* + 10⁻⁶ by about 2.3·10⁻⁷.
- RHO = sqrt_up(R_hi² − 1) ≈ 2.43430 ≤ 2.45, and R_hi < 2.64.

Remark (only R_lo matters near Melissen). In P̃_m(B; J), R_hi enters only through the upper bounds |σ| ≤ R_hi and |c_k| ≤ RHO. Near Melissen both are inactive: the σ's want to move inward, and the boundary centres have |c| ≤ 2.35 < 2.434. So the relaxed system behaves like the single-radius system at R_lo, with each σ_k allowed to sink to depth about R_lo·(1 − cos ε_k) ≈ R ε_k²/2 below S_{R_lo} (ε_k is the half-width of the box in coordinate k). Making J wider costs essentially nothing. Making J reach down to R_* costs everything: P̃_5(B; J) is feasible whenever φ̄ ∈ B, because Melissen solves P_5(φ̄; R_*) and R_* ∈ J.

### §1.1 [Ed.: omitted — program diff superseded by the complete program text of Appendix E §3.]

---

## §3. LOC: localisation certificates and the transfer to F6′

### §3.1 Frame data (exact objects; floats only to choose them)
- **Labels.** In the witness frame for m = 5: E = F5 disk 1, F = F5 disk 2, and (D_1, …, D_9) = F5 disks (9, 7, 11, 10, 6, 8, 4, 3, 5). This order is counter-clockwise in F5: the centre angles are 3.006, 3.628, 4.340, 5.084, 5.797, 0.136 (+2π), 0.800, π/2, 2.342 (+2π). So no reflection is needed. Let λ be the relabelling map witness → F5. F5 disk 3 is D_8.
- **Rotation.** Q is an exactly orthogonal rational rotation, Q = [[c, −s], [s, c]] with c = (1 − τ²)/(1 + τ²), s = 2τ/(1 + τ²) and τ ∈ ℚ, τ ≈ tan(θ_0/2). Here θ_0 ≈ π/2 − atan2(−2.147991599, 0.950361552) ≈ 2.72478 is the angle that takes the witness frame to the F5 frame (it puts c(D_8) on the positive y-axis). The choice of τ affects only whether the certificates exist, never their soundness.
- **References.** ξ_v := Qᵀ c̄_{λ(v)}, which is exactly rational. The row vectors of Q are n^x = (c, −s) and n^y = (s, c), so (Qc)_x = n^x·c and (Qc)_y = n^y·c.

### §3.2 The LOC lemma
**Lemma LOC.** Let U be a rational box in φ-space with widths ≤ 3/2 and with half-plane data as in §1, let J = [R_lo, R_hi] satisfy the hypotheses of §1, and let δ > 0 be rational. Consider the 44 systems

  𝒮(v, ι, e) := P̃_5(U; J) ∪ { e·n^ι·c_v ≥ e·c̄_{λ(v),ι} + δ },

for v ∈ {c_E, c_F, c_1, …, c_9}, ι ∈ {x, y} and e ∈ {+1, −1}. Suppose each 𝒮(v, ι, e) has a Lemma D′ certificate with V < 0 and M = 7/2. The extra constraint is just one more half-plane, with n = e·n^ι and h = e·c̄ + δ; Lemma D′ needs no sign condition on h. Then for every R ∈ J, every φ ∈ U ∩ Φ_A and every solution of P_5(φ; R),

  |(Q c_v)_ι − c̄_{λ(v),ι}| < δ  for all v and ι.

*Proof.* A solution of P_5(φ; R) gives a solution of P̃_5(U; J) (Corollary W1_J). Suppose some coordinate violated the bound, say e·((Q c_v)_ι − c̄_ι) ≥ δ. Then the same point would solve 𝒮(v, ι, e). The solution set of 𝒮 is a subset of that of P̃_5(U; J), so the a-priori bound M = 7/2 holds for 𝒮, and Lemma D′ says 𝒮 is infeasible. This is a contradiction. ∎

The exact checker needs only one new function: for each of the 44 triples, append the triple's half-plane to `halfplanes(ep, U)`, run `W.minimize` (or the high-precision minimiser of §4.6), and check that `V_exact(...) < 0`. The swapped split m = 4 works the same way around φ̄′, with its own labels λ′ (E = disk 2, F = disk 1; D_1..D_9 = disks 8, 4, 3, 5, 9, 7, 11, 10, 6) and its own Q′.

### §3.3 Transfer to the F6′ normalisation
Assume the conclusion of LOC holds for some δ. The requirement on δ is derived below. Let R ∈ (R_*, R_* + 10⁻⁶] and let (c_v) be a solution of P_5(φ; R) with φ ∈ U. Put u_v := Q c_v and relabel by λ. Then u_3 is the F5-disk-3 centre, and |u_{v,ι} − c̄_{v,ι}| < δ for all v and ι.

**Rotation.** Since x̄_3 = 0 and ȳ_3 = 2.34884120…, we have |x(u_3)| < δ and y(u_3) > ȳ_3 − δ > 0. Let β := arctan(x(u_3)/y(u_3)) and z_v := R_β u_v. Then x(z_3) = 0 and y(z_3) > 0, and

  |β| ≤ |x(u_3)|/y(u_3) < δ/(ȳ_3 − δ) =: β_max.

**Error of each coordinate.** z_v − c̄_v = R_β(u_v − c̄_v) + (R_β − I)c̄_v, so:
- First term: each coordinate is at most (|cos β| + |sin β|)·δ ≤ (1 + β_max)δ.
- Second term: the x-coordinate is at most |sin β|·|ȳ_v| + (1 − cos β)|x̄_v|, and the y-coordinate is at most |sin β|·|x̄_v| + (1 − cos β)|ȳ_v|.
- From F5: max_{v≠3} |ȳ_v| = 2.01247018… (disks 10 and 11), max_v |x̄_v| = 1.82750955…, and every |c̄_v| ≤ 2.3489.

Hence, for every v ≠ 3 and both coordinates,

  |z_v − c̄_v|_∞ ≤ (1 + β_max)δ + β_max·2.0125 + β_max²·1.18.

For v = 3: x(z_3) = 0 = x̄_3, and |y(z_3) − ȳ_3| = | |u_3| − ȳ_3 | ≤ √2·δ is a crude bound. A sharper one: |u_3| ≤ √(δ² + (ȳ_3 + δ)²) ≤ ȳ_3 + δ + δ²/(2ȳ_3), and |u_3| ≥ y(u_3) > ȳ_3 − δ, so |y(z_3) − ȳ_3| ≤ δ + δ².

[Ed.: The original continued here with a linearised constant valid for δ ≤ 10⁻⁵ and a conclusion for δ = 9·10⁻⁷. Replaced by the conclusion at the value actually run:]

At δ = δ₁ = 3/1000: β_max = δ₁/(ȳ_3 − δ₁) = 1.27886·10⁻³, and the bound above is (1 + β_max)δ₁ + 2.0125β_max + 1.18β_max² = 5.57947·10⁻³ < 7·10⁻³ (evaluated in exact rationals). For v = 3 the bound δ + δ² is smaller. (The coefficient 1.18 bounds max(max|x̄_v|, max_{v≠3}|ȳ_v|)/2 = 1.00624, using 1 − cos β ≤ β²/2; 2.0125 bounds max_{v≠3}|ȳ_v| = 2.01247; the first term uses |cos β| + |sin β| ≤ 1 + |β|.)

**Radius.** 0 < R − R̄ = (R − R_*) + (R_* − R̄) ≤ 10⁻⁶ + 1.502·10⁻²¹.

**Conclusion.** The rotated, relabelled configuration has x(c_3) = 0 and ‖z − z̄‖_∞ ≤ 5.57947·10⁻³ < 7·10⁻³, i.e. z ∈ B(7·10⁻³), the hypothesis of Theorem MID(7/1000) (Appendix D). For m = 4 the same constants apply with Q′, λ′ (the reference values are the F5 decimals, and F5 disk 3 is D′_3).

# Appendix D. Theorem A′, Lemma Q, Theorem MID and the certificate program mid_cert.py

[Ed.: Written before the program was run; the run (Appendix G(a)) certified ρ_A = 7/1000. Corrections: the corner-root enclosure error is η_p = 10⁻³⁰·|d̄| (program constant SIGP = 30), not 10⁻⁴⁰/10⁻⁴⁵ as the original text said; the program uses this value consistently in A4–A6 and in radii(). The "orbit form" paragraph (via a gauge lemma not reproduced here) and §7 (predictions, written before the run) are omitted; neither is used. In Theorem A′(1), "the order persists" because polar angles move by < 0.006 while the reference steps are ≥ 0.606. Every formula used is derived in full in this appendix.]

## 0. Plan (written first; status updated at the end)

Route chosen: NOT the chart (Theorem B) and NOT a Finsler argument in the 22 original coordinates. Instead:
LIFT the problem by adding the 18 corner points used by the active functions as extra unknowns. In the lifted
space (58 unknowns) every constraint is a QUADRATIC polynomial (|p−a|² = 1, |p−b|² = 1 for each corner, and
|P|² − R² ≥ 0, 1 − |Q − c_X|² ≥ 0, 1 − |t − c_k|² ≥ 0). Hence all Taylor expansions are EXACT at second order,
there are no third derivatives at all, Hessians are constant integer matrices, and the "quartic cross term"
becomes an explicit diagonal quadratic form whose size is controlled by the a-priori displacement radii.
The exclusion is then one inequality R − R̄ ≤ ε₁ + r̂·h − ½ hᵀ G h with an explicit constant symmetric matrix G
(depending on ρ through explicit radii), and one positive-definiteness check of G at the single rational point.

Statement attempted: Theorem MID(ρ_A) with ρ_A as large as the program certifies (grid up to 7·10⁻³);
predicted ρ_A ≈ 2·10⁻³ – 3·10⁻³ (see §6).

## 1. Setting

z = (c_1, …, c_11, R) ∈ ℝ²³ in the F5 labelling, 𝒱 = {x(c_3) = 0}, z̄ = F5 decimals (z̄ ∈ 𝒱), B(ρ) = {z ∈ 𝒱 : ‖z − z̄‖_∞ ≤ ρ}.
R_* > R̄: the lower end of I_* is 2.63169077261980820552150…, and R̄ = 2.63169077261980820552, so R_* − R̄ > 10⁻²² (the program re-checks this in exact arithmetic). Hence every covering with R ≥ R_* has R − R̄ > 0.

Boundary pairs (counter-clockwise), j = 1, …, 9:
(C_j, C_{j+1}) = (8,4), (4,3), (3,5), (5,9), (9,7), (7,11), (11,10), (10,6), (6,8).
Tight inner corners: j = 1, 2, 3, 4 with X = 2 and j = 5, 7, 9 with X = 1 (j = 6, 8 are inactive).

Corner formulas (re-derived here in full): for a ≠ b with 0 < |b − a| < 2, d = b − a, m = (a+b)/2,
σ(d) = √(1/|d|² − 1/4), J(x,y) = (−y,x): P(a,b) = m − σJd, Q(a,b) = m + σJd. Both satisfy |p − a| = |p − b| = 1.
For b counter-clockwise after a (on a circle around 0), Jd points towards 0, so P is the outer and Q the inner corner.
t_+ := P(c_1,c_2) (x > 0 because d = c_2 − c_1 points up), t_− := Q(c_1,c_2).

Derivative formula (re-verified). For p ∈ {P, Q}, u_a = p − a, u_b = p − b, ω = u_a × u_b: differentiating
|p − a|² = 1, |p − b|² = 1 gives u_a·dp = u_a·da, u_b·dp = u_b·db, hence dp = (u_a·da)e_a + (u_b·db)e_b with
{e_a, e_b} dual to {u_a, u_b}, |e_a| = |e_b| = 1/|ω|. So |dp| ≤ (|da| + |db|)/|ω|, and |ω| = φ(|d|),
φ(x) := x√(1 − x²/4). φ is concave on [0,2): φ''(x) = x(1 − x²/4)^{−3/2}(x²/8 − 3/4) < 0 for 0 < x < 2.
Hence on any interval [x_lo, x_hi] ⊂ (0,2), min φ = min(φ(x_lo), φ(x_hi)).

Lipschitz bound (Lemma C). If along the segment from z̄ to z the pair distance |d| stays in [x_lo, x_hi] ⊂ (0,2)
and ω_0 := min(φ(x_lo), φ(x_hi)), then |p(z) − p(z̄)| ≤ (|a − ā| + |b − b̄|)/ω_0. (Integrate |dp| along the segment.)

## 2. Theorem A′ (necessity), re-proved with program-checked margins

**Theorem A′.** Let 0 < ρ ≤ 7·10⁻³. Every covering of D_R by eleven unit disks with R ≥ R_*, exactly nine disks
meeting S_R, and z ∈ B(ρ), satisfies g_i(z) ≥ 0 for the 18 active functions
O_j = |P_j|² − R² (j = 1..9), I_j = 1 − |Q_j − c_X|² (7 tight j), T_+ = 1 − |t_+ − c_8|², T_− = 1 − |t_− − c_9|².

Reference checks (all verified by the program, section 5, in exact rational arithmetic at z̄; corners at z̄ are
enclosed with rational error ≤ η_p = 10⁻³⁰·|d̄| (Euclidean), see §3 [Ed.: corrected from 10⁻⁴⁰]):
- (A1) |c̄_1| ≤ 0.40, |c̄_2| ≤ 0.72; 1.84 ≤ |c̄_k| ≤ 2.35 for k = 3..11.
- (A2) For each j: C̄_j × C̄_{j+1} ≥ 0.57|C̄_j||C̄_{j+1}| and C̄_j·C̄_{j+1} ≥ 0.18|C̄_j||C̄_{j+1}|.
- (A3) For the ten pairs (the nine boundary pairs and (c_1,c_2)): with δ_0 := 0.0099, x_∓ := |d̄| ∓ 2δ_0 satisfy
  0 < x_− , x_+ < 2 and φ(x_∓) ≥ 0.80.
- (A4) |Q̄_j| ≤ 1.70 for all nine j (including the inactive j = 6, 8).
- (A5) For the seven tight j: |Q̄_j − c̄_Y| ≥ 1.2 for the other inner centre Y and for every boundary centre other than C̄_j, C̄_{j+1}.
- (A6) |t̄_±| ≤ 0.9; |t̄_+ − c̄_k| ≥ 1.2 for every boundary k ≠ 8; |t̄_− − c̄_k| ≥ 1.2 for every boundary k ≠ 9.
- (A7) With F(c) := c + c/|c|: |F(C̄_j) − C̄_{j+1}| ≥ 1.2 and |F(C̄_{j+1}) − C̄_j| ≥ 1.2 for all j.

*Proof.* δ := √2ρ ≤ 0.009900 ≤ δ_0 bounds the Euclidean displacement of every centre; |R − R̄| ≤ ρ.
(0) |c_1| + 1 ≤ 1.41, |c_2| + 1 ≤ 1.73 < R (A1), so disks 1, 2 miss S_R; the boundary disks are 3–11.
(1) Order. By (A2) every reference step between consecutive polar angles lies in [arcsin 0.57, arccos 0.18] ⊂ [0.606, 1.391]
(sin 0.606 < 0.57, cos 1.391 < 0.18; the smallest true step is ≈ 0.6217, at (9,7) and (6,8)); nine such steps sum to a positive multiple of 2π that is ≤ 12.52 < 4π, so to 2π:
(8,4,3,5,9,7,11,10,6) is the counter-clockwise order of the reference polar angles. Each polar angle moves by at most
arcsin(δ/1.83) < 0.006 (A1), so the order persists. By F3 (R ≥ R_*) the arcs A_k are
cyclically ordered with starts and ends in the same order, no arc contains another, each has length < π; the arc
A_k is symmetric about the polar angle of c_k, so the F3 order is the order of midpoints = polar angles, and F3 gives
A_{C_j} ∩ A_{C_{j+1}} ≠ ∅ for all j.
(2) Corners. Pair distances move by ≤ 2δ, so along the segment |d| ∈ [x_−, x_+] and |ω| ≥ 0.80 (A3, concavity of φ).
By Lemma C every corner moves by ≤ 2δ/0.80 = 2.5δ ≤ 0.0248. With (A4), |Q_j| ≤ 1.725 < R for all nine j.
(3) O_j ≥ 0. Take s ∈ S_R ∩ D(C_j) ∩ D(C_{j+1}) (by (1)). On the lens L = D(C_j) ∩ D(C_{j+1}) the convex function |x|²
is maximised on ∂L, the union of the arc of ∂D(C_j) inside D(C_{j+1}) and the arc of ∂D(C_{j+1}) inside D(C_j), both with
endpoints P_j, Q_j. On a unit circle about c, |x|² is unimodal with maximum at F(c); F moves by ≤ δ(1 + 1/1.83) < 1.55δ,
so by (A7) |F(C_j) − C_{j+1}| ≥ 1.2 − 2.55δ > 1, i.e. F(C_j) ∉ D(C_{j+1}), and symmetrically. So on each arc the maximum
of |x|² is at an endpoint and R = |s| ≤ max(|P_j|, |Q_j|). Since |Q_j| < R, O_j ≥ 0.
(4) I_j ≥ 0 (tight j). With q = Q_j, u = (q − C_j) + (q − C_{j+1}) ≠ 0 (|d| < 2) and (q − C_j)·u > 0, (q − C_{j+1})·u > 0,
the points q + εu (small ε > 0) lie outside D(C_j) ∪ D(C_{j+1}), inside D_R (by (2)), and (by (A5), displacements
≤ 2.5δ + δ < 0.035) outside every other boundary disk. So they lie in D(c_1) ∪ D(c_2); letting ε → 0, q ∈ D(c_1) ∪ D(c_2);
by (A5) q ∉ D(c_Y) for the non-assigned Y, so q ∈ D(c_X).
(5) T_± ≥ 0. Same argument at t_+ ∈ ∂D(c_1) ∩ ∂D(c_2): points t_+ + εu lie outside D(c_1) ∪ D(c_2), inside D_R
(|t_+| ≤ 0.93 by (A6),(2)), hence in a boundary disk; by (A6) only D(c_8) is possible (distance ≥ 1.2 − 0.035 > 1 to the
others); closedness gives t_+ ∈ D(c_8). Mirror for t_−, c_9. ∎

## 3. The lifted quadratic problem

Unknowns (58): the 21 free centre coordinates (x(c_3) ≡ 0 is dropped), R, and 18 corner points (36 coordinates):
P_1..P_9, Q_j for the 7 tight j, t_+, t_−. For a covering z ∈ B(ρ) its lift is x(z) := (z, P_j(z), Q_j(z), t_±(z))
(formula corners, well defined by §2 (2)).

Constraints (54), all quadratic polynomials in x:
- 36 equalities E: for each corner p of the pair (a,b): |p − a|² − 1 = 0, |p − b|² − 1 = 0;
- 18 inequalities g: O_j = |P_j|² − R², I_j = 1 − |Q_j − c_X|², T_+ = 1 − |t_+ − c_8|², T_− = 1 − |t_− − c_9|².
For every covering in B(ρ) with R ≥ R_* (ρ ≤ 7·10⁻³): E(x(z)) = 0 by construction and g(x(z)) ≥ 0 by Theorem A′.

Exact expansion. For each constraint c_k and every h: c_k(x̄ + h) = c_k(x̄) + J_k h + q_k(h), where J_k = ∇c_k(x̄) and
q_k(h) = ½hᵀH_k h is: σ|h_X − h_Y|² for c_k = σ(|X − Y|² − 1) or σ = −1 forms (σ = ±1), and |h_P|² − h_R² for O_j.
(Exact, because c_k is a polynomial of degree 2.)

Base point x̄ = (z̄, p̄): p̄ := m̄ ∓ σ_lo J d̄ with σ_lo ∈ ℚ, σ_lo ≤ σ(d̄) ≤ σ_lo + 10⁻³⁰ (checked by squaring). Then
|p(z̄) − p̄| ≤ η_p := 10⁻³⁰|d̄| (Euclidean). [Ed.: corrected from 10⁻⁴⁵; the program takes η = 10⁻³⁰·sqrt_hi(|d̄|²) ≥ 10⁻³⁰|d̄|.]

Radii (Euclidean upper bounds for the displacement h_X of each "point" X, valid for every covering in B(ρ)):
- centre c_k, k ≠ 3: r = √2 ρ (√2 replaced by the rational 1.41421357 ≥ √2); c_3: r = ρ; R: |h_R| ≤ ρ;
- corner p of pair (a,b): r_p := (r_a + r_b)/ω_0(p) + η_p, where ω_0(p) is a rational lower bound of
  min(φ(|d̄| − (r_a + r_b)), φ(|d̄| + (r_a + r_b))) (Lemma C; the program checks 0 < |d̄| ± (r_a+r_b) < 2).

Slack bounds. For every covering in B(ρ): 0 ≤ g_i(x) ≤ S_i, where
- S_i := g_i(x̄) + 2|P̄_j| r_P + 2R̄ρ + r_P²  for O_j  (J h = 2P̄·h_P − 2R̄h_R, q = |h_P|² − h_R² ≤ r_P²);
- S_i := g_i(x̄) + 2|X̄ − Ȳ|(r_X + r_Y)  for I_j, T_±  (q ≤ 0);
with |·| replaced by rational upper bounds (checked by squaring).

Quadratic remainders. |q_k(h)| ≤ Q_k and q_k(h)² ≤ Q_k w_k(h), where
- for the |X − Y|² forms: Q_k := (r_X + r_Y)², w_k(h) := 2|h_X|² + 2|h_Y|²  (|q| ≤ |h_X − h_Y|² ≤ w_k);
- for O_j: Q_k := max(r_P², ρ²), w_k(h) := |h_P|² + h_R²  (|q| ≤ max(|h_P|², h_R²) ≤ w_k).
Both w_k are diagonal quadratic forms; write w_k(h) = Σ_j m_{kj} h_j².

Parameters. θ ∈ (0,1); weights μ_k > 0 for the equalities (free); μ_i := (rational ≤) λ̂_i/S_i for the inequalities.
Multipliers λ̂ ∈ ℚ¹⁸ with all λ̂_i > 0, ν̂ ∈ ℚ³⁶ (any sign). Define
- r̂ := e_R + Σ_i λ̂_i J_i + Σ_k ν̂_k J_k  (exact rational residual of the KKT equation at x̄; NOT assumed zero),
- H := Σ_i λ̂_i H_i + Σ_k ν̂_k H_k  (constant, exact),
- ε_L := Σ_i λ̂_i g_i(x̄) + Σ_k ν̂_k E_k(x̄),  ε₁ := ε_L + 2(1/θ − 1) Σ_{all k} μ_k c_k(x̄)²,
- D := diag, D_jj := 2(1/θ − 1) Σ_{all k} μ_k Q_k m_{kj},
- G := −H + 2(1 − θ) Σ_{all k} μ_k J_kᵀJ_k − 2D  (58×58, symmetric, explicit).

**Lemma Q (main inequality).** Let ρ ≤ 7·10⁻³ and let z ∈ B(ρ) be a covering with R ≥ R_* and exactly nine disks
meeting S_R; put h := x(z) − x̄. Then  0 < R − R̄ ≤ ε₁ + r̂·h − ½ hᵀGh.

*Proof.* Let L(x) := R + Σλ̂_i g_i(x) + Σν̂_k E_k(x), a quadratic polynomial. Exactly, L(x̄ + h) = L(x̄) + ∇L(x̄)·h + ½hᵀHh
with L(x̄) = R̄ + ε_L and ∇L(x̄) = r̂. At x = x(z), E_k(x) = 0 and s_i := g_i(x) ∈ [0, S_i] (Theorem A′ and the slack bounds),
so R = L(x) − Σλ̂_i s_i. Since 0 ≤ s_i ≤ S_i and μ_i ≤ λ̂_i/S_i, λ̂_i s_i ≥ μ_i s_i²; and μ_k E_k(x)² = 0. Hence
  R − R̄ ≤ ε_L + r̂·h + ½hᵀHh − Σ_{all k} μ_k c_k(x)²,  c_k(x) = a_k + b_k, a_k := J_k h, b_k := c_k(x̄) + q_k(h).
For θ ∈ (0,1), (a+b)² ≥ (1 − θ)a² − (1/θ − 1)b² (as 2ab ≥ −θa² − b²/θ), and b² ≤ 2c_k(x̄)² + 2q_k² ≤ 2c_k(x̄)² + 2Q_k w_k(h). So
  −Σμ_k c_k² ≤ −(1 − θ)Σμ_k (J_k h)² + 2(1/θ − 1)Σμ_k c_k(x̄)² + hᵀDh.
Adding up: R − R̄ ≤ ε₁ + r̂·h − ½hᵀGh. The left inequality is R ≥ R_* > R̄. ∎

**Theorem MID(ρ_A).** Suppose, for some ρ_A ≤ 7·10⁻³ and the rational data above, (i) all λ̂_i > 0, (ii) G ⪰ κI with
a rational κ > 0, (iii) τ := (|r̂|₂ + √(|r̂|₂² + 2κ max(ε₁,0)))/κ ≤ 2·10⁻⁶. Then every covering of D_R by eleven unit disks
with R ≥ R_*, exactly nine disks meeting S_R, and z ∈ B(ρ_A) satisfies ‖z − z̄‖_∞ ≤ |h|₂ < τ ≤ 2·10⁻⁶; hence by F6′ R ≤ R_*,
so R = R_*, and by F6′'s quadratic bound z = z_*.

*Proof.* Lemma Q and (ii): 0 < ε₁ + |r̂|₂|h|₂ − ½κ|h|₂². The quadratic t ↦ ε₁⁺ + |r̂|t − ½κt² is positive only for t < τ,
so |h|₂ < τ. The z-coordinates are among the coordinates of h, so ‖z − z̄‖_∞ ≤ |h|₂. Since z ∈ 𝒱, F6′ applies:
R_* ≤ R ≤ R_* − (7/1000)‖z − z_*‖². ∎


Remarks.
- No chart, no kernel basis, no inverse function theorem, no third derivatives: the lifted constraints are quadratic.
- How the scale gap is bridged: the only ρ-dependence is in S_i (μ_i = λ̂_i/S_i ∝ 1/ρ: the quadratic penalty on
  the slacks gets weaker) and in D (∝ ρ²: the explicit "quartic cross term"). So the certificate fails only when
  λ_min(−H + 2(1−θ)JᵀMJ) ≲ 2‖D‖ or when the weakened penalty no longer kills the two positive directions of H.
- The pessimistic earlier estimate came from cubic remainders of the non-polynomial g_i with 1/ω and 1/λ_min
  amplification. Here the remainders are exactly ½hᵀH_k h with ‖H_k‖ ≤ 4.

## 5. The certificate program (Python 3, standard library only)

What it does: (a) exact checks (A0)–(A7) of Theorem A′; (b) builds the lifted problem at the rational point x̄;
(c) computes multipliers by floating least squares, then makes them exact rationals and computes the exact residual r̂
and ε_L; (d) scans (ρ, θ, μ_eq) in floating point to find the largest ρ for which G looks positive definite;
(e) certifies the chosen ρ_A EXACTLY: G is built in exact rationals, κ′ = 0.9·(float λ_min), a float Cholesky factor L̃
of G − κ′I is computed, E := G − κ′I − L̃L̃ᵀ is computed exactly, and ‖E‖_F ≤ κ′/2 is checked exactly; this gives
G ⪰ (κ′/2)I =: κI (Weyl). (f) checks τ ≤ 2·10⁻⁶ exactly. Square roots: sqrt_lo/sqrt_hi return rationals a, b with
a² ≤ x ≤ b² (asserted by squaring), used only in the direction that is safe for each inequality.
Floating point is used ONLY to choose data (multipliers, parameters, the factor L̃); every inequality of the proof is
checked in exact rational arithmetic.

```python
#!/usr/bin/env python3
"""Certificate for Theorem MID(rho_A) (Appendix D).  Python 3 stdlib only.
All inequalities of the proof are checked in exact rational arithmetic (fractions.Fraction).
Floats are used only to *choose* data (multipliers, parameters, an approximate Cholesky factor)."""
import math, sys, time
from fractions import Fraction as Fr

T0 = time.time()
FAILS = []

def report(name, ok, margin=None):
    tag = 'PASS' if ok else 'FAIL'
    extra = '' if margin is None else '  margin=%.6g' % float(margin)
    print('[%s] %s%s' % (tag, name, extra))
    sys.stdout.flush()
    if not ok:
        FAILS.append(name)
    return ok

# ---------------- rigorous rational square roots ----------------
def _isqrt_scaled(x, prec):
    v = x * (10 ** (2 * prec))
    return math.isqrt(v.numerator // v.denominator)

def sqrt_lo(x, prec=40):
    """rational a with a*a <= x (x >= 0)"""
    x = Fr(x)
    if x < 0:
        raise ArithmeticError('sqrt_lo of negative')
    if x == 0:
        return Fr(0)
    a = Fr(_isqrt_scaled(x, prec), 10 ** prec)
    if not a * a <= x:
        raise ArithmeticError('sqrt_lo check')
    return a

def sqrt_hi(x, prec=40):
    """rational b with b*b >= x (x >= 0)"""
    x = Fr(x)
    if x < 0:
        raise ArithmeticError('sqrt_hi of negative')
    if x == 0:
        return Fr(0)
    b = Fr(_isqrt_scaled(x, prec) + 1, 10 ** prec)
    if not b * b >= x:
        raise ArithmeticError('sqrt_hi check')
    return b

def rnd_up(x, n):
    N = 10 ** n
    v = Fr(x) * N
    return Fr(-((-v.numerator) // v.denominator), N)

def rnd_dn(x, n):
    N = 10 ** n
    v = Fr(x) * N
    return Fr(v.numerator // v.denominator, N)

# ---------------- plane vectors ----------------
def vsub(a, b): return (a[0] - b[0], a[1] - b[1])
def vscale(t, a): return (t * a[0], t * a[1])
def dot(a, b): return a[0] * b[0] + a[1] * b[1]
def cross(a, b): return a[0] * b[1] - a[1] * b[0]
def n2(a): return a[0] * a[0] + a[1] * a[1]
ORIGIN = (Fr(0), Fr(0))

# ---------------- F5 data ----------------
c = {}
c[1] = (Fr(0), Fr('-0.39324960179250027086'))
c[2] = (Fr(0), Fr('0.71839227931685877597'))
c[3] = (Fr(0), Fr('2.34884120097565953729'))
_c4 = (Fr('1.57535264004342806580'), Fr('1.62062588642691912838'))
_c6 = (Fr('1.77273616280974093118'), Fr('-0.93632239910290244643'))
_c8 = (Fr('1.82750955295212993964'), Fr('0.24958048504283922431'))
_c10 = (Fr('0.78521708246826346764'), Fr('-2.01247018720615423819'))
c[4] = _c4;  c[5] = (-_c4[0], _c4[1])
c[6] = _c6;  c[7] = (-_c6[0], _c6[1])
c[8] = _c8;  c[9] = (-_c8[0], _c8[1])
c[10] = _c10; c[11] = (-_c10[0], _c10[1])
RBAR = Fr('2.63169077261980820552')
ISTAR_LO = Fr('2.6316907726198082055215011595056961051671168478238')

B = [8, 4, 3, 5, 9, 7, 11, 10, 6]                     # ccw boundary order
PAIRS = [(B[j], B[(j + 1) % 9]) for j in range(9)]   # boundary pairs j = 0..8
TIGHT = {0: 2, 1: 2, 2: 2, 3: 2, 4: 1, 6: 1, 8: 1}   # tight inner corner j -> inner disk X

SIGP = 30   # precision of the corner square roots
def corner(a, b, kind):
    """rational approximation pbar of P(a,b) (kind 'P') or Q(a,b) (kind 'Q') and a Euclidean error bound"""
    d = vsub(b, a)
    m = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2)
    dd = n2(d)
    s2 = 1 / dd - Fr(1, 4)
    if not s2 > 0:
        raise ArithmeticError('corner: |d| >= 2')
    slo = sqrt_lo(s2, SIGP)            # slo <= sigma <= slo + 10^-SIGP
    Jd = (-d[1], d[0])
    sg = -1 if kind == 'P' else 1
    p = (m[0] + sg * slo * Jd[0], m[1] + sg * slo * Jd[1])
    eta = Fr(1, 10 ** SIGP) * sqrt_hi(dd, 10)
    return p, eta

def dist_lo(p, q, eta=Fr(0)):
    return sqrt_lo(n2(vsub(p, q)), 20) - eta

def dist_hi(p, q, eta=Fr(0)):
    return sqrt_hi(n2(vsub(p, q)), 20) + eta

def phi2(x):     # phi(x)^2 = x^2 (1 - x^2/4)
    return x * x * (1 - x * x / 4)

print('==== Part A: R_* > Rbar and the reference margins of Theorem A\' (rho <= 7e-3) ====')
report('A0  Rbar < lower end of I_*', RBAR < ISTAR_LO, ISTAR_LO - RBAR)
report('A1a |c1| <= 0.40', n2(c[1]) <= Fr('0.40') ** 2, Fr('0.40') - sqrt_hi(n2(c[1])))
report('A1b |c2| <= 0.72', n2(c[2]) <= Fr('0.72') ** 2, Fr('0.72') - sqrt_hi(n2(c[2])))
for k in range(3, 12):
    ok = Fr('1.84') ** 2 <= n2(c[k]) <= Fr('2.35') ** 2
    report('A1c 1.84 <= |c%d| <= 2.35' % k, ok,
           min(sqrt_lo(n2(c[k])) - Fr('1.84'), Fr('2.35') - sqrt_hi(n2(c[k]))))
for (ka, kb) in PAIRS:
    a, b = c[ka], c[kb]
    cr, dt, nn = cross(a, b), dot(a, b), n2(a) * n2(b)
    ok = cr > 0 and cr * cr >= Fr('0.57') ** 2 * nn and dt > 0 and dt * dt >= Fr('0.18') ** 2 * nn
    report('A2  angle step (%d,%d): sin >= 0.57, cos >= 0.18' % (ka, kb), ok,
           min(float(cr) / math.sqrt(float(nn)) - 0.57, float(dt) / math.sqrt(float(nn)) - 0.18))
D0 = Fr('0.0099')
assert Fr('1.41421357') ** 2 >= 2 and Fr('1.41421357') * Fr('0.007') <= D0
for (ka, kb) in PAIRS + [(1, 2)]:
    dd = n2(vsub(c[kb], c[ka]))
    xl = sqrt_lo(dd, 20) - 2 * D0
    xh = sqrt_hi(dd, 20) + 2 * D0
    ok = xl > 0 and xh < 2 and phi2(xl) >= Fr('0.64') and phi2(xh) >= Fr('0.64')
    report('A3  pair (%d,%d): |omega| >= 0.80 on |d| in [%.4f, %.4f]' % (ka, kb, float(xl), float(xh)), ok,
           math.sqrt(float(min(phi2(xl), phi2(xh)))) - 0.80)

PB, QB, ETA_B = {}, {}, {}
for j, (ka, kb) in enumerate(PAIRS):
    PB[j], e1 = corner(c[ka], c[kb], 'P')
    QB[j], e2 = corner(c[ka], c[kb], 'Q')
    ETA_B[j] = max(e1, e2)
TP, eta_tp = corner(c[1], c[2], 'P')
TM, eta_tm = corner(c[1], c[2], 'Q')
for j in range(9):
    v = dist_hi(QB[j], ORIGIN, ETA_B[j])
    report('A4  |Q_%d| <= 1.70 (pair %s)' % (j, PAIRS[j]), v <= Fr('1.70'), Fr('1.70') - v)
for j, X in sorted(TIGHT.items()):
    Y = 3 - X
    others = [k for k in B if k not in PAIRS[j]] + [Y]
    v = min(dist_lo(QB[j], c[k], ETA_B[j]) for k in others)
    report('A5  tight corner Q_%d (pair %s, X=%d): distance >= 1.2 to disks %s' % (j, PAIRS[j], X, others),
           v >= Fr('1.2'), v - Fr('1.2'))
    print('      info: |Q_%d - c_%d| = %.15f (should be 1), |P_%d| = %.15f (should be Rbar)'
          % (j, X, math.sqrt(float(n2(vsub(QB[j], c[X])))), j, math.sqrt(float(n2(PB[j])))))
for (T, eta, own, nm) in [(TP, eta_tp, 8, 't+'), (TM, eta_tm, 9, 't-')]:
    v = dist_hi(T, ORIGIN, eta)
    report('A6a |%s| <= 0.9' % nm, v <= Fr('0.9'), Fr('0.9') - v)
    v = min(dist_lo(T, c[k], eta) for k in B if k != own)
    report('A6b %s at distance >= 1.2 from boundary centres other than c_%d' % (nm, own), v >= Fr('1.2'), v - Fr('1.2'))
    print('      info: |%s - c_%d| = %.15f (should be 1)' % (nm, own, math.sqrt(float(n2(vsub(T, c[own]))))))

def farpoint(cv):
    nl = sqrt_lo(n2(cv), 30)                 # |F~ - F| = (|c| - nl)/nl <= 1e-30/1.8
    return vscale(1 + 1 / nl, cv), Fr(1, 10 ** 29)
for (ka, kb) in PAIRS:
    Fa, ea = farpoint(c[ka])
    Fb, eb = farpoint(c[kb])
    v = min(dist_lo(Fa, c[kb], ea), dist_lo(Fb, c[ka], eb))
    report('A7  far points, pair (%d,%d): distance >= 1.2' % (ka, kb), v >= Fr('1.2'), v - Fr('1.2'))

# ---------------- Part B: the lifted quadratic problem ----------------
print('==== Part B: lifted problem at the rational base point ====')
var_names = []
def newvar(nm):
    var_names.append(nm)
    return len(var_names) - 1
PT, PV, PETA = {}, {}, {}
for k in range(1, 12):
    ix = None if k == 3 else newvar('x%d' % k)
    iy = newvar('y%d' % k)
    PT['c%d' % k] = (ix, iy); PV['c%d' % k] = c[k]; PETA['c%d' % k] = Fr(0)
IR = newvar('R')
CORNERS = {}
for j, (ka, kb) in enumerate(PAIRS):
    CORNERS['P%d' % j] = ('c%d' % ka, 'c%d' % kb, 'P')
for j in sorted(TIGHT):
    ka, kb = PAIRS[j]
    CORNERS['Q%d' % j] = ('c%d' % ka, 'c%d' % kb, 'Q')
CORNERS['tp'] = ('c1', 'c2', 'P')
CORNERS['tm'] = ('c1', 'c2', 'Q')
for nm, (an, bn, kind) in CORNERS.items():
    p, eta = corner(PV[an], PV[bn], kind)
    PT[nm] = (newvar(nm + '.x'), newvar(nm + '.y')); PV[nm] = p; PETA[nm] = eta
NV = len(var_names)
report('B0  58 unknowns', NV == 58)

CONS = []
for nm, (an, bn, kind) in CORNERS.items():
    CONS.append(dict(kind='dist', X=nm, Y=an, sigma=1, eq=True, label='E |%s-%s|^2=1' % (nm, an)))
    CONS.append(dict(kind='dist', X=nm, Y=bn, sigma=1, eq=True, label='E |%s-%s|^2=1' % (nm, bn)))
for j in range(9):
    CONS.append(dict(kind='outer', P='P%d' % j, eq=False, label='O%d %s' % (j + 1, PAIRS[j])))
for j in sorted(TIGHT):
    CONS.append(dict(kind='dist', X='Q%d' % j, Y='c%d' % TIGHT[j], sigma=-1, eq=False,
                     label='I %s X=%d' % (PAIRS[j], TIGHT[j])))
CONS.append(dict(kind='dist', X='tp', Y='c8', sigma=-1, eq=False, label='T+'))
CONS.append(dict(kind='dist', X='tm', Y='c9', sigma=-1, eq=False, label='T-'))
NC = len(CONS)
report('B1  54 constraints (36 equalities, 18 inequalities)',
       NC == 54 and sum(1 for C in CONS if C['eq']) == 36)

def cval(C):
    if C['kind'] == 'dist':
        return C['sigma'] * (n2(vsub(PV[C['X']], PV[C['Y']])) - 1)
    return n2(PV[C['P']]) - RBAR ** 2

def cgrad(C):
    g = {}
    def add(i, v):
        if i is not None:
            g[i] = g.get(i, Fr(0)) + v
    if C['kind'] == 'dist':
        s = C['sigma']; diff = vsub(PV[C['X']], PV[C['Y']])
        for t in (0, 1):
            add(PT[C['X']][t], 2 * s * diff[t]); add(PT[C['Y']][t], -2 * s * diff[t])
    else:
        P = PV[C['P']]
        for t in (0, 1):
            add(PT[C['P']][t], 2 * P[t])
        add(IR, -2 * RBAR)
    return g

def chess(C):
    Hk = {}
    def add(i, j, v):
        if i is not None and j is not None:
            Hk[(i, j)] = Hk.get((i, j), Fr(0)) + v
    if C['kind'] == 'dist':
        s = C['sigma']
        for t in (0, 1):
            xi, yi = PT[C['X']][t], PT[C['Y']][t]
            add(xi, xi, 2 * s); add(yi, yi, 2 * s); add(xi, yi, -2 * s); add(yi, xi, -2 * s)
    else:
        for t in (0, 1):
            pi = PT[C['P']][t]; add(pi, pi, Fr(2))
        add(IR, IR, Fr(-2))
    return Hk

def cweights(C):   # diagonal weights m_kj of w_k(h)
    w = {}
    if C['kind'] == 'dist':
        for nm in (C['X'], C['Y']):
            for i in PT[nm]:
                if i is not None:
                    w[i] = w.get(i, 0) + 2
    else:
        for i in PT[C['P']]:
            w[i] = w.get(i, 0) + 1
        w[IR] = w.get(IR, 0) + 1
    return w

CV = [cval(C) for C in CONS]
JG = [cgrad(C) for C in CONS]
HS = [chess(C) for C in CONS]
CW = [cweights(C) for C in CONS]
print('      max |c_k(xbar)| equalities   = %.3e' % max(abs(float(CV[k])) for k in range(NC) if CONS[k]['eq']))
print('      max |g_i(xbar)| inequalities = %.3e' % max(abs(float(CV[k])) for k in range(NC) if not CONS[k]['eq']))

# ---------------- floating linear algebra (data selection only) ----------------
def fsolve(A, b):
    n = len(A)
    M = [list(A[i]) + [b[i]] for i in range(n)]
    for col in range(n):
        piv = max(range(col, n), key=lambda r: abs(M[r][col]))
        M[col], M[piv] = M[piv], M[col]
        pv = M[col][col]
        if pv == 0.0:
            raise ArithmeticError('singular')
        Mc = M[col]
        for r in range(col + 1, n):
            f = M[r][col] / pv
            if f != 0.0:
                Mr = M[r]
                for cc in range(col, n + 1):
                    Mr[cc] -= f * Mc[cc]
    x = [0.0] * n
    for i in range(n - 1, -1, -1):
        s = M[i][n] - sum(M[i][j] * x[j] for j in range(i + 1, n))
        x[i] = s / M[i][i]
    return x

def fchol(A):
    n = len(A)
    L = [[0.0] * n for _ in range(n)]
    for j in range(n):
        Lj = L[j]
        s = A[j][j] - sum(Lj[k] * Lj[k] for k in range(j))
        if not s > 0.0:
            return None
        d = math.sqrt(s)
        Lj[j] = d
        for i in range(j + 1, n):
            Li = L[i]
            Li[j] = (A[i][j] - sum(Li[k] * Lj[k] for k in range(j))) / d
    return L

def flammin(A):
    n = len(A)
    lo = min(A[i][i] - sum(abs(A[i][j]) for j in range(n) if j != i) for i in range(n)) - 1e-6
    hi = min(A[i][i] for i in range(n)) + 1e-12
    for _ in range(45):
        mid = 0.5 * (lo + hi)
        if fchol([[A[i][j] - (mid if i == j else 0.0) for j in range(n)] for i in range(n)]) is None:
            hi = mid
        else:
            lo = mid
    return lo

# ---------------- multipliers ----------------
Jf = [{i: float(v) for i, v in JG[k].items()} for k in range(NC)]
AJJ = [[sum(v * Jf[l].get(i, 0.0) for i, v in Jf[k].items()) for l in range(NC)] for k in range(NC)]

def exact_resid(yfr):
    r = [Fr(0)] * NV
    r[IR] += 1
    for k in range(NC):
        for i, v in JG[k].items():
            r[i] += yfr[k] * v
    return r

y = fsolve(AJJ, [-Jf[k].get(IR, 0.0) for k in range(NC)])
for _ in range(2):                       # iterative refinement with exact residuals
    rr = [float(v) for v in exact_resid([Fr(t) for t in y])]
    dy = fsolve(AJJ, [-sum(v * rr[i] for i, v in Jf[k].items()) for k in range(NC)])
    y = [y[k] + dy[k] for k in range(NC)]
YF = [Fr(t) for t in y]                  # exact rationals (the binary values of the floats)
RHAT = exact_resid(YF)
EPSL = sum(YF[k] * CV[k] for k in range(NC))
INEQ = [k for k in range(NC) if not CONS[k]['eq']]
print('      multipliers of the 18 inequalities (compare with the orchestrator float data):')
for k in INEQ:
    print('        %-18s lambda = %.6f' % (CONS[k]['label'], float(YF[k])))
print('      sum of outer multipliers = %.7f, 1/(2 Rbar) = %.7f'
      % (sum(float(YF[k]) for k in INEQ if CONS[k]['kind'] == 'outer'), 0.5 / float(RBAR)))
lam_min = min(YF[k] for k in INEQ)
report('B2  all 18 inequality multipliers > 0', lam_min > 0, lam_min)
print('      exact KKT residual: max|rhat_j| = %.3e, eps_L = %.3e' % (max(abs(float(v)) for v in RHAT), float(EPSL)))

H = [[Fr(0)] * NV for _ in range(NV)]
for k in range(NC):
    for (i, j), v in HS[k].items():
        H[i][j] += YF[k] * v

# ---------------- radii, slack bounds, G(rho, theta, mu_eq) ----------------
SQ2 = Fr('1.41421357')
assert SQ2 * SQ2 >= 2

def radii(rho):
    r = {}
    for k in range(1, 12):
        r['c%d' % k] = rho if k == 3 else SQ2 * rho
    for nm, (an, bn, kind) in CORNERS.items():
        ra = r[an] + r[bn]
        dd = n2(vsub(PV[bn], PV[an]))
        xl = sqrt_lo(dd, 20) - ra
        xh = sqrt_hi(dd, 20) + ra
        if not (xl > 0 and xh < 2):
            return None
        w0 = sqrt_lo(min(phi2(xl), phi2(xh)), 20)     # lower bound of |omega| along the segment
        r[nm] = rnd_up(ra / w0 + PETA[nm], 20)
    return r

def build(rho, theta, mueq):
    r = radii(rho)
    if r is None:
        return None
    mu, Qk = [None] * NC, [None] * NC
    for k, C in enumerate(CONS):
        if C['kind'] == 'dist':
            Qk[k] = (r[C['X']] + r[C['Y']]) ** 2
        else:
            Qk[k] = max(r[C['P']] ** 2, rho ** 2)
        if C['eq']:
            mu[k] = mueq
        else:
            if C['kind'] == 'outer':
                Pn = sqrt_hi(n2(PV[C['P']]), 20)
                Si = CV[k] + 2 * Pn * r[C['P']] + 2 * RBAR * rho + r[C['P']] ** 2
            else:
                dn = sqrt_hi(n2(vsub(PV[C['X']], PV[C['Y']])), 20)
                Si = CV[k] + 2 * dn * (r[C['X']] + r[C['Y']])
            Si = rnd_up(Si, 15)
            if not (Si > 0 and YF[k] > 0):
                return None
            mu[k] = rnd_dn(YF[k] / Si, 12)
            if not mu[k] > 0:
                return None
    coefD = 2 * (1 / theta - 1)
    pen = 2 * (1 - theta)
    G = [[-H[i][j] for j in range(NV)] for i in range(NV)]
    for k in range(NC):
        items = list(JG[k].items())
        f = pen * mu[k]
        for (i, vi) in items:
            fvi = f * vi
            Gi = G[i]
            for (j, vj) in items:
                Gi[j] += fvi * vj
    for k in range(NC):
        for i, m in CW[k].items():
            G[i][i] -= 2 * coefD * mu[k] * Qk[k] * m
    eps1 = EPSL + coefD * sum(mu[k] * CV[k] ** 2 for k in range(NC))
    return G, eps1, mu

def tofloat(G):
    return [[float(v) for v in row] for row in G]

THETAS = [Fr('0.3'), Fr('0.5'), Fr('0.7')]
MUEQ = [Fr('0.1'), Fr('0.3'), Fr('1'), Fr('3'), Fr('10')]

def best_params(rho):
    best = (-1e9, None, None)
    for th in THETAS:
        for me in MUEQ:
            out = build(rho, th, me)
            if out is None:
                continue
            lm = flammin(tofloat(out[0]))
            if lm > best[0]:
                best = (lm, th, me)
    return best

print('==== Part C: floating scan (selection of rho_A; not part of the proof) ====')
GRID = [Fr(s) for s in ['0.0005', '0.001', '0.0015', '0.002', '0.0025', '0.003', '0.0035',
                        '0.004', '0.005', '0.006', '0.007']]
scan = []
for rho in GRID:
    lm, th, me = best_params(rho)
    scan.append((rho, lm, th, me))
    print('      rho = %-8g best float lambda_min(G) = %+.4e  (theta=%s, mu_eq=%s)   [%.0fs]'
          % (float(rho), lm, th, me, time.time() - T0))
    sys.stdout.flush()
    if lm < 0 and len(scan) >= 2 and scan[-2][1] < 0:
        break
good = [s for s in scan if s[1] > 1e-7]
if good:
    lo_s = good[-1]
    hi_candidates = [s for s in scan if s[0] > lo_s[0]]
    if hi_candidates:                      # refine rho by bisection between the last good and next bad
        a, b = lo_s[0], hi_candidates[0][0]
        for _ in range(5):
            mid = rnd_dn((a + b) / 2, 6)
            if mid <= a:
                break
            lm, th, me = best_params(mid)
            print('      bisect rho = %-9g lambda_min = %+.4e' % (float(mid), lm))
            if lm > 1e-7:
                a = mid; good.append((mid, lm, th, me))
            else:
                b = mid
good.sort(key=lambda s: s[0])

# ---------------- Part D: exact certification ----------------
print('==== Part D: exact certification ====')
def certify(rho, th, me, lm):
    out = build(rho, th, me)
    G, eps1, mu = out
    kp = Fr(0.9 * lm)
    Gf = tofloat(G)
    kpf = float(kp)
    L = fchol([[Gf[i][j] - (kpf if i == j else 0.0) for j in range(NV)] for i in range(NV)])
    if L is None:
        return None
    LF = [[Fr(v) for v in row] for row in L]
    E2 = Fr(0)
    for i in range(NV):
        Li = LF[i]
        for j in range(i + 1):
            Lj = LF[j]
            s = G[i][j] - (kp if i == j else 0) - sum(Li[t] * Lj[t] for t in range(j + 1))
            E2 += s * s if i == j else 2 * s * s
    kap = kp / 2
    psd_ok = kp > 0 and E2 <= kap * kap
    rn2 = sum(v * v for v in RHAT)
    e1p = eps1 if eps1 > 0 else Fr(0)
    tau = (sqrt_hi(rn2, 60) + sqrt_hi(rn2 + 2 * kap * e1p, 60)) / kap
    return psd_ok, kap, E2, eps1, tau

certified = None
for (rho, lm, th, me) in reversed(good):
    print('      trying rho = %s (theta = %s, mu_eq = %s, float lambda_min = %.4e)' % (rho, th, me, lm))
    res = certify(rho, th, me, lm)
    if res is None:
        print('      float Cholesky failed; next candidate'); continue
    psd_ok, kap, E2, eps1, tau = res
    ok1 = report('D1  rho = %s <= 7e-3 (Theorem A\' applies)' % rho, rho <= Fr('0.007'))
    ok2 = report('D2  G >= kappa*I with kappa = %.6e  (||E||_F = %.3e <= kappa)'
                 % (float(kap), math.sqrt(float(E2))), psd_ok, kap - Fr(math.sqrt(float(E2))))
    ok3 = report('D3  tau = %.3e <= 2e-6  (eps1 = %.3e)' % (float(tau), float(eps1)), tau <= Fr(2, 10 ** 6),
                 Fr(2, 10 ** 6) - tau)
    if ok1 and ok2 and ok3:
        certified = (rho, th, me, kap, tau)
        break
    print('      candidate failed; trying a smaller rho')

print('==== Summary ====')
if certified and not FAILS:
    rho, th, me, kap, tau = certified
    print('CERTIFIED: Theorem MID holds with rho_A = %s = %g (orbit radius rho_A/2.01 = %.6g),'
          % (rho, float(rho), float(rho) / 2.01))
    print('           theta = %s, mu_eq = %s, kappa = %.6e, tau = %.3e' % (th, me, float(kap), float(tau)))
else:
    print('NOT CERTIFIED. Failed checks: %s' % FAILS)
print('total time %.0fs' % (time.time() - T0))
```

## 6. What the program must output for the proof to stand

Every line tagged [PASS] in Parts A, B, D (A0, A1a–c, A2 ×9, A3 ×10, A4 ×9, A5 ×7, A6a/b ×2, A7 ×9, B0, B1, B2, D1, D2, D3),
no [FAIL] line, and the final line
  CERTIFIED: Theorem MID holds with rho_A = <ρ_A> …
The certified ρ_A (a rational printed by the program) is then the radius in Theorem MID(ρ_A); all of (i)–(iii) of the theorem
are exactly B2, D2, D3, and D1 + Part A give Theorem A′ at that radius. Part C is a floating search that only selects
the candidate; nothing from it enters the proof except the chosen data (θ, μ_eq, κ′, the float factor L̃), which are
re-checked exactly in Part D. Expected run time: a few minutes (the scan dominates).

Exact identity behind D2: G = κ′I + L̃L̃ᵀ + E with E computed exactly; L̃L̃ᵀ ⪰ 0, ‖E‖₂ ≤ ‖E‖_F ≤ κ′/2, so G ⪰ (κ′/2)I.

## 7. [Ed.: omitted — pre-run status and predictions. Result of the run: all PASS lines and CERTIFIED with ρ_A = 7/1000, κ = 4.068342·10⁻³, τ = 8.591·10⁻¹⁰; Appendix G(a). The SQ2 check in the program is an `assert` (skipped under python -O); the asserted facts 1.41421357² ≥ 2 and 1.41421357·0.007 ≤ 0.0099 are true.]

# Appendix E. GLOB and LOC on J = [R̄, 2.631692]: Lemma P, the program wit_exact_J.py and its soundness

[Ed.: Written before the runs; Appendix G(b) gives the runs actually made (η = 1/1024, δ₁ = 3/1000) and their outputs. "(C)"/"Appendix C" = Appendix C of this document; "data (A)" = floating-point data used only in the heuristic §1.2. Omitted: §3.4 (box-count predictions), §4 (a criterion for reusing r_1 certificates — not used, the J-runs were simply redone), §5 (what to do if a competitor appears — none appeared: no FAIL line, no DEEP log line) and §6 (pre-run status). Precise form of the GLOB conclusion: every φ ∈ Φ_A with P_m(φ; R) feasible for some R ∈ J lies in U (U′), in particular every witness vector Lemma W_J produces for any admissible choice in its step 2. The phrase "implementation note" of Appendix C about module globals is obsolete: U and MINW are passed in each task's cfg.]

Status line: COMPLETE (as far as possible without code execution). See §6.

Plan:
1. §0 Corrections to the material of Appendix C that matter here (θ₀, ω₉, transfer constant at δ₁ = 1.5·10⁻³, δ₁ = 3·10⁻⁴ vs ρ_A = 5·10⁻⁴).
2. §1 (a) The η–δ₁ relation: a quadratic-model derivation (heuristic, explicit constants from data (A)), the irrelevance of R_hi, and a precise computable criterion (LOC certificates + a `locscan` mode that certifies δ for a list of η).
3. §2 The precision floor removed: penalty-multiplier identity (proved) and a 60-digit Decimal Levenberg–Marquardt refinement of the minimiser (soundness independent of it).
4. §3 (b) The program `wit_exact_J.py` in full, soundness proof of every leaf type and of the LOC certificates, how to run, expected runtimes/box counts.
5. §4 (c) splits m ∉ {4,5}; §5 (d) competitors / logging; §6 status and open questions.

No code execution is available to me: nothing below was run. All run outputs are predictions, marked as such.

---

## §0. Corrections to inherited material (re-verified by hand)

**0.1 The rotation angle θ₀ (witness frame → F5 frame), m = 5.** Appendix C §3.1 gives θ₀ ≈ 2.72478. The exact mirror symmetry of F5 gives a cleaner value. In the m = 5 frame, D₇ = disk 4, D₈ = disk 3 and D₉ = disk 5. The corners φ̄₇ = corner(4,3) and φ̄₈ = corner(3,5) are mirror images under x ↦ −x, so in the F5 frame they sit at π/2 ∓ α. Hence

  θ₀ ≡ π/2 − (φ̄₇ + φ̄₈)/2 (mod 2π) = 7.853981633974 − 5.128939866530 = **2.725041767**.

Two cross-checks:
- φ̄₃ + θ₀ = 1.98734721294 + 2.725041767 = 4.71238898 = 3π/2. That is exactly where the mirror-invariant corner (11,10) must lie.
- The steps of φ̄ are mirror-symmetric (0.5616, 0.6817, 0.7440 | 0.7440, 0.6817, 0.5616 | 0.7660, 0.7764, 0.7660), and they sum to 6.283185.

So the old value is off by 2.6·10⁻⁴. That is harmless for soundness, since Q only has to be some exact rotation. It would cost LOC up to 2.35·2.6·10⁻⁴ ≈ 6·10⁻⁴ of drift, which is not negligible against δ₁ = 1.5·10⁻³. The program computes θ₀ from φ̄ as above, and checks the frame numerically (§3, `frame_check`).

**0.2 The m = 4 frame.** Here D′_k = D_{k+5 mod 9}, so φ̄′_k = φ̄_{k+5} − φ̄₅, with φ̄_{9+j} := φ̄_j + 2π. Explicitly:

  φ̄′ = (0.561643842893, 1.327667885906, 2.104110681180, 2.870134724193, 3.431778567086, 4.113464697173, 4.857481937133, 5.601499177093),

and θ′₀ = θ₀ + φ̄₅ − 2π = −0.145092957. The labels are E = disk 2, F = disk 1, (D′₁, …, D′₉) = disks (8, 4, 3, 5, 9, 7, 11, 10, 6). The step vector is (Δ₆, Δ₇, Δ₈, Δ₉, Δ₁, …, Δ₅). The pinned corner φ′₀ is corner(6,8).

**0.3 Outer-multiplier weights per witness corner.** Put ω_j := 2R̄·λ_{O(j)}, so that Σ_j ω_j = 1. In the m = 5 frame, witness corner j is the corner between D_j and D_{j+1}:

| corner | F5 pair | λ |
|---|---|---|
| φ₀ = φ₉ | (5,9) | 0.029441 |
| φ₁ | (9,7) | 0.024681 |
| φ₂ | (7,11) | 0.020808 |
| φ₃ | (11,10) | 0.012055 |
| φ₄ | (10,6) | 0.020808 |
| φ₅ | (6,8) | 0.024681 |
| φ₆ | (8,4) | 0.029441 |
| φ₇ | (4,3) | 0.014038 |
| φ₈ | (3,5) | 0.014038 |

So ω(pinned) = 5.26338·0.029441 = 0.15496 for m = 5. For m = 4 the pinned corner is (6,8), so ω(pinned) = 0.12991.

**0.4 Transfer constant at the coarse scale.** The bound of Appendix C §3.3 is

  ‖z − z̄‖_∞ ≤ (1 + β_max)δ + 2.0125·β_max + 1.18·β_max²,  with β_max = δ/(ȳ₃ − δ).

I re-derived it, and it is correct for every δ < ȳ₃. It is the linearised constant "1.857δ + 3δ²" that was stated only for δ ≤ 10⁻⁵. Exact values:

| δ₁ | β_max | bound on ‖z − z̄‖_∞ | fits ρ_A = 3·10⁻³? | fits ρ_A = 5·10⁻⁴? |
|---|---|---|---|---|
| 1.5·10⁻³ | 6.3902·10⁻⁴ | 2.7875·10⁻³ | yes | no |
| 3·10⁻⁴ | 1.2774·10⁻⁴ | 5.572·10⁻⁴ | yes | **no** |
| 2.5·10⁻⁴ | — | 4.643·10⁻⁴ | yes | yes |
| 3·10⁻³ [Ed.: added; the value actually run] | 1.27886·10⁻³ | 5.57947·10⁻³ | no | no — but < 7·10⁻³ = ρ_A actually certified |

So **if MID ends with ρ_A = 5·10⁻⁴, δ₁ must be ≤ 2.69·10⁻⁴, and δ₁ = 2.5·10⁻⁴ is the value to use**, not 3·10⁻⁴. For v = 3 the bound is δ + δ², which is smaller. The R-coordinate gives |R − R̄| ≤ 10⁻⁶ + 2·10⁻²¹.

---

## §1. (a) The η–δ₁ relation

Throughout, U = U(η) = Π_{k=1}^{8} [φ̄_k − η, φ̄_k + η] is a cube about the (rational) witness vector. The half-plane data of U are n̂_k = e(φ̄_k) (up to float rounding) and u_k ≥ cos η − 10⁻¹⁶. As in Appendix C §3.5, δ_max(U) := max over the 44 triples (v, ι, e) of sup{ e·((Qc_v)_ι − c̄_{λ(v),ι}) : (c, p, t, σ) solves P̃₅(U; J) }.

### 1.1 Two exact facts

**Lemma A1 (R_hi does not matter).** R_hi enters P̃_m(B; J) only through the upper bounds |σ_k| ≤ R_hi and |c_k| ≤ RHO. Hence the solution set of P̃_m(B; J) is contained in the solution set S⁰(B) of the system with these two families of constraints deleted, and S⁰(B) depends on R_lo only. Consequently δ_max(U) ≤ δ⁰_max(U) (the same supremum over S⁰), and **no enlargement of R_hi (within the hypotheses RHO ≤ 2.45, R_hi < 2.64 of M35_J) can spoil LOC**, provided the certificates do not use the anchor multipliers of |σ| ≤ R_hi. In practice they do not, since those constraints are inactive near Melissen.

*Proof.* Deleting constraints enlarges the solution set. The other constraints contain R only through h_k = R_lo·u_k and through σ₉·(1,0) ≥ R_lo. ∎

(One remark corrects an easy misreading. The cap {|σ| ≤ R_hi, n̂·σ ≥ R_lo cos η} is angularly wider than η: its half-width is arccos(R_lo cos η/R_hi) ≈ √(η² + 2(R_hi − R_lo)/R) ≥ 9.6·10⁻⁴, and for σ₉ it is ≈ 9.6·10⁻⁴. This would look fatal for δ₁ ~ 10⁻³, because a rotation by 10⁻³ moves boundary centres by 2.3·10⁻³. It is not fatal, because the extra angular room exists only at radius > R_lo. A single corner may use it, but the whole configuration cannot. This is what §1.2 quantifies.)

**Lemma A2 (lens–half-plane reduction).** Let (c, p, t, σ) solve P̃₅(B; J), and let Λ_k = D(c_k,1) ∩ D(c_{k+1},1) be the lens of corner k (k = 1, …, 9, with σ₉ the corner of (D₉, D₁)). Then max_{x∈Λ_k} n̂_k·x ≥ R_lo·u_k. Suppose the lens has its outer tip P_k, the intersection point of the two circles of larger modulus, and n̂_k lies in the normal cone of Λ_k at P_k, which is spanned by P_k − c_k and P_k − c_{k+1}. Then the maximum is n̂_k·P_k, so

  |P_k|·cos(θ_k − ψ_k) ≥ R_lo·u_k,  where θ_k = arg P_k and ψ_k = arg n̂_k.

*Proof.* σ_k ∈ Λ_k by (P2). The rest is the support function of a convex set that has a corner at P_k. At Melissen the radial direction e(φ̄_k) is strictly inside that normal cone, because both circles cross S_{R_*} transversally at the corner. So the hypothesis holds on a neighbourhood. ∎

### 1.2 The quadratic model (heuristic: rests on the float data (A))

**Proposition A3 (drift bound, second-order model).** Consider the following data:
- z, the slice coordinates of the configuration;
- β, the rotation that takes the witness frame to slice-normalised position;
- dz = z − z̄, and dθ_j = θ_j − φ̄_j, the corner-angle deviations in the witness frame.

Let γ > 0 be such that, near z̄, every configuration satisfying the 18 constraints g ≥ 0 of (A) obeys

  R − R̄ ≤ −Σ_i (λ_i − μ g_i) g_i − γ|dz|₂² + O(|dz|³)   (the augmented-Lagrangian bound).

From the data, H_L − 2μ DGᵀDG ≤ −0.0605 at μ = 0.5, so γ = 0.030 is admissible. With μ = 5, γ = 0.037 is admissible as long as g_i ≤ λ_i/μ.

Then every solution of P̃₅(U(η); J) close to the Melissen configuration satisfies, to second order,

  (A3)  γ|dz|₂² + (R̄/2)·Σ_{j=1}^{9} ω_j·dθ_j² ≤ (R̄/2)·η²·(1 − ω₉) + (R_* − R_lo).

The last term is below 2·10⁻²¹.

*Derivation.* By Lemma A2 with u_j ≥ cos η (and u₉ = 1, ψ₉ = 0), r_j := |P_j| ≥ R_lo cos η / cos dθ_j for j ≤ 8, and r₉ ≥ R_lo / cos dθ₉.

Put R′ := R_lo cos η. Then (z, R′) satisfies all 18 constraints of (A): the inner ones exactly, and the outer ones with slack O_j = r_j² − R′² ≥ R′² tan² dθ_j (j ≤ 8), and O₉ ≥ R_lo² − R′² + R_lo² tan² dθ₉ ≥ R̄²η²·(1 − O(η²)) + R̄² dθ₉².

Insert this into the augmented-Lagrangian bound, use λ_{O(j)}·R̄² = R̄ω_j/2, and drop the non-negative inner terms. This gives

  R′ − R̄ ≤ −(R̄/2)Σ_j ω_j dθ_j² − (R̄/2)ω₉η² − γ|dz|².

Finally use R′ − R̄ ≥ −R̄η²/2 − (R_* − R_lo) − O(η⁴). ∎

Reading off from (A3), with R̄(1 − ω₉)/2 = 1.1121 (m = 5) and 1.1450 (m = 4):

1. **Deformation:** |dz|₂ ≤ η·√(1.1121/γ). This is 6.09η for γ = 0.030 and 5.46η for γ = 0.037. Along the critical manifold the data give c ∈ [0.043, 0.136] instead of γ, and ‖dz‖_∞ ≈ (0.4–0.7)|u|₂. So the realistic sup-norm deformation is ≈ 0.7·√(1.1121/0.043)·η ≈ **3.6η**.
2. **Rotation:** with dz = 0, (A3) gives Σω_j β² ≤ η²(1 − ω₉), so |β| ≤ √(1 − ω₉)·η = **0.919η**. The boundary centres have |c̄| ≤ 2.349, so the rigid part moves them by ≤ 2.16η.
3. **Joint:** maximising a linear functional of (dz, β) over the ellipsoid (A3) needs the corner-angle sensitivities Θ_j = ∂θ_j/∂z, which the data do not give. Bounding both parts separately gives the crude total 2.16η + 3.6η ≈ 5.8η (realistic) or 2.16η + 6.1η ≈ 8.3η (worst case, ℓ²-bound with γ = 0.03). Assuming the two parts are roughly orthogonal in the ellipsoid metric gives √(2.16² + 3.6²)·η ≈ 4.2η.

**Estimate: δ_max(U(η)) = L·η + O(η²), with L ≈ 4.2 (plausible range 3–8.3).** The O(η²) term is negligible at η ≤ 10⁻³, because the data show a clean quadratic maximum out to |u| = 0.03.

Consequences, using the LOC margin criterion δ_max ≤ δ₁/1.25 so that the certificates have a comfortable margin (§2):

| δ₁ | η (L = 4.2) | η (L = 8.3, worst case) | recommended first try |
|---|---|---|---|
| 1.5·10⁻³ | 2.9·10⁻⁴ | 1.4·10⁻⁴ | η = 2⁻¹² = 2.441·10⁻⁴, then 2⁻¹¹ and 2⁻¹³ |
| 2.5·10⁻⁴ (or 3·10⁻⁴) | 4.8·10⁻⁵ (5.7·10⁻⁵) | 2.4·10⁻⁵ | η = 2⁻¹⁵ = 3.05·10⁻⁵ |

**Why the cube U is the right shape.** By (A3), LOC depends on U only through Σ_j ω_j ε_j². With per-coordinate half-widths ε_j, an anisotropic box ε_j ∝ ω_j^{−1/2} would give the same LOC budget at a larger volume. But GLOB's cost is governed by the distance to φ̄ along the critical directions T, not by the volume of U, so the gain is marginal. A union of boxes does not help LOC at all, because each box would need its own 44 certificates. **Recommendation: a cube with dyadic η, centred at the rational φ̄ of the data.** It needs no rotated coordinates, because Corollary W1_J needs per-coordinate intervals anyway.

### 1.3 The precise computable criterion (this replaces the estimate in the proof)

**Criterion.** LOC-coarse holds for (U(η), δ₁) iff each of the 44 convex systems 𝒮(v, ι, e) = P̃₅(U; J) ∪ {e·n^ι·c_v ≥ e·c̄_{λ(v),ι} + δ₁} is infeasible. Each such system has a Lemma D′ certificate if it is strictly infeasible: the penalty function is convex and coercive, and by Lemma P (§2) its exact minimiser's multipliers give V = −2P* < 0. So the criterion is decidable in practice. Run `loc` for a chosen (η, δ₁) and accept iff the program prints `ALL 44 CERTIFIED`.

To find the largest admissible η, the mode `locscan` does the following for each η in a list and each of the 44 triples. It runs a geometric bisection on δ ∈ [10⁻⁶, 5·10⁻²] (14 steps, ratio precision 0.07 %) with the certification test as oracle. It then prints:
- δ*_{v,ι,e}(η), the smallest δ that the program certified;
- δ*(η) = max over the triples;
- the ratio L(η) := δ*(η)/η.

Every δ*(η) it prints is a proved upper bound for δ_max(U(η)), each being a Lemma D′ certificate. Taking η with δ*(η) ≤ δ₁ and then running `loc` at δ₁ gives the LOC proof. Monotonicity in δ is not needed: the final `loc` run certifies the 44 systems at δ₁ directly.

---

## §2. Removing the double-precision floor

**Lemma P (penalty multipliers; proved).** Take any system of Lemma D′ type (pairs, anchors, half-planes) and its penalty

  f(x) = ½Σ_e(|x_a − x_b| − 1)₊² + ½Σ_j(|x_{v(j)}| − r_j)₊² + ½Σ_i(h_i − n_i·x_{v(i)})₊².

At any point x, read off multipliers as follows:
- y_e = w_e d_e/|d_e| with d_e = x_a − x_b and w_e = (|d_e| − 1)₊;
- z_j = w_j x_v/|x_v| with w_j = (|x_v| − r_j)₊;
- μ_i = s_i := (h_i − n_i·x_v)₊.

Then:
1. the net forces g_v of Lemma D′ are exactly the partial gradients ∂f/∂x_v;
2. Σ_v g_v·x_v = V₀ + 2f(x), where V₀ := Σ|y_e| + Σ r_j|z_j| − Σ μ_i h_i;
3. hence V ≤ −2f(x) + (M + max_v|x_v|)·Σ_v|g_v|.

In particular V < 0 as soon as Σ_v |g_v| < 2f(x)/(M + max|x_v|). At an exact minimiser of an infeasible system, V = −2·min f < 0.

*Proof.*
1. The gradient of ½(|d| − 1)₊² with respect to d is (|d| − 1)₊·d/|d| = y. It enters x_a with + and x_b with −, exactly as in g_v. The same computation works for anchors. For half-planes, ∇ of ½(h − n·x)₊² is −s·n = −μn.
2. y_e·d_e = w_e|d_e| = w_e(1 + w_e) = |y_e| + w_e². Likewise z_j·x_v = r_j|z_j| + w_j², and −μ_i n_i·x_v = −μ_i(h_i − s_i) = −μ_i h_i + s_i². Summing, the left-hand sides give Σ_v g_v·x_v and the squares give 2f.
3. V = V₀ + MΣ|g_v| = Σ g_v·x_v − 2f + MΣ|g_v| ≤ −2f + (max|x_v| + M)Σ|g_v|. ∎

f is convex: (t)₊² is convex and non-decreasing, and |d| − 1, |x| − r and h − n·x are convex. f is also C¹ and piecewise C². So any descent method that drives ∇f to 0 produces certificates for every strictly infeasible system. The obstruction in Appendix C §4.6 is purely Σ|g_v| ≈ 10⁻¹⁵ in double precision, against a requirement Σ|g_v| < 2f/7, where f ~ 20μ² for a violation margin μ.

**Remedy, implemented in §3.** After the float minimiser, run a damped Newton (Levenberg–Marquardt) iteration on f in 60-digit `decimal` arithmetic:
- the Hessian is assembled exactly from the pieces (1 − 1/L)I + ddᵀ/L³, (1 − r/L)I + r xxᵀ/L³ and nnᵀ;
- the step is (H + τI)Δ = −g, solved by dense Gaussian elimination, with τ adapted by the usual LM rule (accept if f does not increase);
- after each accepted step the exact certificate V (computed in `Fraction` from the Decimal point) is tested;
- the iteration stops as soon as V < 0.

Newton converges quadratically once the active set has settled, so 4–6 steps take Σ|g| from 10⁻¹⁰ to below 10⁻⁵⁰. Certification is then possible whenever f* > 10⁻⁴⁸, which corresponds to margins μ ≳ 10⁻²⁵. **No precision floor remains at any scale relevant here.** Soundness does not depend on the refinement in any way, because Lemma D′ admits all multipliers; the Decimal point is converted to `Fraction` exactly.

Cost estimate (not measured):
- one 62 × 62 Decimal solve is about 8·10⁴ multiply-adds, roughly 30–80 ms in CPython;
- a refinement is 5–10 solves plus 5–10 exact V evaluations, so 0.3–1 s;
- it runs only for boxes of maximal width ≤ `hpw` (default 1/16) whose float certificate failed.

Lemma D″ (localised a-priori bound) is therefore not needed. I do not use it.

---

## §3. (b) The program `wit_exact_J.py` (complete text; not run)

It is a standalone file, written as a superset of the F7 document's exact checker `wit_exact.py` (computation C2 of F7, not otherwise used here). The exact kernels (`fl`, `ce`, `sincos`, `pi_enclosure`, `sqrt_up`, `sqrt_dn`, `propagate`, `V_exact`, `split_roots`) are copied verbatim. It imports `ms5_witness_m` (Appendix 2 + diff of the F7 document) as `W`, and uses `W` only for:
- the index layout;
- the 51 pairs `W.static_constraints` (re-checked against Theorem C at start-up by `check_constraints` below);
- `W.Params`, `W.initial_x` and `W.minimize`, which only choose multipliers.

Save it in the same directory as `ms5_witness_m.py` (Appendix F), or add that directory to `PYTHONPATH`.

```python
#!/usr/bin/env python3
"""wit_exact_J.py (Appendix E): Part W on an R-interval J = [R_lo, R_hi] with an excluded cube U about
the Melissen witness vector (GLOB), and the LOC-coarse localisation certificates.

Modes (environment MSPLIT=m selects the split; ms5_witness_m.py must be importable):
  glob    R_lo R_hi nproc nroots [eta|none] [minw] [budget_per_task] [maxtotal]
  loc     R_lo R_hi nproc eta delta          (m in {4,5})
  locscan R_lo R_hi nproc eta1,eta2,...      (m in {4,5}; prints proved upper bounds of delta_max)
  sanity  R_lo R_hi eta                      (m in {4,5})
eta, delta, minw are exact decimal or p/q strings.  All load-bearing quantities are exact rationals;
floats and 60-digit Decimals are used only to CHOOSE multipliers (Lemma D' admits every choice).
"""
import sys, os, time, math
from fractions import Fraction as Fr
from math import isqrt
from decimal import Decimal as Dec, localcontext
import multiprocessing as mp

if sys.flags.optimize:
    raise SystemExit("refusing to run under -O (load-bearing asserts)")
MS = int(os.environ.get("MSPLIT", "0"))
if not (1 <= MS <= 8):
    raise SystemExit("set MSPLIT=m with 1 <= m <= 8")
import ms5_witness_m as W
if W.MSPLIT != MS:
    raise SystemExit("module MSPLIT mismatch")
DPREC = 60                                # Decimal digits of the multiplier refinement

# ----------------------------------------------------------------- exact kernels (verbatim) ----
P = 200
SC = 1 << P
def fl(x):
    return Fr((x.numerator * SC) // x.denominator, SC)
def ce(x):
    return Fr(-((-x.numerator * SC) // x.denominator), SC)

def sincos(t):
    """rigorous enclosures (lo, hi) of sin t and cos t for rational 0 <= t <= 8"""
    t = Fr(t); N = 80
    assert 0 <= t <= 8
    s_lo = s_hi = c_lo = c_hi = Fr(0)
    tl = th = Fr(1)
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
    def atan_inv(n, terms):
        x = Fr(1, n); acc = Fr(0)
        for k in range(terms):
            acc += Fr((-1) ** k, 2 * k + 1) * x ** (2 * k + 1)
        tail = x ** (2 * terms + 1) / (2 * terms + 1)
        return acc - tail, acc + tail
    a5 = atan_inv(5, 60); a239 = atan_inv(239, 30)
    return 16 * a5[0] - 4 * a239[1], 16 * a5[1] - 4 * a239[0]

PI_LO, PI_HI = pi_enclosure()
TPL, TPH = 2 * PI_LO, 2 * PI_HI

def sqrt_up(q):
    if q == 0: return Fr(0)
    K = 1 << 64
    a, b = q.numerator, q.denominator
    s = isqrt(a * b * K * K) + 1
    return Fr(s, b * K)
def sqrt_dn(q):
    K = 1 << 64
    a, b = q.numerator, q.denominator
    return Fr(isqrt(a * b * K * K), b * K)

# ------------------------------------------------------------------- constants on J ----
class EP:
    def __init__(self, Rlo_s, Rhi_s):
        self.Rlo, self.Rhi = Fr(Rlo_s), Fr(Rhi_s)
        assert 2 < self.Rlo <= self.Rhi < Fr(264, 100), "need 2 < R_lo <= R_hi < 2.64 (M35_J)"
        a = Fr(math.asin(1.0 / float(self.Rlo)) + 1e-12)
        (slo, shi), _ = sincos(a)
        assert slo > 1 / self.Rlo and a < PI_LO / 2, "arcsin bound failed"
        self.A = 2 * a                                   # >= 2 arcsin(1/R) for all R >= R_lo
        self.RHO = sqrt_up(self.Rhi * self.Rhi - 1)      # >= sqrt(R^2-1) for all R <= R_hi
        assert self.RHO <= Fr(245, 100), "RHO > 2.45 (M35_J)"
        self.M = Fr(7, 2)

def check_constraints(par):
    """independent transcription of Theorem C for m = MS, compared with W; aborts on any mismatch"""
    m = MS; NE, NF = 0, 1
    C = lambda k: 1 + k; Pp = lambda k: 10 + k; T1, T6 = 20, 21; S = lambda k: 21 + k
    exp = set()
    for k in range(1, 10):
        exp.add((C(k), S(9 if k == 1 else k - 1))); exp.add((C(k), S(k)))
        exp |= {(Pp(k), C(k)), (Pp(k), C(1 if k == 9 else k + 1)), (Pp(k), NE if k <= m else NF)}
    exp |= {(T1, C(1)), (T1, NE), (T1, NF), (T6, C(m + 1)), (T6, NE), (T6, NF)}
    assert (W.NE, W.NF, W.C(1), W.C(9), W.P(1), W.P(9), W.T1, W.T6, W.S(1), W.S(9), W.NV) == \
           (0, 1, 2, 10, 11, 19, 20, 21, 22, 30, 31), "index layout differs"
    assert W.N == 2 * W.NV
    pairs, anchors = W.static_constraints(par)
    if set(pairs) != exp or len(pairs) != len(exp):
        raise SystemExit("constraint list differs from Theorem C")
    return pairs, anchors

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
    """(v, nx, ny, h): h = R_lo * u, u a rigorous lower bound of n.e(t) at both ends (u > 0);
    valid for sigma_k = s_R(phi_k), every R >= R_lo and phi_k in [lo_k, hi_k] (half-plane lemma)."""
    hs = []
    for k in range(1, 9):
        al, be = lo[k], hi[k]
        if not (be - al <= Fr(3, 2)): return None
        mid = float((al + be) / 2)
        nx, ny = Fr(math.cos(mid)), Fr(math.sin(mid))
        us = []
        for t in (al, be):
            (slo, shi), (clo, chi) = sincos(t)
            us.append(min(nx * clo, nx * chi) + min(ny * slo, ny * shi))
        u = min(us)
        if not u > 0: return None
        hs.append((W.S(k), nx, ny, ep.Rlo * u))
    hs.append((W.S(9), Fr(1), Fr(0), ep.Rlo))            # sigma_9 = (R, 0), R >= R_lo
    return hs

def anchors_exact(ep):
    return [(W.NE, Fr(1))] + [(W.C(k), ep.RHO) for k in range(1, 10)] + \
           [(W.S(k), ep.Rhi) for k in range(1, 10)]

def V_exact(ep, x, pairs, anchors, halves):
    """exact upper bound of V (Lemma D') for multipliers read off float x"""
    N = W.N
    g = [Fr(0)] * N
    tot = Fr(0)
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

def fr2dec(q):
    q = Fr(q)
    return Dec(q.numerator) / Dec(q.denominator)

def V_dec(ep, xd, pairs, anchors, halves):
    """same bound as V_exact, multipliers read off a Decimal point xd (converted to Fraction EXACTLY)"""
    with localcontext() as ctx:
        ctx.prec = DPREC
        one = Dec(1)
        g = [Fr(0)] * W.N; tot = Fr(0)
        for (a, b) in pairs:
            dx = xd[2*a] - xd[2*b]; dy = xd[2*a+1] - xd[2*b+1]
            L = (dx * dx + dy * dy).sqrt()
            if L > one:
                q = (L - one) / L
                yx, yy = Fr(q * dx), Fr(q * dy)
                tot += sqrt_up(yx * yx + yy * yy)
                g[2*a] += yx; g[2*a+1] += yy; g[2*b] -= yx; g[2*b+1] -= yy
        for (v, r) in anchors:
            dx, dy = xd[2*v], xd[2*v+1]
            L = (dx * dx + dy * dy).sqrt(); rd = fr2dec(r)
            if L > rd:
                q = (L - rd) / L
                zx, zy = Fr(q * dx), Fr(q * dy)
                tot += r * sqrt_up(zx * zx + zy * zy)
                g[2*v] += zx; g[2*v+1] += zy
        for (v, nx, ny, h) in halves:
            s = fr2dec(h) - (fr2dec(nx) * xd[2*v] + fr2dec(ny) * xd[2*v+1])
            if s > 0:
                mu = Fr(s)                                  # mu >= 0 as Lemma D' requires
                tot -= mu * h
                g[2*v] -= mu * nx; g[2*v+1] -= mu * ny
        for v in range(W.NV):
            tot += ep.M * sqrt_up(g[2*v] ** 2 + g[2*v+1] ** 2)
    return tot

# --------------------------------------------- Levenberg-Marquardt on the convex penalty ----
class FloatOps:
    Z, ONE, BIG = 0.0, 1.0, 1e12
    sqrt = staticmethod(math.sqrt)
    conv = staticmethod(float)
class DecOps:                                   # use only inside localcontext(prec = DPREC)
    Z, ONE, BIG = Dec(0), Dec(1), Dec(10) ** 12
    sqrt = staticmethod(lambda q: q.sqrt())
    conv = staticmethod(fr2dec)

def numcons(anch, halves, ops):
    return ([(v, ops.conv(r)) for (v, r) in anch],
            [(v, ops.conv(nx), ops.conv(ny), ops.conv(h)) for (v, nx, ny, h) in halves])

def assemble(x, pairs, anch, halves, ops):
    """penalty f, its gradient g (= net forces of Lemma D') and Hessian H"""
    N = len(x); Z, ONE, sq = ops.Z, ops.ONE, ops.sqrt
    f = Z; g = [Z] * N; H = [[Z] * N for _ in range(N)]
    def blk(i, j, sg, hxx, hxy, hyy):
        a, b = 2 * i, 2 * j
        if sg < 0: hxx, hxy, hyy = -hxx, -hxy, -hyy
        H[a][b] += hxx; H[a][b+1] += hxy; H[a+1][b] += hxy; H[a+1][b+1] += hyy
    for (a, b) in pairs:
        dx = x[2*a] - x[2*b]; dy = x[2*a+1] - x[2*b+1]
        L = sq(dx * dx + dy * dy)
        if L > ONE:
            w = L - ONE; f += w * w / 2; q = w / L
            g[2*a] += q * dx; g[2*a+1] += q * dy; g[2*b] -= q * dx; g[2*b+1] -= q * dy
            L3 = L * L * L
            hxx, hxy, hyy = q + dx * dx / L3, dx * dy / L3, q + dy * dy / L3
            blk(a, a, 1, hxx, hxy, hyy); blk(b, b, 1, hxx, hxy, hyy)
            blk(a, b, -1, hxx, hxy, hyy); blk(b, a, -1, hxx, hxy, hyy)
    for (v, r) in anch:
        dx, dy = x[2*v], x[2*v+1]
        L = sq(dx * dx + dy * dy)
        if L > r:
            w = L - r; f += w * w / 2; q = w / L
            g[2*v] += q * dx; g[2*v+1] += q * dy
            L3 = L * L * L
            blk(v, v, 1, q + r * dx * dx / L3, r * dx * dy / L3, q + r * dy * dy / L3)
    for (v, nx, ny, h) in halves:
        s = h - (nx * x[2*v] + ny * x[2*v+1])
        if s > Z:
            f += s * s / 2
            g[2*v] -= s * nx; g[2*v+1] -= s * ny
            blk(v, v, 1, nx * nx, nx * ny, ny * ny)
    return f, g, H

def solve(A, b, Z):
    n = len(b)
    Mx = [A[i][:] + [b[i]] for i in range(n)]
    for i in range(n):
        p, best = i, abs(Mx[i][i])
        for r in range(i + 1, n):
            t = abs(Mx[r][i])
            if t > best: p, best = r, t
        if best == Z: raise ZeroDivisionError("singular LM matrix")
        if p != i: Mx[i], Mx[p] = Mx[p], Mx[i]
        Mi = Mx[i]; piv = Mi[i]
        for r in range(i + 1, n):
            Mr = Mx[r]
            if Mr[i] != Z:
                fct = Mr[i] / piv
                for c in range(i, n + 1):
                    if Mi[c] != Z: Mr[c] -= fct * Mi[c]
    xs = [Z] * n
    for i in range(n - 1, -1, -1):
        Mi = Mx[i]; s = Mi[n]
        for c in range(i + 1, n):
            if Mi[c] != Z: s -= Mi[c] * xs[c]
        xs[i] = s / Mi[i]
    return xs

def lm(x, pairs, anch, halves, ops, maxit, tau, taumin, gtol, check=None):
    f, g, H = assemble(x, pairs, anch, halves, ops)
    for _ in range(maxit):
        if check is not None and check(x): return x, True
        if max(abs(t) for t in g) <= gtol: break
        A = [row[:] for row in H]
        for i in range(len(x)): A[i][i] += tau
        try:
            d = solve(A, [-t for t in g], ops.Z)
        except ZeroDivisionError:
            break
        xn = [a + b for a, b in zip(x, d)]
        fn, gn, Hn = assemble(xn, pairs, anch, halves, ops)
        if fn <= f:
            x, f, g, H = xn, fn, gn, Hn; tau = max(tau / 10, taumin)
        else:
            tau = tau * 10
            if tau > ops.BIG: break
    return x, (check(x) if check is not None else False)

def certify(ep, x, pairs, anch, halves):
    """try to certify infeasibility (V < 0) of the system (pairs, anch, halves) starting from float x.
    Returns (ok, float point, how).  Soundness rests only on V_exact / V_dec."""
    x = [float(t) for t in x]
    if V_exact(ep, x, pairs, anch, halves) < 0: return True, x, 'float'
    fa, fh = numcons(anch, halves, FloatOps)
    x, _ = lm(x, pairs, fa, fh, FloatOps, 200, 1e-4, 1e-14, 1e-16)
    if all(math.isfinite(t) for t in x) and V_exact(ep, x, pairs, anch, halves) < 0:
        return True, x, 'float-lm'
    if not all(math.isfinite(t) for t in x): return False, x, 'nan'
    with localcontext() as ctx:
        ctx.prec = DPREC
        da, dh = numcons(anch, halves, DecOps)
        chk = lambda xx: V_dec(ep, xx, pairs, anch, halves) < 0
        xd, ok = lm([Dec(t) for t in x], pairs, da, dh, DecOps, 30,
                    Dec("1e-20"), Dec("1e-58"), Dec("1e-58"), chk)
        xf = [float(t) for t in xd]
    return ok, xf, ('dec' if ok else 'open')

# ------------------------------------------------------------- Melissen frames (m = 5, 4) ----
_CB = {1: ("0", "-0.39324960179250027086"), 2: ("0", "0.71839227931685877597"),
       3: ("0", "2.34884120097565953729"),
       4: ("1.57535264004342806580", "1.62062588642691912838"),
       6: ("1.77273616280974093118", "-0.93632239910290244643"),
       8: ("1.82750955295212993964", "0.24958048504283922431"),
       10: ("0.78521708246826346764", "-2.01247018720615423819")}
CBAR = {}
for _i, (_x, _y) in _CB.items():
    CBAR[_i] = (Fr(_x), Fr(_y))
    if _i >= 4: CBAR[_i + 1] = (-Fr(_x), Fr(_y))          # mirror partners 5, 7, 9, 11
RBAR = Fr("2.63169077261980820552")
PHIBAR5 = [Fr(s) for s in ("0.561643842893", "1.24332997298", "1.98734721294", "2.7313644529",
                           "3.413050582987", "3.97469442588", "4.740718468893", "5.517161264167")]
F5ORDER = {5: (9, 7, 11, 10, 6, 8, 4, 3, 5), 4: (8, 4, 3, 5, 9, 7, 11, 10, 6)}
EF = {5: (1, 2), 4: (2, 1)}                                # (E, F) as F5 disk labels

def frame(m):
    """labels lam (witness point index -> F5 disk), witness vector phibar[0..9] (rational),
    exact rational rotation Q (witness frame -> F5 frame) given by its rows, references cbar_w."""
    assert m in (4, 5)
    TWOPI = (TPL + TPH) / 2
    p5 = [Fr(0)] + PHIBAR5 + [TWOPI]
    if m == 5:
        phib = p5[:]
        theta = math.pi / 2 - float(p5[7] + p5[8]) / 2 + 2 * math.pi
    else:
        ext = p5 + [p5[j] + TWOPI for j in range(1, 10)]
        phib = [ext[k + 5] - p5[5] for k in range(10)]
        theta = math.pi / 2 - float(p5[7] + p5[8]) / 2 + float(p5[5])
    phib = [Fr(round(t * 10 ** 15), 10 ** 15) for t in phib]   # short rationals (any rational centre is admissible)
    lam = {W.NE: EF[m][0], W.NF: EF[m][1]}
    for k in range(1, 10): lam[W.C(k)] = F5ORDER[m][k - 1]
    tau = Fr(math.tan(theta / 2)).limit_denominator(10 ** 15)
    c = (1 - tau * tau) / (1 + tau * tau); s = 2 * tau / (1 + tau * tau)
    assert c * c + s * s == 1
    rows = ((c, -s), (s, c))                                 # (Q u)_x = rows[0].u, (Q u)_y = rows[1].u
    cbar_w = {v: CBAR[lam[v]] for v in lam}
    return dict(lam=lam, phib=phib, theta=theta, tau=tau, rows=rows, cbar_w=cbar_w)

def frame_check(fr):
    """float check that the rotated F5 decimals solve P_m(phibar; Rbar) (tight outer witnesses)"""
    c, s = float(fr['rows'][0][0]), float(fr['rows'][1][0])
    def back(v):                                             # Q^T cbar
        x, y = (float(t) for t in fr['cbar_w'][v])
        return (c * x + s * y, -s * x + c * y)
    R = float(RBAR); dev = 0.0
    for k in range(1, 10):
        cx, cy = back(W.C(k))
        for j in (k - 1, k):
            a = float(fr['phib'][j])
            dev = max(dev, abs(math.hypot(cx - R * math.cos(a), cy - R * math.sin(a)) - 1.0))
    ex, ey = back(W.NE)
    return dev, math.hypot(ex, ey)

def cube(phib, eta):
    lo = [Fr(0)] + [phib[k] - eta for k in range(1, 9)] + [TPL]
    hi = [Fr(0)] + [phib[k] + eta for k in range(1, 9)] + [TPH]
    return lo, hi

# ------------------------------------------------------------------------------ GLOB ----
def boxdist(lo, hi, ref):
    if ref is None: return None
    return max(max(float(lo[k]) - ref[k], ref[k] - float(hi[k]), 0.0) for k in range(1, 9))

def bucket(d):
    if d is None: return 'na'
    if d == 0.0: return '0'
    return '1e%d' % math.floor(math.log10(d))

def try_box(ep, cfg, par, pairs, anch_f, anch, lo, hi, x0):
    if not propagate(ep, lo, hi):
        return 'empty', x0
    U = cfg['U']
    if U is not None and all(U[0][k] <= lo[k] and hi[k] <= U[1][k] for k in range(1, 9)):
        return 'local', x0                                   # leaf inside U: handed to LOC
    hs = halfplanes(ep, lo, hi)
    if hs is None:
        return 'open', x0
    hsf = [(v, float(nx), float(ny), float(h)) for (v, nx, ny, h) in hs]
    flo = [float(t) for t in lo]; fhi = [float(t) for t in hi]
    x = x0 if x0 is not None else W.initial_x(par, flo, fhi)
    x, f = W.minimize(x, pairs, anch_f, hsf)
    if f > 0.0 and V_exact(ep, x, pairs, anch, hs) < 0:
        return 'cert', x
    if max(hi[k] - lo[k] for k in range(1, 9)) <= cfg['hpw']:
        ok, x2, how = certify(ep, x, pairs, anch, hs)
        if ok: return 'cert_hp', x2
    return 'open', x

def process(task):
    cfg, lo, hi, depth0 = task
    ep = EP(cfg['Rlo'], cfg['Rhi']); par = W.Params(cfg['Rlo'])
    pairs, anch_f = W.static_constraints(par)
    anch = anchors_exact(ep)
    st = dict(boxes=0, empty=0, cert=0, cert_hp=0, local=0, split=0)
    fails, logs, left, hist = [], [], [], {}
    stack = [(lo[:], hi[:], None, depth0)]
    t0 = time.time()
    while stack:
        if st['boxes'] >= cfg['budget']:
            left = [(l, h, d) for (l, h, _, d) in stack]; break
        lo, hi, x0, dep = stack.pop(); st['boxes'] += 1
        s, x = try_box(ep, cfg, par, pairs, anch_f, anch, lo, hi, x0)
        if s != 'open':
            st[s] += 1
            if s != 'empty':
                d = boxdist(lo, hi, cfg['ref'])
                key = (s, 5 * (dep // 5), bucket(d))
                hist[key] = hist.get(key, 0) + 1
                if dep >= cfg['deep'] and (d is None or d > cfg['far']) and len(logs) < 200:
                    logs.append(('DEEP', s, dep, d, [float(t) for t in lo[1:9]], [float(t) for t in hi[1:9]]))
            continue
        k = max(range(1, 9), key=lambda j: hi[j] - lo[j])
        if hi[k] - lo[k] < cfg['minw']:
            fails.append(('OPEN', dep, boxdist(lo, hi, cfg['ref']),
                          [float(t) for t in lo[1:9]], [float(t) for t in hi[1:9]]))
            continue
        mid = (lo[k] + hi[k]) / 2
        h1 = hi[:]; h1[k] = mid; l2 = lo[:]; l2[k] = mid
        st['split'] += 1
        stack.append((lo[:], h1, x, dep + 1)); stack.append((l2, hi[:], x, dep + 1))
    return st, fails, logs, left, hist, time.time() - t0

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

def run_glob(av):
    Rlo, Rhi, nproc, nroots = av[0], av[1], int(av[2]), int(av[3])
    eta = av[4] if len(av) > 4 else 'none'
    minw = Fr(av[5]) if len(av) > 5 else Fr(1, 10 ** 9)
    budget = int(av[6]) if len(av) > 6 else 3000
    maxtotal = int(av[7]) if len(av) > 7 else 10 ** 8
    ep = EP(Rlo, Rhi); par = W.Params(Rlo); check_constraints(par)
    fr = frame(MS) if MS in (4, 5) else None
    U = None
    if eta != 'none':
        if fr is None: raise SystemExit("an excluded box U is only allowed for m in {4, 5}")
        U = cube(fr['phib'], Fr(eta))
        assert all(0 < U[0][k] and U[1][k] < 7 and U[1][k] - U[0][k] <= Fr(3, 2) for k in range(1, 9))
    ref = [float(t) for t in fr['phib']] if fr is not None else None
    cfg = dict(Rlo=Rlo, Rhi=Rhi, U=U, ref=ref, minw=minw, budget=budget, hpw=Fr(1, 16), deep=40, far=0.02)
    print("WIT-J glob MSPLIT=%d J=[%s, %s] A=%.15f RHO=%.12f eta=%s minw=%s budget=%d"
          % (MS, Rlo, Rhi, float(ep.A), float(ep.RHO), eta, minw, budget), flush=True)
    if fr is not None:
        dev, e0 = frame_check(fr)
        print("frame: theta=%.12f tau=%s outer-witness deviation %.2e |c_E|=%.6f" % (fr['theta'], fr['tau'], dev, e0))
        if U is not None: print("U lo =", [str(t) for t in U[0][1:9]]); print("U hi =", [str(t) for t in U[1][1:9]])
    for t in (0.3, 1.7, 4.4, 6.9):
        (sl, sh), (cl, ch) = sincos(Fr(t))
        assert sl <= Fr(math.sin(t)) + Fr(1, 10 ** 15) and Fr(math.sin(t)) - Fr(1, 10 ** 15) <= sh
        assert sh - sl < Fr(1, 10 ** 40)
    lo = [Fr(0)] * 10; hi = [Fr(7)] * 10
    if not propagate(ep, lo, hi):
        print("root empty"); return
    tasks = [(cfg, a, b, 0) for a, b in split_roots(lo, hi, nroots)]
    tot = dict(boxes=0, empty=0, cert=0, cert_hp=0, local=0, split=0)
    fails, logs, hist = [], [], {}
    t0 = time.time(); rnd = 0
    with mp.Pool(nproc) as pool:
        while tasks:
            rnd += 1; nxt = []
            for i, (st, fl_, lg, left, hs_, dt) in enumerate(pool.imap_unordered(process, tasks)):
                for k in tot: tot[k] += st[k]
                fails += fl_; logs += lg
                for k, v in hs_.items(): hist[k] = hist.get(k, 0) + v
                nxt += [(cfg, l, h, d) for (l, h, d) in left]
                if (i + 1) % 256 == 0 or i + 1 == len(tasks):
                    print("round %d tasks %d/%d %s requeued %d fails %d %.0fs"
                          % (rnd, i + 1, len(tasks), tot, len(nxt), len(fails), time.time() - t0), flush=True)
            tasks = nxt
            if tot['boxes'] > maxtotal and tasks:
                fails.append(('BUDGET', len(tasks))); break
    for f in fails[:50]: print("FAIL", f)
    for g in logs[:200]: print("LOG", g)
    for key in sorted(hist, key=str): print("HIST", key, hist[key])
    leaves = tot['empty'] + tot['cert'] + tot['cert_hp'] + tot['local']
    print("counts: boxes=%d leaves=%d splits=%d (boxes - 2*splits = %d roots)"
          % (tot['boxes'], leaves, tot['split'], tot['boxes'] - 2 * tot['split']))
    ok = not fails
    print("EXACT RESULT J=[%s,%s] MSPLIT=%d: %s" % (Rlo, Rhi, MS,
          ("ALL BOXES EMPTY, CERTIFIED OR IN U (local=%d, eta=%s)" % (tot['local'], eta)) if ok
          else "NOT CERTIFIED (%d failures)" % len(fails)), flush=True)

# ------------------------------------------------------------------------------- LOC ----
def loc_system(cfg, v, iota, e, delta):
    ep = EP(cfg['Rlo'], cfg['Rhi']); par = W.Params(cfg['Rlo'])
    pairs, anch_f = W.static_constraints(par)
    anch = anchors_exact(ep)
    fr = frame(MS)
    lo, hi = cube(fr['phib'], cfg['eta'])
    hs = halfplanes(ep, lo, hi)
    assert hs is not None
    n = fr['rows'][iota]
    extra = (v, e * n[0], e * n[1], e * fr['cbar_w'][v][iota] + delta)   # e (Q c_v)_iota >= e cbar + delta
    halves = hs + [extra]
    x0 = W.initial_x(par, [float(t) for t in lo], [float(t) for t in hi])
    return ep, par, pairs, anch_f, anch, halves, x0

def loc_test(cfg, v, iota, e, delta):
    ep, par, pairs, anch_f, anch, halves, x0 = loc_system(cfg, v, iota, e, delta)
    hsf = [(vv, float(a), float(b), float(c)) for (vv, a, b, c) in halves]
    try:
        x0, _ = W.minimize(x0, pairs, anch_f, hsf)
    except Exception:
        pass                                     # W.minimize only chooses a start point
    ok, x, how = certify(ep, x0, pairs, anch, halves)
    return ok, how

def loc_task(task):
    cfg, v, iota, e, delta = task
    t0 = time.time(); ok, how = loc_test(cfg, v, iota, e, delta)
    return v, iota, e, ok, how, time.time() - t0

def triples():
    return [(v, iota, e) for v in [W.NE, W.NF] + [W.C(k) for k in range(1, 10)]
            for iota in (0, 1) for e in (1, -1)]

def run_loc(av):
    Rlo, Rhi, nproc, eta, delta = av[0], av[1], int(av[2]), Fr(av[3]), Fr(av[4])
    assert MS in (4, 5)
    ep = EP(Rlo, Rhi); par = W.Params(Rlo); check_constraints(par)
    fr = frame(MS); dev, e0 = frame_check(fr)
    print("WIT-J loc MSPLIT=%d J=[%s,%s] eta=%s delta=%s theta=%.12f tau=%s frame-dev %.2e"
          % (MS, Rlo, Rhi, eta, delta, fr['theta'], fr['tau'], dev), flush=True)
    assert dev < 1e-6, "frame check failed (labels / witness vector / rotation inconsistent)"
    cfg = dict(Rlo=Rlo, Rhi=Rhi, eta=eta)
    nok = 0
    with mp.Pool(nproc) as pool:
        for (v, iota, e, ok, how, dt) in pool.imap_unordered(loc_task, [(cfg, v, i, e, delta) for (v, i, e) in triples()]):
            nok += ok
            print("LOC v=%d (F5 disk %d) %s e=%+d: %s [%s, %.1fs]"
                  % (v, fr['lam'][v], 'xy'[iota], e, 'CERT' if ok else 'OPEN', how, dt), flush=True)
    print("LOC RESULT MSPLIT=%d J=[%s,%s] eta=%s delta=%s: %s" % (MS, Rlo, Rhi, eta, delta,
          "ALL 44 CERTIFIED" if nok == 44 else "NOT CERTIFIED (%d of 44 open)" % (44 - nok)), flush=True)

def scan_task(task):
    cfg, v, iota, e = task
    lo_d, hi_d = Fr(1, 10 ** 6), Fr(5, 100)
    if not loc_test(cfg, v, iota, e, hi_d)[0]: return v, iota, e, None
    if loc_test(cfg, v, iota, e, lo_d)[0]: return v, iota, e, lo_d
    for _ in range(14):
        mid = Fr(math.sqrt(float(lo_d) * float(hi_d))).limit_denominator(10 ** 12)
        if loc_test(cfg, v, iota, e, mid)[0]: hi_d = mid
        else: lo_d = mid
    return v, iota, e, hi_d

def run_locscan(av):
    Rlo, Rhi, nproc = av[0], av[1], int(av[2])
    etas = [Fr(t) for t in av[3].split(',')]
    assert MS in (4, 5)
    ep = EP(Rlo, Rhi); par = W.Params(Rlo); check_constraints(par)
    with mp.Pool(nproc) as pool:
        for eta in etas:
            cfg = dict(Rlo=Rlo, Rhi=Rhi, eta=eta); worst = Fr(0); bad = 0
            for (v, iota, e, d) in pool.imap_unordered(scan_task, [(cfg, v, i, e) for (v, i, e) in triples()]):
                print("SCAN eta=%s v=%d %s e=%+d: certified delta = %s" % (eta, v, 'xy'[iota], e,
                      'none<=0.05' if d is None else '%.4e' % float(d)), flush=True)
                if d is None: bad += 1
                else: worst = max(worst, d)
            print("SCAN RESULT MSPLIT=%d eta=%s: delta*(eta)=%.4e  L=delta*/eta=%.3f  (%d triples uncertified)"
                  % (MS, eta, float(worst), float(worst / eta), bad), flush=True)

def run_sanity(av):
    Rlo, Rhi, eta = av[0], av[1], Fr(av[2])
    assert MS in (4, 5)
    fr = frame(MS); dev, e0 = frame_check(fr)
    print("SANITY frame: theta=%.12f dev=%.2e |c_E|=%.4f (expect dev ~1e-11, |c_E| <= 1)" % (fr['theta'], dev, e0))
    ep = EP(Rlo, Rhi); par = W.Params(Rlo); pairs, anch_f = check_constraints(par)
    cfg = dict(U=None, hpw=Fr(1, 16))
    lo, hi = cube(fr['phib'], eta)
    s, _ = try_box(ep, cfg, par, pairs, anch_f, anchors_exact(ep), lo, hi, None)
    print("SANITY-1 U(eta) at J (contains Melissen, R_lo < R_*): %s -> %s" % (s, 'OK' if s == 'open' else 'BUG: UNSOUND'))
    ok, how = loc_test(dict(Rlo=Rlo, Rhi=Rhi, eta=eta), W.C(8), 1, 1, Fr(1, 10 ** 7))
    print("SANITY-2 LOC with delta=1e-7 (must stay open): %s -> %s" % (ok, 'OK' if not ok else 'BUG'))
    ep1 = EP("2.6317", "2.6317"); par1 = W.Params("2.6317")
    lo, hi = cube(fr['phib'], Fr(1, 1000))
    s, _ = try_box(ep1, cfg, par1, pairs, anch_f, anchors_exact(ep1), lo, hi, None)
    print("SANITY-3 U(1e-3) at R = r_1 (should certify, as in C2): %s" % s)

if __name__ == "__main__":
    mode, av = sys.argv[1], sys.argv[2:]
    {'glob': run_glob, 'loc': run_loc, 'locscan': run_locscan, 'sanity': run_sanity}[mode](av)
```

### 3.1 Exact frame data (as computed by `frame`)

**m = 5.**
- λ(E, F, D₁, …, D₉) = F5 disks (1, 2, 9, 7, 11, 10, 6, 8, 4, 3, 5).
- φ̄ = the eight decimals of the task, rounded to the 10⁻¹⁵ grid.
- θ₀ = π/2 − (φ̄₇ + φ̄₈)/2 + 2π ≈ 2.725041767.
- τ = Fraction(tan(θ₀/2)).limit_denominator(10¹⁵) ≈ 4.7318.
- Q = [[c, −s], [s, c]] with c = (1 − τ²)/(1 + τ²) and s = 2τ/(1 + τ²). The code asserts c² + s² = 1 exactly.

**m = 4.**
- λ′(E, F, D₁, …, D₉) = F5 disks (2, 1, 8, 4, 3, 5, 9, 7, 11, 10, 6).
- φ̄′ as in §0.2.
- θ′₀ = π/2 − (φ̄₇ + φ̄₈)/2 + φ̄₅ ≈ −0.145092957, giving τ′ ≈ −0.072674.

**Both.** U(η) = Π_k [φ̄_k − η, φ̄_k + η], and U′(η) is the same with φ̄′. The program prints both exactly. The `frame_check` routine computes max_k | |Qᵀc̄_{λ(C_k)} − R̄·e(φ̄_j)| − 1 | over j ∈ {k−1, k}. It must be ≈ 10⁻¹¹; `loc` aborts if it exceeds 10⁻⁶. This catches label, order or rotation errors before any LOC run. The guard is a safety check only: it is not load-bearing.

### 3.2 Soundness (what each output proves)

Fix m and J = [R_lo, R_hi] with 2 < R_lo ≤ R_hi < 2.64 and RHO ≤ 2.45; `EP` asserts both. The Part-W_J chain of Appendix C §1 has been re-verified here line by line: Lemma W_J, Theorem C_J, Corollary W1_J, M35_J, Corollary W2_J. In `halfplanes` the bound n̂·s_R(φ) ≥ R·u ≥ R_lo·u needs u > 0, which is checked. σ₉ = (R, 0) satisfies σ_x ≥ R_lo and |σ₉| ≤ R_hi.

The leaf types of `glob` mean the following.
- **empty.** Exact propagation shows that the box contains no point of Φ_A. This holds because A ≥ 2a(R_lo) ≥ 2a(R) for every R ∈ J.
- **cert / cert_hp.** P̃_m(B; J) is infeasible. V is an exact upper bound of Lemma D′'s V, for multipliers read off either a float point (`V_exact`, verbatim from C2) or a 60-digit Decimal point converted exactly to `Fraction` (`V_dec`). V_dec has the same structure as V_exact: μ = Fr(s) only when s > 0, so μ ≥ 0; |y| and |g| are replaced by `sqrt_up` upper bounds; the g_v are accumulated exactly with the signs of D′. Then V < 0 together with M = 7/2 (M35_J) gives that no φ ∈ B ∩ Φ_A and R ∈ J has P_m(φ; R) feasible.
- **local.** The propagated box lies inside U. So every φ ∈ Φ_A of the original box lies in U.
- **Covering.** Bisection children cover their parent, roots cover the propagated root, and the root [0, 7]⁸ ∪ {φ₀ = 0, φ₉ ∈ [TPL, TPH]} contains Φ_A. Re-queued boxes (`left`) are unprocessed stack entries that are re-submitted as new tasks, so nothing is lost. The final identity boxes − 2·splits = nroots is printed as a cross-check.
- **Success line.** `ALL BOXES EMPTY, CERTIFIED OR IN U` is printed only if no OPEN and no BUDGET failure occurred.

**Proved by a successful run.** For every R ∈ J and every solution of Σ_m(R), the witness vector φ of Lemma W_J lies in U. For m ∉ {4, 5} there is no U, so Σ_m(R) has no solution.

**What `loc` proves (Lemma LOC of Appendix C §3.2, re-verified).**
- Each `CERT` line says that 𝒮(v, ι, e) = P̃₅(U; J) ∪ {e·n^ι·c_v ≥ e·c̄_{λ(v),ι} + δ₁} is infeasible. Its solution set lies inside that of P̃₅(U; J), so M = 7/2 applies. Lemma D′ needs no sign condition on h.
- If all 44 lines are CERT, then for every R ∈ J, every φ ∈ U ∩ Φ_A and every solution of P₅(φ; R), we have |(Qc_v)_ι − c̄_{λ(v),ι}| < δ₁ for all 11 centres v and both coordinates ι.
- Combining this with `glob` (U-leaves) and the transfer of §0.4: every configuration of the reduced counterexample class with split 5 has slice distance ‖z − z̄‖_∞ ≤ 2.7875·10⁻³ when δ₁ = 1.5·10⁻³, and ≤ 4.643·10⁻⁴ when δ₁ = 2.5·10⁻⁴. [Ed.: The run used δ₁ = 3/1000, giving ≤ 5.57947·10⁻³ < 7·10⁻³.]
- The same holds for m = 4, with U′ and λ′.

**Trusted base.** Exact Python integer and `Fraction` arithmetic, `math.isqrt`, the exact `Fraction(Decimal)` and `Fraction(float)` conversions, and correct execution of the program text. Decimal and float arithmetic only produce candidate points, and a non-finite float makes `Fraction` raise, which aborts the run. As in C2, no IEEE, libm or Decimal-rounding assumption enters.

**Sanity mode (not load-bearing).**
- SANITY-1: the cube U(η) must *not* certify at J. Melissen solves P₅(φ̄; R_*) with R_* ∈ J, so a certification there would expose a bug.
- SANITY-2: LOC with δ = 10⁻⁷ must stay open, because the solution set reaches ~Lη ≫ 10⁻⁷.
- SANITY-3: U(10⁻³) at R = r₁ should certify, reproducing C2's one-test certification.

### 3.3 How to run

[Ed.: The commands below are the planned ones; the commands actually run, with η = 1/1024 and δ₁ = 3/1000, are listed in Appendix G(b).]

From the directory holding `ms5_witness_m.py` (or with it on `PYTHONPATH`), with RLO = 2.63169077261980820552 and RHI = 2.631692:

```
# 0. sanity (minutes)
MSPLIT=5 python3 wit_exact_J.py sanity $RLO $RHI 1/4096
MSPLIT=4 python3 wit_exact_J.py sanity $RLO $RHI 1/4096
# 1. choose eta: proved upper bounds delta*(eta) for a few dyadic eta
MSPLIT=5 python3 wit_exact_J.py locscan $RLO $RHI 32 1/2048,1/4096,1/8192,1/32768
MSPLIT=4 python3 wit_exact_J.py locscan $RLO $RHI 32 1/2048,1/4096,1/8192,1/32768
# 2. LOC-coarse at the chosen (eta, delta1), e.g. eta = 1/4096, delta1 = 3/2000
MSPLIT=5 python3 wit_exact_J.py loc $RLO $RHI 44 1/4096 3/2000
MSPLIT=4 python3 wit_exact_J.py loc $RLO $RHI 44 1/4096 3/2000
# 3. GLOB
for m in 1 2 3 6 7 8; do MSPLIT=$m python3 wit_exact_J.py glob $RLO $RHI 32 4096 none; done
MSPLIT=5 python3 wit_exact_J.py glob $RLO $RHI 64 4096 1/4096 1/1000000000 3000
MSPLIT=4 python3 wit_exact_J.py glob $RLO $RHI 64 4096 1/4096 1/1000000000 3000
```

Expected (predictions, not runs):

- **sanity:** SANITY-1 open; SANITY-2 open; SANITY-3 cert; frame deviation ≈ 10⁻¹¹.
- **locscan:** δ*(η) ≈ L·η with L ≈ 4 (range 3–8). Cost: about 16 certification attempts per triple, each 1–5 s (float LM 200 steps of a 62 × 62 solve ≈ 1–3 s, plus Decimal ≈ 1 s), so 44 triples × 16 × 3 s ≈ 35 CPU-min per η, i.e. about 1–2 min wall-clock per η on 32 processes.
- **loc:** 44 tests of 1–5 s each.
- **glob, m ∉ {4, 5}:** the counts of C2 (4096 / 3272 / 824, possibly a few more boxes if some r₁-empty leaves stop being empty under the larger A, §4). Wall-clock 2.5–6 min on 4 processes.
- **glob, m ∈ {4, 5}:** see §3.4.


### 3.4, §4, §5, §6 [Ed.: omitted — see the note at the head of this appendix.]

# Appendix F. Helper module ms5_witness_m.py

[Ed.: Verbatim. Imported by wit_exact_J.py as W and used only for the index layout, the constraint list (re-checked at start-up against an independent transcription of Theorem C by check_constraints, which aborts on any mismatch) and to choose multipliers. Its own exact checker modes (R = 2.6317) are not used.]

```python
#!/usr/bin/env python3
"""Witness-angle branch and bound for the system Sigma_m (helper module, Appendix F).

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

import os
MSPLIT = int(os.environ.get("MSPLIT", "5"))   # split label m (E-run D_1..D_m); 5 = original
WID = 1e-15     # ASSUMED: |math.cos(t)-cos(t)|, |math.sin(t)-sin(t)| <= 1e-15 for |t| <= 8
M_BOUND = 3.5   # a-priori bound |x_v| <= 3.5 on the feasible set (Lemma M35 of Appendix A, Part W)
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
        X = NE if k <= MSPLIT else NF
        pairs += [(P(k), C(k)), (P(k), C(kp1)), (P(k), X)]
    pairs += [(T1, C(1)), (T1, NE), (T1, NF), (T6, C(MSPLIT + 1)), (T6, NE), (T6, NF)]
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

# Appendix G. The computations that were run, how to re-run them, and their outputs

Files: mid_cert.py = the program of Appendix D §5; wit_exact_J.py = the program of Appendix E §3, placed in one directory with ms5_witness_m.py (Appendix F); nb_check.py = the program of Appendix A, Appendix 1, with the diff of Appendix B §4 applied, and nb_par.py = the driver given there. Python 3.12, standard library only (the runs used `uv run --no-project python`, i.e. a plain CPython 3.12). Commands (RLO = 2.63169077261980820552, RHI = 2.631692):

```
python3 mid_cert.py
MSPLIT=5 python3 wit_exact_J.py sanity $RLO $RHI 1/4096      # likewise MSPLIT=4 (not load-bearing)
MSPLIT=5 python3 wit_exact_J.py locscan $RLO $RHI <nproc> 1/1024,1/2048   # likewise MSPLIT=4 (not load-bearing)
MSPLIT=5 python3 wit_exact_J.py loc $RLO $RHI 16 1/1024 3/1000        # likewise MSPLIT=4
for m in 1 2 3 6 7 8; do MSPLIT=$m python3 wit_exact_J.py glob $RLO $RHI 8 4096 none; done
MSPLIT=5 python3 wit_exact_J.py glob $RLO $RHI 24 4096 1/1024 1/1000000000 3000 3000000
MSPLIT=4 python3 wit_exact_J.py glob $RLO $RHI 8 4096 1/1024 1/1000000000 3000 3000000
NB_RLO=263169/100000 NB_RHI=1315846/500000 python3 nb_par.py 24
```

All four programs were run on CPython 3.12 under Linux. Programs MID and wit_exact_J.py use only exact rational arithmetic (fractions.Fraction, math.isqrt) for every load-bearing inequality. Floats and 60-digit Decimals are used only to choose multipliers and factors, which are then checked exactly.

**(a) mid_cert.py.** This is the program of Appendix D §5, extracted verbatim and run with no arguments. Its complete output is:

```
==== Part A: R_* > Rbar and the reference margins of Theorem A' (rho <= 7e-3) ====
[PASS] A0  Rbar < lower end of I_*  margin=1.50116e-21
[PASS] A1a |c1| <= 0.40  margin=0.0067504
[PASS] A1b |c2| <= 0.72  margin=0.00160772
[PASS] A1c 1.84 <= |c3| <= 2.35  margin=0.0011588
[PASS] A1c 1.84 <= |c4| <= 2.35  margin=0.0898752
[PASS] A1c 1.84 <= |c5| <= 2.35  margin=0.0898752
[PASS] A1c 1.84 <= |c6| <= 2.35  margin=0.164817
[PASS] A1c 1.84 <= |c7| <= 2.35  margin=0.164817
[PASS] A1c 1.84 <= |c8| <= 2.35  margin=0.00447325
[PASS] A1c 1.84 <= |c9| <= 2.35  margin=0.00447325
[PASS] A1c 1.84 <= |c10| <= 2.35  margin=0.189768
[PASS] A1c 1.84 <= |c11| <= 2.35  margin=0.189768
[PASS] A2  angle step (8,4): sin >= 0.57, cos >= 0.18  margin=0.0461411
[PASS] A2  angle step (4,3): sin >= 0.57, cos >= 0.18  margin=0.12702
[PASS] A2  angle step (3,5): sin >= 0.57, cos >= 0.18  margin=0.12702
[PASS] A2  angle step (5,9): sin >= 0.57, cos >= 0.18  margin=0.0461411
[PASS] A2  angle step (9,7): sin >= 0.57, cos >= 0.18  margin=0.0123895
[PASS] A2  angle step (7,11): sin >= 0.57, cos >= 0.18  margin=0.0839937
[PASS] A2  angle step (11,10): sin >= 0.57, cos >= 0.18  margin=0.107249
[PASS] A2  angle step (10,6): sin >= 0.57, cos >= 0.18  margin=0.0839937
[PASS] A2  angle step (6,8): sin >= 0.57, cos >= 0.18  margin=0.0123895
[PASS] A3  pair (8,4): |omega| >= 0.80 on |d| in [1.3742, 1.4138]  margin=0.198446
[PASS] A3  pair (4,3): |omega| >= 0.80 on |d| in [1.7157, 1.7553]  margin=0.0412951
[PASS] A3  pair (3,5): |omega| >= 0.80 on |d| in [1.7157, 1.7553]  margin=0.0412951
[PASS] A3  pair (5,9): |omega| >= 0.80 on |d| in [1.3742, 1.4138]  margin=0.198446
[PASS] A3  pair (9,7): |omega| >= 0.80 on |d| in [1.1674, 1.2070]  margin=0.14788
[PASS] A3  pair (7,11): |omega| >= 0.80 on |d| in [1.4408, 1.4804]  margin=0.195405
[PASS] A3  pair (11,10): |omega| >= 0.80 on |d| in [1.5506, 1.5902]  margin=0.164407
[PASS] A3  pair (10,6): |omega| >= 0.80 on |d| in [1.4408, 1.4804]  margin=0.195405
[PASS] A3  pair (6,8): |omega| >= 0.80 on |d| in [1.1674, 1.2070]  margin=0.14788
[PASS] A3  pair (1,2): |omega| >= 0.80 on |d| in [1.0918, 1.1314]  margin=0.114785
[PASS] A4  |Q_0| <= 1.70 (pair (8, 4))  margin=0.418945
[PASS] A4  |Q_1| <= 1.70 (pair (4, 3))  margin=0.0606741
[PASS] A4  |Q_2| <= 1.70 (pair (3, 5))  margin=0.0606741
[PASS] A4  |Q_3| <= 1.70 (pair (5, 9))  margin=0.418945
[PASS] A4  |Q_4| <= 1.70 (pair (9, 7))  margin=0.657785
[PASS] A4  |Q_5| <= 1.70 (pair (7, 11))  margin=0.424535
[PASS] A4  |Q_6| <= 1.70 (pair (11, 10))  margin=0.30675
[PASS] A4  |Q_7| <= 1.70 (pair (10, 6))  margin=0.424535
[PASS] A4  |Q_8| <= 1.70 (pair (6, 8))  margin=0.657785
[PASS] A5  tight corner Q_0 (pair (8, 4), X=2): distance >= 1.2 to disks [3, 5, 9, 7, 11, 10, 6, 1]  margin=0.358587
      info: |Q_0 - c_2| = 1.000000000000000 (should be 1), |P_0| = 2.631690772619808 (should be Rbar)
[PASS] A5  tight corner Q_1 (pair (4, 3), X=2): distance >= 1.2 to disks [8, 5, 9, 7, 11, 10, 6, 1]  margin=0.590855
      info: |Q_1 - c_2| = 1.000000000000000 (should be 1), |P_1| = 2.631690772619808 (should be Rbar)
[PASS] A5  tight corner Q_2 (pair (3, 5), X=2): distance >= 1.2 to disks [8, 4, 9, 7, 11, 10, 6, 1]  margin=0.590855
      info: |Q_2 - c_2| = 1.000000000000000 (should be 1), |P_2| = 2.631690772619808 (should be Rbar)
[PASS] A5  tight corner Q_3 (pair (5, 9), X=2): distance >= 1.2 to disks [8, 4, 3, 7, 11, 10, 6, 1]  margin=0.358587
      info: |Q_3 - c_2| = 1.000000000000000 (should be 1), |P_3| = 2.631690772619808 (should be Rbar)
[PASS] A5  tight corner Q_4 (pair (9, 7), X=1): distance >= 1.2 to disks [8, 4, 3, 5, 11, 10, 6, 2]  margin=0.229091
      info: |Q_4 - c_1| = 1.000000000000000 (should be 1), |P_4| = 2.631690772619808 (should be Rbar)
[PASS] A5  tight corner Q_6 (pair (11, 10), X=1): distance >= 1.2 to disks [8, 4, 3, 5, 9, 7, 6, 2]  margin=0.630676
      info: |Q_6 - c_1| = 1.000000000000000 (should be 1), |P_6| = 2.631690772619808 (should be Rbar)
[PASS] A5  tight corner Q_8 (pair (6, 8), X=1): distance >= 1.2 to disks [4, 3, 5, 9, 7, 11, 10, 2]  margin=0.229091
      info: |Q_8 - c_1| = 1.000000000000000 (should be 1), |P_8| = 2.631690772619808 (should be Rbar)
[PASS] A6a |t+| <= 0.9  margin=0.0529507
[PASS] A6b t+ at distance >= 1.2 from boundary centres other than c_8  margin=0.24702
      info: |t+ - c_8| = 1.000000000000000 (should be 1)
[PASS] A6a |t-| <= 0.9  margin=0.0529507
[PASS] A6b t- at distance >= 1.2 from boundary centres other than c_9  margin=0.24702
      info: |t- - c_9| = 1.000000000000000 (should be 1)
[PASS] A7  far points, pair (8,4): distance >= 1.2  margin=0.552708
[PASS] A7  far points, pair (4,3): distance >= 1.2  margin=1.0724
[PASS] A7  far points, pair (3,5): distance >= 1.2  margin=1.0724
[PASS] A7  far points, pair (5,9): distance >= 1.2  margin=0.552708
[PASS] A7  far points, pair (9,7): distance >= 1.2  margin=0.484886
[PASS] A7  far points, pair (7,11): distance >= 1.2  margin=0.768373
[PASS] A7  far points, pair (11,10): distance >= 1.2  margin=0.946609
[PASS] A7  far points, pair (10,6): distance >= 1.2  margin=0.768373
[PASS] A7  far points, pair (6,8): distance >= 1.2  margin=0.484886
==== Part B: lifted problem at the rational base point ====
[PASS] B0  58 unknowns
[PASS] B1  54 constraints (36 equalities, 18 inequalities)
      max |c_k(xbar)| equalities   = 1.546e-30
      max |g_i(xbar)| inequalities = 2.366e-20
      multipliers of the 18 inequalities (compare with the orchestrator float data):
        O1 (8, 4)          lambda = 0.029441
        O2 (4, 3)          lambda = 0.014038
        O3 (3, 5)          lambda = 0.014038
        O4 (5, 9)          lambda = 0.029441
        O5 (9, 7)          lambda = 0.024681
        O6 (7, 11)         lambda = 0.020808
        O7 (11, 10)        lambda = 0.012055
        O8 (10, 6)         lambda = 0.020808
        O9 (6, 8)          lambda = 0.024681
        I (8, 4) X=2       lambda = 0.016857
        I (4, 3) X=2       lambda = 0.004372
        I (3, 5) X=2       lambda = 0.004372
        I (5, 9) X=2       lambda = 0.016857
        I (9, 7) X=1       lambda = 0.074894
        I (11, 10) X=1     lambda = 0.026119
        I (6, 8) X=1       lambda = 0.074894
        T+                 lambda = 0.017376
        T-                 lambda = 0.017376
      sum of outer multipliers = 0.1899919, 1/(2 Rbar) = 0.1899919
[PASS] B2  all 18 inequality multipliers > 0  margin=0.00437213
      exact KKT residual: max|rhat_j| = 3.062e-17, eps_L = 1.501e-21
==== Part C: floating scan (selection of rho_A; not part of the proof) ====
      rho = 0.0005   best float lambda_min(G) = +2.2087e-02  (theta=1/2, mu_eq=10)   [1s]
      rho = 0.001    best float lambda_min(G) = +1.9678e-02  (theta=1/2, mu_eq=3)   [3s]
      rho = 0.0015   best float lambda_min(G) = +1.8290e-02  (theta=7/10, mu_eq=3)   [4s]
      rho = 0.002    best float lambda_min(G) = +1.7237e-02  (theta=7/10, mu_eq=3)   [6s]
      rho = 0.0025   best float lambda_min(G) = +1.5995e-02  (theta=7/10, mu_eq=3)   [7s]
      rho = 0.003    best float lambda_min(G) = +1.5135e-02  (theta=7/10, mu_eq=1)   [9s]
      rho = 0.0035   best float lambda_min(G) = +1.4510e-02  (theta=7/10, mu_eq=1)   [10s]
      rho = 0.004    best float lambda_min(G) = +1.3813e-02  (theta=7/10, mu_eq=1)   [12s]
      rho = 0.005    best float lambda_min(G) = +1.2197e-02  (theta=7/10, mu_eq=1)   [13s]
      rho = 0.006    best float lambda_min(G) = +1.0281e-02  (theta=7/10, mu_eq=1)   [15s]
      rho = 0.007    best float lambda_min(G) = +9.0408e-03  (theta=7/10, mu_eq=3/10)   [16s]
==== Part D: exact certification ====
      trying rho = 7/1000 (theta = 7/10, mu_eq = 3/10, float lambda_min = 9.0408e-03)
[PASS] D1  rho = 7/1000 <= 7e-3 (Theorem A' applies)
[PASS] D2  G >= kappa*I with kappa = 4.068342e-03  (||E||_F = 4.902e-15 <= kappa)  margin=0.00406834
[PASS] D3  tau = 8.591e-10 <= 2e-6  (eps1 = 1.501e-21)  margin=1.99914e-06
==== Summary ====
CERTIFIED: Theorem MID holds with rho_A = 7/1000 = 0.007 (orbit radius rho_A/2.01 = 0.00348259),
           theta = 7/10, mu_eq = 3/10, kappa = 4.068342e-03, tau = 8.591e-10
total time 16s
```

**(b) wit_exact_J.py.** This is the program of Appendix E §3, extracted verbatim. It is placed next to ms5_witness_m.py (Appendix F). Every run used RLO = 2.63169077261980820552 and RHI = 2.631692.

- `sanity` (m = 5 and m = 4, η = 1/4096):
  - frame deviation 1.22e-12; |c_E| = 0.3932 for m = 5 and 0.7184 for m = 4;
  - SANITY-1: open, OK (U is not certified at J, as it must not be);
  - SANITY-2: open, OK;
  - SANITY-3: cert_hp.
- `locscan` with η ∈ {1/1024, 1/2048}. These are proved upper bounds δ*(η) for δ_max. The ratio L = δ*/η:
  - m = 5: δ*(1/1024) = 2.4466e-3 (L = 2.505); δ*(1/2048) = 1.2368e-3 (L = 2.533);
  - m = 4: δ*(1/1024) = 2.4907e-3 (L = 2.550); δ*(1/2048) = 1.2417e-3 (L = 2.543).
- `loc $RLO $RHI 16 1/1024 3/1000`:
  - m = 5: frame-dev 1.22e-12, τ = 1331857233103593/281474976710656. All 44 lines CERT. "LOC RESULT MSPLIT=5 … eta=1/1024 delta=3/1000: ALL 44 CERTIFIED".
  - m = 4: "LOC RESULT MSPLIT=4 … eta=1/1024 delta=3/1000: ALL 44 CERTIFIED".
- `glob $RLO $RHI 8 4096 none`:
  - m = 1, 2, 3, 6, 7, 8: each run printed "EXACT RESULT J=[2.63169077261980820552,2.631692] MSPLIT=m: ALL BOXES EMPTY, CERTIFIED OR IN U (local=0, eta=none)".
  - Counts for m = 1: boxes = 4096, leaves = 4096 (3272 empty, 824 cert), splits = 0.
- `glob $RLO $RHI 24 4096 1/1024 1/1000000000 3000 3000000`, m = 5:
  - "EXACT RESULT J=[…] MSPLIT=5: ALL BOXES EMPTY, CERTIFIED OR IN U (local=154, eta=1/1024)";
  - counts: boxes = 17634, leaves = 10865, splits = 6769 (boxes − 2·splits = 4096 roots);
  - 3272 empty, 1418 cert, 6021 cert_hp, 154 local; no FAIL line and no DEEP log line;
  - the deepest non-local leaves (depth 60–69) all lie at ℓ∞-distance 10⁻⁴–10⁻³ from φ̄.
- m = 4, same command with 8 processes:
  - "EXACT RESULT J=[2.63169077261980820552,2.631692] MSPLIT=4: ALL BOXES EMPTY, CERTIFIED OR IN U (local=196, eta=1/1024)";
  - counts: boxes = 24582, leaves = 14339, splits = 10243 (boxes − 2·splits = 4096 roots);
  - 3272 empty, 2722 cert, 8149 cert_hp, 196 local;
  - no FAIL line and no DEEP log line.

**(c) C1_R.** nb_check.py of Appendix A (its Appendix 1), with the diff of Appendix B §4, driven by nb_par.py with 24 processes, NB_RLO = 263169/100000 and NB_RHI = 1315846/500000. It printed a = [0.3897786486051209, 0.38977896079906837], B = [0.1206842411790998, 0.12068976469677974] and 3−R = [0.368308, 0.36831]. All 24 slices were OK, taking between 5 s and 680 s each, and the run ended with "ALL CASES VERIFIED".
