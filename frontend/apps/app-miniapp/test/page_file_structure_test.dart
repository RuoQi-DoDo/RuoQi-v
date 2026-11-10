import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _pageClassPattern = RegExp(
  r'^class\s+_?\w+Page\s+extends\s+(?:StatefulWidget|StatelessWidget)',
  multiLine: true,
);

void main() {
  test('每个页面类单独位于一个 Dart 文件', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final pageCount = _pageClassPattern
          .allMatches(entity.readAsStringSync())
          .length;
      if (pageCount > 1) {
        offenders.add('${entity.path}: $pageCount');
      }
    }

    expect(offenders, isEmpty, reason: '以下文件包含多个页面类：\n${offenders.join('\n')}');
  });
}
