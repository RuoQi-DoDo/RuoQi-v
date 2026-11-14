import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/main.dart';

void main() {
  testWidgets('IM 应用语言页切换英文并进入英文聊天列表', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    expect(find.text('欢迎使用 RuoQi'), findsOneWidget);
    expect(find.text('同意并继续'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);

    await tester.tap(find.byKey(const Key('im-welcome-language')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-language-page')), findsOneWidget);
    expect(find.text('应用语言'), findsOneWidget);
    expect(find.text('可用语言'), findsOneWidget);
    expect(find.text('其他语言'), findsOneWidget);
    expect(find.text('英语'), findsOneWidget);
    expect(find.byKey(const Key('app-language-en')), findsOneWidget);
    expect(find.byKey(const Key('app-language-af')), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-language-af')));
    await tester.pump();
    expect(find.text('南非荷兰语暂未开放，当前仅支持简体中文和 English。'), findsOneWidget);
    expect(find.byKey(const Key('app-language-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-language-en')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to RuoQi'), findsOneWidget);
    expect(find.text('Agree and continue'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('隐私政策'), findsNothing);
    expect(find.text('同意并继续'), findsNothing);
    expect(find.byTooltip('Accessibility'), findsOneWidget);
    expect(find.byTooltip('More'), findsOneWidget);

    await tester.tap(find.byKey(const Key('im-welcome-language')));
    await tester.pumpAndSettle();
    expect(find.text('App language'), findsOneWidget);
    expect(find.text('应用语言'), findsNothing);
    expect(find.text('Available languages'), findsOneWidget);
    expect(find.text('More languages'), findsOneWidget);
    expect(find.text('Simplified Chinese'), findsOneWidget);
    expect(find.text('英语'), findsNothing);
    await tester.tap(find.byKey(const Key('app-language-close')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('im-welcome-continue')));
    await tester.pumpAndSettle();

    expect(find.text('Enter phone number'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('phone-number-input')),
      '13800138000',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('phone-next')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('phone-verification-page')), findsOneWidget);
    expect(find.text('Verify your phone number'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('phone-code-input')), '123456');
    await tester.pump();
    await tester.tap(find.byKey(const Key('phone-code-verify')));
    await tester.pumpAndSettle();

    expect(find.text('Enterprise Recruiting'), findsOneWidget);
    expect(find.text('File Transfer'), findsOneWidget);
    expect(
      find.text('Interview: Shanghai Shijia Technology wants to meet you'),
      findsOneWidget,
    );
    expect(find.byTooltip('Search'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('IM 应用语言页可以切回简体中文', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('im-welcome-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('app-language-en')));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to RuoQi'), findsOneWidget);

    await tester.tap(find.byKey(const Key('im-welcome-language')));
    await tester.pumpAndSettle();
    expect(find.text('App language'), findsOneWidget);
    await tester.tap(find.byKey(const Key('app-language-zh')));
    await tester.pumpAndSettle();

    expect(find.text('欢迎使用 RuoQi'), findsOneWidget);
    expect(find.text('同意并继续'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('已登录启动跳过欢迎页直接进入 IM 首页', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp(initiallyAuthenticated: true));
    await tester.pumpAndSettle();

    expect(find.text('欢迎使用 RuoQi'), findsNothing);
    expect(find.byKey(const Key('phone-login-page')), findsNothing);
    expect(find.text('企业直聘'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('应用语言页展示完整语言列表，未开放语言不可切换', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('im-welcome-language')));
    await tester.pumpAndSettle();

    final list = find.byKey(const Key('app-language-list'));
    await tester.scrollUntilVisible(
      find.byKey(const Key('app-language-zu')),
      500,
      scrollable: find.descendant(of: list, matching: find.byType(Scrollable)),
    );

    expect(find.byKey(const Key('app-language-zu')), findsOneWidget);
    await tester.tap(find.byKey(const Key('app-language-zu')));
    await tester.pump();
    expect(find.text('祖鲁语暂未开放，当前仅支持简体中文和 English。'), findsOneWidget);
    expect(find.byKey(const Key('app-language-page')), findsOneWidget);
    expect(find.text('应用语言'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('设备语言支持时默认跟随设备语言', (tester) async {
    tester.binding.platformDispatcher
      ..localeTestValue = const Locale('en')
      ..localesTestValue = const [Locale('en')];
    addTearDown(() {
      tester.binding.platformDispatcher
        ..localeTestValue = const Locale('zh')
        ..localesTestValue = const [Locale('zh')];
    });

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to RuoQi'), findsOneWidget);
    expect(find.text('Agree and continue'), findsOneWidget);
    await tester.tap(find.byKey(const Key('im-welcome-language')));
    await tester.pumpAndSettle();

    final deviceLanguage = find.byKey(const Key('app-language-device'));
    expect(deviceLanguage, findsOneWidget);
    expect(
      find.descendant(
        of: deviceLanguage,
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('设备语言不支持时默认回退简体中文', (tester) async {
    tester.binding.platformDispatcher
      ..localeTestValue = const Locale('fr')
      ..localesTestValue = const [Locale('fr')];
    addTearDown(() {
      tester.binding.platformDispatcher
        ..localeTestValue = const Locale('zh')
        ..localesTestValue = const [Locale('zh')];
    });

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    expect(find.text('欢迎使用 RuoQi'), findsOneWidget);
    expect(find.text('同意并继续'), findsOneWidget);
    await tester.tap(find.byKey(const Key('im-welcome-language')));
    await tester.pumpAndSettle();

    expect(find.text('Français'), findsWidgets);
    expect(find.text('（设备语言，不支持时使用简体中文）'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
