/*
 * Copyright (C) 2021 Huawei Device Co., Ltd.
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
import { AsyncTransform } from '../transform/AsyncTransform'
import image from '@ohos.multimedia.image'
import { Size } from '../../imageknife/RequestOption'
import { BusinessError } from '@ohos.base'
import { Constants } from '../constants/Constants'
import { BaseTransform } from './BaseTransform'
import { BlurTransformation } from './BlurTransformation'
import { BrightnessFilterTransformation } from './BrightnessFilterTransformation'
import { RotateImageTransformation } from './RotateImageTransformation'
import { GrayscaleTransformation } from './GrayscaleTransformation'
import { ContrastFilterTransformation } from './ContrastFilterTransformation'
import { CropCircleTransformation } from './CropCircleTransformation'
import { CropCircleWithBorderTransformation, rgbColor } from './CropCircleWithBorderTransformation'
import { CropSquareTransformation } from './CropSquareTransformation'
import { InvertFilterTransformation } from './InvertFilterTransformation'
import { KuwaharaFilterTransform } from './KuwaharaFilterTransform'
import { MaskTransformation } from './MaskTransformation'
import { PixelationFilterTransformation } from './PixelationFilterTransformation'
import { RoundCorner, RoundedCornersTransformation } from './RoundedCornersTransformation'
import { SketchFilterTransformation } from './SketchFilterTransformation'
import { SepiaFilterTransformation } from './SepiaFilterTransformation'
import { SwirlFilterTransformation } from './SwirlFilterTransformation'
import { ToonFilterTransform } from './ToonFilterTransform'
import { VignetteFilterTransform } from './VignetteFilterTransform'
import { CenterCrop } from './pixelmap/CenterCrop'
import { CenterInside } from './pixelmap/CenterInside'
import { FitCenter } from './pixelmap/FitCenter'
import { CropTransformation, CropType } from './CropTransformation'
import { collections } from '@kit.ArkTS'

export class TransformUtils {
  static centerCrop(buf: ArrayBuffer, outWidth: number, outHeihgt: number,
                    callback?: AsyncTransform<Promise<PixelMap>>) {
    let imageSource: image.ImageSource = image.createImageSource(buf);
    imageSource.getImageInfo()
      .then((p) => {
        let sw: number = 0;
        let sh: number = 0;
        let scale: number = 1;
        let pw: number = p.size.width;
        let ph: number = p.size.height;
        if (pw == outWidth && ph == outHeihgt) {
          sw = outWidth;
          sh = outHeihgt;
        } else {
          if (pw * outHeihgt > outWidth * ph) {
            scale = outHeihgt / ph;
          } else {
            scale = outWidth / pw;
          }
          sw = pw * scale;
          sh = ph * scale;
        }
        let options: image.DecodingOptions = {
          editable: true,
          rotate: 0,
          desiredRegion: { size: { width: sw, height: sh },
            x: pw / 2 - sw / 2,
            y: ph / 2 - sh / 2,
          },
        }
        if (callback) {
          callback.asyncTransform('', imageSource.createPixelMap(options));
        }
      })
      .catch((error: BusinessError) => {
        callback?.asyncTransform(error, null);
      })

  }

  static rotateImage(buf: ArrayBuffer, degreesToRotate: number): Promise<PixelMap> {
    let imageSource: image.ImageSource = image.createImageSource(buf);
    let options: image.DecodingOptions = {
      editable: true,
      rotate: degreesToRotate
    }
    let promise: Promise<PixelMap> = imageSource.createPixelMap(options);
    imageSource.release()
    return promise;
  }

  static centerInside(buf: ArrayBuffer, outWidth: number, outHeihgt: number,
                      callback?: AsyncTransform<PixelMap>) {
    let imageSource: image.ImageSource = image.createImageSource(buf);
    imageSource.getImageInfo()
      .then((p: image.ImageInfo) => {
        let pw = p.size.width;
        let ph = p.size.height;
        if (pw <= outWidth && ph <= outHeihgt) {
          imageSource.createPixelMap()
            .then(p => {
              callback?.asyncTransform('', p);
              imageSource.release()
            }).catch((e: BusinessError) => {
            callback?.asyncTransform(Constants.PROJECT_TAG + ';CenterInside error:' + e, null);
            imageSource.release()
          })
        } else {
          TransformUtils.fitCenter(buf, outWidth, outHeihgt, callback);
        }
      })
      .catch((error: BusinessError) => {
        callback?.asyncTransform(error, null);
      })

  }

  static fitCenter(buf: ArrayBuffer, outWidth: number, outHeihgt: number
                   , callback?: AsyncTransform<PixelMap>) {
    let imageSource: image.ImageSource = image.createImageSource(buf);
    imageSource.getImageInfo()
      .then((p: image.ImageInfo) => {
        let pw: number = p.size.width;
        let ph: number = p.size.height;
        let widthPercentage: number = outWidth / pw;
        let heightPercentage: number = outHeihgt / ph;
        let minPercentage: number = Math.min(widthPercentage, heightPercentage);

        let targetWidth: number = Math.round(minPercentage * pw);
        let targetHeight: number = Math.round(minPercentage * ph);

        if (pw == targetWidth && ph == targetHeight) {
          targetWidth = pw;
          targetHeight = ph;
        } else {
          targetWidth = minPercentage * pw;
          targetHeight = minPercentage * ph;
        }
        let options: image.DecodingOptions = {
          editable: true,
          rotate: 0,
          desiredSize: { width: targetWidth, height: targetHeight }
        }
        if (callback != undefined) {
          imageSource.createPixelMap(options)
            .then(p => {
              callback?.asyncTransform('', p);
              imageSource.release();
            })
            .catch((e: BusinessError) => {
              callback?.asyncTransform(Constants.PROJECT_TAG + ';FitCenter error:' + e, null);
              imageSource.release();
            })
        }
      })
      .catch((e: BusinessError) => {
        if (callback) {
          callback.asyncTransform(e, null);
        }
      })
  }

  static getPixelMapSize(imageSource: image.ImageSource, func: AsyncTransform<Size>) {
    if (!imageSource) {
      return;
    }
    imageSource.getImageInfo((err: BusinessError, value: image.ImageInfo) => {
      if (err) {
        func?.asyncTransform(err, null)
        return;
      }
      let pWidth: number = value.size.width;
      let pHeight: number = value.size.height;
      func?.asyncTransform('', { width: pWidth, height: pHeight });
    })
  }

  static addTransformations (data: collections.Array<collections.Array<string>>) {
   let  transformations: Array<BaseTransform<PixelMap>> = new Array();
    data.forEach((value:collections.Array<string> ) => {
      let className = value.shift();
      let params = value.shift() as string;
      switch (className) {
        case "BlurTransformation":
          let paramList: number [] = JSON.parse(params);
          transformations.push(new BlurTransformation(paramList[0], paramList[1]));
          break;
        case "BrightnessFilterTransformation":
          let paramList1: number [] = JSON.parse(params);
          transformations.push(new BrightnessFilterTransformation(paramList1[0]));
          break;
        case "RotateImageTransformation":
          let paramList2: number [] = JSON.parse(params);
          transformations.push(new RotateImageTransformation(paramList2[0]));
          break;
        case "GrayscaleTransformation":
          transformations.push(new GrayscaleTransformation());
          break;
        case "BlurTransformation":
          let paramList3: number [] = JSON.parse(params);
          transformations.push(new BlurTransformation(paramList3[0]));
          break;
        case "ContrastFilterTransformation":
          let paramList4: number [] = JSON.parse(params);
          transformations.push(new ContrastFilterTransformation(paramList4[0]));
          break;
        case "CropCircleTransformation":
          transformations.push(new CropCircleTransformation());
          break;
        case "CropCircleWithBorderTransformation":
          let paramList5: (number | rgbColor) [] = JSON.parse(params);
          transformations.push(new CropCircleWithBorderTransformation(paramList5[0] as number, paramList5[1] as rgbColor));
          break;
        case "CropSquareTransformation":
          transformations.push(new CropSquareTransformation());
          break;
        case "InvertFilterTransformation":
          transformations.push(new InvertFilterTransformation());
          break;
        case "KuwaharaFilterTransform":
          let paramList7: number [] = JSON.parse(params);
          transformations.push(new KuwaharaFilterTransform(paramList7[0] as number));
          break;
        case "MaskTransformation":
          let paramList8: Resource [] = JSON.parse(params);
          transformations.push(new MaskTransformation(paramList8[0] as Resource));
          break;
        case "PixelationFilterTransformation":
          let paramList9: number [] = JSON.parse(params);
          transformations.push(new PixelationFilterTransformation(paramList9[0] as number));
          break;
        case "RoundedCornersTransformation":
          let paramList10: RoundCorner [] = JSON.parse(params);
          transformations.push(new RoundedCornersTransformation(paramList10[0] as RoundCorner));
          break;
        case "SepiaFilterTransformation":
          transformations.push(new SepiaFilterTransformation());
          break;
        case "SketchFilterTransformation":
          transformations.push(new SketchFilterTransformation());
          break;
        case "SwirlFilterTransformation":
          let paramList11: (number | Array<number>) [] = JSON.parse(params);
          transformations.push(new SwirlFilterTransformation(paramList11[0] as number, paramList11[1] as number, paramList11[2] as Array<number>));
          break;
        case "ToonFilterTransform":
          let paramList14: number [] = JSON.parse(params);
          transformations.push(new ToonFilterTransform(paramList14[0], paramList14[1]));
          break;
        case "VignetteFilterTransform":
          let paramList12: Array<number> [] = JSON.parse(params);
          transformations.push(new VignetteFilterTransform(paramList12[0], paramList12[1], paramList12[2]));
          break;
        case "CenterCrop":
          transformations.push(new CenterCrop());
          break;
        case "CenterInside":
          transformations.push(new CenterInside());
          break;
        case "FitCenter":
          transformations.push(new FitCenter());
          break;
        case "CropTransformation":
          let paramList13: (number | CropType) [] = JSON.parse(params);
          transformations.push(new CropTransformation(paramList13[0] as number, paramList13[1] as number, paramList13[2] as CropType));
          break;
        default:
          break
      }
    });
   return transformations;
  }
}