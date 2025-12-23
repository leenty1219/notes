```swift
@propertyWrapper
struct Capitalized {
    private var value: String = ""

    var wrappedValue: String {
        get { value }
        set { value = newValue.capitalized } // 自动首字母大写
    }

    init(wrappedValue: String) {
        self.value = wrappedValue.capitalized
    }
}

struct Person {
    @Capitalized var name: String
}

var p = Person(name: "lee")
print(p.name) // "Lee"

p.name = "john doe"
print(p.name) // "John Doe"
// -------------------------------------------
@propertyWrapper
struct Tracked<Value> {
    private var value: Value
    var changeCount = 0

    var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            changeCount += 1
        }
    }

    var projectedValue: Int { changeCount } // 额外信息
}

struct Counter {
    @Tracked var count = 0
}

var c = Counter()
c.count = 5
c.count = 10
print(c.$count) // 2 次修改
// ----------------------------------

@propertyWrapper
struct AsyncValue<Value> {
    private var value: Value?

    var wrappedValue: Value? { value }

    mutating func load(_ operation: @escaping () async -> Value) async {
        self.value = await operation()
    }
}

struct Content {
    @AsyncValue var user: User?
}

var content = Content()

Task {
    await content._user.load {
        try await API.fetchUser()
    }
}

```


