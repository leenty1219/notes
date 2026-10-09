# Git 操作手册

本文面向日常开发与协作，按“理解状态 → 暂存提交 → 分支协作 → 撤销恢复 → 排障”的顺序整理 Git 常用操作。除特别说明外，命令都在仓库目录的终端中执行。文中的 `<文件>`、`<分支名>`、`<commit>` 是需要替换的提示文字，不要把尖括号原样输入。例如：

```bash
git switch -c feature/login
```

这里 `feature/login` 是实际分支名；写成 `git switch -c <分支名>` 时，应把 `<分支名>` 换成自己要用的名字。后文尽量给出可直接运行的例子，并说明命令对文件、分支或历史造成的变化。

## 目录

- [1. Git 与仓库基础](#1-git-与仓库基础)
- [2. 初始配置](#2-初始配置)
- [3. 查看仓库状态与历史](#3-查看仓库状态与历史)
- [4. 添加、提交与检查变更](#4-添加提交与检查变更)
- [5. 分支操作](#5-分支操作)
- [6. 远程仓库与同步](#6-远程仓库与同步)
- [7. 合并、变基与冲突处理](#7-合并变基与冲突处理)
- [8. 撤销、恢复与找回](#8-撤销恢复与找回)
- [9. 暂存工作区](#9-暂存工作区)
- [10. 标签与版本发布](#10-标签与版本发布)
- [11. 文件忽略与跟踪控制](#11-文件忽略与跟踪控制)
- [12. 常用工作流](#12-常用工作流)
- [13. 常见问题排查](#13-常见问题排查)
- [14. 安全习惯与速查](#14-安全习惯与速查)

## 1. Git 与仓库基础

Git 主要管理三类内容：工作区（当前文件）、暂存区（下一次提交的快照）、本地仓库（已有提交历史）。远程仓库是另一份独立仓库，通过 fetch、pull、push 等操作交换提交。

```text
工作区 --git add--> 暂存区 --git commit--> 本地仓库
                                     本地仓库 --git push--> 远程仓库
远程仓库 --git fetch--> 本地仓库中的远程跟踪分支
```

常见术语：

- **commit**：不可变的历史快照，包含父提交、作者、时间和变更内容。
- **HEAD**：当前检出的提交或分支位置。
- **分支**：指向某个提交的可移动引用。
- **远程跟踪分支**：本地记录的远端分支状态，例如 `origin/main`。
- **上游分支**：当前本地分支默认关联的远程分支。
- **冲突**：Git 无法自动决定两侧修改如何合并，需要人工处理。

## 2. 初始配置

查看配置及来源：

```bash
git config --list --show-origin
```

设置提交身份：

```bash
git config --global user.name "你的姓名"
git config --global user.email "name@example.com"
```

为单个仓库设置身份时，进入仓库后去掉 `--global`。其他常用配置：

```bash
git config --global init.defaultBranch main
git config --global core.editor "vim"
git config --global pull.rebase false
```

`pull.rebase` 可按团队约定设置；也可以每次明确使用 `git pull --rebase` 或 `git pull --no-rebase`。检查某项配置：

```bash
git config --show-origin --get user.email
```

初始化或克隆：

```bash
git init
# 在当前目录建立一个新的 Git 仓库

```bash
git clone https://github.com/example/app.git
# 下载仓库，并在当前目录创建 app/ 文件夹

git clone https://github.com/example/app.git my-app
# 下载仓库，目录名指定为 my-app

git clone --branch release/2.0 https://github.com/example/app.git
# 下载仓库并检出 release/2.0 分支
```

实际使用时，把示例地址换成项目页面提供的 HTTPS 或 SSH 地址。`git clone` 会创建目录；如果目标目录已经存在且非空，通常不能直接克隆进去。

## 3. 查看仓库状态与历史

```bash
git status
# 查看当前分支、暂存区、工作区和未跟踪文件

git status --short --branch
# 用短格式显示状态，并在第一行显示当前分支及跟踪关系

git branch --show-current
# 只显示当前分支名

git log --oneline --decorate -20
# 最近 20 条提交，每条一行，并标注分支/标签位置

git log --graph --oneline --decorate --all
# 用字符图显示所有本地和远程跟踪分支的提交分叉
```

下面用示例哈希演示提交查看：

```bash
git show a1b2c3d
# 查看短哈希 a1b2c3d 对应提交的说明和具体改动

git show --stat a1b2c3d
# 只看这个提交改了哪些文件、每个文件增删多少行
```

哈希可从 `git log --oneline` 复制；通常输入开头足够区分即可。比较两个提交时，顺序是“旧版本、新版本”，结果显示从旧版本到新版本的差异：

```bash
git diff a1b2c3d e4f5a6b
# 比较两个提交之间的文件差异
```


查看某文件的提交记录和逐行来源：

```bash
git log --follow --oneline -- path/to/file
git blame -L 10,30 -- path/to/file
```

状态简写中常见含义：`??` 未跟踪；`A` 新增；`M` 修改；`D` 删除。短状态的两列分别表示暂存区和工作区变化。

## 4. 添加、提交与检查变更

```bash
git add Sources/LoginView.swift
# 只把这个文件的改动放进下一次提交

git add Sources/
# 把 Sources 目录里的新增和修改放进暂存区

git add -p
# 逐块查看改动，每块选择是否暂存

git add -A
# 暂存仓库中的新增、修改和删除

git commit -m "fix: show login error"
# 用给定说明创建提交

git commit -am "fix: handle empty username"
# 快捷提交已跟踪文件的修改和删除；不会包含新建文件
```

`git add` 是把当前文件内容复制到暂存区，不是锁定文件；之后继续编辑文件，会出现“暂存区版本”和“工作区版本”不同的情况。提交前用 `git diff --staged` 检查真正进入提交的内容。


提交前检查：

```bash
git status
git diff --staged
git diff --check            # 检查空白错误
```

提交说明建议描述本次提交的具体变化，保持简短且可检索。需要补充最近一次提交时：

```bash
git commit --amend
# 修改最近提交说明
git commit --amend -m "新的提交说明"
```

`--amend` 会生成新的提交并替换当前分支末端的提交。若原提交已经推送或被他人使用，改写后需要协调团队并安全地更新远端；不要随意改写共享历史。

## 5. 分支操作

```bash
git branch
# 列出本地分支，星号表示当前分支

git branch -a
# 同时列出本地分支和远程跟踪分支，例如 origin/main

git switch -c feature/login
# 从当前提交新建 feature/login 分支，并立即切换过去

git switch main
# 切换到已有的本地 main 分支

git branch -d feature/login
# 删除已合并的本地分支；未合并时 Git 会阻止删除

git branch -D feature/login
# 强制删除本地分支，即使它包含未合并提交也会删除分支引用
```

删除分支引用不等于立即从磁盘删除所有提交对象，但分支上唯一可达的提交以后可能难以找回。删除前先用 `git log main..feature/login --oneline` 检查该分支独有的提交。

旧命令 `git checkout` 仍可使用；新命令 `switch` 用于切换分支，`restore` 用于恢复文件，语义更明确。

从远程分支创建本地分支：

```bash
git fetch origin
git switch --track origin/feature/name
```

重命名当前分支并更新远端：

```bash
git branch -m new-name
git push -u origin new-name
git push origin --delete old-name
```

确认旧远端分支确实不再需要后再删除。

## 6. 远程仓库与同步

```bash
git remote -v
# 查看远端名称和地址，常见名称是 origin

git remote add origin https://github.com/example/app.git
# 把该地址登记为名为 origin 的远端

git remote set-url origin git@github.com:example/app.git
# 修改 origin 的地址，例如从 HTTPS 改为 SSH

git fetch origin
# 下载 origin 的新提交信息，但不改当前分支文件

git fetch --all --prune
# 获取所有远端更新，并清理服务器已删除的远端分支记录
```

`origin` 是克隆时常见的远端别名，并非固定名称。把示例地址换成仓库实际地址；执行 `set-url` 前先用 `remote -v` 确认改的是目标远端。

`fetch` 只更新远程跟踪分支，不会直接改动当前工作区。同步当前分支：

```bash
git pull                         # 获取并按配置整合上游变更
git pull --ff-only               # 只允许快进，适合不想自动生成合并提交时
git pull --rebase                # 获取后把本地提交重放到上游之上
```

推送：

```bash
git push
git push -u origin <分支名>     # 首次推送并设置上游
git push origin HEAD             # 推送当前分支到同名远端分支
```

推送被拒绝时，先检查状态并获取远端更新，再按团队流程合并或变基；不要立即强推。若确实需要更新自己改写过的远端分支，优先使用：

```bash
git push --force-with-lease
```

它会在远端分支仍处于预期位置时才强制更新，比 `--force` 多一层保护，但仍会改写远端历史；先确认该分支没有他人的新提交，并与协作者协调。

## 7. 合并、变基与冲突处理

合并目标分支到当前分支：

```bash
git merge <目标分支>
```

变基当前分支到最新主分支之上：

```bash
git fetch origin
git rebase origin/main
```

合并会整合两条历史，必要时产生合并提交；变基会重写当前分支提交，使历史呈线性。不要对已共享、他人基于其开发的提交随意变基。

冲突处理流程：

1. 用 `git status` 查看冲突文件。
2. 打开文件，查找 `<<<<<<<`、`=======`、`>>>>>>>` 标记，结合两边意图编辑为最终内容并删除标记。
3. 检查改动：`git diff`。
4. 标记已解决：`git add <文件>`。
5. 继续当前操作：合并通常执行 `git commit`；变基执行 `git rebase --continue`。

```bash
git rebase --abort       # 放弃本次变基，回到开始前状态
git merge --abort        # 放弃尚未完成的合并
```

只有在确认某文件应完整采用某一侧时才使用 `git checkout --ours/--theirs` 一类整文件选择；变基期间 ours/theirs 的指向容易与直觉不同，选择后务必检查内容。

## 8. 撤销、恢复与找回

先用 `git status` 判断内容在哪一层，再选择命令。撤销命令影响范围不同，操作前应确认目标文件或提交。

### 工作区改动

```bash
git restore <文件>                 # 丢弃文件未暂存改动
git restore .                      # 丢弃当前目录下所有未暂存改动
git restore --source=<commit> -- <文件> # 从指定提交恢复文件内容
```

丢弃工作区修改通常无法从 Git 历史找回；需要保留时先复制文件或使用 stash。

### 暂存区改动

```bash
git restore --staged <文件>
git restore --staged .
```

这只取消暂存，工作区内容仍保留。

### 撤销已提交内容

```bash
git revert <commit>            # 新建一个反向提交，适合已共享历史
git revert <commit1>..<commit2> # 反向撤销范围内提交（不含起点）
```

`revert` 保留原历史，通常是撤销公共分支提交的首选。合并提交的 revert 需要明确主线父提交（`-m`），执行前确认影响。

### 移动分支指针

```bash
git reset --soft <commit>  # 移动 HEAD，改动保留在暂存区
git reset --mixed <commit> # 默认模式，改动保留在工作区并取消暂存
git reset --hard <commit>  # 同时丢弃目标提交之后的跟踪文件改动
```

`reset` 会改写当前分支历史。`--hard` 可能永久丢失未提交改动，也可能让已推送提交与远端分叉；确认目标并检查备份后使用。撤销公共历史优先考虑 `revert`。

### 找回误操作前的提交

```bash
git reflog
```

reflog 记录本地 HEAD 和分支引用近期变动。找到目标哈希后，可先创建恢复分支：

```bash
git branch recovery/<name> <commit>
```

reflog 通常只在本地保留一段时间，且不能保证找回从未提交、也未被其他工具保存的内容。

## 9. 暂存工作区

临时切换任务时保存工作区：

```bash
git stash push -m "说明"
git stash push -u -m "包含未跟踪文件"
git stash list
git stash show -p stash@{0}
git stash apply stash@{0}   # 应用但保留 stash
git stash pop               # 应用并在成功后删除 stash
git stash drop stash@{0}
```

`stash` 默认不包含未跟踪文件；需要时加 `-u`。应用后出现冲突时按普通冲突流程处理。确认内容已恢复后再删除 stash。

## 10. 标签与版本发布

```bash
git tag                         # 列出标签
git tag -a v1.2.0 -m "版本 1.2.0" <commit>
git show v1.2.0
git push origin v1.2.0
git push origin --tags
```

删除标签：

```bash
git tag -d v1.2.0
git push origin --delete v1.2.0
```

发布标签通常指向稳定提交。推送所有标签会把本地所有标签发到远端，团队流程要求只推特定标签时使用单标签推送。

## 11. 文件忽略与跟踪控制

在 `.gitignore` 中写入规则，例如：

```gitignore
.DS_Store
build/
*.log
.env
!important.env.example
```

`.gitignore` 只影响未跟踪文件。已被跟踪的文件需要从索引移除后，忽略规则才会生效：

```bash
git rm --cached <文件>
git rm -r --cached <目录>
```

上述操作保留本地文件，但会在下次提交中记录删除。提交前确认团队是否希望移除跟踪。

仅在本机忽略某文件的后续变化，可使用索引标记：

```bash
git update-index --skip-worktree <文件>
git update-index --no-skip-worktree <文件>
git ls-files -v | grep '^S'
```

`skip-worktree` 不是团队共享的忽略规则，也不适合长期绕过团队文件更新；它可能让本地版本与仓库版本不一致。需要取消时先执行 `--no-skip-worktree`，再检查状态。另有 `assume-unchanged`，主要用于性能提示，不应当作可靠的本地忽略机制。

查看某文件为什么被忽略：

```bash
git check-ignore -v <文件>
```

## 12. 常用工作流

### 功能分支开发

```bash
git switch main
git pull --ff-only
git switch -c feature/<名称>
# 编辑文件
git status
git diff
git add -p
git diff --staged
git commit -m "实现某项功能"
git push -u origin feature/<名称>
```

随后通过团队采用的代码评审流程合并。合并完成后可清理本地分支：

```bash
git switch main
git pull --ff-only
git branch -d feature/<名称>
```

### 更新开发分支

```bash
git fetch origin
git switch feature/<名称>
git rebase origin/main
```

若分支已推送且此前提交被改写，需要与协作者协调后再用 `git push --force-with-lease` 更新远端。

### 只提交部分修改

```bash
git add -p
git diff --staged
git commit -m "提交说明"
```

按提示选择每个修改块，适合把无关变更拆成独立提交。

## 13. 常见问题排查

### 当前目录是不是仓库？

```bash
git rev-parse --show-toplevel
git status
```

### 当前分支跟踪哪个远端？

```bash
git branch -vv
git status -sb
```

### 远端地址或分支不对？

```bash
git remote -v
git branch -r
git remote show origin
```

### 推送提示 non-fast-forward

先执行 `git fetch` 并查看 `git log --oneline --left-right HEAD...@{upstream}`，确认双方提交，再按团队要求执行 merge 或 rebase。不要未经检查直接强推。

### 撤销了不该撤销的提交

立即查看 `git reflog`，找到操作前的提交并创建恢复分支；若工作区还有未提交修改，先复制或 stash 保存。

### 错误提交了文件或密钥

若只是尚未提交的暂存文件，可执行 `git restore --staged <文件>`。若已提交，删除当前版本并不能自动清除历史中的敏感信息：应立即轮换密钥，并按团队与托管平台流程清理历史、协调所有协作者。不要把真实凭据提交到仓库。

### 大小写重命名在某些文件系统上未被识别

```bash
git mv oldname tempname
git mv tempname OldName
```

### 解决冲突后仍显示未解决

确认冲突标记已经处理，再对每个文件执行 `git add <文件>`，最后运行 `git status`。

### 查看 Git 版本和帮助

```bash
git --version
git help <命令>
git <命令> -h
```

## 14. 安全习惯与速查

日常提交前：

1. `git status -sb` 确认分支和文件状态。
2. `git diff` 与 `git diff --staged` 检查实际内容。
3. 确认没有密钥、个人配置、构建产物或无关文件。
4. 共享分支优先用 `git revert` 撤销提交；改写历史前先确认分支是否已被他人使用。
5. 对 `reset --hard`、`clean`、强制推送等可能丢失内容或改写共享历史的操作，执行前先检查目标和备份。

| 目的 | 命令 |
| --- | --- |
| 查看状态 | `git status -sb` |
| 查看工作区差异 | `git diff` |
| 查看暂存差异 | `git diff --staged` |
| 分块暂存 | `git add -p` |
| 创建分支 | `git switch -c <分支>` |
| 获取远端更新 | `git fetch --all --prune` |
| 取消暂存 | `git restore --staged <文件>` |
| 丢弃未暂存改动 | `git restore <文件>` |
| 安全撤销已共享提交 | `git revert <commit>` |
| 找回引用历史 | `git reflog` |
| 保存临时改动 | `git stash push -u -m "说明"` |
| 安全强制更新个人远端分支 | `git push --force-with-lease` |

## 15. 忽略规则进阶与文件清理

### `.gitignore` 匹配规则

```gitignore
# 注释
*.log          # 匹配任意目录下的 .log 文件
/build/        # 仅匹配仓库根目录 build 目录
build/         # 匹配任意层级名为 build 的目录
!important.log # 重新纳入此前被忽略的文件
\#literal      # 以 # 开头的文件名
```

规则以 `.gitignore` 所在目录为基准；子目录的规则只影响该目录及其后代。`!` 只能重新纳入已被其他规则忽略的路径，但若父目录本身被忽略，通常需要先重新纳入父目录。检查规则来源：

```bash
git check-ignore -v --no-index <路径>
git status --ignored
```

忽略配置层次包括仓库 `.gitignore`（可提交共享）、`.git/info/exclude`（仅本仓库本机）、全局 excludes 文件（当前用户所有仓库）。查看全局配置位置：

```bash
git config --get core.excludesfile
```

### 清理未跟踪文件

```bash
git clean -n                 # 预览将删除的未跟踪文件
git clean -nd                # 预览未跟踪文件和目录
git clean -f                 # 删除未跟踪文件
git clean -fd                # 删除未跟踪文件和目录
git clean -fdx               # 也删除被忽略的文件
```

`git clean` 删除的内容通常不经过回收站，`-x` 会包括构建产物、忽略文件甚至本地配置。始终先用 `-n` 预览，确认路径后再执行。

## 16. 复制提交与拆分提交

### Cherry-pick

把其他分支的一个或多个提交应用到当前分支：

```bash
git cherry-pick <commit>
git cherry-pick <commit1> <commit2>
git cherry-pick <起点>..<终点>  # 不含起点，包含终点
```

冲突解决后执行 `git cherry-pick --continue`；放弃执行 `git cherry-pick --abort`。`-n` / `--no-commit` 可只应用改动而不立即生成提交。cherry-pick 会生成新的提交哈希，不会把原提交“移动”过来；避免在两条长期共享分支间反复复制同一提交。

### 拆分或整理提交

交互式变基可修改最近提交：

```bash
git rebase -i HEAD~3
```

常用动作：`pick` 保留、`reword` 修改说明、`edit` 暂停以修改提交、`squash` 合并且编辑说明、`fixup` 合并并丢弃当前说明、`drop` 删除提交。完成编辑后按提示继续。交互式变基会改写提交历史，只用于自己控制的提交；共享分支使用前先与协作者协调。

## 17. 定位回归：bisect

已知问题曾经不存在的提交和当前有问题的提交时，可二分定位引入问题的提交：

```bash
git bisect start
git bisect bad                 # 当前版本有问题
git bisect good <旧版本提交>   # 旧版本正常
# 在 Git 检出的中间版本上复现并标记
git bisect good
git bisect bad
git bisect reset               # 结束并回到原分支
```

也可用自动化脚本判断每个版本：`git bisect run <测试脚本>`。脚本返回 `0` 表示 good，`1` 至 `124` 表示 bad，`125` 表示该提交无法测试。开始前保存工作区改动；中间状态可能处于 detached HEAD。

## 18. Git Worktree：多工作目录

`git worktree` 让同一个仓库在磁盘上同时有多个工作目录，每个目录可以检出不同分支。适合正在做一个功能时，临时并行修复另一个分支的问题。它不复制一整份独立仓库；提交对象和分支信息仍由主仓库共用。

先查看当前仓库的工作目录：

```bash
git worktree list
```

### 例子：在旁边开一个目录修紧急问题

假设当前仓库目录是 `~/Projects/app`，当前正在 `feature/search` 分支开发；现在需要基于 `main` 开始修复登录问题。打开终端，先进入仓库目录：

```bash
cd ~/Projects/app
```

创建一个新目录 `~/Projects/app-hotfix`，并在里面新建分支 `hotfix/login`：

```bash
git worktree add -b hotfix/login ../app-hotfix main
```

这条命令各部分的意思是：

- `git worktree add`：增加一个独立的工作目录。
- `-b hotfix/login`：新建名为 `hotfix/login` 的分支，并在新目录中切换到它。
- `../app-hotfix`：新目录的位置。`..` 表示当前目录 `~/Projects`，所以结果是 `~/Projects/app-hotfix`。
- `main`：新分支从当前仓库已有的 `main` 分支开始。

进入新目录后，可以独立修改和提交：

```bash
cd ../app-hotfix
git status -sb
# 修改文件
git add Sources/LoginView.swift
git commit -m "fix: prevent login crash"
git push -u origin hotfix/login
```

原来的 `~/Projects/app` 仍然可以继续开发 `feature/search`。两个目录使用同一个仓库的提交历史，但各自有独立的文件和当前分支。

### 使用已经存在的分支

如果 `hotfix/login` 分支已经存在，并且当前没有在别的 worktree 中检出它：

```bash
cd ~/Projects/app
git worktree add ../app-hotfix hotfix/login
```

这里没有 `-b`，因为不创建新分支；命令直接把已有的 `hotfix/login` 分支检出到 `../app-hotfix`。

查看所有工作目录及其分支：

```bash
git worktree list
```

完成工作后，先确认新目录没有未提交改动，再从主仓库目录移除工作目录：

```bash
cd ~/Projects/app
git -C ../app-hotfix status -sb
git worktree remove ../app-hotfix
```

`worktree remove` 只移除这个额外工作目录，不会删除 `hotfix/login` 分支。若分支已合并且不再需要，再单独删除：

```bash
git branch -d hotfix/login
```

每个分支通常只能同时在一个 worktree 中检出。如果看到“already checked out”错误，先运行 `git worktree list` 找到该分支所在目录；进入那个目录继续工作，或先移除对应 worktree。不要用 `--force` 绕过检查，除非确认要丢弃该目录的未提交内容。


## 19. 子模块

子模块用于在一个仓库中引用另一个仓库的特定提交：

```bash
git submodule add <仓库地址> <路径>
git clone --recurse-submodules <主仓库地址>
git submodule update --init --recursive
git submodule status
git submodule update --remote <路径>
```

主仓库记录的是子模块提交指针，不是子模块文件内容。更新子模块后，通常需要在子模块目录提交并推送其变更，再回到主仓库提交新的指针。克隆后若看到子模块目录为空，运行 `git submodule update --init --recursive`。删除子模块要同时清理 `.gitmodules` 配置、索引和对应工作目录，按仓库实际状态操作，不要只删目录。

## 20. Git LFS

Git LFS 用指针文件管理大文件，实际内容存放在 LFS 服务端：

```bash
git lfs install
git lfs track "*.psd"
git add .gitattributes
git add artwork.psd
git lfs ls-files
git lfs pull
```

`.gitattributes` 应提交到仓库，让协作者使用相同规则。将已提交的大文件改为 LFS 跟踪，通常只影响之后的版本；若要迁移完整历史，需要 `git lfs migrate` 重写历史并协调所有协作者。LFS 存储和流量可能有配额限制，使用前确认托管平台策略。

## 21. 补丁与提交包

```bash
git format-patch -1 <commit>             # 导出提交为邮件格式补丁
git format-patch <base>..HEAD
git am <文件.patch>                       # 应用 format-patch 生成的补丁
git diff > changes.patch
git apply --check changes.patch           # 先检查能否应用
git apply changes.patch
git apply --reverse changes.patch         # 反向应用
git bundle create repo.bundle --all       # 打包仓库引用与对象
git bundle verify repo.bundle
git clone repo.bundle repo-copy
```

`format-patch` / `git am` 保留提交作者等信息，适合提交邮件式协作；`diff` / `apply` 传递文件差异，不会自动创建提交。补丁应用失败时检查基准版本和上下文，不要盲目使用 `--reject` 覆盖文件。

## 22. Hooks 与自动化

Git hooks 是特定操作前后执行的脚本，仓库默认钩子目录为 `.git/hooks/`。常见钩子包括 `pre-commit`、`commit-msg`、`pre-push`。钩子文件通常需要可执行权限；普通克隆默认不自动分发自定义 hooks，可通过团队约定的安装脚本或 `core.hooksPath` 管理。

```bash
git config core.hooksPath .githooks
```

`git -c core.hooksPath=/dev/null commit ...` 或 `--no-verify` 可绕过部分客户端钩子，但可能违反团队检查要求；只在明确理解原因并符合团队约定时使用。钩子不能替代服务端权限和 CI 检查。

## 23. 配置、别名与凭据

查看配置层级与来源：

```bash
git config --list --show-origin
git config --system --list
git config --global --list
git config --local --list
```

常见配置：

```bash
git config --global core.autocrlf input      # 常见于 macOS/Linux
# Windows 可按团队换行符策略使用 true 或 input
git config --global core.safecrlf warn
git config --global fetch.prune true
git config --global init.defaultBranch main
git config --global alias.st 'status -sb'
git config --global alias.lg 'log --graph --oneline --decorate --all'
```

行尾设置应遵从项目 `.gitattributes` 和团队规范，避免仅靠个人配置造成文件整批变化。别名可直接通过 `git st`、`git lg` 调用。

凭据优先交给系统凭据管理器、SSH agent 或托管平台官方 CLI。不要把密码、访问令牌写入仓库 URL、脚本、提交说明或 `.gitconfig`。SSH 连接问题可检查 `ssh -T <主机别名>`、公钥是否已登记以及 agent 是否加载密钥；HTTPS 鉴权失败则确认令牌权限、过期状态和凭据缓存。

## 24. 仓库检查与维护

```bash
git fsck --full                 # 检查对象数据库一致性
git count-objects -vH           # 查看对象数量和空间
git gc                          # 清理并压缩对象
git reflog expire --expire=now --all
git gc --prune=now
```

日常通常由 Git 自动维护，无需手动运行清理。立即过期 reflog 和 prune 可能永久移除可恢复对象，尤其不要把后两条作为常规命令执行。仓库损坏或体积异常时先备份完整仓库，再结合 `git fsck` 输出分析；不要在唯一副本上尝试破坏性修复。

查看对象或文件大小时可使用托管平台工具或专用分析工具。删除大文件的最新版本不等于清除历史对象；彻底移除需要重写历史并协调协作者重新同步。

## 25. Detached HEAD 与稀疏检出

检出某个提交而不是分支会进入 detached HEAD 状态：

```bash
git switch --detach <commit>
```

此时可以查看或测试历史版本；若要保留新提交，先创建分支：

```bash
git switch -c rescue/my-change
```

退出前确认需要的提交已有分支引用，否则切走后该提交可能不易找到（可用 reflog 恢复）。

大型单体仓库可只检出部分路径：

```bash
git sparse-checkout init --cone
git sparse-checkout set <目录1> <目录2>
git sparse-checkout list
git sparse-checkout disable
```

稀疏检出仅控制工作区显示的路径，不改变仓库中的提交内容；团队脚本或构建若依赖其他路径，需按需扩展检出范围。

## 26. 进一步的历史查询

```bash
git log --since="2 weeks ago" --author="姓名" -- path/to/file
git log --grep="关键词" --oneline
git log --all -- path/to/file
git rev-parse HEAD
git rev-parse --show-toplevel
git merge-base <分支1> <分支2>
git diff <分支1>...<分支2>     # 两分支共同祖先到右侧分支的差异
git ls-files
git ls-files -o --exclude-standard # 未跟踪且未忽略文件
```

Git 提交可用引用表达式：`HEAD~1` 表示第一父提交的上一个提交；`HEAD^` 表示第一父提交；合并提交的 `HEAD^2` 表示第二父提交。`A..B` 表示可从 B 到达而从 A 不可达的提交集合；`A...B` 在 diff 中表示共同祖先两侧的变化，语境不同含义也不同。

## 27. 操作风险速查

| 操作 | 主要影响 | 使用前检查 |
| --- | --- | --- |
| `git restore <文件>` | 丢弃工作区未暂存内容 | `git diff`，确认无需保留 |
| `git clean -fd` | 删除未跟踪文件和目录 | 先 `git clean -nd` |
| `git clean -fdx` | 还会删除被忽略内容 | 先确认本地配置和产物可重建 |
| `git reset --hard` | 移动分支并丢弃跟踪文件改动 | 保存工作区，核对目标提交 |
| `git rebase` | 重写提交哈希 | 确认提交未被他人依赖 |
| `git push --force-with-lease` | 改写远端分支 | 获取最新状态并通知协作者 |
| `git gc --prune=now` | 清除不可达对象 | 备份仓库，不作为常规维护 |

## 28. 按场景照着操作

以下示例假设远端名为 `origin`，主分支名为 `main`。先用 `git branch -vv` 和 `git remote -v` 确认项目实际名称，再替换示例值。

### 场景一：从零开始提交一个新文件

假设新增了 `README.md`，想创建第一个提交：

```bash
git init
git status -sb
git add README.md
git diff --staged
git commit -m "docs: add project readme"
```

`git status` 会先显示 `?? README.md`；执行 `git add` 后，状态会变成待提交的新增文件。若提交前发现暂存错了：

```bash
git restore --staged README.md
```

文件仍留在磁盘，只是从暂存区移出。

### 场景二：在功能分支开发并推送

```bash
git switch main
git pull --ff-only
git switch -c feature/login-error-message
# 编辑 Sources/LoginView.swift
git status -sb
git diff -- Sources/LoginView.swift
git add Sources/LoginView.swift
git diff --staged
git commit -m "fix: show login error message"
git push -u origin feature/login-error-message
```

第一次推送后，后续在这个分支上通常直接 `git push`。如果一次改了三个文件，只想提交其中一个，明确写文件名 `git add Sources/LoginView.swift`；想拆分同一文件里的不同修改，使用 `git add -p`。

### 场景三：提交前发现暂存了不该提交的文件

例如 `.env` 已暂存，但不应该进仓库：

```bash
git status --short
git restore --staged .env
printf '\n.env\n' >> .gitignore
git add .gitignore
git status --short
```

检查最终状态，确认 `.env` 不在待提交列表中。若 `.env` 以前已经提交过，单加 `.gitignore` 不会停止跟踪，需要先执行 `git rm --cached .env`，然后提交这一变更；文件会保留在本地。

### 场景四：只撤销一个文件的本地改动

假设 `README.md` 有不需要的未提交修改，但 `App.swift` 的改动要保留：

```bash
git status --short
git diff -- README.md
git restore -- README.md
git status --short
```

恢复前先复制或提交需要保留的内容。`git restore -- README.md` 会覆盖该文件未暂存的修改；它不会只撤销某一行。

若 `README.md` 已暂存，也想保留文件修改、仅取消暂存：

```bash
git restore --staged -- README.md
```

### 场景五：提交后发现说明写错，且尚未推送

```bash
git log -1 --oneline
git commit --amend -m "fix: correct login validation"
git log -1 --oneline
```

这会替换本地最近一次提交。若该提交已经推送且其他人可能基于它开发，应先协调；不要直接把普通 `git push` 报错当成强推理由。

### 场景六：已经推送的提交需要撤销

假设错误提交哈希为 `a1b2c3d`，且它已进入共享分支：

```bash
git log --oneline -5
git revert a1b2c3d
git status
git push
```

Git 会创建一个新提交，反向抵消该提交的改动，原提交仍留在历史中。若 revert 时有冲突，编辑冲突文件、`git add <文件>`，再执行 `git revert --continue`；放弃则 `git revert --abort`。

### 场景七：提交了两次，想合成一个提交

确认两次提交都只属于自己、还没有被他人拉取：

```bash
git log --oneline -3
git rebase -i HEAD~2
```

编辑器中会看到两行 `pick`。保留第一行为 `pick`，将第二行的 `pick` 改成 `squash`，保存退出后编辑合并后的提交说明。检查结果：

```bash
git log --oneline -3
git status -sb
```

如果这两次提交已经推送到共享分支，先与协作者协调；改写后远端更新会影响其他人的本地分支。

### 场景八：把另一个分支的单个修复拿过来

`feature/payment` 上有一个修复提交 `d4e5f6a`，要复制到当前的 `release/1.2`：

```bash
git switch release/1.2
git log --oneline feature/payment -5
git cherry-pick d4e5f6a
git log --oneline -3
```

若冲突：编辑文件解决，执行 `git add <文件>`，再执行 `git cherry-pick --continue`。不想继续则执行 `git cherry-pick --abort`。确认提交内容来自预期提交后再推送。

### 场景九：更新功能分支，处理冲突

假设 `feature/profile` 要更新到 `origin/main`：

```bash
git status -sb
git fetch origin
git switch feature/profile
git rebase origin/main
```

若 Git 报 `CONFLICT`：

```bash
git status
# 打开列出的文件，编辑并删除冲突标记
git diff
git add Sources/ProfileView.swift
git rebase --continue
```

若不想继续这次变基：

```bash
git rebase --abort
git status -sb
```

变基完成后若该分支以前推送过，推送前确认没有他人新提交；确需更新时用 `git push --force-with-lease`，并先与分支协作者沟通。

### 场景十：临时切换任务，保留未提交工作

```bash
git status -sb
git stash push -u -m "WIP profile screen"
git switch hotfix/crash-on-launch
# 完成紧急修复后
git switch feature/profile
git stash list
git stash apply stash@{0}
git status -sb
```

确认文件和修改都恢复后，再执行 `git stash drop stash@{0}`。如果 `apply` 后发生冲突，先解决冲突并确认内容；不要因为 stash 还在就重复 apply，以免重复应用修改。

### 场景十一：误删文件或误操作后找回提交

若文件已经提交过，恢复最近提交中的版本：

```bash
git restore --source=HEAD -- Sources/Settings.swift
```

若刚才误执行了 reset 或切错分支，先找回 HEAD 之前的位置：

```bash
git reflog --date=local -10
# 找到误操作之前的哈希，例如 9abc123
git branch recovery/before-reset 9abc123
git switch recovery/before-reset
```

先创建恢复分支，确认提交和文件都在，再决定如何合并回工作分支。若文件从未提交，也没有 stash、编辑器本地历史或备份，Git 通常无法恢复它。

### 场景十二：推送被拒绝

看到 `rejected` 或 `non-fast-forward` 时：

```bash
git status -sb
git fetch origin
git log --oneline --left-right HEAD...origin/$(git branch --show-current)
```

`<` 行是仅本地有的提交，`>` 行是仅远端有的提交。确认远端提交应保留后，按项目约定选择：

```bash
git rebase @{upstream}
# 或者按团队策略合并：
git merge @{upstream}
```

解决冲突并完成整合后再 `git push`。如果不确定哪些提交会被覆盖，暂停推送，先请熟悉该分支的人一起检查日志。

### 场景十三：找出哪次提交引入 bug

```bash
git bisect start
git bisect bad
git bisect good v1.4.0
```

Git 会检出中间提交。每次运行复现步骤后，标记当前版本：

```bash
git bisect good   # 当前版本没有 bug
git bisect bad    # 当前版本有 bug
```

重复直到 Git 找到引入问题的提交，记录结果，然后退出：

```bash
git bisect reset
```

如果项目有返回码明确的自动化检查，可用 `git bisect run ./scripts/check-regression.sh` 自动判定；脚本要能在旧版本上运行，且退出码需符合 bisect 约定。

### 场景十四：确认即将删除哪些未跟踪文件

```bash
git clean -nd
```

例如预览列出 `build/` 和 `tmp.log`，确认都可删除后再执行：

```bash
git clean -fd
```

如果还要删除被忽略的文件，先执行 `git clean -ndx` 看完整列表；确认没有 `.env`、本地证书或不可重建数据，再执行对应删除。不要跳过预览。

### 场景十五：从远端克隆并初始化子模块

```bash
git clone --recurse-submodules git@github.com:example/app.git
cd app
git status -sb
git submodule status
```

若已经普通克隆，补初始化：

```bash
git submodule update --init --recursive
```

主仓库更新子模块指针后，其他协作者拉取主仓库提交并运行 `git submodule update --init --recursive`，即可检出被记录的子模块版本。

### 场景十六：在另一个目录并行修复线上问题

当前目录正开发 `feature/search`，需要同时修复 `hotfix/login`：

```bash
git worktree add -b hotfix/login ../app-hotfix origin/main
cd ../app-hotfix
# 修复、提交并推送
```

完成后回原目录查看：

```bash
cd ../app
git worktree list
git worktree remove ../app-hotfix
```

先确认 hotfix 工作目录没有未提交工作再移除。若只需检出已有分支，可用 `git worktree add ../app-hotfix hotfix/login`。

### 场景十七：把大文件改为 LFS 跟踪

```bash
git lfs install
git lfs track "*.psd"
git add .gitattributes
git add Design/banner.psd
git status --short
git commit -m "chore: track design files with lfs"
git push
```

`git lfs track` 只配置后续加入的文件；已有历史中的大文件不会自动迁移。迁移历史会改写提交哈希，需要团队统一安排。

### 场景十八：安全地删除远端已合并分支

```bash
git switch main
git pull --ff-only
git branch --merged main
git branch -d feature/login-error-message
git push origin --delete feature/login-error-message
```

先确认分支确实已经合并且不再需要。`git branch -D` 会绕过“未合并”保护，本地分支可能包含唯一副本的提交，除非确认不要这些提交，否则不要使用。

---

相关笔记：[Git 使用记录](Git.md)
