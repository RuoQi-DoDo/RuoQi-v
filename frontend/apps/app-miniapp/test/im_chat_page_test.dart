import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/main.dart';
import 'package:ruoqi_app_miniapp/pages/im/im_chat_page.dart';
import 'package:ruoqi_app_miniapp/pages/scan/scan_page.dart';

void main() {
  testWidgets('应用启动直接进入 AI 页面', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-page')), findsOneWidget);
    expect(find.text('欢迎使用 RuoQi'), findsNothing);
    expect(find.byKey(const Key('im-welcome-continue')), findsNothing);
    expect(find.byKey(const Key('phone-login-page')), findsNothing);
    expect(find.byKey(const Key('host-tab-home')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('聊天页发起菜单提供通话页面和扫一扫入口', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: ImChatPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('im-new-chat-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('im-initiation-sheet')), findsOneWidget);
    expect(find.byKey(const Key('im-initiate-call')), findsOneWidget);
    expect(find.byKey(const Key('im-initiate-scan')), findsOneWidget);
    expect(find.text('发起通话'), findsOneWidget);
    expect(find.text('扫一扫'), findsOneWidget);

    await tester.tap(find.byKey(const Key('im-initiate-call')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calls-page')), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('im-new-chat-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('im-initiate-scan')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scan-page')), findsOneWidget);
    expect(find.byKey(const Key('scan-frame')), findsOneWidget);

    await tester.tap(find.byKey(const Key('scan-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scan-page')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('扫描结果可以展示并复制', (tester) async {
    const scannedValue = 'https://ruoqi.example/contact/42';
    String? clipboardText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardText = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                key: const Key('show-test-scan-result'),
                onPressed: () => showScanResult(context, scannedValue),
                child: const Text('show'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('show-test-scan-result')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scan-result-sheet')), findsOneWidget);
    expect(find.text(scannedValue), findsOneWidget);

    await tester.tap(find.byKey(const Key('scan-result-copy')));
    await tester.pumpAndSettle();
    expect(find.text('已复制'), findsOneWidget);
    expect(clipboardText, scannedValue);
    expect(tester.takeException(), isNull);
  });
}
