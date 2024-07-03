/*
 * Copyright (C) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { IParseImage } from '../interface/IParseImage'
import image from '@ohos.multimedia.image';
import { BusinessError } from '@ohos.base'
import { RequestOption } from '../RequestOption';
import {Downsampler,calculateScaleType } from '../downsampling/Downsampler';

export class ParseImageUtil implements IParseImage<PixelMap> {
  parseImage(
    imageinfo: ArrayBuffer,
    onCompleteFunction: (value: PixelMap) => void | PromiseLike<PixelMap>,
    onErrorFunction: (reason?: BusinessError | string) => void,
    request?:RequestOption
  ) {
    this.parseImageThumbnail(1, imageinfo, onCompleteFunction, onErrorFunction,request)
  }

  parseImageThumbnail(scale: number, imageinfo: ArrayBuffer, onCompleteFunction: (value: PixelMap) => void | PromiseLike<PixelMap>, onErrorFunction: (reason?: BusinessError | string) => void,request?:RequestOption) {

    let imageSource: image.ImageSource = image.createImageSource(imageinfo); // 步骤一：文件转为pixelMap 然后变换 给Image组件
    imageSource.getImageInfo().then((value) => {
      let hValue = Math.round(value.size.height * scale);
      let wValue = Math.round(value.size.width * scale);
      let defaultSize: image.Size = {
        height: hValue,
        width: wValue
      };
      let opts: image.DecodingOptions = {
        editable: true,
        desiredSize: defaultSize
      };
      if(request?.downsampType.getName()!==undefined && request?.downsampType.getName()!=='DownsampleNone'){
        const b:calculateScaleType = new Downsampler().calculateScaling(imageinfo, hValue, wValue,request)
        opts= {
          editable: true,
          desiredSize: {
            height: b.targetHeight,
            width: b.targetWidth
          }
        };
      }
      imageSource.createPixelMap(opts).then((pixelMap: image.PixelMap) => {
        onCompleteFunction(pixelMap);
        imageSource.release()
      }).catch((err: string) => {
        onErrorFunction(err);
        imageSource.release()
      })

    }).catch((err: string) => {
      onErrorFunction(err);
      imageSource.release()
    })
  }
}