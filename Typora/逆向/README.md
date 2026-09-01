# 逆向笔记索引

本目录目前主要围绕 Frida 与 iOS 逆向，包含工具链安装、基础使用、官方 API、插件、ARM 寄存器和汇编指令。

## Frida 专题

| 文件 | 内容 |
| --- | --- |
| [frida/工具链安装.md](frida/工具链安装.md) | Homebrew、Git、iTerm2、Python、Frida、Objection、砸壳工具、IDA 等安装 |
| [frida/基础使用.md](frida/基础使用.md) | Frida 基础、frida-ps、frida-trace、frida-dump、Objection、UI 定位、Hook 示例 |
| [frida/官方文档.md](frida/官方文档.md) | Frida 命令、JS API、Process、ApiResolver、Interceptor、Stalker、ObjC 等 |
| [frida/文档.md](frida/文档.md) | OC 数据处理、Objective-C 示例、NSURL 参数打印等 |
| [frida/插件.md](frida/插件.md) | substitute、appsync、AFC2、CrackerXI 等插件 |
| [frida/iOS逆向.md](frida/iOS逆向.md) | Frida 安装、越狱源、deb 处理等 iOS 逆向记录 |
| [frida/ARM寄存器.md](frida/ARM寄存器.md) | ARM 通用寄存器、浮点寄存器、状态寄存器、指令格式 |
| [frida/汇编指令.md](frida/汇编指令.md) | mov、add、sub、cmp、b、ldr、str、ret、堆栈等汇编基础 |

## 推荐阅读顺序

1. [frida/工具链安装.md](frida/工具链安装.md)
2. [frida/基础使用.md](frida/基础使用.md)
3. [frida/官方文档.md](frida/官方文档.md)
4. [frida/iOS逆向.md](frida/iOS逆向.md)
5. [frida/ARM寄存器.md](frida/ARM寄存器.md)
6. [frida/汇编指令.md](frida/汇编指令.md)

## 待整理提示

- `基础使用.md` 内容较长，后续可以拆成“命令使用”“Hook 示例”“UI 定位”“加密分析”“IDA 配合”几部分。
- `官方文档.md` 和 `文档.md` 都有 API 示例，后续可区分为“官方 API 翻译”和“个人案例”。
