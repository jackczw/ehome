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

export const onExit: () => void;

export const getDefaultMMKV: (mode?: number, cryptKey?: string) => string;

export const jniInitialize: (root: string, cachePath: string, logLevel: number) => void;

export const pageSize: () => number;

export const version: () => string;

export const isFileValid: (mMapID: string, relatePath: any) => boolean;

export const getMMKVWithID: (mMapID: string, mode: number, crpKey: string, rootPath?: string) => string;

export const getMMKVWithIDAndSize: (mMapID: string, size: number, mode: number, crpKey: string) => string;

export const encodeBool: (nativeHandle: string, key: string, value: number | Set<string> | string | boolean) => number;

export const decodeBool: (handle: string, key: string, defaultValue: boolean) => boolean;

export const encodeDouble: (nativeHandle: string, key: string, value: number | Set<string> | string | boolean) => number;

export const decodeDouble: (handle: string, key: string, defaultValue: number) => number;

export const encodeString: (nativeHandle: string, key: string, length: number, value: number | Set<string> | string | boolean) => number;

export const decodeString: (handle: string, key: string, length: number, defaultValue: string) => string;

export const containsKey: (nativeHandle: string, key: string) => boolean;

export const count: (nativeHandle: string) => number;

export const totalSize: (nativeHandle: string) => number;

export const actualSize: (nativeHandle: string) => number;

export const removeValueForKey: (nativeHandle: string, key: string) => void;

export const setLogLevel: (realLevel: number) => void;

export const createNB: (size: number) => number;

export const destroyNB: (pointer: number, size: number) => void;

export const writeValueToNB: (handle: string, oKey: string, pointer: number, size: number) => number;

export const checkProcessMode: (handle: string) => boolean;

export const backupOneToDirectory: (mMapID: string, dstDir: string, rootPath: string) => boolean;

export const restoreOneMMKVFromDirectory: (mMapID: string, srcDir: string, rootPath: string) => boolean;

export const backupAllToDirectory: (dstDir: string) => number;

export const restoreAllFromDirectory: (srcDir: string) => number;

export const cryptKey: (nativeHandle: string) => string;

export const reKey: (nativeHandle: string, cryptKey: string) => boolean;

export const checkReSetCryptKey: (nativeHandle: string, cryptKey: string) => boolean;

export const mmapID: (nativeHandle: string) => string;

export const allKeys: (nativeHandle: string) => string[];

export const clearAll: (nativeHandle: string) => void;

export const trim: (nativeHandle: string) => void;

export const close: () => void;

export const clearMemoryCache: (nativeHandle: string) => void;

export const checkContentChangedByOuterProcess: (nativeHandle: string) => void;

export const encodeSet: (nativeHandle: string, key: string, arrayLength: number[], array: string[]) => number;

export const decodeStringSet: (handle: string, key: string) => string[];

export const removeValuesForKeys: (handle: string, keyLength: number[], value: string[]) => void;

export const lock: (handle: string) => void;

export const unlock: (handle: string) => void;

export const tryLock: (handle: string) => boolean;

export const sync: (handle: string, sync: boolean) => void;

export const ashmemFD: (handle: string) => number;

export const ashmemMetaFD: (handle: string) => number;

export const setCallbackHandler: (logReDirecting: boolean, hasCallback: boolean) => void;

export const setWantsContentChangeNotify: (notify: boolean) => void;






