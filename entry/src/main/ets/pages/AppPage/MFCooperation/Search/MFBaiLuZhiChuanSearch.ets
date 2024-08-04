@Entry
@Component
export  struct MFBaiLuZhiChuanSearch {
  @State message: string = '白鹭搜索';
  @State history:string[] = ['塑料袋副经理','水电费','水电','不扣分点','代付款代付款代付款','塑料袋副经经经经经经理塑料袋...','塑料袋副经理']

  textControler:TextInputController = new TextInputController();
  build() {
    Column(){
      Row(){
        Row(){

            TextInput({placeholder:'搜索白鹭之窗',controller:this.textControler})
              .backgroundColor(0xffF6F6F6)
              .height(36)
              .margin({left:26})
              .onFocus(()=>{

              })
              .onChange((value:string)=>{

              })

          Image($r('app.media.MFBaiLuSearchSearchTextImage'))
            .width(20)
            .height(20)
            .position({top:8,left:12})
        }.backgroundColor(0xffF6F6F6)
        .height(36)
        .border({
          radius:18
        })
        .margin({left:24,right:64})

        Button({buttonStyle:ButtonStyleMode.TEXTUAL,type:ButtonType.Normal}){
          Text('取消')
            .fontSize(16)
            .fontWeight(400)
            .fontColor(0xd9000000)
            .margin({left:-8})
        }.width(64)
        .height(36)
        .position({top:0,right:0})
      }


      Column(){
        Row(){
          Text('历史记录')
            .fontSize(14)
            .fontWeight(500)
            .fontColor(0xff111A34)
            .margin({left:24})

          Image($r('app.media.MFBaiLuSearchDeleteBt'))
            .width(16)
            .height(16)
            .position({right:24,top:3})

        }.width('100%')

        Flex({wrap:FlexWrap.Wrap}){
          ForEach(this.history,(item:string,index:number)=>{
            Button({type:ButtonType.Normal,buttonStyle:ButtonStyleMode.TEXTUAL}){
              Text(item)
                .fontSize(14)
                .fontWeight(400)
                .fontColor(0xff111A34)
                .padding({left:12,right:12})
              // .height(24)
              // .maxLines(1)
            }.height(36)
            .margin({right:16,bottom:16})
            .border({
              radius:18,
              width:1,
              color:0xffEAEAEA
            })
            .onClick((event:ClickEvent)=>{


            })
          })
        }
        .padding({top:20,left:24,right:24})
        .width('100%')

      }.margin({top:39})


    }.margin({top:20})
  }
}