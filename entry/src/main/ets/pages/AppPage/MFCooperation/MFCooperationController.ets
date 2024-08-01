import {MFCooperationVc} from './MFCooperationVc'
import {MFCooperationBaiLuVc} from './MFCooperationBaiLuVc'
import {MFCooperationYuGongVc} from './MFCooperationYuGongVc'
import { DialogUtil } from '@yunkss/eftool';

@Entry
@Component
export  struct MFCooperationController {
  @State message: string = 'Hello World';
  @State currentIndex:number = 0;
  @State tabbars:string[] = [
    '协作','白鹭之窗','员工商城'
  ]
  private  scroller: Scroller = new Scroller();

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

      Blank().layoutWeight(1);
      Row(){
        if(this.currentIndex==1){
          Button({buttonStyle:ButtonStyleMode.TEXTUAL}){
            Image($r('app.media.MFBaiLuZhiChuanMore'))
              .width(24)
              .height(24)
          }
          .height(44)
          .width(44)
          .onClick((event:ClickEvent)=>{
            DialogUtil.showDialog({msg:'更多'})
          })
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
        }
      }
    }.width('100%')
  }

  build() {
    Column(){
      this.topbar();

      Tabs({barPosition:BarPosition.Start,index:this.currentIndex}){
        TabContent(){
          MFCooperationVc({message:'协作'});
        }
        // .tabBar(this.tabBuilder('协作',0))

        TabContent(){
          MFCooperationBaiLuVc({message:'白鹭之窗'});
        }
        // .tabBar(this.tabBuilder('管理',1))

        TabContent(){
          MFCooperationYuGongVc({message:'员工管理'})
        }
        // .tabBar(this.tabBuilder('白鹭之窗',2))
      }.vertical(false)
      .divider({strokeWidth:10,color:0xffEDEFF2})
      .barHeight(0)
      .scrollable(true)
      .barMode(BarMode.Fixed)
      .onChange((index:number)=>{
        this.currentIndex = index;
      })
    }.margin({top:20})

  }
}