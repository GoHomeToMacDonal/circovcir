# Eleven unit disks, exactly nine of which meet the boundary circle: the sharp bound

Notation. For c in the plane, D(c,1) is the closed unit disk centred at c. For R > 0, D_R = D(0,R) is the closed disk of radius R centred at the origin and S_R = {|z| = R} its boundary circle. A disk "meets" S_R if it has at least one point on S_R (tangency counts). Let c_*, R_* be the exact Melissen critical configuration and its covering radius (see F5); R_* lies in the rational interval

    I_* = [2.6316907726198082055215011595056961051671168478238, 2.6316907726198082055215011595056961051671168478239].

Put r_1 = 26317/10000 = 2.6317 and r_0 = 263169/100000 = 2.63169 (so r_0 < R_* < r_1, r_1 − R_* ≈ 9.227·10⁻⁶).

**Claim to prove.** Let c_1, …, c_11 be eleven points of the plane (not necessarily distinct) and R > 0, and suppose

    D_R ⊆ D(c_1,1) ∪ D(c_2,1) ∪ … ∪ D(c_11,1),

and that exactly nine of the eleven disks D(c_i,1) meet S_R. Then R ≤ R_*.

(Context, not part of the claim. Melissen's covering itself has exactly nine disks meeting S_{R_*}, so R_* cannot be lowered: the claim is the sharp form. The weaker bound R < r_1 is already proved (F7). Together with F8 the claim gives that R_* is the largest radius of a disk coverable by eleven unit disks. A proof by hand, by a rigorous finite computation (exact or outward-rounded interval arithmetic), or by a combination is acceptable; any computation must be described precisely enough to be re-run. Facts F4–F8 are results of such computations, or of earlier proofs, and may be used as stated.)

## Known facts that may be used

F1 (arc bounds). For R > 2, a closed disk of radius s < R meets S_R in a single arc of angular measure at most 2·arcsin(s/R). Hence a unit disk covers at most 2a(R) of S_R, a(R) = arcsin(1/R); a family of unit disks with a common point p lies in D(p,2) and covers at most 2d(R) of S_R, d(R) = arcsin(2/R). Both a and d decrease in R. At R_*: π − 8a(R_*) > 0.02336 (so eight disks never cover S_R for R ≥ R_*; indeed for every R > 1/sin(π/8) ≈ 2.61313) and 9a(R_*) − π > 0.3664.

F2 (structure). Assume R ≥ R_* and the hypotheses. The origin lies in some disk D(c_i,1), so |c_i| ≤ 1 and that disk misses S_R. Call the nine disks that meet S_R the boundary disks; each has |c_i| ≥ R − 1. The two other disks are called inner disks; one of them contains the origin. (Moving a boundary centre with |c_i| > R radially onto S_R keeps the covering, so one may assume R − 1 ≤ |c_i| ≤ R for boundary disks.)

F3 (combinatorics on the circle, proved by hand). With R ≥ R_* and A_1, …, A_9 the arcs cut on S_R by the boundary disks: since eight arcs cannot cover S_R, every arc has a private open sub-arc and no arc contains another; hence the arcs can be numbered cyclically so that both their start points and end points occur in that cyclic order; no point of S_R lies in three arcs; and only cyclically consecutive arcs intersect, every consecutive pair does intersect. Writing w_i ≤ a for the half-width of A_i, d_i = a − w_i and o_i ≥ 0 for the angular overlap of A_i and A_{i+1}: Σd_i + ½Σo_i = 9a − π. (This excludes triple coverage of points of S_R only, not three boundary disks meeting inside D_R.)

F4 (ten boundary disks). (i) When R > 2, at most ten of eleven unit disks covering D_R meet S_R. (ii) Every covering of D_R by eleven unit disks in which exactly ten disks meet S_R has R < r_0 = 2.63169 < R_*. (Computer-assisted; hand reduction pending independent review.)

F5 (reference configuration). Let c̄_1, …, c̄_11 and R̄ be the following decimals (each a rational approximation, to 20 digits, of the exact Melissen critical configuration c_*, R_*):
    c̄_1 = (0, −0.39324960179250027086)     c̄_2 = (0, 0.71839227931685877597)
    c̄_3 = (0, 2.34884120097565953729)
    c̄_4 = ( 1.57535264004342806580, 1.62062588642691912838)   c̄_5 = (−c̄_4.x, c̄_4.y)
    c̄_6 = ( 1.77273616280974093118, −0.93632239910290244643)  c̄_7 = (−c̄_6.x, c̄_6.y)
    c̄_8 = ( 1.82750955295212993964, 0.24958048504283922431)   c̄_9 = (−c̄_8.x, c̄_8.y)
    c̄_10 = (0.78521708246826346764, −2.01247018720615423819)  c̄_11 = (−c̄_10.x, c̄_10.y)
    R̄ = 2.63169077261980820552.
(Disks 1, 2 are the inner disks; 3–11 are the boundary disks.) The exact configuration c_* covers D(0, R_*), and each listed decimal is within 10⁻²⁰ of the corresponding exact value. c_* is a strict local maximum of the covering radius modulo rotation (computer-assisted, Krawczyk + second-order sufficient conditions).

F6 (local optimality, nine-centre form, computer-assisted). If eleven unit disks cover D_R with R ≥ R̄ − 10⁻⁷, and after some rotation or reflection of the plane about the origin and some relabelling, nine of the centres satisfy |x(c_i) − x(c̄_i)| ≤ 8·10⁻⁹ and |y(c_i) − y(c̄_i)| ≤ 8·10⁻⁹ for i = 3, …, 11 (the other two centres arbitrary), then R ≤ R_*.

F6′ (local optimality, full-box form, computer-assisted). Write z = (c_1, …, c_11, R) ∈ ℝ²³ and z̄ for the vector of the F5 decimals. If eleven unit disks cover D_R and, after some rotation or reflection about the origin and some relabelling, x(c_3) = 0 and ‖z − z̄‖_∞ ≤ 1/500000, then R ≤ R_* − (7/1000)‖z − z_*‖² (in particular R ≤ R_*), where z_* is the exact critical vector.

F7 (the coarse b = 9 bound, already proved). Every covering of the claim's type has R < r_1 = 2.6317. (Hand proof plus two finite computations, checked by two independent implementations; hand proof pending independent review.) Its complete written proof is the document /home/skim/projects/research/circovcir/experiments/2026-10-20-siege-n11-b9/proof.md, whose lemmas may be quoted where their hypotheses hold. Outline of that proof: reduce to R = r_1 with all nine boundary centres on the inner branch R − 1 ≤ |c_k| ≤ √(R² − 1); prove the No-Bridge theorem D_j ∩ D_{j+2} = ∅ (hand proof + interval computation); deduce that the uncovered hole is bounded by nine arcs through the inner corners q_1, …, q_9 of consecutive boundary disks, that the corners in the inner disk E ∋ 0 form a cyclic interval and the rest lie in the second inner disk F, and that each transition disk meets E ∩ F; hence the configuration solves an explicit system Σ_m for a split label m ∈ {1, …, 8}; fixing eight angles φ makes every remaining constraint convex (a second-order-cone system P_m(φ)), and an exact-rational box cover of the φ-polytope with dual infeasibility certificates excludes every m at R = r_1. Several of those lemmas are proved only at R = r_1, with numerical margins; at R close to R_*, near the Melissen configuration (split 5/4), the box certificates necessarily degenerate, because c_* is feasible at R_*.

F8 (ten boundary disks and the full problem). By F2/F4, for R ≥ R_* a covering of D_R by eleven unit disks has exactly nine or exactly ten disks meeting S_R, and the ten case is impossible; so the claim is equivalent to: no eleven unit disks cover D_R for any R > R_*.
