# n=11 镜像对称性普查与 b=10 子情形筛查

- 日期：2026-10-11
- 问题 / 假设：n=11 最优覆盖是否必然镜像对称；R*附近是否存在非对称竞争者；b=10 的哪些子情形离 R* 远。
- 方法：
  - `census.py`：随机多起点 + LSE 退火 + `polish`，对每个局部最优求最小镜像失配（全轴扫描 + 有界一维细化）。
  - `b10_triple.py`：带约束的 b=10 搜索，模式 free / b10 / triple / triple2 / nonwheel（`polish` 的 `extra`、`ineq` 钩子）。
- 复现：
  - `uv run python experiments/2026-10-11-n11-symmetry-census/census.py 400 20261011`
  - `uv run python experiments/2026-10-11-n11-symmetry-census/b10_triple.py <mode> 60 2`

## 结果（全部 L1：浮点，“该方法未找到”）

| 情形 | 最大 R | 对称 | 日志 |
|---|---|---|---|
| 无约束（400 起点） | 2.631691（Melissen，b=9） | 是 | `out/run-400.log` |
| 无约束次优 | 2.618034（φ² 环，b=10）；2.555900（b=8） | 是；否 | 同上 |
| b=10 单组三圆共点 | 2.60939876（实为 W10 轮型） | 是 | `out/triple-60.log` |
| b=10 两组不相交三圆共点 | 2.57736108 | 未查 | `out/triple2-60.log` |
| b=10 非轮型 Voronoi | 2.55550958 | 否 | `out/nonwheel-60.log` |

## 结论与下一步

见 `proofs/20-mirror-symmetry-program.md` §5–§12。b=10 非轮型余量约 0.076，可尝试粗面积链证书；锋利部分在 b=9。
