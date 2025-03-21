# 实战`openSUSE Tumbleweed`用于C语言开发

> 2025-01-12  以下安装软件版本均为此日期时的最新版本

去微软官方下载分发包 [`openSUSE Tumbleweed`](https://aka.ms/wsl-opensuse-tumbleweed)


```bash
# 在线查看可用 wsl 包
wsl --list --online

# 安装
# wsl --install --no-launch --web-download --distribution openSUSE-Tumbleweed
wsl --install --web-download --distribution openSUSE-Tumbleweed
```

## 初始安装

按标准方法安装。设置用户`lee`。

```bash
# 添加普通用户lee免密
echo "lee ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/lee
sudo chmod 0440 /etc/sudoers.d/lee

# 解析git地址 
cat | sudo tee -a /etc/hosts <<EOF
185.199.108.133 raw.githubusercontent.com
185.199.109.133 raw.githubusercontent.com
185.199.110.133 raw.githubusercontent.com
185.199.111.133 raw.githubusercontent.com
140.82.112.4 github.com
140.82.114.4 www.github.com
199.232.5.194 github.global.ssl.fastly.net
54.231.114.219 github-cloud.s3.amazonaws.com
EOF

# 从 Snapshot 版本 20200806 开始，全新安装将默认使用 tmpfs 作为 /tmp。
# 调整 /tmp
sudo vi /etc/fstab
# 将    tmpfs /var/tmp tmpfs defaults 0 0
# 修改为 tmpfs /tmp tmpfs defaults 0 0

# 退出重启 wsl

# 使用内存盘
rm -fr ~/.cache/
ln -s /tmp ~/.cache

cd /var
sudo rm -fr tmp
sudo ln -s /tmp


# 更新大版本
# 安装时原版本
cat /etc/os-release
NAME="openSUSE Tumbleweed"
VERSION_ID="20211027"

# 更新
sudo zypper ref
sudo zypper dup

# 更新后版本
cat /etc/os-release
NAME="openSUSE Tumbleweed"
VERSION_ID="20250109"

#
sudo zypper install -t pattern wsl_base wsl_gui wsl_systemd

# 编辑
sudo vi /etc/wsl.conf

# 加入以下内容
[boot]
systemd=true

# 重启 wsl
```

## 设置中文

```bash
sudo zypper install glibc-locale glibc-lang

sudo yast2 language
sudo yast2 timezone

echo 'export LANG="zh_CN.UTF-8"' | tee -a ~/.profile

# 可暂不安装字体
sudo zypper install \
	google-noto-serif-fonts \
	google-noto-sans-sc-fonts \
	google-noto-sans-sc-mono-fonts 
   
# sudo zypper install wqy-zenhei-fonts wqy-microhei-fonts ibus-pinyin

# 暂不执行下列手工修改命令
sudo localectl set-locale LANG=zh_CN.UTF-8

#
sudo vi /etc/sysconfig/language
INSTALLED_LANGUAGES="zh_CN"
RC_LANG="zh_CN.UTF-8"
RC_LC_ALL="zh_CN.UTF-8"
```

## 安装软件包
```bash
#
sudo zypper ref

# 
sudo zypper install git nano tree \
	python313-devel python313-pip python313-setuptools

# 配置 git
git config --global user.email "14991386@qq.com"
git config --global user.name "liwejun"
```

### c/c++ 工具链 

```bash
# 
sudo zypper install \
	clang clang-tools \
	lldb lld \
	cmake \
	gcc gcc-c++ gdb gcc-locale \
	glibc-devel-static \
	python3-clang

# refrence
sudo apt install flex bison gperf \
	ninja-build ccache

# 
sudo zypper install \
	libopenssl-devel \
	libffi-devel \
	sqlite3-devel \
	ncurses-devel \
	libzip-devel
```

### rust 工具链

```bash
#  
# latest update on 2024-11-28, rust version 1.83.0 (90b35a623 2024-11-26)
#RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup \
RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup \
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 删除html帮助文件，节省存储空间
rm -fr ~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc/rust/html

#
mkdir -p ~/.cargo/registry
ln -s /tmp ~/.cargo/registry/src

# 使用本地资源
cd ~/.cargo/registry
ln -s /mnt/c/Users/lee/scoop/persist/rustup-msvc/.cargo/registry/cache
ln -s /mnt/c/Users/lee/scoop/persist/rustup-msvc/.cargo/registry/index

#
cat > ~/.cargo/config.toml <<EOF
[build]
# jobs = 1                      # number of parallel jobs, defaults to # of CPUs
target-dir = "/var/tmp/target"         # path of where to place all generated artifacts
incremental = true            # whether or not to enable incremental compilation

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
replace-with = 'tuna' # 如：tuna、sjtu、ustc，或者 rustcc

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
EOF

#
cargo install --locked mdbook mdbook-mermaid
cargo install sqlx-cli --no-default-features -F postgres,native-tls,sqlite
cargo install diesel_cli --no-default-features --features "postgres sqlite"
```

## 安装 postgresql

```bash
# 安装
# postgresql-llvmjit
sudo zypper install postgresql postgresql-devel postgresql-contrib 

# 版本
psql --version
## psql (PostgreSQL) 17.4

# 查询状态
sudo systemctl status postgresql

# 启停操作
sudo systemctl start|stop|restart postgresql
```

### 管理配置 postgresql

```bash
# 查看配置文件
sudo -u postgres psql -c 'SHOW config_file'
## /var/lib/pgsql/data/postgresql.conf

sudo -u postgres psql -c 'SHOW hba_file'
## /var/lib/pgsql/data/pg_hba.conf

# 修改配置允许外部访问
sudo nano /var/lib/pgsql/data/postgresql.conf
## 将 
## #listen_addresses = 'localhost'
## 改为
## listen_addresses = '*'

sudo nano /var/lib/pgsql/data/pg_hba.conf
## 在文件末尾添加如下二行
host    all             all             0.0.0.0/0            scram-sha-256
host    all             all             ::/0                 scram-sha-256

# 重启生效
sudo systemctl restart postgresql
```

```bash
# 切换用户登录到交互界面
sudo -u postgres -i

# 想看当前用户
whoami

# 切换用户执行具体命令
sudo -u postgres psql
```

```bash
# 常用数据库管理命令
sudo -u postgres psql

# 数据库列表
postgres=# \l
##     Name    |  Owner   | Encoding | Locale Provider | ...
##  -----------+----------+----------+-----------------+
##   postgres  | postgres | UTF8     | libc            |
##   template0 | postgres | UTF8     | libc            |
##   template1 | postgres | UTF8     | libc            |
##  (3 rows)

# 角色列表
postgres=# \du
##  Role name |                         Attributes
## -----------+------------------------------------------------------------
##  postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS


# 在SuperUser上创建角色
postgres=# CREATE ROLE lee WITH SUPERUSER LOGIN PASSWORD '*';
postgres=# \du
##  Role name |                         Attributes
## -----------+------------------------------------------------------------
##  lee       | Superuser
##  postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS


# 创建一个新的数据库，角色是所有者。
postgres=# CREATE DATABASE <db_name> WITH OWNER lee;
postgres-# \l

# 指定角色连接到数据库。
psql lee -d <db_name>
```

```bash
# 创建开发用数据库用户
sudo -u postgres psql

postgres=# CREATE USER dev PASSWORD 'password' CREATEDB;
postgres=# CREATE DATABASE devdb WITH OWNER dev;
postgres=# \q

# 测试连接
psql -U dev -d devdb -h localhost
```

## 清理

```bash
# 清理
sudo zypper clean
sudo rm -rf /var/log/*
sudo rm -fr /var/cache/zypp
rm -fr ~/.bash_history

# 退回到普通用户
exit
```

退出 `wsl`，在 windows 下运行：

```bash
# 导出分发包
wsl --shutdown
wsl --export openSUSE-Tumbleweed - | gzip -9 > z:\rootfs.tar.gz
```

> 此处生成`base`包

## 用户配置

windows下执行：

```bash
# 设置wsl默认用户为lee
wslconfig /s openSUSE
C:\wsl\openSUSE\openSUSE.exe config --default-user lee
```

