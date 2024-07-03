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
import { UPNG } from '../../3rd_party/upng/UPNG';
import { PngCallback, WorkerType } from './PngCallback';
import image from '@ohos.multimedia.image';
import taskpool from '@ohos.taskpool';
import { BusinessError } from '@ohos.base'

export class Pngj {
  readPngImageInfo(arraybuffer: ArrayBuffer, callback: PngCallback<ArrayBuffer, image.ImageInfo>) {
    let imageSource: image.ImageSource = image.createImageSource(arraybuffer);
    if (imageSource != undefined) {
      imageSource.getImageInfo((err: BusinessError, value: image.ImageInfo) => {
        if (err) {
          return;
        }
        callback.pngCallback(arraybuffer, value);
      });
    }

  }

  /**
   *
   * @param pngBuffer  ArrayBuffer containing the PNG file
   * @param callback
   * returns an image object with following properties:
   * width: the width of the image
   * height: the height of the image
   * depth: number of bits per channel
   * ctype: color type of the file (Truecolor, Grayscale, Palette ...)
   * frames: additional info about frames (frame delays etc.)
   * tabs: additional chunks of the PNG file
   * data: pixel data of the image
   */
  readPngImage(pngBuffer: ArrayBuffer, callback: PngCallback<ArrayBuffer, Object>) {
    let png = UPNG.decode(pngBuffer);
    callback.pngCallback(pngBuffer, png)
  }

  writePngWithString(addInfo: string, pngBuffer: ArrayBuffer, callback: PngCallback<ArrayBuffer, ArrayBufferLike>) {
    let pngDecode = UPNG.decode(pngBuffer);
    let newPng = UPNG.encodeWithString(addInfo, UPNG.toRGBA8(pngDecode), pngDecode.width, pngDecode.height, 0)
    callback.pngCallback(pngBuffer, newPng);
  }

  writePng(pngBuffer: ArrayBuffer, callback: PngCallback<ArrayBuffer, ArrayBufferLike>) {
    let pngDecode = UPNG.decode(pngBuffer);
    let newPng = UPNG.encode(UPNG.toRGBA8(pngDecode), pngDecode.width, pngDecode.height, 0)
    callback.pngCallback(pngBuffer, newPng);
  }

  async readPngImageAsync(e: WorkerType, source: ArrayBuffer, pngCallback: (value: ESObject) => void) {
    let task = new taskpool.Task(taskPngImage, e, source)
    let val1: ESObject = await taskpool.execute(task)
    pngCallback(val1)
    try {
      taskpool.cancel(task)
    } catch (e) {
      console.error("taskpool.cancel occur error:" + e)
    }
  }

  async writePngWithStringAsync(e: WorkerType, source: ArrayBuffer, pngCallback: (value: ESObject) => void, info: string) {
    let task = new taskpool.Task(taskPngImage, e, source, info)
    let val1: ESObject = await taskpool.execute(task)
    pngCallback(val1)
    try {
      taskpool.cancel(task)
    } catch (e) {
      console.error("taskpool.cancel occur error:" + e)
    }
  }

  async writePngAsync(e: WorkerType, source: ArrayBuffer, pngCallback: (value: ESObject) => void) {
    let task = new taskpool.Task(taskPngImage, e, source)
    let val1: ESObject = await taskpool.execute(task)
    pngCallback(val1)
    try {
      taskpool.cancel(task)
    } catch (e) {
      console.error("taskpool.cancel occur error:" + e)
    }
  }
}

@Concurrent
function taskPngImage(e: WorkerType, pngSource: ArrayBuffer, info?: string): Object | ArrayBufferLike | void {
  let a: Object | ArrayBufferLike | undefined = undefined
  let png = UPNG.decode(pngSource)
  switch (e.name) {
    case 'readPngImageAsync':
      let array: Uint8Array = png.data;
      let arrayData = array.buffer.slice(array.byteOffset, array.byteLength + array.byteOffset)
      png.data = arrayData;
      a = png
      break;
    case 'writePngWithStringAsync':
      let addInfo: string | undefined = info;
      let newPng = UPNG.encodeWithString(addInfo, UPNG.toRGBA8(png), png.width, png.height, 0)
      a = newPng
      break;
    case 'writePngAsync':
      let newPng3 = UPNG.encode(UPNG.toRGBA8(png), png.width, png.height, 0)
      a = newPng3
      break;
    default:
      break
  }
  if(a != undefined) {  return a }
}