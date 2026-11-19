import 'dart:convert';

import 'package:common/common.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ruoqi_app_miniapp/appearance.dart';
import 'package:ruoqi_app_miniapp/localization.dart';
import 'package:ruoqi_app_miniapp/pages/ai/ai_page.dart';
import 'package:ruoqi_app_miniapp/pages/ai/chat_history_store.dart';
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

class _MemoryHistoryStore implements ChatHistoryStore {
  final List<ChatConversation> conversations = <ChatConversation>[];

  @override
  Future<void> deleteConversation(String id) async {
    conversations.removeWhere((conversation) => conversation.id == id);
  }

  @override
  Future<ChatConversation?> getConversation(String id) async {
    for (final conversation in conversations) {
      if (conversation.id == id) {
        return conversation;
      }
    }
    return null;
  }

  @override
  Future<List<ChatConversation>> loadConversations() async {
    return List<ChatConversation>.of(conversations);
  }

  @override
  Future<void> renameConversation(String id, String title) async {}

  @override
  Future<void> saveConversation(ChatConversation conversation) async {
    conversations
      ..removeWhere((item) => item.id == conversation.id)
      ..add(conversation);
  }

  @override
  Future<void> setPinned(String id, bool pinned) async {}
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
  testWidgets('AI 页面沿用主应用主题的强调色与表面色', (tester) async {
    final hostTheme = ruoQiTheme(accent: defaultAccentColor, mobile: true);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        theme: hostTheme,
        home: AiPage(
          settingsStore: _ChatSettingsStore(),
          api: DeepSeekApi(),
          historyStore: _MemoryHistoryStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final page = find.byKey(const Key('ai-page'));
    final aiTheme = Theme.of(tester.element(page));
    expect(aiTheme.colorScheme.primary, hostTheme.colorScheme.primary);
    expect(aiTheme.colorScheme.surface, hostTheme.colorScheme.surface);
    expect(aiTheme.scaffoldBackgroundColor, hostTheme.colorScheme.surface);
    expect(
      tester.widget<Scaffold>(page).backgroundColor,
      hostTheme.colorScheme.surface,
    );

    final overlay = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byKey(const Key('ai-system-overlay')),
    );
    expect(overlay.value.statusBarColor, hostTheme.colorScheme.surface);
    expect(overlay.value.statusBarIconBrightness, Brightness.dark);
    expect(overlay.value.statusBarBrightness, Brightness.light);
    expect(overlay.value.systemStatusBarContrastEnforced, isFalse);
  });

  testWidgets('AI 附件入口在输入框下方内联展开并可收起', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
          api: DeepSeekApi(),
          historyStore: _MemoryHistoryStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-attachment-menu')), findsNothing);
    await tester.tap(find.byKey(const Key('ai-attachment-toggle')));
    await tester.pumpAndSettle();

    final menu = find.byKey(const Key('ai-attachment-menu'));
    expect(menu, findsOneWidget);
    expect(find.byKey(const Key('ai-attachment-camera')), findsOneWidget);
    expect(find.byKey(const Key('ai-attachment-gallery')), findsOneWidget);
    expect(find.byKey(const Key('ai-attachment-upload')), findsOneWidget);
    expect(find.byKey(const Key('ai-attachment-ocr')), findsOneWidget);
    expect(find.text('拍照'), findsOneWidget);
    expect(find.text('相册'), findsOneWidget);
    expect(find.text('文件'), findsOneWidget);
    expect(find.text('OCR'), findsOneWidget);
    expect(
      tester.getTopLeft(menu).dy,
      greaterThan(
        tester.getBottomLeft(find.byKey(const Key('ai-composer-card'))).dy,
      ),
    );

    await tester.tap(find.byKey(const Key('ai-attachment-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-attachment-menu')), findsNothing);
  });

  testWidgets('AI 聊天使用 DeepSeek Chat Completions 流式更新', (tester) async {
    final adapter = _ChatStreamAdapter();
    final historyStore = _MemoryHistoryStore();
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
          historyStore: historyStore,
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
    expect(find.text('联网搜索'), findsNothing);
    expect(find.byKey(const Key('ai-answer-actions')), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up_alt_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.thumb_up_alt_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.thumb_up_alt_rounded), findsOneWidget);
    expect(adapter.lastRequest?.path, '/chat/completions');
    expect(adapter.lastRequest?.data['model'], 'deepseek-flash');
    expect(adapter.lastRequest?.data['stream'], isTrue);
    expect(historyStore.conversations, hasLength(1));
    expect(historyStore.conversations.single.messages, hasLength(2));
  });

  testWidgets('聊天内容可滚动时按钮支持跳转顶部和底部', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = _ChatStreamAdapter(longResponse: true);
    final historyStore = _MemoryHistoryStore();
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
          historyStore: historyStore,
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
