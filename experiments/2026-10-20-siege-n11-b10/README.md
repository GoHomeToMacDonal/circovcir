# n=11 (B10)：math-proof siege 攻关

- 日期：2026-10-20
- 问题 / 假设：11 单位圆覆盖 D(0,R) 且恰 10 圆碰圆周 ⟹ R < r₀=2.63169（`proofs/20` §14 的 (B10)）。问题陈述 `problem.md`。
- 方法：`.kiro/skills/math-proof-siege` 协议（判官/工作者子代理，默认设置）。run 目录 `out/`（state.md、ledger.md、index.md、proof.md）。4 轮后 CONCLUDE，short tail；共 13 次 worker 查询（10 answered、1 先 partial 后 answered、1 两次后端 5xx 无答复）。
- 复现：
  - `uv run --no-project python experiments/2026-10-20-siege-n11-b10/lemL.py`（= `proofs/certificates/21b-n11-b10-lemL.py`，~14 s）
  - `wolframscript -file experiments/2026-10-20-siege-n11-b10/lemL_check.wls`（= `proofs/certificates/21a-n11-b10-lemL.wls`，独立 WL Interval 实现，~4 min，日志 `results/lemL_check.log`）

## 结果

| 结论 | 等级 | 文件 |
|---|---|---|
| 恰 10 圆碰圆周的覆盖 R < r₀ | Lemma L：L3 计算（两份独立区间实现）；归约：手证待人工复核 | `proofs/21-n11-b10-angular.md`、`out/proof.md` |

## 结论与下一步

(B10) 闭合 ⟹ n=11 最优性/对称性只剩 (G2-b9)。值得一试：同一“圆周 + 内小圆加权”角度法能否对 b=9 给出 R* 处的锋利界（两内圆情形更复杂，未试）。
