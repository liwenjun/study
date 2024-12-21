# 虚拟机`VBox`实战安装`Ubuntu-22.04-lts`

> 2024-12-18  以下安装软件版本均为此日期时的最新版本

按标准方法安装，选择 `Ubuntu Server (minimized)`。设置用户 `lee`。记得勾选 `openssh-server` 安装选项。

## 映射`ssh`端口

在 `Windows` `Powershell` 下执行

```powershell
cd 'C:\Program Files\Oracle\VirtualBox\'

# 列出虚拟机清单
.\VBoxManage.exe list vms

"ubuntu-22.04-lts" {fb73a306-2ead-4d2e-b011-34483efeecbf}

# 映射端口转发
# 将服务器ssh端口22映射到本地2222端口
.\VBoxManage.exe modifyvm "ubuntu-22.04-lts" --natpf1 "ssh,tcp,,2222,,22"
```

## `ssh`免密登录

在 `Windows` `Powershell` 下执行

```powershell
# 生成密钥
ssh-keygen -t rsa

#> Enter file in which to save the key (C:\Users\lee/.ssh/id_rsa)

# 上传自己的公钥到服务器
cd C:\Users\lee\.ssh
scp -P 2222 id_rsa.pub lee@localhost:~/.ssh  
scp -P 2222 id_rsa lee@localhost:~/.ssh  
      
# 通过其他方式登录服务器后，再进行如下操作）
ssh 127.0.0.1 -p 2222
cd ~/.ssh
cat id_rsa.pub >> authorized_keys
chmod 400 id_rsa
chmod 644 id_rsa.pub
```

## 基础配置

```bash
# 添加普通用户lee免密
echo "lee ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/lee
sudo chmod 0440 /etc/sudoers.d/lee

# 使用内存盘
sudo systemctl link /usr/share/systemd/tmp.mount

# 使用内存盘
rm -fr ~/.cache/
ln -s /tmp ~/.cache

rm -fr ~/.npm/
ln -s /tmp ~/.npm

sudo rm -fr /var/tmp
sudo ln -s /tmp /var/tmp

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

# 删除 snapd packagekit
sudo apt autoremove --purge snapd packagekit

# 解析git地址 
echo "185.199.108.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.109.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.110.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.111.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts

# 调整开机grub等待时长
sudo nano /etc/default/grub
GRUB_TIMEOUT=1
GRUB_RECORDFAIL_TIMEOUT=1

# 刷新生效
sudo update-grub

# 重启
sudo reboot
```

## 挂载附加硬盘

```bash
# 查看硬盘信息
lsblk
```

显示如下信息

```bash
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sdb                         8:16   0   64G  0 disk
sdc                         8:32   0   48G  0 disk
sdd                         8:48   0   24G  0 disk

# 可见 `sdb`、`sdc`、`sdd` 是新挂载的磁盘
sdb -> workspace    64GB
sdc -> source       48GB
sdd -> android      24GB
```

分区并格式化

```bash
# 分区
sudo fdisk /dev/sdb
sudo fdisk /dev/sdc
sudo fdisk /dev/sdd
# 输入 n w 将磁盘划分为一个区

# 查看磁盘信息
lsblk

NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sdb                         8:16   0   64G  0 disk
└─sdb1                      8:17   0   64G  0 part
sdc                         8:32   0   48G  0 disk
└─sdc1                      8:33   0   48G  0 part
sdd                         8:48   0   24G  0 disk
└─sdd1                      8:49   0   24G  0 part
```

```bash
# 格式化为ext4
sudo mkfs.ext4 /dev/sdb1
sudo mkfs.ext4 /dev/sdc1
sudo mkfs.ext4 /dev/sdd1
```

```bash
# 查询磁盘UUID
sudo blkid

/dev/sdb1: UUID="d8938301-9f46-4103-8fbc-a0476ec4326f"
/dev/sdc1: UUID="94b212e6-93c5-429e-9679-0918e4314dff"
/dev/sdd1: UUID="3bdf95e1-1a04-4abf-9544-a1e10c172975"
```

```bash
# 挂载磁盘
# 与 wsl2 保持一致
echo "UUID=d8938301-9f46-4103-8fbc-a0476ec4326f /mnt/workspace ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "UUID=94b212e6-93c5-429e-9679-0918e4314dff /mnt/source ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "UUID=3bdf95e1-1a04-4abf-9544-a1e10c172975 /mnt/android ext4 defaults 0 0" | sudo tee -a /etc/fstab

# 重启
sudo reboot

sudo chown lee:lee /mnt/workspace
sudo chown lee:lee /mnt/source
sudo chown lee:lee /mnt/android
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

## 安装基础开发包

```bash
sudo apt update
sudo apt upgrade

# 安装
sudo apt install vim nano git unzip \
   build-essential \
   libssl-dev libffi-dev \
   libsqlite3-dev sqlite3 \
   pkg-config
  
# 配置 git
git config --global user.email "14991386@qq.com"
git config --global user.name "liwenjun"
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

# sudo nano /etc/postgresql/17/main/pg_hba.conf
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

### 将数据库迁移到附加盘

```bash
# 先停止数据库服务
sudo systemctl stop postgresql
# sudo service postgresql stop

#
mkdir -p /mnt/source/pgsql+data
sudo chown postgres:postgres /mnt/source/pgsql+data

# 迁移文件
sudo -u postgres mv /var/lib/postgresql/17 /mnt/source/pgsql+data/

# 创建链接
cd /var/lib/postgresql
sudo -u postgres ln -s /mnt/source/pgsql+data/17
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
RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup \
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

## 配置 X Server

```bash
# 设置中文
sudo apt install language-pack-zh-hans
sudo dpkg-reconfigure locales # 选择zh_CN.UTF-8和en_US.UTF-8, 默认zh_CN.UTF-8

# 有效设置显示
echo "export DISPLAY=:10.0" >> ~/.profile
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
sudo mkdir -p /usr/share/fonts/chinese

# 将要安装的字体上传到该文件夹下

# 更新字体缓存
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

# 显示版本
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

## 配置 `vscode` 开发环境

### `ssh`远程开发免密登录

在 `Windows` 机器上编辑配置文件 `C:\Users\lee\.ssh\config`

```
Host ubuntu
    HostName 127.0.0.1
    Port 2222
    User lee
    IdentityFile "C:\Users\lee\.ssh\id_rsa"
```

### 安装插件

```bash
# 安装下列plugin
#
# Elm
# Python
# REST Client
# rust-analyser
```

## 解决 vm 与 wsl 用户 uid 和 gid 不一致问题

```bash
# 用户postgres
# 在vm中UID和GID如下:
postgres  UID: 108
postgres  GID: 113

# 在wsl中UID和GID如下：
postgres UID: 110
postgres GID: 120

# 需将二个平台的uid和gid改为一致。
# 向编号大的一方看齐。
# 修改vm中的用户向wsl看齐

# 修改前准备
sudo service postgresql stop

# 修改命令
sudo usermod -u110 postgres
sudo groupmod -g120 postgres

# 手动修改文件属性
sudo find / -user 108 -exec chown -h postgres {} \;
sudo find / -group 113 -exec chgrp -h postgres {} \;

# 这样用户和组的uid、gid就修改好了。可以用id命令看下是否修改的如我们所愿。
id -u postgres
id -g postgres
grep postgres /etc/passwd
grep postgres /etc/group
```

## 删除旧内核

### 方法 1：自动卸载 Ubuntu 多余内核

1. 在「终端」中运行以下命令查看已安装的 Linux 内核列表：

```
dpkg --list | grep linux-image
```

- `ii`：表示已安装，并成功安装和配置。它表示相应的软件包已安装在当前系统上，并处于功能正常的状态。
- **`rc`**：表示已删除，但配置文件仍然存在。它表示该软件包已被删除，但其配置文件仍然存在于系统中。这种状态通常在软件包被删除但没有完全清除时出现，为将来重新安装时保留配置文件。

2. 使用以下命令自动卸载未使用的 Ubuntu 多余内核：

```
sudo apt autoremove --purge
```

### 方法 2：手动删除 Ubuntu 多余内核

要手动删除未使用的旧版本内核，可以按照以下步骤进行：

1. 在「终端」中运行以下命令查看当前内核版本：

```
uname -r
```

这将显示当前正在使用的内核版本，确保不要误删。

2. 运行以下命令以查看系统已经安装的 Linux 内核列表：

```
dpkg --list | grep linux-image
```

3. 从列表中选择要删除的内核。通常情况下，需要保留最新的内核以及 1、2 个旧版本作为备用。

4. 要删除特定内核，请使用以下命令：

```
sudo apt purge linux-image-x.x.x-x-generic
```

其中`x.x.x-x`代表内核版本，替换为要删除的实际版本号。对于每个要卸载的内核，重复执行此命令。

5. 在删除旧的内核后，运行以下命令更新 [GRUB 引导加载程序](https://www.sysgeek.cn/ubuntu-16-04-grub-2-boot-loader/)：

```
sudo update-grub
```

6. 重新启动。

## 清理

```bash
sudo apt autoremove
sudo apt clean all

sudo rm -rf /var/log/*
# sudo rm -rf /tmp/*
rm -fr ~/.bash_history
```

## 备份数据

```bash
# 先关闭虚拟机
7z a -mx9 z:\source.7z C:\wsl\source.vhd
7z a -mx9 z:\android.7z C:\wsl\android.vhd
7z a -mx9 z:\workspace.7z C:\wsl\workspace.vhd
```
