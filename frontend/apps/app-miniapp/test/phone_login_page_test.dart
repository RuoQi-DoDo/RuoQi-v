import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/pages/auth/phone_country.dart';
import 'package:ruoqi_app_miniapp/pages/auth/phone_login_page.dart';

void main() {
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
