import { MFCooperationRecommandModel } from './MFCooperationBaiLuRecomand';




@Entry
@Component
export  struct MFCooperationBaiLuDynamicSubVc {

  @State message: string = 'Hello World';


  @State listArr:MFCooperationRecommandModel[] = [
    new MFCooperationRecommandModel('MF_NEWS','','  ','https://baidu.com','2024-8-1','文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1文章1','','这是作者1',''),
    new MFCooperationRecommandModel('MF_NEWS','','','https://baidu.com','2024-8-1','文章2','','这是作者1',''),
    new MFCooperationRecommandModel('MF_NEWS','','','https://baidu.com','2024-8-1','文章3','','这是作者1',''),

    new MFCooperationRecommandModel('NOTICE','','','https://baidu.com','2024-7-1','文章1','','这是作者2',''),
    new MFCooperationRecommandModel('NOTICE','','','https://baidu.com','2024-7-1','文章2','','这是作者2',''),
    new MFCooperationRecommandModel('NOTICE','','','https://baidu.com','2024-7-1','文章3','','这是作者2',''),

    new MFCooperationRecommandModel('AVIATION_NEWS','','','https://baidu.com','2024-6-1','文章1','','这是作者3',''),
    new MFCooperationRecommandModel('AVIATION_NEWS','','','https://baidu.com','2024-6-1','文章2','','这是作者3',''),
    new MFCooperationRecommandModel('AVIATION_NEWS','','','https://baidu.com','2024-6-1','文章3','','这是作者3',''),
    new MFCooperationRecommandModel('TRENDS','','','https://baidu.com','2024-5-1','文章1','','这是作者4',''),
    new MFCooperationRecommandModel('TRENDS','','','https://baidu.com','2024-5-1','文章2','','这是作者4',''),
    new MFCooperationRecommandModel('TRENDS','','','https://baidu.com','2024-5-1','文章3','','这是作者4',''),
    new MFCooperationRecommandModel('KNOWLEDGE_CENTER','','','https://baidu.com','2024-4-1','文章1','','这是作者5',''),
    new MFCooperationRecommandModel('KNOWLEDGE_CENTER','','','https://baidu.com','2024-4-1','文章2','','这是作者5',''),
    new MFCooperationRecommandModel('KNOWLEDGE_CENTER','','','https://baidu.com','2024-4-1','文章3','','这是作者5',''),
  ]

  build() {
    List(){
      ForEach(this.listArr,(item:MFCooperationRecommandModel,index:number)=>{
        ListItem(){
          Row(){
            Column(){
              Text(item.articleTitle)
                .fontSize(16)
                .fontWeight(400)
                .fontColor(0x111A34)
              Row(){
                Image($r('app.media.MFRecomandCellTime'))
                  .width(14)
                  .height(14)
                Text(item.publishTime)
                  .fontSize(14)
                  .fontWeight(400)
                  .fontColor(0xBFBFBF)
                  .margin({left:4})

                Image($r('app.media.MFRecomandCellPepole'))
                  .width(14)
                  .height(14)
                  .margin({left:10})



                Text(item.author)
                  .fontSize(14)
                  .fontWeight(400)
                  .fontColor(0xBFBFBF)
                  .margin({left:4})

              }.justifyContent(FlexAlign.Start)
              .margin({
                top:11,
              })


            }.layoutWeight(1)
            .margin({
              left:20,
              top:16,
              bottom:15
            })
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)


            if(item.imgUrl === ''){
              Image($r('app.media.MFRecomandCellHeightArrow'))
                .width(16)
                .height(16)
                .margin({
                  left:39,
                  right:25
                })
            }else{
              Image($r('app.media.login_eyes_close'))
                .width(64)
                .height(64)
                .margin({
                  left:19,
                  right:27
                })
            }


          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start)
          // .border({
          //   width:{bottom:0.5},
          //   color:0x14000000,
          //   style:BorderStyle.Solid
          // })
        }
      })
    }.divider({color:0x14000000,strokeWidth:0.5,startMargin:20,endMargin:20})
  }
}