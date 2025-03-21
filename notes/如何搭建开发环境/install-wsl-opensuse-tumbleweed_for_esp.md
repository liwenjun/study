﻿# 实战`openSUSE Tumbleweed`用于esp单片机开发

> 2025-02-09  以下安装软件版本均为此日期时的最新版本

去微软官方下载分发包 [`openSUSE Tumbleweed`](https://aka.ms/wsl-opensuse-tumbleweed)


```bash
# 在线查看可用 wsl 包
wsl --list --online

# 安装
# wsl --install --no-launch --web-download --distribution openSUSE-Tumbleweed
wsl --install --web-download --distribution openSUSE-Tumbleweed
```


## 初始配置

按标准方法安装。设置用户`lee`。

```bash
# 添加普通用户lee免密
echo "lee ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/lee
sudo chmod 0440 /etc/sudoers.d/lee

# 解析git地址 
echo "185.199.108.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.109.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.110.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.111.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "140.82.112.4 github.com" | sudo tee -a /etc/hosts
echo "140.82.114.4 www.github.com" | sudo tee -a /etc/hosts
echo "199.232.5.194 github.global.ssl.fastly.net" | sudo tee -a /etc/hosts
echo "54.231.114.219 github-cloud.s3.amazonaws.com" | sudo tee -a /etc/hosts

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

# 为 pip 配置国内源
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn
EOF

# 更新大版本
# 安装时原版本
cat /etc/os-release
NAME="openSUSE Tumbleweed"
VERSION_ID="20240924"

# 更新
sudo zypper ref
sudo zypper dup

# 更新后版本
cat /etc/os-release
NAME="openSUSE Tumbleweed"
VERSION_ID="20250207"

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
sudo zypper install git nano tree

# 配置 git
git config --global user.email "14991386@qq.com"
git config --global user.name "liwejun"
```

## `ESP-IDF` 开发工具链

```bash
# 第一步：安装准备
sudo zypper install \
	wget flex bison gperf \
	cmake ninja ccache \
	dfu-util libusb-1_0-0 \
	python311-devel python311-setuptools

# 第二步：获取 ESP-IDF
mkdir -p ~/esp
cd ~/esp
git clone -b v5.4 --recursive git@github.com:espressif/esp-idf.git
# git clone -b v5.4 --recursive https://github.com/espressif/esp-idf.git
cd esp-idf
git submodule update --init --recursive

# 第三步：设置工具
cd ~/esp/esp-idf
# 推荐国内用户使用国内的下载服务器，以加快下载速度。
export IDF_GITHUB_ASSETS="dl.espressif.cn/github_assets"
./install.sh esp32s3

# 多个目标芯片
./install.sh esp32,esp32s2
# 所有支持的目标芯片
./install.sh all

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



```
Install Remote WSL extension in Visual Studio Code
Install the Remote - WSL, Remote Development and ESP-IDF extensions
```

## rust 工具链

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

#
cargo install --locked mdbook mdbook-mermaid
cargo install sqlx-cli --no-default-features -F postgres,native-tls,sqlite
cargo install diesel_cli --no-default-features --features "postgres sqlite"

# 嵌入式开发工具

# Cortex-M0, M0+, and M1 (ARMv6-M architecture):
rustup target add thumbv6m-none-eabi

# Cortex-M3 (ARMv7-M architecture):
rustup target add thumbv7m-none-eabi

# Cortex-M4 and M7 without hardware floating point (ARMv7E-M architecture):
rustup target add thumbv7em-none-eabi

# Cortex-M4F and M7F with hardware floating point (ARMv7E-M architecture):
rustup target add thumbv7em-none-eabihf

# Cortex-M23 (ARMv8-M architecture):
rustup target add thumbv8m.base-none-eabi

# Cortex-M33 and M35P (ARMv8-M architecture):
rustup target add thumbv8m.main-none-eabi

# Cortex-M33F and M35PF with hardware floating point (ARMv8-M architecture):
rustup target add thumbv8m.main-none-eabihf

# cargo-binutils
cargo install cargo-binutils
rustup component add llvm-tools

# cargo-generate
cargo install cargo-generate

#
sudo zypper install gdb openocd # qemu-arm
```

## 

## 配置 `Arduino-IDE`

```bash
#
sudo sudo zypper in libnss3 libsecret-1-0

# 
sudo usermod -a -G dialout,lock $USER && \
sudo zypper install git python311-pip python311-pyserial; \
mkdir -p ~/Arduino/hardware/espressif && \
cd ~/Arduino/hardware/espressif && \
git clone git@github.com:espressif/arduino-esp32.git esp32 && \
cd esp32/tools && \
python3 get.py  
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



## Windows主机`USB`配置

先下载安装[`usbipd-win`](https://github.com/dorssel/usbipd-win/releases)软件。 

```powershell
# 先将开发板连接上
usbipd list

# 列出usb清单
BUSID  VID:PID    DEVICE                                                        STATE
1-2    1a86:7523  USB-SERIAL CH340 (COM5)                                       Not shared
1-10   0a5c:5832  Broadcom USH, Microsoft Usbccid Smartcard Reader (WUDF)       Not shared
1-11   1bcf:2b96  Integrated Webcam                                             Not shared
1-14   8087:0025  英特尔(R) 无线 Bluetooth(R)                                   Not shared

# 以管理员权限运行绑定
usbipd bind --busid 1-2   # <BUSID>
usbipd attach --wsl --busid 1-2  # <BUSID>
```

```bash
# wsl侧
dmesg | tail

[ 1564.550941] usb 1-1: new full-speed USB device number 2 using vhci_hcd
[ 1564.630364] vhci_hcd: vhci_device speed not set
[ 1564.700349] usb 1-1: SetAddress Request (2) to port 0
[ 1564.734023] usb 1-1: New USB device found, idVendor=1a86, idProduct=7523, bcdDevice=81.34
[ 1564.734764] usb 1-1: New USB device strings: Mfr=0, Product=2, SerialNumber=0
[ 1564.735439] usb 1-1: Product: USB Serial
[ 1564.755957] usbcore: registered new interface driver ch341
[ 1564.756559] usbserial: USB Serial support registered for ch341-uart
[ 1564.757097] ch341 1-1:1.0: ch341-uart converter detected
[ 1564.759570] usb 1-1: ch341-uart converter now attached to ttyUSB0

# 可见 usb 绑定为 ttyUSB0
```

