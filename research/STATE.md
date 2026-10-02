# 研究状态（STATE）

> 只记录**当前**结论；过程写进 `LOG.md`。每次实验结束更新本文件。证据等级见 `AGENTS.md`。

## 已确立

| 结论 | 等级 | 证据 |
|---|---|---|
| n=1,2,3,4,7 已知构型精确覆盖其 R | L3 | `data/configs/*/known.json`，`ExactCoverQ` + Python 复核 |
| n=8,9,10 已证最优值精确等于 1+2cos(2π/k)，k=n−1（中心圆 + 正则 k 环 `RingConfig[k]`）；n=7 同构型 R=2 | L3 | `ExactCoverQ[RingConfig[k], RingRadius[k]]` True、+1e-30 False（`wl/tests/run_tests.wls`）|
| 条件对称性：在“一个圆盘恰为 D(0,1)，其余 k 个覆盖环带”的假设 H_k 下，k=6..9 有 R ≤ 1+2cos(2π/k)，且取等时外环必为正则环 | L4（条件；待人工复核）| `proofs/01-ring-symmetry.md` + `proofs/certificates/01-ring-symmetry.wls` |
| **n=3,4,7 无条件最优性**（弧计数法，去掉 H_k）：R₃=2/√3, R₄=√2, R₇=2。核心 A(R)=2arcsin(1/R) 严格减且 A(R_n) 精确踩 2π/n（n=3,4）或 2π/6（n=7，另加"覆盖 O 的圆够不到 R>2 边界"一步） | L4（无条件；待人工复核）| `proofs/03-n7-optimal.md` + `proofs/certificates/03-n7-optimal.wls`（exit 0，7 项全 True）|
| 基线优化器复现 n=5,8,9,10 的已证最优值（R = 1.641004463603615, 2.246979603717466, 2.414213562373093, 2.532088886237954） | L2 | `data/configs/{05,08,09,10}/20261001-baseline.json`，Py + WL(wp=40) 缩放证书一致到 ≤7e-16 |
| **R₅ 的精确代数值**：R₅ = 1.64100446360361570… 是八次不可约多项式 625t⁸−800t⁷+22t⁶−1776t⁵+1665t⁴+1360t³−3480t²+2112t+1296 之根（无根式闭式），≠ φ²（镜像最优）| L3（值）| 证书 `proofs/certificates/04-bezdek-n5-n6.wls`（exit 0）；`proofs/04-bezdek-n5-n6.md` |
| Bezdek n=5,6 书目已核实（1984 期刊 Ann. Univ. Sci. Budapest Eötvös Sect. Math. 27, 143–151 + 1979 博士论文）；r₆=1.7988…（非 Friedman 截断 1.798）| 已核实 | 三处独立来源；`docs/literature.md` |
| FT n=8,9,10 计算断言：笔误 2sin→2cos、正则环精确覆盖且紧、G1T 为 f 在 ᾱ 的切线且 f 在 (ᾱ,π) 凹、**Jensen 链 (1)–(7) 修正函数 g=sin((n−2)π/(n−1)−α/2)+F 在 [ᾱ,π] 递减** | L3 | 证书 `proofs/certificates/05-fejestoth-n8-n9-n10.wls`（exit 0，含 gating `E_jensen`：端点恒等 + g′(ᾱ)<0 精确 + g″<0 区间 200 面板）；`proofs/05-fejestoth-n8-n9-n10.md` |
| **n=11 复现 Melissen 记录并给 L3 覆盖证书**：11 单位圆精确覆盖 D(0, R)，R=2.63164999999999957923…**> 2.631**（页面印刷记录下界），精确代数算术判定（`ExactCoverQ=True`，无浮点）。竖直镜像对称；底层高精度紧接触构型 R=2.6316907726198078（28 式，2 内部自由度，max-R 定点） | **L3**（覆盖下界；非最优性） | 证书 `proofs/certificates/06-n11-interval.wls`（exit 0）+ `proofs/06-n11-coverage-L3.md`；构型 `data/configs/11/20261002-melissen-exact.json`（`verified-exact`，WL `exact_cover=true`、cert_gap=0）；高精度源 `…-tight.json`；刚性诊断 `rigidity_check.wls`（满秩 28/30 ⇒ 2 DOF）|

## 开放问题

- n=5 基线构型的闭式识别 → L3（n=8,9,10 已由正则环解决）。**R₅ 的值已精确识别**（八次不可约多项式，见 `proofs/04`）；仍差的是 **Bezdek 精确紧点构型坐标** 以跑 `ExactCoverQ` 升到 L3「构型」，以及 n=5 **最优性**（Bezdek 原文未复核，L0）。
- 去掉 H_k：证明 n=8,9,10 的最优覆盖必含一个恰好覆盖 D(0,1) 的圆（Fejes Tóth 论证的另一半）。n=7 已无条件解决（`proofs/03-n7-optimal.md`，硬计数即可，因 A(2)=π/3 踩整数 6）；n≥8 硬计数失效，仍需面积论证。
  - 进行中：`proofs/02-remove-ring-assumption.md` + `proofs/05-fejestoth-n8-n9-n10.md`。已修复/验证：§2 笔误、G1 缺口、G1T 切线+凹性、**S4 Jensen 链 (1)–(7)（修正 (5) 的 Jensen 项数 ⇒ g=sin((n−2)π/(n−1)−α/2)+F 在 [ᾱ,π] 递减，区间证书 L3）**（证书 05 exit 0）。**剩余硬骨头**：(S3b) G1T 在 α<ᾱ 的区间分支定界证书；(§3) n=10 的 Melissen 距离引理（h 单调凸、|pᵢpᵢ₊₃|>2、Case 1/2 面积界）未配证书。
- n=6：基线 1.790593 → 宽搜 200 起点 **1.795281474905**（`experiments/2026-10-02-bezdek-fejestoth-verify/out/n6-wide-s200.json`）；镜像对称搜索 `n6_mirror.py` 方法已留档但未在时限内跑完。仍 < 记录 1.7988（差 ~2.5e-3，**未达到**）——需读 Bezdek/Melissen 的 n=6 构型角度做热启动，或固定紧约束集解精确方程组。
- 复现 n=11..25 记录；尤其 R_19=√13、R_25=√6+√3 的精确构型。**n=11 已到 L3（覆盖下界，见上「已确立」）**：精确覆盖 D(0,2.6316499…)、>2.631，`ExactCoverQ=True`。几何结论：紧接触构型**非刚性（2 自由度）**，R 与坐标是**高次代数数、无实用闭式**（`FindIntegerNullVector` deg≤24 无低高度匹配、`GroebnerBasis` 消元 900s 超时）。**仍开放 = n=11 的最优性**（"found"，非 proved-optimal；弧计数法 n≥8 失效，面积法仍需 S3b/§3 n=10 距离引理，见 `proofs/02`、`05`）。n=12..25 尚未复现。
- 能否改进任一 n ∈ [11,25] 的记录？

## 死路

- “中心圆 + 外环”的弧长切线论证到 k=10（n=11）就失效：L(0) < 2arcsin(1/R*)，与记录 R_11 = 2.631 > 1+2cos(π/5) 一致。n ≥ 11 不要再沿这条路走。

## 外部笔记（未在本仓库复核，按 L0 对待）

- `../circovcir_audit/FINDINGS.md`：n=25 记录的边界拥有者数 b=16（三环 A/B/C），面积/单圆 Hall 论证不能排除 b∈{14..17}。
