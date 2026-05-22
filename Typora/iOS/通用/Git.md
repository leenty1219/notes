## 修改最近的一条日制

```shell
# 修改最近一条日志信息
git commit --amend -m "MMDI-19580【AI记账】退款类型需要显示绿色和负号，撤回编辑退款标题的修改"
# 强制推送到服务器，注意如果是多人合作开发，队友也需要强制更新
git push origin bugfix/MMDI-19580 --force
```

## 本地忽略

对于已经添加追踪的文件

`skip-worktree`

> 告诉 Git：
> “这个文件我本地可能会改，但你平时别来检查它，也别提示我。”

``` shell
git update-index --skip-worktree 文件地址
# eg：移除根目录下的AGENTS追踪
git update-index --skip-worktree AGENTS.md
# 批量隐藏
git update-index --skip-worktree skills/mymoney-analyze-module/agents/openai.yaml && \
git update-index --skip-worktree skills/mymoney-analyze-module/references/analysis-checklist.md && \
git update-index --skip-worktree skills/mymoney-analyze-module/references/risk-boundaries.md && \
git update-index --skip-worktree skills/mymoney-fix-bug-verify/SKILL.md && \
git update-index --skip-worktree skills/mymoney-fix-bug-verify/agents/openai.yaml && \
git update-index --skip-worktree skills/mymoney-fix-bug-verify/references/bugfix-workflow.md && \
git update-index --skip-worktree skills/mymoney-fix-bug-verify/references/verification-baseline.md && \
git update-index --skip-worktree skills/mymoney-precheck-jenkins-package/SKILL.md && \
git update-index --skip-worktree skills/mymoney-precheck-jenkins-package/agents/openai.yaml && \
git update-index --skip-worktree skills/mymoney-precheck-jenkins-package/references/jenkins-checklist.md && \
git update-index --skip-worktree skills/mymoney-precheck-jenkins-package/references/release-boundaries.md && \
git update-index --skip-worktree skills/mymoney-update-api-cache/SKILL.md && \
git update-index --skip-worktree skills/mymoney-update-api-cache/agents/openai.yaml && \
git update-index --skip-worktree skills/mymoney-update-api-cache/references/api-cache-workflow.md && \
git update-index --skip-worktree skills/mymoney-update-api-cache/references/network-data-boundaries.md
```

### 取消忽略

```shell
git update-index --no-skip-worktree 文件地址
```

### 列出当前已经skip的文件

```shell
git ls-files -v | grep '^S' | cut -c3-

# 实例
skills/mymoney-add-module/SKILL.md
skills/mymoney-add-module/agents/openai.yaml
skills/mymoney-add-module/references/module-placement.md
skills/mymoney-add-module/references/reference-modules.md

# 另外一个版本，前面会有文件的状态
git ls-files -v | grep '^S'
S AGENTS.md
S AI_RULES.md
S skills/mymoney-add-module/SKILL.md
S skills/mymoney-add-module/agents/openai.yaml
S skills/mymoney-add-module/references/module-placement.md
```

### 批量取消

```shell
git ls-files -v | grep '^S' | cut -c3- | xargs git update-index --no-skip-worktree
```

