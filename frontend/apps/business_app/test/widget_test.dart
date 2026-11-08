import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_business_app/appearance.dart';
import 'package:ruoqi_business_app/main.dart';

void main() {
  testWidgets('业务端默认进入客户宿主首页', (tester) async {
    await tester.pumpWidget(const BusinessApp());

    expect(find.text('客户模拟'), findsOneWidget);
    expect(find.text('企业直聘'), findsOneWidget);
    expect(find.text('佳佳'), findsOneWidget);
    expect(find.text('业务工作台'), findsNothing);
    expect(find.text('RuoQi 业务端 App'), findsNothing);
  });

  testWidgets('商户和伙伴从客户小程序选择页打开', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('customer-home-scroll')),
      const Offset(0, 320),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mini-program-picker-merchant')));
    await tester.pumpAndSettle();

    expect(find.text('业务静态页（语义化重构）'), findsOneWidget);
    expect(find.byTooltip('退出小程序'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);

    await tester.tap(find.byTooltip('退出小程序'));
    await tester.pumpAndSettle();
    expect(find.text('我的小程序'), findsOneWidget);

    await tester.tap(find.byKey(const Key('mini-program-picker-partner')));
    await tester.pumpAndSettle();
    expect(find.text('伙伴移动端'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('业务端使用共享 RuoQi 主题与默认强调色', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
    expect(app.theme!.colorScheme.primary, defaultAccentColor);
    expect(app.darkTheme!.colorScheme.primary, defaultAccentColor);
  });
}
