## 1.修饰符
### 1.1 @Bindable
### 1.2 @Environment

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