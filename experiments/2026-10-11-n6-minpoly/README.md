# n=6：R₆ 的极小多项式

- 日期：2026-10-11
- 问题：R₆ 已有 L3 包络（10h），但闭式未知（Gröbner 消元 5400 s 超时）。
- 方法：2200 位临界点上做整数关系找候选多项式（证据），再用证书 10i 精确验证（RootReduce）。确定性，无随机种子。
- 文件：`sys.wl`（两种多项式表述 H/L）、`check.wls`（表述自检）、`lll.wls`/`identify.wls`（整数关系，`out/minpolys.m`）、`field.wls`/`field2.wls`（数域结构，证据）、`exact_rr.wls`（RootReduce 首次尝试）、`galois.wls`（Gal(f₉)=S₉）、`modp.wls`（mod p 消元，未完成，死路）。
- 复现：`wolframscript -file identify.wls`；证书 `wolframscript -file ../../proofs/certificates/10i-n6-R6-closed-form.wls`。

## 结果

| n | R | 等级 | 文件 |
|---|---|---|---|
| 6 | R₆² = f₉ 在 (3.2359,3.2360) 的根，R₆ = 1.79886782757755437114579356374527604409660111470932121883… | L3（精确值） | `results/10i.log` |

## 结论与下一步

见 `proofs/10-n6-half.md` §8。可选：对精确代数构型直接跑 `ExactCoverQ`（10h 已给 L3 覆盖，非必需）。
