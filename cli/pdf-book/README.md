# `PDF`文件切割

网上下载了一些`pdf`图书，是2分栏的扫描版本，放在`kindle`上阅读比较吃力。就想把它切割开来，便于阅读。

使用 python 的 `pypdf` 库来处理

```bash
# 使用国内源
poetry source add ali https://mirrors.aliyun.com/pypi/simple

# 添加依赖
poetry add pypdf

# 运行
poetry run -- pbs
```
