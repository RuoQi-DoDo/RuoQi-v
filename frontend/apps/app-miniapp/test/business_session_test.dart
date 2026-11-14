import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/main.dart';
import 'package:ruoqi_app_miniapp/pages/auth/business_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('本地会话会记住并清除登录状态', () async {
    SharedPreferences.setMockInitialValues({});
    const store = SharedPreferencesBusinessSessionStore();

    expect(await store.readSignedIn(), isFalse);
    await store.writeSignedIn(true);
    expect(await store.readSignedIn(), isTrue);
    await store.writeSignedIn(false);
    expect(await store.readSignedIn(), isFalse);
  });

  testWidgets('登录成功后重启应用直接进入首页', (tester) async {
    final store = _MemorySessionStore();
    await tester.pumpWidget(BusinessApp(sessionStore: store));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('customer-home-scroll')),
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('im-welcome-continue')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('phone-number-input')),
      '13800138000',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('phone-next')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('phone-code-input')), '123456');
    await tester.pump();
    await tester.tap(find.byKey(const Key('phone-code-verify')));
    await tester.pumpAndSettle();

    expect(store.signedIn, isTrue);
    expect(find.text('企业直聘'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    final restored = await store.readSignedIn();
    await tester.pumpWidget(
      BusinessApp(initiallyAuthenticated: restored, sessionStore: store),
    );
    await tester.pumpAndSettle();

    expect(find.text('欢迎使用 RuoQi'), findsNothing);
    expect(find.byKey(const Key('phone-login-page')), findsNothing);
    expect(find.text('企业直聘'), findsOneWidget);
  });

  testWidgets('主动退出登录会清除记住的会话', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemorySessionStore()..signedIn = true;

    await tester.pumpWidget(
      BusinessApp(initiallyAuthenticated: true, sessionStore: store),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('我').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
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

    expect(store.signedIn, isFalse);
    expect(find.byKey(const Key('phone-login-page')), findsOneWidget);
  });
}

class _MemorySessionStore implements BusinessSessionStore {
  bool signedIn = false;

  @override
  Future<bool> readSignedIn() async => signedIn;

  @override
  Future<void> writeSignedIn(bool signedIn) async {
    this.signedIn = signedIn;
  }
}
