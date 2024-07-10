import { Options } from '@ohos/imageknife';
import { Touch } from '@ohos.multimodalInput.touchEvent';
import { DialogUtil } from '@yunkss/eftool';
import { PullToRefresh } from '@ohos/pulltorefresh';
import { display } from '@kit.ArkUI';

///折扣票模型
class MFZheKouPiaoModel {
  num:number = 0
  name:string = ''

  constructor(num:number,name:string) {
    this.num = num;
    this.name = name;
  }
}

///账单列表模型
class MFZhangdanLieBiaoModel {
  name:string = ''
  key:string = ''
  url:string = ''

  constructor(name:string,key:string,url:string) {
    this.name = name;
    this.key = key;
    this.url = url;
  }
}

@Entry
@Component
export  struct MFMineController {

  @State message: string = '我的';

  // 需绑定列表或宫格组件
  private scroller: Scroller = new Scroller();

  @State screenWidth:number  = 375;
  @State data:string[] = ["1","1","1","1","1","1"];
  @State dataNumbers:string[] = ["2","2","2","2","2","2","2","2","2","2","2","2","2","2"];
  @State zheKouArr:MFZheKouPiaoModel[] = [
    new MFZheKouPiaoModel(2,"员工免票"),
    new MFZheKouPiaoModel(6,"员工折扣"),
    new MFZheKouPiaoModel(4,"家属折扣"),
  ]
  @State zhangdanLieBiaoArr:MFZhangdanLieBiaoModel[] = [
    new MFZhangdanLieBiaoModel("百度",'baiduimageKey',"https://baidu.com"),
    new MFZhangdanLieBiaoModel("谷歌",'googleKey',"https://google.com")
  ]

  aboutToAppear(): void {
    try {
      let displayclass:display.Display | null = display.getDefaultDisplaySync()
      // this.screenWidth = displayclass.width;
      console.log("宽度"+this.screenWidth.toString()+JSON.stringify(displayclass));
    }catch (err){

    }


  }

  ///头部
  @Builder getHeaderView(){
    Stack({alignContent:Alignment.TopStart}){
      ///头像装饰
      Image($r('app.media.MFMineHeadIconAttach'))
        .margin({left:64,top:-2})
        .width(44)
        .height(44)



      Column(){
        //名字行
        Row({space:8}){
          Text("厦小航")
            .fontSize(20)
            .fontWeight(500)
            .fontColor(Color.White)
          Row({space:2}){
            Text("电子工作证")
              .fontSize(11)
              .fontWeight(400)
              .fontColor(Color.White)
              .margin({left:11})

            Image($r('app.media.MFMineWhiteArrowright'))
              .margin({right:8})
              .width(8)
              .height(8)

          }.border({
            color:Color.White,
            width:1,
            radius:12,
            style:BorderStyle.Solid
          }).height(24)

        }.alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.End)
        .margin({top:16})

        //岗位行
        Row({space:8}){
          Image($r('app.media.MFMineGangWei'))
            .width(13)
            .height(12)
            .margin({top:2})


          Text("厦航本部_数字委员会员会员会员会员会员会员会员会员会员会员会员会")
            .fontSize(14)
            .fontWeight(400)
            .fontColor(Color.White)
            .margin({right:46})
        }.alignItems(VerticalAlign.Top)
        .margin({top:14})
        .width('100%')

        //工号
        Row({space:8}){
          Image($r('app.media.MFMindIdcard'))
            .width(13)
            .height(12)
            .margin({top:2})

          Text("00001")
            .fontSize(14)
            .fontWeight(400)
            .fontColor(Color.White)

          Blank().layoutWeight(1)

          Image($r('app.media.MFMineIdArrow'))
            .width(16)
            .height(16)
            .margin({right:24})

        }.alignItems(VerticalAlign.Top)
        .margin({top:12})
        .width('100%')

      }.padding({left:118})
      .alignItems(HorizontalAlign.Start)
      .width('100%')


      ///头像
      Image($r('app.media.MFDefault'))
        .margin({left:24,top:17})
        .objectFit(ImageFit.Contain)
        .width(70)
        .height(100)
        .border({
          width:2,
          color:Color.White,
          style:BorderStyle.Solid,
          radius:8
        })

    }.width('100%')

  }

  ///折扣票统计
  @Builder getZheKouPiao(){
    Stack({alignContent:Alignment.TopStart}){

      Row(){
        ForEach(this.zheKouArr,(item:MFZheKouPiaoModel,index:number) => {
          Column({space:1}){
            Row(){
              Text(item.num.toString())
                .fontSize(24)
                .fontWeight(500)
                .fontColor(0x111A34)

              Text('张')
                .fontSize(10)
                .fontWeight(400)
                .fontColor(0x111A34)
                .margin({bottom:4})

            }.alignItems(VerticalAlign.Bottom)

            Text(item.name)
              .fontSize(11)
              .fontWeight(400)
              .fontColor(0x41485D)
          }
        })
      }.width('100%')
      .height('100%')
      .backgroundBlurStyle(BlurStyle.Thin,{colorMode:ThemeColorMode.LIGHT,adaptiveColor:AdaptiveColor.DEFAULT,scale:1.0})
      .justifyContent(FlexAlign.SpaceAround)

      Image($r('app.media.MFMineZheKouPiao'))
        .width(28)
        .height(30)

    }.margin({left:8,right:8,top:20,bottom:10})
    .height(63)
    .border({
      color:Color.White,
      style:BorderStyle.Solid,
      width:1,
      radius:8
    })
    .shadow({color:0x91DDE0F3,radius:20,type:ShadowType.COLOR})
  }

  ///福利券指示器
  @Builder getFuliQuanZhiShiQi(){
    Row(){
      Text('目前无法获取您的节日券信息，请授权～')
        .fontSize(12)
        .fontWeight(400)
        .fontColor(0xffFF453A)
        .layoutWeight(1)
        .margin({left:16})

      Button('授权',{type:ButtonType.Normal,stateEffect:true})
        .onClick((event:ClickEvent)=>{

        })
        .fontColor(Color.White)
        .border({
          radius:14,
        })
        .height(28)
        .backgroundColor(0xffFF8686)
    }
    // .width('100%')
    .margin({left:8,right:8,bottom:10})
    .height(28)
    .border({
      color:0xffFFCCCC,
      width:1,
      style:BorderStyle.Solid,
      radius:14,
    }).backgroundColor(0xffFFE7E7)
    .alignItems(VerticalAlign.Center)
  }

  ///账单列表
  @Builder getZhangDanLiebiao(){
      Column({space:10}){
        ForEach(this.zhangdanLieBiaoArr,(item:MFZhangdanLieBiaoModel,index:number)=>{
          Image($r('app.media.MFDefault'))
            .height((this.screenWidth-8*2)/327*90)
            .border({
              radius:8
            })
            .width('100%')
            .backgroundColor(Color.Red)
        })
      }
      .margin({left:8,right:8,bottom:10})
  }

  @Builder getListView(){
    Scroll(this.scroller){
      Column(){
        this.getHeaderView();
        this.getZheKouPiao();
        this.getFuliQuanZhiShiQi();
        this.getZhangDanLiebiao();
        // ForEach(this.data,(item:String,index:number)=>{
        //   Text(index.toString())
        //     .fontSize(40)
        // })
      }.width('100%')
    }


  }


  build() {
    Stack({alignContent:Alignment.Top}){
      Image(null)
        .backgroundColor(0x5585EB)
        .width('100%')
        .height(271)
        .fillColor(Color.Black)

      Row(){
        Text(this.message)
          .fontSize(20)
          .fontWeight(500)
          .fontColor(Color.White)
          .margin({left:24})

        Row(){
          Image($r('app.media.icon_setting'))
            .objectFit(ImageFit.Contain)
            .height(24)
            .width(24)
            .margin({right:24})
        }.justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .width(72)
        .height(58)
        .onTouch((event:TouchEvent)=>{
          if(event.type == TouchType.Down){
            DialogUtil.showAlertDialog({msg:'点击设置'})
          }
        })


      }.height(58)
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({top:20})



      Column(){
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
        })
      }.margin({top:78})


    }
    .backgroundColor(0xf5f5f5)
    .height('100%')
    .width('100%')
  }
}