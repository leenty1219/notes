# Herdr 用法速查

> 面向编码 agent 的终端工作区管理器（tmux 式的 workspace/tab/pane + agent 感知）。官方：https://herdr.dev
>
> 本机已安装：`herdr 0.8.2`（`~/.local/bin/herdr`），配置 `~/.config/herdr/config.toml`。

## 定位一句话

把终端组织成 **workspace → tab → pane**，并**识别 pane 里跑的是哪个编码 agent**（pi/claude/codex/gemini/cursor/omp/copilot/kimi…），可通过 `herdr` CLI 编排它们。

## 启动 / 会话

```bash
herdr                          # 启动或 attach 到常驻会话（TUI）
herdr --session <name>         # 使用/创建命名持久会话
herdr session attach <name>    # attach 命名会话
herdr --remote <ssh目标>        # 通过 SSH attach 到远程 Herdr server
herdr --no-session             # 无 server/client 的逃生模式
herdr status [server|client]   # 查看本地 client 与 server 状态
herdr server stop              # 停 server
herdr update                   # 升级
herdr channel set stable|preview  # 切换更新通道
herdr completion zsh           # 生成补全
```

## 布局概念

- **ID 格式**：workspace `w1`、tab `w1:t1`、pane `w1:p1`（关闭后 ID 不复用）。
- **Prefix 键**：默认 `Ctrl+B`（tmux 风格）。
- 每个 pane 会注入环境变量：`HERDR_ENV=1`、`HERDR_WORKSPACE_ID`、`HERDR_TAB_ID`、`HERDR_PANE_ID`。

## 常用快捷键（prefix 模式，默认 `Ctrl+B`）

| 按键 | 动作 | 按键 | 动作 |
|------|------|------|------|
| `?` | 帮助 | `c` | 新建 tab |
| `s` | 设置 | `shift+t` | 重命名 tab |
| `q` | detach | `p` / `n` | 上/下一个 tab |
| `w` | 工作区选择器 | `1..9` | 切到第 N 个 tab |
| `g` | 跳转 | `shift+x` | 关闭 tab |
| `shift+n` | 新建工作区 | `shift+p` | 重命名 pane |
| `shift+g` | 新建 worktree | `e` | 编辑 scrollback |
| `shift+w` | 重命名工作区 | `h/j/k/l` | 焦点左/下/上/右 pane |
| `shift+d` | 关闭工作区 | `tab` / `shift+tab` | 循环下一个/上一个 pane |
| `shift+r` | 重载配置 | | |

## 子命令速查

```bash
herdr workspace list|create|get|focus|rename|close ...
herdr tab      list|create|get|focus|rename|close ...
herdr pane     list|current|get|layout|focus|resize|zoom|split|swap|move|close|read|run|send-keys|wait-output ...
herdr agent    list|start|prompt|read|send-keys|wait|get|focus|rename|attach|explain ...
herdr session  list|attach|stop|delete
herdr worktree list|create|open|remove
herdr notification show <title> [--body ...] [--position ...] [--sound none|done|request]
herdr integration install|uninstall|status
```

### 常用操作示例

```bash
# 拆一个右侧 pane（保持 cwd，不抢焦点）
herdr pane split --current --direction right --cwd "$PWD" --no-focus

# 在 pane 里跑普通命令并等结果
herdr pane run <pane_id> "just test"
herdr pane wait-output <pane_id> --match "test result" --timeout 120000
herdr pane read <pane_id> --source recent-unwrapped --lines 120

# 工作区/标签/焦点
herdr workspace create --cwd . --label myproj
herdr tab create --workspace w1 --label dev
herdr pane focus --direction right

# git worktree 辅助
herdr worktree create --branch feat/x --label feat-x
herdr worktree list
```

## 管理编码 agent

**支持的种类（kinds）**：`pi | claude | codex | gemini | cursor | devin | omp | opencode | copilot | kimi | kiro | grok | hermes | qwen | ...`（`herdr agent` 查看完整列表）。

```bash
# 先装对应 agent 的集成（如 pi）
herdr integration install pi
herdr integration status

# 在指定 pane 启动 agent（名字 [a-z][a-z0-9_-]{0,31}，唯一）
herdr agent start reviewer --kind codex --pane <pane_id>
herdr agent start reviewer --kind codex --pane <pane_id> -- <agent 原生参数...>

# 提交任务并等待
herdr agent prompt reviewer "Review the diff, report only actionable findings." --wait --timeout 120000

# 读结果 / 看状态 / 发按键
herdr agent read reviewer --source recent-unwrapped --lines 120
herdr agent get reviewer
herdr agent send-keys reviewer esc
herdr agent wait reviewer --until blocked --timeout 120000
herdr agent list
```

**生命周期状态**：`idle`（就绪）→ `working` → `blocked`（卡在审批/提问 UI）→ `done`（后台任务完成后的 idle）→ `unknown`。

- `agent start` 成功后返回「检测到 agent 就绪」；启动中卡住会返回 `agent_not_ready`。
- `agent prompt --wait` 默认等首个 `idle/done/blocked`；卡在审批框会先返回 `agent_blocked`，需人工处理。

## 配置与环境

- 配置：`~/.config/herdr/config.toml`；`HERDR_CONFIG_PATH` 覆盖路径；`herdr --default-config` 打印默认配置。
- 日志：`~/.config/herdr/herdr.log`（+ `herdr-client.log`、`herdr-server.log`）。
- 重置自定义键位：`herdr config reset-keys`（先备份 config.toml）。
- 热重载：`herdr server reload-config`。
- 给 AI agent 的完整控制手册：`herdr --skill`（输出 SKILL 文件）。
