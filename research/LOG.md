# 研究日志（LOG）

> 追加式，最新在下。每条：日期、做了什么、结果（数值带位数与等级）、指向实验目录/构型文件。不要改写旧条目，错了就追加更正。

## 2026-10-01

- 建立仓库脚手架：双实现覆盖半径（`wl/CirCovCir.wl`、`src/circovcir/geometry.py`），已知构型 n=1,2,3,4,7 生成并 `ExactCoverQ` 精确验证（L3）。
- 基线优化（log-sum-exp 退火 + 精确候选集 active-set SLSQP 打磨，8 起点 seed 0）复现 n=5,8,9,10 已证最优值（L2）；n=6 未找到（1.7906 < 1.798）。
- 坑：浮点构型在退化 Voronoi 顶点留 ~1e-16 孔，令严格 R_max 塌缩；改用缩放证书 R/ρ（见 `docs/methods.md`）。WL 解析十进制字符串改为精确有理数，避免机器精度截断与 `1e-05` 被读成符号 `e`。
- 弧覆盖工具：ω(r,d)=2arccos((r²+d²−1)/(2rd))，以及 β→α 映射 cos(α/2)=(R²−1+4cos²(β/2))/(4R cos(β/2))，双实现（`wl/CirCovCir.wl` Arcs 段、`src/circovcir/arcs.py`），测试在两侧都通过。证明 `proofs/01-ring-symmetry.md`：f_R 只在 [β₀,β₁) 上递减且凹，所以用切线形式的 Jensen 并检查三处边界（k=6 的拐点、d≥2 的圆、α=0 的段）。证书 k=6..9 通过，k=10 失效（L(0)−A=−0.0072）。正则环 n=7..10 的 `ExactCoverQ` 为 True，n=8,9,10 由此升 L3。
- 开始去掉 H_k 的工作。读了 Fejes Tóth (2005) 原文（MSRI Publ. 52），书目已记入 `docs/literature.md`。结论：他的引理只给出"恰一圆不碰边界"，不给同心，所以不能接 01 的弧长论证。主线改为复核并修补他的面积论证（`proofs/02-remove-ring-assumption.md`，步骤 S0–S5）。
- 审计 `experiments/2026-10-01-fejes-toth-audit`（L1）：§2 单格界 θ ≤ f(α) 在 α < π/3 时反例余量 +0.085；原因是 Dirichlet 顶点只满足 |o_i q| ≤ 1。切线补丁 θ ≤ T(α) 数值上成立，可推出原 (3) 式。G2（面积界）成立。另发现定理陈述的笔误：2 sin π/(n−1) 应为 2 cos π/(n−1)。

## 2026-10-02

- n=7 无条件最优性 R₇=2（`proofs/03-n7-optimal.md`，L4 待人工复核）。按用户提示的计数论证，但不走 H_k：R>2 时单圆在 Γ_R 上弧长 ≤ A(R)=2arcsin(1/R) < A(2)=π/3，故覆盖 Γ_R（总 2π）需 t≥7 个圆触及边界；而触及 Γ_R 的圆有 d>R−1>1，覆盖不了 O，覆盖 O 还需 +1 个，共 ≥8>7，矛盾。可达性由 `ExactCoverQ[RingConfig[6],2]`=True、+1e-30=False 给出。关键是 A(2) 恰等 π/3=2π/6 踩在整数 6 上——n≥8 时 A(R*)>2π/n，硬计数失效，才要退回 01/02 的细算。证书 `proofs/certificates/03-n7-optimal.wls` exit 0（E_cover/E_max/E_pi3a/E_pi3b/E_step2 全 True；E_max 的 arccos/arcsin 恒等式用 sin、cos 同时为 0 证）。
- 把 `03` 扩成弧计数法的**三情形合集 n=3,4,7**（同一文件，用户要求）。n=3,4 比 n=7 更简单：A(R_n) 精确踩 **2π/n**（A(2/√3)=2π/3, A(√2)=π/2），所以 R>R_n 时 n 段弧总长 <2π，边界本身就盖不满，**不需要**中心扣减那一步（最优构型本就无中心圆）。n=7 踩 2π/6 比 7 少一个，由中心扣减补上。弧计数法的适用边界 = A(R_n)∈{2π/n,2π/(n−1)} 踩整数 ⟺ n∈{3,4,7}（另 n=1,2 平凡）；n≥8 两法皆失效。证书重写覆盖 7 项（E_max/E_dec/E_hit/E_cover3/E_cover4/E_cover7/E_step2），exit 0。R₃=2/√3、R₄=√2 可达性引用各自 `known.json` + `ExactCoverQ`。
- **n=11 Melissen 构型复现 + 坐标（L2）**（`experiments/2026-10-02-n11-melissen`）。读 Friedman `11.gif` 定结构：竖直镜像对称，3 个在轴上（内下 c0 / 内上 c8 / 顶 c9）+ 4 对镜像外圆。为避免像素坐标（L0），用基线优化器独立求解 `search -n 11 --starts 40 --seed 1` → **R=2.6316907726198**（13+ 位；gap vs 页面记录 2.631 = +6.9e-4，在最后一位不确定度内）。旋转镜像轴到竖直，存 `data/configs/11/20261002-melissen-baseline.json`。双验证 `verify_config.wls` wp=40：ρ(c,R)=1.0000000000000003，缩放证书 R_certified=2.631690772619807，cert_gap=−9.6e-16，紧点 19。渲染 `cover_n11.png` 与原图逐一核对一致。
  - **死路**：直接 min ρ(c,1) 做高精度对称打磨有**尺度退化**——圆心整体内收即可无限降 ρ，NMinimize/NelderMead、FindMinimum、Python active-set+对称投影、以及固定顶点 g 的 scale-pin 变体都掉进 R→√2 / 1 / 2.50 的次优盆地，而非 Melissen 盆地。正确法是**固定 R 对紧接触方程组 FindRoot**（docs/methods.md 已指明），列入 TODO。
  - **开放**：L3 精确闭式（Melissen 1997 无已发表闭式）；清掉 c0/c8/c9 的 ~1e-3 x 残差（对称固定后自然为 0）。
- **n=11 固定-R 紧接触方程组求解（高精度 ~40 位，对称精确）**（`solve_tight_opt.wls`，续前条）。按 STATE 的 TODO 走对了路：
  - **刚性诊断**（`rigidity_check.wls`）：28 条紧接触方程（镜像对称：INT 5 + BND 5 的右半 + 轴上，连同紧点坐标共 28 式 / 30 未知），Jacobian 满秩 28 ⇒ **恰 2 个内部自由度**。即 Melissen n=11 覆盖**不是刚性/孤立**的，存在 2 参数的同-R 形变族——这正是它"found"而非"proved optimal"的几何原因（n=8,9,10 的正则环是刚性的，所以能证最优）。
  - 因 2-DOF 下 R 随形变略变（把 p2 钉在 float 值解出 R=2.63145 < 基线），**用这 2 个自由度最大化 R** 定出唯一记录构型：`FindMaximum` 外层调 `solveAt(u2,v2)`（内层 28×28 `FindRoot` 定 R），收敛到 p2*=(1.77274,−0.93632)。
  - 结果 **R=2.6316907726198078**（与基线 float 一致到 ~1e-16），构型**精确竖直对称**（轴上 x 恰 0），28 条接触残差 =0（58 位）。存 `data/configs/11/20261002-melissen-tight.json`（R、坐标均 40 位十进制）。
  - 双验证 `verify_config.wls` wp=50：`covering_radius_at_R = 1.`（**精确等于 1**，不再是 float 的 1+2e-16），R_certified=2.63169077261980782251…，cert_gap=−1.0e-41，紧点 23。
  - 这是 ~40 位高精度**精确紧接触**证书（远超 float L2）；完整 L3 还差 (a) 把 2-DOF 族里 R-最优点写成精确代数数（`RootApproximant`/Gröbner），或 (b) 对该点做区间算术覆盖证书。渲染 `cover_n11_tight.png`。
  - **代数数识别尝试（结论：无实用闭式）**（`identify2.wls`、`eliminate2.wls`）：把 R 与各坐标求到 wp=120~300，用 `FindIntegerNullVector`（整数关系法 + 报告系数高度）而非 `RootApproximant`——后者高精度下总返回巨大分母的伪有理拟合（第一版 `identify.wls` 就被坑：R 被"识别"成 53 位分母有理数，是格噪声）。低度低高度（deg≤10、|系数|<10¹²）R/R²/全坐标**无匹配**；放宽 deg≤24、|系数|<10²⁰，R/R² 仍无匹配，坐标出现 deg∈{14,15,18,21} 不一致的"匹配"（度数乱 + 系数 10²⁰ = 格噪声特征，非真极小多项式）。符号消元 `GroebnerBasis`（10 条约化方程、每条总度 4、消 11 个几何变量求 R 极小多项式）**900s 超时**。**结论**：R 与坐标是**高次代数数、无实用根式/闭式**，与文献把 Melissen n=11 当纯数值记录一致，也与 2-DOF 非刚性一致（仅凭接触方程 R 非零维确定，加 max-R 稳定性只会抬度数）。→ L3 现实路线是**区间算术覆盖证书**，不是闭式。
- **n=11 L3 覆盖证书（精确算术，达成）**（`certificate.wls` → `proofs/certificates/06-n11-interval.wls` + `proofs/06-n11-coverage-L3.md`）。
  - 这是紧覆盖（~23 紧点 ρ=1），把高精度圆心四舍五入成有理数（分母 10¹⁵）会在内部紧点 (0,−1.3932)（三圆 c0,p4,p4′ 外心）开 ~3e-13 的**与 R 无关**空洞，故不能直接对有理圆心取记录 R 跑 `ExactCoverQ`（实测 False）。
  - 用 `docs/methods.md` 指明的**缩放证书**：ρ=ρ(c,R) ⇒ 单位圆放 c/ρ 处精确覆盖 D(0,R/ρ)，空洞被 1/ρ 吸收。有理圆心 ⇒ 260 个候选点全是代数数 ⇒ `rho2=RootReduce[Max Min |x−c|²]` 精确求值 =1.00000000000000031977…，`Rcert=R/√rho2`=2.63164999999999957923…。
  - **精确符号判定**：`RootReduce[Rcert−2631/1000]>0`=True（>页面记录 2.631），`RootReduce[Rcert−26316/10000]>0`=True（更强 >2.6316）。全程无浮点。
  - 产物：`data/configs/11/20261002-melissen-exact.json`（status `verified-exact`，含 `*_wl` 精确有理圆心/代数 R）；`verify_config.wls` wp=40 复核 **`exact_cover=true`**、`covering_radius_at_R=1.`、cert_gap=0、`R_max_numeric`=2.6316907726（证书 R 是保守有理下界）。证书脚本 exit 0；Python verify ok=true。`make lint test` 全过（51 pytest + 18 WL）。
  - **达成 L3（覆盖下界）**，复现并严格确立 Melissen 记录下界 R₁₁>2.631。**未**证最优性（n=11 仍 open）。

- Bezdek n=5,6 文献核实 + FT n=8,9,10 验证套件（实验 `2026-10-02-bezdek-fejestoth-verify`）。
  - 文献（已核实，去掉"待核实"）：K. Bezdek, *Über einige optimale Konfigurationen von Kreisen*, Ann. Univ. Sci. Budapest. Eötvös Sect. Math. **27 (1984) 143–151**；及 *Körök optimális fedései*（博士论文，Budapest 1979）。三处独立来源（Springer 参考表 / MSU-CRC / MathWorld）一致；FT 2005 引作 "[1979;1983]"（1983/1984 系期刊出版延迟）。FT 2005 p.361 原文给 n=5 为 Neville 1915 猜想、Bezdek 证实，r₆=**1.7988…**（Friedman 页 1.798 是截断）。n=5,6 最优构型只有镜像对称（Csikós）。
  - **R₅ 精确形式（L3「值」）**：Math.SE q/2651575 的八次多项式（误标 six-disks）其实根 1/x₀=1.6410044636…=R₅。推得 R₅ 极小多项式 `625t⁸−800t⁷+22t⁶−1776t⁵+1665t⁴+1360t³−3480t²+2112t+1296`，`IrreduciblePolynomialQ`=True（无根式，印证"只能证不能给闭式"），R₅≠φ²=2.618（镜像最优），基线构型 wp=40 覆盖 D(0,R₅) ρ=1−8e-17。证书 `proofs/certificates/04-bezdek-n5-n6.wls` exit 0。n=5 **最优性**仍 L0（Bezdek 原文未复核）。
  - **FT n=8,9,10 计算断言**：证书 `proofs/certificates/05-fejestoth-n8-n9-n10.wls` exit 0。已验证（L3）：笔误 2sin→**2cos**（`E_typo`）、正则环精确覆盖且紧（`E_ring`）、G1T 是 f 在 ᾱ 的切线且 f 在 (ᾱ,π) 凹（`E_tangent`+`E_concave`，故 α≥ᾱ 侧 G1T 成立）。**诚实开放**：G1T 小-α 区间证书（S3b，未做）；Jensen 链 (1)–(7) 字面转写 g′(ᾱ)=+0.55/+0.79/+0.85>0，与"递减"矛盾（`E_jensen` report-only，未复现，待照原文重建 S4）。整理进 `proofs/05-fejestoth-n8-n9-n10.md`。
  - **n=6 最优值搜索**：基线 1.790593 → 宽搜 200 起点 1.795281（`out/n6-wide-s200.json`）→ 镜像对称搜索（`n6_mirror.py` 族 A/B）CPU >12min 未在时限内跑完，已停，方法与命令留档供人工重跑。**均 < 记录 1.7988，诚实记为"该方法未达到"**（差 1e-3 量级，非平局）。
  - `make lint test` 通过（ruff clean；49 pytest + 18 WL；两张新证书各 exit 0）。
