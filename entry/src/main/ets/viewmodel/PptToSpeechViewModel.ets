import fileio from '@ohos.fileio';
import JSZip from 'jszip';
import tts from '@ohos.tts';
import UIAbility from '@ohos.app.ability.UIAbility';

export enum SpeakState {
  READY = 'ready',
  LOADING = 'loading',
  SPEAKING = 'speaking'
}

export class PptToSpeechViewModel {
  private uiAbility: UIAbility;
  private ttsClient?: tts.TextToSpeech;

  constructor(ability: UIAbility) {
    this.uiAbility = ability;
  }

  async ensureTts(): Promise<tts.TextToSpeech> {
    if (this.ttsClient) {
      return this.ttsClient;
    }
    const client = new tts.TextToSpeech(this.uiAbility.context);
    await client.setLanguage('zh-CN');
    await client.setSpeechRate(1.0);
    this.ttsClient = client;
    return client;
  }

  async parseSlides(filePath: string): Promise<string[]> {
    const stat = await fileio.stat(filePath);
    if (!stat.isFile()) {
      throw new Error('提供的路径不是文件');
    }
    const fd = await fileio.open(filePath, fileio.OpenMode.READ_ONLY);
    const fileSize = stat.size;
    const buffer = new ArrayBuffer(fileSize);
    await fileio.read(fd, buffer);
    await fileio.close(fd);

    const zip = await JSZip.loadAsync(buffer);
    const slideFiles = Object.keys(zip.files)
      .filter(key => key.startsWith('ppt/slides/slide') && key.endsWith('.xml'))
      .sort();
    if (slideFiles.length === 0) {
      throw new Error('未找到幻灯片内容');
    }
    const slides: string[] = [];
    for (const file of slideFiles) {
      const xml = await zip.file(file)?.async('string');
      if (!xml) {
        continue;
      }
      const matches = Array.from(xml.matchAll(/<a:t>([^<]*)<\/a:t>/g)).map(v => v[1]);
      const slideText = matches.join('\n').trim();
      slides.push(slideText || '[空白幻灯片]');
    }
    return slides;
  }

  async speakSlides(slides: string[], onStart?: () => void, onEnd?: () => void): Promise<void> {
    const client = await this.ensureTts();
    onStart?.();
    for (const slide of slides) {
      await client.speak(slide, { queueMode: tts.QueueMode.QUEUE_ADD });
    }
    onEnd?.();
  }

  async stopSpeaking(): Promise<void> {
    if (!this.ttsClient) {
      return;
    }
    await this.ttsClient.stop();
  }
}
