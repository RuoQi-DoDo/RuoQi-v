import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/rendering.dart';
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

const _aiIconButtonStyle = ButtonStyle(
  overlayColor: WidgetStatePropertyAll<Color?>(Colors.transparent),
  splashFactory: NoSplash.splashFactory,
);

const _aiMessageListBottomPadding = 18.0;
const _aiMessageListScrollButtonPadding = 52.0;
const _aiMessageBottomTolerance = 24.0;

/// Lets the host page clear an active text selection before handling Back.
class AiTextSelectionController {
  Object? _owner;
  VoidCallback? _dismiss;

  bool get isActive => _owner != null;

  void dismiss() {
    if (isActive) {
      _dismiss?.call();
    }
  }

  void _activate(Object owner, VoidCallback dismiss) {
    _owner = owner;
    _dismiss = dismiss;
  }

  void _deactivate(Object owner) {
    if (_owner != owner) {
      return;
    }
    _owner = null;
    _dismiss = null;
  }
}

/// A DeepSeek-inspired AI conversation surface with local demo interactions.
class AiPage extends StatefulWidget {
  const AiPage({
    super.key,
    this.onBack,
    this.onOpenSettings,
    this.settingsStore,
    this.api,
    this.historyStore,
    this.ttsCache,
    this.recordingReader,
    this.scrollController,
    this.textSelectionController,
  });

  final VoidCallback? onBack;
  final VoidCallback? onOpenSettings;
  final DeepSeekSettingsStore? settingsStore;
  final DeepSeekApi? api;
  final ChatHistoryStore? historyStore;
  final DeepSeekTtsCache? ttsCache;
  final Future<Uint8List> Function(String path)? recordingReader;
  final ScrollController? scrollController;
  final AiTextSelectionController? textSelectionController;

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
  Timer? _noticeTimer;
  OverlayEntry? _noticeEntry;
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
  bool _followResponseScroll = true;
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
    _noticeTimer?.cancel();
    _noticeEntry?.remove();
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

  void _handleHeaderBack() {
    final selection = widget.textSelectionController;
    if (selection?.isActive ?? false) {
      selection!.dismiss();
      return;
    }
    widget.onBack?.call();
  }

  void _newConversation() {
    if (_messages.isEmpty && _activeConversationId == null) {
      _showTransientNotice(
        AppLocalizations.of(context).text('已经在新对话中', 'Already in a new chat'),
      );
      return;
    }
    _responseTimer?.cancel();
    _chatSubscription?.cancel();
    _hideTransientNotice();
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
      _followResponseScroll = true;
    });
  }

  void _showTransientNotice(String message) {
    if (!mounted) {
      return;
    }
    _hideTransientNotice();
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: Center(child: _AiTransientNotice(message: message)),
        ),
      ),
    );
    overlay.insert(entry);
    _noticeEntry = entry;
    _noticeTimer = Timer(const Duration(milliseconds: 1600), () {
      if (_noticeEntry == entry) {
        _hideTransientNotice();
      }
    });
  }

  void _hideTransientNotice() {
    _noticeTimer?.cancel();
    _noticeTimer = null;
    _noticeEntry?.remove();
    _noticeEntry = null;
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
        _showTransientNotice(
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
      _showTransientNotice(
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
      _followResponseScroll = true;
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
    final text = AppLocalizations.of(context);
    setState(() => _autoRead = enabled);
    _showTransientNotice(
      text.text(
        enabled ? '已开启自动朗读' : '已关闭自动朗读',
        enabled ? 'Auto read on' : 'Auto read off',
      ),
    );
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
          _showTransientNotice(
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
        _showTransientNotice(_chatErrorMessage(error));
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
        _showTransientNotice(
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
      _showTransientNotice(AppLocalizations.of(context).text('已复制', 'Copied'));
    }
  }

  void _editMessage(_AiMessage message) {
    if (message.role != _AiRole.user) {
      return;
    }
    _setComposerText(message.content);
    _showTransientNotice(
      AppLocalizations.of(
        context,
      ).text('已载入输入框，可修改后发送', 'Loaded into the composer. Edit and send again.'),
    );
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
    final title = AppLocalizations.of(context)
        .text('RuoQi AI 对话', 'RuoQi AI conversation');
    final conversationId = _activeConversationId;
    final shareUri = conversationId == null
        ? null
        : Uri.parse('https://link.amiemall.com/share')
              .replace(pathSegments: ['share', conversationId]);
    await SharePlus.instance.share(
      shareUri == null
          ? ShareParams(
              text: content,
              title: title,
              subject: title,
              sharePositionOrigin: box is RenderBox
                  ? box.localToGlobal(Offset.zero) & box.size
                  : null,
            )
          : ShareParams(
              uri: shareUri,
              title: title,
              subject: title,
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
    if (!_followResponseScroll) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_messageScroll.hasClients || !_followResponseScroll) {
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
    final atBottom =
        position.maxScrollExtent - position.pixels <= _messageBottomTolerance;
    final userScrolledAway =
        _responding &&
        _followResponseScroll &&
        !atBottom &&
        position.userScrollDirection != ScrollDirection.idle;
    final resumeFollow = atBottom && !_followResponseScroll;
    final becameScrollable = canScroll && !_messagesCanScroll;
    if (canScroll != _messagesCanScroll ||
        atBottom != _messagesAtBottom ||
        userScrolledAway ||
        resumeFollow) {
      setState(() {
        _messagesCanScroll = canScroll;
        _messagesAtBottom = atBottom;
        if (userScrolledAway) {
          _followResponseScroll = false;
        }
        if (resumeFollow) {
          _followResponseScroll = true;
        }
      });
    }
    if (becameScrollable && _followResponseScroll) {
      _scrollMessagesToEnd();
    }
  }

  double get _messageBottomTolerance =>
      _aiMessageBottomTolerance +
      (_messagesCanScroll
          ? _aiMessageListScrollButtonPadding - _aiMessageListBottomPadding
          : 0);

  void _handleUserMessageScroll(ScrollDirection direction) {
    if (direction != ScrollDirection.idle) {
      _pauseResponseScroll();
      return;
    }
    if (!_responding || _followResponseScroll || !_messageScroll.hasClients) {
      return;
    }
    final position = _messageScroll.position;
    if (position.maxScrollExtent - position.pixels <= _messageBottomTolerance) {
      setState(() => _followResponseScroll = true);
    }
  }

  void _toggleMessageScrollEdge() {
    if (!_messageScroll.hasClients) {
      return;
    }
    final goToBottom = !_messagesAtBottom;
    setState(() => _followResponseScroll = goToBottom);
    _messageScroll.animateTo(
      goToBottom ? _messageScroll.position.maxScrollExtent : 0,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _pauseResponseScroll() {
    if (!_responding) {
      return;
    }
    if (_messageScroll.hasClients) {
      final position = _messageScroll.position;
      if (position.activity is DrivenScrollActivity) {
        position.jumpTo(position.pixels);
      }
    }
    if (_followResponseScroll) {
      setState(() => _followResponseScroll = false);
    }
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
      _followResponseScroll = true;
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
      _showTransientNotice(
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
        _showTransientNotice(
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
        _showTransientNotice(
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
        _showTransientNotice(
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
      _showTransientNotice(
        AppLocalizations.of(context)
            .text('${file.filename} 已上传', '${file.filename} uploaded'),
      );
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        _showTransientNotice(_chatErrorMessage(error));
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
                                    _showTransientNotice(
                                      '${detail.filename} · ${detail.id}',
                                    );
                                  }
                                } on DeepSeekApiException catch (error) {
                                  if (context.mounted) {
                                    _showTransientNotice(
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
                                      _showTransientNotice(
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
        _showTransientNotice(_chatErrorMessage(error));
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
      _showTransientNotice(
        AppLocalizations.of(context).text(
          '已识别 ${result.pageCount} 页',
          'Recognized ${result.pageCount} pages',
        ),
      );
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        _showTransientNotice(_chatErrorMessage(error));
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
      _followResponseScroll = true;
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
        _showTransientNotice(_chatErrorMessage(error));
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
        _showTransientNotice(_chatErrorMessage(error));
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

  Future<void> _cancelRecorderQuietly() async {
    try {
      await _recorder.cancel();
    } catch (_) {
      // The gesture already ended; there is no recording left to report.
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
            _showTransientNotice(
              AppLocalizations.of(context)
                  .text('请允许使用麦克风', 'Microphone permission is required'),
            );
          }
          return;
        }
        if (!mounted || (fromHold && !_holdToTalkActive)) {
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
        if (!mounted) {
          await _cancelRecorderQuietly();
          return;
        }
        if (fromHold && !_holdToTalkActive) {
          await _cancelRecorderQuietly();
          if (mounted) {
            setState(() {
              _recording = false;
              _holdToTalkCancel = false;
            });
          }
          return;
        }
        setState(() => _recording = true);
      }
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        setState(() => _recording = false);
        _showTransientNotice(_chatErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _recording = false);
        _showTransientNotice(
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
        _showTransientNotice(
          AppLocalizations.of(context).text('未识别到语音内容', 'No speech detected'),
        );
        return;
      }
      await _send(transcript);
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        setState(() => _recording = false);
        _showTransientNotice(_chatErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _recording = false);
        _showTransientNotice(
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
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: AiColors.selection,
        selectionHandleColor: AiColors.selectionHandle,
      ),
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
                              body: Listener(
                                behavior: HitTestBehavior.translucent,
                                onPointerDown: (_) => _pauseResponseScroll(),
                                child: SafeArea(
                                  bottom: false,
                                  child: Column(
                                    children: [
                                      _AiHeader(
                                        onBack: _handleHeaderBack,
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
                                                        reserveScrollButtonSpace:
                                                            _messagesCanScroll,
                                                        speakingText:
                                                            _speakingText,
                                                        speechLoading:
                                                            _speechLoading,
                                                        textSelectionController:
                                                            widget
                                                                .textSelectionController,
                                                        onCopy: (message) =>
                                                            unawaited(
                                                              _copyMessage(
                                                                message.content,
                                                              ),
                                                            ),
                                                        onEdit: _editMessage,
                                                        onFeedback:
                                                            _setMessageFeedback,
                                                        onPauseAutoScroll:
                                                            _pauseResponseScroll,
                                                        onUserScroll:
                                                            _handleUserMessageScroll,
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
                                        onAttachmentAction: (action) =>
                                            unawaited(
                                              _handleAttachmentAction(action),
                                            ),
                                        onVoice: _showVoiceMessage,
                                        attachmentName:
                                            _attachmentFile?.filename,
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
    required this.onBack,
    required this.onHistory,
    required this.onNewConversation,
    required this.title,
    required this.autoRead,
    required this.onToggleAutoRead,
  });

  final VoidCallback? onBack;
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onBack != null)
                    IconButton(
                      key: const Key('ai-back'),
                      style: _aiIconButtonStyle,
                      tooltip: text.text('返回聊天', 'Back to chat'),
                      onPressed: onBack,
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AiColors.text(context),
                        size: 20,
                      ),
                    ),
                  IconButton(
                    key: const Key('ai-history'),
                    style: _aiIconButtonStyle,
                    tooltip: text.text('对话记录', 'Chat history'),
                    onPressed: onHistory,
                    icon: _TwoLineMenuIcon(color: AiColors.text(context)),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AiHeaderAction(
                    buttonKey: const Key('ai-auto-read'),
                    label: text.text('自动朗读', 'Auto read'),
                    onPressed: onToggleAutoRead,
                    icon: DeepSeekAutoReadIcon(
                      color: autoRead
                          ? AiColors.accentText(context)
                          : AiColors.text(context),
                      muted: !autoRead,
                      size: 27,
                    ),
                  ),
                  _AiHeaderAction(
                    buttonKey: const Key('ai-new-conversation'),
                    label: text.text('新对话', 'New chat'),
                    onPressed: onNewConversation,
                    onLongPress: onNewConversation,
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

class _AiHeaderAction extends StatelessWidget {
  const _AiHeaderAction({
    required this.buttonKey,
    required this.label,
    required this.onPressed,
    required this.icon,
    this.onLongPress,
  });

  final Key buttonKey;
  final String label;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      key: buttonKey,
      style: _aiIconButtonStyle,
      onPressed: onPressed,
      icon: icon,
    );
    return Semantics(
      button: true,
      label: label,
      onTap: onPressed,
      onLongPress: onLongPress,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: onLongPress ?? () {},
        child: button,
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
            const AiBrandMark(key: Key('ai-brand-mark'), size: 72),
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

class _AiTransientNotice extends StatelessWidget {
  const _AiTransientNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return PageTransientNotice(
      key: const Key('ai-transient-notice'),
      message: message,
    );
  }
}

class _AiConversation extends StatelessWidget {
  const _AiConversation({
    super.key,
    required this.messages,
    required this.responding,
    required this.scrollController,
    required this.reserveScrollButtonSpace,
    required this.speakingText,
    required this.speechLoading,
    required this.textSelectionController,
    required this.onCopy,
    required this.onEdit,
    required this.onFeedback,
    required this.onPauseAutoScroll,
    required this.onUserScroll,
    required this.onSpeak,
    required this.onShare,
    required this.onRegenerate,
  });

  final List<_AiMessage> messages;
  final bool responding;
  final ScrollController scrollController;
  final bool reserveScrollButtonSpace;
  final String speakingText;
  final bool speechLoading;
  final AiTextSelectionController? textSelectionController;
  final ValueChanged<_AiMessage> onCopy;
  final ValueChanged<_AiMessage> onEdit;
  final void Function(_AiMessage message, int feedback) onFeedback;
  final VoidCallback onPauseAutoScroll;
  final ValueChanged<ScrollDirection> onUserScroll;
  final ValueChanged<_AiMessage> onSpeak;
  final ValueChanged<_AiMessage> onShare;
  final ValueChanged<_AiMessage> onRegenerate;

  @override
  Widget build(BuildContext context) {
    final showTyping =
        responding &&
        (messages.isEmpty || messages.last.role != _AiRole.assistant);
    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        onUserScroll(notification.direction);
        return false;
      },
      child: ListView.builder(
        key: const Key('ai-conversation'),
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
          24,
          14,
          18,
          reserveScrollButtonSpace
              ? _aiMessageListScrollButtonPadding
              : _aiMessageListBottomPadding,
        ),
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
            onEdit: () => onEdit(message),
            onFeedback: (feedback) => onFeedback(message, feedback),
            onPauseAutoScroll: onPauseAutoScroll,
            onSpeak: () => onSpeak(message),
            speaking:
                message.content == speakingText && speakingText.isNotEmpty,
            speechLoading:
                message.content == speakingText &&
                speechLoading &&
                speakingText.isNotEmpty,
            textSelectionController: textSelectionController,
            onShare: () => onShare(message),
            onRegenerate: () => onRegenerate(message),
          );
        },
      ),
    );
  }
}

class _AiMessageBubble extends StatefulWidget {
  const _AiMessageBubble({
    required this.message,
    required this.showActions,
    required this.onCopy,
    required this.onEdit,
    required this.onFeedback,
    required this.onPauseAutoScroll,
    required this.onSpeak,
    required this.speaking,
    required this.speechLoading,
    required this.textSelectionController,
    required this.onShare,
    required this.onRegenerate,
  });

  final _AiMessage message;
  final bool showActions;
  final VoidCallback onCopy;
  final VoidCallback onEdit;
  final ValueChanged<int> onFeedback;
  final VoidCallback onPauseAutoScroll;
  final VoidCallback onSpeak;
  final bool speaking;
  final bool speechLoading;
  final AiTextSelectionController? textSelectionController;
  final VoidCallback onShare;
  final VoidCallback onRegenerate;

  @override
  State<_AiMessageBubble> createState() => _AiMessageBubbleState();
}

class _AiMessageBubbleState extends State<_AiMessageBubble> {
  final GlobalKey<SelectionAreaState> _selectionAreaKey =
      GlobalKey<SelectionAreaState>();
  final GlobalKey _selectionContentKey = GlobalKey();
  OverlayEntry? _selectionEndHandleEntry;
  Offset? _selectionEndHandlePosition;
  Offset? _selectionAnchor;
  bool _selectingText = false;
  bool _enteringTextSelection = false;

  TextStyle _userTextStyle(BuildContext context) {
    return TextStyle(
      color: AiColors.text(context),
      fontSize: 18.5,
      height: 1.55,
      letterSpacing: -0.15,
    );
  }

  Widget _selectableContent(Widget child) {
    return SelectionArea(
      key: _selectionAreaKey,
      contextMenuBuilder: _buildSelectionToolbar,
      onSelectionChanged: _handleSelectionChanged,
      child: Builder(key: _selectionContentKey, builder: (_) => child),
    );
  }

  void _exitTextSelection() {
    _selectionAreaKey.currentState?.selectableRegion.clearSelection();
    _finishTextSelection();
  }

  void _finishTextSelection() {
    _removeSelectionEndHandle();
    widget.textSelectionController?._deactivate(this);
    if (!mounted || !_selectingText) {
      return;
    }
    setState(() => _selectingText = false);
  }

  void _handleSelectionChanged(SelectedContent? content) {
    if (!_selectingText || _enteringTextSelection) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_selectingText || _enteringTextSelection) {
        return;
      }
      final region = _selectionAreaKey.currentState?.selectableRegion;
      final hasSelection =
          region?.contextMenuButtonItems.any(
            (item) => item.kind == ContextMenuButtonKind.copy,
          ) ??
          false;
      if (!hasSelection) {
        _finishTextSelection();
      } else {
        _refreshSelectionEndHandle();
      }
    });
  }

  Future<void> _enterTextSelection() async {
    final anchor = _selectionAnchor;
    _enteringTextSelection = true;
    widget.textSelectionController?._activate(this, _exitTextSelection);
    setState(() => _selectingText = true);
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }

    // Showing the overlay through the public selection API also creates the
    // handles and toolbar. Replacing the selection with the paragraph beneath
    // the original long press then matches DeepSeek's in-place behavior.
    final region = _selectionAreaKey.currentState?.selectableRegion;
    region?.selectAll(SelectionChangedCause.toolbar);
    final selectionContext = _selectionContentKey.currentContext;
    if (anchor != null &&
        selectionContext != null &&
        selectionContext.mounted) {
      final registrar = SelectionContainer.maybeOf(selectionContext);
      if (registrar is SelectionContainerDelegate) {
        registrar.dispatchSelectionEvent(
          SelectParagraphSelectionEvent(globalPosition: anchor),
        );
        _showSelectionEndHandle(selectionContext);
      }
    }
    _enteringTextSelection = false;
  }

  void _showSelectionEndHandle(BuildContext selectionContext) {
    if (widget.message.role != _AiRole.assistant) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_selectingText || !selectionContext.mounted) {
        return;
      }
      final position = _findSelectionEndPoint();
      if (position == null) {
        return;
      }
      _removeSelectionEndHandle();
      _selectionEndHandlePosition = position;
      final entry = OverlayEntry(
        builder: (context) {
          final currentPosition = _selectionEndHandlePosition;
          if (currentPosition == null) {
            return const SizedBox.shrink();
          }
          return Positioned(
            left: currentPosition.dx - 16,
            top: currentPosition.dy - 14,
            child: _AiSelectionEndHandle(
              key: const Key('ai-selection-end-handle'),
              color: AiColors.selectionHandle,
              onDragUpdate: _handleSelectionEndHandleDragUpdate,
            ),
          );
        },
      );
      Overlay.of(selectionContext, rootOverlay: true).insert(entry);
      _selectionEndHandleEntry = entry;
    });
  }

  Offset? _findSelectionEndPoint() {
    final selectionContext = _selectionContentKey.currentContext;
    if (selectionContext == null || !selectionContext.mounted) {
      return null;
    }
    final registrar = SelectionContainer.maybeOf(selectionContext);
    if (registrar is! MultiSelectableSelectionContainerDelegate) {
      return null;
    }

    Offset? result;
    for (final selectable in registrar.selectables) {
      final range = selectable.getSelection();
      final geometry = selectable.value;
      if (range == null ||
          range.endOffset <= range.startOffset ||
          geometry.selectionRects.isEmpty) {
        continue;
      }
      final rect = geometry.selectionRects.last;
      final position = MatrixUtils.transformPoint(
        selectable.getTransformTo(null),
        Offset(rect.right, rect.bottom),
      );
      if (result == null ||
          position.dy > result.dy ||
          (position.dy == result.dy && position.dx > result.dx)) {
        result = position;
      }
    }
    return result;
  }

  void _handleSelectionEndHandleDragUpdate(DragUpdateDetails details) {
    final selectionContext = _selectionContentKey.currentContext;
    if (selectionContext == null || !selectionContext.mounted) {
      return;
    }
    final registrar = SelectionContainer.maybeOf(selectionContext);
    if (registrar is SelectionContainerDelegate) {
      registrar.dispatchSelectionEvent(
        SelectionEdgeUpdateEvent.forEnd(globalPosition: details.globalPosition),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshSelectionEndHandle();
      });
    }
  }

  void _refreshSelectionEndHandle() {
    if (!mounted || !_selectingText) {
      return;
    }
    final position = _findSelectionEndPoint();
    if (position == null) {
      _removeSelectionEndHandle();
      return;
    }
    _selectionEndHandlePosition = position;
    _selectionEndHandleEntry?.markNeedsBuild();
  }

  void _removeSelectionEndHandle() {
    _selectionEndHandleEntry?.remove();
    _selectionEndHandleEntry?.dispose();
    _selectionEndHandleEntry = null;
    _selectionEndHandlePosition = null;
  }

  @override
  void dispose() {
    _removeSelectionEndHandle();
    widget.textSelectionController?._deactivate(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
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
            child: _selectingText
                ? _selectableContent(
                    Text(
                      message.content,
                      key: const Key('ai-user-selectable-text'),
                      style: _userTextStyle(context),
                    ),
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPressStart: (details) {
                      _selectionAnchor = details.globalPosition;
                      unawaited(
                        _showMessageMenu(context, details.globalPosition),
                      );
                    },
                    child: Text(
                      message.content,
                      style: _userTextStyle(context),
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
            _selectingText
                ? _selectableContent(
                    MarkdownBody(
                      key: const Key('ai-assistant-selectable-message'),
                      data: message.content,
                      selectable: false,
                      styleSheet: _assistantMarkdownStyle(context),
                    ),
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPressStart: (details) {
                      _selectionAnchor = details.globalPosition;
                      unawaited(
                        _showMessageMenu(context, details.globalPosition),
                      );
                    },
                    child: MarkdownBody(
                      data: message.content,
                      selectable: false,
                      styleSheet: _assistantMarkdownStyle(context),
                    ),
                  ),
            if (widget.showActions) ...[
              const SizedBox(height: 10),
              _AnswerActionBar(
                feedback: message.feedback,
                speaking: widget.speaking,
                speechLoading: widget.speechLoading,
                onCopy: widget.onCopy,
                onFeedback: widget.onFeedback,
                onSpeak: widget.onSpeak,
                onShare: widget.onShare,
                onRegenerate: widget.onRegenerate,
              ),
            ],
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _assistantMarkdownStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MarkdownStyleSheet(
      a: TextStyle(
        color: AiColors.accentText(context),
        decoration: TextDecoration.underline,
        decorationColor: AiColors.accentText(context),
      ),
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
      strong: TextStyle(
        color: AiColors.text(context),
        fontWeight: FontWeight.w600,
      ),
      em: const TextStyle(fontStyle: FontStyle.italic),
      del: TextStyle(
        color: AiColors.muted(context),
        decoration: TextDecoration.lineThrough,
      ),
      code: TextStyle(
        color: AiColors.text(context),
        backgroundColor: scheme.surfaceContainerHigh,
        fontFamily: 'monospace',
        fontSize: 16,
        height: 1.45,
      ),
      codeblockPadding: const EdgeInsets.all(14),
      codeblockDecoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AiColors.border(context)),
      ),
      blockquote: TextStyle(
        color: AiColors.muted(context),
        fontSize: 17.5,
        height: 1.65,
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      blockquoteDecoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: AiColors.accent(context), width: 3),
        ),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AiColors.border(context), width: 0.8),
        ),
      ),
      listBullet: TextStyle(
        color: AiColors.text(context),
        fontSize: 18.5,
        height: 1.65,
      ),
      tableHead: TextStyle(
        color: AiColors.text(context),
        fontSize: 14.5,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      tableBody: TextStyle(
        color: AiColors.text(context),
        fontSize: 15,
        height: 1.5,
      ),
      tableHeadAlign: TextAlign.center,
      tableBorder: TableBorder.all(color: AiColors.border(context), width: 0.8),
      tableColumnWidth: const FlexColumnWidth(),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      tableCellsDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      tablePadding: const EdgeInsets.only(top: 8, bottom: 14),
      tableVerticalAlignment: TableCellVerticalAlignment.top,
      blockSpacing: 12,
    );
  }

  Future<void> _showMessageMenu(
    BuildContext context,
    Offset globalPosition,
  ) async {
    widget.onPauseAutoScroll();
    final fromUser = widget.message.role == _AiRole.user;
    final text = AppLocalizations.of(context);
    final overlayBox =
        Overlay.of(context, rootOverlay: true).context.findRenderObject()
            as RenderBox;
    final localPosition = overlayBox.globalToLocal(globalPosition);
    final position = RelativeRect.fromLTRB(
      localPosition.dx,
      localPosition.dy,
      overlayBox.size.width - localPosition.dx,
      overlayBox.size.height - localPosition.dy,
    );

    PopupMenuItem<_AiMessageMenuAction> item(
      _AiMessageMenuAction value,
      IconData icon,
      String label, {
      bool flipHorizontally = false,
    }) {
      final iconWidget = Icon(icon, color: Colors.white, size: 19);
      return PopupMenuItem<_AiMessageMenuAction>(
        value: value,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (flipHorizontally)
              Transform.flip(flipX: true, child: iconWidget)
            else
              iconWidget,
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final divider = const PopupMenuDivider(
      height: 1,
      thickness: 1,
      color: Color(0xFF3C3C3C),
    );
    final items = fromUser
        ? <PopupMenuEntry<_AiMessageMenuAction>>[
            item(
              _AiMessageMenuAction.copy,
              Icons.content_copy_rounded,
              text.text('复制', 'Copy'),
            ),
            item(
              _AiMessageMenuAction.selectText,
              Icons.text_fields_rounded,
              text.text('选择文本', 'Select text'),
            ),
            divider,
            item(
              _AiMessageMenuAction.edit,
              Icons.edit_outlined,
              text.text('修改', 'Edit'),
            ),
            item(
              _AiMessageMenuAction.share,
              Icons.reply_rounded,
              text.text('分享', 'Share'),
              flipHorizontally: true,
            ),
          ]
        : <PopupMenuEntry<_AiMessageMenuAction>>[
            item(
              _AiMessageMenuAction.copy,
              Icons.content_copy_rounded,
              text.text('复制', 'Copy'),
            ),
            item(
              _AiMessageMenuAction.selectText,
              Icons.text_fields_rounded,
              text.text('选择文本', 'Select text'),
            ),
            divider,
            item(
              _AiMessageMenuAction.regenerate,
              Icons.refresh_rounded,
              text.text('重新生成', 'Regenerate'),
            ),
            item(
              _AiMessageMenuAction.like,
              Icons.thumb_up_alt_outlined,
              text.text('喜欢', 'Like'),
            ),
            item(
              _AiMessageMenuAction.dislike,
              Icons.thumb_down_alt_outlined,
              text.text('不喜欢', 'Dislike'),
            ),
            divider,
            item(
              _AiMessageMenuAction.read,
              Icons.volume_up_outlined,
              text.text('朗读', 'Read aloud'),
            ),
            item(
              _AiMessageMenuAction.share,
              Icons.reply_rounded,
              text.text('分享', 'Share'),
              flipHorizontally: true,
            ),
          ];

    final action = await showMenu<_AiMessageMenuAction>(
      context: context,
      useRootNavigator: true,
      position: position,
      items: items,
      color: const Color(0xFF2A2A2A),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black54,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      constraints: BoxConstraints(
        minWidth: fromUser ? 194 : 224,
        maxWidth: 280,
      ),
      menuPadding: const EdgeInsets.symmetric(vertical: 4),
    );
    if (!context.mounted || action == null) {
      return;
    }
    switch (action) {
      case _AiMessageMenuAction.copy:
        widget.onCopy();
      case _AiMessageMenuAction.selectText:
        await _enterTextSelection();
      case _AiMessageMenuAction.edit:
        widget.onEdit();
      case _AiMessageMenuAction.share:
        widget.onShare();
      case _AiMessageMenuAction.regenerate:
        widget.onRegenerate();
      case _AiMessageMenuAction.like:
        widget.onFeedback(1);
      case _AiMessageMenuAction.dislike:
        widget.onFeedback(-1);
      case _AiMessageMenuAction.read:
        widget.onSpeak();
    }
  }

  Widget _buildSelectionToolbar(
    BuildContext context,
    SelectableRegionState selectableRegionState,
  ) {
    final text = AppLocalizations.of(context);
    final items = selectableRegionState.contextMenuButtonItems;

    ContextMenuButtonItem? itemFor(ContextMenuButtonKind kind) {
      for (final item in items) {
        if (item.kind == kind) {
          return item;
        }
      }
      return null;
    }

    final copy = itemFor(ContextMenuButtonKind.copy);
    final selectAll = itemFor(ContextMenuButtonKind.selectAll);
    final share = itemFor(ContextMenuButtonKind.share);
    final anchors = selectableRegionState.contextMenuAnchors;

    return _AiTextSelectionToolbar(
      key: const Key('ai-text-selection-toolbar'),
      anchorAbove: anchors.primaryAnchor,
      anchorBelow: anchors.secondaryAnchor ?? anchors.primaryAnchor,
      buttons: [
        if (copy?.onPressed case final onPressed?)
          _AiTextSelectionToolbarButton(
            key: const Key('ai-selection-copy'),
            icon: Icons.content_copy_rounded,
            label: text.text('复制', 'Copy'),
            onPressed: onPressed,
          ),
        if (selectAll?.onPressed case final onPressed?)
          _AiTextSelectionToolbarButton(
            key: const Key('ai-selection-select-all'),
            icon: Icons.check_box_rounded,
            label: text.text('全选', 'Select all'),
            onPressed: onPressed,
          ),
        if (share?.onPressed case final onPressed?)
          _AiTextSelectionToolbarButton(
            key: const Key('ai-selection-share'),
            icon: Icons.reply_rounded,
            label: text.text('分享', 'Share'),
            onPressed: onPressed,
            flipHorizontally: true,
          ),
      ],
    );
  }
}

class _AiSelectionEndHandle extends StatelessWidget {
  const _AiSelectionEndHandle({
    super.key,
    required this.color,
    required this.onDragUpdate,
  });

  final Color color;
  final GestureDragUpdateCallback onDragUpdate;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context)
          .text('调整选区结尾', 'Adjust selection end'),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: onDragUpdate,
        child: SizedBox.square(
          dimension: 32,
          child: CustomPaint(painter: _AiSelectionEndHandlePainter(color)),
        ),
      ),
    );
  }
}

class _AiSelectionEndHandlePainter extends CustomPainter {
  const _AiSelectionEndHandlePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawLine(
      const Offset(16, 3),
      const Offset(16, 14),
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(16, 20), 8, paint);
  }

  @override
  bool shouldRepaint(covariant _AiSelectionEndHandlePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _AiTextSelectionToolbar extends StatelessWidget {
  const _AiTextSelectionToolbar({
    super.key,
    required this.anchorAbove,
    required this.anchorBelow,
    required this.buttons,
  });

  final Offset anchorAbove;
  final Offset anchorBelow;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    const screenPadding = 8.0;
    const contentDistance = 16.0;
    final paddingAbove = MediaQuery.paddingOf(context).top + screenPadding;
    final localAdjustment = Offset(screenPadding, paddingAbove);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenPadding,
        paddingAbove,
        screenPadding,
        screenPadding,
      ),
      child: CustomSingleChildLayout(
        delegate: TextSelectionToolbarLayoutDelegate(
          anchorAbove:
              anchorAbove - const Offset(0, contentDistance) - localAdjustment,
          anchorBelow:
              anchorBelow + const Offset(0, screenPadding) - localAdjustment,
        ),
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF343436),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Row(mainAxisSize: MainAxisSize.min, children: buttons),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiTextSelectionToolbarButton extends StatelessWidget {
  const _AiTextSelectionToolbarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.flipHorizontally = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool flipHorizontally;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, color: Colors.white, size: 22);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (flipHorizontally)
                Transform.flip(flipX: true, child: iconWidget)
              else
                iconWidget,
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  height: 1.1,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AiMessageMenuAction {
  copy,
  selectText,
  edit,
  share,
  regenerate,
  like,
  dislike,
  read,
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
          Icon(icon, size: 13, color: AiColors.accentText(context)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AiColors.accentText(context),
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
    return SizedBox(
      key: const Key('ai-answer-actions'),
      height: 34,
      child: Row(
        children: [
          _AnswerActionButton(
            tooltip: text.text('复制', 'Copy'),
            onPressed: onCopy,
            icon: Icons.content_copy_rounded,
          ),
          const SizedBox(width: 4),
          _AnswerActionButton(
            tooltip: text.text('有帮助', 'Helpful'),
            onPressed: () => onFeedback(1),
            icon: feedback == 1
                ? Icons.thumb_up_alt_rounded
                : Icons.thumb_up_alt_outlined,
            selected: feedback == 1,
          ),
          const SizedBox(width: 4),
          _AnswerActionButton(
            tooltip: text.text('没有帮助', 'Not helpful'),
            onPressed: () => onFeedback(-1),
            icon: feedback == -1
                ? Icons.thumb_down_alt_rounded
                : Icons.thumb_down_alt_outlined,
            selected: feedback == -1,
          ),
          const SizedBox(width: 4),
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
          const SizedBox(width: 4),
          _AnswerActionButton(
            tooltip: text.text('分享', 'Share'),
            onPressed: onShare,
            icon: Icons.reply_rounded,
            flipHorizontally: true,
          ),
          const Spacer(),
          _AnswerActionButton(
            tooltip: text.text('重新生成', 'Regenerate'),
            onPressed: onRegenerate,
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }
}

class _AnswerActionButton extends StatelessWidget {
  const _AnswerActionButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.selected = false,
    this.flipHorizontally = false,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  final bool selected;
  final bool flipHorizontally;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 20,
      color: selected ? AiColors.text(context) : AiColors.muted(context),
    );
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: _aiIconButtonStyle,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      icon: flipHorizontally
          ? Transform.flip(flipX: true, child: iconWidget)
          : iconWidget,
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
                                        child: SizedBox.expand(
                                          key: const Key(
                                            'ai-voice-hold-button',
                                          ),
                                          child: Center(
                                            child: Text(
                                              text.text('按住说话', 'Hold to talk'),
                                              style: TextStyle(
                                                color: AiColors.text(context),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.15,
                                              ),
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
                              const SizedBox(height: 5),
                              if (voiceMode)
                                Container(
                                  key: const Key('ai-voice-mode-divider'),
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AiColors.border(context),
                                        AiColors.border(context),
                                        Colors.transparent,
                                      ],
                                      stops: const [0, 0.12, 0.88, 1],
                                    ),
                                  ),
                                ),
                              SizedBox(height: voiceMode ? 7 : 4),
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
                                                  ? AiColors.accentText(context)
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
                                                  ? AiColors.accentText(context)
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
                                    tooltipTriggerMode:
                                        TooltipTriggerMode.manual,
                                    onLongPress: onAttachment,
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
                                      tooltipTriggerMode:
                                          TooltipTriggerMode.manual,
                                      onPressed: onVoice,
                                      onLongPress: onVoice,
                                      icon: DeepSeekKeyboardIcon(
                                        key: const Key(
                                          'ai-voice-keyboard-icon',
                                        ),
                                        color: AiColors.text(context),
                                        size: 18,
                                      ),
                                    )
                                  else if (controller.text.trim().isEmpty)
                                    _AiRoundAction(
                                      key: const Key('ai-voice-mode-toggle'),
                                      tooltip: text.text('语音输入', 'Voice input'),
                                      tooltipTriggerMode:
                                          TooltipTriggerMode.manual,
                                      onPressed: onVoice,
                                      onLongPressStart: focused
                                          ? onHoldToTalkStart
                                          : null,
                                      onLongPressMoveUpdate: focused
                                          ? onHoldToTalkMove
                                          : null,
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
    final radius = BorderRadius.circular(16);
    return Material(
      color: AiColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: AiColors.border(context).withValues(alpha: 0.8),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AiColors.accent(context).withValues(alpha: 0.12),
        highlightColor: AiColors.accent(context).withValues(alpha: 0.06),
        child: SizedBox(
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AiColors.text(context), size: 24),
              const SizedBox(height: 6),
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
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
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
                        ? AiColors.accentText(context)
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
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget icon;
  final TooltipTriggerMode? tooltipTriggerMode;
  final VoidCallback? onLongPress;
  final VoidCallback? onLongPressStart;
  final ValueChanged<Offset>? onLongPressMoveUpdate;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      triggerMode: tooltipTriggerMode,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        onLongPress: onLongPress,
        onLongPressStart: onLongPress == null && onLongPressStart != null
            ? (_) => onLongPressStart!()
            : null,
        onLongPressMoveUpdate:
            onLongPress == null && onLongPressMoveUpdate != null
            ? (details) => onLongPressMoveUpdate!(details.localOffsetFromOrigin)
            : null,
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AiColors.text(context), width: 1.35),
              ),
              alignment: Alignment.center,
              child: icon,
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
