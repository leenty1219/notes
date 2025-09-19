## 1.自定义弹框底部
```swift
// 掉起弹框
SCCommonViewPopManager.shareInstance().pop(with: sheet, canClickBgDismiss: true)

// 内嵌的view要调用一下
func adjustContentSize() {
        let size = self.systemLayoutSizeFitting(CGSize(width: pv_ScreenWidth(), height: 0),
                                                 withHorizontalFittingPriority: .required,
                                                 verticalFittingPriority: .fittingSizeLevel)
        self.frame.size = size
    }
```
## 2.获取本地账本月开始于
```objc
id<SettingService> settingService = [[BusinessFactory sharedInstance] settingService];
CalendarStartSettingVo *calendarStartSetting = [settingService calendarStartSetting];
NSInteger startDay = calendarStartSetting.monthStart; // 当前账本设置的起始日
```
## 3.获取月起始时间&周起始时间
```objc
id<SettingService> settingService = [[BusinessFactory sharedInstance] settingService];
NSInteger monthStart = [[settingService calendarStartSetting] monthStart];
NSInteger monthStart = [[settingService calendarStartSetting] monthStart];
```
## 4.获取当前账本

```objc
/// 获取神象云账本
SuiCloudAccountBookKit.sharedAccountBookKit.accountBookManager.currentAccountBook
/// 获取本地账本
id<AccountBookService,AccountBookInnerService> accountBookService = [AccountBookBusinessFactory accountBookService];

AccountBookVo * accountBookVo = [accountBookService currentAccountBook];
```
## 5.Toast
```objc
// loading
[SMUIToast showIndicator];
[SMUIToast dismiss];
// message
[SMUIToast showTitleAtCenterForAWhile:@"message"];
```
## 6.获取当前用户信息
```objc
// 这个地方一个账本一个profile，是本地账本数据
id<SettingService> settingService = [[BusinessFactory sharedInstance] settingService];

[settingService currentUserProfile];
```
## 7.设置神象云账本自定义周期
神象云账本自定义周期和本地账本的月开始于是2个独立的功能，具体逻辑按下面的处理：
![[Pasted image 20250918101237.png]]
## 8.