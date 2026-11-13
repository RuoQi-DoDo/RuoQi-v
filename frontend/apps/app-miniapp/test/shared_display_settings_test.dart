import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/app_shell.dart';
import 'package:ruoqi_app_miniapp/appearance.dart';
import 'package:ruoqi_app_miniapp/localization.dart';
import 'package:ruoqi_app_miniapp/main.dart';
import 'package:ruoqi_app_miniapp/miniapp/ats/ats_miniapp.dart';
import 'package:ruoqi_app_miniapp/miniapp/ats/ats_style.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/common.dart';
import 'package:ruoqi_app_miniapp/miniapp/hr/hr_miniapp.dart';
import 'package:ruoqi_app_miniapp/miniapp/hr/hr_style.dart';
import 'package:ruoqi_app_miniapp/pages/display/display_settings_page.dart';

void main() {
  test('字体默认对齐微信标准的最终显示字号', () {
    final controller = BusinessThemeController();
    addTearDown(controller.dispose);

    expect(controller.fontScale, defaultFontScale);
    expect(defaultFontScale, 0.85);
    expect(minFontScale, 0.8);
    expect(defaultFontScale - minFontScale, closeTo(0.05, 0.0001));
  });

  test('字体大小可在微信标准字号下再调小一档', () {
    final controller = BusinessThemeController();
    addTearDown(controller.dispose);

    controller.setFontScale(0.7);
    expect(controller.fontScale, minFontScale);

    controller.setFontScale(defaultFontScale);
    expect(controller.fontScale, 0.85);
  });

  testWidgets('显示设置恢复默认时回到微信标准字号档', (tester) async {
    await tester.pumpWidget(
      BusinessAppFrame(title: 'test', home: (_) => const DisplaySettingsPage()),
    );
    await tester.pumpAndSettle();

    final settings = BusinessThemeScope.of(
      tester.element(find.byKey(const Key('display-settings-page'))),
    );
    expect(find.text('标准'), findsOneWidget);
    settings.setFontScale(maxFontScale);
    await tester.pumpAndSettle();
    expect(settings.fontScale, maxFontScale);
    expect(find.text('标准'), findsNothing);
    expect(find.text('130%'), findsOneWidget);

    await tester.tap(find.text('恢复默认'));
    await tester.pumpAndSettle();

    expect(settings.fontScale, defaultFontScale);
    expect(find.text('标准'), findsOneWidget);
    expect(find.text('85%'), findsNothing);
    final slider = tester.widget<Slider>(
      find.byKey(const Key('display-font-size')),
    );
    expect(slider.value, defaultFontScale);
    expect(slider.min, 0.8);
    expect(slider.divisions, 10);
  });

  testWidgets('公共显示页更新已打开的小程序并保留内部路由和状态', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BusinessAppFrame(
        title: 'test',
        home: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MiniProgramShell.route(
                title: '商户',
                child: const _MiniProgramProbe(),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('increment'));
    await tester.pump();
    await tester.tap(find.byTooltip('小程序菜单'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('设置'));
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('display-theme-dark')));
    await tester.pumpAndSettle();
    final controller = BusinessThemeScope.of(
      tester.element(find.byKey(const Key('display-settings-page'))),
    );
    controller.setFontScale(1.2);
    await tester.pumpAndSettle();
    final language = find.byKey(const Key('display-language-en'));
    await tester.ensureVisible(language);
    await tester.tap(language);
    await tester.pumpAndSettle();
    expect(find.text('Appearance & display'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('display-settings-page')),
        matching: find.byType(BackButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Count: 1'), findsOneWidget);
    final probe = tester.element(find.byKey(const Key('mini-program-probe')));
    expect(Theme.of(probe).brightness, Brightness.dark);
    expect(Localizations.localeOf(probe).languageCode, 'en');
    expect(MediaQuery.textScalerOf(probe).scale(20), 24);
    expect(find.byTooltip('Close mini-program'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final (name, miniProgram, background)
      in <(String, Widget, Color Function(BuildContext))>[
        (
          'ATS',
          const AtsMiniProgram(),
          (context) => AtsColors.resolve(context, AtsColors.background),
        ),
        (
          'HR',
          const HrMiniProgram(),
          (context) => HrColors.resolve(context, HrColors.bg),
        ),
      ]) {
    testWidgets('$name 跟随宿主主题切换并使用深色语义色板', (tester) async {
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        BusinessAppFrame(title: name, home: (_) => miniProgram),
      );
      await tester.pumpAndSettle();
      final scaffold = find
          .descendant(
            of: find.byWidget(miniProgram),
            matching: find.byType(Scaffold),
          )
          .first;
      final before = tester.element(scaffold);
      final lightBackground = background(before);
      final settings = BusinessThemeScope.of(before);
      settings.setMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      final after = tester.element(scaffold);
      expect(Theme.of(after).brightness, Brightness.dark);
      expect(background(after), isNot(lightBackground));
      expect(background(after).computeLuminance(), lessThan(0.1));
      settings.setLocale(const Locale('en'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Close mini-program'), findsOneWidget);
      expect(
        find.text(name == 'ATS' ? 'Recruitment' : 'HR workspace'),
        findsOneWidget,
      );
      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('小屏英文及放大字体下可以从宿主设置进入公共页面', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();
    final settings = BusinessThemeScope.of(
      tester.element(find.byType(Scaffold).first),
    );
    settings.setLocale(const Locale('en'));
    settings.setFontScale(1.3);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Me'));
    await tester.pumpAndSettle();
    await tester.drag(find.byKey(const Key('me-page')), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    expect(find.text('Appearance & display'), findsOneWidget);
    await tester.tap(find.text('Account security'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('account-security-page')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('屏幕方向选择调用原生方向接口', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final controller = BusinessThemeController();
    addTearDown(controller.dispose);
    await controller.setOrientation(AppOrientation.landscape);
    expect(calls.last.method, 'SystemChrome.setPreferredOrientations');
    expect(calls.last.arguments, [
      'DeviceOrientation.landscapeLeft',
      'DeviceOrientation.landscapeRight',
    ]);
    await controller.setOrientation(AppOrientation.system);
    expect(calls.last.arguments, isEmpty);
  });
}

class _MiniProgramProbe extends StatefulWidget {
  const _MiniProgramProbe();

  @override
  State<_MiniProgramProbe> createState() => _MiniProgramProbeState();
}

class _MiniProgramProbeState extends State<_MiniProgramProbe> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('mini-program-probe'),
    body: Column(
      children: [
        Text(AppLocalizations.of(context).text('计数：$_count', 'Count: $_count')),
        TextButton(
          onPressed: () => setState(() => _count++),
          child: const Text('increment'),
        ),
      ],
    ),
  );
}
