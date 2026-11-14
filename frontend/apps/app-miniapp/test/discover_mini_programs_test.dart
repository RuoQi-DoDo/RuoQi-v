import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/app_shell.dart';
import 'package:ruoqi_app_miniapp/main.dart';
import 'package:ruoqi_app_miniapp/pages/discover/discover_page.dart';
import 'package:ruoqi_app_miniapp/pages/mini_programs/mini_programs_page.dart';

void main() {
  testWidgets('发现入口打开小程序并返回列表和原发现位置', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('host-tab-discover')));
    await tester.pumpAndSettle();
    final offset = await _openFromDiscover(tester);

    expect(find.byKey(const Key('mini-programs-page')), findsOneWidget);
    await tester.tap(find.byKey(const Key('mini-program-entry-merchant')));
    await tester.pumpAndSettle();
    expect(find.text('业务静态页（语义化重构）'), findsOneWidget);
    await tester.tap(find.byTooltip('退出小程序'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mini-programs-page')), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('discover-page')), findsOneWidget);
    expect(find.byKey(const Key('mini-programs-page')), findsNothing);
    expect(_discoverPosition(tester).pixels, offset);
    expect(
      find.byKey(const Key('discover-mini-programs')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('独立发现页面无需宿主回调也能打开真实小程序目录', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(const MaterialApp(home: DiscoverPage()));
    await tester.pumpAndSettle();
    await _openFromDiscover(tester);

    for (final id in ['ats', 'hr', 'merchant', 'partner', 'platform']) {
      expect(find.byKey(Key('mini-program-entry-$id')), findsOneWidget);
    }
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('目录支持中文和英文搜索、空结果和清空', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(
      BusinessAppFrame(title: 'test', home: (_) => const MiniProgramsPage()),
    );
    await tester.pumpAndSettle();
    final search = find.byKey(const Key('mini-programs-search'));

    await tester.enterText(search, '商户');
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('mini-program-entry-merchant')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('mini-program-entry-ats')), findsNothing);

    await tester.enterText(search, 'HR');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mini-program-entry-hr')), findsOneWidget);
    expect(find.byKey(const Key('mini-program-entry-merchant')), findsNothing);

    await tester.enterText(search, '不存在的小程序');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mini-programs-empty')), findsOneWidget);
    await tester.tap(find.byKey(const Key('mini-programs-search-clear')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(search).controller!.text, isEmpty);
    expect(find.byKey(const Key('mini-programs-empty')), findsNothing);
    for (final id in ['ats', 'hr', 'merchant', 'partner', 'platform']) {
      expect(find.byKey(Key('mini-program-entry-$id')), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('从发现启动 ATS 后退出返回原小程序列表', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(
      BusinessAppFrame(title: 'test', home: (_) => const DiscoverPage()),
    );
    await tester.pumpAndSettle();
    await _openFromDiscover(tester);
    await tester.tap(find.byKey(const Key('mini-program-entry-ats')));
    await tester.pumpAndSettle();
    expect(find.text('搜索岗位或关键词'), findsOneWidget);
    expect(find.byTooltip('退出小程序'), findsOneWidget);
    await tester.tap(find.byTooltip('退出小程序'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mini-programs-page')), findsOneWidget);
    expect(find.byKey(const Key('mini-program-entry-ats')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('发现页面允许业务覆盖小程序入口行为', (tester) async {
    _usePhoneSize(tester);
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(home: DiscoverPage(onOpenMiniPrograms: () => calls++)),
    );
    await tester.pumpAndSettle();
    await _openFromDiscover(tester);
    expect(calls, 1);
    expect(find.byKey(const Key('mini-programs-page')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ATS 系统返回先回小程序首页再退出到目录', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(
      BusinessAppFrame(title: 'test', home: (_) => const DiscoverPage()),
    );
    await tester.pumpAndSettle();
    await _openFromDiscover(tester);
    await tester.tap(find.byKey(const Key('mini-program-entry-ats')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('搜索岗位或关键词'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, '搜索职位、公司或技能'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('搜索岗位或关键词'), findsOneWidget);
    expect(find.byKey(const Key('mini-programs-page')), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mini-programs-page')), findsOneWidget);
    expect(find.byKey(const Key('mini-program-entry-ats')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(414, 896);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<double> _openFromDiscover(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const Key('discover-mini-programs')),
    200,
    scrollable: find.descendant(
      of: find.byKey(const Key('discover-page')),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pumpAndSettle();
  final offset = _discoverPosition(tester).pixels;
  await tester.tap(find.byKey(const Key('discover-mini-programs')));
  await tester.pumpAndSettle();
  return offset;
}

ScrollPosition _discoverPosition(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('discover-page'), skipOffstage: false),
        matching: find.byType(Scrollable),
        skipOffstage: false,
      ),
    )
    .position;
