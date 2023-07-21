# `cleo` 学习实操

本项目是 `Python` [cleo](https://github.com/python-poetry/cleo) 库的学习实操，应用于命令行程序。

## 创建项目

```bash
poetry new python-cleo-study
cd python-cleo-study

# 在项目中配置国内源
poetry source add --priority=default aliyun https://mirrors.aliyun.com/pypi/simple/

# 添加依赖包
poetry add cleo
```

## 运行范例

```bash
poetry install

poetry run cli -- add https://github.com/python-poetry/cleo ./cleo -l
poetry run cli -- up ./cleo -l
```
