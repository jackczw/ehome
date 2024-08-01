import { display } from '@kit.ArkUI';
import { DialogUtil, ToastUtil } from '@yunkss/eftool';


class MFOtherSystemEHomeProduceModel{
  productName:string = '';
  productPic:string = '';
  productPrice:string = '';
  marketPrice:string = '';
  productLink:string = '';
  index:number = 0;

  constructor(productName:string,productPic:string,productPrice:string,marketPrice:string,productLink:string,index:number) {
      this.productName = productName;
      this.productPic = productPic;
      this.productPrice = productPrice;
      this.marketPrice = marketPrice;
      this.productLink = productLink;
      this.index = index;
  }
}

@Entry
@Component
export struct MFCooperationYuGongVc {
  @State message: string = 'Hello World';
  @State modelList:string[] = ['职工云食堂','厦航内购平台'];
  @State screenWidth:number = 0
  @State yunshiList:MFOtherSystemEHomeProduceModel[] = [
    new MFOtherSystemEHomeProduceModel('商品1','','191.1','200','',0),
    new MFOtherSystemEHomeProduceModel('商品2','','33','50','',1),
    new MFOtherSystemEHomeProduceModel('商品3','','200','453','',2),
  ]
  onPageShow(): void {
    this.screenWidth = display.getDefaultDisplaySync().width;
    if(this.screenWidth<10){
      this.screenWidth = 375;
    }
  }



  build() {
    Scroll(){
      Column(){
        ForEach(this.modelList,(item:string,index:number)=>{
          this.getModelF(item,index);
        })
      }.backgroundColor(0xf2f2f2)

    }.scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
  }

  @Builder getModelF(item:string,index:number){
    ///云食堂
    Stack({alignContent:Alignment.TopStart}){
      //背景
      Image($r('app.media.login_eyes_close'))
        .width(this.screenWidth)
        .height(this.screenWidth/375.0*207.0)
        .backgroundColor(Color.Red)

      //内容
      Stack({alignContent:Alignment.TopStart}){
        Text().width('100%')
        Text()
          .width(127)
          .height(8)
          .linearGradient({colors:index==0?[[0x0063E657,0],[0xffffffff,0.98]]:[[0x0085DCFF,0],[0xff5BA5FF,0.98]],direction:GradientDirection.Right})
          .border({radius:4})
          .margin({left:12,top:22})
        Text(item)
          .fontSize(14)
          .fontWeight(500)
          .fontColor(0xd9000000)
          .margin({left:16,top:11})



        Image(index==0?$r('app.media.MFYuanGongShangChengGreen'):$r('app.media.MFYuanGongShangChengBlue'))
          .width(105)
          .height(49)
          .position({right:0,top:0})
          .onTouch((event:TouchEvent)=>{
            if(event.type == TouchType.Down){
              DialogUtil.showDialog({msg:'购买更多'})
            }
          })

        Text('购买更多')
          .fontSize(13)
          .fontWeight(500)
          .fontColor(0xffffff)
          .position({right:18,top:10})
          .enabled(false)
        if(index==0){
          //余额
          Row(){
            Row({}){
              Row(){
                Text('总余额')
                  .fontSize(11)
                  .fontWeight(500)
                  .fontColor(0xff111A34)

                Text('1429.5')
                  .fontSize(15)
                  .fontWeight(500)
                  .fontColor(0xd9000000)
                  .margin({left:3})
              }
              Row(){
                Text().width(4).height(4).border({radius:2}).backgroundColor(0xffFF453A)
                Text('食堂用餐')
                  .fontSize(11)
                  .fontWeight(400)
                  .fontColor(0xff4C4C4C)
                  .margin({left:4})

                Text('1268.5')
                  .fontSize(15)
                  .fontWeight(500)
                  .fontColor(0xff111A34)
                  .margin({left:2})
              }
              Row(){
                Text().width(4).height(4).border({radius:2}).backgroundColor(0xff3390FF)
                Text('个人充值')
                  .fontSize(11)
                  .fontWeight(400)
                  .fontColor(0xff4C4C4C)
                  .margin({left:4})

                Text('161.1')
                  .fontSize(15)
                  .fontWeight(500)
                  .fontColor(0xff111A34)
                  .margin({left:2})
              }
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.SpaceAround)
            .alignItems(VerticalAlign.Center)
            .backgroundColor(0xffF0FFF0)
            .border({
              radius:16
            })
          }.width('100%')
          .margin({top:49})
          .padding({left:12,right:12})
          .height(42)
        }


        //商品列表
        Row(){
          ForEach(this.yunshiList,(item:MFOtherSystemEHomeProduceModel,index:number)=>{
            Column(){
              Image($r('app.media.login_eyes_close'))
                .width(101)
                .height(104)

              Text(item.productName)
                .fontSize(9.6)
                .fontWeight(400)
                .fontColor(0x80000000)
                .maxLines(1)
                .margin({left:4,right:4,top:3})

              Row(){
                Text('￥')
                  .fontSize(9)
                  .fontWeight(700)
                  .fontColor(0xffFF9041)
                Text(item.productPrice)
                  .fontSize(15)
                  .fontWeight(700)
                  .fontColor(0xffFF9041)
                  .margin({bottom:-2})

                Text('￥'+item.marketPrice)
                  .fontSize(9)
                  .fontWeight(700)
                  .fontColor(0xffA5A5A5)
                  .decoration({type:TextDecorationType.LineThrough,color:0xffA5A5A5,})

              }.margin({left:3,top:3,bottom:6.8})
              .alignItems(VerticalAlign.Bottom)

            }.width(101)
            .height(145)
            .alignItems(HorizontalAlign.Start)
            .border({
              radius:16,
              color:0xffF5F5F5,
              style:BorderStyle.Solid,
              width:1
            })
          })
        }.justifyContent(FlexAlign.SpaceAround)
        .position({top:index==0?107:57})
        .padding({left:8,right:8})
        .width('100%')
        .height(145)


      }.margin({
        top:161,
        left:8,
        right:8
      })
      .border({
        radius:16
      })
      .height(index==0?268:218)
      .linearGradient({colors:[[0xffD8FFF0,0],[0xffFFFFFF,0.13],[0xffFFFFFF,1]],direction:GradientDirection.Bottom})

    }.width('100%')
    .margin({bottom:8})
  }
}