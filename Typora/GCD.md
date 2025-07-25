## GCD

###  1. 创建&使用串行队列

```objc
dispatch_queue_t serialQueue = dispatch_queue_create("SerialQueue", DISPATCH_QUEUE_SERIAL);

dispatch_async(serialQueue, ^{

  NSLog(@"1");
});
```

###  2. 创建&使用并行队列

```objective-c
dispatch_queue_t concurrentQueue = dispatch_queue_create("ConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);

dispatch_async(concurrentQueue, ^{

  NSLog(@"1");

});
```

> * 把任务放到并行队列中，不一定会开启新线程。要看当前已存在的线程执行情况。
>
> * 串行队列，系统一定会开启一个新的线程。大量的开启会造成上下文切换消耗

#### 4.1 队列优先级

* `QOS_CLASS_USER_INTERACTIVE`  = 0x21:  用于用户数据，希望快点返回

* `QOS_CLASS_USER_INITIATED`  0x19 : 处理用户一般性数据

* `QOS_CLASS_DEFAULT`  = 0x15 :  默认

* `QOS_CLASS_UTILITY` = 0x11:  公共优先级偏低的

* `QOS_CLASS_BACKGROUND` = 0x09: 非常耗时的不重要数据
*  `QOS_CLASS_UNSPECIFIED` = 0x0 不希望使用的数据

###  3. dispatch_group 组

// 串行：DISPATCH_QUEUE_SERIAL  

// 并行：DISPATCH_QUEUE_CONCURRENT

```objective-c

dispatch_queue_t global = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
dispatch_group_t group = dispatch_group_create();

dispatch_group_async(group, global, ^{
  sleep(1);
  NSLog(@"1");
});

dispatch_group_async(group, global, ^{
  sleep(1);
  NSLog(@"2");
});

dispatch_group_notify(group, global, ^{
  sleep(1);
  NSLog(@"finish!");
});

// 也可以用 dispatch_group_wait来替代相同效果
// dispatch_group_wait 卡的是group线程，不会卡当前线程
dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

NSLog(@"finish!");
```

###  4. dispatch_barrier_async 栏栅函数

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
```

###  5. 快速迭代 dispatch_apply

```objc
dispatch_queue_t global = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);

dispatch_apply(100, global, ^(size_t iteration) {
  sleep(1);
  NSLog(@"%lu",iteration);
});

NSLog(@"finish!");
// 输出为先打印 0-99，完成后打印 finish
```



### 6. dispatch_semaphore 锁

> 建议使用Cpp的方式或者@property中用strong来修饰

```objc
dispatch_semaphore_t _semaphore;
_semaphore = dispatch_semaphore_create(1); // 代表了允许通过的线程数

- (void)concurrent:(int)idx{
  dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER); // 信号减1 ，如果小于等于0 就会阻塞
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
//使用之前创建的队列来创建计时器
// 参数1：DISPATCH_SOURCE_TYPE_TIMER 为定时器类型
// 参数2、3：中间两个参数对定时器无用
// 参数4：在什么队列中使用
self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

// 参数1：任务定时器
// 参数2：任务开始时间
// 参数3：任务间隔(单位均为纳秒)
// 参数4：可接受的误差时间，设置0即不允许出现误差
dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);

// 设置定时器任务
dispatch_source_set_event_handler(self.timer, ^{

});

// 启动定时器
dispatch_resume(self.timer);
// 暂停定时器，注意 dispatch_resume 和 dispatch_suspend 成对出现，多次调用dispatch_suspend会卡线程
dispatch_suspend(self.timer); 
// 停止定时器
dispatch_source_cancel(self.timer);


```

###  8. dispatch_source_create一点扩展

```objc
__block NSUInteger total = 0;
dispatch_source_t dataSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, 		dispatch_get_main_queue());

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
```

* `DISPATCH_SOURCE_TYPE_DATA_ADD` 是添加，如果相隔时间很紧dispatch会合并后一起发送。间隔时间大不会
* `DISPATCH_SOURCE_TYPE_DATA_REPLACE` 是永远展示最新值
* `DISPATCH_SOURCE_TYPE_DATA_OR` ：位计算。例如：可以根据位枚举来判断错误
* `DISPATCH_SOURCE_TYPE_SIGNAL`：监听事件，如app被kill释放资源

> 还可以监听文件的改动，具体应用场景具体再看

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

这是一个`YYKit`的代码片段，其中`queue = dispatch_queue_create("com.ibireme.yykit.webimage.setter", DISPATCH_QUEUE_SERIAL);`是创建的一个串行队列，设置目标target到global中去。

如何理解：这个`queue`的本质是串行设置优先级，利用 `dispatch_get_global_queue` 来设置优先级。这里并不会因为将target设置到global就会改变串行本质。



