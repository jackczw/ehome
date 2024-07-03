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
export class LogUtil {
  static isLog: boolean = true
  static tag: string= 'MMKV - '
  /**
   * debug log
   * @param message
   */
  static d(message: string) {
    if (LogUtil.isLog) {
      console.debug(LogUtil.tag+message)
    }
  }

  /**
   * info log
   * @param message
   */
  static i(message: string) {
    if (LogUtil.isLog) {
      console.info(LogUtil.tag+message)
    }
  }

  /**
   * error log
   * @param message
   */
  static e(message: string) {
    if (LogUtil.isLog) {
      console.error(LogUtil.tag+message)
    }
  }

  /**
   * warn log
   * @param message
   */
  static w(message: string) {
    if (LogUtil.isLog) {
      console.warn(LogUtil.tag+message)
    }
  }
}