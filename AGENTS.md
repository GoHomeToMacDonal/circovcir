# AGENTS.md — circovcir 研究协议

本仓库研究 **n 个单位圆覆盖最大圆**（[Friedman: circovcir](https://erich-friedman.github.io/packing/circovcir/)）。这是困难数学问题：数值上“看起来对”远不等于对。本文件是所有 agent 与人的工作契约，开工前先读完，并读 `research/STATE.md` 了解当前状态。

## 1. 环境与命令

- **Python 只用 uv**：`uv sync`、`uv run …`、`uv add <pkg>`（会写 `pyproject.toml` + `uv.lock`）。禁止 `pip install`、禁止系统 python。
- **Wolfram Mathematica 14.3**：`wolframscript` 位于 `~/Wolfram/Mathematica/14.3/Executables/wolframscript`（不在 PATH；可设 `WOLFRAMSCRIPT`）。也可用 `.mcp/wolfram_mcp.py` 提供的 MCP 工具 `wolfram_eval` / `wolfram_plot` 做交互式计算。
- 常用：

```bash
make test          # pytest（不含 slow）+ WL 自检 wl/tests/run_tests.wls
make lint          # ruff
make verify CONFIG=data/configs/07/known.json   # Python + Wolfram 双验证
make known         # 重新生成 data/configs/*/known.json
uv run circovcir search -n 11 --starts 50 --out data/configs/11/20261001-baseline.json
```

- 临时文件放 `$KIROCREW_SCRATCH`（或实验的 `out/`），不要写 `/tmp`，不要写进仓库根。

## 2. 分工：什么用 Wolfram，什么用 Python

| 任务 | 首选 | 原因 |
|---|---|---|
| 精确验证（代数数、等号判定） | **Wolfram** `ExactCoverQ` | `RootReduce`/精确符号判定 |
| 高精度 R、紧点结构 | **Wolfram** `MaxCoveredRadius[..., WorkingPrecision->50]`、`TightPoints` | 任意精度 + 显著性算术 |
| 闭式识别 | **Wolfram** `IdentifyClosedForm`、`RootApproximant`、`FindIntegerNullVector` | |
| 紧约束方程组精确/高精度求解、Gröbner、`Reduce`/`CylindricalDecomposition` | **Wolfram** | 符号能力 |
| 作图 | **Wolfram** `CoverPlot`（导出 png 到 `results/`） | |
| 大规模多起点搜索、批量统计 | **Python** `circovcir.optimize`（numpy/scipy） | 快、易并行 |
| float 快筛 | **Python** `circovcir.geometry` | |
| 区间算术证书 | 二选一：WL `Interval`/`CenteredInterval`，或 `mpmath.iv` | 必须保证向外舍入 |

共享逻辑只能放在 `wl/CirCovCir.wl` 与 `src/circovcir/`；实验目录里不要复制粘贴算法。

## 3. 核心算法的不变量

`docs/methods.md` 的“有限候选集定理”是整个项目的地基，**两份独立实现**：`wl/CirCovCir.wl` 和 `src/circovcir/geometry.py`。
- 改其中一份 ⇒ 同步另一份 ⇒ `make test` 两边全过。
- 任何新验证器先在 n=1,3,4,7（已知精确解）上通过，并加回归测试。
- 测试不准为了通过而放宽容差；先找原因。

## 4. 证据等级与验证阶梯（最重要）

| 等级 | 含义 | 最低要求 |
|---|---|---|
| L0 | 想法 / 未复核外部笔记 | — |
| L1 | float 数值 | Python `covering_radius ≤ 1+1e-9` |
| L2 | 双实现高精度一致 | Python + Wolfram（wp ≥ 40）`verify_config` 一致；构型已存 `data/configs/` |
| L3 | 精确 | 精确闭式构型 + `ExactCoverQ` 为 True；或完整区间算术证书 |
| L4 | 定理 | `proofs/` 中证明 + 每个计算步骤的可复现证书 |

规则：
- 任何陈述（日志、STATE、对用户的汇报）都要带等级。
- “改进记录”至少 L2，且要给出：R 的 ≥ 15 位有效数字、与记录的差、紧点数、构型文件路径。差 < 1e-9 时视为**平局/数值噪声**，须 L3 才能宣称。
- 记录值 `data/records.json` 是页面印刷的十进制**下界**（截断），比较时考虑最后一位的不确定性。
- 一次失败的数值搜索**不能**证明不存在更好构型；只能记为“该方法未找到”。
- 不要只依据文档里的数字汇报进展；以实际文件与重跑结果为准。

## 5. 数据约定

- 构型唯一真源：`data/configs/NN/*.json`，schema 见 `data/configs/README.md`。坐标存十进制字符串，单位圆、目标圆心在原点。
- `known.json` 由脚本生成，不手改；新构型不覆盖旧文件，用新名字。
- `*_wl` 字段会被 `ToExpression` 执行：只加载本仓库生成/审过的文件。
- `status` 只能按阶梯升级，并在 `checks` 里写明验证命令、精度、结果。

## 6. 研究流程

1. 读 `research/STATE.md`，选一个开放问题；写清假设。
2. `cp -r experiments/_template experiments/YYYY-MM-DD-<slug>`，单入口脚本、固定种子。
3. 跑 → 产物进 `results/`（小）或 `out/`（大，忽略）。
4. 值得保留的构型存 `data/configs/`，按阶梯验证。
5. `research/LOG.md` 追加条目；`research/STATE.md` 更新“已确立 / 开放 / 死路”。死路也要写——避免下一个人重走。
6. 新的通用能力（新验证器、新优化器）回收进 `wl/` 或 `src/`，带测试。

## 7. Git

- 小而原子的提交，消息格式：`<area>: <what>`，area ∈ {wl, py, data, exp, docs, proof, infra}。例：`data: n=11 candidate R=2.6310 (L2)`。
- 提交前 `make lint test`（`make hooks` 一次即可让 `.githooks/pre-commit` 自动执行）。
- 不提交：`.venv/`、缓存、实验 `out/`、`*.mx`、笔记本输出；png 只提交 `results/` 下的小图。
- 不推 `main`；用分支 + PR。不改写已推送历史。

## 8. 写作

- 文档用中文，代码标识符/注释用英文。
- 数学结论写清前提、量词与等号情形；数值写有效位数。
- 引用文献前在 `docs/literature.md` 核实书目；未核实标“待核实”。
