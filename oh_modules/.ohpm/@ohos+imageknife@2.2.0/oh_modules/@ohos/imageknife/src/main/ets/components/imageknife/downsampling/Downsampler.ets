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
import { RequestOption } from '../RequestOption';
import { FileTypeUtil } from '../utils/FileTypeUtil';
import { CenterOutside, FitCenter, SampleSizeRounding } from './DownsampleStartegy';

let TAG = 'downsampling'
export interface calculateScaleType {
  targetWidth: number,
  targetHeight: number
}


export class Downsampler {
  calculateScaling(
    imageType: ArrayBuffer,
    sourceHeight: number,
    sourceWidth: number,
    request?: RequestOption
  ): calculateScaleType {
    const fileType: string | null = new FileTypeUtil().getFileType(imageType)
    let powerOfTwoWidth: number | null = null;
    let powerOfTwoHeight: number | null = null;
    let targetWidth: number = 0
    let targetHeight: number = 0
    if (request?.size.width && !request?.size.height) {
      targetWidth = this.round((request?.size.height) * sourceWidth / sourceHeight)
    } else if (request?.size.height && !request?.size.width) {
      targetHeight = this.round((request?.size.width) * sourceHeight / sourceWidth)
    } else if (request?.size.height && request?.size.width) {
      targetHeight = request.size.height;
      targetWidth = request?.size.width;
    } else {
      throw new Error("Cannot found width or height ");
    }
    if (sourceWidth <= 0 || sourceHeight <= 0){
      throw new Error("Cannot found width or height");
    };
    let orientedSourceWidth = sourceWidth;
    let orientedSourceHeight = sourceHeight;
    if (this.isRotationRequired(90)) {
      orientedSourceWidth = sourceHeight;
      orientedSourceHeight = sourceWidth;
    }
    /*安卓的模式*/
    let exactScaleFactor: number = new FitCenter()
      .getScaleFactor(orientedSourceWidth, orientedSourceHeight, targetWidth, targetHeight)
    if (exactScaleFactor <= 0) {
      throw new Error("Cannot	round	with exactScaleFactor");
    }
    /*安卓的模式*/
    let rounding: SampleSizeRounding = new FitCenter()
      .getSampleSizeRounding(orientedSourceWidth, orientedSourceHeight, targetWidth, targetHeight)
    if (rounding == null) {
      throw new Error("Cannot round with null rounding");
    }
    let outWidth: number = this.round(exactScaleFactor * orientedSourceWidth);
    let outHeight: number = this.round(exactScaleFactor * orientedSourceHeight);
    let widthScaleFactor = Math.floor(orientedSourceWidth / outWidth);
    let heightScaleFactor = Math.floor(orientedSourceHeight / outHeight);
    let scaleFactor = rounding == SampleSizeRounding.MEMORY ?
    Math.max(widthScaleFactor, heightScaleFactor) :
    Math.min(widthScaleFactor, heightScaleFactor)
    // 将整型的缩放因子转换为2的次幂采样大小
    let powerOfTwoSampleSize: number = 0;
    powerOfTwoSampleSize = Math.max(1, this.highestOneBit(scaleFactor))
    if (rounding == SampleSizeRounding.MEMORY && powerOfTwoSampleSize < (1 / exactScaleFactor)) {
      powerOfTwoSampleSize = powerOfTwoSampleSize << 1;
    }
    // 基于上一步得出的采样大小,根据不同的图片类型，计算采样后的图片尺寸
    if (fileType == "jpeg") {
      let nativeScaling = Math.min(powerOfTwoSampleSize, 8);
      powerOfTwoWidth = Math.ceil(orientedSourceWidth / nativeScaling);
      powerOfTwoHeight = Math.ceil(orientedSourceHeight / nativeScaling);
      let secondaryScaling = Math.floor(powerOfTwoSampleSize / 8);
      if (secondaryScaling > 0) {
        powerOfTwoWidth = powerOfTwoWidth / secondaryScaling;
        powerOfTwoHeight = powerOfTwoHeight / secondaryScaling;
      }
    } else if (fileType == "png") {
      powerOfTwoWidth = Math.floor(orientedSourceWidth / powerOfTwoSampleSize);
      powerOfTwoHeight = Math.floor(orientedSourceHeight / powerOfTwoSampleSize);
    } else if (fileType == "webp") {
      powerOfTwoWidth = Math.round(orientedSourceWidth / powerOfTwoSampleSize);
      powerOfTwoHeight = Math.round(orientedSourceHeight / powerOfTwoSampleSize);
    } else {
      powerOfTwoWidth = orientedSourceWidth / powerOfTwoSampleSize;
      powerOfTwoHeight = orientedSourceHeight / powerOfTwoSampleSize;
    }
    let a: calculateScaleType = { "targetWidth": powerOfTwoWidth, "targetHeight": powerOfTwoHeight }
    return a
  }

  highestOneBit(i: number): number {
    i |= (i >> 1);
    i |= (i >> 2);
    i |= (i >> 4);
    i |= (i >> 8);
    i |= (i >> 16);
    return i - (i >>> 1);
  }

  round(value: number): number {
    return Math.floor(value + 0.5);
  }

  isRotationRequired(degreesToRotate: number): boolean {
    return degreesToRotate == 90 || degreesToRotate == 270;
  }

  getDensityMultiplier(adjustedScaleFactor: number): number {
    return Math.round(Number.MAX_VALUE * (adjustedScaleFactor <= 1 ? adjustedScaleFactor : 1 / adjustedScaleFactor));
  }

  adjustTargetDensityForError(adjustedScaleFactor: number): number {
    let densityMultiplier = this.getDensityMultiplier(adjustedScaleFactor);
    let targetDensity = this.round(densityMultiplier * adjustedScaleFactor);
    let scaleFactorWithError = targetDensity / densityMultiplier;
    let difference = adjustedScaleFactor / scaleFactorWithError;
    return this.round(difference * targetDensity);
  }
}