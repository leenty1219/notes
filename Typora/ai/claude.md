# Claude Code 用法速查

> Anthropic 的终端编码 agent。官方文档：https://code.claude.com/docs

## 安装 / 启动

```bash
curl -fsSL https://claude.ai/install.sh | bash   # 或 brew install --cask claude-code
claude                 # 交互模式
claude "任务"          # 交互 + 初始提示
claude -p "任务"       # 打印模式（非交互，输出后退出）
claude -c              # 继续最近会话
claude --resume        # 打开会话选择器
```

> npm 安装已弃用：`npm install -g @anthropic-ai/claude-code`。

## 认证

- 首次运行 `claude` 后输入 `/login`（Anthropic 账号订阅），或用 `ANTHROPIC_API_KEY`。
- 命令行：`claude auth login` / `claude auth logout` / `claude auth status`。

## 权限模式（`Shift+Tab` 循环）

| 模式 | 说明 |
|------|------|
| `default` | 手动确认 |
| `acceptEdits` | 自动接受文件编辑 |
| `plan` | 计划模式（只读分析）|
| `auto` | 自动模式（分类器决定）|
| `bypassPermissions` | 跳过全部权限检查 |

```bash
claude --permission-mode plan
claude --dangerously-skip-permissions   # 直接跳过权限（= bypassPermissions）
claude --permission-mode plan --allow-dangerously-skip-permissions
```

## 常用快捷键

| 按键 | 动作 |
|------|------|
| `Ctrl+C` | 中断 / 清空输入（连按两次退出）|
| `Ctrl+D` | 退出（空输入时）|
| `Esc` | 中断 / 关闭对话框 |
| `Esc`+`Esc` | 清空草稿 / 打开回退（rewind）菜单 |
| `Shift+Tab` | 循环权限模式 |
| `Ctrl+O` | 切换转写查看器（看工具详情）|
| `Ctrl+L` | 重绘屏幕 |
| `Ctrl+R` | 历史命令反向搜索 |
| `Ctrl+G` | 打开外部编辑器编辑提示 |
| `Ctrl+B` | 后台运行任务 |
| `Ctrl+T` | 切换任务清单 |
| `Ctrl+S` | 暂存/恢复提示 |
| `Ctrl+V` | 粘贴图片 |
| `Up/Down` 或 `Ctrl+P`/`Ctrl+N` | 历史 / 移动光标 |
| `Tab` | 接受自动补全 |
| `Alt+P` | 切换模型 |
| `Alt+T` | 切换扩展思考 |
| `Alt+O` | 切换快速模式 |
| `!` 开头 | shell 模式（执行命令并让 Claude 回应）|
| `@` | 文件路径补全 |
| `\`+Enter / `Shift+Enter` / `Ctrl+J` | 多行输入 |

## 常用斜杠命令

| 命令 | 说明 |
|------|------|
| `/help` | 帮助 |
| `/login` / `/logout` | 认证 |
| `/clear` | 清空会话 |
| `/compact` | 压缩上下文 |
| `/model` | 切换模型 |
| `/config` | 打开设置 |
| `/status` | 版本/模型/账号/连接状态 |
| `/usage`（别名 `/cost` `/stats`）| 会话成本与用量 |
| `/resume`（别名 `/continue`）| 恢复会话 |
| `/review`（别名 `/code-review`）| 审查 diff/PR/分支/路径 |
| `/rewind`（别名 `/checkpoint` `/undo`）| 回退到之前某点 |
| `/rename [name]` | 重命名会话 |
| `/init` | 生成 CLAUDE.md |
| `/memory` | 管理记忆 |
| `/add-dir <path>` | 添加工作目录 |
| `/permissions` | 查看/管理权限 |
| `/mcp` | 管理 MCP 服务器 |
| `/theme` | 切换主题 |
| `/tui [default\|fullscreen]` | 切换 TUI 渲染 |
| `/doctor` | 安装诊断 |
| `/skills` | 列出技能 |
| `/run` / `/verify` / `/simplify` | 运行/验证/简化（内置技能）|
| `/security-review` | 分支安全审查 |
| `/subtask` / `/tasks` | 子代理 / 后台任务 |

## 关键 CLI 参数

| 参数 | 说明 |
|------|------|
| `-p, --print` | 打印模式 |
| `-c, --continue` | 继续最近会话 |
| `--resume` | 打开会话选择器 |
| `--model <id>` | 指定模型 |
| `--append-system-prompt <文本>` | 追加系统提示 |
| `--append-system-prompt-file <文件>` | 从文件追加系统提示 |
| `--allowedTools "Bash(git log *)" "Read"` | 免审批工具 |
| `--disallowedTools "Edit" "Bash(rm *)"` | 禁用工具/规则 |
| `--add-dir <path>` | 添加工作目录 |
| `--effort low\|medium\|high\|xhigh\|max\|ultracode` | 努力等级 |
| `--settings <file>` | 加载额外设置 |
| `--mcp-config <file>` | 加载 MCP 配置 |
| `--output-format text\|json\|stream-json` | 输出格式 |
| `--verbose` | 详细输出 |
| `--max-turns <n>` | 最大轮数 |
| `--sandbox` | 沙箱模式 |
| `--bare` | 极简模式（跳过技能/命令/MCP/CLAUDE.md 自动发现）|
| `--agents '{"reviewer":{...}}'` | 定义子代理 |
| `--bg, --background` | 后台会话 |

## 配置与上下文

- 设置文件：`~/.claude/settings.json`（用户）、`.claude/settings.json`（项目，提交共享）、`.claude/settings.local.json`（本地，不提交）。
- 上下文文件：`CLAUDE.md`（项目说明/约定）。
- 技能：`~/.claude/skills/<名字>/SKILL.md`（个人）、`.claude/skills/`（项目）。
- 命令：`.claude/commands/*.md`（与技能等价，生成 `/命令`）。
