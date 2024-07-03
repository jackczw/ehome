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
import { MMKVLogLevel } from './MMKVLogLevel'
import { SerializeBase } from './SerializeBase';
import prefrences from '@ohos.data.preferences';
import { LogUtil } from './LogUtil';
import mmkvSo from 'libmmkv.so';
import { ICallBack } from './ICallBack';
import buffer from '@ohos.buffer';
import { getKeys } from './Util';
import common from '@ohos.app.ability.common';

export class MMKV {
  private static rootDir: string = ''
  private nativeHandle: string = "0"
  private static checkedHandleSet: Set<string>
  static isProcessModeCheckerEnabled: boolean = true
  static SINGLE_PROCESS_MODE: number = 1 << 0
  static MULTI_PROCESS_MODE: number = 1 << 1
  private static ASHMEM_MODE: number = 1 << 3
  private static BACKUP_MODE: number = 1 << 4
  static logLevel2Index: Map<MMKVLogLevel, number> = new Map<MMKVLogLevel, number>()
  static index2Level: MMKVLogLevel[] = [MMKVLogLevel.LevelDebug, MMKVLogLevel.LevelInfo, MMKVLogLevel.LevelWarning,
  MMKVLogLevel.LevelError, MMKVLogLevel.LevelNone]
  static gWantLogReDirecting: boolean = false

  private constructor(handle: string) {
    try {
      this.nativeHandle = handle
    } catch (e) {
      LogUtil.d('constructor - e ' + e)
    }
  }

  /**
   * initial data
   */
  static initial() {
    MMKV.checkedHandleSet = new Set<string>()
    MMKV.logLevel2Index.set(MMKVLogLevel.LevelDebug, 0)
    MMKV.logLevel2Index.set(MMKVLogLevel.LevelInfo, 1)
    MMKV.logLevel2Index.set(MMKVLogLevel.LevelWarning, 2)
    MMKV.logLevel2Index.set(MMKVLogLevel.LevelError, 3)
    MMKV.logLevel2Index.set(MMKVLogLevel.LevelNone, 4)
  }

  /**
   * Initialize MMKV with customize settings.
   * You must call one of the initialize() methods on App startup process before using MMKV.
   * @param rootDir The root folder of MMKV, defaults to $(FilesDir)/mmkv.
   * @param cachePath The cache folder of MMKV
   * @param logLevel The log level of MMKV, defaults to {@link MMKVLogLevel#LevelInfo}.
   * @return The root folder of MMKV.
   */
  static initialize(root: string, cachePath: string, logLevel?: MMKVLogLevel): string {
    if (!root || !cachePath) {
      throw new Error('root is null or cachePath is null')
    }
    try {
      MMKV.initial()
      if (typeof (logLevel) == 'undefined') {
        logLevel = MMKVLogLevel.LevelDebug
      }
      mmkvSo.jniInitialize(root, cachePath, MMKV.logLevel2Int(logLevel))
    } catch (e) {
      LogUtil.i('initialize ' + e)
    }
    MMKV.rootDir = root
    return MMKV.rootDir
  }

  /**
   * Get an backed-up MMKV instance with customize settings all in one.
   * @param mmapID The unique ID of the MMKV instance.
   * @param mode The process mode of the MMKV instance, defaults to {@link #SINGLE_PROCESS_MODE}.
   * @param cryptKey The encryption key of the MMKV instance (no more than 16 bytes).
   * @param rootPath The backup folder of the MMKV instance.
   */
  static getBackedUpMMKVWithID(mmapID: string, mode: number, crpKey: string, rootPath: string): MMKV {
    if (!MMKV.rootDir) {
      throw new Error('You should Call MMKV.initialize() first.')
    }
    mode = mode | MMKV.BACKUP_MODE
    let handle: string = mmkvSo.getMMKVWithID(mmapID, mode, crpKey, rootPath)
    return MMKV.checkProcessMode(handle, mmapID, mode);
  }

  /**
   * Create an MMKV instance in customize process mode, with an encryption key.
   * @param mmapID The unique ID of the MMKV instance.
   * @param mode The process mode of the MMKV instance, defaults to {@link #SINGLE_PROCESS_MODE}.
   * @param cryptKey The encryption key of the MMKV instance (no more than 16 bytes).
   * @param rootPath The folder of the MMKV instance, defaults to $(FilesDir)/mmkv.
   */
  static getMMKVWithMMapID(mmapID: string, mode: number, crpKey: string, rootPath?: string): MMKV {
    if (!MMKV.rootDir) {
      throw new Error('You should Call MMKV.initialize() first.')
    }
    if (!rootPath) {
      rootPath = undefined
    }
    let handle: string = mmkvSo.getMMKVWithID(mmapID, mode, crpKey, rootPath)
    return MMKV.checkProcessMode(handle, mmapID, mode)
  }

  /**
   * Create an MMKV instance base on Anonymous Shared Memory, aka not synced to any disk files.
   * @param mmapID The unique ID of the MMKV instance.
   * @param size The maximum size of the underlying Anonymous Shared Memory.
   *            Anonymous Shared Memory on Android can't grow dynamically, must set an appropriate size on creation.
   * @param mode The process mode of the MMKV instance, defaults to {@link #SINGLE_PROCESS_MODE}.
   * @param cryptKey The encryption key of the MMKV instance (no more than 16 bytes).
   */
  static getMMKVWithAshmemID(mmapID: string, size: number, mode: number, crpKey: string): MMKV {
    if (!MMKV.rootDir) {
      throw new Error('You should Call MMKV.initialize() first.')
    }
    mode = mode | MMKV.ASHMEM_MODE
    MMKV.simpleLog(MMKVLogLevel.LevelInfo, "getting mmkv in main process")
    let handle: string = mmkvSo.getMMKVWithIDAndSize(mmapID, size, mode, crpKey)
    if (!!handle) {
      return new MMKV(handle)
    } else {
      return new MMKV("0")
    }
  }

  /**
   * Create the default MMKV instance in single-process mode.
   */
  static getDefaultMMKV(mode?: number, cryptKey?: string): MMKV {
    if (!MMKV.rootDir) {
      throw new Error('You should Call MMKV.initialize() first.')
    }
    if (typeof (mode) == 'undefined') {
      mode = MMKV.SINGLE_PROCESS_MODE
    }
    if (!cryptKey) {
      cryptKey = undefined
    }
    let handle: string = mmkvSo.getDefaultMMKV(mode, cryptKey)
    return MMKV.checkProcessMode(handle, 'DefaultMMKV', mode)
  }

  /**
   * Create the default MMKV instance in customize process mode, with an encryption key.
   * @param handle The ID of the MMKV instance
   * @param mode The process mode of the MMKV instance, defaults to {@link #SINGLE_PROCESS_MODE}.
   * @param cryptKey The encryption key of the MMKV instance (no more than 16 bytes).
   */
  private static checkProcessMode(handle: string, mmapID: string, mode: number): MMKV {
    if (handle == "0") {
      throw new Error('Fail to create an MMKV instance [' + mmapID + '] in JNI')
    }
    if (!MMKV.checkedHandleSet.has(handle)) {
      if (!MMKV.jniCheckProcessMode(handle)) {
        let message = ''
        if (mode == MMKV.SINGLE_PROCESS_MODE) {
          message = 'Opening a multi-process MMKV instance [' + mmapID + '] with SINGLE_PROCESS_MODE!';
        } else {
          message = 'Opening an MMKV instance [' + mmapID + '] with MULTI_PROCESS_MODE, ';
          message += "while it's already been opened with SINGLE_PROCESS_MODE by someone somewhere else!";
        }
        throw new Error(message);
      }
      MMKV.checkedHandleSet.add(handle)
    }
    return new MMKV(handle)
  }

  /**
   *
   * @param handle  The ID of the MMKV instance
   */
  private static jniCheckProcessMode(handle: string): boolean {
    return mmkvSo.checkProcessMode(handle)
  }

  /**
   * decode double value by key
   * @param handle The ID of the MMKV instance
   * @param key the value of key
   * @param defaultValue defaultValue the default value
   */
  private static jniDecodeNumber(handle: string, key: string, defaultValue: number): number {
    return mmkvSo.decodeDouble(handle, key, defaultValue)
  }

  /**
   * decode string value by key
   * @param handle The ID of the MMKV instance
   * @param key the value of key
   * @param defaultValue defaultValue the default value
   */
  private static jniDecodeString(handle: string, key: string, defaultValue: string): string {
    let buf = buffer.from(defaultValue, 'utf8', defaultValue.length);
    return mmkvSo.decodeString(handle, key, buf.length, defaultValue)
  }

  /**
   * decode boolean value by key
   * @param handle The ID of the MMKV instance
   * @param key the value of key
   * @param defaultValue defaultValue the default value
   */
  private static jniDecodeBool(handle: string, key: string, defaultValue: boolean): boolean {
    return mmkvSo.decodeBool(handle, key, defaultValue)
  }

  /**
   * decode stringSet value by key
   * @param handle The ID of the MMKV instance
   * @param key the value of key
   * @param defaultValue defaultValue the default value
   */
  private static jniDecodeStringSet(handle: string, key: string): string[] {
    return mmkvSo.decodeStringSet(handle, key)
  }

  /**
   * get number value by key
   * @param key the value of key
   * @param defaultValue the default value
   */
  decodeNumber(key: string, defaultValue?: number): number {
    if (typeof (defaultValue) == 'undefined') {
      defaultValue = 0
    }
    return MMKV.jniDecodeNumber(this.nativeHandle, key, defaultValue)
  }

  /**
   * get boolean value by key
   * @param key the value of key
   * @param defaultValue the default value
   */
  decodeBool(key: string, defaultValue?: boolean): boolean {
    if (typeof (defaultValue) == 'undefined') {
      defaultValue = false
    }
    return MMKV.jniDecodeBool(this.nativeHandle, key, defaultValue)
  }

  /**
   * get string value by key
   * @param key the value of key
   * @param defaultValue the default value
   */
  decodeString(key: string, defaultValue?: string): string {
    if (typeof (defaultValue) == 'undefined') {
      defaultValue = ''
    }
    return MMKV.jniDecodeString(this.nativeHandle, key, defaultValue)
  }

  /**
   * get serialize value by key
   * @param key the value of key
   * @param defaultValue the default value
   */
  decodeSerialize<T extends SerializeBase>(key: string, defaultValue: T): T {
    try {
      let valueObj = defaultValue.toSerialize()
      let serializeStr = JSON.stringify(valueObj)
      let value = MMKV.jniDecodeString(this.nativeHandle, key, serializeStr)
      let objStr: Object = JSON.parse(value)
      defaultValue.deseSerialize(objStr)
    } catch (e) {
      LogUtil.e('decodeSerialize e:' + e)
    }
    return defaultValue
  }

  /**
   * get set value by key
   * @param key the value of key
   * @param defaultValue the default value
   */
  decodeSet(key: string, defaultValue?: Set<string>): Set<string> {
    if (typeof (defaultValue) == 'undefined') {
      defaultValue = new Set<string>()
    }
    let stringSet: string[] = MMKV.jniDecodeStringSet(this.nativeHandle, key)
    if (stringSet == null) {
      LogUtil.i('decodeStringSet native return is null');
      return defaultValue;
    }
    let tempSet: Set<string> = new Set<string>()
    stringSet.forEach((item: string) => {
      tempSet.add(item)
    })
    return tempSet
  }

  private encodeInt2Bool(boolNum: number): boolean {
    if (boolNum == 0) {
      return false;
    } else {
      return true
    }
  }

  /**
   * save key value
   * @param key the value of key
   * @param value
   */
  encode(key: string, value: number | Set<string> | string | boolean): boolean {
    let boolNum: number = 0;
    if (typeof (value) == 'number') {
      boolNum = mmkvSo.encodeDouble(this.nativeHandle, key, value)
      return this.encodeInt2Bool(boolNum);
    } else if (typeof (value) == 'string') {
      let buf = buffer.from(value, 'utf8', value.length);
      boolNum = mmkvSo.encodeString(this.nativeHandle, key, buf.length, value);
      return this.encodeInt2Bool(boolNum);
    } else if (typeof (value) == 'boolean') {
      boolNum = mmkvSo.encodeBool(this.nativeHandle, key, value);
      return this.encodeInt2Bool(boolNum);
    } else if (value instanceof Set) {
      let arr: string[] = new Array();
      let arrayLength: number[] = new Array();
      let i: number = 0;
      value.forEach((value1) => {
        arr[i] = value1;
        let buf: buffer.Buffer = buffer.from(value1, 'utf8', value1.length);
        arrayLength[i] = buf.length;
        i++;
      });

      boolNum = mmkvSo.encodeSet(this.nativeHandle, key, arrayLength, arr);
      return this.encodeInt2Bool(boolNum);
    } else {
      MMKV.simpleLog(MMKVLogLevel.LevelError, 'unknown type');
      return false
    }
  }

  /**
   * save string value
   * @param key the value of key
   * @param value
   */
  encodeString(key: string, value: string): boolean {
    let boolNum = 0;
    let buf = buffer.from(value, 'utf8', value.length);
    boolNum = mmkvSo.encodeString(this.nativeHandle, key, buf.length, value);
    return this.encodeInt2Bool(boolNum);
  }

  /**
   * save Set<string> value
   * @param key the value of key
   * @param value
   */
  encodeSet(key: string, value: Set<string>): boolean {
    let arr: string[] = new Array();
    let arrayLength: number[] = new Array();
    let i: number = 0;
    value.forEach((value1) => {
      arr[i] = value1;
      let buf: buffer.Buffer = buffer.from(value1, 'utf8', value1.length);
      arrayLength[i] = buf.length;
      i++;
    });
    let boolNum: number = mmkvSo.encodeSet(this.nativeHandle, key, arrayLength, arr);
    return this.encodeInt2Bool(boolNum);
  }

  /**
   * save boolean value
   * @param key the value of key
   * @param value
   */
  encodeBool(key: string, value: boolean): boolean {
    let boolNum: number = mmkvSo.encodeBool(this.nativeHandle, key, value);
    return this.encodeInt2Bool(boolNum);
  }

  /**
   * save number value
   * @param key the value of key
   * @param value
   */
  encodeNumber(key: string, value: number): boolean {
    let boolNum: number = mmkvSo.encodeDouble(this.nativeHandle, key, value)
    return this.encodeInt2Bool(boolNum);
  }

  /**
   * save Serialize key & value
   * @param key the value of key
   * @param value
   */
  encodeSerialize(key: string, value: SerializeBase): boolean {
    let valueObj = value.toSerialize()
    let serializeStr = JSON.stringify(valueObj)
    let buf = buffer.from(serializeStr, 'utf8', serializeStr.length);
    let boolNum: number = mmkvSo.encodeString(this.nativeHandle, key, buf.length, serializeStr)
    return this.encodeInt2Bool(boolNum);
  }

  /**
   * Check whether or not MMKV contains the key.
   * @param key The key of the value.
   */
  containsKey(key: string): boolean {
    return mmkvSo.containsKey(this.nativeHandle, key)
  }

  /**
   * @return All the keys.
   */
  getAllKeys(): string[] {
    return mmkvSo.allKeys(this.nativeHandle)
  }

  /**
   * Clear all the key-values inside the MMKV instance.
   */
  clearAll() {
    mmkvSo.clearAll(this.nativeHandle)
  }

  /**
   * Clear memory cache of the MMKV instance.
   * You can call it on memory warning.
   * Any subsequent call to the MMKV instance will trigger all key-values loading from the file again.
   */
  clearMemoryCache() {
    mmkvSo.clearMemoryCache(this.nativeHandle)
  }

  /**
   * Batch remove some keys from the MMKV instance.
   * @param arrKeys The keys to be removed.
   */
  removeValuesForKeys(value: string[]) {
    let keyLength: number[] = new Array();
    let i = 0;
    value.forEach((key) => {
      keyLength[i] = key.length;
      i++;
    });

    keyLength.forEach((length: number) => {
      console.log(length + "");
    });
    mmkvSo.removeValuesForKeys(this.nativeHandle, keyLength, value);
  }

  /**
   * @return The total count of all the keys.
   */
  count(): number {
    return mmkvSo.count(this.nativeHandle)
  }

  /**
   * Get the size of the underlying file. Align to the disk block size, typically 4K for an Android device.
   */
  totalSize(): number {
    return mmkvSo.totalSize(this.nativeHandle)
  }

  /**
   * Get the actual used size of the MMKV instance.
   * This size might increase and decrease as MMKV doing insertion and full write back.
   */
  actualSize(): number {
    return mmkvSo.actualSize(this.nativeHandle)
  }

  /**
   * remove value by key
   * @param key the key of value
   */
  removeValueForKey(key: string) {
    mmkvSo.removeValueForKey(this.nativeHandle, key)
  }

  /**
   *
   */
  getHandle(): string {
    return this.nativeHandle
  }

  /**
   * Call this method if the MMKV instance is no longer needed in the near future.
   * Any subsequent call to any MMKV instances with the same ID is undefined behavior.
   */
  close() {
    mmkvSo.close()
    this.nativeHandle = "0"
  }

  /**
   * The {@link #totalSize()} of an MMKV instance won't reduce after deleting key-values,
   * call this method after lots of deleting if you care about disk usage.
   * Note that {@link #clearAll()}  has a similar effect.
   */
  trim() {
    mmkvSo.trim(this.nativeHandle)
  }

  /**
   * Check inter-process content change manually.
   */
  checkContentChangedByOuterProcess() {
    mmkvSo.checkContentChangedByOuterProcess(this.nativeHandle)
  }

  /**
   * restore one MMKV instance from srcDir
   * @param mmapID the MMKV ID to restore
   * @param srcDir the restore source directory
   * @param rootPath the customize root path of the MMKV, if null then restore to the root dir of MMKV
   */
  static restoreOneMMKVFromDirectory(mmapID: string, srcDir: string, rootPath: string): boolean {
    return mmkvSo.restoreOneMMKVFromDirectory(mmapID, srcDir, rootPath)
  }

  /**
   * backup one MMKV instance to dstDir
   * @param mmapID the MMKV ID to backup
   * @param rootPath the customize root path of the MMKV, if null then backup from the root dir of MMKV
   * @param dstDir the backup destination directory
   */
  static backupOneToDirectory(mmapID: string, dstDir: string, rootPath: string): boolean {
    return mmkvSo.backupOneToDirectory(mmapID, dstDir, rootPath)
  }

  /**
   * backup all MMKV instance to dstDir
   * @param dstDir the backup destination directory
   * @return count of MMKV successfully backuped
   */
  static backupAllToDirectory(dstDir: string): number {
    return mmkvSo.backupAllToDirectory(dstDir)
  }

  /**
   * restore all MMKV instance from srcDir
   * @param srcDir the restore source directory
   * @return count of MMKV successfully restored
   */
  static restoreAllFromDirectory(srcDir: string): number {
    return mmkvSo.restoreAllFromDirectory(srcDir)
  }

  /**
   * Set the log level of MMKV.
   * @param level
   */
  static setLogLevel(level: MMKVLogLevel) {
    let realLevel = MMKV.logLevel2Int(level)
    mmkvSo.setLogLevel(realLevel)
  }

  /**
   * @return The root folder of MMKV, defaults to $(FilesDir)/mmkv.
   */
  static getRootDir(): string {
    return MMKV.rootDir
  }

  /**
   * The device's memory page size
   */
  static pageSize(): number {
    return mmkvSo.pageSize()
  }

  /**
   * The version of MMKV.
   */
  static version(): string {

    return mmkvSo.version()
  }

  /**
   * Check whether the MMKV file is valid or not
   * @param mmapID The unique ID of the MMKV instance
   */
  static isFileValid(mmapID: string): boolean {
    return mmkvSo.isFileValid(mmapID, null)
  }

  /**
   * The encryption key (no more than 16 bytes
   */
  getCryptKey(): string {
    return mmkvSo.cryptKey(this.nativeHandle)
  }

  /**
   * Transform plain text into encrypted text, or vice versa by passing a null encryption key.
   * You can also change existing crypt key with a different cryptKey.
   * @param cryptKey The new encryption key (no more than 16 bytes).
   * @return True if success, otherwise False.
   */
  reCryptKey(cryptKey: string): boolean {
    return mmkvSo.reKey(this.nativeHandle, cryptKey)
  }

  /**
   * Just reset the encryption key (will not encrypt or decrypt anything).
   * @param cryptKey The new encryption key (no more than 16 bytes).
   */
  checkReSetCryptKey(cryptKey: string) {
    mmkvSo.checkReSetCryptKey(this.nativeHandle, cryptKey)
  }

  /**
   * The unique ID of the MMKV instance
   */
  getMMapID(): string {
    return mmkvSo.mmapID(this.nativeHandle)
  }

  /**
   * logLevel change to Int
   * @param level
   */
  private static logLevel2Int(level: MMKVLogLevel): number {
    let realLevel: number = 1
    switch (level) {
      case MMKVLogLevel.LevelDebug:
        realLevel = 0
        break
      case MMKVLogLevel.LevelWarning:
        realLevel = 2
        break
      case MMKVLogLevel.LevelError:
        realLevel = 3
        break
      case MMKVLogLevel.LevelNone:
        realLevel = 4
        break
      case MMKVLogLevel.LevelInfo:
      default:
        realLevel = 1
        break
    }
    return realLevel
  }

  /**
   * console message
   * @param level
   * @param message
   */
  static simpleLog(level: MMKVLogLevel, message: string) {
    // mul-thread
    switch (MMKV.index2Level[level]) {
      case MMKVLogLevel.LevelDebug:
        LogUtil.d('MMKV ' + message)
        break
      case MMKVLogLevel.LevelInfo:
        LogUtil.i('MMKV ' + message)
        break
      case MMKVLogLevel.LevelWarning:
        LogUtil.w('MMKV ' + message)
        break
      case MMKVLogLevel.LevelError:
        LogUtil.e('MMKV ' + message)
        break
      case MMKVLogLevel.LevelNone:
        break
    }
  }

  /**
   * parse preference file
   * @param context 上下文
   * @param path the name of preference file
   * @param callback 异步回调，result返回1说明preferencesToMMKV成功结束，其他返回值说明preferencesToMMKV调用异常
   */
  preferencesToMMKV(context: common.BaseContext, name: string, callback: ICallBack) {
    if (context == null) {
      LogUtil.e("context is null,preferencesToMMKV need context");
      return;
    }

    prefrences.getPreferences(context, name, (err, pref) => {
      if (err) {
        LogUtil.e("Failed to get preferences. code =" + err.code + ", message =" + err.message);
        if (callback != null) {
          callback.callBackResult(0);
        }
        return;
      }
      pref.getAll()
        .then((obj) => {
          let objKeys: string[] = getKeys(obj);
          for (let i = 0; i < objKeys.length; i++) {
            let params = obj as Record<string, Object>;
            LogUtil.i(objKeys[i] + " " + params[objKeys[i]]);
            if (typeof params[objKeys[i]] == 'string') {
              this.encodeString(objKeys[i], params[objKeys[i]] as string);
            } else if (typeof params[objKeys[i]] == 'boolean') {
              this.encodeBool(objKeys[i], params[objKeys[i]] as boolean);
            } else if (typeof params[objKeys[i]] == 'number') {
              this.encodeNumber(objKeys[i], params[objKeys[i]] as number);
            }
          }
          if (callback != null) {
            callback.callBackResult(1);
          }
          return;
        }).catch((err: Error) => {
        if (err) {
          console.error("Failed to get all key-values. err =" + err.message);
          if (callback != null) {
            callback.callBackResult(0);
          }
          return;
        }
      })
    })
  }
}