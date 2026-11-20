import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/main.dart';
import 'package:ruoqi_app_miniapp/pages/auth/business_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('本地会话会记住并清除登录状态', () async {
    SharedPreferences.setMockInitialValues({});
    const store = SharedPreferencesBusinessSessionStore();

    expect(await store.readSignedIn(), isFalse);
    await store.writeSignedIn(true);
    expect(await store.readSignedIn(), isTrue);
    await store.writeSignedIn(false);
    expect(await store.readSignedIn(), isFalse);
  });

  testWidgets('无论会话状态如何启动都直接进入 AI', (tester) async {
    final store = _MemorySessionStore();
    await tester.pumpWidget(BusinessApp(sessionStore: store));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-page')), findsOneWidget);
    expect(find.text('欢迎使用 RuoQi'), findsNothing);
    expect(find.byKey(const Key('phone-login-page')), findsNothing);
    expect(find.byKey(const Key('host-tab-home')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(
      BusinessApp(initiallyAuthenticated: false, sessionStore: store),
    );
    await tester.pumpAndSettle();

    expect(find.text('欢迎使用 RuoQi'), findsNothing);
    expect(find.byKey(const Key('phone-login-page')), findsNothing);
    expect(find.byKey(const Key('ai-page')), findsOneWidget);
    expect(find.byKey(const Key('host-tab-home')), findsNothing);
  });

  testWidgets('设置页不再提供退出登录入口', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemorySessionStore()..signedIn = true;

    await tester.pumpWidget(
      BusinessApp(initiallyAuthenticated: true, sessionStore: store),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-history-settings')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-page')), findsOneWidget);
    expect(find.byKey(const Key('settings-logout')), findsNothing);
    expect(store.signedIn, isTrue);
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
