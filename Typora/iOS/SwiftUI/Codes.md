## 1.设置圆角

```swift
Text("Hello")
    .padding()
    .background(Color.blue)
    .cornerRadius(10)
// 裁剪当前 View 的整体形状, 如果有 background，要注意顺序！
```

```swift
Text("Hello")
    .padding()
    .background(Color.blue)
    .clipShape(RoundedRectangle(cornerRadius: 10))
// 推荐方式
```

```swift
Text("Hello")
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.blue)
    )
// 只裁剪背景（最常用场景🔥）
```

```swift
Text("Hello")
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
    )
    .overlay(
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray, lineWidth: 1)
    )
// 带边框的圆角
```

```swift
struct RoundedCorner: Shape {
    var radius: CGFloat = 10
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

Text("Hello")
    .padding()
    .background(Color.blue)
    .clipShape(RoundedCorner(radius: 10, corners: [.topLeft, .topRight]))
// 部分圆角
```



