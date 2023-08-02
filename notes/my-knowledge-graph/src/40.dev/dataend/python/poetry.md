# Poetry 让Python打包和依赖管理变得简单

[官网](https://python-poetry.org/)

## 安装

```shell
# linux
curl -sSL https://install.python-poetry.org | python3 -

# windows
scoop install poetry

# 更新
poetry self update
```



## 基本使用

### 项目设置

#### 创建一个新项目

```shell
poetry new poetry-demo
```

项目目录内容如下

```
poetry-demo
├── pyproject.toml
├── README.md
├── poetry_demo
│   └── __init__.py
└── tests
    └── __init__.py
	
```

配置文件`pyproject.toml`在项目根目录中，内容

```toml
[tool.poetry]
name = "poetry-demo"
version = "0.1.0"
description = ""
authors = ["李文军 <liwenjun@21cn.com>"]
readme = "README.md"
packages = [{include = "poetry_demo"}]

[tool.poetry.dependencies]
python = "^3.11"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

#### 初始化一个已有项目

```shell
cd pre-existing-project
poetry init
```

### 使用虚拟环境

By default, Poetry creates a virtual environment in {cache-dir}/virtualenvs. 
默认情况下，诗歌会在 中创建虚拟环境。

There are several ways to run commands within this virtual environment.
有几种方法可以在此虚拟环境中运行命令。


#### 使用 poetry run

```shell
poetry run python your_script.py

# 如果有命令行工具，如pytest
poetry run pytest
```

#### 激活虚拟环境

激活虚拟环境的最简单方法是使用`poetry shell`。

停用虚拟环境并退出shell，使用`exit`。 要在不离开shell的情况下停用虚拟环境，请使用`deactivate`。


### 安装依赖

```shell
poetry install

# 仅安装依赖项
poetry install --no-root

# 更新依赖项
poetry update
```



## 配置

Poetry can be configured via the `config` command

### 局部配置 Local configuration

Poetry提供了项目级配置，使用 `--local` 选项

```bash
poetry config virtualenvs.create false --local
```

### 列出当前配置项

```bash
poetry config --list
```

内容

```ini
cache-dir = "/path/to/cache/directory"
virtualenvs.create = true
virtualenvs.in-project = null
virtualenvs.options.always-copy = true
virtualenvs.options.no-pip = false
virtualenvs.options.no-setuptools = false
virtualenvs.options.system-site-packages = false
virtualenvs.path = "{cache-dir}/virtualenvs"  # /path/to/cache/directory/virtualenvs
virtualenvs.prefer-active-python = false
virtualenvs.prompt = "{project_name}-py{python_version}"
```
