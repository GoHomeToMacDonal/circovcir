# 2026-10-09 n=100 探索（无页面记录）

- 问题：n=100 个单位圆能覆盖多大的圆？结构是否延续 n≤25 的"外环 b 个圆 + 内核"？
- 方法：`fast.py`（Delaunay 候选集的精确覆盖半径，比全三元组快约 150 倍，与 `geometry.covering_radius` 一致；SLP 打磨，活跃集取 3·step 内的候选点）；`run.py`（hex / hexcore / rings / random 四类种子 × 16，退火 + 打磨）；`ils.py`（扰动 + 打磨、只接受更好）；`bscan.py`（固定外环数 b 播种：相邻外圆交点恰在 ∂O 上，内核取六角格）；`plot.wls`（作图）。BLAS 单线程，固定种子。
- 复现：`uv run python run.py 100 16` → `ils.py out/n100-s0.json 40 30`；`bscan.py 100 28 38 6 12` → `ils.py out/bscan-starts-b32-33-34.json 40 30`；`wolframscript -file plot.wls <json> <png> </dev/null`。

## 结果（L1，float；参考实现复核 ρ(c,R) ≤ 1+4e-15）

| 阶段 | 最好 R | b |
|---|---|---|
| 多起点 64 个（最好的是 hex 种子） | 8.6354908611 | 33 |
| ILS 30 链 × 40 轮 | **8.6578719162** | 33 |
| b 扫描 28..38（6 种子 × 12 轮 ILS） | 8.6452199715（b 种子 33） | 33 |
| 从 b=32/33/34 最优再做 ILS 30 链 × 40 轮 | **8.6578719161**（来自 b=32 种子的链） | 33 |

- **b 倾向收敛到 33**：种子 b=28..38 打磨后 b 会漂移；R>8.62 的结果最终 b 全是 32..34，ILS 后的最好结果全是 b=33（种子 b=32、33、34 都收敛过去）。
- **8.6578719161 被两次独立找到**：第一次来自 hex 种子，第二次来自 b=32 种子。两份构型按圆心到原点距离排序后，最大差 6e-5，判为同一构型（相差一个旋转或反射）。第二好的盆地 8.6551535 也重复出现了 6 次。
- 面积启发式上界 √(n·3√3/(2π)) = 9.0939（出处未核实），当前达到它的 95.2%。
- 本方法没找到更好的构型，不代表不存在（AGENTS §4）。

## L2 存档（2026-10-09）

- `data/configs/100/20261009-ils-kkt.json`（`verified-numeric`），float 来源 `…/20261009-ils-float.json`。
- **R = 8.6578719165130917604273575652738899943**（KKT wp=40；float 值 8.657871916122 低了 3.9e-10，未收敛完全）。
- 活跃集 152 个（119 三圆共点 + 33 边界点；下一个候选低 1.4e-4，切分干净）。`prep_kkt.py`（Delaunay 活跃集）→ `../2026-10-09-structured-12-25/kkt.wls … 40 nocover`：961×961 方阵 KKT 满秩（机器精度秩），4 步二次收敛，残差 5.5e-71，约 23 s。
- 双验证：Python `circovcir verify` ok（R_max=8.65787191651305，紧点 152）；WL `verify_config.wls` wp=40（约 60 min）R_max−R=3.9e-36，cert_gap=0，紧点 152。
- 坑：(1) `circovcir verify --wolfram` 的 Python 包装 600 s 超时，n=100 必须直接跑 `wolframscript -file wl/scripts/verify_config.wls`；(2) `kkt.wls` 在 wp 下算 961 维 `MatrixRank` 超过 30 分钟，已改成大系统用机器精度秩，并新增 `nocover` 参数跳过重复的 `MaxCoveredRadius`（n=12 回归一致）。

## 下一步

- 加入对称种子（D_k 外环 + 匹配的内核），以及更长或多级的扰动搜索。
- λ 符号与二阶条件（局部最优性）尚未检查。
