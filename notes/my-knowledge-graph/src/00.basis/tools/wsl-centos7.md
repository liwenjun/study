# 实战`wsl`安装`CentOS7` 

`CentOS`的分发安装包下载，请点 [`CentOS-WSL`](https://github.com/mishamosher/CentOS-WSL) ，[`wsldl`](https://github.com/yuk7/wsldl)

## 基本设置

这部分是操作系统级的通用设置。只需要在安装 `wsl2` 包后首次进入时配置一次即可。  
首次进入 `CentOS` 时，通常会以`root`身份登录。  
以`root`身份执行如下命令：

```bash
# 更新dns
rm -f /etc/resolv.conf

#rm -fr /tmp
#ln -s /mnt/wsl/ /tmp
```

退出并重新进入 wsl，以`root`身份继续执行：

```bash
# 配置epel源
yum install -y epel-release
sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!//download\.fedoraproject\.org/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
    -e 's!//download\.example/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
    -e 's!http://mirrors!https://mirrors!g' \
    -i /etc/yum.repos.d/epel*.repo

# 安装 git2.x
yum clean all
yum install -y https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
yum install -y git
yum remove -y endpoint-repo

# 安装软件包
yum install -y wget tree unzip \
    gcc gcc-c++ \
    postgresql-devel openssl-devel libffi-devel
yum clean all
    
# 添加普通用户lee
test -d /etc/sudoers.d \
    || (echo "Making directoryetc/sudoers.d"; mkdir -p /etc/sudoers.d)
grep -F "#includedir /etc/sudoers.d" /etc/sudoers \
    || (echo 'Adding "#includedir /etc/sudoers.d" to /etc/sudoers'; \
    echo "#includedir /etc/sudoers.d" >> /etc/sudoers)
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
useradd lee
echo "***" | passwd --stdin lee
echo "lee ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/lee
chmod 0440 /etc/sudoers.d/lee
```

## 用户配置

windows下执行：

```cmd
# 设置wsl默认用户为lee
cd /d D:\wsl\CentOS7
CentOS.exe config --default-user lee
```

进入 `wsl`，此时以普通用户身份执行：

```bash
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
ln -s /mnt/wsl ~/.cargo/registry/src
ln -s /mnt/wsl ~/.cargo/registry/cache

cat > ~/.cargo/config <<EOF
[build]
# jobs = 1                      # number of parallel jobs, defaults to # of CPUs
# target-dir = "/tmp/target"         # path of where to place all generated artifacts
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

# 安装几个开发中用到的工具
cargo install sqlx-cli --no-default-features -F postgres,native-tls,sqlite
cargo install diesel_cli --no-default-features -F postgres,sqlite

cargo install cargo-edit
cargo install microserver
cargo install mdbook mdbook-mermaid

# cargo install miniserve
# cargo install maturin
```



## 配置 elm 开发工具

```bash
# CentOS7 不支持高版本 Nodejs, 使用 v16 版本
volta install node@16
rm -f ~/.volta/tools/inventory/node/node-*-linux-x64.tar.gz

# 暂不安装 npm yarn

# volta install elm-tooling elm-doc-preview elm-review elm-analyse elm-go elm-spa sass
# volta install elm-tooling elm-doc-preview elm-review elm-analyse sass

# 配置安装 elm 工具链
cd /tmp
npm init
npm i -D elm-tooling
npx elm-tooling init
npx elm-tooling tools
npx elm-tooling install
```



### 临时启用高版本gcc

```
sudo yum install -y centos-release-scl-rh
sudo yum install -y centos-release-scl
sudo yum install devtoolset-11-make devtoolset-11-gcc devtoolset-11-gcc-c++
source /opt/rh/devtoolset-11/enable

# 编译安装
volta install run-pty
```



### 配置 vscode 运行环境

```bash
code .

# 安装下列plugin
#
# Elm
# Rust-analyse
# REST Client
#
```

### 缓存开发包

1. 缓存 elm 开发项目依赖包
1. python开发项目 poetry install
1. rust开发项目

	```shell
	ln -s /mnt/z/TEMP/ target
	mkdir .cargo
	cargo vendor --respect-source-config --versioned-dirs > .cargo/config.toml
	cargo build --release
	```

## 清理

```bash
sudo yum clean all
 
sudo rm -rf /var/log/*
sudo rm -rf /tmp/*
sudo rm -f /etc/resolv.conf
# rm -fr ~/.cache
# rm -fr ~/.npm
rm -fr ~/.bash_history
```

退出 wsl

## 导出分发包

在 windows 下运行

```bash
wsl --shutdown
wsl --export CentOS - | gzip -9 > z:\rootfs.tar.gz
```
