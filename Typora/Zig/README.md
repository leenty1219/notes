# Zig 知识点查阅

这里记录 Zig 的语言用法、标准库和工程工具，适合不定期阅读、复习和写代码时查阅。Zig 仍在快速发展，版本间标准库和构建 API 可能变化；阅读示例时先确认 Zig 版本，并以该版本的官方文档为准。

## 知识点文档

| 文档 | 可查内容 |
| --- | --- |
| [背景与选型.md](背景与选型.md) | Zig 的设计目标、与 C/Rust 的优势与代价、适用场景、版本与生态现状 |
| [基础语法与类型.md](基础语法与类型.md) | 变量、整数与数组、函数、控制流、指针、切片、结构体、枚举、可选值、错误联合、编译期计算、内存分配 |

## 阅读建议

- 先安装 Zig 并运行最小程序，了解 `zig build-exe`、`zig run` 和 `zig test`。
- 阅读语法时关注 Zig 的显式性：变量可变性、错误处理、内存分配都需要明确表达。
- 写动态数据结构时特别留意 allocator 的来源、分配和释放时机。
- 标准输入输出和 `build.zig` API 在不同版本变化较多，使用之前核对安装版本对应的文档与示例。

## 官方学习资料

- [Zig 官方网站](https://ziglang.org/)
- [Learn Zig](https://ziglang.org/learn/)：官方学习入口，含语言参考、标准库文档、安装和社区资源
- [Zig Language Reference](https://ziglang.org/documentation/master/)：语言参考；`master` 面向开发中的版本，稳定项目应选对应发布版本文档
- [Standard Library Documentation](https://ziglang.org/documentation/master/std/)：标准库 API
- [Zig 下载与发布版本](https://ziglang.org/download/)
- [Ziglings](https://github.com/ratfactor/ziglings)：循序渐进的填空练习，适合边做边学；选择与本地 Zig 版本兼容的分支/版本
- [Zig By Example](https://zig-by-example.com/)：社区示例，适合作为补充，版本细节需自行核对
- [Zig 标准库源码](https://github.com/ziglang/zig/tree/master/lib/std)：需要了解实现或查找示例时使用

## 与 Rust / C 的初步对照

- Zig 与 Rust 一样强调显式错误处理和编译期能力，但 Zig 没有 Rust 那套借用检查器；内存管理通常由程序员通过 allocator 管理。
- Zig 面向低层和通用系统编程，提供 C 互操作能力；它不是“语法更简单的 Rust”，两者的安全保证和设计取舍不同。
- 学 Zig 时需要重点掌握 allocator、指针与切片、错误联合、编译期执行（`comptime`）、构建系统和 C 互操作。
