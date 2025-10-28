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
## 2.


## 12. 关键字
### eraseToAnyPublisher
它返回一个 `AnyPublisher` 实例
### 线程
.receive(on: RunLoop.main)
