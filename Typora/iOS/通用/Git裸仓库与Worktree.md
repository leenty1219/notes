# 用裸仓库管理多个 Worktree

本文介绍一种本地工作流：用一个裸仓库存放 Git 数据，再为不同分支创建多个独立工作目录。适合在同一台电脑上同时开发多个分支，例如一个目录继续做功能，另一个目录紧急修复问题。

## 1. 先理解目录关系

假设项目名为 `app`，工作目录放在 `~/Projects`：

```text
~/Projects/app.git       裸仓库：保存 Git 提交、分支等数据，不直接编辑代码
~/Projects/app-main      main 分支的工作目录
~/Projects/app-hotfix    hotfix/login 分支的工作目录
```

两个工作目录共用 `app.git` 中的 Git 数据，但文件内容和当前分支各自独立。裸仓库不是工作目录；开发时进入 `app-main` 或 `app-hotfix`。

## 2. 从已有远端仓库创建裸仓库

以下例子使用 GitHub SSH 地址。将 `git@github.com:example/app.git` 替换成项目的实际仓库地址：

```bash
mkdir -p ~/Projects
git clone --bare git@github.com:example/app.git ~/Projects/app.git
```

`git clone --bare` 会把仓库克隆到 `app.git`，不创建普通的项目文件目录。克隆完成后检查仓库和分支：

```bash
git --git-dir=~/Projects/app.git remote -v
git --git-dir=~/Projects/app.git branch
```

`--git-dir=~/Projects/app.git` 告诉 Git：“要操作的仓库数据在这个裸仓库目录中。”这样可以从任意当前目录执行命令。

如果仓库还没有任何提交，通常还没有可供 worktree 检出的分支。先在普通仓库中创建并推送首个提交，再克隆为裸仓库；或先按项目初始化流程建立首个提交。

## 3. 创建 main 工作目录

```bash
git --git-dir=~/Projects/app.git worktree add ~/Projects/app-main main
```

参数解释：

- `worktree add`：为这个仓库增加一个工作目录。
- `~/Projects/app-main`：新工作目录的完整路径；项目文件会出现在这里。
- `main`：要在新目录检出的现有分支。

进入目录并确认状态：

```bash
cd ~/Projects/app-main
git status -sb
git branch --show-current
```

如果主分支叫 `master` 或其他名字，把命令末尾的 `main` 换成实际分支名。可以用 `git --git-dir=~/Projects/app.git branch` 查看裸仓库已有的本地分支。

## 4. 创建另一个分支的工作目录

从 `main` 新建 `hotfix/login` 分支，并把它检出到 `app-hotfix`：

```bash
git --git-dir=~/Projects/app.git worktree add -b hotfix/login ~/Projects/app-hotfix main
```

这条命令中：

- `-b hotfix/login`：创建新分支 `hotfix/login`。
- `~/Projects/app-hotfix`：新分支对应的工作目录路径。
- 最后的 `main`：新分支从 `main` 当前指向的提交开始。

进入新工作目录开发：

```bash
cd ~/Projects/app-hotfix
git branch --show-current
git status -sb
```

输出的当前分支应为 `hotfix/login`。在此目录中编辑、提交，不会改变 `app-main` 目录中未提交的文件内容：

```bash
# 以下以项目中确实存在的文件为例
git add Sources/LoginView.swift
git commit -m "fix: prevent login crash"
```

如果 `hotfix/login` 分支已经存在，不要加 `-b`，直接检出已有分支：

```bash
git --git-dir=~/Projects/app.git worktree add ~/Projects/app-hotfix hotfix/login
```

一个分支不能同时在两个 worktree 中检出。如果提示该分支已经被检出，先运行 `git --git-dir=~/Projects/app.git worktree list`，找到它所在的目录并到那里工作。

## 5. 获取远端更新和推送提交

裸仓库本身保存的是本地已有的 Git 数据。要获取远端的新提交，显式 fetch：

```bash
git --git-dir=~/Projects/app.git fetch origin
```

如果克隆时远端名称不是 `origin`，先检查：

```bash
git --git-dir=~/Projects/app.git remote -v
```

在工作目录中整合远端 `main` 的更新：

```bash
cd ~/Projects/app-main
git fetch origin
git merge origin/main
```

这里 `origin/main` 是最近一次 fetch 后本地记录的远端 main 状态。也可以按团队约定使用 `git rebase origin/main`；变基会重写当前分支自己的提交，已共享的提交不要随意变基。

推送当前修复分支：

```bash
cd ~/Projects/app-hotfix
git push -u origin hotfix/login
```

`origin` 是远端别名，`hotfix/login` 是要推送的本地分支。`-u` 会将它关联到远端同名分支；后续在该目录中通常可直接运行 `git push` 和 `git pull`。若 push 提示拒绝，先 fetch 并整合远端变化，不要直接强制推送。

## 6. 查看和清理工作目录

列出裸仓库关联的所有工作目录：

```bash
git --git-dir=~/Projects/app.git worktree list
```

完成某项工作后，先确认目录没有未提交内容：

```bash
git -C ~/Projects/app-hotfix status -sb
```

`-C` 表示先切换到指定目录再运行 Git 命令。确认提交已保存、目录中没有需要保留的改动后，移除额外工作目录：

```bash
git --git-dir=~/Projects/app.git worktree remove ~/Projects/app-hotfix
```

这只移除 `app-hotfix` 工作目录，不会删除 `hotfix/login` 分支。确认该分支已合并且不再需要后，才删除分支：

```bash
git --git-dir=~/Projects/app.git branch -d hotfix/login
```

如果 worktree 目录已经被手动删除，Git 可能还保留旧目录记录，可清理失效记录：

```bash
git --git-dir=~/Projects/app.git worktree prune
```

## 7. 从空仓库开始

裸仓库没有提交时，`main` 还没有提交可以检出。初次建项目可先用普通仓库创建首个提交，然后制作裸仓库：

```bash
mkdir -p ~/Projects/app-seed
cd ~/Projects/app-seed
git init -b main
printf '# App\n' > README.md
git add README.md
git commit -m "docs: initialize repository"
git clone --bare ~/Projects/app-seed ~/Projects/app.git
```

现在裸仓库已有 `main` 分支和首个提交，可以按前文创建工作目录：

```bash
git --git-dir=~/Projects/app.git worktree add ~/Projects/app-main main
```

之后可删除 `app-seed` 普通仓库，也可以保留作初始化副本；删除前确认裸仓库和工作目录都已能正常使用。

## 8. 常见误区

- 不要在 `app.git` 里编辑项目文件；它是裸仓库，没有普通工作区。
- `git worktree remove` 删除工作目录，不会自动删除对应分支。
- `git worktree add -b 分支名 路径 起点分支` 中的“起点分支”决定新分支从哪个提交开始；例如最后写 `main` 就从 main 开始。
- `git worktree add 路径 已有分支` 用于检出已存在分支；这时不要再加 `-b`。
- 路径是实际创建工作目录的位置。建议用清楚的绝对路径，避免不确定相对路径是相对于哪个目录。
- 裸仓库加 worktree 主要解决本机多分支并行工作。若将裸仓库放在多人共用服务器上，同时让服务或用户直接在其 worktree 中修改文件，需要额外设计权限、并发和部署流程；常规团队协作通常让每位开发者拥有自己的克隆，再通过远端仓库交换提交。

## 9. 实例：Nuke 项目的裸仓库与两个 Worktree

下面是一个实际的 iOS 开源项目示例：Nuke 是 Swift 图片加载项目，仓库里包含 `Package.swift`、`Nuke.xcodeproj`、`Sources/`、`Tests/` 和 `Demo/`。示例目录使用 `~/Desktop/ios-worktree-demo`。

### 9.1 裸克隆项目

先创建演示根目录，再将 Nuke 克隆为裸仓库，目标路径指定为根目录下的 `.git`：

```bash
mkdir -p ~/Desktop/ios-worktree-demo
git clone --bare https://github.com/kean/Nuke.git ~/Desktop/ios-worktree-demo/.git
```

`--bare` 表示此次克隆只建立 Git 仓库数据，不在根目录展开 `Package.swift`、`Sources/` 等项目文件。命令完成后，`ios-worktree-demo/.git/` 是裸仓库。

### 9.2 在根目录下创建 main 工作目录

进入演示根目录，再创建 `main` 工作目录：

```bash
cd ~/Desktop/ios-worktree-demo
git worktree add ./main main
```

第一个 `./main` 是要创建的文件夹路径；第二个 `main` 是要检出的已有分支。执行后，Nuke 的项目文件出现在 `ios-worktree-demo/main/`：

```text
ios-worktree-demo/
├── .git/                 裸仓库数据
└── main/                 main 分支工作目录
    ├── .git              一个指向 Git 管理数据的文本文件
    ├── Package.swift     Swift Package 配置
    ├── Nuke.xcodeproj/   Xcode 工程
    ├── Sources/          源码
    ├── Tests/            测试
    └── Demo/             示例应用
```

注意：`main/.git` 是一个小型指针文件，指向 `.git/worktrees/main/`。`.git/worktrees/main/` 里是这个工作目录的 Git 管理数据（如 `HEAD`、`index` 和路径记录），**不是项目源码**。源码、Xcode 工程和资源文件都在 `main/` 目录中。

### 9.3 用一条命令创建第二个工作目录

仍在 `ios-worktree-demo/` 根目录执行：

```bash
git worktree add ./main2
```

因为没有写现有分支或提交，Git 会根据路径最后一段 `main2` 自动新建同名分支，并从当前 `HEAD`（此例为 `main` 的提交）开始。执行后结构为：

```text
ios-worktree-demo/
├── .git/                 共用的裸仓库数据
├── main/                 检出 main 分支，包含完整项目文件
└── main2/                检出新建的 main2 分支，也包含完整项目文件
```

刚创建时，`main` 和 `main2` 指向同一个提交，所以两个目录中的文件内容相同；之后在其中一个目录编辑并提交，只会更新该目录检出的分支。另一个目录不会自动变化。

检查结果：

```bash
git worktree list
git -C ./main status -sb
git -C ./main2 status -sb
git -C ./main branch --show-current
git -C ./main2 branch --show-current
```

`worktree list` 会列出裸仓库、`main` 和 `main2`。两个工作目录分别显示当前分支 `main`、`main2`；新建后状态应干净。

### 9.4 打开 Xcode 工程

可以从任一工作目录打开同一份 Xcode 工程：

```bash
open ~/Desktop/ios-worktree-demo/main/Nuke.xcodeproj
open ~/Desktop/ios-worktree-demo/main2/Nuke.xcodeproj
```

两个路径对应两份工作区文件，因此可以分别打开并操作两个分支。Nuke 仓库也提供 Swift Package，可在对应目录中运行 Swift 工具链命令。

### 9.5 清理示例 Worktree

移除第二个工作目录前，先确认没有未提交修改：

```bash
git -C ~/Desktop/ios-worktree-demo/main2 status -sb
git -C ~/Desktop/ios-worktree-demo worktree remove ~/Desktop/ios-worktree-demo/main2
```

这会移除 `main2/` 工作目录和 Git 为它保存的管理数据；本地分支 `main2` 默认仍保留。确认不再需要分支时，才删除它：

```bash
git -C ~/Desktop/ios-worktree-demo branch -d main2
```

---

相关笔记：[Git 操作手册](Git操作手册.md)
