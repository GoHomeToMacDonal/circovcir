# 构型文件 schema

路径：`data/configs/NN/<name>.json`，NN 为两位 n。`known.json` 保留给文献/平凡已知构型，由 `wl/scripts/make_known_configs.wls` 生成，**不要手改**。其它命名：`<YYYYMMDD>-<slug>.json`（例：`20261001-de-seed3.json`）。

| 字段 | 必需 | 说明 |
|---|---|---|
| `n` | ✓ | 圆个数 |
| `R` | ✓ | 被覆盖圆盘半径，十进制字符串（尽可能多位） |
| `centers` | ✓ | n 个 `[x, y]`，十进制字符串；单位圆、目标圆心在原点 |
| `status` | ✓ | `candidate` → `verified-numeric`（L2）→ `verified-exact`（L3）→ `proved-optimal`（L4） |
| `source` | ✓ | 出处（人名/文献/实验目录） |
| `provenance` | ✓ | 生成命令或脚本，必须可复现 |
| `R_wl`, `centers_wl` | 可选 | 精确 Wolfram 表达式（InputForm）；存在时 `LoadConfig` 优先使用并可跑 `ExactCoverQ` |
| `checks` | 可选 | 验证结果快照（谁、何精度、何结果） |

安全：`LoadConfig` 对 `*_wl` 字段用 `ToExpression`，等于执行代码——只加载本仓库自己生成/审过的文件。
