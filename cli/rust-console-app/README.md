# `rust-console-app` 命令行应用



本项目应用 [console-rs](https://github.com/console-rs) 组织的三个库 [console](https://github.com/console-rs/console)、[dialoguer](https://github.com/console-rs/dialoguer)、[indicatif](https://github.com/console-rs/indicatif)来创建控制台命令行应用程序。

## 创建项目

```bash
cargo new rust-console-app
cd rust-console-app

# 添加依赖
cargo add console -F windows-console-colors
cargo add dialoguer -F history,completion,fuzzy-matcher,fuzzy-select
cargo add indicatif -F improved_unicode,in_memory,rayon,tokio,unicode-segmentation,vt100
cargo add 
```

