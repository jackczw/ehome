import { LengthMetrics } from '@kit.ArkUI'
import { media } from '@kit.MediaKit'

@Entry
@Component
struct LoginPage {
  @State value: number = 0
  accoutControler:TextInputController = new TextInputController();
  password:TextInputController = new TextInputController();
  build() {
    Column() {
      Row(){
        Text('欢迎使用厦航e家')
          .fontColor(0xD9000000)
          .fontSize(24)
          .fontWeight(600)
          .layoutWeight(1)
      }.margin({top:50,left:24})

      Row() {
        Image($r("app.media.startIcon"))
          .width(20)
          .height(20)
        TextInput({
          placeholder: "请输入您的账号",
          controller:this.accoutControler
        }).backgroundColor(Color.White)
          .placeholderColor(0x33000000)
          .fontColor(0xD9000000)
          .fontSize(16)
          .layoutWeight(1)
          .onChange((value:string)=>{
            console.log(value);
          })
          .onSubmit((keyType:EnterKeyType,event:SubmitEvent)=>{
            console.info(EnterKeyType+'输入法回车键的类型值')
          })
      }.height(66)
      // .backgroundColor(Color.Red)
      .margin({ top: 27, left: 24, right: 24 })
      .padding({ top: 20 })
      .border({
        width: {
          bottom: LengthMetrics.vp(1)
        },
        color: {
          bottom: 0x14000000
        },
        style: {
          bottom: BorderStyle.Solid
        }
      })


      Row() {
        Image($r("app.media.startIcon"))
          .width(20)
          .height(20)
        TextInput({
          placeholder: "请输入您的密码",
          controller:this.password
        }).type(InputType.Password)
          .backgroundColor(Color.White)
          .placeholderColor(0x33000000)
          .fontColor(0xD9000000)
          .fontSize(16)
          .layoutWeight(1)
          .onChange((value:string)=>{
            console.log(value);
          })
          .onSubmit((keyType:EnterKeyType,event:SubmitEvent)=>{
            console.info(EnterKeyType+'输入法回车键的类型值')
          })

      }
      .padding({
        top: 20
      })
      .height(66)
      // .backgroundColor(Color.Red)
      .margin({ top: 0, left: 24, right: 24 })
      .border({
        width: {
          bottom: LengthMetrics.vp(1)
        },
        color: {
          bottom: 0x14000000
        },
        style: {
          bottom: BorderStyle.Solid
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}