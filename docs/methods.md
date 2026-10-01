# 核心算法：有限候选集上的覆盖半径

`wl/CirCovCir.wl`（`CandidatePoints` / `CoveringRadius` / `ExactCoverQ`）与 `src/circovcir/geometry.py` 实现的是**同一个定理的两份独立代码**。改动其中一份必须同步另一份，并让两边测试都通过。

## 定理

设 f(x) = min_i |x − c_i|，K = D(0,R)。f 在紧集 K 上的最大值在下列有限集合 C 中某点取到：

- (T) 三点 c_i, c_j, c_k 的外心（落在 K 内者）；
- (B) 中垂线 {x : |x−c_i| = |x−c_j|} 与圆周 |x| = R 的交点；
- (A) 圆周上的“对径点” −R c_i/|c_i|（c_i ≠ 0）；另加 (R,0) 以处理 c_i = 0。

## 证明梗概

设 x* 为 f 在 K 上的最大点，I = {i : |x*−c_i| = f(x*)} 为最近中心集合。

1. x* 在 K 内部：若 |I| ≤ 2，存在方向使所有 |x−c_i| (i∈I) 同时增大（|I|=1 取远离 c_i 方向；|I|=2 沿中垂线远离两点中点方向），与极大矛盾。故 |I| ≥ 3，x* 是某三点的外心 ⇒ (T)。
2. x* 在圆周上：若 |I| ≥ 2，x* 在某条中垂线上 ⇒ (B)。若 |I| = 1，在 x* 附近 f = |x−c_i|，限制在圆周上取极大，切向导数为零 ⇒ x* ∥ c_i，且极大（非极小）⇒ x* = −R c_i/|c_i|；c_i = 0 时整条弧上 f 为常数，弧端点属于 (B)，若整圆属于一个胞腔（n=1）则 (R,0) 兜底 ⇒ (A)。

由于 C ⊆ K 且包含 x*，有 ρ(c,R) = max_{x∈C} f(x)。（C 中多余的点只会给出下界，不影响最大值——所以无需真正构造 Voronoi 图。）复杂度 O(n³)·n，n ≤ 50 完全够用。

## 精确判定 `ExactCoverQ`

输入为精确（代数）数时，候选点都是代数数。对每个比较 1 − |x−c_i|² ≥ 0：先做 40 位认证数值，|值| > 1e-30 直接定号；否则对差 `RootReduce` 后取精确符号。等号情形（紧点）因此被精确判定。这是 L3 级证据（见 `AGENTS.md`）。

## 数值注意

- float 版对圆周点 h² 的微小负值做截断，对 K 内判定留 1e-12 相对容差；它只做**快筛**。
- 浮点优化出的构型在退化的 Voronoi 顶点处常留下 ~1e-16 的“孔”：ρ(c,R) = 1 + O(1e-16) 且与 R 无关（孔在内部），于是严格意义上 R_max(c) 会塌缩，`MaxCoveredRadius` 的高精度二分也就失去意义。正确的数值证书是**缩放证书**：令 ρ = ρ(c,R)，则单位圆放在 c/ρ 处精确覆盖 D(0, R/ρ)。`verify_config.wls` 报告 `R_certified = R/ρ`（ρ ≤ 1 时取 R）。要 L3 仍须把构型识别为精确闭式再跑 `ExactCoverQ`。
- 最优构型必然有大量紧点（等号），float 版在等号附近不可靠；判定记录必须上 Wolfram 高精度 / 精确。
- 优化目标 r(c) = ρ(c,1) 非光滑（max-min）。`optimize.py` 用 log-sum-exp 双重光滑 + 退火作基线；严肃的局部打磨应在紧约束集固定后解方程组（FindRoot, WorkingPrecision ≥ 50）。

## 弧覆盖工具

`CoveredArc[r,d]` / `arcs.covered_arc`：Γ_r 落在距 O 为 d 的单位圆盘内的弧角。`RingAlpha` / `ring_alpha`：给定内圆弧 β 时外圆弧 α。推导、凹性区间与对称性定理见 `proofs/01-ring-symmetry.md`。
