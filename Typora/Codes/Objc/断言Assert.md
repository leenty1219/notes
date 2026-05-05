## 1.NSAssert

```objc
- (void)updateUser:(id)user {
    NSAssert(user != nil, @"user 不能为空");
    // 后续逻辑
}
```

## 2.NSCAssert

```c
void ProcessValue(NSInteger value) {
    NSCAssert(value >= 0, @"value 不能小于 0");
}
```

## 3.NSParameterAssert

```objc
- (void)setName:(NSString *)name {
    NSParameterAssert(name);
    _name = [name copy];
}
```

