# 研究日志（LOG）

> 追加式，最新在下。每条：日期、做了什么、结果（数值带位数与等级）、指向实验目录/构型文件。不要改写旧条目，错了就追加更正。

## 2026-10-01

- 建立仓库脚手架：双实现覆盖半径（`wl/CirCovCir.wl`、`src/circovcir/geometry.py`），已知构型 n=1,2,3,4,7 生成并 `ExactCoverQ` 精确验证（L3）。
- 基线优化（log-sum-exp 退火 + 精确候选集 active-set SLSQP 打磨，8 起点 seed 0）复现 n=5,8,9,10 已证最优值（L2）；n=6 未找到（1.7906 < 1.798）。
- 坑：浮点构型在退化 Voronoi 顶点留 ~1e-16 孔，令严格 R_max 塌缩；改用缩放证书 R/ρ（见 `docs/methods.md`）。WL 解析十进制字符串改为精确有理数，避免机器精度截断与 `1e-05` 被读成符号 `e`。
- 弧覆盖工具：ω(r,d)=2arccos((r²+d²−1)/(2rd))，以及 β→α 映射 cos(α/2)=(R²−1+4cos²(β/2))/(4R cos(β/2))，双实现（`wl/CirCovCir.wl` Arcs 段、`src/circovcir/arcs.py`），测试在两侧都通过。证明 `proofs/01-ring-symmetry.md`：f_R 只在 [β₀,β₁) 上递减且凹，所以用切线形式的 Jensen 并检查三处边界（k=6 的拐点、d≥2 的圆、α=0 的段）。证书 k=6..9 通过，k=10 失效（L(0)−A=−0.0072）。正则环 n=7..10 的 `ExactCoverQ` 为 True，n=8,9,10 由此升 L3。
