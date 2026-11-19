import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/pages/ai/deepseek_tts_cache.dart';

void main() {
  test('TTS 相同内容复用缓存，不同内容使用不同文件', () async {
    final directory = await Directory.systemTemp.createTemp(
      'ruoqi_tts_cache_test_',
    );
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
    final cache = DeepSeekTtsCache(directory: directory, maxFiles: 2);
    final first = await cache.put(
      text: '你好',
      bytes: Uint8List.fromList([1, 2, 3]),
    );
    final reused = await cache.get(text: '你好');
    final second = await cache.put(
      text: '再见',
      bytes: Uint8List.fromList([4, 5, 6]),
    );

    expect(reused?.path, first.path);
    expect(second.path, isNot(first.path));
    expect(await reused?.readAsBytes(), [1, 2, 3]);
    expect(await cache.get(text: '不存在'), isNull);
  });

  test('TTS 缓存按最近使用限制文件数量', () async {
    final directory = await Directory.systemTemp.createTemp(
      'ruoqi_tts_cache_prune_',
    );
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
    final cache = DeepSeekTtsCache(directory: directory, maxFiles: 2);
    for (var index = 0; index < 4; index++) {
      await cache.put(text: '内容 $index', bytes: Uint8List.fromList([index]));
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }

    final files = await directory
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    expect(files, hasLength(2));
  });
}
