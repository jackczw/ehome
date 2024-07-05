import { Options } from '@ohos/imageknife';
import { Touch } from '@ohos.multimodalInput.touchEvent';
import { DialogUtil } from '@yunkss/eftool';

@Entry
@Component
export  struct MFMineController {
  @State message: string = '我的';


  build() {
    Stack({alignContent:Alignment.Top}){
      Image(null)
        .backgroundColor(0x5585EB)
        .width('100%')
        .height(271)
        .fillColor(Color.Black)

      Column() {
        Row(){
          Text(this.message)
            .fontSize(20)
            .fontWeight(500)
            .fontColor(Color.White)
            .margin({left:24})

          Row(){
            Image($r('app.media.icon_setting'))
              .objectFit(ImageFit.Contain)
              .height(24)
              .width(24)
              .margin({right:24})
          }.justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .width(72)
          .height(58)
          .onTouch((event:TouchEvent)=>{
            if(event.type == TouchType.Down){
              DialogUtil.showAlertDialog({msg:'点击设置'})
            }
          })


        }.height(58)
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)



      }.width('100%')
      .height('100%')
      .margin({top:20})
    }

    .height('100%')
    .width('100%')
  }
}