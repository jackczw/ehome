import { it } from '@ohos/hypium';
import { RESOURCE } from '@ohos/imageknife';
import { DialogUtil } from '@yunkss/eftool';


class  MFCooperationColors{
  c:ResourceColor = '';
  num:number = 0;

  constructor(c:ResourceColor,num:number) {
    this.c = c;
    this.num = num
  }
}

class MFCooperationRecomandHeader {
  title:string = ''
  imgUrl:string = ''
  detailUrl:string = ''


  constructor(title:string,imgUrl:string,detailUrl:string) {
    this.title = title;
    this.imgUrl = imgUrl;
    this.detailUrl = detailUrl;
  }
}

export  class MFCooperationRecommandModel {
  tabKey:string = ''
  menuKey:string = ''
  imgUrl:string = ''
  articleLink:string = ''
  publishTime:string = ''
  articleTitle:string = ''
  imgId:string = ''
  author:string = ''
  articlePkid:string = ''

  constructor(tabKey:string,menuKey:string,imgUrl:string,articleLink:string,publishTime:string,articleTitle:string,imgId:string,author:string,articlePkid:string,) {
    this.tabKey = tabKey;
    this.menuKey = menuKey;
    this.imgUrl = imgUrl;
    this.articleLink = articleLink;
    this.publishTime = publishTime;

    this.articleTitle = articleTitle;
    this.imgId = imgId;
    this.author = author;
    this.articlePkid = articlePkid;

  }
}



@Entry
@Component
export struct MFCooperationBaiLuRecomand {
  @State headerArr:MFCooperationRecomandHeader[] = [
    new MFCooperationRecomandHeader('标题1','','https://www.baidu.com'),
    new MFCooperationRecomandHeader('标题2','','https://www.baidu.com'),
    new MFCooperationRecomandHeader('标题3','','https://www.baidu.com'),
  ]

  @State listArr:MFCooperationRecommandModel[][] = [
    [
    //公司新闻
      new MFCooperationRecommandModel('MF_NEWS','','','https://baidu.com','2024-8-1','文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1','','这是作者1',''),
      new MFCooperationRecommandModel('MF_NEWS','','  ','https://baidu.com','2024-8-1','文章2','','这是作者1',''),
      new MFCooperationRecommandModel('MF_NEWS','','','https://baidu.com','2024-8-1','文章3','','这是作者1','')
    ],
    [
    //通知公告
      new MFCooperationRecommandModel('NOTICE','','','https://baidu.com','2024-7-1','文章1','','这是作者2',''),
      new MFCooperationRecommandModel('NOTICE','','','https://baidu.com','2024-7-1','文章2','','这是作者2',''),
      new MFCooperationRecommandModel('NOTICE','','','https://baidu.com','2024-7-1','文章3','','这是作者2','')
    ],
    [
    //航空报
      new MFCooperationRecommandModel('AVIATION_NEWS','','','https://baidu.com','2024-6-1','文章1','','这是作者3',''),
      new MFCooperationRecommandModel('AVIATION_NEWS','','','https://baidu.com','2024-6-1','文章2','','这是作者3',''),
      new MFCooperationRecommandModel('AVIATION_NEWS','','','https://baidu.com','2024-6-1','文章3','','这是作者3','')
    ],
    [
    //动态
      new MFCooperationRecommandModel('TRENDS','','','https://baidu.com','2024-5-1','文章1','','这是作者4',''),
      new MFCooperationRecommandModel('TRENDS','','','https://baidu.com','2024-5-1','文章2','','这是作者4',''),
      new MFCooperationRecommandModel('TRENDS','','','https://baidu.com','2024-5-1','文章3','','这是作者4','')
    ],
    [
    //知识中心
      new MFCooperationRecommandModel('KNOWLEDGE_CENTER','','','https://baidu.com','2024-4-1','文章1','','这是作者5',''),
      new MFCooperationRecommandModel('KNOWLEDGE_CENTER','','','https://baidu.com','2024-4-1','文章2','','这是作者5',''),
      new MFCooperationRecommandModel('KNOWLEDGE_CENTER','','','https://baidu.com','2024-4-1','文章3','','这是作者5','')
    ],
  ]
  getColors(tabkey:string){
    let s = [new MFCooperationColors(0xD1F2FF,0),new MFCooperationColors(0xF1FEFF,1)];
    if(tabkey === 'MF_NEWS'){//公司新闻
      s = [new MFCooperationColors(0xD1F2FF,0),new MFCooperationColors(0xF1FEFF,1)];
    }
    if(tabkey === 'NOTICE'){//通知公告
      s = [new MFCooperationColors(0xD1F2FF,0),new MFCooperationColors(0xF1FEFF,1)];
    }
    if(tabkey === 'AVIATION_NEWS'){//航空报
      s = [new MFCooperationColors(0xFFDCD1,0),new MFCooperationColors(0xFFF9F1,1)];
    }
    if(tabkey === 'TRENDS'){ //动态
      s = [new MFCooperationColors(0xD1FFDB,0),new MFCooperationColors(0xFEFFF1,1)];
    }
    if(tabkey === 'KNOWLEDGE_CENTER'){//知识中心
      s = [new MFCooperationColors(0xFFF3D1,0),new MFCooperationColors(0xFFFEF1,1)];
    }
    let a:ResourceColor =  s[0].c;
    let b:number =  s[0].num;

    let c:ResourceColor =  s[1].c;
    let d:number =  s[1].num;

    let f:[ResourceColor, number][];
    f =  [[a,b],[c,d]];
    return f;
  }

  getSectionLogo(tabkey:string){
    let s = $r("app.media.MFComandGongGaoTongZhi");
    if(tabkey === 'MF_NEWS'){//公司新闻
      s = $r("app.media.MFComandGongGaoTongZhi");
    }
    if(tabkey === 'NOTICE'){//通知公告
      s = $r("app.media.MFComandGongGaoTongZhi");
    }
    if(tabkey === 'AVIATION_NEWS'){//航空报
      s = $r("app.media.MFComandHKB");
    }
    if(tabkey === 'TRENDS'){ //动态
      s = $r("app.media.MFComandDongTai");
    }
    if(tabkey === 'KNOWLEDGE_CENTER'){//知识中心
      s = $r("app.media.MFComandZhiShiZhongXin");
    }
    return s;
  }

  getSectionTextImage(tabkey:string){

    let s = $r("app.media.MFComandGongGaoTongZhiText");
    if(tabkey === 'MF_NEWS'){//公司新闻
      s = $r("app.media.MFComandGongGaoTongZhiText");
    }
    if(tabkey === 'NOTICE'){//通知公告
      s = $r("app.media.MFComandGongGaoTongZhiText");
    }
    if(tabkey === 'AVIATION_NEWS'){//航空报
      s = $r("app.media.MFComandHKBText");
    }
    if(tabkey === 'TRENDS'){ //动态
      s = $r("app.media.MFComandDongTaiText");
    }
    if(tabkey === 'KNOWLEDGE_CENTER'){//知识中心
      s = $r("app.media.MFComandZhiShiZhongXinText");
    }
    return s;
  }

  getSectionHeaderTextImageWidth(tabkey:string){

    let s = 262;
    if(tabkey === 'MF_NEWS'){//公司新闻
      s = 262;
    }
    if(tabkey === 'NOTICE'){//通知公告
      s = 262;
    }
    if(tabkey === 'AVIATION_NEWS'){//航空报
      s = 246;
    }
    if(tabkey === 'TRENDS'){ //动态
      s = 179;
    }
    if(tabkey === 'KNOWLEDGE_CENTER'){//知识中心
      s = 185;
    }
    return s;
  }

  getSectionHeaderTextImageLeft(tabkey:string){

    let s = 76;
    if(tabkey === 'MF_NEWS'){//公司新闻
      s = 76;
    }
    if(tabkey === 'NOTICE'){//通知公告
      s = 76;
    }
    if(tabkey === 'AVIATION_NEWS'){//航空报
      s = 84;
    }
    if(tabkey === 'TRENDS'){ //动态
      s = 117;
    }
    if(tabkey === 'KNOWLEDGE_CENTER'){//知识中心
      s = 114;
    }
    return s;
  }

  @Builder getSectionHeader(headerModel:MFCooperationRecommandModel){

    Stack({alignContent:Alignment.TopStart}){


      Row(){
        Blank().layoutWeight(1)
      }.border({
        radius:12
      })
        .height(55)
        .margin({
          top:33,
          left:20,
          right:20,
        })
        .linearGradient({
          direction:GradientDirection.Bottom,
          colors:this.getColors(headerModel.tabKey)
        })



      Image(this.getSectionTextImage(headerModel.tabKey))
        .width(this.getSectionHeaderTextImageWidth(headerModel.tabKey))
        .margin({left:this.getSectionHeaderTextImageLeft(headerModel.tabKey),top:50})

      Image(this.getSectionLogo(headerModel.tabKey))
        .width(100)
        .height(100)
        .margin({left:46})

    }.width('100%')
    .height(100)

  }

  @Builder getGroupCell(headerModel:MFCooperationRecommandModel){
    Row(){
      Column(){
          Text(headerModel.articleTitle)
            .fontSize(16)
            .fontWeight(400)
            .fontColor(0x111A34)
            .margin({bottom:11})
            .textAlign(TextAlign.Start)

          Row(){
            Image($r('app.media.MFRecomandCellTime'))
              .width(14)
              .height(14)
            Text(headerModel.publishTime)
              .fontSize(14)
              .fontWeight(400)
              .fontColor(0xBFBFBF)
              .margin({left:4})

            Image($r('app.media.MFRecomandCellPepole'))
              .width(14)
              .height(14)
              .margin({left:10})



            Text(headerModel.author)
              .fontSize(14)
              .fontWeight(400)
              .fontColor(0xBFBFBF)
              .margin({left:4})

          }.justifyContent(FlexAlign.Start)

      }.layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)

      if(headerModel.imgUrl === ''){
        Image($r('app.media.MFRecomandCellHeightArrow'))
          .width(16)
          .height(16)
          .margin({
            left:39,
          })
      }else{
        Image($r('app.media.login_eyes_close'))
          .width(64)
          .height(64)
          .margin({
            left:19,
          })
      }
    }.margin({left:20,right:25,top:16,bottom:0})
    .padding({bottom:15})
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .border({
      width:{bottom:0.5},
      color:0x14000000,
      style:BorderStyle.Solid
    })
    .onClick((event:ClickEvent)=>{
      DialogUtil.showDialog({msg:headerModel.articleTitle})
    })

  }

  @Builder getSectionItem(item:MFCooperationRecommandModel[]){

      ListItemGroup({header:this.getSectionHeader(item[0])}){
        ForEach(item,(a:MFCooperationRecommandModel,index:number)=>{
              this.getGroupCell(a);
        })
      }
  }

  @State message: string = 'Hello World';
  private  scroller:Scroller = new Scroller();
  build() {
    Scroll(this.scroller){
      Column(){
        Swiper(){
          ForEach(this.headerArr,(item:MFCooperationRecomandHeader,index:number)=>{
            Stack({alignContent:Alignment.Bottom}){
              Image($r('app.media.login_eyes_open'))
                .backgroundColor(Color.White)
              Text(item.title)
                .fontColor(Color.White)
                .fontSize(14)
                .fontWeight(600)
                .backgroundColor(0x80000000)
                .padding({top:8,left:13,right:13,bottom:20})
                .width('100%')
            }.width('100%')
            .height('100%')

          })
        }.width('100%')
        .loop(true)
        .height(210)
        .indicator(
          Indicator.dot()
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(6)
            .selectedItemHeight(6)
            .color(0x4DEBEDF0)
            .selectedColor(Color.White)
        )

        List(){
          ForEach(this.listArr ,(item:MFCooperationRecommandModel[],index:number)=>{
            this.getSectionItem(item)
          })
        }.divider({color:0x14000000,strokeWidth:0.5,startMargin:20,endMargin:20})
        // .divider({color:0x14000000,strokeWidth:0.5,startMargin:20,endMargin:25})


      }
    }
  }
}