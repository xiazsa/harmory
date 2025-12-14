import UIAbility from '@ohos.app.ability.UIAbility';
import { PptToSpeechViewModel, SpeakState } from '../viewmodel/PptToSpeechViewModel';

@Entry
@Component
struct Index {
  private viewModel?: PptToSpeechViewModel;
  @State private filePath: string = '';
  @State private slides: string[] = [];
  @State private status: SpeakState = SpeakState.READY;
  @State private errorMessage: string = '';

  aboutToAppear() {
    const ability = getContext(this) as UIAbility;
    this.viewModel = new PptToSpeechViewModel(ability);
  }

  private async loadSlides() {
    if (!this.viewModel) {
      return;
    }
    this.status = SpeakState.LOADING;
    this.errorMessage = '';
    try {
      this.slides = await this.viewModel.parseSlides(this.filePath);
      this.status = SpeakState.READY;
    } catch (err) {
      this.errorMessage = (err as Error).message;
      this.slides = [];
      this.status = SpeakState.READY;
    }
  }

  private async speak() {
    if (!this.viewModel || this.slides.length === 0) {
      this.errorMessage = '请先解析 PPTX 幻灯片';
      return;
    }
    this.errorMessage = '';
    await this.viewModel.speakSlides(
      this.slides,
      () => (this.status = SpeakState.SPEAKING),
      () => (this.status = SpeakState.READY)
    );
  }

  private async stop() {
    await this.viewModel?.stopSpeaking();
    this.status = SpeakState.READY;
  }

  build() {
    Column({ space: 12 }) {
      Text($r('app.string.app_name')).fontSize(24).fontWeight(FontWeight.Bold).padding({ top: 24 });
      Text('提供 PPTX 文件路径，解析后由系统 TTS 顺序朗读。').fontSize(14).opacity(0.8);

      TextInput({ placeholder: $r('app.string.choose_file'), text: this.filePath })
        .onChange(v => this.filePath = v)
        .width('100%')
        .padding(12)
        .border({ width: 1, color: '#d0d5dd', radius: 12 });

      Row({ space: 12 }) {
        Button($r('app.string.choose_file'))
          .type(ButtonType.Capsule)
          .onClick(() => this.loadSlides());

        if (this.status !== SpeakState.SPEAKING) {
          Button($r('app.string.start_tts'))
            .type(ButtonType.Capsule)
            .onClick(() => this.speak());
        } else {
          Button($r('app.string.stop_tts'))
            .type(ButtonType.Capsule)
            .onClick(() => this.stop());
        }
      }
      .margin({ top: 6 });

      if (this.errorMessage) {
        Text(this.errorMessage).fontColor(Color.Red).fontSize(14);
      }

      Text(this.status === SpeakState.LOADING ? $r('app.string.status_loading') :
        this.status === SpeakState.SPEAKING ? $r('app.string.status_speaking') :
        $r('app.string.status_ready'))
        .fontSize(14)
        .fontColor('#344054');

      List() {
        ForEach(this.slides, (slide, index) => {
          ListItem() {
            Column({ space: 6 }) {
              Text(`幻灯片 ${index + 1}`).fontWeight(FontWeight.Medium);
              Text(slide).maxLines(6).textOverflow({ overflow: TextOverflow.Ellipsis });
            }
            .padding(12)
            .backgroundColor('#F8FAFC')
            .borderRadius(12);
          };
        });
      }
      .height('60%')
      .width('100%');
    }
    .width('100%')
    .padding(24)
    .justifyContent(FlexAlign.Start)
    .backgroundColor('#FFFFFF');
  }
}
