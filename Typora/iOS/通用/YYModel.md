# YYModel

## 1.Model与JSON互转

```objc
// JSON:
{
    "uid":123456,
    "name":"Harry",
    "created":"1965-07-31T00:00:00+0000"
}

// Model:
@interface User : NSObject
@property UInt64 uid;
@property NSString *name;
@property NSDate *created;
@end
@implementation User
@end

	
// 将 JSON (NSData,NSString,NSDictionary) 转换为 Model:
User *user = [User yy_modelWithJSON:json];
// 将 Model 转换为 JSON 对象:
NSDictionary *json = [user yy_modelToJSONObject];
```

## 2.自定义Key映射转换

```objc
//返回一个 Dict，将 Model 属性名对映射到 JSON 的 Key。
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"name" : @"n",
             @"page" : @"p",
             @"desc" : @"ext.desc",
             @"bookID" : @[@"id",@"ID",@"book_id"]};
}
// ⚠️ 字典中的`value`是服务器返回的原始json值，转换为`key`
// 事例
// JSON
{
    "n":"Harry Pottery",
    "p": 256,
    "ext" : {
        "desc" : "A book written by J.K.Rowing."
    },
    "ID" : 100010
}
// Model
@interface Book : NSObject
@property NSString *name;
@property NSInteger page;
@property NSString *desc;
@property NSString *bookID;
@end
```

## 3.嵌套转换

### 3.1 Model嵌套

Model里引用了另外一个Model，非容器类的什么都不用做，会自动的转换完成

### 3.2 容器嵌套

容器类需要指定容器所包含的类型，容器包含入`NSArray` `NSSet` `NSDictionNary`等

```objc

@interface Attributes
@property NSString *name;
@property NSArray *shadows; //Array<Shadow>
@property NSSet *borders; //Set<Border>
@property NSMutableDictionary *attachments; //Dict<NSString,Attachment>
@end
  
 
// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"shadows" : [Shadow class],
             @"borders" : Border.class,
             @"attachments" : @"Attachment" };
}
```

## 4.黑白名单

```objc
// 如果实现了该方法，则处理过程中会忽略该列表内的所有属性
+ (NSArray *)modelPropertyBlacklist {
    return @[@"test1", @"test2"];
}
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。即：仅处理白名单中的属性
+ (NSArray *)modelPropertyWhitelist {
    return @[@"name"];
}
```

## 5.自定义转换

```objc
// JSON:
{
	"name":"Harry",
	"timestamp" : 1445534567
}
	
// Model:
@interface User
@property NSString *name;
@property NSDate *createdAt;
@end

@implementation User
// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSNumber *timestamp = dic[@"timestamp"];
    if (![timestamp isKindOfClass:[NSNumber class]]) return NO;
    _createdAt = [NSDate dateWithTimeIntervalSince1970:timestamp.floatValue];
    return YES;
}
	
// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if (!_createdAt) return NO;
    dic[@"timestamp"] = @(n.timeIntervalSince1970);
    return YES;
}
@end
```

## 6.Coding/Copying/hash/equal/description

```objc
@interface YYShadow :NSObject <NSCoding, NSCopying>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CGSize size;
@end

@implementation YYShadow
// 直接添加以下代码即可自动完成
- (void)encodeWithCoder:(NSCoder *)aCoder { [self yy_modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self yy_modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self yy_modelCopy]; }
- (NSUInteger)hash { return [self yy_modelHash]; }
- (BOOL)isEqual:(id)object { return [self yy_modelIsEqual:object]; }
- (NSString *)description { return [self yy_modelDescription]; }
@end
```

