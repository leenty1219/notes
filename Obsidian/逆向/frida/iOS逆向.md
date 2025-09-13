## 1. Frida安装

设备越狱完成后，如果没有frida商店手动安装

> 这个似乎没什么用，本来想的是安装cydia 地址：[https://github.com/frida/frida/releases/](https://github.com/frida/frida/releases/)

```jsx
scp frida_14.2.18_iphoneos-arm.deb root@192.168.50.235:/tmp #将本地包拷贝到手机
cd /tmp // 安装
dpkg -i frida_14.2.18_iphoneos-arm.deb// 安装
```

安装`Frida`需要依赖`pip`安装工具，`pip`是集成在`python`环境中。首先需要安装`python`，为了保险起见安装Python版本 `3.8.10`

### 1.安装python

进入python的安装网站：[https://www.python.org/downloads/](https://www.python.org/downloads/) 在旧版本中找到`3.8.10`安装器安装。

```bash
pip3 install frida==14.2.18 
# 大概率会证书报错
sudo pip3 install --upgrade certifi # 更新证书
# 如果此时还会报错，那么就采用下载到本地安装
```

到

[`https://files.pythonhosted.org/packages/ec/95/9c04e212ed9d0dbae88b14c9ac9476815a9b377e6db63a3e7efca379412f/frida-14.2.18-py3.8-macosx-10.9-x86_64.egg](<https://files.pythonhosted.org/packages/ec/95/9c04e212ed9d0dbae88b14c9ac9476815a9b377e6db63a3e7efca379412f/frida-14.2.18-py3.8-macosx-10.9-x86_64.egg>)` 下载对应版本的固件。

执行命令 `pip3 install frida==14.2.18` 直接就会从本地安装成功了

> 注意下载的本地文件，要放到user目录下

安装另外一个工具 `frida-tools`

```bash
pip3 install frida-tools==9.2.5
```

> 记录一下可用的frida版本

```bash
frida --version # 16.2.1
frida-tools      #  12.3.0
frida-server # 16.5.9
objection #1.11.0  遇到问题的话，升级一下（1.11相对frida来说偏低）
```

砸壳

`CrackerXI` 和 `frida-ios-dump`

`AFC2` （App File Counter）可能会出现好几个，查看支持的版本号来安源装一个合适的

## 源

### 添加的源

- [https://apt.cydiami.com](https://apt.cydiami.com)
- [https://apt.cydia.ren](https://apt.cydia.ren)
- [https://apt.cdalei.com](https://apt.cdalei.com)
- [https://repo.amg789.com](https://repo.amg789.com)
- [https://apt.bingner.com](https://apt.bingner.com)
- [https://apt.thebigboss.org/repofiles/cydia](https://apt.thebigboss.org/repofiles/cydia)
- [https://repo.byteage.com](https://repo.byteage.com)
- [https://repo.chariz.com](https://repo.chariz.com)
- [https://cydia.akemi.ai](https://cydia.akemi.ai)
- [https://apt.cydiakk.com](https://apt.cydiakk.com)
- [https://aptso.cn](https://aptso.cn)
- [https://build.frida.re](https://build.frida.re)
- [https://apt.maskjb.com](https://apt.maskjb.com)
- [https://apt.tinyapps.cn](https://apt.tinyapps.cn)
- [https://xia0z.github.io](https://xia0z.github.io)
- [https://getzbra.com/repo](https://getzbra.com/repo)
- [https://cydia.zodttd.com/repo/cydia](https://cydia.zodttd.com/repo/cydia)
- [https://apt.zorrovip.com](https://apt.zorrovip.com)
- [https://apt.wxhbts.com](https://apt.wxhbts.com)
- [https://apt.ncydia.com](https://apt.ncydia.com)
- [https://apt.ssoes.com](https://apt.ssoes.com)

• [https://repo.misty.moe/apt/](https://repo.misty.moe/apt/) 直接包含了SSL kill

### 使用DeRootifier来转行64位的deb

```bash
#克隆项目
git clone <https://github.com/haxi0/Derootifier.git>
cd DeRootifier
./build.command # 指向编译
```

加密工具

[`https://gchq.github.io/CyberChef/`](https://gchq.github.io/CyberChef/)

```bash
frida-ps -U # 直接看手机的运行程序
```