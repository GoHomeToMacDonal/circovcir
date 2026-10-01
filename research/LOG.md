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
