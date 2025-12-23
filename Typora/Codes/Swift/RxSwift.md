## 1.操作符

| 符号                       | 特点                                                                                                                                              |
| ------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| amb                      | 多个源中，只取第一个发出的事件，后续也只取它的事件                                                                                                                       |
| buffer                   | 缓存元素，等到周期后以集合发出                                                                                                                                 |
| catchError               | 捕捉到一个错误后，返回别的事件，防止中断                                                                                                                            |
| combineLatest            | 当所有源都发出过数据后，其中任意一个源发出事件，都会发出集合内的最新值                                                                                                             |
| **concat**               | 串联源，只有前一个完成后，下一个才会被订阅                                                                                                                           |
| **connect**              | **通知 `ConnectableObservable` 可以开始发出元素。**订阅后不会发出元素，直到 **connect** 操作符被应用为止                                                                       |
| **create**               | 操作符将创建一个 `Observable`                                                                                                                           |
| **debounce**             | **过滤掉高频产生的元素。会发出上一个未处理元素**                                                                                                                      |
| throttle                 | 在冷却期会**丢掉**事件                                                                                                                                   |
| **debug**                | **打印所有的订阅，事件以及销毁信息**                                                                                                                            |
| **deferred**             | **直到订阅发生，才创建 `Observable`，并且为每位订阅者创建全新的 `Observable`**                                                                                          |
| **delay**                | **将 `Observable` 的每一个元素拖延一段时间后发出**                                                                                                              |
| **delaySubscription**    | **进行延时订阅**                                                                                                                                      |
| **dematerialize**        | **dematerialize 操作符将 [materialize](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/decision_tree/materialize.html) 转换后的元素还原** |
| **distinctUntilChanged** | **阻止 `Observable` 发出相同的元素**                                                                                                                     |
| **do**                   | **当 `Observable` 产生某些事件时，执行某个操作**                                                                                                               |
| **elementAt**            | **只发出 `Observable` 中的第 n 个元素**                                                                                                                  |
| **empty**                | **创建一个空 `Observable`**                                                                                                                          |
| **error**                | **创建一个只有 `error` 事件的 `Observable`**                                                                                                             |
| **filter**               | **仅仅发出 `Observable` 中通过判定的元素**                                                                                                                  |
| **flatMap**              | **将 `Observable` 的元素转换成其他的 `Observable`，然后将这些 `Observables` 合并**                                                                                |
| **flatMapLatest**        | **将 `Observable` 的元素转换成其他的 `Observable`，然后取这些 `Observables` 中最新的一个**                                                                            |
| **from**                 | **将其他类型或者数据结构转换为 `Observable`**                                                                                                                 |
| **groupBy**              | **将源 `Observable` 分解为多个子 `Observable`**                                                                                                         |
| **ignoreElements**       | **忽略掉所有的元素只发出 `error` 或 `completed` 事件**                                                                                                        |
| **interval**             | **创建一个 `Observable` 每隔一段时间，发出一个索引数**                                                                                                            |
| just                     | **创建 `Observable` 发出唯一的一个元素**                                                                                                                   |
| map                      | **通过一个转换函数，将 `Observable` 的每个元素转换一遍**                                                                                                           |
| **merge**                | **将多个 `Observables` 合并成一个**                                                                                                                     |
| **materialize**          | **将序列产生的事件，转换成元素。（又包了一层Observable？）**                                                                                                           |
| **never**                | **创建一个永远不会发出元素的 `Observable`**                                                                                                                  |
| **observeOn**            | **指定 `Observable` 在那个 `Scheduler` 发出事件。自己执行onNext的闭包线程**                                                                                        |
| **subscribeOn**          | **指定 `Observable` 在那个 `Scheduler` 执行。事件线程，比如调用.create的闭包线程**                                                                                    |
| **publish**              | **将 `Observable` 转换为可被连接的 `Observable`**                                                                                                        |
| **reduce**               | **持续的将 `Observable` 的每一个元素应用一个函数，然后发出最终结果**                                                                                                     |
| **refCount**             | **将可被连接的 `Observable` 转换为普通 `Observable`**                                                                                                      |
| **repeatElement**        | **创建重复发出某个元素的 `Observable`**                                                                                                                    |
| **replay**               | **确保观察者接收到同样的序列，即使是在 `Observable` 发出元素后才订阅**                                                                                                    |
| **retry**                | **如果源 `Observable` 产生一个错误事件，重新对它进行订阅，希望它不会再次产生错误**                                                                                              |
| **sample**               | **不定期的对 `Observable` 取样**                                                                                                                       |
| **scan**                 | **持续的将 `Observable` 的每一个元素应用一个函数，然后发出每一次函数返回的结果**                                                                                               |
| **shareReplay**          | **使观察者共享 `Observable`，观察者会立即收到最新的元素，即使这些元素是在订阅前产生的**                                                                                            |
| **single**               | **限制 `Observable` 只有一个元素，否出发出一个 `error` 事件**                                                                                                    |
| **skip**                 | **跳过 `Observable` 中头 n 个元素**                                                                                                                    |
| **skipUntil**            | **跳过 `Observable` 中头几个元素，直到另一个 `Observable` 发出一个元素**                                                                                            |
| **skipWhile**            | **跳过 `Observable` 中头几个元素，直到元素的判定为否**                                                                                                            |
| **startWith**            | **将一些元素插入到序列的头部**                                                                                                                               |
| **take**                 | **仅仅从 `Observable` 中发出头 n 个元素**                                                                                                                 |
| **takeLast**             | **仅仅从 `Observable` 中发出尾部 n 个元素**                                                                                                                |
| **takeUntil**            | **忽略掉在第二个 `Observable` 产生事件后发出的那部分元素**                                                                                                          |
| **takeWhile**            | **镜像一个 `Observable` 直到某个元素的判定为 false**                                                                                                          |
| **timeout**              | **如果源 `Observable` 在规定时间内没有发出任何元素，就产生一个超时的 `error` 事件**                                                                                         |
| **timer**                | **创建一个 `Observable` 在一段延时后，产生唯一的一个元素**                                                                                                          |
| **using**                | **创建一个可被清除的资源，它和 `Observable` 具有相同的寿命**                                                                                                         |
| **window**               | **将 `Observable` 分解为多个子 `Observable`，周期性的将子 `Observable` 发出来**                                                                                  |
| **withLatestFrom**       | **将两个 `Observables` 最新的元素通过一个函数组合起来，当第一个 `Observable` 发出一个元素，就将组合后的元素发送出来**                                                                     |
| **zip**                  | **通过一个函数将多个 `Observables` 的元素组合起来，然后将每一个组合的结果发出来**                                                                                              |
| range                    | 一个序列，类似for循环                                                                                                                                    |
|                          |                                                                                                                                                 |
|                          |                                                                                                                                                 |
|                          |                                                                                                                                                 |

## 2.combineLatest

```swift
 let a = PublishSubject<String>()
 let b = PublishSubject<String>()
 let c = PublishSubject<String>()

 PublishSubject<String>.combineLatest([a,b]).bind { t in
     print(t)
 }.disposed(by: bag)
        
        
 a.onNext("a1")
 a.onNext("a2")
 b.onNext("b1")
 b.onNext("b2")
 a.onNext("a3")
 
//  ["a2", "b1"]
//  ["a2", "b2"]
//  ["a3", "b2"]
// 必须每个元素都发出过元素
// 每个事件触发时，都会把其它源最新的事件取出来组合一起发送出来
```

## 3.merge

```swift
 let a = PublishSubject<String>()
 let b = PublishSubject<String>()
 let c = PublishSubject<String>()

 PublishSubject<String>.merge([a,b]).bind { t in
     print(t)
 }.disposed(by: bag)
        
        
 a.onNext("a1")
 a.onNext("a2")
 b.onNext("b1")
 b.onNext("b2")
 a.onNext("a3")
 /*
a1
a2
b1
b2
a3
*/
// 就是简单的将多个类型相同的源合并为一个源
```

## 4.zip

```swift
 let a = PublishSubject<String>()
 let b = PublishSubject<String>()
 let c = PublishSubject<String>()

 PublishSubject<String>.zip([a,b]).bind { t in
     print(t)
 }.disposed(by: bag)
        
        
 a.onNext("a1")
 a.onNext("a2")
 b.onNext("b1")
 b.onNext("b2")
 a.onNext("a3")
/*
["a1", "b1"]
["a2", "b2"]
*/
// 简单的配对，a的第一个和b第二个，a的第二个和b的第二个
// 如果不能凑对，就不会发出
```

## 5.withLatestFrom

```swift
 let a = PublishSubject<String>()
        let b = PublishSubject<String>()
        let c = PublishSubject<String>()

        
        
        b.withLatestFrom(a).bind { t in
            print(t)
        }.disposed(by: bag)
        
        
        a.onNext("a1")
        a.onNext("a2")
        a.onNext("a3")
        b.onNext("b1")
        b.onNext("b2")
        
        /*
        a3
				a3
        */
        
// 当b触发的时候，就发出a的最新事件。如果a还没有事件，那么就不会发出任何事件
```

## 6 flatMapLatest

- **`flatMap`**：把源序列的元素映射成一个新的 **Observable**，然后把所有内部 Observable 合并成一个。
- **`flatMapLatest`**：和 `flatMap` 类似，但它只会订阅并接收 **最新的 Observable** 的事件，旧的会被丢弃。

> 想象你在搜索框输入关键字，每次输入都会发起一个网络请求。你只关心**最后一次请求**的结果（最新的输入），前面输入触发的请求即使有结果也不要了。

```swift
let disposeBag = DisposeBag()

// 模拟一个输入框
let textInput = PublishSubject<String>()

// 每次输入触发一个“网络请求”
func fakeRequest(_ query: String) -> Observable<String> {
    return Observable<String>.create { observer in
        print("开始请求: \\(query)")
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            observer.onNext("结果 for \\(query)")
            observer.onCompleted()
        }
        return Disposables.create()
    }
}

textInput
    .flatMapLatest { query in
        return fakeRequest(query)
    }
    .subscribe(onNext: { result in
        print("收到: \\(result)")
    })
    .disposed(by: disposeBag)

textInput.onNext("A")   // 请求 A
textInput.onNext("AB")  // 请求 AB
textInput.onNext("ABC") // 请求 ABC

```

## 10.线程优先级

```swift
MainScheduler.instance
ConcurrentDispatchQueueScheduler(qos: .background) // 并行
SerialDispatchQueueScheduler(qos: .background) // 串行
```

## 11 chatgpt的总结

### 1 创建类（Creating）

|操作符|描述|示例|
|---|---|---|
|`just`|发出单个元素后结束|`Observable.just(1)`|
|`of`|发出一组固定元素|`Observable.of(1,2,3)`|
|`from`|把数组逐个发出|`Observable.from([1,2,3])`|
|`empty`|不发出元素，只结束|`Observable<Int>.empty()`|
|`never`|不发出元素，也不结束|`Observable.never()`|
|`error`|直接发出错误|`Observable.error(MyError.x)`|
|`create`|自定义事件序列|`Observable.create { obs in obs.onNext(1) }`|
|`deferred`|订阅时再创建 Observable|`Observable.deferred { .just(Int.random()) }`|
|`interval`|周期性发出整数|`Observable.interval(.seconds(1), scheduler: MainScheduler.instance)`|
|`timer`|延时或周期性发出|`Observable.timer(.seconds(1), period: .seconds(2), scheduler: MainScheduler.instance)`|

---

### 2️⃣ 变换类（Transforming）

|操作符|描述|示例|
|---|---|---|
|`map`|元素逐个映射|`.map { $0 * 2 }`|
|`flatMap`|转换为新 Observable 并合并|`.flatMap { fetchData(id: $0) }`|
|`flatMapLatest`|只订阅最新的 Observable|`.flatMapLatest { queryAPI($0) }`|
|`concatMap`|顺序订阅映射的 Observables|`.concatMap { loadPage($0) }`|
|`scan`|累加中间值|`.scan(0,+)`|
|`buffer`|缓存后一次性发出|`.buffer(timeSpan:.seconds(2), count:3, scheduler:MainScheduler.instance)`|
|`window`|分片为多个 Observable|`.window(timeSpan:.seconds(1), count:2, scheduler:MainScheduler.instance)`|

---

### 3️⃣ 过滤类（Filtering）

|操作符|描述|示例|
|---|---|---|
|`filter`|过滤条件成立的元素|`.filter { $0 > 5 }`|
|`take`|取前 N 个|`.take(3)`|
|`takeLast`|取最后 N 个|`.takeLast(2)`|
|`skip`|跳过前 N 个|`.skip(2)`|
|`distinctUntilChanged`|忽略连续重复|`.distinctUntilChanged()`|
|`debounce`|停止输入一段时间才发出最后值|`.debounce(.milliseconds(300), scheduler: MainScheduler.instance)`|
|`throttle`|时间窗口内只发出第一个|`.throttle(.seconds(1), scheduler: MainScheduler.instance)`|
|`sample`|采样最新值|`.sample(trigger)`|
|`elementAt`|取第 N 个元素|`.elementAt(2)`|

---

### 4️⃣ 组合类（Combining）

|操作符|描述|示例|
|---|---|---|
|`merge`|合并多个序列|`Observable.merge([obs1, obs2])`|
|`concat`|顺序拼接序列|`Observable.concat(obs1, obs2)`|
|`zip`|按顺序配对|`Observable.zip(obs1, obs2)`|
|`combineLatest`|任一源有新值时组合|`Observable.combineLatest(obs1, obs2)`|
|`withLatestFrom`|触发时取另一个最新值|`trigger.withLatestFrom(source)`|
|`switchLatest`|只转发最新序列|`sources.switchLatest()`|

---

### 5️⃣ 错误处理（Error Handling）

|操作符|描述|示例|
|---|---|---|
|`catchError`|出错时切换序列|`.catchError { _ in .just(-1) }`|
|`catchErrorJustReturn`|出错时给默认值|`.catchErrorJustReturn(-1)`|
|`retry`|出错时重试|`.retry(3)`|

---

### 6️⃣ 实用类（Utility）

|操作符|描述|示例|
|---|---|---|
|`delay`|延时发出|`.delay(.seconds(2), scheduler: MainScheduler.instance)`|
|`do`|插入副作用|`.do(onNext:{print($0)})`|
|`materialize`|事件转成元素|`.materialize()`|
|`dematerialize`|还原事件流|`.dematerialize()`|
|`timeout`|超时报错|`.timeout(.seconds(5), scheduler: MainScheduler.instance)`|
|`using`|管理资源|`Observable.using(resourceFactory:..., observableFactory:...)`|

---

### 7️⃣ 条件/布尔（Conditional / Boolean）

|操作符|描述|示例|
|---|---|---|
|`amb`|谁先发就用谁|`obs1.amb(obs2)`|
|`takeUntil`|满足条件时停止|`.takeUntil(trigger)`|
|`skipUntil`|条件触发前跳过|`.skipUntil(trigger)`|
|`all`|判断是否所有元素满足|`.all { $0 > 0 }`|

---

### 8️⃣ 转换成其他（Transforming to Other Observables）

|操作符|描述|示例|
|---|---|---|
|`toArray`|收集为数组|`.toArray()`|
|`reduce`|归约成一个结果|`.reduce(0,+)`|
|`count`|元素数量|`.count()`|
