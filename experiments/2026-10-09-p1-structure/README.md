# P1 结构引理（n=8,9）向外舍入区间证书

- 日期：2026-10-09
- 问题 / 假设：关闭 proofs/06 §4 **P1**（对应 [FT] §2 的 S1，n∈{8,9}）。
  命题：n∈{8,9}，R_n=1+2cos(2π/k)，k=n−1，{Cᵢ} 覆盖 C_n ⟹
  (i) 恰一圆在 int C_n 内；(ii) 相交 bd C_n 的圆无三者共点。
  [FT] §2 已把 n=8,9 的论证完整写出，缺口纯机械：两条弧长上界引理的初等证明 +
  四个 arcsin 数值不等式的向外舍入区间复核。**这不是开放数学难题。**
- 方法：单入口 `run.wls`，直接调用已封证书
  `proofs/certificates/05e-p1-structure-n8-n9.wls`（唯一真源，无算法复制）。
- 复现：`wolframscript -file experiments/2026-10-09-p1-structure/run.wls ; echo "EXIT=$?"`
  （或直接 `wolframscript -file proofs/certificates/05e-p1-structure-n8-n9.wls`）。

## 两条弧长上界引理（初等几何，证明写在证书头注）

- **L-arc1（单圆）**：单个单位圆覆盖 bd C_n 的弧，其 o-张角 ≤ 2·arcsin(1/R_n)。
  证：bd C_n 与闭单位圆的交是一段弧，两端点都在该单位圆内，故其弦 ≤ 直径 = 2；
  半径 r 的圆上长 L 的弦张中心角 2·arcsin(L/(2r))，关于 L 递增，取 L=2 得 2·arcsin(1/r)。
  = 现成 `CirCovCir`MaxCoveredArc`（几何推导同文件 `CoveredArc[r,d]` 的弦/半径界）。
- **L-arc2（三圆共点）**：三个有公共点 p 的单位圆覆盖 bd C_n 的弧，其 o-张角 ≤ 2·arcsin(2/R_n)。
  证：p 在三圆内 ⟹ 对每圆 |p−心| ≤ 1；任一被覆盖点 x 在某圆内 ⟹ |x−心| ≤ 1，
  三角不等式 |x−p| ≤ |x−心|+|心−p| ≤ 2。故被覆盖的 bd C_n 点全落在 D(p,2) 内，
  两端点弦 ≤ |a−p|+|p−b| ≤ 4，同一弦/角律给 2·arcsin(4/(2r)) = 2·arcsin(2/r)。
  = 本任务新增的孪生函数 `CirCovCir`MaxCoveredArcTriple`（带 usage + wl/tests 回归）。

## 四个不等式的向外舍入区间复核

区间算术（WL `Interval`，构造即向外舍入；arcsin 单调递增 ⟹ `ArcSin[Interval]` 为有效包络）：
取 LHS 包络的**上端点**与 π 包络的**下端点**，要求 `LHS_upper < Pi_lower`（严格、向外）。

| 不等式 | LHS_upper（向外） | π_lower（向外） | 严格 <π | 余量 |
|---|---|---|---|---|
| 6·arcsin(1/R₈)        | 2.767326081 | 3.141592653 | ✅ True | 0.3743 |
| 4·arcsin(1/R₈)+arcsin(2/R₈) | 2.942412903 | 3.141592653 | ✅ True | 0.1992 |
| 7·arcsin(1/R₉)        | 2.989550105 | 3.141592653 | ✅ True | 0.1520 |
| 5·arcsin(1/R₉)+arcsin(2/R₉) | 3.111686536 | 3.141592653 | ✅ True | **0.0299** |

四项全真，最小余量 ≈ 0.0299（n=9 三圆共点那条）。

### 诚实边界：[FT] 第一条印刷数是排版笔误

[FT] §2 把 `6 arcsin(1/r₈)` 印成 **2.76326081**，真值是 **2.767326081…**（论文把 "767326"
误转成 "76326"，少印一个数字）。两者都 < π，结论不受影响；本证书核验**真值**并记录笔误，
不复现错印。其余三条（2.989550105 / 2.942412903 / 3.111686536）逐位命中 [FT] 印刷数。

## 结果

| n | 对象 | 等级 | 文件 |
|---|---|---|---|
| 8,9 | P1 结构引理（恰一内部圆 + 无三圆共点） | L3 | `proofs/certificates/05e-p1-structure-n8-n9.wls`（exit 0） |

证书 6 项 gating 全 True，真 exit code = 0（无管道/timeout 掩盖）。

## 结论与下一步

- **P1(n=8,9) 已配证书、关闭**（L3）。两条弧长引理有初等证明且落到可复用库函数，
  四个不等式有向外舍入区间复核。
- 本任务只加了 WL 侧纯几何上界 `MaxCoveredArcTriple`；它是单侧上界，**不涉及**
  `wl/`↔`src/` 的双实现候选集不变量（AGENTS.md §3），故 Python 侧无对应、无需为凑而改。
- 剩余缺口（非本任务）：P0（反射约定，genuine-open 初等）、P2（n=10 Melissen 文献关）。
- 已同步 `proofs/06`、`proofs/02`、`research/STATE.md`、`research/LOG.md`。
- 未 commit——留给 orchestrator 核验后提交。
