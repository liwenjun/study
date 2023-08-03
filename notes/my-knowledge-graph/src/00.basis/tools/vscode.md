# `VSCode` 快速上手

> 推荐教程 [`VSCode` 极客教程](https://geek-docs.com/vscode/vscode-tutorials/what-is-vscode.html)

下载链接: [Visual Studio Code - Code Editing. Redefined](https://code.visualstudio.com/)



## 设置中文界面

`vscode`默认的语言是英文。简单几步即可设置成中文。

1. 按快捷键“Ctrl+Shift+P”。
2. 在`vscode`顶部会出现一个搜索框。
3. 输入“configure language”，然后回车。
4. `vscode`里面就会打开一个语言配置文件。
5. 将“en-us”修改成“zh-cn”。
6. 按“Ctrl+S”保存设置。
7. 关闭`vscode`，再次打开就可以看到中文界面了。



## 用户设置

文件--首选项--设置，打开用户设置。

这里解析几个常用配置项：

（1）editor.fontsize用来设置字体大小，可以设置editor.fontsize : 14;

（2）files.autoSave这个属性是表示文件是否进行自动保存，推荐设置为onFocusChange——文件焦点变化时自动保存。

（3）editor.tabCompletion用来在出现推荐值时，按下Tab键是否自动填入最佳推荐值，推荐设置为on;

（4）editor.codeActionsOnSave中的source.organizeImports属性，这个属性能够在保存时，自动调整 import 语句相关顺序，能够让你的 import 语句按照字母顺序进行排列，推荐设置为true,即"editor.codeActionsOnSave": { "source.organizeImports": true }；

（5）editor.lineNumbers设置代码行号,即editor.lineNumbers ：true；



## 常用快捷键

高效的使用vscode,记住一些常用的快捷键是必不可少的。

以下以Windows为主，windows的 Ctrl，mac下换成Command就行了

对于 **行** 的操作：

- 重开一行：光标在行尾的话，回车即可；不在行尾，ctrl` + enter` 向下重开一行；ctrl+`shift + enter` 则是在上一行重开一行
- 删除一行：光标没有选择内容时，ctrl` + x` 剪切一行；ctrl +`shift + k` 直接删除一行
- 移动一行：`alt + ↑` 向上移动一行；`alt + ↓` 向下移动一行
- 复制一行：`shift + alt + ↓` 向下复制一行；`shift + alt + ↑` 向上复制一行
- ctrl + z 回退

对于 **词** 的操作：

- 选中一个词：ctrl` + d`

搜索或者替换：

- ctrl` + f` ：搜索
- ctrl` + alt + f`： 替换
- ctrl` + shift + f`：在项目内搜索

通过**Ctrl + `** 可以打开或关闭终端

Ctrl+P 快速打开最近打开的文件

Ctrl+Shift+N 打开新的编辑器窗口

Ctrl+Shift+W 关闭编辑器

Home 光标跳转到行头

End 光标跳转到行尾

Ctrl + Home 跳转到页头

Ctrl + End 跳转到页尾

Ctrl + Shift + [ 折叠区域代码

Ctrl + Shift + ] 展开区域代码

Ctrl + / 添加关闭行注释

Shift + Alt +A 块区域注释



## 插件安装

在输入框中输入想要安装的插件名称，点击安装即可。安装后没有效果，可以重启vscode。



## 设置同步

Settings Sync，在不同电脑间同步你的插件。

首先要想在不同的设备间同步你的插件, 需要用到 Token 和 Gist id

Token 就是你把插件上传到 github 上时, 让你保存的那段字符，Gist id 在你上传插件的那台电脑上保存着。

先给大家来三个快捷键，后面会用到

```text
1、CTRL+SHIFT+P
2、ALT+SHIFT+D 下载配置
3、ALT+SHIFT+U 上传配置
```

现在手把手教大家配置：

1、安装Settings Sync
2、登陆Github>settings>Developer settings>personal access tokens>generate new token，输入名称，勾选Gist，提交
3、保存Github Access Token
4、打开vscode，Ctrl+Shift+P打开命令框-->输入sync-->选择高级设置-->编辑本地扩展设置-->编辑token
5、Ctrl+Shift+P打开命令框-->输入sync-->找到update/upload settings，上传成功后会返回Gist ID，保存此Gist ID.
6、在 VSCode 里，依次打开: 文件 -> 首选项 -> 设置，然后输入 Sync 进行搜索:能找到你gist id
7、若需在其他机器上DownLoad插件的话，同样，Ctrl+Shift+P打开命令框，输入sync，找到Download settings，会跳转到Github的Token编辑界面，点Edit，regenerate token，保存新生成的token，在vscode命令框中输入此Token，回车，再输入之前的Gist ID，即可同步插件和设置

