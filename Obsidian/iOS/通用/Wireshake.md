### 连接手机

`rvictl -s iPhone设备id`

`rvictl -x iphone设备id`

### 过滤原地址

`ip.src == 139.178.159.27`

### 过滤目标地址

`ip.dst == 139.178.159.27`

`ip.src == 47.106.214.47 || ip.dst == 47.106.214.47` 深圳测试环境地址

**`tcp.port == 443`**