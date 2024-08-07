import { it } from '@ohos/hypium';
import { PullToRefresh } from '@ohos/pulltorefresh';
import { ToastUtil } from '@yunkss/eftool';

// @property (strong,nonatomic) NSString * appinfoUrl;
// @property (strong,nonatomic) NSString * typeAsc;
// @property (strong,nonatomic) NSString * pkid;
// @property (strong,nonatomic) NSString * appinfoZhname;
// @property (strong,nonatomic) NSString * apptypeName;
// @property (strong,nonatomic) NSString * apptypeEnname;
// @property (strong,nonatomic) NSString * appinfoEnname;
// @property (strong,nonatomic) NSString * appinfoPhoto;
// @property (strong,nonatomic) NSString * appinfoBandid;
// @property (assign,nonatomic) BOOL isNeedShowLocal;
// @property (assign,nonatomic) BOOL offlineApp;
// @property (strong,nonatomic) NSString *imageCacheUrl;
// @property (strong,nonatomic) NSString *recentTime;
class MFBranchAppModel{
  appinfoZhname:string = '';
  appinfoPhoto:Resource ;
  // appinfoUrl:string = '';
  // typeAsc:string = '';
  // pkid:string = '';
  //
  // apptypeName:string = '';
  //
  // apptypeEnname:string = '';
  // appinfoEnname:string = '';
  //
  // appinfoBandid:string = '';
  // isNeedShowLocal:boolean = false;
  //
  // offlineApp:boolean = false;
  // imageCacheUrl:string = '';
  // recentTime:string = '';

  constructor(appinfoZhname:string,appinfoPhoto:Resource) {
    this.appinfoZhname = appinfoZhname;
    this.appinfoPhoto = appinfoPhoto;
  }
}


@Entry
@Component
export  struct MFWorkbranchController {
  @State message: string = 'Hello World';
  // 需绑定列表或宫格组件
  private scroller: Scroller = new Scroller();

  @State screenWidth:number  = 375;
  @State data:string[] = ["1","1","1","1","1","1"];
  @State dataNumbers:string[] = ["2","2","2","2","2","2","2","2","2","2","2","2","2","2"];

  private swiperController: SwiperController = new SwiperController();
  @State adImage:string[] = ['1','1','1']
  @State appsForTop:MFBranchAppModel[] = [
    new MFBranchAppModel('薪酬查询',$r('app.media.login_eyes_close')),
    new MFBranchAppModel('手册',$r('app.media.login_eyes_close')),
    new MFBranchAppModel('一卡通',$r('app.media.login_eyes_close')),
    new MFBranchAppModel('动态',$r('app.media.login_eyes_close'))
  ]

  @State appsForAll:MFBranchAppModel[][] = [
    [
      new MFBranchAppModel('薪酬查询',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('一卡通',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('手册',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('动',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('动',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('手册',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('一卡通',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('薪酬查询薪酬查询',$r('app.media.login_eyes_close')),
    ],
    [
      new MFBranchAppModel('薪酬查询',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('一卡通',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('手册',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('动',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('动',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('手册',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('一卡通',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('薪酬查询',$r('app.media.login_eyes_close')),
    ],
    [
      new MFBranchAppModel('薪酬查询',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('一卡通',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('手册',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('动',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('动',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('手册',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('一卡通',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('薪酬查询',$r('app.media.login_eyes_close')),
    ],
    [
      new MFBranchAppModel('薪酬查询',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('一卡通',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('手册',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('动',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('动',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('手册',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('一卡通',$r('app.media.login_eyes_close')),
      new MFBranchAppModel('薪酬查询',$r('app.media.login_eyes_close')),
    ],


  ]

  ///轮播图
  @Builder adscroller(){
      Swiper(){

        ForEach(this.adImage,(item:string,index:number)=>{
          Image($r('app.media.login_eyes_open'))
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Red)
        })
      }.indicator(
        Indicator.dot()
          .itemWidth(3)
          .itemHeight(3)
          .selectedItemWidth(9)
          .selectedItemHeight(3)
          .selectedColor(Color.White)
          .color(Color.White)
          .bottom(10)
      ).width('100%')
       .height(202)
       .direction(Direction.Ltr)
    .autoPlay(true)
    .loop(true)
    .interval(1000)
    .position({left:0,top:0})
    // .backgroundColor(Color.Red)

  }

  @Builder oneApp(){

  }
  ///指定app
  @Builder topApps(){
    Row(){
      ForEach(this.appsForTop,(item:MFBranchAppModel,index:number)=>{
        Button({type:ButtonType.Normal}){
          Column(){
            Image(item.appinfoPhoto)
              .width(48)
              .height(48)
            Text(item.appinfoZhname)
              .fontColor(0xD9000000)
              .fontSize(13)
              .fontWeight(400)

          }.padding({top:10,bottom:12,left:12,right:12})
        }.backgroundColor(Color.White)
        .onClick((event:ClickEvent)=>{
          ToastUtil.showToast(item.appinfoZhname);
        })
      })
    }.justifyContent(FlexAlign.SpaceAround)
    .width('100%')
  }

  @Builder sectionApps(){
    ForEach(this.appsForAll,(item:MFBranchAppModel[],index:number)=>{

      Column(){
        Row(){
          Blank().backgroundColor(0xFF3390FF)
            .width(3)
            .height(16)
          Text(`${index}`)
            .fontColor(0xFF002A5B)
            .fontSize(15)
            .fontWeight(500)
            .margin({left:13})
            .layoutWeight(1)

          if(index==0){
            Row(){
              Image($r('app.media.MFWorkBranchManagerApps'))
                .width(16)
                .height(16)
              Text('管理')
                .fontColor(0x80000000)
                .fontSize(12)
                .fontWeight(400)
            }.height('100%')
            .margin({right:16})

            Button({buttonStyle:ButtonStyleMode.TEXTUAL})
              .height('100%')
              .width(60)
              .position({top:0,right:0})
              .onClick((event:ClickEvent)=>{
                ToastUtil.showToast('管理');
              })
          }


        }.height(48)
        .width('100%')
        Grid(){
          ForEach(item,(md:MFBranchAppModel,num:number)=>{
            GridItem(){
              Button({type:ButtonType.Normal}){
                Column(){
                  Image(md.appinfoPhoto)
                    .width(28)
                    .height(28)

                  Text(md.appinfoZhname)
                    .fontColor(0xD9000000)
                    .fontSize(13)
                    .fontWeight(400)
                    .margin({top:1})
                    .maxLines(1)

                }.justifyContent(FlexAlign.Center)
                .padding({top:10,bottom:12,left:12,right:12})
              }.backgroundColor(Color.White)
              .onClick((event:ClickEvent)=>{
                ToastUtil.showToast(md.appinfoZhname);
              })
            }
          })
        }.width('100%')
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(0)
        .rowsGap(0)
        .height(70*(item.length/4.0+(item.length%4==0?0:1)))
        .margin({top:6,bottom:10})
      }
      .margin({left:8,right:8,bottom:10})
      .border({
        radius:8,

      }).shadow({
        radius:15,
        color:0x80DBDBDB,
        type:ShadowType.COLOR,
        offsetY:2

      })



    })
  }


  @Builder getListView(){
      Scroll(this.scroller){
        Column(){
          this.adscroller()

          Column(){
            this.topApps();
            this.sectionApps();
          }.margin({top:190})
          // .height('100%')
          .width('100%')
          .backgroundColor(Color.White)
          .border({
            radius:{topLeft:12,topRight:12}
          })
        }
        .width('100%')
      }
      // .margin({bottom:58})
      // .scrollBar(BarState.Off)
  }

  ///天气头部
  @Builder workBranchHeader(){
    Row(){
      Column(){
        Text('早上好，夏小航')
          .fontSize(16)
          .fontWeight(400)
          .fontColor(0xD9000000)

        Text('厦门 14-30度 晴')
          .fontSize(10)
          .fontWeight(400)
          .fontColor(0x80000000)
          .margin({top:2})
      }.layoutWeight(1)
      .margin({left:24})
      .alignItems(HorizontalAlign.Start)

      Button({type:ButtonType.Normal}){
        Image($r('app.media.MFWorkBranchScanner'))
          .height(24)
          .width(24)
      }.height(48)
      .width(48)
      .backgroundColor(Color.White)

      Button({type:ButtonType.Normal}){
        Image($r('app.media.MFWorkBranchSearch'))
          .height(24)
          .width(24)
      }.height(48)
      .width(48)
      .margin({right:12})
      .backgroundColor(Color.White)

    }.height(58)
    .width('100%')

  }





  build() {
    Column(){
      this.workBranchHeader();
      PullToRefresh({
        // 必传项，列表组件所绑定的数据
        data: $data,
        // 必传项，需绑定传入主体布局内的列表或宫格组件
        scroller: this.scroller,
        // 必传项，自定义主体布局，内部有列表或宫格组件
        customList: () => {
          // 一个用@Builder修饰过的UI方法
          this.getListView();
        },
        // 可选项，下拉刷新回调
        onRefresh: () => {
          return new Promise<string>((resolve, reject) => {
            // 模拟网络请求操作，请求网络2秒后得到数据，通知组件，变更列表数据
            setTimeout(() => {
              resolve('刷新成功');
              this.data = this.dataNumbers;
            }, 2000);
          });
        },
        // 可选项，上拉加载更多回调
        onLoadMore: () => {
          return new Promise<string>((resolve, reject) => {
            // 模拟网络请求操作，请求网络2秒后得到数据，通知组件，变更列表数据
            setTimeout(() => {
              resolve('');
              this.data.push("增加的条目" + this.data.length);
            }, 2000);
          });
        },
        customLoad: null,
        customRefresh: null,
      }).margin({bottom:58})
    }.margin({top:20})
  }
}