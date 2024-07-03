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

export class AsyncLock {
  private locked: boolean = false;
  private waitingList: Array<Function> = [];


  async acquire() {
    if (this.locked) {
      await new Promise((resolve) => {
        this.waitingList.push(resolve);
      });
    }
    this.locked = true;
  }

  release() {
    this.locked = false;
    if (this.waitingList.length > 0) {
      let resolve = this.waitingList.shift();
      resolve && resolve();
    }
  }
}