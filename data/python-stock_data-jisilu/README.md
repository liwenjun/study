# 股票数据抓取与处理（数据源来自集思录[https://www.jisilu.cn/]）

[股票数据API文档](./api/README.md)

## 创建项目

```shell
poetry new python-stock_data-jisilu
cd python-stock_data-jisilu

# 在项目中配置国内源
poetry source add --priority=default aliyun https://mirrors.aliyun.com/pypi/simple/

# 添加依赖包
poetry add requests cleo fake-useragent

# 添加开发依赖包
poetry add -D jupyter jupyterlab jupyterlab-language-pack-zh-CN

# 启动 jupyterlab 用于开发
poetry run jupyter-lab -- notebook
```


## 组织代码

将代码按功能进行分包，统一组织在 `src` 目录下。

