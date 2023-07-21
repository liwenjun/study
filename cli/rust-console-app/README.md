# `rust-console-app` 命令行应用

本项目应用 [console-rs](https://github.com/console-rs) 组织的三个库 [console](https://github.com/console-rs/console)、[dialoguer](https://github.com/console-rs/dialoguer)、[indicatif](https://github.com/console-rs/indicatif)来创建控制台命令行应用程序。

## 创建项目

```bash
mkdir rust-console-app
cd rust-console-app
# 此目录为项目根目录空间，以下子项目均加入workspace中。

# 创建其中一个子项目
cargo console-study
cd console-study

# 添加依赖
cargo add console -F windows-console-colors

# 创建另一个子项目
cd ..
cargo indicatif-study
cd indicatif-study

# 添加依赖
cargo add indicatif -F improved_unicode,in_memory,rayon,tokio,unicode-segmentation,vt100

#
cargo add dialoguer -F history,completion,fuzzy-matcher,fuzzy-select
```

## 运行示例

```bash
#
cargo run -p console-study --example term
```
