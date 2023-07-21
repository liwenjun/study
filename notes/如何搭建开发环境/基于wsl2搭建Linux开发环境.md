
CentOS的分发安装包下载，请点[CentOS-WSL](https://github.com/mishamosher/CentOS-WSL) ，[wsldl](https://github.com/yuk7/wsldl)

## 基本设置

这部分是操作系统级的通用设置。只需要在首次配置一次即可。 

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
   sqlite-devel postgresql-devel openssl-devel libffi-devel  
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

退出`wsl`返回`windows`，执行：
```powershell
# 设置wsl默认用户为lee  
cd /d D:\wsl\CentOS7  
CentOS.exe config --default-user lee
```

再次进入 `wsl`，此时以普通用户身份执行：
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
index-url = https://mirrors.aliyun.com/pypi/simple
[install]  
trusted-host = https://mirrors.aliyun.com/pypi/simple
EOF  

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
  
cat > ~/.cargo/config <<EOF
[build]  
# jobs = 1            # number of parallel jobs, defaults to # of CPUs  
target-dir = "/mnt/wsl/target"     # path of where to place all generated artifacts incremental = true      # whether or not to enable incremental compilation  
  
[cargo-new]  
vcs = "none"       # VCS to use ('git', 'hg', 'pijul', 'fossil', 'none')  
  
[profile.release]  
panic = "abort" # Strip expensive panic clean-up logic  
codegen-units = 1 # Compile crates one after another so the compiler can optimize better  
lto = true # Enables link to optimizations  
opt-level = "s" # Optimize for binary size  
strip = true # Remove debug symbols  
  
[source.crates-io]  
registry = "https://github.com/rust-lang/crates.io-index"  
replace-with = 'sjtu' # 如：tuna、sjtu、ustc，或者 rustcc  
  
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
```

安装开发辅助工具
```bash
cargo install --locked cargo-edit cargo-deny
cargo install --locked sqlx-cli --no-default-features -F postgres,native-tls,sqlite
cargo install --locked diesel_cli --no-default-features -F postgres,sqlite-bundled
cargo install --locked microserver
```

## 配置 elm 开发工具

```bash
# CentOS7 不支持高版本 Nodejs, 使用 v16 版本  
volta install node@16  
rm -f ~/.volta/tools/inventory/node/node-*-linux-x64.tar.gz  

# 缓存 elm 工具链  
cd /mnt/wsl
npm i -D elm-tooling
npx elm-tooling init
npx elm-tooling tools
npx elm-tooling install

# 全局启用 elm 工具链
cd ~/.volta/bin
ln -s ~/.elm/elm-tooling/elm/0.19.1/elm
ln -s ~/.elm/elm-tooling/elm-format/0.8.7/elm-format
ln -s ~/.elm/elm-tooling/elm-json/0.2.13/elm-json
ln -s ~/.elm/elm-tooling/elm-test-rs/3.0.0/elm-test-rs

# 全局安装辅助工具
volta install elm-doc-preview elm-review elm-watch
volta install npm-check-updates
volta install vite vite-plugin-elm
volta install elm-land
```

## 配置 java 开发环境

```bash
# 下载 Java 17 二进制文件
cd /mnt/z
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
sudo yum -y install ./jdk-17_linux-x64_bin.rpm
# 安装路径是 /usr/lib/jvm/jdk-17-oracle-x64/

# 安装 clojure
cd /mnt/z
sudo yum install -y rlwrap
curl -O https://download.clojure.org/install/linux-install-1.11.1.1347.sh
chmod +x linux-install-1.11.1.1347.sh
sudo ./linux-install-1.11.1.1347.sh

clj -h

# Practicalli Clojure CLI Config
git clone https://github.com/practicalli/clojure-deps-edn.git $XDG_CONFIG_HOME/clojure
```

## 配置 vscode 运行环境

```
# 安装下列plugin  

Elm
Python
rust-analyse
Calva
REST Client
```

## 缓存开发包

1. 缓存 elm 开发项目依赖包
2. python开发项目 poetry install
3. rust开发项目   
    mkdir .cargo  
    cargo vendor --respect-source-config --versioned-dirs > .cargo/config.toml  

## 清理

```bash
sudo yum clean all
sudo rm -rf /var/log/*
sudo rm -rf /tmp/*
sudo rm -f /etc/resolv.conf
# rm -fr ~/.cache
# rm -fr ~/.npm
rm -f ~/.bash_history
```

## 导出分发包

在 windows 下运行 `cmd`
```cmd
wsl --shutdown
wsl --export CentOS - | gzip -9 > z:\rootfs.tar.gz
```
