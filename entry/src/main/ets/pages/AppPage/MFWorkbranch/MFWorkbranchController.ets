@Entry
@Component
export  struct MFWorkbranchController {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('MFWorkbranchControllerHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)

    }
    .height('100%')
    .width('100%')
  }
}