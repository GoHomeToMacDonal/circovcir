# 02 — 去掉结构假设：n = 8, 9, 10 的最优性（证明草稿）

状态：**L0 → 进行中**。目标定理：n = 8, 9, 10 时 R_n = 1 + 2cos(2π/(n−1))，且最优覆盖唯一（中心圆 + 正则环）。
骨架：G. Fejes Tóth, "Thinnest covering of a circle by eight, nine, or ten congruent circles", in *Combinatorial and Computational Geometry*, MSRI Publ. 52 (2005), 361–376（[PDF](https://library.slmath.org/books/Book52/files/18fejes.pdf)）。下文称 [FT]。计划逐步复核 [FT]，并为每个数值步骤配证书。

## 与 01 的关系

01 的弧长论证要求中心圆**恰好**是 D(0,1)。[FT] 的引理只给出"恰有一个圆不碰 ∂C_n"，并**不**给出它与 C_n 同心，所以由 [FT] 引理推不出 H_k。[FT] 用的是面积论证（Dirichlet 胞腔剖分 + Jensen），完全绕开了 H_k。因此 02 的主线是"复核并修补 [FT]"，01 保留为 n=7..10 的独立条件证明，也作为 k 环情形的教学版本。

## 步骤表

| 步 | 内容（[FT] 位置） | 状态 | 证书 / 证据 |
|---|---|---|---|
| S0 | 反射约定：可设 o 与 o_i 在 C_i、C_n 的根轴同侧（⇒ α_i ≤ π） | 待证（[FT] 无证明） | — |
| S1 | 引理（n=8,9）：恰一个圆在 int C_n 内；边界上无三圆共点。只用 arcsin 不等式 | 待做证书 | — |
| S2 | 引理（n=10）：Melissen 距离论证 + 面积论证（[FT] §3），h(ϑ) 单调且凸，Case 1/2 面积界 | **L3（基于 [FT] 转引，2026-10-09）**：h 第一性原理重建复现 FT 印刷数，h′/h″>0 区间 B&B，(9)–(13)+Case 1/2 总和<a(C₁₀) 逐位命中 FT；Melissen 原文待核实 | `proofs/certificates/05c-melissen-n10.wls`（exit 0，6 gating）|
| S3a | 单格界 G1：θ_i ≤ f(α_i) | **[FT] 缺口**：α_i < π/3 时不成立，改用切线界 G1T | `experiments/2026-10-01-fejes-toth-audit`（L1） |
| S3b | G1T 在 α < π/3 区域严格成立（区间分支定界） | **L3（完全封住，2026-10-09）**：边界面 + ring collar + 内部 B&B 三块无缝覆盖 Ω | `proofs/certificates/05b-g1t-small-alpha.wls`（exit 0；calib & P1 & BF & Pcollar & Pbb 全 True，n=8,9,10）|
| S3c | 单格界 G2：a(R_i) ≤ F(α_i)；f 凹且增，F 凹（[FT] 的代数） | L1 成立，待证 | 同上 |
| S4 | Jensen 链 (1)–(7)；修正函数 `g(α)=sin((n−2)π/(n−1)−α/2)+F(α)` 在 6π/(n−1) 处递减（[FT] 原排版丢了 (5) Jensen 分母 2(n−1) 的因子 2）| **L3（证书）** | `E_jensen`（gating）：端点恒等精确 + g′(ᾱ)<0 精确 + g″<0 区间（200 面板）|
| S5 | 取等 ⇒ 构型全等 | **L3（刚性事实封闭，2026-10-09）/ 定理 L4-条件**：等号情形的严格性（R1 f″<0、R2 F″<0、R3 g 严格递减、R4 单格取等轨迹=正则胞腔、R5 等角闭合）全部 exit-0；S5 定理 = R1–R5 与 S3b/S4/§3 证书的几何组合，无新自由系统故无 Krawczyk 盒 | `proofs/certificates/05d-s5-equality-rigidity.wls`（exit 0，R1&R2&R3&R4&R5 全 True，n=8,9,10）|

## 已发现的问题

1. **G1 缺口（S3a）**：[FT] 由 2π = Σ∠q_i o q_{i+1} ≤ Σ f(α_i) 推出 (3)。但 q_i 只是 Dirichlet 胞腔在 ∂C_n 上的顶点，只满足 |o_i q_i| ≤ 1，不一定等于 1，此时 θ_i ≤ f(α_i) 可能不成立：弦长界只有 max(2sin(α/2), 1)。补丁是用 f 在 ᾱ 处的切线 T 代替 f；(3) 只需要 Σθ ≤ ΣT(α_i)。L1 数值显示补丁成立，严格化见 S3b。
   - **S3b 完全封住（2026-10-09，L3）**：几何锁定 θ=t₂−t₁、α=∠(u₁,o,u₂)、u_j=R(cos t_j,sin t_j)−(s,0)、约束域 Ω={s∈[R−1,√(R²−1)], |u_j|≤1, α≤ᾱ}。证书 `proofs/certificates/05b-g1t-small-alpha.wls`（**exit 0**）把 M:=cos θ−cos T(α)≥0（等价 θ≤T）封在整个 Ω 上，四块无缝覆盖：(P1) **T≥f on (0,π)**（切线 + 全局凹，区间 f″<0）；(BF) **边界面 |u₁|=|u₂|=1 上 θ=f(α) 精确** ⟹ 该面 θ≤T（含正则环取等）；(Pcollar) **ring 邻域 B_ring=ring±1/160** 用一阶 KKT 梯度号引理（ring 是 KKT 边界极小非内部驻点，∇M≠0，故用梯度号而非 Hessian：dM/dt₁>0、dM/dt₂<0、d|u₁|²/dt₁<0、d|u₂|²/dt₂>0 把可行点逼到 |u|=1 面）；(Pbb) **Ω∖B_ring 内部区间 B&B**，min lower(M)=+4.7e−8/+1.2e−9/+1.8e−7（n=8/9/10，N[] 求值的有限正数），closed_all=True、stack 空、未触预算。**Cycle 9 的两个修复**：Bug 1 — centered-form 的符号梯度 `D[…Cos[T[ArcCos[w]]]…]` 含 `ArcCos'[w]=−1/√(1−w²)`，盒内 w=cos α 触 ±1 时 1−w² 跨 0 → 整个梯度区间 (−∞,∞) → corr=∞；改为**链式分解**把 w、dw/dx 保持为不含 arccos 的干净有理/三角式，Q=1/√(1−w²) 单独构造且仅在 w 严格落于 (−1,1) 时（否则退回恒有效的朴素端点界）喂窄区间。Bug 2 — worst 曾是含 ∞ 的符号 Interval 使 Exit 判定不诚实；现每个盒下界 N[] 求值并断言有限实数（非有限 → 有限哨兵 −BIG 再细分），worst 仅在**叶子**（已封或触深度）上取，且 Pbb 返回合取显式"有限实数且 ≥0"检验。**封住关键**：外盒 [smin,smax]×[−H0,H0]² 严格包含 Ω，其 s=R−1 附近（h(s)→0、|u_j|>1）的不可行角把界拖负；凡 Min[|u₁|²]>1 或 Min[|u₂|²]>1（整盒出 Ω）即丢弃，搜索塌到几千盒且 min_lowerM 转正。coverage 独立网格复核（~65–70k 可行点/各 n）M<0 违例=0、三块所有权划分之和=可行点数（无缝、无重叠），d0 两处同为 1/160。`make lint test` 全绿（52 pytest + 18 WL）。详见 `experiments/2026-10-08-g1t-small-alpha`。
2. **笔误**：[FT] 定理陈述中外环圆心到 o 的距离写作 2 sin π/(n−1)，应为 2 cos π/(n−1)。n=8 时前者为 0.868，与 r_8 = 2.247 不符。
3. **Jensen 链 (5) 的转写错误（已修）**：收尾函数本文曾字面记作 `sin(2(n−2)π/(n−1) − α) + F(α)`，在 ᾱ 求导得 g′(ᾱ)>0，与 [FT] "递减"矛盾。核对 [FT] (364–367) 原文后定位：(5) 式 ½Σ(sin βᵢ+sin γᵢ) 是对 **2(n−1)** 个 sin 项做 Jensen，正弦宗量应为 Σ(βᵢ+γᵢ)/(2(n−1)) = (n−2)π/(n−1) − α/2（PDF 排版丢了分母的因子 2 与 α 的 ½）。正确函数 **g(α)=sin((n−2)π/(n−1) − α/2) + F(α)**：满足 (7) 端点恒等 g(ᾱ)=sin β̄+F(ᾱ)，且 g′(ᾱ)<0（n=8/9/10 = −0.457/−0.207/−0.0056），区间证书证 [ᾱ,π] 递减（L3）。详见 `proofs/05` §4。
