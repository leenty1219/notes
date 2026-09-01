# Typora 笔记总览

这是一个以 iOS 开发为主轴的个人知识库，同时包含 AI 编码工具、Frida 逆向、Go/Rust 语言基础、Mac/NAS/生活记录等内容。

## 快速入口

| 主题 | 入口 | 说明 |
| --- | --- | --- |
| iOS 开发 | [iOS/README.md](iOS/README.md) | iOS 通用知识、Swift、SwiftUI、ObjC、设计模式、适配指南 |
| 代码片段 | [Codes/README.md](Codes/README.md) | ObjC、Swift、GCD、CALayer、Sui 相关代码与实践片段 |
| AI 工具 | [ai/README.md](ai/README.md) | pi、Codex、Claude、Copilot、Kimi、Herdr、OMX 等速查 |
| 逆向分析 | [逆向/README.md](逆向/README.md) | Frida、iOS 逆向、ARM 寄存器、汇编、工具链 |
| Go | [Go/README.md](Go/README.md) | Go 基础、并发、字符串、日志、XORM、Go Mod 等 |
| Rust | [Rust/README.md](Rust/README.md) | Rust 基础、trait、生命周期、闭包、多线程等 |
| Combine + UIKit | [Combine+UIKit/README.md](Combine+UIKit/README.md) | Combine 与 UIKit 封装实例 |
| Mac | [Mac/README.md](Mac/README.md) | Mac 使用记录 |
| NAS | [Nas/README.md](Nas/README.md) | 家庭服务、DNS 配置 |
| 生活 | [Life/README.md](Life/README.md) | 基金、小学报名、CDN AdGuard 等 |
| Sui | [Sui/README.md](Sui/README.md) | 工作内容与 AI Prompt 记录 |
| 图片资源 | [images/README.md](images/README.md) | Typora 图片资源 |

## 当前结构建议

当前不移动、不删除任何原始内容，先通过 README 建立导航。后续如果要继续整理，建议按下面的优先级处理：

1. 合并 SwiftUI 重复和分散内容：`iOS/Swift/SwiftUI/`、`iOS/SwiftUI/`、`Codes/SwiftUI.md`。
2. 明确 `iOS` 与 `Codes` 的边界：`iOS` 放知识原理和专题总结，`Codes` 放可复用片段和实践模板。
3. 检查重复文件：`iOS/Swift/SwiftUI/Animates.md` 与 `iOS/SwiftUI/Animates.md` 当前内容完全一致。
4. 给大文档拆分二级目录，优先考虑 `iOS/设计模式.md`、`iOS/通用/基础知识.md`、`iOS/Swift/Combine.md`。
5. 将 `.DS_Store` 这类系统文件加入忽略或清理，但清理前建议确认是否需要保留目录元数据。

## 内容维护规则

- 新增 iOS 原理、框架、语言特性笔记，优先放入 `iOS/`。
- 新增可复用代码片段、模板、封装实例，优先放入 `Codes/`。
- 新增 AI 工具命令、配置、快捷键，优先放入 `ai/`。
- 新增 Frida、汇编、逆向分析内容，优先放入 `逆向/`。
- 新增生活、设备、家庭服务相关记录，优先放入 `Life/`、`Mac/`、`Nas/`。

## 重要说明

本次优化只新增索引与整理说明，没有移动或删除已有笔记，原内容保持不变。
