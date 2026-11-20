import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ruoqi_app_miniapp/appearance.dart';
import 'package:ruoqi_app_miniapp/main.dart';
import 'package:ruoqi_app_miniapp/pages/im/im_chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('应用启动直接进入 AI 页面', (tester) async {
    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-page')), findsOneWidget);
    expect(find.text('欢迎使用 RuoQi'), findsNothing);
    expect(find.byKey(const Key('im-welcome-continue')), findsNothing);
    expect(find.byKey(const Key('phone-login-page')), findsNothing);
    expect(find.byKey(const Key('phone-number-input')), findsNothing);
    expect(find.byKey(const Key('host-tab-ai')), findsNothing);
    expect(find.byKey(const Key('host-tab-home')), findsNothing);
  });

  testWidgets('IM 首页首屏展示聊天并可滚动查看全部 20 条', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: ImChatPage()));
    await tester.pumpAndSettle();

    for (final chat in [
      '企业直聘',
      '佳佳',
      '文件传输助手',
      '招聘交流群',
      '腾讯新闻',
      '张老师',
      '林小满',
      '项目协作群',
      '服务通知',
      'RuoQi 助手',
    ]) {
      expect(find.text(chat), findsOneWidget);
    }
    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('customer-home-scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.maxScrollExtent, greaterThan(0));

    for (final chat in [
      '王工',
      '产品设计群',
      '系统提醒',
      '陈一鸣',
      '运营协作群',
      '刘洋',
      '订阅号消息',
      '何川',
      '客户服务',
      '招聘助手',
    ]) {
      await tester.scrollUntilVisible(
        find.text(chat),
        240,
        scrollable: find.descendant(
          of: find.byKey(const Key('customer-home-scroll')),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text(chat), findsOneWidget);
    }
  });

  testWidgets('AI 设置页仅展示模型和界面与显示', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-history')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-history-settings')), findsOneWidget);
    await tester.tap(find.byKey(const Key('ai-history-settings')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-ai-model')), findsOneWidget);
    expect(find.text('模型'), findsOneWidget);
    expect(find.text('界面与显示'), findsOneWidget);
    expect(find.text('账号安全'), findsNothing);
    expect(find.text('通知'), findsNothing);
    expect(find.byKey(const Key('settings-logout')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('客户小程序选择页只展示 Tospino', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('ai-home-pull-listener')),
      const Offset(0, 320),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tospino'), findsNWidgets(2));
    expect(
      find.byKey(const Key('mini-program-picker-tospino')),
      findsOneWidget,
    );
    for (final id in ['ats', 'hr', 'merchant', 'platform']) {
      expect(find.byKey(Key('mini-program-picker-$id')), findsNothing);
    }
  });

  testWidgets('业务端使用共享 RuoQi 主题与默认强调色', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
    expect(app.theme!.colorScheme.primary, defaultAccentColor);
    expect(app.darkTheme!.colorScheme.primary, defaultAccentColor);
  });

  testWidgets('应用首次打开 AI 首页时立即同步状态栏样式', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pump();

    final page = find.byKey(const Key('ai-page'));
    final pageTheme = Theme.of(tester.element(page));
    final overlay = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byKey(const Key('ai-system-overlay')),
    );
    expect(overlay.value.statusBarColor, pageTheme.colorScheme.surface);
    expect(overlay.value.statusBarIconBrightness, Brightness.dark);
    expect(overlay.value.statusBarBrightness, Brightness.light);
    expect(overlay.value.systemStatusBarContrastEnforced, isFalse);
  });

  testWidgets('客户首页不再展示宿主底部导航', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-page')), findsOneWidget);
    for (final tab in ['ai', 'home', 'discover', 'me']) {
      expect(find.byKey(Key('host-tab-$tab')), findsNothing);
    }
  });
}
