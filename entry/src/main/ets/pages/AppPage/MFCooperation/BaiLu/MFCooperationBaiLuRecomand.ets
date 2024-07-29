import { it } from '@ohos/hypium';

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

class MFCooperationRecommandModel {
  menuKey:string = ''
  imgUrl:string = ''
  articleLink:string = ''
  publishTime:string = ''
  articleTitle:string = ''
  imgId:string = ''
  author:string = ''
  articlePkid:string = ''

  constructor(menuKey:string,imgUrl:string,articleLink:string,publishTime:string,articleTitle:string,imgId:string,author:string,articlePkid:string,) {
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
    new MFCooperationRecomandHeader('标题2','','https://www.baidu.com'),
  ]



  @State message: string = 'Hello World';
  private  scroller:Scroller = new Scroller();
  build() {
    Scroll(this.scroller){
      Column(){
        Swiper(){
          ForEach(this.headerArr,(item:MFCooperationRecomandHeader,index:number)=>{
            Stack({alignContent:Alignment.Bottom}){
              Image($r('app.media.login_eyes_open'))
                .backgroundColor(Color.Yellow)
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
            .color(0xEBEDF0)
            .selectedColor(Color.White)
        )

      }
    }
  }
}