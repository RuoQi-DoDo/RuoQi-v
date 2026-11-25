import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:record/record.dart';
import 'package:ruoqi_app_miniapp/app_theme.dart';
import 'package:ruoqi_app_miniapp/appearance.dart';
import 'package:ruoqi_app_miniapp/localization.dart';
import 'package:ruoqi_app_miniapp/pages/ai/ai_page.dart';
import 'package:ruoqi_app_miniapp/pages/ai/ai_style.dart';
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
  _ChatStreamAdapter({this.longResponse = false, this.response});

  final bool longResponse;
  final String? response;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    final content =
        response ??
        (longResponse
            ? List.filled(60, '这是一段用于测试快速滚动按钮的长文本内容。').join('\n\n')
            : '你好');
    final stopChunk = response != null || longResponse
        ? 'data: {"choices":[{"delta":{},"finish_reason":"stop"}]}\n\n'
        : 'data: {"choices":[{"delta":{"content":"，世界"},"finish_reason":"stop"}]}\n\n';
    return ResponseBody.fromString(
      'data: ${jsonEncode({
        'choices': [
          {
            'delta': {'content': content},
            'finish_reason': null,
          },
        ],
      })}\n\n'
      '$stopChunk'
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

class _ControlledChatStreamAdapter implements HttpClientAdapter {
  final StreamController<Uint8List> _controller = StreamController<Uint8List>();
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody(
      _controller.stream,
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }

  void addContent(String content) {
    _controller.add(
      Uint8List.fromList(
        utf8.encode(
          'data: ${jsonEncode({
            'choices': [
              {
                'delta': {'content': content},
                'finish_reason': null,
              },
            ],
          })}\n\n',
        ),
      ),
    );
  }

  Future<void> finish() async {
    _controller
      ..add(
        Uint8List.fromList(
          utf8.encode(
            'data: {"choices":[{"delta":{},"finish_reason":"stop"}]}\n\n'
            'data: [DONE]\n\n',
          ),
        ),
      )
      ..close();
  }

  @override
  void close({bool force = false}) {}
}

class _StopContinueDeepSeekApi extends DeepSeekApi {
  final StreamController<DeepSeekChatChunk> initial =
      StreamController<DeepSeekChatChunk>();
  final List<List<DeepSeekChatMessage>> requests = [];

  void addInitialContent(String content) {
    initial.add(DeepSeekChatChunk(content: content, reasoningContent: ''));
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
  }) {
    requests.add(messages);
    if (requests.length == 1) {
      return initial.stream;
    }
    return Stream<DeepSeekChatChunk>.fromIterable(const [
      DeepSeekChatChunk(content: '继续生成部分。', reasoningContent: ''),
    ]);
  }
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

class _AttachmentDeepSeekApi extends DeepSeekApi {
  int uploadCalls = 0;
  Completer<void>? uploadGate;
  final List<String> uploadedFilenames = <String>[];
  final Map<String, int> uploadProgressSent = <String, int>{};
  final Map<String, int> uploadProgressTotal = <String, int>{};
  List<DeepSeekChatMessage>? chatRequest;

  @override
  Future<DeepSeekFile> uploadFile({
    required String apiKey,
    required String filename,
    required Uint8List bytes,
    String purpose = 'user_data',
    int? expiresAfterSeconds,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    uploadCalls++;
    expect(bytes, isNotEmpty);
    uploadedFilenames.add(filename);
    onSendProgress?.call(bytes.length ~/ 2, bytes.length);
    uploadProgressSent[filename] = bytes.length ~/ 2;
    uploadProgressTotal[filename] = bytes.length;
    await uploadGate?.future;
    final file = DeepSeekFile(
      id: 'file_$filename',
      bytes: bytes.length,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      filename: filename,
      purpose: purpose,
    );
    return file;
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
    chatRequest = messages;
    yield const DeepSeekChatChunk(
      content: '图片已收到',
      reasoningContent: '',
      finishReason: 'stop',
    );
  }
}

class _VoiceRecordPlatform extends RecordPlatform {
  _VoiceRecordPlatform({this.permissionResult});

  final Future<bool>? permissionResult;
  String? outputPath;
  int permissionCalls = 0;
  int startCalls = 0;
  int stopCalls = 0;

  @override
  Future<void> create(String recorderId) async {}

  @override
  Future<bool> hasPermission(String recorderId, {bool request = true}) async {
    permissionCalls++;
    return permissionResult == null ? true : await permissionResult!;
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
    final hostTheme = miniAppTheme(accent: defaultAccentColor);
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
    expect(
      tester.getSize(find.byKey(const Key('ai-brand-mark'))),
      const Size.square(60),
    );

    final overlay = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byKey(const Key('ai-system-overlay')),
    );
    expect(overlay.value.statusBarColor, hostTheme.colorScheme.surface);
    expect(overlay.value.statusBarIconBrightness, Brightness.dark);
    expect(overlay.value.statusBarBrightness, Brightness.light);
    expect(overlay.value.systemStatusBarContrastEnforced, isFalse);
  });

  testWidgets('AI 欢迎语使用时段模板且不展示 RuoQi 字样', (tester) async {
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

    final welcome = tester.widget<Text>(
      find.byKey(const Key('ai-welcome-message')),
    );
    expect(const {
      '你好，让我们开始聊天吧。',
      '你好，有什么我能帮你吗？',
      '今天想做点什么？',
      '早上好，今天想做点什么？',
      '早上好，有什么我能帮你吗？',
      '早上好，今天有什么安排？',
      '上午好，今天想处理点什么？',
      '上午好，我能帮什么忙吗？',
      '上午好，有什么我能帮你吗？',
      '中午好，有什么我能帮你吗？',
      '中午好，想先聊点什么？',
      '下午好，今天想聊点什么？',
      '下午好，我能帮什么忙吗？',
      '下午好，有什么我能帮你吗？',
      '晚上好，今天过得怎么样？',
      '晚上好，需要我帮你处理什么？',
      '晚上好，想聊点什么？',
      '夜深了，还没休息吗？',
      '夜深了，需要我帮你处理什么？',
      '晚上好，需要我陪你聊聊吗？',
      '周末好，今天想做点什么？',
      '周末愉快，有什么我能帮你吗？',
      '周末好，想聊点什么？',
    }, contains(welcome.data));
    expect(welcome.data, isNot(contains('RuoQi')));
    expect(find.textContaining('RuoQi'), findsNothing);
  });

  testWidgets('AI 欢迎语在已有对话记录时使用欢迎回来模板', (tester) async {
    final now = DateTime.now();
    final historyStore = _MemoryHistoryStore();
    await historyStore.saveConversation(
      ChatConversation(
        id: 'existing-conversation',
        title: '之前的对话',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        messages: const [
          ChatHistoryMessage(role: 'user', content: '你好'),
          ChatHistoryMessage(role: 'assistant', content: '你好，有什么可以帮你？'),
        ],
      ),
    );

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
          historyStore: historyStore,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final welcome = tester.widget<Text>(
      find.byKey(const Key('ai-welcome-message')),
    );
    expect(const {
      '欢迎回来，我可以为你做点什么？',
      '欢迎回来，今天想聊点什么？',
      '欢迎回来，有什么我能帮你吗？',
      '又见面了，今天想聊点什么？',
    }, contains(welcome.data));
    expect(welcome.data, isNot(contains('RuoQi')));
  });

  testWidgets('AI 旧图片历史可从缓存文件恢复预览', (tester) async {
    final now = DateTime.now();
    final pngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
      '+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final filename = 'scaled_ai_history_${now.microsecondsSinceEpoch}.png';
    final file = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}$filename',
    );
    file.writeAsBytesSync(pngBytes, flush: true);
    addTearDown(() {
      if (file.existsSync()) {
        file.deleteSync();
      }
    });
    final historyStore = _MemoryHistoryStore();
    await historyStore.saveConversation(
      ChatConversation(
        id: 'legacy-image-conversation',
        title: '旧图片对话',
        createdAt: now,
        updatedAt: now,
        messages: [
          ChatHistoryMessage(role: 'user', content: '附件：$filename'),
          const ChatHistoryMessage(role: 'assistant', content: '图片已收到'),
        ],
      ),
    );

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
          historyStore: historyStore,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ai-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('旧图片对话'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-sent-image')), findsOneWidget);
    expect(find.text('附件：$filename'), findsNothing);
  });

  testWidgets('AI 页面跟随全局暗色石墨灰主题', (tester) async {
    final hostTheme = miniAppTheme(
      brightness: Brightness.dark,
      accent: defaultAccentColor,
    );
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
    final pageContext = tester.element(page);
    final aiTheme = Theme.of(pageContext);
    expect(aiTheme.colorScheme.primary, hostTheme.colorScheme.primary);
    expect(aiTheme.colorScheme.surface, MiniAppDarkColors.background);
    expect(AiColors.background(pageContext), MiniAppDarkColors.background);
    expect(AiColors.surface(pageContext), MiniAppDarkColors.surface);
    expect(AiColors.softSurface(pageContext), MiniAppDarkColors.surfaceHigh);
    expect(AiColors.text(pageContext), MiniAppDarkColors.text);
    expect(AiColors.muted(pageContext), MiniAppDarkColors.muted);
    expect(
      tester.widget<Scaffold>(page).backgroundColor,
      AiColors.background(pageContext),
    );

    final overlay = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byKey(const Key('ai-system-overlay')),
    );
    expect(overlay.value.statusBarColor, AiColors.background(pageContext));
    expect(overlay.value.statusBarIconBrightness, Brightness.light);
    expect(overlay.value.statusBarBrightness, Brightness.dark);
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
    for (final action in ['camera', 'gallery', 'upload', 'ocr']) {
      final tile = find.byKey(Key('ai-attachment-$action'));
      final material = tester.widget<Material>(
        find.descendant(of: tile, matching: find.byType(Material)).first,
      );
      expect(
        material.color,
        AiColors.surface(tester.element(tile)),
        reason: action,
      );
      expect(tester.getSize(tile).height, 70, reason: action);
    }
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

  testWidgets('AI 图片附件显示缩略预览并可在无文字时直接发送', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _AttachmentDeepSeekApi();
    api.uploadGate = Completer<void>();
    final historyStore = _MemoryHistoryStore();
    final pngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
      '+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
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
          imagePicker: (_) async => [
            XFile.fromData(
              pngBytes,
              path: '/tmp/photo.png',
              mimeType: 'image/png',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ai-attachment-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-attachment-gallery')));
    for (
      var attempt = 0;
      attempt < 20 &&
          find
              .byKey(const Key('ai-attachment-upload-progress'))
              .evaluate()
              .isEmpty;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(api.uploadCalls, 1);
    expect(find.byKey(const Key('ai-attachment-preview')), findsOneWidget);
    expect(
      find.byKey(const Key('ai-attachment-upload-progress')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('ai-attachment-upload-spinner')),
      findsOneWidget,
    );
    expect(find.text('50%'), findsOneWidget);
    expect(find.byKey(const Key('ai-attachment-suggestions')), findsNothing);
    expect(
      find.byKey(const Key('ai-attachment-suggestions-loading')),
      findsOneWidget,
    );
    expect(find.text('photo.png 已上传'), findsNothing);

    api.uploadGate!.complete();
    for (
      var attempt = 0;
      attempt < 20 &&
          find
              .byKey(const Key('ai-attachment-upload-progress'))
              .evaluate()
              .isNotEmpty;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(
      find.byKey(const Key('ai-attachment-preview-image')),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const Key('ai-attachment-preview'))),
      const Size(90, 96),
    );
    expect(
      tester.getSize(find.byKey(const Key('ai-attachment-preview-image'))),
      const Size(78, 90),
    );
    expect(
      find.byKey(const Key('ai-attachment-upload-progress')),
      findsNothing,
    );
    expect(find.byKey(const Key('ai-attachment-suggestions')), findsOneWidget);
    expect(
      find.byKey(const Key('ai-attachment-suggestions-loading')),
      findsNothing,
    );
    expect(find.text('这是什么'), findsOneWidget);
    expect(find.text('分析一下'), findsOneWidget);
    expect(find.text('怎么办'), findsOneWidget);
    expect(find.byKey(const Key('ai-voice-mode-toggle')), findsNothing);
    expect(find.byKey(const Key('ai-send')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-attachment-preview')), findsNothing);
    expect(find.byKey(const Key('ai-sent-image')), findsOneWidget);
    expect(find.byKey(const Key('ai-sent-image-content')), findsOneWidget);
    expect(find.text('附件：photo.png'), findsNothing);
    expect(find.text('图片已收到'), findsOneWidget);
    expect(api.chatRequest?.last.content, [
      {'type': 'file', 'file_id': 'file_photo.png'},
    ]);
    expect(historyStore.conversations.single.messages, hasLength(2));
    final savedImage =
        historyStore.conversations.single.messages.first.attachments.single;
    expect(historyStore.conversations.single.messages.first.content, isEmpty);
    expect(File(savedImage.path).existsSync(), isTrue);
    addTearDown(() {
      final file = File(savedImage.path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    await tester.tap(find.byKey(const Key('ai-new-conversation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('photo.png'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-sent-image')), findsOneWidget);
    expect(find.byKey(const Key('ai-sent-image-content')), findsOneWidget);
    expect(find.textContaining('附件：photo.png'), findsNothing);
  });

  testWidgets('AI 相册支持多张图片同时上传并逐张显示进度', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _AttachmentDeepSeekApi()..uploadGate = Completer<void>();
    final historyStore = _MemoryHistoryStore();
    final pngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
      '+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );

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
          imagePicker: (_) async => [
            XFile.fromData(
              pngBytes,
              path: '/tmp/first.png',
              mimeType: 'image/png',
            ),
            XFile.fromData(
              pngBytes,
              path: '/tmp/second.png',
              mimeType: 'image/png',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ai-attachment-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-attachment-gallery')));
    for (
      var attempt = 0;
      attempt < 20 &&
          find
                  .byKey(const Key('ai-attachment-upload-progress'))
                  .evaluate()
                  .length <
              2;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(api.uploadCalls, 2);
    expect(api.uploadedFilenames, ['first.png', 'second.png']);
    expect(find.byKey(const Key('ai-attachment-preview')), findsNWidgets(2));
    expect(
      find.byKey(const Key('ai-attachment-upload-progress')),
      findsNWidgets(2),
    );
    expect(find.text('50%'), findsNWidgets(2));
    expect(find.byKey(const Key('ai-attachment-suggestions')), findsNothing);
    expect(
      find.byKey(const Key('ai-attachment-suggestions-loading')),
      findsOneWidget,
    );

    api.uploadGate!.complete();
    for (
      var attempt = 0;
      attempt < 20 &&
          find
              .byKey(const Key('ai-attachment-upload-progress'))
              .evaluate()
              .isNotEmpty;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(
      find.byKey(const Key('ai-attachment-upload-progress')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('ai-attachment-preview-image')),
      findsNWidgets(2),
    );
    expect(find.byKey(const Key('ai-attachment-suggestions')), findsOneWidget);
    expect(
      find.byKey(const Key('ai-attachment-suggestions-loading')),
      findsNothing,
    );
    expect(find.text('first.png 已上传'), findsNothing);
    expect(find.text('second.png 已上传'), findsNothing);

    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pumpAndSettle();

    final sentImages = find.byKey(const Key('ai-sent-image-content'));
    expect(sentImages, findsNWidgets(2));
    expect(tester.getSize(sentImages.at(0)).height, closeTo(98, 0.01));
    expect(tester.getSize(sentImages.at(1)).height, closeTo(98, 0.01));
    expect(
      tester.getTopLeft(sentImages.at(0)).dy,
      closeTo(tester.getTopLeft(sentImages.at(1)).dy, 0.01),
    );
    expect(
      tester.getTopLeft(sentImages.at(1)).dx -
          tester.getTopRight(sentImages.at(0)).dx,
      closeTo(6, 0.01),
    );
    expect(tester.getTopRight(sentImages.at(1)).dx, lessThanOrEqualTo(396));

    await tester.tap(find.byKey(const Key('ai-sent-image-tile-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-image-preview')), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-320, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ai-image-preview-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-image-preview')), findsNothing);

    expect(find.text('附件：first.png、second.png'), findsNothing);
    expect(api.chatRequest?.last.content, [
      {'type': 'file', 'file_id': 'file_first.png'},
      {'type': 'file', 'file_id': 'file_second.png'},
    ]);
    expect(historyStore.conversations.single.messages, hasLength(2));
    expect(historyStore.conversations.single.messages.first.content, isEmpty);
    expect(
      historyStore.conversations.single.messages.first.attachments,
      hasLength(2),
    );
    for (final attachment
        in historyStore.conversations.single.messages.first.attachments) {
      expect(File(attachment.path).existsSync(), isTrue);
    }
  });

  testWidgets('AI 多图超出消息宽度时横向滚动且不压缩高度', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _AttachmentDeepSeekApi();
    final pngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
      '+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    final tallPngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAoAAABkCAIAAAAwrjbAAAAAGElEQVR4nO3BAQEA'
      'AACAkP6v7ggKAACgBgwcAAF+dCQYAAAAAElFTkSuQmCC',
    );

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
          historyStore: _MemoryHistoryStore(),
          imagePicker: (_) async => [
            for (var index = 0; index < 5; index++)
              XFile.fromData(
                index == 0 ? tallPngBytes : pngBytes,
                path: '/tmp/${index == 0 ? 'tall' : 'image'}-$index.png',
                mimeType: 'image/png',
              ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ai-attachment-toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ai-attachment-gallery')));
    await tester.pumpAndSettle();

    expect(api.uploadCalls, 5);
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pumpAndSettle();

    final sentImages = find.byKey(const Key('ai-sent-image-content'));
    expect(sentImages, findsNWidgets(5));
    for (var index = 0; index < 5; index++) {
      expect(tester.getSize(sentImages.at(index)).height, closeTo(98, 0.01));
    }
    expect(tester.getSize(sentImages.at(0)).width, closeTo(98, 0.01));

    final scrollFinder = find.byKey(const Key('ai-sent-image-scroll'));
    final scrollableFinder = find.descendant(
      of: scrollFinder,
      matching: find.byType(Scrollable),
    );
    expect(scrollableFinder, findsOneWidget);
    final position = tester.state<ScrollableState>(scrollableFinder).position;
    expect(position.maxScrollExtent, greaterThan(0));

    await tester.drag(scrollableFinder, const Offset(-160, 0));
    await tester.pumpAndSettle();

    expect(position.pixels, greaterThan(0));
    for (var index = 0; index < 5; index++) {
      expect(tester.getSize(sentImages.at(index)).height, closeTo(98, 0.01));
    }
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

  testWidgets('AI 顶部与圆形操作按钮不绘制灰色按压反馈', (tester) async {
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

    for (final key in ['ai-history', 'ai-auto-read', 'ai-new-conversation']) {
      final button = tester.widget<IconButton>(find.byKey(Key(key)));
      expect(
        button.style?.overlayColor?.resolve(const <WidgetState>{}),
        Colors.transparent,
        reason: key,
      );
    }
    for (final key in ['ai-attachment-toggle', 'ai-voice-mode-toggle']) {
      final action = find.byKey(Key(key));
      expect(
        find.descendant(of: action, matching: find.byType(InkResponse)),
        findsNothing,
        reason: key,
      );
      expect(
        find.descendant(of: action, matching: find.byType(InkWell)),
        findsNothing,
        reason: key,
      );
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
        tester
                .widget<Container>(
                  find
                      .descendant(of: notice, matching: find.byType(Container))
                      .first,
                )
                .decoration!
            as BoxDecoration;
    expect(decoration.color, const Color(0xFF4A4A4A));
    expect(decoration.borderRadius, BorderRadius.circular(18));
    final noticeStyle = tester
        .widget<DefaultTextStyle>(
          find
              .descendant(of: notice, matching: find.byType(DefaultTextStyle))
              .first,
        )
        .style;
    expect(noticeStyle.decoration, TextDecoration.none);

    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.byKey(const Key('ai-transient-notice')), findsNothing);

    await tester.tap(find.byKey(const Key('ai-auto-read')));
    await tester.pump(const Duration(milliseconds: 160));
    expect(find.text('已关闭自动朗读'), findsOneWidget);
  });

  testWidgets('重复点击新对话时在页面中央提示已经在新对话中', (tester) async {
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

    await tester.tap(find.byKey(const Key('ai-new-conversation')));
    await tester.pump(const Duration(milliseconds: 160));

    expect(find.text('已经在新对话中'), findsOneWidget);
    final notice = find.byKey(const Key('ai-transient-notice'));
    expect(tester.getCenter(notice).dx, closeTo(207, 1));
    expect(tester.getCenter(notice).dy, closeTo(448, 1));
    await tester.pump(const Duration(milliseconds: 1600));
    expect(notice, findsNothing);
  });

  testWidgets('长按附件按钮展开扩展菜单且不显示白色 Tooltip', (tester) async {
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

    await tester.longPress(find.byKey(const Key('ai-attachment-toggle')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('ai-attachment-menu')), findsOneWidget);
    expect(find.text('添加附件'), findsNothing);
  });

  testWidgets('长按自动朗读按钮不显示白色 Tooltip 或中间提示', (tester) async {
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

    await tester.longPress(find.byKey(const Key('ai-auto-read')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('自动朗读'), findsNothing);
    expect(find.byKey(const Key('ai-transient-notice')), findsNothing);
  });

  testWidgets('长按新对话按钮执行点击动作', (tester) async {
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

    await tester.longPress(find.byKey(const Key('ai-new-conversation')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('已经在新对话中'), findsOneWidget);
  });

  testWidgets('AI 聊天使用 DeepSeek Chat Completions 流式更新', (tester) async {
    final adapter = _ChatStreamAdapter();
    final historyStore = _MemoryHistoryStore();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = adapter;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
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
    expect(find.byIcon(Icons.reply_rounded), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up_alt_outlined), findsOneWidget);
    Map<Object?, Object?>? sharePayload;
    const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(shareChannel, (call) async {
      expect(call.method, 'share');
      sharePayload = call.arguments as Map<Object?, Object?>;
      return 'success';
    });
    addTearDown(() => messenger.setMockMethodCallHandler(shareChannel, null));
    await tester.tap(find.byTooltip('分享'));
    await tester.pumpAndSettle();
    expect(sharePayload?['text'], isNull);
    expect(
      sharePayload?['uri'],
      allOf(
        startsWith('https://link.amiemall.com/share/conversation-'),
        isNot(contains(' ')),
      ),
    );
    expect(sharePayload?['title'], 'RuoQi AI 对话');
    expect(sharePayload?['subject'], 'RuoQi AI 对话');
    expect(find.text('分享方式'), findsNothing);
    await tester.tap(find.byIcon(Icons.thumb_up_alt_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.thumb_up_alt_rounded), findsOneWidget);
    expect(adapter.lastRequest?.path, '/chat/completions');
    expect(adapter.lastRequest?.data['model'], 'deepseek-flash');
    expect(adapter.lastRequest?.data['stream'], isTrue);
    expect(historyStore.conversations, hasLength(1));
    expect(historyStore.conversations.single.messages, hasLength(2));
  });

  testWidgets('AI Markdown 表格在暗色主题下保持文字和边框可读', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final adapter = _ChatStreamAdapter(
      response: '''
| 维度 | DDR6 | LPDDR6 |
| --- | --- | --- |
| 主要用途 | 台式机、服务器 | 智能手机、平板 |
| 功耗 | 性能优先 | 极致低功耗 |
''',
    );
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
        theme: miniAppTheme(
          brightness: Brightness.dark,
          accent: defaultAccentColor,
        ),
        home: AiPage(
          settingsStore: _ChatSettingsStore(),
          api: DeepSeekApi(dio: dio),
          historyStore: _MemoryHistoryStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-composer')), '对比两种内存');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pumpAndSettle();

    final tableFinder = find.byType(Table);
    expect(tableFinder, findsOneWidget);
    final table = tester.widget<Table>(tableFinder);
    final border = table.border!;
    expect(border.top.color, MiniAppDarkColors.border);
    expect(table.defaultVerticalAlignment, TableCellVerticalAlignment.top);
    expect(
      table.children.any(
        (row) =>
            row.decoration is BoxDecoration &&
            (row.decoration! as BoxDecoration).color ==
                MiniAppDarkColors.surface,
      ),
      isTrue,
    );

    final cellStyles = tester
        .widgetList<DefaultTextStyle>(
          find.descendant(
            of: tableFinder,
            matching: find.byType(DefaultTextStyle),
          ),
        )
        .map((style) => style.style.color);
    expect(cellStyles, contains(MiniAppDarkColors.text));
    expect(cellStyles, isNot(contains(Colors.black)));
  });

  testWidgets('AI Markdown 行内代码和代码块在暗色主题下保持可读', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final adapter = _ChatStreamAdapter(
      response: '''
编辑器在`0.18 版本`首次提供预览。

```dart
final version = '0.18';
print(version);
```
''',
    );
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
        theme: miniAppTheme(
          brightness: Brightness.dark,
          accent: defaultAccentColor,
        ),
        home: AiPage(
          settingsStore: _ChatSettingsStore(),
          api: DeepSeekApi(dio: dio),
          historyStore: _MemoryHistoryStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-composer')), '解释版本');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pumpAndSettle();

    Iterable<TextSpan> flatten(InlineSpan span) sync* {
      if (span is! TextSpan) {
        return;
      }
      yield span;
      for (final child in span.children ?? const <InlineSpan>[]) {
        yield* flatten(child);
      }
    }

    final spans = tester
        .widgetList<RichText>(
          find.descendant(
            of: find.byKey(const Key('ai-assistant-message')),
            matching: find.byType(RichText),
          ),
        )
        .expand((widget) => flatten(widget.text));
    final inlineCode = spans.firstWhere((span) => span.text == '0.18 版本');
    expect(inlineCode.style?.color, MiniAppDarkColors.text);
    expect(inlineCode.style?.backgroundColor, MiniAppDarkColors.surfaceHigh);
    final blockCode = spans.firstWhere(
      (span) => span.text?.contains("final version = '0.18';") ?? false,
    );
    expect(blockCode.style?.color, MiniAppDarkColors.text);
    expect(blockCode.style?.backgroundColor, MiniAppDarkColors.surfaceHigh);
  });

  testWidgets('长按用户消息和 AI 回答显示对应操作菜单', (tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = _ChatStreamAdapter();
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
          historyStore: _MemoryHistoryStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-composer')), '介绍一下你自己');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('ai-user-message')));
    await tester.pumpAndSettle();
    for (final label in ['复制', '选择文本', '修改', '分享']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('重新生成'), findsNothing);

    await tester.tap(find.text('修改'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('ai-composer')))
          .controller
          ?.text,
      '介绍一下你自己',
    );

    await tester.longPress(find.text('你好，世界'));
    await tester.pumpAndSettle();
    for (final label in ['复制', '选择文本', '重新生成', '喜欢', '不喜欢', '朗读', '分享']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('修改'), findsNothing);
  });

  testWidgets('选择文本在 AI 回答原位进入选区并显示横排工具栏', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = _ChatStreamAdapter();
    final selectionController = AiTextSelectionController();
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
          historyStore: _MemoryHistoryStore(),
          textSelectionController: selectionController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-composer')), '介绍一下你自己');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('你好，世界'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('选择文本'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.byKey(const Key('ai-assistant-selectable-message')),
      findsOneWidget,
    );
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(find.byKey(const Key('ai-text-selection-toolbar')), findsOneWidget);
    expect(find.byKey(const Key('ai-selection-end-handle')), findsOneWidget);
    expect(selectionController.isActive, isTrue);
    for (final label in ['复制', '全选', '分享']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    selectionController.dismiss();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-page')), findsOneWidget);
    expect(find.byType(SelectionArea), findsNothing);
    expect(find.byKey(const Key('ai-text-selection-toolbar')), findsNothing);
    expect(find.byKey(const Key('ai-selection-end-handle')), findsNothing);
  });

  testWidgets('全选会选中当前 AI 回答的全部段落', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const answer = '第一段回答。\n\n第二段回答。';
    final dio = Dio(BaseOptions(baseUrl: 'https://api.deepseek.com'))
      ..httpClientAdapter = _ChatStreamAdapter(response: answer);
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
          historyStore: _MemoryHistoryStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-composer')), '测试问题');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('第一段回答。'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('选择文本'));
    await tester.pumpAndSettle();
    final paragraphEnd = tester.getCenter(
      find.byKey(const Key('ai-selection-end-handle')),
    );

    await tester.tap(find.byKey(const Key('ai-selection-select-all')));
    await tester.pumpAndSettle();
    final answerEnd = tester.getCenter(
      find.byKey(const Key('ai-selection-end-handle')),
    );
    expect(answerEnd.dy, greaterThan(paragraphEnd.dy));

    String? copiedText;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copiedText =
            (call.arguments as Map<Object?, Object?>)['text'] as String?;
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.tap(find.byKey(const Key('ai-selection-copy')));
    await tester.pumpAndSettle();
    expect(copiedText, contains('第一段回答。'));
    expect(copiedText, contains('第二段回答。'));
    expect(copiedText, isNot(contains('测试问题')));
  });

  testWidgets('流式回答中长按消息暂停自动滚动但不停止回答', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final adapter = _ControlledChatStreamAdapter();
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
          historyStore: _MemoryHistoryStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-composer')), '滚动测试');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pump();
    adapter.addContent(
      List.generate(
        24,
        (index) => '第 $index 段回答内容。这里是一段用于测试滚动跟随的较长文本。',
      ).join('\n\n'),
    );
    for (
      var attempt = 0;
      attempt < 20 &&
          find.byKey(const Key('ai-assistant-message')).evaluate().isEmpty;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 400));

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('ai-conversation')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.drag(
      find.byKey(const Key('ai-conversation')).last,
      const Offset(0, 2000),
    );
    await tester.pump(const Duration(milliseconds: 600));
    final pausedOffset = scrollable.position.pixels;
    final pausedMax = scrollable.position.maxScrollExtent;
    expect(pausedOffset, lessThan(pausedMax));

    await tester.longPress(find.byKey(const Key('ai-user-message')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tapAt(const Offset(4, 4));
    await tester.pump(const Duration(milliseconds: 300));

    adapter.addContent(
      List.generate(
        24,
        (index) => '新增流式内容 $index。这里继续追加回答，但阅读位置应保持不变。',
      ).join('\n\n'),
    );
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 400));
    expect(scrollable.position.pixels, closeTo(pausedOffset, 1));
    expect(scrollable.position.maxScrollExtent, greaterThan(pausedMax));

    await tester.drag(
      find.byKey(const Key('ai-conversation')).last,
      const Offset(0, -5000),
    );
    await tester.pump(const Duration(milliseconds: 600));
    adapter.addContent(
      List.generate(12, (index) => '恢复跟随内容 $index。回到列表底部后继续自动滚动。').join('\n\n'),
    );
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      scrollable.position.pixels,
      closeTo(scrollable.position.maxScrollExtent, 1),
    );

    await adapter.finish();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-assistant-message')), findsOneWidget);
  });

  testWidgets('AI 回答中显示主题色停止按钮并可中止流式回答', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final adapter = _ControlledChatStreamAdapter();
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
          historyStore: _MemoryHistoryStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-composer')), '停止回答测试');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pump();
    adapter.addContent('已经生成的第一段回答。');
    for (
      var attempt = 0;
      attempt < 20 && find.textContaining('已经生成的第一段回答').evaluate().isEmpty;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    final stopButton = find.byKey(const Key('ai-stop'));
    final stopIcon = find.byKey(const Key('ai-stop-icon'));
    expect(stopButton, findsOneWidget);
    expect(stopIcon, findsOneWidget);
    final stopDecoration =
        tester.widget<AnimatedContainer>(stopIcon).decoration! as BoxDecoration;
    expect(stopDecoration.color, AiColors.accent(tester.element(stopIcon)));

    await tester.tap(stopButton);
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(const Key('ai-stop')), findsNothing);
    expect(find.byKey(const Key('ai-typing-indicator')), findsNothing);
    expect(find.textContaining('已经生成的第一段回答'), findsOneWidget);

    adapter.addContent('停止后不应继续追加。');
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('停止后不应继续追加'), findsNothing);
  });

  testWidgets('AI 停止后显示继续生成并从断点续写', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _StopContinueDeepSeekApi();
    addTearDown(api.initial.close);
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
          historyStore: _MemoryHistoryStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-composer')), '继续生成测试');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pump();
    api.addInitialContent('已经生成的前半段。');
    for (
      var attempt = 0;
      attempt < 20 && find.textContaining('已经生成的前半段').evaluate().isEmpty;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.tap(find.byKey(const Key('ai-stop')));
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byKey(const Key('ai-continue-generation')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ai-continue-generation')));
    await tester.pumpAndSettle();

    expect(api.requests, hasLength(2));
    expect(find.textContaining('已经生成的前半段。继续生成部分。'), findsOneWidget);
    expect(find.byKey(const Key('ai-continue-generation')), findsNothing);
    final continuationRequest = api.requests.last;
    expect(
      continuationRequest[continuationRequest.length - 2].role,
      'assistant',
    );
    expect(
      continuationRequest[continuationRequest.length - 2].content,
      '已经生成的前半段。',
    );
    expect(continuationRequest.last.content, contains('从中断处继续生成'));
  });

  testWidgets('流式回答中手动滚动后停止自动跟随并在完成后保持位置', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final adapter = _ControlledChatStreamAdapter();
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
          historyStore: _MemoryHistoryStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-composer')), '手动滚动测试');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pump();
    adapter.addContent(
      List.generate(
        24,
        (index) => '第 $index 段回答内容。这里是一段用于测试手动滚动停止跟随的较长文本。',
      ).join('\n\n'),
    );
    for (
      var attempt = 0;
      attempt < 20 &&
          find.byKey(const Key('ai-assistant-message')).evaluate().isEmpty;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 400));

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('ai-conversation')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.drag(
      find.byKey(const Key('ai-conversation')).last,
      const Offset(0, 240),
    );
    await tester.pump(const Duration(milliseconds: 600));
    final pausedOffset = scrollable.position.pixels;
    final pausedMax = scrollable.position.maxScrollExtent;
    expect(pausedOffset, lessThan(pausedMax - 24));

    adapter.addContent(
      List.generate(
        24,
        (index) => '新增流式内容 $index。用户手动操作后阅读位置应保持不变。',
      ).join('\n\n'),
    );
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 400));
    expect(scrollable.position.pixels, closeTo(pausedOffset, 1));
    expect(scrollable.position.maxScrollExtent, greaterThan(pausedMax));

    await adapter.finish();
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, closeTo(pausedOffset, 1));
    expect(
      scrollable.position.pixels,
      lessThan(scrollable.position.maxScrollExtent),
    );
  });

  testWidgets('流式回答中触摸页面立即停止自动滚动', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final adapter = _ControlledChatStreamAdapter();
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
          historyStore: _MemoryHistoryStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('ai-composer')), '按压暂停测试');
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pump();
    final paragraphs = List.generate(
      24,
      (index) => '第 $index 段回答内容。这里是一段用于测试按压暂停的长文本。',
    );
    adapter.addContent(paragraphs.join('\n\n'));
    for (
      var attempt = 0;
      attempt < 20 &&
          find.byKey(const Key('ai-assistant-message')).evaluate().isEmpty;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 400));

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('ai-conversation')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.maxScrollExtent, greaterThan(24));

    await tester.tapAt(const Offset(210, 187));
    await tester.pump();
    final heldOffset = scrollable.position.pixels;
    final heldMax = scrollable.position.maxScrollExtent;
    adapter.addContent('新增流式内容。触摸后阅读位置应保持不变。');
    for (var attempt = 0; attempt < 8; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(scrollable.position.pixels, closeTo(heldOffset, 1));
    expect(scrollable.position.maxScrollExtent, greaterThan(heldMax));

    await adapter.finish();
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, closeTo(heldOffset, 1));
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

    final composer = find.byKey(const Key('ai-composer'));
    await tester.tap(find.byKey(const Key('ai-hold-to-talk')));
    await tester.pump();
    expect(tester.widget<TextField>(composer).focusNode?.hasFocus, isTrue);

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
    expect(find.byKey(const Key('ai-voice-keyboard-icon')), findsNothing);
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

  testWidgets('AI 首次授权麦克风后松手不会启动空录音', (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final previousRecordPlatform = RecordPlatform.instance;
    final permissionResult = Completer<bool>();
    final recordPlatform = _VoiceRecordPlatform(
      permissionResult: permissionResult.future,
    );
    RecordPlatform.instance = recordPlatform;
    addTearDown(() => RecordPlatform.instance = previousRecordPlatform);
    final api = _VoiceDeepSeekApi();

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
          historyStore: _MemoryHistoryStore(),
          recordingReader: (_) async => Uint8List.fromList(const [1, 2, 3]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('ai-voice-mode-toggle'))),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(recordPlatform.permissionCalls, 1);

    await gesture.up();
    permissionResult.complete(true);
    await tester.pumpAndSettle();

    expect(recordPlatform.startCalls, 0);
    expect(recordPlatform.stopCalls, 0);
    expect(api.transcriptionCalls, 0);
    expect(find.text('录音或语音识别失败'), findsNothing);
    expect(find.text('未识别到语音内容'), findsNothing);
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
    final scrollButtonRect = tester.getRect(scrollButton);
    final regenerateButtonRect = tester.getRect(
      find
          .ancestor(
            of: find.byIcon(Icons.refresh_rounded),
            matching: find.byType(IconButton),
          )
          .first,
    );
    expect(regenerateButtonRect.overlaps(scrollButtonRect), isFalse);
    expect(
      scrollButtonRect.top,
      greaterThanOrEqualTo(regenerateButtonRect.bottom + 16),
    );

    await tester.tap(scrollButton);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

    await tester.tap(scrollButton);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
  });
}
