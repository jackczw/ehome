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

import { HttpDownloadClient } from './HttpDownloadClient'
import { LoadLocalFileClient } from './LoadLocalFileClient'
import { LoadDataShareFileClient } from './LoadDataShareFileClient'
import loadRequest from '@ohos.request';
import { ImageKnifeGlobal } from '../ImageKnifeGlobal'
import common from '@ohos.app.ability.common'
import { NetworkDownloadClient } from './NetworkDownloadClient'
import { DataFetchResult } from './DataFetchResult'

// 数据加载器
@Sendable
export class DownloadClient implements IDataFetch {
  private networkDownloadClient:NetworkDownloadClient = new NetworkDownloadClient();
  private httpDownloadClient:HttpDownloadClient = new HttpDownloadClient();
  private localFileClient:LoadLocalFileClient = new LoadLocalFileClient();
  private dataShareFileClient:LoadDataShareFileClient = new LoadDataShareFileClient();

  async loadData(request: RequestOption): Promise<DataFetchResult> {
    if (typeof request.loadSrc == 'string') {
      if (request.customGetImage) {
        return await request.customGetImage(ImageKnifeGlobal.getInstance()
          .getHapContext() as common.UIAbilityContext, request.loadSrc);
      } else if (this.isLocalLoadSrc(ImageKnifeGlobal.getInstance().getHapContext(), request.loadSrc)) {
        // 本地沙盒
        return this.localFileClient.loadData(request)
      } else if (request.loadSrc.startsWith('datashare://') || request.loadSrc.startsWith('file://')) {
        return  this.dataShareFileClient.loadData(request)
      } else {
        // 网络下载
        return await this.httpDownloadClient.loadData(request);
      }
    }else{
      let result:DataFetchResult = new DataFetchResult()
      result.error ="参数错误！";
      return result;
    }
  }

  isLocalLoadSrc(context: Object | undefined, loadSrc: string): boolean {
    if (context != undefined) {
      let fileDir: string = (context as common.UIAbilityContext).filesDir as string;
      let cacheDir: string = (context as common.UIAbilityContext).cacheDir as string
      if (loadSrc.startsWith(fileDir) || loadSrc.startsWith(cacheDir)) {
        return true;
      }
    }
    return false;
  }
}