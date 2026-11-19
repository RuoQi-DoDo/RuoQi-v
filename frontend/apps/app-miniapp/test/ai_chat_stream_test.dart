import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ruoqi_app_miniapp/localization.dart';
import 'package:ruoqi_app_miniapp/pages/ai/ai_page.dart';
import 'package:ruoqi_app_miniapp/pages/ai/deepseek_api.dart';
import 'package:ruoqi_app_miniapp/pages/ai/deepseek_settings_store.dart';

class _ChatSettingsStore implements DeepSeekSettingsStore {
  @override
  Future<void> clearApiKey() async {}

  @override
  Future<DeepSeekSettings> load() async {
    return const DeepSeekSettings(
      apiKey: 'sk-test',
      selectedModelId: 'deepseek-flash',
      selectedModelName: 'DeepSeek-V4.1-Flash',
    );
  }

  @override
  Future<void> saveApiKey(String apiKey) async {}

  @override
  Future<void> saveSelectedModel({
    required String id,
    required String name,
  }) async {}
}

class _ChatStreamAdapter implements HttpClientAdapter {
  _ChatStreamAdapter({this.longResponse = false});

  final bool longResponse;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    final content = longResponse
        ? List.filled(60, '这是一段用于测试快速滚动按钮的长文本内容。').join('\n\n')
        : null;
    return ResponseBody.fromString(
      'data: ${jsonEncode({
        'choices': [
          {
            'delta': {'content': content ?? '你好'},
            'finish_reason': null,
          },
        ],
      })}\n\n'
      '${content == null ? 'data: {"choices":[{"delta":{"content":"，世界"},"finish_reason":"stop"}]}\n\n' : 'data: {"choices":[{"delta":{},"finish_reason":"stop"}]}\n\n'}'
      'data: [DONE]\n\n',
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  testWidgets('AI 聊天使用 DeepSeek Chat Completions 流式更新', (tester) async {
    final adapter = _ChatStreamAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = adapter;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: AiPage(
          settingsStore: _ChatSettingsStore(),
          api: DeepSeekApi(dio: dio),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-composer')), '介绍一下你自己');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-user-message')), findsOneWidget);
    expect(find.byKey(const Key('ai-assistant-message')), findsOneWidget);
    expect(find.text('你好，世界'), findsOneWidget);
    expect(find.text('介绍一下你自己'), findsWidgets);
    expect(find.byKey(const Key('ai-answer-actions')), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up_alt_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.thumb_up_alt_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.thumb_up_alt_rounded), findsOneWidget);
    expect(adapter.lastRequest?.path, '/chat/completions');
    expect(adapter.lastRequest?.data['model'], 'deepseek-flash');
    expect(adapter.lastRequest?.data['stream'], isTrue);
  });

  testWidgets('聊天内容可滚动时按钮支持跳转顶部和底部', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = _ChatStreamAdapter(longResponse: true);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: AiPage(
          settingsStore: _ChatSettingsStore(),
          api: DeepSeekApi(dio: dio),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('ai-composer')), '继续');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pumpAndSettle();

    final scrollButton = find.byKey(const Key('ai-message-scroll-button'));
    expect(scrollButton, findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);

    await tester.tap(scrollButton);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

    await tester.tap(scrollButton);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
  });
}
