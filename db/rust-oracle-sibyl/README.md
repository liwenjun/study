# 使用 `sibyl` 操作 `oracle` 数据库

`Sibyl` 是 `rust` 访问操作 `Oracle` 数据库的包，基于 [OCI](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnoci/index.html) ，提供同步(阻塞)和异步(非阻塞)2套`API`，使用时只能二选一。

**阻塞模式**：

```toml
[dependencies]
sibyl = { version = "0.6", features = ["blocking"] }
```

**非阻塞模式**：

```toml
[dependencies]
sibyl = { version = "0.6", features = ["nonblocking", "tokio"] }
```

## 先决条件

`Sibyl` 需要 `Windows` 或 `Linux` 已安装 `Oracle` 客户端，支持的最低版本是 `12.2`。


## 构建说明

项目构建时，需要知道 `OCI` 客户端库的位置。可以通过环境变量提供该信息： 

### `Linux` 系统，设置 `LIBRARY_PATH`

```shell
export LIBRARY_PATH=/usr/lib/oracle/19.18/client64/lib
cargo build --examples --features=blocking
```

### `Windows`  系统，设置 `OCI_LIB_DIR` 

在 Windows 上，如果编译目标环境为`gnu` ，`OCI_LIB_DIR` 将指向 `oci.dll` 所在目录

```
set OCI_LIB_DIR=%ORACLE_HOME%\bin
cargo build --examples --features=blocking
```

如果编译目标环境为`msvc` ，`OCI_LIB_DIR` 将指向 `oci.lib` 所在目录

```plaintext
set OCI_LIB_DIR=%ORACLE_HOME%\oci\lib\msvc
cargo build --examples --features=blocking
```

必须设置 `OCI_LIB_DIR` 环境变量！ `rust-analyzer` 也有要求。 在 `VS Code` 配置文件 `.vscode\settings.json` 中设置:

```json
"rust-analyzer.server.extraEnv": { "OCI_LIB_DIR": "C:\Path\To\Oracle\instantclient\sdk\lib\msvc" }
```

