# n=6：证明直径前提 (H0)

- 日期：2026-10-11
- 问题：去掉 `proofs/10-n6-half.md` 的前提 (H0)。用户方案：中心圆 O₁ 在 y 轴；y 轴剩余段由一个圆覆盖（对称化到 proofs/10）或至少两个圆（弧长分析排除）。
- 结果文档：`proofs/10b-n6-H0.md`；证书 `proofs/certificates/10f-n6-H0-case3.wls`、`10g-n6-H0-case2.wls`、`10lib-H0.wl`。
- 复现（证书）：`cd proofs/certificates && wolframscript -file 10f-n6-H0-case3.wls`（~71 s），`... 10g-n6-H0-case2.wls`（~25 min）。

## 探索脚本（L1 浮点，非证书）

| 脚本 | 内容 |
|---|---|
| `arcstats.py` | 已知构型的边界弧、损失统计 |
| `case3_explore.py` | 情形 3：只用损失和（Σ ≤ 12α−2π）的判据——裕量为负，不够 |
| `case3_arcs.py`, `probe3.py` | 离散化的缺口长度判据（被离散误差误导，已弃用） |
| `case3_exact.py` | 精确缺口 + Q 方向依赖的弧上界，裕量 ≈ 0.026 |
| `case3_free.py` | 与方向无关的 Q 弧上界（即 10f 判据），裕量 ≈ 4.5e−3 |
| `case2_explore.py`, `case2_closed.py` | 情形 2 的缺口与引理 V 的粗判据（closed 版不够） |
| `case2_vstar.py` | 引理 V 的三点形式（即 10g V2），最小外接圆裕量 ≈ 0.033 |
| `probe_case3.wls` | 10f 谓词的速度/负对照试探 |

运行：`cd experiments/2026-10-11-n6-H0 && uv run python case3_free.py 9`（几分钟）。

## 结论

R ∈ [R_lo, R_lo+1e−10] 时情形 3 不出现；情形 2 满足 proofs/10 引理 H2 的全部前提。合起来：n=6 最优性与唯一性不再依赖 (H0)（计算侧 L3，人工步骤待复核）。
