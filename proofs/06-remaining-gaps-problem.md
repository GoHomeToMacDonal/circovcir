# 06 — 无条件 L4 的剩余缺口：一个自封闭的待解问题

状态：**问题陈述文档（L0 — 陈述，不求解）**。
目的：把 Fejes Tóth n=8,9,10 无条件最优性证明里**仅剩的非计算缺口**，整理成一个**自封闭、良定义**的问题，使读者可以独立接手求解或复核，而不需要重读整条证明链。本文**不**构造证书、**不**求解；它只精确陈述「还差什么」以及「补上后如何合拢」。

> 读法：§1 给定公理（四个已封的 exit-0 证书，当作已知事实引用）；§2 一处定义所有记号；§3 从 [FT] §2 原文逐字抽取 S0、S1 的确切陈述并给出诚实定级；§4 把 S0、S1、n=10 引理各写成一条独立命题；§5 给出合拢定理（这些命题 + §1 公理 ⟹ 无条件定理）。

---

## 0. 文献（已核实）

**[FT]** G. Fejes Tóth, *Thinnest covering of a circle by eight, nine, or ten congruent circles*, in *Combinatorial and Computational Geometry* (J. E. Goodman, J. Pach, E. Welzl, eds.), MSRI Publications **52**, Cambridge Univ. Press, 2005, pp. 361–376。PDF: [library.slmath.org/books/Book52/files/18fejes.pdf](https://library.slmath.org/books/Book52/files/18fejes.pdf)。本文对 §2 的引用均**从该 PDF `pdftotext -layout` 抽取后逐字转录**（抽取日 2026-10-09，§2 = 原文 pp.363–367）。公式被 PDF 排版破坏处，下文显式标注并从上下文重建。

**[Melissen]** J. B. M. Melissen, *Packing and covering with circles*, PhD thesis, Universiteit Utrecht, 1997, pp. 108–111。**原文未取得**（公网无 PDF；[FT] §3 的 n=10 距离论证归功于此文）。本仓库对 n=10 引理的验证全部基于 **[FT] §3 的转述**，不是对 Melissen 原文的独立复核。

---

## 1. 给定（GIVEN）：四个已封的计算证书，当作公理引用

下列四条已各配 **exit-0 Wolfram 证书**，是本问题的**已知事实**。接手者**不得**重证，只能引用。路径与担保：

**(G-A) S3b — G1T 小-α 定界.** `proofs/certificates/05b-g1t-small-alpha.wls`（exit 0，L3）。
担保：在 §2 的约束域 Ω 上（见 §2 记号），`M := cos θ − cos T(α) ≥ 0` 处处成立，即单格张角界 **θ(α) ≤ T(α)** 在整个 Ω 成立，等号仅在正则胞腔（α=ᾱ、双顶点接触 |u₁|=|u₂|=1）处。此即 [FT] (3) 式所需的 Σθ=2π ≤ ΣT(αᵢ)（T 为 f 在 ᾱ 的切线，替补 [FT] 原文有缺口的 G1：θ≤f(α)）。

**(G-B) S4 — Jensen 链 (1)–(7) 收尾单调性.** `proofs/certificates/05-fejestoth-n8-n9-n10.wls` 的 gating `E_jensen`（exit 0，L3）。
担保：**修正**收尾函数 `g(α) = sin((n−2)π/(n−1) − α/2) + F(α)` 在 [ᾱ,π] **严格递减**（端点恒等 g(ᾱ)=sin β̄+F(ᾱ) 精确 + g′(ᾱ)<0 精确 + g″<0 向外舍入区间 200 面板）。注：[FT] PDF 排版在 (5) 丢了 Jensen 平均分母 2(n−1) 的因子 2，字面读成 `sin(2(n−2)π/(n−1) − α)+F`（在 ᾱ 处求导为正，自相矛盾）；修正见 `proofs/05` §4。

**(G-C) §3 — n=10 Melissen 距离引理.** `proofs/certificates/05c-melissen-n10.wls`（exit 0，L3 **基于 [FT] 转引**）。
担保：h(ϑ) 单调且凸、|pᵢpᵢ₊₃|=2.02349>2、|pᵢpᵢ₊₄|=2.357538>2、面积界 (9)–(13) 与 Case 1/2 总和 < a(C₁₀)=πr₁₀²，全部逐位命中 [FT] §3 印刷数（h 第一性原理重建，不信任被破坏的符号文本）。**红线**：Melissen 原文 pp.108–111 **未取得、待核实**；五边形界 (10) 验的是不等式（略紧于 FT）而非复现 FT 精确小数。

**(G-D) S5 — 取等 ⟹ 全等的刚性事实.** `proofs/certificates/05d-s5-equality-rigidity.wls`（exit 0，R1–R5 全 True，L3）。
担保：R1 f″<0、R2 F″<0 于 (0,π)（⟹ (3)(6) 严格凹 Jensen 取等 ⟺ 所有 αᵢ 相等）、R3 g 在 [ᾱ,π] 严格递减、R4 单格取等轨迹=正则胞腔（关键恒等式 R·sin(π/k)=sin(3π/k)，RootReduce 精确）、R5 k·θ̄=2π + `RingConfig[k]` 精确紧覆盖（等角闭合）。

**(G-E) 可达性 + 笔误更正.** `E_ring`、`E_typo`（证书 05，L3）。
担保：`ExactCoverQ[RingConfig[k], RingRadius[k]]`=True 且 `+10⁻³⁰`=False（正则环精确且紧覆盖 D(0,R_n)）；外环圆心到 O 的距离精确等于 **2cos(π/k)**（[FT] 定理陈述印成 2sin π/(n−1) 系笔误）。

> **这五条合起来覆盖了证明的「计算侧」全部。** 本文要陈述的三个缺口（S0、S1、n=10 引理的文献层级）全是**非计算**的几何/簿记/文献问题。

---

## 2. 记号（一处定义，全文自洽；与 `proofs/02`、`05` 一致）

**设定.** 固定 n ∈ {8, 9, 10}，置 k = n−1。设 C_n 是圆心在 o（取为原点）、半径 R_n = 1 + 2cos(2π/k) 的圆盘，其边界记 bd C_n。设 C₀, …, C_{n−1} 是 n 个**闭单位圆**（半径 1），圆心 o₀, …, o_{n−1}，它们**覆盖** C_n（即 C_n ⊆ ⋃ Cᵢ）。目标构型 C̄₀,…,C̄_{n−1}：C̄₀ 与 C_n 同心，C̄₁,…,C̄_{n−1} 的圆心 ō₁,…,ō_{n−1} 位于以 o 为心、**2cos(π/k)** 为半径的正 k 边形顶点上（即 `RingConfig[k]`）。带 bar 的量 = 目标构型的对应量。

**根轴（radical axis）.** 两圆 Cᵢ、C_n 的根轴 = 平面上对两圆**幂相等**的点的轨迹，是一条垂直于连心线 o oᵢ 的直线。幂 pow(x; C) = |x − center|² − radius²。两圆相交时，根轴过两交点。「o 与 oᵢ 在根轴同侧」= o、oᵢ 落在该直线分出的同一个半平面。

**内部圆（interior disk）.** 称 Cᵢ 为内部圆，若 Cᵢ ⊆ int C_n（即 Cᵢ 不碰 bd C_n，Cᵢ ∩ bd C_n = ∅）。

**Dirichlet 胞腔.** 对覆盖 {Cᵢ}，Cᵢ 关于 C_n 的 Dirichlet 胞腔 Dᵢ = C_n 中「到 oᵢ 比到任何其他 oⱼ 都不远」的点集（最近圆心剖分，交 C_n）。由 §3 的事实（经 G-C/arcsin 计数），每个胞腔顶点三面交会，D₀ 是 k 边形，Dᵢ（i≥1）是三直边 + 一段 bd C_n 弧围成的曲边四边形。

**两个核心函数**（[FT] §2，r = R_n 为参数，0 ≤ α ≤ π）：
```
f(α) = 2 arcsin( sin(α/2) / r )
F(α) = r² arcsin( sin(α/2)/r ) − (1/2) sin( 2 arcsin(sin(α/2)/r) ) + sin(α)/2
```
几何意义（[FT] 原文）：设 C 是半径 r、圆心 o 的圆，C̃ 是圆心 õ∈C 的单位圆，bd C 与 bd C̃ 交于 a、b；若 ∠aõb = α，则 **f(α) = ∠aob**，**F(α) = 由线段 õa、õb 与 bd C 的弧 ab 围成区域的面积**。
事实（[FT] §2，本仓库 G-A/G-D 已验）：f 凹且严格增；F 凹（证明见 [FT]，验证见 R2）。

**单格角量**（[FT] §2，见其 Figure 1；D₀ 顶点 p₁…p_{k}，bd C_n 上胞腔顶点 q₁…q_{k}，约定 Dᵢ 顶点为 pᵢ,pᵢ₊₁,qᵢ₊₁,qᵢ）：
```
αᵢ = ∠qᵢ oᵢ qᵢ₊₁   βᵢ = ∠pᵢ oᵢ qᵢ    γᵢ = ∠pᵢ₊₁ oᵢ qᵢ₊₁
δᵢ = ∠pᵢ oᵢ pᵢ₊₁    εᵢ = ∠pᵢ o₀ pᵢ₊₁
θᵢ = ∠qᵢ o qᵢ₊₁ （该胞腔的弧在 o 处的张角）
```
正则值：**ᾱᵢ = 6π/k**，β̄ᵢ = γ̄ᵢ = (n−5)π/k，δ̄ᵢ = ε̄ᵢ = 2π/k。恒等式 f(6π/k) = 2π/k。

**G-A 的约束域 Ω**（单格参数化，证书 05b 口径）：圆心 oᵢ=(s,0)，R−1 ≤ s ≤ √(R²−1)；弧端点方向 u_j = R(cos t_j, sin t_j) − (s,0)，j=1,2；θ = t₂−t₁，α = ∠(u₁, oᵢ, u₂)；Ω = { s∈[R−1, √(R²−1)], |u_j| ≤ 1, α ≤ ᾱ }。T(α) = f(ᾱ) + f′(ᾱ)(α−ᾱ) 为 f 在 ᾱ 的切线。

**T(α) 记号.** T = f 在 ᾱ 处切线，用于替补 [FT] 原文有缺口的 G1（见 §1 G-A）。

---

## 3. [FT] §2 原文逐字抽取 — S0、S1

### 3.1 S0（反射约定）— [FT] 原文

[FT] §2（PDF 第 365 页，紧接 f、F 的凹性验证之后）：

> *"Let Cn be a circle of radius rn centered at o and let C0, …, Cn−1 be closed unit circles with centers o0, …, on−1 covering Cn. **We assume that for a circle Ci, i = 0, …, n−1, for which Ci ∩ bd Cn ≠ ∅ the centers of Ci and Cn lie on the same side of the radical axis of the circles Ci and Cn. Otherwise we reflect Ci in this radical axis and still get a covering of Cn.**"*

以及（同页，Figure 1 之前，δ/ε 定义之后）：

> *"We note that **the assumption that o and oi lie on the same side of the radical axis of Cn and Ci implies that αi ≤ π** for i = 1, …, n−1."*

**抽取保真度**：这两段 pdftotext 抽取**干净无破坏**（无公式，纯文字 + `αi ≤ π`）。

**S0 包含两个被 [FT] *断言而未证* 的子命题**：
- **(S0a) 反射保覆盖**：若 o、oᵢ 在 Cᵢ/C_n 根轴异侧，则把 Cᵢ 关于该根轴反射得到 Cᵢ′，所得圆族仍覆盖 C_n。[FT] 只写 "and still get a covering"，**无一字论证**。
- **(S0b) 同侧 ⟹ αᵢ≤π**：在同侧约定下，胞腔内角 αᵢ=∠qᵢoᵢqᵢ₊₁ ≤ π。[FT] 写 "It is easy to check / implies that"，**无论证**。

**诚实定级（S0）**：**genuine-open（但几何上初等）**。两条都是 [FT] 的**断言**，正文一行带过，没有展开。它们不是「只需转录」——[FT] 根本没写证明；但从根轴/幂的定义看都是初等平面几何（见 §4 命题 P0），接手者需补出完整论证。这是**真缺口**，不是转录。

### 3.2 S1（n=8,9 结构引理）— [FT] 原文

[FT] §2（第 365 页，紧接 S0 之后，先给引理陈述）：

> **Lemma.** *"Exactly one of the circles {Ci}ⁿ⁻¹_{i=0} is contained in int Cn. Moreover, no three of the circles intersecting bd Cn can have a common point."*

然后给出 n=8,9 的**完整 arcsin 论证**（逐字转录；下标 r₈/r₉ 指 R_8/R_9）：

> *"Since rn > 2, there is a circle, say C0, which is contained in int Cn. Observe that an arc of bd Cn which is covered by a unit circle spans at o an angle not greater than 2 arcsin(1/rn). Since*
> *6 arcsin(1/r8) = 2.76326081… < π   and   7 arcsin(1/r9) = 2.989550105… < π,*
> *it follows that if n = 8 or n = 9, then Ci ∩ bd Cn ≠ ∅ for i = 1, …, n−1. We also observe that three unit circles with a common point cannot cover a part of bd Cn whose angle spanned at o exceeds 2 arcsin(2/rn). Since*
> *4 arcsin(1/r8) + arcsin(2/r8) = 2.942412903… < π*
> *and*
> *5 arcsin(1/r9) + arcsin(2/r9) = 3.111686536… < π,*
> *it follows that for n = 8 and 9 no three of the circles Ci, i = 1, …, n−1, can have a common point."*

n=10 处 [FT] 明说此法失效，转 §3/Melissen：

> *"This argument breaks down when n = 10. We have 7 arcsin(1/r10) = 2.841948021… < π, showing that at most two of the circles {Ci}⁹_{i=0} are contained in int C10; however 8 arcsin(1/r10) = 3.24794059… > π, so we cannot exclude in this way that two of the circles {Ci}⁹_{i=0} are contained in int C10. Also the proof that no three of the circles intersecting bd Cn can have a common point requires a different argument. Melissen [1997, pp. 108–111] proved the Lemma for n = 10 using an argument based on the investigation of distances. In Section 3 we repeat Melissen's argument for the proof of the first part of the Lemma and give an alternative proof for the second statement, using estimations of areas."*

**抽取保真度**：全段 pdftotext 抽取**干净**；五个 arcsin 数值常数（2.76326081、2.989550105、2.942412903、3.111686536、2.841948021、3.24794059）无破坏，可直接核验。唯一需从上下文补读的是 `2 arcsin(1/rn)` 与 `2 arcsin(2/rn)` 两处弧长上界的几何依据（见下）。

**S1 的论证结构（[FT] 实际写出的）**，分两断言：
- **(S1-i) 恰一圆在 int C_n 内**。依据链：(a) r_n>2 ⟹ 至少一圆在 int C_n（否则无法盖住圆心邻域）；(b) 单个单位圆盖 bd C_n 的弧，其 o-张角 ≤ **2 arcsin(1/r_n)**（弦长/半径的初等界）；(c) 若 n=8,9，k·2arcsin(1/r_n) < 2π 的互补形式 `(k−1)arcsin(1/r_n)<π`… — 实际 [FT] 用的是 `6 arcsin(1/r8)<π`、`7 arcsin(1/r9)<π`，推出**每个** Cᵢ (i≥1) 都碰 bd C_n，故恰好只有 C₀ 在内部。
- **(S1-ii) 边界上无三圆共点**。依据：三单位圆共点时盖 bd C_n 的弧 o-张角 ≤ **2 arcsin(2/r_n)**；由 `4 arcsin(1/r8)+arcsin(2/r8)<π`、`5 arcsin(1/r9)+arcsin(2/r9)<π` 推出无三圆共点（n=8,9）。

**诚实定级（S1）**：**n=8,9 = 转录 / 验证（NOT genuine-open）**；**n=10 = 文献依赖（genuine-open 直到取得 Melissen 或自证）**。
- 对 n=8,9，[FT] §2 的论证**是完整的、显式写出的**：五个 arcsin 不等式 + 两条弧长上界引理（2arcsin(1/r)、2arcsin(2/r)）。缺口只是：(1) 本仓库**尚无**对这两条弧长上界引理的独立证明（它们是初等的，但未落到证书/文档）；(2) 五个数值不等式**尚无**本仓库的向外舍入区间复核。两者都属**转录 + 机械验证**，不是开放难题。**若接手者只做这两件事，S1(n=8,9) 即关闭。**
- 对 n=10，[FT] §2 明确说此法失效（8 arcsin(1/r₁₀)>π），引理第一部分借 Melissen 距离论证、第二部分 [FT] §3 用面积法另证。本仓库 G-C 已把 [FT] §3 的计算断言做到 L3，**但 Melissen 原文 pp.108–111 未取得**。故 n=10 的 S1 仍悬在文献上。

---

## 4. 三条独立命题（待证 / 待关闭）

### P0 — 反射约定（对应 S0，genuine-open，初等）

**P0a（反射保覆盖）.** 设 {Cᵢ} 覆盖 C_n，Cᵢ ∩ bd C_n ≠ ∅，且 o、oᵢ 位于 Cᵢ、C_n 根轴的异侧。令 Cᵢ′ 为 Cᵢ 关于该根轴的镜像。则 (Cᵢ′) ∪ (其余 Cⱼ) 仍覆盖 C_n。
*可假设*：根轴与幂的初等性质；两圆半径 1 与 R_n>2 固定。*要证*：C_n 中原由 Cᵢ 覆盖而反射后未被 Cᵢ′ 覆盖的点集为空（提示：根轴把平面分成「离 Cᵢ 更近」与「离 C_n 中心更近」两半；C_n ∩ (Cᵢ 一侧) 在反射下的像仍含于 Cᵢ′ ∩ C_n）。

**P0b（同侧 ⟹ αᵢ≤π）.** 在「对每个碰界的 Cᵢ，o 与 oᵢ 同侧于根轴」的约定下，边界胞腔内角 αᵢ = ∠qᵢ oᵢ qᵢ₊₁ ≤ π（i=1,…,k）。
*可假设*：Dirichlet 剖分已建立，qᵢ、qᵢ₊₁ 是 Dᵢ 在 bd C_n 上的两端点。*要证*：同侧约定使 oᵢ 位于弦 qᵢqᵢ₊₁ 的「C_n 中心一侧」，从而圆心对该弧所张不超过平角。

> P0 是真缺口（[FT] 未证），但预期是初等平面几何小引理，非困难问题。关闭后可配一个几何说明文档或轻量 WL 符号检查（非必需 Krawczyk）。

### P1 — n=8,9 结构引理（对应 S1(n=8,9)，转录 + 验证）

**命题.** 设 n∈{8,9}，{Cᵢ}ⁿ⁻¹ 覆盖 C_n（R_n=1+2cos(2π/k)，k=n−1）。则 (i) 恰有一个 Cᵢ 含于 int C_n；(ii) 相交 bd C_n 的圆中无三者共点。
*辅助引理（需独立证明）*：
- **(L-arc1)** 一个单位圆覆盖的 bd C_n 弧在 o 处张角 ≤ 2 arcsin(1/R_n)。
- **(L-arc2)** 三个有公共点的单位圆覆盖的 bd C_n 弧在 o 处张角 ≤ 2 arcsin(2/R_n)。
*需验证的数值不等式（向外舍入区间）*：
```
6·arcsin(1/R₈) < π            7·arcsin(1/R₉) < π
4·arcsin(1/R₈)+arcsin(2/R₈) < π      5·arcsin(1/R₉)+arcsin(2/R₉) < π
```
*关闭条件*：L-arc1、L-arc2 各给初等证明 + 四个不等式区间复核。**本命题对 n=8,9 不是开放难题，是转录与机械验证。** （[FT] §3 对 n=10 的对应部分已由 G-C 覆盖，但搭在未取得的 Melissen 原文上。）

> **状态更新（2026-10-09）：P1(n=8,9) 已配 exit-0 证书，关闭（L3）。**
> 证书 `proofs/certificates/05e-p1-structure-n8-n9.wls`（exit 0，6 项 gating 全 True）：
> - **L-arc1 / L-arc2** 各给初等几何证明（写在证书头注），并落到可复用库函数
>   `CirCovCir`MaxCoveredArc`（单圆，chord ≤2 ⟹ 2 arcsin(1/r)）、
>   `CirCovCir`MaxCoveredArcTriple`（三圆共点，三角不等式 ⟹ chord ≤4 ⟹ 2 arcsin(2/r)；
>   本次新增，带 usage + `wl/tests` 回归）。
> - **四个 arcsin 不等式**向外舍入区间复核（WL `Interval`，LHS 上端点 < π 下端点，严格 <π）：
>   余量分别 0.3743 / 0.1992 / 0.1520 / **0.0299**（最紧 = n=9 三圆共点）。
> - **诚实边界**：[FT] 把 `6 arcsin(1/r₈)` 印成 2.76326081，真值 2.767326081（论文数字转置笔误）；
>   两者皆 <π，证书核验真值并记录笔误。其余三条逐位命中 [FT] 印刷数。
> - 实验目录 `experiments/2026-10-09-p1-structure/`（单入口 `run.wls` + README）。

### P2 — n=10 引理的文献层级（对应 S1(n=10)/S2，genuine-open 直到取得原文或自证）

**命题（已由 G-C 做到 L3-转引，此处陈述尚缺什么）.** [FT] §3 对 n=10 的引理（第一部分「至多/恰一圆在 int C₁₀」借 Melissen 距离论证；第二部分「无三胞腔共点」[FT] 用面积法）其**计算断言**已被 `05c` 逐位复现（h 单调/凸、|pᵢpᵢ₊₃|>2、|pᵢpᵢ₊₄|>2、(9)–(13)+Case 1/2 总和<a(C₁₀)）。
*仍缺（二选一的清晰路径）*：
- **(a) 取得 Melissen 1997 博论 pp.108–111 原文**，核对 [FT] 转述无误（把 G-C 从「L3-基于转引」升到「L3-独立复核」）。
- **(b) 对距离不等式给自封闭重证**：`05c` 已第一性原理重建 h(ϑ) 并复现关键数值断言（|pᵢpᵢ₊₃|、|pᵢpᵢ₊₄|、面积界）——**这是部分进展**；仍缺的是把这些数值断言组织成一个**不依赖 [FT] 转述**的完整逻辑论证（尤其五边形界 (10) 当前只验了不等式、未复现 FT 精确闭式，且「这些距离不等式 ⟹ 无八圆盖界/无三胞腔共点」的归约步骤本仓库尚未独立写出）。

---

## 5. 合拢定理（REDUCTION）：这些命题 + §1 公理 ⟹ 无条件定理

**目标定理（无条件）.** 对 n∈{8,9,10}，R_n = 1 + 2cos(2π/(n−1))，且覆盖 D(0,R_n) 的最优单位圆构型**模旋转唯一**，等于 `RingConfig[n−1]`（中心圆 + 正则 (n−1) 环，环心距 O 为 2cos(π/(n−1))）。

**合拢链（每一步标注依赖）.**

1. **可达性 + 值**：`RingConfig[k]` 精确且紧覆盖 D(0,R_n) ⟹ R_n 可达，且外环距离=2cos(π/k)。 ← **G-E**。
2. **拓扑/结构**（把一般覆盖归到「恰一内部圆 + k 个边界胞腔」）：
   - 反射归一化，并得 αᵢ≤π ← **P0（S0，待证）**。
   - 恰一圆在 int C_n、边界无三圆共点、Dirichlet 剖分同构于目标构型的剖分 ← **P1（S1，n=8,9：已配证书 `05e`，关闭 L3）** / **P2 + G-C（n=10：Melissen/面积，搭文献）**。
3. **单格张角界**：2π = Σθᵢ ≤ ΣT(αᵢ)（T=f 在 ᾱ 切线），逐格 θ≤T 于 Ω ⟹ Σαᵢ ≥ k·ᾱ（即 [FT] (3) 式，f(ᾱ)=2π/k）。 ← **G-A（S3b）** + G-E 的 f(ᾱ) 恒等。
4. **面积求和 + Jensen 收尾**：对每个胞腔的三角形/区域面积用 (1)–(6) 求和，收尾函数 g(α)=sin((n−2)π/k−α/2)+F(α) 在 [ᾱ,π] 严格递减（第 3 步给 α-mean≥ᾱ） ⟹ 总面积 Σ(…) ≤ 正则构型的对应总面积 = a(C_n)。但覆盖 ⟹ 总面积 ≥ a(C_n)，故**全链取等**。 ← **G-B（S4）**；n=10 的面积界另需 **G-C（§3）**。
5. **取等 ⟹ 全等**：全链取等 + 严格凹 Jensen（R1 f″<0、R2 F″<0）⟹ 所有 αᵢ=ᾱ；R4 单格取等轨迹=正则胞腔（R·sin(π/k)=sin(3π/k) 精确）；R5 k·θ̄=2π 等角闭合 ⟹ 构型 = `RingConfig[k]` 模旋转。 ← **G-D（S5）**。

**自封闭保证（这些是 ONLY 缺的三件）.** 第 1、3、4、5 步**全部**由已封的 exit-0 证书 G-A…G-E 支撑（计算侧完成）。整条链对**无条件** L4 唯一缺的输入是第 2 步的三个非计算命题：
- **P0（S0）**：反射保覆盖 + 同侧⟹αᵢ≤π。**genuine-open，初等，待证。**
- **P1（S1, n=8,9）**：恰一内部圆 + 无三圆共点。**已配 exit-0 证书 `05e`（L3），关闭**
  （两条弧长引理初等证明 + 四个 arcsin 不等式向外舍入区间复核）。
- **P2（S1/S2, n=10）**：Melissen 距离引理的**文献层级** —— 要么取得 Melissen 原文（路径 a），要么对距离不等式给完整自封闭重证并补上「距离不等式 ⟹ 结构结论」的归约（路径 b；G-C 已复现数值断言为部分进展）。

补齐 P0、P1、P2 后，与 G-A…G-E 按上述五步合拢，即得 n=8,9 的**无条件 L4**；n=10 另须 P2 的文献关（a 或 b）闭合。

---

## 附：诚实红线汇总

| 缺口 | [FT] 是「证了」还是「断言」 | 本仓库现状 | 性质 |
|---|---|---|---|
| S0a 反射保覆盖 | 断言（"still get a covering"，无证） | 无 | genuine-open，初等 |
| S0b 同侧⟹αᵢ≤π | 断言（"implies that αᵢ≤π"，无证） | 无 | genuine-open，初等 |
| S1(n=8,9) | **完整写出**（5 个 arcsin + 2 弧长界） | **已配 exit-0 证书 05e（L3），关闭** | 转录 + 验证（已关） |
| S1(n=10) 第一部分 | 借 Melissen（原文未取得） | G-C 复现 [FT]§3 计算断言 L3 | 文献依赖 |
| S1(n=10) 第二部分 | [FT]§3 面积法另证 | G-C 复现 L3 | 文献/转引 |
| 五边形界 (10) | FT 印刷闭式（被 PDF 破坏） | 仅验不等式（略紧），未复现精确小数 | 待精确复现 |

> **不要越界**：S3b/S4/§3/S5 四个计算关卡已 exit-0，**勿重证**。本文的任务对象只有 P0、P1、P2 三件。
