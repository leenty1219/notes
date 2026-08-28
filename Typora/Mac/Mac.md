### 1. 安装任何来源

```bash
sudo spctl --master-disable
```

### 2. Xcode 描述文件地址

`~/Library/MobileDevice/Provisioning Profiles`

### 3. 重新加载环境

```bash
source "$HOME/.cargo/env”
```

## 4. Xcode 历史版本安装

## 5. 改键宏

[在线改键](https://www.caniusevia.com/)

键盘定义：[https://docs.qmk.fm/keycodes](https://docs.qmk.fm/keycodes)

 [https://docs.qmk.fm/keycodes_basic](https://docs.qmk.fm/keycodes_basic)

## 6. 定时休眠

`sudo shutdown -s +23`

## 7. Speeder

**为防止域名被墙导致无法打开官网，请务必收藏[website@speeder.eu.org]([mailto:website@speeder.eu.org](mailto:website@speeder.eu.org)?subject=%E6%9F%A5%E8%AF%A2Speeder%E6%9C%80%E6%96%B0%E7%BD%91%E5%9D%80&body=%E6%9F%A5%E8%AF%A2Speeder%E6%9C%80%E6%96%B0%E7%BD%91%E5%9D%80)，发送任意邮件即可获得Speeder可用网址。（如果长时间未得到回复，请更换邮箱再试）**

**官网地址：[](https://www.speeder.cfd/)[https://www.speeder.cfd](https://www.speeder.cfd)**

**备用地址一：[](https://panel.speeder.cfd/)[https://panel.speeder.cfd](https://panel.speeder.cfd)**

**备用地址二：[](https://www.speeder.eu.org/)[https://www.speeder.eu.org](https://www.speeder.eu.org)**

**备用地址三：[](https://panel.speeder.eu.org/)[https://panel.speeder.eu.org](https://panel.speeder.eu.org)**

**备用地址四：[](https://www.speeder.click/)[https://www.speeder.click](https://www.speeder.click)**

**备用地址五：[](https://panel.speeder.click/)[https://panel.speeder.click](https://panel.speeder.click)**

**备用地址六：[](https://speeder.mobilegameanalysis.art/)[https://speeder.mobilegameanalysis.art](https://speeder.mobilegameanalysis.art)**

**备用地址七：[](https://45.62.117.198:10520/)[https://45.62.117.198:10520](https://45.62.117.198:10520)**

**备用地址八：[](https://45.62.117.198:10521/)[https://45.62.117.198:10521](https://45.62.117.198:10521)**

**备用地址九：[](https://98.126.19.75:10520/)[https://98.126.19.75:10520](https://98.126.19.75:10520)**

**请收藏 [](https://speeder.pages.dev/)[https://speeder.pages.dev](https://speeder.pages.dev) 和 [](https://go.speeder.pp.ua/)[https://go.speeder.pp.ua](https://go.speeder.pp.ua)，打开可自动跳转可用网址**

## 8. Github配置snippets和Dash

[https://github.com/leenty1219/notes](https://github.com/leenty1219/notes)

## 9. 修改Build号

需要放在**Compile Sources**之前执行

```bash
#!/bin/bash
# 每次编译的时候修复 build 号为当前时间
currentDate=$(date "+%Y%m%d%H%M")
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $currentDate" "$INFOPLIST_FILE"
```

## 10. Rswift

需要放在**Compile Sources**之前执行

Input Files 需要输入`$TEMP_DIR/rswift-lastrun`

Output Files 输入 `$SRCROOT/Locate/Others/R.generated.swift`

```bash
"$PODS_ROOT/R.swift/rswift" generate "$SRCROOT/Locate/Others/R.generated.swift"
# 自动执行 SwiftLint 的修复
#cd $PODS_ROOT
#cd ..
#swiftlint --fix
```

![image.png](attachment:a4952b51-5fa7-43aa-85c7-57b6f7954f98:image.png)

## 11.Rss

地址：[https://feeder.co/reader](https://feeder.co/reader)

## 12. 字体库

### 12.1.fira code

### 12.2.maple-font 
[下载地址](https://github.com/subframe7536/maple-font/blob/variable/README_CN.md](https://github.com/subframe7536/maple-font/blob/variable/README_CN.md)

## 12.安装鼠须管
brew install squirrel-app

## 13.截图软件

[Snapzy](https://github.com/duongductrong/Snapzy)

## 14.我的软件

BBEdit、Woodpeker、Xcode、Xcodes、VSCode、Lookin、Typora、ImageOptim、Proxyman、Alfred、IINA、Codex、SnippetsLab、Things、Fork、Dash、clang-format、SwiftFormatter、爱思助手、IDAPro、Bob、Beyond Compare、Bitwarden、iShot Pro、KaleiDoscope、Typinator(snippets)、espanso(snippets)

Stacher7 SnapZy Clock BleUnlock Umbra 



herdr：一个终端的agent集合

EdgeEver：自部署的免费笔记软件

## 15 配置本机Claude

```bash
export ANTHROPIC_BASE_URL=http://172.22.151.244:3030   #配置自定义的url
export ANTHROPIC_API_KEY=xxx #配置api key
export ANTHROPIC_MODEL=glm-5.2 # 配置模型名称
#目录未知
/Users/sui/.claude/setting.json
#更新环境生效
source ~/.zshrc
source ~/.bash_profile
source ~/.bashrc

#codex figma登录
codex mcp login figma
```

## 16 配置GitHub Copilot CLI 支持DeepSeek

参考[链接](https://api-docs.deepseek.com/zh-cn/quick_start/agent_integrations/copilot_cli/)

```bash
npm install -g @github/copilot
export COPILOT_PROVIDER_TYPE=anthropic
export COPILOT_PROVIDER_BASE_URL=https://api.deepseek.com/anthropic
export COPILOT_PROVIDER_API_KEY=sk-your-deepseek-api-key
# 模型名称
export COPILOT_MODEL=deepseek-v4-pro
# 限制模型最大token数量
export COPILOT_PROVIDER_MAX_PROMPT_TOKENS=840000
#注意：提示词仍会发送到 api.deepseek.com — 离线模式仅阻止 GitHub 的 API 调用
export COPILOT_OFFLINE=true

#检查环境
copilot help providers
```

## 17 GitNexus

```bash
# 安装
npm install -g gitnexus
# 对项目索引

# --embeddings 启用语义搜索
# --skills 把 Leiden 算法识别的每个功能社区生成独立的 SKILL.md，写到 .claude/skills/generated/<area>/，让 Claude Code 在不同模块工作时拿到精准的局部架构上下文
# --verbose 打印被跳过的文件，方便诊断索引覆盖率
gitnexus analyze --embeddings --skills --verbose

gitnexus list      # 查看所有已索引的仓库
gitnexus status    # 查看当前仓库索引状态

# 启动本地 HTTP 服务来浏览图谱：
gitnexus serve
# 如果你不想长期占着一个终端，可以把服务放到后台：
nohup gitnexus serve > ~/.gitnexus/serve.log 2>&1 &

# 需要停止时执行 
pkill -f "gitnexus serve" 
#或 
lsof -ti:4747 | xargs kill。
```

