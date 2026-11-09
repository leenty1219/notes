# AI 代码设计规范

## 0. 硬规则（不可协商）

1. **Lint 规范与本文必须同时满足。** 满足一个不能以违反另一个为代价。
2. 两者冲突或做不到时，**停下并报告用户，请求本次例外**。AI 无权自行决定例外。
3. 禁止任何绕过手段，包括但不限于：
   - `swiftlint:disable` / `oclint:suppress`、改 lint 配置或阈值；
   - 缩写、压缩、嵌套闭包、三元链来凑 Lint 指标；
   - 把违规代码藏进 `extension`、`typealias`、新文件、字符串拼接，规避 §8 的 grep 检查；
   - 改名、换写法让检查"看不到"问题；
   - 在报告里隐瞒或淡化违规。
4. 只约束**新增代码**。历史代码不重构、不改名、不移动、不格式化，一行也不动；发现违规只在最终报告列出。
5. 禁止以"旁边的历史代码也这么写"为理由复制坏模式。
6. 禁止为满足本文扩大改动范围。范围优先。

## 1. 分层与依赖方向（MVVM）

```
View / VC  →  ViewModel  →  Service / Repository  →  Model
```

依赖只能向右，禁止反向、跨层。新 Swift 页面：`VC + View + ViewModel`。

### 1.1 ViewModel

判定标准：不依赖 UIKit / SwiftUI，纯 Foundation 测试里能直接创建并断言输出。

- 禁止 `import UIKit` / `SwiftUI` / `AppKit`。
- 禁止出现 UI 类型：`UIColor`、`UIImage`、`UIFont`、`UIView`、`UIViewController`、`UIAlertController`、`UIEdgeInsets`、`CGRect`、`CGSize`、带 UI 属性的 `NSAttributedString`。
- 只输出语义，不输出呈现：颜色/图片/样式用枚举或名称，View 层映射。
- 业务格式化（金额、日期、文案选择）在 ViewModel 内完成，输出 `String`。
- 禁止持有 VC / View / Router；禁止 push / present / 弹窗 / Toast。需要时输出事件（枚举 + 闭包/`PassthroughSubject`/delegate），由 VC 执行。
- 禁止直接用 `.shared`、`UserDefaults.standard`、`NotificationCenter.default`。依赖以协议经 `init` 注入；模块已有解析方式（如 `SuiModuleProviderManager`）则沿用。
- 对外状态 `private(set)`。线程安全由 ViewModel 保证（`@MainActor` 或集中一处切主线程），不让 View 到处包 `DispatchQueue.main.async`。
- 绑定机制沿用所在模块。部署目标 iOS 15，禁用 `@Observable`（需 iOS 17）。

> 不 import ≠ 没依赖：同模块其他文件已 import 的 UIKit 符号，本文件不 import 也能用。必须用 §8 的 grep 检查 UI 类型。

### 1.2 其他层

- **View / VC**：只做绑定、转发用户操作、执行 ViewModel 事件。禁止业务判断、数据转换、格式化、校验、网络请求、直接访问 Service / DAO。
- **Service / Repository**：对上暴露协议；返回领域模型或整理后的错误；不返回 `[String: Any]`、原始 JSON、第三方库类型。
- **Model**：优先 `struct` / `enum`；无 UI、网络、单例依赖；派生值用计算属性。

```swift
// ❌ ViewModel 依赖 UIKit
import UIKit
final class AccountBalanceViewModel {
    func balanceColor(for amount: Decimal) -> UIColor { amount < 0 ? .red : .black }
}

// ✅ 输出语义，颜色由 View 层映射
enum BalanceTone { case normal, negative }
final class AccountBalanceViewModel {
    func tone(for amount: Decimal) -> BalanceTone { amount < 0 ? .negative : .normal }
}

// ❌ Bool 拼状态，存在非法组合
var isLoading = false
var hasError = false

// ✅ 枚举表达状态
enum LoadState<Value> { case idle, loading, loaded(Value), failed(String) }
@Published private(set) var state: LoadState<[Item]> = .idle
```

### 1.3 ViewModel 单元测试（必须）

- 新增 ViewModel 中**所有不依赖 UIKit 的方法和计算属性**，必须有单元测试，无一例外。新 ViewModel 本就禁止依赖 UIKit，因此等于全部方法。
- 在历史 ViewModel 里新增的方法，只要不依赖 UIKit，同样必须有单元测试。历史方法不补。
- 每个方法至少覆盖：正常流程、关键边界、失败/异常路径（适用时）。断言输出状态或发出的事件，不断言内部实现。
- 依赖用协议 mock 注入。测试中禁止真实网络、数据库、`.shared` 单例、真实时间。
- 测试类 `final`，一个文件一个测试类，命名 `<ViewModel名>Tests`，放入所在模块已有的单测 target（主工程为 `MyMoney/MyMoneyProTests`）。`XCTFail` 必须带消息。
- 不得用删除方法、改成 `private`、挪进 View/VC 来逃避测试要求。
- 写测试是必须的；编译、运行测试只在用户要求时才做。未运行的必须在报告里写明。

## 2. 命名（Swift API Design Guidelines）

- 调用处读起来像一句英文：`accounts.remove(at: index)`。
- 按角色命名，不按类型：`greeting` 而非 `string`。
- 省略重复类型的词：`remove(_ member:)` 而非 `removeElement(_:)`。
- 禁止缩写（`mgr`、`cfg`、`btn`、`vc`、`vm`、`tmp`、`val`、`obj`、`arr`、`dict`）和拼音；`URL`、`ID` 等通用术语除外。
- 禁止类型后缀重复：`accounts`，不是 `accountArr` / `accountList`。
- 无副作用用名词短语（`formattedBalance`、`distance(to:)`），有副作用用祈使动词（`reload()`、`submit()`）。
- 可变/不可变成对：`sort()` / `sorted()`。工厂方法以 `make` 开头。
- Bool 读作断言：`isEmpty`、`isSubmitEnabled`、`hasPendingChanges`。禁止 `isShowXxx`、`isNotXxx`、`noXxx`。
- 协议：是什么用名词，能力用 `-able` / `-ing`。
- 首参构成语法短语则省略标签，否则必须带；其余参数一律带标签；默认值参数放末尾。
- 缩略词大小写一致：`userID`、`htmlParser`。
- 禁止泛名作类型名：`Manager`、`Helper`、`Util`、`Handler`、`Processor`、`Info`、`Data`、`Common`。类型名必须带出业务对象与职责。
- 禁止泛名作方法名：`handle()`、`process()`、`update()`、`refreshUI()`、`setupData()`。
- ViewModel 输入用意图（`submit()`、`selectAccount(at:)`），输出用状态（`title`、`isSubmitEnabled`）。禁止 `buttonClicked()`、`setTitle()`、`updateUI()`。

## 3. 结构与可读性

- 一文件一个主类型，文件名 = 类型名；协议实现放 `Type+Protocol.swift`。
- Lint 上限是天花板，不是目标。建议：函数 ≤ 30 行，类型 ≤ 200 行，嵌套 ≤ 2 层。超出就拆，不压缩。
- 一个函数只做一件事，同一抽象层级。取数、转换、更新 UI 分开。
- 提前 `guard` 返回；回调超过 2 层拆成具名函数或 `async/await`。
- 类型表达意图：状态组合用 `enum`；业务数据用 `struct`；禁止在业务层传 `[String: Any]`、`Any`、`AnyObject`、元组。
- 常量名带业务语义：`maxImageCountPerTransaction`，不是 `limit`。
- 状态单一来源，派生值用计算属性。
- 纯逻辑写成无依赖函数/值类型；副作用集中在 Service。
- 访问控制默认 `private`，需要才放开。
- 错误由 Service 层归一化一次，ViewModel 转成可展示结果，View 不解析底层错误。
- 注释只写 why（业务规则、外部约束、反直觉处理），不写 what，不替代改名。
- 妥协必须留 `// TODO: - <Jira号> 说明`，并在报告里列出。

## 4. 可拆分 / 可开源

新模块整个目录拷走，补几个协议实现即可编译。

- 非 View 层只 `import Foundation`（可加 `Combine`）。
- 不引用 App 全局能力：`AppDelegate`、全局路由、埋点 SDK、账号/主题/会员单例、内部网络库类型。需要时在模块内声明协议，由调用方注入。
- 组装代码（创建 ViewModel、注入真实实现）集中在入口一处。
- 业务文案、域名、密钥、内部库名、内部 Jira 号不进核心逻辑。
- 对外只暴露必要入口。

## 5. 写前自问

1. 职责能用一句不含"和"的话说完吗？
2. 属于哪一层，依赖方向对吗？
3. 依赖能经 `init` 以协议注入吗？
4. 目录拷走要补哪些协议？

任一答不出，先修设计再写代码。

## 6. 禁止的偷懒做法

- 为过长度限制把名字缩短（`vm`、`cfg`、`tmpData`）。
- 为过函数长度/复杂度把逻辑塞进嵌套闭包、三元链。
- ViewModel 里用 `UIColor` / `UIImage` / `UIViewController`。
- 业务逻辑写进 VC / Cell。
- 直接调用 `.shared`。
- 多个 `Bool` 拼状态。
- `[String: Any]` / 元组传数据。
- 到处包 `DispatchQueue.main.async`。
- `Manager` / `Helper` / `Util` 兜底。
- 一个函数里取数 + 转换 + 刷 UI。
- 复制旁边的历史坏写法。

## 7. 最终报告必须包含

- 新增类型所属层与一句话职责。
- 依赖的协议及注入位置。
- ViewModel 方法与测试用例的对应关系；未运行的测试明确标注。
- 发现但未修改的历史违规（路径 + 一句话）。
- 需要用户批准的例外（若有）及原因。

## 8. 交付前自检

- [ ] Lint 规范全部满足，无 `swiftlint:disable` / `oclint:suppress`
- [ ] 本文全部满足，无绕过手段
- [ ] 新 ViewModel 无 `import UIKit/SwiftUI`，无 UI 类型
- [ ] ViewModel 不持有 VC/View/Router，不弹窗不跳转
- [ ] ViewModel 每个不依赖 UIKit 的方法都有单元测试（正常/边界/失败）
- [ ] 无直接 `.shared` / `UserDefaults.standard`，依赖经协议注入
- [ ] View/VC 无业务判断、格式化、网络
- [ ] 状态用 `enum`/`struct`，无 Bool 拼状态、`[String: Any]`
- [ ] 命名无缩写、拼音、泛名
- [ ] 一文件一主类型，函数单一职责
- [ ] 非 View 层只依赖 Foundation / Combine
- [ ] 未改动历史代码

对新增 ViewModel 文件执行，命中项逐条说明，否则修正：

```bash
rg -n 'import (UIKit|SwiftUI|AppKit)|\bUI[A-Z][A-Za-z]+\b|\b(CGRect|CGSize)\b|\.shared\b|UserDefaults\.standard|NotificationCenter\.default|DispatchQueue\.main' <新增 ViewModel 文件>
```

---

来源：Swift API Design Guidelines（swift.org）；The Swift Programming Language: Access Control；WWDC23 Discover Observation in SwiftUI；Google Swift Style Guide；Artsy "MVVM in Swift"；Swift Forums "silent import"。Apple 无官方 MVVM 规范，§1 分层边界来自社区共识。
