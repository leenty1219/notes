## 1. NSOperation

一般情况下不会直接使用`NSOperation`，而是是使用其子类：`NSInvocationOperation`、`NSBlockOperation`

NSOperation是一个抽象类，为了做任何有用的工作，它必须被子类化。尽管这个类是抽象的，但它给了它的子类一个十分有用而且线程安全的方式来建立状态、优先级、依赖性和取消等的模型。NSOperation提供了三种方式来创建任务。 **1、使用子类 NSInvocationOperation； 2、使用子类 NSBlockOperation； 3、自定义继承自 NSOperation 的子类，通过实现内部相应的方法来封装操作。**

## 2. NSInvocationOperation

```objc
-(void)invocationOperation{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operation) object:nil];
    [operation start];
}

-(void)operation{
    for (int i = 0; i < 5; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"%d--%@",i,[NSThread currentThread]);
    }
}
// 没有开启子线程，当前输出都是在 `invocationOperation` 调用的线程
```

## 3. NSBlockOperation

```objc
-(void)blockOperationDemo{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"%d--%@",i,[NSThread currentThread]);
        }
    }];
    [operation start];
}
// 没有开启子线程，当前输出都是在 `invocationOperation` 调用的线程
```

```objc
[operation addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"executionBlock1--%@", [NSThread currentThread]);
        }
 }];
 // 添加的任务会视情况开启线程
```

## 4. NSOperationQueue 队列

- 主队列：通过`[NSOperationQueue mainQueue]`方式获取，凡是添加到主队列中的任务都会放到主线程中执行。
- 自定义队列：通过`[[NSOperationQueue alloc] init]`方式创建一个队列，凡是添加到自定义队列中的任务会自动放到子线程中执行。

```objc
NSOperationQueue *queue = [[NSOperationQueue alloc]init];
NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"operation2--%@", [NSThread currentThread]);
    }
}];
[queue addOperation:operation1];
```