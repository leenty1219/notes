# oh-my-pi（omp）用法速查

> pi 的增强分叉（by can1357），主打「把 IDE 接进来」的开箱即用编码 agent。官方：https://omp.sh / https://github.com/can1357/oh-my-pi
>
> 命令名为 `omp`。60+ provider、31 个内置工具、14 个 LSP 操作、28 个 DAP 操作、约 8 万行 Rust 核心（grep/shell/AST 等在进程内，零 fork/exec）。

## 安装

```bash
curl -fsSL https://omp.sh/install | sh        # macOS / Linux
brew install can1357/tap/omp                  # Homebrew
bun install -g @oh-my-pi/pi-coding-agent      # Bun（推荐）
nix run github:can1357/oh-my-pi               # Nix
# Windows PowerShell: irm https://omp.sh/install.ps1 | iex
```

补全：`eval "$(omp completions zsh)"`（bash/fish 同理）。

## 启动 / 入口

```bash
omp                  # 交互 TUI
omp -p "任务"        # 单次回答后退出
omp --mode rpc       # stdio 上 NDJSON RPC（供程序驱动）
omp acp              # ACP 模式（Zed 等编辑器直接驱动）
omp setup            # 首次配置向导
```

## 模型与角色

- **角色**按意图路由：`default`（日常）、`smol`（廉价子代理）、`slow`（深度推理）、`plan`（计划）、`commit`（写 changelog）、`vision`、`designer`、`task`、`advisor`、`tiny`。
- 启动覆盖：`--smol` / `--slow` / `--plan`。
- `Ctrl+P` 循环当前角色的候选模型；`/model` 会话内换模型。
- `/login` 登录 provider（oauth / plan / local 三种认证形态）。

## 常用工具速览（31 个）

| 类别 | 工具 |
|------|------|
| 文件/搜索 | `read` `write` `edit` `ast_edit` `ast_grep` `grep` `glob` |
| 运行时 | `bash`（内置 46 个 coreutils）`eval`（持久 Python/JS cell）|
| 代码智能 | `lsp` `debug`（真调试器：lldb/dlv/debugpy）`security_scan` |
| 协调 | `task`（并行子代理）`hub` `todo` `ask` |
| 桌面/网页 | `browser` `computer`（直接操作宿主桌面）`web_search` `github` `generate_image` `inspect_image` `tts` |
| 记忆/技能 | `checkpoint` `rewind` `retain` `recall` `reflect` `memory_edit` `learn` `manage_skill` |

- 钉住启用集：`omp --tools read,edit,bash,...`。
- 稀有工具藏在 `xd://` 设备后：`read xd://` 列出，`write xd://<tool>` 运行（需 `tools.xdev`）。

## 提示魔法关键词

写在普通提示里（仅在正文中触发）：`ultrathink`（多步推理+最高思考档）、`orchestrate`（用并行子代理做大量独立工作并逐步验证）、`workflowz`（用 `task` 搭确定性子代理流水线）。

## 会话命令

| 命令 | 作用 |
|------|------|
| `/vibe` | Vibe 模式：当“导演”驱动常驻 fast/good worker（只读工具集）|
| `/fresh` | 重置 provider 流状态（清掉卡住的 prompt 缓存），不动本地记录 |
| `/model` | 换模型/角色 |
| `/login` | 登录 provider |
| `/reload-plugins` | 重载扩展 |
| `/advisor status` | 查看“第二模型把关”状态 |

## 配置

- 模型路由：`~/.omp/agent/config.yml`（如 `modelRoles: { default: spark/minimax-m3 }`）。
- 自定义 OpenAI 兼容 provider：`~/.omp/agent/models.yml`，然后 `omp models <provider>` 验证发现。
- 规则/技能/MCP 自动继承：`.claude` `.cursor` `.windsurf` `.gemini` `.codex` `.cline` `.github/copilot` `.vscode` 里的内容无需迁移。

## 亮点特性速览

- **LSP 接进每次写入**：重命名走 `workspace/willRenameFiles`，re-export/别名导入一起改。
- **真调试器**：agent 可 attach lldb/dlv/debugpy 单步看变量。
- **子代理 fan-out**：`task` 在隔离 worktree 里并行跑，返回 schema 校验的 typed 结果；`Alt+A` 开 Agent Hub 看每个子代理实时状态。
- **advisor**：第二个模型每轮旁观点评（note：concern/blocker）。
- **/collab**：生成链接/二维码实时分享会话（read-write 或只读 view）。
- **时间旅行流规则**：正则命中就中断 token 流、注入规则再重试，不用每轮付上下文税。
- **Hashline 编辑**：按内容哈希锚点改文件，改丢锚点直接拒掉补丁（省 token、防串行错）。
- **GitHub 即文件系统**：`read pr://1428`、`grep` 走 diff，`agent://<id>/findings.0.path` 取子代理结果。
- **冲突即 URL**：写 `@theirs/@ours/@base` 到 `conflict://N` 解决合并冲突。
- **omp commit**：把工作区拆成原子提交并校验提交信息。
- **记忆**：`retain`/`recall`/`learn`，会话间记住代码库事实（`memory.backend` 可选 local/Hindsight/Mnemopi）。
- **AST 编辑预览**：`ast_edit` 先出 (proposed) 卡片，确认后一次性落盘。

## 扩展

- 扩展 = TypeScript 模块（工具 API、斜杠命令、快捷键、TUI 原语都开放）。
- 让 omp 自己写缺失的部分，再 `/reload-plugins`；可放本地、上 `marketplace` 或发 npm。

## 快速排查

```bash
omp doctor        # 诊断（如有）
omp models <provider>   # 校验 provider 模型发现
omp --help        # 完整 CLI 参数
```
