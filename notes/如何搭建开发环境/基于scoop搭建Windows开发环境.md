先安装 `Microsoft C++ 生成工具`，下载点击 [这里](https://visualstudio.microsoft.com/visual-cpp-build-tools/)。
注意安装时选择 `C++`，再钩上 `Windows 10 SDK`。

## 安装 `scoop` 及相关工具

```powershell
# 安装scoop
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# 安装基础工具
scoop install aria2
scoop install git

# 安装扩展库
scoop bucket add extras
# scoop bucket add java
# scoop bucket add scoop-clojure
# scoop bucket add nerd-fonts

# 更新信息
scoop update

# 安装开发所需工具包
scoop install windows-terminal
scoop install gzip sudo curl
scoop install obsidian
scoop install poetry
scoop install postgresql postgrest
scoop install volta
scoop install vscode
scoop install heidisql sqlitestudio  # 数据库工具
scoop install JetBrains-Mono firacode SarasaGothic-SC # 字库
```

## vscode 安装开发用的插件

```
wsl
elm
python
rust-analyzer
rest client
prettier
tabnine
```

## 通过volta安装前端开发工具

配置npm国内源 `%USER_HOME%\.npmrc`
```
registry=https://registry.npm.taobao.org/
```

配置yarn国内源 `%USER_HOME%\.yarnrc.yml`
```
npmRegistryServer: "https://registry.npmmirror.com"
```

安装
```powershell
scoop install volta

# 安装 nodejs
volta install node

# 缓存 elm 开发工具链
cd z:\TEMP
npm i -D elm-tooling
npx elm-tooling init
npx elm-tooling tools
npx elm-tooling install

# 将上面的工具链加入全局开发路径
cd %SCOOP%\persist\volta\appdata\bin
sudo cmd
mklink elm.exe %Users%\AppData\Roaming\elm\elm-tooling\elm\0.19.1\elm.exe
mklink elm-format.exe %PATH%\elm-tooling\elm-format\0.8.7\elm-format.exe
mklink elm-json.exe %PATH%\elm-tooling\elm-json\0.2.13\elm-json.exe
mklink elm-test-rs.exe %PATH%\elm-tooling\elm-test-rs\3.0.0\elm-test-rs.exe

# 全局安装几个常用工具 (如权限不足， 请用 sudo 执行)
sudo volta install elm-doc-preview elm-review elm-watch
sudo volta install npm-check-updates
sudo volta install vite vite-plugin-elm
sudo volta install elm-land
sudo volta install run-pty
```

## 安装配置postgresql数据库

```powershell
# 安装
scoop install postgresql

# 启停数据库
pg_ctl start
pg_ctl stop

# 注册服务
pg_ctl register -N PostgreSQL

# Default superuser login: postgres, password: <blank>
```

创建开发用户和数据库
```powershell
pg_ctl start
psql -U postgres
```

然后执行如下SQL
```sql
CREATE USER dev WITH PASSWORD 'password';
-- ALTER ROLE dev WITH PASSWORD 'password';
CREATE DATABASE devdb OWNER dev;
-- GRANT ALL PRIVILEGES ON DATABASE devdb TO dev;

\c devdb

CREATE SCHEMA AUTHORIZATION dev;
CREATE SCHEMA api AUTHORIZATION dev;
```

[[postgresql常见命令及操作]] 

## 安装配置python开发环境

配置python国内源 `%USER_HOME%\pip\pip.ini`
```
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
```

安装
```powershell
scoop install poetry

# 调整全局配置，便于迁移至内网开发
poetry config virtualenvs.in-project true
poetry config virtualenvs.options.always-copy true
poetry config virtualenvs.options.no-pip true
poetry config virtualenvs.options.no-setuptools true

# 在项目中配置国内源
poetry source add --priority=default aliyun https://mirrors.aliyun.com/pypi/simple/
```

## 安装配置rust开发环境

```powershell
# 安装
scoop install rustup-msvc
```

配置 `%CARGO_HOME%\config`
```toml
[build]
# jobs = 1                      # number of parallel jobs, defaults to # of CPUs
target-dir = "z:/down/target"         # path of where to place all generated artifacts
incremental = true            # whether or not to enable incremental compilation

[future-incompat-report]
frequency = 'always' # when to display a notification about a future incompat report

[cargo-new]
vcs = "none"              # VCS to use ('git', 'hg', 'pijul', 'fossil', 'none')

[profile.release]
panic = "abort" # Strip expensive panic clean-up logic
codegen-units = 1 # Compile crates one after another so the compiler can optimize better
lto = true # Enables link to optimizations
opt-level = "s" # Optimize for binary size
strip = true # Remove debug symbols

[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = 'sjtu' # 如：tuna、sjtu、ustc，或者 rustcc

# 注：以下源配置一个即可，无需全部
# 目前 sjtu 相对稳定些

# 中国科学技术大学
[source.ustc]
registry = "https://mirrors.ustc.edu.cn/crates.io-index"

# 上海交通大学
[source.sjtu]
registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index/"

# 清华大学
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

# rustcc社区
[source.rustcc]
registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
```

安装辅助工具
```powershell
cargo install --locked cargo-deny cargo-edit
cargo install --locked diesel_cli --no-default-features -F "postgres sqlite-bundled"
cargo install --locked sqlx-cli --no-default-features --features native-tls,postgres,sqlite
cargo install --locked microserver
```

## 安装配置postgrest开发环境

```powershell
scoop install postgrest
```

在数据库中创建一个用于匿名 Web 请求的角色
```powershell
psql -U postgres -d devdb
```
执行如下 SQL
```sql
-- 创建匿名用户
create role web_anon nologin;
grant connect on database devdb to web_anon;
grant usage on schema api to web_anon;
grant select on table api.posts to web_anon;
--grant select on all tables in schema api to web_anon;

-- 创建授权用户
create role todo_user nologin;
grant connect on database devdb to todo_user;
grant usage on schema api to todo_user;
grant all on api.posts to todo_user;
grant usage, select on sequence api.posts_id_seq to todo_user;
--grant all on all tables in schema api to web_anon;

create role web_anon nologin;
grant connect on database devdb to web_anon;
grant usage on schema api to web_anon;
grant select on table api.posts to web_anon;
--grant select on all tables in schema api to web_anon;

-- 创建专用角色
create role authenticator noinherit login password 'secretpassword';
-- CREATE ROLE authenticator LOGIN NOINHERIT NOCREATEDB NOCREATEROLE NOSUPERUSER;
grant web_anon to authenticator;
grant todo_user to authenticator;
```

配置启动参数文件 ex.conf
```ini
db-anon-role = "web_anon"
db-schema = "api"
db-uri = "postgresql://authenticator:secretpassword@127.0.0.1/devdb"
jwt-secret = "5rmZEf1uIYJj88VfEFPH3bMw9wvPfJL9"
```
TOKEN
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoidG9kb191c2VyIn0.gUOKnMS0wLW9iFArQcmJKiWQMNOw28x6zy33UsfBG28
```

Rest Client
```
POST http://127.0.0.1:3000/posts HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoidG9kb191c2VyIn0.gUOKnMS0wLW9iFArQcmJKiWQMNOw28x6zy33UsfBG28
content-type: application/json

{
    "title": "你好",
    "body": "Hello"
}
```
