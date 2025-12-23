
[Github 教程地址](https://github.com/SwiftfulThinking/SwiftUI-Bootcamp)
## 1.修饰符

| 装饰器                | 所属类型                    | 谁持有       | 生命周期          | 适合场景       |
| ------------------ | ----------------------- | --------- | ------------- | ---------- |
| @State             | 值（struct）               | 视图本身      | 跟随视图          | 视图私有的小状态   |
| @Binding           | 引用（binding）             | 父持有，子引用   | 由原持有者决定       | 子视图需要修改父状态 |
| @StateObject       | ObservableObject（class） | 视图（首次创建）  | 视图首次创建后保持同一实例 | 视图拥有自己的 VM |
| @ObservedObject    | ObservableObject（class） | 外部持有，视图观察 | 由外部决定         | 父视图注入或共享对象 |
| @EnvironmentObject | ObservableObject        | 上层注入      | 注入点决定         | 全局/跨层级共享   |

### 1.1 @Bindable

属于 Swift 5.9 全新 Observation 系统，与 ObservableObject 不同。
```swift
@Observable
class ProfileModel {
    var name: String = ""
    var age: Int = 0
}

@Bindable var profile: ProfileModel

TextField("Name", text: $profile.name)

```


### 1.2 @Environment

全局共享的环境值，可以是自己传入的，也可能是系统传入

### 1.3 @State

用在 `struct View` 内保存 **视图私有**、轻量的可变状态（通常是值类型：Bool、String、Int、小结构体等）
- 视图“持有”并拥有这个状态（ownership）。
- SwiftUI 负责在状态改变时让视图重新渲染。
- 当视图被销毁，@State 的数据也会被释放。
- 不适合放大型/复杂/跨多个视图共享的状态
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

### 1.4 @Binding

在子视图中**不用持有**状态，但需要读写父视图提供的状态。相当于子视图拿到一个“引用”去修改父视图的 @State 或其他可绑定值。

- 不是存值，而是“引用”某个可绑定的值（父视图的 @State、@StateObject 的 published 属性、或者其他 Binding）。
- 子视图修改 binding，会反映到原始持有者并触发更新。

```swift
struct ParentView: View {
    @State private var isOn = false

    var body: some View {
        ToggleView(isOn: $isOn) // 传 binding
    }
}

struct ToggleView: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("开关", isOn: $isOn)
    }
}
```
### 1.5 @ObservedObject

在视图中观察一个遵循 `ObservableObject` 的类（引用类型），类里用 `@Published` 标记会触发视图刷新。适用于：视图**不负责**创建这个对象，通常由外部注入（父视图、环境或其他地方创建并传入）。

- 视图**不拥有**对象的生命周期；对象可能由父视图或外部创建并负责销毁。
- 当 `ObservableObject` 的 `@Published` 属性变化时，所有观察到它的视图会刷新。
- 如果你在视图里用 `@ObservedObject var vm = ViewModel()` 并不是最佳（会在 view reload 时重复创建）——更常见是外部注入或在列表 item 中使用（但注意复用问题）。
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
### 1.6 @StateObject

当视图**第一次**创建时初始化并**拥有**一个 `ObservableObject` 的实例（负责生命周期），且在视图的后续重新构建中保持同一实例。适用于：需要在视图内部创建 view model 并保证不会被重复创建的场景。

- 解决 `@ObservedObject var vm = ...` 在视图重建时重复创建的问题。
- 只在 iOS 14+ 使用（Xcode 12+），是为 view model 持有设计的。
- 对比：`@State` 持有值类型，`@StateObject` 持有引用类型的 ObservableObject。

```swift
class MyViewModel: ObservableObject {
    @Published var items = [String]()
}

struct MyView: View {
    @StateObject private var vm = MyViewModel() // 视图“拥有”vm

    var body: some View {
        List(vm.items, id: \.self) { Text($0) }
    }
}
```
### 1.7 @EnvironmentObject

在应用多个视图间**跨层级**共享状态。需要在某个上层视图使用 `.environmentObject(obj)` 注入，然后任何子视图用 `@EnvironmentObject` 读取。

- 适合应用级或跨很多层级需要的全局状态（例如用户会话、全局设置）。
- 如果没有在上层注入就使用，会导致运行时崩溃（缺少依赖）。
- 不要滥用，过多全局依赖会降低可测试性。

```swift
class AppState: ObservableObject {
    @Published var loggedIn: Bool = false
}

// 在根视图注入
ContentView().environmentObject(AppState())

// 子视图取用
struct MenuView: View {
    @EnvironmentObject var appState: AppState
    // ...
}
```

### 1.8 @Published


##  2.UIKit和SwiftUI互相嵌入使用
### 2.1在UIKit 中嵌入 SwiftUI（UIHostingController）
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

// 使用
let vc = UIHostingController(rootView: SimpleSwiftUIView())
navigationController?.pushViewController(vc, animated: true)
```
### 2.2.在SwiftUI中嵌入UIKit
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
### 2.3 iOS16直接使用
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
### 2.4 在SwiftUI 嵌入 UIKit - UIViewRepresentable
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
### 2.5 SwiftUI 嵌入 UIViewController（UIViewControllerRepresentable）
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
### 2.6双向通信
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
## 3.present dismiss
```swift
@Environment(\.presentationMode) var presentationMode

presentationMode.warppedValue.dismiss()

// ⚠️不要在 .sheet 添加逻辑操作

// 如果使用transition来做动画的话

```

## 4动画
如果使用`transition`来做类似 sheet 动画的话，可能在`dismiss`的时候没有动画。此时需要吧它包装在一个`ZStack`里面，同时记得设置v的偏移量
```swift
ZStack{

.....

}.zIndex(2.0)

// 使用 .animation()
var body: some View {

	VStack {
	
		Button("Button") {
			isAnimated.toggle()
		}
		Spacer()
		RoundedRectangle(cornerRadius: isAnimated ? 50 : 25)
	
			.fill(isAnimated ? Color.red : Color.green)
			.animation(Animation
						.default
						.repeatForever(autoreverses: true))
			.frame(
				width: isAnimated ? 100 : 300,
				height: isAnimated ? 100 : 300)
			.rotationEffect(Angle(degrees: isAnimated ? 360 : 0))
			.offset(y: isAnimated ? 300 : 0)
		Spacer()
	}
}

// 使用withAnimation
var body: some View {

	ZStack(alignment: .bottom) {
		VStack {
			Button("BUTTON") {
				withAnimation(.easeInOut) { // <- animation here
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


## 5 测试api
`dummyjson.com`
 