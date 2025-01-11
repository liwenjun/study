# 实战`openSUSE Tumbleweed`用于C语言开发

> 2025-01-11  以下安装软件版本均为此日期时的最新版本

去微软官方下载分发包 [`openSUSE Tumbleweed`](https://aka.ms/wsl-opensuse-tumbleweed)

## 初始安装

按标准方法安装。设置用户`lee`。

```bash
# 安装时版本
cat /etc/os-release
NAME="openSUSE Tumbleweed"
VERSION_ID="20211027"

# 更新
sudo zypper ref
sudo zypper dup

# 更新后版本
cat /etc/os-release
NAME="openSUSE Tumbleweed"
VERSION_ID="20250108"

# 从 Snapshot 版本 20200806 开始，全新安装将默认使用 tmpfs 作为 /tmp。
# 使用内存盘
rm -fr ~/.cache/
ln -s /tmp ~/.cache

cd /var
sudo rm -fr tmp
sudo ln -s /tmp

# 添加普通用户lee免密
echo "lee ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/lee
sudo chmod 0440 /etc/sudoers.d/lee

# 解析git地址 
echo "185.199.108.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.109.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.110.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
echo "185.199.111.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
```

## 安装软件包
```bash
#
sudo zypper ref

# 
sudo zypper install git nano 

# 配置 git
git config --global user.email "14991386@qq.com"
git config --global user.name "liwejun"

#
sudo zypper install \
	clang lldb lld \
	cmake \
	gcc gcc-c++ gdb

#
sudo zypper install \
	libopenssl-devel \
	libffi-devel \
	sqlite3-devel \
	ncurses-devel \
	libzip-devel
	
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

