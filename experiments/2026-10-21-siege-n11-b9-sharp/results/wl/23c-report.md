# 23c — GLOB + LOC 在 R 区间 J 上的 Wolfram 独立复核

日期：2026-10-21。对象：`experiments/2026-10-21-siege-n11-b9-sharp/out/proof.md` §1 Steps 2–4（Appendix C §1、§3.1–3.2，Appendix E §0、§3.1–3.2，Appendix A Part W）。原计算只由一份 Python 实现 `wit_exact_J.py` 跑过一次（日志 `out/judge/r3/wit/`）。本证书 `proofs/certificates/23c-n11-b9sharp-glob-loc.wls` 是第二份独立实现：从我们自己的 22c（单半径 26317/10000 的 Part W 证书）扩展到区间 J = [R̄, 2.631692]，按数学陈述重写，没有翻译 `wit_exact_J.py`。从原稿只取属于陈述的数据（φ̄、φ̄′ 的定义、η、τ、τ′、λ、λ′、δ₁、F5 圆心）。

## 方法要点

- P̃_m(B; J)：σ_k (k≤8) 满足 |σ_k| ≤ R_hi、n̂_k·σ_k ≥ R_lo·u_k，u_k 是 n̂_k·e(t) 在区间两端的有理下界（精度 30 的 bignum Interval，下取到 2⁻⁸⁰ 网格，要求 u_k > 0）；σ_9 满足 |σ_9| ≤ R_hi、σ_9,x ≥ R_lo；|c_E| ≤ 1，|c_k| ≤ RHO = sqrt_up(R_hi² − 1)；配对约束 (P2)–(P4) 按 Theorem C。用半平面前精确检查盒宽 ≤ 3/2。
- A = 2·ArcSin(1/R_lo) 的 bignum 区间上端点（有理数），所以 A ≥ 2a(R) 对所有 R ∈ J。
- 树：不收缩原盒，只在“传播后盒”的最宽坐标中点处把原盒切成两半（切点严格在原盒内部）。每片叶子记录路径（坐标、切点、左右）。最后精确检查：路径重建等于叶盒；同一节点的切法一致且路径前缀无关 ⇒ 内部两两不交；叶体积之和精确等于 7⁸ ⇒ 叶子恰好铺满根 [0,7]⁸。
- 乘子：直接解 Lemma D′ 的对偶 SOCP（目标就是 V，g_v 为自由变量按 M = 7/2 计价，Σμ = 1），`SecondOrderConeOptimization` Method → "CSDP"；`::inac` 不算失败。承重步骤 V < 0 全用精确有理数，范数用自验整数平方根上界。
- 传播后最宽 < 10⁻⁹ 仍未判定的盒是硬 FAIL，绝不丢弃；超预算也是 FAIL。
- 只用 bignum Interval（精度 30），端点经 `SetPrecision[·, ∞]` 转有理数；不用机器精度 Interval。

## 进展记录

（运行中逐步追加）

- 数据核对（sanity 模式，8 s）：S1（J 常数、sqrtUp、Cos/Sin/ArcSin 包络）True；S2（m=1..8 的 51 条配对约束逐类计数与 Theorem C 一致，19 个锚点）True。Q、Q′ 精确正交（QᵀQ = I，det = 1）；λ、λ′ 是 1..11 的双射，E、F 是内圆盘 1、2；F5 圆盘 3 = D₈（m=5）/ D₃（m=4）；D₁..D₉ 在 F5 中逆时针；φ̄、φ̄′ ∈ Φ_A（精确）；frame 偏差（40 位）1.223·10⁻¹² / 1.223·10⁻¹²（与 Python 打印的 1.22e-12 一致）；φ̄ 与由 F5 圆心按 Lemma W 第 2 步算出的见证区间相差 ≤ 4.4·10⁻¹³（m=5）、7.4·10⁻¹³（m=4）；τ 与 tan(θ₀/2)（θ₀ 按 App. E §0.1/§3.1 的公式）一致到 10⁻¹⁶；R̄ < I_* 下端，R_hi > I_* 上端 + 10⁻⁶。
- 关于 φ̄′ 的说明：App. E §0.2 印出的是 12 位小数；`frame` 实际使用的是 10⁻¹⁵ 网格上的值（如 φ̄′₄ = 2.870134724192586，不是 2.870134724193）。脚本从 φ̄ 按定义（含 2π 包络）重算 10⁻¹⁵ 网格值，并检查它与印出的 12 位小数之差 ≤ 5·10⁻¹³。这只是印刷精度问题，不影响可靠性（任何有理中心都可以）。
- LOC（`loc` 模式，各 5 s）：m=5、m=4 均 44/44 认证。负对照：φ̄ / φ̄′ 立方体半宽 10⁻⁶、10⁻⁵ 不被认证；由 F5 圆心算出的见证盒半宽 10⁻⁶ 不被认证；δ = 10⁻⁶ 的 44 个 LOC 系统（m=5、m=4）认证数均为 0/44。
- GLOB 试点（m=5，与 U 相交的 4 个根盒，8 子核，235 s）：14216 盒，7110 叶（认证 6937、local 173），0 失败；173 个 local 叶的传播盒都精确落在 U 内。驱动采用“每任务 ≤ 400 盒，未处理栈重新排队”的轮次方式。

## 结果（`all` 模式，8 子核；run 1：645 s，run 2：635 s，两次计数逐项相同，run 2 记录 EXIT=0）

末行 `23c GLOB+LOC VERIFIED`。

| m | 根盒 | 测试盒 | 叶 | 空 | 认证 | local | 分裂 | 失败 | 铺满检查 | 时间 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1,2,3,6,7,8（各） | 512 | 512 | 512 | 0 | 512 | 0 | 0 | 0 | 通过 | 6 s |
| 5 | 512 | 14734 | 7623 | 0 | 7450 | 173 | 7111 | 0 | 通过 | 235 s |
| 4 | 512 | 18422 | 9467 | 0 | 9236 | 231 | 8955 | 0 | 通过 | 340 s |

- 铺满检查（每个 m）：路径重建与叶盒相同、同一节点切法一致、路径前缀无关（⇒ 内部不交）、叶体积和精确等于 7⁸（⇒ 覆盖根 [0,7]⁸）。全部为 True。local 叶的传播盒都精确落在 U（m=5）/ U′（m=4）内。
- 没有“空”叶：根盒是在传播盒中点处切出的，所以每片都与 Φ_A 的盒包络相交；Φ_A 外的部分随所在叶一起被认证。Python 的 3272 个空叶来自它的均匀 4096 根网格。两份实现的树不同，计数不可比，可比的是结论：两者都是“每片叶空、已认证或在 U/U′ 内”，m ∉ {4,5} 时没有 local 叶。
- LOC：m=5（U, Q, λ）与 m=4（U′, Q′, λ′）的 44 个系统 𝒮(v, ι, e)（11 个圆心 × {x,y} × {±1}，δ₁ = 3/1000，M = 7/2）全部有精确 V < 0 证书。LOC 立方体与 GLOB 的 U 是同一个对象 `cube[frames[m]["phib"]]`；Lemma LOC 的其余前提也都检查了：U 宽 2η ≤ 3/2，J 的前提 RHO ≤ 2.45、R_hi < 2.64，δ₁ 为正有理数，U ⊆ 根。
- 负对照（两次运行都对）：N1 φ̄、φ̄′ 立方体半宽 10⁻⁶ 和 10⁻⁵ 在 J 上不被认证；N2 由 F5 圆心算出的 Melissen 见证盒半宽 10⁻⁶ 不被认证；N3 δ = 10⁻⁶ 的 LOC 系统，m=5、m=4 各 0/44 被认证。
- 诊断（不承重，`23c-diag-locscan.wls`，对 δ 做 14 步几何二分）：δ*(1/1024) ≤ 2.4541·10⁻³（m=5，L = 2.513），≤ 2.4902·10⁻³（m=4，L = 2.550）。Python locscan 是 2.4466·10⁻³ / 2.4907·10⁻³，两者吻合（差别在二分分辨率 ≈ 0.06%/步 和乘子质量）。δ₁ = 3·10⁻³ 比证得的扩散上界大约 22%。

## proof.md 中的欠说明处（都不影响可靠性）

1. **Q′（τ′）在 proof.md 里没有给出。** Appendix G(b) 只印了 m=5 的 τ = 1331857233103593/2⁴⁸。τ′ = −68511808261983/942727686399593 只出现在 Python 日志 `out/judge/r3/wit/loc4.log` 的头一行，本证书从那里取。Lemma LOC 对任何精确有理旋转都成立，Step 5 也只需要“某个”精确旋转，所以不影响结论；但要按原稿复现就需要这个数，应补进 Step 4 或 App. G。我们检查过：Q′ 精确正交，cos(2·arctan τ′) 与 θ′₀ = π/2 − (φ̄₇+φ̄₈)/2 + φ̄₅ 的余弦一致到 10⁻¹⁶。
2. **φ̄′ 的精确值。** App. E §0.2 只印了 12 位小数。程序实际用的是按 `frame` 的规则“φ̄_{k+5} − φ̄₅（φ̄_{9+j} = φ̄_j + 2π），舍入到 10⁻¹⁵ 网格”得到的有理数，例如 φ̄′₄ = 2.870134724192586。只照 §0.2 的小数复现会得到另一个（同样可接受的）立方体 U′。本证书按规则重算，并检查与 §0.2 的差 ≤ 5·10⁻¹³。
3. Step 4 的结论写的是“every φ ∈ U”，Lemma LOC（App. C §3.2）给的是 φ ∈ U ∩ Φ_A。用到它的地方 φ 都来自 Lemma W_J，本来就在 Φ_A 中，所以无影响。
4. Step 3 的计数（17634/24582 盒、3272 空等）是 Python 树特有的。正文把它们当作“输出”来引用是可以的，但它们不是结论的一部分。

本次没有发现 proof.md 中 Steps 2–4 的数学错误：Part W_J 链条（Lemma W_J、Theorem C_J、Cor. W1_J、M35_J、D′、Lemma LOC）按陈述实现后，得到与原 Python 相同的结论。

## 可信基与等级

可信基：Mathematica 14.3 的精确有理/整数运算，bignum Interval（精度 30）的 Cos/Sin/ArcSin 与 N[Interval[{π,π}],30]（S1 用 60 位值做了抽样检验），脚本正确执行。浮点（CSDP）只用来选乘子。GLOB/LOC 现有两份独立实现（Python Fraction 与 WL 精确有理），计算侧达到 **L3**。推理链（Steps 0–6 的手证部分）仍待人工复核。

## 复现

```bash
WS=~/Wolfram/Mathematica/14.3/Executables/wolframscript
$WS -file proofs/certificates/23c-n11-b9sharp-glob-loc.wls all 8      # ~11 min，8 子核
$WS -file proofs/certificates/23c-n11-b9sharp-glob-loc.wls sanity     # 数据核对 + 负对照，~10 s
$WS -file experiments/2026-10-21-siege-n11-b9-sharp/results/wl/23c-diag-locscan.wls   # 诊断，~2 min
```

日志（`experiments/2026-10-21-siege-n11-b9-sharp/results/wl/`）：`23c-all.log`、`23c-all-run2.log`（证书两次完整运行）、`23c-pilot5.log`（试点，m=5 的 4 个根盒）、`23c-diag-locscan.log`。

sha256：

```
87267d3933109e8faa4f02897c4eafbfc9c7b77db10ccabc2ff0e8e87d14b54d  proofs/certificates/23c-n11-b9sharp-glob-loc.wls
1412b96755c11517119a6a93f27f0e95255972f27446a47dff64d61f8b5af322  results/wl/23c-diag-locscan.wls
92b6876f434679da7b41f1702e5ffdea5284deb42d8810b396dbbe64b185d432  results/wl/23c-all.log
0d96dd87080084ad64ef39206c0e06fd46e4e82d72c3e65c33a5286a8aa18d85  results/wl/23c-all-run2.log
8d2a1f39595ddf99532c99d9300e27ed22a40eb56e232b772682a6f6dc20a21c  results/wl/23c-diag-locscan.log
```
