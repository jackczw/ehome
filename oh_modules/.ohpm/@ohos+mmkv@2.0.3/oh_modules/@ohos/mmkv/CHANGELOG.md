## 2.0.3
- 适配DevEco Studio: 4.0 (4.0.3.513), SDK: API10 (4.0.10.10)
- ArkTs语法适配

## 2.0.2
- 修复JSON.stringify获取的length不准确导致文件截取问题
- preferencesToMMKV接口增加context可选传参
- 修改test.md内容
- 去除多进程相关接口，以及MMKV一些无用接口

## 2.0.1
- 修复MMKV存入大文件，读取时内容截取的问题。
- preferencesToMMKV接口增加callback回调。

## 2.0.0
- 包管理工具由npm切换为ohpm
- 适配DevEco Studio: 3.1 Beta2(3.1.0.400)
- 适配SDK: API9 Release(3.2.11.9) 
- napi层修复double转long精度失准导致闪退的问题

## 1.0.7
- 适配Api9
- 新增系统preferences文件数据转存mmkv文件中存储

## 1.0.6
- hvigor工程结构整改

## 1.0.4
一款小型键值对存储框架
- 支持存储number、boolean、string、Set<String>类型数据存储
- 支持继承组件中SerializeBase.ets的class类对象的序列化反序列化
- 支持存储数据备份
- 支持存储数据恢复
- 支持系统dataStorage的API的存储数据转移存到mmkv存储文件中

