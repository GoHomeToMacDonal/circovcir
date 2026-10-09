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
