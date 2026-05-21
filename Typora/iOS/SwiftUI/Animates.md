## 1.隐式动画

只要 state 改变，就会动画过渡

`withAnimation`

* 一次性包裹

* 影响 block 内所有 state 变化

`.animation(value:)`监听某个 value

```swift
// 在动画中修改值，就默认附带了动画
withAnimation {
    isExpanded.toggle()
}
// 或者
.animation(.easeInOut, value: isExpanded)
```

## 2.Animation 类型

用于普通 UI的几种动画形式

* .easeIn
* .easeOut
* .easeInOut
* .linear
* spring，更精细的控制`.interpolatingSpring(stiffness: 100, damping: 10)`
* .snappy (ios 17+)
* .smooth (ios 17+)
* .bouncy (ios 17+)

SwiftUI 动画的关键不是“怎么动”，而是：“**哪个属性在变**”

```swift
Rectangle()
    .frame(width: isOn ? 200 : 100)
    .animation(.easeInOut, value: isOn)
```

## 3.过度动画

```swift
if show {
    Text("Hello")
        .transition(.opacity)
}

// 
.transition(
    .asymmetric( // 定义了in/out的分别形式
        insertion: .move(edge: .top),
        removal: .opacity
    )
)
```

常见的transition

* .opacity

* .slide

* .move(edge: .leading)

* .scale

## 4.matchedGeometryEffect

```swift
//两个 view 共享同一个“动画身份”
@Namespace var ns

if isExpanded {
    BigView()
        .matchedGeometryEffect(id: "card", in: ns)
} else {
    SmallView()
        .matchedGeometryEffect(id: "card", in: ns)
}
```

## 能做什么？

- 卡片展开（App Store）
- Hero 动画
- 列表 → 详情页过渡

## 5.显示动画

### 5.1 关闭动画

```swift
// 可以关闭某些动画
.transaction { tx in
    tx.animation = nil
}
```

### 5.2 withAnimation + 自定义 timing

```swift
withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
    state = true
}
```

## 6. 手势动画

```swift
@State var offset: CGSize = .zero

DragGesture()
    .onChanged { value in
        offset = value.translation
    }
    .onEnded { _ in
        withAnimation(.spring()) {
            offset = .zero
        }
    }
```

