# 证明与证书

- `NN-<topic>.md`：证明草稿（命题、证明、引用的计算证书）。
- `certificates/`：机器可检的证书——精确代数构型 + `ExactCoverQ` 运行记录，或区间算术（WL `Interval` / `mpmath.iv`）分支定界的完整日志。

一条证明只有在每个计算步骤都有可复现的证书脚本，且证书在干净环境下重跑通过时，才能在 `research/STATE.md` 标 L4。

## 索引（部分）

- `09-n5-independent.md`：n=5 的最优性与存在性独立证明。思路是左右拼接，再按 B 的覆盖方式分情形。
  - 证书：`certificates/09a-n5-basic.wls`、`09b-n5-L8-gap.wls`、`09c-n5-existence.wls`、`09d-n5-local.wls`、`09e-n5-sweep.wls`、`09f-n5-uniqueness.wls`（§10 取等唯一性 + 镜像对称，~30 s），共用库 `09lib-n5.wl`。
  - 耗时：09e 约 2 h，09d 约 6.5 min，其余各约 2 min。
- `10-n6-half.md`：n=6 在“直径前提”(H0) 下的最优性与覆盖方式唯一性（右半圆化为三点 V,T2,X(w) 不可容纳；阈值 R₆=1.79886782757755437…，构型唯一且镜像对称）。(H0) 本身未证（已由 10b-n6-H0 去掉）；R₆ 包络与存在性 L3（§7）；R₆ 闭式 L3（§8：R₆² 是不可约九次多项式的根，无根式表示）。
  - 证书：`certificates/10a-n6-domain.wls`、`10b-n6-bracket.wls`、`10c-n6-local.wls`、`10d-n6-sweep.wls`、`10h-n6-R6-enclosure.wls`（R₆ Krawczyk 包络 + R₆ 处区间覆盖）、`10i-n6-R6-closed-form.wls`（R₆ 极小多项式，RootReduce 精确验证），共用库 `10lib-n6.wl`。
  - 耗时：10d 约 2.5 h，其余各 < 1 min。
  - 等级：计算侧 L3；【人工】步骤见该文 §7″。
- `10b-n6-H0.md`：去掉 (H0)。O₁∋0 置于 y 轴；y 轴剩余段需两圆的情形由弧缺口覆盖判据排除，单圆情形经帽子引理化为 10 的半圆问题，并证引理 V（右侧圆不含 V*）。
  - 证书：`certificates/10f-n6-H0-case3.wls`（~71 s）、`10g-n6-H0-case2.wls`（~25 min），共用库 `10lib-H0.wl`。
  - 等级：计算侧 L3；【人工】步骤见该文 §5。
