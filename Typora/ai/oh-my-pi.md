# oh-my-pi（omp）完全速查手册

> omp = "Oh My Pi"，是 [Pi](https://github.com/badlogic/pi-mono)（@mariozechner）的增强分叉，主打「把 IDE 接进来」的开箱即用终端编码 agent。命令名是 `omp`。
>
> 官网：https://omp.sh · GitHub：https://github.com/can1357/oh-my-pi · Discord：https://discord.gg/4NMW9cdXZa
>
> 一句话定位：**60+ provider · 31 个内置工具 · 14 个 LSP 操作 · 28 个 DAP 操作 · ~8 万行 Rust 核心**。grep / shell / AST / 高亮 / PTY / 桌面控制 / 图片解码 / token 计数全部编译进进程内，热路径零 fork/exec，macOS / Linux / Windows 同一个二进制。

---

## 一、安装

```bash
curl -fsSL https://omp.sh/install | sh        # macOS / Linux
brew install can1357/tap/omp                  # Homebrew
bun install -g @oh-my-pi/pi-coding-agent      # Bun（官方推荐，需 bun ≥ 1.3.14）
nix run github:can1357/oh-my-pi               # Nix 免安装运行
nix profile install github:can1357/oh-my-pi   # Nix 安装到 profile
mise use -g github:can1357/oh-my-pi           # 固定版本（mise）
# Windows PowerShell:
irm https://omp.sh/install.ps1 | iex
```

> **Alpine / musl**：预编译 musl 二进制动态链接 `libstdc++`/`libgcc`，Alpine 默认不带，先 `apk add libstdc++ libgcc`。

**Shell 补全**（omp 从实时命令元数据生成，永不漂移；`--model`/`--smol`/`--slow`/`--plan` 会按内置模型目录补全，`--resume` 按本地会话补全）：

```bash
eval "$(omp completions zsh)"                 # 加进 ~/.zshrc
eval "$(omp completions bash)"                # 加进 ~/.bashrc
omp completions fish > ~/.config/fish/completions/omp.fish
```

---

## 二、启动方式（4 种入口）

```bash
omp                       # 交互 TUI（默认）
omp "列出 src/ 下所有 .ts 文件"   # 交互 + 初始提示
omp @prompt.md @图.png "审查一下"  # @path 附加文件/图片到初始消息
omp -p "总结这个仓库"        # print/headless：输出后退出（脚本化入口）
echo "review this diff" | omp -p   # 非 TTY stdin 自动作为初始提示，无需 - 标记
omp --mode json            # JSON 事件流（机器可读，配 -p 用）
omp --mode rpc             # stdio 上 NDJSON RPC（供程序驱动）
omp --mode rpc-ui          # RPC + UI 事件（tool 卡片/选择器以 extension_ui_request 帧交给宿主）
omp acp                    # ACP 模式（Zed 等编辑器直接驱动）
omp -- "以-开头会被当 flag"  # -- 之后全部按字面文本处理
```

**Node SDK 内嵌**（`@oh-my-pi/pi-coding-agent` 导出 `ModelRegistry` / `SessionManager` / `createAgentSession` / `discoverAuthStorage`）。

### 常用启动参数（launch flags）

| 类别 | 参数 | 作用 |
|------|------|------|
| 工作区 | `--cwd <dir>` / `--add-dir <dir>` / `--session-dir <dir>` / `--no-session` | 起始目录 / 额外工作区 / 会话目录 / 不保存会话 |
| 会话 | `--continue`(`-c`) / `--resume [id]`(`-r`) / `--fork <session>` / `--from-claude` / `--from-codex` / `--export <session>` | 继续 / 恢复 / 派生 / 导入 Claude/Codex 会话 / 导出 HTML |
| 模型 | `--model <id或role>` / `--smol <id>` / `--slow <id>` / `--plan <id>` / `--models <a,b,c>` | 模型或角色（`slow`、`@slow`、模糊名 `opus`、`openai/gpt-5.2` 均可）/ 限制 Ctrl+P 循环 |
| 思考 | `--thinking <level>` / `--hide-thinking` / `--print-thoughts` | 等级 `off,minimal,low,medium,high,xhigh,max,auto` / 隐藏思考块 / print 模式带思考 |
| 模式 | `--prewalk` / `--plan-yolo` | 计划落地后切便宜模型 / 只读计划→自动批准→执行 |
| 工具/审批 | `--tools a,b,c` / `--no-tools` / `--no-lsp` / `--no-pty` / `--approval-mode <m>` / `--auto-approve`(`--yolo`) / `--advisor` / `--max-time <t>` | 钉住工具集 / 禁用工具 / 禁用 LSP / 禁用 PTY / 审批模式 / 全自动 / 开启第二模型把关 / 限时 |
| 扩展 | `--extension <path>`(`-e`) / `--hook <path>` / `--plugin-dir <dir>` / `--no-extensions` / `--skills <globs>` / `--no-skills` / `--no-rules` | 加载扩展（可重复）/ 钩子 / 插件目录 / 关闭扩展发现 / 过滤技能 / 关闭技能 / 关闭规则 |
| 提示 | `--system-prompt <文本|文件>` / `--append-system-prompt <文本|文件>` | 替换 / 追加系统提示 |
| 其他 | `--config <file>`（可重复）/ `--profile <name>` / `--alias <name>` / `--allow-home` | 一次性配置叠加 / 隔离 profile / 建 shell 别名 / 允许从 ~ 启动 |

### 常用子命令

| 命令 | 作用 |
|------|------|
| `omp setup` | 首次配置向导 / 装可选功能依赖 |
| `omp models [搜索]` / `omp models refresh` | 列出/搜索模型（也验证自定义 provider 发现）；强制刷新目录 |
| `omp config list/get/set/reset/path` | 管理配置（见「配置」节） |
| `omp update`（`--canary`/`--stable`） | 检查并升级（切换发布通道） |
| `omp usage` / `omp stats` | 各账户限额用量 / 本地用量看板 |
| `omp commit` | 生成提交信息 + 更新 changelog |
| `omp completions <sh>` | 打印补全脚本 |
| `omp plugin install/uninstall/list` | 扩展包管理（`install`=`omp install`） |
| `omp join` | 加入共享 collab 会话 |
| `omp share <session>` | 加密分享会话（=`/share`） |
| `omp git` | 全屏 git UI（分屏 diff + 暂存侧栏 + 提交编辑器） |
| `omp ps` / `omp worktree`(`wt`) / `omp shell` / `omp search`(`q`) | 后台进程 / 管理工作树(~/.omp/wt) / shell 控制台 / 测 web 搜索 |
| `omp token <provider>` / `omp ssh` | 取 API key/OAuth token / 管理 SSH 主机 |
| `omp auth-broker` / `omp auth-gateway` | 远程凭证仓库 / 认证网关 |
| `omp bench` / `omp grep` / `omp read` / `omp render` / `omp images` | 模型基准 / 测 grep 工具 / 预览 read 结果 / 渲染会话 / 图片后端诊断 |

---

## 三、模型、角色与认证

### 角色（按意图路由，9 个）

| 角色 | 用途 |
|------|------|
| `default` | 日常主任务 |
| `smol` | 廉价快速（子代理 fan-out、`tiny` 的后备） |
| `slow` | 深度推理 |
| `plan` | 计划模式 |
| `commit` | 写 changelog |
| `vision` / `task` / `advisor` / `tiny` | 图像 / 子代理默认 / 第二模型把关 / 轻量后台任务（标题、记忆、auto 思考分级） |

- 启动覆盖：`--smol` / `--slow` / `--plan`；`--model <id-or-role>`（`@slow`、`slow`、`opus`、`openai/gpt-5.2` 都可）。
- 会话内：`Ctrl+P` / `Shift+Ctrl+P` 循环当前角色候选模型；`Alt+M` 打开角色分配选择器；`/model` 换模型；`Alt+P` 临时换。
- 思考等级：`off → minimal → low → medium → high → xhigh → max`（`auto` 由本地分类器决定），`Shift+Tab` 循环，默认 `high`。
- 角色值可带思考后缀：`anthropic/claude-opus-4-5:high`。

### 按任务难度/意图路由 API（角色配置速查）

核心思路：**不是"难度探测器自动选 API"，而是按意图分档手动切 + 几个环节自动触发**。

示例配置（`~/.omp/agent/config.yml`）：

```yaml
modelRoles:
  default: anthropic/claude-sonnet-4-5    # 日常主力
  smol:    openai/gpt-4.1-mini            # 廉价快速（子代理 fan-out）
  slow:    anthropic/claude-opus-4-5:high # 深度推理（可带思考档后缀）
  plan:    <model>                        # 计划模式
  commit:  <model>                        # changelog 草稿
  task:    <model>                        # 子代理默认
  advisor: <model>                        # 第二模型把关
  tiny:    本地小模型                      # 后台杂活（标题/记忆/思考分级）
cycleOrder: [smol, default, slow]         # Ctrl+P 循环顺序
```

- 命令改：`omp config set modelRoles.slow anthropic/claude-opus-4-5:high`；**数组是整体替换**（项目 cycleOrder 会顶掉全局）。

**切换方式（手动档）**：`Ctrl+P` / `Shift+Ctrl+P` 按 `cycleOrder` 前后循环；`Alt+P` 临时换；`Alt+M` 角色分配选择器；`/model` 直换；启动 `--model <id-or-role>`。

**真正自动的点**：

| 环节 | 自动逻辑 |
|------|---------|
| 子代理 fan-out | `task`/`smol` 角色默认派给子代理便宜快模型（`task.agentModelOverrides` 可逐个覆盖） |
| auto 思考分级 | `defaultThinkingLevel: auto` 时本地 tiny 分类器（`providers.autoThinkingModel`）按问题复杂度自动定档——这是最接近"按难度"的，但分的是思考预算不是换 API |
| plan 落地降档 | `plan` 角色 + `prewalk.enabled` / `--plan-yolo`：强模型做计划、便宜模型执行 |
| advisor 把关 | `advisor.enabled` 第二模型复核主回答（`advisor.immuneTurns` 免检轮数） |
| 故障回退 | `retry.fallbackChains` + `retry.modelFallback`：主模型 429/配额墙自动切备用链，`fallbackRevertPolicy: cooldown-expiry` 冷却后回切 |

**主动上强模型**：提示词里写关键词 `ultrathink`（多步推理 + 当前模型最高思考档）；或手动切 `slow` / `/plan` 走 `plan` 角色。

### 认证 `/login`

```text
/login             # 打开 oauth/key 选择器
/login <provider>  # 直达某 provider，如 /login anthropic
/login <redirect-url>  # 补 OAuth 回调
/logout            # 清除存储凭据
```

认证形态三种：`oauth`（登 provider 账号）/ `plan`（走编码订阅路由）/ `local`（本地服务器，key 可选）。登录是**按 provider 隔离**的，登 `anthropic` 不等于登 `openai`。

**Provider 三大类**：

- **前沿直连 API**：Anthropic、OpenAI、OpenAI Codex、Google Gemini/Vertex/Antigravity、xAI/SuperGrok、DeepSeek、Mistral、Groq、Cerebras、Fireworks、Together、Baseten、DeepInfra、Hugging Face、NVIDIA、Meta、Amazon Bedrock、Azure OpenAI、SiliconFlow、GMI Cloud、CoreWeave、Sakana AI、OpenRouter、Synthetic、Vercel AI Gateway、Cloudflare AI Gateway、Wafer Serverless…
- **订阅编码计划**：Cursor、GitHub Copilot、GitLab Duo、Devin、Kimi Code、Moonshot、MiniMax Coding Plan（含 CN）、阿里 Coding Plan、Qwen Portal、Z.AI / GLM、智谱、小米 MiMo、千帆、Umans、NanoGPT、Novita、Venice、Kilo、ZenMux、OpenCode Go/Zen…
- **本地自托管**：Ollama、Ollama Cloud、LM Studio、llama.cpp、vLLM、LiteLLM（前三个本地引擎**无 key 即可用**，启动引擎即被发现）。

### 自定义 OpenAI 兼容 provider（`~/.omp/agent/models.yml`）

```yaml
providers:
  spark:
    baseUrl: http://192.168.10.223:8000/v1
    api: openai-completions
    apiKey: dummy          # 环境变量名或字面量；前缀 ! 表示执行命令取 stdout
    authHeader: true       # 注入 Authorization: Bearer
    disableStrictTools: true  # Anthropic 兼容代理不支持 strict 时
    models:
      - id: minimax-m3
        name: MiniMax M3
        contextWindow: 100000
        maxTokens: 32000
```

- 允许的 `api`：`openai-completions` / `openai-responses` / `openai-codex-responses` / `azure-openai-responses` / `anthropic-messages` / `bedrock-converse-stream` / `google-generative-ai` / `google-gemini-cli` / `google-vertex`。
- 验证：`omp models spark`（或 `omp models find <substr>`）。
- 无凭据本地 provider 加 `auth: none`；自动发现用 `discovery.type: ollama|llama.cpp|lm-studio|openai-models-list|proxy|litellm`。
- 预置默认路由：`~/.omp/agent/config.yml` 里 `modelRoles: { default: spark/minimax-m3 }`，或会话里 `/model` 分配。

### 接入内网/自建 API 的完整模板（models.yml + config.yml 联动）

分工：**`models.yml` 定义"服务端"（URL / 模型名 / 协议 / 凭据）**，**`config.yml` 只做"路由"（角色 → `provider/model`）**。

`~/.omp/agent/models.yml`：

```yaml
providers:
  myapi:                            # provider 名随意，路由时用 `myapi/<模型id>`
    baseUrl: http://192.168.1.10:8000/v1   # 自建网关（one-api/new-api/vLLM/…），注意结尾 /v1
    api: openai-completions         # 按上游协议选，见下“允许的 api”清单
    apiKey: dummy                   # 无鉴权可留空或 dummy；也可写环境变量名，!前缀=执行命令取 stdout
    authHeader: true                # 注入 Authorization: Bearer
    disableStrictTools: true        # 兼容代理不支持 strict tool 时必开（Anthropic 系代理尤其）
    # discovery: { type: openai-models-list }   # 自动拉上游 /models 列表，替代手写 models 列表
    models:
      - id: deepseek-v4-flash        # 上游真实模型 id（调用时实际传的名字）
        name: DeepSeek V4 Flash (内网)  # 显示名，随便起
        contextWindow: 131072        # 务必填对，omp 用它做上下文/压缩预算
        maxTokens: 8192
        # thinking: true             # 模型支持 reasoning 才开，否则别加
      - id: minimax-m3               # 同一网关可继续加第二、第三个…模型
        name: MiniMax M3
        contextWindow: 100000
        maxTokens: 32000
```

`~/.omp/agent/config.yml`：

```yaml
modelRoles:
  default: myapi/deepseek-v4-flash:high   # provider/模型id（:思考档 可选，需模型真支持）
  smol:    myapi/deepseek-v4-flash
  slow:    myapi/deepseek-v4-flash:max
  commit:  myapi/deepseek-v4-flash
  task:    myapi/deepseek-v4-flash         # 子代理默认也指到内建 API
cycleOrder: [smol, default, slow]
# enabledModels: [myapi/*]                 # 只留内建 API 的模型（数组整体替换！）
# disabledProviders: [openai, anthropic]   # 可选：屏蔽官方发现源（数组整体替换！）
```

使用注意：

- **网关同时支持 OpenAI + Anthropic 两套协议**时：`api` 是 **provider 级**字段，不能在同一个 provider 里混配；做法是同一 `baseUrl` 下注册两个 provider 对拍，哪个好用就把 `modelRoles` 指到哪个：

```yaml
providers:
  myapi-oa:                      # OpenAI 兼容面：工具调用兼容性最稳、通用性最好
    baseUrl: http://192.168.1.10:8000/v1
    api: openai-completions
    apiKey: dummy
    models:
      - id: deepseek-v4-flash
        name: DeepSeek V4 Flash (oa)
        contextWindow: 131072
        maxTokens: 8192
      - id: minimax-m3
        name: MiniMax M3 (oa)
        contextWindow: 100000
        maxTokens: 32000
  myapi-ano:                     # Anthropic 兼容面：支持 thinking（:high/:max）、流式更接近 Claude
    baseUrl: http://192.168.1.10:8000/v1
    api: anthropic-messages
    apiKey: dummy
    authHeader: true
    disableStrictTools: true     # 兼容代理不支持 strict tool 时必开
    models:
      - id: deepseek-v4-flash
        name: DeepSeek V4 Flash (ano)
        contextWindow: 131072
        maxTokens: 8192
        # thinking: true
      - id: minimax-m3
        name: MiniMax M3 (ano)
        contextWindow: 100000
        maxTokens: 32000
```

  两个面都 `omp models <名>` 验证能拉到后，各跑一轮同一任务对比：想要 `:high`/`:max` 思考档但 OpenAI 面不支持，就切到 anthropic 面；纯工具/低成本场景留 openai 面。
- 验证一条龙：`omp models refresh` → `omp models myapi` → `omp models find <模型名>`，能列出即接入成功；不行多半是 baseUrl 拼错（缺 `/v1`）或 `api` 协议选错。
- 换配置即时生效不必重启：会话里 `/reload-plugins`，或干脆新开会话；改了 models.yml 建议 `omp models refresh` 先。
- 数组键（`enabledModels` / `disabledProviders` / `cycleOrder`）**整体替换不合并**，写全局时要包含全部想保留的项。
- `:high`/`:max` 思考档后缀只对真支持 reasoning 的模型有效，普通开源/蒸馏模型请去掉。

### 路由四个旋钮

1. **自定义 provider**（`models.yml`，见上）。
2. **回退链** `retry.fallbackChains`：主模型 429/配额墙时切下一个，冷却后自动回来（`fallbackRevertPolicy: cooldown-expiry`）。
3. **按路径选模型**：`enabledModels` / `disabledProviders` 支持 `path:` 前缀条目，只对某个仓库生效。
4. **轮换凭据**：同 provider 叠多个 key，带会话亲和与逐凭据退避。

### API key 解析顺序

```
运行时 --api-key ＞ models.yml apiKey ＞ 存储的 OAuth ＞ /login 存的 key ＞ 环境变量/.env ＞ 其他存储 key ＞ models.yml 兜底
```

一个模型「可用」需要：provider 不在 `disabledProviders`，且（无 key 引擎 **或** 有可解析凭据）。

---

## 四、会话管理

### 存储模型

- 位置：`~/.omp/agent/sessions/<编码cwd>/<时间戳>_<sessionId>.jsonl`；blob 在 `~/.omp/agent/blobs/<sha256>`；提示历史 SQLite 在 `~/.omp/agent/history.db`。
- 格式：JSONL，**append-only 树 + 可变 leaf 指针**（每条含 `id`+`parentId`）。分支只移动指针，不删除旧条目。头部固定 256 字节 title 槽。

### 会话命令

| 命令 | 作用 |
|------|------|
| `/new` | 新建空会话 |
| `/resume [id]` / `/resume @claude` / `@codex` | 选历史会话 / 导入 Claude/Codex 会话 |
| `/fork` | 从当前会话派生新会话（新文件） |
| `/clone` | 复制当前活动分支到新会话 |
| `/tree` | 会话树导航（同文件内回任意节点、切分支，可带分支摘要） |
| `/compact [指令]` | 手动压缩上下文 |
| `/handoff` | 生成交接文档并作为压缩条目提交 |
| `/shake` | 机械式内容精简（tool 结果→artifact:// 引用） |
| `/export [--themes] [path]` | 导出 HTML |
| `/import <file>` | 从 JSONL 导入恢复 |
| `/share` | 端到端加密分享链接（read-write）；`/collab view` 只读链接 |
| `/dump` | 文本导出（系统提示+工具定义+消息）到剪贴板 |
| `/fresh` | 重置 provider 流状态（清卡住的 prompt 缓存），**不动**本地记录 |
| `/clear` | 清空当前对话上下文（写 `reset_boundary`，磁盘历史保留） |
| `/drop` | 删除当前会话并开新的（尽力而为） |
| `/restart` | 原参数重启进程并恢复当前会话 |
| `/name <名>` / `/session` | 设置会话名 / 查看会话信息 |
| `/trust` | 信任本项目 `.pi`/`.omp` 本地文件 |

**CLI 对应**：`--continue`(`-c`)、`--resume [id]`、`--fork`、`--export <file>`、`--from-claude`、`--from-codex`。

### `/tree` 要点

- `↑/↓` 移动、`←/→` 翻页、`Ctrl+←/→` 折叠/展开分支段、直接打字搜索、`Enter` 选中、`Shift+L` 打标签、`Shift+T` 显示时间戳。
- 过滤模式循环 `Ctrl+O`：default / no-tools(`Ctrl+T`) / user-only(`Ctrl+U`) / labeled-only(`Ctrl+L`) / all(`Ctrl+A`)。
- 选中用户消息→放回编辑器改后重提（产生新分支）；选中助手/工具条目→从该点继续。
- 跨分支切换时可自动总结被放弃的分支（`branchSummary.enabled`）。
- `/tree`（同文件多方案） vs `/fork`（另起新文件） vs `/clone`（复制当前工作后继续）。

---

## 五、快捷键速查

| 按键 | 动作 |
|------|------|
| `Ctrl+P` / `Shift+Ctrl+P` | 循环当前角色模型 前进/后退 |
| `Alt+P` / `Alt+M` | 临时换模型 / 打开模型选择器 |
| `Alt+Shift+P` | 切换 plan 模式 |
| `Ctrl+R` | 搜索提示历史 |
| `Ctrl+O` / `Ctrl+Shift+O` | 展开/收起工具输出 / 显示/隐藏工具活动 |
| `Ctrl+T` / `Shift+Tab` | 思考块显示 / 循环思考等级 |
| `Ctrl+G` | 用 `$EDITOR` 编辑草稿 |
| `Ctrl+Q`（或 `Ctrl+Enter`）/ `Alt+Up` | 排队 follow-up / 取回排队消息 |
| `Alt+R` | 重试上一条失败的助手回复 |
| `Alt+A`（旧 `Ctrl+S`） | 打开 Agent Hub |
| `Ctrl+V` 粘贴图片（Windows 用 `Alt+V`；`Ctrl+Shift+V` 纯文本粘贴） | |
| `Escape` 连按两次 | 打开 `/tree`（`doubleEscapeAction` 可设 `none`） |
| `Ctrl+L` | 开/关 live 语音模式 |
| `!命令` / `!!命令` | 执行命令并发送给模型 / 只执行不发送 |

- **消息队列**：agent 工作时 `Enter` 排队 steering（本轮工具跑完投递），`Alt+Enter`/`Ctrl+Q` 排队 follow-up（全部完成后投递），`Escape` 中止并恢复排队消息，`Alt+Up` 取回。
- 自定义：`~/.omp/agent/keybindings.yml`（键 = 动作 ID，值 = 一个或一组 chord；空数组禁用）。改后 `/reload` 生效，`/hotkeys` 看当前生效组合。

---

## 六、斜杠命令（built-in 常用）

| 命令 | 作用 |
|------|------|
| `/vibe` | Vibe 模式：当"导演"驱动常驻 fast/good worker（只读工具集） |
| `/fresh` | 重置 provider 流状态，不动本地记录 |
| `/model` / `/login` / `/logout` | 换模型 / 登录 / 登出 |
| `/reload-plugins` | 重载扩展 |
| `/advisor status` / `on` / `off` | 查看/开关「第二模型把关」 |
| `/pause` | 全局暂停（主 agent/子代理/advisor 都在安全边界停靠；Esc/Enter/Space/Ctrl+C 恢复） |
| `/review` | 代码评审：P0–P3 优先级 + 置信度 + 结论 |
| `/collab` / `/collab view` | 分享读写链接 / 只读链接（生成链接+二维码，`omp join` 加入） |
| `/memory view/stats/diagnose/queue/sync/clear/enqueue/mm` | 记忆维护 |
| `/todo` | 任务清单 |
| `/debug` | 调试/报告/性能面板 |
| `/hotkeys` / `/settings` | 快捷键 / 设置面板 |
| `/skill:<name> [args]` | 调用技能 |
| `/extensions` | 查看扩展与上下文文件状态（可开关） |
| `/agents` | 管理内置 task agent |
| `/jobs` | 后台异步任务快照 |
| `/join` / `/move <dir>` | 加入 collab / 切换工作目录 |

> 自定义斜杠命令：`~/.omp/agent/commands/*.md`（项目 `.omp/commands/*.md`），支持 `$1` `$2` 位置参数、`$@`/`$ARGUMENTS` 全部参数。Claude/Codex/OpenCode 等工具的 `commands/` 也会被继承。

---

## 七、提示魔法关键词（只在正文中触发）

| 关键词 | 效果 |
|--------|------|
| `ultrathink` | 多步推理 + 当前模型最高思考档 |
| `orchestrate` | 并行子代理做大量独立工作并逐步验证 |
| `workflowz` | 用 `task`/eval 内核搭确定性子代理流水线（需 eval+task 都启用） |

匹配规则：**必须全小写**、独立成词（`orchestrate,` 触发；`orchestrated`、`orchestrate.ts`、`orchestrate()` 不触发）；代码块/行内代码/HTML 内不触发；只对含该词的这一轮生效。设置：`omp config set magicKeywords.enabled false`（全局）、`magicKeywords.ultrathink false`（单个）。

---

## 八、工具大全（31 个）

> 核心工具与 `read`/`bash` 同命名空间。用 `--tools read,edit,bash,...` 钉住启用集；**稀有/按需工具藏在 `xd://` 设备后**：`read xd://` 列出，`write xd://<tool>` 运行（需 `tools.xdev`）。
> 默认关闭（需设置开启）：`github`、`security_scan`、`generate_image`、`tts`、`checkpoint`、`rewind`，以及记忆工具（`retain`/`recall`/`reflect`/`memory_edit`，按 `memory.backend`）。

### 文件 / 搜索

| 工具 | 说明 |
|------|------|
| `read` | 一个 path 通吃：文件、目录、归档、SQLite、PDF/Office、notebook、图片、URL、`ssh://` 远程、`://` 内部资源。**结构摘要**（大代码文件给声明骨架而非全文）。行选择器 `:N` `:A-B` `:A+C` `:5-16,40-80` `:raw` `:img` `:conflicts`；图片提问 `read <图>?q=问题`；SQLite `db.sqlite:table:key`、`?q=SELECT...` |
| `write` | 创建/覆盖文件、归档条目、SQLite 行 |
| `edit` | 默认 **hashline** 模式：按内容哈希锚点 `[path#TAG]` 打补丁，`PUT`/`CUT`/`REM`/`MV` 操作，锚点过期会拒掉补丁。模式可选 `hashline`/`apply_patch`/`patch`/`replace`（`edit.mode`） |
| `ast_edit` | ast-grep 结构化重写，先出 `(proposed)` 卡片，确认后经 `xd://resolve` 一次性原子落盘 |
| `ast_grep` | 50+ tree-sitter 语法的结构化代码查询 |
| `grep` | 文件/glob/内部 URL 上的正则搜索（ripgrep 编译进进程内，最快） |
| `glob` | glob 路径查找；要内容匹配请用 `grep` |

### 运行时

| 工具 | 说明 |
|------|------|
| `bash` | 工作区 shell，**46 个进程内 coreutils**（`ls/sed/sort/xargs/jq` 等都编译进内置 crate，零 fork/exec），可选 PTY、后台任务（`async:true`）、自动后台化。`timeout` 默认 300s |
| `eval` | 持久 Python / JS cell：`{language:"py"\|"js", code}`。**状态跨调用保留**；`display()` 结构化捕获、`tool.<name>()` 反调 agent 工具、`agent()`/`completion()`/`workpool()` 子代理桥、`@tool` 定义内核工具 |

### 代码智能

| 工具 | 说明 |
|------|------|
| `lsp` | 诊断、导航、符号、重命名（走 `workspace/willRenameFiles`，re-export/别名导入一起改）、代码动作、原始请求 |
| `debug` | 真调试器：attach `lldb-dap`/`dlv`/`debugpy` 等，断点、单步、线程、栈、变量、反汇编、读写内存 |
| `security_scan` | 原生安全审查（preflight→start→status→validate），或驱动 Codex Security 云扫描 |

### 协调

| 工具 | 说明 |
|------|------|
| `task` | 并行子代理（`tasks[]` 批量或单发），隔离 worktree、schema 校验的 typed 结果、`agent://<id>` 取输出 |
| `hub` | 统一协调面：对等消息（原 irc）、后台任务等待/取消（原 job）、长驻进程监管（原 launch） |
| `todo` | 会话任务清单（init/start/done/drop/block/append/view…），带阶段跟踪 |
| `ask` | 交互式结构化提问（选项单选/多选、超时自动选推荐项） |

### 桌面 / 网页

| 工具 | 说明 |
|------|------|
| `browser` | Puppeteer 标签页：Chromium/CDP 应用/你自己的 Chrome（经 relay），导航、检查、交互、`tab.run()` 跑 JS |
| `computer` | 控制真实宿主桌面：窗口枚举、截图、原生输入、OS 可访问性树、剪贴板（`computer.window()`/`win.screenshot()`/`el.press()`） |
| `web_search` | 一个查询走 23 个 provider 链，返回答案+引用；站点感知抽取（GitHub/arXiv/StackOverflow 等转结构化 markdown） |
| `github` | `gh` CLI 操作：repo/文件/PR 创建/checkout/push、搜索、Actions run 实时盯梢（需装 `gh`） |
| `generate_image` | 生成/编辑位图（Gemini/GPT/xAI Grok 图像模型） |
| `tts` | xAI Grok Voice 文本转语音（5 个内置音色，WAV/MP3） |

### 记忆 / 技能

| 工具 | 说明 |
|------|------|
| `checkpoint` / `rewind` | 打检查点 → 探索 → `rewind` 把探索上下文折叠成报告（成对使用） |
| `retain` / `recall` / `reflect` | 存记忆 / 搜记忆 / 基于记忆综合回答 |
| `memory_edit` | 按 id 更新/遗忘/作废记忆（仅 mnemopi） |
| `learn` / `manage_skill` | 沉淀可复用经验（可顺带建技能）/ 创建、更新、删除受管技能 |

---

## 九、内部 URL 方案（16 个，FS 形工具内透明解析）

| 方案 | 用途 |
|------|------|
| `pr://1428` / `pr://<owner>/<repo>/<N>` | 读 PR（`/diff` `/diff/<i>` `/diff/all` 看 diff）；`grep` 可直接在 diff 上搜 |
| `issue://<N>` | 读 issue |
| `agent://<id>` / `agent://<id>/findings.0.path` / `?q=` | 取子代理输出，按路径/JSON 查询抽取 |
| `history://<id>` | 子代理精简转录 |
| `skill://<name>` / `skill://<name>/相对路径` | 读技能 SKILL.md 及资产 |
| `memory://root` / `memory://root/MEMORY.md` / `memory://<id>` | 读记忆产物 |
| `artifact://<id>` | 读会话大输出 artifact |
| `local://<path>` | 本地临时共享文件（子代理共享父的 local:// 根） |
| `conflict://N`（写 `@theirs/@ours/@base`）/ `conflict://*` | 解决合并冲突（每个冲突一条 URL，批量 `*`） |
| `ssh://host/<path>` | 读远程文件 |
| `rule://<name>` / `security://scans/...` / `vault://` / `xd://` / `mcp://` / `omp://` | 规则 / 安全扫描结果 / 凭据库 / 罕见工具设备 / MCP / 内部 |

---

## 十、LSP 配置

- **自动检测**：cwd 含 rootMarker 且二进制可找到（先查项目本地 `node_modules/.bin`、venv、bin，再 `$PATH`）即启用，常见环境零配置。
- 内置 50+ server：`rust-analyzer`、`clangd`、`gopls`、`typescript-language-server`/`typescript-native`、`denols`、`biome`、`eslint`、`pyright`、`pylsp`、`ruff`、`jdtls`、`metals`、`solargraph`、`ruby-lsp`、`sourcekit-lsp`、`swiftlint`、`yamlls`、`terraformls`、`dockerls`…（详见 `defaults.json`）。
- 配置文件 `lsp.json`（或 `.yaml`/`.yml`），位置优先级从低到高：`~/lsp.json` → 插件 → 用户目录（`~/.omp/agent/lsp.json`）→ cwd 目录（`.omp/lsp.json`）→ cwd 根（`lsp.json`）。

```jsonc
// ~/.omp/agent/lsp.json 或 <项目>/.omp/lsp.json
{
  "servers": {
    "gopls": { "settings": { "gopls": { "gofumpt": false } } },
    "eslint": { "disabled": true },
    "my-lsp": {                      // 自定义新 server
      "command": "my-lsp-server", "args": ["--stdio"],
      "fileTypes": [".xyz"], "rootMarkers": [".xyz-project", ".git"]
    }
  },
  "idleTimeoutMs": 300000             // 空闲 5 分钟关 server
}
```

- Server 字段：`command`/`fileTypes`/`rootMarkers`（新 server 必填）、`args`/`initOptions`/`settings`/`disabled`/`isLinter`/`warmupTimeoutMs`/`capabilities`（rust-analyzer 的 `flycheck`/`ssr` 等）。
- 相关设置：`lsp.lazy`（按需启动）、`lsp.diagnosticsOnWrite`、`lsp.formatOnWrite`、`lsp.shared`（多进程共享）。`--no-lsp` 一键关闭。

---

## 十一、真调试器（DAP）

- 内置 adapter：`gdb`、`lldb-dap`、`codelldb`、`debugpy`、`dlv`、`js-debug-adapter`、`netcoredbg`、`kotlin-debug-adapter`、`rdbg`、`php-debug-adapter`、`bash-debug-adapter`、`dart-debug-adapter`、`flutter-debug-adapter`、`elixir-ls-debugger`。
- 工具 `debug` 的 `action`：`launch`/`attach`/`set_breakpoint`/`set_data_breakpoint`/`continue`/`step_over`/`step_in`/`step_out`/`pause`/`evaluate`/`stack_trace`/`threads`/`scopes`/`variables`/`disassemble`/`read_memory`/`write_memory`/`modules`/`loaded_sources`/`custom_request`/`output`/`terminate`/`sessions`。
- 自定义 adapter：`dap.json`（位置优先级同 LSP）。

```jsonc
// .omp/dap.json
{ "adapters": { "custom-jvm": { "command": "kotlin-debug-adapter",
    "fileTypes": [".java",".kt"], "rootMarkers": ["pom.xml"],
    "launchDefaults": { "request": "launch", "projectRoot": "." } } } }
```

- JS/TS 调试器（vscode-js-debug）需手动装：释放 tarball 到 `~/.local/opt/js-debug/`、或设 `JS_DEBUG_DAP_SERVER=<path-to-dapDebugServer.js>`、或 Mason `:MasonInstall js-debug-adapter`。注意 `npm i -g js-debug-adapter` 会 404。

---

## 十二、记忆（Memory）

`memory.backend`（默认 `off`）：

| 后端 | 说明 |
|------|------|
| `off` | 关闭 |
| `local` | 项目级摘要 + `learned.md` 经验（后台管道从历史会话抽取→合并出 `MEMORY.md`/`memory_summary.md`/`skills/`） |
| `hindsight` | 远程 Hindsight 记忆（`hindsight.apiUrl` 等；暴露 `recall`/`retain`/`reflect`） |
| `mnemopi` | 本地 SQLite 记忆（`@oh-my-pi/pi-mnemopi`；额外有 `memory_edit`） |
| `sharpshooter` | 摩擦门控的项目决策文件（架构/产品/风格），后台整合 |

- 开启：`omp config set memory.backend local`（或 `/settings` → 记忆）。
- `/memory`：`view`/`stats`/`diagnose`/`queue`/`sync`/`clear`/`enqueue`/`mm`（Hindsight 心智模型维护）。
- 读产物：`read memory://root`（启动注入的紧凑摘要）、`memory://root/MEMORY.md`、`memory://root/learned.md`、`memory://root/skills/<name>/SKILL.md`、`memory://<id>`（mnemopi 全行）。
- 自动学习：`autolearn.enabled: true` 启用 `learn` 工具（停后自动沉淀经验、可建受管技能到 `~/.omp/agent/managed-skills`）。
- 注入到系统提示的「Memory Guidance」是启发式上下文，**不是**仓库当前状态的权威。

---

## 十三、压缩（Compaction）与会话树

- 触发：`/compact` 手动；上下文溢出、`stopReason==="length"`、超过阈值、轮中阈值、空闲 6 种自动路径。
- `compaction.methodOrder` 默认 `[remote, snapcompact, handoff, shake, soft]`：
  - `remote`：provider 原生 OpenAI 兼容服务端压缩；
  - `snapcompact`：把丢弃历史**光栅化成位图 PNG**喂给视觉模型（本地、零网络、按模型选字体/尺寸）；
  - `handoff`：生成交接文档提交为压缩条目；
  - `shake`：机械把大 tool 结果换成 `artifact://` 引用；
  - `soft`：普通 LLM 摘要。
- 关键设置：`compaction.enabled`(true)、`compaction.thresholdPercent`(-1 按保留量)、`compaction.keepRecentTokens`(20000)、`compaction.autoContinue`(true)、`compaction.asyncEnabled`(true 后台预压缩)、`snapcompact.shape`(auto)。
- 显示转录（TUI）**不再视觉重启**：压缩处只显示一条 `── 📷 compacted · ctrl+o ──` 分隔线，展开看摘要，历史滚动条保留。

---

## 十四、审批模式（Tool Approval）

三档 `tools.approvalMode`：

| 模式 | 自动批准 | 会询问 |
|------|----------|--------|
| `always-ask` | read | write、exec |
| `write` | read、write | exec |
| `yolo`（默认） | read、write、exec | 无 |

- 工具分三档：`read`（读数据）/ `write`（改工作区）/ `exec`（执行代码、驱动浏览器、生代理等）。
- 每工具覆盖：`tools.approval: { bash: prompt, read: allow, mcp__xxx: deny }`；MCP 工具按最终注册名 `mcp__<server>_<tool>`。
- `bash.patterns`（允许/询问/拒绝，`*` 通配，`deny` 是绝对的；compound 命令逐段匹配）：`rm -rf *` 之类危险命令即使 yolo 也强制确认。
- `bashInterceptor`（把 `cat`→`read`、`rg`→`grep`、`sed -i`→`edit`、重定向→`write` 等路由到专用工具）。
- 子代理 headless 强制 yolo，父 `task` 调用是授权边界。
- `--auto-approve`/`--yolo`/`--approval-mode` 本次覆盖。

---

## 十五、子代理与 Agent Hub

- `task` 工具 fan-out：默认批式 `{context, tasks:[{task,agent?,name?,outputSchema?,isolated?}]}`；隔离模式跑在独立 worktree、返回 patch 或合并分支；结果 schema 校验后 typed 返回。
- 内置 agent：`task`、`sonic`（fast 档）、`scout`、`reviewer`、`security-reviewer`；自定义放 `.omp/agents/`（项目）或 `~/.omp/agent/agents/`。
- **Agent Hub**（`Alt+A`）：实时名册（running/idle/parked/aborted）+ 用量；`Enter` 聚焦子代理读转录、`r` 复活、`x` 杀、`t` 切树形/扁平视图。
- **Vibe 模式**（`/vibe`）：导演模式，只读工具 + 5 个 worker 控制工具（`vibe_spawn`/`vibe_send`/`vibe_wait`/`vibe_kill`/`vibe_list`）；`fast`（sonic）做机械活、`good`（task）做判断。
- `hub` 工具：`send`/`inbox`/`list`/`wait`/`cancel`/`jobs`/`start`/`ps`/`logs`/`stop` 统一对等消息与后台任务。
- 关键设置：`task.maxConcurrency`(32)、`task.maxRecursionDepth`(2)、`task.agentIdleTtlMs`(7min)、`async.enabled`。

---

## 十六、上下文文件（AGENTS.md / RULES.md）

**自动发现注入，无需让 agent 去读。** 默认模板把内容放进 `<repo-rules>` 块。

### 原生 `.omp`（优先级最高）

| 文件 | 作用 |
|------|------|
| `~/.omp/agent/AGENTS.md` / `<最近非空 .omp>/AGENTS.md` | 用户/项目背景 |
| `~/.omp/agent/RULES.md` / `<最近非空 .omp>/RULES.md` | **sticky 硬规则**：长会话后仍贴近当前轮次重挂载 |

- 规则：项目级只读**最近一个非空 `.omp/` 目录**里的文件，缺了不向上继续找。
- `AGENTS.md` 放长期背景；`RULES.md` 放"永不提交/不碰生成文件"这类硬约束（保持短）。

### 其他工具约定自动继承（无需迁移）

`.claude/CLAUDE.md`、`.codex/AGENTS.md`、`.gemini/GEMINI.md`、`.config/opencode/AGENTS.md`、`.github/copilot-instructions.md`、`.agent[s]/AGENTS.md`、独立 `AGENTS.md`/`CLAUDE.md`、`.cursor/rules/*.mdc`、`.windsurf/rules/*.md`、`.clinerules` 等。

- 同一作用域 shadowing：`native > omp-plugins > claude > agent-plugins > agents/claude-plugins/codex > gemini > opencode > cursor/windsurf > cline > github > vscode > agents-md/claude-md`。
- 关闭整源：`disabledProviders: [claude, github]`；只关单个文件：`disabledExtensions: [context-file:user:CLAUDE.md]`。
- `@` 导入：上下文文件里 `@docs/arch.md` 内联展开（相对导入文件目录、`~` 展开、最多 5 跳、环跳过）。
- 禁用加载：`--no-rules` / `--no-context-files`（`-nc`）相关 flag。

---

## 十七、技能（Skills）

- 布局：`<skills-root>/<name>/SKILL.md`（**一层**，不支持多层嵌套）。
- 位置：`.omp/skills/`（项目）、`~/.omp/agent/skills/`（用户）、`.claude/skills/`、`.github/skills/`、插件 skills、受管 `~/.omp/agent/managed-skills/`。
- `SKILL.md` frontmatter：`name`、`description`（原生/插件/github 源**必填**）、`globs`、`alwaysApply`、`hide`、`disableModelInvocation`。
- 用法：模型按需 `read skill://<name>`；交互 `/skill:<name> [args]`（把技能正文注入为自定义消息，相对路径按技能目录解析）。
- 受管技能：`manage_skill` / `learn` 工具写入 `managed-skills/<name>/SKILL.md`（需 `autolearn.enabled`）。

---

## 十八、扩展（Extensions）

- 扩展 = TypeScript 模块，默认导出 `(pi) => {}` 工厂。位置：`~/.omp/agent/extensions/*.ts`（全局）、`.pi/extensions/*.ts` / `.omp/extensions`（项目）、`-e ./x.ts`（临时）。
- 能力全开：事件（`pi.on`）、LLM 工具（`pi.registerTool`）、斜杠命令（`pi.registerCommand`）、快捷键、消息渲染、provider 注册、文件写/删 fallback、事件总线。
- 核心 API：`pi.on(event, handler)` / `registerTool` / `registerCommand` / `registerShortcut` / `registerFlag` / `sendMessage` / `sendUserMessage` / `appendEntry` / `setModel` / `setThinkingLevel` / `setSessionName` / `exec` / `registerProvider`。
- 常用事件：`session_start`/`session_shutdown`、`input`、`tool_call`（可 block）、`tool_result`（可改结果）、`user_bash`、`before_agent_start`、`turn_start`/`turn_end`、`before_provider_request`/`after_provider_response`、`session_before_switch`/`session_before_compact`（可取消）、`mcp_notification`。
- `ctx.ui`：`select/confirm/input/editor/notify/setStatus/setWidget`；`ctx.models`（只读模型查询）；`ctx.setInterval/setTimeout`（**托管定时器**，抛错不会拖垮会话）。
- 工具定义用 `pi.zod`（omptype 后端）；参数 schema 用对象枚举；`execute` 抛异常 = 报错给 LLM；输出截断 50KB/2000 行。
- 让 omp 自己写缺失部分 → `/reload-plugins`。

---

## 十九、配置体系

### 位置与优先级（低→高）

```
内置默认 ＜ 全局 ~/.omp/agent/config.yml ＜ 项目 <cwd>/.omp/config.yml ＜ --config 叠加 ＜ 运行时 flag/环境变量
```

- 对象**深合并**；**数组整体替换**（项目数组会覆盖全局数组，不会追加——最常见坑）。
- 路径作用域：`enabledModels` / `enabledProviders` / `disabledProviders` 支持 `path:` 条目。
- 命令：`omp config list|get <k>|set <k> <v>|reset <k>|path`；会话内 `/settings`。
- `PI_CODING_AGENT_DIR` 整体搬走 `~/.omp/agent` 基目录。

### 重点设置

```yaml
modelRoles: { default: anthropic/claude-sonnet-4-5, smol: openai/gpt-4.1-mini, slow: anthropic/claude-opus-4-5:high }
cycleOrder: [smol, default, slow]          # Ctrl+P 循环顺序
enabledModels: []                           # 允许清单（空=全部）
disabledProviders: []                       # 禁用的模型/发现源
advisor: { enabled: false }                 # 第二模型把关
defaultThinkingLevel: high
tools: { approvalMode: yolo, approval: { bash: prompt } }
edit: { mode: hashline }
read: { defaultLimit: 300, summarize: { enabled: true } }
compaction: { enabled: true, keepRecentTokens: 20000 }
memory: { backend: off }
lsp: { enabled: true, lazy: true, diagnosticsOnWrite: true }
theme: { dark: titanium, light: light }
statusLine: { preset: default }
retry:
  fallbackChains: { default: [anthropic/claude-opus-4-5, openai/gpt-5.5] }
```

---

## 二十、环境变量速查

**`.env` 加载顺序**（先定义者胜，进程环境永远最高）：`<cwd>/.env` ＞ `~/.omp/agent/.env` ＞ `~/.omp/.env` ＞ `~/.env`。

| 变量 | 作用 |
|------|------|
| `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` / `GEMINI_API_KEY` / `GROQ_API_KEY` / `OPENROUTER_API_KEY` / `DEEPSEEK_API_KEY` / `MISTRAL_API_KEY` / `XAI_API_KEY` … | 各 provider key（详见 providers 表） |
| `PI_CODING_AGENT_DIR` | 整体迁移 agent 目录（默认 `~/.omp/agent`） |
| `PI_SMOL_MODEL` / `PI_SLOW_MODEL` / `PI_PLAN_MODEL` | 覆盖 smol/slow/plan 角色 |
| `PI_NO_PTY=1` / `PI_PY=0` / `PI_JS=0` | 禁 PTY / 禁 Python eval / 禁 JS eval |
| `PI_CACHE_RETENTION=long` | 提示缓存保留（`long`/`short`/`none`） |
| `PI_PROXY` / `PI_PROXY_<PROVIDER>` | 进程级 / 单 provider 代理 |
| `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY` | 通用代理（回环/内网/NOPROXY 永远直连） |
| `OMP_AUTH_BROKER_URL` / `OMP_AUTH_BROKER_TOKEN` | 远程凭证仓库 |
| `PI_TASK_MAX_OUTPUT_BYTES/LINES` | 子代理输出上限 |
| `JS_DEBUG_DAP_SERVER` | JS 调试器 dapDebugServer.js 路径 |
| `GEMINI_SEARCH_MODEL` / `EXA_API_KEY` / `BRAVE_API_KEY` / `TAVILY_API_KEY` / `KAGI_API_KEY` / `JINA_API_KEY` | web_search provider |
| `GH_TOKEN` / `GITHUB_TOKEN` | GitHub 抓取鉴权 |
| `PI_OFFLINE=1` | 禁用启动网络操作 |
| `PI_STRICT_EDIT_MODE` / `PI_EDIT_VARIANT` | 强制 edit 变体 |
| `PUPPETEER_EXECUTABLE_PATH` | 指定系统 Chromium |

---

## 二十一、快速排查

```bash
omp models <provider>          # 校验某 provider 模型发现
omp models refresh             # 强制刷新模型目录
omp config list                # 看全部生效设置（含类型/默认值）
omp config get disabledProviders   # 看合并后的值
omp usage                      # 各账户限额用量
omp stats                      # 本地用量看板
omp update                     # 升级
omp --help / omp <cmd> --help  # 完整 CLI 参考
```

- provider 模型不可选：查 `disabledProviders` 是否包含该 ID，以及是否已有凭据（`/login <provider>` 或环境变量或 `models.yml` apiKey）。
- 项目设置没生效：记住**数组整体替换**，项目 `disabledProviders` 会顶掉全局列表。
- 流卡住：`/fresh` 重置 provider 流状态。
- 快捷键冲突：`/hotkeys` 查看，`~/.omp/agent/keybindings.yml` 改后 `/reload`。

---

## 二十二、与 pi 的差异速记

| 维度 | pi（原版） | omp |
|------|-----------|-----|
| 命令 | `pi` | `omp` |
| 内置工具 | read/write/edit/bash/grep/find/ls | 31 个（含 LSP/DAP/browser/computer/web_search/task/记忆等） |
| 执行引擎 | Node | ~8 万行 Rust 原生（grep/shell/AST 进程内） |
| 编辑 | 普通 edit | hashline 内容哈希锚点 + ast_edit 预览 |
| 子代理 | 无内置 | `task` fan-out + Agent Hub + Vibe 模式 |
| 记忆 | 无 | local/hindsight/mnemopi 后端 |
| 调试 | 无 | 真 DAP 调试器（lldb/dlv/debugpy） |
| LSP | 无 | 每次写入接 LSP（重命名/诊断/格式化） |
| 分享 | /share gist | /collab 实时协同 + /share 加密链接 |

> 详细官方文档：https://omp.sh/docs（tools / providers / sdk / lsp-config 等），源码 `docs/` 目录随仓库同步。
