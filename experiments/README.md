# 实验

每个实验一个目录：`experiments/YYYY-MM-DD-<slug>/`，复制 `_template/` 开始。

```
YYYY-MM-DD-slug/
  README.md     问题 / 假设 / 方法 / 结论（含证据等级）
  run.py | run.wls  唯一入口；固定随机种子；参数写在文件顶部或命令行
  results/      小而可提交的产物（json/csv/png，< ~1 MB）
  out/          大或可再生产物（已 gitignore）
```

规则：
- 实验只读 `src/`、`wl/`；需要改共享代码时，先改共享代码 + 测试，再在实验里调用。
- 找到值得保留的构型：写入 `data/configs/NN/`（status=`candidate`），再按验证阶梯升级。
- 结束时：`research/LOG.md` 追加一条，`research/STATE.md` 更新结论/死路。
