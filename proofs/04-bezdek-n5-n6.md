# 04 — Bezdek 的 n = 5, 6 最优覆盖（文献核实 + Mathematica 验证）

状态：**n=5 最优值精确形式已验证到 L3 的「值」一侧（极小多项式 + 高精度覆盖），最优性本身为 L0 转述（Bezdek 原文未在本仓库复核）；n=6 最优值 r₆=1.7988… 仅为文献转述（L0），本仓库数值尚未达到。**
证书 `proofs/certificates/04-bezdek-n5-n6.wls`（exit 0）。
工具：`wl/CirCovCir.wl`（`LoadConfig`、`CoveringRadius`、`ExactCoverQ`、`IdentifyClosedForm`）。

## 0. 文献（已核实书目）

Friedman 记录页把 n=5,6 的最优性归给 K. Bezdek。原始条目在 `docs/literature.md` 标「待核实」，本轮经三处独立来源核实：

- **1984 期刊论文**：K. Bezdek, *Über einige optimale Konfigurationen von Kreisen*, **Ann. Univ. Sci. Budapest. Eötvös Sect. Math. 27 (1984), 143–151**。
  来源：Springer 参考文献表（[link.springer.com/article/10.1023/A:1004224507766](https://link.springer.com/article/10.1023/A:1004224507766)）、MSU/CRC *Disk Covering Problem* 词条、Wolfram MathWorld。
  说明：Fejes Tóth (2005) 引作 "Bezdek [1979; 1983]"；MathWorld 写 "Bezdek 1983, 1984"。卷号 27 的实际出版年是 **1984**，"1983" 是期刊的出版延迟（投稿/卷年）。两者是同一篇。
- **1979 博士论文**：K. Bezdek, *Körök optimális fedései*（匈牙利语，"圆的最优覆盖"），egyetemi doktori értekezés，Eötvös Loránd 大学，Budapest，1979。
  来源：Springer 参考文献表给出标题；Fejes Tóth 2005 的 "[1979]"。
- **数值**：Fejes Tóth (2005) p.361 原文：*"Neville [1915] conjectured that r5 = 1.64100446… and this has been verified by K. Bezdek [1979; 1983] who also determined the value of r6 = 1.7988…"*。
  ⟹ n=5 的最优值是 **Neville 1915 猜想、Bezdek 证实**；n=6 的最优值 r₆ = **1.7988…**（Friedman 页面印的 1.798 是十进制截断下界）。
- **对称性**：B. Csikós（Fields Institute 讲义，*Optimal Covering of a Disk with Congruent Smaller Disks*）："For n = 5 and 6 the optimal configuration has only a mirror symmetry." ⟹ 最优构型只有镜像对称，无旋转对称——这正是随机起点难命中、而需要对称种子的原因。

> 规则遵守：以上条目作者/标题/出处/年份齐全，`docs/literature.md` 已去掉「待核实」。**但 Bezdek 两篇原文本仓库没有拿到全文**，所以「最优性证明」本身按 **L0（外部转述）** 对待，不冒充已复核。

## 1. n = 5：R₅ 的精确形式（已验证）

**结论（L3「值」一侧）.** R₅ 是如下八次整系数多项式在 1.641 附近的实根，且不可约（⟹ 无根式闭式）：

$$625\,t^8 - 800\,t^7 + 22\,t^6 - 1776\,t^5 + 1665\,t^4 + 1360\,t^3 - 3480\,t^2 + 2112\,t + 1296 = 0.$$

R₅ = **1.64100446360361570065083282405938618732…**（30+ 位，证书 `E_r5poly`）。

**来源与验证链：**
1. 该八次多项式取自 Math.StackExchange q/2651575（标题误作 "six disks"，实为 **五圆** 值）。本仓库**没有**照单全收，而是独立验证：其实根 x₀≈0.60938 满足 1/x₀ = 1.6410044636…。
   命令：`experiments/2026-10-02-bezdek-fejestoth-verify/probe_r6_poly.wls`（`NSolve[..., WorkingPrecision->50]`）。
2. 令 R₅ = 1/x₀，用 `MinimalPolynomial[R5, t]` 得到上式（即把 x 多项式系数反序）。
   命令：`experiments/2026-10-02-bezdek-fejestoth-verify/probe_r5_exact.wls`。
3. 证书 `E_r5poly`：`RootReduce[mp[R5]] === 0`（精确），且 R₅ 与仓库基线 `data/configs/05/20261001-baseline.json` 的数值差 < 1e-14（实测 ~5e-16，浮点噪声）。
4. 证书 `E_r5deg`：`IrreduciblePolynomialQ` = True，次数 8 ⟹ Galois 群不可解，**没有根式闭式**。这与「Neville 只能猜、Bezdek 要证」一致——若有漂亮闭式，当年就不必等到 Bezdek。
5. 证书 `E_r5nphi`：R₅ ≠ φ² = 2.618…（五圆**对称**排布的半径）。最优是「略小于对称值」的镜像构型（MathWorld 亦述）。
6. 证书 `E_r5cover`：仓库基线构型在 wp=40 下对 D(0, R₅) 的覆盖半径 ρ = 0.99999999999999992（≈1，差为退化 Voronoi 顶点的 ~1e-16 孔，见 `docs/methods.md` 缩放证书说明）。

**仍差什么到 L3「最优性」/完整 L3「构型」：** 需要 Bezdek 的**精确紧点构型**（代数坐标）再跑 `ExactCoverQ`。基线是浮点优化结果，坐标非闭式，`ExactCoverQ` 不适用。本仓库据有的是「R₅ 的精确代数值 + 浮点构型的高精度覆盖」。**最优性**（没有更小的 R）属 Bezdek 原文论证，本仓库 **L0 转述**。

## 2. n = 6：最优值与搜索（未达到，诚实记录）

**目标**：r₆ = 1.7988…（文献值，L0 转述）。**本仓库现状**：

| 来源 | R | 与 1.7988 差 | 命令 / 文件 |
|---|---|---|---|
| 基线（8 起点 seed 0）| 1.790592575329 | −8.2e−3 | `data/configs/06/20261001-baseline.json` |
| 宽搜（200 起点 seed 20261002）| 1.795281474905 | −3.5e−3 | `out/n6-wide-s200.json` |
| 镜像对称搜索（见下）| 见 LOG | — | `n6_mirror.py`、`out/n6-mirror.json` |

**镜像对称搜索方法（`n6_mirror.py`，seed 20261002）**：按 Csikós「最优只有镜像对称」的提示，把搜索限制在关于 x 轴镜像的六圆构型，两个族：
- 族 A：3 对镜像点 {(xᵢ, ±yᵢ)}（6 自由度）；
- 族 B：2 对镜像 + 2 个轴上点（6 自由度）。
每族多起点先用 Nelder-Mead 在对称参数化上优化平滑代理，再对**完整（不设对称）**构型做 `optimize.polish` 的精确 active-set 打磨，最后用精确候选集覆盖半径打分（打分不假设任何对称）。

> 诚实声明：若镜像搜索仍 < 1.7988，记为「该方法未达到记录」，**不**宣称达到、**不**放宽容差。差 < 1e-9 才算平局，这里差在 1e-3 量级，是真未达到。记录值与命令写进 `research/LOG.md`。

## 3. 证据等级

| 结论 | 等级 | 证据 |
|---|---|---|
| Bezdek 两篇书目（1984 期刊 + 1979 论文）| 已核实 | 三处独立来源；`docs/literature.md` |
| R₅ 的精确八次极小多项式（不可约）| L3（值）| `E_r5poly` + `E_r5deg`（精确）|
| R₅ ≠ φ²（最优非对称）| L3 | `E_r5nphi` |
| 基线构型高精度覆盖 D(0, R₅)| L2 | `E_r5cover`（wp=40，ρ≈1）|
| n=5 **最优性**（无更小 R）| L0 | Bezdek 原文转述，仓库未复核 |
| r₆ = 1.7988… | L0 | [FT] 2005 转述 |
| n=6 本仓库最优值 | L2 | 见 §2 表（均 < 记录）|

## Research State（下一步）

- **开放（n=6）**：达到 r₆=1.7988 的构型。镜像搜索若不够，下一步可：(a) 从 Bezdek/Melissen 文献读出 n=6 最优构型的角度参数做热启动；(b) 固定紧约束集后用 WL `FindRoot`（wp≥50）解精确方程组。
- **开放（n=5 升 L3 构型）**：取得 Bezdek 的精确紧点坐标（代数数）后跑 `ExactCoverQ`；或对基线构型做闭式识别（当前 `IdentifyClosedForm` 对单坐标给不出低次闭式，需联立紧约束方程）。
- **待人工**：Bezdek 1984/1979 原文的最优性论证——本仓库只验证了「值」，没有复核「证明」。
- 证书命令：`wolframscript -file proofs/certificates/04-bezdek-n5-n6.wls`（exit 0）。
