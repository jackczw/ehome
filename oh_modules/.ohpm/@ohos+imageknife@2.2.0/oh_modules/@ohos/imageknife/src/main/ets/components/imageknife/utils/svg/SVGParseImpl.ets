/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
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
import { IParseSvg } from './IParseSvg'
import { RequestOption } from '../../RequestOption'
import { BusinessError } from '@ohos.base'
import { ImageKnifeData, ImageKnifeType } from '../../ImageKnifeData'
import image from '@ohos.multimedia.image'
import { Downsampler, calculateScaleType } from '../../downsampling/Downsampler'

export class SVGParseImpl implements IParseSvg {
  parseSvg(option: RequestOption, imageInfo: ArrayBuffer,
           onComplete: (value: PixelMap) => void | PromiseLike<ImageKnifeData>,
           onErrorFunction: (reason?: BusinessError | string) => void) {

    let imageSource: image.ImageSource = image.createImageSource(imageInfo); // 步骤一：文件转为pixelMap 然后变换 给Image组件
    imageSource.getImageInfo().then((value) => {
      let hValue = Math.round(value.size.height);
      let wValue = Math.round(value.size.width);
      let defaultSize: image.Size = {
        height: vp2px(hValue),
        width: vp2px(wValue)
      };
      let opts: image.DecodingOptions = {
        editable: true,
        desiredSize: defaultSize
      };
      if (option?.downsampType.getName()!==undefined && option?.downsampType.getName()!=='DownsampleNone') {
        const b: calculateScaleType = new Downsampler().calculateScaling(imageInfo, hValue, wValue, option)
        opts = {
          editable: true,
          desiredSize: {
            width: b.targetWidth,
            height: b.targetHeight
          }
        }
      }
      imageSource.createPixelMap(opts).then((pixelMap: image.PixelMap) => {
        let imageKnifeData = ImageKnifeData.createImagePixelMap(ImageKnifeType.PIXELMAP, pixelMap)
        onComplete(imageKnifeData?.drawPixelMap?.imagePixelMap as PixelMap);
        imageSource.release()
      }).catch((err: string) => {
        onErrorFunction(err);
        imageSource.release()
      })
    })
  }
}