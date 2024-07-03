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

import  { IDataFetch } from '../networkmanage/IDataFetch'
import { RequestOption } from '../RequestOption'
import { FileUtils } from '../../cache/FileUtils'
import { BusinessError } from '@ohos.base'
import { DataFetchResult } from './DataFetchResult'

@Sendable
export class LoadLocalFileClient implements IDataFetch {
  async loadData(request: RequestOption) {
    let result:DataFetchResult =new DataFetchResult()
    try {
      if (typeof request.loadSrc == 'string') {
        let fileBuffer = await FileUtils.getInstance().readFilePicAsync(request.loadSrc)
        if (fileBuffer == null || fileBuffer.byteLength <= 0) {
          result.error = 'LoadLocalFileClient loadLocalFileData The File Does Not Exist!Check The File!';
        } else {
          result.data = fileBuffer
        }
      }
    } catch (e) {
      result.error ='LoadLocalFileClient loadLocalFileData Error Msg ='+e?.message;
    }
    return result;
  }
}