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
import { FileUtils } from './FileUtils'
import { DiskCacheEntry } from './DiskCacheEntry'
import { SparkMD5 } from '../3rd_party/sparkmd5/spark-md5'
import common from '@ohos.app.ability.common'
import { CustomSendableMap } from './CustomSendableMap'

@Sendable
export class DiskLruCache {
  // 默认缓存数据最大值
  private static readonly DEFAULT_MAX_SIZE: number = 300 * 1024 * 1024
  // 默认缓存文件名
  private static readonly DEFAULT_NAME: string = 'diskLruCache'
  // 缓存文件路径地址
  private path: string = ''

  // 缓存数据最大值
  private maxSize: number = DiskLruCache.DEFAULT_MAX_SIZE
  // 当前缓存数据值
  private size: number = 0
  // 缓存数据集合
  private cacheMap: CustomSendableMap = new CustomSendableMap()

   constructor(path: string, maxSize: number) {
    this.path = path
    this.maxSize = maxSize
  }

  /**
   * 打开context获取的cache路径中的缓存，如果不存在缓存，则创建新缓存
   *
   * @param context 上下文
   * @param maxSize 缓存数据最大值，默认值为300M
   */
  public static create(context: common.UIAbilityContext, maxSize?: number): DiskLruCache {
    if (!!!context) {
      throw new Error('DiskLruCache create context is empty, checking the parameter');
    }
    if (!!!maxSize) {
      maxSize = DiskLruCache.DEFAULT_MAX_SIZE
    }
    if (maxSize <= 0) {
      throw new Error("DiskLruCache create maxSize <= 0, checking the parameter");
    }

    // 使用默认应用在内部存储上的缓存路径，作为存储地址
    let path = context.cacheDir + FileUtils.SEPARATOR + DiskLruCache.DEFAULT_NAME
    if (!FileUtils.getInstance().existFolder(path)) {
      FileUtils.getInstance().createFolder(path)
    }
    if (path.endsWith(FileUtils.SEPARATOR)) {
      path = path
    } else {
      path = path + FileUtils.SEPARATOR
    }
    return new DiskLruCache(path, maxSize)
  }

  /**
   * 设置disk缓存最大数据值
   *
   * @param max 缓存数据最大值
   */
  setMaxSize(max: number) {
    if (max <= 0 || max > DiskLruCache.DEFAULT_MAX_SIZE) {
      throw new Error('setMaxSize error, checking the parameter');
    }
    this.maxSize = max
    this.trimToSize()
  }

  /**
   * 存储disk缓存数据
   *
   * @param key 键值
   * @param content 文件内容
   */
  set(key: string, content: ArrayBuffer | string) {
    if (!!!key) {
      throw new Error('key is null, checking the parameter')
    }
    let fileSize = 0;
    if (content instanceof ArrayBuffer) {
      if (content == null || content.byteLength == 0) {
        throw new Error('content is null. checking the parameter')
      }
      fileSize = content.byteLength
    } else {
      if (!!!content) {
        throw new Error('content is null, checking the parameter')
      }
      fileSize = content.length;
    }
    if (this.fileSizeMoreThenMaxSize(fileSize)) {
      throw new Error('content must be less then DiskLruCache Size, checking the parameter')
      return
    }
    key = SparkMD5.hashBinary(key)
    this.size = this.size + fileSize
    this.putCacheMap(key, fileSize)
    this.trimToSize()
    let tempPath = this.path + key
    FileUtils.getInstance().writeNewFile(tempPath, content)
  }

  /**
   * 异步存储disk缓存数据
   *
   * @param key 键值
   * @param content 文件内容
   */
  async setAsync(key: string, content: ArrayBuffer | string): Promise<void> {
    if (!!!key) {
      throw new Error('key is null, checking the parameter')
    }
    let fileSize = 0;
    if (content instanceof ArrayBuffer) {
      if (content == null || content.byteLength == 0) {
        throw new Error('content is null. checking the parameter')
      }
      fileSize = content.byteLength
    } else {
      if (!!!content) {
        throw new Error('content is null, checking the parameter')
      }
      fileSize = content.length;
    }
    if (this.fileSizeMoreThenMaxSize(fileSize)) {
      throw new Error('content must be less then DiskLruCache Size, checking the parameter')
      return
    }
    key = SparkMD5.hashBinary(key)
    this.size = this.size + fileSize
    this.putCacheMap(key, fileSize)
    this.trimToSize()
    let tempPath = this.path + key
    await FileUtils.getInstance().writeNewFileAsync(tempPath, content)
  }

  /**
   * 获取key缓存数据
   *
   * @param key key 键值
   */
  get(key: string): ArrayBuffer | undefined {
    if (!!!key) {
      throw new Error('key is null,checking the parameter');
    }
    key = SparkMD5.hashBinary(key)
    let path = this.path + key;
    if (FileUtils.getInstance().exist(path)) {
      let ab: ArrayBuffer = FileUtils.getInstance().readFile(path)
      this.putCacheMap(key, ab.byteLength)
      return ab
    } else {
      return undefined;
    }
  }

  /**
   * 异步获取key缓存数据
   *
   * @param key 键值
   */
  async getAsync(key: string): Promise<ArrayBuffer | undefined> {
    if (!!!key) {
      throw new Error('key is null,checking the parameter');
    }
    key = SparkMD5.hashBinary(key)
    let path = this.path + key;
    if (FileUtils.getInstance().exist(path)) {
      let ab: ArrayBuffer = await FileUtils.getInstance().readFileAsync(path)
      this.putCacheMap(key, ab.byteLength)
      return ab
    } else {
      return undefined;
    }
  }

  /**
   * 获取key缓存数据绝对路径
   *
   * @param key 键值
   */
  getFileToPath(key: string): string {
    if (!!!key) {
      throw new Error('key is null,checking the parameter');
    }
    key = SparkMD5.hashBinary(key);
    let path = this.path + key;
    if (FileUtils.getInstance().exist(path)) {
      return path
    } else {
      return "";
    }
  }

  /**
   * 异步获取key缓存数据绝对路径
   *
   * @param key 键值
   */
  async getFileToPathAsync(key: string): Promise<string> {
    if (!!!key) {
      throw new Error('key is null,checking the parameter');
    }
    key = SparkMD5.hashBinary(key);
    let path = this.path + key;
    if (FileUtils.getInstance().exist(path)) {
      return path
    } else {
      return ""
    }
  }

  /**
   * 获取缓存路径
   */
  getPath(): string {
    return this.path;
  }

  /**
   * 删除key缓存数据
   *
   * @param key 键值
   */
  deleteCacheDataByKey(key: string): DiskCacheEntry {
    if (!!!key) {
      throw new Error('key is null,checking the parameter');
    }
    key = SparkMD5.hashBinary(key)
    let path = this.path + key;
    if (FileUtils.getInstance().exist(path)) {
      let ab = FileUtils.getInstance().readFile(path)
      this.size = this.size - ab.byteLength
      this.cacheMap.remove(key)
      FileUtils.getInstance().deleteFile(path)
    }
    return this.cacheMap.get(key) as DiskCacheEntry;
  }

  /**
   *遍历当前的磁盘缓存数据
   *
   * @param fn 遍历后方法回调
   */
  foreachDiskLruCache(fn: Function) {
    this.cacheMap.each(fn())
  }

  /**
   * 清除所有disk缓存数据
   */
  cleanCacheData() {
    this.cacheMap.each((value, key) => {
      FileUtils.getInstance().deleteFile(this.path + key)
    })
    this.cacheMap.clear()
    this.size = 0
  }
  async cleanAllDiskCache() {
    let filenames: string[] = await FileUtils.getInstance().ListFile(this.path);
    for (let i = 0; i < filenames.length; i++) {
      await FileUtils.getInstance().deleteFile(this.path + filenames[i]);
    }
    this.cacheMap.clear();
    this.size = 0;
  }

  getCacheMap() {
    return this.cacheMap;
  }

  /**
   * 返回当前DiskLruCache的size大小
   */
  getSize() {
    return this.size;
  }

  /**
   * 缓存数据map集合
   *
   * @param key 键值
   * @param length 缓存文件大小
   */
  private putCacheMap(key: string, length?: number) {
    if (length && length > 0) {
      this.cacheMap.put(key, new DiskCacheEntry(key, length))
    } else {
      this.cacheMap.put(key, new DiskCacheEntry(key))
    }
  }

  /**
   * 根据LRU算法删除多余缓存数据
   */
  private trimToSize() {
    while (this.size > this.maxSize) {
      let tempKey: string = this.cacheMap.getFirstKey()
      let fileSize = FileUtils.getInstance().getFileSize(this.path + tempKey)
      if (fileSize > 0) {
        this.size = this.size - fileSize
      }
      FileUtils.getInstance().deleteFile(this.path + tempKey)
      this.cacheMap.remove(tempKey)
    }
  }

  /**
   * 图片文件过大 直接超过DiskLruCache上限
   */
  private fileSizeMoreThenMaxSize(fileSize: number): boolean {
    if (fileSize > this.maxSize) {
      return true;
    }
    return false;
  }

  /**
   * 子线程里只写入缓存文件
   * @param context
   * @param key
   * @param value
   */
  static saveFileCacheOnlyFile(path: string, key: string, value: ArrayBuffer): boolean {
    // 写文件
    if (!!!key) {
      throw new Error('key is null, checking the parameter')
    }
    key = SparkMD5.hashBinary(key);
    FileUtils.getInstance().writeNewFile(path + key, value);
    return true
  }

  /**
   * 子线程中，通过文件名，直接查找是否有文件缓存
   * @param context
   * @param key
   * @returns
   */
  static getFileCacheByFile(path: string, key: string): ArrayBuffer | undefined {
    // 从文件获取查看是否有缓存
    if (!!!key) {
      throw new Error('key is null,checking the parameter');
    }
    key = SparkMD5.hashBinary(key)
    let filepath = path + key;
    if (FileUtils.getInstance().exist(filepath)) {
      let ab: ArrayBuffer = FileUtils.getInstance().readFile(filepath)
      return ab
    } else {
      return undefined;
    }
  }

  // 添加缓存键值对，但不写文件（用于子线程已经写文件的场景）
  setCacheMapAndSize(key: string, content: ArrayBuffer | string): void {
    if (!!!key) {
      throw new Error('key is null, checking the parameter')
    }
    let fileSize = 0;
    if (content instanceof ArrayBuffer) {
      if (content == null || content.byteLength == 0) {
        throw new Error('content is null. checking the parameter')
      }
      fileSize = content.byteLength
    } else {
      if (!!!content) {
        throw new Error('content is null, checking the parameter')
      }
      fileSize = content.length;
    }
    if (this.fileSizeMoreThenMaxSize(fileSize)) {
      throw new Error('content must be less then DiskLruCache Size, checking the parameter')
    }
    key = SparkMD5.hashBinary(key);
    this.size = this.size + fileSize;
    this.putCacheMap(key, fileSize);
    this.trimToSize();
  }
}