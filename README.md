# PPTX To Speech (HarmonyOS 6)

基于鸿蒙 6.0 编译系统的示例应用，实现与 [PPTX-TO-SPEECH](https://github.com/xiazsa/PPTX-TO-SPEECH) 类似的功能：解析 PPTX 幻灯片文本并通过系统 TTS 顺序朗读。

## 功能概述
- 读取本地 PPTX 文件（输入文件路径）。
- 解析每个幻灯片中的文本（使用 `jszip` 解压并匹配 `<a:t>` 标签）。
- 调用鸿蒙 TTS 能力依次朗读全部幻灯片。
- 简单的 ArkUI 界面：输入文件路径、解析按钮、开始/停止朗读按钮、幻灯片文本预览。

## 目录结构
- `AppScope/app.json5`：应用配置，目标 API 9。
- `build-profile.json5` / `hvigorfile.ts`：全局构建配置。
- `entry/`：Stage 模块，包含 UI、资源和模块配置。
  - `src/main/module.json5`：模块元数据、权限（读取/写入媒体）。
  - `src/main/ets/viewmodel/PptToSpeechViewModel.ets`：PPTX 解析与 TTS 播放逻辑。
  - `src/main/ets/pages/Index.ets`：ArkUI 页面，提供文件路径输入与控制。
  - `src/main/resources`：字符串、图标、背景等资源。

## 构建与运行
1. **安装依赖**
   ```bash
   ohpm install
   ```
2. **编译**
   ```bash
   hvigorw assembleHap --mode debug
   ```
3. **部署到设备/模拟器**
   将生成的 HAP 安装到支持 API 9 的鸿蒙 6 设备，授予媒体读写权限。

## 使用说明
1. 在主页输入 PPTX 文件的绝对路径（例如 `/data/storage/el2/base/files/sample.pptx`）。
2. 点击“选择 PPTX 文件”（解析）后，页面会展示每页文本摘要。
3. 点击“开始朗读”触发系统 TTS 顺序播放；“停止朗读”可随时中断。

## 适配提示
- `jszip` 用于解析 PPTX，若需处理图片/音频可在 `PptToSpeechViewModel` 中扩展。
- 如需文件选择器，可接入 `@ohos.file.picker`，当前示例使用手动路径输入便于本地调试。
- 如果设备语音包缺少中文，可在 `ensureTts()` 中调整 `setLanguage` 参数或语速。
