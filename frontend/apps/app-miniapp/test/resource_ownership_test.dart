import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _assetPathPattern = RegExp(
  r"""Image\.asset\(\s*['"]([^'"]+)['"]""",
  multiLine: true,
);

void main() {
  test('小程序图片与字体位于所属小程序目录', () {
    expect(
      Directory('assets').existsSync(),
      isFalse,
      reason: '应用根目录不应继续存放小程序专属资源',
    );

    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- lib/miniapp/merchant/assets/images/'));
    expect(
      pubspec,
      contains('lib/miniapp/merchant/assets/fonts/lightIconFont.ttf'),
    );
    expect(
      pubspec,
      contains('lib/miniapp/merchant/assets/fonts/boldIconFont.ttf'),
    );

    final missing = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      final source = entity.readAsStringSync();
      for (final match in _assetPathPattern.allMatches(source)) {
        final path = match.group(1)!;
        if (!path.startsWith('lib/miniapp/merchant/assets/images/') ||
            !File(path).existsSync()) {
          missing.add('${entity.path}: $path');
        }
      }
    }

    expect(missing, isEmpty, reason: '图片资源归属或路径不正确：\n${missing.join('\n')}');
  });

  test('每个小程序在自身目录维护翻译数据', () {
    const expectedOwners = <String, String>{
      'ats': 'l10n/ats_labels.dart',
      'hr': 'l10n/hr_labels.dart',
      'launcher': 'l10n/launcher_labels.dart',
      'merchant': 'l10n/merchant_labels.dart',
      'partner': 'l10n/partner_labels.dart',
      'platform': 'l10n/platform_localizations.dart',
      'tospino': 'l10n/tospino_labels.dart',
    };

    for (final entry in expectedOwners.entries) {
      final translationFile = File('lib/miniapp/${entry.key}/${entry.value}');
      expect(
        translationFile.existsSync(),
        isTrue,
        reason: '${entry.key} 的翻译应位于 ${entry.key} 目录',
      );
    }

    final commonAggregator = File(
      'lib/miniapp/common/l10n/miniapp_localizations.dart',
    ).readAsStringSync();
    for (final owner in [
      'ats',
      'hr',
      'merchant',
      'partner',
      'tospino',
      'launcher',
    ]) {
      expect(
        commonAggregator,
        contains("import '../../$owner/l10n/${owner}_labels.dart';"),
      );
    }
  });

  test('小程序私有 API 位于所属小程序目录', () {
    const owners = ['ats', 'hr', 'merchant', 'partner', 'platform', 'tospino'];

    for (final owner in owners) {
      expect(
        Directory('lib/api/$owner').existsSync(),
        isFalse,
        reason: '$owner 的 API 不应继续放在宿主公共 lib/api 目录',
      );
      expect(
        Directory('lib/miniapp/$owner/api').existsSync(),
        isTrue,
        reason: '$owner 的 API 应位于 lib/miniapp/$owner/api',
      );
    }

    final sharedApiOwners = Directory('lib/api')
        .listSync()
        .whereType<Directory>()
        .map((directory) => directory.path.split(Platform.pathSeparator).last)
        .toSet();
    expect(sharedApiOwners, {'customer', 'im'});
  });
}
