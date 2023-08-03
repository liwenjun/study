# Jupyter 学习环境

搭建一个 Jupyter 学习环境。

```shell
poetry new jupyter-study-env
cd jupyter-study-env

# 在项目中配置国内源
poetry source add --priority=default aliyun https://mirrors.aliyun.com/pypi/simple/

# 添加依赖包
poetry add -D jupyter
poetry add -D jupyterlab
poetry add -D jupyterlab-language-pack-zh-CN

# 启动 jupyterlab
poetry run jupyter-lab
```
