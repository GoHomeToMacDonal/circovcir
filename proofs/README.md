# 证明与证书

- `NN-<topic>.md`：证明草稿（命题、证明、引用的计算证书）。
- `certificates/`：机器可检的证书——精确代数构型 + `ExactCoverQ` 运行记录，或区间算术（WL `Interval` / `mpmath.iv`）分支定界的完整日志。

一条证明只有在每个计算步骤都有可复现的证书脚本，且证书在干净环境下重跑通过时，才能在 `research/STATE.md` 标 L4。

## 索引（部分）

- `09-n5-independent.md`：n=5 的最优性与存在性独立证明。思路是左右拼接，再按 B 的覆盖方式分情形。
  - 证书：`certificates/09a-n5-basic.wls`、`09b-n5-L8-gap.wls`、`09c-n5-existence.wls`、`09d-n5-local.wls`、`09e-n5-sweep.wls`，共用库 `09lib-n5.wl`。
  - 耗时：09e 约 2 h，09d 约 6.5 min，其余各约 2 min。
  - 等级：计算侧 L3；【人工】步骤见该文 §7″。
