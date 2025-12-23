## 1.安装
```bash
# 使用brew安装
brew install carthage
```
##  2.配置文件
在项目工程中配置文件
```shell
touch Cartfile
```
## 3.添加项目依赖
```bash
# 必须5.x版本 (大于或等于 5.0 ，小于 6.0)
github "SnapKit/SnapKit" ~> 5.0.0
# 最低2.3.1版本 
github "ReactiveCocoa/ReactiveCocoa" >= 2.3.1 
# 必须0.4.1版本 
github "jspahrsummers/libextobjc" == 0.4.1

```
## 4.常用命令
```bash
# 安装库
carthage update
# 安装库指定iOS平台
carthage update --platform iOS
# 安装库在指定平台使用 xcframeworks
carthage update --platform iOS --use-xcframeworks

carthage update --platform iOS --use-xcframeworks --no-use-binaries
# 删除某个缓存
rm -rf ~/Library/Caches/org.carthage.CarthageKit/dependencies/smuikit

#更新其中一个，名称为下面的名称
sui@iMac-M1 Project % carthage update smuikit --use-xcframeworks --platform iOS

******* Fetching **SuiDB-iOS**

******* Fetching **smuikit**

******* Fetching **datasource-formula-ios**

******* Fetching **KissXML**

******* Fetching **Osprey-iOS**

******* Fetching **Masonry**

******* Fetching **SuiModuleKit**

******* Fetching **PieChart**

******* Fetching **scuikit**

******* Fetching **AFNetworking**

******* Fetching **SuiAppMigration**

******* Fetching **SnapKit**

******* Fetching **SuiMonitor-iOS**

******* Fetching **suihybrid**

******* Fetching **Statistics-iOS**

******* Fetching **JLRoutes**

******* Fetching **SuiNetworking-iOS**

******* Fetching **MJRefresh**

******* Fetching **MyMoneyDAO**

******* Fetching **MyMoneyVendor-iOS**

******* Fetching **lottie-ios**

******* Fetching **YYModel**

******* Fetching **SDWebImage**

******* Fetching **SuiFoundation-iOS**

******* Fetching **fmdb**


```


## 5.工程引入
在`General`的Frameworks中引入库

## 6.创建自己的库
