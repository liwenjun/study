# Cleo 创建美观且可测试的命令行界面

[Cleo allows you to create beautiful and testable command-line interfaces](https://github.com/python-poetry/cleo)



## 基本用法

要创建从命令行问候的命令，请创建`greet_command.py`并添加以下内容：

```python3
from cleo.commands.command import Command
from cleo.helpers import argument, option

class GreetCommand(Command):
    name = "greet"
    description = "Greets someone"
    arguments = [
        argument(
            "name",
            description="Who do you want to greet?",
            optional=True
        )
    ]
    options = [
        option(
            "yell",
            "y",
            description="If set, the task will yell in uppercase letters",
            flag=True
        )
    ]

    def handle(self):
        name = self.argument("name")

        if name:
            text = f"Hello {name}"
        else:
            text = "Hello"

        if self.option("yell"):
            text = text.upper()

        self.line(text)
```

You also need to create the file `application.py` to run at the command line which creates an `Application` and adds commands to it:

还需要建立运行文件`application.py`， 创建一个`Application`并添加命令：

```python3
#!/usr/bin/env python

from greet_command import GreetCommand

from cleo.application import Application


application = Application()
application.add(GreetCommand())

if __name__ == "__main__":
    application.run()
```

测试运行

```bash
$ python application.py greet John
```

将显示

```text
Hello John
```

还可以使用`--yell`选项将所有内容设置为大写：

```bash
$ python application.py greet John --yell
```

将显示

```text
HELLO JOHN
```



### 为输出着色

无论何时输出文本，都可以用标签将文本包围起来以着色输出。例如：

```python3
# blue text
self.line("<info>foo</info>")

# green text
self.line("<comment>foo</comment>")

# cyan text
self.line("<question>foo</question>")

# bold red text
self.line("<error>foo</error>")
```

The closing tag can be replaced by `</>`, which revokes all formatting options established by the last opened tag.

结束标记可以替换为 ，这将撤销所有格式 由上次打开的标记建立的选项。`</>`

可以使用该方法定义自己的样式：`add_style()`

It is possible to define your own styles using the `add_style()` method:

```python3
self.add_style("fire", fg="red", bg="yellow", options=["bold", "blink"])
self.line("<fire>foo</fire>")
```

Available foreground and background colors are: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan` and `white`.

And available options are: `bold`, `underscore`, `blink`, `reverse` and `conceal`.

可用的前景色和背景色包括：、、、、、 和 。`black``red``green``yellow``blue``magenta``cyan``white`

可用选项包括：、、 和 。`bold``underscore``blink``reverse``conceal`

您还可以在标签名称中设置以下颜色和选项：

You can also set these colors and options inside the tag name:

```python3
# green text
self.line("<fg=green>foo</>")

# black text on a cyan background
self.line("<fg=black;bg=cyan>foo</>")

# bold text on a yellow background
self.line("<bg=yellow;options=bold>foo</>")
```

### 

### 详细级别

Cleo有四个详细级别。这些在`Output`类中定义：

| Mode                     | Meaning                            | Console option    |
| ------------------------ | ---------------------------------- | ----------------- |
| `Verbosity.QUIET`        | Do not output any messages         | `-q` or `--quiet` |
| `Verbosity.NORMAL`       | The default verbosity level        | (none)            |
| `Verbosity.VERBOSE`      | Increased verbosity of messages    | `-v`              |
| `Verbosity.VERY_VERBOSE` | Informative non essential messages | `-vv`             |
| `Verbosity.DEBUG`        | Debug messages                     | `-vvv`            |

可以在命令中仅为特定详细级别打印消息。例如：

```python3
if Verbosity.VERBOSE <= self.io.verbosity:
    self.line(...)
```

您还可以使用更多语义方法来测试每个详细级别：

```python3
if self.output.is_quiet():
    # ...

if self.output.is_verbose():
    # ...
```

您也可以将详细程度标志直接传递给`line()` 。

```python3
self.line("", verbosity=Verbosity.VERBOSE)
```

当使用安静级别，所有输出都被抑制。



### 使用参数

命令中最有趣的部分是参数和选项。参数是空格分隔的字符串，位于命令名称之后。它们是有顺序的，并且可以是可选的，也可以是必需的。例如，向命令添加一个可选参数`last_name`，并使`name`参数成为必需参数：

```python3
class GreetCommand(Command):
    name = "greet"
    description = "Greets someone"
    arguments = [
        argument(
            "name",
            description="Who do you want to greet?",
        ),
        argument(
            "last_name",
            description="Your last name?",
            optional=True
        )
    ]
    options = [
        option(
            "yell",
            "y",
            description="If set, the task will yell in uppercase letters",
            flag=True
        )
    ]
```

现在可以访问命令中的`last_name`参数：

```python3
last_name = self.argument("last_name")
if last_name:
    text += f" {last_name}"
```

现在可以通过以下任一方式使用该命令：

```bash
$ python application.py greet John
$ python application.py greet John Doe
```

也可以让参数获取值列表（想象一下你想问候你所有的朋友）。为此，必须放在参数列表的末尾：

```python3
class GreetCommand(Command):
    name = "greet"
    description = "Greets someone"
    arguments = [
        argument(
            "names",
            description="Who do you want to greet?",
            multiple=True
        )
    ]
    options = [
        option(
            "yell",
            "y",
            description="If set, the task will yell in uppercase letters",
            flag=True
        )
    ]
```

要使用它，只需指定任意数量的名称：

```bash
$ python application.py greet John Jane
```

您可以以列表形式访问参数`names`：

```python3
names = self.argument("names")
if names:
    text = "Hello " + ", ".join(names)
```

### 

### 使用选项

与参数不同，选项不是排序的（这意味着可以以任何顺序 ）并用两个破折号指定（例如`--yell`，还可以声明一个单字母的快捷方式，像`-y`）。选项*始终*是可选的，可以设置为接受值（例如`--dir=src`）或简单地作为没有值的布尔标志（例如`--yell`）。

> *提示*：也可以使选项*选择性*地接受值（`--yell`或`--yell=loud`都可正常工作）。选项也可以配置为接受列表。

例如，向命令添加一个可用于指定消息应连续打印多少次：

```python3
class GreetCommand(Command):
    name = "greet"
    description = "Greets someone"
    arguments = [
        argument(
            "name",
            description="Who do you want to greet?",
            optional=True
        )
    ]
    options = [
        option(
            "yell",
            "y",
            description="If set, the task will yell in uppercase letters",
            flag=True
        ),
        option(
            "iterations",
            description="How many times should the message be printed?",
            default=1
        )
    ]
```

接下来，在命令中使用它多次打印消息：

```python3
for _ in range(int(self.option("iterations"))):
    self.line(text)
```

现在，当运行任务时，可以选择指定一个`--iterations`标志：

```bash
$ python application.py greet John
$ python application.py greet John --iterations=5
```

第一个示例只会打印一次，因为`iterations`是空的，并且 默认为`1`。第二个示例将打印五次。

回想一下，选项不关心它们的顺序。因此，以下任何一种将起作用：

```bash
$ python application.py greet John --iterations=5 --yell
$ python application.py greet John --yell --iterations=5
```



### 测试命令

Cleo提供了多种工具来帮助您测试命令。最有用的一个是`CommandTester`类。它使用一个特殊的 IO 类来无需真实控制台即可轻松测试：

```python3
from greet_command import GreetCommand

from cleo.application import Application
from cleo.testers.command_tester import CommandTester


def test_execute():
    application = Application()
    application.add(GreetCommand())

    command = application.find("greet")
    command_tester = CommandTester(command)
    command_tester.execute()

    assert "..." == command_tester.io.fetch_output()
```

`CommandTester.io.fetch_output()`方法返回在控制台正常调用期间的显示内容。 `CommandTester.io.fetch_error()可以获得stderr输出。

您可以通过传递参数和选项给`CommandTester.execute()`来测试：

```python3
from greet_command import GreetCommand

from cleo.application import Application
from cleo.testers.command_tester import CommandTester


def test_execute():
    application = Application()
    application.add(GreetCommand())

    command = application.find("greet")
    command_tester = CommandTester(command)
    command_tester.execute("John")

    assert "John" in command_tester.io.fetch_output()
```

还可以使用`ApplicationTester`类测试整个控制台应用程序。

### 调用现有命令

如果一个命令依赖于在其之前运行的另一个命令，不需要记住执行顺序，你可以直接调用它。可以创建一个“元命令”(meta)，运行一堆其他命令，这也很有用。

从一个命令调用另一个命令很简单：

```python3
def handle(self):
    return_code = self.call("greet", "John --yell")
    return return_code
```

如果要抑制已执行命令的输出，可以使用`call_silent()`方法代替。

### 自动完成

Cleo支持在`bash`、`zsh`和`fish`中自动（制表符）完成。

默认情况下，应用程序将具有一个`completions`命令。若要为应用程序注册这些补全，请在终端中运行以下命令之一（替换`[program]`为用于运行应用程序的命令）：

```bash
# Bash
[program] completions bash | sudo tee /etc/bash_completion.d/[program].bash-completion

# Bash - macOS/Homebrew (requires `brew install bash-completion`)
[program] completions bash > $(brew --prefix)/etc/bash_completion.d/[program].bash-completion

# Zsh
mkdir ~/.zfunc
echo "fpath+=~/.zfunc" >> ~/.zshrc
[program] completions zsh > ~/.zfunc/_[program]

# Zsh - macOS/Homebrew
[program] completions zsh > $(brew --prefix)/share/zsh/site-functions/_[program]

# Fish
[program] completions fish > ~/.config/fish/completions/[program].fish
```
