# 研究日志（LOG）

> 追加式，最新在下。每条：日期、做了什么、结果（数值带位数与等级）、指向实验目录/构型文件。不要改写旧条目，错了就追加更正。

## 2026-10-01

- 建立仓库脚手架：双实现覆盖半径（`wl/CirCovCir.wl`、`src/circovcir/geometry.py`），已知构型 n=1,2,3,4,7 生成并 `ExactCoverQ` 精确验证（L3）。
- 基线优化（log-sum-exp 退火 + 精确候选集 active-set SLSQP 打磨，8 起点 seed 0）复现 n=5,8,9,10 已证最优值（L2）；n=6 未找到（1.7906 < 1.798）。
- 坑：浮点构型在退化 Voronoi 顶点留 ~1e-16 孔，令严格 R_max 塌缩；改用缩放证书 R/ρ（见 `docs/methods.md`）。WL 解析十进制字符串改为精确有理数，避免机器精度截断与 `1e-05` 被读成符号 `e`。
- 弧覆盖工具：ω(r,d)=2arccos((r²+d²−1)/(2rd))，以及 β→α 映射 cos(α/2)=(R²−1+4cos²(β/2))/(4R cos(β/2))，双实现（`wl/CirCovCir.wl` Arcs 段、`src/circovcir/arcs.py`），测试在两侧都通过。证明 `proofs/01-ring-symmetry.md`：f_R 只在 [β₀,β₁) 上递减且凹，所以用切线形式的 Jensen 并检查三处边界（k=6 的拐点、d≥2 的圆、α=0 的段）。证书 k=6..9 通过，k=10 失效（L(0)−A=−0.0072）。正则环 n=7..10 的 `ExactCoverQ` 为 True，n=8,9,10 由此升 L3。
- 开始去掉 H_k 的工作。读了 Fejes Tóth (2005) 原文（MSRI Publ. 52），书目已记入 `docs/literature.md`。结论：他的引理只给出"恰一圆不碰边界"，不给同心，所以不能接 01 的弧长论证。主线改为复核并修补他的面积论证（`proofs/02-remove-ring-assumption.md`，步骤 S0–S5）。
- 审计 `experiments/2026-10-01-fejes-toth-audit`（L1）：§2 单格界 θ ≤ f(α) 在 α < π/3 时反例余量 +0.085；原因是 Dirichlet 顶点只满足 |o_i q| ≤ 1。切线补丁 θ ≤ T(α) 数值上成立，可推出原 (3) 式。G2（面积界）成立。另发现定理陈述的笔误：2 sin π/(n−1) 应为 2 cos π/(n−1)。
