# Codex CLI 用法速查

> OpenAI 的终端编码 agent。官方文档：https://developers.openai.com/codex

## 安装 / 启动

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh   # 或 npm install -g @openai/codex，或 brew install --cask codex
codex                 # 交互 TUI
codex exec "任务"     # 非交互（脚本/CI），短写 codex e
codex app             # 打开 ChatGPT 桌面应用
codex review          # 非交互代码审查
```

## 认证

- 首次运行 `codex`，选 **Sign in with ChatGPT**（Plus / Pro / Business / Edu / Enterprise）。
- 或 API key：`CODEX_API_KEY=<key> codex exec ...`（需额外配置）。

## 非交互模式 `codex exec`

```bash
codex exec "总结仓库结构并列出 5 个风险点"
codex exec --json "任务" | jq                 # JSONL 事件流
codex exec -o result.txt "任务"               # 只写最后一条消息到文件
codex exec --output-schema schema.json "任务" # 按 JSON Schema 输出结构化结果
codex exec --ephemeral "任务"                 # 不持久化会话
codex exec resume --last "继续修你发现的 bug"  # 继续上次任务
codex exec resume <SESSION_ID> "..."          # 继续指定会话
codex exec --skip-git-repo-check "任务"        # 跳过 git 仓库检查
```

- 默认 `exec` 跑在**只读沙箱**；stdout 只输出最终回复，进度走 stderr。
- 管道：`curl ... | codex exec "把前 20 条整理成 markdown 表格"`。

## 沙箱与审批

| 参数 | 取值 / 说明 |
|------|-------------|
| `--sandbox, -s` | `read-only`（exec 默认）\| `workspace-write` \| `danger-full-access` |
| `--ask-for-approval, -a` | `untrusted` \| `on-request` \| `never` |
| `--yolo` | 跳过所有审批与沙箱（仅限受控环境）|

```bash
codex exec --sandbox workspace-write "实现这个功能"
codex exec --sandbox danger-full-access "..."   # 仅在隔离 CI/容器里用
```

## 常用全局参数

| 参数 | 说明 |
|------|------|
| `--model, -m <id>` | 指定模型 |
| `--cd, -C <path>` | 指定工作目录 |
| `--add-dir <path>` | 额外授权写目录（可重复）|
| `--image, -i <path>` | 附加图片 |
| `--search` | 开启联网搜索（默认 cached）|
| `--oss` | 用本地开源模型（LM Studio / Ollama）|
| `--local-provider lmstudio\|ollama` | 指定本地 provider |
| `--config, -c key=value` | 覆盖配置项 |
| `--profile, -p <name>` | 叠加 profile 配置 |
| `--strict-config` | 配置含未知字段时报错 |

## 会话管理

```bash
codex resume            # 继续会话（打开选择器）
codex archive <会话>    # 归档（不删除，从列表隐藏）
codex unarchive <会话>  # 取消归档
codex delete <会话>     # 永久删除（UUID 用 --force）
codex cloud             # 云端会话交互选择器
codex cloud exec "任务" # 直接提交云端任务
codex cloud list        # 列出最近云端任务
```

## 其他命令

```bash
codex doctor        # 诊断安装/配置/认证/git/终端
codex completion zsh  # 生成 shell 补全
codex features      # 管理 feature flag
codex debug models  # 打印模型目录 JSON
```

## 配置与上下文

- 配置文件：`~/.codex/config.toml`（CLI 的 `-c key=value` 优先级更高）。
- 上下文文件：`AGENTS.md`（项目说明/约定）。
- 交互内输入 `/help` 查看全部斜杠命令与快捷键。

## 常用斜杠命令（以 `/help` 为准）

`/init`（生成 AGENTS.md）、`/model`、`/resume`、`/compact`、`/diff`、`/undo`、`/login`、`/logout`、`/approvals`、`/permissions`、`/config`、`/theme`、`/mcp`、`/status`、`/quit`。
