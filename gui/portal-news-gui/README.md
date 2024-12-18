# 门户新闻采集工具

分2个小工具程序： `采集工具seeker.exe` 和`点击工具clicker.exe`

## 1. 采集工具

通过配置文件`conf.toml`定向采集。

将配置文件与执行程序 `seeker.exe`放在同一目录，打开`cmd`窗口运行即可。

```bash
clicker.exe

# 最好将采集结果定向输出到文件中
clicker.exe > out.csv
```

`out.csv`文件内容样例(可用`wps`表格打开查看编辑)：

```csv
date,title,number,url,click
202205, 公司领导赴...调研指导工作, 2541, /article/202205/article2677255.html,
202206, 【特别推荐】奋力开创...新局面, 6026, /article/202206/article2691269.html,
......
```

此文件稍做编辑可供点击工具批量使用。

## 2. 点击工具

将程序`clicker.exe`放在上述采集工具同一目录内。有2种使用方法：

### 单页点击

```bash
clicker.exe -k <点击次数> <url>

# 范例：点击下列url指向页面100次
clicker.exe -k 100 /article/202208/article2718170.html
```

### 批量点击

此方法以采集工具输出文件`out.csv`作为输入，批量点击文件内所列`url`。
使用前需先编辑`out.csv`文件，在最后一列`click`栏填写点击次数（有效数字为1至255）。
只有正确填写了数字的行所指`url`会被点击，未填写或错误填写的行不会点击。

```bash
clicker.exe -f out.csv
```
