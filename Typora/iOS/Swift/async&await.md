## 1.withCheckedContinuation 桥接
```swift
func loadDataAsync() async -> String {
    return await withCheckedContinuation { continuation in
        loadData { value in
            continuation.resume(returning: value)
        }
    }
}
```
## 2.async let
```swift
func fetchData() async throws -> (User, Orders) {
    async let user = fetchUser()
    async let orders = fetchOrders()
    return try await (user, orders)
}
```
* 自动并发
* 自动等待（在 try await 时）
* 与作用域绑定，出了作用域编译器会强制 await 或取消
## 3.TaskGroup
```swift
func fetchAll() async throws -> [Item] {
    try await withThrowingTaskGroup(of: Item.self) { group in
        for id in 1...5 {
            group.addTask { await fetchItem(id) }
        }
        
        var items: [Item] = []
        for try await result in group {
            items.append(result)
        }
        return items
    }
}
```
* 动态创建子任务个数
* 错误可以向上冒泡
* 子任务失效时会自动取消其他任务（fail-fast）
**Task**优先级
* **.high/ .userInitiated**  立刻反应 [[UI]]、重要任务
* .**mediu**m 普通计算
* **utility** 后台数据
* **background** 冗余，不重要
* **low** 尽量排队
```swift
Task(priority: .userInitiated) {
    await fetchData()
}
```
## 4.任务取消
## 5.MainActor
```swift
@MainActor
class ViewModel {
    func updateUI() {
        label.text = "Updated"
    }
}
@MainActor
func refreshUI() {
    label.text = "xx"
}

await MainActor.run {
    self.label.text = "Hello"
}
```
| 若一个 class 标注 `@MainActor`，则其所有方法默认主线程执行。
例子：
```swift
func refreshButtonTapped() {
    Task { @MainActor in
        loadingView.isHidden = false
    }

    Task {
        let data = try await fetchData()
        await MainActor.run {
            self.render(data)
            self.loadingView.isHidden = true
        }
    }
}
// 更优雅的写法
Task { @MainActor in
    loadingView.isHidden = false
}
Task { @MainActor in
    defer { loadingView.isHidden = true }
    let data = try await fetchData()
    render(data)
}
```
## 6.Actor
- **同一时间只允许一个任务访问内部状态（自动上锁）**
- **只要跨 actor 访问，就必须 `await`（即“线程切换提示”）**
```swift
actor Counter {
    var value = 0
    func increase() {
        value += 1
    }
}
// 访问
let counter = Counter()

Task.detached {
    await counter.increase()
}

Task.detached {
    await counter.increase()
}
```
## 7.AsyncStream
```swift
func makeStream() -> AsyncStream<Int> {
    AsyncStream { continuation in
        continuation.yield(1)
        continuation.yield(2)
        continuation.finish()
    }
}
Task {
    for await value in makeStream() {
        print(value)
    }
    print("完成")
}
```
AsyncStream 封装按钮的点击事件
```swift
extension UIButton {
    var tapStream: AsyncStream<Void> {
        AsyncStream { continuation in
            let target = ButtonTarget {
                continuation.yield(())
            }
            self.addTarget(target, action: #selector(ButtonTarget.invoke), for: .touchUpInside)

            continuation.onTermination = { @Sendable _ in
                // 按需移除监听（防内存泄漏）
                self.removeTarget(target, action: #selector(ButtonTarget.invoke), for: .touchUpInside)
            }
        }
    }
}

private class ButtonTarget: NSObject {
    let handler: () -> Void
    init(_ handler: @escaping () -> Void) { self.handler = handler }
    @objc func invoke() { handler() }
}
// 使用
Task {
    for await _ in myButton.tapStream {
        print("按钮点击")
    }
}
```
## 8.构建MVVM
```swift
actor UserViewModel {
    private var user: User?
    // 可能多个`订阅者`,这里存储起来
    private var continuations: [AsyncStream<User?>.Continuation] = []

    var stream: AsyncStream<User?> {
        AsyncStream { continuation in
            continuations.append(continuation)
            continuation.yield(user)
        }
    }

    func loadUser() async {
        // 假装网络请求
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        self.user = User(name: "张三")
        continuations.forEach { $0.yield(user) }
    }
}
// 使用
Task { @MainActor in
    for await user in viewModel.stream {
        self.nameLabel.text = user?.name ?? "加载中..."
    }
}

Task {
    await viewModel.loadUser()
}
```

```swift
struct User: Codable {
    let name: String
    let age: Int
}
import Foundation

@MainActor
actor Observable<Value> {
    private var value: Value
    private var continuations: [AsyncStream<Value>.Continuation] = []

    init(_ initialValue: Value) {
        self.value = initialValue
    }

    var stream: AsyncStream<Value> {
        AsyncStream { continuation in
            continuations.append(continuation)
            continuation.yield(value)
            continuation.onTermination = { [weak self] _ in
                self?.continuations.removeAll { $0 === continuation }
            }
        }
    }

    func update(_ newValue: Value) {
        value = newValue
        continuations.forEach { $0.yield(newValue) }
    }

    func current() -> Value { value }
}
import Foundation

class APIService {
    func fetchUser() async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            // 模拟网络延迟
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                let user = User(name: "张三", age: 18)
                continuation.resume(returning: user)
            }
        }
    }
}
@MainActor
actor UserViewModel {
    private let service = APIService()
    
    // 状态流
    let user = Observable<User?>(nil)
    
    // 异步加载数据
    func loadUser() async {
        do {
            let data = try await service.fetchUser()
            user.update(data)
        } catch {
            print("网络请求失败: \(error)")
        }
    }
    
    func updateName(_ name: String) {
        if var current = user.current() {
            current = User(name: name, age: current.age)
            user.update(current)
        }
    }
}
import UIKit

class ViewController: UIViewController {
    
    let viewModel = UserViewModel()
    
    let nameLabel = UILabel()
    let updateButton = UIButton(type: .system)
    let nameField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // 绑定 UI
        Task { @MainActor in
            for await user in await viewModel.user.stream {
                self.nameLabel.text = user?.name ?? "加载中..."
            }
        }
        
        // 监听按钮点击
        Task { @MainActor in
            for await _ in updateButton.tapStream {
                await viewModel.updateName(nameField.text ?? "")
            }
        }
        
        // 监听输入框变化
        Task { @MainActor in
            for await text in nameField.textChanges {
                print("输入内容: \(text)")
            }
        }
        
        // 加载数据
        Task {
            await viewModel.loadUser()
        }
    }
    
    func setupUI() {
        nameLabel.frame = CGRect(x: 50, y: 100, width: 300, height: 30)
        updateButton.frame = CGRect(x: 50, y: 150, width: 100, height: 40)
        nameField.frame = CGRect(x: 50, y: 200, width: 200, height: 40)
        
        updateButton.setTitle("更新名字", for: .normal)
        nameField.borderStyle = .roundedRect
        
        view.addSubview(nameLabel)
        view.addSubview(updateButton)
        view.addSubview(nameField)
    }
}

```
## 9. UIButton UITextField 的一些封装思路
```swift
import UIKit

extension UIButton {
    var tapStream: AsyncStream<Void> {
        AsyncStream { continuation in
            let target = ButtonTarget { continuation.yield(()) }
            self.addTarget(target, action: #selector(ButtonTarget.invoke), for: .touchUpInside)
            continuation.onTermination = { _ in
                self.removeTarget(target, action: #selector(ButtonTarget.invoke), for: .touchUpInside)
            }
        }
    }
}

private class ButtonTarget: NSObject {
    let handler: () -> Void
    init(_ handler: @escaping () -> Void) { self.handler = handler }
    @objc func invoke() { handler() }
}

extension UITextField {
    var textChanges: AsyncStream<String> {
        AsyncStream { continuation in
            let target = TextFieldTarget { [weak self] in
                continuation.yield(self?.text ?? "")
            }
            self.addTarget(target, action: #selector(TextFieldTarget.changed), for: .editingChanged)
        }
    }
}

private class TextFieldTarget: NSObject {
    let handler: () -> Void
    init(_ handler: @escaping () -> Void) { self.handler = handler }
    @objc func changed() { handler() }
}

```