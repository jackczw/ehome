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
import { IParseGif } from './IParseGif'
import { Dims, GIFFrame } from './GIFFrame'
import image from '@ohos.multimedia.image'
import { BusinessError } from '@ohos.base'
import worker, { ErrorEvent, MessageEvents } from '@ohos.worker';
import taskpool from '@ohos.taskpool'
import { LogUtil } from '../LogUtil'
import { RequestOption } from '../../RequestOption'
import { Downsampler,calculateScaleType } from '../../downsampling/Downsampler'

export interface senderData {
  type: string,
  data: ArrayBuffer;
}

export interface gifBackData {
  dims: Dims[],
  delay: number[],
  disposalType: number[],
  patch: Uint8ClampedArray[],
  transparentIndex: number[]
}

export class GIFParseImpl implements IParseGif {
  parseGifs(
    imageinfo: ArrayBuffer,
    callback: (data?: GIFFrame[], err?: BusinessError | string) => void,
    _request?: RequestOption
  ) {
    // 硬解码流程
    let imageSource = image.createImageSource(imageinfo);
    let decodeOpts: image.DecodingOptions = {
      sampleSize: 1,
      editable: true,
      rotate: 0
    }
    let hValue: number = 0
    let wValue: number = 0
    imageSource.getImageInfo().then((value) => {
      hValue = Math.round(value.size.height);
      wValue = Math.round(value.size.height);
      if ( _request?.downsampType.getName()!==undefined && _request?.downsampType.getName()!=='DownsampleNone') {
        const b: calculateScaleType = new Downsampler().calculateScaling(imageinfo, Math.round(value.size.height), Math.round(value.size.width), _request)
        decodeOpts = {
          sampleSize: 1,
          editable: true,
          rotate: 0,
          desiredSize: {
            width: b.targetWidth,
            height: b.targetHeight
          }
        }
      }
    })
    let data: GIFFrame[] = [];
    imageSource.createPixelMapList(decodeOpts).then((pixelList: Array<PixelMap>) => {
      //sdk的api接口发生变更：从.getDelayTime() 变为.getDelayTimeList()
      imageSource.getDelayTimeList().then(delayTimes => {
        if (pixelList.length > 0) {
          let pixelmap1 = pixelList[0];
          pixelmap1.getImageInfo().then(imageInfo => {
            for (let i = 0; i < pixelList.length; i++) {
              let frame = new GIFFrame();
              frame.drawPixelMap = pixelList[i];
              frame.dims = { width: imageInfo.size.width, height: imageInfo.size.height, top: 0, left: 0 }
              if (i < delayTimes.length) {
                frame.delay = delayTimes[i];
              } else {
                frame.delay = delayTimes[delayTimes.length - 1]
              }
              data.push(frame)
            }
            callback(data, undefined)
            imageSource.release();
          }).catch((err: string) => {
            imageSource.release();
            callback(undefined, err)
          })
        }
      }).catch((err: string) => {
        imageSource.release();
        callback(undefined, err)
      })
    }).catch((err: string) => {
      imageSource.release();
      callback(undefined, err)
    })
  }
}