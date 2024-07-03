# MMKV

## 介绍

一款小型键值对存储框架

- 支持存储 number、boolean、string、Set<String>类型数据存储
- 支持继承组件中 SerializeBase.ets 的 class 类对象的序列化反序列化
- 支持存储数据备份
- 支持存储数据恢复

## 下载安装

```
ohpm install @ohos/mmkv
```
OpenHarmony ohpm 环境配置等更多内容，请参考[如何安装 OpenHarmony ohpm 包](https://gitee.com/openharmony-tpc/docs/blob/master/OpenHarmony_har_usage.md)


## 使用

### 1、初始化：设置 mmkv 保存文件根目录(rootPath)和缓存目录(cachePath)

    MMKV.initialize(rootPath, cachePath)

### 2、实例化 mmkv：

    let mmkv = MMKV.getBackedUpMMKVWithID(mmapID, MMKV.SINGLE_PROCESS_MODE, "Tencent MMKV", backupRootDir);

### 3、存取键值对数据:
#### 3.1 常用数据类型：boolean、number、string、Set<string>
##### 存数据示例：

    mmkv.encodeBool('abool', false)
    mmkv.encodeNumber('anumber', 3.0122)
    mmkv.encodeString('astring', 'dsfsg')
    let set1 = new Set<string>()
    set1.add('ass1')
    mmkv.encodeSet('aSet', set1)
##### 取数据示例：

    mmkv.decodeBool('abool')
    mmkv.decodeNumber('astring')
    mmkv.decodeString('aNumber')
    mmkv.decodeSet('aSet')

#### 3.2 类对象数据的序列化反序列化
##### 类对象需要继承 SerializeBase类，需序列化属性需要标识注解@Serialize() 如：

    class MyClass extends SerializeBase{
        @Serialize()
        public code: number = 0;
        public title: string = 'titles';
        @Serialize()
        public description: string = 'descs';
    }
##### 存数据：

    let myClass1 = new MyClass(1, 't1', 'desc1')
    kv.encodeSerialize('serialize111', myClass1)
##### 取数据：

    let myClass2 = kv.decodeSerialize('serialize111', new MyClass())

### 4、系统轻量级存储数据转存为mmkv存储

    //name:context：上下文, preference文件名, callback：异步回调
    preferencesToMMKV(name: string, callback: ICallBack, context: Context)

### 5、设置加密密钥

    mmkv.reCryptKey('Key_seq_1') //Key_seq_1：加密密钥

### 6、数据备份

##### 备份otherDir路径mmapID的mmkv存储数据到backupRootDir

    MMKV.backupOneToDirectory(mmapID, backupRootDir, otherDir)//mmapID：需要备份的mmapID；backupRootDir：备份到目标路径；otherDir：待备份所在路径

##### 备份全部mmkv存储数据到backupRootDir

    MMKV.backupAllToDirectory(backupRootDir) //backupRootDir：备份到目标路径

### 7、数据恢复

##### 从srcDir恢复mmkv存储数据

    MMKV.restoreOneMMKVFromDirectory(mmapID, srcDir, otherDir)//mmapID：需要恢复的mmapID；srcDir：目标路径；otherDir：待备份所在路径

##### 恢复srcDir路径下的全部mmkv存储数据

    MMKV.restoreAllFromDirectory(srcDir) //srcDir： 目标路径

### 8、清除所有存储数据

    mmkv.clearAll()

## 接口说明

| 方法名                               | 入参                                                             | 接口描述                |
|-----------------------------------|----------------------------------------------------------------|---------------------|
| version                           | 无                                                              | 获取 native版本         |
| getRootDir                        | 无                                                              | 获取存储路径              |
| pageSize                          | 无                                                              | 获取设备内存页数量           |
| getDefaultMMKV                    | mode?: number, cryptKey?: string                               | 创建默认实例              |
| totalSize                         | 无                                                              | 获取基础文件的大小           |
| encode                            | key: string, value: number、Set<string>、string、boolean          | 存储数据                |
| decodeString                      | key: string, defaultValue?: string                             | 根据key获取字符串值         |
| decodeBool                        | key: string, defaultValue?: boolean                            | 根据key获取布尔值          |
| decodeNumber                      | handle: string, key: string, defaultValue: number              | 根据key获取number值      |
| decodeSet                         | key: string, defaultValue?: Set<string>                        | 根据key获取数组值          |
| containsKey                       | key: string                                                    | 检查是否包含传入的key        |
| getCryptKey                       | 无                                                              | 获取加密密钥              |
| getMMapID                         | 无                                                              | 获取实例id              |
| removeValueForKey                 | key: string                                                    | 按key移除值             |
| removeValuesForKeys               | value: string[]                                                | 批量移除值               |
| clearAll                          | 无                                                              | 清除所有键值              |
| count                             | 无                                                              | 获取key的数量            |
| isFileValid                       | mmapID: string                                                 | 检查MMKV文件是否有效        |
| reCryptKey                        | cryptKey: string                                               | 重新设置密钥              |
| backupOneToDirectory              | mmapID: string, dstDir: string, rootPath: string               | 将一个MMKV实例备份到dstDir  |
| backupAllToDirectory              | dstDir: string                                                 | 将所有MMKV实例备份到dstDir  |
| restoreOneMMKVFromDirectory       | mmapID: string, srcDir: string, rootPath: string               | 从srcDir恢复一个MMKV实例   |
| restoreAllFromDirectory           | srcDir: string                                                 | 从srcDir恢复所有MMKV实例   |
| initialize                        | root: string, cachePath: string, logLevel?: MMKVLogLevel       | 初始化MMKV             |
| getBackedUpMMKVWithID             | mmapID: string, mode: number, crpKey: string, rootPath: string | 获取备份MMKV实例          |
| encodeSerialize                   | key: string, value: SerializeBase                              | 存储序列化数据             |
| decodeSerialize                   | key: string, defaultValue: T                                   | 按key获取序列化数据         |
| encodeString                      | key: string, value: string                                     | 存储String数据          |
| encodeSet                         | key: string, value: Set<string>                                | 存储Set数据             |
| encodeBool                        | key: string, value: boolean                                    | 存储Bool数据            |
| encodeNumber                      | key: string, value: number                                     | 存储Number数据          |
| getAllKeys                        | 无                                                              | 获取所有key             |
| clearMemoryCache                  | 无                                                              | 清除MMKV实例的内存缓存       |
| actualSize                        | 无                                                              | 获取MMKV实例的实际使用大小     |
| getHandle                         | 无                                                              | 获取MMKV 实例句柄         |
| close                             | 无                                                              | 关闭mmkv实例            |
| trim                              | 无                                                              | 清除MMKV实例中的所有键值      |
| checkContentChangedByOuterProcess | 无                                                              | 手动检查进程间内容更改         |
| setLogLevel                       | level: MMKVLogLevel                                            | 设置日志级别              |
| checkReSetCryptKey                | cryptKey: string                                               | 重置加密密钥（不会加密或解密任何内容） |
| simpleLog                         | level: MMKVLogLevel, message: string                           | 打印日志                |
| preferencesToMMKV                 | context: Context, name: string, callback: ICallBack            | 系统轻量级存储数据转存为mmkv存储  |
| LogUtil.d                         | message: string                                                | 打印debug类型日志         |
| LogUtil.i                         | message: string                                                | 打印info类型日志          |
| LogUtil_e                         | message: string                                                | 打印error类型日志         |
| isEnd                             | 无                                                              | 获取文件读取是否结束          |
| close                             | 无                                                              | 文件读取关闭              |

单元测试用例详情见[TEST.md](https://gitee.com/openharmony-tpc/MMKV/blob/master/TEST.md)

## 约束与限制

在下述版本验证通过：

- DevEco Studio: 4.0 (4.0.3.513), SDK: API10 (4.0.10.10)
- DevEco Studio: 4.0 Canary2(4.0.3.312), SDK: API10 (4.0.9.3)
- DevEco Studio: 3.1 Beta2(3.1.0.400), SDK: API9 Release(3.2.11.9)

## 目录结构

```
|----MMMKV
|     |---- entry  # 示例代码文件夹
|     |---- MMMKV  # MMMKV库文件夹
|           |---- index.ets  # 对外接口
|     |---- README.md  # 安装使用方法
```

## 贡献代码

使用过程中发现任何问题都可以提 [Issue](https://gitee.com/openharmony-tpc/MMKV/issues) 给我们，当然，我们也非常欢迎你给我们发 [PR](https://gitee.com/openharmony-tpc/MMKV/pulls) 。

## 开源协议

本项目基于 [BSD 3-Clause License](https://www.tizen.org/bsd-3-clause-license) ，请自由地享受和参与开源。
