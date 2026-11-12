import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/miniapp/merchant/business/account_links_page.dart'
    as merchant_links;
import 'package:ruoqi_app_miniapp/miniapp/merchant/business/account_log_page.dart'
    as merchant_logs;
import 'package:ruoqi_app_miniapp/miniapp/merchant/business/device_list_page.dart';
import 'package:ruoqi_app_miniapp/pages/account/account.dart';

void main() {
  testWidgets('公共安全流程共享账号并返回账号安全页', (tester) async {
    tester.view.physicalSize = const Size(414, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final account = AccountController();
    addTearDown(account.dispose);

    await tester.pumpWidget(
      AccountScope(
        controller: account,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    Navigator.of(context).push(AccountSecurityPage.route()),
                child: const Text('打开账号安全'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开账号安全'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('platform-security-phone')));
    await tester.pumpAndSettle();
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
    expect(account.phone, '+86 138******8000');
    await tester.ensureVisible(
      find.byKey(const Key('platform-phone-success-done')),
    );
    await tester.tap(find.byKey(const Key('platform-phone-success-done')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('account-security-page')), findsOneWidget);
    expect(find.text(account.phone!), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('商户关联账号和设备入口更新同一公共账号及日志', (tester) async {
    tester.view.physicalSize = const Size(414, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final account = AccountController();
    addTearDown(account.dispose);

    await tester.pumpWidget(
      AccountScope(
        controller: account,
        child: const MaterialApp(home: merchant_links.AccountLinksPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, '解绑').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认解绑'));
    await tester.pumpAndSettle();
    expect(account.linkedAccountCount, 2);

    await tester.pumpWidget(
      AccountScope(
        controller: account,
        child: const MaterialApp(
          key: ValueKey('devices'),
          home: DeviceListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '下线').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认下线'));
    await tester.pumpAndSettle();
    expect(account.devices.length, 2);
    expect(account.logs.first.action, '设备下线');

    await tester.pumpWidget(
      AccountScope(
        controller: account,
        child: const MaterialApp(
          key: ValueKey('logs'),
          home: merchant_logs.AccountLogPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('platform-account-log-page')), findsOneWidget);
    expect(find.text('设备下线'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
