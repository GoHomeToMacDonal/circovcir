# n=6：R₆ 的 Krawczyk 包络与 R₆ 处的区间覆盖证书

- 日期：2026-10-11
- 问题：R₆ 的数值和 R₆ 处覆盖存在性此前只有 L2（无闭式）。目标是不靠闭式升到 L3。
- 方法：证书 `proofs/certificates/10h-n6-R6-enclosure.wls` 一个文件，确定性，无随机种子。
- 复现：`cd experiments/2026-10-11-n6-R6-enclosure/results && wolframscript -file ../../../proofs/certificates/10h-n6-R6-enclosure.wls`

## 结果

| n | R | 等级 | 文件 |
|---|---|---|---|
| 6 | R₆ ∈ [1.7988678275775543711457935637452760440966011147093112, …093313] | L3（包络 + 覆盖存在性） | `results/10h.log` |

## 结论与下一步

见 `proofs/10-n6-half.md` §7。R₆ 的极小多项式已在 `experiments/2026-10-11-n6-minpoly/`（证书 10i）求出。
