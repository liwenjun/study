# 实战`Debian`搭建开发环境

> 2025-03-08  以下安装软件版本均为此日期时的最新版本

```bash
# 在线查看可用 wsl 包
wsl --list --online

# 安装
# wsl --install --no-launch --web-download --distribution Debian
wsl --install --web-download --distribution Debian
```

## 基本配置项

```bash
# 添加普通用户lee免密
echo "lee ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/lee
sudo chmod 0440 /etc/sudoers.d/lee

# 编辑
sudo nano /etc/wsl.conf

# 加入以下内容
[boot]
systemd=true

# 使用内存盘
sudo systemctl link /usr/share/systemd/tmp.mount

# 重启

# 使用内存盘
rm -fr ~/.cache/
ln -s /tmp ~/.cache

# rm -fr ~/.config
# ln -s /tmp ~/.config

cd /var
sudo rm -fr tmp
sudo ln -s /tmp

# 解析git地址 
echo "185.199.108.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.109.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.110.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.111.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "140.82.112.4 github.com" | sudo tee -a /etc/hosts
echo "140.82.114.4 www.github.com" | sudo tee -a /etc/hosts
echo "199.232.5.194 github.global.ssl.fastly.net" | sudo tee -a /etc/hosts
echo "54.231.114.219 github-cloud.s3.amazonaws.com" | sudo tee -a /etc/hosts

# 为 pip 配置国内源
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn
EOF

# 解决 GUI 应用程序启动报错
echo "sudo rm -fr /tmp/.X11-unix && sudo ln -s /mnt/wslg/.X11-unix /tmp/.X11-unix" | sudo tee -a /etc/bash.bashrc

# 删除不用的软件包 vim-tiny
sudo apt autoremove --purge -y vim-tiny

# 退出 wsl 回到 windows
exit
wsl --shutdown
wsl	
```

## 大版本升级

```bash
# 从 Debian 11 升级到 Debian 12
sudo apt update
sudo apt upgrade
sudo apt full-upgrade
sudo apt autoremove

# 完成上述命令后，重新启动 Debian 11 系统：

# 记下关于 Debian 11 的几个信息
uname -mr
# > 5.15.167.4-microsoft-standard-WSL2 x86_64
cat /etc/debian_version
# > 11.3

# 修改 /etc/apt/sources.list 
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
deb https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware

# 更新
sudo apt update
sudo apt upgrade
sudo apt full-upgrade
sudo apt autoremove

# 重新启动
```

## 配置中文

````bash
# 更新
sudo apt update
sudo apt upgrade

# 设置中文
sudo apt install language-pack-zh-hans
sudo dpkg-reconfigure locales # 选择zh_CN.UTF-8和en_US.UTF-8, 默认zh_CN.UTF-8

# 有效设置显示
echo "export DISPLAY=:0.0" >> ~/.profile

#　安装 fcitx
sudo apt install fcitx \
	fonts-noto-cjk fonts-noto-core fonts-noto-color-emoji \
	dbus-x11 \
	fcitx-googlepinyin fcitx-table-wubi-large

# Confiure environment
# generate dbus machine id using root account:
# 已有 sudo dbus-uuidgen > /var/lib/dbus/machine-id

cat | sudo tee /etc/profile.d/fcitx.sh <<EOF
#!/bin/bash
export QT_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export DefaultIMModule=fcitx

# optional
fcitx-autostart &>/dev/null
EOF

# 退出重启 wsl

# 运行下列命令添加并配置输入法
fcitx-config-gtk3
````

## 本机 `C/C++` 开发环境

```bash
# 安装
sudo apt install curl git \
    wget unzip tree \
	build-essential gdb cmake \
	libssl-dev libffi-dev \
	pkg-config \
	python3-dev python3-pip python3-venv python3-setuptools 

# 配置 git
git config --global user.email "14991386@qq.com"
git config --global user.name "liwenjun"

# 安装最新稳定版clang, 当前18
sudo apt install lsb-release wget software-properties-common gnupg
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
```

## `ESP-IDF` 开发工具链

```bash
# 第一步：安装准备
sudo apt install flex bison gperf \
	ninja-build ccache \
	dfu-util libusb-1.0-0

# 第二步：获取 ESP-IDF
mkdir -p ~/esp
cd ~/esp
git clone -b v5.4 --recursive git@github.com:espressif/esp-idf.git
cd esp-idf
git submodule update --init --recursive

# 第三步：设置工具
cd ~/esp/esp-idf
# 推荐国内用户使用国内的下载服务器，以加快下载速度。
export IDF_GITHUB_ASSETS="dl.espressif.cn/github_assets"
./install.sh all # esp32s3

# 多个目标芯片
#./install.sh esp32,esp32s2
# 所有支持的目标芯片
#./install.sh all

# 第四步：设置环境变量
. $HOME/esp/esp-idf/export.sh

# 如果需要经常运行 ESP-IDF，可以为执行 export.sh 创建一个别名，具体步骤如下：
# 复制并粘贴以下命令到 shell 配置文件中（.profile、.bashrc 等）
alias get_idf='. $HOME/esp/esp-idf/export.sh'

# 现在可以在任何终端窗口中运行 get_idf 来设置或刷新 ESP-IDF 环境。

# 不建议直接将 export.sh 添加到 shell 的配置文件。这样做会导致在每个终端会话中都激活 IDF 虚拟环境（包括无需使用 ESP-IDF 的会话）。这违背了使用虚拟环境的目的，还可能影响其他软件的使用。

# 第五步：开始使用 ESP-IDF 吧
# 现在你已经具备了使用 ESP-IDF 的所有条件，接下来将介绍如何开始第一个工程。
# Configure Your Project
cd hello_world
idf.py set-target esp32s3
idf.py menuconfig
```

### 安装`VScode`插件

```
# 在 wsl 环境下安装 ESP-IDF 插件, clangd, python, 
```

## 编译 `MicroPython`

```bash
# 检出当前最新版本 https://micropython.org/
# 2025-02-21 版本是 v1.24.1
cd ~
git clone -b v1.24.1 --recursive git@github.com:micropython/micropython.git
cd micropython
git submodule update --init --recursive

# 先构建才能进行预编译
cd mpy-cross
make

# 构建文档
python3 -m venv env
source env/bin/activate
pip install -r docs/requirements.txt
cd docs
make html

# 如果需要构建 stm32 固件，需要 ARM 交叉编译器：
sudo apt install gcc-arm-none-eabi libnewlib-arm-none-eabi

# 编译v1.24.1仅支持 idf v5.2.2
# 切换idf版本
cd ~/esp/esp-idf
git checkout v5.2.2
git submodule update --init --recursive

# 安装编译工具
export IDF_GITHUB_ASSETS="dl.espressif.cn/github_assets"
./install.sh all
source export.sh 
```

## 安装配置 `Mosquitto`

```bash
sudo apt install mosquitto mosquitto-dev

# Download the EMQX repository
curl -s https://assets.emqx.com/scripts/install-emqx-deb.sh | sudo bash

# Install EMQX
sudo apt-get install emqx

# Run EMQX
sudo systemctl start emqx
```

## 配置 rust 开发环境

```bash
# 安装 rust 开发环境 
#RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup \
RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup \
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 删除html帮助文件，节省存储空间
rm -fr ~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc/rust/html

#
mkdir -p ~/.cargo/registry
ln -s /tmp ~/.cargo/registry/src

# 使用本地资源
#cd ~/.cargo/registry
#ln -s /mnt/c/Users/lee/scoop/persist/rustup-msvc/.cargo/registry/cache
#ln -s /mnt/c/Users/lee/scoop/persist/rustup-msvc/.cargo/registry/index

#
cat > ~/.cargo/config.toml <<EOF
[build]
# jobs = 1                      # number of parallel jobs, defaults to # of CPUs
target-dir = "/tmp/target"         # path of where to place all generated artifacts
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
```

### 安装常用工具

```
cargo install sqlx-cli --no-default-features -F postgres,native-tls,sqlite
cargo install diesel_cli --no-default-features --features "postgres sqlite"

# cargo install ripgrep
# cargo install mdbook mdbook-mermaid
```

## 清理并导出

```bash
sudo apt autoremove
sudo apt clean all

sudo rm -rf /var/log/*
rm -fr ~/.bash_history
```

```
# 导出分发包
cmd
wsl --shutdown
wsl --export Debian - | gzip -9 > z:\rootfs.tar.gz
```

## 用户配置

windows下执行：

```cmd
# 设置wsl默认用户为lee
wslconfig /s Debian
C:\wsl\Debian\Debian.exe config --default-user lee
```
