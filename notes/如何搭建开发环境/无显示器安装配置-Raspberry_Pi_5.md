# 无显示器安装配置 Raspberry Pi 5

### 硬件

- Raspberry Pi 5
- TF卡, 读卡器
- 充电线, 电源适配器

### 软件

- Win32DiskManager [下载](https://link.zhihu.com/?target=https%3A//sourceforge.net/projects/win32diskimager/)
-  PuTTY [下载](https://link.zhihu.com/?target=https%3A//www.putty.org/)
-  VNC [下载](https://link.zhihu.com/?target=https%3A//www.realvnc.com/en/connect/download/viewer/windows/)

 以上软件提前安装



## 系统卡制作

通过[树莓派官网](https://link.zhihu.com/?target=https%3A//www.raspberrypi.org/software/operating-systems/)获取操作系统Raspberry OS(可选择Lite版本，建议64位). 下载后解压得到**img**镜像文件, 在写入前需格式化SD卡(选项**FAT32**). 将镜像文件通过**Win32DiskManager**写入SD卡。

不要心急，由于树莓派最新的raspberry系统（2016年11月25日后）是默认关闭ssh功能的，需要人为的打开这个ssh功能。其实操作很简单，就是在新制作完成的SD卡中的boot分区(**就是windows打开的TF卡根目录**)下新建一个空白的ssh文件即可。

### 配置无线连接

在boot目录下新建文件 `wpa_supplicant.conf`, 内容如下

```ini
country=CN
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    ssid="网络名称，使用英语，保留引号"
    psk="网络密码，保留引号"
    key_mgmt=WPA-PSK
    priority=1 # 优先级，优先级大的优先连接
}
network={
    ssid="wifi名称2"
    psk="wifi密码2"
    key_mgmt=WPA-PSK
    priority=2 
}
```

## SSH访问

下面，可以通过SSH协议来访问我们的树莓派了。在 Windows 下，我们可以使用 [PuTTY](https://link.zhihu.com/?target=https%3A//www.putty.org/) 这个软件，

~~树莓派的默认用户名是pi，密码是raspberry。~~

新版本的os基于安全原因，已删除了pi帐号。需要自己配置新帐号：

打开tf卡的根目录（boot的根目录），创建 userconf文件，该文件内输入用户名和密码的密文，例如，格式如下：

```
用户名:密码密文
```

以下例子，用户名为pi，密码为raspberry的密文

```
pi:$6$4ilokQRQxmURT.py$aJWBQ5yniJJPwV3CKawYJcnSK5JZGhrVZYF3K4omRUFv6KL0MysEH7F4NZRMNMcYF.U3xsQvWrx7ZL2GKxuv.1
```

保存文件并安全退出tf卡。把tf卡装回树莓派的tf卡槽，开机后，系统就会自动配置用户名和密码，pi 密码是 raspberry。

要生成加密密码的密文，最简单的方法是在已经运行的树莓派上使用 OpenSSL——打开一个终端窗口并输入:

```bash
echo 'mypassword' | openssl passwd -6 -stdin
```

回车后，就会得出一段密文。把`mypassword`替换成你想设置的密码，就得出你的密码密文，这个方式非常安全，相同的密码每次生成的密文都不一样的。

```bash
ssh user@ip地址
```



## 树莓派基本设置

只需要输入 sudo raspi-config，就可以进行配置模式，我们可以进行修改密码，扩展系统分区，开启SSH和VNC功能等等操作。

在第一项<Change User Password>里面，我们修改登录账户的密码。

在第五项<Interfacing Options>里面，我们可以设置开启SSH和VNC功能。

在第七项<Advanced Options>里面，我们可以设置 Expand Filesystem，将系统扩展到整个 SD 卡，建议大家都执行该操作。

最后我们退出配置界面，在终端中输入 sudo apt-get install xrdp 指令来安装 xrdp 服务，来实现 Windows 远程桌面访问树莓派。

```bash
# Enable VNC
sudo raspi-config
# choose 5 Interfacing Options -> P3 VNC -> Enable VNC[Yes]

# change resolution
sudo raspi-config
# choose 7 Advanced Options -> A5 Resolution -> 1920*2080(Optional)

#Expand Filesystem
sudo raspi-config 
# choose A1 Expand Filesystem -> Reboot[yes]

#After reboot, check filesystem
df -h
```

## 通过使用 USB 转 UART 3.3V 串行线登录树莓派

要通过 USB 转 TTL 串行连接连接到 RPi，您需要以下信息：

- 端口号：要找到它，请打开 Windows 设备管理器（或等效设备）并在 Ports 部分下搜索。
- 连接速度：默认情况下，您需要输入 115,200 波特才能连接到 RPi。
- 其他终端应用可能需要的其他信息：数据位 = 8;停止位 = 1;奇偶校验 = 无;和 Flow control = XON/XOFF。



按以下方式将电缆连接到 RPi：

- 黑色接地 （GND） 线连接到 GPIO 接头上引脚 6 ，即 RPi GND 引脚
- 黄色接收 （RXD） 线连接到 GPIO 接头上的引脚 8 （GPIO14），即 UART 传输引脚 （TXD0）
- 橙色传输 （TXD） 线连接到 GPIO 接头上的引脚 10 （GPIO15），即 UART 接收引脚 （RXD0）
- **红色线 不能连接任何引脚**



针对 rpi5 有一个专门的 uart 接线端口可用。在typeC电源口附近。
