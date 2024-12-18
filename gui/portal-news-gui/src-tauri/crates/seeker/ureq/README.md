# `ureq` 说明

不支持 `gbk` 编码页面

修改 `src\response.rs` 文件

将第32行代码

 `pub const DEFAULT_CHARACTER_SET: &str = "utf-8";`

修改为

`pub const DEFAULT_CHARACTER_SET: &str = "gbk";`

