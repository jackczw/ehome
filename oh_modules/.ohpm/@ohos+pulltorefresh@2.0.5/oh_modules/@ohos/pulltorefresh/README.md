# PullToRefresh

## 简介

> PullToRefresh是一款OpenHarmony环境下可用的下拉刷新、上拉加载组件。
> 支持设置内置动画的各种属性，支持设置自定义动画。

#### 效果展示：

内置动画效果

![Refresh](gifs/Refresh.gif)![Refresh](gifs/LoadMore.gif)

## 下载安装

```shell
ohpm install @ohos/pulltorefresh
```

## 使用说明

### 快速使用

```typescript
import { PullToRefresh } from '@ohos/pulltorefresh'

// 需绑定列表或宫格组件
private scroller: Scroller = new Scroller();
  
PullToRefresh({
// 必传项，列表组件所绑定的数据
data: $data,
// 必传项，需绑定传入主体布局内的列表或宫格组件
scroller: this.scroller,
// 必传项，自定义主体布局，内部有列表或宫格组件
customList: () => {
  // 一个用@Builder修饰过的UI方法
  this.getListView();
},
// 可选项，下拉刷新回调
onRefresh: () => {
  return new Promise<string>((resolve, reject) => {
    // 模拟网络请求操作，请求网络2秒后得到数据，通知组件，变更列表数据
    setTimeout(() => {
      resolve('刷新成功');
      this.data = this.dataNumbers;
    }, 2000);
  });
},
// 可选项，上拉加载更多回调
onLoadMore: () => {
  return new Promise<string>((resolve, reject) => {
    // 模拟网络请求操作，请求网络2秒后得到数据，通知组件，变更列表数据
    setTimeout(() => {
      resolve('');
      this.data.push("增加的条目" + this.data.length);
    }, 2000);
  });
},
customLoad: null,
customRefresh: null,
})
```

设置属性示例和设置自定义动画示例请看[示例entry](https://gitee.com/openharmony-sig/PullToRefresh/tree/master/entry/src/main/ets/pages)

## 属性（接口）说明

### PullToRefresh组件属性

| 属性                 | 类型                                                             | 释义                           | 默认值                         |
| :------------------:| :-------------------------------------------------------------: | :---------------------------: | :----------------------------: |
| data                | Object[]                                                             | 列表或宫格组件所绑定的数据         | undefined                      |
| scroller            | Scroller                                                        | 列表或宫格组件所绑定的Scroller对象 | undefined                      |
| customList          | ```() => void   ```                                             | 自定义主体布局，内部有列表或宫格组件 | undefined                      |
| refreshConfigurator | PullToRefreshConfigurator                                       | 组件属性配置                    | PullToRefreshConfigurator      |
| mWidth              | Length                                                          | 容器宽                         | undefined（自适应）              |
| mHeight             | Length                                                          | 容器高                         | undefined（自适应）              |
| onRefresh           | ```() => Promise<string>```                                     | 下拉刷新回调                    | 1秒后结束下拉刷新动画并提示“刷新失败” |
| onLoadMore          | ```() => Promise<string>```                                     | 上拉加载更多回调                 | 1秒后结束上拉加载动画              |
| customRefresh       | ```() => void ```                                               | 自定义下拉刷新动画布局            | undefined                      |
| onAnimPullDown      | ```(value?: number, width?: number, height?: number) => void``` | 下拉中回调                      | undefined                      |
| onAnimRefreshing    | ```(value?: number, width?: number, height?: number) => void``` | 刷新中回调                      | undefined                      |
| customLoad          | ```() => void```                                                | 自定义上拉加载动画布局            | undefined                      |
| onAnimPullUp        | ```(value?: number, width?: number, height?: number) => void``` | 上拉中回调                      | undefined                      |
| onAnimLoading       | ```(value?: number, width?: number, height?: number) => void``` | 加载中回调                      | undefined                      |

### PullToRefreshConfigurator类接口

| 接口                       | 参数类型                     | 释义                       | 默认值            |
| :------------------------:| :-------------------------: | :-----------------------: | :--------------: |
| setHasRefresh             | boolean                     | 是否具有下拉刷新功能          | true             |
| setHasLoadMore            | boolean                     | 是否具有上拉加载功能          | true             |
| setMaxTranslate           | number                      | 可下拉上拉的最大距离          | 100              |
| setSensitivity            | number                      | 下拉上拉灵敏度               | 0.7              |
| setListIsPlacement        | boolean                     | 滑动结束后列表是否归位         | true             |
| setAnimDuration           | number                      | 滑动结束后，回弹动画执行时间    | 150              |
| setRefreshHeight          | number                      | 下拉动画高度                 | 30               |
| setRefreshColor           | string                      | 下拉动画颜色                 | '#999999'        |
| setRefreshBackgroundColor | ResourceColor               | 下拉动画区域背景色            | 'rgba(0,0,0,0)'  |
| setRefreshTextColor       | ResourceColor               | 下拉加载完毕后提示文本的字体颜色 | '#999999'        |
| setRefreshTextSize        | number 或 string 或 Resource | 下拉加载完毕后提示文本的字体大小 | 18               |
| setRefreshAnimDuration    | number                      | 下拉动画执行一次的时间         | 1000             |
| setLoadImgHeight          | number                      | 上拉动画中图片的高度           | 30               |
| setLoadBackgroundColor    | ResourceColor               | 上拉动画区域背景色            | 'rgba(0,0,0,0)'   |
| setLoadTextColor          | ResourceColor               | 上拉文本的字体颜色            | '#999999'         |
| setLoadTextSize           | number 或 string 或 Resource | 上拉文本的字体大小            | 18                |
| setLoadTextPullUp1        | string                      | 上拉1阶段文本                | '正在上拉刷新...'   |
| setLoadTextPullUp2        | string                      | 上拉2阶段文本                | '放开刷新'         |
| setLoadTextLoading        | string                      | 上拉加载更多中时的文本         | '正在玩命加载中...' |

## 约束与限制

在下述版本验证通过：
- DevEco Studio: 4.1 Canary(4.1.3.317), SDK: API11 (4.1.0.36)
- DevEco Studio: 4.0 (4.0.3.512), SDK: API10 (4.0.10.9)
- DevEco Studio: 4.0 Canary2(4.0.3.300), SDK: API10 (4.0.8.6)

## 贡献代码

使用过程中发现任何问题都可以提 [Issue](https://gitee.com/openharmony-sig/PullToRefresh/issues)
给我们，当然，我们也非常欢迎你给我们发 [PR](https://gitee.com/openharmony-sig/PullToRefresh/pulls) 。

## 开源协议

本项目基于 [Apache License 2.0](https://gitee.com/openharmony-sig/PullToRefresh/blob/master/LICENSE) ，请自由地享受和参与开源。

## 遗留问题

1.自定义列表组件需要设置为无边缘效果(例如:List组件需要设置.edgeEffect(EdgeEffect.None))。