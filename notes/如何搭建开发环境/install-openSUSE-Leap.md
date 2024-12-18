# 实战 `openSUSE Leap 15.6`

> 2024-10-15  以下安装软件版本均为此日期时的最新版本

参考指南

```
https://zh.opensuse.org/SDB:%E5%BF%AB%E9%80%9F%E9%85%8D%E7%BD%AE%E6%8C%87%E5%8D%97
```

## 初始化安装

按标准方法安装。设置用户`lee`。


如果不需要自动更新，或者不需要 Packagekit 本身，首先可以考虑:

```
sudo zypper rm -u PackageKit
```


### 将`/tmp`设置为`tmpfs`文件系统

 ```bash
# 移除 fstab 中的 /tmp 项
sudo cp /etc/fstab /etc/fstab.bak
sudo vi /etc/fstab
sudo systemctl link /usr/share/systemd/tmp.mount

# 使用内存盘
sudo rm -fr /var/tmp
sudo ln -s /tmp /var/tmp

rm -fr ~/.npm/
ln -s /tmp ~/.npm

# 重启
sudo reboot
 ```
### 配置环境

```bash
# 解析git地址 
sudo vi /etc/hosts

# 在末尾加上下列4行
185.199.108.133 raw.githubusercontent.com
185.199.109.133 raw.githubusercontent.com
185.199.110.133 raw.githubusercontent.com
185.199.111.133 raw.githubusercontent.com

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
```

### 安装 NVIDIA 驱动源

```
sudo zypper in openSUSE-repos-NVIDIA
# or
# sudo zypper addrepo --refresh 'https://download.nvidia.com/opensuse/leap/$releasever' NVIDIA

# 安装显卡驱动
# sudo zypper in nvidia-video-G06
```



## 安装开发包



### 基础包

```bash
sudo zypper update

# 
sudo zypper install git libopenssl-devel libffi-devel make gcc gcc-c++ java-17-openjdk-devel
sudo zypper install python3-devel postgresql-server postgresql-devel sqlite3-devel

# 配置 git
git config --global user.email "liwenjun@21cn.com"
git config --global user.name "liwejun"

# docker
sudo zypper install docker docker-compose docker-compose-switch 
sudo systemctl enable docker

# To join the docker group that is allowed to use the docker daemon:
sudo usermod -G docker -a $USER
newgrp docker

# Restart the docker daemon:
sudo systemctl restart docker

# Verify docker is running:
docker version

# This will pull down and run the, "Hello World" docker container from dockerhub:
docker run --rm hello-world

# Clean up and remove docker image we pulled down:
docker images
docker rmi -f IMAGE_ID
# Where "IMAGE_ID" is the Id value of the "Hello World" container.

# 卸载 Docker
sudo zypper remove docker
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

docker 使用国内镜像源

```bash
# 10 月后最新镜像更新请关注博主原文：https://xuanyuan.me/blog/archives/1154
# 0913 新增：https://dockerproxy.cn
# 0829 新增：https://docker.rainbond.cc
# 0827 新增：https://docker.udayun.com
# 0823 新增：https://docker.211678.top

sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": [
        "https://dockerproxy.cn",
        "https://docker.rainbond.cc"
    ]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```



### 配置 python 开发工具

```bash
# pyenv
curl https://pyenv.run | bash

# poetry
# curl -sSL https://install.python-poetry.org | python3 -
```

#### pyenv基本使用

```bash
# Install additional Python versions
# For example
pyenv install 3.12.7

# Switch between Python versions
# To select a Pyenv-installed Python as the version to use, run one of the following commands:

pyenv shell <version> -- select just for current shell session
pyenv local <version> -- automatically select whenever you are in the current directory (or its subdirectories)
pyenv global <version> -- select globally for your user account

# E.g. to select the above-mentioned newly-installed Python 3.10.4 as your preferred version to use:
pyenv global 3.12.7

# Using "system" as a version name would reset the selection to your system-provided Python.

# Uninstall Python versions
pyenv uninstall <versions>.
```



### 配置 elm 开发工具

```bash
# 安装 volta (JavaScript命令行管理工具)
# version 2.0.1
curl https://get.volta.sh | bash

volta install node
rm -f ~/.volta/tools/inventory/node/node-*-linux-x64.tar.gz

# 配置安装 elm 工具链
cd /tmp
npm init -y
npm i -D elm-tooling
npx elm-tooling init
npx elm-tooling tools
npx elm-tooling install

# 配置用户全局使用
# 2024-10-15 此时的版本
cd ~/.local/bin
ln -s ~/.elm/elm-tooling/elm/0.19.1/elm
ln -s ~/.elm/elm-tooling/elm-format/0.8.7/elm-format
ln -s ~/.elm/elm-tooling/elm-json/0.2.13/elm-json
ln -s ~/.elm/elm-tooling/elm-test-rs/3.0.0/elm-test-rs

# 全局安装常用工具
volta install elm-doc-preview elm-watch
# volta install elm-doc-preview elm-review elm-analys

volta install pnpm
```



### 配置 rust 开发环境

```bash
# 安装 rust 开发环境
# RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup \
# RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup \
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

mkdir ~/.cargo/registry
ln -s /tmp ~/.cargo/registry/src

cat > ~/.cargo/config.toml <<EOF
[build]
# jobs = 1                      # number of parallel jobs, defaults to # of CPUs
target-dir = "/tmp/target"      # path of where to place all generated artifacts
incremental = true              # whether or not to enable incremental compilation

[cargo-new]
vcs = "none"              # VCS to use ('git', 'hg', 'pijul', 'fossil', 'none')

[profile.dev]
incremental = true       # Compile your binary in smaller steps.

[profile.release]
panic = "abort"         # Strip expensive panic clean-up logic
codegen-units = 1       # Compile crates one after another so the compiler can optimize better
lto = true              # Enables link to optimizations
opt-level = "s"         # Optimize for binary size
strip = true            # Remove debug symbols

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

# cargo 目前已内置 add, remove 功能
# cargo install --locked cargo-edit

cargo install --locked ripgrep mdbook

cargo install sqlx-cli --no-default-features -F postgres,native-tls,sqlite
cargo install diesel_cli --no-default-features --features "postgres sqlite"

# cargo install microserver
# cargo install miniserve
# cargo install maturin
```



### 配置 Haskell

```bash
sudo zypper in curl gcc-g++ gcc gmp-devel make libncurses6 xz perl pkg-config

curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# To start a simple repl, run:
ghci

# To start a new haskell project in the current directory, run:
cabal init --interactive

# To install other GHC versions and tools, run:
ghcup tui
```



## 安装生产力工具

> 以下常用的软件工具，可去这里搜索、下载、安装
    ```
    https://software.opensuse.org/
    ```



### Beyond Compare

```
# 安装
sudo rpm --import https://www.scootersoftware.com/RPM-GPG-KEY-scootersoftware
sudo zypper refresh
# 下载 https://www.scootersoftware.com/files/bcompare-4.4.7.28397.x86_64.rpm
# sudo zypper install https://www.scootersoftware.com/files/bcompare-4.4.7.28397.x86_64.rpm
sudo zypper bcompare-4.4.7.28397.x86_64.rpm

# 安装过程出现提示时，选择2 
Problem: nothing provides 'gvfs-smb' needed by the to be installed bcompare
 Solution 1: do not install bcompare
 Solution 2: break bcompare by ignoring some of its dependencies

Choose from above solutions by number or cancel [1/2/c/d/?] (c): 2

# 卸载
sudo zypper remove bcompare

# 破解
cd /usr/lib64/beyondcompare/
sudo sed -i "s/keexjEP3t4Mue23hrnuPtY4TdcsqNiJL-5174TsUdLmJSIXKfG2NGPwBL6vnRPddT7tH29qpkneX63DO9ECSPE9rzY1zhThHERg8lHM9IBFT+rVuiY823aQJuqzxCKIE1bcDqM4wgW01FH6oCBP1G4ub01xmb4BGSUG6ZrjxWHJyNLyIlGvOhoY2HAYzEtzYGwxFZn2JZ66o4RONkXjX0DF9EzsdUef3UAS+JQ+fCYReLawdjEe6tXCv88GKaaPKWxCeaUL9PejICQgRQOLGOZtZQkLgAelrOtehxz5ANOOqCaJgy2mJLQVLM5SJ9Dli909c5ybvEhVmIC0dc9dWH+/N9KmiLVlKMU7RJqnE+WXEEPI1SgglmfmLc1yVH7dqBb9ehOoKG9UE+HAE1YvH1XX2XVGeEqYUY-Tsk7YBTz0WpSpoYyPgx6Iki5KLtQ5G-aKP9eysnkuOAkrvHU8bLbGtZteGwJarev03PhfCioJL4OSqsmQGEvDbHFEbNl1qJtdwEriR+VNZts9vNNLk7UGfeNwIiqpxjk4Mn09nmSd8FhM4ifvcaIbNCRoMPGl6KU12iseSe+w+1kFsLhX+OhQM8WXcWV10cGqBzQE9OqOLUcg9n0krrR3KrohstS9smTwEx9olyLYppvC0p5i7dAx2deWvM1ZxKNs0BvcXGukR+/g" BCompare

# 然后打开Beyond Conpare，弹出Trial Mode Error！弹窗
# 单击右下角按钮“Enter Key”，输入以下秘钥【注意：包括开始和结尾的横线行】
--- BEGIN LICENSE KEY ---
GXN1eh9FbDiX1ACdd7XKMV7hL7x0ClBJLUJ-zFfKofjaj2yxE53xauIfkqZ8FoLpcZ0Ux6McTyNmODDSvSIHLYhg1QkTxjCeSCk6ARz0ABJcnUmd3dZYJNWFyJun14rmGByRnVPL49QH+Rs0kjRGKCB-cb8IT4Gf0Ue9WMQ1A6t31MO9jmjoYUeoUmbeAQSofvuK8GN1rLRv7WXfUJ0uyvYlGLqzq1ZoJAJDyo0Kdr4ThF-IXcv2cxVyWVW1SaMq8GFosDEGThnY7C-SgNXW30jqAOgiRjKKRX9RuNeDMFqgP2cuf0NMvyMrMScnM1ZyiAaJJtzbxqN5hZOMClUTE+++
--- END LICENSE KEY -----
```



### Typora

```
# 手工安装
# 下载 https://download2.typoraio.cn/linux/Typora-linux-x64.tar.gz
sudo tar -zxvf Typora-linux-x64.tar.gz -C /opt

# 破解
https://github.com/hazukieq/Yporaject
https://github.com/DiamondHunters/NodeInject
https://github.com/DiamondHunters/NodeInject_Hook_example

# 配置启动项
[Desktop Entry]
Name=Typora
Exec=/opt/Typora/Typora
Icon=/opt/Typora/typora.png
Categories=Office
Terminal=false
Type=Application
StartupNotify=true
```



### KoodoReader

```
https://dl.koodoreader.com/v1.5.1/Koodo-Reader-1.5.1.AppImage
```



### LocalSend

```
https://github.com/localsend/localsend/releases/download/v1.15.4/LocalSend-1.15.4-linux-x86-64.AppImage
```



### IntelliJ IDEA Community

```
https://download-cdn.jetbrains.com.cn/idea/ideaIC-2024.2.3.tar.gz
```



###  Android Studio

```
https://developer.android.google.cn/studio

To install Android Studio on Linux, follow these steps:

1. Unpack the .tar.gz to /opt/.
1.1 For a 64-bit version of Linux, first install the required libraries for 64-bit machines.
	sudo yum install zlib.i686 ncurses-libs.i686 bzip2-libs.i686
2. To launch Android Studio, open a terminal, navigate to the android-studio/bin/ directory, and execute studio.sh.
```



###  Remarkable `md编辑器`

```
https://github.com/jamiemcg/remarkable
```



### vscode

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper addrepo https://packages.microsoft.com/yumrepos/vscode vscode
sudo zypper refresh
sudo zypper install code
```



### obsidian

用于记笔记，很方便。

```bash
# 下载
wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.7/Obsidian-1.6.7.AppImage

# 编辑文件： /usr/share/applications/obsidian.desktop
# 输入以下内容：
[Desktop Entry]
Name=Obsidian
Comment=Obsidian
Exec=/opt/obsidian-1.6.7.AppImage
Icon=/opt/obsidian.png
Categories=Office
Terminal=false
Type=Application
StartupNotify=true
```



### 安装 VirtualBox

```
# 安装 Oravle VirtualBox 官网版本
sudo rpm --import https://www.virtualbox.org/download/oracle_vbox_2016.asc

# cd /etc/zypp/repos.d/
# sudo wget https://download.virtualbox.org/virtualbox/rpm/opensuse/virtualbox.repo
# sudo zypper ref

sudo zypper in kernel-default-devel
sudo zypper in VirtualBox

# 自制签名
sudo mkdir -p /var/lib/shim-signed/mok
sudo openssl req -nodes -new -x509 -newkey rsa:2048 -outform DER -addext "extendedKeyUsage=codeSigning" -keyout /var/lib/shim-signed/mok/MOK.priv -out /var/lib/shim-signed/mok/MOK.der
sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
sudo reboot

# rebuild
sudo /sbin/vboxconfig

# 
sudo rcvboxdrv setup
```



> Creating group 'vboxusers'. VM users must be member of that group!
> This system is currently not set up to build kernel modules.
> Please install the gcc make perl packages from your distribution.
> Please install the Linux kernel "header" files matching the current kernel
> for adding new hardware support to the system.
> The distribution packages containing the headers are probably:
>     kernel-default-devel kernel-default-devel-6.4.0-150600.23.25

> There were problems setting up VirtualBox.  To re-start the set-up process, run
>   /sbin/vboxconfig
> as root.  If your system is using EFI Secure Boot you may need to sign the
> kernel modules (vboxdrv, vboxnetflt, vboxnetadp, vboxpci) before you can load
> them. Please see your Linux system's documentation for more information.

> 重启后提醒：

> $ sudo /sbin/vboxconfig
> vboxdrv.sh: Stopping VirtualBox services.
> vboxdrv.sh: Starting VirtualBox services.
> vboxdrv.sh: You must sign these kernel modules before using VirtualBox:
>   vboxdrv vboxnetflt vboxnetadp
> See the documentation for your Linux distribution..
> vboxdrv.sh: Building VirtualBox kernel modules.
> vboxdrv.sh: Signing VirtualBox kernel modules.
> vboxdrv.sh: failed: 

> System is running in Secure Boot mode, however your distribution
> does not provide tools for automatic generation of keys needed for
> modules signing. Please consider to generate and enroll them manually:

    sudo mkdir -p /var/lib/shim-signed/mok
    sudo openssl req -nodes -new -x509 -newkey rsa:2048 -outform DER -addext "extendedKeyUsage=codeSigning" -keyout /var/lib/shim-signed/mok/MOK.priv -out /var/lib/shim-signed/mok/MOK.der
    sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
    sudo reboot

> Restart "rcvboxdrv setup" after system is rebooted


#### 重新整理安装openSUSE项目提供的VirtualBox如下 


1. 安装 Virtualbox

```
sudo zypper in virtualbox 
```

> 如果你是 Leap 用户，并且希望能够使用最新版本的 `virtualbox`， 可前往 http://software.opensuse.org，下载并安装适用于 Leap 的，由社区打包的软件包。

加入用户组

运行如下命令，将当前的用户添加至用户组：

```
sudo usermod -aG vboxusers $USER
```

然后重启系统。


2. 安装扩展包

Extension Pack 扩展包主要提供了 USB 驱动和 3D 加速驱动等因版权无法自由分发的内容。

    下载 VirtualBox Extension Pack。

要安装扩展包，请先打开 VirtualBox，点击左侧 工具栏 上的选项按钮，切换到 扩展 页面，然后再点击上方的 install 安装你刚刚下载保持的扩展包文件，然后你就会看到扩展包的使用许可协议，滚动到底端，然后点击 我同意，即可安装扩展包：
首次打开 VirtualBox 会提示用户是否启用 USB 功能（这可能会带来安全风险，但是它带来的便利值得这么做），个人建议可以使用该功能。


3. 为虚拟机安装增强功能

请先安装 virtualbox-guest-tools：

```
sudo zypper in virtualbox-guest-tools
```

重启系统，然后再将虚拟机用户添加至对应的用户组：

```
sudo usermod -aG vboxsf $USER
```

重新登录系统即可看到你之前设置好的共享文件夹（该共享文件夹一般位于 /media 目录之下，如果你没有看到自动挂载的文件夹，你需要手动将共享文件夹固定到文件浏览器的侧边栏之中）。 


4. kernal

```
sudo zypper install virtualbox-host-source kernel-devel kernel-default-devel

sudo /usr/sbin/vboxconfig

# 参考信息
https://doc.opensuse.org/release-notes/x86_64/openSUSE/Leap/15.6/#drivers-hardware
https://en.opensuse.org/openSUSE:UEFI
https://en.opensuse.org/SDB:NVIDIA_drivers#Secureboot
```



## 以下路径可链接到 /tmp

```
~/.cache/mozilla/firefox/efexjfeb.default-release/cache2

```





