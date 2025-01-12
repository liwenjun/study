# 实战`openSUSE Tumbleweed`用于C语言开发

> 2025-01-12  以下安装软件版本均为此日期时的最新版本

去微软官方下载分发包 [`openSUSE Tumbleweed`](https://aka.ms/wsl-opensuse-tumbleweed)

## 初始安装

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


# 更新大版本
# 安装时原版本
cat /etc/os-release
NAME="openSUSE Tumbleweed"
VERSION_ID="20211027"

# 更新
sudo zypper ref
sudo zypper dup

# 更新后版本
cat /etc/os-release
NAME="openSUSE Tumbleweed"
VERSION_ID="20250109"

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
# sudo zypper install wqy-zenhei-fonts
sudo localectl set-locale LANG=zh_CN.UTF-8

#
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

# c 工具链
sudo zypper install \
	clang clang-tools \
	lldb lld \
	cmake \
	gcc gdb

# 
sudo zypper install \
	libopenssl-devel \
	libffi-devel \
	sqlite3-devel \
	ncurses-devel \
	libzip-devel

#
sudo zypper install \
	python311-devel \
	python311-pip \
	python3-clang

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

