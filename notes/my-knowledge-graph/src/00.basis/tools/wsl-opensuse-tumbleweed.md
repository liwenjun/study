# 实战`wsl`安装`openSUSE Tumbleweed`

去微软官方下载分发包 [`openSUSE Tumbleweed`](https://aka.ms/wsl-opensuse-tumbleweed)

## 用户配置

windows下执行：

```cmd
# 设置wsl默认用户为lee
cd /d D:\wsl\openSUSE
openSUSE.exe config --default-user lee
```

## 更新配置

```bash
sudo zypper dup
```

```bash
# 
sudo zypper install git postgresql-devel libopenssl-devel libffi-devel gcc gcc-c++
sudo zypper install python3-devel python3-pip sqlite3-devel make tree


# 为 clojure 开发准备
echo 'export XDG_CONFIG_HOME="$HOME/.config"' >> ~/.bashrc

# 为 npm 配置国内源
echo 'registry=https://registry.npmmirror.com' >> ~/.npmrc

# 为 yarn 配置国内源
echo 'npmRegistryServer: "https://registry.npmmirror.com"' >> ~/.yarnrc.yml

# 为 pip 配置国内源
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn
EOF

# 配置 git
git config --global user.email "***"
git config --global user.name "***"

# 安装 volta (JavaScript命令行管理工具)
# version 1.1.1
curl https://get.volta.sh | bash
```

## 配置 rust 开发环境

```bash
# 安装 rust 开发环境
# RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

mkdir ~/.cargo/registry
ln -s /var/tmp ~/.cargo/registry/src

cat > ~/.cargo/config <<EOF
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

cargo install sqlx-cli --no-default-features -F postgres,native-tls,sqlite
cargo install diesel_cli --no-default-features --features "postgres sqlite"

# cargo install https ripgrep
cargo install mdbook mdbook-mermaid
cargo install cargo-edit
cargo install microserver

# cargo install miniserve
## cargo install maturin
```



## 配置 python 开发工具

```bash
curl -sSL https://install.python-poetry.org | python3 -
```



## 配置 elm 开发工具

```bash
volta install node
rm -f ~/.volta/tools/inventory/node/node-*-linux-x64.tar.gz

# volta install elm-doc-preview elm-review elm-analyse

# 配置安装 elm 工具链
cd /tmp
npm init
npm i -D elm-tooling
npx elm-tooling init
npx elm-tooling tools
npx elm-tooling install
```



## 配置 haskell 

```
# sudo zypper install gmp make ncurses realpath xz-utils
sudo zypper install gmp-devel

curl --proto '=https' --tlsv1.2 -sSf https://mirrors.ustc.edu.cn/ghcup/sh/bootstrap-haskell | BOOTSTRAP_HASKELL_YAML=https://mirrors.ustc.edu.cn/ghcup/ghcup-metadata/ghcup-0.0.7.yaml sh
```

修改 ~/.cabal/config

```
repository mirrors.tuna.tsinghua.edu.cn
  url: http://mirrors.tuna.tsinghua.edu.cn/hackage
  secure: True

-- repository hackage.haskell.org
--   url: http://hackage.haskell.org/
```

修改 ~/.ghcup/config.conf, 在末尾加上

```
url-source:
    OwnSource: https://mirrors.ustc.edu.cn/ghcup/ghcup-metadata/ghcup-0.0.7.yaml 
```







## 配置 vscode 运行环境

```bash
code .

# 安装下列plugin
#
# Elm
# Rust-analyse
# REST Client
#
```

## 缓存开发包

1. 缓存 elm 开发项目依赖包
1. python开发项目 poetry install
1. rust开发项目

	```
	ln -s /mnt/z/TEMP/ target
	mkdir .cargo
	cargo vendor --respect-source-config --versioned-dirs > .cargo/config.toml
	cargo build --release
	```

## 清理

```bash
sudo zypper clean
 
sudo rm -rf /var/log/*
sudo rm -rf /tmp/*
rm -fr ~/.bash_history
```

退出 wsl

## 导出分发包

在 windows 下运行

```bash
wsl --shutdown
wsl --export openSUSE-Tumbleweed - | gzip -9 > z:\rootfs.tar.gz
```
