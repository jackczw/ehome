import { DialogUtil, Logger, ToastUtil } from '@yunkss/eftool';
import { router } from '@kit.ArkUI';

class HistoryModel{
  maxX:number = 0;
  lastIndex:number = 0;
  currentWidth:number = 0;

  constructor(maxX:number,lastIndex:number,currentWidth:number) {
    this.maxX = maxX;
    this.lastIndex = lastIndex;
    this.currentWidth = currentWidth;
  }
}


class MFMatchModel{
  index:number = 0;
  word:string = ''

  constructor(index:number,word:string) {
    this.index = index;
    this.word = word;
  }
}
@Entry
@Component
export  struct MFBaiLuZhiChuanSearch {
  @State message: string = '白鹭搜索';
  @State history:string[] = ['塑料袋副经理','水电费','水电','不扣分点','代付款代付款代付款','塑料袋副经经经经经经理塑料袋','塑料袋副经理',"1","2"]
  @State searchReslut:string[] = ['塑料袋副经理','水电费','水电','不扣分点','代付款代付款代付款','塑料袋副经经袋副经经袋副经经袋副经经经经经经理塑料袋','塑料袋副经理',"1","2"]

  //屏幕宽度
  screenWidth:number = 360;
  //flex可用宽度
  flexWidht = this.screenWidth - 48;
  //flex最大高度
  @State flexHeight:number = 20+48*5;

  @State lineWidth:HistoryModel[] = [];
  currentMaxX:number = 0;
  @State expand:boolean = false;
  @State indexForexpandbt:number = -1;
  @State textStr:string = '';
  @State expandBtWidth:number = 44;
  @State widthArr:number[] = [];
  @State isNeedShowHistory:boolean = true;


  textControler:TextInputController = new TextInputController();

  proccessHistoryTextLength(text:string){
    if(text.length>9){
      return text.substring(0,9)+'...'
    }
    return text
  }

  getTextLength(text:string){
    if(this.expand){//
      this.history.forEach((value:String,index:Number)=>{
        // this.proccessHistoryTextLength(value);
      })
    }else{

    }
  }

  getFlexHeight(){
    let linelength = this.lineWidth.length;
    let height = 20 + 48*linelength;

    if(this.lineWidth.length>2){

      if(this.expand==false){
        let md:HistoryModel = this.lineWidth[1];
        if((md.maxX+40)>this.flexWidht){

        }
        this.indexForexpandbt =  md.lastIndex;
        this.flexHeight = 20 + 48*2;
      }else{
        let linelength = this.lineWidth.length;
        let md:HistoryModel = this.lineWidth[linelength-1];
        this.indexForexpandbt =  md.lastIndex;
        this.flexHeight = 20 + 48*linelength;
      }
    }
  }

  build() {
    Column(){
      Row(){
        Row(){

            TextInput({placeholder:'搜索白鹭之窗',controller:this.textControler})
              .backgroundColor(0xffF6F6F6)
              .height(36)
              .margin({left:26})
              .onFocus(()=>{

              })
              .onChange((value:string)=>{
                  this.textStr = value;
              })
              .onSubmit((enterkey:EnterKeyType,event:SubmitEvent)=>{
                // this.lineWidth = [];
                // this.currentMaxX = 0;
                // this.indexForexpandbt = -1;
                // this.history.unshift(this.textStr);
                if(this.textStr.length > 0){
                  this.history.unshift(this.textStr);
                  let arr = this.history;
                  this.lineWidth = [];
                  this.widthArr = [];
                  this.currentMaxX = 0;
                  this.indexForexpandbt = -1;
                  this.expandBtWidth = 44;
                  this.history = [];

                  setTimeout(()=>{
                    this.lineWidth = [];
                    this.widthArr = [];
                    this.currentMaxX = 0;
                    this.indexForexpandbt = -1;
                    this.expandBtWidth = 44;

                    this.history = arr;
                    this.isNeedShowHistory = true;
                  },200)
                }else{
                  ToastUtil.showToast('请输入搜索内容');
                }


              })

          Image($r('app.media.MFBaiLuSearchSearchTextImage'))
            .width(20)
            .height(20)
            .position({top:8,left:12})
        }.backgroundColor(0xffF6F6F6)
        .height(36)
        .border({
          radius:18
        })
        .margin({left:24,right:64})

        Button({buttonStyle:ButtonStyleMode.TEXTUAL,type:ButtonType.Normal}){
          Text('取消')
            .fontSize(16)
            .fontWeight(400)
            .fontColor(0xd9000000)
            .margin({left:-8})
        }.width(64)
        .height(36)
        .position({top:0,right:0})
        .onClick((event:ClickEvent)=>{
            router.back();
        })
      }


      Column(){
        if(this.isNeedShowHistory){
          Row(){
            Text('历史记录')
              .fontSize(14)
              .fontWeight(500)
              .fontColor(0xff111A34)
              .margin({left:24})

            Image($r('app.media.MFBaiLuSearchDeleteBt'))
              .width(16)
              .height(16)
              .position({right:24,top:3})



          }.width('100%')

          Button({buttonStyle:ButtonStyleMode.TEXTUAL})
            .width(60)
            .height(60)
            .position({top:0,right:0})
            .onClick((event:ClickEvent)=>{
              ToastUtil.showToast('删除');
              this.lineWidth = [];
              this.widthArr = [];
              this.currentMaxX = 0;
              this.indexForexpandbt = -1;
              this.expandBtWidth = 44;
              this.history = [];
              this.isNeedShowHistory = false;
            })
        }


        Flex({wrap:FlexWrap.Wrap}){
          ForEach(this.history,(item:string,index:number)=>{
            if(this.indexForexpandbt >0 && this.indexForexpandbt == index) {
              Button({type:ButtonType.Normal}){
                Row(){
                  Row(){
                    Image(this.expand?$r('app.media.MFBaiLuSearchHistoryArrowUp'):$r('app.media.MFBaiLuSearchHistoryArrowDown'))
                      .width(16)
                      .height(16)
                  }.height(32)
                  .justifyContent(FlexAlign.Center)
                  .width(44)
                  .border({
                    radius:16,
                    width:1,
                    color:0xffEAEAEA
                  })
                }.width('100%')
                  // .padding({left:12,right:12})
              }
              .width(this.expandBtWidth)
              .backgroundColor(Color.White)
              .margin({right:16,bottom:16})
              .onClick((event:ClickEvent)=>{
                let arr = this.history;
                this.lineWidth = [];
                this.widthArr = [];
                this.currentMaxX = 0;
                this.indexForexpandbt = -1;
                this.expandBtWidth = 44;
                this.history = [];

                setTimeout(()=>{
                  this.expand = !this.expand;
                  this.lineWidth = [];
                  this.widthArr = [];
                  this.currentMaxX = 0;
                  this.indexForexpandbt = -1;
                  this.expandBtWidth = 44;

                  this.history= arr;

                },200)
              })

            }else{
              Button({type:ButtonType.Normal,buttonStyle:ButtonStyleMode.TEXTUAL}){

                  Text(this.proccessHistoryTextLength(item))
                    .fontSize(14)
                    .fontWeight(400)
                    .fontColor(0xff111A34)
                    .padding({left:12,right:12})

              }.height(32)
              .onSizeChange((old,newvalue:SizeOptions)=>{
                if(index==0){
                  this.currentMaxX = 0
                  this.expandBtWidth = 44;
                }
                if(newvalue.width){
                  this.widthArr.push(Number(newvalue.width.toString()));
                  let width = (Number(newvalue.width.toString())+16);
                  if((this.currentMaxX+width) > this.flexWidht){
                    if(this.widthArr.length > (index-1)){
                      this.lineWidth.push(new HistoryModel(this.currentMaxX,index-1,this.widthArr[index-1]));
                    }else{
                      this.lineWidth.push(new HistoryModel(this.currentMaxX,index-1,Number(newvalue.width.toString())));
                    }

                    this.currentMaxX = width;
                  }else{
                    this.currentMaxX = width+this.currentMaxX;
                  }
                  if(index == this.history.length-1) {
                    this.lineWidth.push(new HistoryModel(this.currentMaxX,index,Number(newvalue.width.toString())));
                  }
                }


                console.log(`index:${index}   `+ this.proccessHistoryTextLength(item) + '     宽度变化'+`${newvalue.width}`)
                if(index == this.history.length-1){
                  console.log('进来了')
                  console.log(JSON.stringify(this.lineWidth));
                  if(this.lineWidth.length>2){

                    if(this.expand==false){
                      let md:HistoryModel = this.lineWidth[1];
                      // if((md.maxX+44)<this.flexWidht){
                      //   this.indexForexpandbt =  md.lastIndex;
                      // }else{
                      //   this.indexForexpandbt =  md.lastIndex+1;
                      // }
                      this.expandBtWidth =  md.currentWidth;
                      this.indexForexpandbt =  md.lastIndex;

                      this.flexHeight = 20 + 48*2;
                    }else{
                      let linelength = this.lineWidth.length;
                      if(linelength>5){
                        linelength = 5;
                      }
                      let md:HistoryModel = this.lineWidth[linelength-1];
                      this.expandBtWidth =  md.currentWidth;
                      if((md.maxX+44)>this.flexWidht) {

                      }else{

                      }
                      this.indexForexpandbt =  md.lastIndex;
                      this.flexHeight = 20 + 48*linelength;
                    }
                  }
                  this.lineWidth.forEach((value: HistoryModel, index: number, array: HistoryModel[]) => {

                  });
                }
              })
              .margin({right:16,bottom:16})
              .border({
                radius:16,
                width:1,
                color:0xffEAEAEA
              })
              .onClick((event:ClickEvent)=>{
                if(this.history.length > index){
                  let str = this.history[index];
                  this.history.splice(index,1);
                  this.history.unshift(str);

                  let arr = this.history;
                  this.lineWidth = [];
                  this.widthArr = [];
                  this.currentMaxX = 0;
                  this.indexForexpandbt = -1;
                  this.expandBtWidth = 44;
                  this.history = [];

                  setTimeout(()=>{
                    this.lineWidth = [];
                    this.widthArr = [];
                    this.currentMaxX = 0;
                    this.indexForexpandbt = -1;
                    this.expandBtWidth = 44;
                    this.history= arr;
                  },200)

                }



              })
            }

          })
        }
        .height(this.flexHeight)
        .padding({top:20,left:24,right:24})
        .width('100%')
        .clip(true)
        .onSizeChange((old,newvalue)=>{
          console.log('系统宽度'+`${newvalue.width}`)
        })

      }.margin({top:39})


      Image($r('app.media.MFBaiLuSearchHot'))
        .width(48)
        .height(12)
        .margin({left:19,bottom:16,top:30})


    Column(){
      Row(){
        Image($r('app.media.MFBaiLuSearchHotDot1'))
          .height(6)
          .width(6)
          .margin({right:16})
        Text('111111111111111111111111111111111111111111111111111111111111111111111')
          .padding({top:16,bottom:16,right:24})
          .width('100%')
      }.margin({left:24,right:24})
      .border({
        color:0x14000000,
        style:BorderStyle.Solid,
        width:{bottom:1}

      })


      Row(){
        Image($r('app.media.MFBaiLuSearchHotDot2'))
          .height(6)
          .width(6)
          .margin({right:16})
        Text('222222222222222222222222222222222222222222222222222222222222222222222222222222222222')
          .padding({top:16,bottom:16,right:24})
          .width('100%')
          .fontSize(14)
          .fontWeight(400)
          .fontColor(0xff111A34)
      }.margin({left:24,right:24})
      .border({
        color:0x14000000,
        style:BorderStyle.Solid,
        width:{bottom:1}

      })

    }

    ///搜索类别数据
      List(){
        ForEach(this.searchReslut,(item:string,index:number)=>{
          ListItem(){
            Row(){
              Text(item)
                .fontSize(16)
                .fontWeight(400)
                .fontColor(0xff111A34)
                .padding({top:16,bottom:16})
                .width('100%')
            }.margin({left:20,right:25})
            .border({
              color:0x14000000,
              style:BorderStyle.Solid,
              width:{bottom:1}

            })
          }
        })
      }.position({left:0,top:58})
      .backgroundColor(Color.White)
      .width('100%')
      .height('100%')

      ///无数据
      Column(){
        Image($r('app.media.MFBaiLuSearcNOData'))
          .width(149)
          .height(149)
          .margin({top:173})
        // ///preveiw 似乎无法显示
        // RichText('<p style="font-size: 35px;text-align: center;font-weight: bold; color: rgb(24,78,228)">字体大小35px,行高45px</p>')

        Text('暂无搜索结果')
          .fontSize(12)
          .fontWeight(400)
          .fontColor(0xffC5CAD5)
          .margin({top:-29})
      }.position({left:0,top:58})
      .backgroundColor(Color.White)
      .width('100%')
      .height('100%')

    }.margin({top:20})
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }



  ///匹配字符串中的词
  findWordsWithPositions(str: string, word: string) {
    const regex = new RegExp(`\\b${word}\\b`, 'gi'); // 'g' 表示全局搜索，'i' 表示不区分大小写
    let match:RegExpExecArray | null;
    const positions: MFMatchModel[] = [];

    while ((match = regex.exec(str)) !== null) {
       // 注意：match[0] 是匹配的文本，match.index 是匹配项的位置

      positions.push(new MFMatchModel(match.index,match[0]));

        // 重要的是不要在这里使用 regex.lastIndex++，因为 exec 会自动处理它
        // 如果你在循环中手动修改了 lastIndex，可能会导致意外的行为
  }

  return positions;
}

}
