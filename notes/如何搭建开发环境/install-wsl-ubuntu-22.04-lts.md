# 实战`Ubuntu-22.04-LTS`

> 2024-12-08  以下安装软件版本均为此日期时的最新版本



```bash
# 在线查看可用 wsl 包
wsl --list --online
```

```
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

# 添加普通用户lee免密
echo "lee ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/lee
sudo chmod 0440 /etc/sudoers.d/lee
```

```bash
# 解析git地址 
echo "185.199.108.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.109.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.110.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.111.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
```

```bash
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
```

```bash
# 删除 snapd
sudo apt autoremove --purge snapd
sudo rm -rf /var/cache/snapd/
rm -rf ~/snap
rm -rf /snap

#
sudo apt autoremove --purge packagekit

# 删除 vim-tiny
sudo apt remove vim-tiny
```

```bash
# 退出 wsl 回到 windows
exit
wsl --shutdown
wsl

# 更新
sudo apt update
sudo apt upgrade

# 安装
sudo apt install vim nano unzip \
	build-essential \
  	libpq-dev libssl-dev libffi-dev \
  	libsqlite3-dev pkg-config
```



### 配置GUI选项

```bash
# 安装中文字体
sudo ln -s /mnt/c/Windows/Fonts /usr/share/fonts/win
fc-cache -fv

# 解决 GUI 应用程序启动报错
# 编辑 /etc/bash.bashrc 在文件末尾加入如下一行命令：
sudo rm -fr /tmp/.X11-unix && sudo ln -s /mnt/wslg/.X11-unix /tmp/.X11-unix
```




### [调整`WSL`内存使用](https://learn.microsoft.com/zh-cn/windows/wsl/wsl-config)

```bash
# 编辑文件
C:\Users\<UserName>\.wslconfig

# 加入如下内容
[wsl2]
memory=36GB 
processors=10
swap=4GB
localhostforwarding=true
```



## 加装附加磁盘



### 创建虚拟磁盘

- 按 Win + R 组合键，打开运行，在运行窗口中输入：`compmgmt.msc` 命令，确定或回车，打开磁盘管理器；

- 打开存储\磁盘管理，右键点击”磁盘管理“，选择”`创建 VHD`“，虚拟硬盘格式选择”`VHDX`“，其他自己设置，然后点”确定“；
- 选择刚才创建的磁盘， 右键点击”`分离 VHD`“



### 挂载 `vhdx` 

```bash
# 创建自动任务挂载 vhdx
# 创建启动脚本 wsl2.bat
# 以管理员身份运行：
wsl --mount --vhd D:\Dev\wsl2_dev\workspace.vhdx --bare
wsl --mount --vhd D:\Dev\wsl2_dev\source.vhdx --bare
wsl --mount --vhd D:\Dev\wsl2_dev\android.vhdx --bare

# 方法一
# 启动任务管理器
# 选择 启动应用
# 点击 运行新任务
# 选择脚本，选中 以管理员运行

# 方法二
# 启动 `任务计划程序`
# 创建任务
# 选择 `只在用户登录时运行` , 勾选 `使用最高权限运行`
# 在操作中添加前面创建的脚本
```

### 在 `wsl` 中格式化并挂载

```bash
# 查看磁盘信息
lsblk

NAME MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda    8:0    0 388.4M  1 disk
sdb    8:16   0     6G  0 disk [SWAP]
sdc    8:32   0   102G  0 disk
sdd    8:48   0    61G  0 disk
sde    8:64   0    31G  0 disk
sdf    8:48   0     1T  0 disk /mnt/wslg/distro
                               /
# 可见 sdc, sdd 是新挂载的磁盘
sdc -> workspace  102GB
sdd -> source      61GB
sde -> android     31GB
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
sda      8:0    0 388.4M  1 disk
sdb      8:16   0     6G  0 disk [SWAP]
sdc      8:32   0   102G  0 disk
└─sdc1   8:33   0   102G  0 part
sdd      8:48   0    61G  0 disk
└─sdd1   8:49   0    61G  0 part
sde      8:64   0    31G  0 disk
└─sde1   8:65   0    31G  0 part
sdf      8:48   0     1T  0 disk /mnt/wslg/distro
                                 /
```

```bash
# 格式化为ext4
sudo mkfs.ext4 /dev/sdc1
sudo mkfs.ext4 /dev/sdd1
sudo mkfs.ext4 /dev/sde1
```

```bash
# 手动挂载磁盘
sudo mkdir /mnt/workspace
sudo chmod 777 /mnt/workspace
sudo mount /dev/sdc1 /mnt/workspace

sudo mkdir /mnt/source
sudo chmod 777 /mnt/source
sudo mount /dev/sdd1 /mnt/source

sudo mkdir /mnt/android
sudo chmod 777 /mnt/android
sudo mount /dev/sde1 /mnt/android
```


```bash
# 自动挂载
# 查询磁盘UUID
sudo blkid

/dev/sdf: UUID="c842124c-ac37-42e1-a7db-be85374b0742" BLOCK_SIZE="4096" TYPE="ext4"
/dev/sdb: UUID="cff8dfc1-4905-42a3-a644-807f16e069c2" TYPE="swap"
/dev/sda: BLOCK_SIZE="4096" TYPE="ext4"
/dev/sdc1: UUID="6b4bbc33-4a48-476a-8a36-2cbb89ea6aa4" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="1cd0932e-01"
/dev/sdd1: UUID="75493a97-bb35-4df0-b075-c45d8605d516" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="477035ba-01"
/dev/sde1: UUID="03e78d1a-62b9-46dd-a252-e78b09b4b6c4" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="4cf2c92f-01"

# 可以看到UUID为
sdc1 = 6b4bbc33-4a48-476a-8a36-2cbb89ea6aa4
sdd1 = 75493a97-bb35-4df0-b075-c45d8605d516
sde1 = 03e78d1a-62b9-46dd-a252-e78b09b4b6c4

# 编辑分区自动挂载文件
sudo vim /etc/fstab

# 打开后，添加如下内容
UUID=6b4bbc33-4a48-476a-8a36-2cbb89ea6aa4 /mnt/workspace ext4 defaults 0 0
UUID=75493a97-bb35-4df0-b075-c45d8605d516 /mnt/source ext4 defaults 0 0
UUID=03e78d1a-62b9-46dd-a252-e78b09b4b6c4 /mnt/android ext4 defaults 0 0
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
sudo apt upgrade
sudo apt autoremove

# 安装
sudo apt install postgresql postgresql-contrib

# 将数据库迁移到工作区
sudo service postgresql stop
cd /var/lib
sudo mv /var/lib/postgresql /mnt/workspace/dev+base/
sudo ln -s /mnt/workspace/dev+base/postgresql

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

sudo nano /etc/postgresql/17/main/pg_hba.conf
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
sudo apt install python3-venv python3-dev

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



## 安装 Microsoft Edge 浏览器

```bash
#
sudo apt install software-properties-common apt-transport-https ca-certificates

# 导入 Microsoft GPG 密钥，确保软件包的安全性：
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -

#
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main"

#
sudo apt update

#
sudo apt install microsoft-edge-stable

# 版本
microsoft-edge --version
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

