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

## 2026-10-09

- **S3b（G1T 小-α）完全封住 — L3（Cycle 9）**（证书 `proofs/certificates/05b-g1t-small-alpha.wls`，**exit 0**；实验 `experiments/2026-10-08-g1t-small-alpha`）。前八轮把命题拆成 `allok = calib && P1 && BF && Pcollar && Pbb`，只剩内部 B&B 的 **Pbb=False**；本轮修两个 bug 后全封。
  - **Bug 1（centered-form 的 ArcCos' 包裹爆炸）**：旧 `gMs=D[cos θ−Cos[T[ArcCos[w]]], s]`（gMt1/gMt2 同）含 `ArcCos'[w]=−1/√(1−w²)`，其中 w=cos α=(u₁·u₂)/(|u₁||u₂|)。盒内 w 区间触 ±1（窄/退化胞腔 w→1）时 1−w² 跨 0 ⟹ 梯度区间塌成 `Interval[{−∞,∞}]` ⟹ corr=∞ ⟹ cen=−∞。朴素端点路径里 cosv 已 clamp 到 [−1,1]，所以炸的只有 centered-form 的符号梯度。**修法（链式分解，route b 收尾）**：把 w 与 dw/dx 保持为**不含 arccos** 的干净有理/三角式；由 dM/ds=−fp·Q·sin(T)·dw/ds、dM/dt₁=sin θ−fp·Q·sin(T)·dw/dt₁、dM/dt₂=−sin θ−fp·Q·sin(T)·dw/dt₂，把 **Q=1/√(1−w²)** 单独构造，**仅当盒内 w 可证严格落于 (−1,1)（余量 eQ=1e−6）**时用 Q 的盒上最大值 Qmax=1/√(1−wabs²)（偶、随|w|增，端点取极大 ⟹ 以 Qmax 替 Q 是对 |dM/dx| 的上估 ⟹ 外界有效）；否则退回**恒有效的朴素端点界**。arccos 只在盒心数值出现一次（Mc）和作为这个单独受控的 Q 因子。
  - **Bug 2（Exit 非有限）**：旧 `worst` 可为含 ∞ 的符号 Interval，`N[worst,8]` 仍 ∞/符号 ⟹ Exit 判定不诚实。**修法**：每个盒下界 `N[Max[naive,cen],PREC]` 求值并断言有限实数（非有限 → 有限哨兵 −BIG，盒细分）；`worst` 仅在**叶子**（已封 lb≥0 或触深度 maxDepth=100）上取（旧代码把每个被细分的父盒松界也折进 worst，故 min_lowerM 永远被根盒 −0.22 钉死——这是前几轮"卡在 −0.22/−0.27/−0.28"的真正原因，而非方法失败）；Pbb 返回合取显式 `NumericQ ∧ Element[Reals] ∧ 有限 ∧ ≥0`。
  - **封住关键（丢弃出-Ω 盒）**：B&B 外盒 [smin,smax]×[−H0,H0]² 严格包含 Ω；其 s=R−1 附近（h(s)→0、|u_j|>1）的**不可行角**把界拖负（worst box 恰在此，|u₁|=1.27、|u₂|=1.06>1，点本不在 Ω）。凡 `Min[|u₁|²]>1` 或 `Min[|u₂|²]>1`（outward 下界 ⟹ 整盒每点 |u|>1 ⟹ 整盒出 Ω）即丢弃。此一改使搜索从 >5e5 盒塌到几千盒且 min_lowerM 转正。另把细分维选在 rad_i·|grad_i| 最大者（最快收 centered 修正）。
  - **结果（真 exit 0，`wolframscript -f …; echo EXIT=$?` 确认）**：calib/P1/BF/Pcollar 全 True 不变；**Pbb=True 三 n**，min lower(M)（N[] 求值的有限正数）= **n=8:+4.739e−8（3665 盒）、n=9:+1.230e−9（5379 盒）、n=10:+1.816e−7（7719 盒）**，closed_all=True、stack 空、budget_hit=False。证书打印 `CERTIFICATE OK — S3b (G1T small-alpha) CLOSED for n=8,9,10 (L3)`。
  - **coverage 无缝的 explicit 复核**（`coverage_check.wls`，独立于证书）：d0 在 Pcollar 与 Pbb inRing 两处**同为 1/160**；ring 取等点 (sstar,−tstar,tstar) 的 M=0（49 位零，margin→0 自检）；各 n 对 Ω 密网格（~65–70k 可行点）**M<0 违例=0**；每可行点恰属 {B_ring collar / |u|=1 面 / 内部 B&B} 之一，三块所有权之和=可行点数（无缝、无重叠、无缝隙）。两个 drop（|u|>1 不可行、α>ᾱ 偏侧）只移除非-Ω 点。
  - **诚实边界**：Exit 0 当且仅当 allok=True 且其所有依赖量都是 N[] 求值的有限数；未动容差、未缩约束域、未向内舍入、未把符号/∞ 塞进 Exit。S3b 由此从"部分（边界面 L3，内部开放）"升到 **L3 完全封住**。
  - 文档同步：`proofs/02` S3b 行与进度段、`proofs/05` §3b 段+状态表+净差+Research State、`research/STATE.md`。`make lint test` 全绿（ruff clean；52 pytest（1 slow deselected）+ 18 WL，0 失败；未改 wl/src）。**未 git commit**，留待人工核。
  - **去掉 H_k 的无条件最优性**仍开放，剩余硬骨头收窄为 §3 n=10 的 Melissen 距离引理（未配证书）与 S5（取等⟹全等）。

- **§3 n=10 Melissen 距离引理 → L3（基于 [FT] 转引；2026-10-09）**（`experiments/2026-10-09-melissen-n10/`、证书 `proofs/certificates/05c-melissen-n10.wls` exit 0）。去掉 H_k 的无条件最优性链里只剩 §3（本条）与 S5。
  - **Melissen 1997 博论原文：未取得。** web 搜索 + Utrecht DSpace 探针（唯一线索 handle 1874/22859 经下载核对是 Weiss *Dendroidal sets* 2007，另一篇），公网无该博论 PDF。全部以 **[FT] 2005 §3 对 Melissen 的转述**为准（`pdftotext -layout` 抽取，数值常数全干净；仅 h(ϑ) 与五边形界 (10) 的闭式被上下标破坏）。引理层级**最高 L3（基于 [FT] 转引）**，原文 pp.108–111 **待核实**。`@kirocrew-computer` MCP 声明但未配置——本任务不需要，本机 wolframscript 足够。
  - **关键事实**：本引理 ∂C₁₀ 半径 **r₁₀=1+2cos(2π/9)=2.5320888862…=R₁₀**（n=10 覆盖半径本身），**非 1.7988**（那是 n=6 记录 r₆）。由 [FT] 印刷常数 `7 arcsin(1/r₁₀)=2.841948021` 反解得同值。
  - **h(ϑ) 第一性原理重建（不信任被破坏符号文本）**：两对称单位圆共覆测度 ϑ 的弧，o 到二圆边界内交点距离。闭式（分支经 FT 印刷数验证，w=r₁₀）：cx=w cos²(ϑ/4)−cos(ϑ/4)√(1−w²sin²(ϑ/4))、cy=w sin(ϑ/4)cos(ϑ/4)−sin(ϑ/4)√(1−w²sin²(ϑ/4))、h=cx−√(1−cy²)，域 0≤ϑ≤4 arcsin(1/r₁₀)。**复现 FT 印刷数逐位**：\|pᵢpᵢ₊₃\|=2 h(th0)sin(ψmin/2)=**2.0234914…>2**、\|pᵢpᵢ₊₄\|=**2.3575386…>2**（th0=π−4 arcsin(1/r₁₀)）。被 pdftotext 破坏的 FT 闭式猜测在 ϑ=2.5 处变复数——印证不许从破坏文本重建。
  - **h 单调 + 凸（向外舍入区间 B&B）**：h′>0（35 叶、0 未闭、min lower +3.80e−7）、h″>0（9 叶、0 未闭、min lower +0.088）；每盒守卫两 sqrt 宗量>0（min +1.16e−7），避开早期朴素端点的依赖包裹爆炸（曾使 √(负区间) 吞掉符号）。
  - **面积界 (9)–(13) 逐位命中 FT**：(9) 8 sin(π/4)=5.656854249、(9′) 7 sin(2π/7)=5.472820377、(11) 段=0.27675335、(13) 8F=4.92397937、(13′) 7F=4.332295377；a(C₁₀)=πr₁₀²=**20.14224>20.1422**；**Case 1 总和 20.14216 < a(C₁₀)**、**Case 2 总和 19.9278 < a(C₁₀)** ⟹ 矛盾（引理成立）。
  - **诚实边界**：五边形界 (10) 的 FT 印刷闭式被破坏，改验「4 边长 1、1 边长 2 的圆内接五边形真最大面积 ≤ FT 所述 2.284572282」——本仓库真最大 **2.28454…≤2.284572282**（略紧，不等式成立），**未复现 FT 精确小数**。另 [FT] 正文一处 `arcsin(2/r₁₀)+5 arcsin(2/r₁₀)` 第二项应为 `arcsin(1/r₁₀)`（干净值 2.940546309 为准，排版笔误）。
  - 文档同步：`proofs/05` §4b+§3 Research State+§5 表、`proofs/02` S2 行、`docs/literature.md` Melissen 条目、`research/STATE.md`。**未 git commit**，留待人工核。

- **S5 取等 ⟹ 构型全等（刚性事实 L3；定理 L4-条件）** — `proofs/02` 步骤表最后一关（原「待写细节」）封闭。证书 `proofs/certificates/05d-s5-equality-rigidity.wls`（**exit 0**，R1&R2&R3&R4&R5 对 n=8,9,10 全 True），实验 `experiments/2026-10-09-s5-rigidity/`（单入口 `run.wls` + README）。
  - **判断：S5 不是零维代数系统，不配 Krawczyk。** 对比 `proofs/07` n=11 **局部**最优性确实归约为 22×22 KKT 盒；S5 的唯一性来自**等号情形的刚性** —— 严格凹 Jensen（(3)、(6)）与严格单格界（G1T、G2）各自把每个胞腔钉死到正则胞腔，无残余自由参数，故无新自由系统可 Krawczyk。证书只做「等号⟹各参数相等/接触被迫」依赖的严格性事实。
  - **R1/R2（f″<0、F″<0 于 (0,π)，向外舍入 300 面板 + 自适应二分）**：worstUpper(f″)=−3.16e−5/−3.93e−5/−2.75e−6、worstUpper(F″)=−9.33e−5/−1.10e−4/−1.18e−4（n=8/9/10），0 面板失败。⟹ (3)(6) 严格凹 Jensen 取等 ⟺ 所有 αᵢ 相等。
  - **R3（g 在 [ᾱ,π] 严格递减）**：g′(ᾱ)=−0.457271/−0.207107/−0.005572 精确 + g″<0 区间（worstUpper≈−0.45~−0.47，200 面板），复用 S4 结论。⟹ 收尾界取最大仅 α-mean=ᾱ，结合 α-mean≥ᾱ（由 (3)）⟹ Σαᵢ=kᾱ。
  - **R4（单格取等轨迹=正则胞腔，RootReduce 精确）**：T(ᾱ)=f(ᾱ)、关键恒等式 **R·sin(π/k)=sin(3π/k)**（RootReduce=0，即 f(ᾱ)=2π/k=θ̄）、ring 顶点 \|u\|²=1 且 Cos[ring α]=Cos[ᾱ]（RootReduce=0）。⟹ 每格 αᵢ=ᾱ、双接触、θᵢ=2π/k ⟹ 全等正则胞腔。
  - **R5（等角闭合，精确）**：k·θ̄=2π（精确）+ `RingConfig[k]` 精确紧覆盖（E_ring）。⟹ k 段 2π/k 弧铺满 ∂C_n ⟹ 中心等角 @ 2cos(π/k) = `RingConfig[k]` 模旋转。QED S5。
  - **两个工具修复（诚实记档，非放宽量词）**：(1) R1/R2 的 α→0 第一面板 worstUpper 曾 +1.4e−4/+5.6e−3（panelsFail=1/2），是**区间高估**（f″、F″ 分子趋 0，端点包裹松）非真实变号 —— 逐点 f″≈−1e−4 严格负，自适应二分（最大深度 1–5）即清零。(2) R4 的三恒等式 `Simplify===0` 全判 False（arcsin/arccos 形），改 `RootReduce`（精确，与 `CirCovCir`sgn` 近零同工具）后全 True。另修一处注释 `*)` 提前闭合的 WL 语法噪声（`T_i*).`）。
  - **诚实边界**：R1–R5 本身 L3；S5 **定理** = R1–R5 与 S3b(05b)/S4(05)/§3(05c) 证书的几何组合，取最弱依赖等级：**n=8,9 为 L4-条件**（待人工复核 [FT] §2 面积论证骨架 S0/S1 引理 + Dirichlet 剖分），**n=10 另搭未取得的 Melissen 原文**（pp.108–111）。至此 `proofs/02` 四个计算关卡 S3b/S4/§3/S5 全部 exit-0。
  - 文档同步：`proofs/02` S5 行、`proofs/05` §4c + §5 表 + 净差 + Research State、`research/STATE.md`。`make lint test` 全绿。**未 git commit**，留待人工核。

- **S0/S1 缺口的问题化文档（写作任务，非证书）** — 新建 `proofs/06-remaining-gaps-problem.md`。从 [FT] 2005 §2 原文（PDF `pdftotext -layout` 抽取，pp.363–367）逐字抽出 S0（反射约定）与 S1（n=8,9 结构引理）的确切陈述，并对无条件 L4 仅剩的三个**非计算**缺口做诚实定级：
  - **S0（反射约定）= genuine-open（初等）**：[FT] 把「反射保覆盖」("…and still get a covering")与「同侧⟹αᵢ≤π」("…implies that αᵢ≤π")两处都**断言而未证**。拆成命题 P0a、P0b（初等平面几何，待补）。
  - **S1(n=8,9) = 转录 + 机械验证（非开放难题）**：[FT] §2 的 arcsin 论证**完整写出**（5 个不等式 6·arcsin(1/r₈)<π 等 + 两条弧长上界 2arcsin(1/r)、2arcsin(2/r)）。缺口仅是本仓库尚无弧长引理的独立证明与五个不等式的向外舍入区间复核 —— 做完即关闭。
  - **S1(n=10) = 文献依赖**：[FT] 明说 arcsin 法失效（8·arcsin(1/r₁₀)>π），改借 Melissen 距离论证 + §3 面积法。G-C(05c) 已复现 §3 计算断言 L3，但 Melissen 原文 pp.108–111 未取得；清晰路径 (a) 取得原文 / (b) 自封闭重证 + 补「距离不等式⟹结构结论」归约。
  - 文档含：§1 四个 exit-0 证书（S3b/S4/§3/S5 + 可达性/笔误）作公理引用；§2 一处定义全部记号（α/θ/f/F/ᾱ/Dirichlet 胞腔/根轴/Ω/T）；§3 [FT] §2 S0/S1 逐字转录 + 保真度 + 定级；§4 命题 P0/P1/P2；§5 五步合拢定理（P0+P1+P2 与四证书合拢 ⟹ 无条件唯一性）+ 自封闭保证（这三件是 ONLY 缺口）。PDF 抽取存 `$KIROCREW_SCRATCH/ft2005-layout.txt`（§2 抽取干净，五个 arcsin 常数无破坏）。**不碰 proofs/02、05 的证明内容；未 git commit。**

- **P1 结构引理（n=8,9）配证书 → L3 关闭（2026-10-09）**（证书 `proofs/certificates/05e-p1-structure-n8-n9.wls`，**exit 0**；实验 `experiments/2026-10-09-p1-structure/`，单入口 `run.wls` + README）。`proofs/06` 三缺口里**唯一纯机械、机器能关**的一件（S0 反射=genuine-open，S1(n=10)=Melissen 文献，均非本任务）。
  - **命题**：n∈{8,9}，{Cᵢ} 覆盖 C_n ⟹ (i) 恰一圆在 int C_n 内；(ii) 相交 bd C_n 的圆无三者共点。[FT] §2 的 arcsin 论证已完整写出，缺口仅两条弧长上界引理的初等证明 + 四个数值不等式的向外舍入区间复核。
  - **两条弧长上界引理（初等几何，证明写在证书头注）**：
    - **L-arc1（单圆）** bd C_n 弧 o-张角 ≤ 2 arcsin(1/R_n)：bd C_n ∩ 闭单位圆是一段弧，两端点都在该圆内 ⟹ 弦 ≤ 直径 2；半径 r 圆上长 L 弦张中心角 2 arcsin(L/(2r))（关于 L 增），L=2 得 2 arcsin(1/r)。= 现成 `CirCovCir`MaxCoveredArc`。
    - **L-arc2（三圆共点）** ≤ 2 arcsin(2/R_n)：公共点 p 在三圆内 ⟹ 每圆 |p−心|≤1；被覆盖点 x 在某圆内 |x−心|≤1 ⟹ |x−p|≤|x−心|+|心−p|≤2 ⟹ 被覆盖 bd 点全在 D(p,2) 内，两端弦 ≤4，同律给 2 arcsin(2/r)。= **本次新增** `CirCovCir`MaxCoveredArcTriple`（带 usage + `wl/tests` 回归；单侧纯几何上界，不涉 wl↔src 双实现候选集不变量，故 Python 侧无对应、未为凑而改，AGENTS.md §3 已在 README 说明）。
  - **四个不等式向外舍入区间复核（WL `Interval`，取 LHS 包络上端点 < π 包络下端点，严格 <π）**：6 arcsin(1/R₈)（LHS_up 2.767326081，余量 **0.3743**）、4 arcsin(1/R₈)+arcsin(2/R₈)（2.942412903，0.1992）、7 arcsin(1/R₉)（2.989550105，0.1520）、5 arcsin(1/R₉)+arcsin(2/R₉)（3.111686536，**0.0299** 最紧，n=9 三圆共点）。四项全 True。
  - **诚实边界**：[FT] 把 `6 arcsin(1/r₈)` 印成 **2.76326081**，真值 **2.767326081**（论文"76326"↔"767326"数字转置笔误）；两者皆 <π，结论不受影响，证书核验真值并记录笔误。其余三条逐位命中 [FT] 印刷数。gating 6 项（L-arc1/L-arc2 符号恒等 + 四不等式）全 True，真 exit code=0（`echo EXIT=$?` 确认，无管道/timeout 掩盖）；每个 gating 量为 `Max[Interval]`/`Min[Interval]` 的有限实数，未把符号/∞/未求值 Interval 塞进 Exit。
  - 文档同步：`proofs/06` P1 命题+§5 合拢链/保证+诚实红线表、`proofs/02` S1 行、`research/STATE.md`（已确立 + 剩余缺口）。`make lint test` 全绿（68 pytest，1 slow deselected + 20 WL，0 失败；2026-10-10 复核，证书 05e 重跑 exit 0）。至此 `proofs/06` 对 n=8,9 的无条件 L4 仅余 **P0 反射约定**（初等，genuine-open）；n=10 另需 Melissen 原文（P2）。

- **n=12..25 全部复现 Friedman 记录（2026-10-09；L2，n=19/25 L3）** — 实验 `experiments/2026-10-09-structured-12-25/`（README 有完整表）。
  - **方法**：按记录图片 + 层数提示（与 O 相交的圆数 b：12:9, 13:10, 14:10, 15:11, 16–19:12, 20:13）播同心环种子 → 高温起步光滑退火 + 精确候选集 active-set polish（30 进程，BLAS 单线程）→ 抽活跃集（T 三圆共点 / B 两圆交点在 ∂O）→ **多项式 KKT**（每个活跃点自带点变量，方程全二次）Gauss–Newton wp=50，3 步二次收敛（残差 ≤1e-60），独立 `MaxCoveredRadius`(wp=50) 复核到 ≤1e-46 → `circovcir verify --wolfram` ok。
  - **结果**（差 = 本构型 R − 页面截断下界，均 <1e-3 ⇒ 复现非改进）：12: 2.76929324985416205903（b=9）；13: 2.88479188177984910691（10）；14: 3.01448125798817914200（10）；15: 3.14324130132054031207（11）；16: 3.24443787790418505061（12）；17: 3.34972926145191095471（12）；18: 3.44628275030480365615（12）；19: √13（12，六角格 19 点，`ExactCoverQ` True、+1e-20 False，**L3**）；20: 3.69210531804115451775（13）；21: 3.80452253053674664262（13）；22: 3.94864456319881300470（14）；23: 4.00073971139114041227（15）；24: 4.07661342397408727758（15）；25: √6+√3（16，**D8 闭式**：O + 8@2cos(π/8)·e^{ikπ/4} + 8@(2+√2)·e^{i(π/8+kπ/4)} + 8@4cos(π/8)·e^{ikπ/4}，`ExactCoverQ` True、+1e-20 False，**L3**）。构型 `data/configs/NN/20261009-*.json`。
  - **坑（死路记档）**：(1) Pool(30)×numpy 默认 32 BLAS 线程 ⇒ 负载 ~400，n=21 慢数倍；`search.py` 顶部强制 `OMP/OPENBLAS/MKL_NUM_THREADS=1`。(2) 第一版 KKT 用外接半径²−1 / 含 √ 的交点式，符号 Jacobian 巨大、`/.` 代入慢到 watchdog 超时；改多项式形式后每个 n ~1 min。(3) `N[机器数, 140]` 不提升精度 ⇒ 初值须 `SetPrecision`，否则 Newton 停在 1e-19。(4) n=19、25 全部候选点都紧，KKT 秩亏、Gauss–Newton 发散 ⇒ 改为从 float 坐标识别闭式（两者都是简单代数构型）。(5) n=21、24 KKT 秩亏 2 但收敛且独立复核一致，构型有效，是否为连续族未判。
  - 页面现标 n=11..20 \"Proved by VoxEquinox in 2026\"（L0，未核实，未加入 `docs/literature.md`）。**未 git commit**。

- **n=100 探索 + L2 存档（2026-10-09）** — 实验 `experiments/2026-10-09-n100-explore/`（README 有全过程）。页面无 n=100 记录。
  - 新工具（实验内）：`fast.py` Delaunay 候选集精确覆盖半径（比全三元组快约 150×，与 `geometry.covering_radius` 一致）+ SLP 打磨（活跃集取 3·step 内；按 step 独立收缩会让 LP 锯齿，n=25 卡在 4.058）；`run.py` 多族种子；`ils.py` 扰动搜索；`bscan.py` 外环圆数扫描；`prep_kkt.py` → 复用 `kkt.wls`。
  - 结果：**R₁₀₀ = 8.6578719165130917604273575652738899943**（L2，`data/configs/100/20261009-ils-kkt.json`），b=33 个外圆，152 个活跃点（119 三圆共点 + 33 边界点），961 维 KKT 满秩。两次独立找到（六角格种子、b=32 种子）；b 扫描 28..38 最终都收敛到 b≈33。六角密度启发式上界 9.094（出处未核实），达到 95.2%。
  - 坑：`circovcir verify --wolfram` 包装 600 s 超时（n=100 的 WL 验证约 60 min，需直接跑 `verify_config.wls`）；`kkt.wls` 高精度 `MatrixRank` 在 961 维上卡住超过 30 min，已改为大系统用机器精度秩，并加 `nocover` 参数。2026-10-10 复核：Python `circovcir verify` ok（152 紧点）。

- **P0 反射约定（[FT] §2 S0）补证 → L3 关闭（2026-10-10）**（证书 `proofs/certificates/05f-p0-reflection.wls`，**exit 0**，8 gating 全为符号/精确判定；证明写在 `proofs/06-remaining-gaps-problem.md` §4 P0）。
  - 坐标：oᵢ=(0,d)，根轴 y=h=(d²+R²−1)/(2d)，镜像 d′=(R²−1)/d；同侧 ⟺ d²≤R²−1。
  - **P0a**：根轴下方由 |p−oᵢ′|²−|p−oᵢ|²=2(d−d′)(y−h)≤0 直接覆盖；上方是圆弓形=弧的凸包，弧上 |p−oᵢ′|²−1=−2d′(y−h)≤0。`Reduce` 给出更强刻画：Cᵢ∩C_n⊆Cᵢ′ ⟺ d≥√(R²−1)。
  - **P0b**：Dᵢ⊆Cᵢ ⟹ 胞腔弧在 {y≥h≥d}，从内点 oᵢ 看方向单调且全在闭上半平面 ⟹ αᵢ≤π（取等 ⟺ d²=R²−1）。
  - **P0c（新增，[FT] 未提）**：反射归一化不丢唯一性——若归一化=RingConfig 而某环圆是反射所得，撤销反射后内部三重点附近出现未覆盖点（k=7,8,9 精确判定）。
  - 剩余：n=8,9 无条件 L4 仅待人工通读 [FT] §2 面积论证骨架；n=10 仍待 P2（Melissen）。

## 2026-10-10 人工核验文档 + G2 面积界补证（证书 08，L3）

- 新文档 `proofs/REVIEW.md`：已闭合证明（T1 n=3,4,7；T2 n=8,9；T2′ n=10 条件；T3/T4 n=11；T5 n=19,25）的完整证明过程，CAS 步骤写「见 xxx.wls 门 Gk」，手证步骤标【人工】，[FT] 差异表 §C.10，复核清单 §F。全部证书 2026-10-10 重跑 exit 0。
- **发现缺口**：[FT] (6) 的单格面积界 G2：a(Rᵢ) ≤ F(αᵢ) 在仓库里只有 L1（audit 浮点），此前「四关卡全封」的表述漏了它。已补：
  - αᵢ ≥ π/3：a(Rᵢ)=S(θᵢ)+τ，|τ|=½ab sin α，弦长界 c²≤2−2cos α（a,b≤1）⟹ θ≤f(α) ⟹ a(Rᵢ)≤F(αᵢ)；
  - αᵢ < π/3：Rᵢ ⊆ 单位扇形 ⟹ a(Rᵢ)≤αᵢ/2 < U(αᵢ)（U=F 在 ᾱ 的切线，端点余量 ≥0.18）；
  - 用切线 U 代替 (6) 的 Jensen，收尾函数 G=sin(2π/k)+sin((k−1)π/k−α/2)+U 显然凹，G′(ᾱ)<0 精确 ⟹ 递减；k·G(ᾱ)=πR² 精确。
  - 证书 `proofs/certificates/08-review-supplement.wls`（exit 0）：H1 弦长引理 Resolve、H2 F″<0 对一切 r>1 Resolve、H3–H9 精确/有理区间。
- 新写手证（[FT] 无证）：Dirichlet 胞腔复形同构（REVIEW §C.3）、取等⟹RingConfig 的直接论证（§C.8，o₀=o 由 k 个外交点同在两等半径圆上）。待人工复核。

- **P2（n=10 结构引理）路径 b 自证 → 计算 L3（2026-10-10）**（`proofs/08-p2-n10-selfcontained.md`；证书 `proofs/certificates/05g-p2-n10-selfcontained.wls`，**exit 0**，20 gating，约 3.5 min；实验 `experiments/2026-10-10-p2-n10-selfcontained/`）。
  - 引理 B：[FT] 的「h 在对称位置极小」改写为 β_ρ（过 p、起点为 Re^{ix} 的单位圆的终点角）的三条性质（β 在 [−a_max,0] 上不减；φ=β(x)+β(−x) 在 [0,s*] 上递减；2β(0)=H(ρ)），区间 B&B 验证；不需要「内交点」条件。距离界 |pᵢpᵢ₊₃| ≥ 2.0023、|pᵢpᵢ₊₄| ≥ 2.3328。
  - **[FT] (13) 依赖 G1（α<π/3 时不成立）**：只用 05b 的切线界时 Case 1 余量为 −7.9e−4，论证失败。引理 L：逐格 a(R)+μθ ≤ F(a*)+μf(a*)（α≥π/3 时初等，α<π/3 时用粗界），恰好重得 8F(a₀)=4.92397937、7F(b₀)=4.33229538。
  - 引理 P：边长只有上界的一般五边形 ≤ 2.28458（真最大值 2.2845429；阈值 2.28454 时 B&B 不闭合，作反向对照）。
  - [FT] 印刷问题：ϑ₁+ϑⱼ 的不等号方向印反；(10′)(11′) 与 2×(10)、2×(11) 不一致。
  - **更正 `proofs/06`**：G2（a(Rᵢ) ≤ F(αᵢ)）只有 L1，是 n=8,9,10 主链的计算侧缺口，之前漏列。同日已由证书 `08` 补到 L3（见上条）。
  - 踩坑：B&B 分界点要取二进有理数；WL 注释里的 `f'(a*)` 会提前闭合 `(*`；wolframscript 语法错误时仍 exit 0，须以末行 `CERTIFICATE OK` 为准。

## 2026-10-10 n=5 独立证明尝试：左右拼接框架（第一步，约化问题精确重得 R₅）

- 实验 `experiments/2026-10-10-n5-independent/`：`tight.wls`（旋转使覆盖原点的圆 C1 在 +y 轴，列紧点）、`reduced.wls`（Gröbner 消元）、`angle_form.wls`（角度式 + 三项检查）、`frontier.py`（右侧两圆 Pareto 前沿）。
- 结构（数值最优，L2）：C1=(0,d*)，d*=0.9531549472491301；右侧 D2≈(1.2323,0.4175)、D3≈(0.6039,−0.8439)，左侧镜像。7 个紧点**全部**在 Γ=∂(C_n∖C1)=A∪B 上（A=∂C_n 未被 C1 覆盖部分，B=C1 在 C_n 内的背部边界），无内部三重点 ⟹ 只要求覆盖 Γ 的松弛有望是紧的。
- 约化（对称拼接）：D3 过 (0,−R) 与 (0,d−1)，D2 以 T 与 X_A 为对径点。右侧条件的角度式（ψ 从底点量起）：
  π − arccos((R²+d²−1)/(2dR)) ≤ 2 arcsin(1/R) + 2 arctan(√(4−(R+d−1)²)/(R+1−d))。
  max_d 取等 ⟹ **R = R₅**：消去 d 后结式含 Bezdek/Neville 八次多项式因子（`reduced.wls`，精确，L3「约化问题的值」）；R₅+1e−6 时 max_d gap=−3.5e−6。
- 检查（数值，L1/L2）：B 弧交接处余量 0.32 rad（B 约束不紧）；D3「两底点在边界」引理 DE 全局优化吻合到 1e−11；重建的 5 圆构型 CoveringRadius(wp40)=1。
- 一般（非对称）前沿 G(φ_e)：结构公式与无结构 SLSQP+采样复核一致到 1e−13（φ_e∈[−0.3,0.3]）；偶凸性 G(φ)+G(−φ)−2G(0) ≥ 4.6e−5（4 组 (R,d)，φ≤0.6）⟹ 对称拼接 WLOG（**仅 L1 证据**）。
- 未闭合（证明缺口）：(a)「两圆在右、两圆在左」不是显然的，需组合引理（T_R、T_L 由不同圆覆盖；每对覆盖含角点的连续段）；(b) D3 引理、D2 对径引理的手证；(c) 偶凸性的区间证书；(d) d 小（C1 不碰 ∂C_n）情形：4 圆覆盖整圆需 R ≤ √2 < R₅，平凡排除。

## 2026-10-10 n=5 最优性独立证明：计算侧闭合（证书 09a–09e，L3）

- 文档 `proofs/09-n5-independent.md`（拼装见 §7′）。证明链：
  L1（C1 必触及 ∂C_n）→ L2（四段 A 弧缺一不可、按位置排序、P 点范围 |ψ_P| ≤ w ≤ 0.088）→ 按 B 的覆盖方式分为好情形 G 与坏情形 (a)(b)(c)。
  - 好情形：在窗口 W 内用闭式到达函数 E。φ₃(ψ)（E = c 的解）是凸函数，由此得 φ₃(ψ)+φ₃(−ψ) ≥ 2φ₃(0) > 0，其中 φ₃(0) > 0 来自 L8。
  - 坏情形：用 fits 判据做全局区间扫描。
- 证书（全部 exit 0，末行 CERTIFICATE OK）：
  - `09a-n5-basic.wls`：L1、L2 的数值门，以及定义域 R ∈ [1.641, 1.643]、d ∈ [0.845, 1]；
  - `09b-n5-L8-gap.wls`：gap < 0，区间 B&B 加 22 次消元多项式（含八次因子）、根计数，带反向对照；约 2 min；
  - `09c-n5-existence.wls`：精确代数构型，ExactCoverQ = True（d* 为八次代数数）；约 2 min；
  - `09d-n5-local.wls`：窗口 W 内 E_φ, E_ψ > 0、Qn < 0、锐角、外接圆半径单调；6.5 min；
  - `09e-n5-sweep.wls`：F1–F4 全局扫描，299419 个盒，约 2 h，带反向对照。首跑日志夹有一行 license 噪声；**干净重跑 exit 0、CERTIFICATE OK、同样 299419 盒、7018 s，无噪声**（`out/09e-rerun.log`）。
- 死路：
  (1) 固定 φ* 下界——D₂ 能够到 B 的底部；
  (2) E 的联合偶凹性——Hessian 有正特征值 +0.58。
- 仍为【人工】：单调性与闭性、L2 排序、分情形、fits 判据、弧连通、隐函数凸性推理。待人工复核后可升 L4。

## 2026-10-11 n=6：直径前提下的最优性与覆盖方式唯一性（计算侧 L3；R₆、存在性 L2）

- 用户前提 (H0)：两圆 C1=D((0,a),1)、C2=D((0,−b),1) 覆盖 y 轴直径，右/左半各由另两圆补全。文档 `proofs/10-n6-half.md`，实验 `experiments/2026-10-10-n6-proof/`。
- 归约：H1 计数（10α<2π ⟹ 没有圆同时碰左右边界弧，每侧恰两圆）；H2 弧连通 + 闭性 ⟹ 某单位圆含 V、T2、X(w)，w∈[0,2α]（或 a↔b 反射情形）。
- 证书 10a（F1–F4）、10b（B1 m(R_lo)<0、B2 m(R_hi)>0，147 499 盒）、10c（L1–L5，~35 s）、10d（N 外三点不可容纳，26 882 113 盒，8 837 s）全部 exit 0。R₆ := m(R) 唯一零点 ∈ (1.798867827575, +1e−3)。
- 结论（在 H0 下）：R ≤ R₆；R=R₆ 时 (a,b)=(a₆,b₆) 唯一、w=0，C3=D(mid(T1,X0),1)、C4=外接圆盘(V,T2,X0)，左右镜像——构型唯一且仅有镜像对称。与 Bezdek r₆=1.7988…（L0）一致，属**复现**。
- 数值（L2）：R₆ = 1.79886782757755437114579356374527604409660111，a₆ = 0.93548542820120509732…，b₆ = 1.01058133672818553079…（wp80 牛顿残差 <1e−76）。构型 `data/configs/06/20261011-half-critical.json`，`make verify` ok（Py 8 紧点，WL wp40 gap 1.5e−37）。
- 失败/死路：Gröbner 消元求 R₆ 极小多项式 5400 s 超时（`out/elim.log`）；在整个 N_ab 上直接证 Hessian 正定因区间依赖跑不完（>25 min 超时）→ 改为半径 1/1280 的核心盒 Hessian（475 盒）+ 核心外 G(R_lo)>0（中值形式，4 019 盒）；朴素区间包络做 L5 也 >20 min 未完。
- 10d 首次日志末尾混入另一次运行的残片，已无包装干净重跑：同为 26 882 113 盒，8 642 s，exit 0（`out/10d-rerun.log`）。
- 待办：(H0) 本身的证明；R₆ 闭式 / 区间法存在性证书（升 L3）；H1/H2 人工复核。

## 2026-10-11 n=6 弧长表述（用户方案：直径两圆 + 上半两圆）

- 实验 `experiments/2026-10-11-n6-arc/arc.wls`（wp50，单入口）。前提同 proofs/10 的 (H0)：C1=D((−p,0),1)、C2=D((q,0),1) 覆盖水平直径；上半盘只由 C1,C2,C3,C4 覆盖；C3 ∋ Q1,P12（由 |Q1Q2|>2 与左右反射，这一步在 (H0) 下是 WLOG）。
- **字面目标 l1/2+l2/2+l3 太松**：l3 允许与 C1 弧重叠，上界退化为 θ1+θ2+4α≥π，p=q=1 时给 r≤1.830372022604501（L1/L2，仅 Wolfram），比 R6 大 0.0315，排除不了任何东西。
- **修正**：只计 C3 在 Q1 之后的新弧。极值 C3 = 过 Q1,P12 的第二个单位圆（第一个就是 ∂C1），新弧 = 2β3，β3=arccos((r²+|c3|²−1)/(2r|c3|))，于是 F(r,p,q)=θ1+θ2+2β3+2α−π，剩余弧需 ≤2α（C4 弦长 2）。
- **结果（L2 数值，单实现）**：F=∂pF=∂qF=0 的 wp50 根 r=1.79886782757755437114579356374527604410，与 proofs/10 的 R6 差 4.7e−45；(p,q)=(b6,a6)；Q1,P12,X 三角形锐角 (51.66°,71.54°,56.80°)；|X Q2|=2；(p,q) Hessian 特征值 −42.95, −6.71（局部极大）。R6+1e−3 处粗网格 max F=−0.0048（证据，不是证明）。
- **结论**：该方案与 proofs/10 的三点问题是同一个约束（镜像标号），给出同一阈值和同一极值构型；它把 10d 的 4 维 B&B 降到 (r,p,q) 3 维且有闭式，但 **(H0) 仍是前提**，没有解决卡点。严格化还缺：C3 新弧 ≤ 2β3 对钝角/边界情形的论证（全局证书）。
- **更新（同日）：F 的 L3 证书。** 新增 `proofs/certificates/10e-n6-arc-sweep.wls`（exit 0，末行 CERTIFICATE OK）。人工引理 H2'：由弧的连通性和 10a F1，承担 V（即用户的 P12）的那个圆一定含 X0，所以 10d 的自由参数 w 可以去掉。10e 的三个门：A0（N_ab 上 w=0 时为锐角）；S（N_ab 外 V,T2,X0 不可容纳，三维 B&B，5 482 291 盒，1 488 s，10d 为 26 882 113 盒、8 837 s）；C0 负对照。(R6,a6,b6) 处外接圆半径² − 1 = 1.4e−38。链条 10a F1 + H2' + 10e + 10b + 10c(L3–L5) ⟹ 在 (H0) 下 F < 0 对所有 r > R6 成立（计算侧 L3），相当于定理 10 的第 1–2 条。(H0) 仍未证。proofs/10 新增 §3'。

## 2026-10-11 n=6：证明直径前提 (H0)（计算侧 L3）

- 用户方案：O₁∋0 置于 y 轴（a∈[R−1,1]）；y 轴剩余段 S=[−R,a−1] 由一个圆覆盖（情形 2）或至少两个圆（情形 3）。文档 `proofs/10b-n6-H0.md`，实验 `experiments/2026-10-11-n6-H0/`。
- 半径约化到 R∈[R_lo, R_lo+1e−10]（含 R₆），证书全程用这个区间。
- **情形 3（证书 10f，L3，220 909 盒，71 s）**：P∋q 是另一圆；见证点（P 弦下端、∂O₁∩∂P 交点）迫使第三圆 Q 靠近原点，弧半角 ≤ θ(1+|w|)；缺口 ∂C∖(I₁∪I_P) 不能被 {2α,2α,2α,2θ_Q} 覆盖（分组/搭桥判据）。负对照：R=1.79528 的三重对称覆盖不被排除。
  - 死路：只用损失和 Σ(2α−|Iₖ|) ≤ 12α−2π 的判据裕量为负（−0.0096 / −0.008，`case3_explore.py`）——三重对称局部最优 1.795281 的弧也恰好铺满，只有缺口分段结构能区分。离散缺口长度判据（`case3_arcs.py`）给出 −0.0024 是离散误差，细化后 +0.0045。
- **情形 2（证书 10g，L3，G2 337 盒 + V2 2 889 915 盒，约 25 min）**：帽子引理 P∩{x≤0}⊆C₂*=D((0,y),1)（用户的对称化）；两侧缺口 > 2α ⟹ 两侧各恰两圆；引理 V：右侧两圆各覆盖 A_R 一端长 ≥|A_R|−2α 的端段，故含 {V*,T2P,X0} 或 {V*,T1,Y}，三点不可容纳。⟹ V*∈O₃∪O₄，proofs/10 的 H2 前提全部成立。这也关闭了 proofs/10 里"左侧圆不参与覆盖 V"的残余前提。
- 唯一性：反射情形给 a=b₆>1 与 O₁∋0 矛盾；x>0 时 T2*′ 旁的边界点无人覆盖 ⟹ P=C₂*。
- **结论**：n=6 的 R≤R₆ 与唯一性不再依赖 (H0)；计算侧 L3，【人工】步骤（弧覆盖组合判据、闭性/拓扑论证）待复核。R₆ 值与存在性仍 L2。
