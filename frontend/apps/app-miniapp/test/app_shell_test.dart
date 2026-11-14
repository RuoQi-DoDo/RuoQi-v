import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/app_shell.dart';
import 'package:ruoqi_app_miniapp/main.dart';

void main() {
  testWidgets('移动端应用字体设置且不启用全局文案选择', (tester) async {
    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.builder, isNotNull);
    expect(find.byType(SelectionArea), findsNothing);
    expect(app.theme!.textTheme.titleLarge?.fontSize, 17);
    expect(app.theme!.textTheme.bodyLarge?.fontSize, 17);
    expect(app.theme!.textTheme.bodyMedium?.fontSize, 15);
    expect(app.theme!.textTheme.bodySmall?.fontSize, 12);
  });

  test('只有 Web 使用全局文案选择包装', () {
    expect(platformSelectionBuilder(isWeb: false), isNull);
    expect(platformSelectionBuilder(isWeb: true), isNotNull);
  });
}
