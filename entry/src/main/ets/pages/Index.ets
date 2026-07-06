const TARGET_COMBO: number[] = [1, 2, 1, 1] // True Combination
const MAX_LENGTH: number = 4

type LockState = 'locked' | 'entering' | 'unlocked' | 'error'

@Entry
@Component
struct Index {
  @State lockState: LockState = 'locked'
  @State currentCombo: number[] = []
  @State feedbackMsg: string = ''
  @State touchCount: number = 0 // Number of active fingers

  private combosMatch(a: number[], b: number[]): boolean {
    if (a.length !== b.length) {
      return false
    }
    for (let i = 0; i < a.length; i++) {
      if (a[i] !== b[i]) {
        return false
      }
    }
    return true
  }

  private handleTap(fingers: number): void {
    if (this.lockState === 'unlocked' || this.lockState === 'error') {
      return
    }

    this.currentCombo = [...this.currentCombo, fingers]
    this.lockState = 'entering'

    if (this.currentCombo.length === MAX_LENGTH) {
      if (this.combosMatch(this.currentCombo, TARGET_COMBO)) {
        this.lockState = 'unlocked'
        this.feedbackMsg = 'Unlocked!'
      } else {
        this.lockState = 'error'
        this.feedbackMsg = 'Wrong Combination'
        setTimeout(() => {
          this.currentCombo = []
          this.lockState = 'locked'
          this.feedbackMsg = ''
        }, 1500)
      }
    }
  }

  private reset(): void {
    this.currentCombo = []
    this.lockState = 'locked'
    this.feedbackMsg = ''
    this.touchCount = 0
  }

  private getBgColor(): ResourceColor {
    if (this.lockState === 'unlocked') {
      return '#1A3C1A'
    }
    if (this.lockState === 'error') {
      return '#3C1A1A'
    }

    return '#1A1A2E'
  }

  private getDotColor(index: number): ResourceColor {
    if (index >= this.currentCombo.length) {
      return '#444466'
    }
    const val = this.currentCombo[index];
    return val === 1 ? '#4FC3F7' : '#FF8A65'
  }

  private getDotLabel(index: number): string {
    if (index >= this.currentCombo.length) {
      return '?'
    }
    return this.currentCombo[index] === 1 ? '①' : '②'
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.getBgColor())
        .animation({ duration: 400, curve: Curve.EaseInOut })

      Column({ space: 8 }) {

        Text($r('app.string.title'))
          .fontSize(20)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)

        if (this.lockState === 'locked') {
          Text($r('app.string.desc'))
            .fontSize(13)
            .fontColor('#AAAACC')
            .textAlign(TextAlign.Center)
        }

        Row({ space: 10 }) {
          ForEach([0, 1, 2, 3], (index: number) => {
            Column({ space: 4 }) {
              Text(this.getDotLabel(index))
                .fontSize(18)
                .fontColor('#FFFFFF')
              Circle()
                .width(14)
                .height(14)
                .fill(this.getDotColor(index))
                .animation({ duration: 200 })
            }
          }, (item: string) => item);
        }

        if (this.feedbackMsg !== '') {
          Text(this.feedbackMsg)
            .fontSize(15)
            .fontColor(this.lockState === 'unlocked' ? '#66FF66' : '#FF6666')
            .fontWeight(FontWeight.Bold)
        }

        // Touch Area
        if (this.lockState !== 'unlocked') {
          Stack() {
            Rect()
              .width(160)
              .height(70)
              .fill('#ff')
              .stroke('#5555AA')
              .strokeWidth(2)
              .radiusWidth(16)
              .radiusHeight(16)

            Text(this.touchCount === 0 ? $r('app.string.tap') :
              this.touchCount === 1 ? $r('app.string.one_finger') : $r('app.string.two_fingers'))
              .fontSize(14)
              .fontColor('#CCCCFF')
          }
          .width(160)
          .height(70)
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              // Update the number of active touches
              this.touchCount = event.touches.length
            } else if (event.type === TouchType.Up) {
              // Save when the last finger is lifted
              if (event.touches.length === 1 && this.touchCount > 0) {
                const fingers = Math.min(this.touchCount, 2) // Max 2
                this.handleTap(fingers)
                this.touchCount = 0
              }
            }
          })
        }

        Button($r('app.string.reset'))
          .fontSize(13)
          .height(34)
          .backgroundColor('#33334A')
          .fontColor('#AAAACC')
          .onClick(() => this.reset())
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
