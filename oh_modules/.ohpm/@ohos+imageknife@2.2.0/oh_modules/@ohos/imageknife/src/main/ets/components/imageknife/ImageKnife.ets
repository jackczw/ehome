/*
 * Copyright (C) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { DiskLruCache } from "../cache/DiskLruCache"
import { EngineKeyFactories } from "../cache/key/EngineKeyFactories"
import { EngineKeyInterface } from "../cache/key/EngineKeyInterface"
import { CacheType, RequestOption, Size, ImageKnifeRequestState } from "../imageknife/RequestOption";
import { AsyncCallback } from "../imageknife/interface/AsyncCallback"
import { PlaceHolderManager } from "../imageknife/holder/PlaceHolderManager"
import { RetryHolderManager } from "../imageknife/holder/RetryHolderManager"
import { ErrorHolderManager } from "../imageknife/holder/ErrorHolderManager"
import { RequestManager } from "../imageknife/requestmanage/RequestManager"
import { NONE } from "../cache/diskstrategy/enum/NONE"
import { FileTypeUtil } from '../imageknife/utils/FileTypeUtil'
import { DownloadClient } from '../imageknife/networkmanage/DownloadClient'
import { IDataFetch } from '../imageknife/networkmanage/IDataFetch'
import { ParseResClient } from '../imageknife/resourcemanage/ParseResClient'
import { IResourceFetch } from '../imageknife/resourcemanage/IResourceFetch'
import { ImageKnifeData, ImageKnifeType } from '../imageknife/ImageKnifeData'
import { ImageKnifeGlobal } from '../imageknife/ImageKnifeGlobal'
import image from "@ohos.multimedia.image"
import http from '@ohos.net.http'
import { CompressBuilder } from "../imageknife/compress/CompressBuilder"
import { IDrawLifeCycle } from '../imageknife/interface/IDrawLifeCycle'
import { LogUtil } from '../imageknife/utils/LogUtil'
import { MethodMutex } from './utils/base/MethodMutex'
import worker from '@ohos.worker'
import common from '@ohos.app.ability.common'
import { MemoryLruCache } from '../cache/MemoryLruCache'
import { BusinessError } from '@ohos.base'
import taskpool from '@ohos.taskpool'
import { DefaultJobQueue } from './utils/DefaultJobQueue';
import { IJobQueue } from './utils/IJobQueue';
import LightWeightMap from '@ohos.util.LightWeightMap';
import List from '@ohos.util.List';
import { GIFFrame } from './utils/gif/GIFFrame'
import emitter from '@ohos.events.emitter';

import { MemoryCacheProxy } from './requestmanage/MemoryCacheProxy'
import { ObjectKey } from './ObjectKey'
import { Constants } from './constants/Constants'
import { TransformUtils } from './transform/TransformUtils'
import { GIFParseImpl } from './utils/gif/GIFParseImpl'
import { IParseImage } from './interface/IParseImage'
import { ParseImageUtil } from './utils/ParseImageUtil'
import { SVGParseImpl } from './utils/svg/SVGParseImpl'
import { SendableData } from './SendableData'
import { collections } from '@kit.ArkTS'
import { TaskParams } from './TaskParams'
import { MResource } from './utils/MResource'

export class ImageKnife {
  static readonly SEPARATOR: string = '/'
  memoryCache: MemoryLruCache;
  dataFetch: IDataFetch;
  resourceFetch: IResourceFetch<ArrayBuffer>;
  filesPath: string = ""; // data/data/包名/files目录
  diskMemoryCache: DiskLruCache;
  memoryCacheProxy: MemoryCacheProxy<string, ImageKnifeData> = new MemoryCacheProxy(new MemoryLruCache(100, 100 * 1024 * 1024));
  headerMap: Map<string, Object> = new Map<string, Object>(); //定义全局map
  placeholderCache: string = "placeholderCache"
  isPaused: boolean = false;
  mutex: MethodMutex = new MethodMutex();
  fileTypeUtil: FileTypeUtil; // 通用文件格式辨别
  diskCacheFolder: string = "ImageKnifeDiskCache"
  defaultListener: AsyncCallback<ImageKnifeData> = {
    callback: (err: string, data: ImageKnifeData) => {
      return false
    }
  }; // 全局监听器

  // gifWorker
  gifWorker: worker.ThreadWorker | undefined = undefined;
  defaultLifeCycle: IDrawLifeCycle | undefined = undefined;
  // 开发者可配置全局缓存
  engineKeyImpl: EngineKeyInterface;
  private mParseImageUtil: IParseImage<PixelMap>;
  // 最大并发
  maxRequests: number = 64;
  // 排队队列
  private jobQueue: IJobQueue = new DefaultJobQueue();
  // 执行中的请求
  private executingJobMap: LightWeightMap<string, List<RequestOption>> = new LightWeightMap();

  private constructor() {
    this.mParseImageUtil = new ParseImageUtil();

    // 构造方法传入size 为保存文件个数
    this.memoryCache = new MemoryLruCache(100, 100 * 1024 * 1024);

    // 创建网络下载能力
    this.dataFetch = new DownloadClient();

    // 创建本地数据解析能力
    this.resourceFetch = new ParseResClient();

    // 初始化本地 文件保存
    this.filesPath = (ImageKnifeGlobal.getInstance().getHapContext() as common.UIAbilityContext).filesDir as string;

    this.diskMemoryCache = DiskLruCache.create(ImageKnifeGlobal.getInstance()
      .getHapContext() as common.UIAbilityContext);

    // 通用文件格式识别初始化
    this.fileTypeUtil = new FileTypeUtil();

    this.engineKeyImpl = new EngineKeyFactories();

  }

  //全局设置请求头调用方法
  addHeader(key: string, value: Object) {
    this.headerMap.set(key, value);
  }

  deleteHeader(key: string) {
    this.headerMap.delete(key);
  }

  getMemoryCache(): MemoryLruCache {
    return this.memoryCache;
  }

  getMemoryCacheProxy(): MemoryCacheProxy<string, ImageKnifeData> {
    return this.memoryCacheProxy;
  }

  public static with(context: Object): ImageKnifeGlobal {
    // 存入hapContext;
    let global: ImageKnifeGlobal = ImageKnifeGlobal.getInstance();
    global.setHapContext(context)

    // 初始化ImageKnife
    if (!ImageKnife.sInstance) {
      ImageKnife.sInstance = new ImageKnife();
    }

    // 存入ImageKnife
    global.setImageKnife(ImageKnife.sInstance)

    return global;
  }

  getDiskMemoryCache(): DiskLruCache {
    return this.diskMemoryCache;
  };

  setDiskMemoryCache(diskLruCache: DiskLruCache) {
    this.diskMemoryCache = diskLruCache;
  };

  getFileTypeUtil(): FileTypeUtil {
    return this.fileTypeUtil;
  }

  getImageKnifeContext() {
    return ImageKnifeGlobal.getInstance().getHapContext();
  }

  setMemoryCache(lrucache: MemoryLruCache) {
    this.memoryCache = lrucache;
  }
  // 移除全部内存缓存
  removeAllMemoryCache(): void {
    this.memoryCacheProxy.removeAllValue();
  }
  // 移除全部磁盘缓存
  async removeAllFileCache(): Promise<void> {
    if (this.diskMemoryCache !== undefined) {
      await this.getDiskMemoryCache().cleanAllDiskCache();
    }
  }
  // 移除指定内存缓存
  removeMemoryCache(url: string): void {
    let key = this.getMemoryCacheKey(url);
    this.memoryCacheProxy.removeValue(key);
  }
  // 移除指定磁盘缓存
  removeFileCache(url: string): void {
    let key = this.getDiskCacheKey(url);
    this.diskMemoryCache.deleteCacheDataByKey(key);
  }
  // 获取指定内存缓存key值
  getMemoryCacheKey(url: string) {
    let request = new RequestOption();
    let factories: EngineKeyInterface;
    let dontAnimateFlag = request.dontAnimateFlag;
    let signature = request.signature;
    const imageSize: Size = {
      width: 200,
      height: 200,
    }
    let size = JSON.stringify(imageSize);
    if (this.engineKeyImpl) {
      factories = this.engineKeyImpl;
    } else {
      factories = new EngineKeyFactories();
    }
    let transformed = '';
    if (request && request.transformations) {
      for (let i = 0; i < request.transformations.length; i++) {
        if (i == request.transformations.length - 1) {
          transformed += request.transformations[i].getName() + "";
        } else {
          transformed += request.transformations[i].getName() + ",";
        }
      }
    }
    return factories.generateMemoryCacheKey(url, size, transformed, dontAnimateFlag, signature);
  }
  // 获取指定磁盘缓存key值
  getDiskCacheKey(url: string) {
    let request = new RequestOption();
    let signature = request.signature;
    let factories: EngineKeyInterface;
    if (this.engineKeyImpl) {
      factories = this.engineKeyImpl;
    } else {
      factories = new EngineKeyFactories();
    }
    return factories.generateOriginalDiskCacheKey(url, signature);
  }

  getDefaultListener() {
    return this.defaultListener;
  }

  setGifWorker(worker: worker.ThreadWorker) {
    this.gifWorker = worker
  }

  getGifWorker() {
    return this.gifWorker;
  }

  getDefaultLifeCycle() {
    return this.defaultLifeCycle;
  }

  setDefaultLifeCycle(viewLifeCycle: IDrawLifeCycle) {
    this.defaultLifeCycle = viewLifeCycle;
  }

  setEngineKeyImpl(impl: EngineKeyInterface) {
    this.engineKeyImpl = impl;
  }

  private static sInstance: ImageKnife;

  setDefaultListener(newDefaultListener: AsyncCallback<ImageKnifeData>) {
    this.defaultListener = newDefaultListener;
  }

  public compressBuilder(): CompressBuilder {
    return new CompressBuilder();
  }

  // 设置缓存张数，缓存大小，单位字节
  public setLruCacheSize(size: number, memory: number) {
    if (this.memoryCache.map.size() <= 0) {
      this.memoryCache = new MemoryLruCache(size, memory);
    } else {
      let newLruCache = new MemoryLruCache(size, memory);
      this.memoryCache.foreachLruCache((value: ImageKnifeData, key: string, map: Object) => {
        newLruCache.put(key, value);
      })
      this.memoryCache = newLruCache;
    }
  }

  public replaceDataFetch(fetch: IDataFetch) {
    this.dataFetch = fetch;
  }


  // 替代原来的DiskLruCache
  public replaceDiskLruCache(size: number) {
    this.diskMemoryCache.setMaxSize(size)
    // if (this.diskMemoryCache.getCacheMap().size() <= 0) {
    //   this.diskMemoryCache = DiskLruCache.create(ImageKnifeGlobal.getInstance().getHapContext(), size);
    // } else {
    //   let newDiskLruCache = DiskLruCache.create(ImageKnifeGlobal.getInstance().getHapContext(), size);
    //   this.diskMemoryCache.foreachDiskLruCache((value: string | ArrayBuffer, key: string, map: Object) => {
    //     newDiskLruCache.set(key, value);
    //   })
    //   this.diskMemoryCache = newDiskLruCache;
    // }
  }

  // 预加载 resource资源一级缓存，string资源实现二级缓存
  preload(request: RequestOption): void {
    // 每个request 公共信息补充
    request.setFilesPath(this.filesPath);
    return this.loadResources(request);
  }
  loadResources(request: RequestOption) {
    let factories: EngineKeyInterface;
    let cacheKey: string;
    let transferKey: string;
    let dataKey: string;
    if (this.engineKeyImpl) {
      factories = this.engineKeyImpl;
    } else {
      factories = new EngineKeyFactories();
    }
    // 生成内存缓存key 内存 变换后磁盘

    let loadKey = '';
    if (typeof request.loadSrc == 'string') {
      loadKey = request.loadSrc;
    } else {
      loadKey = JSON.stringify(request.loadSrc);
    }

    let size = JSON.stringify(request.size);

    let transformed = '';
    if (request && request.transformations) {
      for (let i = 0; i < request.transformations.length; i++) {
        if (i == request.transformations.length - 1) {
          transformed += request.transformations[i].getName() + "";
        } else {
          transformed += request.transformations[i].getName() + ",";
        }
      }
    }

    let dontAnimateFlag = request.dontAnimateFlag;

    let signature = request.signature;

    cacheKey = factories.generateMemoryCacheKey(loadKey,size,transformed,dontAnimateFlag,signature);

    // 生成磁盘缓存变换后数据key 变换后数据保存在磁盘
    transferKey = factories.generateTransformedDiskCacheKey(loadKey,size,transformed,dontAnimateFlag,signature);

    // 生成磁盘缓存源数据key 原始数据保存在磁盘
    dataKey = factories.generateOriginalDiskCacheKey(loadKey,signature);

    request.generateCacheKey = cacheKey;
    request.generateResourceKey = transferKey;
    request.generateDataKey = dataKey;

    this.loadCacheManager(request);
  }
  // 暂停所有请求
  async pauseRequests(): Promise<void> {
    await this.mutex.lock(async () => {
      this.isPaused = true;
    })
  }

  // 恢复所有被暂停的请求
  async resumeRequests(): Promise<void> {
    await this.mutex.lock(async () => {
      this.isPaused = false;
      if (this.executingJobMap.length > 0) {
        this.executingJobMap.forEach((list: List<RequestOption>) => {
          this.taskpoolLoadResource(list.get(0), Constants.MAIN_HOLDER);
        })
      } else {
        this.dispatchNextJob();
      }
    })
  }

  // 删除 请求
  remove(uuid: string) {
    LogUtil.log('VISIBLE: remove request ' + uuid);
    this.executingJobMap.remove(uuid);
  }

  // 正常加载
  call(request: RequestOption): void {
    // 添加全局监听
    if (this.defaultListener) {
      request.addListener(this.defaultListener)
    }

    // 每个request 公共信息补充
    request.setFilesPath(this.filesPath);

    if (this.headerMap.size > 0) {
      request.addHeaderMap(this.headerMap)
    }

    this.generateDataCacheKey(request)
    // 首先执行占位图 解析任务
    if (request.placeholderSrc) {
      this.taskpoolLoadResource(request, Constants.PLACE_HOLDER);
    }
    // 其次执行重试占位图 解析任务
    if (request.retryholderSrc) {
      this.taskpoolLoadResource(request, Constants.RETRY_HOLDER);
    }

    // 最后解析错误占位图
    if (request.errorholderSrc) {
      this.taskpoolLoadResource(request, Constants.ERROR_HOLDER);
    }
    return this.parseSource(request);
  }


  public isUrlExist(url: string, cacheType: CacheType = CacheType.Default, size: Size = {
    width: 0,
    height: 0
  }): Promise<ImageKnifeData> {

    return new Promise((resolve, reject) => {
      let request = new RequestOption();
      request.load(url)
        .setImageViewSize(size)
      this.generateDataCacheKey(request);
      let loadComplete = (imageKnifeData: ImageKnifeData) => {
        resolve(imageKnifeData);
      }
      let loadError = (err ?: BusinessError | string) => {
        if (cacheType == CacheType.Default) {
          this.loadMemoryDiskIsUrl(request, loadComplete, loadError);
        }
        reject(err);
      }

      if (cacheType == CacheType.Cache) {
        this.loadMemoryCacheIsUrl(request, loadComplete, loadError);

      } else if (cacheType == CacheType.Disk) {
        this.loadMemoryDiskIsUrl(request, loadComplete, loadError);
      }
      else if (cacheType == CacheType.Default) {
        this.loadMemoryCacheIsUrl(request, loadComplete, loadError);
      }
    })
  }


  loadMemoryCacheIsUrl(request: RequestOption, onComplete: (imageKnifeData: ImageKnifeData) => void | PromiseLike<ImageKnifeData>, onError: (err?: BusinessError | string) => void) {
    let cache = this.memoryCacheProxy.loadMemoryCache(request.generateCacheKey, true);
    if (cache == null || typeof cache == 'undefined') {
      onError("No data in cache!")
    } else {
      cache.waitSaveDisk = false;
      //2.网络缓存有数据，返回
      onComplete(cache);
    }
  }

  loadMemoryDiskIsUrl(request: RequestOption, onComplete: (imageKnifeData: ImageKnifeData) => void | PromiseLike<ImageKnifeData>, onError: (err?: BusinessError | string) => void) {
    let cached =  this.diskMemoryCache.get(request.generateDataKey);
    if (cached != null) {
      let filetype: string | null = this.fileTypeUtil.getFileType(cached);

      if (filetype == null) {
        onError('请检查数据源');
        return;
      }

      if (!this.fileTypeUtil.isImage(cached)) {
        onError('暂不支持的类型！类型=' + filetype);
      }

      if ((ImageKnifeData.GIF == filetype || ImageKnifeData.WEBP == filetype) && !request.dontAnimateFlag) {
        let gifParseImpl = new GIFParseImpl()
        gifParseImpl.parseGifs(cached, (data?: GIFFrame[], err?: BusinessError | string) => {
          if (err) {
            onError(err)
          }
          LogUtil.log("gifProcess data is null:" + (data == null));
          if (!!data) {
            let imageKnifeData = ImageKnifeData.createImageGIFFrame(ImageKnifeType.GIFFRAME, data);
            LogUtil.log('gifProcess 生成gif 返回数据类型')
            onComplete(imageKnifeData)
          } else {
            onError('Parse GIF callback data is null, you need check callback data!')
          }
        })

      } else if (ImageKnifeData.SVG == filetype) {
        let svgParseImpl = new SVGParseImpl()
        let success = (value: PixelMap) => {
          let imageKnifeData = ImageKnifeData.createImagePixelMap(ImageKnifeType.PIXELMAP, value);
          onComplete(imageKnifeData);
        }
        svgParseImpl.parseSvg(request, cached, success, onError)
      } else {
        //5.磁盘有数据，解析错误返回onError
        let success = (value: PixelMap) => {
          let imageKnifeData = ImageKnifeData.createImagePixelMap(ImageKnifeType.PIXELMAP, value);
          onComplete(imageKnifeData);
        }
        this.mParseImageUtil.parseImage(cached, success, onError)
      }

    } else {
      //6.磁盘无数据，返回onError
      onError("No data in disk cache!")
    }

  }


  generateDataCacheKey(request: RequestOption) {
    let factories: EngineKeyInterface;
    let cacheKey: string;
    let transferKey: string;
    let dataKey: string;
    //设置全局缓存key
    if (this.engineKeyImpl) {
      factories = this.engineKeyImpl;
    } else {
      factories = new EngineKeyFactories();
    }
    // 生成内存缓存key 内存 变换后磁盘

    let loadKey = '';
    if (typeof request.loadSrc == 'string') {
      loadKey = request.loadSrc;
    } else {
      loadKey = JSON.stringify(request.loadSrc);
    }

    let size = JSON.stringify(request.size);

    let transformed = '';
    if (request && request.transformations) {
      for (let i = 0; i < request.transformations.length; i++) {
        if (i == request.transformations.length - 1) {
          transformed += request.transformations[i].getName() + "";
        } else {
          transformed += request.transformations[i].getName() + ",";
        }
      }
    }

    let dontAnimateFlag = request.dontAnimateFlag;

    let signature = request.signature;

    cacheKey = factories.generateMemoryCacheKey(loadKey, size, transformed, dontAnimateFlag, signature);

    // 生成磁盘缓存变换后数据key 变换后数据保存在磁盘
    transferKey = factories.generateTransformedDiskCacheKey(loadKey, size, transformed, dontAnimateFlag, signature);

    // 生成磁盘缓存源数据key 原始数据保存在磁盘
    dataKey = factories.generateOriginalDiskCacheKey(loadKey, signature);
    if (request.placeholderSrc) {
      let placeholderLoadKey = '';
      if (typeof request.placeholderSrc == 'string') {
        placeholderLoadKey = request.placeholderSrc;
        // string类型占位图生成内存缓存源数据key
        request.placeholderRegisterMemoryCacheKey = factories.generateMemoryCacheKey(placeholderLoadKey, size, transformed, dontAnimateFlag, signature);
        // string类型占位图生成磁盘缓存源数据key 原始数据保存在磁盘
        request.placeholderRegisterCacheKey = factories.generateOriginalDiskCacheKey(placeholderLoadKey, signature);
      } else {
        placeholderLoadKey = JSON.stringify(request.placeholderSrc);
        request.placeholderCacheKey = this.generateCacheKey(placeholderLoadKey, size, dontAnimateFlag, signature);
      }
    }
    if (request.retryholderSrc) {
      let retryholderLoadKey = '';
      if (typeof request.retryholderSrc == 'string') {
        retryholderLoadKey = request.retryholderSrc;
      } else {
        retryholderLoadKey = JSON.stringify(request.retryholderSrc);
      }
      request.retryholderCacheKey = this.generateCacheKey(retryholderLoadKey, size, dontAnimateFlag, signature)
    }
    if (request.errorholderSrc) {
      let errorholderLoadKey = '';
      if (typeof request.errorholderSrc == 'string') {
        errorholderLoadKey = request.errorholderSrc;
      } else {
        errorholderLoadKey = JSON.stringify(request.errorholderSrc);
      }
      request.errorholderCacheKey = this.generateCacheKey(errorholderLoadKey, size, dontAnimateFlag, signature)
    }
    request.generateCacheKey = cacheKey;
    request.generateResourceKey = transferKey;
    request.generateDataKey = dataKey;
  }

  private generateCacheKey(loadkey: string, size: string, dontAnimateFlag: boolean, signature?: ObjectKey) {
    let factories: EngineKeyInterface;

    //设置全局缓存key
    if (this.engineKeyImpl) {
      factories = this.engineKeyImpl;
    } else {
      factories = new EngineKeyFactories();
    }
    return factories.generateMemoryCacheKey(loadkey, size, '', dontAnimateFlag, signature);
  }

  // 删除执行结束的running
  removeRunning(request: RequestOption) {
    LogUtil.log('VISIBLE: removeRunning ' + request.uuid + '|' + request.loadSrc);
    if (!this.isPaused) {
      //不暂停则继续加载
      this.executingJobMap.remove(request.uuid);
      this.dispatchNextJob();
    }
  }

  // 启动新线程 去磁盘取 去网络取
  private loadCacheManager(request: RequestOption) {
    LogUtil.log("VISIBLE: loadCacheManager start uuid : " + request.uuid + '|' + request.requestState + " url : " + request.loadSrc);
    if (request.requestState === ImageKnifeRequestState.DESTROY) return;
    if (this.keyNotEmpty(request)) {
      if (this.executingJobMap.length > this.maxRequests) {
        this.jobQueue.add(request);
        return
      }
      let requestList: List<RequestOption> | undefined = this.executingJobMap.get(request.uuid);
      if (requestList == undefined) {
        requestList = new List();
        requestList.add(request);
        this.executingJobMap.set(request.uuid, requestList);
        if (!this.isPaused) {
          LogUtil.log("loadCacheManager start uuid : " + request.uuid + " url : " + request.loadSrc);
          //暂停则不开启加载
          this.taskpoolLoadResource(request, Constants.MAIN_HOLDER);
        }
      } else {
        requestList.add(request);
        this.executingJobMap.set(request.uuid, requestList);
        LogUtil.log("loadCacheManager reuse uuid : " + request.uuid + " url : " + request.loadSrc);
        return;
      }
    } else {
      LogUtil.log("key没有生成无法进入存取！");
    }
  }

  private assembleSendableData(request: RequestOption, usageType: string){
    //图片变换方法无法直接传递到子线程，这里先把对象名和构造参数传递到子线程，然后在子线程中实例化变换方法

    let transformations: collections.Array<collections.Array<string>> = new collections.Array<collections.Array<string>>();

    if (usageType == Constants.MAIN_HOLDER) {
      for (let i = 0; i < request.transformations.length; i++) {
       let  item = collections.Array.from([request.transformations[i].getClassName(), request.transformations[i].getConstructorParams()]) as collections.Array<string>;
        transformations.push(item)
      }
    }
    let displayProgress = request.progressFunc ? true : false;

    let data: SendableData = new SendableData();
    data.setUsageType(usageType)
    data.setDisplayProgress(displayProgress)
    data.setUuid(request.uuid)
    data.setDontAnimateFlag(request.dontAnimateFlag)
    data.setThumbSizeMultiplier(request.thumbSizeMultiplier)
    data.setThumbDelayTime(request.thumbDelayTime)
    data.setOnlyRetrieveFromCache(request.onlyRetrieveFromCache)
    data.setIsCacheable(request.isCacheable)
    data.setGpuEnabled(request.gpuEnabled)
    data.setGenerateCacheKey(request.generateCacheKey)
    data.setGenerateResourceKey(request.generateResourceKey)
    data.setGenerateDataKey(request.generateDataKey)
    data.setSignature(request.signature)
    data.setTransformations(transformations)
    data.setDiskMemoryCache(this.diskMemoryCache)
    data.setDataFetch(this.dataFetch)
    data.setDiskMemoryCachePath(this.diskMemoryCache.getPath())
    data.setPlaceHolderRegisterCacheKey(request.placeholderRegisterCacheKey);
    data.setPlaceHolderRegisterMemoryCacheKey(request.placeholderRegisterMemoryCacheKey);
    data.setDownsampType(request.downsampType)
    return data;
  }

  private assembleSTaskData(request: RequestOption){
    let data: TaskParams = {
      headers: request.headers,
      moduleContext: request.moduleContext,
      priority: request.priority,
      size: request.size,
      loadSrc: this.transformResource(request.loadSrc) as string | PixelMap | MResource,
      placeholderSrc: this.transformResource(request.placeholderSrc) as string | PixelMap | MResource | undefined,
      errorholderSrc: this.transformResource(request.errorholderSrc) as PixelMap | MResource | undefined,
      retryholderSrc:this.transformResource(request.retryholderSrc) as PixelMap | MResource | undefined,
      fallbackSrc: this.transformResource(request.fallbackSrc) as PixelMap | MResource | undefined,
      customGetImage: request.customGetImage
    }
    return data;
  }

  private transformResource(loadSrc:string | PixelMap | Resource | undefined):string | PixelMap | MResource | undefined{
    let res = loadSrc as Resource
    if (res && res.id && res.type) {
      return {
        bundleName: res.bundleName,
        moduleName: res.moduleName,
        id: res.id,
        params: res.params,
        type: res.type
      } as MResource;
    }
    return loadSrc as string | PixelMap | undefined;

  }

  //多线程请求加载资源
  private taskpoolLoadResource(request: RequestOption, usageType: string) {
    // string类型占位图实现从缓存中获取图片
    if (request.placeholderSrc == 'string') {
      request.placeholderCacheKey = request.placeholderRegisterMemoryCacheKey;
    }
    let mainCache = this.memoryCacheProxy.loadMemoryCache(request.generateCacheKey, request.isCacheable);
    let placeholderCache = this.memoryCacheProxy.loadMemoryCache(request.placeholderCacheKey, request.isCacheable);
    let retryholderCache = this.memoryCacheProxy.loadMemoryCache(request.retryholderCacheKey, request.isCacheable);
    let errorholderCacheKey = this.memoryCacheProxy.loadMemoryCache(request.errorholderCacheKey, request.isCacheable);

    if (usageType == Constants.PLACE_HOLDER && placeholderCache) {
      LogUtil.info("imageknife load placeholder from MemoryCache")
      request.placeholderOnComplete(placeholderCache);
      return;
    } else if (usageType == Constants.RETRY_HOLDER && retryholderCache) {
      LogUtil.info("imageknife load retryholder from MemoryCache")
      request.retryholderOnComplete(retryholderCache);
      return;
    } else if (usageType == Constants.ERROR_HOLDER && errorholderCacheKey) {
      LogUtil.info("imageknife load errorholder from MemoryCache")
      request.errorholderOnComplete(errorholderCacheKey);
      return;
    } else if (usageType == Constants.MAIN_HOLDER && mainCache) {
      mainCache.waitSaveDisk = false;
      let requestList: List<RequestOption> | undefined = this.executingJobMap.get(request.uuid);
      LogUtil.info("VISIBLE: imageknife load mainsource from MemoryCache. requestList?.length: " + requestList?.length);
      // 组件被销毁会删除请求，因此requestList可能是undefined
      if(requestList != undefined) {
        requestList.forEach((requestOption: RequestOption)=>{
          if (requestOption.requestState === ImageKnifeRequestState.PROGRESS) {
            requestOption.requestState = ImageKnifeRequestState.COMPLETE;
          }
          requestOption.loadComplete(mainCache as ImageKnifeData,true);
        })
      }
      return;
    }
    //组装可以通过sendable传递的数据
    let sendData:SendableData = this.assembleSendableData(request, usageType);
    //其他不能sendable发送的数据
    let taskData:TaskParams = this.assembleSTaskData(request);

    //使用taskpool多线程执行资源下载
    let task: ESObject = new taskpool.Task(taskExecute,sendData,taskData)
    if (request.progressFunc){
      emitter.on(Constants.PROGRESS_EMITTER as ESObject, (data: ESObject) => {
        if (request.progressFunc && data?.data?.value) {
          let percent = data.data.value as number;
          request.progressFunc.asyncSuccess(percent);
        }
      });
    }
    taskpool.execute(task,request.priority).then((data: ESObject) => {
      if (usageType == Constants.PLACE_HOLDER) {
        if ((typeof (data as PixelMap).isEditable) == 'boolean') {
          let imageKnifeData = ImageKnifeData.createImagePixelMap(ImageKnifeType.PIXELMAP, data as PixelMap);
          request.placeholderOnComplete(imageKnifeData)
          this.memoryCacheProxy.putValue(request.placeholderCacheKey,imageKnifeData)
        } else {
          request.placeholderOnError("request placeholder error")
        }
      } else if (usageType == Constants.RETRY_HOLDER) {
        if ((typeof (data as PixelMap).isEditable) == 'boolean') {
          let imageKnifeData = ImageKnifeData.createImagePixelMap(ImageKnifeType.PIXELMAP, data as PixelMap);
          request.retryholderOnComplete(imageKnifeData)
          this.memoryCacheProxy.putValue(request.retryholderCacheKey,imageKnifeData)
        } else {
          request.retryholderOnError("request retryholder error")
        }
      } else if (usageType == Constants.ERROR_HOLDER) {
        if ((typeof (data as PixelMap).isEditable) == 'boolean') {
          let imageKnifeData = ImageKnifeData.createImagePixelMap(ImageKnifeType.PIXELMAP, data as PixelMap);
          request.errorholderOnComplete(imageKnifeData)
          this.memoryCacheProxy.putValue(request.errorholderCacheKey,imageKnifeData)
        } else {
          request.errorholderOnError("request errorholder error")
        }
      } else {
        if ((typeof (data as PixelMap).isEditable) == 'boolean') {
          let imageKnifeData = ImageKnifeData.createImagePixelMap(ImageKnifeType.PIXELMAP, data as PixelMap);
          let requestList: List<RequestOption> | undefined = this.executingJobMap.get(request.uuid)
          LogUtil.info("VISIBLE: taskpool execute done. data as PixelMap: " + requestList?.length);
          // 组件被销毁会删除请求，因此requestList可能是undefined
          if(requestList != undefined) {
            requestList.forEach((requestOption: RequestOption)=>{
              if (requestOption.requestState === ImageKnifeRequestState.PROGRESS) {
                requestOption.requestState = ImageKnifeRequestState.COMPLETE;
              }
              requestOption.loadComplete(imageKnifeData);
            })
          }
          this.memoryCacheProxy.putValue(request.generateCacheKey, imageKnifeData);
        } else if ((data as GIFFrame[]).length > 0) {
          let imageKnifeData = ImageKnifeData.createImageGIFFrame(ImageKnifeType.GIFFRAME, data as GIFFrame[]);
          let requestList: List<RequestOption> | undefined = this.executingJobMap.get(request.uuid);
          LogUtil.info("VISIBLE: taskpool execute done. data as GIFFrame: " + requestList?.length);
          // 组件被销毁会删除请求，因此requestList可能是undefined
          if(requestList != undefined) {
            requestList.forEach((requestOption: RequestOption)=>{
              if (requestOption.requestState === ImageKnifeRequestState.PROGRESS) {
                requestOption.requestState = ImageKnifeRequestState.COMPLETE;
              }
              requestOption.loadComplete(imageKnifeData);
            })
          }
          this.memoryCacheProxy.putValue(request.generateCacheKey, imageKnifeData);
        } else {
          if (request.requestState === ImageKnifeRequestState.PROGRESS) {
            request.requestState = ImageKnifeRequestState.ERROR;
          }
          LogUtil.info("VISIBLE: MAIN_HOLDER loadError. request: " + request.uuid + '|' + request.requestState + '|' + request.loadSrc);
          request.loadError("request resources error")
        }
      }
    }).catch((err: BusinessError | string) => {
      if (request.requestState === ImageKnifeRequestState.PROGRESS) {
        request.requestState = ImageKnifeRequestState.ERROR;
      }
      LogUtil.info("VISIBLE: taskpool response Error. request: " + request.uuid + '|' + request.requestState + '|' + request.loadSrc);
      request.loadError(err)
    })
  }

  private keyNotEmpty(request: RequestOption): boolean {
    if (
      request.generateCacheKey != null && request.generateCacheKey.length > 0 &&
        request.generateDataKey != null && request.generateDataKey.length > 0 &&
        request.generateResourceKey != null && request.generateResourceKey.length > 0
    ) {
      return true;
    }
    return false;
  }

  private parseSource(request: RequestOption): void {
    if ((typeof (request.loadSrc as image.PixelMap).isEditable) == 'boolean') {
      let imageKnifeData = ImageKnifeData.createImagePixelMap(ImageKnifeType.PIXELMAP, request.loadSrc as PixelMap)
      request.loadComplete(imageKnifeData);
    } else if (typeof request.loadSrc == 'string') {
      // 进入三级缓存模型
      return this.loadCacheManager(request);
    } else {
      let res = request.loadSrc as Resource;
      if (typeof res.id != 'undefined' && typeof res.type != 'undefined') {
        // 进入三级缓存模型  本地资源不参与磁盘缓存
        let none = new NONE();
        request.diskCacheStrategy(none);
        this.loadCacheManager(request);
      } else {
        LogUtil.error("输入参数有问题！")
      }
    }
  }

  prefetchToDiskCache(url: string): Promise<string> {
    return new Promise((resolve, reject) => {
      let key = this.engineKeyImpl.generateOriginalDiskCacheKey(url, undefined);
      let cachedPath = this.getDiskMemoryCache().getFileToPath(key);
      if (cachedPath == null || cachedPath == "" || cachedPath == undefined) {
        let request = new RequestOption();
        request.load(url)
          .addListener({ callback: (err: BusinessError | string, data: ImageKnifeData) => {
            if (err) {
              reject(err)
            } else {
              let cachedPath = this.getDiskMemoryCache().getFileToPath(key);
              resolve(cachedPath);
            }
            return false;
          }
          })
        this.call(request);
      } else {
        resolve(cachedPath);
      }

    })
  }

  // 分发下一个任务
  dispatchNextJob() {
    let request: RequestOption | undefined = this.jobQueue.pop();
    LogUtil.log('VISIBLE: 出队列 . ' + request?.uuid + '|' + request?.requestState + '|' + request?.loadSrc);
    if (request != undefined) {
      // 出队列的时候，如果已经销毁就不执行loadCacheManager
      if(request.requestState !== ImageKnifeRequestState.DESTROY) {
        this.loadCacheManager(request);
      } else {
        this.dispatchNextJob();
      }
    }
  }

  // 设置请求的最大并发数量
  setMaxRequests(count: number) {
    if (count > 0) {
      this.maxRequests = count;
    }
  }
}


/**
 * 加载资源子线程包含流程：网络请求资源->下载资源到本地->解码成ixelMap | GIFFrame[]->缓存到内存和磁盘
 * @param taskParams:任务参数，JSON字符串类型
 * @param headers：请求头
 * @param moduleContext：模块上下文
 * @returns
 */
@Concurrent
async function taskExecute(sendData:SendableData,taskData:TaskParams): Promise<PixelMap | GIFFrame[]> {

  //sendable里面加载http模块有问题，需要在@Concurrent先使用下，临时规避方法，待Sendable解决后删除
  let unused_arg0 = http.CertType;

  let emitProgressPercent = (percentValue: number) => {
    let eventData: emitter.EventData = {
      data: {
        "value": percentValue,
      }
    };
    emitter.emit(Constants.PROGRESS_EMITTER as ESObject, eventData)
  }

  let transformations = sendData.getTransformations();
  let usageType = sendData.getUsageType();
  let displayProgress = sendData.getDisplayProgress();
  //子线程构造RequestOption对象
  let newRequestOption = new RequestOption();
  newRequestOption.priority = taskData.priority;
  newRequestOption.uuid = sendData.getUuid();
  newRequestOption.loadSrc = taskData.loadSrc as string | PixelMap | Resource;
  newRequestOption.dontAnimateFlag = sendData.getDontAnimateFlag();
  newRequestOption.generateCacheKey = sendData.getGenerateCacheKey();
  newRequestOption.generateResourceKey = sendData.getGenerateResourceKey();
  newRequestOption.generateDataKey = sendData.getGenerateDataKey();
  newRequestOption.thumbSizeMultiplier = sendData.getThumbSizeMultiplier();
  newRequestOption.thumbDelayTime = sendData.getThumbDelayTime();
  newRequestOption.size = taskData.size;
  newRequestOption.placeholderRegisterCacheKey = sendData.getPlaceHolderRegisterCacheKey();
  newRequestOption.placeholderRegisterMemoryCacheKey = sendData.getPlaceHolderRegisterMemoryCacheKey();
  newRequestOption.downsampType = sendData.getDownsampType();
  if(taskData.placeholderSrc){
    newRequestOption.placeholderSrc = taskData.placeholderSrc as string | PixelMap | Resource | undefined;
  }
  if(taskData.fallbackSrc){
    newRequestOption.fallbackSrc = taskData.fallbackSrc as PixelMap | Resource | undefined;
  }
  if(taskData.errorholderSrc){
    newRequestOption.errorholderSrc = taskData.errorholderSrc as PixelMap | Resource | undefined;
  }
  if(taskData.retryholderSrc){
    newRequestOption.retryholderSrc = taskData.retryholderSrc as PixelMap | Resource | undefined;
  }
  newRequestOption.onlyRetrieveFromCache = sendData.getOnlyRetrieveFromCache();
  newRequestOption.gpuEnabled = sendData.getGpuEnabled();
  newRequestOption.headers = taskData.headers;
  newRequestOption.signature = sendData.getSignature();
  ImageKnifeGlobal.getInstance().setHapContext(taskData.moduleContext as common.UIAbilityContext);
  newRequestOption.moduleContext = taskData.moduleContext as common.UIAbilityContext;
  newRequestOption.isCacheable = sendData.getIsCacheable();
  //设置磁盘缓存路径
  newRequestOption.diskMemoryCachePath = sendData.getDiskMemoryCachePath();
  newRequestOption.customGetImage = taskData.customGetImage;
  if (displayProgress) {
    newRequestOption.addProgressListener({
      asyncSuccess: (percentValue: number) => {
        // 如果进度条百分比 未展示大小,展示其动画
        emitProgressPercent(percentValue)
      }
    })
  }
  //如果是本地图片不作磁盘缓存
  if (typeof newRequestOption.loadSrc !== 'string') {
    let none = new NONE();
    newRequestOption.diskCacheStrategy(none);
  }

  if (usageType == Constants.PLACE_HOLDER) {
    let manager = new PlaceHolderManager<PixelMap>(newRequestOption);
    return await new Promise<PixelMap>(manager.process);
  } else if (usageType == Constants.RETRY_HOLDER) {
    let manager = new RetryHolderManager<PixelMap>(newRequestOption);
    return await new Promise<PixelMap>(manager.process);
  } else if (usageType == Constants.ERROR_HOLDER) {
    let manager = new ErrorHolderManager<PixelMap>(newRequestOption);
    return await new Promise<PixelMap>(manager.process);
  } else {
    if (transformations) {
      newRequestOption.setTransformations(TransformUtils.addTransformations(transformations))
    }
    let diskMemoryCache = sendData.getDiskMemoryCache();
    let newDataFetch = sendData.getDataFetch();
    let newResourceFetch = new ParseResClient();
    let manager = new RequestManager(newRequestOption, diskMemoryCache as DiskLruCache, newDataFetch, newResourceFetch);
    return await new Promise<PixelMap | GIFFrame[]>(manager.process);
  }
}

