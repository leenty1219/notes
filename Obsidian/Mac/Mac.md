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

[https://docs.qmk.fm/keycodes](https://docs.qmk.fm/keycodes) [https://docs.qmk.fm/keycodes_basic](https://docs.qmk.fm/keycodes_basic)

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