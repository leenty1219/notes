# SwiftUI 笔记

[Github 教程地址](https://github.com/SwiftfulThinking/SwiftUI-Bootcamp)

## 目录

- [1. 状态与数据流](#1-状态与数据流)
- [2. 常用修饰符与样式](#2-常用修饰符与样式)
- [3. 布局与尺寸](#3-布局与尺寸)
- [4. 动画与转场](#4-动画与转场)
- [5. 页面展示与关闭](#5-页面展示与关闭)
- [6. UIKit 与 SwiftUI 互嵌](#6-uikit-与-swiftui-互嵌)
- [7. 调试与测试资源](#7-调试与测试资源)

## 1. 状态与数据流

### 1.1 属性包装器对比

| 装饰器 | 所属类型 | 谁持有 | 生命周期 | 适合场景 |
| --- | --- | --- | --- | --- |
| `@State` | 值类型 | 视图本身 | 跟随视图 | 视图私有的小状态 |
| `@Binding` | Binding 引用 | 父持有，子引用 | 由原持有者决定 | 子视图需要修改父状态 |
| `@StateObject` | `ObservableObject` | 视图首次创建 | 视图首次创建后保持同一实例 | 视图拥有自己的 ViewModel |
| `@ObservedObject` | `ObservableObject` | 外部持有，视图观察 | 由外部决定 | 父视图注入或共享对象 |
| `@EnvironmentObject` | `ObservableObject` | 上层注入 | 注入点决定 | 全局或跨层级共享 |
| `@Environment` | 环境值 | 系统或上层注入 | 环境决定 | 读取系统环境或自定义环境值 |
| `@Bindable` | Observation 对象 | 外部或当前视图 | 对象本身决定 | Swift 5.9 Observation 的双向绑定 |
| `@Published` | `ObservableObject` 属性 | 对象本身 | 对象生命周期 | 属性变化时通知视图刷新 |

### 1.2 @State

用在 `struct View` 内保存视图私有、轻量的可变状态。

```swift
struct CounterView: View {
    @State private var count: Int = 0

    var body: some View {
        VStack {
            Text("\(count)")
            Button("＋") { count += 1 }
        }
    }
}
```

### 1.3 @Binding

子视图不持有状态，但需要读写父视图提供的状态时使用。

```swift
struct ParentView: View {
    @State private var isOn = false

    var body: some View {
        ToggleView(isOn: $isOn)
    }
}

struct ToggleView: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("开关", isOn: $isOn)
    }
}
```

### 1.4 @ObservedObject

观察外部传入的 `ObservableObject`，视图不负责对象生命周期。

```swift
class UserSettings: ObservableObject {
    @Published var name: String = ""
}

struct ProfileView: View {
    @ObservedObject var settings: UserSettings

    var body: some View {
        TextField("姓名", text: $settings.name)
    }
}
```

### 1.5 @StateObject

视图内部创建并持有 `ObservableObject` 时使用，避免视图刷新时重复创建对象。

```swift
class MyViewModel: ObservableObject {
    @Published var items = [String]()
}

struct MyView: View {
    @StateObject private var vm = MyViewModel()

    var body: some View {
        List(vm.items, id: \.self) { Text($0) }
    }
}
```

### 1.6 @EnvironmentObject

跨层级共享对象。上层用 `.environmentObject(obj)` 注入，子视图用 `@EnvironmentObject` 读取。

```swift
class AppState: ObservableObject {
    @Published var loggedIn: Bool = false
}

ContentView().environmentObject(AppState())

struct MenuView: View {
    @EnvironmentObject var appState: AppState
}
```

### 1.7 @Environment

读取系统或自定义环境值。

```swift
@Environment(\.colorScheme) var colorScheme
```

### 1.8 @Bindable

属于 Swift 5.9 Observation 系统，与 `ObservableObject` 不同。

```swift
@Observable
class ProfileModel {
    var name: String = ""
    var age: Int = 0
}

@Bindable var profile: ProfileModel

TextField("Name", text: $profile.name)
```

### 1.9 @Published

用于 `ObservableObject` 内部，被标记的属性变化后会触发订阅视图刷新。

```swift
class ViewModel: ObservableObject {
    @Published var text: String = ""
}
```

## 2. 常用修饰符与样式

### 2.1 .clipShape 裁剪形状

`.clipShape` 本身最低支持 **iOS 13+**，传入不同 `Shape` 可以裁剪成不同形状。

| 形状 | 最低版本 | 简单用法 | 区别 |
| --- | --- | --- | --- |
| `Rectangle` | iOS 13+ | `.clipShape(Rectangle())` | 矩形裁剪，通常较少单独使用 |
| `RoundedRectangle` | iOS 13+ | `.clipShape(RoundedRectangle(cornerRadius: 12))` | 四个角圆角一致 |
| `Circle` | iOS 13+ | `.clipShape(Circle())` | 圆形，常用于头像 |
| `Ellipse` | iOS 13+ | `.clipShape(Ellipse())` | 椭圆，宽高不一致时更明显 |
| `Capsule` | iOS 13+ | `.clipShape(Capsule())` | 胶囊形，圆角自动等于短边一半 |
| 自定义 `Shape` | iOS 13+ | `.clipShape(MyShape())` | 自己控制裁剪路径 |
| `ContainerRelativeShape` | iOS 14+ | `.clipShape(ContainerRelativeShape())` | 跟随外层容器形状 |
| `UnevenRoundedRectangle` | iOS 16+ | `.clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 0, bottomTrailingRadius: 12, topTrailingRadius: 0))` | 四个角可以设置不同圆角 |
| `AnyShape` | iOS 16+ | `.clipShape(AnyShape(Circle()))` | 类型擦除，方便动态切换形状 |

```swift
Image("avatar")
    .frame(width: 80, height: 80)
    .clipShape(Circle())

Text("标签")
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .clipShape(Capsule())
```

### 2.2 暗黑模式

```swift
@Environment(\.colorScheme) var colorScheme

Text("This color is locally adaptive!")
    .foregroundColor(colorScheme == .light ? .green : .yellow)
```

### 2.3 图片充满固定比例容器

```swift
image
   .resizable()
   .scaledToFill()
   .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
   .aspectRatio(4 / 3, contentMode: .fit)
   .clipped()
```

## 3. 布局与尺寸

### 3.1 GeometryReader 读取父视图大小

```swift
struct MyView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("宽度: \(geometry.size.width)")
                Text("高度: \(geometry.size.height)")
            }
        }
    }
}
```

### 3.2 布局记录

待补充。

## 4. 动画与转场

### 4.1 transition 做类 sheet 动画

如果使用 `transition` 做类似 sheet 的动画，`dismiss` 时可能没有动画。可以包在 `ZStack` 中，并设置层级和偏移。

```swift
ZStack {
    // ...
}
.zIndex(2.0)
```

### 4.2 .animation

```swift
var body: some View {
    VStack {
        Button("Button") {
            isAnimated.toggle()
        }
        Spacer()
        RoundedRectangle(cornerRadius: isAnimated ? 50 : 25)
            .fill(isAnimated ? Color.red : Color.green)
            .animation(Animation.default.repeatForever(autoreverses: true))
            .frame(
                width: isAnimated ? 100 : 300,
                height: isAnimated ? 100 : 300
            )
            .rotationEffect(Angle(degrees: isAnimated ? 360 : 0))
            .offset(y: isAnimated ? 300 : 0)
        Spacer()
    }
}
```

### 4.3 withAnimation

```swift
var body: some View {
    ZStack(alignment: .bottom) {
        VStack {
            Button("BUTTON") {
                withAnimation(.easeInOut) {
                    showView.toggle()
                }
            }
            Spacer()
        }

        if showView {
            RoundedRectangle(cornerRadius: 30)
                .frame(height: UIScreen.main.bounds.height * 0.5)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom),
                    removal: AnyTransition.opacity.animation(.easeInOut)
                ))
        }
    }
    .edgesIgnoringSafeArea(.bottom)
}
```

## 5. 页面展示与关闭

### 5.1 present dismiss

```swift
@Environment(\.presentationMode) var presentationMode

presentationMode.wrappedValue.dismiss()
```

注意：不要在 `.sheet` 添加复杂逻辑操作。

## 6. UIKit 与 SwiftUI 互嵌

### 6.1 UIKit 中嵌入 SwiftUI：UIHostingController

```swift
import SwiftUI

struct SimpleSwiftUIView: View {
    var body: some View {
        VStack {
            Text("Hello from SwiftUI")
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
        }
        .padding()
    }
}

let vc = UIHostingController(rootView: SimpleSwiftUIView())
navigationController?.pushViewController(vc, animated: true)

let hostingVC = UIHostingController(rootView: MySwiftUIView())
addChild(hostingVC)
view.addSubview(hostingVC.view)
hostingVC.view.frame = view.bounds
hostingVC.didMove(toParent: self)
```

### 6.2 SwiftUI 中嵌入 UIKit 视图

```swift
let host = UIHostingController(rootView: SimpleSwiftUIView())
let swiftUIView = host.view!
swiftUIView.translatesAutoresizingMaskIntoConstraints = false

containerView.addSubview(swiftUIView)

NSLayoutConstraint.activate([
    swiftUIView.topAnchor.constraint(equalTo: containerView.topAnchor),
    swiftUIView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
    swiftUIView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
    swiftUIView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
])
```

### 6.3 SwiftUI 嵌入 UIKit：UIViewRepresentable

```swift
struct UIKitLabel: UIViewRepresentable {
    var text: String

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.textColor = .red
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
    }
}

var body: some View {
    UIKitLabel(text: "This is a UIKit Label")
        .frame(height: 50)
}
```

### 6.4 SwiftUI 嵌入 UIViewController：UIViewControllerRepresentable

```swift
import SwiftUI
import WebKit

struct WebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIViewController {
        let webView = WKWebView()
        let vc = UIViewController()
        vc.view = webView
        return vc
    }

    func updateUIViewController(_ vc: UIViewController, context: Context) {
        if let webView = vc.view as? WKWebView {
            webView.load(URLRequest(url: url))
        }
    }
}
```

### 6.5 UIKit 和 SwiftUI 双向通信

```swift
struct TextFieldWrapper: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.delegate = context.coordinator
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextFieldWrapper

        init(_ parent: TextFieldWrapper) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}

@State private var name = ""

TextFieldWrapper(text: $name)
Text("Entered: \(name)")
```

### 6.6 UIKit 和 SwiftUI 数据传递

#### 6.6.1 使用 Binding

```swift
struct MySwiftUIView: View {
    @Binding var text: String
}

let binding = Binding<String>(
    get: { text },
    set: { text = $0 }
)
```

#### 6.6.2 使用 ObservableObject

```swift
class ViewModel: ObservableObject {
    @Published var text: String = ""
}

@ObservedObject var vm: ViewModel

let vm = ViewModel()
let vc = UIHostingController(rootView: MySwiftUIView(vm: vm))
```

### 6.7 UIHostingConfiguration：iOS 16+

```swift
class SwiftUICell: UITableViewCell {}

struct CellContent: View {
    let text: String

    var body: some View {
        HStack {
            Text(text)
            Spacer()
        }
        .padding()
    }
}

cell.contentConfiguration = UIHostingConfiguration {
    CellContent(text: "Row \(indexPath.row)")
}
```

### 6.8 HostingView 封装

```swift
import Foundation
import SwiftUI
#if os(macOS)
public typealias PlatformViewType = NSView
#elseif !os(watchOS)
import UIKit
public typealias PlatformViewType = UIView
#endif

#if !os(watchOS)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
open class HostingView<Content> : PlatformViewType where Content : View {
    #if os(macOS)
    typealias HostingController = NSHostingController
    #else
    typealias HostingController = UIHostingController
    #endif
    private let hostingVC: HostingController<Content>
    public var rootView: Content {
        get { return hostingVC.rootView }
        set { hostingVC.rootView = newValue }
    }

    public init(rootView: Content) {
        self.hostingVC = HostingController(rootView: rootView)
        super.init(frame: .zero)
        addSubview(hostingVC.view)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingVC.view.topAnchor.constraint(equalTo: self.topAnchor),
            hostingVC.view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
```

### 6.9 UIHostingConfigurationBackport

```swift
import SwiftUI
import UIKit

public struct UIHostingConfigurationBackport<Content, Background>: UIContentConfiguration where Content: View, Background: View {
  let content: Content
  let background: Background
  let margins: NSDirectionalEdgeInsets
  let minWidth: CGFloat?
  let minHeight: CGFloat?

  public init(@ViewBuilder content: () -> Content) where Background == EmptyView {
    self.content = content()
    background = .init()
    margins = .zero
    minWidth = nil
    minHeight = nil
  }

  init(content: Content, background: Background, margins: NSDirectionalEdgeInsets, minWidth: CGFloat?, minHeight: CGFloat?) {
    self.content = content
    self.background = background
    self.margins = margins
    self.minWidth = minWidth
    self.minHeight = minHeight
  }

  public func makeContentView() -> UIView & UIContentView {
    return UIHostingContentViewBackport<Content, Background>(configuration: self)
  }

  public func updated(for state: UIConfigurationState) -> UIHostingConfigurationBackport {
    return self
  }

  public func background<S>(_ style: S) -> UIHostingConfigurationBackport<Content, _UIHostingConfigurationBackgroundViewBackport<S>> where S: ShapeStyle {
    return UIHostingConfigurationBackport<Content, _UIHostingConfigurationBackgroundViewBackport<S>>(
      content: content,
      background: .init(style: style),
      margins: margins,
      minWidth: minWidth,
      minHeight: minHeight
    )
  }

  public func background<B>(@ViewBuilder content: () -> B) -> UIHostingConfigurationBackport<Content, B> where B: View {
    return UIHostingConfigurationBackport<Content, B>(
      content: self.content,
      background: content(),
      margins: margins,
      minWidth: minWidth,
      minHeight: minHeight
    )
  }

  public func margins(_ insets: EdgeInsets) -> UIHostingConfigurationBackport<Content, Background> {
    return UIHostingConfigurationBackport<Content, Background>(
      content: content,
      background: background,
      margins: .init(insets),
      minWidth: minWidth,
      minHeight: minHeight
    )
  }

  public func margins(_ edges: Edge.Set = .all, _ length: CGFloat) -> UIHostingConfigurationBackport<Content, Background> {
    return UIHostingConfigurationBackport<Content, Background>(
      content: content,
      background: background,
      margins: .init(
        top: edges.contains(.top) ? length : margins.top,
        leading: edges.contains(.leading) ? length : margins.leading,
        bottom: edges.contains(.bottom) ? length : margins.bottom,
        trailing: edges.contains(.trailing) ? length : margins.trailing
      ),
      minWidth: minWidth,
      minHeight: minHeight
    )
  }

  public func minSize(width: CGFloat? = nil, height: CGFloat? = nil) -> UIHostingConfigurationBackport<Content, Background> {
    return UIHostingConfigurationBackport<Content, Background>(
      content: content,
      background: background,
      margins: margins,
      minWidth: width,
      minHeight: height
    )
  }
}

final class UIHostingContentViewBackport<Content, Background>: UIView, UIContentView where Content: View, Background: View {
  private let hostingController: UIHostingController<ZStack<TupleView<(Background, Content)>>?> = {
    let controller = UIHostingController<ZStack<TupleView<(Background, Content)>>?>(rootView: nil)
    controller.view.backgroundColor = .clear
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    return controller
  }()

  var configuration: UIContentConfiguration {
    didSet {
      if let configuration = configuration as? UIHostingConfigurationBackport<Content, Background> {
        hostingController.rootView = ZStack {
          configuration.background
          configuration.content
        }
        directionalLayoutMargins = configuration.margins
      }
    }
  }

  override var intrinsicContentSize: CGSize {
    var intrinsicContentSize = super.intrinsicContentSize
    if let configuration = configuration as? UIHostingConfigurationBackport<Content, Background> {
      if let width = configuration.minWidth {
        intrinsicContentSize.width = max(intrinsicContentSize.width, width)
      }
      if let height = configuration.minHeight {
        intrinsicContentSize.height = max(intrinsicContentSize.height, height)
      }
    }
    return intrinsicContentSize
  }

  init(configuration: UIContentConfiguration) {
    self.configuration = configuration

    super.init(frame: .zero)

    addSubview(hostingController.view)
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMoveToSuperview() {
    if superview == nil {
      hostingController.willMove(toParent: nil)
      hostingController.removeFromParent()
    } else {
      parentViewController?.addChild(hostingController)
      hostingController.didMove(toParent: parentViewController)
    }
  }
}

public struct _UIHostingConfigurationBackgroundViewBackport<S>: View where S: ShapeStyle {
  let style: S

  public var body: some View {
    Rectangle().fill(style)
  }
}

private extension UIResponder {
  var parentViewController: UIViewController? {
    return next as? UIViewController ?? next?.parentViewController
  }
}

cell.contentConfiguration = UIHostingConfigurationBackport(content: {
    HStack {
        Image(systemName: "star")
        Text("Favorites")
        Spacer()
    }
})
```

## 7. 调试与测试资源

### 7.1 测试 API

```text
dummyjson.com
```
