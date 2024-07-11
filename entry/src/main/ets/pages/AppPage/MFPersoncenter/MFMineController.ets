import { Options } from '@ohos/imageknife';
import { Touch } from '@ohos.multimodalInput.touchEvent';
import { DialogUtil } from '@yunkss/eftool';
import { PullToRefresh } from '@ohos/pulltorefresh';
import { display } from '@kit.ArkUI';
import { edgeWidths } from '@ohos.arkui.node';

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


///云食堂按钮
class MFYunShiTangModel {
  name:string = ''
  image:Resource = $r('app.media.MFDefault')

  constructor(name:string,image:Resource) {
    this.name = name;
    this.image = image;
  }
}


///预约服务 与我相关模型
class MFMineAppModel {
  name:string = ''
  image:Resource = $r('app.media.MFDefault')

  constructor(name:string,image:Resource) {
    this.name = name;
    this.image = image;
  }
}

interface  MFFuliFace{
  a:string,
  b:string
  c:string
}


///福利券
class MFFuliQuanModel {
  ///1生日券(8提货券)
  /// 2春节券 3端午券 4中秋券 5电影 6闽南大戏院 7通用券(在类型2节日券底下，业务来维护这是“中秋”还是“春节”，我们根据这个来匹配节日券，然后增加了一个通用的模板)
  cardType:number = 0
  //////1待领取 2待绑定 3待使用
  cardStatus:number = 0
  pkid:string = ''
  ///NewYear春节 Lantern元宵 TombSweeping清明 DragonBoat端午 MidAutumn中秋
  festivalType:string = ''

  getTimeStart:string = ''
  getTimeEnd:string = ''
  getTimeDesc:string = ''
  useTimeStart:string = ''
  cardLink:string = ''
  useTimeEnd:string = ''
  useTimeDesc:string = ''

  cardName:string = ''

  cardBalance:string = ''

  isNeedShowUnReceive:boolean = false


  constructor(cardName:string) {
    this.cardName =cardName;
  }

  // constructor(
  //   cardType: number,
  //   cardStatus:number,
  //   pkid:string,
  //   festivalType:string,
  //
  //   getTimeStart:string,
  //   getTimeEnd:string,
  //   getTimeDesc:string,
  //   useTimeStart:string,
  //
  //   useTimeEnd:string,
  //   useTimeDesc:string,
  //   cardLink:string,
  //   cardName:string,
  //
  //   cardBalance:string,
  //   isNeedShowUnReceive:boolean
  // ) {
  //   this.cardType = cardType;
  //   this.cardStatus = cardStatus;
  //   this.pkid = pkid;
  //   this.festivalType = festivalType;
  //
  //   this.getTimeStart = getTimeStart;
  //   this.getTimeEnd = getTimeEnd;
  //   this.getTimeDesc = getTimeDesc;
  //   this.useTimeStart = useTimeStart;
  //
  //   this.useTimeEnd = useTimeEnd;
  //   this.useTimeDesc = useTimeDesc;
  //   this.cardLink = cardLink;
  //   this.cardName = cardName;
  //
  //   this.cardBalance = cardBalance;
  //   this.isNeedShowUnReceive = isNeedShowUnReceive;
  //
  // }
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

  @State yunShiTangBt:MFYunShiTangModel[] = [
    new MFYunShiTangModel('付款',$r('app.media.MFYunShiTangFuKuan')),
    new MFYunShiTangModel('充值',$r('app.media.MFYunShiTangChongZhi')),
    new MFYunShiTangModel('流水',$r('app.media.MFYunShiTangLiuShui'))
  ]

  @State yuyuefuwuArr:MFMineAppModel[] = [
    new MFMineAppModel('场馆预约',$r('app.media.MFYunShiTangFuKuan')),
    new MFMineAppModel('健康管理',$r('app.media.MFYunShiTangChongZhi')),
    new MFMineAppModel('美发馆预约',$r('app.media.MFYunShiTangLiuShui'))
  ]

  @State yuwoxiangguanArr:MFMineAppModel[] = [
    new MFMineAppModel('休假申请',$r('app.media.MFYunShiTangFuKuan')),
    new MFMineAppModel('休假变更',$r('app.media.MFYunShiTangChongZhi')),
    new MFMineAppModel('不漏刷卡',$r('app.media.MFYunShiTangLiuShui')),
    new MFMineAppModel('考勤查询',$r('app.media.MFYunShiTangFuKuan')),
    new MFMineAppModel('人力流程管理',$r('app.media.MFYunShiTangChongZhi')),
    new MFMineAppModel('调休小时设置',$r('app.media.MFYunShiTangLiuShui')),
    new MFMineAppModel('放弃年休假',$r('app.media.MFYunShiTangLiuShui')),
  ]


  @State fuliquanArr:MFFuliQuanModel[] = [

    ]

  aboutToAppear(): void {




    try {
      let displayclass:display.Display = display.getDefaultDisplaySync()
      if(displayclass.width>0){
        this.screenWidth = displayclass.width;
      }

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

  ///云食堂
  @Builder getYunShiGang(){
    Column(){
      //第一行
      Row(){
        Text("职工云食堂")
          .fontSize(14)
          .fontWeight(500)
          .fontColor(0xd9000000)
          .layoutWeight(1)
          .margin({left:16})


        Row(){
          Text("更多")
            .fontSize(12)
            .fontWeight(400)
            .fontColor(0x80000000)
            .margin({left:16})
          Image($r('app.media.MFMineYunShiTangArrow'))
            .height(10)
            .width(10)
            .margin({left:2,right:16})
        }
        .height("100%")
        .onTouch((event:TouchEvent)=>{
          if(event.type == TouchType.Down){
            DialogUtil.showAlertDialog({msg:'点击更多'})
          }
        })

      }
      .margin({bottom:10})
      .height(49)

      // 第二行
      Row(){
        Column(){
          Row(){
            Text("总余额")
              .fontSize(11)
              .fontWeight(400)
              .fontColor(0xff111A34)
              .margin({left:16,top:3})

            Text("1111")
              .fontSize(15)
              .fontWeight(400)
              .fontColor(0xff111A34)
              .margin({left:4})
          }
          Row(){
            Blank()
              .width(4)
              .height(4)
              .backgroundColor(0xffFF453A)
              .margin({left:18})
              .border({
                radius:2
              })

            Text("食堂用餐")
              .fontSize(11)
              .fontWeight(400)
              .fontColor(0xff858B9C)
              .margin({left:4})

            Text("1111")
              .fontSize(13)
              .fontWeight(400)
              .fontColor(0xff41485D)
              .margin({left:4})
          }.alignItems(VerticalAlign.Center)
          .margin({top:10})

          Row(){
            Blank()
              .width(4)
              .height(4)
              .backgroundColor(0xff3390FF)
              .margin({left:18})
              .border({
                radius:2
              })

            Text("个人充值")
              .fontSize(11)
              .fontWeight(400)
              .fontColor(0xff858B9C)
              .margin({left:4})

            Text("1111")
              .fontSize(13)
              .fontWeight(400)
              .fontColor(0xff41485D)
              .margin({left:4})
          }.alignItems(VerticalAlign.Center)
          .margin({top:4})

        }.border({
          color:0xffF1F1F3,
          style:BorderStyle.Solid,
          width:{right:1}
        })
        .alignItems(HorizontalAlign.Start)
        .width(150)
        .margin({bottom:19})

        Row(){
          ForEach(this.yunShiTangBt,(item:MFYunShiTangModel,index:number)=>{
            Column(){
              Image(item.image)
                .width(44)
                .height(44)

              Text(item.name)
                .fontSize(11)
                .fontWeight(400)
                .fontColor(0xff111A34)
                .margin({top:8})
            }.onTouch((event:TouchEvent)=>{
              if(event.type == TouchType.Down){
                if(index==0){
                  DialogUtil.showAlertDialog({msg:'点击付款'})
                }else if(index==1){
                  DialogUtil.showAlertDialog({msg:'点击充值'})
                }else if(index==2){
                  DialogUtil.showAlertDialog({msg:'点击流水'})
                }
              }
            })
          })
        }.alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({bottom:19})
        .layoutWeight(1)
      }
      // .backgroundColor(Color.Red)
      .width('100%')

    }.margin({left:8,right:8,bottom:8})
    .height(140)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .border({
      radius:4
    })
    .shadow({radius:15,color:0x41DBDBDB,offsetY:2})
    // .width('100%')
  }

  ///预约服务  与我相关
  @Builder getYuWoXiangguan(name:string,arr:MFMineAppModel[]){
      Column(){
          Text(name)
            .fontSize(14)
            .fontWeight(500)
            .fontColor(0xd9000000)
            .margin({left:16,top:16})
          Grid(){
            ForEach(arr,(item:MFMineAppModel,index:number)=>{
              GridItem(){
                  Column(){
                    Image(item.image)
                      .width(28)
                      .height(28)
                      .margin({bottom:5})

                    Text(item.name)
                      .fontSize(13)
                      .fontWeight(400)
                      .fontColor(0x99000000)
                  }
              }.width('25%')
              .padding({top:12,bottom:8})
            })
          }
          .layoutDirection(GridDirection.Row)
          .maxCount(4)
        .width('100%')
      }.margin({left:8,right:8,bottom:8})
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Color.White)
      .border({
        radius:4
      })
      .shadow({radius:15,color:0x41DBDBDB,offsetY:2})
  }

  ///福利券
  @Builder getFuLiQuan(){
    Column(){
      //第一行
      Row(){
        Text("福利券")
          .fontSize(14)
          .fontWeight(500)
          .fontColor(0xd9000000)
          .layoutWeight(1)
          .margin({left:16})


        Row(){
          Text("更多")
            .fontSize(12)
            .fontWeight(400)
            .fontColor(0x80000000)
            .margin({left:16})
          Image($r('app.media.MFMineYunShiTangArrow'))
            .height(10)
            .width(10)
            .margin({left:2,right:16})
        }
        .height("100%")
        .onTouch((event:TouchEvent)=>{
          if(event.type == TouchType.Down){
            DialogUtil.showAlertDialog({msg:'点击更多'})
          }
        })

      }
      .margin({bottom:10})
      .height(49)

      


    }.margin({left:8,right:8,bottom:8})
    .height(140)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
    .border({
      radius:4
    })
    .shadow({radius:15,color:0x41DBDBDB,offsetY:2})
  }

  @Builder getListView(){
    Scroll(this.scroller){
      Column(){
        this.getHeaderView();
        this.getZheKouPiao();
        this.getFuliQuanZhiShiQi();
        this.getZhangDanLiebiao();
        this.getYunShiGang();
        this.getYuWoXiangguan('预约服务',this.yuyuefuwuArr);
        this.getYuWoXiangguan('与我相关',this.yuwoxiangguanArr);
        this.getFuLiQuan();
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