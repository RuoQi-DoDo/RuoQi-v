import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/pages/group.dart';
import 'package:ruoqi_app_miniapp/pages/group_config.dart';
import 'package:ruoqi_app_miniapp/pages/group_registry.dart';
import 'package:ruoqi_app_miniapp/main.dart';

void main() {
  test('业务组配置支持已知值并回退到 IM', () {
    expect(
      resolveConfiguredBusinessGroup(override: 'merchant'),
      BusinessGroup.merchant,
    );
    expect(resolveConfiguredBusinessGroup(override: 'HR'), BusinessGroup.hr);
    expect(
      resolveConfiguredBusinessGroup(override: 'unknown'),
      BusinessGroup.im,
    );
    expect(definitionFor(BusinessGroup.im).hostsMiniPrograms, isTrue);
    expect(definitionFor(BusinessGroup.merchant).hostsMiniPrograms, isFalse);
  });

  testWidgets('每个业务组都有可作为 App 根页面的 home', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (final group in BusinessGroup.values) {
      final definition = definitionFor(group);
      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: definition.home)),
      );
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: '${group.id} home should render',
      );
    }
  });

  testWidgets('index.html 选中的业务组决定 BusinessApp 主页面', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const BusinessApp(businessGroup: BusinessGroup.partner),
    );
    await tester.pumpAndSettle();

    expect(find.text('伙伴移动端'), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'RuoQi 伙伴');
  });
}
