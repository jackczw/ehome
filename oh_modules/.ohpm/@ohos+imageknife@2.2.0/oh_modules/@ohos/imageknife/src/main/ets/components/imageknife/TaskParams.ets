/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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
import { ObjectKey } from './ObjectKey';
import { Priority, Size } from '../imageknife/RequestOption'
import common from '@ohos.app.ability.common'
import { MResource } from './utils/MResource';
import { DataFetchResult } from './networkmanage/DataFetchResult';

export class TaskParams {
  headers: Map<string, Object> = new Map<string, Object>();
  moduleContext?: common.UIAbilityContext = undefined;
  priority: Priority = Priority.MEDIUM // 优先级
  size: Size = { width: -1, height: -1 };
  loadSrc: string | PixelMap | MResource = "";
  placeholderSrc: string | PixelMap | MResource | undefined = undefined;
  errorholderSrc: PixelMap | MResource | undefined = undefined;
  retryholderSrc: PixelMap | MResource | undefined = undefined;
  fallbackSrc: PixelMap | MResource | undefined = undefined;
  customGetImage?: (context: Context, loadSrc: string) => Promise<DataFetchResult>;
}