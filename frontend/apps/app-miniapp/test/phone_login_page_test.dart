import 'package:common/common.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/appearance.dart';
import 'package:ruoqi_app_miniapp/pages/auth/phone_country.dart';
import 'package:ruoqi_app_miniapp/pages/auth/phone_login_page.dart';
import 'package:ruoqi_app_miniapp/pages/auth/phone_verification_page.dart';

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('手机号和地区选择页适配 ${brightness.name} 主题', (tester) async {
      final theme = ruoQiTheme(
        brightness: brightness,
        accent: defaultAccentColor,
        mobile: true,
      );
      final scheme = theme.colorScheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: PhoneLoginPage(onRequestVerification: (_) {}),
        ),
      );
      await tester.pump();

      expect(
        tester
            .widget<Scaffold>(find.byKey(const Key('phone-login-page')))
            .backgroundColor,
        scheme.surface,
      );
      expect(
        tester.widget<Text>(find.text('输入电话号码')).style?.color,
        scheme.onSurface,
      );
      final nextStyle = tester
          .widget<FilledButton>(find.byKey(const Key('phone-next')))
          .style!;
      expect(nextStyle.backgroundColor?.resolve({}), scheme.primary);
      expect(nextStyle.foregroundColor?.resolve({}), scheme.onPrimary);

      await tester.tap(find.byKey(const Key('phone-country-selector')));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<Scaffold>(
              find.byKey(const Key('phone-country-picker-page')),
            )
            .backgroundColor,
        scheme.surface,
      );
      expect(
        tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
        scheme.surface,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('phone-country-search')))
            .decoration
            ?.fillColor,
        scheme.surfaceContainerHigh,
      );
      expect(
        tester.widget<Divider>(find.byType(Divider).first).color,
        scheme.outlineVariant,
      );
      expect(
        tester.widget<Text>(find.text('China')).style?.color,
        scheme.onSurfaceVariant,
      );
    });
  }

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('验证码页适配 ${brightness.name} 主题', (tester) async {
      final theme = ruoQiTheme(
        brightness: brightness,
        accent: defaultAccentColor,
        mobile: true,
      );
      final scheme = theme.colorScheme;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: PhoneVerificationPage(
            phoneNumber: '+8613800138000',
            onVerified: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pump();

      expect(
        tester
            .widget<Scaffold>(find.byKey(const Key('phone-verification-page')))
            .backgroundColor,
        scheme.surface,
      );
      expect(
        tester.widget<Text>(find.text('验证你的电话号码')).style?.color,
        scheme.onSurface,
      );
      expect(
        tester.widget<Text>(find.textContaining('我们已向')).style?.color,
        scheme.onSurfaceVariant,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('phone-code-input')))
            .style
            ?.color,
        scheme.onSurface,
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('phone-code-status')))
            .style
            ?.color,
        scheme.onSurfaceVariant,
      );
      final verifyStyle = tester
          .widget<FilledButton>(find.byKey(const Key('phone-code-verify')))
          .style!;
      expect(verifyStyle.backgroundColor?.resolve({}), scheme.primary);
      expect(verifyStyle.foregroundColor?.resolve({}), scheme.onPrimary);
    });
  }

  testWidgets('手机号页默认中国区号，输入号码后下一步可用', (tester) async {
    String? submittedNumber;
    await tester.pumpWidget(
      MaterialApp(
        home: PhoneLoginPage(
          onRequestVerification: (number) => submittedNumber = number,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('输入电话号码'), findsOneWidget);
    expect(find.text('中国'), findsOneWidget);
    expect(find.text('+86'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('phone-number-input')))
          .focusNode
          ?.hasFocus,
      isTrue,
    );
    expect(tester.testTextInput.isVisible, isTrue);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('phone-next')))
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.byKey(const Key('phone-number-input')),
      '138 0013 8000',
    );
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('phone-next')))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('phone-next')));
    expect(submittedNumber, '+8613800138000');
  });

  testWidgets('手机号页可搜索并切换国家区号', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PhoneLoginPage(
          onRequestVerification: (_) {},
          initialCountry: phoneCountries.first,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('phone-country-selector')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('phone-country-picker-page')), findsOneWidget);
    expect(find.text('选择国家/地区'), findsOneWidget);
    expect(find.byKey(const Key('phone-country-close')), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.text('China'), findsOneWidget);
    expect(find.text('🇨🇳'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('phone-country-search')),
      'United Kingdom',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('phone-country-GB')));
    await tester.pumpAndSettle();

    expect(find.text('英国'), findsOneWidget);
    expect(find.text('+44'), findsOneWidget);
  });
}
