## OC线程安全的自增

使用 `int32_t`定义的类型。

`OSAtomicIncrement32(&_value);`

> 此种方式在ios 10中已经废弃，使用新的方式



### 原子性

```objc
#include <atomic>
{
 std::atomic<int32_t> _counter; // 定义变量
}

{
  _counter = 3; // 设置默认值
  std::atomic_fetch_add_explicit(&_counter, 1, std::memory_order_relaxed); // += 1的操作
  std::atomic_fetch_sub_explicit(&_counter, 1,std::memory_order_relaxed); // -= 1的操作
  std::atomic_fetch_and_explicit // *value = *value & mask
  std::atomic_fetch_or_explicit  //*value = *value | mask
  std::atomic_fetch_xor_explicit // 异或运算 *value = *value ^ mask
    std::atomic_exchange_explicit  // 交换 value = newValue
      
  int32_t value = _counter.load(); //读取值
  
  // CAS 的基本逻辑,如果当前值等于期望值 expected，那么把它换成新值 desired，否则不动.
  // 如：如果等于 0 ，就设置为 1
  atomic_int value = ATOMIC_VAR_INIT(100);  // 初始值是 100

    int expected = 100;                       // 我们期望当前是 100
    int desired = 200;                        // 想改成 200

    // 尝试将 value 从 expected 改为 desired
    bool success = atomic_compare_exchange_strong_explicit(
        &value,         // 要修改的变量
        &expected,      // 当前期望值
        desired,        // 想设置的新值
        memory_order_acq_rel,  // 成功时的 memory order
        memory_order_relaxed   // 失败时的 memory order
    );

}


```

#### cas

```objc
    std::atomic_int _count{10}; // 初始化的值
    int expected = 10; // 期望的值
    int desired = 100; // 修改的值
    std::atomic_compare_exchange_strong_explicit(&_count, &expected, desired, std::memory_order_relaxed, std::memory_order_relaxed);

// 这里的含义：如果 _count 与期望的值 expected 相等，那么 _count 就修改为 desired，否则不改变
//   if (_count == expected){
//				_count = desired;
//   }

    NSLog(@"value = %d",_count.load());
```



| 你要做的操作 | 推荐函数                             |
| ------------ | ------------------------------------ |
| 原子加       | `atomic_fetch_add_explicit`          |
| 原子减       | `atomic_fetch_sub_explicit`          |
| 原子布尔操作 | `fetch_and`, `fetch_or`, `fetch_xor` |
| 原子设置值   | `atomic_exchange_explicit`           |
| 原子条件设置 | `atomic_compare_exchange_*_explicit` |



| 内存顺序               | 保证                                | 适合场景             |
| ---------------------- | ----------------------------------- | -------------------- |
| `memory_order_relaxed` | 只保证原子性，不保证顺序            | 计数器、无需同步依赖 |
| `memory_order_release` | 写操作之后不能被重排到 release 后面 | 写方                 |
| `memory_order_acquire` | 读操作之前不能被重排到 acquire 前面 | 读方                 |
| `memory_order_acq_rel` | 两者都保证                          | 双向同步             |
| `memory_order_seq_cst` | 顺序一致性（最安全）                | 推荐默认使用         |

#### 获取纳秒

```c++
#include <mach/mach_time.h>
uint64_t t = mach_absolute_time();
```

