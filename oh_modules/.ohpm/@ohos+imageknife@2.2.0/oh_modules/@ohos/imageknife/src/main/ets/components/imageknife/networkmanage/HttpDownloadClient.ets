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

import { IDataFetch } from '../networkmanage/IDataFetch'
import { RequestOption } from '../RequestOption'
import http from '@ohos.net.http'
import { RequestData } from './RequestData'
import { DataFetchResult } from './DataFetchResult'


@Sendable
export class HttpDownloadClient implements IDataFetch {
  async loadData(request: RequestOption) {
     let result:DataFetchResult = new DataFetchResult();
     try {
       let httpRequest = http.createHttp()
       let arrayBuffers = new Array<ArrayBuffer>();
       httpRequest.on('headersReceive', (header: Object) => {
         // 跟服务器连接成功准备下载
         if (request.progressFunc) {
           // 进度条为0
           request.progressFunc.asyncSuccess(0)
         }
       })
       httpRequest.on('dataReceive', (data: ArrayBuffer) => {
         // 下载数据流多次返回
         arrayBuffers.push(data);
       })
       httpRequest.on('dataReceiveProgress', (data: RequestData) => {
         // 下载进度
         if (data != undefined && (typeof data.receiveSize == 'number') && (typeof data.totalSize == 'number')) {
           let percent = Math.round(((data.receiveSize * 1.0) / (data.totalSize * 1.0)) * 100)
           if (request.progressFunc) {
             request.progressFunc.asyncSuccess(percent)
           }
         }
       })
       httpRequest.on('dataEnd', () => {
         // 下载完毕
       })
       const headerObj: Record<string, Object> = {}
       request.headers.forEach((value, key) => {
         headerObj[key] = value
       })
       const data = await httpRequest.requestInStream(request.loadSrc as string, {
         header: headerObj,
         method: http.RequestMethod.GET,
         expectDataType: http.HttpDataType.ARRAY_BUFFER,
         connectTimeout: 60000, // 可选 默认60000ms
         readTimeout: 0, // 可选, 默认为60000ms
         usingProtocol: http.HttpProtocol.HTTP1_1, // 可选,协议类型默认值由系统自动指定
         usingCache: false
       }).catch((err: Error) => {
         result.error = `HttpDownloadClient has error, http code = ` + JSON.stringify(err);
       })
       if ( data == 200) {
         result.data = this.combineArrayBuffers(arrayBuffers);
       }
       console.log('TestCustomDataFetch http onComplete, code = ' + data + ',length = ' + result.data?.byteLength);
     } catch (err) {
       result.error ='HttpDownloadClient catch err request uuid =' + request.uuid;
     }
     return result;
  }

  combineArrayBuffers(arrayBuffers: ArrayBuffer[]): ArrayBuffer {
    // 计算多个ArrayBuffer的总字节大小
    let totalByteLength = 0;
    for (const arrayBuffer of arrayBuffers) {
      totalByteLength += arrayBuffer.byteLength;
    }

    // 创建一个新的ArrayBuffer
    const combinedArrayBuffer = new ArrayBuffer(totalByteLength);

    // 创建一个Uint8Array来操作新的ArrayBuffer
    const combinedUint8Array = new Uint8Array(combinedArrayBuffer);

    // 依次复制每个ArrayBuffer的内容到新的ArrayBuffer中
    let offset = 0;
    for (const arrayBuffer of arrayBuffers) {
      const sourceUint8Array = new Uint8Array(arrayBuffer);
      combinedUint8Array.set(sourceUint8Array, offset);
      offset += sourceUint8Array.length;
    }

    return combinedArrayBuffer;
  }
}