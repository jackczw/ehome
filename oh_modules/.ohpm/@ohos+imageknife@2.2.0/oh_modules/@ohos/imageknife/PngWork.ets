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
import taskpool from '@ohos.taskpool';
import { UPNG } from './src/main/ets/components/3rd_party/upng/UPNG'
import { WorkerType } from "./src/main/ets/components/imageknife/pngj/PngCallback"

export function handler(e: WorkerType, source: ArrayBuffer, pngCallback: (value:ESObject) => void, info?: string) {
  let task: taskpool.Task | undefined = undefined
  if (info == undefined) {
    task = new taskpool.Task(printArgs, e)
  } else {
    task = new taskpool.Task(printArgs, e, source)
  }
  let val1: ESObject = taskpool.execute(task)
  pngCallback(val1)
  try {
    taskpool.cancel(task)
  } catch (e) {
    console.error("taskpool.cancel occur error:" + e)
  }
}

@Concurrent
function printArgs(e: WorkerType, pngSource: ArrayBuffer, info?: string): Object | ArrayBufferLike | void {
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


