# Swift Decode

## 1.基础使用

```swift
/// 把json字符串解析为data类型
let data = jsonString.data(using: .utf8)!

/// 把json字符串解析为模型
struct User: Decodable {
    let id: Int
    let name: String
  
    // 解析时重命名
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case name = "user_name"
    }
  
  	init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(Int.self, forKey: .id)) ?? 0
    }
}

let decoder = JSONDecoder()
let user = try decoder.decode(User.self, from: data)



```

### 1.1 嵌套解析

| JSON 形态 |      Swift API       |
| :-------: | :------------------: |
|    {}     |    keyedContainer    |
|    []     |   unkeyedContainer   |
|   单值    | singleValueContainer |

```json
{
  "user": {
    "id": 1,
    "name": "Tom"
  }
}
```

```swift
struct Response: Decodable {
    let user: User
}

struct User: Decodable {
    let id: Int
    let name: String
}


// 手写自定义解析
struct Response: Decodable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case data
    }

    enum UserKeys: String, CodingKey {
        case id, name
    }

    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let data = try root.nestedContainer(keyedBy: UserKeys.self, forKey: .data)

        id = try data.decode(Int.self, forKey: .id)
        name = try data.decode(String.self, forKey: .name)
    }
}
```





## 2.AnyValue协议

```swift
protocol AnyValue {
    associatedtype Value
    var value: Value { get }
}
```

### 2.1 AnyInt

```swift
struct AnyInt: Decodable, AnyValue {
    let value: Int

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()

        if let int = try? c.decode(Int.self) {
            value = int
        } else if let double = try? c.decode(Double.self) {
            value = Int(double)
        } else if let string = try? c.decode(String.self),
                  let int = Int(string) {
            value = int
        } else {
            value = 0
        }
    }
}
```

### 2.2 AnyDouble

```swift
struct AnyDouble: Decodable, AnyValue {
    let value: Double

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()

        if let d = try? c.decode(Double.self) {
            value = d
        } else if let i = try? c.decode(Int.self) {
            value = Double(i)
        } else if let s = try? c.decode(String.self),
                  let d = Double(s) {
            value = d
        } else {
            value = 0
        }
    }
}
```

### 2.3 AnyBool

```swift
struct AnyBool: Decodable, AnyValue {
    let value: Bool

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()

        if let b = try? c.decode(Bool.self) {
            value = b
        } else if let i = try? c.decode(Int.self) {
            value = i != 0
        } else if let s = try? c.decode(String.self) {
            value = ["true", "1", "yes"].contains(s.lowercased())
        } else {
            value = false
        }
    }
}
```

###                                                          2.4 AnyString

```swift
struct AnyString: Decodable, AnyValue {
    let value: String

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()

        if let s = try? c.decode(String.self) {
            value = s
        } else if let i = try? c.decode(Int.self) {
            value = String(i)
        } else if let d = try? c.decode(Double.self) {
            value = String(d)
        } else {
            value = ""
        }
    }
}
```

### 2.5 AnyArray

```swift
struct AnyArray<Element: Decodable>: Decodable {
    let value: [Element]

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        value = (try? c.decode([Element].self)) ?? []
    }
}
```

### 2.6 AnyObjectOrArray

```swift
enum AnyObjectOrArray<T: Decodable>: Decodable {
    case object(T)
    case array([T])
    case empty

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()

        if let obj = try? c.decode(T.self) {
            self = .object(obj)
        } else if let arr = try? c.decode([T].self) {
            self = .array(arr)
        } else {
            self = .empty
        }
    }
}
```

### 2.7 KeyedDecodingContainer

```swift
extension KeyedDecodingContainer {
    func decodeSafely<T: Decodable>(_ type: T.Type, forKey key: Key) -> T? {
        return try? decodeIfPresent(type, forKey: key)
    }

    func decodeSafely<T: Decodable>(_ type: T.Type,
                                    forKey key: Key,
                                    default defaultValue: T) -> T {
        return (try? decode(type, forKey: key)) ?? defaultValue
    }
}

```

## 3.使用事例

```json
{
  "id": "1001",
  "name": 123,
  "score": "98.5",
  "is_vip": 1,
  "tags": null,
  "profile": {},
  "friends": []
}

```

```swift
struct UserDTO: Decodable {
    let id: AnyInt
    let name: AnyString
    let score: AnyDouble
    let isVIP: AnyBool
    let tags: AnyArray<String>
    let profile: AnyObjectOrArray<Profile>

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case score
        case isVIP = "is_vip"
        case tags
        case profile
    }
}

// ------

struct User {
    let id: Int
    let name: String
    let score: Double
    let isVIP: Bool
    let tags: [String]
}

extension User {
    init(dto: UserDTO) {
        id = dto.id.value
        name = dto.name.value
        score = dto.score.value
        isVIP = dto.isVIP.value
        tags = dto.tags.value
    }
}
// 使用
let decoder = JSONDecoder()
let dto = try decoder.decode(UserDTO.self, from: data)
let user = User(dto: dto)

```

