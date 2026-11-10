import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_business_app/mini-program/mini_program_shell.dart';
import 'package:ruoqi_business_app/mini-program/platform/pages/platform_account_home_page.dart';
import 'package:ruoqi_business_app/mini-program/platform/pages/platform_account_links_page.dart';
import 'package:ruoqi_business_app/mini-program/platform/pages/platform_account_log_page.dart';
import 'package:ruoqi_business_app/mini-program/platform/pages/platform_account_security_page.dart';
import 'package:ruoqi_business_app/mini-program/platform/pages/platform_device_management_page.dart';
import 'package:ruoqi_business_app/mini-program/platform/pages/platform_email_binding_page.dart';
import 'package:ruoqi_business_app/mini-program/platform/pages/platform_password_change_page.dart';
import 'package:ruoqi_business_app/mini-program/platform/pages/platform_phone_binding_page.dart';
import 'package:ruoqi_business_app/mini-program/platform/pages/platform_profile_edit_page.dart';
import 'package:ruoqi_business_app/mini-program/platform/pages/platform_profile_page.dart';
import 'package:ruoqi_business_app/mini-program/platform/platform_mini_program.dart';
import 'package:ruoqi_business_app/mini-program/platform/platform_models.dart';

void main() {
  testWidgets('平台账号中心页面均可使用小程序布局渲染', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final controller = PlatformAccountController();
    addTearDown(controller.dispose);

    final pages = <Widget>[
      PlatformAccountHomePage(controller: controller),
      PlatformProfilePage(controller: controller),
      PlatformAccountSecurityPage(controller: controller),
      PlatformPhoneBindingPage(
        controller: controller,
        mode: PlatformCredentialMode.change,
      ),
      PlatformEmailBindingPage(
        controller: controller,
        mode: PlatformCredentialMode.change,
      ),
      PlatformPasswordChangePage(controller: controller),
      PlatformAccountLinksPage(controller: controller),
      PlatformDeviceManagementPage(controller: controller),
      PlatformAccountLogPage(controller: controller),
      PlatformProfileEditPage(
        controller: controller,
        field: PlatformProfileField.nickname,
      ),
    ];

    for (final page in pages) {
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$page should render');
    }
  });

  testWidgets('平台小程序可从账号中心完成安全手机修改', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: MiniProgramShell(title: '平台管理', child: PlatformMiniProgram()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('platform-account-home')), findsOneWidget);
    expect(find.text('账号中心'), findsOneWidget);

    await tester.tap(find.text('个人资料'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('platform-profile-page')), findsOneWidget);

    await tester.tap(find.byTooltip('返回'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('账号安全'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('platform-account-security-page')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('platform-security-phone')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('platform-phone-binding-page')),
      findsOneWidget,
    );

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('platform-phone-input')),
        matching: find.byType(TextField),
      ),
      '13800138000',
    );
    await tester.tap(find.byKey(const Key('platform-phone-next')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('platform-phone-code')),
        matching: find.byType(TextField),
      ),
      '123456',
    );
    await tester.tap(find.byKey(const Key('platform-phone-verify')));
    await tester.pumpAndSettle();

    expect(find.text('手机号修改成功'), findsOneWidget);
    await tester.tap(find.byKey(const Key('platform-phone-success-done')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('platform-account-home')), findsOneWidget);
  });
}
