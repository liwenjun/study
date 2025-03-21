# 实战`Debian`多系统安装

> 2025-03-09
> 选择安装KDE桌面

## 基本配置项

```bash
# 以root身份执行
su -
usermod -aG sudo lee
groups lee
exit

# 添加普通用户lee免密
echo "lee ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/lee
sudo chmod 0440 /etc/sudoers.d/lee

# 使用内存盘
sudo systemctl link /usr/share/systemd/tmp.mount

# 重启

# 使用内存盘
rm -fr ~/.cache/
ln -s /tmp ~/.cache

cd /var
sudo rm -fr tmp
sudo ln -s /tmp

# 解析git地址 
sudo tee -a /etc/hosts <<EOF
185.199.108.133 raw.githubusercontent.com
185.199.109.133 raw.githubusercontent.com
185.199.110.133 raw.githubusercontent.com
185.199.111.133 raw.githubusercontent.com
140.82.112.4 github.com
140.82.114.4 www.github.com
199.232.5.194 github.global.ssl.fastly.net
54.231.114.219 github-cloud.s3.amazonaws.com
EOF

# 配置 git
git config --global user.email "14991386@qq.com"
git config --global user.name "liwenjun"

# 为 npm 配置国内源
echo 'registry=https://registry.npmmirror.com' >> ~/.npmrc

# 为 pip 配置国内源
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn
EOF

# 删除不用的软件包 vim-tiny
sudo apt autoremove --purge -y vim-tiny

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
sudo apt full-upgrade
sudo apt autoremove

# 重新启动
```

## 安装 NVIDIA 驱动

```bash
# 本节暂不执行
# 安装必要的组件
sudo apt install linux-headers-$(uname -r) build-essential libglvnd-dev pkg-config

# 为了防止无意升级内核造成驱动不能用，要先禁止内核更新 来源: https://blog.csdn.net/CanvaChen/article/details/131254870
sudo dpkg --get-selections | grep linux-(image|headers)

# 将结果里的 linux-image 和 linux-headers 固定版本，例如:
sudo apt-mark hold linux-image-6.1.0-31-amd64 linux-headers-6.1.0-31-amd64 linux-headers-6.1.0-31-common

# 得到如下的结果说明版本已经 hold：
linux-image-6.1.0-31-amd64 set on hold.
linux-headers-6.1.0-31-amd64 set on hold.
linux-headers-6.1.0-31-common set on hold.
```

```bash
# 步骤1：更新Debian系统
sudo apt update
sudo apt upgrade

# 步骤2：识别Nvidia显卡
lspci | grep -i nvidia

# 此命令将列出连接到系统的所有硬件，并筛选出仅与Nvidia相关的条目。查找描述显卡的行，看起来像这样：
01:00.0 VGA compatible controller: NVIDIA Corporation GP107GLM [Quadro P1000 Mobile] (rev a1)
01:00.1 Audio device: NVIDIA Corporation GP107GL High Definition Audio Controller (rev a1)

# 步骤3：添加非免费存储库
# 前面已配置

# 步骤4：在Debian中安装Nvidia驱动程序
# 最简单的方法是使用nvidia-detect工具，它将为您的显卡推荐最佳驱动程序：
sudo apt install nvidia-detect
nvidia-detect

# 输出将会像这样：
Detected NVIDIA GPUs:
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation ...

It is recommended to install the
	nvidia-driver
package.

# 推荐的软件包是nvidia-driver，因此安装它即可：
sudo apt install nvidia-driver

# 如果nvidia-detect推荐不同的软件包，请用推荐的软件包名称替换nvidia-driver。
# 在安装过程中，可能会要求你确认是否要安装驱动程序，按Y和Enter继续即可。

# 安装完成后，重新启动

# 系统重新启动后，可以验证Nvidia驱动程序是否已安装并正常工作，命令如下：
nvidia-smi

# 此命令将显示有关Nvidia显卡的信息，包括驱动程序版本和GPU使用情况。如果你看到此信息，则表示驱动程序已正确安装。
```

**故障排除**

如果安装驱动程序后遇到任何问题，可以尝试以下几种方法解决：

- 重启后黑屏：如果重启后屏幕变黑，可能需要切换到其它终端（例如，按 CTRL + ALT + F2），然后重新安装驱动程序。也可以尝试在启动时使用nomodeset内核参数。
- 驱动程序未加载：如果驱动程序未加载，请确保已安装nvidia-kernel-dkms软件包，该软件包可确保Nvidia内核模块正确构建并适用于系统。
- 错误的驱动程序：如果安装了错误的驱动程序，可以使用sudo apt remove nvidia-*来删除它，然后安装正确的驱动程序。

## 安装 Qemu

```bash
sudo apt update
sudo apt install qemu-system \
	libvirt-daemon-system libvirt-clients \
	bridge-utils virt-manager \
	qemu-guest-agent

#
sudo usermod -aG kvm $USER
sudo usermod -aG libvirt $USER
```

## 安装 Microsoft Edge 和 Vscode

```bash
# 1
sudo apt install software-properties-common apt-transport-https ca-certificates curl -y

# 2
curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg > /dev/null

# 3
echo 'deb [signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list

echo 'deb [signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/code stable main' | sudo tee /etc/apt/sources.list.d/vscode.list

# 4
sudo apt update

# 5
sudo apt install code microsoft-edge-stable
```

## 配置 python 环境

```bash
# 安装 Thonny 及 python3扩展
sudo apt install thonny \
	python3-ptyprocess \
	python3-tk tk-dev \
	python3-dev python3-venv \
	python3-pip python3-setuptools 

# 安装 poetry 2.1.1
curl -sSL https://install.python-poetry.org | python3 -


# 配置 pyenv
curl https://pyenv.run | bash

# Running `pyenv install -l` gives the list of all avaisudo apt install 
# to download and install Python 3.13, run:
pyenv install 3.13
```

## 本机 `C/C++` 开发环境

```bash
# 安装
sudo apt install lsb-release unzip tree \
	aria2 pkg-config \
	flex bison gperf \
	ninja-build ccache \
	build-essential gdb \
	libssl-dev libffi-dev 

# 安装新版本 cmake
cd /tmp
VER=3.31.6 && \
	wget https://github.com/Kitware/CMake/releases/download/v$VER/cmake-$VER-linux-x86_64.sh && \
	chmod +x cmake-$VER-linux-x86_64.sh && cd /opt && /tmp/cmake-$VER-linux-x86_64.sh

# 安装最新稳定版clang, 当前19
sudo bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

# 添加所有可用的 llvm-config 版本到 update-alternatives
sudo update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-19 100
# 选择默认版本
sudo update-alternatives --config llvm-config

# 添加所有可用的 clang 版本到 update-alternativessudo
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-19 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-19 100
sudo update-alternatives --install /usr/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-19 100
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-19 100
# 选择默认版本
sudo update-alternatives --config clang
sudo update-alternatives --config clang++
sudo update-alternatives --config clang-cpp
sudo update-alternatives --config clangd
```

## 安装 postgresql

```bash
sudo apt install postgresql postgresql-contrib libpq-dev

# 版本
psql --version
## psql (PostgreSQL) 15.10 (Debian 15.10-0+deb12u1)

# 查询状态
sudo systemctl status postgresql
# sudo service postgresql status

# 启停操作
sudo systemctl start|stop|restart postgresql
# sudo service postgresql start|stop|restart
```

### 管理配置 postgresql

```bash
# 查看配置文件
sudo -u postgres psql -c 'SHOW config_file'
## /etc/postgresql/15/main/postgresql.conf

sudo -u postgres psql -c 'SHOW hba_file'
## /etc/postgresql/15/main/pg_hba.conf

# 修改配置允许外部访问
sudo nano /etc/postgresql/15/main/postgresql.conf
## 将
## #listen_addresses = 'localhost'
## 改为
## listen_addresses = '*'

# 允许 所有主机通过密码访问
echo "host    all             all             0.0.0.0/0            scram-sha-256" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf
echo "host    all             all             ::/0                 scram-sha-256" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf

# sudo nano /etc/postgresql/15/main/pg_hba.conf
## 在文件末尾添加如下二行
## host    all             all             0.0.0.0/0            scram-sha-256
## host    all             all             ::/0                 scram-sha-256

# 重启生效
sudo service postgresql restart
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

## 安装配置 `Docker`

```bash
#
curl -sSL https://download.docker.com/linux/debian/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/docker-ce.gpg > /dev/null
#
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce.gpg] https://download.docker.com/linux/debian $(lsb_release -sc) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# 使用国内镜像源 
curl -sS https://download.docker.com/linux/debian/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/docker-ce.gpg > /dev/null
#
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-ce.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian $(lsb_release -sc) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 如果需要某个特定用户可以用 Docker rootless 模式运行 Docker，那么可以把这个用户也加入 docker 组，比如我们把 lee 用户加进去：
sudo apt install docker-ce-rootless-extras
sudo usermod -aG docker lee

# 检查
docker version
```

### 修改 Docker 配置

以下配置添加国内镜像源，会限制日志文件大小，防止 Docker 日志塞满硬盘 (泪的教训)：

```bash
# 写入配置文件
sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
      "https://docker-0.unsee.tech",
      "https://docker-cf.registry.cyou",
      "https://docker.1panel.live"
    ],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "20m",
        "max-file": "3"
    }
}
EOF
```

然后重启 Docker 服务：

```bash
sudo systemctl restart docker
```

好了，我们已经安装好了

### 拉常用`docker`资源

```bash
# pull images
docker compose -f oracle.yaml pull
```

## `ESP-IDF` 开发工具链

```bash
# 第一步：安装准备
sudo apt install dfu-util libusb-1.0-0

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

## 编译 `MicroPython`

```bash
# 检出当前最新版本 https://micropython.org/
# 2025-03-09 版本是 v1.24.1
cd ~
git clone -b v1.24.1 --recursive git@github.com:micropython/micropython.git
cd micropython
git submodule update --init --recursive

# 先构建才能进行预编译
make -C mpy-cross

# 构建文档
python3 -m venv env
source env/bin/activate
pip install -r docs/requirements.txt
cd docs
make html

# 构建 unix port
cd ports/unix
make submodules
make

LINK build-standard/micropython
   text    data     bss     dec     hex filename
 725974   69304    7088  802366   c3e3e build-standard/micropython

# 保存一份到可查找路径下
cp build-standard/micropython ~/.local/bin/


# 如果需要构建 stm32 固件，需要 ARM 交叉编译器：
#sudo apt install gcc-arm-none-eabi libnewlib-arm-none-eabi

# 编译v1.24.1仅支持 idf v5.2.2
# 切换idf版本
cd ~/esp/esp-idf
git checkout v5.2.2
git submodule update --init --recursive

# 安装编译工具
export IDF_GITHUB_ASSETS="dl.espressif.cn/github_assets"
./install.sh all
source export.sh 
# 删除不兼容的工具
python /home/lee/esp/esp-idf/tools/idf_tools.py uninstall

# 原版编译，仅支持4M或8M
cd ~/micropython/ports/esp32
make BOARD=ESP32_GENERIC_S3 submodules
export IDF_TARGET=esp32s3
make BOARD=ESP32_GENERIC_S3 BOARD_VARIANT=SPIRAM_OCT

# 先擦除
python -m esptool --chip esp32s3 erase_flash

# 烧写
python -m esptool --chip esp32s3 -b 460800 --before default_reset --after hard_reset write_flash --flash_mode dio --flash_size 8MB --flash_freq 80m 0x0 build-ESP32_GENERIC_S3-SPIRAM_OCT/bootloader/bootloader.bin 0x8000 build-ESP32_GENERIC_S3-SPIRAM_OCT/partition_table/partition-table.bin 0x10000 build-ESP32_GENERIC_S3-SPIRAM_OCT/micropython.bin

bootloader  @0x000000    19152  (   13616 remaining)
partitions  @0x008000     3072  (    1024 remaining)
application @0x010000  1597168  (  434448 remaining)
total                  1662704
```

### 定制编译 esp32-s3-N16R8 版本

```bash
cd ~/micropython/ports/esp32/boards/
cp -R ESP32_GENERIC_S3 ESP32_GENERIC_S3_N16R8
cd ESP32_GENERIC_S3_N16R8
```

只保留4个文件：

```
board.json
mpconfigboard.cmake
mpconfigboard.h
sdkconfig.board
```

`board.json`
```json
{
    "deploy": [
        "../deploy_s3.md"
    ],
    "docs": "",
    "features": [
        "BLE",
        "External Flash",
        "External RAM",
        "WiFi"
    ],
    "images": [
        "generic_s3.jpg"
    ],
    "mcu": "esp32s3",
    "product": "ESP32-S3-N16R8",
    "thumbnail": "",
    "url": "https://www.espressif.com/en/products/modules",
    "vendor": "Espressif"
}
```

`mpconfigboard.cmake`
```cmake
set(IDF_TARGET esp32s3)

set(SDKCONFIG_DEFAULTS
    boards/sdkconfig.base
    ${SDKCONFIG_IDF_VERSION_SPECIFIC}
    boards/sdkconfig.usb
    boards/sdkconfig.ble
    boards/sdkconfig.spiram_sx
    boards/ESP32_GENERIC_S3_N16R8/sdkconfig.board
    boards/sdkconfig.240mhz
    boards/sdkconfig.spiram_oct
)

list(APPEND MICROPY_DEF_BOARD
    MICROPY_HW_BOARD_NAME="Generic ESP32S3 module with Octal-SPIRAM"
```

`mpconfigboard.h`
```h
#ifndef MICROPY_HW_BOARD_NAME
// Can be set by mpconfigboard.cmake.
#define MICROPY_HW_BOARD_NAME               "Generic ESP32S3 module"
#endif
#define MICROPY_HW_MCU_NAME                 "ESP32S3"

// Enable UART REPL for modules that have an external USB-UART and don't use native USB.
#define MICROPY_HW_ENABLE_UART_REPL         (1)

#define MICROPY_HW_I2C0_SCL                 (9)
#define MICROPY_HW_I2C0_SDA                 (8)
```

`sdkconfig.board`
```
CONFIG_ESPTOOLPY_FLASHMODE_QIO=y
CONFIG_ESPTOOLPY_FLASHFREQ_80M=y
CONFIG_ESPTOOLPY_AFTER_NORESET=y

CONFIG_ESPTOOLPY_FLASHSIZE_4MB=
CONFIG_ESPTOOLPY_FLASHSIZE_8MB=
CONFIG_ESPTOOLPY_FLASHSIZE_16MB=y
CONFIG_PARTITION_TABLE_CUSTOM=y
CONFIG_PARTITION_TABLE_CUSTOM_FILENAME="partitions-16MiB.csv"
```

编译+烧录：

```bash
cd ~/micropython/ports/esp32
make BOARD=ESP32_GENERIC_S3_N16R8 submodules
export IDF_TARGET=esp32s3
make BOARD=ESP32_GENERIC_S3_N16R8

Partition table binary generated. Contents:
*******************************************************************************
# ESP-IDF Partition Table
# Name, Type, SubType, Offset, Size, Flags
nvs,data,nvs,0x9000,24K,
phy_init,data,phy,0xf000,4K,
factory,app,factory,0x10000,1984K,
vfs,data,fat,0x200000,14M,
*******************************************************************************

# 先擦除
python -m esptool --chip esp32s3 erase_flash

# 烧写
python -m esptool --chip esp32s3 -b 460800 --before default_reset --after no_reset write_flash --flash_mode dio --flash_size 16MB --flash_freq 80m 0x0 build-ESP32_GENERIC_S3_N16R8/bootloader/bootloader.bin 0x8000 build-ESP32_GENERIC_S3_N16R8/partition_table/partition-table.bin 0x10000 build-ESP32_GENERIC_S3_N16R8/micropython.bin
or from the "/home/lee/micropython/ports/esp32/build-ESP32_GENERIC_S3_N16R8" directory
 python -m esptool --chip esp32s3 -b 460800 --before default_reset --after no_reset write_flash "@flash_args"
bootloader  @0x000000    19152  (   13616 remaining)
partitions  @0x008000     3072  (    1024 remaining)
application @0x010000  1597168  (  434448 remaining)
total                  1662704
```

## 安装配置 `Mosquitto`

```bash
sudo apt install mosquitto mosquitto-dev

# Download the EMQX repository
curl -s https://assets.emqx.com/scripts/install-emqx-deb.sh | sudo bash

# Install EMQX
sudo apt install emqx

# Run EMQX
sudo systemctl start emqx
```

## `Arduino-IDE`开发环境

```bash
# 下载安装包
cd /tmp
# wget https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.4_Linux_64bit.AppImage
aria2c -c https://downloads.arduino.cc/arduino-ide/arduino-ide_2.3.4_Linux_64bit.AppImage

cd /opt
sudo mv /tmp/arduino-ide_2.3.4_Linux_64bit.AppImage .
sudo chmod +x arduino-ide_2.3.4_Linux_64bit.AppImage
sudo ln -s arduino-ide_2.3.4_Linux_64bit.AppImage arduino-ide

cd ~/.local/bin
ln -s /opt/arduino-ide_2.3.4_Linux_64bit.AppImage arduino-ide

# 手工安装esp开发链
sudo usermod -a -G dialout $USER
sudo apt install python3-serial
mkdir -p ~/Arduino/hardware/espressif
cd ~/Arduino/hardware/espressif
git clone --recursive git@github.com:espressif/arduino-esp32.git esp32
cd esp32
git submodule update --init --recursive
cd tools
# 内置的python3.11会报错。可通过pyenv安装python3.13
python3 get.py
# get.py 使用了 ../package/*.json 配置文件，修改此文件的url指向国内源，可加快速度 
# 将 https://github.com 替换为 https://dl.espressif.cn/github_assets
```


## 安装 Android Studio

```bash
# Step 1
sudo apt update
sudo apt upgrade

# Step 2. Install Dependencies.
sudo apt install default-jdk

# Step 3. Installing Android Studio on Debian 12.
cd /tmp
aria2c -c https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.3.1.13/android-studio-2024.3.1.13-linux.tar.gz

cd /opt
sudo tar -xvf /tmp/android-studio-2024.3.1.13-linux.tar.gz

# Step 4
cd android-studio/bin
./studio

# Follow the on-screen instructions to complete the setup wizard. This process includes selecting a UI theme, downloading necessary SDK components, and configuring settings.
```

## 配置 rust 开发环境

```bash
# 安装 rust 开发环境 
#RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup \
#RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup \
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

#
mkdir -p ~/.cargo/registry
ln -s /tmp ~/.cargo/registry/src

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

```bash
cargo install sqlx-cli --no-default-features -F postgres,native-tls,sqlite
cargo install diesel_cli --no-default-features --features "postgres sqlite"

# cargo install ripgrep
# cargo install mdbook mdbook-mermaid
```

### tauri 开发支持

```bash
# 安装依赖包
sudo apt install libwebkit2gtk-4.1-dev \
  libxdo-dev \
  libssl-dev \
  file \
  libayatana-appindicator3-dev \
  librsvg2-dev

# 安装开发工具
cargo install create-tauri-app --locked
cargo install tauri-cli --locked

# 测试一下
cd /tmp
cargo create-tauri-app
cd tauri-app
cargo tauri dev
```

### tauri + android 开发支持

```bash
# 安装 android studio

# 当前用户加入kvm, 运行模拟器
# sudo groupadd -r kvm
sudo gpasswd -a $USER kvm

# Use the SDK Manager in Android Studio to install the following:
Android SDK Platform
Android SDK Platform-Tools
NDK (Side by side)
Android SDK Build-Tools
Android SDK Command-line Tools

# Set ANDROID_HOME and NDK_HOME environment variables.
export ANDROID_HOME="$HOME/Android/Sdk"
export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk)"

# Add the Android targets with rustup:
rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi \
	i686-linux-android \
	x86_64-linux-android
```


## 配置 elm 开发工具

```bash
# 安装 volta (JavaScript命令行管理工具)
# version 2.0.2
curl https://get.volta.sh | bash

# 版本 node-v22.12.0
volta install node
rm -f ~/.volta/tools/inventory/node/node-*-linux-x64.tar.gz

#
cd ~/.volta/
rm -fr log
ln -s /tmp log

# 配置安装 elm 工具链
cd /tmp
npm init -y
npm i -D elm-tooling
npx elm-tooling init
npx elm-tooling tools
npx elm-tooling install

# 安装 lamdera
# Version 1.3.2
curl https://static.lamdera.com/bin/lamdera-1.3.2-linux-x86_64 -o ~/.elm/elm-tooling/lamdera-1.3.2-linux-x86_64
chmod a+x ~/.elm/elm-tooling/lamdera-1.3.2-linux-x86_64

# 配置用户全局使用
mkdir -p ~/.local/bin
cd ~/.local/bin
ln -s ~/.elm/elm-tooling/elm/0.19.1/elm
ln -s ~/.elm/elm-tooling/elm-format/0.8.7/elm-format
ln -s ~/.elm/elm-tooling/elm-json/0.2.13/elm-json
ln -s ~/.elm/elm-tooling/elm-test-rs/3.0.0/elm-test-rs
ln -s ~/.elm/elm-tooling/lamdera-1.3.2-linux-x86_64 lamdera

# 全局安装常用工具
volta install elm-doc-preview
volta install elm-review elm-test elm-watch elm-land npm-check-updates
```


## 配置 Haskell 开发环境

```bash
# 安装依赖包
sudo apt install \
	libffi-dev \
	libffi8 \
 	libgmp-dev \
 	libgmp10 \
 	libncurses-dev \
 	libncurses5 \
 	libtinfo5 \
 	pkg-config

# ghcup
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# 安装 hls
ghcup tui
```

## 安装电子书阅读软件

[calibre](https://calibre-ebook.com/zh_CN)
[koodo reader](https://koodo.960960.xyz/zh)
[foliate](https://johnfactotum.github.io/foliate/)


```bash
#
sudo apt install foliate

# 安装程序之前，您必须在系统上安装 xdg-utils，wget，xz-utils和python
# 独立安装，不需要root权限
wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin install_dir=~/.local isolated=y

#sudo -v && wget --no-check-certificate -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin

# 如果在终端运行Calibre时遇到关于Wayland的错误，且Calibre未启动，请以QT_QPA_PLATFORM=xcb calibre身份运行Calibre，这将阻止其使用Wayland。

# 如果出现错误 Could not load the Qt platform plugin xcb 您缺少一些所需的X11-XCB库，例如libxcb-cursor0或libxcb-xinerama0，有关 详细信息

# 如果你在服务器上得到关于缺失“libEGL”的报错，你可能需要安装如“libegl1”和“libopengl0”等一些OpenGL包。
```


## 安装 Beyond Compare

```bash
cd /tmp
tar -zxvf bcompare-5.0.4.30422.x86_64.tar.gz
cd bcompare-5.0.4.30422
# copy BCompare BC5key.txt 到本目录
sudo ./install.sh
```


## 安装 `Typora`

```bash
# 解压缩安装包
cd ~/.local
tar -Jxvf typora.tar.xz

# 创建链接
cd ~/.local/bin
ln -s ../Typora-linux-x64/Typora typora

# Crack
cd ../Typora-linux-x64/Typora
./node_inject
./license-gen

License for you: 8M2MHH-F5Y7FM-LTUE49-LRJ7DT
```

## 安装其他工具

```bash
# pdf 分割与合并工具
#sudo apt install pdfsam
```

## 清理旧的内核

在运行

```
sudo apt update && sudo apt upgrade
```

或者

```
sudo apt update && sudo apt full-upgrade
```

后如果更新了新的内核虽然通常情况下会自动更新`GRUB`配置文件

但是还是建议手动运行

```
sudo update-grub
```

更新配置文件防止特殊情况没有自动更新`GRUB`配置文件

使用以下命令查看当前正在使用的内核防止删除错误

```
uname -r
```

查看系统中安装的所有内核版本

```
dpkg --list | grep linux-image
```

运行`apt autoremove --purge`会删除不再使用的旧内核，但系统会保留至少一个备用的内核

```
sudo apt autoremove --purge
```

如果你只想保留正在使用的内核可以手动删除指定内核

```
sudo apt remove --purge linux-image-6.1.0-29-amd64
```

如果你安装过内核头文件还需要清理内核头文件

列出系统重的内核头文件

```
dpkg --list | grep linux-headers
```

清理旧的内核头文件

```
sudo apt remove --purge linux-headers-6.1.0-29-amd64
```

## 清理

```bash
sudo apt autoremove
sudo apt clean all

sudo rm -rf /var/log/*
rm -fr ~/.bash_history
```
