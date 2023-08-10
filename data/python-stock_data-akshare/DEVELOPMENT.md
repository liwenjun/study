# 基于AKShare股票数据抓取与处理实战



## 预期目标

通过`API`获取网站数据，本地存储后，进行加工处理，最终以图形化方式展示所需信息。

[AKShare官方文档](https://www.akshare.xyz/)  [自己整理的API文档](./AKShare_API.md)



## 创建项目

```shell
poetry new python-stock_data-akshare
cd python-stock_data-akshare

# 在项目中配置国内源
poetry source add --priority=default aliyun https://mirrors.aliyun.com/pypi/simple/

# 添加依赖包
poetry add akshare tqdm cleo
poetry add pandas matplotlib plotly

# 添加开发依赖包
poetry add -D jupyterlab-language-pack-zh-CN

# 启动 jupyterlab 用于开发
poetry run jupyter-lab -- notebook
```



## 组织代码

将代码按功能进行分包，统一组织在 `src` 目录下。

- data_fetch - 数据抓取功能包
- data_process - 数据处理功能包
- data_presentation - 数据展现功能包



## 创建(迁移)数据库

考虑到此工具仅供个人使用，数据量也不是太大，我们选用`Sqlite3`数据库作为本地数据存储。

采用之前学过的`SQLx-cli`工具来实现数据库的创建和迁移，最大化利用现有工具。

1. 创建`.env`文件，配置`DATABASE_URL`环境变量

2. 执行下列命令创建数据库和迁移脚本
    ```shell
    sqlx mig add init-schema
    sqlx db setup
    ```
    
3. 数据库迁移脚本

    [脚本内容](./migrations/20230810012950_init-schema.sql)

> 当然，如果不熟悉`SQLx-cli`也没问题，我们可以用 `Pythonic` 的方法来完成这项工作。通过安装 [Alembic](https://alembic.sqlalchemy.org/) 工具包也可达到相同目的。



## 打包分发

使用 `python-embed` 版本打包分发，缩减文件大小。
