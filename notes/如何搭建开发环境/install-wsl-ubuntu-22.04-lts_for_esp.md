# 实战`Ubuntu-22.04`配置`ESP`开发环境

> 2025-02-10  以下安装软件版本均为此日期时的最新版本

```bash
# 在线查看可用 wsl 包
wsl --list --online

# 安装
# wsl --install --no-launch --web-download --distribution Ubuntu-22.04
wsl --install --web-download --distribution Ubuntu-22.04
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


## `ESP-IDF` 开发工具链

```bash
# 第一步：安装准备
sudo apt install git wget flex bison gperf \
	python3 python3-pip python3-venv \
	cmake ninja-build ccache \
	libffi-dev libssl-dev \
	dfu-util libusb-1.0-0 \
	gcc gcc-c++    # 补充本地C/C++, 为编译micropython准备

# 第二步：获取 ESP-IDF
mkdir -p ~/esp
cd ~/esp
git clone -b v5.4 --recursive git@github.com:espressif/esp-idf.git
# git clone -b v5.4 --recursive https://github.com/espressif/esp-idf.git

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
# 在 wsl 环境下安装 ESP-IDF 插件
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
git clone git@github.com:espressif/arduino-esp32.git esp32 && \
cd esp32/tools && \
python3 get.py
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
