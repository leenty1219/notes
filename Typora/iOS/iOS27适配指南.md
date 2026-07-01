iOS27 适配

参考[文章](https://lrdcq.com/me/read.php/169.htm)

 **P0 致命｜UIKit Scene-based 生命周期强制**
 \- 影响：iOS 27 SDK 构建的 App 未迁移将**直接无法启动**，用户看到的是闪退。
 \- 必须操作：实现 ***UIWindowSceneDelegate\***，配置 ***UIApplicationSceneManifest\***，移除旧 window 初始化逻辑。
\- **P0 构建失败｜ld64 链接器完全移除**
 \- 影响：使用 ***-ld_classic\*** 的项目将编译失败，CI/CD 流水线中断。
 \- 必须操作：检查并移除所有 ***-ld_classic\*** 引用，升级依赖旧链接器的三方库。
\- **P0 构建失败｜Swift 依赖扫描器 Clang module 去重**
 \- 影响：同名 Clang module 将导致扫描报错，编译无法通过。
 \- 必须操作：排查并去除项目中重复的 ***module.modulemap\*** 声明。
\- **P1 功能影响｜NSURL 双重编码修复**
 \- 影响：如果代码中有针对双重编码的 workaround，现在可能导致 URL 解析异常。
 \- 必须操作：搜索项目中所有 URL 编码相关的 workaround 并评估是否需移除。
\- **P1 行为变更｜C++ multimap/multiset::find() 语义变化**
 \- 影响：不再保证返回首个等值元素，依赖此行为的代码将产生难以察觉的逻辑错误。
 \- 必须操作：将相关调用替换为 ***lower_bound\*** 或 ***equal_range\***。
\- **P1 功能废弃｜On Demand Resources 废弃**
 \- 影响：***NSBundleResourceRequest\*** 已废弃，后续版本可能完全移除。
 \- 必须操作：制定迁移计划，切换到 Background Assets 框架。
\- **P1 命名冲突｜System 框架 FilePath.stat() 新方法**
 \- 影响：自定义扩展中未限定的 ***stat()\*** 调用可能与新 API 冲突，导致编译错误。
 \- 必须操作：使用 ***Darwin.stat()\*** 显式限定或迁移到新 API。

**快速检查命令（在项目根目录执行）：**
\- 检查 Scene 迁移：`grep -r "var window: UIWindow" --include="\*.swift"\`
\- 检查 ld_classic：`grep -r "ld_classic" --include="\*.xcconfig" --include="\*.pbxproj"\`
\- 检查重复 module：*`find . -name "module.modulemap" | sort\*`
\- 检查 ODR 使用：`grep -r "NSBundleResourceRequest" --include="\*.swift" --include="\*.m"`



适配重复的分支**MMDI-19967**



## 1.工程适配

```objc
// 1、获取StatusBarHidden
[UIApplication sharedApplication].statusBarStyle
[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
[[UIApplication sharedApplication] statusBarFrame];
[[UIScreen mainScreen] applicationFrame];


// 2、相册相关的访问，目前还没完全展开
 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
 ALAuthorizationStatus authForPhoto = [ALAssetsLibrary authorizationStatus];

```



## 2.子工程