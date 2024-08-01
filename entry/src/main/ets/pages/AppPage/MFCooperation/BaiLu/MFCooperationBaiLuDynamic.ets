import { MFCooperationBaiLuDynamicSubVc } from './MFCooperationBaiLuDynamicSubVc';

@Entry
@Component
export struct MFCooperationBaiLuDynamic {
  @State tabbars:string[] = [
    '推广','IT','安全','人力',
  ]
  @State message: string = 'Hello World';

  @State currentIndex:number = 0;

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
    Scroll(this.scroller){
      Row({space:0}){
        ForEach(this.tabbars,(item:string,index:number)=>{
          Button({buttonStyle:ButtonStyleMode.TEXTUAL,type:ButtonType.Normal}){
            Text(item)
              .fontColor(this.currentIndex == index?0xffFFFFFF:0xff000000)
              .fontWeight(this.currentIndex == index?500:400)
              .fontSize(12)
              .margin({left:18,right:18})
          }
          .backgroundColor(this.currentIndex == index?0x1A3390FF:0xffF7F8FA)
          .linearGradient({colors:this.currentIndex == index?[[0x7ECCFF,0.19],[0x567CFF,0.76]]:[],direction:GradientDirection.Right,})
          .height(26)
          .border({
            radius:5
          })
          .onClick((event:ClickEvent)=>{
            this.currentIndex = index;
          })
        })
        // Blank().layoutWeight(1)
      }
      .backgroundColor(0xffF7F8FA)
      .height(30)
      .margin({left:20,right:20})
      .border({
        radius:6
      })
    }.scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
  }

  build() {
    Column(){
      this.topbar();

      Tabs({barPosition:BarPosition.Start,index:this.currentIndex}){
        ForEach(this.tabbars,(item:string,num:number)=>{
          TabContent(){
            MFCooperationBaiLuDynamicSubVc({message:item});
            // MFCooperationVc({message:'协作'});
          }
        })
      }.vertical(false)
      .barHeight(0)
      .scrollable(true)
      .barMode(BarMode.Fixed)
      .onChange((index:number)=>{
        this.currentIndex = index;
        this.scroller.scrollTo({xOffset:'200',yOffset:'0'});
      })
    }.justifyContent(FlexAlign.Start)

  }
}