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


@Entry
@Component
export  struct MFBaiLuZhiChuanSearch {
  @State message: string = '白鹭搜索';
  @State history:string[] = ['塑料袋副经理','水电费','水电','不扣分点','代付款代付款代付款','塑料袋副经经经经经经理塑料袋','塑料袋副经理',"1","2"]

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



    }.margin({top:20})
  }
}