# Kimi Code CLI 用法速查

> 月之暗面（Moonshot AI）的终端编码 agent。官方文档：https://moonshotai.github.io/kimi-code/en/
>
> 注：旧项目 Kimi CLI 正逐步并入 Kimi Code CLI（命令仍为 `kimi`），新用户直接装 Kimi Code。

## 安装 / 启动

```bash
curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash   # 或 uv tool install --python 3.13 kimi-cli
kimi --version        # 验证
kimi                  # 交互 TUI
kimi -p "任务"        # 非交互打印（输出到 stdout）
kimi web              # 本地浏览器 UI
kimi acp              # IDE 集成模式（ACP，供 Zed/JetBrains 驱动）
```

## 认证

- 首次运行输入 `/login`，选 **Kimi Code**（OAuth，自动开浏览器）或其他平台（输入 API key）。
- 非交互登录：`kimi login`（设备码流程）。

## CLI 参数

| 参数 | 短写 | 说明 |
|------|------|------|
| `--session [id]` | `-S` | 恢复会话（带 ID 直接打开，不带进入选择器）|
| `--continue` | `-c` | 继续当前目录最近会话 |
| `--model <alias>` | `-m` | 指定模型 |
| `--prompt <prompt>` | `-p` | 非交互单次运行 |
| `--output-format text\|stream-json` | | 非交互输出格式（仅配合 `-p`）|
| `--yolo` | `-y` | 自动批准常规工具调用（跳过审批）|
| `--auto` | | 自动权限模式，全程不提问 |
| `--plan` | | 计划模式（优先只读工具探索规划）|
| `--skills-dir <dir>` | | 从指定目录加载技能（可重复）|
| `--agent <name>` | | 用指定 agent 启动新会话 |
| `--agent-file <path>` | | 从 Markdown 文件加载自定义 agent |
| `--add-dir <dir>` | | 添加额外工作目录（可重复）|

- 隐藏别名：`-r`/`--resume` = `--session`；`--yes`/`--auto-approve` = `--yolo`。
- `--continue` 与 `--session` 互斥；`--yolo` 与 `--auto` 互斥；`-p` 不能与 `--yolo`/`--auto`/`--plan` 组合。

### 常用组合

```bash
kimi                                    # 新会话
kimi -c                                 # 继续上次
kimi -S 01HZ...XYZ                      # 打开指定会话
kimi -y                                 # 跳过审批（批量安全任务）
kimi --auto                             # 全自动
kimi --plan                             # 先读代码产出计划
kimi -p "总结当前仓库状态"
kimi -p "列出改动文件" --output-format stream-json   # 供程序解析
kimi -m kimi-code/kimi-for-coding -p "解释最近 diff"
```

## 子命令

```bash
kimi login            # 非交互登录（设备码）
kimi acp              # ACP 模式（IDE 驱动）
kimi web              # 浏览器 UI
kimi doctor           # 校验配置文件
kimi export           # 导出会话
kimi migrate          # 迁移旧数据
kimi upgrade          # 检查更新
kimi provider         # 管理 provider
kimi mcp add/list/remove/auth ...   # 管理 MCP 服务器
```

### MCP 示例

```bash
kimi mcp add --transport http context7 https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: ..."
kimi mcp add --transport stdio chrome-devtools -- npx chrome-devtools-mcp@latest
kimi mcp list
kimi mcp auth linear
kimi --mcp-config-file /path/to/mcp.json    # 临时用 MCP 配置
```

## 交互功能

- 输入 `/help` 查看全部斜杠命令与用法提示。
- `/init`：分析项目并生成 `AGENTS.md`。
- `Ctrl-X`：切换到 shell 命令模式（直接执行 shell 命令，不离开 Kimi）。
- 内置子代理：`coder`、`explore`、`plan`（隔离上下文并行工作）。
- `/mcp-config`：对话式配置 MCP。

## 配置与上下文

- 配置文件：`config.toml`（含 `default_model` 等；`kimi doctor` 可校验）。
- 上下文文件：`AGENTS.md`。
- 技能目录：`--skills-dir` 或配置 `extra_skill_dirs`。
- Zsh 集成：安装 `zsh-kimi-cli` 插件后按 `Ctrl-X` 在 agent/shell 模式间切换。
- 编辑器集成：`kimi acp` + Zed/JetBrains（`~/.config/zed/settings.json` 或 `~/.jetbrains/acp.json` 配置）。
