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
import common from '@ohos.app.ability.common'
import { collections } from '@kit.ArkTS';
import { IDataFetch } from './networkmanage/IDataFetch';
import { DiskLruCache } from '../cache/DiskLruCache';
import { DownloadClient } from './networkmanage/DownloadClient';
import { BaseDownsampling } from './downsampling/BaseDownsampling';
import { DownsampleNone } from './downsampling/DownsampleStartegy';
@Sendable
export class SendableData{

  private usageType: string = '';
  private displayProgress: boolean = false
  private uuid: string = '' // 唯一标识
  private dontAnimateFlag: boolean = false;
  private thumbSizeMultiplier: number = 0;
  private thumbDelayTime: number = 1000;
  private onlyRetrieveFromCache: boolean = false;
  private isCacheable: boolean = true;
  private gpuEnabled: boolean = false;
  private generateCacheKey: string = "";
  private generateResourceKey: string = "";
  private generateDataKey: string = "";
  private signature?: ObjectKey;
  private transformations: collections.Array<collections.Array<string>> = new collections.Array<collections.Array<string>>();
  private diskMemoryCachePath: string = '';
  private diskMemoryCache?: DiskLruCache;
  private dataFetch: IDataFetch = new DownloadClient();
  private placeholderRegisterCacheKey: string = "";
  private placeholderRegisterMemoryCacheKey: string = "";
  private downsampType: BaseDownsampling = new DownsampleNone();

  public setDataFetch(value: IDataFetch) {
    this.dataFetch = value;
  }

  public getDataFetch(): IDataFetch{
    return this.dataFetch;
  }

  public setDiskMemoryCachePath(value: string) {
    this.diskMemoryCachePath = value;
  }

  public getDiskMemoryCachePath(): string{
    return this.diskMemoryCachePath;
  }


  public setDiskMemoryCache(value: DiskLruCache) {
    this.diskMemoryCache = value;
  }

  public getDiskMemoryCache(): DiskLruCache | undefined{
    return this.diskMemoryCache;
  }

  public setTransformations(value: collections.Array<collections.Array<string>>) {
    this.transformations = value;
  }

  public getTransformations(): collections.Array<collections.Array<string>>{
    return this.transformations;
  }

  public setSignature(value: ObjectKey | undefined) {
    this.signature = value;
  }

  public getSignature(): ObjectKey | undefined{
    return this.signature;
  }

  public setGenerateDataKey(value: string) {
    this.generateDataKey = value;
  }

  public getGenerateDataKey(): string {
    return this.generateDataKey;
  }

  public setGenerateResourceKey(value: string) {
    this.generateResourceKey = value;
  }

  public getGenerateResourceKey(): string {
    return this.generateResourceKey;
  }

  public setGenerateCacheKey(value: string) {
    this.generateCacheKey = value;
  }

  public getGenerateCacheKey(): string {
    return this.generateCacheKey;
  }

  public setGpuEnabled(value: boolean) {
    this.gpuEnabled = value;
  }

  public getGpuEnabled(): boolean {
    return this.gpuEnabled;
  }

  public setIsCacheable(value: boolean) {
    this.isCacheable = value;
  }

  public getIsCacheable(): boolean {
    return this.isCacheable;
  }

  public setOnlyRetrieveFromCache(value: boolean) {
    this.onlyRetrieveFromCache = value;
  }

  public getOnlyRetrieveFromCache(): boolean {
    return this.onlyRetrieveFromCache;
  }

  public setThumbDelayTime(value: number) {
    this.thumbDelayTime = value;
  }

  public getThumbDelayTime(): number {
    return this.thumbDelayTime;
  }

  public setThumbSizeMultiplier(value: number) {
    this.thumbSizeMultiplier = value;
  }

  public getThumbSizeMultiplier(): number {
    return this.thumbSizeMultiplier;
  }

  public setDontAnimateFlag(value: boolean) {
    this.dontAnimateFlag = value;
  }

  public getDontAnimateFlag(): boolean {
    return this.dontAnimateFlag;
  }

  public setUuid(value: string) {
    this.uuid = value;
  }

  public getUuid(): string {
    return this.uuid;
  }

  public setDisplayProgress(value: boolean) {
    this.displayProgress = value;
  }

  public getDisplayProgress(): boolean {
    return this.displayProgress;
  }

  public setUsageType(value: string) {
    this.usageType = value;
  }

  public getUsageType(): string {
    return this.usageType;
  }

  public setPlaceHolderRegisterCacheKey(value: string) {
    this.placeholderRegisterCacheKey = value;
  }

  public getPlaceHolderRegisterCacheKey(): string {
    return this.placeholderRegisterCacheKey;
  }

  public setPlaceHolderRegisterMemoryCacheKey(value: string) {
    this.placeholderRegisterMemoryCacheKey = value;
  }

  public getPlaceHolderRegisterMemoryCacheKey(): string {
    return this.placeholderRegisterMemoryCacheKey;
  }

  public setDownsampType(Type: BaseDownsampling): BaseDownsampling {
    return this.downsampType = Type;
  }

  public getDownsampType(): BaseDownsampling {
    return this.downsampType;
  }
}