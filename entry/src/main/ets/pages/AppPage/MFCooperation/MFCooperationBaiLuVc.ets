

@Entry
@Component
export struct MFCooperationBaiLuVc {
  @State tabbars:string[] = [
    '推荐','公司新闻','公司公告'
  ]
  @State message: string = 'Hello World';

  @State currentIndex:number = 0;

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
    Row({space:12}){
      ForEach(this.tabbars,(item:string,index:number)=>{
        Button({buttonStyle:ButtonStyleMode.TEXTUAL,type:ButtonType.Normal}){
          Text(item)
            .fontColor(this.currentIndex == index?0xff3390FF:0xff41485D)
            .fontWeight(400)
            .fontSize(12)
            .margin({left:12,right:12})
        }
        .backgroundColor(this.currentIndex == index?0x1A3390FF:0xffF7F8FA)

        .height(28)
        .border({
          radius:14
        })
        .onClick((event:ClickEvent)=>{
          this.currentIndex = index;
        })
      })
    }
    .width('100%')
    .height(52)
    .padding({left:20})

  }

  build() {
    Column(){
      this.topbar();

      Tabs({barPosition:BarPosition.Start,index:this.currentIndex}){
        TabContent(){
          Text('1')
          // MFCooperationVc({message:'协作'});
        }
        // .tabBar(this.tabBuilder('协作',0))

        TabContent(){
          Text('2')
          // MFCooperationBaiLuVc({message:'管理'});
        }
        // .tabBar(this.tabBuilder('管理',1))

        TabContent(){
          Text('3')
          // MFCooperationYuGongVc({message:'白鹭之窗'})
        }
        // .tabBar(this.tabBuilder('白鹭之窗',2))
      }.vertical(false)
      .barHeight(0)
      .scrollable(true)
      .barMode(BarMode.Fixed)
      .onChange((index:number)=>{
        this.currentIndex = index;
      })
    }

  }
}