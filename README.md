# circovcir — n 个单位圆覆盖最大的圆

研究 [Erich Friedman's Packing Center: Circles Covering Circles](https://erich-friedman.github.io/packing/circovcir/)：
给定 n，求最大的 R_n，使 n 个单位圆能覆盖半径 R_n 的圆盘。等价地，求用 n 个等圆覆盖单位圆盘的最小半径 r_n = 1/R_n。

已知：n ≤ 10 已证明最优（n=5,6 Bezdek；8,9,10 Fejes Tóth），n = 11–25 只有数值记录（Melissen 1997, Tan 2018）。完整表见 `data/records.json`。

## 快速开始

```bash
uv sync                                   # Python 3.12 环境（只用 uv）
make test                                 # Python 测试 + Wolfram 自检
uv run circovcir records                  # 已知记录表
uv run circovcir verify data/configs/07/known.json --wolfram   # 双实现验证
uv run circovcir search -n 8 --starts 20  # 基线数值搜索
```

Wolfram（Mathematica 14.3）：`Get["wl/CirCovCir.wl"]`，脚本在 `wl/scripts/`。

## 目录

| 路径 | 内容 |
|---|---|
| `AGENTS.md` | 研究协议、验证阶梯、约定（agent 和人都先读这个） |
| `docs/` | 问题定义 `problem.md`、核心算法与证明 `methods.md`、文献 `literature.md` |
| `wl/` | Wolfram 包 `CirCovCir.wl`（精确/高精度验证、闭式识别、作图）、脚本、测试 |
| `src/circovcir/` | Python 包：float 快筛、配置 I/O、基线优化、Wolfram 桥 |
| `data/` | `records.json` 已知记录；`configs/NN/*.json` 具体构型（唯一真源） |
| `experiments/` | 每个实验一个目录 `YYYY-MM-DD-slug/`，可复现 |
| `research/` | `STATE.md` 当前研究状态，`LOG.md` 时间序日志 |
| `proofs/` | 严格证书（精确/区间算术）和证明草稿 |
| `notebooks/` | Wolfram 笔记本探索（不提交大输出） |
