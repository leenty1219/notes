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
