# 2026-10-02 — Bezdek (n=5,6) + Fejes Tóth (n=8,9,10) 证明核实与验证

目标：核实 Bezdek n=5,6 与 Fejes Tóth n=8,9,10 的最优性文献，用 wolframscript 验证各证明的关键计算断言，整理进 `proofs/04-*.md`、`proofs/05-*.md`、证书 `proofs/certificates/04-*.wls`、`05-*.wls`，并更新 `docs/literature.md`。

共享算法只在 `wl/CirCovCir.wl` 与 `src/circovcir/`；本目录只有一次性脚本（固定种子）。scratch 进 `out/`（git 忽略）。

## 脚本（单入口，固定种子）

- `probe_r6_poly.wls`：验证 Math.SE q/2651575 的八次多项式（误标 "six disks"）其实根 1/x₀ = 1.6410044636… = **R₅**（NSolve wp=50）。
- `probe_r5_exact.wls`：由此推出 R₅ 的精确八次极小多项式，与仓库基线比对到 48 位。
- `n6_mirror.py`（seed 20261002）：n=6 最优值尝试，限制在镜像对称族（A：3 对；B：2 对+2 轴上点），Nelder-Mead + 精确 active-set 打磨，精确候选集打分。产物 `out/n6-mirror.json`。
- 宽搜：`uv run circovcir search -n 6 --starts 200 --seed 20261002`（产物 `out/n6-wide-s200.json`）。

## 复现

```bash
export WOLFRAMSCRIPT=~/Wolfram/Mathematica/14.3/Executables/wolframscript
# n=5 精确值
$WOLFRAMSCRIPT -file experiments/2026-10-02-bezdek-fejestoth-verify/probe_r5_exact.wls
# 证书
$WOLFRAMSCRIPT -file proofs/certificates/04-bezdek-n5-n6.wls      # exit 0
$WOLFRAMSCRIPT -file proofs/certificates/05-fejestoth-n8-n9-n10.wls  # exit 0
# n=6 搜索
uv run python experiments/2026-10-02-bezdek-fejestoth-verify/n6_mirror.py
```

## 结论摘要

- Bezdek 书目核实：1984 期刊（Ann. Univ. Sci. Budapest Eötvös Sect. Math. 27, 143–151）+ 1979 博士论文。见 `proofs/04`。
- R₅ 精确 = 八次不可约多项式之根（无根式），≠ φ²（镜像最优）。L3「值」。
- FT 笔误（2 sin→2 cos）+ G1 缺口（α<π/3）+ G1T 切线补丁（切线性 & 凹性 L3）。Jensen 链字面转写未复现（诚实开放）。见 `proofs/05`。
- n=6：基线 1.7906 → 宽搜 1.7953 → 镜像搜索见 `out/n6-mirror.json`；均 < 记录 1.7988（未达到，诚实记录）。
