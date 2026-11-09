import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_business_app/mini-program/ats/ats_mini_program.dart';
import 'package:ruoqi_business_app/mini-program/ats/ats_routes.dart';
import 'package:ruoqi_business_app/main.dart';

void main() {
  testWidgets('应用默认打开客户首页，再进入小程序并可退出', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    expect(find.text('客户模拟'), findsOneWidget);
    expect(find.text('最近使用的小程序'), findsNothing);
    expect(find.text('下拉打开最近使用的小程序'), findsNothing);
    expect(find.text('搜索'), findsNothing);
    expect(find.text('搜索岗位或关键词'), findsNothing);

    await _openAtsFromCustomer(tester);

    expect(find.text('欢迎来到企业直聘'), findsNothing);
    expect(find.text('搜索岗位或关键词'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('分类'), findsOneWidget);
    expect(find.text('消息'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byTooltip('退出小程序'), findsOneWidget);

    final tabCenters = [
      for (final label in ['首页', '分类', '消息', '我的'])
        tester.getCenter(find.text(label)).dx,
    ];
    expect(tabCenters.first, greaterThan(40));
    expect(tabCenters.last, lessThan(374));
    for (var i = 1; i < tabCenters.length; i++) {
      expect(tabCenters[i] - tabCenters[i - 1], closeTo(103.5, 2));
    }

    await tester.drag(
      find.byKey(const Key('mini-program-exit-swipe')),
      const Offset(0, -80),
    );
    await tester.pumpAndSettle();

    expect(find.text('搜索岗位或关键词'), findsNothing);
    expect(find.text('搜索小程序'), findsOneWidget);
    expect(
      find.byKey(const Key('customer-mini-program-picker')),
      findsOneWidget,
    );

    await tester.drag(find.text('RuoQi'), const Offset(0, -80));
    await tester.pumpAndSettle();
    expect(find.text('客户模拟'), findsOneWidget);
  });

  testWidgets('小程序底部导航与招聘者身份可用', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();
    await _openAts(tester);

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();
    expect(find.text('游客模式'), findsOneWidget);
    expect(find.text('未登录 / 注册'), findsOneWidget);
    expect(find.text('求职服务'), findsOneWidget);

    await tester.tap(find.text('切换身份'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('招聘者').last);
    await tester.pumpAndSettle();

    expect(find.text('招聘管理'), findsOneWidget);
    expect(find.text('公司管理'), findsOneWidget);
  });

  testWidgets('ATS 右上角胶囊退出按钮返回客户首页', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();
    await _openAts(tester);

    await tester.tap(find.byTooltip('退出小程序'));
    await tester.pumpAndSettle();

    expect(find.text('搜索小程序'), findsOneWidget);
    expect(find.text('搜索岗位或关键词'), findsNothing);
  });

  testWidgets('客户首页下滑打开微信式小程序选择页', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('customer-home-scroll')),
      const Offset(0, 320),
    );
    await tester.pumpAndSettle();

    expect(find.text('搜索小程序'), findsOneWidget);
    expect(find.text('我的小程序'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byTooltip('关闭'), findsNothing);

    await tester.tap(find.byKey(const Key('mini-program-picker-ats')));
    await tester.pumpAndSettle();
    expect(find.text('搜索岗位或关键词'), findsOneWidget);
  });

  testWidgets('小程序选择页是子视图，上滑回到客户首页', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('customer-home-scroll')),
      const Offset(0, 320),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('customer-mini-program-picker')),
      findsOneWidget,
    );

    await tester.drag(find.text('RuoQi'), const Offset(0, -80));
    await tester.pumpAndSettle();

    expect(find.text('客户模拟'), findsOneWidget);
    expect(find.byKey(const Key('customer-mini-program-picker')), findsNothing);
  });

  testWidgets('参考项目的全部页面路由均可构建', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final route in AtsRoute.values) {
      final controller = AtsAppController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390,
              height: 760,
              child: AtsPageRouter.build(route, controller),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '页面 ${route.path} 构建失败');
      controller.dispose();
    }
  });
}

Future<void> _openAts(WidgetTester tester) async {
  await _openAtsFromCustomer(tester);
}

Future<void> _openAtsFromCustomer(WidgetTester tester) async {
  await tester.drag(
    find.byKey(const Key('customer-home-scroll')),
    const Offset(0, 320),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('mini-program-picker-ats')));
  await tester.pumpAndSettle();
}
