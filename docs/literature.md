# 文献

条目来自 Friedman 页面的署名；书目细节标 “待核实” 的，在引用前必须查到原文并修正此文件。

| n | 结果 | 出处 |
|---|---|---|
| 5 | 证明最优，R = 1.64100446360361570…（Neville 1915 猜想值，Bezdek 证实）| K. Bezdek, *Über einige optimale Konfigurationen von Kreisen*, Ann. Univ. Sci. Budapest. Eötvös Sect. Math. **27** (1984), 143–151；及 K. Bezdek, *Körök optimális fedései*（圆的最优覆盖，博士论文），Eötvös Loránd 大学，Budapest，1979。（**已核实**：Springer/MSU/MathWorld 三处书目一致；Fejes Tóth 2005 原文引作 "Bezdek [1979; 1983]"，卷号 27 的实际出版年为 1984，1983/1984 系期刊出版延迟。Neville 猜想值由 [FT] 2005 p.361 转述。本仓库 R₅ 的精确八次极小多项式已验证，见 `proofs/04-bezdek-n5-n6.md`）|
| 6 | 证明最优，r₆ = 1.7988…（**非** Friedman 页截断的 1.798）| 同上 Bezdek 两篇。（**已核实**：Fejes Tóth 2005 p.361 "Bezdek … who also determined the value of r6 = 1.7988…"。最优构型只有镜像对称，无旋转对称，见 B. Csikós Fields 讲义。本仓库尚未达到该最优值，见 `proofs/04-bezdek-n5-n6.md`）|
| 8, 9, 10 | 证明最优，R_n = 1+2cos(2π/(n−1))，最优构型唯一 | G. Fejes Tóth, "Thinnest covering of a circle by eight, nine, or ten congruent circles", in *Combinatorial and Computational Geometry* (J. E. Goodman, J. Pach, E. Welzl, eds.), MSRI Publ. 52, Cambridge Univ. Press, 2005, pp. 361–376。[PDF](https://library.slmath.org/books/Book52/files/18fejes.pdf)（2026-10-01 已读原文。n=8,9,10 都在这一篇，**以 2005 为准**，Friedman 页面写的 "1996" 系早期年份。复核：§2 单格界有缺口 + 定理陈述有笔误（2 sin→2 cos），已整理进 `proofs/05-fejestoth-n8-n9-n10.md`，并有证书 `proofs/certificates/05-fejestoth-n8-n9-n10.wls`。原始审计见 `proofs/02-remove-ring-assumption.md`）） |
| 10（引理部分） | 9 个以下的圆盖不住 ∂C_10 的距离论证 | H. Melissen, *Packing and covering with circles*, PhD thesis, Utrecht, 1997, pp. 108–111（经 [FT] 转引，待核实） |
| 11, 12 | 记录 | H. Melissen, 1997（待核实） |
| 13–25 | 记录 | Jeremy Tan, 2018（来源形式待查：论文/私信/网页） |

背景 / 方法相关（待核实后补）：

- C. T. Zahn, 早期等圆覆盖圆盘的数值搜索（1962，待核实）。
- Nurmela & Östergård 一系列等圆覆盖（正方形/三角形）的数值方法，可借鉴优化与验证流程。

规则：新增文献写清 作者、标题、出处、年份、DOI/URL，以及它给出的**具体数值或定理**，并注明是否已在本仓库复现。
