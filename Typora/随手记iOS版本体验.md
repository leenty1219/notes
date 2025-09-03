# 随手记iOS版本体验

## 1 体验机型&版本

本次体检的机型为：iPhone 15 ProMax，App版本为：**App Store 13.2.25**

## 2 产品体验

### 2.1 基础功能

​	在未登录状态下，App主要包含了`首页`、`我的账本`、`账本模板`、`我的`四大模块。App核心主要是围绕记账功能展开。

### 2.2 首页

首页主要包含几大快内容：

* **搜索**

  不仅提供用户的账本内容，还会额外提供一些搜索推荐。

* **账本**

  展示最近的账本，还提供新建账本快捷入口。

* **消息**

  消息主要包含活动消息、系统通知。消息接收还支持分类开启/关闭。

* **推荐阅读**

  推荐阅读里面主要包含了使用技巧，今日分享，福利活动等。消息主要包含活动和系统通知。



`首页`作为用户进入App最快接触页面，为用户提供了快捷使用账本推荐。同时更广维度的搜索也能为用户提供更多的操作范围。

### 2.3 我的账本

账本分为**随手记账本**和**神象云账本**

账本分为`我创建`和`我参与`同时可以通过滑动快速切换。账本同样也支持搜索功能，此处的搜索框提示语为***搜索我的账本***，更细维度的提示搜索用途。

账本支持跨端使用和自部署。

随手记账本为本地存储

神象云账本为服务区存储，支持更多功能自定义配置。

#### 2.3.1 账本详情

账本支持多维度记录、分析

* 日期

  支持按日、周、月、年、日历统计。

* 趋势

  支持折线图、饼图来展示消费类型占比，以及收入/支持走势。

* 记账人

  合作账单还支持以记账人来统计

* 支出类型

​	支持支出渠道统计，微信、支付宝、银行卡等

......

账本在UI上展示非常多元，用户还支持自定义账本UI样式。支持用户以个人风格组合模块。

同时报表还支持以不同的风格导出。



账单支持添加家人/员工，可以与他人共建账本。

账单还支持添加机器人来自动化处理账单任务。

账本还支持日志记录，追踪每一笔支出/收入。避免误差不可回溯

账本支持流水删除后找回，防止误操作

账本支持封账来更好的周期控制和权限控制

账本还支持从第三方平台（微信、支付宝等）导入汇总

### 2.4 模版

模版主要分为推荐、家庭、个人、生意、爱好几大模块

社会各行各业总有不同的支出/收入项目。项目提供了不同的行业模版，可以让用户一键使用。

用户还可以根据模版内容进行微调，整体还是提供了更细维度覆盖更广人群使用。

### 2.5 我的

用户基础信息包含了头像，用户名，性别，生日，手机号

App还支持多种快捷登录方式：邮箱、微信、QQ、新浪微博、Apple ID

公司自建虚拟货币体系香蕉贝，可以用来购买账本、额外服务等。

为了差异同时提供了会员体系包含：

* 基础会员

  适合进阶个人/家庭记账用户，扩展基础的记账功能。基础会员也包含免广告特权。

* 专业会员

  是个小微企业，个体户等。

* 免广告会员

  免广告，提供纯净模式。

* 空间会员

  提升云账本的空间容量上限。



### 2.6 其他

1.iOS App还支持快捷指令一键记账，方便快速入账。

2.账本支持删除后回收，防止误操作导致账本丢失。

3.支持深色模式。

4.支持启动密码保护验证。

## 3.建议

### 3.1 内存泄漏

代码中存在部分内存泄漏

在`CometHomeAdManager.m`中，存在循环引用释放问题

```objc
- (void)setupAdManagerWithPositionID:(NSString *)positionID resultNum:(int)resultNum completion:(void(^)(NSArray<FDAdvertisementModel *> *modelArray))completion {
    self.adManager.showTimes = 0;
    __weak __typeof(self) weakSelf = self;
    self.adManager.requestOperation = ^(FDAdvertiseRequestHandler  _Nonnull handler) {
        [weakSelf downloadAdWithPositionID:positionID resultNum:resultNum completion:^(NSArray<FDAdvertisementModel *> *modelArray, BOOL success) {
            modelArray = [self sortAdModelArrayAndRemoveClosedModelWithAdModelArray:modelArray];
            weakSelf.adModelArray = modelArray;
            completion(modelArray);
            handler ? handler(modelArray.firstObject, success) : nil;
        }];
    };
    [self.adManager tryRequestAdResourceWithAdViewConfigModelComplete:^(FDAdvertiseResourceManager * _Nonnull manager) {
        
    } suspended:nil];
}
```

在`LocalImageLoader.m`中存在`CGImageRef`未释放

```objective-c
+ (UIImage *)addAccountBookCoverMasksWithOriginImage:(UIImage *)originImage {    
    CGFloat coverProportion = 50.0 / 68.0;
    CGSize imageSize = CGSizeMake(originImage.size.width * originImage.scale, originImage.size.height * originImage.scale);
    CGSize coverSize = CGSizeMake(imageSize.height * coverProportion, imageSize.height);
    CGRect drawRect = CGRectMake(0, 0, coverSize.width, coverSize.height);
    
    UIGraphicsBeginImageContextWithOptions(coverSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // 添加圆角mask
    CGRect leftMaskRect = CGRectMake(0, 0, coverSize.width / 2, coverSize.height);
    CGRect rightMaskRect = CGRectMake(coverSize.width / 2, 0, coverSize.width / 2, coverSize.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:leftMaskRect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(coverSize.width / 28, coverSize.width / 28)];
    [maskPath appendPath:[UIBezierPath bezierPathWithRoundedRect:rightMaskRect byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(coverSize.width / 7, coverSize.width / 7)]];
    [maskPath addClip];
    
    // 裁剪图片
    CGRect clipRect = CGRectMake((imageSize.width - coverSize.width) / 2, 0, coverSize.width, coverSize.height);
    CGImageRef clipImageRef = CGImageCreateWithImageInRect([originImage CGImage], clipRect);
    UIImage *clipImage = [UIImage imageWithCGImage:clipImageRef];
    [clipImage drawInRect:drawRect];
    
    // 添加光影层
    UIImage *overLayer = [UIImage imageNamed:@"icon_accountBookCover_customOverLayer"];
    [overLayer drawInRect:drawRect];
    
    CGContextRestoreGState(context);
    
    UIImage *coverImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coverImage;
}
```



