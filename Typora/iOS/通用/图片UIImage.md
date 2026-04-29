## 1.拉伸/点九图

```swift
let insets = UIEdgeInsets(top: 5, left: 50, bottom: 5, right: 50)
// resizingMode: stretch 拉伸，title：重复平铺
let image = UIImage(named: "import_data_ai_tip_background")?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
```

