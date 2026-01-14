## 1.自定义弹框底部
也可以参考自定义周期`SCCustomPeriodSelectView`的实现
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
## 8.自定义事件上报
```objc
// View事件

[PersonalUserBehaviorGatheringServiceInstance logBusinessIDForView: @"随手记新首页_浏览" extraValue:nil];
// 点击事件
 [PersonalUserBehaviorGatheringServiceInstance logBusinessIDForClick: @"账本管理首页_全局搜索框" extraValue: logDic.toJSONString];
 // 离开事件
 - (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];

    if (_enterTimeInterval && _enterTimeInterval != 0) {

        NSInteger stayTime = ([[NSDate new] timeIntervalSince1970] - _enterTimeInterval) * 1000;

        NSDictionary *customValue = @{

            @"time_op" : [NSString stringWithFormat:@"%@", @(stayTime)]

        };

        [SuiCloudUserBehaviorGatheringServiceInstance logBusinessIDForLeave:@"图表设置页_离开" extraValue:[customValue toJSONString]];

    }

}
// 云账本
[SCNewbieGuideManager.sharedManager logDemoBookForViewIfNeed:@"神象云演示账本首页" customValue:nil];
RecordTracer.kingLogPrint("随云保存记一笔发送请求日志 \(#function) save record failed, self:\(String(describing: self)), containerDelegate:\(String(describing: self?.containerDelegate)), transaction:\(String(describing: transaction))")

                RecordTracer.kingLogPrint("save record failed")
```
## 9.依赖更新
```bash
## pod更新

| --verbose 是输出详细信息

pod install --verbose
## carthage
carthage update --platform iOS --use-xcframeworks --no-use-binaries
## 不更新仓库
pod install --no-repo-update
## 添加本地自定义库到本地
pod repo add custom-repo git@m.sui.work:componentization/CocoaPodSpec.git

// 指向一个未提交的
git "git@m.sui.work:iOS/component/smuikit.git" "2a76e855098ec56dfcbd2142a976bef10f9f1852" #~> 2.0
// 拉取某个依赖
carthage update smuikit --platform iOS --use-xcframeworks
```
## 10.判断是否Pro版本
```objc
#ifdef PRO_VERSION

    if ([[FDServerDomainManager shareInstance] isProductServerEnvironment]) {

        return [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MCNTabDefaultConfigProVersion" ofType:@"geojson"]];

    } else {

        return [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MCNTabDefaultConfigTestVersionProVersion" ofType:@"geojson"]];

    }

#else

    if ([[FDServerDomainManager shareInstance] isProductServerEnvironment]) {

        return [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MCNTabDefaultConfig" ofType:@"geojson"]];

    } else {

        return [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MCNTabDefaultConfigTestVersion" ofType:@"geojson"]];

    }

#endif
```
## 11.SUISocialComponent 内网pod发布
```bash
# lint 验证
pod spec lint SUISocialComponent.podspec --allow-warnings --verbose

# pod repo 发布
pod repo push sui-componentization-cocoapodspec SUISocialComponent.podspec --allow-warnings --verbose --skip-import-validation
# SUISocialComponent.podspec

Pod::Spec.new do |spec|
  spec.name         = "SUISocialComponent"
  spec.version      = "1.0.0"
  spec.summary      = "..."
  spec.homepage     = "..."
  spec.license      = { :type => "MIT" }
  spec.author       = { "You" => "you@example.com" }
  spec.source       = { :git => "git@git.mycompany.com:SUISocialComponent.git", :tag => spec.version.to_s }
  spec.platform     = :ios, "12.0"

  spec.source_files = "SUISocialComponent/**/*.{h,m,swift}"

  # vendored framework
  spec.vendored_frameworks = [
    "SUISocialComponent/XiaoHongShu/XiaoHongShuOpenSDK.xcframework",
    "SUISocialComponent/Tencent/TencentOpenAPI.framework"
  ]

  # ⚠️ 关键：排除模拟器架构
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 x86_64'
  }
  spec.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 x86_64'
  }
end


#更新本地的源 
pod repo update sui-componentization-cocoapodspec //  SUISocialComponent本地源的名称
pod repo list // 查看本地的源列表

```
## 12.YPNavigation
```objc
typedef NS_ENUM(NSUInteger, YPNavigationBarConfigurations) {
    /*
     *  是否隐藏 navigation bar，默认是 show。
     */
    YPNavigationBarShow   = 0,
    YPNavigationBarHidden = 1,
    /*
     *  YPNavigationBarStyleLight = UIbarStyleDefault
     *  YPNavigationBarStyleBlack = UIbarStyleBlack
     *
     *  bar style 会影响 status bar 的样式，为 black 的时候 status bar 是白色，light 的时候是黑色。
     *  当没有自定义 background color 和 background image 的时候，navigation bar 的颜色也由 bar style 决定
     *  另外如果没有提供有效的 tintColor，YPNavigationBarTransition 将根据 bar style 自动设置 tintColor
     */
    YPNavigationBarStyleLight = 0 << 4,  // UIbarStyleDefault
    YPNavigationBarStyleBlack = 1 << 4,  // UIbarStyleBlack
    /*
     *  translucent = 半透明，transparent = 全透明，opaque = 不透明
     */
    YPNavigationBarBackgroundStyleTranslucent = 0 << 8,
    YPNavigationBarBackgroundStyleOpaque      = 1 << 8,
    YPNavigationBarBackgroundStyleTransparent = 2 << 8,
    /*
     *  使用颜色或者图片来配置 navigation bar 的 background image
     */
    YPNavigationBarBackgroundStyleNone  = 0 << 16,
    YPNavigationBarBackgroundStyleColor = 1 << 16,
    YPNavigationBarBackgroundStyleImage = 2 << 16,
    YPNavigationBarConfigurationsDefault = 0,
    /*
     *  是否显示 UINavigationBar 下方的横线，默认不显示
     *  在全透明 （Transparent） 的时候，将忽略 shadow image 的设置
     */
     YPNavigationBarShowShadowImage = 1 << 20,
};

- (YPNavigationBarConfigurations) yp_navigtionBarConfiguration;

// TintColor
- (UIColor *) yp_navigationBarTintColor;

// BackgroundColor
- (UIColor *) yp_navigationBackgroundColor;


遵守 <YPNavigationBarConfigureStyle> 协议



eg.
// 注意如果需要修改导航栏的颜色，需要调用

mmui_setNavigationBarBackgroundColor

- (YPNavigationBarConfigurations)yp_navigtionBarConfiguration {
    return YPNavigationBarBackgroundStyleColor | YPNavigationBarShow | YPNavigationBarBackgroundStyleOpaque;;
}

- (UIColor *)yp_navigationBackgroundColor {
    return SuiDynamicColor(UIColor.whiteColor, [UIColor colorWithHexString:@"#1C1C1E"]);
}

- (UIColor *)yp_navigationBarTintColor { 
    return SuiDynamicColor(UIColor.redColor, UIColor.blueColor);
}
```
## 13.暗黑适配标准
* 前面是亮色，后面是暗色
`SuiDynamicColor(UIColor.whiteColor, UIColor.blackColor)；`
[figma](https://www.figma.com/design/ZfvmUnWkjnROsWd7CN3qKg/%F0%9F%8C%9F%E7%A5%9E%E8%B1%A1%E4%BA%91%E7%BB%84%E4%BB%B6-%E9%A2%9C%E8%89%B2-%E5%AD%97%E4%BD%93-%E5%9B%BE%E6%A0%87%E8%A7%84%E8%8C%83?node-id=15987-7821&p=f&m=dev)
## 14.图片tintColor
```objc
let image = UIImage(named: "v12_navBar-more")?.sui_image(withTintColor: UIColor(hexString: "#AAAAAA"))
```
## 15.Toast
```objc
SMUIToast.showTitleAtCenter(forAWhile: "封账成功")
// loading

 SMUIToast.showIndicator()

 SMUIToast.dismiss()
```
## 16.Router
```objc
// 注册类
[SuiRoutes addPageClass:[MessageCenterHomeVC class] routePattern:MessageCenterHomeURLPattern];
// 跳转
 [SuiRoutes showPageWithURL:[NSURL sui_routeURLWithRoutePattern:MessageCenterHomeURLPattern]];
```
## 17.Mj刷新
```objc
        CustomRefreshHeader *header = [CustomRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeaderAction)];

        header.showRetry = YES;

        header.hideTipsView = YES;

        [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];

        [header setTitle:@"下拉刷新" forState:MJRefreshStatePulling];

        [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];

        _collectionView.mj_header = header;

        MJRefreshAutoNormalFooter *mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{

            [weakSelf requestMoreFeeds];

        }];

        mj_footer.refreshingTitleHidden = YES;

        mj_footer.triggerAutomaticallyRefreshPercent = -13;

        mj_footer.backgroundColor = SuiDynamicColor([UIColor colorWithHexString:@"#F5F5F5"], UIColor.blackColor);

        [mj_footer setTitle:@"" forState:MJRefreshStateIdle];

        [mj_footer setTitle:@"" forState:MJRefreshStatePulling];

        _collectionView.mj_footer = mj_footer;

        _collectionView.mj_footer.hidden = YES;
```
## 18.Alert弹框
```objc
SMUIAlertView *theAlert = [[SMUIAlertView alloc] initWithTitle:@"版本更新"
                                                                  message:@"发现新版本，是否更新随手记呢～"
cancelButtonTitle:@"取消"
otherButtonTitles:@"确定", nil];
```
## 19.登录状态
```objc
- (BOOL)isLogin {

    id<UserCenterProtocol> userService = [[SuiModuleProviderManager sharedManager] moduleSeriveWithProtocol:@protocol(UserCenterProtocol)];

    return [userService isSignedIn];

}
// 去登录
/// 显示登录页
- (void)showLoginViewController {

    [SuiRoutes showPageWithURL:[[NSURL sui_routeURLWithRoutePattern:UserCenterLoginURLPattern] sui_routeURLByAppendingQueryPresent] userInfo:@{UserCenterLoginDelegateQueryKey: self}];
```
## 20.网络请求
```objc
/// 查询首页信息流运营位 http://yapi.sui.work/project/626/interface/api/184082

- (void)queryFeedOperationWithIsNeedMonthCardStyle:(BOOL)isNeedMonthStyle

                                   isNeedShareData:(BOOL)isNeedShareData

                                        completion:(void (^)(HomeFeedOperation *operation, NSError *error))completion {

    NSDictionary *parameters = @{@"include_message_box_log_style": @(isNeedMonthStyle),

                            @"include_share_data": @(isNeedShareData)};

    NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionary];

    requestHeaders[@"Content-Type"] = @"application/json";

    RESTClient *restClient = [RESTClient authClientWithBaseURLString:self.domainString];

    [restClient POST:@"/cab-message-ws/terminal/widgets/v2/homepage/infoFlow/operation" timeout:5 headers:requestHeaders parameters:parameters parameterEncoding:HTTPParameterJSONEncoding success:^(id operation, id responseObject) {

        HomeFeedOperation *result;

        if ([responseObject isKindOfClass:[NSData class]]) {

            id dictData = [responseObject toJSONObject];

            if ([dictData isKindOfClass:[NSDictionary class]]) {

                HomeFeedOperation *operation = [HomeFeedOperation new];

                [operation configWithDict:dictData];

                [[HomePageViewCacheManager shared] setCacheForOperation:operation];

                result = operation;

            }

        }

        completion ? completion(result, nil) : nil;

    } failure:^(id operation, NSError *error) {

        completion ? completion(nil, error) : nil;

    }];

}
```
## 21.网络错误提示
`SMUIToast.showTitleAtCenter(forAWhile: err.localizedDescription)`
## 22.修改首页日历卡片

在`CometHomeViewController`的`- (void)loadXMLData:(NSData *)xmlData`中遍历Node去找到日历CCalendarNode修改`time_range`属性来请求时间范围。
```objc
- (void)fetchWithDatasourceNode:(CDataSourceNode *)dsNode accountBookID:(NSString *)accountBookId atGroup:(dispatch_group_t)group completeHandler:(void(^)(CBindingData * _Nullable bindingData, NSData * _Nullable jsonData)) completion {

    dispatch_group_enter(group);

    QueryNode *queryNode = dsNode.queryNode;

    NSAssert(accountBookId, @"账本 ID 不能为空");

    NSString *path = [CEDataSourceQueryRequest pathForVTable:dsNode.vtableName];

    id jsonQuery = queryNode.criteria;

    if (_timeRangeProvider) { // 外部提供代理处理自定义时间

        // change time range

        CEDataSourceQuery *query = [DSQModelFromJSON dsqFromJSONObject:queryNode.criteria];

        //  VC 提供过滤条件时改写时间，改写所有卡片的时间

        if([_timeRangeProvider currentTimeRange].isValid) {

            CETimeRange *newTimeRange = [_timeRangeProvider currentTimeRange];

            query.timeRange.column = query.timeRange.column ? query.timeRange.column : newTimeRange.column;

            query.timeRange.fromTime = newTimeRange.fromTime;

            query.timeRange.toTime = newTimeRange.toTime;

            query.timeRange.modeType = CETimeRangeModeAbsolute;

            jsonQuery = [query convertParameter];

        }

    }
}
```
## 23.代理忽略
```swift
timestamp.apple.com,sequoia.apple.com,seed-sequoia.siri.apple.com,172.16.*,172.17.*,172.18.*,172.19.*,172.2*,172.30.*,172.31.*,192.168.*,*.cn,*.apple.com,*.aliyun.com,*.work,*.ssjlicai.com,*.baidu.com,*.qq.com,*.yunzhijia.com,*.jetbrains.com,*.feidee.net,*.sui.com,*.sui.work,*.julicai.com,*.deepseek.com,*.doubao.com,*.feidee.com,*.pglstatp-toutiao.com
```

## 24.查询单条流水

```objc
id<SCTransactionService> transactionService;
if (bookID.length) {
    transactionService = [SCCommonRemoteServiceFactory.sharedFactory makeRemoteTransactionService:bookID];
} else {
    transactionService = [SCCurrentRemoteServiceFactory.sharedFactory makeRemoteTransactionService];
}
[transactionService queryTransactionWithID:transaction_id completion:^(SCTransaction * _Nullable transaction, NSError * _Nullable error) {
    [RecordTransactionRouter gotoEditRecordWith:self.navigationController transaction:transaction delegate:nil];
}];
```

## 25.查询多条流水<使用Filter>

```objc
id<SCSearchProtocol> accountBookService = [self makeSearchService];
__weak typeof(self) weakSelf = self;
NSNumber *pageOffset = [NSNumber numberWithInteger:self.transactionList.count];
NSNumber *size = [NSNumber numberWithInteger:kTransactionSearchSize];
[accountBookService searchTransactionWithFilter:_filter page:pageOffset size:size completion:^(NSArray<SCTransaction *> * _Nullable transactions, BOOL hasMore, NSError * _Nullable error)  {
    if(!error) {

    } else {

    }
}];
```

## 26.金额千分符号显示

```objc
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

self.incomeLabel.text = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:[income doubleValue]]];

- (NSNumberFormatter *)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.maximumFractionDigits = 2;
        _numberFormatter.minimumFractionDigits = 2;
    }
    return _numberFormatter;
}
```

## 27 fastlane 修改版本号和Build号

```shell
fastlane prompt_for_version_number # 执行成功后，会让你输入一个版本号
fastlane prompt_for_build_number # 执行成功后，会让你输入一个build号

# 测试来看似乎是修改plist文件来达到的，如果没有配置需求
#    <key>CFBundleShortVersionString</key>
#    <string>13.2.41</string>
#    <key>CFBundleVersion</key>
#    <string>12479</string>
#
#
```

```plist
<key>CFBundleShortVersionString</key>
<string>13.2.41</string>
<key>CFBundleVersion</key>
<string>12479</string>
```



## 28 sheet弹框

```objc
 SMUIActionSheet *actionSheet = [[SMUIActionSheet alloc] initWithTitle:NSLocalizedString(@"Detected accounting data on this device, whether to restore?", nil)
                                                                    style:SMUIActionSheetStyleForm];
    
    SMUIActionSheetAction *restoreAction = [SMUIActionSheetAction actionWithTitle:NSLocalizedString(@"Restore", nil)
                                                                            style:SMUIActionSheetActionStyleDefault
                                                                          handler:^{
        //用户点击恢复
        if (transactionVerifyWrongTimes < TransactionVerifyMaximumWrongTimes) {
            //还可以继续选流水, 跳转到选流水页面
            DeviceTransactionVerifyViewController *viewController = [DeviceTransactionVerifyViewController new];
            [self showController:viewController];
        } else {
            //提交用户信息验证
            NSString *title = NSLocalizedString(@"submit verify", nil);
            PersonalInfoVerifyTableHeaderView *tableHeaderView = [[PersonalInfoVerifyTableHeaderView alloc] init];
            PersonalInfoUploadViewController *uploadViewController = [[PersonalInfoUploadViewController alloc] initWithHeader:tableHeaderView submitButtonTitle:title];
            [self showController:uploadViewController];
        }
    }];
    [actionSheet addAction:restoreAction];
    
    SMUIActionSheetAction *cancelAction = [SMUIActionSheetAction actionWithTitle:NSLocalizedString(@"Cancel and delete all data", nil)
                                                                           style:SMUIActionSheetActionStyleCancel
                                                                         handler:^{
        //用户点击清空数据
        [[FDDeviceSyncAPIManager new] clearSyncedDataWithCompletionHandler:^(NSString *errorMessage) {
            if (errorMessage) {
                return;
            }

            [UserDefaultUtil setDeviceAccountState:DeviceAccountStateUnknown];
            [UserDefaultUtil resetTransactionVerifyWrongTimes];
            [FDDeviceStatusRefreshHelper refreshDeviceStatusWithCompletion:nil];
        }];
    }];
    [actionSheet addAction:cancelAction];
    
    [actionSheet showWithAnimated:YES];
```

