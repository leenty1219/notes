# SwiftUI 使用用例手册（iOS 15）

面向“现在要做一个界面，应该查哪个控件、怎么组合”的速查手册。示例以 **iOS 15** 为最低目标，默认使用 SwiftUI 原生 API；iOS 16/17 才提供的 API 不作为必要依赖。

> 以下代码片段通常放在 `View` 的属性或 `body` 中。模型示例可按项目需要拆分文件。项目最低系统版本设为 iOS 15 时，避免直接使用 `NavigationStack`、`Grid`、`presentationDetents`、`scrollContentBackground`、`ContentUnavailableView`、`@Observable`、`@Bindable` 等较新 API。

## 目录

- [1. 页面骨架与导航](#1-页面骨架与导航)
- [2. 文本、按钮与图标](#2-文本按钮与图标)
- [3. 输入控件与表单](#3-输入控件与表单)
- [4. 列表、网格与滚动](#4-列表网格与滚动)
- [5. 弹层、菜单与提示](#5-弹层菜单与提示)
- [6. 图片与加载状态](#6-图片与加载状态)
- [7. 布局、背景与装饰](#7-布局背景与装饰)
- [8. 手势、状态与动画](#8-手势状态与动画)
- [9. 数据请求与生命周期](#9-数据请求与生命周期)
- [10. 可访问性与常用环境值](#10-可访问性与常用环境值)
- [11. 控件场景速查](#11-控件场景速查)
- [12. iOS 15 与后续版本 API 对照](#12-ios-15-与后续版本-api-对照)

## 1. 页面骨架与导航

### 1.1 导航栏 + 列表 + 详情页

iOS 15 使用 `NavigationView` 和 `NavigationLink`。详情页需要导航标题时，标题修饰符放在目的页面上。

```swift
struct Article: Identifiable {
    let id: Int
    let title: String
    let summary: String
}

struct ArticleListView: View {
    private let articles = [
        Article(id: 1, title: "SwiftUI 布局", summary: "HStack、VStack 与 ZStack"),
        Article(id: 2, title: "状态管理", summary: "State 与 Binding")
    ]

    var body: some View {
        NavigationView {
            List(articles) { article in
                NavigationLink(destination: ArticleDetailView(article: article)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.title).font(.headline)
                        Text(article.summary).font(.subheadline).foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("文章")
        }
    }
}

struct ArticleDetailView: View {
    let article: Article

    var body: some View {
        Text(article.summary)
            .padding()
            .navigationTitle(article.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
```

### 1.2 工具栏按钮

```swift
NavigationView {
    Text("页面内容")
        .navigationTitle("设置")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") { save() }
            }
        }
}
```

`ToolbarItem` 的 placement 可按导航栏位置选择；iOS 15 常见值包括 `.navigationBarLeading`、`.navigationBarTrailing`、`.principal`。

### 1.3 Tab 页面

```swift
struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationView { HomeView() }
                .tabItem { Label("首页", systemImage: "house") }

            NavigationView { SettingsView() }
                .tabItem { Label("设置", systemImage: "gearshape") }
        }
    }
}
```

每个 Tab 使用自己的 `NavigationView`，可分别维护各自的导航栈。

## 2. 文本、按钮与图标

### 2.1 按钮和禁用状态

```swift
struct SaveButton: View {
    @State private var title = ""

    var body: some View {
        VStack(spacing: 12) {
            TextField("请输入标题", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: save) {
                Label("保存", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }

    private func save() { }
}
```

### 2.2 多行文本与截断

```swift
Text(articleBody)
    .lineLimit(3)
    .truncationMode(.tail)
```

需要按空间自适应时可以使用 `lineLimit(nil)`；避免给正文设过小的固定行数，影响动态字体和可访问性。

### 2.3 SF Symbols

```swift
Image(systemName: "heart.fill")
    .font(.system(size: 22, weight: .semibold))
    .foregroundColor(.pink)
```

纯装饰图标可使用 `.accessibilityHidden(true)`；承担含义的图标应提供文字标签，或和 `Label` 一起使用。

## 3. 输入控件与表单

### 3.1 表单设置页

```swift
struct PreferencesView: View {
    @State private var notificationsEnabled = true
    @State private var selectedLevel = "标准"
    private let levels = ["省电", "标准", "高性能"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("通知")) {
                    Toggle("接收通知", isOn: $notificationsEnabled)
                }

                Section(header: Text("画质")) {
                    Picker("画质等级", selection: $selectedLevel) {
                        ForEach(levels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                }
            }
            .navigationTitle("偏好设置")
        }
    }
}
```

### 3.2 登录表单、键盘类型与焦点提交

```swift
struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        Form {
            TextField("邮箱", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            SecureField("密码", text: $password)
                .textContentType(.password)
                .submitLabel(.done)
                .onSubmit(login)

            Button("登录", action: login)
                .disabled(email.isEmpty || password.isEmpty)
        }
    }

    private func login() { }
}
```

`textInputAutocapitalization`、`submitLabel` 和 `onSubmit` 均可用于 iOS 15。`@FocusState` 是 iOS 15 新增，可用于控制键盘焦点：

```swift
struct SearchField: View {
    @State private var query = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("搜索", text: $query)
            .focused($isFocused)
            .onAppear { isFocused = true }
    }
}
```

### 3.3 滑块、步进器与日期选择

```swift
struct PlaybackSettings: View {
    @State private var volume = 0.5
    @State private var repeatCount = 1
    @State private var reminderDate = Date()

    var body: some View {
        Form {
            Slider(value: $volume, in: 0...1) {
                Text("音量")
            }
            Stepper("重复次数：\(repeatCount)", value: $repeatCount, in: 1...10)
            DatePicker("提醒时间", selection: $reminderDate, in: Date()...)
        }
    }
}
```

`DatePicker` 可用 `displayedComponents: .date` 或 `.hourAndMinute` 限定选择内容。

## 4. 列表、网格与滚动

### 4.1 可删除和移动的列表

```swift
struct Todo: Identifiable {
    let id = UUID()
    var title: String
}

struct TodoListView: View {
    @State private var todos = [Todo(title: "检查邮件"), Todo(title: "整理笔记")]

    var body: some View {
        NavigationView {
            List {
                ForEach(todos) { todo in
                    Text(todo.title)
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            .navigationTitle("待办事项")
            .toolbar { EditButton() }
        }
    }

    private func delete(at offsets: IndexSet) { todos.remove(atOffsets: offsets) }
    private func move(from source: IndexSet, to destination: Int) {
        todos.move(fromOffsets: source, toOffset: destination)
    }
}
```

### 4.2 搜索列表

```swift
struct SearchableNamesView: View {
    @State private var query = ""
    private let names = ["小明", "小红", "小李"]

    private var results: [String] {
        guard !query.isEmpty else { return names }
        return names.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationView {
            List(results, id: \.self) { Text($0) }
                .navigationTitle("联系人")
                .searchable(text: $query, prompt: "搜索姓名")
        }
    }
}
```

`.searchable` 从 iOS 15 开始提供。搜索范围、建议和提交行为可通过 `searchScopes`、`suggestions`、`onSubmit(of: .search)` 扩展。

### 4.3 横向卡片列表

```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 12) {
        ForEach(0..<10) { index in
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.15))
                .frame(width: 150, height: 100)
                .overlay(Text("卡片 \(index + 1)"))
        }
    }
    .padding(.horizontal)
}
```

### 4.4 LazyVGrid 两列网格

```swift
struct PhotoGrid: View {
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<20) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(Text("\(index + 1)"))
                }
            }
            .padding()
        }
    }
}
```

`LazyVGrid`、`LazyHGrid` 在 iOS 14+ 可用；需要大量内容时优先使用懒加载容器。

### 4.5 下拉刷新

```swift
List(items) { item in
    Text(item.title)
}
.refreshable {
    await reload()
}
```

`.refreshable` 从 iOS 15 开始提供，闭包支持 `async`。刷新逻辑结束后系统会自动收起刷新指示器。

## 5. 弹层、菜单与提示

### 5.1 Sheet 展示编辑页面

```swift
struct ParentView: View {
    @State private var showingEditor = false

    var body: some View {
        Button("编辑资料") { showingEditor = true }
            .sheet(isPresented: $showingEditor) {
                EditorView()
            }
    }
}

struct EditorView: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Text("编辑内容")
                .navigationTitle("编辑")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") { presentationMode.wrappedValue.dismiss() }
                    }
                }
        }
    }
}
```

iOS 15 可用 `presentationMode` 关闭 sheet；`@Environment(\.dismiss)` 是 iOS 15 新增的简洁方式：

```swift
@Environment(\.dismiss) private var dismiss
// Button(action: { dismiss() }) { Text("关闭") }
```

### 5.2 全屏页面

```swift
@State private var showingOnboarding = false

Button("开始") { showingOnboarding = true }
    .fullScreenCover(isPresented: $showingOnboarding) {
        OnboardingView()
    }
```

### 5.3 Alert 确认操作

```swift
@State private var showingDeleteAlert = false

Button("删除", role: .destructive) { showingDeleteAlert = true }
    .alert("删除项目？", isPresented: $showingDeleteAlert) {
        Button("取消", role: .cancel) { }
        Button("删除", role: .destructive) { deleteItem() }
    } message: {
        Text("删除后无法恢复。")
    }
```

### 5.4 ConfirmationDialog 操作菜单

```swift
@State private var showingActions = false

Button("更多操作") { showingActions = true }
    .confirmationDialog("选择操作", isPresented: $showingActions, titleVisibility: .visible) {
        Button("分享") { share() }
        Button("删除", role: .destructive) { deleteItem() }
        Button("取消", role: .cancel) { }
    }
```

`confirmationDialog` 是 iOS 15 对应的 API；旧代码中常见名称 `ActionSheet` 已弃用。

### 5.5 ContextMenu 长按菜单

```swift
Text("长按此项")
    .contextMenu {
        Button { copyText() } label: {
            Label("复制", systemImage: "doc.on.doc")
        }
        Button(role: .destructive) { deleteItem() } label: {
            Label("删除", systemImage: "trash")
        }
    }
```

## 6. 图片与加载状态

### 6.1 AsyncImage 加载网络图片

```swift
AsyncImage(url: URL(string: imageURL)) { phase in
    switch phase {
    case .empty:
        ProgressView()
    case .success(let image):
        image.resizable().scaledToFill()
    case .failure:
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .foregroundColor(.secondary)
    @unknown default:
        EmptyView()
    }
}
.frame(width: 120, height: 120)
.clipShape(RoundedRectangle(cornerRadius: 12))
```

`AsyncImage` 从 iOS 15 开始提供。它适合基础加载和占位场景；复杂缓存、预取、重试需求见 [SwiftUI.md 的缓存策略](SwiftUI.md#8-asyncimage-缓存策略)。

### 6.2 本地图片裁剪

```swift
Image("landscape")
    .resizable()
    .scaledToFill()
    .frame(width: 160, height: 100)
    .clipped()
```

`scaledToFill` 可能超出目标区域，通常和固定 `frame`、`clipped()` 一起使用。

## 7. 布局、背景与装饰

### 7.1 常见布局容器

```swift
VStack(alignment: .leading, spacing: 12) {
    Text("标题").font(.title2)
    HStack {
        Text("说明")
        Spacer()
        Image(systemName: "chevron.right")
    }
}
.padding()
```

- `VStack`：纵向排列；`HStack`：横向排列；`ZStack`：前后叠放。
- `Spacer()`：占据可用空白，把相邻内容推向两侧。
- `Group`：组织视图，不创建额外布局容器。

### 7.2 卡片背景和边框

```swift
VStack(alignment: .leading, spacing: 8) {
    Text("订单状态").font(.headline)
    Text("配送中").foregroundColor(.secondary)
}
.padding()
.frame(maxWidth: .infinity, alignment: .leading)
.background(Color(.secondarySystemBackground))
.clipShape(RoundedRectangle(cornerRadius: 12))
.overlay {
    RoundedRectangle(cornerRadius: 12)
        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
}
```

### 7.3 安全区背景

```swift
ZStack {
    Color.blue.ignoresSafeArea()
    Text("内容仍位于安全区域内")
        .foregroundColor(.white)
}
```

尽量只让背景忽略安全区，避免正文被刘海、状态栏或 Home Indicator 遮挡。

### 7.4 自适应宽度与对齐

```swift
Text("靠左并占满可用宽度")
    .frame(maxWidth: .infinity, alignment: .leading)
```

`GeometryReader` 会参与布局并占用父视图提供的空间；仅为居中、等分或填充时，优先考虑 `frame`、`Spacer`、`HStack`、`VStack`。

## 8. 手势、状态与动画

### 8.1 点击展开内容

```swift
struct ExpandableRow: View {
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading) {
            Button {
                withAnimation(.easeInOut) { expanded.toggle() }
            } label: {
                HStack {
                    Text("详细信息")
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                }
            }
            .buttonStyle(PlainButtonStyle())

            if expanded {
                Text("这里展示更多说明内容。")
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
    }
}
```

### 8.2 拖动卡片

```swift
struct DraggableCard: View {
    @State private var offset = CGSize.zero

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.orange)
            .frame(width: 180, height: 120)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { offset = $0.translation }
                    .onEnded { _ in
                        withAnimation(.spring()) { offset = .zero }
                    }
            )
    }
}
```

### 8.3 动画 modifier 绑定状态变化

```swift
Circle()
    .fill(isSelected ? Color.green : Color.gray)
    .frame(width: isSelected ? 100 : 60, height: isSelected ? 100 : 60)
    .animation(.easeInOut(duration: 0.25), value: isSelected)
```

显式指定 `value:` 可限定触发动画的状态，适合 iOS 15；避免使用 iOS 17 才有的新式无参数 `.animation` 写法。

## 9. 数据请求与生命周期

### 9.1 ViewModel 加载列表

```swift
struct FeedItem: Decodable, Identifiable {
    let id: Int
    let title: String
}

@MainActor
final class FeedViewModel: ObservableObject {
    @Published private(set) var items: [FeedItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    func load() async {
        guard let url = URL(string: "https://example.com/feed") else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            items = try JSONDecoder().decode([FeedItem].self, from: data)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct FeedView: View {
    @StateObject private var model = FeedViewModel()

    var body: some View {
        Group {
            if model.isLoading {
                ProgressView()
            } else if let message = model.errorMessage {
                Text(message)
            } else {
                List(model.items) { item in Text(item.title) }
            }
        }
        .task { await model.load() }
    }
}
```

`.task` 和 Swift 并发的 `URLSession.data(from:)` 在 iOS 15 可用。真实项目还应处理 HTTP 状态码、取消、空数据和错误重试。

### 9.2 监听视图状态变化

```swift
.onChange(of: selectedTab) { newValue in
    analytics.trackTab(newValue)
}
```

`onChange(of:perform:)` 在 iOS 15 使用带一个新值参数的闭包形式。

## 10. 可访问性与常用环境值

### 10.1 合并控件标签

```swift
HStack {
    Image(systemName: "star.fill")
    Text("4.8 分")
}
.accessibilityElement(children: .combine)
```

对只有图标的按钮添加明确标签：

```swift
Button(action: close) {
    Image(systemName: "xmark")
}
.accessibilityLabel("关闭")
```

### 10.2 深色模式适配

```swift
@Environment(\.colorScheme) private var colorScheme

var body: some View {
    Text("自适应内容")
        .foregroundColor(colorScheme == .dark ? .white : .black)
}
```

优先使用系统语义色（如 `.primary`、`.secondary`、`Color(.systemBackground)`），只有需要特定表现时再手动判断 `colorScheme`。

### 10.3 安全区与尺寸类别

```swift
@Environment(\.verticalSizeClass) private var verticalSizeClass

var body: some View {
    Group {
        if verticalSizeClass == .compact {
            HStack { sidebar; content }
        } else {
            VStack { sidebar; content }
        }
    }
}
```

尺寸类别适合少量布局方向调整；更复杂的自适应布局可结合 `GeometryReader`，并考虑动态字体与横屏场景。

## 11. 控件场景速查

| 要实现的需求 | 优先查找 | iOS 15 注意点 |
| --- | --- | --- |
| 页面内纵向/横向排列 | `VStack` / `HStack` / `Spacer` | 简单布局不必先用 `GeometryReader` |
| 图层叠放 | `ZStack` / `overlay` / `background` | 区分覆盖内容与绘制背景 |
| 设置表单 | `Form` / `Section` / `Toggle` / `Picker` | 表单样式由系统管理 |
| 文本输入 | `TextField` / `SecureField` / `@FocusState` | 焦点管理从 iOS 15 可用 |
| 可编辑、可删除列表 | `List` / `ForEach` / `onDelete` / `onMove` | 使用稳定且唯一的 `Identifiable.id` |
| 大量网格数据 | `LazyVGrid` / `LazyHGrid` | Grid 容器从 iOS 14 可用 |
| 列表搜索 | `.searchable` | 从 iOS 15 可用 |
| 下拉刷新 | `.refreshable` | 从 iOS 15 可用，使用 async 闭包 |
| 导航推入 | `NavigationView` / `NavigationLink` | `NavigationStack` 是 iOS 16+ |
| 页面弹出 | `.sheet` / `.fullScreenCover` | 半屏 detents 是 iOS 16+ |
| 确认危险操作 | `.alert` / `.confirmationDialog` | iOS 15 使用新式 alert/dialog 闭包 API |
| 长按操作 | `.contextMenu` | 菜单操作要提供文字和明确语义 |
| 网络图片 | `AsyncImage` | iOS 15+；复杂缓存考虑专用加载器 |
| 页面加载请求 | `.task` + async/await | iOS 15+；避免在 `body` 直接发请求 |
| 状态驱动动画 | `withAnimation` / `.animation(_:value:)` | `value:` 形式适用于 iOS 15 |
| UIKit 视图嵌入 | `UIViewRepresentable` | ViewController 使用 `UIViewControllerRepresentable` |

## 12. iOS 15 与后续版本 API 对照

| API / 特性 | 最低版本 | iOS 15 项目做法 |
| --- | --- | --- |
| `NavigationStack` | iOS 16 | 使用 `NavigationView`、`NavigationLink` |
| `Grid` / `GridRow` | iOS 16 | 使用 `LazyVGrid` / `LazyHGrid` 或堆栈布局 |
| `.presentationDetents` | iOS 16 | 使用系统默认 `.sheet` 或 `.fullScreenCover` |
| `.scrollContentBackground` | iOS 16 | 用 `List`/`Form` 可用样式，或自定义 `ScrollView` |
| `UIHostingConfiguration` | iOS 16 | 用 `UIHostingController` 配合 cell containment |
| `ContentUnavailableView` | iOS 17 | 自行组合图标、标题、说明和操作按钮 |
| `@Observable` / `@Bindable` | iOS 17 | 使用 `ObservableObject`、`@Published`、`@StateObject`、`@ObservedObject` |
| 新式 `.animation { content in ... }` 等 | iOS 17 | 使用 `withAnimation` 或 `.animation(_:value:)` |

需要支持 iOS 15 及以上、同时在新系统采用新 API 时，使用 `if #available(iOS 16, *)` / `if #available(iOS 17, *)` 做运行时分支，并确认替代实现的交互一致。
