## 1.Future
适合用在一次性任务中
```swift
func fetchUser(id: String) -> Future<User, Error> {
    Future { promise in
        api.getUser(id: id) { result in
            switch result {
            case .success(let user):
                promise(.success(user))
            case .failure(let error):
                promise(.failure(error))
            }
        }
    }
}

// 使用
let cancellable = fetchUser("1")
    .sink { value in
        print("Got:", value) 
    }
```
## 2.系统自建的Pulisher

### 2.1 Notification
```swift
let publisher = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
publisher.sink { _ in
    print("App进入后台")
}
```
### 2.2 网络
```swift
import Combine

let url = URL(string: "https://api.github.com/users/apple")!
URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: User.self, decoder: JSONDecoder())
    .sink(receiveCompletion: { print($0) },
          receiveValue: { user in print(user) })
```
### 2.3 KVO
```swift
import Combine

class MyView: UIView {
    private var cancellable: AnyCancellable?

    func observeFrame() {
        cancellable = publisher(for: \.frame)
            .sink { newFrame in
                print("Frame changed: \(newFrame)")
            }
    }
}

       view.publisher(for: \.backgroundColor).sink { color in

            print("color = 111")

        }.store(in: &cancel)
```
### 2.4 Timer
```swift
import Combine

let timer = Timer.publish(every: 1.0, on: .main, in: .common)
let cancellable = timer
    .autoconnect()
    .sink { date in
        print("Tick: \(date)")
    }
```
### 2.5 Runloop
```swift
import Combine

Just("Hello")
    .delay(for: .seconds(2), scheduler: RunLoop.main)
    .sink { print($0) }
```




## 12. 关键字
### eraseToAnyPublisher
它返回一个 `AnyPublisher` 实例
### 线程
.receive(on: RunLoop.main)





## 3.关键字

### 3.1 Just

发布单个值然后完成

```swift
let just = Just("Hello")
    .sink { value in
        print(value)  // 输出: Hello
    }
```

### 3.2 Future

异步执行操作并发布结果

```swift
// Future：封装异步回调，只执行一次，结果通过 promise 发布
func fetchData() -> Future<String, Error> {
    return Future { promise in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            promise(.success("数据加载完成"))
        }
    }
}

fetchData()
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("错误: \(error)")
            }
        },
        receiveValue: { value in
            print(value)  // 输出: 数据加载完成
        }
    )
```

### 3.3 Deferred

延迟创建 Publisher，直到有订阅者

```swift
let deferred = Deferred {
    Future { promise in
        print("开始执行")
        promise(.success("结果"))
    }
}
// 此时不会执行（只创建了 Deferred，未订阅）
print("创建完成")

// 订阅时才执行内部 Future，并收到 "结果"
deferred.sink { value in
    print(value)  // 输出: 开始执行, 结果
}
```

### 3.4 Empty

不发布任何值，可选择立即完成或永不完成。Empty 是 Combine 中非常有用的占位符 Publisher，常用于条件分支、错误处理、以及保持订阅活跃。

```swift
// 立即完成：不发送任何 value，只发送 completion
let empty = Empty<String, Never>(completeImmediately: true)
    .sink(
        receiveCompletion: { _ in print("完成") },
        receiveValue: { _ in }
    )

// 永不完成：既不发值也不发 completion，常用于测试或「占位」
let never = Empty<String, Never>(completeImmediately: false)
```

`Empty` 最常见的用途是作为**占位符 Publisher**，在条件不满足时提供一个"空"的 Publisher，避免返回 Optional 或处理 nil 的情况。

```swift
// 场景：根据条件返回不同的 Publisher
func fetchData(shouldFetch: Bool) -> AnyPublisher<String, Never> {
    if shouldFetch {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .compactMap { String(data: $0, encoding: .utf8) }
            .replaceError(with: "")
            .eraseToAnyPublisher()
    } else {
        // 使用 Empty 作为占位，不执行任何操作
        return Empty(completeImmediately: true)
            .eraseToAnyPublisher()
    }
}

// 使用：无论条件如何，返回类型都是 AnyPublisher<String, Never>
fetchData(shouldFetch: true)
    .sink { print($0) }  // 正常接收数据

fetchData(shouldFetch: false)
    .sink { print($0) }  // 立即完成，不接收任何值
```

错误处理中的占位

```swift
// 在 catch 中使用 Empty 作为备用 Publisher
func loadUserData() -> AnyPublisher<User, Error> {
    return URLSession.shared.dataTaskPublisher(for: userURL)
        .map(\.data)
        .decode(type: User.self, decoder: JSONDecoder())
        .catch { error -> AnyPublisher<User, Error> in
            if error is DecodingError {
                // 解码错误时返回空 Publisher，不发送任何值
                return Empty(completeImmediately: true)
                    .eraseToAnyPublisher()
            } else {
                // 其他错误继续传播
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
}
```

Empty 的 `completeImmediately: false` 模式可以创建一个**永不完成的 Publisher**，这在需要保持订阅活跃、贯穿整个程序生命周期的场景中非常有用

```swift
class BackgroundTaskManager {
    private var cancellables = Set<AnyCancellable>()
    
    // 创建一个永不完成的 Empty 作为基础流
    private let keepAlive = Empty<Never, Never>(completeImmediately: false)
        .eraseToAnyPublisher()
    
    func startBackgroundTask() {
        // 使用 flatMap 将 Empty 转换为周期性的任务流
        keepAlive
            .flatMap { _ -> AnyPublisher<Date, Never> in
                // 每 5 秒执行一次任务
                return Timer.publish(every: 5.0, on: .main, in: .common)
                    .autoconnect()
                    .map { _ in Date() }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] date in
                self?.performBackgroundTask(at: date)
            }
            .store(in: &cancellables)
    }
    
    private func performBackgroundTask(at date: Date) {
        print("执行后台任务: \(date)")
        // 执行实际的后台任务，如数据同步、状态检查等
    }
    
    func stopBackgroundTask() {
        cancellables.removeAll()  // 取消所有订阅
    }
}
```



### 3.5 flatMap 

```swift
// 在 flatMap 中根据条件决定是否执行操作
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .flatMap { query -> AnyPublisher<[String], Never> in
                if query.isEmpty {
                    // 空查询时返回 Empty，不执行搜索
                    return Empty(completeImmediately: true)
                        .eraseToAnyPublisher()
                } else {
                    // 执行搜索
                    return self.search(query: query)
                        .catch { _ in Just([]) }
                        .eraseToAnyPublisher()
                }
            }
            .assign(to: \.results, on: self)
            .store(in: &cancellables)
    }
    
    private func search(query: String) -> AnyPublisher<[String], Error> {
        // 搜索实现
        return Just(["结果1", "结果2"])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
```

### 3.6 Sequence

```swift
// 符合 Sequence 的类型都有 .publisher，按顺序发布元素
let sequence = (1...5).publisher
    .sink { value in
        print(value)  // 输出: 1, 2, 3, 4, 5
    }
```

### 3.7 自定义Publisher

```swift
// 自定义 Publisher：从数组按需发布元素，遵循背压
struct CustomPublisher: Publisher {
    typealias Output = Int
    typealias Failure = Never
    
    let values: [Int]
    
    func receive<S>(subscriber: S) where S: Subscriber, 
        S.Input == Output, S.Failure == Failure {
        // 收到订阅者时，创建自定义 Subscription 并下发给订阅者
        let subscription = CustomSubscription(
            subscriber: subscriber,
            values: values
        )
        subscriber.receive(subscription: subscription)
    }
}

// 自定义 Subscription：根据 request(demand) 按需从 values 取数并下发
class CustomSubscription<S: Subscriber>: Subscription 
    where S.Input == Int, S.Failure == Never {
    
    var subscriber: S?
    let values: [Int]
    var currentIndex = 0
    var requested: Subscribers.Demand = .none
    
    init(subscriber: S, values: [Int]) {
        self.subscriber = subscriber
        self.values = values
    }
    
    func request(_ demand: Subscribers.Demand) {
        requested += demand
        
        // 在 demand 允许且还有数据时，逐个下发
        while requested > .none && currentIndex < values.count {
            let value = values[currentIndex]
            currentIndex += 1
            requested -= .max(1)
            
            _ = subscriber?.receive(value)
        }
        
        if currentIndex >= values.count {
            subscriber?.receive(completion: .finished)
            cancel()
        }
    }
    
    func cancel() {
        subscriber = nil
    }
}

// 使用自定义 Publisher：行为等价于 [1,2,3].publisher
let custom = CustomPublisher(values: [1, 2, 3])
    .sink { value in
        print(value)  // 输出: 1, 2, 3
    }
```

### 3.8 Map

```swift
// map：对每个元素做变换，类型可改变
[1, 2, 3].publisher
    .map { $0 * 2 }
    .sink { print($0) }  // 输出: 2, 4, 6

// flatMap：每个元素映射为一个新 Publisher，再把这些 Publisher 的输出「压平」成一条流
["A", "B", "C"].publisher
    .flatMap { letter in
        (1...2).publisher.map { "\(letter)\($0)" }
    }
    .sink { print($0) }  // 输出: A1, A2, B1, B2, C1, C2


// compactMap：类似 map，但闭包返回 Optional；nil 会被丢弃，不往下游发
["1", "2", "abc", "3"].publisher
    .compactMap { Int($0) }
    .sink { print($0) }  // 输出: 1, 2, 3
```

### 3.9 scan 带操作符计算

```swift
// scan：给定初始值，每收到一个元素就与当前累积值做运算，并下发新的累积值
[1, 2, 3, 4, 5].publisher
    .scan(0, +)
    .sink { print($0) }  // 输出: 1, 3, 6, 10, 15
```

### 3.10 filter

```swift
// filter：只下发谓词为 true 的值
[1, 2, 3, 4, 5].publisher
    .filter { $0 % 2 == 0 }
    .sink { print($0) }  // 输出: 2, 4
```

### 3.11 removeDuplicates 

```swift
// removeDuplicates：连续相同只发第一个，相当于「相邻去重」
[1, 1, 2, 2, 3, 3].publisher
    .removeDuplicates()
    .sink { print($0) }  // 输出: 1, 2, 3
```

### 3.12 first / last

```swift
// first：只取第一个元素，取到后发完成
[1, 2, 3, 4, 5].publisher
    .first()
    .sink { print($0) }  // 输出: 1

// last：必须等上游完成，再发最后一个元素
[1, 2, 3, 4, 5].publisher
    .last()
    .sink { print($0) }  // 输出: 5
```

### 3.13 dropFirst / dropLast

``` swift
// dropFirst(n)：跳过前 n 个，只发后面的
[1, 2, 3, 4, 5].publisher
    .dropFirst(2)
    .sink { print($0) }  // 输出: 3, 4, 5
```

### 3.14 combineLatest

组合多个 Publisher 的最新值

```swift
/// combineLatest：两边都**至少**发过一个值后，每次任一边发新值就组合「两边当前最新值」下发
let publisher1 = PassthroughSubject<String, Never>()
let publisher2 = PassthroughSubject<Int, Never>()

publisher1
    .combineLatest(publisher2)
    .sink { value1, value2 in
        print("\(value1): \(value2)")
    }

publisher1.send("A")  // 无输出（publisher2 尚未发过值）
publisher2.send(1)    // 输出: A: 1
publisher1.send("B")  // 输出: B: 1（用 B 与 2 的最新值 1 组合）
publisher2.send(2)    // 输出: B: 2
```

### 3.15 merge

合并多个 Publisher。

```swift
// merge：多个流合并成一条，哪个先发就先收到哪个，类型必须相同
let publisher1 = PassthroughSubject<Int, Never>()
let publisher2 = PassthroughSubject<Int, Never>()

publisher1
    .merge(with: publisher2)
    .sink { print($0) }

publisher1.send(1)  // 输出: 1
publisher2.send(2)  // 输出: 2
publisher1.send(3)  // 输出: 3
```

### 3.16 zip

```swift
// zip：按「第 n 个与第 n 个」配对，凑齐一对才下发，顺序严格
let publisher1 = PassthroughSubject<String, Never>()
let publisher2 = PassthroughSubject<Int, Never>()

publisher1
    .zip(publisher2)
    .sink { value1, value2 in
        print("\(value1): \(value2)")
    }

publisher1.send("A")  // 等待 publisher2 的第一个值
publisher1.send("B")  // 等待 publisher2 的第二个值
publisher2.send(1)    // 输出: A: 1
publisher2.send(2)    // 输出: B: 2
```

### 3.17 debounce

防抖，等待指定时间后发布最新值。

```swift
// debounce：在一段时间内没有新值时，才把「最后一次收到的值」发出去（适合搜索框）
let subject = PassthroughSubject<String, Never>()

subject
    .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
    .sink { print($0) }

subject.send("H")     // 不输出（等待 0.5s）
subject.send("He")    // 重置等待
subject.send("Hel")   // 重置等待
subject.send("Hell")  // 重置等待
subject.send("Hello") // 0.5 秒内无新值，输出: Hello
```

### 3.18 throttle

节流，在指定时间间隔内只发布第一个值。

```swift
// throttle：在时间窗口内只取一个值；latest: false 取窗口内第一个，true 取最后一个
let subject = PassthroughSubject<String, Never>()

subject
    .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
    .sink { print($0) }

subject.send("A")  // 立即输出: A，开启 1 秒窗口
subject.send("B")  // 不输出（1 秒内）
subject.send("C")  // 不输出（1 秒内）
// 1 秒后
subject.send("D")  // 输出: D
```

### 3.19 delay

```swift
// delay：每个元素都延后指定时间再下发，相对顺序不变
[1, 2, 3].publisher
    .delay(for: .seconds(1), scheduler: DispatchQueue.main)
    .sink { print($0) }  // 1 秒后依次输出: 1, 2, 3
```

### 3.20 catch  error

```swift
// catch：上游失败时用闭包返回一个备用 Publisher，流继续用备用流
enum MyError: Error {
    case failure
}

let publisher = Fail<String, MyError>(error: .failure)
    .catch { error -> Just<String> in
        print("捕获错误: \(error)")
        return Just("备用值")
    }
    .sink { print($0) }  // 输出: 捕获错误: failure, 备用值
```

### 3.21 retry

```swift
// retry(n)：失败时重新订阅上游最多 n 次（这里是 2 次，共最多 3 次执行）
var attempts = 0

let publisher = Future<String, Error> { promise in
    attempts += 1
    if attempts < 3 {
        promise(.failure(NSError(domain: "test", code: 1)))
    } else {
        promise(.success("成功"))
    }
}
.retry(2)  // 最多重试 2 次，第 3 次成功
.sink(
    receiveCompletion: { print($0) },
    receiveValue: { print($0) }  // 输出: 成功
)
```

### 3.22 replaceError

用默认值替换错误

```swift
// replaceError：失败时不发错误，改为发一个默认值并正常结束
let publisher = Fail<String, MyError>(error: .failure)
    .replaceError(with: "默认值")
    .sink { print($0) }  // 输出: 默认值
```

### 3.23 PassthroughSubject

直接传递值，不保存当前值。

```swift
// PassthroughSubject：只转发 send 的值，不存当前值，后订阅的收不到之前的值
let subject = PassthroughSubject<String, Never>()

// 订阅1
let cancellable1 = subject.sink { print("订阅1: \($0)") }

subject.send("A")  // 输出: 订阅1: A

// 订阅2：之后 send 的值两个订阅都会收到
let cancellable2 = subject.sink { print("订阅2: \($0)") }

subject.send("B")  // 输出: 订阅1: B, 订阅2: B
```

### 3.24 CurrentValueSubject

保存当前值，新订阅者会立即收到当前值。

```swift
// CurrentValueSubject：持有当前 value，新订阅者会先收到当前值再收后续 send
let subject = CurrentValueSubject<String, Never>("初始值")

// 订阅1：立即收到初始值
let cancellable1 = subject.sink { print("订阅1: \($0)") }
// 输出: 订阅1: 初始值

subject.value = "新值"  // 输出: 订阅1: 新值

// 订阅2：一订阅就收到当前值 "新值"
let cancellable2 = subject.sink { print("订阅2: \($0)") }
// 输出: 订阅2: 新值（立即收到当前值）
```

### 3.25 @Published 属性包装器

⚠️注意会默认发送初始值

```swift
// @Published：属性变化时自动发值；$name 是该属性的 Publisher
class ViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var age: Int = 0
    
    init() {
        // 监听 name 的变化，防抖后处理
        $name
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] newName in
                print("名称变化: \(newName)")
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

let viewModel = ViewModel()
viewModel.name = "张三"  // 0.5 秒后输出: 名称变化: 张三
```

### 3.26 @Published

`@Published` 是 Combine 中最常用和推荐的方式，特别适合在 ViewModel 或 ObservableObject 中使用

### 3.27 KVO Publisher

- `.initial`：订阅时立即发送当前值
- `.new`：属性变化时发送新值
- `.old`：属性变化时发送旧值
- `.prior`：变化前发送旧值，变化后发送新值

```swift
import Combine

class Person: NSObject {
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}

// 使用
let person = Person()

// 将 KVO 属性转换为 Publisher
person.publisher(for: \.name, options: [.initial, .new])
    .sink { name in
        print("姓名变化: \(name)")
    }
    .store(in: &cancellables)

person.publisher(for: \.age, options: [.initial, .new])
    .sink { age in
        print("年龄变化: \(age)")
    }
    .store(in: &cancellables)

// 修改属性会触发 Publisher
person.name = "张三"  // 输出: 姓名变化: 张三
person.age = 25      // 输出: 年龄变化: 25
```

### 3.28 Thread

##### DispatchQueue

```swift
// subscribe(on:)：订阅与上游工作在哪个调度器；receive(on:)：下游收值在哪个调度器（常用主线程更新 UI）
[1, 2, 3].publisher
    .subscribe(on: DispatchQueue.global())  // 在后台线程执行订阅与上游
    .receive(on: DispatchQueue.main)        // 在主线程接收并执行 sink
    .sink { print($0) }
```

##### RunLoop

```swift
// RunLoop 也符合 Scheduler，可在当前 RunLoop 上调度
[1, 2, 3].publisher
    .subscribe(on: RunLoop.current)
    .sink { print($0) }
```

##### OperationQueue

```swift
// OperationQueue 可作为 Scheduler，可限制并发数
let queue = OperationQueue()
queue.maxConcurrentOperationCount = 2

[1, 2, 3, 4, 5].publisher
    .subscribe(on: queue)
    .sink { print($0) }
```

#### ImmediateScheduler

```swift
// ImmediateScheduler：不延迟，立即在当前上下文执行，常用于测试
let scheduler = ImmediateScheduler.shared

[1, 2, 3].publisher
    .receive(on: scheduler)
    .sink { print($0) }
```

 



 
