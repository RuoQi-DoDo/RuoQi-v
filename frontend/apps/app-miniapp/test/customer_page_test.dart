import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/pages/auth/login_page.dart';

void main() {
  testWidgets('客户 App 登录页渲染', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('RuoQi 客户 App'), findsOneWidget);
    expect(find.text('客户登录'), findsOneWidget);
    expect(find.text('登 录'), findsOneWidget);
  });

  testWidgets('登录表单校验空字段', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.text('登 录'));
    await tester.pump();

    expect(find.text('请输入用户名'), findsOneWidget);
    expect(find.text('请输入密码'), findsOneWidget);
  });

  testWidgets('登录成功后通知宿主切换业务首页', (tester) async {
    var loggedIn = false;
    await tester.pumpWidget(
      MaterialApp(home: LoginPage(onLoginSuccess: () => loggedIn = true)),
    );

    await tester.enterText(find.byKey(const Key('login-username')), 'demo');
    await tester.enterText(find.byKey(const Key('login-password')), 'secret');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(loggedIn, isTrue);
  });
}
