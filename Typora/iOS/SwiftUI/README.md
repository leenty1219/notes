# SwiftUI 笔记索引

本目录独立整理 SwiftUI 相关内容，与 `iOS/Swift/` 中的 Swift 语言基础区分开。

## 文件列表

| 文件 | 内容 |
| --- | --- |
| [SwiftUI用例手册.md](SwiftUI用例手册.md) | **iOS 15 控件与特性场景速查**：导航、输入、列表、弹层、图片、布局、手势、异步加载和版本对照 |
| [SwiftUI.md](SwiftUI.md) | SwiftUI 综合笔记：状态数据、修饰符、布局、动画、UIKit 互嵌等 |
| [模型处理.md](模型处理.md) | SwiftUI 中 Model、ViewModel、状态拆分和列表 MVVM 设计 |
| [Animates.md](Animates.md) | SwiftUI 动画相关记录 |
| [Codes.md](Codes.md) | SwiftUI 常用代码片段 |

## 使用建议

- 需要按实际界面需求查控件组合时，先查 [SwiftUI用例手册.md](SwiftUI用例手册.md) 的“控件场景速查”。
- 需要了解状态设计、动画原理、UIKit 互嵌或图片缓存时，查阅对应专题笔记。
- 用例手册以 iOS 15 为基线；API 版本差异见手册末尾对照表。

## 归类原则

- SwiftUI 框架、View、修饰符、布局、动画、数据流、UIKit 互嵌内容放在当前目录。
- Swift 语言特性、并发、Combine、Property Wrapper 等语言或系统框架内容放在 `../Swift/`。
- 可复用代码片段优先放在 [Codes.md](Codes.md)，系统性总结优先放在 [SwiftUI.md](SwiftUI.md)。
