# Jupyter 一款跨所有语言的交互式计算软件(开放标准、Web服务)

[Jupyter官网](https://jupyter.org/)

Jupyter 项目包含了 [Jupyter Notebook](https://jupyter-notebook.readthedocs.io/en/latest/) 和 [JupyterLab](https://jupyterlab.readthedocs.io/en/latest/) 二个基于web的创作和编辑应用。

Jupyter源于Ipython Notebook，是使用Python（也有R、Julia、Node等其他语言的内核）进行代码演示、数据分析、可视化、教学的很好的工具，对Python的愈加流行和在AI领域的领导地位有很大的推动作用。

Jupyter Lab是Jupyter的一个拓展，它提供了更好的用户体验，例如可以同时在一个浏览器页面打开编辑多个Notebook，Ipython console和terminal终端，并且支持预览和编辑更多种类的文件，如代码文件，Markdown文档，json，yml，csv，各种格式的图片，vega文件（一种使用json定义图表的语言)和geojson（用json表示地理对象），还可以使用Jupyter Lab连接Google Drive等云存储服务，极大得提升了生产力。

JupyterLab作为一种基于web的集成开发环境，你可以使用它编写notebook、操作终端、编辑markdown文本、打开交互模式、查看csv文件及图片等功能。以.ipynb格式写的代码和文档，可以导出为PDF、HTML等格式。你可以把JupyterLab当作一种究极进化版的Jupyter Notebook。原来的单兵作战，现在是空陆空联合协作。只要你屏幕足够大，完全可以一边看PDF电子书，markdown文档，图片等，一边敲代码，数据分析和绘图，对了还能写LaTeX文档，直接预览，目录也可以有和流程图也可以画，shell命令运行也行。

总之，JupyterLab有以下特点：

- 交互模式：Python交互式模式可以直接输入代码，然后执行，并立刻得到结果，因此Python交互模式主要是为了调试Python代码用的
- 内核支持的文档：使你可以在可以在Jupyter内核中运行的任何文本文件（Markdown，Python，R等）中启用代码
- 模块化界面：可以在同一个窗口同时打开好几个notebook或文件（HTML, TXT, Markdown等等），都以标签的形式展示，更像是一个IDE
- 镜像notebook输出：让你可以轻易地创建仪表板
- 同一文档多视图：使你能够实时同步编辑文档并查看结果
- 支持多种数据格式：你可以查看并处理多种数据格式，也能进行丰富的可视化输出或者Markdown形式输出
- 云服务：使用JupyterLab连接Google Drive等服务，极大地提升生产力

**安装Jupyter Lab**

```shell
pip install jupyterlab
```

**运行Jupyter Lab**

在安装Jupyter Lab后，接下来要做的是运行它。
你可以在命令行使用jupyter-lab或jupyter lab命令，然后默认浏览器会自动打开Jupyter Lab。



**还有一种快捷启用Jupyter的方法**

通过安装 [Anaconda](https://www.anaconda.com/download) 或 [WinPython](https://winpython.github.io/) 来使用。windows环境下可使用scoop安装：

```shell
scoop install anaconda3
# 或
scoop install winpython
```

