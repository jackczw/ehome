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
import { BaseDownsampling } from './BaseDownsampling'
@Sendable
export class CenterInside {
  getName() {
    return "CenterInside"
  }

  getScaleFactor(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    return Math.min(1, this.getScale(sourceWidth, sourceHeight, requestWidth, requestHeight))
  }

  getSampleSizeRounding(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    //下采样因子
    return 1
  }

  getScale(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    let widthPercentage = requestWidth / sourceWidth
    let heightPercentage = requestHeight / sourceHeight
    return Math.min(widthPercentage, heightPercentage)
  }
}

/*不进行下采样*/
@Sendable
export class DownsampleNone implements BaseDownsampling {
  getName() {
    return "DownsampleNone"
  }

  getScaleFactor(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    //下采样因子
    return 1
  }

  getSampleSizeRounding(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    //下采样因子
    return 1
  }
}

/* 下采样使得图像的组大尺寸在给定的尺寸的1/2之间*/
@Sendable
export class AtMost implements BaseDownsampling {
  getName() {
    return "AtMost"
  }

  getScaleFactor(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    let maxIntegerFactor = Math.ceil(Math.max(sourceHeight / requestHeight, sourceWidth / requestWidth));
    let lesserOrEqualSampleSize = Math.max(1, this.highestOneBit(maxIntegerFactor))
    let greaterOrEqualSampleSize = lesserOrEqualSampleSize << (lesserOrEqualSampleSize < maxIntegerFactor ? 1 : 0)
    return 1 / greaterOrEqualSampleSize
  }

  getSampleSizeRounding(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    return 0
  }

  highestOneBit(i: number): number {
    i |= (i >> 1);
    i |= (i >> 2);
    i |= (i >> 4);
    i |= (i >> 8);
    i |= (i >> 16);
    return i - (i >>> 1);
  }
}

@Sendable
export class Atleast implements BaseDownsampling {
  getName() {
    return "Atleast"
  }

  getScaleFactor(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    let minIntegerFactor = Math.floor(Math.min(sourceHeight / requestHeight, sourceWidth / requestWidth))
    return minIntegerFactor == 0 ? 1 : 1 / this.highestOneBit(minIntegerFactor)
  }

  getSampleSizeRounding(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    //下采样因子
    return 1
  }

  highestOneBit(i: number): number {
    i |= (i >> 1);
    i |= (i >> 2);
    i |= (i >> 4);
    i |= (i >> 8);
    i |= (i >> 16);
    return i - (i >>> 1);
  }
}

@Sendable
export class CenterOutside implements BaseDownsampling {
  getName() {
    return "CenterOutside"
  }

  getScaleFactor(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    let widthPercentage = requestWidth / sourceWidth
    let heightPercentage = requestHeight / sourceHeight
    return Math.max(widthPercentage, heightPercentage)
  }

  getSampleSizeRounding(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    //下采样因子
    return 1
  }
}

@Sendable
export class FitCenter implements BaseDownsampling {
  getName() {
    return "FitCenter"
  }

  getScaleFactor(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    let widthPercentage = requestWidth / sourceWidth
    let heightPercentage = requestHeight / sourceHeight
    return Math.min(widthPercentage, heightPercentage)
  }

  getSampleSizeRounding(sourceWidth: number, sourceHeight: number, requestWidth: number, requestHeight: number): number {
    //下采样因子
    return 1
  }
}

export enum SampleSizeRounding {
  MEMORY,
  QUALITY
}