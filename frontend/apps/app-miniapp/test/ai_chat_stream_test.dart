import 'dart:convert';
import 'dart:io';

import 'package:common/common.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:record/record.dart';
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

class _VoiceDeepSeekApi extends DeepSeekApi {
  int transcriptionCalls = 0;
  final List<List<DeepSeekChatMessage>> chatRequests = [];

  @override
  Future<DeepSeekTranscription> speechToText({
    required String apiKey,
    required String filename,
    required Uint8List bytes,
  }) async {
    transcriptionCalls++;
    expect(filename, 'voice.wav');
    expect(bytes, isNotEmpty);
    return const DeepSeekTranscription(
      requestId: 'voice-request',
      text: '  直接用语音发送  ',
      durationMs: 1200,
    );
  }

  @override
  Stream<DeepSeekChatChunk> streamChatCompletion({
    required String apiKey,
    required String model,
    required List<DeepSeekChatMessage> messages,
    bool thinking = false,
    bool webSearch = false,
    int? maxTokens,
    double? temperature,
  }) async* {
    chatRequests.add(messages);
    yield const DeepSeekChatChunk(
      content: '语音消息已收到',
      reasoningContent: '',
      finishReason: 'stop',
    );
  }
}

class _VoiceRecordPlatform extends RecordPlatform {
  String? outputPath;
  int startCalls = 0;
  int stopCalls = 0;

  @override
  Future<void> create(String recorderId) async {}

  @override
  Future<bool> hasPermission(String recorderId, {bool request = true}) async {
    return true;
  }

  @override
  Future<void> start(
    String recorderId,
    RecordConfig config, {
    required String path,
  }) async {
    startCalls++;
    outputPath = path;
    File(path).writeAsBytesSync(const [0, 1, 2, 3]);
  }

  @override
  Future<String?> stop(String recorderId) async {
    stopCalls++;
    return outputPath;
  }

  @override
  Future<bool> isRecording(String recorderId) async => false;

  @override
  Future<void> cancel(String recorderId) async {
    final path = outputPath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  @override
  Future<void> dispose(String recorderId) async {}

  @override
  Stream<RecordState> onStateChanged(String recorderId) =>
      const Stream<RecordState>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

  testWidgets('AI 模式按钮不绘制矩形按压覆盖层', (tester) async {
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

    for (final key in ['ai-deep-thinking', 'ai-web-search']) {
      final chip = find.byKey(Key(key));
      final ink = tester.widget<InkWell>(
        find.descendant(of: chip, matching: find.byType(InkWell)),
      );
      expect(ink.splashFactory, NoSplash.splashFactory, reason: key);
      expect(
        ink.overlayColor?.resolve(const <WidgetState>{}),
        Colors.transparent,
        reason: key,
      );
      await tester.tap(chip);
      await tester.pump();
    }
  });

  testWidgets('自动朗读开关在页面中央显示灰色圆角提示', (tester) async {
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

    await tester.tap(find.byKey(const Key('ai-auto-read')));
    await tester.pump(const Duration(milliseconds: 160));
    expect(find.text('已开启自动朗读'), findsOneWidget);
    expect(find.byKey(const Key('ai-transient-notice')), findsOneWidget);
    final notice = find.byKey(const Key('ai-transient-notice'));
    expect(tester.getCenter(notice).dx, closeTo(207, 1));
    expect(tester.getCenter(notice).dy, closeTo(448, 1));
    final decoration =
        tester.widget<Container>(notice).decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xE64A4A4A));
    expect(decoration.borderRadius, BorderRadius.circular(18));

    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.byKey(const Key('ai-transient-notice')), findsNothing);

    await tester.tap(find.byKey(const Key('ai-auto-read')));
    await tester.pump(const Duration(milliseconds: 160));
    expect(find.text('已关闭自动朗读'), findsOneWidget);
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

  testWidgets('AI 语音转写完成后直接作为消息发送', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final previousRecordPlatform = RecordPlatform.instance;
    final recordPlatform = _VoiceRecordPlatform();
    RecordPlatform.instance = recordPlatform;
    addTearDown(() => RecordPlatform.instance = previousRecordPlatform);
    final api = _VoiceDeepSeekApi();
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
          api: api,
          historyStore: historyStore,
          recordingReader: (_) async => Uint8List.fromList(const [1, 2, 3]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('ai-voice-mode-toggle'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    for (
      var attempt = 0;
      attempt < 20 && recordPlatform.outputPath == null;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(const Key('ai-recording-panel')), findsOneWidget);
    expect(recordPlatform.startCalls, 1);

    await gesture.up();
    await tester.pumpAndSettle();
    for (
      var attempt = 0;
      attempt < 20 && api.transcriptionCalls == 0;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(recordPlatform.stopCalls, 1);
    expect(File(recordPlatform.outputPath!).existsSync(), isTrue);
    expect(find.text('录音或语音识别失败'), findsNothing);
    expect(api.transcriptionCalls, 1);
    expect(api.chatRequests, hasLength(1));
    expect(api.chatRequests.single.last.content, '直接用语音发送');
    expect(find.text('直接用语音发送'), findsWidgets);
    expect(find.text('语音消息已收到'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('ai-composer')))
          .controller
          ?.text,
      isEmpty,
    );
    expect(historyStore.conversations.single.messages, hasLength(2));
    await tester.pumpWidget(const SizedBox.shrink());
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
