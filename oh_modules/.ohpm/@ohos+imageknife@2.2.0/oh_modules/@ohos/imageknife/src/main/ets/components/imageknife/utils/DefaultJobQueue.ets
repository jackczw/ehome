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
import { IJobQueue } from './IJobQueue';
import Queue from '@ohos.util.Queue';
import taskpool from '@ohos.taskpool';
import { RequestOption } from '../RequestOption';

export class DefaultJobQueue implements IJobQueue {
  highQueue: Queue<RequestOption> = new Queue();
  normalQueue: Queue<RequestOption> = new Queue();
  lowQueue: Queue<RequestOption> = new Queue();

  getQueueLength(): number {
    return this.highQueue.length + this.normalQueue.length + this.lowQueue.length;
  }

  add(request: RequestOption): void {
    if (request.priority === undefined || request.priority === taskpool.Priority.MEDIUM) {
      this.normalQueue.add(request);
    } else if (request.priority === taskpool.Priority.HIGH) {
      this.highQueue.add(request);
    } else {
      this.lowQueue.add(request);
    }
  }

  pop(): RequestOption | undefined {
    if (this.highQueue.length > 0) {
      return this.highQueue.pop();
    } else if (this.normalQueue.length > 0) {
      return this.normalQueue.pop();
    } else {
      return this.lowQueue.pop();
    }
  }
}