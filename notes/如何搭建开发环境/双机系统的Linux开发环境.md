操作系统选择 `Ubuntu Desktop 22.04 LTS`

## 安装后的基本设置

### 设置 /tmp 为 tmpfs

```bash
# tmp.mount is not enabled by default. Just copy and enable it
sudo cp -v /usr/share/systemd/tmp.mount /etc/systemd/system/
sudo systemctl enable tmp.mount
sudo systemctl start tmp.mount
df
```

### 解决Ubuntu和Windows双系统时间不同步问题

时间不同步，原因非常简单：
windows认为，BIOS时间就是当地时间。所以windows会直接显示BIOS时间。
ubuntu认为，BIOS时间应当是UTC时间（格林尼治标准时间）。所以ubuntu会将BIOS时间加上8小时后再显示出来（在中国）。

解决方案非常简单。直接在ubuntu终端中输入：
```bash
timedatectl set-local-rtc 1
```

这句话的作用是让ubuntu将系统时间和BIOS时间同步。现在，ubuntu和windows一样，都认为BIOS时间就是当地时间，联网更新时，也是直接将BIOS时间设为当地时间。这样就没问题了。

### 添加中文输入法

打开 ｀设置 -> 键盘｀ 添加五笔输入法
按 Win＋ Space 键切换输入法

### 安装 vim

先移除预安装的vim-tiny

```bash
sudo apt remove vim-tiny
sudo apt install vim
```

### 修改 host

```bash
sudo vi /etc/hosts
```

加入下列内容 
```
185.199.108.133 raw.githubusercontent.com
185.199.109.133 raw.githubusercontent.com
185.199.110.133 raw.githubusercontent.com
185.199.111.133 raw.githubusercontent.com
```

### 安装 edge 浏览器

> 推荐使用下载工具 aria2

```bash
sudo apt install aria2

# download .deb file
aria2c http://......

sudo apt install ./<file>.deb

# 调整配置 config
```

### 禁用（彻底移除）Snap

已经确认 snapd 是无法禁用的，只能强制删除。以下操作无需停止 snapd 服务。

（1）删掉所有的已经安装的 Snap 软件。

snap list 用于查看已经安装的 Snap 软件，通过脚本全部删除：

```bash
for p in $(snap list | awk '{print $1}'); do
  sudo snap remove $p
done
```

一般需要执行两次（桌面版三次），提示如下则正确执行：

再次执行，提示如下，表明已经删除干净：
```
No snaps are installed yet. Try 'snap install hello-world'.
```

（2）删除 Snap 的 Core 文件。

```bash
sudo systemctl stop snapd
sudo systemctl disable --now snapd.socket

for m in /snap/core/*; do
   sudo umount $m
done
```

（3）删除 Snap 的管理工具。

```bash
sudo apt autoremove --purge snapd
```

（4）删除 Snap 的目录。

```bash
rm -rf ~/snap
sudo rm -rf /snap
sudo rm -rf /var/snap
sudo rm -rf /var/lib/snapd
sudo rm -rf /var/cache/snapd
```

（5）配置 APT 参数：禁止 apt 安装 snapd。

```bash
sudo sh -c "cat > /etc/apt/preferences.d/no-snapd.pref" << EOL
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOL
```

同时禁用 snap Firefox 的更新（Server 版也可以配置）：

```bash
sudo sh -c "cat > /etc/apt/preferences.d/no-firefox.pref" << EOL
Package: firefox
Pin: release a=*
Pin-Priority: -10
EOL
```

现在服务器版安装桌面环境也没有 Snap！

## 安装配置开发环境和工具

### install vscode

```bash
aria2c https://az764295.vo.msecnd.net/stable/b3e4e68a0bc097f0ae7907b217c1119af9e03435/code_1.78.2-1683731010_amd64.deb

sudo apt install ./vscode.deb
```

### install volta

```bash
curl https://get.volta.sh | bash
```

### install rust

```bash
sudo apt install curl build-essential gcc make
sudo apt install libsqlite3-dev libpq-dev libmysqlclient-dev
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### install poetry

```bash
vi ~/.pip/pip.conf # 修改使用国内源
```

```bash
sudo apt install python3-pip
curl -sSL https://install.python-poetry.org | python3 -
```


### install docker desktop

```bash
sudo usermod -aG kvm $USER

# Set up the repository
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

# Add Docker’s official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Use the following command to set up the repository:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 下载  deb 文件 安装
aria2c http://....

sudo apt update
sudo apt install ./docker-desktop-4.20.0-amd64.deb 
```

## 安装辅助工具

### obsidian

建议安装 AppImage包。
```bash
# 安装缺失包
sudo apt install libfuse2
```

### koodo reader

电子图书阅读软件