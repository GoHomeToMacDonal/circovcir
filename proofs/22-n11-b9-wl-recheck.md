# 22 — n=11、恰 9 圆碰圆周（b=9）证明的 Mathematica 独立复核

日期：2026-10-21。对象：math-proof siege 终稿 `experiments/2026-10-20-siege-n11-b9/proof.md`（定理：11 个单位圆覆盖 D_R 且恰 9 个圆碰 S_R ⟹ R < r₁ = 26317/10000）。本文记录三份 Wolfram 证书，它们去掉了原稿的浮点/libm 假设，并逐条复核手算常数。

**定理（原稿）.** c₁,…,c₁₁ ∈ ℝ²，D_R ⊆ ⋃ D(c_i,1)，恰 9 个圆盘与 S_R 相交 ⟹ R < 26317/10000。

**与本仓库其他结果的关系.** 原稿引用的 (T10) 在本仓库中：(i) 是 `proofs/11` §1.2（覆盖原点的圆盘不碰 S_R，平凡）；(ii) 是 `proofs/21`（(B10)，L3 计算，手证待复核）。两者合起来给出 n=11 的全局上界 R < 2.6317（**不是锋利界**；Melissen 构型 R≈2.6316908，记录 2.631）。

## 等级

| 部分 | 内容 | 等级 |
|---|---|---|
| 手证（Parts R, A, B, D, E, M §1–4, O, N, W, §12） | 原稿逐步论证 | 手证；siege 内部多轮核验；**待人工复核** |
| 手算常数 | 22a：原稿 223 条数值/不等式断言全部用 50 位区间算术判定；改正后的 46 条替换陈述全真 | **L3 计算** |
| C1（No-Bridge 有限检查，Part M §5） | 原稿 `nb_check.py`（binary64 + libm 假设）；22b 独立重写，bignum 区间 + 精确有理判定 | 22b：**L3 计算**（bignum 区间 + 精确判定，无 IEEE/libm 假设）；与 `nb_check.py` 两份独立实现 |
| C2（Σ_m 无解，§11） | 原稿 `wit_exact_m.py`（Python Fraction 精确）；22c 独立重写（WL 精确有理 + 自选对偶乘子） | **L3 计算**，两份独立实现 |

整体：计算侧 L3——C1、C2 各有两份独立实现，其中 22b、22c、C2 都不依赖浮点假设；推理链待人工复核后才能升 L4。

## 22a — 手算常数（`certificates/22a-n11-b9-hand-constants.wls`）

- 方法：R = 26317/10000 精确；精度 50 的 bignum `Interval`，所有判定都把区间端点 `SetPrecision[·, ∞]` 成有理数后精确比较；恒等式用 `Expand`/`Together`；单调性用 `Reduce` 或区间细分。VAL 行容差为最后印刷位的一个单位。
- 第一次运行（原文原样）：223 条中 194 真、29 假。29 条全部是笔误或末位误差，没有一条是承重缺口；每条的后果分析都写在脚本的 `conseq` 表里，并有对应的正确陈述（如 M39c、M48c、M62、M67、M78）被验证为真。
- 值得注意的三条：
  - M50：原稿把情形划分写成 [0,0.03] ∪ [0.03,0.060331]，但 B/2 = 0.06033107 > 0.060331，漏了 (0.060331, B/2]。情形 2 的论证对整个 [0.03, B/2] 成立（M67），已改为 [0.03, B/2]。
  - M75 / X02：Lemma 4.2 的一步实际余量是 8.98·10⁻⁴，不是原稿 §13 所说的“所有余量 ≥ 10⁻³”。已改正 §13。
  - M89：Part M §4 Addendum 的解释性说法“三个角点半径 ≤ 1.38 的代价超过 B”是错的（3C(1.38)=0.1136 < B）；它不承重（C1 只用 (Q2) 本身），已改写。
- 已据此改正 proof.md（21 处，均为数值/表述，无论证结构改动）。脚本 §V 复核改正后的 46 条替换陈述，全部为真。退出码 0 当且仅当 §V 全真且每条原文假断言都有记录的后果分析。
- 运行：`wolframscript -file proofs/certificates/22a-n11-b9-hand-constants.wls`，约 7 s，输出 `22a ALL HAND CONSTANTS VERIFIED (corrected text; every original slip documented)`。

## 22b — C1：No-Bridge 有限检查（`certificates/22b-n11-b9-nobridge.wls`）

- 依据 Part M §4 的数学陈述（(FAR)、(NEAR-Y)、Lemma 1.4、(Q2)、约简规则）重写，**不是**翻译 `nb_check.py`。
- 算术：精度 20 的 bignum `Interval`（Sqrt、ArcSin、ArcCos、ArcTan、Sin、Cos）；常数由精确值 `N[Interval[{x,x}],20]` 包络；盒端点、预算是精确有理数，每个判定都在精确有理数上做。**不用机器精度 Interval**：测试发现 Mathematica 14.3 的机器精度 Interval ArcCos/ArcTan 不向外舍入，约三分之一的点值以 ~1e-16 漏掉真值。
- 自检：T1（2000 个随机盒 × 8 个函数、500 个 ArcTan 参数、常数对 50 位值的包含）、T2（B、C(1.085)、ρ(B/2) 的参考值）、T3 负对照（全预算下远 X 集非空、objX<1.2 不可证；两者都必须为 False）。
- 结构：K_X ∈ [0, B.hi] 切 48 片；每片先求远 Y 集 objY 的上界 U_Y（best-first），再证远 X 集 objX < 2π − U_Y；NEAR-Y 证近 Y 集空或远 X 集空（预算 2·10³…2·10⁶ 递增重试）；失败则二分该片（最深 10 层）。最后检查叶子片精确平铺 [0, B.hi]。
- 运行中修正（2026-10-21，均不影响可靠性）：
  1. `refute` 加最小盒宽 wMin = 10⁻¹⁰：存活盒窄于此即返回 False（保守，不丢弃任何盒）。原因：精确有理端点不像浮点那样在 ulp 处饱和，围绕一个真可行点（如片 12–13 的近 Y 集）DFS 会无限下降，内存涨到 10–22 GB、单片数小时。加上后近 Y 集在 7–11 s 内判定为“非空”，转而证远 X 集空。
- 结果（R = 26317/10000，6 个子核，45 分 36 秒；2026-10-21 07:18–08:04）：48 片中 47 片单叶通过，片 [0.03268, 0.03519]（Python 的难片附近）二分一次后两叶通过，单片最长 2552 s；共 49 叶，全部 OK，叶子精确平铺 [0, B.hi] 且 B.hi ≥ B。T1/T2 为 True，T3 两个负对照均为 False（符合要求）。末行 `22b ALL SLICES VERIFIED`。

## 22c — C2：Σ_m 无解（`certificates/22c-n11-b9-witness.wls`）

- 依据 Part W（角多面体 Φ、Theorem C、松弛系统 P̃_m(B)、半平面引理、Lemma M35、Lemma D′）重写，**不是**翻译 `wit_exact.py`。与原实现的独立之处：
  - 自己的分支定界树：根 [0,7]⁸，精确约束传播收缩盒（原实现只判空不收缩），二分最宽坐标，传播后的根先 BFS 均分为 512 个根盒（原实现 4096 个未收缩根盒）；
  - 乘子来源：直接解 Lemma D′ 的对偶 SOCP（`SecondOrderConeOptimization`，Method → "CSDP"，失败时退回默认方法），目标为 Σ|y_e| + Σ r_j|z_j| − Σ μ_i h_i + M Σ_v |g_v|（M = 7/2，Σμ = 1）；原实现用罚函数原始极小点读乘子；
  - 承重步骤：V < 0 用精确有理数计算（浮点乘子取有理数、范数用自验整数平方根上界、半平面偏移 h_k 由精度 30 的 bignum Cos/Sin 在精确有理端点处给出严格下界并下取到 2⁻⁸⁰ 网格）。
- 可信基：Mathematica 有理/整数运算的正确性，bignum `Interval` Cos/Sin 与 `N[Interval[{2π,2π}],30]` 的正确性；浮点只用来选证书数据。
- 自检：S1（常数、sqrtUp、Cos/Sin 包络）、S2（m=1..8 的约束表逐类计数，与 Theorem C 一致）、T1（R=2.6316 < R_* 时 Melissen 见证盒半宽 10⁻⁶、10⁻⁴ 必须不被认证——确实 open）、T2（R=2.6317 时同一点半宽 10⁻³ 盒可认证）。
- 运行中修正（2026-10-21，均不影响可靠性，V 的精确检查不变）：
  1. 求解器警告（`::inac`）不再当作失败（任何乘子都可用于 Lemma D′）；
  2. 对偶不再强制 g_v = 0 + 最小二乘校正，而是把 g_v 作为变量并按 M 计价——这正是 Lemma D′ 的 V；
  3. 改用 CSDP：默认内点法在近紧盒上停在最优值上方约 10⁻³ 处（`experiments/2026-10-20-siege-n11-b9/results/wl/diag22c-solver.wls`），使 m=4 的一个根盒树膨胀到 1.8 万盒；CSDP 下该根盒 899 盒。
- 结果（R = 26317/10000，3 个子核，3 分 27 秒；重跑一次计数完全相同）：

| m | 根盒 | 盒数 | 空 | 认证 | 失败 |
|---|---|---|---|---|---|
| 1,2,3,6,7,8（各） | 512 | 512 | 127 | 385 | 0 |
| 4 | 512 | 1468 | 127 | 863 | 0 |
| 5 | 512 | 1046 | 127 | 652 | 0 |

  末行 `22c ALL m CERTIFIED`，退出码 0。与原实现一样，只有 m = 4、5（Melissen 构型在两种命名下所在的标签）需要细分。

## 复现

```bash
WS=~/Wolfram/Mathematica/14.3/Executables/wolframscript
$WS -file proofs/certificates/22a-n11-b9-hand-constants.wls          # ~7 s
$WS -file proofs/certificates/22c-n11-b9-witness.wls all 3           # ~3.5 min, 3 subkernels
$WS -file proofs/certificates/22b-n11-b9-nobridge.wls 48 6           # ~46 min, 6 subkernels
```

日志：`experiments/2026-10-20-siege-n11-b9/results/wl/`（`22a.log`、`22b-all.log`、`22c-all.log`、`22c-all-run2.log`；`*-killed-*`、`22a-run1-original.log` 是修正前的记录，`diag22*.wls` 是诊断脚本，不是证书）。

sha256（运行时版本）：

```
1a45bac4b18a03e06b6d2094230e1ae9368d2aea5abbb27c2b4459c0120bab61  22a-n11-b9-hand-constants.wls
0f1e61803c5d5f9d3a8a754d786f5d8b7cdf73f5fa55b59d4292d399f89e8b43  22b-n11-b9-nobridge.wls
f5559aada523fb6260bf319170636b947936d631c8545713ae6087e536794c86  22c-n11-b9-witness.wls
```

## 剩余缺口

1. 手证部分只经过 siege 内部核验，**待人工复核**（含原稿 §13 列出的 Lemma L2 拓扑事实）。
2. 运行未由第三方独立执行；可信基是 Mathematica 14.3（22a–22c）与 CPython（原 C1/C2）。
3. 结论 R < 2.6317 不是 n=11 的锋利界（与 Melissen 的 2.6316908 相差约 9·10⁻⁶），不证明 Melissen 构型最优。
