import {MFCooperationVc} from './MFCooperationVc'
import {MFCooperationBaiLuVc} from './MFCooperationBaiLuVc'
import {MFCooperationYuGongVc} from './MFCooperationYuGongVc'
import { DialogUtil, ToastUtil } from '@yunkss/eftool';



///自定义弹窗
@CustomDialog
struct MFBaiLuZhiChuanCustomView {
  controller?:CustomDialogController
  build() {
      Column(){
        Row(){
          Text('设置栏目')
            .width('100%')
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .fontWeight(500)
            .fontColor(0xff111A34)
          Button({type:ButtonType.Normal,buttonStyle:ButtonStyleMode.TEXTUAL}){
            Image($r('app.media.MFBaiLuSheZhiLanMuClose'))
              .height(24)
              .width(24)
          }.onClick((event: ClickEvent) => {
            ToastUtil.showToast('close');
            if(this.controller != undefined){
              this.controller.close();
            }
          })
            .width(64)
            .height(64)
            .position({right:0,top:0})



        }.height(64)
        .alignItems(VerticalAlign.Center)
      }
      .margin({ bottom: 10 })
  }
}



@Entry
@Component
export  struct MFCooperationController {
  @State message: string = 'Hello World';
  @State currentIndex:number = 0;
  @State tabbars:string[] = [
    '协作','白鹭之窗','员工商城'
  ]
  private  scroller: Scroller = new Scroller();
  mfDailogView:CustomDialogController = new CustomDialogController({
    builder:MFBaiLuZhiChuanCustomView(),
    autoCancel:true,
    height:371,
    width:'100%',
    alignment:DialogAlignment.Bottom,
    cornerRadius:{topLeft:8,topRight:8,bottomLeft:0,bottomRight:0},
    // openAnimation:{
    //   duration:1200,
    //   curve:Curve.EaseInOut,
    //   delay:500,
    //   playMode:PlayMode.Alternate
    // }
  })

  @Builder tabBuilder(title: string, targetIndex: number) {
    Column() {

      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#FF3390FF' : '#FF848484')
        .fontSize(10)
        .margin({left:6,right:6})
    }
    // .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  @Builder topbar(){
    Stack({alignContent:Alignment.TopStart}){
      Row(){
        Scroll(this.scroller){
          Row({space:0}){
            ForEach(this.tabbars,(item:string,index:number)=>{
              Button({buttonStyle:ButtonStyleMode.TEXTUAL,type:ButtonType.Normal}){
                Text(item)
                  .fontColor(this.currentIndex == index?0xff000000:0xff858B9C)
                  .fontWeight(this.currentIndex == index?500:400)
                  .fontSize(16)
              }.margin({left:6,right:6})
              .height('100%')
              .onClick((event:ClickEvent)=>{
                this.currentIndex = index;
              })
            })
          }
          .height(58)
          .padding({left:6})
        }.scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .margin({right:this.currentIndex==1?88:0})
      }.width('100%')


      if(this.currentIndex==1){
        Button({buttonStyle:ButtonStyleMode.TEXTUAL}){
          Image($r('app.media.MFBaiLuZhiChuanMore'))
            .width(24)
            .height(24)
        }
        .height(44)
        .width(44)
        .onClick((event:ClickEvent)=>{
          if (this.mfDailogView != null) {
            this.mfDailogView.open()
          }
          // DialogUtil.showDialog({msg:'更多'})

        })
        .position({top:7,right:44})

        Button({buttonStyle:ButtonStyleMode.TEXTUAL}){
          Image($r('app.media.MFBaiLuZhiChuanSearch'))
            .width(24)
            .height(24)
        }
        .height(44)
        .width(44)
        .onClick((event:ClickEvent)=>{
          DialogUtil.showDialog({msg:'搜索'})
        })
        .position({top:7,right:0})
      }
    }

  }



  build() {
    Column(){
      this.topbar();

      Tabs({barPosition:BarPosition.Start,index:this.currentIndex}){
        TabContent(){
          MFCooperationVc({message:'协作'});
        }.margin({bottom:58})
        // .tabBar(this.tabBuilder('协作',0))

        TabContent(){
          MFCooperationBaiLuVc({message:'白鹭之窗'});
        }.margin({bottom:58})
        // .tabBar(this.tabBuilder('管理',1))

        TabContent(){
          MFCooperationYuGongVc({message:'员工管理'})
        }.margin({bottom:58})
        // .tabBar(this.tabBuilder('白鹭之窗',2))
      }.vertical(false)
      .divider({strokeWidth:10,color:0xffEDEFF2})
      .barHeight(0)
      .scrollable(true)
      .barMode(BarMode.Fixed)
      .onChange((index:number)=>{
        this.currentIndex = index;
      })
      .margin({bottom:0})
    }.margin({top:20})

  }
}