import {MFMineController} from '../MFPersoncenter/MFMineController'
import {MFCooperationController} from '../MFCooperation/MFCooperationController'
import {MFWorkbranchController} from '../MFWorkbranch/MFWorkbranchController'

@Entry
@Component
struct MFTabbar {
  @State message: string = 'Hello World';
  @State currentIndex:number = 1;

  @Builder tabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 25, height: 25 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#FF3390FF' : '#FF848484')
        .fontSize(10)
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({barPosition:BarPosition.End,index:this.currentIndex}){
      TabContent(){
        MFCooperationController({message:'协作'});
      }.tabBar(this.tabBuilder('协作',0,$r("app.media.icon_work"),$r("app.media.icon_work_un")))

      TabContent(){
        MFWorkbranchController({message:'工作台'});
      }.tabBar(this.tabBuilder('工作台',1,$r("app.media.icon_gongzuotai_use"),$r("app.media.icon_gongzuotai_un")))

      TabContent(){
        MFMineController({message:'我的'})
      }.tabBar(this.tabBuilder('我的',2,$r("app.media.icon_my_user"),$r("app.media.icon_my_un")))
    }.vertical(false)
    .barHeight(60)
    .scrollable(false)
    .barMode(BarMode.Fixed)
    .onChange((index:number)=>{
      this.currentIndex = index;
    })
  }
}