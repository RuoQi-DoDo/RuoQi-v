import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/miniapp/ats/ats_miniapp.dart';
import 'package:ruoqi_app_miniapp/miniapp/ats/ats_routes.dart';
import 'package:ruoqi_app_miniapp/main.dart';

void main() {
  testWidgets('存在系统状态栏时不再绘制模拟状态栏', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(padding: const EdgeInsets.only(top: 24)),
            child: child!,
          );
        },
        home: AtsMiniProgram(onExit: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('9:41'), findsNothing);
    expect(find.byTooltip('小程序菜单'), findsOneWidget);
    expect(find.byTooltip('退出小程序'), findsOneWidget);
  });

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

    await tester.drag(
      find.byKey(const Key('mini-program-picker-exit-swipe')),
      const Offset(0, -80),
    );
    await tester.pump(const Duration(milliseconds: 250));
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

  testWidgets('客户首页下滑直接打开小程序选择页且不展示刷新 loading', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    double panelScale() {
      return tester
          .widget<Transform>(find.byKey(const Key('mini-program-panel-scale')))
          .transform
          .entry(0, 0);
    }

    final dragStart = tester.getCenter(
      find.byKey(const Key('customer-home-scroll')),
    );
    final gesture = await tester.startGesture(dragStart);
    await gesture.moveTo(
      dragStart + const Offset(0, 120),
      timeStamp: const Duration(milliseconds: 120),
    );
    await tester.pump();

    expect(find.byType(RefreshProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    final firstPullScale = panelScale();
    expect(firstPullScale, greaterThan(0.42));
    expect(firstPullScale, lessThan(1));

    await gesture.moveTo(
      dragStart + const Offset(0, 220),
      timeStamp: const Duration(milliseconds: 240),
    );
    await tester.pump();
    expect(find.byKey(const Key('mini-program-loading-dots')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const Key('customer-host-home'))).dy,
      greaterThan(0),
    );
    await gesture.up();
    await tester.pump();
    final openingTransform = tester.widget<Transform>(
      find.byKey(const Key('mini-program-panel-scale')),
    );
    final openingScale = openingTransform.transform.entry(0, 0);
    expect(openingScale, greaterThanOrEqualTo(firstPullScale));
    expect(openingScale, lessThanOrEqualTo(1));
    await tester.pumpAndSettle();

    expect(find.text('搜索小程序'), findsOneWidget);
    expect(find.byKey(const Key('mini-program-loading-dots')), findsNothing);
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

    await tester.drag(
      find.byKey(const Key('mini-program-picker-exit-swipe')),
      const Offset(0, -80),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('客户模拟'), findsOneWidget);
    expect(find.byKey(const Key('customer-mini-program-picker')), findsNothing);
  });

  testWidgets('更多和我的小程序页面可打开并返回', (tester) async {
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

    await tester.tap(find.text('更多'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('mini-program-collection-recent')),
      findsOneWidget,
    );
    expect(find.text('最近使用的小程序'), findsOneWidget);
    expect(
      find.byKey(const Key('mini-program-collection-list')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('mini-program-collection-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的小程序'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('mini-program-collection-mine')),
      findsOneWidget,
    );
    expect(find.text('我的小程序'), findsOneWidget);

    await tester.tap(find.byKey(const Key('mini-program-collection-back')));
    await tester.pumpAndSettle();
    expect(find.text('最近'), findsOneWidget);
  });

  testWidgets('通讯录、发现、我三个底栏页面可切换', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('通讯录'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('contacts-page')), findsOneWidget);
    expect(find.text('新的朋友'), findsOneWidget);
    expect(find.text('群聊'), findsOneWidget);

    await tester.tap(find.text('发现').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('discover-page')), findsOneWidget);
    expect(find.text('朋友圈'), findsOneWidget);
    expect(find.text('视频号'), findsOneWidget);
    expect(find.text('小程序'), findsOneWidget);

    await tester.tap(find.text('我').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('me-page')), findsOneWidget);
    expect(find.text('Jengro Woo'), findsOneWidget);
    expect(find.text('服务'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('我可以进入设置页，通知开关与退出入口可用', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('我').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-page')), findsOneWidget);
    expect(find.text('账号与安全'), findsOneWidget);
    expect(find.text('消息通知'), findsOneWidget);
    expect(find.text('个人信息与权限'), findsOneWidget);

    final notificationSwitch = find.descendant(
      of: find.byKey(const Key('settings-message-notifications')),
      matching: find.byType(Switch),
    );
    expect(tester.widget<Switch>(notificationSwitch).value, isTrue);
    await tester.tap(notificationSwitch);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(notificationSwitch).value, isFalse);

    final settingsList = find.descendant(
      of: find.byKey(const Key('settings-page')),
      matching: find.byType(ListView),
    );
    await tester.drag(settingsList, const Offset(0, -360));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-logout')));
    await tester.pumpAndSettle();

    expect(find.text('退出后将返回登录页面，是否继续？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('me-page')), findsOneWidget);
  });

  testWidgets('正常模式与黑色模式可切换并覆盖通讯录', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    await tester.tap(find.text('通讯录'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(
        tester.element(find.byKey(const Key('contacts-page'))),
      ).brightness,
      Brightness.light,
    );

    await tester.tap(find.text('我').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();

    final darkModeSwitch = find.descendant(
      of: find.byKey(const Key('settings-dark-mode')),
      matching: find.byType(Switch),
    );
    expect(tester.widget<Switch>(darkModeSwitch).value, isFalse);
    await tester.tap(darkModeSwitch);
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(
      Theme.of(
        tester.element(find.byKey(const Key('settings-page'))),
      ).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byKey(const Key('settings-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('通讯录'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(
        tester.element(find.byKey(const Key('contacts-page'))),
      ).brightness,
      Brightness.dark,
    );
  });

  testWidgets('通讯录、发现、我和设置页在小屏下无布局异常', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('通讯录'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('发现').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('我').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.drag(find.byKey(const Key('me-page')), const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
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
