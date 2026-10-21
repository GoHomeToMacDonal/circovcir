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
- `11-n11-global-reduction.md`：n=11 全局最优性的**未完成**独立尝试；边界圆数 9/10 归约、公共点簇限制，以及十辐条 Voronoi 轮型的条件排除。
  - 证书：`certificates/11a-n11-global-reduction.wls`（L3 计算；手证待复核）。
  - 入口：`experiments/2026-10-10-n11-global/run.wls`，同时复跑已有局部证书 07。
  - 不包含 b=9 的全局上界或 b=10 非轮型的完整排除，**不是全局最优性证明**。
- `12-n11-b9-witness.md`：b=9 的旋转规范与精确自适应排除。全部 b9 的较粗上界 R<2.819988（L3 计算 + 手证待复核）；指定外九圆盒可用残集二圆冲突排除，**锋利上界未完成**。
  - 证书：`certificates/12a-n11-b9-domain.wls`；有理见证和小树在 `experiments/2026-10-10-n11-b9-witness/results/`。
  - 入口：同实验目录 `run.py`。预算不足的分支树明确标未闭合。
- `13-n11-technical-route.md`：完整技术路线、b9 有序弧单纯形全域归约，以及已认证的显式局部盒（每坐标半宽2e−6；不限制镜像扰动）。
  - 证书：`13a-n11-ordered-arcs.wls`、`13b-n11-explicit-collar.wls`（L3）；全局定位仍未完成，两内圆恢复指定域见14。
  - 入口：`experiments/2026-10-10-n11-arc-collar/run.py`。
- `14-n11-inner-lift.md`：G3指定外九圆盒（逐坐标半宽8e−9），任意两内圆补全迫使全23坐标经旋转进入13b，得到条件锋利界R≤R*；**不含全局外圈定位**。
  - 证书：`certificates/14a-n11-inner-lift.wls`（L3），独立精确有理残集/冲突树/支持半平面对偶回放，最后100位区间旋转包含。
  - 入口：`experiments/2026-10-11-n11-inner-lift/run.py`，另重跑13b；有理证书 `results/lift.json`。
- `15-n11-b9-localization.md`：只处理b9；中央盘径向次序界给粗上界R<2.786784686984（L3计算，手证待复核）；半径区间树和精确旋转匹配G3叶已接通，**全域树未闭合**。
  - 证书：`15a-n11-ordered-root.wls`、`15b-n11-radial-order.wls`、`15c-n11-localization-leaf.wls`；15c核验整个局部连续参数盒，不是采样。
  - 入口：`experiments/2026-10-11-n11-b9-localization/run.py`，显式重跑14a/13b依赖。
- `16-n11-b9-rank.md`：b9全部名次情形+极坐标中心域残集排除，五个连续面板×56情形=280域完整闭合，得到全b9 R<2.76（L3计算，几何归约待复核）；**不是R*锋利界**。
  - 证书：`16a-n11-rank-cover.wls` 独立核验线性对偶、极坐标外包、漏点、两圆冲突树；接15b覆盖更高半径。
  - 入口：`experiments/2026-10-11-n11-b9-rank/run.py`；完整明文证书`results/rank-cover.json`约2.1MB。
- `17-n11-b9-propagation.md`：残集树强制两内圆归属、精确圆心界、新点递推及同色冲突。新增[2.74,2.76]七面板×56域排除，接16a/15b得全b9 R<2.74（L3计算）；**锋利界未完成**。
  - 证书：`17a-n11-propagation-cover.wls`，独立重跑16a及392新域，含缺少终止/负对偶等负对照。
  - 入口：`experiments/2026-10-11-n11-b9-propagation/run.py`；`results/propagation-cover.json`约3MB，消融记录明确11叶需新增点而非只扩大种子集。
- `18-n11-b9-correlation.md`：中心逐个径向切片上的条件角度精确支持，完整扇形并集保留同中心半径—角度相关性；新增[2.73,2.74]两面板×56域排除，接17a/16a/15b得全b9 R<2.73（L3计算），**仍非锋利界**。
  - 证书：`18a-n11-sliced-cover.wls`，独立回放112域、1818扇形片、624强制点，并核验分割缝隙/负对偶/假扇形等负对照。
  - 入口：`experiments/2026-10-11-n11-b9-correlation/run.py`；`results/sliced-cover.json`约2.4MB；同24/48种子未分片对照仍19域未决。
- `19-n11-b9-separation.md`：精确有限点两圆直线分割，正覆盖指导新漏点提出；新增[2.725,2.73]全部56名次域排除，接18a/17a/16a/15b得全b9 R<2.725（L3计算），**锋利界未完成**。
  - 证书：`19a-n11-separated-cover.wls`，独立回放1176统一漏点、12043方向室，完整名次及退化/假冲突负对照。
  - 入口：`experiments/2026-10-11-n11-b9-separation/run.py`；`results/separated-cover.json`约1.3MB，另保存九组低半径有限点两圆正证书，不宣称全盘覆盖。
- `21-n11-b10-angular.md`：(B10)——恰 10 圆碰圆周 ⟹ R < r₀=263169/100000（math-proof siege）。Lemma L 计算 L3（两份独立实现），§1–3 归约手证待复核。
  - 证书：`21a-n11-b10-lemL.wls`（WL Interval）、`21b-n11-b10-lemL.py`。
- `22-n11-b9-wl-recheck.md`：(B9) siege 终稿 `experiments/2026-10-20-siege-n11-b9/proof.md`（恰 9 圆碰圆周 ⟹ R < 26317/10000）的 Mathematica 独立复核。与 21 合起来给 n=11 全局 R < 2.6317（**非锋利**）。计算侧 L3，手证待复核。
  - 证书：`22a-n11-b9-hand-constants.wls`（223 条手算常数，50 位区间，~7 s）、`22b-n11-b9-nobridge.wls`（C1 No-Bridge，bignum 区间 + 精确判定，去掉 libm 假设，~46 min/6 核）、`22c-n11-b9-witness.wls`（C2 Σ_m，精确有理 + 自选对偶乘子，~3.5 min/3 核）。
  - 日志：`experiments/2026-10-20-siege-n11-b9/results/wl/`。
