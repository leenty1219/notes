# Tokio 与 Rust 网络编程

Tokio 是 Rust 中常用的异步运行时，提供任务调度、异步网络 I/O、定时器、同步原语等能力。它不是 Rust 语言本身的一部分：`async`/`await` 和 `Future` 属于语言/标准库抽象，Tokio 负责驱动异步任务并提供生态组件。

## 学习资料

建议按这个顺序阅读，API 以使用中的 Tokio 版本文档为准：

1. [Tokio Tutorial](https://tokio.rs/tokio/tutorial)：官方循序教程，涵盖异步、任务、I/O、TCP 和共享状态。
2. [Tokio 文档](https://docs.rs/tokio/latest/tokio/)：crate API 文档，可查 `Runtime`、`spawn`、`TcpListener`、`TcpStream`、同步原语等。
3. [Tokio API 指南](https://docs.rs/tokio/latest/tokio/#modules)：按模块浏览功能，结合示例使用。
4. [Rust Async Book](https://rust-lang.github.io/async-book/)：Future、Pin、异步运行机制等底层概念，入门后再读更合适。
5. [Reqwest 文档](https://docs.rs/reqwest/latest/reqwest/)：HTTP 客户端。
6. [Axum 文档](https://docs.rs/axum/latest/axum/)：基于 Tokio、Tower 和 Hyper 的 Web 服务框架。
7. [Hyper 文档](https://docs.rs/hyper/latest/hyper/)：较底层 HTTP 实现；初学 Web 服务通常先用 Axum。

阅读开源代码时，优先从小型 Axum/Reqwest 项目开始。先看入口如何建立 runtime、如何定义 handler、如何处理 `Result`，暂时不必从 executor 底层实现读起。

## 先理解 Future 与 async/await

`async fn` 调用后会返回一个 Future。Future 表示“将来可能完成的计算”，本身不会自动开线程，也不会在调用瞬间完成；运行时反复 poll 它，在 I/O 等待时运行其他任务。

```rust
async fn fetch_label() -> String {
    String::from("done")
}

// 在 async 上下文中等待结果：
// let label = fetch_label().await;
```

`.await` 只能出现在异步上下文中。一个 async 函数内部调用另一个 async 函数时通常需要 `.await`，否则得到的只是 Future。

异步主要解决大量 I/O 等待任务的资源利用率问题，不代表 CPU 密集计算会自动并行。CPU 密集工作需要合适的线程池或 `spawn_blocking` 等方式。

## 建立 Tokio 项目

在项目根目录执行：

```bash
cargo add tokio --features full
```

也可以在 `Cargo.toml` 手动声明。`full` 适合学习和快速开始，会启用较多功能；正式项目可按需要选 feature，例如 `macros`、`rt-multi-thread`、`net`、`time`、`sync`。具体 feature 以当前版本文档为准。

```toml
[dependencies]
tokio = { version = "1", features = ["full"] }
```

异步入口常用 `#[tokio::main]` 宏：

```rust
#[tokio::main]
async fn main() {
    println!("Tokio runtime 已启动");
}
```

宏会为程序创建 runtime 并执行 async main。库代码通常不应自行启动全局 runtime，而应由应用入口管理运行时。

## 并发等待多个任务

连续 await 通常是顺序等待：

```rust
let first = request_a().await;
let second = request_b().await;
```

两个任务若互相独立，可使用 `tokio::join!` 同时推进：

```rust
let (a, b) = tokio::join!(request_a(), request_b());
```

`join!` 在当前任务中并发轮询多个 Future，不会为每个 Future 自动创建独立操作系统线程。它们若有一个长期执行 CPU 计算而不让出执行权，也会阻塞同一运行线程。

需要独立调度的任务可以 `tokio::spawn`：

```rust
let handle = tokio::spawn(async move {
    compute_or_wait().await
});

match handle.await {
    Ok(value) => println!("结果：{value}"),
    Err(join_error) => eprintln!("任务失败：{join_error}"),
}
```

spawn 的 Future 和输出需要满足线程安全边界（通常是 `Send + 'static`），因为多线程 runtime 可能在线程间迁移任务。`move` 将闭包捕获的数据移入任务。不要把 `'static` 误解为一定泄漏内存，它在此表示任务不能借用短生命周期的局部变量。

## 定时器与超时

```rust
use std::time::Duration;
use tokio::time::{sleep, timeout};

async fn work() -> Result<(), &'static str> {
    sleep(Duration::from_millis(100)).await;
    Ok(())
}

#[tokio::main]
async fn main() {
    match timeout(Duration::from_secs(1), work()).await {
        Ok(Ok(())) => println!("完成"),
        Ok(Err(error)) => eprintln!("业务错误：{error}"),
        Err(_) => eprintln!("操作超时"),
    }
}
```

超时会丢弃对应 Future，形成取消效果。操作被取消时是否留下部分副作用，需要结合具体 API 判断。

## TCP Echo 服务端示例

下面的服务端接收 TCP 连接，把收到的数据原样写回。保存为 Tokio 二进制项目的 `src/main.rs`：

```rust
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpListener;

#[tokio::main]
async fn main() -> std::io::Result<()> {
    let listener = TcpListener::bind("127.0.0.1:7000").await?;
    println!("listening on 127.0.0.1:7000");

    loop {
        let (mut socket, address) = listener.accept().await?;
        println!("client connected: {address}");

        tokio::spawn(async move {
            let mut buffer = [0_u8; 1024];
            loop {
                let count = match socket.read(&mut buffer).await {
                    Ok(0) => return, // 对端关闭连接
                    Ok(count) => count,
                    Err(error) => {
                        eprintln!("read error: {error}");
                        return;
                    }
                };

                if let Err(error) = socket.write_all(&buffer[..count]).await {
                    eprintln!("write error: {error}");
                    return;
                }
            }
        });
    }
}
```

用 `nc 127.0.0.1 7000` 连接测试。TCP 是字节流，不保留消息边界；真实协议必须自行定义长度、分隔符或帧格式，不能假设一次 `read` 就得到一条完整消息。

## HTTP 客户端：Reqwest

Reqwest 提供高层 HTTP 客户端，常见用途是请求 REST API。开启 JSON 功能：

```toml
[dependencies]
reqwest = { version = "0.12", features = ["json"] }
tokio = { version = "1", features = ["macros", "rt-multi-thread"] }
serde = { version = "1", features = ["derive"] }
```

版本号及 feature 会随时间变化，写笔记时以 crates.io 和 docs.rs 当前版本为准。

```rust
use serde::Deserialize;

#[derive(Debug, Deserialize)]
struct Post {
    id: u32,
    title: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = reqwest::Client::new();
    let post: Post = client
        .get("https://jsonplaceholder.typicode.com/posts/1")
        .send()
        .await?
        .error_for_status()?
        .json()
        .await?;

    println!("{}: {}", post.id, post.title);
    Ok(())
}
```

`send()` 成功只说明 HTTP 请求得到响应，不代表状态码是 2xx。`error_for_status()` 可将 HTTP 错误状态转成错误。`.json().await` 会读取响应体并反序列化，因此结构体字段要匹配服务端 JSON；生产请求还要考虑超时、重试策略、认证和日志脱敏。

## HTTP 服务：Axum

Axum 适合构建异步 HTTP 服务。基本处理器可直接返回文本：

```rust
use axum::{routing::get, Router};

async fn hello() -> &'static str {
    "Hello, Rust!"
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/", get(hello));
    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000")
        .await
        .expect("bind failed");

    axum::serve(listener, app)
        .await
        .expect("server failed");
}
```

添加依赖：`cargo add axum tokio --features tokio/full`。Axum 的版本/API 可能变化，按 docs.rs 对应版本核对。实际项目一般还需要配置状态注入、JSON 提取、错误响应、日志、配置和优雅关闭。

## 共享状态

多个 handler 共享只读配置时，可使用 `Arc`。共享可变状态通常配合 `tokio::sync::Mutex`：

```rust
use std::sync::Arc;
use tokio::sync::Mutex;

let counter = Arc::new(Mutex::new(0_u64));
let counter_for_task = Arc::clone(&counter);

let handle = tokio::spawn(async move {
    let mut value = counter_for_task.lock().await;
    *value += 1;
});

handle.await?;
```

异步锁在竞争时会挂起任务；不要持锁跨越很长的 `.await`，否则容易造成拥堵或死锁。若锁内工作不需要 await，标准库 `std::sync::Mutex` 在短临界区也可能合适，但要避免阻塞 runtime 工作线程。

## 同步与异步边界

不要在 Tokio 异步任务中直接调用长时间阻塞的文件、网络或系统调用，否则会占用 runtime 工作线程。优先使用异步 API；必须调用阻塞函数时可考虑 `tokio::task::spawn_blocking`。也不要在 runtime 已启动的异步上下文中随意再次调用 `#[tokio::main]` 包装的同步入口。

## 网络库如何选择

| 需求 | 常用选择 | 说明 |
| --- | --- | --- |
| 异步运行时、TCP/UDP | Tokio | 任务调度、异步 I/O、定时器、同步原语 |
| HTTP 客户端 | Reqwest | 高层请求 API，支持 JSON、TLS 等常见功能 |
| HTTP 服务端 | Axum | 基于 Tokio 生态，路由和 handler 组合清晰 |
| 底层 HTTP | Hyper | 更接近 HTTP 协议实现，控制力更强、抽象也更底层 |
| 同步 HTTP 客户端 | ureq 等 | 适合简单同步程序，具体选择查看当前维护状态 |
| 命令行参数 | clap | CLI 参数解析，常与 Tokio 应用组合 |

网络协议、TLS 和异步运行时配置都可能有安全与部署影响；对外服务应另外学习输入校验、连接超时、请求体大小限制、认证授权、TLS 和日志隐私。

## 建议练习

1. 写 TCP Echo 客户端，练习 `connect`、`read`、`write_all`。
2. 给 Echo 协议增加换行分帧，正确处理一次读取包含多条消息、或一条消息分多次读取。
3. 用 Reqwest 请求公开 JSON API，处理状态码、超时和 JSON 解析错误。
4. 用 Axum 添加 `/health`、路径参数和 JSON 响应。
5. 给服务添加共享状态、日志和优雅关闭，再观察 `Send`、所有权和错误处理要求。

## 查错提示

- Future 没执行：是否缺少 `.await`，或没有 runtime 驱动？
- `future cannot be sent between threads safely`：检查 spawn 捕获的数据、非 `Send` 类型，以及是否跨 `.await` 持有锁/引用。
- TCP 数据不完整：TCP 是字节流，需要实现分帧。
- 请求返回 404/500 但代码没有报错：检查是否调用 `error_for_status()`。
- 程序被超时取消：确认取消时资源和部分操作的状态是否安全。
