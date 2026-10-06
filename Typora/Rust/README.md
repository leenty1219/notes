# Rust 知识点查阅

这里按知识点记录 Rust 的用法和例子，适合不定期阅读、复习和写代码时查阅。每篇尽量包含基本概念、常见写法、使用场景和容易踩的坑；先从感兴趣的主题读，不需要按课程顺序完成。

## 核心知识点

| 文档 | 可查内容 |
| --- | --- |
| [语法与数据类型.md](语法与数据类型.md) | 变量、标量与复合类型、函数、控制流、String/&str、Vec、HashMap、模式匹配 |
| [所有权与借用.md](所有权与借用.md) | move、Copy、clone、不可变/可变借用、切片、返回值所有权、借用检查错误定位 |
| [基础.md](基础.md) | struct、enum、Option、Result、trait、生命周期、闭包、模块、智能指针、测试、Cargo、线程等综合参考 |
| [Tokio与网络编程.md](Tokio与网络编程.md) | async/await、Tokio runtime、spawn、TCP、Reqwest、Axum、共享状态、网络库选择与官方学习资料 |

## 建议的阅读方式

- 复习语言基础：读“语法与数据类型”，挑选代码在 Cargo 项目里运行和修改。
- 被编译器的借用错误卡住：查“所有权与借用”，画出所有者与引用的使用范围。
- 查类型建模、错误处理、trait 或工程命令：在“基础”里按目录定位。
- 开始写网络请求或服务：从“Tokio与网络编程”开始，并跟随其中的官方教程和 API 文档继续学习。

Rust 知识会在项目中反复遇到。阅读时可以挑一个例子改造成自己的场景，并把遇到的编译错误和最终修复方式补记到对应专题。

## 外部资料与生态

- [The Rust Programming Language（官方书）](https://doc.rust-lang.org/book/)
- [Rust By Example](https://doc.rust-lang.org/rust-by-example/)
- [标准库文档](https://doc.rust-lang.org/std/)
- [Rust 中文社区文档](https://www.rustwiki.org.cn/zh-CN/book/)
- [awesome-rust](https://github.com/rust-unofficial/awesome-rust)
- Tokio、Reqwest、Axum 等网络资料见 [Tokio与网络编程.md](Tokio与网络编程.md#学习资料)
- [Pake](https://github.com/tw93/Pake)（桌面端项目）、[egui](https://github.com/emilk/egui)（GUI）、Nom（解析库）、UniFFI（跨语言绑定）
- 原有 Notion 页面：[基础知识](https://www.notion.so/5c853af02cf8496b918f25ee5788052d?pvs=21)、[Rust 圣经阅读](https://www.notion.so/Rust-11b5c164e7c441abb0bb94db677f940d?pvs=21)
