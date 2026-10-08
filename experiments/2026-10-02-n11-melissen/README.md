# 2026-10-02 n=11 — Melissen 构型复现与坐标计算

## 假设 / 目标
n=11 是开放问题，记录 R_11 = 2.631（Hans Melissen, 1997，Friedman 页面十进制下界）。
目标：复现 Melissen 构型，用 Mathematica 算出每个圆心坐标，并按证据阶梯验证。

## 构型结构（读自 Friedman `11.gif`）
竖直镜像对称（x → −x）。11 个单位圆：
- **3 个在对称轴上**：下方内圆 c0、上方内圆 c8、顶部圆 c9；
- **4 对镜像外圆**：{c1,c6}, {c2,c5}, {c3,c10}, {c4,c7}。

渲染图 `cover_n11.png` 与原图逐一核对一致（见下）。

## 方法
1. **独立数值求解**（不依赖图像像素，避免 L0 坐标）：
   `uv run circovcir search -n 11 --starts 40 --seed 1` → 基线优化器（退火光滑 + 精确候选集 active-set 打磨）
   得 **R = 2.6316907726198**，gap vs 记录 2.631 = +6.9e-4（在页面最后一位不确定度内）。
2. 旋转使镜像轴竖直（`C2.npy`），存 `data/configs/11/20261002-melissen-baseline.json`。
3. **双实现验证**（Python float + Wolfram wp=40）：`wl/scripts/verify_config.wls`。

## 结果（证据等级 L2）
| 量 | 值 |
|---|---|
| R | **2.6316907726198**（13+ 位有效数字） |
| ρ(c, R)（Wolfram wp=40） | 1.0000000000000003（≤ 1，覆盖成立） |
| R_certified（缩放证书） | 2.631690772619807 |
| R_cert_gap vs 记录 | −9.6e-16（即与自身记录值一致到 ~1e-15） |
| 紧点数 | 19 |

坐标见 `data/configs/11/20261002-melissen-baseline.json`（十进制字符串，单位圆、目标圆心在原点）。
对称轴上的 c0/c8/c9 仍带 ~1e-3 的 x 残差（float 最优未严格对称）。

## 脚本
- `float_seed_s1.json` — 基线搜索原始产物。
- `plot.wls` — 渲染 `cover_n11.png`（`CoverPlot`）。
- `solve_sym.wls` / `polish_sym.wls` — 对称参数化（3 轴上 + 4 对 = 11 标量）的高精度打磨尝试。
  **死路记录**：直接最小化 ρ(c,1) 有尺度退化——把圆心整体往原点收缩即可无限降低 ρ，
  优化器（NMinimize/NelderMead、FindMinimum、以及 Python active-set polish + 对称投影）
  都会掉进 R→√2 / R→1 的平凡盆地，而非 Melissen 盆地。
  正确做法是**固定 R、对紧接触方程组用 FindRoot**（docs/methods.md 已指明），或最大化
  尺度等变的 R，二者都避开退化。见下方 TODO。

## TODO（下一步，未做）
- **L3 精确闭式**：Melissen 1997 的 R_11 无已发表闭式。要升 L3 需：固定 R、
  用 19 个紧点写出接触方程组（镜像对称下约 12 个独立方程 vs 12 未知 = 轴上 3 + 4 对×2 + R），
  `FindRoot`（WorkingPrecision ≥ 50）从本目录 float 解局部收敛，再 `RootApproximant`/
  `FindIntegerNullVector` 试闭式；若闭式失败，做区间算术证书给 L3。
- 顺带把 c0/c8/c9 的 x 残差清零（对称固定后自然为 0）。
