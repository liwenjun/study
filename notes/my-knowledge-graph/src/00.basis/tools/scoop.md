# Scoop上手指南

`Scoop`是一个包管理工具，类似`Ubuntu`的`apt`和`Mac`的`homebrew`，只需通过一条命令即可快速完成软件的下载、安装和配置等步骤。

项目地址：[GitHub - lukesampson/scoop: A command-line installer for Windows.](https://github.com/lukesampson/scoop)



## 安装

根据官方的条件要求，你需要：

1. Windows 7 SP1+或Windows Server 2008+（当然你用主流的Windows 10或Windows 11更没有什么问题）。
2. [PowerShell 5](https://link.zhihu.com/?target=https%3A//www.microsoft.com/en-us/download/details.aspx%3Fid%3D54616)（及以上，包含[PowerShell Core](https://link.zhihu.com/?target=https%3A//docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows%3Fview%3Dpowershell-7.2%26viewFallbackFrom%3Dpowershell-6)）和[.NET Framework 4.5](https://link.zhihu.com/?target=https%3A//docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows%3Fview%3Dpowershell-7.2%26viewFallbackFrom%3Dpowershell-6)（及以上）（当然我相信读者朋友们肯定都满足了，实在未满足可通过文本链接前去下载）。

还有两个中国用户需要确认的额外的条件（当然我觉得你能看到这篇文章自然也都满足了）：

1. 由于众所周知的天朝网络原因，你需要能够正常访问Github并下载其资源。
2. 由于环境变量中文路径的支持问题，你的Windows用户名或自定义的安装路径不得包含中文。



```powershell
# 设置PowerShell权限，如果之前已开启，可忽略。
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 安装
iwr -useb get.scoop.sh | iex
```



完成之后，相应位置就会生成一个scoop文件夹，子目录：

- apps——所有通过scoop安装的软件都在里面。
- buckets——管理软件的仓库，用于记录哪些软件可以安装、更新等信息，默认添加`main`仓库，主要包含无需GUI的软件，可手动添加其他仓库或自建仓库。
- cache——软件下载后安装包暂存目录。
- persit——用于储存一些用户数据，不会随软件更新而替换。
- shims——用于软链接应用，使应用之间不会互相干扰，实际使用过程中无用户操作不必细究。



## 使用

记得随时使用 `scoop help` 查看帮助信息

#### scoop search

查找软件，通常是想看看某个程序是否可以通过 Scoop 安装

```
scoop search <app>
```

如

```
scoop search python
```

#### scoop install

安装应用程序，分两种情况：

- 只为当前用户安装，安装在 Scoop 目录下的 apps 文件夹

```
scoop install <app>
```

如

```
scoop install python
```

- 为所有用户安装，默认安装在 `C:/ProgramData/scoop` 或者是上文提到的自定义的全局应用安装目录，并且需要以管理员身份运行

```
scoop install <app> -g
```

如

```
scoop install python -g
```

如果要安装特定版本的应用，比如说 `curl 7.56.1`，则应该这样

```
scoop install curl@7.56.1
```

#### scoop uninstall

卸载某一程序

```
scoop uninstall <app>
```

如

```
scoop uninstall python
```

卸载程序并移除所有配置文件

```
scoop uninstall <app> -p
```

如

```
scoop uninstall python -p
```

卸载全局安装的应用程序，需以管理员身份运行

```
scoop uninstall <app> -g
```

如

```
scoop uninstall python -g
```

#### scoop update

更新 Scoop 及所有 bucket 但不更新 app

```
scoop update
```

更新某一特定程序

```
scoop update <app>
```

如

```
scoop update python
```

更新 Scoop、bucket 及所有程序

```
scoop update *
```

更新全局安装的程序，需要以管理员身份运行

```
scoop update <app> -g
```

如

```
scoop update python -g
```

#### scoop list

查看已安装的程序

```
scoop list
```

#### scoop status

查看哪些程序可以升级

```
scoop status
```

#### scoop config

需要设置的一般也就是两个，aria2 开关以及 proxy 设置

开闭 aria2 `scoop config aria2-enabled true` or `scoop config aria2-enabled false`，但不建议开启，经常有各种奇奇怪怪的问题。同时，启用 aria2 前需要先安装 `scoop install aria2`

proxy 设置，如 `scoop config proxy 127.0.0.1:1080`

#### scoop home

查看某一程序的主页

```
scoop home <app>
```

如

```
scoop home python
```

便唤起浏览器，打开 Python [官网](https://www.python.org/)

#### scoop reset

借用 Wiki [例子](https://github.com/lukesampson/scoop/wiki/Switching-Ruby-And-Python-Versions)

```
# 先添加 versions bucket
scoop bucket add versions

# 同时安装 Python 2.7 和最新版本
scoop install python27 python

# 切换到 Python 2.7.x
scoop reset python27

# 切换到 Python 3.x
scoop reset python
```

#### scoop cleanup

删除已安装软件的旧版本，如删除所有软件旧版本

```
scoop cleanup *
```

#### scoop cache

清理软件缓存，通常是下载的软件安装包。以下命令清除所有缓存，即清空 Scoop 目录下的 cache 文件夹

```
scoop cache rm *
```

#### scoop bucket

查看「已知库」

```
scoop bucket known
```

查看已经添加的库

```
scoop bucket list
```

删除已经添加的库

```
scoop bucket rm <bucket>
```

添加库，分两种情况：

- 添加「已知库」

```
scoop bucket add <bucket>
```

如添加上文提到的 versions 库

```
scoop bucket add versions
```

- 添加第三方库

```
scoop bucket add <bucket> <bucket_url>
```

如添加 Ash258、chawyehsu 和我的库

```
scoop bucket add Ash258 https://github.com/Ash258/Scoop-Ash258.git
scoop bucket add dorado https://github.com/chawyehsu/dorado.git
scoop bucket add spoon https://github.com/FDUZS/spoon.git
```



### 我的 Scoop 清单

```
scoop list
Installed apps:

Name                Version             Source        Updated             Info
----                -------             ------        -------             ----
7zip                23.01               main          2023-06-28 16:36:10
aria2               1.36.0-1            main          2023-05-10 10:43:05
babashka            1.3.182             scoop-clojure 2023-07-25 07:46:56
binaryen            114                 main          2023-07-18 15:10:14
clj-deps            1.11.1.1273-4       scoop-clojure 2023-07-25 08:26:31
clojure-lsp         2023.07.01-22.35.41 scoop-clojure 2023-07-04 08:35:57
curl                8.2.1_2             main          2023-08-01 07:45:46
dark                3.11.2              main          2023-05-23 09:14:13
firacode            6.2                 nerd-fonts    2023-07-19 08:31:08
firefox             115.0               extras        2023-07-10 07:49:15
git                 2.41.0.3            main          2023-07-19 07:46:33
github              3.2.7               extras        2023-08-01 08:40:15
gzip                1.3.12              main          2023-05-23 09:07:23
heidisql            12.5                extras        2023-06-12 08:09:27
innounp             0.50                main          2023-05-24 08:12:00
JetBrains-Mono      2.304               nerd-fonts    2023-07-19 08:32:51
koodo-reader        1.5.7               extras        2023-07-31 15:30:13
mdbook              0.4.32              main          2023-07-18 08:14:24
miniserve           0.24.0              main          2023-07-07 08:30:57
nginx               1.25.1              main          2023-07-10 15:36:37
notepadplusplus     8.5.4               extras        2023-06-19 07:56:31
obsidian            1.3.5               extras        2023-06-05 09:41:02
pnpm                8.6.10              main          2023-07-25 07:47:33
poetry              1.5.1               main          2023-05-30 08:32:23
postgresql          15.3                main          2023-05-23 09:11:02
postgrest           11.1.0              main          2023-06-09 09:13:48
pwsh                7.3.6               main          2023-07-17 07:48:48
python              3.11.4              main          2023-06-08 08:02:25
ripgrep             13.0.0              main          2023-05-30 09:03:26
rustup-msvc         1.26.0              main          2023-05-23 09:10:31
SarasaGothic-SC     0.41.3              nerd-fonts    2023-07-19 08:44:09
sqlitestudio        3.4.4               extras        2023-06-14 15:03:36
sudo                0.2020.01.26        main          2023-05-23 09:07:31
temurin-lts-jdk     17.0.7-7            java          2023-05-23 10:26:44
typora              1.6.7               extras        2023-06-12 08:28:34
volta               1.1.1               main          2023-05-23 09:24:54
vscode              1.80.2              extras        2023-07-28 11:29:13
windows-terminal    1.17.11461.0        extras        2023-05-30 08:37:26
```

