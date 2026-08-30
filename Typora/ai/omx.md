# oh-my-codex（OMX）用法速查

> 建立在 **OpenAI Codex CLI** 之上的工作流/编排层：更好的提示、流程、多目标执行与运行时。官方仓库：https://github.com/Yeachan-Heo/oh-my-codex
>
> 注意：官方/原始 OMX 项目就是这个仓库，npm 包为 `oh-my-codex`。别用第三方 “OMX v2” 之类的分叉。

## 一句话

**Codex 仍是执行引擎**，OMX 只做外层：角色关键词 + 技能 + 工作流 + `.omx/` 持久状态。适合已经用 Codex、想让日常工作流更顺手的人。

## 安装 / 前提

```bash
codex --version              # 前提：已装并认证 Codex CLI
npm install -g oh-my-codex   # Node.js 20+；二选一安装
# 或让 npm 一并管理 Codex：npm install -g @openai/codex && npm install -g oh-my-codex
omx --help
```

> 不要对 Homebrew 装的 `codex` 再跑 `npm install -g @openai/codex`（会 EEXIST 冲突）。OMX 只需要 PATH 里有可用的 `codex`。

## 快速开始

```bash
omx doctor                                                  # 校验安装结构
codex login status                                          # 校验认证
omx exec --skip-git-repo-check -C . "Reply with exactly OMX-EXEC-OK"   # 真实模型调用冒烟测试

omx --worktree=feat/task --madmax --xhigh                   # 推荐启动方式（git 项目内）
```

进入会话后走标准流程：`$deep-interview` → `$ralplan` → `$ultragoal`（或 `/goal` + `$ultragoal`）。

## 启动标志

| 标志 | 说明 |
|------|------|
| `--worktree[=name]`, `-w` | 在独立 git worktree 里启动（`../<repo>.omx-worktrees/`）；不带名字 = 一次性 detached |
| `--madmax` | = Codex `--dangerously-bypass-approvals-and-sandbox`（跳过审批与沙箱，谨慎）|
| `--high` / `--xhigh` | = `-c model_reasoning_effort="high|xhigh"` 推理强度 |
| `--direct` | 单次启动，不启用 OMX 的 tmux/HUD 管理 |
| `--yolo` | 直通 Codex 的 `--yolo` |
| `--tmux` / `--detached-tmux` | 强制 tmux 启动策略 |

> 并发 `--madmax` 会话不要同目录跑，用不同的命名 worktree：`--worktree=feature/auth`、`--worktree=fix/flaky-tests`。

## 子命令

```bash
omx doctor                      # 安装/运行环境校验
omx setup --scope project --merge-agents   # 项目级安装（写 AGENTS.md 引导段、prompts、skills、hooks）
omx setup --scope user                        # 用户级安装
omx setup --no-merge-agents | --clear-merge-agents-policy
omx exec ...                    # 包装 codex exec
omx update                      # 立即查 npm 更新并重跑 setup 刷新
omx uninstall                   # 清理 OMX 管理的 hooks 包装
omx hud --watch                 # 监控/状态面板
```

### 任务队列（mission）

```bash
omx mission plan ./mission.md      # 解析并产出摘要（先验证）
omx mission run ./mission.md -- --model gpt-5   # 顺序执行清单里的 prompt
omx mission status ./mission.md
omx mission resume ./mission.md
omx mission mark ./mission.md --task task-002 --status blocked
omx mission rerun ./mission.md --task task-002
# 产物：.omx/missions/<slug>/summary.json、ledger.jsonl
```

### 团队运行时（team）

```bash
omx team 3:executor "fix the failing tests with verification"   # 1 个 leader + 3 个 worker
omx team status <team-name>
omx team resume <team-name>
omx team shutdown <team-name>
```

## 工作流关键词（会话内 `$...`）

| 关键词 | 用途 |
|--------|------|
| `$autopilot` | 官方推荐的编排入口，链式跑 `$deep-interview → $ralplan → $ultragoal` |
| `$deep-interview "..."` | 苏格拉底式澄清需求，产出可执行的需求工件（只澄清，不实现）|
| `$ralplan "..."` | 架构/可行性/共识规划（只产出计划，不改代码）|
| `$ultragoal "..."` | 持久多目标执行，`.omx/ultragoal` 账本记录 checkpoint |
| `$team "..."` | 协调并行执行（任务足够大时用）|
| `$plan "..."` | 可选规划与澄清（`--interview` 模式）|
| `$code-review` | 代码审查 |
| `$ultraqa` | 质量保证 |
| `$ralph` | 单主完成循环（替代多目标运行）|
| `$best-practice-research` / `$autoresearch` / `$autoresearch-goal` | 研究边界（喂给 `$ralplan`）|

**斜杠命令**：`/goal ...`（持久目标/检查点，跨轮次对账）、`/skills`（浏览已装技能）。

## 环境变量

| 变量 | 作用 |
|------|------|
| `OMX_ROOT` | 指定会话状态根目录（`$HOME/.omx/instances/<名>`），同一 root 只允许一个写会话 |
| `OMX_AUTO_UPDATE=0` | 关闭启动时的更新检查 |
| `OMX_AUTO_UPDATE=defer` | 延迟更新（不弹窗）|
| `OMX_LAUNCH_POLICY=direct\|tmux\|detached-tmux\|auto` | 启动策略（CLI 标志优先于它）|

## 目录与配置

- `.omx/` — 计划、日志、记忆、运行时状态（`.omx/ultragoal`、`.omx/state/`、`.omx/missions/`）。
- `.omx-config.json` — 模型/环境路由配置。
- AGENTS.md — 由 `omx setup --merge-agents` 在 `<!-- OMX:AGENTS:START/END -->` 之间维护引导段。
- hooks：`plugins/oh-my-codex/hooks/hooks.json`（插件式）、`.codex/hooks.json`（旧式回退）、`.omx/hooks/*.mjs`。

## 心智模型

Codex 干实际 agent 活；**OMX 角色关键词**复用角色；**OMX 技能**复用工作流；**`.omx/`** 存状态。把它当“更好的任务路由 + 工作流 + 运行时”，而不是天天手动敲的命令面。
