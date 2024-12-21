# 实战`Ubuntu-22.04-LTS`

> 2024-12-08  以下安装软件版本均为此日期时的最新版本

```bash
# 在线查看可用 wsl 包
wsl --list --online
```

```bash
NAME                            FRIENDLY NAME
Ubuntu                          Ubuntu
Debian                          Debian GNU/Linux
kali-linux                      Kali Linux Rolling
Ubuntu-18.04                    Ubuntu 18.04 LTS
Ubuntu-20.04                    Ubuntu 20.04 LTS
Ubuntu-22.04                    Ubuntu 22.04 LTS
Ubuntu-24.04                    Ubuntu 24.04 LTS
OracleLinux_7_9                 Oracle Linux 7.9
OracleLinux_8_7                 Oracle Linux 8.7
OracleLinux_9_1                 Oracle Linux 9.1
openSUSE-Leap-15.6              openSUSE Leap 15.6
SUSE-Linux-Enterprise-15-SP5    SUSE Linux Enterprise 15 SP5
SUSE-Linux-Enterprise-15-SP6    SUSE Linux Enterprise 15 SP6
openSUSE-Tumbleweed             openSUSE Tumbleweed
```

```bash
# 安装
wsl --install --no-launch --web-download --distribution  Ubuntu-22.04
```

## 基本配置项

```bash
# 添加普通用户lee免密
echo "lee ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/lee
sudo chmod 0440 /etc/sudoers.d/lee

# 使用内存盘
sudo systemctl link /usr/share/systemd/tmp.mount

# 使用内存盘
rm -fr ~/.cache/
ln -s /tmp ~/.cache

rm -fr ~/.config
ln -s /tmp ~/.config

rm -fr ~/.npm/
ln -s /tmp ~/.npm

cd /var
sudo rm -fr tmp
sudo ln -s /tmp

# 解析git地址 
echo "185.199.108.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.109.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.110.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.111.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts

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
```

```bash
# 退出 wsl 回到 windows
exit
wsl --shutdown
wsl
```

```bash
# 更新
sudo apt update
sudo apt upgrade

# 安装
sudo apt install vim nano unzip \
	build-essential \
	libssl-dev libffi-dev \
	libsqlite3-dev \
	pkg-config
```

### [调整`WSL`内存使用](https://learn.microsoft.com/zh-cn/windows/wsl/wsl-config)

```bash
# 编辑文件
C:\Users\<UserName>\.wslconfig

# 加入如下内容
[wsl2]
memory=36GB 
processors=6
swap=2GB
localhostforwarding=true
```

## 加装附加磁盘

### 创建虚拟磁盘

- 按 Win + R 组合键，打开运行，在运行窗口中输入：`compmgmt.msc` 命令，确定或回车，打开磁盘管理器；

- 打开存储\磁盘管理，右键点击”磁盘管理“，选择”`创建 VHD`“，虚拟硬盘格式选择”`VHDX`“，其他自己设置，然后点”确定“；
- 选择刚才创建的磁盘， 右键点击”`分离 VHD`“

### 挂载 `vhd`

```bash
# 创建自动任务挂载 vhd
# 创建启动脚本 wsl2.bat
# 以管理员身份运行：
wsl --mount --vhd C:\wsl\workspace.vhdx --bare
wsl --mount --vhd C:\wsl\source.vhdx --bare
wsl --mount --vhd C:\wsl\android.vhdx --bare
```

### 在 `wsl` 中格式化并挂载

```bash
# 查看磁盘信息
lsblk
```

```bash
# 分区
sudo fdisk /dev/sdc
sudo fdisk /dev/sdd
sudo fdisk /dev/sde
# 输入 n w 将磁盘划分为一个区

# 查看磁盘信息
lsblk

NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sdc      8:32   0    64G  0 disk
└─sdc1   8:33   0    64G  0 part
sdd      8:48   0    48G  0 disk
└─sdd1   8:49   0    48G  0 part
sde      8:64   0    24G  0 disk
└─sde1   8:65   0    24G  0 part

# 可见 sdc, sdd, sde 是新挂载的磁盘
sdc -> workspace   64GB
sdd -> source      48GB
sde -> android     24GB
```

```bash
# 格式化为ext4
sudo mkfs.ext4 /dev/sdc1
sudo mkfs.ext4 /dev/sdd1
sudo mkfs.ext4 /dev/sde1
```

```bash
# 查询磁盘UUID
sudo blkid

/dev/sdc1: UUID="d8938301-9f46-4103-8fbc-a0476ec4326f"
/dev/sdd1: UUID="94b212e6-93c5-429e-9679-0918e4314dff"
/dev/sde1: UUID="3bdf95e1-1a04-4abf-9544-a1e10c172975"

# 挂载
echo "UUID=d8938301-9f46-4103-8fbc-a0476ec4326f /mnt/workspace ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "UUID=94b212e6-93c5-429e-9679-0918e4314dff /mnt/source ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "UUID=3bdf95e1-1a04-4abf-9544-a1e10c172975 /mnt/android ext4 defaults 0 0" | sudo tee -a /etc/fstab
```

### 创建符号链接

```bash
mkdir -p /mnt/workspace/dev+base
cd /mnt/workspace/dev+base

mkdir .volta
mkdir .elm
mkdir .cargo
mkdir .rustup
mkdir .vscode-server

cd ~
ln -s /mnt/workspace/dev+base/.volta
ln -s /mnt/workspace/dev+base/.elm
ln -s /mnt/workspace/dev+base/.cargo
ln -s /mnt/workspace/dev+base/.rustup
ln -s /mnt/workspace/dev+base/.vscode-server
```

## 安装 postgresql

```bash
# 配置官方源
sudo apt install -y postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh

sudo apt update

# 安装
sudo apt install postgresql postgresql-contrib libpq-dev

# 版本
psql --version
## psql (PostgreSQL) 17.2 (Ubuntu 17.2-1.pgdg22.04+1)

# 查询状态
sudo service postgresql status

# 启停操作
sudo service postgresql start|stop|restart
```

### 管理配置 postgresql

```bash
# 查看配置文件
sudo -u postgres psql -c 'SHOW config_file'
## /etc/postgresql/17/main/postgresql.conf

sudo -u postgres psql -c 'SHOW hba_file'
## /etc/postgresql/17/main/pg_hba.conf

# 修改配置允许外部访问
sudo nano /etc/postgresql/17/main/postgresql.conf
## 将 
## #listen_addresses = 'localhost'
## 改为
## listen_addresses = '*'

# 允许 所有主机通过密码访问
echo "host    all             all             0.0.0.0/0            scram-sha-256" | sudo tee -a /etc/postgresql/17/main/pg_hba.conf
echo "host    all             all             ::/0                 scram-sha-256" | sudo tee -a /etc/postgresql/17/main/pg_hba.conf

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

### 将数据库迁移到附加盘

```bash
# 先停止数据库服务
sudo service postgresql stop

#
mkdir -p /mnt/source/pgsql+data
sudo chown postgres:postgres /mnt/source/pgsql+data

# 迁移文件
sudo -u postgres mv /var/lib/postgresql/17 /mnt/source/pgsql+data/

# 创建链接
cd /var/lib/postgresql
sudo -u postgres ln -s /mnt/source/pgsql+data/17
```

### 获取 `wsl2` 本机ip地址

```bash
# 查看wsl2本机ip地址
ip addr show eth0

## 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
##    link/ether 00:15:5d:83:06:4b brd ff:ff:ff:ff:ff:ff
##    inet 172.27.144.57/20 brd 172.27.159.255 scope global eth0
##       valid_lft forever preferred_lft forever
##    inet6 fe80::215:5dff:fe83:64b/64 scope link
##       valid_lft forever preferred_lft forever

# 或更短的命令
hostname -I
## 172.27.144.57
```

```bash
# 可以从 PowerShell 或 Windows 主机中的命令提示符会话运行以下命令之一：

PS> bash -c 'hostname -I'
## 172.27.144.57
 
PS> wsl -- hostname -I
## 172.27.144.57
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

# 使用本地缓存
#cd ~/.elm
#ln -s /mnt/c/Users/lee/AppData/Roaming/elm/0.19.1
#ln -s /mnt/c/Users/lee/AppData/Roaming/elm/elm-json

# 全局安装常用工具
volta install elm-doc-preview
volta install elm-review elm-test elm-watch elm-land npm-check-updates
```

## 配置 python 学习环境

```bash
# pyenv
curl https://pyenv.run | bash

# 迁移到工作区 
cd ~
mv .pyenv /mnt/workspace/dev+base/
ln -s /mnt/workspace/dev+base/.pyenv

#
sudo apt install python3-venv python3-dev python3-pip

# 安装 poetry 1.8.5
curl -sSL https://install.python-poetry.org | python3 -
```

## 配置 rust 开发环境

```bash
# 安装 rust 开发环境 
# latest update on 2024-11-28, rust version 1.83.0 (90b35a623 2024-11-26)
#RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup \
#RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup \
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 删除html帮助文件，节省存储空间
# 保留
# rm -fr ~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/share/doc/rust/html

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
cargo install microserver
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
# 创建符号链接，使用扩展盘
mkdir -p /mnt/android/dev+base
cd /mnt/android/dev+base

mkdir Android
mkdir .android
mkdir .gradle
mkdir .java
mkdir .m2

cd ~
ln -s /mnt/android/dev+base/Android
ln -s /mnt/android/dev+base/.android
ln -s /mnt/android/dev+base/.gradle
ln -s /mnt/android/dev+base/.java
ln -s /mnt/android/dev+base/.m2
```

```bash
# 安装 android studio
# 去官网 https://developer.android.google.cn/studio?hl=zh-cn 下载
cd /mnt/android/dev+base
sudo tar -zxvf /mnt/z/android-studio-2024.2.1.11-linux.tar.gz
cd /opt
sudo ln -s /mnt/android/dev+base/android-studio

# Set the JAVA_HOME environment variable:
export JAVA_HOME=/opt/android-studio/jbr

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

## 配置 Haskell 开发环境

```bash
# 创建符号链接使用扩展盘
cd /mnt/workspace/dev+base

mkdir .ghcup
mkdir .cabal
mkdir .stack

cd ~
ln -s /mnt/workspace/dev+base/.ghcup
ln -s /mnt/workspace/dev+base/.cabal
ln -s /mnt/workspace/dev+base/.stack
```

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

## 配置 OCaml 开发环境

```bash
# 创建符号链接使用扩展盘
cd /mnt/workspace/dev+base

mkdir .opam

cd ~
ln -s /mnt/workspace/dev+base/.opam

# 
bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"

# 
opam init

#
opam install ocaml-lsp-server odoc ocamlformat utop
```

## 配置 vscode 运行环境

```bash
code .

# 安装所需插件
Elm
REST Client
rust-analyzer
...
```

## 配置 X Server

```bash
# 设置中文
sudo apt install language-pack-zh-hans
sudo dpkg-reconfigure locales # 选择zh_CN.UTF-8和en_US.UTF-8, 默认zh_CN.UTF-8

# 有效设置显示
echo "export DISPLAY=:0.0" >> ~/.profile
```

### 配置中文输入法

````bash
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

#optional
fcitx-autostart &>/dev/null
EOF

# 运行下列命令添加并配置输入法
fcitx-config-gtk3
````

### 安装更多中文字体，包括Windows字体

```bash
# 安装中文字体
sudo ln -s /mnt/c/Windows/Fonts /usr/share/fonts/win
fc-cache -fv

# 检查是否成功安装
fc-list :lang=zh
```

## 安装 Microsoft Edge 浏览器

```bash
# 依赖包
sudo apt install apt-transport-https ca-certificates

# 导入 Microsoft GPG 密钥，确保软件包的安全性：
curl -fSsL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg > /dev/null

# 添加 Microsoft Edge 官方软件源
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list

# 更新
sudo apt update

# 安装稳定版本
sudo apt install microsoft-edge-stable

# 版本
microsoft-edge --version
```

## 安装 `Typora`

```bash
# 解压缩安装包
cd /mnt/workspace/dev+base/
tar -Jxvf /tmp/typora.tar.xz

# 创建链接
cd ~/.local/bin
ln -s /mnt/workspace/dev+base/Typora-linux-x64/Typora typora

# 将 Typora 运行过程文件映射到内存盘
cd ~/.config
rm -fr Typora
ln -s /tmp Typora

# 运行一次 Typora 并注册
# 会建一个许可文件 ~/.config/Typora/Vax4u0GGta
# 此文件名在每次注册时可能会不一样，具体查看 ~/.config/Typora/ 目录
# 将此文件迁移
mv ~/.config/Typora/Vax4u0GGta /mnt/workspace/dev+base/Typora-linux-x64/LIC_VM
mv ~/.config/Typora/Uq0bHbcKS5 /mnt/workspace/dev+base/Typora-linux-x64/LIC_WSL

# 编辑 /etc/bash.bashrc 在文件末尾加入如下一行命令
echo "mkdir /tmp/Typora && ln -s /mnt/workspace/dev+base/Typora-linux-x64/LIC_VM /tmp/Typora/Vax4u0GGta" | sudo tee -a /etc/bash.bashrc

echo "mkdir /tmp/Typora && ln -s /mnt/workspace/dev+base/Typora-linux-x64/LIC_WSL /tmp/Typora/Uq0bHbcKS5" | sudo tee -a /etc/bash.bashrc
```

## 安装 UltraEdit

```bash
# 解压缩安装
cd /mnt/workspace/dev+base/
tar -zxvf /mnt/d/openSUSE-Leap/uex_23.0.0.21_amd64.tar.gz
cd ~/.local/bin
ln -s /mnt/workspace/dev+base/uex/bin/uex

# 运行一次
uex

# 保存语法高亮文件 (只需执行一次)
mv ~/.idm/uex/wordfiles /mnt/workspace/dev+base/uex/share/
# 以后只需要执行这一行命令即可
rm -fr ~/.idm/uex/wordfiles
ln -s /mnt/workspace/dev+base/uex/share/wordfiles ~/.idm/uex/wordfiles

# Linux 下 UltraEdit 破解 30 天试用限制
rm -rfd ~/.idm/uex
rm -rf ~/.idm/*.spl
rm -rf /tmp/*.sp
```

## 安装 Beyond Compare

```bash
# 安装依赖包
sudo apt install \
	desktop-file-utils gcr gnome-keyring gnome-keyring-pkcs11 \
	gvfs gvfs-backends gvfs-common gvfs-daemons \
  	gvfs-fuse gvfs-libs libarchive13 libatasmart4 libavahi-glib1 \
  	libblockdev-crypto2 libblockdev-fs2 libblockdev-loop2 \
  	libblockdev-part-err2 libblockdev-part2 libblockdev-swap2 \
  	libblockdev-utils2 libblockdev2 libcdio-cdda2 \
  	libcdio-paranoia2 libcdio19 libexif12 libgck-1-0 libgcr-base-3-1 \
  	libgcr-ui-3-1 libgdata-common libgdata22 \
  	libgoa-1.0-0b libgoa-1.0-common libgpgme11 libgphoto2-6 \
  	libgphoto2-l10n libgphoto2-port12 libimobiledevice6 libldb2 \
  	libmtp-common libmtp-runtime libmtp9 libnfs13 libopenjp2-7 \
  	libpam-gnome-keyring libparted-fs-resize0 libplist3 \
  	libpoppler118 libqt5printsupport5 libqt5x11extras5 libsmbclient \
  	libtalloc2 libtevent0 libudisks2-0 libusbmuxd6 \
  	libvolume-key1 libwbclient0 p11-kit p11-kit-modules \
  	pinentry-gnome3 poppler-data poppler-utils python3-ldb \
  	python3-talloc samba-libs udisks2 usbmuxd

#
tar /tmp/bcompare-5.0.4.30422.x86_64.tar.gz
cd bcompare-5.0.4.30422

# 修改 install.sh  PREFIX=$HOME/bcompare
mkdir ~/bcompare
./install.sh

cd ~
mv bcompare /mnt/workspace/dev+base/
ln -s /mnt/workspace/dev+base/bcompare
cd .local/bin/
ln -s ~/bcompare/bin/bcompare
```

### 破解

前置工作

使用 010Editor 等二进制工具，修改 Beyond Compare 可执行文件中内置的 RSA 密钥

修改前：

```
++11Ik:7EFlNLs6Yqc3p-LtUOXBElimekQm8e3BTSeGhxhlpmVDeVVrrUAkLTXpZ7mK6jAPAOhyHiokPtYfmokklPELfOxt1s5HJmAnl-5r8YEvsQXY8-dm6EFwYJlXgWOCutNn2+FsvA7EXvM-2xZ1MW8LiGeYuXCA6Yt2wTuU4YWM+ZUBkIGEs1QRNRYIeGB9GB9YsS8U2-Z3uunZPgnA5pF+E8BRwYz9ZE--VFeKCPamspG7tdvjA3AJNRNrCVmJvwq5SqgEQwINdcmwwjmc4JetVK76og5A5sPOIXSwOjlYK+Sm8rvlJZoxh0XFfyioHz48JV3vXbBKjgAlPAc7Np1+wk
```

修改后（修改字符串末尾的 `p1+wk` 为 `pn+wk` ）：

```
++11Ik:7EFlNLs6Yqc3p-LtUOXBElimekQm8e3BTSeGhxhlpmVDeVVrrUAkLTXpZ7mK6jAPAOhyHiokPtYfmokklPELfOxt1s5HJmAnl-5r8YEvsQXY8-dm6EFwYJlXgWOCutNn2+FsvA7EXvM-2xZ1MW8LiGeYuXCA6Yt2wTuU4YWM+ZUBkIGEs1QRNRYIeGB9GB9YsS8U2-Z3uunZPgnA5pF+E8BRwYz9ZE--VFeKCPamspG7tdvjA3AJNRNrCVmJvwq5SqgEQwINdcmwwjmc4JetVK76og5A5sPOIXSwOjlYK+Sm8rvlJZoxh0XFfyioHz48JV3vXbBKjgAlPAc7Npn+wk
```

生成注册密钥

```
git clone https://github.com/garfield-ts/BCompare_Keygen.git
cd BCompare_Keygen
pip3 install -r requirements.txt
python3 keygen.py
```

得到可用的注册密钥：

```
--- BEGIN LICENSE KEY ---
7uo7UY8gVANuMyCkDtSZRnNBkDXr1o4msYwtu7GFPaZ9B6naWXfsqEBgD5hM8jm3Sw2L4oFHY53VchaHv4j3q4QNiNxPgcv3qz89nKu3VSgQDVpPrAUWKgkjko5Gvck7BBBJmnKbGZJtDTi21WnJ5AMm7upD6QXgbf2BUS7toxB7jzhFLyotDj59KMGkgXMBXeUoa6T7Yt76MZN6UcHqYG5fMLuBp1JfGxpMXE7AMeUXXLwvAxsJGMkC5oS93WoVLopUoBW4SYNpS7YzzirkqZdRt58TbQpqcvwFeD32X2ZamVAv9SjeQUQhyEwktExFwTc541HrJeDV2xqfr4EgbUprSWEu8p
--- END LICENSE KEY -----
```

用上述密钥注册后，备份注册文件：


```bash
# Crack
cp ~/.config/bcompare5/BC5Key.txt ~/bcompare/lib64/beyondcompare/
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
wsl --export Ubuntu-22.04 - | gzip -9 > z:\rootfs.tar.gz
```

## 用户配置

windows下执行：

```cmd
# 设置wsl默认用户为lee
wslconfig /s Ubuntu
C:\wsl\Ubuntu\Ubuntu.exe config --default-user lee
```
