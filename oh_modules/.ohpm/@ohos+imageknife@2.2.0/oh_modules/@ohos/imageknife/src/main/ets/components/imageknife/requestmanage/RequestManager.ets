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

import { RequestOption, Size } from '../../imageknife/RequestOption'
import { DiskLruCache } from "../../cache/DiskLruCache"
import { LruCache } from '../../cache/LruCache'
import { SparkMD5 } from '../../3rd_party/sparkmd5/spark-md5'
import { MemoryCacheProxy } from '../requestmanage/MemoryCacheProxy'
import { DiskCacheProxy } from '../requestmanage/DiskCacheProxy'
import { FileTypeUtil } from '../utils/FileTypeUtil'
import { IDataFetch } from '../../imageknife/networkmanage/IDataFetch'
import { IResourceFetch } from '../../imageknife/resourcemanage/IResourceFetch'
import { ImageKnifeData, ImageKnifeType } from '../ImageKnifeData'
import { AllCacheInfo } from '../../imageknife/interface/IAllCacheInfoCallback'
import { ParseImageUtil } from '../utils/ParseImageUtil'
import { IParseImage } from '../interface/IParseImage'
import image from '@ohos.multimedia.image'
import { SVGParseImpl } from '../utils/svg/SVGParseImpl'
import { GIFParseImpl } from '../utils/gif/GIFParseImpl'
import { GIFFrame } from '../utils/gif/GIFFrame'
import { LogUtil } from '../../imageknife/utils/LogUtil'
import { BusinessError } from '@ohos.base'
import { DataFetchResult } from '../networkmanage/DataFetchResult'
import { BaseTransform } from '../transform/BaseTransform'

const imagePackerApi = image.createImagePacker();

export enum Stage {

  INITIALIZE,

  RESOURCE_CACHE,

  DATA_CACHE,

  SOURCE,

  ENCODE,

  FINISHED,
}


export enum RunReason {

  INITIALIZE,

  SWITCH_TO_SOURCE_SERVICE,

  DECODE_DATA,
}

export class RequestManager {
  private TAG: string = "RequestManager";
  private options: RequestOption;
  private mIDataFetch: IDataFetch;
  private mIResourceFetch: IResourceFetch<ArrayBuffer>;
  private mParseImageUtil: IParseImage<PixelMap>;
  private diskMemoryCache: DiskLruCache;

  constructor(option: RequestOption,diskMemoryCache: DiskLruCache, dataFetch: IDataFetch, resourceFetch: IResourceFetch<ArrayBuffer>) {
    this.options = option;

    this.diskMemoryCache = diskMemoryCache;
    // 网络下载能力
    this.mIDataFetch = dataFetch;

    // 本地数据解析能力
    this.mIResourceFetch = resourceFetch;

    // 解析image能力
    this.mParseImageUtil = new ParseImageUtil();
  }

  // DecodeJob work
  private mStage: Stage = Stage.INITIALIZE;
  private mRunReason: RunReason = RunReason.INITIALIZE;
  process = (onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) => {
    LogUtil.log("ImageKnife RequestManager process !");
    this.loadLeve1MemoryCache(onComplete, onError)
  }

  private runWrapped(request: RequestOption, runReason: RunReason, onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    LogUtil.log("ImageKnife RequestManager runWrapped")
    if (runReason == RunReason.INITIALIZE) {
      this.mStage = this.getNextStage(request, this.mStage);
      this.searchLoadFrom(this.options, this.mStage, onComplete, onError);
    } else {
      throw new Error("Unrecognized run reason: " + runReason)
    }
  }

  private getNextStage(request: RequestOption, current: Stage): Stage {
    if (current == Stage.INITIALIZE) {
      return request.strategy.decodeCachedResource()
        ? Stage.RESOURCE_CACHE
        : this.getNextStage(request, Stage.RESOURCE_CACHE);
    } else if (current == Stage.RESOURCE_CACHE) {
      return request.strategy.decodeCachedData()
        ? Stage.DATA_CACHE
        : this.getNextStage(request, Stage.DATA_CACHE);
    } else if (current == Stage.DATA_CACHE) {
      return request.onlyRetrieveFromCache ? Stage.FINISHED : Stage.SOURCE;
    } else if (current == Stage.SOURCE) {
      return Stage.FINISHED;
    } else if (current == Stage.FINISHED) {
      return Stage.FINISHED;
    } else {
      throw new Error("ImageKnife Unrecognized stage: " + current);
    }
  }

  // 究竟从哪里加载数据
  private searchLoadFrom(request: RequestOption, current: Stage, onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    LogUtil.log("ImageKnife RequestManager searchLoadFrom")
    if (current == Stage.RESOURCE_CACHE) {
      this.loadDiskFromTransform(request, onComplete, onError);
    } else if (current == Stage.DATA_CACHE) {
      this.loadDiskFromSource(request, onComplete, onError);
    } else if (current == Stage.SOURCE) {
      this.parseSource(request, onComplete, onError)
    } else if (current == Stage.FINISHED) {
      onError("在仅从缓存获取数据中，未获取到数据！")
    } else {
      throw new Error("Unrecognized stage: " + current);
    }
  }

  // 加载网络资源
  private async loadSourceFromNetwork(request: RequestOption, onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    try {
      LogUtil.log("ImageKnife RequestManager loadSourceFromNetwork")
      let result: DataFetchResult = await this.mIDataFetch.loadData(request);
      if(result.error){
        onError(result.error)
      }else{
        if(result.data){
          this.downloadSuccess(request, result.data, onComplete, onError)
        }else{
          onError("datafetch data is null")
        }
      }
    } catch (e) {
      LogUtil.error("ImageKnife RequestManager loadSourceFromNetwork error")
    }
  }

  // 加载本地资源
  private loadSourceFormNative(request: RequestOption, onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    LogUtil.log("ImageKnife RequestManager loadSourceFormNative")
    // 本地解析后进行一级缓存
    let success = (arrayBuffer: ArrayBuffer) => {
      // 使用媒体子系统 ImageSource解析文件 获取PixelMap
      let fileTypeUtil = new FileTypeUtil();
      let typeValue = fileTypeUtil.getFileType(arrayBuffer)
      LogUtil.log("ImageKnife RequestManager  - 文件类型为= " + typeValue)
      // gif、webp处理
      if ((ImageKnifeData.GIF == typeValue || ImageKnifeData.WEBP == typeValue) && !request.dontAnimateFlag) {
        // 处理gif、webp
        this.gifProcess(onComplete, onError, arrayBuffer, typeValue, request)
      } else if (ImageKnifeData.SVG == typeValue) {
        // 处理svg
        this.svgProcess(request, onComplete, onError, arrayBuffer, typeValue)
      } else {
        if (request.transformations[0]) {
          this.getTransformImage(request, arrayBuffer, request.transformations, 0, onComplete, onError);
        }
        else {
          let success = (value: PixelMap) => {
            onComplete(value);
          }
          this.mParseImageUtil.parseImage(arrayBuffer, success, onError,request)
        }
      }
    }
    let ctx = request.getModuleContext();
    if (ctx != undefined) {
      this.mIResourceFetch.loadResource(ctx, request.loadSrc as Resource, success, onError);
    } else {
      onError('ImageKnife RequestManager loadSourceFormNative moduleContext is undefined! please check it')
    }

  }

  private getTransformImage(request: RequestOption, source: ArrayBuffer, transformations: Array<BaseTransform<PixelMap>>, index: number,
                            onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    transformations[index].transform(source, request, {
      asyncTransform: (error: BusinessError | string, pixelMap: PixelMap | null) => {
        // 输出给Image
        if (pixelMap) {
          if (index == request.transformations.length - 1) {
            onComplete(pixelMap)
          } else {
            let packOpts: image.PackingOption = { format: "image/png", quality: 98 };
            imagePackerApi.packing(pixelMap, packOpts).then((data: ArrayBuffer) => {
              // data 为打包获取到的文件流，写入文件保存即可得到一张图片
              index++;
              this.getTransformImage(request, data, transformations, index, onComplete, onError);
            }).catch((error: BusinessError) => {
              onError(error);
              console.error('requestManager Failed to pack the image. And the error is: ' + JSON.stringify(error));
            })
          }
        } else {
          onError(error);
          console.error('requestManager getTransformImage error! ' + JSON.stringify(error));
        }
      }
    })
  }

  private saveTransformImage(request: RequestOption, source: ArrayBuffer, transformations: Array<BaseTransform<PixelMap>>, index: number, filetype: string,
                             onComplete: (value: PixelMap) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    transformations[index].transform(source, request, {
      asyncTransform: (error: BusinessError | string, pixelMap: PixelMap | null) => {
        // 输出给Image
        if (pixelMap) {
          if (index == request.transformations.length - 1) {
            this.saveCacheAndDisk(pixelMap, filetype, onComplete, source);
          } else {
            let packOpts: image.PackingOption = { format: "image/png", quality: 98 };
            imagePackerApi.packing(pixelMap, packOpts).then((data: ArrayBuffer) => {
              // data 为打包获取到的文件流，写入文件保存即可得到一张图片
              index++;
              this.saveTransformImage(request, data, transformations, index, filetype, onComplete, onError);
            }).catch((error: BusinessError) => {
              onError(error);
              console.error('requestManager Failed to pack the image. And the error is: ' + JSON.stringify(error));
            })
          }
        } else {
          onError(error);
          console.error('requestManager saveTransformImage error! ' + JSON.stringify(error));
        }
      }
    })
  }

  // 加载磁盘缓存 原图
  private loadDiskFromSource(request: RequestOption, onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    LogUtil.log("ImageKnife RequestManager loadDiskFromSource")
    let cached =  this.diskMemoryCache.get(request.generateDataKey);
    if (cached != null && cached.byteLength > 0) {
      LogUtil.log("ImageKnife loadDiskFromSource load resource from DiskLruCache")
      this.parseDiskFile2PixelMap(request, cached, onComplete, onError)
    } else {
      this.mStage = Stage.SOURCE;
      this.mStage = request.onlyRetrieveFromCache? Stage.FINISHED : Stage.SOURCE
      this.searchLoadFrom(this.options, this.mStage, onComplete, onError);
    }
  }

  // 加载磁盘缓存 变换后图片
  private loadDiskFromTransform(request: RequestOption, onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    LogUtil.log("ImageKnife RequestManager loadDiskFromTransform")
    let cached =  this.diskMemoryCache.get(request.generateResourceKey);
    if (cached != null) {
      LogUtil.log("ImageKnife loadDiskFromTransform load resource from DiskLruCache")
      this.parseDiskTransformFile2PixelMap(request, cached, onComplete, onError)
    } else {
      this.mStage = Stage.DATA_CACHE;
      this.searchLoadFrom(this.options, this.mStage, onComplete, onError);
    }
  }

  parseSource(request: RequestOption, onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    LogUtil.log("ImageKnife RequestManager parseSource")
    try {
      if ((typeof (request.loadSrc as image.PixelMap).isEditable) == 'boolean') {
        // PixelMap 外层捕获效率更高，不会进入这里
      } else if (typeof request.loadSrc == 'string') {
        this.loadSourceFromNetwork(request, onComplete, onError);
      } else {
        let res = request.loadSrc as Resource;
        if (typeof res.id != 'undefined') {
          this.loadSourceFormNative(request, onComplete, onError)
        } else {
          LogUtil.log("输入参数有问题！")
        }
      }
    } catch (e) {
      LogUtil.error("ImageKnife RequestManager parseSource error")
    }

  }

  private loadLeve1MemoryCache(onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    try {
      this.runWrapped(this.options, this.mRunReason, onComplete, onError)
    } catch (e) {
      LogUtil.error("ImageKnife loadLeve1MemoryCache error")
    }
  }

  // 解析磁盘文件变成PixeMap
  private parseDiskFile2PixelMap(request: RequestOption, source: ArrayBuffer, onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    LogUtil.log("ImageKnife RequestManager parseDiskFile2PixelMap")
    // 步骤一：文件转为pixelMap 然后变换 给Image组件
    let fileTypeUtil = new FileTypeUtil();
    let typeValue = fileTypeUtil.getFileType(source);
    // 解析磁盘文件 gif、webp 和 svg
    if ((ImageKnifeData.GIF == typeValue || ImageKnifeData.WEBP == typeValue) && !request.dontAnimateFlag) {
      // 处理gif、webp
      this.gifProcess(onComplete, onError, source, typeValue,request)
    } else if (ImageKnifeData.SVG == typeValue) {
      this.svgProcess(request, onComplete, onError, source, typeValue)
    } else {
      if (this.options.transformations[0]) {
        if (this.options.thumbSizeMultiplier) {
          let thumbOption: RequestOption = new RequestOption();
          thumbOption.setImageViewSize({
            width: Math.round(this.options.thumbSizeMultiplier * this.options.size.width),
            height: Math.round(this.options.thumbSizeMultiplier * this.options.size.height)
          })
          let ctx = this.options.getModuleContext()
          if (ctx != undefined) {
            thumbOption.setModuleContext(ctx)
          } else {
            onError('RequestManager parseDiskFile2PixelMap moduleContext is undefined, please check it!')
            return
          }
          let thumbCallback = this.options.thumbholderOnComplete;
          let thumbError = this.options.thumbholderOnError;
          this.getTransformImage(thumbOption, source, this.options.transformations, 0, thumbCallback, thumbError);
          setTimeout(() => {
            this.getTransformImage(request, source, this.options.transformations, 0, onComplete, onError);
          }, this.options.thumbDelayTime);
        }
        else {
          this.getTransformImage(request, source, this.options.transformations, 0, onComplete, onError);
        }
      } else {
        // thumbnail 缩略图部分
        if (request.thumbSizeMultiplier) {
          let thumbCallback = this.options.thumbholderOnComplete
          let thumbError = this.options.thumbholderOnError
          let thumbSuccess = (value: PixelMap) => {
            thumbCallback(value);
          }
          this.mParseImageUtil.parseImageThumbnail(request.thumbSizeMultiplier, source, thumbSuccess, thumbError);
          setTimeout(() => {
            let success = (value: PixelMap) => {
              onComplete(value);
            }
            this.mParseImageUtil.parseImage(source, success, onError,request)
          }, this.options.thumbDelayTime)
        } else {
          let success = (value: PixelMap) => {
            onComplete(value);
          }
          this.mParseImageUtil.parseImage(source, success, onError,request)
        }
      }
    }
  }

  // 解析磁盘变换后文件变成PixeMap
  private parseDiskTransformFile2PixelMap(request: RequestOption, source: ArrayBuffer, onComplete: (value: PixelMap) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    LogUtil.log("ImageKnife RequestManager parseDiskTransformFile2PixelMap")
    let fileTypeUtil = new FileTypeUtil();
    let typeValue = fileTypeUtil.getFileType(source);
    // thumbnail 缩略图部分
    if (request.thumbSizeMultiplier) {
      let thumbCallback = this.options.thumbholderOnComplete
      let thumbError = this.options.thumbholderOnError
      let thumbSuccess = (value: PixelMap) => {
        thumbCallback(value);
      }
      this.mParseImageUtil.parseImageThumbnail(request.thumbSizeMultiplier, source, thumbSuccess, thumbError);
      setTimeout(() => {
        let success = (value: PixelMap) => {
          onComplete(value);
        }
        this.mParseImageUtil.parseImage(source, success, onError,request)
      }, this.options.thumbDelayTime)
    } else {
      let success = (value: PixelMap) => {
        onComplete(value);
      }
      this.mParseImageUtil.parseImage(source, success, onError,request)
    }
  }

  private downloadSuccess(request: RequestOption, source: ArrayBuffer, onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {

    if (source == null || source == undefined || source.byteLength <= 0) {
      onError('ImageKnife Download task completed. but download file is empty!')
      return
    }

    // 下载成功之后 去data/data/包名/唯一路径/文件名  读取数据
    // 步骤一：文件转为pixelMap 然后变换 给Image组件
    // 步骤二: 文件名保存一份全局
    // 步骤三:查看文件是否支持 非支持类型直接返回
    let fileTypeUtil = new FileTypeUtil();
    let filetype: string | null = fileTypeUtil.getFileType(source);
    if (filetype == null) {
      onError("下载文件解析后类型为null,请检查数据源！");
      return;
    }

    if (!fileTypeUtil.isImage(source)) {
      onError("暂不支持 下载文件类型！类型=" + filetype);
      return;
    }

    // 解析磁盘文件 gif、webp 和 svg
    if ((ImageKnifeData.GIF == filetype || ImageKnifeData.WEBP == filetype) && !this.options.dontAnimateFlag) {
      // 处理gif、webp
      this.gifProcess(onComplete, onError, source, filetype,request)

      // 保存二级磁盘缓存
      Promise.resolve(source)
        .then((arraybuffer: ArrayBuffer) => {
          this.diskMemoryCache.set(this.options.generateDataKey,arraybuffer);
        })
        .catch((err: BusinessError) => {
          LogUtil.log('download file is =' + ImageKnifeData.GIF + 'and save diskLruCache error =' + (err as BusinessError))
        })
    } else if (ImageKnifeData.SVG == filetype) {
      // 处理svg
      this.svgProcess(request, onComplete, onError, source, filetype)

      // 保存二级磁盘缓存
      Promise.resolve(source)
        .then((arraybuffer: ArrayBuffer) => {
          this.diskMemoryCache.set(this.options.generateDataKey,arraybuffer);
        })
        .catch((err: BusinessError) => {
          LogUtil.log('download file is =' + ImageKnifeData.SVG + 'and save diskLruCache error =' + (err as BusinessError))
        })
    } else {
      // 进行变换
      if (this.options.transformations[0]) {
        // thumbnail 缩略图部分
        if (this.options.thumbSizeMultiplier) {
          if (filetype != null) {
            this.thumbnailProcess(source, filetype, onComplete, onError);
          }
        } else {
          this.saveTransformImage(this.options, source, this.options.transformations, 0, filetype, onComplete, onError);
        }
      } else {
        // thumbnail 缩略图部分
        if (this.options.thumbSizeMultiplier) {
          let thumbCallback = this.options.thumbholderOnComplete
          let thumbError = this.options.thumbholderOnError
          let thumbSuccess = (value: PixelMap) => {
            thumbCallback(value);
          }
          this.mParseImageUtil.parseImageThumbnail(this.options.thumbSizeMultiplier, source, thumbSuccess, thumbError);
          setTimeout(() => {
            let success = (value: PixelMap) => {
              if (filetype != null) {
                this.saveCacheAndDisk(value, filetype, onComplete, source);
              }
            }
            this.mParseImageUtil.parseImage(source, success, onError,request)
          }, this.options.thumbDelayTime)
        } else {
          let success = (value: PixelMap) => {
            if (filetype != null) {
              this.saveCacheAndDisk(value, filetype, onComplete, source);
            }
          }
          this.mParseImageUtil.parseImage(source, success, onError,request)
        }
      }
    }
  }

  createImagePixelMap(imageKnifeType: ImageKnifeType, imageKnifeValue: PixelMap): ImageKnifeData {
    return ImageKnifeData.createImagePixelMap(imageKnifeType, imageKnifeValue);
  }

  createImageGIFFrame(imageKnifeType: ImageKnifeType, imageKnifeValue: GIFFrame[]): ImageKnifeData {
    return ImageKnifeData.createImageGIFFrame(imageKnifeType, imageKnifeValue);
  }


  private async saveCacheAndDisk(value: PixelMap, filetype: string, onComplete: (value: PixelMap) => void | PromiseLike<ImageKnifeData>, source: ArrayBuffer) {
    let save2DiskCache = (arraybuffer: ArrayBuffer) => {
      this.diskMemoryCache.set(this.options.generateDataKey,arraybuffer);
      // 落盘之后需要主动移除当前request并且调用下一个加载
      let removeCurrentAndSearchNextRun = this.options.removeCurrentAndSearchNext;
      removeCurrentAndSearchNextRun();
    }
    let runSave2Disk = (resolve: (value: ArrayBuffer) => void | PromiseLike<ArrayBuffer>, reject: (reason?: BusinessError | string) => void) => {
      resolve(source);
    }
    let promise = new Promise(runSave2Disk);
    await promise.then(save2DiskCache);
    onComplete(value);
  }

  thumbnailProcess(source: ArrayBuffer, filetype: string, onComplete: (value: PixelMap) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void) {
    let thumbOption = new RequestOption();
    let ctx = this.options.getModuleContext()
    if (ctx != undefined) {
      thumbOption.setModuleContext(ctx)
    } else {
      onError('RequestManager thumbnailProcess moduleContext is undefined, please check it!')
      return
    }
    thumbOption.setImageViewSize({
      width: Math.round(this.options.thumbSizeMultiplier * this.options.size.width),
      height: Math.round(this.options.thumbSizeMultiplier * this.options.size.height)
    })
    let thumbCallback = this.options.thumbholderOnComplete
    let thumbError = this.options.thumbholderOnError
    this.getTransformImage(thumbOption, source, this.options.transformations, 0, thumbCallback, thumbError);
    setTimeout(() => {
      this.saveTransformImage(this.options, source, this.options.transformations, 0, filetype, onComplete, onError);
    }, this.options.thumbDelayTime)
  }

  private svgProcess(option: RequestOption, onComplete: (value: PixelMap) => void | PromiseLike<ImageKnifeData>, onError: (reason?: BusinessError | string) => void, arraybuffer: ArrayBuffer, typeValue: string, cacheStrategy?: (cacheData: ImageKnifeData) => void) {
    let svgParseImpl = new SVGParseImpl()
    svgParseImpl.parseSvg(option, arraybuffer, onComplete, onError)
  }

  private gifProcess(
    onComplete: (value: PixelMap | GIFFrame[]) => void | PromiseLike<ImageKnifeData>,
    onError: (reason?: BusinessError | string) => void,
    arraybuffer: ArrayBuffer,
    typeValue: string,
    request?:RequestOption,
    cacheStrategy?: (cacheData: ImageKnifeData) => void) {
    let gifParseImpl = new GIFParseImpl()
    gifParseImpl.parseGifs(
      arraybuffer,
      (data?: GIFFrame[], err?: BusinessError | string) => {
      if (err) {
        onError(err)
      }
      LogUtil.log("gifProcess data is null:" + (data == null));
      if (!!data) {
        // let imageKnifeData = this.createImageGIFFrame(ImageKnifeType.GIFFRAME, data)
        // LogUtil.log('gifProcess 生成gif 返回数据类型')
        // if (cacheStrategy) {
        //   LogUtil.log('gifProcess 生成gif并且存入了缓存策略')
        //   cacheStrategy(imageKnifeData)
        // }
        onComplete(data)
      } else {
        onError('Parse GIF callback data is null, you need check callback data!')
      }
    },request)
  }
}
