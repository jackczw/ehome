/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

import { ICache } from "../requestmanage/ICache"
import { LruCache } from "../../cache/LruCache"

export class ContextCacheProxy implements ICache<string, Context> {
  private mLruCache: LruCache<string, Context>;
  private static cache: ContextCacheProxy = new ContextCacheProxy(new LruCache(5));

  private constructor(lruCache: LruCache<string, Context>) {
    this.mLruCache = lruCache;
  }

  public static getInstance(): ContextCacheProxy {
    return ContextCacheProxy.cache;
  }


  // 缓存类型
  getName() {
    return "ContextCacheProxy"
  }

  contextGetValue(key: string, context: Context): Context | undefined{
    if (this.hasValue(key)) {
      return this.getValue(key);
    } else {
      let moduleContext = context.createModuleContext(key);
      this.putValue(key, moduleContext)
      return moduleContext;
    }
  }

  getValue(key: string): Context | undefined {
    return this.mLruCache.get(key);
  }

  hasValue(key: string): boolean {
    return this.mLruCache.has(key);
  }

  putValue(key: string, value: Context) {
    this.mLruCache.put(key, value);
  }

  removeValue(key: string): Context | undefined {
    return this.mLruCache.remove(key);
  }

  clear() {
    this.mLruCache.evicAll();
  }


  // 外界调用
  loadMemoryCache(key: string, isMemoryCacheable: boolean): Context | null {
    // 是否开启内存缓存
    if (!isMemoryCacheable) {
      return null;
    }
    let cached = this.getValue(key)
    if (cached != null) {
      return cached;
    }
    return null;
  }
}