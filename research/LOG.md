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
- **S4 Jensen 链 (1)–(7) 从原文重建 + 修正转写错误（L3，`E_jensen` 升为 gating）**（实验 `2026-10-02-bezdek-fejestoth-verify`，续前条）。
  - 从 PDF 原文（`$KIROCREW_SCRATCH/ft2005.pdf`，`pdftotext -layout` 提取干净，§2 364–367 页）逐式转录 (1)–(7)。定位 bug：旧字面转写 `g=sin(2(n−2)π/(n−1)−α)+F(α)` 的 g′(ᾱ)=+0.55/+0.79/+0.85>0 与"递减"矛盾，**不是**符号/F 定义错（本仓库 `f`、`F` 与 [FT] 印出的 f′、F′ 符号恒等），而是 **(5) 式 ½Σ(sin βᵢ+sin γᵢ) 的 Jensen 项数是 2(n−1)**，正弦宗量应为 Σ(βᵢ+γᵢ)/(2(n−1))=(n−2)π/(n−1)−α/2（PDF 排版丢了分母因子 2 与 α 的 ½）。
  - **正确函数 g(α)=sin((n−2)π/(n−1)−α/2)+F(α)**。两重验证：(7) 端点恒等 g(ᾱ)=sin β̄+F(ᾱ) **精确成立**（字面版给 sin(2β̄)≠sin β̄，自相矛盾）；g′(ᾱ)<0。
  - **区间证书（L3）**：`E_jensen` 现 gating，三项全 True —— 端点恒等 `Simplify[…]===0`；g′(ᾱ)<0 精确符号（n=8/9/10=−0.457/−0.207/−0.0055722，40 位）；g″(α)<0 ∀α∈[ᾱ,π] 用 WL `Interval` 向外舍入 10⁻²⁵、200 面板，0 面板失败。(A)+(B)⟹g 在 [ᾱ,π] 严格递减，正是 [FT] (7)。证书 `05` exit 0（`CERTIFICATE OK`），所有旧检查（E_typo/E_ring/E_fbar/E_tangent/E_concave）保持 True 未放宽。
  - 文档：`proofs/05` §4 重写为完整 (1)–(7) + 修正说明 + L3；`proofs/02` S4 行与"已发现的问题"更新；`proofs/05` §5 表、Research State、STATE.md 同步。**S4 关闭**；去掉 H_k 的无条件最优性仍开放（剩 S3b 小-α 区间证书 + §3 n=10 Melissen 距离引理）。
  - `make lint test` 通过。
- **n=11 KKT 乘子方程组 + λ 符号 + 二阶条件**（2026-10-08，实验 `2026-10-08-n11-kkt`，`run.wls 80`）。
  - 表述：max R s.t. h_t(c,R) ≤ 0，t 为 18 个活跃紧点（9 内部 Voronoi 顶点：h=外接半径²−1；9 边界点：h=R²−|y_ij|²，y_ij 为两单位圆外交点）。h>0 ⇔ 该处开洞。
  - **一阶（全坐标 23 维，不假设对称）**：18×23 Jacobian 满秩 18，null(Gᵀ)=0 ⇒ **λ 唯一**；**18 个 λ 全 > 0**（最大 B=0.167，最小 J=0.0121），镜像对 λ 精确相等。⇒ 无冗余接触，每个紧点都"受力"。
  - **方形对称 KKT 系统**：10 约束 + 12 条 ∂L/∂(q,R)=0，22×22，FindRoot wp=80 残差 0（78 位）。**R_KKT = 2.631690772619808205521501159505696105167116847823853445969749**。
  - **更正**：旧 `20261002-melissen-tight.json` 的 R=2.63169077261980782251…（"40 位"）只有前 ~16 位是 max-R 点——外层 `FindMaximum` 是机器精度；R_KKT − R_stored = +3.83e-16。L3 证书（R ≥ 2.63165）不受影响。
  - **二阶**：活跃集切空间 5 维（含旋转），去旋转后 Lagrangian Hessian 4 个特征值 −0.281, −0.255, −0.222, −0.165，全负。配合严格互补（λ>0）⇒ 二阶充分条件成立：**Melissen 构型（模旋转）是 R 的严格局部极大**（等级 L2：wp=80 数值，未做区间证书）。之前说的"2 自由度"是**接触等式**族的维数；在不等式表述下 R 沿这 4 个方向（对称 2 + 反对称 2）都严格下降。
  - 构型存 `data/configs/11/20261008-melissen-kkt.json`，`make verify` wp=40：covering_radius_at_R=1.、R_gap=2.6e-37、cert_gap=0，Python ok。
  - 意义：这 22 条方程（10 接触 + 12 稳定性）就是 R 的完整"边界条件"（零维）；后续求极小多项式应消元**这个**系统，不是旧的 10 条接触方程（那组在 R 上非零维，这是 900s 超时的原因之一）。

## 2026-10-08

- **S3b（G1T 小-α）部分封住**（`experiments/2026-10-08-g1t-small-alpha`，证书 `proofs/certificates/05b-g1t-small-alpha.wls`，exit 1）。几何锁定（来自 2026-10-01 audit 的 `cell()` + Dirichlet 定义）：边界胞腔 o=(s,0)，顶点在 Γ_R 极角 t₁≤t₂，u_j=R(cos t_j,sin t_j)−o，**θ=t₂−t₁**（O 处张角）、**α=arccos((u₁·u₂)/(|u₁||u₂|))**（o 处张角）；约束域 Ω={s∈[R−1,√(R²−1)], t_j∈[−h(s),h(s)]⟺|u_j|≤1, α≤ᾱ}，h(s)=arccos((R²+s²−1)/(2Rs))。
- float 校准（`screen.py`/`screen2.py`，seed 20261008）：正则环取等点 s*=2cos(π/k)、t_j=∓π/k 复现 α=ᾱ、θ=f(ᾱ)、margin→0（机器零，三 n）。四个结构发现：(1) f 在 (0,π) 全局凹（f″<0，0/500 正）；(2) 边界面 |u₁|=|u₂|=1 上 **θ=f(α) 精确**（max|θ−f|=5e−15）；(3) 内部 |u_j|<1 时 θ 可 >f(α)（+0.083，G1 缺口）⟹ 不能退化成 θ≤f≤T；(4) (s,t₁,t₂)-空间 **sup(θ−T)=0 仅在 ring 点取到，二阶负定触点**。
- 证书封住两块 **L3**：**(P1) T≥f on (0,π)**（T 是 f 在 ᾱ 的切线 + 全局凹，区间 f″<0 向外舍入 10⁻²⁵、300 面板、0 失败）；**(BF) 边界面 θ=f(α) 精确** ⟹ 该面 θ≤T（含正则环取等轨迹）。
- **仍开放（诚实）**：内部 |u_j|<1（P2 ring collar Hessian 负定 + P3 内部 3D 区间 B&B）。朴素 WL `Interval` 在 arccos((u₁·u₂)/(|u₁||u₂|)) 与符号 Hessian 的 |u|^(3/2) 分母上**跨 0 包裹**：collar(δ₀=1/20) Hessian 区间矩阵 entry 非 Interval（1/|u|^(3/2) → (−∞,∞)）；B&B 60000 盒/深度 28 内 min_margin_enclosed 停在 −0.32/−0.47/−0.55（高估），预算耗尽未封。**未动容差、未缩约束域、未向内舍入**。
- Cycle 4 计划：换**不含 arccos/归一化**的区间表述。候选 (a) 解析证内部 max(θ−T) 必在 |u_j|=1 面取得（则 P1+BF 封全域）；(b) cos-空间区间 `cos θ ≥ cos T(α)` + centered-form 收紧 + collar 用梯度 Lipschitz 盒界（非 Hessian）。
- **route (a) 否证（2026-10-08，`screen3.py`/`screen4.py`，seed 20261008，N≥4e5）**：|u_j| 由 (s,t_j) 钉死（|u_j|²=R²+s²−2Rs cos t_j），**无独立径向自由度**——route (a) 字面「固定 θ 减小 ρ_j」不是 Ω 内运动；边界面是曲线 |t_j|=h(s)。落到真实变量后：(1) dG/dt₁、dG/dt₂（G=θ−T）**双符号**（min dG/dt₂=−1.58、max dG/dt₁=+0.89），无全局单调坐标把内部点抬到面；(2) **同-s 面支配不成立**——反例 s=2.325460,t₁=−0.404509,t₂=−0.124867（|u₁|=0.9966,|u₂|=0.3666 强不对称），内部 G=−0.0903 > 同-s 对称面 G=−0.1059（超 +1.5e−2）。θ≤T 仍逐点成立，失败的是「面≥内部」传输。**死路记档，不再走 route (a)。** Cycle 5 走 route (b)。（注：此 cycle 的子会话因 kiro-cli 登录态过期中断，否证结论已在中断前写入 README/screen，由 Kiro 核验并落档。）
- `make lint test` 全绿：52 pytest（1 slow deselected）+ 18 WL，0 失败（未改 wl/src）。**未 git commit**。
- **n=11 严格局部最优 L3（Krawczyk 区间证书）**（2026-10-08，`experiments/2026-10-08-n11-kkt/krawczyk.wls` → `proofs/certificates/07-n11-local-opt.wls`，exit 0，约 15 s；文档 `proofs/07-n11-local-optimality.md`）。
  - K1：对称 22×22 KKT 系统，盒半径 1e-45，K(X) ⊂ int X（收缩比 2e-42）⇒ 唯一 KKT 点。近似点先在 150 位 Newton 精化——run.wls 存的 λ 只有约 40 位（LeastSquares 用了 wp/2），直接用会使 K 与 X 不相交（第一次失败的原因）。
  - K2：λ 区间下界全 >0（最小 0.01205）。K3：Finsler（ρ=1，规范行 e₅），中点有理矩阵 − 1e-30·I 精确正定（λ_min 0.0447；`PositiveDefiniteMatrixQ` + Sylvester），条目宽度 4e-84。K4：其余圆心间隙 ≥ 1.04，几何间隙 ≥ 3.1。K5：286 个候选点 = 18 活跃 + 236 证 f<1 + 26 在 K 外 + 5 由对称恰为 J + 1 精确共线（S0,S1,S2）。
  - 坑：WL 注释里写 `u*)`、`R*)` 会提前闭合 `(*`，导致 ToExpression 语法错。轴上候选点（镜像对中垂线 = y 轴、轴上圆心的对径点）区间算法无法区分它与 J，需用对称性精确处理。
  - 结论（L3）：c* 是模旋转的严格局部极大，且精确覆盖 D(0,R*)。全局最优仍开放。

- **S3b 续（Cycle 4-5，仍部分）**：试两条封内部 |u|<1 的路，均未全封，但定位清楚、无硬凑。
  - **route (a) 边界面单调性归约——否证**：Ω 中 |u_j| 由 (s,t_j) 钉死，无独立径向自由度；边界面是曲线 |t_j|=h(s)。逐顶点单调 dG/dt_j 双符号（违例大量），同-s 对称面不支配不对称内部点（n=10 反例 s=2.325460,t₁=−0.404509,t₂=−0.124867,|u₁|=0.997,|u₂|=0.367,α=0.533<ᾱ,θ=0.280,G=−0.0903<0 但 >同-s 面 G=−0.106）。route(a) 作为干净引理死。
  - **route (b) cos-空间——去包裹成功、依赖高估未封**：M=cos θ−cos T(α)≥0 等价于 θ≤T。|u_j|∈[0.21,1] 远离 0 ⟹ 无 arccos/|u|^(3/2) 包裹；cos α 干净区间；n=9,10 符号 Hessian 已是 interval matrix。但朴素端点区间依赖高估（s 共享），B&B 120000 盒 min_lowerM −0.22/−0.27/−0.28（真值 float min M≥+7e−4），collar Hessian 盒太宽 Sylvester 下界负。cert `05b` 仍 exit 1（P1+BF 封取等轨迹 L3，P2cos/P3cos 开放）。
  - Cycle 6：centered/mean-value form 收依赖（宽度 O(δ²)）+ ring 梯度精确 + Hessian PSD 小盒；退路：固定 (t₁,t₂) 对 s 单变量区间定号降到 2D B&B。`experiments/2026-10-08-g1t-small-alpha/screen3..5.py`。
  - `make lint test` 全绿（52 pytest + 18 WL）；未改 wl/src；未 git commit。
