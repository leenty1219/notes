## 1. 交换方法

```objc
#import "UIViewController+Logging.h"
#import <objc/runtime.h>

@implementation UIViewController (Logging)

+ (void)load
{
		// +load 方法只会调用一次，线程安全不需要 dispatch_once
		// 注意也不能调用 [super load];
		// +initialize 需要 dispatch_once
    swizzleMethod([self class], @selector(viewDidAppear:), @selector(swizzled_viewDidAppear:));
}

- (void)swizzled_viewDidAppear:(BOOL)animated
{
    // 已经交换了方法，以自己的情况来确定是不是需要触发回原方法
    [self swizzled_viewDidAppear:animated];
    // 扩展的内容
    NSLog(@"%@", NSStringFromClass([self class]));
}

// originalSelector 原函数
// swizzledSelector 交换的目标函数
void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)
{
    // the method might not exist in the class, but in its superclass
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // 添加函数原函数（直接以交换函数来替换实现）
    // 这里如果已存在原函数，比如父类的函数回添加失败
    // 如果添加成功，就replace交换函数的实现为原函数
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    // the method doesn’t exist and we just added one
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
		    // 如果方法已存在，添加失败。那么就直接 exchange 两个方法
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}
```

## 2. 分类添加属性

```objectivec
@interface Person (Run)

@property (nonatomic, copy) NSString *name;

@end

// Person+Run.m  
static const char NameKey;

@implementation Person (Run)

- (void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, &NameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name
{
    return objc_getAssociatedObject(self,  &NameKey);
}
```

|策略类型|等效|
|---|---|
|`OBJC_ASSOCIATION_RETAIN_NONATOMIC`|`nonatomic & strong`|
|`OBJC_ASSOCIATION_COPY_NONATOMIC`|`nonatomic & copy`|
|`OBJC_ASSOCIATION_RETAIN`|`atomic & strong`|
|`OBJC_ASSOCIATION_ASSIGN`|`assign <不是基本类型，不安全>`|
|`OBJC_ASSOCIATION_COPY`|`atomic & copy`|

> 由于`objc_setAssociatedObject` 只能绑定基本类型。所以如果要扩展 `int/float` 等类型，需要包装为`NSNumber`对象来处理