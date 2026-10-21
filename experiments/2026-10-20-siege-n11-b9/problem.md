# Eleven unit disks, exactly nine of which meet the boundary circle

Notation. For c in the plane, D(c,1) is the closed unit disk centred at c. For R > 0, D_R = D(0,R) is the closed disk of radius R centred at the origin and S_R = {|z| = R} its boundary circle. A disk "meets" S_R if it has at least one point on S_R (tangency counts). Put

    r_1 = 26317/10000 = 2.6317.

**Claim to prove.** Let c_1, …, c_11 be eleven points of the plane (not necessarily distinct) and R > 0, and suppose

    D_R ⊆ D(c_1,1) ∪ D(c_2,1) ∪ … ∪ D(c_11,1),

and that exactly nine of the eleven disks D(c_i,1) meet S_R. Then R < r_1.

(Context, not part of the claim. The best known covering of a disk by eleven unit disks (Melissen) has radius R_* = 2.63169077261980820552…, and in it exactly nine disks meet S_R; so the claim is false with r_1 replaced by any number ≤ R_*, and the margin r_1 − R_* ≈ 9.2·10⁻⁶ is small. It is already proved that coverings in which ten disks meet S_R have R < 2.63169, and that at most ten disks can meet S_R when R > 2; so the claim, once proved, gives the upper bound 2.6317 for the largest disk that eleven unit disks can cover, against the lower bound R_*. A proof by hand, by a rigorous finite computation (exact or outward-rounded interval arithmetic), or by a combination is acceptable; any computation must be described precisely enough to be re-run. Facts F5 and F6 below are the results of such computations and may be used as stated.)

## Known facts that may be used

F1 (arc bounds). For R > 2, a closed disk of radius s < R meets S_R in a single arc of angular measure at most 2·arcsin(s/R). Hence a unit disk covers at most 2a(R) of S_R, a(R) = arcsin(1/R); a family of unit disks with a common point p lies in D(p,2) and covers at most 2d(R) of S_R, d(R) = arcsin(2/R). Both a and d decrease in R. At r_1: π − 8a(r_1) > 0.02337 (so eight disks never cover S_R) and 9a(r_1) − π > 0 (nine can).

F2 (structure). Assume R ≥ r_1 and the hypotheses. The origin lies in some disk D(c_i,1), so |c_i| ≤ 1 and that disk misses S_R. Call the nine disks that meet S_R the boundary disks; each has |c_i| ≥ R − 1. The two other disks are called inner disks; one of them contains the origin. (Moving a boundary centre with |c_i| > R radially onto S_R keeps the covering, so one may assume R − 1 ≤ |c_i| ≤ R for boundary disks.)

F3 (combinatorics on the circle, proved by hand). With R ≥ r_1 and A_1, …, A_9 the arcs cut on S_R by the boundary disks: since eight arcs cannot cover S_R, every arc has a private open sub-arc and no arc contains another; hence the arcs can be numbered cyclically so that both their start points and end points occur in that cyclic order; no point of S_R lies in three arcs; and only cyclically consecutive arcs intersect, every consecutive pair does intersect. Writing w_i ≤ a for the half-width of A_i, d_i = a − w_i and o_i ≥ 0 for the angular overlap of A_i and A_{i+1}: Σd_i + ½Σo_i = 9a − π. (This excludes triple coverage of points of S_R only, not three boundary disks meeting inside D_R.)

F4 (coarse global bound, computer-assisted). Every covering of the claim's type has R < 2.725.

F5 (reference configuration). Let c̄_1, …, c̄_11 and R̄ be the following decimals (each a rational approximation, to 20 digits, of the exact Melissen critical configuration c_*, R_*):
    c̄_1 = (0, −0.39324960179250027086)     c̄_2 = (0, 0.71839227931685877597)
    c̄_3 = (0, 2.34884120097565953729)
    c̄_4 = ( 1.57535264004342806580, 1.62062588642691912838)   c̄_5 = (−c̄_4.x, c̄_4.y)
    c̄_6 = ( 1.77273616280974093118, −0.93632239910290244643)  c̄_7 = (−c̄_6.x, c̄_6.y)
    c̄_8 = ( 1.82750955295212993964, 0.24958048504283922431)   c̄_9 = (−c̄_8.x, c̄_8.y)
    c̄_10 = (0.78521708246826346764, −2.01247018720615423819)  c̄_11 = (−c̄_10.x, c̄_10.y)
    R̄ = 2.63169077261980820552.
(Disks 1, 2 are the inner disks; 3–11 are the boundary disks.) The exact configuration c_* covers D(0, R_*), and each listed decimal is within 10⁻²⁰ of the corresponding exact value.

F6 (local optimality, computer-assisted). If eleven unit disks cover D_R with R ≥ R̄ − 10⁻⁷, and after some rotation or reflection of the plane about the origin and some relabelling, nine of the centres satisfy |x(c_i) − x(c̄_i)| ≤ 8·10⁻⁹ and |y(c_i) − y(c̄_i)| ≤ 8·10⁻⁹ for i = 3, …, 11 (the other two centres arbitrary), then R ≤ R_* < r_1. Consequently, to prove the claim it suffices to show that every covering of the claim's type with R ≥ r_1 has, after a rotation or reflection about the origin and a relabelling, nine of its centres within 8·10⁻⁹ (coordinatewise) of c̄_3, …, c̄_11: F6 then gives R ≤ R_* < r_1, a contradiction.
