@Entry
@Component
struct MFTabbar {
  @State message: string = 'Hello World';
  @State currentIndex:number = 0;

  @Builder tabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 25, height: 25 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#1698CE' : '#6B6B6B')
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({barPosition:BarPosition.End,index:1}){
      TabContent(){
        Text("协作")
      }.tabBar('协作')

      TabContent(){
        Text("工作台")
      }.tabBar('工作台')

      TabContent(){
        Text("我的")
      }.tabBar('我的')
    }.vertical(false)
    .barHeight(60)
    .scrollable(false)
    .barMode(BarMode.Fixed)
  }
}