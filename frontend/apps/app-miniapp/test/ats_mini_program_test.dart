import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/miniapp/ats/ats_miniapp.dart';
import 'package:ruoqi_app_miniapp/miniapp/ats/ats_routes.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_capsule_overlay.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_navigation_bar.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_status_bar.dart';
import 'package:ruoqi_app_miniapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'finders.dart';

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
    expect(findMaterialTooltip('小程序菜单'), findsOneWidget);
    expect(findMaterialTooltip('退出小程序'), findsOneWidget);
    expect(find.byType(MiniProgramCapsuleOverlay), findsOneWidget);
    expect(find.byType(MiniProgramNavigationBar), findsNothing);
  });

  testWidgets('企业直聘上滑后状态栏取消绿色底色', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: AtsMiniProgram()));
    await tester.pumpAndSettle();

    final before = tester
        .widget<MiniProgramStatusBar>(find.byType(MiniProgramStatusBar))
        .backgroundColor;
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    final after = tester
        .widget<MiniProgramStatusBar>(find.byType(MiniProgramStatusBar))
        .backgroundColor;
    expect(after, isNot(before));
    expect(tester.takeException(), isNull);
  });

  testWidgets('应用默认打开 AI 首页且小程序选择页仅展示 Tospino', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-page')), findsOneWidget);
    expect(find.byKey(const Key('customer-home-scroll')), findsNothing);
    expect(find.text('客户模拟'), findsNothing);
    expect(find.text('最近使用的小程序'), findsNothing);
    expect(find.text('下拉打开最近使用的小程序'), findsNothing);
    expect(find.text('搜索'), findsNothing);
    expect(find.text('搜索岗位或关键词'), findsNothing);

    await tester.drag(
      find.byKey(const Key('ai-home-pull-listener')),
      const Offset(0, 320),
    );
    await tester.pumpAndSettle();

    expect(find.text('搜索小程序'), findsOneWidget);
    expect(
      find.byKey(const Key('customer-mini-program-picker')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('mini-program-picker-tospino')),
      findsOneWidget,
    );
    for (final id in ['ats', 'hr', 'merchant', 'platform']) {
      expect(find.byKey(Key('mini-program-picker-$id')), findsNothing);
    }

    await tester.drag(
      find.byKey(const Key('mini-program-picker-exit-swipe')),
      const Offset(0, -80),
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-page')), findsOneWidget);
  });

  testWidgets('小程序底部导航与招聘者身份可用', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
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

  testWidgets('首页搜索栏与轮播图保持视觉间距', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();
    await _openAts(tester);

    final searchBar = find.byKey(const Key('ats-home-search'));
    final firstBanner = find.byKey(const ValueKey('ats-home-banner-card-0'));
    expect(searchBar, findsOneWidget);
    expect(firstBanner, findsOneWidget);

    final gap =
        tester.getTopLeft(firstBanner).dy - tester.getBottomLeft(searchBar).dy;
    expect(gap, greaterThanOrEqualTo(24));
  });

  testWidgets('AI 首页下滑打开小程序选择页，聊天页不再触发', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();
    double panelScale() {
      return tester
          .widget<Transform>(find.byKey(const Key('mini-program-panel-scale')))
          .transform
          .entry(0, 0);
    }

    final dragStart = tester.getCenter(
      find.byKey(const Key('ai-home-pull-listener')),
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
    expect(findMaterialTooltip('关闭'), findsNothing);

    expect(
      find.byKey(const Key('mini-program-picker-tospino')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('mini-program-picker-ats')), findsNothing);
    await tester.drag(
      find.byKey(const Key('mini-program-picker-exit-swipe')),
      const Offset(0, -80),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-page')), findsOneWidget);
    expect(find.byKey(const Key('customer-mini-program-picker')), findsNothing);
  });

  testWidgets('小程序选择页是子视图，上滑回到 AI 首页', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('ai-home-pull-listener')),
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

    expect(find.byKey(const Key('ai-page')), findsOneWidget);
    expect(find.byKey(const Key('customer-mini-program-picker')), findsNothing);
  });

  testWidgets('更多和我的小程序页面可打开并返回', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('ai-home-pull-listener')),
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

  testWidgets('AI 为默认首页且宿主底栏已隐藏', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-page')), findsOneWidget);
    expect(find.byKey(const Key('ai-brand-mark')), findsOneWidget);
    expect(find.text('你好，我是 RuoQi'), findsOneWidget);
    expect(find.text('发消息或按住说话'), findsOneWidget);
    for (final tab in ['ai', 'home', 'discover', 'me']) {
      expect(find.byKey(Key('host-tab-$tab')), findsNothing);
    }
  });

  testWidgets('未配置 DeepSeek 时提示先完成 API 设置', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('ai-composer')), '帮我梳理今天的工作重点');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pumpAndSettle();
    final snackBar = find.byType(SnackBar);
    expect(snackBar, findsOneWidget);
    expect(
      find.descendant(of: snackBar, matching: find.textContaining('DeepSeek')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('ai-typing-indicator')), findsNothing);
  });

  testWidgets('AI 左上角打开 DeepSeek 式历史侧边栏并支持管理', (tester) async {
    final now = DateTime.now();
    SharedPreferences.setMockInitialValues({
      'deepseek_chat_history_v1': jsonEncode([
        {
          'id': 'conversation-today',
          'title': '如何提高招聘沟通效率',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'pinned': false,
          'messages': [
            {'role': 'user', 'content': '如何提高招聘沟通效率'},
            {'role': 'assistant', 'content': '可以从明确目标开始。'},
          ],
        },
        {
          'id': 'conversation-yesterday',
          'title': '帮我润色职位描述',
          'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
          'pinned': false,
          'messages': [
            {'role': 'user', 'content': '帮我润色职位描述'},
            {'role': 'assistant', 'content': '可以，把原文发给我。'},
          ],
        },
        {
          'id': 'conversation-week',
          'title': '整理本周工作重点',
          'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
          'updatedAt': now.subtract(const Duration(days: 3)).toIso8601String(),
          'pinned': false,
          'messages': [
            {'role': 'user', 'content': '整理本周工作重点'},
            {'role': 'assistant', 'content': '先确认最重要的目标。'},
          ],
        },
      ]),
    });
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();
    final welcomeTitle = find.text('你好，我是 RuoQi');
    final initialTitleX = tester.getTopLeft(welcomeTitle).dx;
    await tester.tap(find.byKey(const Key('ai-history')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-history-drawer')), findsOneWidget);
    expect(
      tester.getTopLeft(welcomeTitle).dx,
      greaterThan(initialTitleX + 200),
    );
    expect(
      tester.widget<Opacity>(find.byKey(const Key('ai-main-fade'))).opacity,
      closeTo(0.3, 0.01),
    );
    expect(find.text('搜索对话内容...'), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);
    expect(find.text('昨天'), findsOneWidget);
    expect(find.text('7 天内'), findsOneWidget);
    expect(find.text('如何提高招聘沟通效率'), findsOneWidget);
    expect(find.byKey(const Key('ai-history-settings')), findsOneWidget);
    expect(find.text('Jengro Woo'), findsNothing);
    expect(find.byKey(const Key('ai-history-model')), findsOneWidget);
    expect(find.text('当前模型'), findsOneWidget);

    await tester.dragFrom(const Offset(280, 420), const Offset(-260, 0));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-history-drawer')), findsNothing);
    expect(tester.getTopLeft(welcomeTitle).dx, closeTo(initialTitleX, 0.1));
    expect(
      tester.widget<Opacity>(find.byKey(const Key('ai-main-fade'))).opacity,
      1,
    );

    await tester.tap(find.byKey(const Key('ai-history')));
    await tester.pumpAndSettle();
    await tester.longPress(find.text('如何提高招聘沟通效率'));
    await tester.pumpAndSettle();
    expect(find.text('重命名'), findsOneWidget);
    expect(find.text('置顶'), findsOneWidget);
    expect(find.text('删除'), findsOneWidget);

    await tester.tap(find.text('重命名'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('ai-history-rename-input')),
      '招聘沟通优化',
    );
    await tester.tap(find.byKey(const Key('ai-history-rename-confirm')));
    await tester.pumpAndSettle();
    final historyPreferences = await SharedPreferences.getInstance();
    expect(
      historyPreferences.getString('deepseek_chat_history_v1'),
      contains('招聘沟通优化'),
    );
    expect(find.text('招聘沟通优化'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('ai-history-search')), '职位');
    await tester.pumpAndSettle();
    expect(find.text('帮我润色职位描述'), findsOneWidget);
    expect(find.text('如何提高招聘沟通效率'), findsNothing);

    await tester.tap(find.byKey(const Key('ai-history-settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-page')), findsOneWidget);
  });

  testWidgets('设置页仅展示模型和界面与显示', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ai-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-history-settings')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-page')), findsOneWidget);
    expect(find.text('模型'), findsOneWidget);
    expect(find.text('界面与显示'), findsOneWidget);
    expect(find.text('账号安全'), findsNothing);
    expect(find.text('通知'), findsNothing);
    expect(find.text('个人信息与权限'), findsNothing);
    expect(find.byKey(const Key('settings-logout')), findsNothing);

    await tester.tap(find.byKey(const Key('settings-back')));
    await tester.pumpAndSettle();
    await tester.dragFrom(const Offset(280, 420), const Offset(-260, 0));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-page')), findsOneWidget);
  });

  testWidgets('设置页模型入口可进入 DeepSeek API 模型页', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-history-settings')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-ai-model')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-model-settings-page')), findsOneWidget);
    expect(find.byKey(const Key('deepseek-api-key')), findsOneWidget);
    expect(find.byKey(const Key('deepseek-api-key-connect')), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('deepseek-api-key')))
          .obscureText,
      isTrue,
    );

    await tester.tap(find.byKey(const Key('deepseek-api-key-connect')));
    await tester.pumpAndSettle();
    expect(find.text('请输入 DeepSeek API Key'), findsOneWidget);

    await tester.tap(find.byKey(const Key('deepseek-api-key-visibility')));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('deepseek-api-key')))
          .obscureText,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('ai-model-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-page')), findsOneWidget);
    expect(find.text('未选择'), findsOneWidget);
  });

  testWidgets('从设置返回并切换 AI 页面时不恢复输入框焦点', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();

    final composer = find.byKey(const Key('ai-composer'), skipOffstage: false);
    final editable = find.descendant(
      of: composer,
      matching: find.byType(EditableText, skipOffstage: false),
      skipOffstage: false,
    );
    final holdToTalk = find.byKey(const Key('ai-hold-to-talk'));
    expect(holdToTalk, findsOneWidget);
    await tester.tap(holdToTalk);
    await tester.pump();
    expect(find.byKey(const Key('ai-hold-to-talk')), findsNothing);
    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.text('你好，我是 RuoQi'));
    await tester.pump();
    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isFalse);
    expect(find.byKey(const Key('ai-hold-to-talk')), findsOneWidget);

    await tester.tap(holdToTalk);
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('host-tab-ai')), findsNothing);
    expect(
      tester.getBottomLeft(find.byKey(const Key('ai-composer-card'))).dy,
      lessThan(600),
    );
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ai-history')));
    await tester.pumpAndSettle();
    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isFalse);

    await tester.tap(find.byKey(const Key('ai-history-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-back')));
    await tester.pumpAndSettle();

    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isFalse);
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('AI 语音按钮切换到按住说话模式并可返回键盘', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();

    final voiceGesture = tester.widget<GestureDetector>(
      find.byKey(const Key('ai-composer-gesture')),
    );
    expect(voiceGesture.onLongPressStart, isNotNull);
    expect(voiceGesture.onLongPressMoveUpdate, isNotNull);

    await tester.tap(find.byKey(const Key('ai-voice-mode-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-voice-hold-button')), findsOneWidget);
    expect(find.text('按住说话'), findsOneWidget);
    expect(find.byKey(const Key('ai-composer')), findsNothing);

    await tester.tap(find.byKey(const Key('ai-voice-mode-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-voice-hold-button')), findsNothing);
    expect(find.byKey(const Key('ai-composer')), findsOneWidget);
  });

  testWidgets('AI 长按语音立即显示录音面板并支持上滑取消', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('ai-voice-mode-toggle'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.byKey(const Key('ai-recording-panel')), findsOneWidget);
    expect(find.text('松手发送，上滑取消'), findsOneWidget);

    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    expect(find.text('松开取消'), findsOneWidget);

    await gesture.up();
    await tester.pump();
    expect(find.byKey(const Key('ai-recording-panel')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('正常模式与黑色模式可切换并覆盖 AI 页', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    expect(
      Theme.of(tester.element(find.byKey(const Key('ai-page')))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byKey(const Key('ai-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-history-settings')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('界面与显示'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('display-theme-row')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('display-theme-dark')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(
      Theme.of(tester.element(find.byKey(const Key('display-settings-page'))))
          .brightness,
      Brightness.dark,
    );

    await tester.tap(find.byKey(const Key('display-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-back')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byKey(const Key('ai-page')))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('AI 与小程序选择页在小屏下无布局异常', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const Key('ai-home-pull-listener')),
      const Offset(0, 320),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('mini-program-picker-tospino')),
      findsOneWidget,
    );
    await tester.drag(
      find.byKey(const Key('mini-program-picker-exit-swipe')),
      const Offset(0, -80),
    );
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
  await tester.pumpWidget(const MaterialApp(home: AtsMiniProgram()));
  await tester.pumpAndSettle();
}
