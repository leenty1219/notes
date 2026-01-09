### 1. 创建&使用串行队列

```objc
dispatch_queue_t serialQueue = dispatch_queue_create("SerialQueue", DISPATCH_QUEUE_SERIAL);
dispatch_async(serialQueue, ^{
		NSLog(@"1");
});
```

### 2. 创建&使用并行队列

```objc
dispatch_queue_t concurrentQueue = dispatch_queue_create("ConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
dispatch_async(concurrentQueue, ^{
		NSLog(@"1");
});
```

> _把任务放到并行队列中，不一定会开启新线程。要看当前已存在的线程执行情况。_

> _串行队列，系统一定会开启一个新的线程。大量的开启会造成上下文切换消耗_

_4.1 队列优先级_

- **`QOS_CLASS_USER_INTERACTIVE`**= 0x21: 用于用户数据，希望快点返回
- **`QOS_CLASS_USER_INITIATED0x19`** : 处理用户一般性数据
- **`QOS_CLASS_DEFAULT`**= 0x15 : 默认
- **`QOS_CLASS_UTILITY`**= 0x11: 公共优先级偏低的
- **`QOS_CLASS_BACKGROUND`**= 0x09: 非常耗时的不重要数据
- **`QOS_CLASS_UNSPECIFIED`**= 0x0 不希望使用的数据

### 3. dispatch_group 组

```objc
// 串行：DISPATCH_QUEUE_SERIAL
// 并行：DISPATCH_QUEUE_CONCURRENT

dispatch_queue_t global = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
dispatch_group_t group = dispatch_group_create();

// 向group中添加任务
dispatch_group_async(group, global, ^{
		sleep(1);
		NSLog(@"1");
});
// 向group中添加任务
dispatch_group_async(group, global, ^{
		sleep(1);
		NSLog(@"2");
});
// group中任务执行完毕后的通知
dispatch_group_notify(group, global, ^{
		sleep(1);
		NSLog(@"finish!");
});

// 也可以用 dispatch_group_wait来替代相同效果*
// dispatch_group_wait 卡的是group线程，不会卡当前线程*
dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
NSLog(@"finish!");
```

### 4. dispatch_barrier_async 栏栅函数

```objc
dispatch_queue_t global = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);

dispatch_async( global, ^{
		sleep(1);
		NSLog(@"1");
});

dispatch_barrier_async(global, ^{
		NSLog(@"barrier");
});

NSLog(@"3");

dispatch_async( global, ^{
		sleep(1);
		NSLog(@"2");
});

// 打印顺序为：3、1、barrier、2
// barrier 的前提是在同一个线程，不会影响别的线程
```

### 5. 快速迭代 dispatch_apply

```objc
dispatch_queue_t global = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);

dispatch_apply(100, global, ^(size_t iteration) {
		sleep(1);
		NSLog(@"%lu",iteration);
});

NSLog(@"finish!");

// 多线程执行遍历，输出为先打印 0-99，完成后打印 finish
```

### 6. dispatch_semaphore 锁

- 建议使用`cpp`方式或者`@property`中用`strong`来修饰

```objc
{
		dispatch_semaphore_t _semaphore;
}

_semaphore = dispatch_semaphore_create(1); // 代表了允许通过的线程数

- (void)concurrent:(int)idx{
		dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER); // 信号减1 ，如果小于等于0 就会阻塞
		sleep(1);
		NSLog(@"%d",idx);
		dispatch_semaphore_signal(_semaphore); // 信号加1
}
```

### 7. dispatch定时器

```objc
@property (nonatomic, strong) dispatch_source_t timer; // 需要强引用，防止释放

//创建线程队列

dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

// 使用之前创建的队列来创建计时器
// 参数1：DISPATCH_SOURCE_TYPE_TIMER 添加source源为定时器
// 参数2、3：当source为定时器时，无效，直接填 0 0
// 参数4：在什么队列中使用

self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

// 配置定时器参数
// 参数1：需要设定的 dispatch_source_t, 当前为 timer
// 参数2：任务开始时间
// 参数3：任务间隔(单位均为纳秒)
// 参数4：可接受的误差时间，设置0即不允许出现误差
dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);

// 设置source回调任务
dispatch_source_set_event_handler(self.timer, ^{

});

// 启动定时器
dispatch_resume(self.timer);

// 暂停定时器，注意 dispatch_resume 和 dispatch_suspend 成对出现，多次调用dispatch_suspend会卡线程
dispatch_suspend(self.timer);

// 停止定时器
dispatch_source_cancel(self.timer);
```

### 8. dispatch_source_create一点扩展

```objc
__block NSUInteger total = 0;
dispatch_source_t dataSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0,   dispatch_get_main_queue());
dispatch_source_set_event_handler(dataSource, ^{
		unsigned long value = dispatch_source_get_data(dataSource);
		total += val
		NSLog(@"Received total value: %lu", value);
});
dispatch_resume(dataSource);
dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
		sleep(1);
		dispatch_source_merge_data(dataSource, 1); // += 1
});

// 2. 在任意线程发送数据
dispatch_source_merge_data(dataSource, 2); // += 2

- **DISPATCH_SOURCE_TYPE_DATA_ADD : 是添加，如果相隔时间很紧dispatch会合并后一起发送。间隔时间大不会**
- **DISPATCH_SOURCE_TYPE_DATA_REPLACE :是永远展示最新值**
- **DISPATCH_SOURCE_TYPE_DATA_OR**：**位计算。例如：可以根据位枚举来判断错误**
- **DISPATCH_SOURCE_TYPE_SIGNAL**：**接收到UNIX信号时响应, 如app被kill释放资源**
- **DISPATCH_SOURCE_TYPE_MACH_RECV** : **MACH端口接收**
- **DISPATCH_SOURCE_TYPE_MACH_SEND : MACH端口发送**
- **DISPATCH_SOURCE_TYPE_PROC : 进程监听,如进程的退出、创建一个或更多的子线程、进程收到UNIX信号**
- **DISPATCH_SOURCE_TYPE_READ : IO操作，如对文件的操作、socket操作的读响应**
- **DISPATCH_SOURCE_TYPE_TIMER : 定时器**
- **DISPATCH_SOURCE_TYPE_VNODE : 文件状态监听，文件被删除、移动、重命名**
- **DISPATCH_SOURCE_TYPE_WRITE : IO操作，如对文件的操作、socket操作的写响应**

具体应用场景具体再看
```

### 9. 队列设置目标

```objc
+ (dispatch_queue_t)setterQueue {
		static dispatch_queue_t queue;
		static dispatch_once_t onceToken;
		
		dispatch_once(&onceToken, ^{
				queue = dispatch_queue_create("com.ibireme.yykit.webimage.setter", DISPATCH_QUEUE_SERIAL);
				dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
		});
		return queue;
}
```

这是一个`YYKit`的代码片段，其中`queue = dispatch_queue_create("com.ibireme.yykit.webimage.setter", DISPATCH_QUEUE_SERIAL);`是创建的一个**串行队列**，设置目标`target`到`*global*`中去。

如何理解：

> 这个操作的本质是串行设置优先级，利用 `dispatch_get_global_queue` 来设置优先级。这里并不会因为将target设置到global就会改变串行本质。

### 10. 实现多读单写

使用场景是`多读单写`的情况，如果是`单读单写互斥`的情况 ，使用`semaphore`

```objc
@implementation KCPerson
- (instancetype)init{
    if(self = [super init]){
        _concurrentQueue = dispatch_queue_creat("com.kc_person.syncQueue", DISPATCH_QUEUE_CONCURRENT);
        _dic = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void)kc_setSafeObject:(id)object forKey:(NSString *)key{
    key = [key copy];
    dispatch_barrier_async(_concurrentQueue, ^{
        [_dic setObject:object key:key];
    });
}

- (id)kc_safeObjectForKey:(NSString *)key{
    __block NSString *temp;
    dispatch_sync(_concurrentQueue, ^{
        temp = [_dic objcetForKey:key];
    });
    return temp;
}
```

> 我们要维系一个自定义队列，不能用全局队列

## 11. Swift下的实例

```swift
// 主队列（UI更新必须在主线程执行）
let mainQueue = DispatchQueue.main

// 全局队列（并发队列）
// qos 决定优先级：.userInteractive, .userInitiated, .default, .utility, .background
let globalQueue = DispatchQueue.global(qos: .background)

// 自定义串行队列
let serialQueue = DispatchQueue(label: "com.example.serial")

// 自定义并发队列
let concurrentQueue = DispatchQueue(label: "com.example.concurrent", attributes: .concurrent)
```

```swift
DispatchQueue.global(qos: .userInitiated).async {
    print("耗时任务：\\(Thread.current)")
    DispatchQueue.main.async {
        print("回到主线程更新UI：\\(Thread.current)")
    }
}
```

```swift
DispatchQueue.global().sync {
    print("同步执行：\\(Thread.current)")
}
```

```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    print("延迟 2 秒执行")
}
// 栅栏任务（barrier）
let concurrentQueue = DispatchQueue(label: "com.example.concurrent", attributes: .concurrent)

for i in 1...3 {
    concurrentQueue.async {
        print("读取任务 \\(i)")
    }
}

concurrentQueue.async(flags: .barrier) {
    print("写入任务（独占执行）")
}

for i in 4...6 {
    concurrentQueue.async {
        print("读取任务 \\(i)")
    }
}
// 一次性执行
private let onceToken = UUID().uuidString // Swift 没有 dispatch_once，用静态属性替代

struct Config {
    static let shared: Config = {
        print("初始化一次")
        return Config()
    }()
}
```

```swift
let group = DispatchGroup()

let queue = DispatchQueue.global()

queue.async(group: group) {
    print("任务1")
}
queue.async(group: group) {
    print("任务2")
}

group.notify(queue: .main) {
    print("所有任务完成，回到主线程")
}
```

```swift
let semaphore = DispatchSemaphore(value: 2) // 最多同时执行 2 个任务
let queue = DispatchQueue.global()

for i in 1...5 {
    queue.async {
        semaphore.wait()
        print("开始任务 \\(i)")
        sleep(2)
        print("完成任务 \\(i)")
        semaphore.signal()
    }
}
```

```swift
let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
timer.schedule(deadline: .now(), repeating: 1.0) // 每秒一次
timer.setEventHandler {
    print("定时器触发：\\(Date())")
}
timer.resume()
```