# 实战`Ubuntu`配置开发环境

> 2025-03-12  以下安装软件版本均为此日期时的最新版本

```bash
# 在线查看可用 wsl 包
wsl --list --online

# 安装
# wsl --install --no-launch --web-download --distribution Ubuntu
wsl --install --web-download --distribution Ubuntu
```

## 基本配置项

```bash
# 添加普通用户lee免密
echo "lee ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/lee
sudo chmod 0440 /etc/sudoers.d/lee

# 添加权限允许用户访问串口
sudo usermod -a -G dialout $USER

# 启动 systemd
cat | sudo tee /etc/wsl.conf <<EOF
[boot]
systemd=true
EOF

# 使用内存盘
sudo systemctl link /usr/share/systemd/tmp.mount

# 使用内存盘
rm -fr ~/.cache/
ln -s /tmp ~/.cache

# rm -fr ~/.config
# ln -s /tmp ~/.config

sudo rm -fr /var/tmp
sudo ln -s /tmp /var/tmp

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

# 为 pip 配置国内源
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn
EOF

# 配置 git
git config --global user.email "14991386@qq.com"
git config --global user.name "liwenjun"

# 解决 GUI 应用程序启动报错
echo "sudo rm -fr /tmp/.X11-unix && sudo ln -s /mnt/wslg/.X11-unix /tmp/.X11-unix" | sudo tee -a /etc/bash.bashrc

# 删除不用的软件包 snapd、packagekit、vim-tiny
sudo apt autoremove --purge -y \
	snapd \
	packagekit \
	vim-tiny
	
# 退出 wsl 回到 windows
exit
wsl --shutdown
wsl	
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
sudo apt install fcitx dbus-x11 \
	fcitx-googlepinyin fcitx-table-wubi-large

sudo apt install fonts-noto-cjk fonts-noto-core fonts-noto-color-emoji

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
sudo apt install wget nano unzip tree \
	build-essential gdb cmake \
	libssl-dev libffi-dev \
	pkg-config \
	python3-dev python3-pip python3-venv python3-setuptools 

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
# 推荐国内用户使用国内的下载服务器，以加快下载速度。
export IDF_GITHUB_ASSETS="dl.espressif.cn/github_assets"
./install.sh all

# 多个目标芯片
#./install.sh esp32,esp32s2

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
idf.py build
idf.py flash monitor
```

### 更新 ESP-IDF

```bash
cd $IDF_PATH
git fetch

# 更新到指定版本
# git checkout vX.Y.Z
# 此处输入确定的版本号，比如 v5.4
git checkout v5.4

# 更新至 master 分支
git checkout master
git pull

# 刷新子包
git submodule update --init --recursive
# 推荐国内用户使用国内的下载服务器，以加快下载速度。
export IDF_GITHUB_ASSETS="dl.espressif.cn/github_assets"
./install.sh all
```

### 安装`VScode`插件

```
# 在 wsl 环境下安装 ESP-IDF 插件, clangd, python, 
```

## 编译 `MicroPython`

```bash
## 内容占用空间较多，不放在wsl中。

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
git fetch
git checkout v5.2.2
git submodule update --init --recursive

# 安装编译工具
export IDF_GITHUB_ASSETS="dl.espressif.cn/github_assets"
./install.sh all
source export.sh 
```

## 安装配置 `Mosquitto`

```bash
sudo apt-add-repository ppa:mosquitto-dev/mosquitto-ppa
sudo apt update
sudo apt install mosquitto mosquitto-dev
```

## 配置 rust 开发环境

```bash
# 安装 rust 开发环境 
# latest update on 2024-11-28, rust version 1.83.0 (90b35a623 2024-11-26)
#RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup \
#RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup \
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

## `Arduino-IDE`开发环境

[Windows WSL子系统Ubuntu22.04安装`Nvidia`显卡驱动](https://blog.csdn.net/no1xium/article/details/131299917)

```bash
# Arduino-IDE 依赖
sudo apt install libnss3

#
sudo usermod -a -G dialout $USER && \
sudo apt install python3-serial && \
mkdir -p ~/Arduino/hardware/espressif && \
cd ~/Arduino/hardware/espressif && \
git clone --recursive git@github.com:espressif/arduino-esp32.git esp32 && \
cd esp32/tools && \
python3 get.py
# get.py 使用了 ../package/*.json 配置文件，修改此文件的url指向国内源，可加快速度 
# 将 https://github.com 替换为 https://dl.espressif.cn/github_assets

# 补充 Windows 环境下的手动安装流程
# 1、 进入我的文档目录 C:/Users/lee/Documents
# 2、 创建并进入子目录 [C:/Users/lee/Documents/]Arduino/hardware/espressif
cd C:/Users/lee/Documents/Arduino/hardware/espressif
git clone --recursive git@github.com:espressif/arduino-esp32.git esp32
cd esp32
git submodule update --init --recursive
# 在安装编译工具前，先编辑配置文件 package/package_esp32_index.template.json 使用国内源
#
./tools/get.exe
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
wsl --export Ubuntu - | gzip -9 > z:\rootfs.tar.gz
```

## 用户配置

windows下执行：

```cmd
# 设置wsl默认用户为lee
wslconfig /s Ubuntu
C:\wsl\Ubuntu\Ubuntu.exe config --default-user lee
```
