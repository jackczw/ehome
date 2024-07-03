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
import {RequestOption,Size} from "../../imageknife/RequestOption"
import {ResourceTypeEts} from "../../imageknife/constants/ResourceTypeEts"
import {Base64} from "../../cache/Base64"
import {FileTypeUtil} from "../../imageknife/utils/FileTypeUtil"
import {ImageKnifeData,ImageKnifeType} from "../ImageKnifeData"
import {ParseImageUtil} from '../utils/ParseImageUtil'
import {ParseResClient} from '../resourcemanage/ParseResClient'
import { SupportFormat } from '../utils/FileTypeUtil'
import { SVGParseImpl } from '../utils/svg/SVGParseImpl'
import {LogUtil} from '../../imageknife/utils/LogUtil'
import resourceManager from '@ohos.resourceManager';
import image from "@ohos.multimedia.image"
import { BusinessError } from '@ohos.base'
export class RetryHolderManager<T> {
  private options: RequestOption;

  constructor(option: RequestOption) {
    this.options = option;
  }

  process = (onComplete:(value:PixelMap)=>void|PromiseLike<ImageKnifeData>, onError:(reason?:BusinessError|string)=>void)=>{
    this.displayRetryholder(onComplete, onError);
  }

  private displayRetryholder(onComplete:(value:PixelMap)=>void|PromiseLike<ImageKnifeData>, onError:(reason?:BusinessError|string)=>void){
    LogUtil.log("ImageKnife displayRetryholder")
    if ((typeof (this.options.retryholderSrc as image.PixelMap).isEditable) == 'boolean') {
      let imageKnifeData = ImageKnifeData.createImagePixelMap(ImageKnifeType.PIXELMAP, this.options.placeholderSrc as PixelMap)
      onComplete(imageKnifeData?.drawPixelMap?.imagePixelMap as PixelMap);
    } else if (typeof this.options.placeholderSrc == 'string') {

    } else {
      let res = this.options.retryholderSrc as Resource;
      if (typeof res.id != 'undefined' && typeof res.id != 'undefined') {
        let resourceFetch = new ParseResClient();
        let suc = (arraybuffer:ArrayBuffer) => {
          let fileTypeUtil = new FileTypeUtil();
          let typeValue = fileTypeUtil.getFileType(arraybuffer);
          switch (typeValue) {
            case SupportFormat.svg:
              this.svgProcess(onComplete, onError, arraybuffer, typeValue)
              break;
            case SupportFormat.jpg:
            case SupportFormat.png:
            case SupportFormat.bmp:
            case SupportFormat.gif:
            case SupportFormat.tiff:
            case SupportFormat.webp:
            case SupportFormat.heic:
              this.mediaImageProcess(onComplete, onError, arraybuffer, typeValue)
              break;
            default:
              onError("PlaceHolderManager 文件类型不支持")
              break;
          }
        }
        let ctx = this.options.getModuleContext();
        if(ctx != undefined){
          resourceFetch.loadResource(ctx,res, suc, onError)
        }else{
          onError("RetryHolderManager moduleContext is undefined,please check it!")
        }
      } else {
        onError("RetryHolderManager 输入参数有问题!")
      }
    }
  }



  private svgProcess(onComplete:(value:PixelMap)=>void|PromiseLike<ImageKnifeData>, onError:(reason?:BusinessError|string)=>void, arraybuffer:ArrayBuffer, typeValue:string) {
    let svgParseImpl = new SVGParseImpl()
    svgParseImpl.parseSvg(this.options,arraybuffer, onComplete,onError);
  }

  private mediaImageProcess(onComplete:(value:PixelMap)=>void|PromiseLike<ImageKnifeData>, onError:(reason?:BusinessError|string)=>void, arraybuffer:ArrayBuffer, typeValue:string) {
    let parseImageUtil = new ParseImageUtil()
    let success = (value: PixelMap) => {
      let imageKnifeData = ImageKnifeData.createImagePixelMap(ImageKnifeType.PIXELMAP, value)
      onComplete(imageKnifeData?.drawPixelMap?.imagePixelMap as PixelMap)
    }
    parseImageUtil.parseImage(arraybuffer, success, onError)
  }
}