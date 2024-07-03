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
import  'reflect-metadata';
import {LogUtil} from './LogUtil';

export const SerializeMetaKey = 'Serialize';

// 序列化装饰器
export function Serialize(name?: string) {
  return (target: any, property: string): void => {
    Reflect.defineMetadata(SerializeMetaKey, name || property, target, property);
  };
}

// 基类
export class SerializeBase {
  constructor() {
  }

  // 格式化
  toString(): string {
    return '';
  }

  // 序列化
  toSerialize(): Object {
    const obj = {};
    Object.keys(this).forEach(property => {
      const serialize = Reflect.getMetadata(SerializeMetaKey, this, property);
      if (typeof (serialize) != 'undefined') {
        if (this[property] instanceof SerializeBase) {
          obj[serialize] = this[property].toJSON();
        } else {
          obj[serialize] = this[property];
        }
      }
    });
    return obj;
  }

  // deserialization
  deseSerialize(obj) {
    obj && Object.keys(this).forEach(property => {
      const serialize = Reflect.getMetadata(SerializeMetaKey, this, property);
      if (typeof (serialize) != 'undefined') {
        if (this[property] instanceof SerializeBase) {
          this[property].fromJSON(obj[serialize]);
        } else {
          this[property] = obj[serialize];
        }
      }
    });
  }

  // 打印
  print() {
    Object.keys(this).forEach(property => {
      LogUtil.d('MMKV - print ' + property + ': ' + this[property]);
    });
  }
}