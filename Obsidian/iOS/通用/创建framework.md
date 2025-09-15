## 1. 使用FrameWork模版创建

选择`Xcode`-`File`-`New` 在模版中选择FrameWork

![image.png](attachment:11aaf9f7-814d-4554-a050-111507e6ab66:image.png)

## 2. 项目配置

在生成文件类型上选择`静态库`/`动态库` _自己创建的动态库不能和别的app共用。_

![image.png](attachment:ae5ef626-a579-433e-8f4e-47526a21e962:image.png)

根据要使用的目标设备选择编译SDK：`Build Setting` - `Architectures` - `Base SDK`

![image.png](attachment:ab08984c-4b4d-4d1e-9aee-be7d579ff7f5:image.png)

## 3. 选择需要公开的头文件

将需要公开的头文件，拖动到`Build Phases` - `Headers`-`public`中

将需要公开的头文件在`SVLog.h` （Framework 同名文件，默认生成的）中引用

![image.png](attachment:7e50a22f-d00e-4737-b513-61409cb8419b:image.png)

![image.png](attachment:6dc17e22-0db3-437a-beb7-1c8dc480aeba:image.png)

## 4. 配置Run模式

在Scheme配置中将Run模式修改为`Release`

此时已经能够跑出framework了，但是仅支持真机/模拟器

注意：默认的地址在xcode `DerivedData/…` 文件下。

可以添加脚本来配置生成文件路径：

```bash
# 设置目标路径（项目根目录下的 Frameworks 文件夹）
TARGET_PATH="${PROJECT_DIR}/Frameworks"
# 创建目标文件夹（如果不存在）
mkdir -p "$TARGET_PATH"
# 拷贝生成的 framework
cp -R "${BUILT_PRODUCTS_DIR}/${FULL_PRODUCT_NAME}" "$TARGET_PATH"
```

> 需要注意的是，可能会遇到沙盒错误

> 在`Target` - `BuildSetting` - `Build Options` - `User Script Sandboxing` 下修改为`NO`

## 5. 聚合模拟器&真机

添加新的`Target` 类型选择 `Aggregate`

![image.png](attachment:571782c0-c42b-4118-a3f4-54dc96606fda:image.png)

在`Build Phases`中添加编译依赖

![image.png](attachment:2be148e2-17fd-43ca-b1e9-cf5607cb1d08:image.png)

添加编译脚本

```bash
# 目标输出路径
OUTPUT_DIR="${PROJECT_DIR}/Output"
FRAMEWORK_NAME="SVLogs" # 修改为自己的framework名称

# 清理上次生成
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# 生成 iOS (真机) framework
xcodebuild archive \\
  -scheme "${FRAMEWORK_NAME}" \\
  -configuration Release \\
  -sdk iphoneos \\
  -archivePath "$OUTPUT_DIR/ios_devices.xcarchive" \\
  SKIP_INSTALL=NO \\
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# 生成 iOS Simulator framework
xcodebuild archive \\
  -scheme "${FRAMEWORK_NAME}" \\
  -configuration Release \\
  -sdk iphonesimulator \\
  -archivePath "$OUTPUT_DIR/ios_simulators.xcarchive" \\
  SKIP_INSTALL=NO \\
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# 合并为 XCFramework
xcodebuild -create-xcframework \\
  -framework "$OUTPUT_DIR/ios_devices.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \\
  -framework "$OUTPUT_DIR/ios_simulators.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \\
  -output "$OUTPUT_DIR/${FRAMEWORK_NAME}.xcframework"

echo "✅ XCFramework 打包完成：$OUTPUT_DIR/${FRAMEWORK_NAME}.xcframework"
```

## 6. Other

`Build Libraries for Distribution` 这个配置： 为你的 Framework 生成可供他人安全使用的**模块接口**与**二进制描述**，使其具备“官方 SDK”一样的发布能力

**苹果推荐开启**

- 关闭时，只适合：
    - 库仅用于**内部项目**；
    - 不需要模块化发布；
    - 编译环境一致（Swift版本、架构一致）。
- 开启后：
    - 生成**模块接口描述文件**；
    - 支持**跨项目、跨模块、跨编译器**版本使用；
    - Swift 模块具备**二进制兼容性**；
    - 支持其他项目以模块化方式导入，成为真正意义上的**可分发 SDK**。