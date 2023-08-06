# 股票数据抓取与处理

## 预期目标

通过抓取[集思录](https://www.jisilu.cn/)网站实时数据，本地存储后，进行加工处理，最终以图形化方式展示所需信息。

[股票数据API文档](./api/README.md)


## 创建项目

```shell
poetry new python-stock_data-jisilu
cd python-stock_data-jisilu

# 在项目中配置国内源
poetry source add --priority=default aliyun https://mirrors.aliyun.com/pypi/simple/

# 添加依赖包
poetry add requests cleo fake-useragent tqdm

# 添加开发依赖包
poetry add -D jupyter jupyterlab jupyterlab-language-pack-zh-CN

# 启动 jupyterlab 用于开发
poetry run jupyter-lab -- notebook
```


## 组织代码

将代码按功能进行分包，统一组织在 `src` 目录下。

## 创建(迁移)数据库

考虑到此工具仅供个人使用，数据量也不是太大，采用`Sqlite3`数据库作为本地数据存储。

计划用之前学习过的 `Rust` `SQLx-cli` 工具来实现数据库的创建和迁移，最大化利用现有工具。

1. 创建`.env`文件，配置`DATABASE_URL`环境变量

2. 执行下列命令创建数据库和迁移脚本
    ```
    sqlx db create
    sqlx mig add init-schema
    sqlx mig run
    ```

3. 数据库迁移脚本

    [脚本内容](./migrations/20230804133155_init-schema.sql)

> 当然，如果不熟悉`Rust`也没问题，我们可以用 `Pythonic` 的方法来完成这项工作。通过安装 [Alembic](https://alembic.sqlalchemy.org/) 工具可实现数据库的创建和迁移工作。

