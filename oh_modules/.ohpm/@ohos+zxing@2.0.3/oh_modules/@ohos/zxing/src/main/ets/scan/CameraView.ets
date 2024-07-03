/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { CameraConstants, CameraPosition, CaptureMode } from './constants/CameraConstants';
import CameraService from './model/CameraService';
import router from '@ohos.router';
import CameraPreview from './CameraPreview';
import CameraLifecycle from './model/CameraLifecycle';
import camera from '@ohos.multimedia.camera';
import MainModel from './viewmodel/CustomCameraModel';
import DimensionUtil from './utils/DimensionUtil';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import prompt from '@ohos.promptAction'
import { CameraCodeScanConst } from './constants/CameraCodeScanConst';


@Component
export default struct CameraView {
  private mainModel: MainModel | null = null;
  @State isQRCodeScanStopped: boolean = false
  @Provide(CameraConstants.CAPTURE_MODE_KEY) curCaptureMode: CaptureMode = CaptureMode.PREVIEW_FRAME;
  @Provide(CameraConstants.RATION_CHANGE_KEY) isRatioChanging: boolean = false;
  @Provide(CameraConstants.RATION_KEY) curRatio: number = CameraConstants.RATIO_DEFAULT_VALUE;
  @Provide(CameraConstants.RATION_ENABLE) isRatioEnable: boolean = false;

  aboutToAppear() {
    // DimensionUtil初始化，得到GlobalContext设置的值
    DimensionUtil.getInstance().init()
    let that = this;
    that.mainModel = MainModel.getInstant();
    let listenerData: CameraLifecycle = {
      onCameraConfigure(mode: CaptureMode, position: CameraPosition, resolution: camera.Size, resolutions: camera.Profile[]) {
        that.isRatioEnable = (position === CameraPosition.BACK);
        that.curCaptureMode = mode;
        (that.mainModel as MainModel).hideRationMenu(0, () => {
          that.isRatioChanging = false;
        });
      },
      onRatioChanged(outputRation: number, outputRationRage: number[]) {
        that.curRatio = outputRation;
      },
    }
    CameraService.getInstance().addLifecycleListener(listenerData);
  }

  aboutToDisappear() {
    console.log('cwq aboutToDisappear is called')
    CameraService.getInstance().destroy()
  }

  @Builder
  TopButton() {
    Row() {
      // 返回按钮
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Image($r('app.media.scan_back'))
          .width(DimensionUtil.getVp($r('app.float.camera_close_size')) / 2)
          .height(DimensionUtil.getVp($r('app.float.camera_close_size')) / 2).objectFit(ImageFit.Fill)
      }
      .backgroundColor('#00000000')
      .width(DimensionUtil.getVp($r('app.float.camera_close_size')))
      .height(DimensionUtil.getVp($r('app.float.camera_close_size')))
      .onClick(() => {
        router.back()
      })

      // 相册图片
      Button({ type: ButtonType.Normal, stateEffect: true }) {
        Image($r('app.media.scan_photo'))
          .width(DimensionUtil.getVp($r('app.float.camera_close_size')) / 2)
          .height(DimensionUtil.getVp($r('app.float.camera_close_size')) / 2).objectFit(ImageFit.Fill)
      }
      .backgroundColor('#00000000')
      .width(DimensionUtil.getVp($r('app.float.camera_close_size')))
      .height(DimensionUtil.getVp($r('app.float.camera_close_size')))
      .onClick(async () => {
        this.isQRCodeScanStopped = true
        let context = AppStorage.get('context') as common.UIAbilityContext
        // 打开手机相册
        await context.startAbilityForResult({
          parameters: { uri: 'singleselect' },
          bundleName: 'com.huawei.hmos.photos',
          abilityName: 'com.huawei.hmos.photos.MainAbility',
        }).then(data => {
          // 获取want数据
          if (data.want != undefined) {
            let want: Want = data['want'];
            if (want) {
              // param代表want参数中的paramters
              let param = want['parameters'] as Record<string, string[] | Object>;
              if (param) {
                // 被选中的图片路径数组
                let selectedUri = param['select-item-list'] as Array<string>;
                setTimeout(async () => {
                  let showResult = await CameraService.getInstance().parseImageQRCode(selectedUri[0]);
                  if (showResult.isSucess) {
                    let decodeText = showResult.decodeResult
                    AppStorage.setOrCreate(CameraCodeScanConst.QR_CODE_PARSE_RESULT, decodeText)
                  } else {
                    prompt.showToast({
                      message: $r('app.string.scanCodeNotRecognized')
                    })
                  }
                }, 50)
              }
            }
          }
        })
      })
    }
    .width("100%")
    .margin({ top: 24 })
    .padding({ left: 24, right: 24 })
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      CameraPreview()
      this.TopButton()
    }
    .backgroundColor(Color.Black)
    .height("100%")
  }
}