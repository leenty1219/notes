## 修改最近的一条日制

```shell
# 修改最近一条日志信息
git commit --amend -m "MMDI-19580【AI记账】退款类型需要显示绿色和负号，撤回编辑退款标题的修改"
# 强制推送到服务器，注意如果是多人合作开发，队友也需要强制更新
git push origin bugfix/MMDI-19580 --force
```

