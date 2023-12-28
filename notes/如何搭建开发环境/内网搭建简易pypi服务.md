

下载requirements内的包及其依赖到【某文件夹】

```text
pip download -r requirements.txt
```

本地安装`pip2pi`

```text
pip install pip2pi
```

命令行切换到前面下载的 `.whl`文件夹，建立索引（自动生成了index.html）

```text
dir2pi -S 【某文件夹】
```

然后文件夹内就出现了一个simple文件夹，这里的内容就和阿里、清华、豆瓣的源差别没那么大了。



### nginx发布镜像源

Nginx 安装很简单，Terminal里执行nginx不报错就算大功告成。

找到nginx.conf文件，仅需修改如下几个内容，其他的都不需要动：

```text
server{
listen 80;
server_name 你的IP地址
root 【某文件夹】的路径
}
```

重启nginx服务器

```text
# Linux
sudo systemctl restart nginx
# Windows
nginx -s reload
```

浏览器打开http://你的IP/simple



如果内网内的主机想要pip安装所需的包，还需要配置一下pip，写入下面的内容：

```text
[global]
index-url = http://你的IP/simple
[install]
trusted-host = 你的IP
```

内网的主机安装Python的包及其依赖

```text
pip install [所需的包名]
```

