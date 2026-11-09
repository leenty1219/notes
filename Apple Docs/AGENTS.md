# Apple Docs(本地,来自 Xcode 与 Dash)

离线的 Apple 开发者文档,仅含 iOS/iPadOS。两部分来源:

- Swift 页面:`/System/Library/AssetsV2/com_apple_MobileAsset_AppleDeveloperDocumentation`(Xcode 自带的文档资源,与 Xcode 的 DocumentationSearch 同源)。
- Objective-C 页面:Dash 的 `Apple API Reference` docset(同一批 Apple DocC 数据的 occ 版本)。

文档版本用 `./adoc info` 查看。

## 查询

```
./adoc search viewdidload              # 名称搜索:支持驼峰拆分、子串、拼写容错
./adoc search "uiview animate"         # 多个词:每个词都要出现在标题或路径中
./adoc search label -f uikit -n 10     # 限定 framework
./adoc search "background task" --text # 正文全文搜索
./adoc show uikit/uilabel/numberoflines
./adoc objc foundation/nsstring        # Objective-C 文档(本地优先)
./adoc info
```

- `show` 接收 `search` 输出的 key(`/documentation/` 之后的小写路径),也接受完整的 `developer.apple.com/documentation/...` 链接。
- 搜索结果中类型排在成员之前。搜 `string` 会同时返回 Swift `String` 和 `NSString`。
- 页面为 Markdown。文章的小节已合并进所属页面,以 `##` 标题呈现。
- 搜索同时覆盖 Objective-C 名称。命中 OC 名称时,结果下方多一行 `Objective-C: <选择器>` 给出对应关系。

## 范围与限制

- 仅 iOS/iPadOS:页面自身平台列表含 iOS 或 iPadOS 即保留;没有平台信息的页面继承所属 framework 根页面。
- 不导入 HIG(`/design`)和教程(`/tutorials`)。
- 页面 164,675 个:Swift 页面 90,628 个,只有 Objective-C 的页面 74,047 个(如 `NSInvocation`);Objective-C 版本 125,209 个。
- 图片、视频、示例工程文件没有。

## Objective-C

- Objective-C 文档已在本地库,不再需要联网确认签名和选择器名,直接 `./adoc objc <key>`。key 与 `show` 相同。
- Swift 与 OC 方法名不同(例如 Swift 的 `appending(_:)` 对应 OC 的 `stringByAppendingString:`),不要凭 Swift 声明推测 OC 写法,查库。

```
./adoc objc foundation/nsstring/appending\(_:\)   # - (NSString *) stringByAppendingString:(NSString *) aString;
./adoc objc foundation/nsstring                   # 类声明、讨论、成员列表(OC 名称 [对应的 Swift key])
./adoc objc foundation/nsinvocation               # 只有 OC 的页面,show 与 objc 都可用
```

- 成员列表里方括号内是该成员的 Swift key,可直接用于 `show` 和 `objc`。
- 本地没有该页的 OC 版本时,`objc` 自动联网取一次并在 stderr 提示;加 `--offline` 则只查本地,查不到直接报错。`objc` 输出与 `show` 一致,均为 Markdown。
- 只有 OC 的页面,`show` 头部标注 `Objective-C only`。
- 常见选择器也可直接 `search`(如 `./adoc search stringByAppendingString`),不需要先知道 Swift 名。
- 本地库没有的 API(超出 iOS 范围,如 `appkit/nsview`)仍然会联网。

## 更新规则

- 只能手动更新,由用户在需要时触发:
  - `./adoc import`:重新读取 Xcode 资源,按内容哈希增量合并(记录在 `changes` 表)。Xcode 升级后执行。
  - `./adoc import-oc`:重新从 Dash docset 导入 Objective-C 页面(会先清空原 OC 数据再全量重建索引)。
- 两部分的 scope 独立:Xcode 导入只碰 `lang='swift'` 的页面,Dash 导入只碰 OC 页面和 `lang='oc'` 的页面;两边都有的页面共用一条 `pages` 记录。
- AI 可以随意查询。修改数据或工具必须经用户同意。Apple 文档视为正确,不由 AI 判定对错。
- 源资源以只读(`immutable=1`)方式打开,不得写入。不得修改 Dash 自己的 docset 目录。

## 实现说明

- `data/docs.db`(SQLite,约 310 MB,可重新生成,不提交 git):
  - `pages` 元数据(`lang` 为 `swift` 或 `oc`)、`bodies` 存 Swift 页面的 zlib 压缩 Markdown、`oc_pages` 存 OC 页面 Markdown(id 与 `pages.id` 相同)、`names_fts`(trigram,一个页面可有多行名称,Swift 名与 OC 名各一行)、`text_fts`(FTS5)、`changes`。
  - `search` 与 `show` 对两类页面统一处理:`show` 在 `bodies` 无记录时读 `oc_pages`。
- Python 自带的 SQLite(3.35)打不开 Xcode 源库里的 `STRICT` 表,所以 `import` 先用 `/usr/bin/sqlite3` 把需要的行复制到临时文件再合并。
- `import-oc` 直接读 Dash docset:`Contents/Resources/Documents/cache.db` 的 `refs` 表给出分片(`data_id`/`offset`/`length`),分片落在 `Contents/Resources/Documents/fs/<data_id>` 的 brotli 流里,解压后按偏移切片即为单页 DocC JSON。需要 `brotli` 模块。
- Dash 的 docset 是 Apple DocC 数据的镜像,内容等同于 `developer.apple.com`;Dash 应用本身是第三方构建,不作为可信来源引用,只读它的数据文件。
