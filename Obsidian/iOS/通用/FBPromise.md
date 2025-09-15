谷歌 [promise](https://github.com/google/promises) 相关文档

### 1. 创建一个promise

```objc
FBLPromise<NSString *> *promise = [FBLPromise onQueue:dispatch_get_main_queue()
                                                async:^(FBLPromiseFulfillBlock fulfill,
                                                        FBLPromiseRejectBlock reject) {
  // Called asynchronously on the dispatch queue specified.
  if (success) {
    // Resolve with a value.
    fulfill(@"Hello world.");
  } else {
    // Resolve with an error.
    reject(someError);
  }
}];
```

如何没有特别的设置，promise默认在主线程执行，上方的示例等同于下方：

默认调度队列：`FBLPromise.defaultDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);`

```objc
FBLPromise<NSString *> *promise = [FBLPromise async:^(FBLPromiseFulfillBlock fulfill,
                                                      FBLPromiseRejectBlock reject) {
  // Called asynchronously on the default queue.
  if (success) {
    fulfill(@"Hello world.");
  } else {
    reject(someError);
  }
}];
```

### 2. do

如果不需要异步操作，使用 `do`

```objc
FBLPromise<NSString *> *promise = [FBLPromise do:^id {
  // Called asynchronously on the default queue.
  return success ? @"Hello world" : someError;
}];
```

### 3. Pending

`pending` 的生命周期难以控制，尽量少用

```objc
FBLPromise<NSString *> *promise = [FBLPromise pendingPromise];
// ...
if (success) {
  [promise fulfill:@"Hello world"];
} else {
  [promise reject:someError];
}
```

### 4. resolved promise

将`初始值`或`错误`传递给 Promise 的构造函数

```objc
- (FBLPromise<NSData *> *)getDataAtURL:(NSURL *)anURL {
  if (anURL.absoluteString.length == 0) {
    return [FBLPromise resolvedWith:nil];
  }
  return [self loadURL:anURL];
}
```

### 5. catch

处理错误`catch`

### 6. all

`all` 运算符是等待所有的结果都执行完毕

```objc
// Promises of same type:
[[FBLPromise all:[contacts fbl_map:^id(MyContact *contact) {
  return [MyClient getAvatarForContact:contact];
}]] then:^id(NSArray<UIImage *> *avatars) {
  [self updateAvatars:avatars];
  return nil;
}];

// Promises of different types:
[[FBLPromise
    all:@[ [MyClient getLocationForContact:contact], [MyClient getAvatarForContact:contact] ]]
    then:^id(NSArray *locationAndAvatar) {
      [self updateContactLocation:locationAndAvatar.firstObject
                        andAvatar:locationAndAvatar.lastObject];
      return nil;
    }];
```

### 7. always

`always` 一定会执行，比如关闭文件连接

```objc
[[[[self getCurrentUserContactsAvatars] then:^id(NSArray<UIImage *> *avatars) {
  [self updateAvatars:avatars];
  return avatars;
}] catch:^(NSError *error) {
  [self showErrorAlert:error];
}] always:^{
  self.label.text = @"All done.";
}];
```

### 8. any

`any` 与 `all` 类似，但即使提供的数组中的某些承诺被拒绝，它也会实现。如果输入数组中的所有 Promise 都被拒绝，则返回的 Promise 将被拒绝，并出现与最后一个被拒绝的错误相同的错误。

```objc
// Promises of same type:
[[FBLPromise any:[contacts fbl_map:^id(MyContact *contact) {
  return [MyClient getAvatarForContact:contact];
}]] then:^id(NSArray *avatarsOrErrors) {
  [self updateAvatars:[avatarsOrErrors fbl_filter:^BOOL(id avatar) {
    return [avatar isKindOfClass:[UIImage class]];
  }]];
  return nil;
}];

// Promises of different types:
[[FBLPromise
    any:@[ [MyClient getLocationForContact:contact], [MyClient getAvatarForContact:contact] ]]
    then:^id(NSArray *locationAndAvatarOrErrors) {
      id location = locationAndAvatarOrErrors.firstObject;
      id avatar = locationAndAvatarOrErrors.lastObject;
      if ([location isKindOfClass:[CLLocation class]] && [avatar isKindOfClass:[UIImage class]]) {
        [self updateContactLocation:location andAvatar:avatar];
      } else {  // Optionally handle errors if needed.
        if ([location isKindOfClass:[NSError class]]) {
          [self showErrorAlert:location];
        }
        if ([avatar isKindOfClass:[NSError class]]) {
          [self showErrorAlert:avatar];
        }
      }
      return nil;
    }];
```

### 9. AwaitPromise

使用 `awaitPromise` 您可以同步等待承诺在不同的线程上得到解决。当您需要以不同方式混合来自多个异步例程的多个结果时，这可能很有用，即无法使用 `then` 、 `all` 等将它们链接在清晰的管道中，或者只是想要以同步风格编写异步代码。

```objc
[[[FBLPromise do:^id {
  NSError *error;
  NSNumber *minusFive = FBLPromiseAwait([calculator negate:@5], &error);
  if (error) return error;
  NSNumber *twentyFive = FBLPromiseAwait([calculator multiply:minusFive by:minusFive], &error);
  if (error) return error;
  NSNumber *twenty = FBLPromiseAwait([calculator add:twentyFive to:minusFive], &error);
  if (error) return error;
  NSNumber *five = FBLPromiseAwait([calculator subtract:twentyFive from:twenty], &error);
  if (error) return error;
  NSNumber *zero = FBLPromiseAwait([calculator add:minusFive to:five], &error);
  if (error) return error;
  NSNumber *result = FBLPromiseAwait([calculator multiply:zero by:five], &error);
  if (error) return error;
  return result;
}] then:^id(NSNumber *result) {
  // ...
}] catch:^(NSError *error) {
  // ...
}];
```

### 10. delay

`delay` 返回一个新的待处理承诺，该承诺在给定的延迟后以与 `self` 相同的值实现，或立即拒绝并出现相同的错误。如果您想在承诺链中添加人为暂停，它可能会派上用场。

### 11. race

`race` 类方法与 `all` 类似，但它返回的 Promise 的履行或拒绝的分辨率与给定的第一个 Promise 的分辨率相同

### 12. recover

`recover` 让我们 `catch` 发生错误并轻松地从中恢复，而不会破坏承诺链的其余部分

```objc
[[[self getCurrentUserContactsAvatars] recover:^id(NSError *error) {
  NSLog(@"Fallback to default avatars due to error: %@", error);
  return [self getDefaultsAvatars];
}] then:^id(NSArray<UIImage *> *avatars) {
  [self updateAvatars:avatars];
  return avatars;
}];
```

### 13. reduce

`reduce` 可以轻松地使用给定的闭包或块从 Promise 集合中生成单个值。与 Swift 库的 `reduce(_:_:)` 相比，使用 `Promise.reduce` 的一个好处是 `Promise.reduce` 会为您解析部分值的承诺，这样您就不必链接闭包内的承诺以获得其价值。以下是如何将数字数组缩减为单个字符串的简单示例：

```objc
NSArray<NSNumber *> *numbers = @[ @1, @2, @3 ];
[[[FBLPromise resolvedWith:@"0"] reduce:numbers
                                combine:^id(NSString *partialString, NSNumber *nextNumber) {
  return [NSString stringWithFormat:@"%@, %@", partialString, nextNumber.stringValue];
}] then:^id(NSString *string) {
  // Final result = 0, 1, 2, 3
  NSLog(@"Final result = %@", string);
  return nil;
}];
```

### 14. retry

如果与该任务关联的 Promise 最初被拒绝， `retry` 可以灵活地重新尝试该任务。默认情况下，操作员在初始拒绝后进行一次重试，并在重试之前延迟一秒。如果默认值不能满足您的用例， `retry` 运算符还支持指定将工作块分派到的自定义队列、最大重试尝试次数、延迟时间间隔和可选谓词如果不满足给定条件，可以提前保释。

```objc
- (FBLPromise<NSData *, NSURLResponse *> *)fetchWithURL:(NSURL *)url {
  return [FBLPromise wrap2ObjectsOrErrorCompletion:^(FBLPromise2ObjectsOrErrorCompletion handler) {
    [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:handler];
  }];
}

NSURL *url = [NSURL URLWithString:@"<https://myurl.com>"];

// Defaults to one retry attempt after a one second delay.
[[[FBLPromise retry:^id {
  return [self fetchWithURL:url];
}] then:^id(NSArray *values) {
  NSLog(@"%@", values);
  return nil;
}] catch:^(NSError *error) {
  NSLog(@"%@", error);
}];

```

配置重试机制

```objc
// Specifies a custom queue, 5 retry attempts, 2 second delay, and a predicate.
dispatch_queue_t customQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
[[[FBLPromise onQueue:customQueue
    attempts:5
    delay:2.0
    condition:^BOOL(NSInteger remainingAttempts, NSError *error) {
      return error.code == NSURLErrorNotConnectedToInternet;
    }
    retry:^id {
      return [self fetchWithURL:url];
}] then:^id(NSArray *values) {
  // Will enter `then` block if one of the retry attempts succeeds.
  NSLog(@"%@", values);
  return nil;
}] catch:^(NSError *error) {
  // Will enter `catch` block if all retry attempts have been exhausted or the
  // given condition was not met.
  NSLog(@"%@", error);
}]
```

### 15. timeout

`timeout` 允许我们等待一个承诺一段时间，或者如果它没有在给定时间内解决则拒绝它。超时的 Promise 在 `FBLPromiseErrorDomain` 域中以 `NSError` 拒绝，代码为 `FBLPromiseErrorCodeTimedOut` 。

### 16. validate（类似filter）

`validate` 使值检查变得微不足道，而不会破坏承诺链。它接收类似于 `then` 的值，但返回一个布尔值，指示该值是否可接受。如果 `validate` 返回 true，则承诺将通过该值实现。如果为 false，则承诺会被 `FBLPromiseErrorDomain` 域中的 `NSError` 拒绝，代码为 `FBLPromiseErrorCodeValidationFailure` 。

### 17. wrap

`wrap` 类方法提供了一种将使用常见回调模式（如 `^(id, NSError *)` 等）的其他方法转换为 Promise 的便捷方法。

```objc
- (FBLPromise<NSData*> *)newAsyncMethodReturningAPromise {
  return [FBLPromise wrapObjectOrErrorCompletion:^(FBLPromiseObjectOrErrorCompletion handler) {
    [MyClient wrappedAsyncMethodWithTypicalCompletion:handler];
  }];
}
```