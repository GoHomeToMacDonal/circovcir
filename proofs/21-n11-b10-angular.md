# 21 — n=11：恰 10 圆碰目标圆周的覆盖不可能达到 r₀（(B10) 闭合）

日期：2026-10-20。来源：math-proof siege 运行 `experiments/2026-10-20-siege-n11-b10/`（4 轮，判官+工作者子代理；运行本身按 AGENTS §4 为 L0），随后用本仓库工具独立复核。

**定理.** 11 个闭单位圆盘覆盖 D(0,R) 且恰有 10 个圆盘与圆周 |z|=R 相交（相切计入），则 R < r₀ = 263169/100000。圆心可重合、可在任意位置；不用 Voronoi 结构。

**等级.**
- Lemma L（每圆盘不等式）：**L3 计算**，两份独立实现——`certificates/21a-n11-b10-lemL.wls`（WL `Interval` 外向舍入，精确有理盒端点与参数，exit 0，38 行全 OK，58376 盒；负对照 λ=0.5 失败）与 `certificates/21b-n11-b10-lemL.py`（binary64 + 64 ulp 外推，依赖 libm acos/asin 误差 <~30 ulp；ALL OK 58376 盒，13.5 s）。
- §1–§3 归约（Lemma A、两条加权覆盖不等式、Lemma Θ、Proposition D）：手证；siege 内两次独立核验 + 终稿核验无误，本人逐步复读未见缺口；**待人工复核**后升 L4。
- **不是** n=11 最优性：b=9 情形（含 Melissen 构型）不在本定理内。

**思路一句话.** 外 10 圆必须同时覆盖目标圆周 S_R 和以 c₀ 为心、半径 ρ↓1 的小圆（后者加非负三角权 w=1−k cos β+j cos 2β）；两条角度不等式的凸组合把问题化为单圆盘不等式 F_e(r,s) < π/10（三变量），再按 e=|c₀|∈[0,0.3684] 分 38 行做区间 B&B。

**对 STATE 的影响.** `proofs/20` §14 定理 S 的 (B10) 已闭合；n=11 最优性与镜像对称性只剩 (G2-b9)。原计划的 (B10) 混合 B&B（§15–16）不再需要。

---

## 附：完整证明（siege 终稿原文，英文）

# Eleven unit disks, exactly ten meeting the boundary circle: R < r_0

## Theorem

Let c_0, …, c_10 ∈ ℝ² (not necessarily distinct) and R > 0 with D_R ⊆ ⋃_{i=0}^{10} D(c_i,1), and suppose exactly ten of the disks D(c_i,1) meet S_R. Then R < r_0 = 263169/100000.

The proof is by contradiction: assume R ≥ r_0. Two circles that the ten "outer" disks have to cover give two angular covering inequalities. The first is the limit of the circles |z − c_0| = ρ as ρ ↓ 1, taken with a nonnegative trigonometric weight; the second is S_R, taken with uniform weight. A convex combination of the two reduces everything to one per-disk inequality in three real variables (Lemma L). An outward-rounded interval branch-and-bound proves Lemma L; §4 gives the program in full along with its output. The proof does not use Voronoi structure, distinctness of centres, or counts of arcs.

Notation: φ(s) = arccos(min(s,2)/2) for s > 0; a(R) = arcsin(1/R); clamp(x) = max(−1, min(1, x)).

## 1. Standing reductions

Assume R ≥ r_0 (> 2) and the hypotheses.

1.1 (Labelling, F2.) The point 0 ∈ D_R is covered, so some disk contains 0. Its centre has modulus ≤ 1, so all its points have modulus ≤ 2 < R and it misses S_R. Exactly one disk misses S_R, so this disk is that one. Call it D(c_0,1) and put e := |c_0| ≤ 1. The other ten disks meet S_R, so each contains a point of modulus R, and therefore r_i := |c_i| ≥ R − 1 (i = 1..10).

1.2 (Projection.) Suppose |c_i| > R for some i ≥ 1. Replace c_i by c_i' = R c_i/|c_i| and let u = c_i/|c_i|. The perpendicular bisector of c_i and c_i' is the line {x·u = (|c_i|+R)/2}. Every x ∈ D_R has x·u ≤ R < (|c_i|+R)/2, so x lies on the side of c_i' and |x − c_i'| ≤ |x − c_i|. Hence D(c_i,1) ∩ D_R ⊆ D(c_i',1) and the covering survives. From here on only the following facts are used:

  (S) D_R ⊆ ⋃_{i=0}^{10} D(c_i,1), e = |c_0| ≤ 1, R − 1 ≤ r_i ≤ R (i = 1..10), R ≥ r_0.

Rotate so that c_0 = (e, 0). Put s_i := |c_i − c_0|, and let ψ_i be the direction of c_i − c_0 as seen from c_0.

1.3 Lemma A. e ≤ 3 − R ≤ 3 − r_0 = 0.36831.
Proof. Let |x| < R − 2. For i ≥ 1, |x − c_i| ≥ r_i − |x| > (R−1) − (R−2) = 1, so x lies in no outer disk. Since x ∈ D_R, it lies in D(c_0,1). Take x_t = −t·(1,0) with 0 ≤ t < R − 2. Then |x_t − c_0| = e + t ≤ 1, and letting t → R − 2 gives e + R − 2 ≤ 1. ∎
Consequences: R ≤ 3 − e; s_i ≥ r_i − e ≥ (R−1) − (3−R) = 2R − 4 ≥ 1.26338 > 1; R − e ≥ 2R − 3 > 1.

## 2. Covering inequalities

Lemma B (arc cut by a unit disk). Let Γ be the circle with centre p and radius ρ > 0, and let c be a point at distance σ > 0 from p, in direction ψ. The point p + ρ(cos β, sin β) lies in D(c,1) iff σ² + ρ² − 2σρ cos(β − ψ) ≤ 1, i.e. iff cos(β − ψ) ≥ q := (σ²+ρ²−1)/(2σρ). So D(c,1) ∩ Γ is the closed arc |β − ψ| ≤ ω, where ω = arccos(clamp(q)); it is empty or a single point if q ≥ 1. In every use below q > 0, so ω ≤ π/2.

Lemma C (weighted covering). Let closed arcs I_1, …, I_n cover a circle (parameter β ∈ [0, 2π)) and let w ≥ 0 be integrable. Then ∫_0^{2π} w ≤ Σ_i ∫_{I_i} w, because 1 ≤ Σ_i 1_{I_i} pointwise and w ≥ 0. (This is the only place where w ≥ 0 is used, and it is essential there.)

Weighted-arc identity. Let w(β) = 1 − k cos β + j cos 2β. For the arc of half-width ω about ψ,
  ½∫_{ψ−ω}^{ψ+ω} w dβ = ω − k sin ω cos ψ + (j/2) sin 2ω cos 2ψ,  and ½∫_0^{2π} w = π.

2.1 Inner constraint. Let 1 < ρ ≤ R − e and Γ_ρ = {|z − c_0| = ρ}. Each z ∈ Γ_ρ has |z| ≤ e + ρ ≤ R, so z ∈ D_R, and |z − c_0| > 1, so z ∉ D(c_0,1). Hence the ten outer disks cover Γ_ρ. By Lemma B (p = c_0, σ = s_i > 1, so q > 0), disk i cuts Γ_ρ in an arc of half-width ω_i(ρ) = arccos(clamp((s_i²+ρ²−1)/(2s_iρ))) centred at ψ_i. Fix (k, j) such that w ≥ 0 on ℝ. Lemma C and the identity give Σ_i [ω_i(ρ) − k sin ω_i(ρ) cos ψ_i + (j/2) sin 2ω_i(ρ) cos 2ψ_i] ≥ π. Every term is continuous in ρ on (1, R−e] and has a limit as ρ ↓ 1: as ρ ↓ 1, ω_i(ρ) → arccos(clamp(s_i/2)) = φ(s_i). (The limit is needed because Γ_1 itself lies inside D(c_0,1).) Hence

  (Inner) Σ_{i=1}^{10} I(r_i, s_i) ≥ π,  I := φ(s) − k sin φ(s) cos ψ + (j/2) sin 2φ(s) cos 2ψ.

If s ≥ 2 then φ = 0 and I = 0. If s ≤ 2 then sin φ = √(1 − s²/4) and sin 2φ = s√(1 − s²/4). The law of cosines, r_i² = e² + s_i² + 2es_i cos ψ_i, gives cos ψ_i = (r_i² − s_i² − e²)/(2es_i) for e > 0, and cos 2ψ = 2cos²ψ − 1. So I depends only on (e, r, s). When k = j = 0, I = φ(s) and e = 0 is allowed. For e > 0 and admissible (r, s) (see 2.3) we have r ≥ r_0 − 1 > e, so |s − e| ≤ r ≤ s + e and the formula for cos ψ lies in [−1, 1].

2.2 Outer constraint. D(c_0,1) ⊆ D(0, 1+e) ⊆ D(0,2) misses S_R, so the outer disks cover S_R. Lemma B with p = 0, ρ = R, σ = r_i ∈ [R−1, R] gives half-widths θ_R(r_i) = arccos(q_R(r_i)), where q_R(r) = (r²+R²−1)/(2rR) ∈ (0, 1]; q_R ≤ 1 holds because (R−r)² ≤ 1. With w ≡ 1:

  (Outer) Σ_{i=1}^{10} θ_R(r_i) ≥ π.

Let r_c := √(r_0² − 1) = 2.43349…. Define Θ(r) := θ_{r_0}(r) for r_0 − 1 ≤ r ≤ r_c and Θ(r) := a(r_0) for r ≥ r_c.

Lemma Θ. (i) θ_R(r) ≤ Θ(r) whenever R ≥ r_0 and r ∈ [R−1, R]. (ii) Θ is continuous and nondecreasing on [r_0 − 1, ∞), and Θ ≤ a(r_0).
Proof. (i) Case r ≤ r_c. For R' ≥ r_0, ∂q_{R'}(r)/∂R' = (R'² − r² + 1)/(2rR'²) > 0, because r ≤ r_c < r_0 ≤ R'. Hence q_R(r) ≥ q_{r_0}(r) > 0. Also q_{r_0}(r) ≤ 1, since r_0 − 1 ≤ R − 1 ≤ r ≤ r_c < r_0. As arccos is decreasing, θ_R(r) ≤ θ_{r_0}(r). Case r ≥ r_c. The arc's two endpoints lie in D(c_i,1), so its chord satisfies 2R sin θ_R ≤ 2. Since θ_R ≤ π/2, this gives θ_R ≤ arcsin(1/R) ≤ a(r_0). (ii) ∂q_{r_0}/∂r = (r² − r_c²)/(2r_0r²) < 0 for r < r_c, so θ_{r_0} increases on [r_0 − 1, r_c]. At r_c, q = r_c/r_0 = √(1 − 1/r_0²), so θ_{r_0}(r_c) = a(r_0) and Θ is continuous there; beyond r_c it is constant. ∎

(Note: θ_{r_0} decreases for r > r_c. So the cap is necessary, and any machine lower bound for r_c must really be ≤ r_c.)

2.3 Proposition D (combination). Let λ ∈ [0,1] and let k, j be such that w = 1 − k cos β + j cos 2β ≥ 0 for all β. Put F_e(r,s) := λ I_e(r,s) + (1−λ) Θ(r) and A_e := {(r,s) : r_0 − 1 ≤ r ≤ 3 − e, |r − s| ≤ e}. Under (S), every (r_i, s_i) ∈ A_e: r_i ∈ [R−1, R] ⊆ [r_0−1, 3−e] by Lemma A, and |r_i − s_i| ≤ |c_0| = e by the triangle inequality. Taking λ·(Inner) + (1−λ)·(Outer) and applying Lemma Θ(i) gives Σ_{i=1}^{10} F_e(r_i, s_i) ≥ π. Therefore: if F_e < π/10 on all of A_e, no configuration with |c_0| = e exists.

## 3. Lemma L and the conclusion

Lemma L. For every e ∈ [0, 0.3684] (⊇ [0, 3 − r_0]), take the row (e_a, e_b, λ, k, j) of the table below with e ∈ [e_a, e_b]; the decimal literals are read as IEEE binary64 values. Then 0 ≤ λ ≤ 1, w = 1 − k cos β + j cos 2β ≥ 0 on ℝ, and F_e(r,s) < π/10 for all (r,s) ∈ A_e.

```
 e_a   e_b    λ      k      j       |  e_a   e_b    λ      k      j
0     0.005 0.21   0      0         | 0.185 0.195 0.2267 0.9021 0.2062
0.005 0.015 0.2065 0.0507 -0.0101   | 0.195 0.205 0.2313 0.9091 0.2007
0.015 0.025 0.2066 0.0995 -0.0084   | 0.205 0.215 0.2316 0.9566 0.2193
0.025 0.035 0.2147 0.1373 -0.0078   | 0.215 0.225 0.2364 0.9769 0.2326
0.035 0.045 0.2085 0.1939 -0.0027   | 0.225 0.235 0.2401 1.034  0.2795
0.045 0.055 0.208  0.241  0.0043    | 0.235 0.245 0.239  1.0748 0.2851
0.055 0.065 0.2151 0.2771 0.0082    | 0.245 0.255 0.2393 1.1103 0.2939
0.065 0.075 0.2092 0.3401 0.0155    | 0.255 0.265 0.2401 1.1894 0.3485
0.075 0.085 0.21   0.3837 0.0227    | 0.265 0.275 0.2473 1.1833 0.3553
0.085 0.095 0.2178 0.4135 0.0314    | 0.275 0.285 0.2457 1.2576 0.3913
0.095 0.105 0.2208 0.4592 0.0516    | 0.285 0.295 0.2504 1.2857 0.4197
0.105 0.115 0.2139 0.5211 0.0553    | 0.295 0.305 0.2579 1.2879 0.4392
0.115 0.125 0.2169 0.5675 0.0675    | 0.305 0.315 0.2576 1.3238 0.4503
0.125 0.135 0.2157 0.6247 0.0827    | 0.315 0.325 0.2619 1.3633 0.4854
0.135 0.145 0.2186 0.6632 0.1015    | 0.325 0.335 0.2719 1.3201 0.4774
0.145 0.155 0.2211 0.7008 0.1122    | 0.335 0.345 0.2644 1.4002 0.4958
0.155 0.165 0.221  0.756  0.1319    | 0.345 0.355 0.2719 1.3954 0.5128
0.165 0.175 0.2281 0.7444 0.1207    | 0.355 0.365 0.2831 1.387  0.5304
0.175 0.185 0.2269 0.8281 0.1646    | 0.365 0.3684 0.2831 1.387 0.5304
```

The proof of Lemma L is the computation in §4.

Proof of the Theorem. Assume R ≥ r_0. By §1, (S) holds and, by Lemma A, e = |c_0| ∈ [0, 0.36831]. Take the row of Lemma L containing e. By Proposition D, Σ_{i=1}^{10} F_e(r_i,s_i) ≥ π with every (r_i, s_i) ∈ A_e. By Lemma L every term is < π/10, so the sum is < π, a contradiction. Hence R < r_0. ∎

## 4. Certification of Lemma L

### 4.1 Mathematical facts used by the program
- Θ is nondecreasing on [r_0 − 1, ∞) (Lemma Θ(ii)). So for a box r ∈ [r_1, r_2], the value Θ(r_2) bounds Θ at every admissible r in the box. If r_2 < r_0 − 1, the box has no admissible point and whatever the program computes for it is irrelevant.
- φ(s) and sin φ(s) = √(1 − min(s,2)²/4) are nonincreasing in s. For s ≤ 2, sin 2φ = s√(1 − s²/4); for s ≥ 2, φ = sin φ = sin 2φ = 0 and I = 0.
- At admissible points cos ψ ∈ [−1, 1] (§2.1). So the enclosure may be intersected with [−1, 1], and an empty intersection proves the box has no admissible point.
- Nonnegativity of w. With x = cos β ∈ [−1, 1], w = (1−j) − kx + 2jx². Its minimum on [−1, 1] is min(1+j−k, 1+j+k), except when j > 0 and |k| ≤ 4j: then the vertex value 1 − j − k²/(8j) is also a candidate. (For j ≤ 0 the function is concave or linear, so the minimum is at an endpoint.) The function `weight_nonneg` evaluates this in exact rationals of the binary64 parameters.
- Domain. For e ∈ [e_a, e_b], A_e ⊆ [r_lo, r_hi] × [s_lo, s_hi] with r_lo ≤ r_0 − 1, r_hi ≥ 3 − e_a, s_lo ≤ r_lo − e_b and s_hi ≥ r_hi + e_b. The rows chain exactly: the first starts at 0, consecutive endpoints are identical floats (asserted), and the last ends at 0.3684 > 3 − r_0.
- The first row has k = j = 0, so ψ is never used and e = 0 is allowed. Every other row has e_a ≥ 0.005 > 0, so the division by 2es is legitimate.

### 4.2 Enclosures (validity of the program)
Floating-point model: IEEE-754 binary64 (CPython floats), correctly rounded + − × / and sqrt, and `math.nextafter` (Python ≥ 3.9).

Every computed quantity is moved outward by N = 64 nextafter steps (`dn`/`up`). A correctly rounded operation errs by at most ½ ulp, and N steps move by at least N/2 ulp even across a binade boundary, so `dn(fl(x∘y)) ≤ x∘y ≤ up(fl(x∘y))`. For libm `acos` and `asin` (not correctly rounded) the same widening covers any error below about 30 ulp, far beyond the accuracy of standard libms. `mul`, `add`, `sub`, `sq` and `div` (which asserts a positive denominator) are therefore valid inclusion functions. Division and multiplication by 2 and 4 are exact.

Specific constants:
- R0LO ≤ r_0 ≤ R0HI is checked by an exact `Fraction` assert.
- `math.pi` < π, so PI10_LO = dn(fl(math.pi/10)) < π/10.
- RC_LO ≤ r_c is required (see the note after Lemma Θ) and holds. The code computes dn(fl(fl(R0LO·R0LO) − 1)): R0LO ≤ r_0, the two roundings (both in the binade [4, 8)) err by at most 1 ulp in total, far below the 64-ulp push-down, so the argument of sqrt is ≤ r_0² − 1; sqrt is correctly rounded and the result is again pushed down by 64 ulp.
- For r ≥ RC_LO the program returns A_HI = up(asin(up(1/R0LO))) ≥ a(r_0) ≥ Θ(r). For r < RC_LO ≤ r_c it returns min(A_HI, up(acos(q))), where q ≤ q_{r_0}(r) because the numerator is rounded down using R0LO² ≤ r_0² and the denominator is rounded up using R0HI ≥ r_0.

The φ, sin φ and sin 2φ enclosures follow from monotonicity in s. When s_2 ≥ 2 the lower ends are ≤ 0, so the true value 0 for s ∈ [2, s_2] is enclosed. The cos ψ and cos 2ψ enclosures use interval arithmetic followed by the legitimate clamp. In the final bound, λ ≥ 0, up(1−λ) ≥ 1−λ ≥ 0 and Θ ≥ 0. Hence Fhi(box) ≥ F_e(r,s) at every admissible (e,r,s) in the box.

Branch and bound. A box is handled in one of four ways:
- (a) discarded by the geometric test `s_1 > up(r_2+e_2)` or `s_2 < dn(r_1−e_2)`. This is sound in every rounding mode, because an admissible point satisfies r − e ≤ s ≤ r + e;
- (b) certified because Fhi < PI10_LO;
- (c) discarded because the cos ψ enclosure is empty;
- (d) bisected along its widest coordinate (e-width weighted ×4) at the float midpoint; the two closed halves cover the box.

The run fails if a box narrower than 10⁻⁷ is reached or more than 10⁷ boxes are visited. So "OK" for a row means the leaves cover the root box and each is of type (a), (b) or (c). That is, F_e < π/10 on A_e for every e in the row.

### 4.3 The program (Python 3, standard library only; run with `python3 lemL.py`)
```python
# Rigorous (outward-rounded) branch-and-bound check of Lemma L(e) for e in [0, 0.3684].
# For each e-interval [ea,eb] with parameters (lam,k,j) it proves
#   F(e,r,s) = lam*I + (1-lam)*Theta(r) < pi/10
# on {(e,r,s): ea<=e<=eb, r0-1<=r<=3-e, |r-s|<=e}, where
#   I = phi - k*sin(phi)*cos(psi) + (j/2)*sin(2phi)*cos(2psi), phi=acos(min(s,2)/2),
#   cos(psi) = (r^2-s^2-e^2)/(2es) (clamped to [-1,1]),
#   Theta(r) = acos((r^2+r0^2-1)/(2 r r0)) for r<=sqrt(r0^2-1), = asin(1/r0) beyond (increasing in r).
# Outward rounding: every float operation result is widened by 64 ulps (math.nextafter);
# libm acos/asin are assumed accurate to well under 30 ulp (sqrt is correctly rounded by IEEE 754).
import math
from fractions import Fraction as Fr
PARAMS = [  # (ea, eb, lam, k, j)
(0,0.005,0.21,0.0,0.0),(0.005,0.015,0.2065,0.0507,-0.0101),(0.015,0.025,0.2066,0.0995,-0.0084),
(0.025,0.035,0.2147,0.1373,-0.0078),(0.035,0.045,0.2085,0.1939,-0.0027),(0.045,0.055,0.208,0.241,0.0043),
(0.055,0.065,0.2151,0.2771,0.0082),(0.065,0.075,0.2092,0.3401,0.0155),(0.075,0.085,0.21,0.3837,0.0227),
(0.085,0.095,0.2178,0.4135,0.0314),(0.095,0.105,0.2208,0.4592,0.0516),(0.105,0.115,0.2139,0.5211,0.0553),
(0.115,0.125,0.2169,0.5675,0.0675),(0.125,0.135,0.2157,0.6247,0.0827),(0.135,0.145,0.2186,0.6632,0.1015),
(0.145,0.155,0.2211,0.7008,0.1122),(0.155,0.165,0.221,0.756,0.1319),(0.165,0.175,0.2281,0.7444,0.1207),
(0.175,0.185,0.2269,0.8281,0.1646),(0.185,0.195,0.2267,0.9021,0.2062),(0.195,0.205,0.2313,0.9091,0.2007),
(0.205,0.215,0.2316,0.9566,0.2193),(0.215,0.225,0.2364,0.9769,0.2326),(0.225,0.235,0.2401,1.034,0.2795),
(0.235,0.245,0.239,1.0748,0.2851),(0.245,0.255,0.2393,1.1103,0.2939),(0.255,0.265,0.2401,1.1894,0.3485),
(0.265,0.275,0.2473,1.1833,0.3553),(0.275,0.285,0.2457,1.2576,0.3913),(0.285,0.295,0.2504,1.2857,0.4197),
(0.295,0.305,0.2579,1.2879,0.4392),(0.305,0.315,0.2576,1.3238,0.4503),(0.315,0.325,0.2619,1.3633,0.4854),
(0.325,0.335,0.2719,1.3201,0.4774),(0.335,0.345,0.2644,1.4002,0.4958),(0.345,0.355,0.2719,1.3954,0.5128),
(0.355,0.365,0.2831,1.387,0.5304),(0.365,0.3684,0.2831,1.387,0.5304)]
def dn(x,n=64):
    for _ in range(n): x=math.nextafter(x,-math.inf)
    return x
def up(x,n=64):
    for _ in range(n): x=math.nextafter(x,math.inf)
    return x
def mul(a,b):
    p=[a[0]*b[0],a[0]*b[1],a[1]*b[0],a[1]*b[1]]; return (dn(min(p)),up(max(p)))
def add(a,b): return (dn(a[0]+b[0]),up(a[1]+b[1]))
def sub(a,b): return (dn(a[0]-b[1]),up(a[1]-b[0]))
def sc(k,a): return mul((k,k),a)
def sq(a):
    lo,hi=a
    if lo>=0: return (dn(lo*lo),up(hi*hi))
    if hi<=0: return (dn(hi*hi),up(lo*lo))
    return (0.0,up(max(lo*lo,hi*hi)))
def div(a,b):
    assert b[0]>0; return mul(a,(dn(1/b[1]),up(1/b[0])))
R0F=263169/100000            # float nearest to r0; true r0 lies in [R0LO,R0HI]
R0LO,R0HI=dn(R0F,1),up(R0F,1)
assert Fr(R0LO)<=Fr(263169,100000)<=Fr(R0HI)
RC_LO=dn(math.sqrt(dn(R0LO*R0LO-1)))   # lower bound for sqrt(r0^2-1)
A_HI=up(math.asin(up(1/R0LO)))         # upper bound for a(r0)=asin(1/r0) >= Theta everywhere
def theta_hi(r):   # upper bound for Theta(r) (Theta <= a(r0) always; theta=acos(q) decreasing in q)
    if r>=RC_LO: return A_HI
    num=dn(dn(dn(r*r)+dn(R0LO*R0LO))-1)
    den=up(up(2*r)*R0HI)
    q=max(-1.0,min(1.0,dn(num/den)))
    return min(A_HI,up(math.acos(q)))
PI10_LO=dn(math.pi/10)     # math.pi < true pi, so pi/10 > dn(...)
def Fhi(lam,k,j,E,Rr,S):
    e1,e2=E; r1,r2=Rr; s1,s2=S
    th=theta_hi(r2)
    if s1>=2: I=(0.0,0.0)
    else:
        s2c=min(s2,2.0)
        phi=(dn(math.acos(min(1.0,up(s2c/2)))),up(math.acos(dn(s1/2))))
        sp=(dn(math.sqrt(max(0.0,dn(1-up(s2c*s2c)/4)))),   # sin(phi)=sqrt(1-s^2/4),
            up(math.sqrt(max(0.0,up(1-dn(s1*s1)/4)))))      # decreasing in s
        s2p=mul((s1,s2c),sp)                  # sin(2phi)=s*sqrt(1-s^2/4)
        if k==0 and j==0: I=phi
        else:
            num=sub(sub(sq((r1,r2)),sq((s1,s2))),sq((e1,e2)))
            den=(dn(2*e1*s1),up(2*e2*s2))
            c=div(num,den); c=(max(-1.0,c[0]),min(1.0,c[1]))
            if c[0]>c[1]: return -9.0         # box contains no admissible point
            c2=sub(sc(2.0,sq(c)),(1.0,1.0))   # cos(2psi)=2cos^2-1
            I=add(sub(phi,sc(k,mul(sp,c))),sc(j/2,mul(s2p,c2)))
    oml=up(1-lam)                             # >= 1-lam
    return up(up(lam*I[1]) + up(oml*th))      # lam>=0, oml>=0, th>=0
def weight_nonneg(k,j):   # exact: w = (1-j) - k x + 2 j x^2 >= 0 on x in [-1,1]
    k=Fr(k); j=Fr(j)
    vals=[1+j-k,1+j+k]
    if j>0 and abs(k)<=4*j: vals.append(1-j-k*k/(8*j))
    return min(vals)>=0
def check(lam,k,j,E,maxn=10**7):
    e1,e2=E; rlo=dn(R0LO-1); rhi=up(3-e1)
    stack=[((e1,e2),(rlo,rhi),(max(1e-9,dn(rlo-e2)),up(rhi+e2)))]; n=0
    while stack:
        Eb,Rb,Sb=stack.pop(); n+=1
        if n>maxn: return False,n
        if Sb[0]>up(Rb[1]+Eb[1]) or Sb[1]<dn(Rb[0]-Eb[1]): continue
        if Fhi(lam,k,j,Eb,Rb,Sb)<PI10_LO: continue
        w=[(Eb[1]-Eb[0])*4,(Rb[1]-Rb[0]),(Sb[1]-Sb[0])]
        if max(w)<1e-7: return False,(Eb,Rb,Sb)
        i=w.index(max(w)); B=[Eb,Rb,Sb]; lo,hi=B[i]; m=(lo+hi)/2
        for part in ((lo,m),(m,hi)):
            B2=list(B); B2[i]=part; stack.append(tuple(B2))
    return True,n
tot=0; allok=True
assert PARAMS[0][0]==0 and PARAMS[-1][1]>=3-263169/100000
for (a,b,_,_,_),(c,_,_,_,_) in zip(PARAMS,PARAMS[1:]): assert b==c
for ea,eb,lam,k,j in PARAMS:
    assert 0<=lam<=1 and weight_nonneg(k,j)
    ok,n=check(lam,k,j,(ea,eb)); tot+=n if ok else 0; allok&=ok
    print(ea,eb,lam,k,j,"OK" if ok else "FAIL",n,flush=True)
print("ALL OK" if allok else "FAILURE","total boxes",tot)
```

### 4.4 Output (CPython 3.12.9, x86-64 Linux; about 15 s; the program was extracted verbatim from §4.3 and re-run at finalization with identical output)
```
0 0.005 0.21 0.0 0.0 OK 225
0.005 0.015 0.2065 0.0507 -0.0101 OK 625
0.015 0.025 0.2066 0.0995 -0.0084 OK 831
0.025 0.035 0.2147 0.1373 -0.0078 OK 1271
0.035 0.045 0.2085 0.1939 -0.0027 OK 1269
0.045 0.055 0.208 0.241 0.0043 OK 1423
0.055 0.065 0.2151 0.2771 0.0082 OK 1691
0.065 0.075 0.2092 0.3401 0.0155 OK 1777
0.075 0.085 0.21 0.3837 0.0227 OK 1897
0.085 0.095 0.2178 0.4135 0.0314 OK 2043
0.095 0.105 0.2208 0.4592 0.0516 OK 2653
0.105 0.115 0.2139 0.5211 0.0553 OK 2411
0.115 0.125 0.2169 0.5675 0.0675 OK 2447
0.125 0.135 0.2157 0.6247 0.0827 OK 2369
0.135 0.145 0.2186 0.6632 0.1015 OK 2327
0.145 0.155 0.2211 0.7008 0.1122 OK 2143
0.155 0.165 0.221 0.756 0.1319 OK 2015
0.165 0.175 0.2281 0.7444 0.1207 OK 2001
0.175 0.185 0.2269 0.8281 0.1646 OK 1877
0.185 0.195 0.2267 0.9021 0.2062 OK 1907
0.195 0.205 0.2313 0.9091 0.2007 OK 1673
0.205 0.215 0.2316 0.9566 0.2193 OK 1635
0.215 0.225 0.2364 0.9769 0.2326 OK 1439
0.225 0.235 0.2401 1.034 0.2795 OK 1555
0.235 0.245 0.239 1.0748 0.2851 OK 1357
0.245 0.255 0.2393 1.1103 0.2939 OK 1369
0.255 0.265 0.2401 1.1894 0.3485 OK 1267
0.265 0.275 0.2473 1.1833 0.3553 OK 1273
0.275 0.285 0.2457 1.2576 0.3913 OK 1181
0.285 0.295 0.2504 1.2857 0.4197 OK 1269
0.295 0.305 0.2579 1.2879 0.4392 OK 1223
0.305 0.315 0.2576 1.3238 0.4503 OK 1221
0.315 0.325 0.2619 1.3633 0.4854 OK 1203
0.325 0.335 0.2719 1.3201 0.4774 OK 1189
0.335 0.345 0.2644 1.4002 0.4958 OK 1393
0.345 0.355 0.2719 1.3954 0.5128 OK 1007
0.355 0.365 0.2831 1.387 0.5304 OK 1201
0.365 0.3684 0.2831 1.387 0.5304 OK 719
ALL OK total boxes 58376
```

Every row prints OK, and the asserts (parameter chaining, 0 ≤ λ ≤ 1, exact nonnegativity of w, R0LO ≤ r_0 ≤ R0HI) pass. This proves Lemma L and with it the Theorem.

Supporting checks:
- The same program with 3-ulp widening and the original round-to-nearest pruning test `s_1 > fl(r_2+e_2)`, `s_2 < fl(r_1−e_2)` gives identical output. That test is also sound under round-to-nearest, since rounding is monotone and fixes floats.
- With the widening raised from 64 to 128 ulp (replace every default `n=64` by `n=128`) the output is again identical (ALL OK, 58376 boxes), so the certificate tolerates libm acos/asin errors up to about 60 ulp.
- An empirical (non-rigorous) comparison of `math.asin` and `math.acos` on 3000 random arguments in (−0.999, 0.999) against 50-digit `decimal` references gave worst errors of 0.503 and 0.502 ulp on the machine used.
- The certificate is not vacuous: changing the first row's λ to 0.30 makes that row FAIL, at e ≈ 0.005, r ≈ 1.886, s ≈ 1.881.

## 5. Status

The main claim (the Theorem: every covering of D_R by eleven unit disks with exactly ten disks meeting S_R has R < r_0) is fully proved, for all configurations (coincident centres allowed, centres anywhere), by §1–§3 together with the computation of §4. No mathematical gap is known.

The computational step (Lemma L) rests on these environmental assumptions:
- IEEE binary64 arithmetic with correctly rounded + − × / and sqrt, and `math.nextafter`;
- libm `acos`/`asin` errors below about 30 ulp (64-ulp widening; the 128-ulp run relaxes this to about 60 ulp). Standard libms are far more accurate, and the sampled errors on the machine used were ≈ 0.5 ulp, but this is not proved here.

The program is short, standard-library only, and re-runnable in about 15 s; the output in §4.4 was reproduced at finalization. Nothing is claimed about the true supremum of R over the class (conjecturally (3+√5)/2) beyond R < r_0.

## 6. Other routes

- Computer-free proof of Lemma L. A separate hand proof covers e ∈ [0, 0.36831] using only three parameter sets: (λ, k, j) = (0.2, 4.87e, 0) on (0, 0.2], (0.235, 1, 0.25) on [0.2, 0.26] and (0.26, 1.25, 0.4) on [0.26, 0.36831], via quasiconvexity in e and a reduction to one-dimensional slices, with e = 0 handled directly. Its binding evaluations were independently recomputed (worst margin about 0.0063), but the arithmetic is hand arithmetic, not outward-rounded, and the proof is not reproduced here; this document does not rely on it.
- Small-e case by hand. For |c_0| ≤ 0.015 the claim follows from the circles |z| = 1 + e and S_R with λ = 0.215, using concavity and a tangent line at r = 1.9. Subsumed by §4.
- Voronoi/area route. The ten-spoke-wheel area argument extends by hand to all distinct-centre configurations whose clipped Voronoi diagram has no interior vertex shared only by outer cells and has at most 10 boundary arcs. Per-triangle area bounds alone ("edge relaxation") cannot handle the remaining Voronoi graphs: for one such graph an explicit feasible point gives an area bound 22.15 > π r_0². This route was abandoned in favour of the angular route above.
