# Sign Up A New Subscriber

本章首先尝试实现这个用户故事：

> 作为博客访问者，
> 我想订阅时事通讯，
> 以便在博客上发布新内容时收到电子邮件更新。

我们希望博客访问者以嵌入网页的形式输入他们的电子邮件地址。
该表单将触发对后端 API 调用，后端服务器实际处理信息、存储信息并发送响应。
本章关注后端服务器——我们将实现`/subscriptions`POST 端点。

## 制订策略

我们正从头开始一个新项目，需要处理大量的前期工作：

- 选择一个 Web 框架并熟悉它；截至 2022 年 3 月，`actix-web`是用于生产用途的 Rust API 的首选 Web 框架；
- 定义我们的测试策略；
- 选择一个 crate 与数据库进行交互；
- 定义如何随着时间的推移管理对数据库模式的更改（又名迁移）；
- 实际写一些查询。

这太多了，一头扎进可能会让人不知所措。
先实现一个`/health_check`端点。没有业务逻辑，但却是了解 Web 框架的好机会。

## 实现第一个端点 `/health_check`

当收到一个`/health_check` `GET`请求时，返回`200 OK`没有正文的响应。

先用`cargo`来创建项目框架：

```
cargo new z2p
```

添加依赖：

```
cargo add actix-web
cargo add tokio -F macros,rt-multi-thread
```

`main.rs`代码：

```rust
use actix_web::{web, App, HttpServer, HttpResponse};

async fn health_check() -> HttpResponse {
    HttpResponse::Ok().finish()
}

#[tokio::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/health_check", web::get().to(health_check))
    })
    .bind("127.0.0.1:8000")?
    .run()
    .await
}
```

验证：

```bash
curl -v http://127.0.0.1:8000/health_check
```

## 实现第一个集成测试

`/health_check`是我们的第一个端点，可以通过`curl`手工测试。但我们希望自动化测试。

按下列步骤实施：

1. 先将项目改造为 `lib` 模式

2. 将`main`函数原样移动到我们的库`lib.rs`中（命名`run`以避免冲突）

3. 添加集成测试

添加开发依赖：

```
cargo add --dev reqwest
```

创建测试源码目录：

```mkdir -p tests
mkdir -p tests
```

`tests/health_check.rs` 代码：

```rust
//! tests/health_check.rs

#[tokio::test]
async fn health_check_works() {
    spawn_app().await.expect("Failed to spawn our app.");

    let client = reqwest::Client::new();
    let response = client
        .get("http://127.0.0.1:8000/health_check")
        .send()
        .await
        .expect("Failed to execute request.");

    assert!(response.status().is_success());
    assert_eq!(Some(0), response.content_length());
}

async fn spawn_app() -> std::io::Result<()> {
    z2p::run().await
}
```

`cargo test`无论等待多长时间，测试执行都不会终止。到底是怎么回事？

在`z2p::run`我们调用（和等待）`HttpServer::run`。`HttpServer::run`返回一个`Server`实例 - 当我们调用它时，它开始*无限期地*`.await`监听我们指定的地址，但它永远不会自行关闭或完成。 这意味着永远不会返回，并且我们的测试逻辑永远不会被执行。

我们需要将应用程序*作为后台任务*运行。
[`tokio::spawn`](https://docs.rs/tokio/latest/tokio/fn.spawn.html)就非常方便：`tokio::spawn`获取`Future`并将其交给运行时轮询，而无需等待其完成；因此，它可与下游`Future`和任务（例如我们的测试逻辑）*同时运行*。

####  重构代码

让我们重构`z2p::run`以返回`Server`而无需等待它：

```rust
//! src/lib.rs
use actix_web::{web, App, HttpResponse, HttpServer};

async fn health_check() -> HttpResponse {
    HttpResponse::Ok().finish()
}

pub fn run() -> Result<Server, std::io::Error> {
    let server = HttpServer::new(|| {
        App::new()
            .route("/health_check", web::get().to(health_check))
    })
    .bind("127.0.0.1:8000")?
    .run();
    // No .await here!
    Ok(server)
}

//! src/main.rs
#[tokio::main]
async fn main() -> std::io::Result<()> {
    z2p::run()?.await
}

//! tests/health_check.rs
// [...]

fn spawn_app() {
    let server = z2p::run().expect("Failed to bind address");
    let _ = tokio::spawn(server);
}

#[tokio::test]
async fn health_check_works() {
    // No .await, no .expect
    spawn_app();
    // [...]
}
```

`cargo test` 通过！

## 改进

如果需要或可能的话，现在来重新审视并改进它。

### 清理

当测试运行结束时，我们在后台运行的应用会发生什么？它会关闭吗？它会像僵尸一样吗？

好吧，连续运行`cargo test`多次总是成功 - 强烈暗示我们的 8000 端口在每次运行结束时被释放，暗示应用程序已正确关闭。
再次查看`tokio::spawn`的文档支持我们的假设：当`tokio`运行时关闭时，在其上生成的所有任务都将被删除。`tokio::test`在每个测试用例开始时启动一个新的运行时，并在每个测试用例结束时关闭。
换句话说，好消息 - 无需实现任何清理逻辑。

### 选择随机端口

`spawn_app`将始终尝试在端口 8000 上运行 - 不理想：

- 如果我们机器上的另一个程序（例如我们自己的应用程序！）正在使用端口 8000，测试将失败；
- 如果我们尝试并行运行两个或多个测试，其中只有一个会设法绑定端口，所有其他测试都会失败。

我们可以做得更好：测试应该在随机可用端口上运行它们的后台应用程序。

我们如何为测试找到一个随机可用的端口？
操作系统来救援：我们将使用[端口 0](https://www.lifewire.com/port-0-in-tcp-and-udp-818145)。
端口 0 在操作系统级别是特殊情况：尝试绑定端口 0 将触发操作系统扫描可用端口，然后将其绑定到应用程序。

我们需要以某种方式找出操作系统为我们的应用程序提供的端口。[`std::net::TcpListener`](https://doc.rust-lang.org/beta/std/net/struct.TcpListener.html)可以实现。
`HttpServer`做了两件事：绑定地址，然后启动应用程序。我们可以接管第一步：用`TcpListener`绑定端口，然后通过 [`listen`](https://docs.rs/actix-web/4.0.1/actix_web/struct.HttpServer.html#method.listen)将其交给`HttpServer`。

有什么好处？
[`TcpListener::local_addr`](https://doc.rust-lang.org/beta/std/net/struct.TcpListener.html#method.local_addr)返回一个 [`SocketAddr`](https://doc.rust-lang.org/beta/std/net/enum.SocketAddr.html)，它暴露了我们绑定的实际端口[`.port()`](https://doc.rust-lang.org/beta/std/net/enum.SocketAddr.html#method.port)。

修改如下：

```rust
//! src/lib.rs
// [...]

pub fn run(listener: TcpListener) -> Result<Server, std::io::Error> {
    let server = HttpServer::new(|| {
            App::new()
                .route("/health_check", web::get().to(health_check))
        })
        .listen(listener)?
        .run();
    Ok(server)
}

//! tests/health_check.rs
// [...]

fn spawn_app() -> String {
    let listener = TcpListener::bind("127.0.0.1:0")
        .expect("Failed to bind random port");
    let port = listener.local_addr().unwrap().port();
    let server = z2p::run(listener).expect("Failed to bind address");
    let _ = tokio::spawn(server);
    // We return the application address to the caller!
    format!("http://127.0.0.1:{}", port)
}

#[tokio::test]
async fn health_check_works() {
    let address = spawn_app();
    let client = reqwest::Client::new();
    let response = client
        .get(&format!("{}/health_check", &address))
        .send()
        .await
        .expect("Failed to execute request.");

    assert!(response.status().is_success());
    assert_eq!(Some(0), response.content_length());
}

//! src/main.rs
#[tokio::main]
async fn main() -> std::io::Result<()> {
  let listener = TcpListener::bind("127.0.0.1:8000").expect("Failed to bind");
  z2p::run(listener)?.await
}
```
