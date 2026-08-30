# GitHub Copilot CLI 用法速查

> GitHub 官方的终端编码 agent。官方文档：https://docs.github.com/copilot/concepts/agents/about-copilot-cli

## 安装 / 启动

```bash
curl -fsSL https://gh.io/copilot-install | bash   # 或 brew install copilot-cli，或 npm install -g @github/copilot
copilot                 # 交互模式
copilot "任务"          # 交互 + 初始提示
copilot --banner        # 再次显示欢迎横幅
```

## 认证

- 首次运行输入 `/login`，按提示用 GitHub 账号登录。
- 或用 fine-grained PAT（需开启 "Copilot Requests" 权限），环境变量 `GH_TOKEN` 或 `GITHUB_TOKEN`（前者优先）。
- 前提：需要有效的 Copilot 订阅。

## 模型

- 默认 **Claude Sonnet 4.5**。
- `/model` 切换其他模型（如 Claude Sonnet 4、GPT-5）。

## 权限

- 每次操作执行前都会预览，**未经你明确批准不会执行任何动作**。

## 实验模式

```bash
copilot --experimental    # 启动即启用（设置会持久化，之后无需再加）
/experimental             # 会话内启用
```

- **Autopilot 模式**：按 `Shift+Tab` 循环模式，让 agent 持续工作直到任务完成。

## 斜杠命令

| 命令 | 说明 |
|------|------|
| `/help` | 帮助 |
| `/login` | 登录 GitHub |
| `/model` | 切换模型 |
| `/experimental` | 启用实验模式 |
| `/lsp` | 查看 LSP 服务器状态 |
| `/feedback` | 提交反馈 |

## 配额

- 每次提交 prompt 消耗 1 个 **premium request**（高级请求）配额。

## MCP

- 内置 GitHub MCP server（可访问仓库、issue、PR）。
- 支持自定义 MCP server 扩展能力。

## LSP 代码智能（可选）

用户级配置 `~/.copilot/lsp-config.json`，仓库级 `.github/lsp.json`：

```json
{
  "lspServers": {
    "typescript": {
      "command": "typescript-language-server",
      "args": ["--stdio"],
      "fileExtensions": { ".ts": "typescript", ".tsx": "typescript" }
    }
  }
}
```

LSP server 需自行安装（如 `npm install -g typescript-language-server`）。

## 配置目录

- `~/.copilot/`（用户级配置，如 `lsp-config.json`）。
- 仓库级：`.github/lsp.json`。

## 其他

- Windows 需 PowerShell v6+。
- 企业/组织管理员可在组织设置中禁用 Copilot CLI。
- `copilot --help` 查看完整 CLI 参数。
