
## 记录YYKit的使用
```objc
#import <YYKit/YYKitMacro.h>

static inline bool dispatch_is_main_queue() {
    return pthread_main_np() != 0;
}

// 在主线程上异步添加任务

static inline void dispatch_async_on_main_queue(void (^block)()) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

// 在主线程上同步添加任务

static inline void dispatch_sync_on_main_queue(void (^block)()) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}
```
