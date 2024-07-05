@Entry
@Component
export  struct MFCooperationController {
  @State message: string = 'Hello World';

  build() {
    Column() {
      Text(this.message)
        .id('MFCooperationControllerHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)

    }
    .height('100%')
    .width('100%')
  }
}