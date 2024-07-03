## 2.2.0
- 修复错误图绘制完后变成占位图
- 提供图片加载成功/失败的事件
- 修复懒加载在多次点击出现卡死的问题
- 支持多种组合变换
- 提供清理缓存能力
- 修复preLoad接口失效
- 修复多线程图片加载出现空白问题
- 获取组件宽高改用onSizeChange （需要API12）
- svg解码宽高单位给位px
- 修复复用场景下从内存获取图片后又清空了画布导致图片不显示
- 修复复用场景主图比占位图绘制快后下次不显示占位图问题

## 2.2.0-rc.2
- ImageKnife支持下采样
- ImageKnife支持heic图片修改demo，按钮控制组件是否展示
- 修复通过磁盘链接加载图片无法显示
- ImageKnife控制可视化区域图片
- 修复占位图、错误图、重试图从内存获取之后进入子线程导致内存泄露
- ImageKnifeComponent组件key属性改为id属性
- 修改header图的存储标志位

## 2.2.0-rc.1
- 修改ImageKnife跳过网络,点击默认,图片没有传入宽高,无显示bug
- ImageKnife支持根据自定义key获取已缓存的图片
- ImageKnife加载图片支持自定义网络栈和图片加载组件
- 适配复用场景触发懒加载onDataReloaded
- ImageKnife控制重要图片请求加载优先级

## 2.2.0-rc.0
- 修复自定义DataFetch接口实现不生效问题
- 修改磁盘缓存到子线程
- 更新SDK到API12
- 适配Sendable内存共享优化
- 修改全局请求头覆盖request请求头
- imageKnife支持heic测试demo独立页面展示
- drawLifeCycle支持gif图

## 2.1.2
- 修改ImageKnife跳过网络，从内存中获取图片 cacheType参数未使用bug
- 新增WEBP图片解析能力。
- 新增gif图片支持暂停播放功能

## 2.1.2-rc.12
- 新增gif播放次数功能
- 新增磁盘预加载返回文件路径接口prefetchToDiskCache
- 新增跳过网络判断缓存或者磁盘中是否存在图片接口isUrlExist
- 删除多余操作磁盘记录读写
- 清除定时器改为Gif图时清除
- uuid改为util.generateRandomUUID()

## 2.1.2-rc.11
- 修复设置磁盘容量最大值出现闪退
- 修复概率出现jscrash问题
- 修复进度条问题
- 修复单帧gif图片加载失败
- removeRunning删除running队列log设置开关
- ImageKnife新增图片宽高自适应功能
- 修复onlyRetrieveFromCache属性(仅磁盘和内存获取资源)失效
- 修改拼写错误
- 新增多线程优先级
- 修复复用场景下图片闪动以及概率错位
- 获取组件宽高改为使用CanvasRenderingContext2D对象获取宽高，并修复改变字体大小导致部分图片消失
- 修复获取不到磁盘缓存文件问题
- 修复获取不到网络请求错误回调问题

## 2.1.2-rc.10
- 修复部分gif图片识别成静态图
- 修复同一张图片发送多次请求
- 复用场景缓存到树aboutToRecycle清理定时器

## 2.1.2-rc.9
- 使用taskpool实现多线程加载图片资源
- 修复部分gif图片识别成静态图
- 修复同一张图片发送多次请求
- disAppear生命周期清空定时器只在gif图片时执行

## 2.1.2-rc.8
- onAreaChange绘制图片改为component Util绘制

## 2.1.2-rc.7
- 修复图片圆角图形变换导致抗锯齿、ScaleType失效
- 修复使用模糊化出现图片变模糊和变形

## 2.1.2-rc.6
- 修复手机调节显示大小时图片消失
- imageKnife防盗链，header请求头属性设置
- pngWorker线程改为taskpool
- 修复正方形裁剪有些图片裁剪创建pixelMap失败

## 2.1.2-rc.5
- moduleContext新增缓存策略，缓存上限5，缓存策略Lru
- 适配DevEco Studio 4.1（4.1.3.415）--SDK:API11（ 4.1.0.56）


## 2.1.2-rc.4
- canvas新增抗锯齿
- 修复图片缩放时出现重影

## 2.1.2-rc.3
- svg图片解码改为imageSource解码


## 2.1.2-rc.2
- HSP兼容性优化
- 暴露DetachFromLayout接口
- 修复无法识别部分svg图片的类型

## 2.1.2-rc.1
- 修复断网状态下错误占位图不显示
- 适配IDE4.1(4.1.3.322)和SDK API11(4.1.0.36)

## 2.1.2-rc.0
- 开放.jpg .png .gif的taskpool解码能力


## 2.1.1
- 屏蔽了taskpool解码能力
- 2.1.1正式版本发布

## 2.1.1-rc.5
- .jpg .png .gif解码功能使用taskpool实现
- 修复了内存缓存张数设置为1时gif图片消失的问题
- 新增内存缓存策略，新增缓存张数，缓存大小设置接口
- 磁盘存缓存setAsync改成同步
- 部分release释放放在异步
- requestInStream的回调改成异步
- 修复tasktool出现crash问题
- imageKnife依赖更名为library
- 解决外部定时器失效的问题


## 2.1.1-rc.4

- 删除pako源码依赖,使用ohpm依赖
- 删除gif软解码相关依赖库,包括gifuct-js和jsBinarySchemaParser
- 新增ImageKnife在HSP场景中的使用案例展示
- 更改ImageKnifeOption：
  新增可选参数context,HSP场景中在shard library中使用必须要传递当前library的context对象 （例如:getContext(this).createModuleContext('library') as common.UIAbilityContext）才能保证后续程序正常获取shared library中的Resource资源
- 更改RequestOption:
  新增接口setModuleContext(moduleCtx:common.UIAbilityContext)在HSP场景中必须调用该接口传入正确的context对象,保证HSP场景下正确访问资源
  新增接口getModuleContext():common.UIAbilityContext | undefined

## 2.1.1-rc.3

- 门面类ImageKnife新增pauseRequests接口,全局暂停请求
- 门面类ImageKnife新增resumeRequests接口,全局恢复暂停

## 2.1.1-rc.2

- gif解码改为imageSource解码,不在对worker强依赖
- 下载接口修改为http.requestInStream

## 2.1.1-rc.1

- 新增自定义key参数配置
- 新增MemoryLruCache主动调用PixelMap的release方法,释放native的PixelMap内存
- 新增ImageSource主动调用release方法释放native持有的ImageSource内存

## 2.1.1-rc.0

- 修复不兼容API9的问题

## 2.1.0

- ArkTs语法适配:

  globalThis.ImageKnife方式已经不可使用

  提供了ImageKnifeGlobal对象单例全局可访问

  访问ImageKnife对象需要使用ImageKnifeGlobal.getInstance().getImageKnife()

- 裁剪组件暴露PixelMapCrop组件和配置类Options, 配置类Options不再需要声明PixelMapCrop.Options中的PixelMapCrop命名空间

- 适配DevEco Studio 版本：4.0(4.0.3.512), SDK: API10 (4.0.10.9)

## 2.0.5-rc.0

- 修复若干问题：

​      优化了内存缓存策略，修复了内存缓存策略给布尔值不生效的问题

## 2.0.4

- 修复若干问题：

​      修复了pngj测试页面，快速点击导致应用闪退的问题


## 2.0.3

- 修复若干问题：

​      修复了部分url测试，多次点击加载gif动画重影的问题

​      优化了gif测试中的测试图片，加强了测试的直观性

​      解决gif图片只有1帧时因帧时间延时时间为NaN时导致图片帧不显示的问题


## 2.0.2

- 修复若干问题：

​      修复ImageKnife绘制部分复杂gif图片，gif图片闪屏显示的问题

​      适配DevEco Studio 版本：4.0 Canary2(4.0.3.312), SDK: API10 (4.0.9.3)



## 2.0.1

- 修复若干问题：

​      修复ImageKnifeDrawFactory中的setOval和setRect的中心点取值错误，导致部分圆角绘制失效的问题。

​      修复因重复下载导致的漏加载的问题。

- 新增用例看护已修复的问题

## 2.0.0

- 包管理工具由npm切换为ohpm。
- 适配DevEco Studio: 3.1Beta2(3.1.0.400)。
- 适配SDK: API9 Release(3.2.11.9)。
- 新增开发者可对图片缓存进行全局配置能力。
- 新增对OpenHarmony图库的Uri数据加载的能力（需要申请图库访问权限和文件读取权限，动态申请图库访问权限）。
- 修复若干问题：

​      ImageKnifeOption的loadSrc为undefined，导致的crash问题。

​      ImageKnifeComponent直接绘制GIF图片格式第几帧的时候，无法绘制问题。

## 1.0.6

- 适配DevEco Studio 3.1Beta1及以上版本。

- 适配OpenHarmony SDK API version 9及以上版本。

- 以下变换支持通过GPU进行图片变换，默认未开启，开启需要自行调用接口.enableGPU()。

  ​	支持模糊图片变换

  ​	支持亮度滤波器

  ​	支持颜色反转滤波器

  ​	支持对比度滤波器

  ​	支持灰色滤波器

  ​	支持桑原滤波器

  ​	支持马赛克滤波器

  ​	支持乌墨色滤波器

  ​	支持素描滤波器

  ​	支持扭曲滤波器

  ​	支持动画滤波器

  ​	支持装饰滤波器
## 1.0.5
- 自定义组件已支持通用属性和通用事件绑定,因此ImageKnifeComponent将删除相关内容,相关内容由用户自定义实现，提高扩展能力。

- ImageKnifeOption 支持列表绑定。

- ImageKnifeOption 。

  新增

  -  1.onClick事件属性 

  删除 

  - 1.size(设置大小) 
  - 2.sizeAnimated 显式动画 
  - 3.backgroundColor背景色
  - 4.margin 组件外间距 等属性,删除的属性将由通用属性提供支持,可支持在ImageKnifeComponent自定义组件上链式调用
## 1.0.4

- 渲染显示部分使用Canvas组件替代Image组件。

- 重构渲染封装层ImageKnifeComponent自定义组件。

- 新增GIF图片解析能力。

- 新增SVG图片解析能力。

- RequestOption删除addRetryListener接口,重试图层监听请使用retryholder接口。

## 1.0.3

- 适配OpenHarmony API9 Stage模型。
## 1.0.2
- 支持用户自定义扩展变换接口。

## 1.0.1
- 由gradle工程整改为hvigor工程。

## 1.0.0
专门为OpenHarmony打造的一款图像加载缓存库，致力于更高效、更轻便、更简单：
- 支持内存缓存，使用LRUCache算法，对图片数据进行内存缓存。
- 支持磁盘缓存，对于下载图片会保存一份至磁盘当中。
- 支持进行图片变换。
- 支持用户配置参数使用:(例如：配置是否开启一级内存缓存，配置磁盘缓存策略，配置仅使用缓存加载数据，配置图片变换效果，配置占位图，配置加载失败占位图等)。
- 推荐使用ImageKnifeComponent组件配合ImageKnifeOption参数来实现功能。
- 支持用户自定义配置实现能力参考ImageKnifeComponent组件中对于入参ImageKnifeOption的处理。

