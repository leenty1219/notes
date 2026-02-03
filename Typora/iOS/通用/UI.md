## 1.设置抗拉伸/压缩
```swift
// 设置压缩/拉伸等级
label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
```

self.edgesForExtendedLayout = UIRectEdgeBottom; // 只允许底部延伸 安全区