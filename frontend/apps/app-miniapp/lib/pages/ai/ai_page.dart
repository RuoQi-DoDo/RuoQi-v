import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';

import '../../localization.dart';
import '../common/page_widgets.dart';
import 'ai_history_drawer.dart';
import 'ai_style.dart';
import 'chat_history_store.dart';
import 'deepseek_api.dart';
import 'deepseek_settings_store.dart';
import 'deepseek_icons.dart';
import 'deepseek_tts_cache.dart';

/// A DeepSeek-inspired AI conversation surface with local demo interactions.
class AiPage extends StatefulWidget {
  const AiPage({
    super.key,
    this.onOpenSettings,
    this.settingsStore,
    this.api,
    this.historyStore,
    this.ttsCache,
    this.recordingReader,
    this.scrollController,
  });

  final VoidCallback? onOpenSettings;
  final DeepSeekSettingsStore? settingsStore;
  final DeepSeekApi? api;
  final ChatHistoryStore? historyStore;
  final DeepSeekTtsCache? ttsCache;
  final Future<Uint8List> Function(String path)? recordingReader;
  final ScrollController? scrollController;

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> with SingleTickerProviderStateMixin {
  final TextEditingController _composer = TextEditingController();
  final FocusNode _composerFocus = FocusNode();
  late final ScrollController _messageScroll;
  late final bool _ownsMessageScroll;
  final List<_AiMessage> _messages = <_AiMessage>[];

  late final AnimationController _historyController;
  late final DeepSeekApi _api = widget.api ?? DeepSeekApi();
  late final DeepSeekSettingsStore _settingsStore =
      widget.settingsStore ?? const SharedPreferencesDeepSeekSettingsStore();
  late final ChatHistoryStore _historyStore =
      widget.historyStore ?? const SharedPreferencesChatHistoryStore();
  late final DeepSeekTtsCache _ttsCache = widget.ttsCache ?? DeepSeekTtsCache();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ImagePicker _imagePicker = ImagePicker();
  StreamSubscription<DeepSeekChatChunk>? _chatSubscription;
  StreamSubscription<void>? _speechSubscription;
  File? _ttsFile;
  Timer? _responseTimer;
  bool _deepThinking = false;
  bool _webSearch = true;
  bool _autoRead = false;
  bool _speaking = false;
  bool _speechLoading = false;
  String _speakingText = '';
  bool _responding = false;
  String _selectedModelName = '';
  String _conversationTitle = '';
  String? _activeConversationId;
  DateTime? _conversationCreatedAt;
  List<AiHistoryEntry> _historyEntries = const [];
  DeepSeekFile? _attachmentFile;
  bool _recording = false;
  bool _holdToTalkActive = false;
  bool _holdToTalkCancel = false;
  bool _voiceMode = false;
  bool _composerFocused = false;
  bool _attachmentMenuOpen = false;
  bool _messagesAtBottom = true;
  bool _messagesCanScroll = false;
  int _chatGeneration = 0;

  @override
  void initState() {
    super.initState();
    _ownsMessageScroll = widget.scrollController == null;
    _messageScroll = widget.scrollController ?? ScrollController();
    _historyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 240),
    );
    unawaited(_loadDeepSeekSettings());
    _composer.addListener(_handleComposerChanged);
    _composerFocus.addListener(_handleComposerFocusChanged);
    _messageScroll.addListener(_handleMessageScroll);
  }

  @override
  void dispose() {
    _responseTimer?.cancel();
    _chatSubscription?.cancel();
    _speechSubscription?.cancel();
    _ttsFile = null;
    unawaited(_recorder.dispose());
    unawaited(_audioPlayer.dispose());
    _composer
      ..removeListener(_handleComposerChanged)
      ..dispose();
    _composerFocus
      ..removeListener(_handleComposerFocusChanged)
      ..dispose();
    _messageScroll.removeListener(_handleMessageScroll);
    if (_ownsMessageScroll) {
      _messageScroll.dispose();
    }
    _historyController.dispose();
    super.dispose();
  }

  void _handleComposerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleComposerFocusChanged() {
    if (mounted) {
      setState(() {
        _composerFocused = _composerFocus.hasFocus;
        if (_composerFocused) {
          _attachmentMenuOpen = false;
        }
      });
    }
  }

  void _requestComposerFocus() {
    _composerFocus.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _composerFocus.hasFocus) {
        unawaited(
          SystemChannels.textInput.invokeMethod<void>('TextInput.show'),
        );
      }
    });
  }

  void _newConversation() {
    _responseTimer?.cancel();
    _chatSubscription?.cancel();
    unawaited(_stopSpeech());
    _chatGeneration++;
    FocusScope.of(context).unfocus();
    _composer.clear();
    setState(() {
      _messages.clear();
      _conversationTitle = '';
      _activeConversationId = null;
      _conversationCreatedAt = null;
      _deepThinking = false;
      _webSearch = true;
      _autoRead = false;
      _voiceMode = false;
      _attachmentMenuOpen = false;
      _responding = false;
    });
  }

  Future<void> _send([String? suggestion, bool addUserMessage = true]) async {
    final prompt = (suggestion ?? _composer.text).trim();
    if (prompt.isEmpty || _responding) {
      return;
    }
    DeepSeekSettings settings;
    try {
      settings = await _settingsStore.load();
    } catch (_) {
      if (mounted) {
        showPageMessage(
          context,
          AppLocalizations.of(context)
              .text('无法读取 DeepSeek 配置', 'Unable to read DeepSeek settings'),
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }
    if (settings.apiKey.isEmpty || settings.selectedModelId.isEmpty) {
      showPageMessage(
        context,
        AppLocalizations.of(context).text(
          '请先在设置中配置 DeepSeek API Key 和模型',
          'Configure a DeepSeek API key and model in Settings first',
        ),
      );
      return;
    }
    final attachment = addUserMessage ? _attachmentFile : null;
    final nextTitle = addUserMessage && _messages.isEmpty
        ? prompt
        : _conversationTitle;
    FocusScope.of(context).unfocus();
    _composer.clear();
    final history = <DeepSeekChatMessage>[
      const DeepSeekChatMessage(role: 'system', content: _deepSeekSystemPrompt),
      for (final message in _messages)
        if (message.content.isNotEmpty)
          DeepSeekChatMessage(
            role: message.role == _AiRole.user ? 'user' : 'assistant',
            content: message.content,
          ),
      if (addUserMessage)
        DeepSeekChatMessage(
          role: 'user',
          content: attachment == null
              ? prompt
              : [
                  {'type': 'text', 'text': prompt},
                  {'type': 'file', 'file_id': attachment.id},
                ],
        ),
    ];
    final generation = ++_chatGeneration;
    var streamStarted = false;
    var responseBuffer = '';
    setState(() {
      _selectedModelName = settings.selectedModelName;
      _conversationTitle = _shortTitle(nextTitle);
      if (addUserMessage && _activeConversationId == null) {
        final now = DateTime.now();
        _activeConversationId = 'conversation-${now.microsecondsSinceEpoch}';
        _conversationCreatedAt = now;
      }
      if (addUserMessage) {
        _messages.add(_AiMessage.user(prompt));
        _attachmentFile = null;
      }
      _attachmentMenuOpen = false;
      _responding = true;
    });
    _scrollMessagesToEnd();

    await _chatSubscription?.cancel();
    _chatSubscription = _api
        .streamChatCompletion(
          apiKey: settings.apiKey,
          model: settings.selectedModelId,
          messages: history,
          thinking: _deepThinking,
          webSearch: _webSearch,
        )
        .listen(
          (chunk) {
            if (!mounted ||
                generation != _chatGeneration ||
                chunk.content.isEmpty) {
              return;
            }
            responseBuffer += chunk.content;
            setState(() {
              if (!streamStarted) {
                streamStarted = true;
                _messages.add(
                  _AiMessage.assistant(
                    chunk.content,
                    deepThinking: _deepThinking,
                    webSearch: _webSearch,
                  ),
                );
              } else if (_messages.isNotEmpty) {
                final last = _messages.last;
                _messages[_messages.length - 1] = last.copyWith(
                  content: '${last.content}${chunk.content}',
                );
              }
            });
            _scrollMessagesToEnd();
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!mounted || generation != _chatGeneration) {
              return;
            }
            setState(() {
              _responding = false;
              _chatSubscription = null;
              _messages.add(
                _AiMessage.assistant(
                  _chatErrorMessage(error),
                  deepThinking: _deepThinking,
                  webSearch: _webSearch,
                ),
              );
            });
            unawaited(_saveCurrentConversation());
            _scrollMessagesToEnd();
          },
          onDone: () {
            if (!mounted || generation != _chatGeneration) {
              return;
            }
            setState(() {
              _responding = false;
              _chatSubscription = null;
              if (!streamStarted) {
                _messages.add(
                  _AiMessage.assistant(
                    AppLocalizations.of(context)
                        .text('DeepSeek 未返回内容', 'DeepSeek returned no content'),
                  ),
                );
              }
            });
            if (_autoRead && responseBuffer.trim().isNotEmpty) {
              unawaited(_startSpeech(responseBuffer.trim()));
            }
            unawaited(_saveCurrentConversation());
            _scrollMessagesToEnd();
          },
        );
  }

  Future<void> _toggleSpeech(String text) async {
    if (_speechLoading) {
      await _stopSpeech();
      return;
    }
    if (_speaking && _speakingText != text) {
      await _startSpeech(text);
      return;
    }
    if (_speaking) {
      await _stopSpeech();
      return;
    }
    await _startSpeech(text);
  }

  void _toggleAutoRead() {
    final enabled = !_autoRead;
    setState(() => _autoRead = enabled);
    if (!enabled) {
      unawaited(_stopSpeech());
    }
  }

  Future<void> _startSpeech(String text) async {
    await _stopSpeech();
    if (!mounted) {
      return;
    }
    setState(() {
      _speechLoading = true;
      _speakingText = text;
    });
    try {
      File? audioFile = await _ttsCache.get(text: text);
      if (audioFile == null) {
        final settings = await _settingsStore.load();
        if (!mounted) {
          return;
        }
        if (settings.apiKey.isEmpty) {
          setState(() => _speechLoading = false);
          showPageMessage(
            context,
            AppLocalizations.of(context).text(
              '请先在设置中配置 DeepSeek API Key',
              'Configure a DeepSeek API key in Settings first',
            ),
          );
          return;
        }
        final audio = await _api.textToSpeech(
          apiKey: settings.apiKey,
          text: text,
        );
        audioFile = await _ttsCache.put(text: text, bytes: audio.bytes);
      }
      _ttsFile = audioFile;
      await _audioPlayer.play(
        DeviceFileSource(audioFile.path, mimeType: 'audio/wav'),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _speechLoading = false;
        _speaking = true;
        _speakingText = text;
      });
      await _speechSubscription?.cancel();
      _speechSubscription = _audioPlayer.onPlayerComplete.listen((_) {
        unawaited(_finishSpeechPlayback());
      });
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        setState(() {
          _speechLoading = false;
          _speaking = false;
          _speakingText = '';
        });
        showPageMessage(context, _chatErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _speechLoading = false;
          _speaking = false;
          _speakingText = '';
        });
        await _deleteTtsFile();
        if (!mounted) {
          return;
        }
        showPageMessage(
          context,
          AppLocalizations.of(context).text('语音播放失败', 'Unable to play audio'),
        );
      }
    }
  }

  Future<void> _stopSpeech() async {
    await _speechSubscription?.cancel();
    _speechSubscription = null;
    await _audioPlayer.stop();
    _ttsFile = null;
    if (mounted) {
      setState(() {
        _speaking = false;
        _speechLoading = false;
        _speakingText = '';
      });
    }
  }

  Future<void> _finishSpeechPlayback() async {
    await _speechSubscription?.cancel();
    _speechSubscription = null;
    _ttsFile = null;
    if (mounted) {
      setState(() {
        _speaking = false;
        _speakingText = '';
      });
    }
  }

  Future<void> _deleteTtsFile() async {
    final file = _ttsFile;
    _ttsFile = null;
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }

  String _chatErrorMessage(Object error) {
    final l10n = AppLocalizations.of(context);
    if (error is DeepSeekApiException) {
      return switch (error.type) {
        DeepSeekApiErrorType.missingApiKey => l10n.text(
          '请先在设置中配置 DeepSeek API Key',
          'Configure a DeepSeek API key in Settings first',
        ),
        DeepSeekApiErrorType.unauthorized => l10n.text(
          'DeepSeek API Key 无效或已过期',
          'The DeepSeek API key is invalid or expired',
        ),
        DeepSeekApiErrorType.network => l10n.text(
          '无法连接 DeepSeek，请检查网络',
          'Unable to connect to DeepSeek. Check your network.',
        ),
        DeepSeekApiErrorType.server => l10n.text(
          'DeepSeek 服务暂不可用',
          'DeepSeek is temporarily unavailable',
        ),
        DeepSeekApiErrorType.invalidResponse => l10n.text(
          'DeepSeek 返回数据格式异常',
          'DeepSeek returned an invalid response',
        ),
        DeepSeekApiErrorType.request => l10n.text(
          '请求失败：${error.message}',
          'Request failed: ${error.message}',
        ),
      };
    }
    return l10n.text('请求失败，请稍后重试', 'Request failed. Try again later.');
  }

  Future<void> _copyMessage(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (mounted) {
      showPageMessage(
        context,
        AppLocalizations.of(context).text('已复制回答', 'Answer copied'),
      );
    }
  }

  void _setMessageFeedback(_AiMessage message, int feedback) {
    final index = _messages.indexOf(message);
    if (index < 0) {
      return;
    }
    setState(() {
      _messages[index] = message.copyWith(
        feedback: message.feedback == feedback ? 0 : feedback,
      );
    });
    unawaited(_saveCurrentConversation());
  }

  Future<void> _shareMessage(String content) async {
    final box = context.findRenderObject();
    await SharePlus.instance.share(
      ShareParams(
        text: content,
        subject: AppLocalizations.of(context)
            .text('RuoQi AI 回答', 'RuoQi AI answer'),
        sharePositionOrigin: box is RenderBox
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      ),
    );
  }

  Future<void> _regenerateMessage(_AiMessage message) async {
    if (_responding) {
      return;
    }
    final messageIndex = _messages.indexOf(message);
    if (messageIndex < 0) {
      return;
    }
    var userIndex = messageIndex - 1;
    while (userIndex >= 0 && _messages[userIndex].role != _AiRole.user) {
      userIndex--;
    }
    if (userIndex < 0) {
      return;
    }
    final prompt = _messages[userIndex].content;
    setState(() {
      _messages.removeRange(userIndex + 1, _messages.length);
    });
    await _send(prompt, false);
  }

  void _scrollMessagesToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messageScroll.hasClients) {
        return;
      }
      _messageScroll.animateTo(
        _messageScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _handleMessageScroll() {
    if (!_messageScroll.hasClients) {
      return;
    }
    final position = _messageScroll.position;
    final canScroll = position.maxScrollExtent > 24;
    final atBottom = position.maxScrollExtent - position.pixels <= 24;
    if (canScroll != _messagesCanScroll || atBottom != _messagesAtBottom) {
      setState(() {
        _messagesCanScroll = canScroll;
        _messagesAtBottom = atBottom;
      });
    }
  }

  void _toggleMessageScrollEdge() {
    if (!_messageScroll.hasClients) {
      return;
    }
    _messageScroll.animateTo(
      _messagesAtBottom ? 0 : _messageScroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  double _historyWidth(BuildContext context) =>
      math.min(288.0, MediaQuery.sizeOf(context).width * 0.84);

  Future<void> _showHistory() async {
    FocusScope.of(context).unfocus();
    if (_attachmentMenuOpen) {
      setState(() => _attachmentMenuOpen = false);
    }
    await Future.wait([_loadDeepSeekSettings(), _loadHistoryEntries()]);
    if (!mounted) {
      return;
    }
    _historyController.animateTo(
      1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadDeepSeekSettings() async {
    try {
      final settings = await _settingsStore.load();
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedModelName = settings.selectedModelName;
      });
    } catch (_) {
      // The drawer remains usable when local preferences are unavailable.
    }
  }

  void _closeHistory() {
    _historyController.animateTo(
      0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInCubic,
    );
  }

  void _handleHistoryDragStart(DragStartDetails details) {
    _historyController.stop();
  }

  void _handleHistoryDragUpdate(DragUpdateDetails details) {
    final width = _historyWidth(context);
    _historyController.value =
        (_historyController.value + details.delta.dx / width).clamp(0.0, 1.0);
  }

  void _handleHistoryDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_historyController.value < 0.72 || velocity < -350) {
      _closeHistory();
    } else {
      _showHistory();
    }
  }

  Future<void> _openHistoryEntry(AiHistoryEntry entry) async {
    _closeHistory();
    _responseTimer?.cancel();
    _chatSubscription?.cancel();
    _chatGeneration++;
    _composer.clear();
    final conversation = await _historyStore.getConversation(entry.id);
    if (!mounted || conversation == null) {
      return;
    }
    setState(() {
      _messages
        ..clear()
        ..addAll(conversation.messages.map(_toAiMessage));
      _conversationTitle = conversation.title;
      _activeConversationId = conversation.id;
      _conversationCreatedAt = conversation.createdAt;
      final lastAssistant = conversation.messages.lastWhere(
        (message) => message.role == 'assistant',
        orElse: () => const ChatHistoryMessage(role: 'assistant', content: ''),
      );
      _deepThinking = lastAssistant.deepThinking;
      _webSearch = lastAssistant.webSearch;
      _responding = false;
    });
    _scrollMessagesToEnd();
  }

  Future<void> _loadHistoryEntries() async {
    try {
      final conversations = await _historyStore.loadConversations();
      if (!mounted) {
        return;
      }
      setState(() {
        _historyEntries = conversations
            .map(
              (conversation) => AiHistoryEntry(
                id: conversation.id,
                title: conversation.title,
                group: _historyGroup(conversation.updatedAt),
                updatedAt: conversation.updatedAt,
                pinned: conversation.pinned,
              ),
            )
            .toList(growable: false);
      });
    } catch (_) {
      // Keep the drawer usable when history storage is unavailable.
    }
  }

  AiHistoryGroup _historyGroup(DateTime updatedAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(updatedAt.year, updatedAt.month, updatedAt.day);
    final difference = today.difference(day).inDays;
    if (difference <= 0) {
      return AiHistoryGroup.today;
    }
    if (difference == 1) {
      return AiHistoryGroup.yesterday;
    }
    if (difference < 7) {
      return AiHistoryGroup.lastSevenDays;
    }
    return AiHistoryGroup.older;
  }

  _AiMessage _toAiMessage(ChatHistoryMessage message) {
    return message.role == 'assistant'
        ? _AiMessage.assistant(
            message.content,
            deepThinking: message.deepThinking,
            webSearch: message.webSearch,
          ).copyWith(feedback: message.feedback)
        : _AiMessage.user(message.content);
  }

  Future<void> _saveCurrentConversation() async {
    final id = _activeConversationId;
    if (id == null || _messages.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final conversation = ChatConversation(
      id: id,
      title: _conversationTitle.isEmpty
          ? AppLocalizations.of(context).text('新对话', 'New chat')
          : _conversationTitle,
      createdAt: _conversationCreatedAt ?? now,
      updatedAt: now,
      messages: _messages
          .map(
            (message) => ChatHistoryMessage(
              role: message.role == _AiRole.user ? 'user' : 'assistant',
              content: message.content,
              deepThinking: message.deepThinking,
              webSearch: message.webSearch,
              feedback: message.feedback,
            ),
          )
          .toList(growable: false),
    );
    await _historyStore.saveConversation(conversation);
  }

  Future<void> _renameHistoryEntry(AiHistoryEntry entry, String title) async {
    await _historyStore.renameConversation(entry.id, title);
    if (mounted && _activeConversationId == entry.id) {
      setState(() => _conversationTitle = title);
    }
    await _loadHistoryEntries();
  }

  Future<void> _pinHistoryEntry(AiHistoryEntry entry, bool pinned) async {
    await _historyStore.setPinned(entry.id, pinned);
    await _loadHistoryEntries();
  }

  Future<void> _deleteHistoryEntry(AiHistoryEntry entry) async {
    await _historyStore.deleteConversation(entry.id);
    if (mounted && _activeConversationId == entry.id) {
      _newConversation();
    }
    await _loadHistoryEntries();
  }

  String _shortTitle(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.runes.length <= 24) {
      return normalized;
    }
    return String.fromCharCodes(normalized.runes.take(24));
  }

  Future<DeepSeekSettings?> _requireDeepSeekSettings() async {
    try {
      final settings = await _settingsStore.load();
      if (!mounted) {
        return null;
      }
      if (settings.apiKey.isNotEmpty) {
        return settings;
      }
    } catch (_) {
      if (!mounted) {
        return null;
      }
    }
    if (mounted) {
      showPageMessage(
        context,
        AppLocalizations.of(context).text(
          '请先在设置中配置 DeepSeek API Key',
          'Configure a DeepSeek API key in Settings first',
        ),
      );
    }
    return null;
  }

  void _toggleAttachmentMenu() {
    _composerFocus.unfocus();
    setState(() => _attachmentMenuOpen = !_attachmentMenuOpen);
  }

  Future<void> _handleAttachmentAction(_AttachmentAction action) async {
    if (_attachmentMenuOpen) {
      setState(() => _attachmentMenuOpen = false);
    }
    final settings = await _requireDeepSeekSettings();
    if (!mounted || settings == null) {
      return;
    }
    switch (action) {
      case _AttachmentAction.camera:
        await _pickImageAttachment(settings, ImageSource.camera);
      case _AttachmentAction.gallery:
        await _pickImageAttachment(settings, ImageSource.gallery);
      case _AttachmentAction.upload:
        await _uploadAttachment(settings);
      case _AttachmentAction.files:
        await _showFiles(settings);
      case _AttachmentAction.ocr:
        await _runOcr(settings);
      case _AttachmentAction.search:
        await _searchWeb(settings);
      case _AttachmentAction.fetch:
        await _fetchWebPage(settings);
    }
  }

  Future<void> _pickImageAttachment(
    DeepSeekSettings settings,
    ImageSource source,
  ) async {
    XFile? picked;
    try {
      picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 2048,
        preferredCameraDevice: CameraDevice.rear,
      );
    } on PlatformException {
      if (mounted) {
        showPageMessage(
          context,
          source == ImageSource.camera
              ? AppLocalizations.of(context).text(
                  '无法打开相机，请检查相机权限',
                  'Unable to open the camera. Check camera permission.',
                )
              : AppLocalizations.of(context).text(
                  '无法打开相册，请检查照片权限',
                  'Unable to open the photo library. Check photo permission.',
                ),
        );
      }
      return;
    } on Exception {
      if (mounted) {
        showPageMessage(
          context,
          AppLocalizations.of(context)
              .text('图片选择失败，请重试', 'Unable to select an image. Try again.'),
        );
      }
      return;
    }
    if (picked == null || !mounted) {
      return;
    }
    try {
      await _uploadSelectedFile(
        settings,
        filename: picked.name,
        bytes: await picked.readAsBytes(),
      );
    } on Exception {
      if (mounted) {
        showPageMessage(
          context,
          AppLocalizations.of(context)
              .text('图片读取失败，请重试', 'Unable to read the image. Try again.'),
        );
      }
    }
  }

  Future<void> _uploadAttachment(DeepSeekSettings settings) async {
    final picked = await FilePicker.pickFile(
      dialogTitle: AppLocalizations.of(context)
          .text('选择要上传的文件', 'Choose a file to upload'),
    );
    if (picked == null) {
      return;
    }
    await _uploadSelectedFile(
      settings,
      filename: picked.name,
      bytes: await picked.readAsBytes(),
    );
  }

  Future<void> _uploadSelectedFile(
    DeepSeekSettings settings, {
    required String filename,
    required Uint8List bytes,
  }) async {
    try {
      final file = await _api.uploadFile(
        apiKey: settings.apiKey,
        filename: filename,
        bytes: bytes,
      );
      if (!mounted) {
        return;
      }
      setState(() => _attachmentFile = file);
      showPageMessage(
        context,
        AppLocalizations.of(context)
            .text('${file.filename} 已上传', '${file.filename} uploaded'),
      );
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        showPageMessage(context, _chatErrorMessage(error));
      }
    }
  }

  Future<void> _showFiles(DeepSeekSettings settings) async {
    try {
      final result = await _api.listFiles(
        apiKey: settings.apiKey,
        limit: 100,
        order: 'desc',
      );
      if (!mounted) {
        return;
      }
      final files = List<DeepSeekFile>.of(result.data);
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
          builder: (context, setSheetState) => SizedBox(
            height: 460,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)
                              .text('DeepSeek 文件', 'DeepSeek files'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${files.length}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: files.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)
                                .text('暂无文件', 'No files'),
                          ),
                        )
                      : ListView.builder(
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final file = files[index];
                            return ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(
                                file.filename,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${file.purpose} · ${_formatBytes(file.bytes)}',
                              ),
                              onTap: () async {
                                try {
                                  final detail = await _api.retrieveFile(
                                    apiKey: settings.apiKey,
                                    fileId: file.id,
                                  );
                                  if (context.mounted) {
                                    showPageMessage(
                                      context,
                                      '${detail.filename} · ${detail.id}',
                                    );
                                  }
                                } on DeepSeekApiException catch (error) {
                                  if (context.mounted) {
                                    showPageMessage(
                                      context,
                                      _chatErrorMessage(error),
                                    );
                                  }
                                }
                              },
                              trailing: IconButton(
                                tooltip: AppLocalizations.of(context)
                                    .text('删除文件', 'Delete file'),
                                onPressed: () async {
                                  try {
                                    await _api.deleteFile(
                                      apiKey: settings.apiKey,
                                      fileId: file.id,
                                    );
                                    if (!context.mounted) {
                                      return;
                                    }
                                    setSheetState(() => files.remove(file));
                                  } on DeepSeekApiException catch (error) {
                                    if (context.mounted) {
                                      showPageMessage(
                                        context,
                                        _chatErrorMessage(error),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        showPageMessage(context, _chatErrorMessage(error));
      }
    }
  }

  Future<void> _runOcr(DeepSeekSettings settings) async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'png',
        'jpg',
        'jpeg',
        'webp',
      ],
      dialogTitle: AppLocalizations.of(context)
          .text('选择要识别的文件', 'Choose a file to recognize'),
    );
    if (picked == null) {
      return;
    }
    try {
      final bytes = await picked.readAsBytes();
      final result = await _api.ocr(
        apiKey: settings.apiKey,
        filename: picked.name,
        bytes: bytes,
      );
      if (!mounted) {
        return;
      }
      final recognized = result.pages
          .map((page) => page.text)
          .where((text) => text.trim().isNotEmpty)
          .join('\n\n');
      final output = recognized.trim().isEmpty
          ? AppLocalizations.of(
              context,
            ).text('该文件未识别到可展示的文字。', 'No readable text was found in this file.')
          : recognized;
      _appendOcrConversation(filename: picked.name, output: output);
      showPageMessage(
        context,
        AppLocalizations.of(context).text(
          '已识别 ${result.pageCount} 页',
          'Recognized ${result.pageCount} pages',
        ),
      );
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        showPageMessage(context, _chatErrorMessage(error));
      }
    }
  }

  void _appendOcrConversation({
    required String filename,
    required String output,
  }) {
    final text = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    setState(() {
      if (_activeConversationId == null) {
        _activeConversationId = 'conversation-${now.microsecondsSinceEpoch}';
        _conversationCreatedAt = now;
      }
      if (_conversationTitle.isEmpty) {
        _conversationTitle = _shortTitle(
          text.text('OCR · $filename', 'OCR · $filename'),
        );
      }
      _messages
        ..add(
          _AiMessage.user(text.text('识别文件：$filename', 'OCR file: $filename')),
        )
        ..add(_AiMessage.assistant(output));
    });
    _scrollMessagesToEnd();
    unawaited(_saveCurrentConversation());
  }

  Future<void> _searchWeb(DeepSeekSettings settings) async {
    final query = await _showTextPrompt(
      title: AppLocalizations.of(context).text('搜索网页', 'Search the web'),
      hint: AppLocalizations.of(context).text('输入搜索内容', 'Enter a search query'),
    );
    if (query == null || query.isEmpty) {
      return;
    }
    try {
      final result = await _api.search(query, apiKey: settings.apiKey);
      if (!mounted) {
        return;
      }
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => SizedBox(
          height: 480,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
            itemCount: result.results.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = result.results[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.title),
                subtitle: Text(
                  item.snippet.isNotEmpty ? item.snippet : item.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _setComposerText('${item.title}\n${item.url}');
                },
              );
            },
          ),
        ),
      );
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        showPageMessage(context, _chatErrorMessage(error));
      }
    }
  }

  Future<void> _fetchWebPage(DeepSeekSettings settings) async {
    final url = await _showTextPrompt(
      title: AppLocalizations.of(context).text('阅读网页', 'Read a web page'),
      hint: 'https://',
      keyboardType: TextInputType.url,
    );
    if (url == null || url.isEmpty) {
      return;
    }
    try {
      final page = await _api.fetchPage(apiKey: settings.apiKey, url: url);
      if (!mounted) {
        return;
      }
      _setComposerText('# ${page.title}\n\n${page.content}');
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        showPageMessage(context, _chatErrorMessage(error));
      }
    }
  }

  Future<String?> _showTextPrompt({
    required String title,
    required String hint,
    TextInputType? keyboardType,
  }) async {
    var draft = '';
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextFormField(
          initialValue: '',
          autofocus: true,
          keyboardType: keyboardType,
          onChanged: (text) => draft = text.trim(),
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).text('取消', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(draft),
            child: Text(AppLocalizations.of(context).text('确定', 'OK')),
          ),
        ],
      ),
    );
    return value;
  }

  void _setComposerText(String text, {bool focus = true}) {
    _composer
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
    if (focus) {
      _composerFocus.requestFocus();
    }
    setState(() {});
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  Future<void> _showVoiceMessage() async {
    if (_recording) {
      await _cancelVoiceRecording();
      return;
    }
    if (_attachmentMenuOpen) {
      setState(() => _attachmentMenuOpen = false);
    }
    if (_voiceMode) {
      setState(() => _voiceMode = false);
      _composerFocus.requestFocus();
    } else {
      _composerFocus.unfocus();
      setState(() => _voiceMode = true);
    }
  }

  void _beginHoldToTalk() {
    setState(() {
      _holdToTalkActive = true;
      _holdToTalkCancel = false;
    });
    unawaited(_startVoiceRecording(fromHold: true));
  }

  void _moveHoldToTalk(Offset offsetFromOrigin) {
    if (!_holdToTalkActive) {
      return;
    }
    final shouldCancel = offsetFromOrigin.dy < -64;
    if (shouldCancel != _holdToTalkCancel) {
      setState(() => _holdToTalkCancel = shouldCancel);
    }
  }

  void _endHoldToTalk() {
    if (!_holdToTalkActive) {
      return;
    }
    setState(() => _holdToTalkActive = false);
    if (_holdToTalkCancel) {
      unawaited(_cancelVoiceRecording());
    } else {
      unawaited(_finishVoiceRecording());
    }
  }

  Future<void> _startVoiceRecording({bool fromHold = false}) async {
    if (_recording) {
      return;
    }
    final settings = await _requireDeepSeekSettings();
    if (!mounted || settings == null) {
      return;
    }
    try {
      if (!_recording) {
        final permission = await _recorder.hasPermission();
        if (!permission) {
          if (mounted) {
            showPageMessage(
              context,
              AppLocalizations.of(context)
                  .text('请允许使用麦克风', 'Microphone permission is required'),
            );
          }
          return;
        }
        final path =
            '${Directory.systemTemp.path}/ruoqi_voice_${DateTime.now().millisecondsSinceEpoch}.wav';
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
            bitRate: 256000,
          ),
          path: path,
        );
        if (mounted) {
          setState(() => _recording = true);
          if (fromHold && !_holdToTalkActive) {
            if (_holdToTalkCancel) {
              await _cancelVoiceRecording();
            } else {
              await _finishVoiceRecording();
            }
          }
        }
      }
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        setState(() => _recording = false);
        showPageMessage(context, _chatErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _recording = false);
        showPageMessage(
          context,
          AppLocalizations.of(context)
              .text('录音或语音识别失败', 'Recording or speech recognition failed'),
        );
      }
    }
  }

  Future<void> _finishVoiceRecording() async {
    if (!_recording) {
      return;
    }
    final settings = await _requireDeepSeekSettings();
    if (!mounted) {
      return;
    }
    if (settings == null) {
      await _recorder.cancel();
      if (mounted) {
        setState(() => _recording = false);
      }
      return;
    }
    try {
      final path = await _recorder.stop();
      setState(() => _recording = false);
      if (path == null) {
        return;
      }
      final bytes =
          await (widget.recordingReader?.call(path) ??
              File(path).readAsBytes());
      final result = await _api.speechToText(
        apiKey: settings.apiKey,
        filename: 'voice.wav',
        bytes: bytes,
      );
      if (!mounted) {
        return;
      }
      setState(() => _voiceMode = false);
      final transcript = result.text.trim();
      if (transcript.isEmpty) {
        showPageMessage(
          context,
          AppLocalizations.of(context).text('未识别到语音内容', 'No speech detected'),
        );
        return;
      }
      await _send(transcript);
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        setState(() => _recording = false);
        showPageMessage(context, _chatErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _recording = false);
        showPageMessage(
          context,
          AppLocalizations.of(context)
              .text('录音或语音识别失败', 'Recording or speech recognition failed'),
        );
      }
    }
  }

  Future<void> _cancelVoiceRecording() async {
    if (!_recording) {
      return;
    }
    await _recorder.cancel();
    if (mounted) {
      setState(() {
        _recording = false;
        _holdToTalkCancel = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final aiScheme = baseTheme.colorScheme.copyWith(
      primary: AiColors.accent(context),
      surface: AiColors.background(context),
      onSurface: AiColors.text(context),
      surfaceContainerLowest: AiColors.background(context),
      surfaceContainerLow: AiColors.surface(context),
      surfaceContainer: AiColors.surface(context),
      surfaceContainerHigh: AiColors.softSurface(context),
      onSurfaceVariant: AiColors.muted(context),
      outlineVariant: AiColors.border(context),
    );
    final aiTheme = baseTheme.copyWith(
      scaffoldBackgroundColor: AiColors.background(context),
      colorScheme: aiScheme,
    );
    final historyEntries = _historyEntries;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      key: const Key('ai-system-overlay'),
      value: AiColors.systemUiOverlayStyle(context),
      child: Theme(
        data: aiTheme,
        child: AnimatedBuilder(
          animation: _historyController,
          builder: (context, child) {
            final progress = _historyController.value;
            final drawerOpen = progress > 0;
            final drawerWidth = _historyWidth(context);
            return PopScope(
              canPop: !drawerOpen,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop && drawerOpen) {
                  _closeHistory();
                }
              },
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Transform.translate(
                      offset: Offset(drawerWidth * progress, 0),
                      child: Opacity(
                        key: const Key('ai-main-fade'),
                        opacity: 1 - progress * 0.7,
                        child: ExcludeSemantics(
                          excluding: drawerOpen,
                          child: IgnorePointer(
                            ignoring: drawerOpen,
                            child: Scaffold(
                              key: const Key('ai-page'),
                              backgroundColor: AiColors.background(context),
                              body: SafeArea(
                                bottom: false,
                                child: Column(
                                  children: [
                                    _AiHeader(
                                      onHistory: _showHistory,
                                      onNewConversation: _newConversation,
                                      title: _conversationTitle,
                                      autoRead: _autoRead,
                                      onToggleAutoRead: _toggleAutoRead,
                                    ),
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 220,
                                              ),
                                              switchInCurve:
                                                  Curves.easeOutCubic,
                                              switchOutCurve:
                                                  Curves.easeInCubic,
                                              child: _messages.isEmpty
                                                  ? const _AiWelcome(
                                                      key: ValueKey(
                                                        'ai-welcome',
                                                      ),
                                                    )
                                                  : _AiConversation(
                                                      key: const ValueKey(
                                                        'ai-conversation',
                                                      ),
                                                      messages: _messages,
                                                      responding: _responding,
                                                      scrollController:
                                                          _messageScroll,
                                                      speakingText:
                                                          _speakingText,
                                                      speechLoading:
                                                          _speechLoading,
                                                      onCopy: (message) =>
                                                          unawaited(
                                                            _copyMessage(
                                                              message.content,
                                                            ),
                                                          ),
                                                      onFeedback:
                                                          _setMessageFeedback,
                                                      onSpeak: (message) =>
                                                          unawaited(
                                                            _toggleSpeech(
                                                              message.content,
                                                            ),
                                                          ),
                                                      onShare: (message) =>
                                                          unawaited(
                                                            _shareMessage(
                                                              message.content,
                                                            ),
                                                          ),
                                                      onRegenerate:
                                                          _regenerateMessage,
                                                    ),
                                            ),
                                          ),
                                          if (_messages.isNotEmpty &&
                                              _messagesCanScroll)
                                            Positioned(
                                              right: 18,
                                              bottom: 10,
                                              child: _MessageScrollButton(
                                                atBottom: _messagesAtBottom,
                                                onPressed:
                                                    _toggleMessageScrollEdge,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    _AiComposer(
                                      controller: _composer,
                                      focusNode: _composerFocus,
                                      focused: _composerFocused,
                                      canSend:
                                          _composer.text.trim().isNotEmpty &&
                                          !_responding,
                                      responding: _responding,
                                      deepThinking: _deepThinking,
                                      webSearch: _webSearch,
                                      onToggleDeepThinking: () => setState(
                                        () => _deepThinking = !_deepThinking,
                                      ),
                                      onToggleWebSearch: () => setState(
                                        () => _webSearch = !_webSearch,
                                      ),
                                      attachmentMenuOpen: _attachmentMenuOpen,
                                      onAttachment: _toggleAttachmentMenu,
                                      onAttachmentAction: (action) => unawaited(
                                        _handleAttachmentAction(action),
                                      ),
                                      onVoice: _showVoiceMessage,
                                      attachmentName: _attachmentFile?.filename,
                                      onRemoveAttachment: () => setState(
                                        () => _attachmentFile = null,
                                      ),
                                      voiceActive:
                                          _recording || _holdToTalkActive,
                                      voiceMode: _voiceMode,
                                      onRequestFocus: _requestComposerFocus,
                                      onHoldToTalkStart: _beginHoldToTalk,
                                      onHoldToTalkMove: _moveHoldToTalk,
                                      onHoldToTalkEnd: _endHoldToTalk,
                                      recordingWillCancel: _holdToTalkCancel,
                                      onSend: () => unawaited(_send()),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (drawerOpen)
                      Positioned.fill(
                        child: GestureDetector(
                          key: const Key('ai-history-scrim'),
                          behavior: HitTestBehavior.opaque,
                          onTap: _closeHistory,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: drawerWidth,
                      child: Offstage(
                        offstage: !drawerOpen,
                        child: Transform.translate(
                          offset: Offset(-drawerWidth * (1 - progress), 0),
                          child: ExcludeSemantics(
                            excluding: !drawerOpen,
                            child: IgnorePointer(
                              ignoring: !drawerOpen,
                              child: Material(
                                color: AiColors.surface(context),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onHorizontalDragStart:
                                      _handleHistoryDragStart,
                                  onHorizontalDragUpdate:
                                      _handleHistoryDragUpdate,
                                  onHorizontalDragEnd: _handleHistoryDragEnd,
                                  onHorizontalDragCancel: () {
                                    if (_historyController.value < 0.5) {
                                      _closeHistory();
                                    } else {
                                      _showHistory();
                                    }
                                  },
                                  child: SafeArea(
                                    bottom: false,
                                    child: AiHistoryPanel(
                                      entries: historyEntries,
                                      modelName: _selectedModelName,
                                      onSelect: (entry) {
                                        _closeHistory();
                                        _openHistoryEntry(entry);
                                      },
                                      onOpenSettings: () {
                                        _closeHistory();
                                        widget.onOpenSettings?.call();
                                      },
                                      onRename: _renameHistoryEntry,
                                      onPin: _pinHistoryEntry,
                                      onDelete: _deleteHistoryEntry,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AiHeader extends StatelessWidget {
  const _AiHeader({
    required this.onHistory,
    required this.onNewConversation,
    required this.title,
    required this.autoRead,
    required this.onToggleAutoRead,
  });

  final VoidCallback onHistory;
  final VoidCallback onNewConversation;
  final String title;
  final bool autoRead;
  final VoidCallback onToggleAutoRead;

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                const SizedBox(width: 96),
                Expanded(
                  child: Text(
                    title.isEmpty ? text.text('新对话', 'New chat') : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AiColors.text(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.25,
                    ),
                  ),
                ),
                const SizedBox(width: 96),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                key: const Key('ai-history'),
                tooltip: text.text('对话记录', 'Chat history'),
                onPressed: onHistory,
                icon: _TwoLineMenuIcon(color: AiColors.text(context)),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const Key('ai-auto-read'),
                    tooltip: text.text('自动朗读', 'Auto read'),
                    onPressed: onToggleAutoRead,
                    icon: DeepSeekAutoReadIcon(
                      color: autoRead
                          ? AiColors.accent(context)
                          : AiColors.text(context),
                      muted: !autoRead,
                      size: 25,
                    ),
                  ),
                  IconButton(
                    key: const Key('ai-new-conversation'),
                    tooltip: text.text('新对话', 'New chat'),
                    onPressed: onNewConversation,
                    icon: DeepSeekNewChatIcon(
                      color: AiColors.text(context),
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TwoLineMenuIcon extends StatelessWidget {
  const _TwoLineMenuIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 19,
      height: 12.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 1.7,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 11,
            height: 1.7,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiWelcome extends StatelessWidget {
  const _AiWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AiBrandMark(key: Key('ai-brand-mark')),
            const SizedBox(height: 24),
            Text.rich(
              TextSpan(
                text: text.text('你好，我是 ', 'Hello, I’m '),
                style: TextStyle(
                  color: AiColors.text(context),
                  fontSize: 26.5,
                  height: 1.24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.45,
                ),
                children: [
                  TextSpan(
                    text: 'RuoQi',
                    style: TextStyle(
                      fontSize: 25.5,
                      fontFamily: 'Inter',
                      letterSpacing: -0.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AiConversation extends StatelessWidget {
  const _AiConversation({
    super.key,
    required this.messages,
    required this.responding,
    required this.scrollController,
    required this.speakingText,
    required this.speechLoading,
    required this.onCopy,
    required this.onFeedback,
    required this.onSpeak,
    required this.onShare,
    required this.onRegenerate,
  });

  final List<_AiMessage> messages;
  final bool responding;
  final ScrollController scrollController;
  final String speakingText;
  final bool speechLoading;
  final ValueChanged<_AiMessage> onCopy;
  final void Function(_AiMessage message, int feedback) onFeedback;
  final ValueChanged<_AiMessage> onSpeak;
  final ValueChanged<_AiMessage> onShare;
  final ValueChanged<_AiMessage> onRegenerate;

  @override
  Widget build(BuildContext context) {
    final showTyping =
        responding &&
        (messages.isEmpty || messages.last.role != _AiRole.assistant);
    return ListView.builder(
      key: const Key('ai-conversation'),
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 14, 18, 18),
      itemCount: messages.length + (showTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (showTyping && index == messages.length) {
          return const _AiTypingIndicator();
        }
        final message = messages[index];
        final streaming =
            responding &&
            index == messages.length - 1 &&
            message.role == _AiRole.assistant;
        return _AiMessageBubble(
          message: message,
          showActions:
              message.role == _AiRole.assistant &&
              message.content.isNotEmpty &&
              !streaming,
          onCopy: () => onCopy(message),
          onFeedback: (feedback) => onFeedback(message, feedback),
          onSpeak: () => onSpeak(message),
          speaking: message.content == speakingText && speakingText.isNotEmpty,
          speechLoading:
              message.content == speakingText &&
              speechLoading &&
              speakingText.isNotEmpty,
          onShare: () => onShare(message),
          onRegenerate: () => onRegenerate(message),
        );
      },
    );
  }
}

class _AiMessageBubble extends StatelessWidget {
  const _AiMessageBubble({
    required this.message,
    required this.showActions,
    required this.onCopy,
    required this.onFeedback,
    required this.onSpeak,
    required this.speaking,
    required this.speechLoading,
    required this.onShare,
    required this.onRegenerate,
  });

  final _AiMessage message;
  final bool showActions;
  final VoidCallback onCopy;
  final ValueChanged<int> onFeedback;
  final VoidCallback onSpeak;
  final bool speaking;
  final bool speechLoading;
  final VoidCallback onShare;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.role == _AiRole.user;
    if (fromUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            key: const Key('ai-user-message'),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.76,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            decoration: BoxDecoration(
              color: AiColors.softSurface(context),
              borderRadius: BorderRadius.circular(24),
            ),
            child: SelectableText(
              message.content,
              style: TextStyle(
                color: AiColors.text(context),
                fontSize: 18.5,
                height: 1.55,
                letterSpacing: -0.15,
              ),
            ),
          ),
        ),
      );
    }

    return KeyedSubtree(
      key: const Key('ai-assistant-message'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.deepThinking) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _AiModeTag(
                    icon: Icons.psychology_alt_outlined,
                    label: AppLocalizations.of(context)
                        .text('深度思考', 'Deep thinking'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            MarkdownBody(
              data: message.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: AiColors.text(context),
                  fontSize: 18.5,
                  height: 1.72,
                  letterSpacing: -0.08,
                ),
                h1: TextStyle(
                  color: AiColors.text(context),
                  fontSize: 23,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
                h2: TextStyle(
                  color: AiColors.text(context),
                  fontSize: 20.5,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
                h3: TextStyle(
                  color: AiColors.text(context),
                  fontSize: 19,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                ),
                listBullet: TextStyle(
                  color: AiColors.text(context),
                  fontSize: 18.5,
                  height: 1.65,
                ),
                blockSpacing: 12,
              ),
            ),
            if (showActions) ...[
              const SizedBox(height: 10),
              _AnswerActionBar(
                feedback: message.feedback,
                speaking: speaking,
                speechLoading: speechLoading,
                onCopy: onCopy,
                onFeedback: onFeedback,
                onSpeak: onSpeak,
                onShare: onShare,
                onRegenerate: onRegenerate,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AiModeTag extends StatelessWidget {
  const _AiModeTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AiColors.softSurface(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AiColors.accent(context)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AiColors.accent(context),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerActionBar extends StatelessWidget {
  const _AnswerActionBar({
    required this.feedback,
    required this.speaking,
    required this.speechLoading,
    required this.onCopy,
    required this.onFeedback,
    required this.onSpeak,
    required this.onShare,
    required this.onRegenerate,
  });

  final int feedback;
  final bool speaking;
  final bool speechLoading;
  final VoidCallback onCopy;
  final ValueChanged<int> onFeedback;
  final VoidCallback onSpeak;
  final VoidCallback onShare;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    return Row(
      key: const Key('ai-answer-actions'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _AnswerActionButton(
          tooltip: text.text('复制', 'Copy'),
          onPressed: onCopy,
          icon: Icons.content_copy_rounded,
        ),
        _AnswerActionButton(
          tooltip: text.text('有帮助', 'Helpful'),
          onPressed: () => onFeedback(1),
          icon: feedback == 1
              ? Icons.thumb_up_alt_rounded
              : Icons.thumb_up_alt_outlined,
          selected: feedback == 1,
        ),
        _AnswerActionButton(
          tooltip: text.text('没有帮助', 'Not helpful'),
          onPressed: () => onFeedback(-1),
          icon: feedback == -1
              ? Icons.thumb_down_alt_rounded
              : Icons.thumb_down_alt_outlined,
          selected: feedback == -1,
        ),
        _AnswerActionButton(
          tooltip: speaking || speechLoading
              ? text.text('停止朗读', 'Stop reading')
              : text.text('朗读', 'Read aloud'),
          onPressed: onSpeak,
          icon: speechLoading
              ? Icons.hourglass_top_rounded
              : speaking
              ? Icons.stop_circle_outlined
              : Icons.volume_up_outlined,
          selected: speaking || speechLoading,
        ),
        _AnswerActionButton(
          tooltip: text.text('分享', 'Share'),
          onPressed: onShare,
          icon: Icons.ios_share_rounded,
        ),
        _AnswerActionButton(
          tooltip: text.text('重新生成', 'Regenerate'),
          onPressed: onRegenerate,
          icon: Icons.refresh_rounded,
        ),
      ],
    );
  }
}

class _AnswerActionButton extends StatelessWidget {
  const _AnswerActionButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.selected = false,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        icon,
        size: 20,
        color: selected ? AiColors.accent(context) : AiColors.muted(context),
      ),
    );
  }
}

class _MessageScrollButton extends StatelessWidget {
  const _MessageScrollButton({required this.atBottom, required this.onPressed});

  final bool atBottom;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('ai-message-scroll-button'),
      color: AiColors.surface(context),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox.square(
          dimension: 42,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: Icon(
              atBottom
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              key: ValueKey(atBottom),
              color: AiColors.text(context),
              size: 23,
            ),
          ),
        ),
      ),
    );
  }
}

class _AiTypingIndicator extends StatelessWidget {
  const _AiTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('ai-typing-indicator'),
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: AiColors.brandGradient(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AiBrandMark(
                key: const Key('ai-typing-logo'),
                size: 16,
                color: AiColors.onAccent(context),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AiColors.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AiColors.border(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < 3; index++)
                  Container(
                    width: 5,
                    height: 5,
                    margin: EdgeInsets.only(right: index == 2 ? 0 : 5),
                    decoration: BoxDecoration(
                      color: AiColors.muted(context).withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiComposer extends StatelessWidget {
  const _AiComposer({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.canSend,
    required this.responding,
    required this.deepThinking,
    required this.webSearch,
    required this.onToggleDeepThinking,
    required this.onToggleWebSearch,
    required this.attachmentMenuOpen,
    required this.onAttachment,
    required this.onAttachmentAction,
    required this.onVoice,
    required this.onSend,
    this.attachmentName,
    this.onRemoveAttachment,
    this.voiceActive = false,
    required this.voiceMode,
    required this.onRequestFocus,
    required this.onHoldToTalkStart,
    required this.onHoldToTalkMove,
    required this.onHoldToTalkEnd,
    required this.recordingWillCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final bool canSend;
  final bool responding;
  final bool deepThinking;
  final bool webSearch;
  final VoidCallback onToggleDeepThinking;
  final VoidCallback onToggleWebSearch;
  final bool attachmentMenuOpen;
  final VoidCallback onAttachment;
  final ValueChanged<_AttachmentAction> onAttachmentAction;
  final VoidCallback onVoice;
  final VoidCallback onSend;
  final String? attachmentName;
  final VoidCallback? onRemoveAttachment;
  final bool voiceActive;
  final bool voiceMode;
  final VoidCallback onRequestFocus;
  final VoidCallback onHoldToTalkStart;
  final ValueChanged<Offset> onHoldToTalkMove;
  final VoidCallback onHoldToTalkEnd;
  final bool recordingWillCancel;

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    final canHoldToTalk = (voiceMode || controller.text.isEmpty) && !focused;
    return TextFieldTapRegion(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerUp: (_) => onHoldToTalkEnd(),
        onPointerCancel: (_) => onHoldToTalkEnd(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 8, 13, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                key: const Key('ai-composer-card'),
                duration: const Duration(milliseconds: 160),
                constraints: const BoxConstraints(minHeight: 106),
                padding: const EdgeInsets.fromLTRB(18, 7, 9, 9),
                decoration: BoxDecoration(
                  color: AiColors.surface(context),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: voiceActive
                        ? AiColors.accent(context)
                        : AiColors.border(context),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withValues(
                        alpha: AiColors.isDark(context) ? 0.2 : 0.025,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  key: const Key('ai-composer-gesture'),
                  behavior: voiceActive || canHoldToTalk
                      ? HitTestBehavior.opaque
                      : HitTestBehavior.deferToChild,
                  onTap: voiceActive ? onHoldToTalkEnd : null,
                  onLongPressStart: !voiceActive && canHoldToTalk
                      ? (_) => onHoldToTalkStart()
                      : null,
                  onLongPressMoveUpdate: voiceActive || canHoldToTalk
                      ? (details) =>
                            onHoldToTalkMove(details.localOffsetFromOrigin)
                      : null,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: voiceActive
                        ? _RecordingPanel(
                            cancel: recordingWillCancel,
                            color: AiColors.accent(context),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (attachmentName != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.insert_drive_file,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          attachmentName!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: text.text(
                                          '移除附件',
                                          'Remove attachment',
                                        ),
                                        onPressed: onRemoveAttachment,
                                        visualDensity: VisualDensity.compact,
                                        constraints:
                                            const BoxConstraints.tightFor(
                                              width: 30,
                                              height: 30,
                                            ),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(
                                height: 46,
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    if (voiceMode)
                                      Positioned.fill(
                                        child: Container(
                                          key: const Key(
                                            'ai-voice-hold-button',
                                          ),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AiColors.softSurface(
                                              context,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              13,
                                            ),
                                          ),
                                          child: Text(
                                            text.text('按住说话', 'Hold to talk'),
                                            style: TextStyle(
                                              color: AiColors.text(context),
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      TextField(
                                        key: const Key('ai-composer'),
                                        focusNode: focusNode,
                                        controller: controller,
                                        minLines: 1,
                                        maxLines: 4,
                                        keyboardType: TextInputType.multiline,
                                        textInputAction:
                                            TextInputAction.newline,
                                        cursorColor: AiColors.accent(context),
                                        onTapOutside: (_) =>
                                            focusNode.unfocus(),
                                        style: TextStyle(
                                          color: AiColors.text(context),
                                          fontSize: 18,
                                          height: 1.4,
                                        ),
                                        decoration: null,
                                      ),
                                    if (!voiceMode &&
                                        controller.text.isEmpty &&
                                        !focused)
                                      Positioned.fill(
                                        child: GestureDetector(
                                          key: const Key('ai-hold-to-talk'),
                                          behavior: HitTestBehavior.opaque,
                                          onTap: onRequestFocus,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              text.text(
                                                '发消息或按住说话',
                                                'Message or hold to talk',
                                              ),
                                              style: TextStyle(
                                                color: AiColors.hint(context),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _AiModeChip(
                                            key: const Key('ai-deep-thinking'),
                                            icon: DeepSeekThinkingIcon(
                                              color: deepThinking
                                                  ? AiColors.accent(context)
                                                  : AiColors.text(context),
                                              size: 19,
                                            ),
                                            label: text.text(
                                              '深度思考',
                                              'Deep thinking',
                                            ),
                                            selected: deepThinking,
                                            onTap: onToggleDeepThinking,
                                          ),
                                          const SizedBox(width: 7),
                                          _AiModeChip(
                                            key: const Key('ai-web-search'),
                                            icon: Icon(
                                              Icons.language_rounded,
                                              color: webSearch
                                                  ? AiColors.accent(context)
                                                  : AiColors.text(context),
                                              size: 19,
                                            ),
                                            label: text.text(
                                              '智能搜索',
                                              'Smart search',
                                            ),
                                            selected: webSearch,
                                            onTap: onToggleWebSearch,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  _AiRoundAction(
                                    key: const Key('ai-attachment-toggle'),
                                    tooltip: attachmentMenuOpen
                                        ? text.text(
                                            '关闭附件菜单',
                                            'Close attachments',
                                          )
                                        : text.text('添加附件', 'Add attachment'),
                                    onPressed: onAttachment,
                                    icon: AnimatedRotation(
                                      turns: attachmentMenuOpen ? 0.125 : 0,
                                      duration: const Duration(
                                        milliseconds: 190,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      child: DeepSeekPlusIcon(
                                        color: AiColors.text(context),
                                        size: 19,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  if (responding)
                                    _AiSendButton(
                                      enabled: false,
                                      responding: true,
                                      onTap: onSend,
                                    )
                                  else if (voiceMode)
                                    _AiRoundAction(
                                      key: const Key('ai-voice-mode-toggle'),
                                      tooltip: text.text(
                                        '切换至键盘',
                                        'Switch to keyboard',
                                      ),
                                      onPressed: onVoice,
                                      icon: Icon(
                                        Icons.keyboard_alt_outlined,
                                        color: AiColors.text(context),
                                        size: 23,
                                      ),
                                    )
                                  else if (controller.text.trim().isEmpty)
                                    _AiRoundAction(
                                      key: const Key('ai-voice-mode-toggle'),
                                      tooltip: text.text('语音输入', 'Voice input'),
                                      tooltipTriggerMode:
                                          TooltipTriggerMode.manual,
                                      onPressed: onVoice,
                                      icon: DeepSeekVoiceIcon(
                                        color: AiColors.text(context),
                                        size: 24,
                                      ),
                                    )
                                  else
                                    _AiSendButton(
                                      enabled: canSend,
                                      responding: false,
                                      onTap: onSend,
                                    ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              _AiAttachmentReveal(
                open: attachmentMenuOpen,
                child: _AiAttachmentMenu(onSelected: onAttachmentAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiAttachmentReveal extends StatefulWidget {
  const _AiAttachmentReveal({required this.open, required this.child});

  final bool open;
  final Widget child;

  @override
  State<_AiAttachmentReveal> createState() => _AiAttachmentRevealState();
}

class _AiAttachmentRevealState extends State<_AiAttachmentReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 210),
    reverseDuration: const Duration(milliseconds: 150),
    value: widget.open ? 1 : 0,
  );

  @override
  void didUpdateWidget(covariant _AiAttachmentReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open == oldWidget.open) {
      return;
    }
    if (widget.open) {
      unawaited(_controller.forward());
    } else {
      unawaited(_controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final progress =
            (_controller.status == AnimationStatus.reverse
                    ? Curves.easeInCubic
                    : Curves.easeOutCubic)
                .transform(_controller.value);
        if (progress == 0) {
          return const SizedBox.shrink();
        }
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: progress,
            child: IgnorePointer(
              ignoring: !widget.open,
              child: ExcludeSemantics(
                excluding: !widget.open,
                child: Opacity(
                  opacity: progress,
                  child: Transform.translate(
                    offset: Offset(0, -8 * (1 - progress)),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AiAttachmentMenu extends StatelessWidget {
  const _AiAttachmentMenu({required this.onSelected});

  final ValueChanged<_AttachmentAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    final shortcuts = <_AttachmentShortcut>[
      _AttachmentShortcut(
        action: _AttachmentAction.camera,
        icon: Icons.photo_camera_outlined,
        label: text.text('拍照', 'Camera'),
      ),
      _AttachmentShortcut(
        action: _AttachmentAction.gallery,
        icon: Icons.photo_library_outlined,
        label: text.text('相册', 'Photos'),
      ),
      _AttachmentShortcut(
        action: _AttachmentAction.upload,
        icon: Icons.attach_file_rounded,
        label: text.text('文件', 'File'),
      ),
      _AttachmentShortcut(
        action: _AttachmentAction.ocr,
        icon: Icons.document_scanner_outlined,
        label: text.text('OCR', 'OCR'),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: Row(
        key: const Key('ai-attachment-menu'),
        children: [
          for (var index = 0; index < shortcuts.length; index++) ...[
            Expanded(
              child: _AiAttachmentTile(
                key: Key('ai-attachment-${shortcuts[index].action.name}'),
                icon: shortcuts[index].icon,
                label: shortcuts[index].label,
                onTap: () => onSelected(shortcuts[index].action),
              ),
            ),
            if (index != shortcuts.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _AttachmentShortcut {
  const _AttachmentShortcut({
    required this.action,
    required this.icon,
    required this.label,
  });

  final _AttachmentAction action;
  final IconData icon;
  final String label;
}

class _AiAttachmentTile extends StatelessWidget {
  const _AiAttachmentTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = AiColors.isDark(context);
    final radius = BorderRadius.circular(16);
    return Material(
      color: AiColors.searchSurface(context),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: dark
            ? BorderSide.none
            : BorderSide(
                color: AiColors.border(context).withValues(alpha: 0.8),
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AiColors.accent(context).withValues(alpha: 0.12),
        highlightColor: AiColors.accent(context).withValues(alpha: 0.06),
        child: SizedBox(
          height: 82,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AiColors.text(context), size: 27),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AiColors.text(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordingPanel extends StatelessWidget {
  const _RecordingPanel({required this.cancel, required this.color});

  final bool cancel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    return SizedBox(
      key: const Key('ai-recording-panel'),
      height: 228,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            cancel
                ? text.text('松开取消', 'Release to cancel')
                : text.text('松手发送，上滑取消', 'Release to send, swipe up to cancel'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cancel ? AiColors.danger(context) : AiColors.text(context),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 24),
          _RecordingWaveform(color: cancel ? AiColors.danger(context) : color),
        ],
      ),
    );
  }
}

class _RecordingWaveform extends StatefulWidget {
  const _RecordingWaveform({required this.color});

  final Color color;

  @override
  State<_RecordingWaveform> createState() => _RecordingWaveformState();
}

class _RecordingWaveformState extends State<_RecordingWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth / 4).floor().clamp(32, 80);
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var index = 0; index < count; index++) _waveBar(index),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _waveBar(int index) {
    final phase = _controller.value * math.pi * 2;
    final broadWave = (math.sin(index * 0.2 + phase) + 1) / 2;
    final detailWave = (math.sin(index * 0.61 - phase * 1.4) + 1) / 2;
    final height = 7 + 39 * (0.18 + broadWave * 0.62 + detailWave * 0.2);
    return Container(
      width: 1.8,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1.1),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _AiModeChip extends StatelessWidget {
  const _AiModeChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AiColors.softSurface(context)
          : AiColors.surface(context),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? AiColors.softSurface(context)
              : AiColors.border(context),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 34,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? AiColors.accent(context)
                        : AiColors.text(context),
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AiRoundAction extends StatelessWidget {
  const _AiRoundAction({
    super.key,
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.tooltipTriggerMode,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget icon;
  final TooltipTriggerMode? tooltipTriggerMode;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      triggerMode: tooltipTriggerMode,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onPressed,
          radius: 22,
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AiColors.text(context),
                    width: 1.35,
                  ),
                ),
                alignment: Alignment.center,
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiSendButton extends StatelessWidget {
  const _AiSendButton({
    required this.enabled,
    required this.responding,
    required this.onTap,
  });

  final bool enabled;
  final bool responding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).text('发送', 'Send');
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkResponse(
            key: const Key('ai-send'),
            onTap: enabled ? onTap : null,
            radius: 22,
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: enabled
                        ? AiColors.accent(context)
                        : AiColors.softSurface(context),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: responding
                      ? SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: AiColors.accent(context),
                          ),
                        )
                      : Icon(
                          Icons.arrow_upward_rounded,
                          color: enabled
                              ? AiColors.onAccent(context)
                              : AiColors.muted(context),
                          size: 16,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _AttachmentAction { camera, gallery, upload, files, ocr, search, fetch }

enum _AiRole { user, assistant }

class _AiMessage {
  const _AiMessage.user(this.content)
    : role = _AiRole.user,
      deepThinking = false,
      webSearch = false,
      feedback = 0;

  const _AiMessage.assistant(
    this.content, {
    this.deepThinking = false,
    this.webSearch = false,
  }) : role = _AiRole.assistant,
       feedback = 0;

  final _AiRole role;
  final String content;
  final bool deepThinking;
  final bool webSearch;
  final int feedback;

  _AiMessage copyWith({
    String? content,
    bool? deepThinking,
    bool? webSearch,
    int? feedback,
  }) {
    return _AiMessage._(
      role: role,
      content: content ?? this.content,
      deepThinking: deepThinking ?? this.deepThinking,
      webSearch: webSearch ?? this.webSearch,
      feedback: feedback ?? this.feedback,
    );
  }

  const _AiMessage._({
    required this.role,
    required this.content,
    required this.deepThinking,
    required this.webSearch,
    required this.feedback,
  });
}

const String _deepSeekSystemPrompt =
    'You are RuoQi AI, a helpful assistant. Answer in the user language.';
