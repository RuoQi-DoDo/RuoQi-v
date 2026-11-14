import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/app_shell.dart';
import 'package:ruoqi_app_miniapp/pages/contacts/contacts_page.dart';
import 'package:ruoqi_app_miniapp/pages/discover/discover_page.dart';
import 'package:ruoqi_app_miniapp/pages/host/business_host_page.dart';
import 'package:ruoqi_app_miniapp/pages/profile/me_page.dart';
import 'package:ruoqi_app_miniapp/pages/settings/settings_page.dart';

void main() {
  testWidgets('替换业务首页后继续复用公共页面和小程序，并保留首页状态', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BusinessAppFrame(
        title: '其他业务',
        home: (_) => BusinessHostPage(
          homeLabel: '业务首页',
          homeBuilder: (context, scrollController) =>
              _ReplacementBusinessHome(scrollController: scrollController),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('其他业务工作台'), findsOneWidget);
    expect(find.text('客户模拟'), findsNothing);
    await tester.tap(find.text('增加业务计数'));
    await tester.pump();

    await tester.tap(find.text('通话'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calls-page')), findsOneWidget);
    await tester.tap(find.text('发现').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('discover-page')), findsOneWidget);
    await tester.tap(find.text('我').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('me-page')), findsOneWidget);
    await tester.drag(find.byKey(const Key('me-page')), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-page')), findsOneWidget);
    expect(find.text('界面与显示'), findsOneWidget);
    expect(find.text('账号安全'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings-back')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('业务首页'));
    await tester.pumpAndSettle();
    expect(find.text('业务计数：1'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('replacement-home-scroll')),
      const Offset(0, 320),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('customer-mini-program-picker')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('mini-program-picker-merchant')));
    await tester.pumpAndSettle();
    expect(find.text('业务静态页（语义化重构）'), findsOneWidget);
    await tester.tap(find.byTooltip('退出小程序'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('mini-program-picker-exit-swipe')),
      const Offset(0, -80),
    );
    await tester.pumpAndSettle();
    expect(find.text('业务计数：1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final (page, pageKey) in <(Widget, String)>[
    (const ContactsPage(), 'contacts-page'),
    (const DiscoverPage(), 'discover-page'),
    (const MePage(), 'me-page'),
    (const SettingsPage(), 'settings-page'),
  ]) {
    testWidgets('${page.runtimeType} 可作为独立路由运行', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pumpAndSettle();
      expect(find.byKey(Key(pageKey)), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('独立我的页面默认打开公共设置', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: MePage()));
    await tester.pumpAndSettle();
    await tester.drag(find.byKey(const Key('me-page')), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-page')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('新业务可指定退出后进入自己的登录路由', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BusinessAppFrame(
        title: '其他业务',
        home: (_) => BusinessHostPage(
          homeBuilder: (context, scrollController) =>
              _ReplacementBusinessHome(scrollController: scrollController),
          loginBuilder: (_) => const Scaffold(body: Text('其他业务登录')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('我').last);
    await tester.pumpAndSettle();
    await tester.drag(find.byKey(const Key('me-page')), const Offset(0, -240));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    await _confirmLogout(tester);
    expect(find.text('其他业务登录'), findsOneWidget);
    expect(find.byType(BusinessHostPage), findsNothing);
  });

  testWidgets('公共设置可将登出交给业务处理', (tester) async {
    var logoutCount = 0;
    await tester.pumpWidget(
      MaterialApp(home: SettingsPage(onLogout: () => logoutCount++)),
    );
    await tester.pumpAndSettle();
    await _confirmLogout(tester);
    expect(logoutCount, 1);
    expect(find.byKey(const Key('settings-page')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('公共宿主与页面不依赖 IM 业务实现', () {
    final offenders = <String>[];
    final directive = RegExp(
      r'''^(?:import|export|part)\s+['"]([^'"]+)['"]''',
      multiLine: true,
    );
    for (final name in [
      'host',
      'common',
      'contacts',
      'discover',
      'profile',
      'settings',
      'auth',
    ]) {
      for (final file in Directory(
        'lib/pages/$name',
      ).listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        for (final match in directive.allMatches(file.readAsStringSync())) {
          final target = match.group(1)!;
          final resolved = target.startsWith('package:')
              ? target
              : file.absolute.uri.resolve(target).path;
          if (resolved.contains('/pages/im/')) offenders.add(file.path);
        }
      }
    }
    expect(offenders, isEmpty);
  });
}

Future<void> _confirmLogout(WidgetTester tester) async {
  await tester.drag(
    find.descendant(
      of: find.byKey(const Key('settings-page')),
      matching: find.byType(ListView),
    ),
    const Offset(0, -1000),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('settings-logout')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('退出'));
  await tester.pumpAndSettle();
}

class _ReplacementBusinessHome extends StatefulWidget {
  const _ReplacementBusinessHome({required this.scrollController});

  final ScrollController scrollController;

  @override
  State<_ReplacementBusinessHome> createState() =>
      _ReplacementBusinessHomeState();
}

class _ReplacementBusinessHomeState extends State<_ReplacementBusinessHome> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('其他业务工作台')),
    body: ListView(
      key: const Key('replacement-home-scroll'),
      controller: widget.scrollController,
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        Text('业务计数：$_count'),
        TextButton(
          onPressed: () => setState(() => _count++),
          child: const Text('增加业务计数'),
        ),
      ],
    ),
  );
}
