# pi 用法速查

> 只记用法，方便使用时快速查询。启动：`pi`（交互模式）。

---

## 一、启动与模式

```bash
pi                          # 交互模式（默认）
pi "列出 src/ 下所有 .ts 文件"   # 交互 + 初始提示
pi -p "总结这个代码库"          # 打印模式，输出后退出
cat README.md | pi -p "总结这段文字"   # 打印模式读取管道 stdin
pi --mode json              # JSON 事件流模式
pi --mode rpc               # RPC 模式（进程集成）
```

---

## 二、会话

```bash
pi -c                      # 继续最近的会话
pi -r                      # 浏览并选择历史会话
pi --no-session            # 临时模式（不保存）
pi --name "任务名"          # 启动时设置会话名
pi --session <path|id>     # 打开指定会话（文件或部分 ID）
pi --fork <path|id>        # 派生指定会话为新会话
pi --session-dir <dir>     # 自定义会话存储目录
```

**交互模式内会话命令**：

| 命令 | 作用 |
|------|------|
| `/resume` | 浏览选择历史会话 |
| `/new` | 新建会话 |
| `/name <名字>` | 设置会话显示名 |
| `/session` | 查看会话文件/ID/消息数/token/费用 |
| `/tree` | 导航会话树（回到任意节点继续）|
| `/fork` | 从之前的用户消息派生新会话 |
| `/clone` | 复制当前活动分支到新会话 |
| `/compact [指令]` | 手动压缩上下文 |
| `/export [file]` | 导出会话为 HTML/JSONL |
| `/import <file>` | 从 JSONL 导入并恢复会话 |
| `/share` | 上传为私有 gist 生成分享链接 |

### `/tree` 会话树详解

**是什么**：pi 把会话存成**树结构**（JSONL，每个条目有 `id` + `parentId`），`/tree` 让你在**同一个文件内**回到任意历史节点继续，或在多个分支间切换，完整历史都保留、**不新建文件**。

**打开方式**：`/tree`，或 `Escape` 连按两次（可设 `doubleEscapeAction`）。

树形示例：

```
├─ 用户："帮我实现登录"
│  └─ 助手："好的……"
│     ├─ 用户："方案 A"
│     │  └─ 助手："方案 A 的做法……"
│     │     └─ 用户："可行"  ← 当前活动叶子
│     └─ 用户："还是用方案 B"
│        └─ 助手："方案 B 的做法……"
```

**操作按键**：

| 按键 | 动作 |
|------|------|
| `↑` / `↓` | 在可见条目间移动 |
| `←` / `→` | 翻页 |
| `Ctrl+←/→` 或 `Alt+←/→` | 折叠/展开当前分支段，或在分支段之间跳转 |
| 直接输入文字 | 搜索过滤 |
| `Enter` | 选中当前条目 |
| `Escape` / `Ctrl+C` | 取消 |
| `Ctrl+X` | 复制选中消息 |
| `Shift+L` | 给选中条目打标签（书签）/ 清除标签 |
| `Shift+T` | 切换是否显示标签时间戳 |

**过滤模式**（隐藏工具结果等，让树更清晰）：

| 模式 | 显示内容 | 按键 |
|------|----------|------|
| default | 默认视图 | `Ctrl+D` |
| no-tools | 隐藏工具结果 | `Ctrl+T` |
| user-only | 只显示用户消息 | `Ctrl+U` |
| labeled-only | 只显示打了标签的条目 | `Ctrl+L` |
| all | 显示所有条目 | `Ctrl+A` |
| （循环切换）| 依次切换以上模式 | `Ctrl+O` 前进 / `Shift+Ctrl+O` 后退 |

**选中条目的行为**（决定“从哪继续”）：

| 选中的条目类型 | 结果 |
|----------------|------|
| **用户/自定义消息** | 叶子移到该消息的父节点，消息文本**放回编辑器**，可修改后重新提交 → 产生新分支 |
| **助手/工具/压缩等条目** | 叶子移到该条目，编辑器为空，**从该点继续** |
| **根用户消息** | 重置到空对话，原提示放回编辑器 |

**分支摘要**：用 `/tree` 从一个分支切到另一个分支时，pi 可**总结被放弃的分支**并把摘要附到新位置，保留离开那条线的上下文（不会重放整条分支）。可选手动指令。

**标签**：`Shift+L` 打标签后，可在树里过滤、定位重要节点；也可用扩展 API `pi.setLabel()` 设置。

**`/tree` vs `/fork` vs `/clone`**：

| 功能 | `/tree` | `/fork` | `/clone` |
|------|---------|---------|----------|
| 输出 | 同一会话文件 | 新会话文件 | 新会话文件 |
| 视图 | 完整树 | 用户消息选择器 | 当前活动分支 |
| 典型用途 | 在原文件内探索备选方案 | 从更早的某条提示另起新会话 | 复制当前工作后再继续 |
| 摘要 | 可选分支摘要 | 无 | 无 |

> 想保留多个方案放在一起用 `/tree`；想单独一个文件用 `/fork` 或 `/clone`。

---

## 三、编辑器操作

| 操作 | 按键 |
|------|------|
| 引用文件 | 输入 `@` 模糊搜索 |
| 路径补全 | `Tab` |
| 多行输入 | `Shift+Enter`（Windows Terminal 用 `Ctrl+Enter`）|
| 外部编辑器 | `Ctrl+G` |
| 粘贴图片/文本 | `Ctrl+V`（Windows 用 `Alt+V`），或拖图片进终端 |
| 执行命令并发给模型 | `!命令` |
| 执行命令**不**发给模型 | `!!命令` |

---

## 四、快捷键

| 按键 | 动作 |
|------|------|
| `Ctrl+C` | 清空编辑器（连按两次退出）|
| `Escape` | 取消/中止（连按两次打开 `/tree`）|
| `Ctrl+L` | 打开模型选择器 |
| `Ctrl+P` / `Shift+Ctrl+P` | 循环切换 scoped models |
| `Shift+Tab` | 循环切换思考等级 |
| `Ctrl+S` | 在模型/思考选择器里保存为默认 |
| `Ctrl+O` | 折叠/展开工具输出 |
| `Ctrl+T` | 折叠/展开思考块 |
| `Ctrl+X` | 复制最后一条助手消息 |
| `Ctrl+D` | 编辑器为空时退出 |

**消息队列**（agent 工作时发消息）：

| 按键 | 作用 |
|------|------|
| `Enter` | 排队 steering 消息（当前轮工具执行完投递）|
| `Alt+Enter` | 排队 follow-up 消息（所有工作完成后投递）|
| `Escape` | 中止并恢复排队消息 |
| `Alt+Up` | 取回排队消息到编辑器 |

---

## 五、模型与思考等级

```bash
# 命令行动态指定
pi --provider openai --model gpt-4o "帮我重构"
pi --model openai/gpt-4o "帮我重构"        # 带 provider 前缀，无需 --provider
pi --model sonnet:high "解这道复杂题"       # 模型:思考等级 简写
pi --thinking high "解这道复杂题"           # 单独指定思考等级
pi --models "claude-*,gpt-4o"              # 限制 Ctrl+P 循环的模型
pi --list-models [搜索词]                   # 列出可用模型
```

**交互模式内**：`/model` 或 `Ctrl+L` 切模型，`/thinking` 或 `Shift+Tab` 切思考等级。

**思考等级**：`off` → `minimal` → `low` → `medium` → `high` → `xhigh` → `max`

**认证**：`/login` 选订阅或存 API key；`/logout` 清除；或用环境变量（如 `ANTHROPIC_API_KEY`、`OPENAI_API_KEY`、`GEMINI_API_KEY`）。

---

## 六、工具控制

```bash
pi --tools read,grep,find,ls -p "审查代码"   # 只读白名单
pi --exclude-tools 某工具名                  # 禁用指定工具
pi --no-builtin-tools                        # 禁用内置工具（保留扩展工具）
pi --no-tools                                # 禁用所有工具
```

内置工具：`read`、`write`、`edit`、`bash`、`grep`、`find`、`ls`、`powershell`(Windows)。

---

## 七、引用文件与管道

```bash
pi @prompt.md "回答这个"
pi -p @截图.png "图里有什么？"
pi @code.ts @test.ts "一起审查这两个文件"
pi -p -- "- 总结这些要点"   # 提示以短横线开头时用 -- 分隔
```

---

## 八、上下文文件（AGENTS.md）

启动时自动加载 `AGENTS.md`/`CLAUDE.md`：全局 `~/.pi/agent/AGENTS.md` + 父目录 + 当前目录。

- 目录含 `AGENTS.override.md` 时用它**替代**该目录的 `AGENTS.md`/`CLAUDE.md`。
- 禁用上下文文件加载：`--no-context-files` / `-nc`。加这个参数启动时 pi 就**不读取**任何 `AGENTS.md`/`CLAUDE.md`（全局、父目录、当前目录的都不读）。适合想完全不带项目说明、干净地跑一次的场景。
- 改后 `/reload` 或重启生效。
- 替换系统提示：`.pi/SYSTEM.md`（项目）/ `~/.pi/agent/SYSTEM.md`（全局）；追加用 `APPEND_SYSTEM.md`。

```markdown
# 项目约定
- 改完代码运行 npm run check
- 不要在生产环境跑迁移
```

---

## 九、定制资源

| 类型 | 用法 | 位置 |
|------|------|------|
| 提示模板 | 输入 `/模板名` 展开（带参数 `$1`、`$@`）| `~/.pi/agent/prompts/`、`.pi/prompts/` |
| 技能 | `/skill:名字` 或让模型自动加载 | `~/.pi/agent/skills/`、`.pi/skills/`、`.agents/skills/` |
| 扩展 | 自定义工具/命令/UI | `~/.pi/agent/extensions/`、`.pi/extensions/` |
| 主题 | `/settings` 或 settings.json `"theme"` | `~/.pi/agent/themes/`、`.pi/themes/` |

**CLI 临时加载资源**（不写入设置）：

```bash
pi -e ./my-extension.ts            # 加载扩展（可重复）
pi --skill ./my-skill              # 加载技能
pi --prompt-template ./t.md        # 加载模板
pi --theme ./t.json                # 加载主题
pi --no-extensions -e ./only.ts    # 精确只加载这一个
pi --use-theme light               # 本次运行用指定主题
```

**模板参数示例**：`$1` `$2` 位置参数、`$@`/`$ARGUMENTS` 全部参数、`${1:-默认}`、`${@:N}`、`${@:N:L}`。

---

## 十、自定义扩展（Extensions）

用 TypeScript 写模块，给 pi 加**自定义工具、命令、快捷键、事件拦截、UI**。

### 放置位置

| 位置 | 作用域 |
|------|--------|
| `~/.pi/agent/extensions/*.ts` | 全局 |
| `~/.pi/agent/extensions/*/index.ts` | 全局（子目录）|
| `.pi/extensions/*.ts` | 项目 |
| `.pi/extensions/*/index.ts` | 项目（子目录）|

- 快速测试不写入设置：`pi -e ./my-extension.ts`
- 自动发现的位置可用 `/reload` 热重载

### 最小示例

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function (pi: ExtensionAPI) {
  // 事件：拦截危险命令
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName === "bash" && event.input.command?.includes("rm -rf")) {
      const ok = await ctx.ui.confirm("危险！", "允许 rm -rf？");
      if (!ok) return { block: true, reason: "被用户阻止" };
    }
  });

  // 注册 LLM 可调用的工具
  pi.registerTool({
    name: "greet",
    description: "向某人问好",
    parameters: Type.Object({ name: Type.String() }),
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      return { content: [{ type: "text", text: `你好，${params.name}！` }] };
    },
  });

  // 注册斜杠命令
  pi.registerCommand("hello", {
    description: "打招呼",
    handler: async (args, ctx) => {
      ctx.ui.notify(`你好 ${args || "world"}！`, "info");
    },
  });
}
```

### 核心 API 速查

| 方法 | 作用 |
|------|------|
| `pi.on(event, handler)` | 订阅事件 |
| `pi.registerTool(def)` | 注册 LLM 可调用的工具 |
| `pi.registerCommand(name, opts)` | 注册 `/命令` |
| `pi.registerShortcut("ctrl+x", {handler})` | 注册快捷键 |
| `pi.registerFlag("name", {type, default})` | 注册 CLI 参数 |
| `pi.sendMessage()` / `pi.sendUserMessage()` | 注入消息 |
| `pi.appendEntry(type, data)` | 持久化扩展数据（不进 LLM 上下文）|
| `pi.setSessionName()` / `pi.setLabel()` | 设置会话名 / 打标签 |
| `pi.setModel()` / `pi.setThinkingLevel()` | 切模型 / 思考等级 |
| `pi.exec(cmd, args, opts)` | 执行 shell 命令 |
| `pi.getActiveTools()` / `setActiveTools()` | 管理启用的工具 |
| `pi.registerProvider(name, config)` | 注册模型 provider |
| `pi.events` | 扩展间事件总线 |

### 常用事件

| 事件 | 触发时机 / 用途 |
|------|----------------|
| `session_start` / `session_shutdown` | 会话启动 / 销毁（清理资源）|
| `input` | 用户输入时，可 transform/handled |
| `tool_call` | 工具执行前，**可 block** |
| `tool_result` | 工具执行后，可改结果 |
| `user_bash` | 用户 `!`/`!!` 命令，可拦截 |
| `before_agent_start` | 可注入消息 / 改系统提示 |
| `turn_start` / `turn_end` | 每轮开始 / 结束 |
| `model_select` / `thinking_level_select` | 模型 / 思考等级变化 |
| `session_before_switch` / `session_before_fork` | 切换 / 派生会话前，可取消 |
| `session_before_compact` / `session_before_tree` | 压缩 / 树导航前，可自定义 |

### ctx 常用

| 成员 | 作用 |
|------|------|
| `ctx.ui.select/confirm/input/editor/notify` | 对话框与通知 |
| `ctx.ui.setStatus/setWidget/setFooter/custom` | 状态栏 / 组件 / 页脚 / 自定义 UI |
| `ctx.cwd` / `ctx.mode` / `ctx.hasUI` | 工作目录 / 模式 / 是否有 UI |
| `ctx.sessionManager` | 只读会话状态 |
| `ctx.signal` | AbortSignal（中止感知）|
| `ctx.isIdle()` / `ctx.abort()` / `ctx.shutdown()` | 控制流 |
| `ctx.compact()` / `ctx.reload()` | 触发压缩 / 重载 |

### 工具定义要点

- 参数 schema 用 TypeBox；字符串枚举用 `StringEnum`（不要用 `Type.Union`，Google API 不支持）。
- `execute` 里**抛异常** = 报错给 LLM（`isError: true`）；返回 `terminate: true` = 提前结束本轮。
- 输出要截断（上限 50KB / 2000 行），用 `truncateHead` / `truncateTail`。
- 改文件用 `withFileMutationQueue()` 加入队列，避免并行工具互相覆盖。
- 覆盖内置工具：注册同名工具即可（如 `read`）。

### 用户交互对话框

```typescript
const c = await ctx.ui.select("选一个:", ["A", "B", "C"]);
const ok = await ctx.ui.confirm("删除？", "不可撤销");
const name = await ctx.ui.input("名字:", "占位符");
const text = await ctx.ui.editor("编辑:", "预填内容");
ctx.ui.notify("完成！", "info");   // info | warning | error
```

> 官方示例在 `docs/examples/extensions/`（权限门禁、Git 检查点、SSH、子代理、计划模式等都有现成实现）。

---

## 十一、包管理

```bash
pi install npm:@foo/bar            # 装包
pi install git:github.com/user/repo
pi install https://github.com/user/repo@v1
pi remove npm:@foo/bar             # 卸载
pi list                            # 列出已装包
pi config                          # 启用/禁用扩展、技能、提示、主题
pi update                          # 更新 pi
pi update --all                    # 更新 pi 和所有包
pi update --extensions             # 只更新包
pi update --models                 # 只刷新模型目录
pi update --self                   # 只更新 pi
```

- `-l` 参数：装到项目本地（`.pi/`），默认装到全局。
- 临时试用不安装：`pi -e npm:@foo/bar`。

---

## 十二、常用设置（settings.json）

位置：`~/.pi/agent/settings.json`（全局）、`.pi/settings.json`（项目，覆盖全局）。

```json
{
  "defaultProvider": "anthropic",
  "defaultModel": "claude-sonnet-4-20250514",
  "defaultThinkingLevel": "medium",
  "theme": "dark",
  "enabledModels": ["claude-*", "gpt-4o"],
  "defaultTools": ["bash", "edit", "write"],
  "compaction": { "enabled": true, "reserveTokens": 16384, "keepRecentTokens": 20000 },
  "httpProxy": "http://127.0.0.1:7890",
  "packages": ["pi-skills"]
}
```

常用键：`defaultProvider` / `defaultModel` / `defaultThinkingLevel` / `theme` / `enabledModels` / `defaultTools` / `compaction` / `sessionDir` / `externalEditor` / `httpProxy` / `steeringMode` / `followUpMode` / `transport` / `packages` / `extensions` / `skills` / `prompts` / `themes`。

---

## 十三、环境变量速查

| 变量 | 作用 |
|------|------|
| `PI_OFFLINE=1` | 禁用所有启动网络操作 |
| `PI_SKIP_VERSION_CHECK=1` | 跳过版本检查 |
| `PI_CODING_AGENT_DIR` | 覆盖配置目录（默认 `~/.pi/agent`）|
| `PI_CODING_AGENT_SESSION_DIR` | 覆盖会话目录 |
| `HTTP_PROXY` / `HTTPS_PROXY` | 代理 |
| `PI_CACHE_RETENTION=long` | 延长提示缓存 |
| `ANTHROPIC_API_KEY` 等 | 各 provider 的 API key |

**bash 工具内可用变量**：`PI_SESSION_ID`、`PI_SESSION_FILE`、`PI_PROVIDER`、`PI_MODEL`、`PI_REASONING_LEVEL`（判断当前模型时查这些，别靠系统提示猜）。

---

## 十四、其他

| 选项 | 作用 |
|------|------|
| `-a` / `--approve` | 本次运行信任项目本地文件 |
| `-na` / `--no-approve` | 本次运行忽略项目本地文件 |
| `--system-prompt <文本>` | 替换系统提示 |
| `--append-system-prompt <文本>` | 追加系统提示 |
| `--tui-mode fullscreen` | 全屏 TUI（实验）|
| `--verbose` | 详细启动 |
| `-h` / `-v` | 帮助 / 版本 |

**完整快捷键**：`/hotkeys` 查看，自定义改 `~/.pi/agent/keybindings.json`（改后 `/reload` 生效）。

**项目信任**：首次在含 `.pi/settings.json` 的目录启动会询问是否信任；用 `/trust` 保存决定。
