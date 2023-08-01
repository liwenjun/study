# Volta: 强大的 JavaScript 工具管理器

[官方指南](https://docs.volta.sh/guide/)

## 安装

如果操作系统是 Mac / Linux（包括 WSL），可以使用以下命令轻松安装它。

```shell
curl https://get.volta.sh | bash
```

对于 Windows，可以使用 [`Scoop`](.\scoop.md)  安装。

## 管理工具链

> Volta 工具链管理的工具由`volta install`两个`volta uninstall`命令控制

### 安装Node

> 在工具链中安装工具时，安装的版本是该工具的_默认版本_。除非在一个项目目录中工作，其中有一个固定版本的 Node 以使用不同的版本，否则它默认为 Volta 使用的版本。 例如，可以通过安装特定版本来选择 Node 的默认版本。

```shell
$ volta install node@14.15.5
```

> 如果没有指定确切的版本，Volta 会选择与的请求相匹配的适当版本。

```shell
$ volta install node@14
```

> `latest`也可以安装最新版本。此外，如果完全省略版本，Volta 将选择并安装最新的 LTS 版本。

```shell
$ volta install node@latest
# Node@LTS
$ volta install node
```

> 当运行任何这些命令时，由 Volta 在 PATH 环境（或 Windows 上的 Path）中提供的节点可执行文件默认自动运行所选版本的节点。 同样，可以使用`volta install npm`和`volta install yarn`分别选择 npm 和 Yarn 包管理器的版本。这些工具使用所选节点的默认版本运行。

### 固定Node

> `volta pin`可以使用命令来选择项目的 Node 引擎和包管理器的版本。

```shell
$ volta pin node@14.17
$ volta pin npm@6.14
```

将Volta保存到`package.json`:

```json
"volta":  {  
	"node":  "14.17.3",  
	"npm":  "6.14.13"  
}
```

> 这样，使用 Volta 进行项目开发的每个人都将自动获得与json设置的相同版本。

### 使用项目工具

> node和包管理器可执行文件不是工具链中唯一的智能工具。工具链中的包二进制文件也可以识别当前目录并尊重当前项目结构。

> 例如，安装 Typescript 包会将编译器可执行文件 ( `tsc`) 添加到工具链中。 终端

```shell
$ npm install --global typescript
```

> 根据参与的项目，此可执行文件将切换到项目中选择的 TypeScript 版本。

```shell
cd /path/to/project-using-typescript-3.9.4
tsc --version # 3.9.4

cd /path/to/project-using-typescript-4.1.5
tsc --version # 4.1.5
```

如所见，不仅 Node 和 npm / Yarn 等包管理器，而且通过它们安装的包二进制文件都受到 Volta 的监控。因此，它会自动切换每个项目的版本。



## Volta常用命令介绍

介绍一些常用的命令。

### `volta install`

`volta install`设置工具的默认版本。如果未缓存本地指定的版本，请从该工具中获取它。
 如何使用`volta install [FLAGS] <tool[@version]>`。 上面说明了安装时指定版本的方法，但总结如下。

```shell
# 安装指定版本的node
$ volta install node@14.17.3  

# 安装特定版本中的稳定的node版本
$ volta install node@14  

# 安装LTS版本的node 
$ volta install  node  

# 安装最新版本的node
$ volta install node@latest
```

### `volta pin`

`volta pin package.json`该命令更新项目文件以使用所选版本的工具。
 此命令只能用于节点和包管理器（npm / Yarn）。
 使用方法是`volta pin [FLAGS] <tool[@version]>`。

```shell
# node版本固定
$ volta pin node@14.17

# npm版本固定
$ volta pin npm@6.14 
# or volta pin yarn@1.19
```

在项目目录中执行上述`volta pin`命令时，`package.json`将写入以下设置。

```diff-json
{
  ...,
+ "volta": {
+   "node": "14.17.3",
+   "npm": "6.14.13" //or "yarn": "1.19.2"
+ }
}
```

通过与您的团队共享此`package.json`内容，例如在 GitHub 上，每个人都可以使用相同版本的 Node 或 npm。

例如，假设您在`package.json`一个项目中运行了上述设置。如果 npm 的版本缓存在 本地机器上，将显示。 如果它没有缓存在本地机器上，它将从安装开始，并在安装完成时显示。

`npm -v`
 `6.14.13``6.14.13`
 `6.14.13``6.14.13`

这样，如果你本地有那个版本，它会自动切换到那个版本，否则它会从版本安装开始。

这很方便，而且`npm install`即使你运行它而不用担心版本，版本也会自动对齐，所以`package-lock.json`不会有任何差异。（npm 6系和7系`package-lock.json`的内容很不一样。）

### `volta list`

`volta list`该命令检查并显示包含已安装 Node 运行时、包管理器和二进制文件的包。
 如何使用`volta list [FLAGS] [OPTIONS] [tool]`。

`volta list`该命令的用法总结如下。

```shell
# 使用方法
volta list [FLAGS] [OPTIONS] [tool]
# Flags
-c, --current # 显示当前活动工具
              # 此标志为缺省设置
-d, --default # 显示默认工具
    --verbose # 启用高级诊断
    --quiet   # 防止不必要的显示
-h, --help    # 显示帮助信息

# OPTIONS
--format <format>   # 指定输出格式
                    # 有效值为`human`or`plain`
                    # 默认值为`human`，否则为`plain`
                    
# ARGS
<tool>  # 指定要列出的工具（node，npm，yarn或其他二进制文件）
        # 指定all以显示所有内容
```

`volta list`您可以查看该项目中使用的工具的版本。
 `volta list all`现在您可以看到 Volta 管理的工具列表。

