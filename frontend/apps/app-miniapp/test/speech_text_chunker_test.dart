import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/pages/ai/speech_text_chunker.dart';

void main() {
  test('短回答保持为单个 TTS 片段', () {
    expect(splitSpeechTextForPlayback('你好。今天想聊点什么？'), ['你好。今天想聊点什么？']);
  });

  test('长回答先切出短首段并保持原文顺序', () {
    final text = List.generate(
      24,
      (index) => '这是第 $index 段用于测试语音分片播放的内容。',
    ).join();

    final chunks = splitSpeechTextForPlayback(text);

    expect(chunks.length, greaterThan(1));
    expect(chunks.first.length, lessThanOrEqualTo(90));
    expect(chunks.skip(1).every((chunk) => chunk.length <= 220), isTrue);
    expect(chunks.join(), text);
  });

  test('没有标点的长文本保持完整而不从中间硬切', () {
    final text = List.filled(40, '连续朗读内容').join();

    final chunks = splitSpeechTextForPlayback(text);

    expect(chunks, [text]);
  });

  test('没有标点但有空格时只在空格处分片', () {
    final text = List.filled(40, 'continuous speech content').join(' ');

    final chunks = splitSpeechTextForPlayback(text);

    expect(chunks.length, greaterThan(1));
    expect(chunks.every((chunk) => !chunk.startsWith(' ')), isTrue);
    expect(chunks.every((chunk) => !chunk.endsWith(' ')), isTrue);
    expect(chunks.join(' '), text);
  });

  test('空白文本不会产生 TTS 请求', () {
    expect(splitSpeechTextForPlayback('   \n  '), isEmpty);
  });
}
