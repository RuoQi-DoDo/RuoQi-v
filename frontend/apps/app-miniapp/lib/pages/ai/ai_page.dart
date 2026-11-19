import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';

import '../../localization.dart';
import '../common/page_widgets.dart';
import 'ai_history_drawer.dart';
import 'ai_style.dart';
import 'deepseek_api.dart';
import 'deepseek_settings_store.dart';
import 'deepseek_icons.dart';

/// A DeepSeek-inspired AI conversation surface with local demo interactions.
class AiPage extends StatefulWidget {
  const AiPage({super.key, this.onOpenSettings, this.settingsStore, this.api});

  final VoidCallback? onOpenSettings;
  final DeepSeekSettingsStore? settingsStore;
  final DeepSeekApi? api;

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> with SingleTickerProviderStateMixin {
  final TextEditingController _composer = TextEditingController();
  final ScrollController _messageScroll = ScrollController();
  final List<_AiMessage> _messages = <_AiMessage>[];

  late final AnimationController _historyController;
  late final DeepSeekApi _api = widget.api ?? DeepSeekApi();
  late final DeepSeekSettingsStore _settingsStore =
      widget.settingsStore ?? const SharedPreferencesDeepSeekSettingsStore();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<DeepSeekChatChunk>? _chatSubscription;
  Timer? _responseTimer;
  bool _deepThinking = false;
  bool _webSearch = true;
  bool _autoRead = false;
  bool _responding = false;
  String _selectedModelName = '';
  String _conversationTitle = '';
  DeepSeekFile? _attachmentFile;
  bool _recording = false;
  bool _messagesAtBottom = true;
  bool _messagesCanScroll = false;
  int _chatGeneration = 0;

  @override
  void initState() {
    super.initState();
    _historyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 240),
    );
    unawaited(_loadDeepSeekSettings());
    _composer.addListener(_handleComposerChanged);
    _messageScroll.addListener(_handleMessageScroll);
  }

  @override
  void dispose() {
    _responseTimer?.cancel();
    _chatSubscription?.cancel();
    unawaited(_recorder.dispose());
    unawaited(_audioPlayer.dispose());
    _composer
      ..removeListener(_handleComposerChanged)
      ..dispose();
    _messageScroll.removeListener(_handleMessageScroll);
    _messageScroll.dispose();
    _historyController.dispose();
    super.dispose();
  }

  void _handleComposerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _newConversation() {
    _responseTimer?.cancel();
    _chatSubscription?.cancel();
    _chatGeneration++;
    FocusScope.of(context).unfocus();
    _composer.clear();
    setState(() {
      _messages.clear();
      _conversationTitle = '';
      _deepThinking = false;
      _webSearch = true;
      _autoRead = false;
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
      _conversationTitle = nextTitle;
      if (addUserMessage) {
        _messages.add(_AiMessage.user(prompt));
        _attachmentFile = null;
      }
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
              unawaited(_speakText(responseBuffer.trim()));
            }
            _scrollMessagesToEnd();
          },
        );
  }

  Future<void> _speakText(String text) async {
    try {
      final settings = await _settingsStore.load();
      if (!mounted || settings.apiKey.isEmpty) {
        return;
      }
      final audio = await _api.textToSpeech(
        apiKey: settings.apiKey,
        text: text,
      );
      await _audioPlayer.stop();
      await _audioPlayer.play(
        BytesSource(audio.bytes, mimeType: audio.contentType ?? 'audio/wav'),
      );
    } on DeepSeekApiException catch (error) {
      if (mounted) {
        showPageMessage(context, _chatErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        showPageMessage(
          context,
          AppLocalizations.of(context).text('语音播放失败', 'Unable to play audio'),
        );
      }
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

  String _demoResponse(String prompt) {
    final l10n = AppLocalizations.of(context);
    if (prompt.contains('工作') || prompt.toLowerCase().contains('work')) {
      return l10n.text(
        '可以从三件事开始：\n\n'
            '1. 先确认今天最重要的一个结果。\n'
            '2. 把任务拆成 25–45 分钟可以完成的小块。\n'
            '3. 留出一段不被打断的时间处理核心工作。\n\n'
            '需要的话，我可以继续帮你整理成一份可执行的今日清单。',
        'Start with three things:\n\n'
            '1. Define the one most important outcome for today.\n'
            '2. Break the work into 25–45 minute blocks.\n'
            '3. Protect one uninterrupted block for the core task.\n\n'
            'I can turn this into an actionable checklist if you like.',
      );
    }
    if (prompt.contains('邀请') || prompt.toLowerCase().contains('invite')) {
      return l10n.text(
        '当然可以：\n\n'
            '你好，我们认真阅读了你的经历，认为你与当前岗位非常匹配。'
            '想邀请你参加一次线上沟通，预计约 30 分钟。'
            '请告知你方便的时间，我们会为你安排会议链接。\n\n'
            '你可以把岗位名称和时间补充给我，我会继续润色。',
        'Of course:\n\n'
            'Hello, we reviewed your experience and believe you are a strong '
            'match for this role. We would like to invite you to a 30-minute '
            'online conversation. Please share a convenient time and we will '
            'send you a meeting link.\n\n'
            'Tell me the role and preferred time to refine it further.',
      );
    }
    if (prompt.contains('润色') || prompt.toLowerCase().contains('polish')) {
      return l10n.text(
        '没问题。把原文发给我，我会在保留原意的基础上，'
            '让表达更清晰、专业，并根据使用场景调整语气。',
        'Sure. Send me the original text and I will make it clearer and more '
            'professional while preserving the meaning and tone you need.',
      );
    }
    return l10n.text(
      '收到。这是 RuoQi AI 的界面演示，我已经记录你的问题：\n\n'
          '“$prompt”\n\n'
          '你可以继续补充背景、目标或期望格式，我会按更完整的信息给出结果。',
      'Got it. This is the RuoQi AI interface demo and I have noted your '
          'question:\n\n'
          '"$prompt"\n\n'
          'Add more context, goals, or a preferred format and I will respond '
          'with a more complete result.',
    );
  }

  double _historyWidth(BuildContext context) =>
      math.min(288.0, MediaQuery.sizeOf(context).width * 0.84);

  void _showHistory() {
    FocusScope.of(context).unfocus();
    unawaited(_loadDeepSeekSettings());
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

  void _openHistoryEntry(AiHistoryEntry entry) {
    _closeHistory();
    _responseTimer?.cancel();
    _composer.clear();
    final response = _demoResponse(entry.prompt);
    setState(() {
      _messages
        ..clear()
        ..add(_AiMessage.user(entry.prompt))
        ..add(_AiMessage.assistant(response, webSearch: true));
      _conversationTitle = entry.title;
      _deepThinking = false;
      _webSearch = true;
      _responding = false;
    });
    _scrollMessagesToEnd();
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

  Future<void> _showAttachmentMessage() async {
    final settings = await _requireDeepSeekSettings();
    if (!mounted || settings == null) {
      return;
    }
    final action = await showModalBottomSheet<_AttachmentAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file_rounded),
              title: Text(
                AppLocalizations.of(context)
                    .text('上传文件到 DeepSeek', 'Upload a file to DeepSeek'),
              ),
              onTap: () => Navigator.of(context).pop(_AttachmentAction.upload),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_rounded),
              title: Text(AppLocalizations.of(context).text('文件列表', 'Files')),
              onTap: () => Navigator.of(context).pop(_AttachmentAction.files),
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: Text(
                AppLocalizations.of(context).text('OCR 识别文档', 'OCR a document'),
              ),
              onTap: () => Navigator.of(context).pop(_AttachmentAction.ocr),
            ),
            ListTile(
              leading: const Icon(Icons.search_rounded),
              title: Text(
                AppLocalizations.of(context).text('搜索网页', 'Search the web'),
              ),
              onTap: () => Navigator.of(context).pop(_AttachmentAction.search),
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: Text(
                AppLocalizations.of(context).text('阅读网页链接', 'Read a web page'),
              ),
              onTap: () => Navigator.of(context).pop(_AttachmentAction.fetch),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) {
      return;
    }
    switch (action) {
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

  Future<void> _uploadAttachment(DeepSeekSettings settings) async {
    final picked = await FilePicker.pickFile(
      dialogTitle: AppLocalizations.of(context)
          .text('选择要上传的文件', 'Choose a file to upload'),
    );
    if (picked == null) {
      return;
    }
    try {
      final bytes = await picked.readAsBytes();
      final file = await _api.uploadFile(
        apiKey: settings.apiKey,
        filename: picked.name,
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
      _setComposerText(recognized);
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

  void _setComposerText(String text) {
    _composer
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
    FocusScope.of(context).requestFocus();
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
          showPageMessage(
            context,
            AppLocalizations.of(context)
                .text('正在录音，再次点击结束', 'Recording. Tap again to stop.'),
          );
        }
        return;
      }

      final path = await _recorder.stop();
      if (mounted) {
        setState(() => _recording = false);
      }
      if (path == null) {
        return;
      }
      final bytes = await File(path).readAsBytes();
      final result = await _api.speechToText(
        apiKey: settings.apiKey,
        filename: 'voice.wav',
        bytes: bytes,
      );
      if (!mounted) {
        return;
      }
      _setComposerText(result.text);
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

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final aiScheme = baseTheme.colorScheme.copyWith(
      primary: AiColors.accent,
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
    final text = AppLocalizations.of(context);
    final historyEntries = buildDemoAiHistoryEntries(text);

    return Theme(
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
                                    onToggleAutoRead: () =>
                                        setState(() => _autoRead = !_autoRead),
                                  ),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 220,
                                            ),
                                            switchInCurve: Curves.easeOutCubic,
                                            switchOutCurve: Curves.easeInCubic,
                                            child: _messages.isEmpty
                                                ? const _AiWelcome(
                                                    key: ValueKey('ai-welcome'),
                                                  )
                                                : _AiConversation(
                                                    key: const ValueKey(
                                                      'ai-conversation',
                                                    ),
                                                    messages: _messages,
                                                    responding: _responding,
                                                    scrollController:
                                                        _messageScroll,
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
                                                          _speakText(
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
                                    onAttachment: _showAttachmentMessage,
                                    onVoice: _showVoiceMessage,
                                    attachmentName: _attachmentFile?.filename,
                                    onRemoveAttachment: () =>
                                        setState(() => _attachmentFile = null),
                                    recording: _recording,
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
                                onHorizontalDragStart: _handleHistoryDragStart,
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
                          ? AiColors.accent
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
            SizedBox(
              width: 166,
              height: 92,
              child: CustomPaint(
                key: const Key('ai-whale-mark'),
                painter: _AiWhalePainter(),
              ),
            ),
            const SizedBox(height: 28),
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

class _AiWhalePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 166;
    canvas.save();
    canvas.scale(scale, scale);

    final blue = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AiColors.accentDeep, AiColors.accent],
      ).createShader(const Rect.fromLTWH(0, 0, 166, 92));
    final deepBlue = Paint()..color = const Color(0xFF3548DB);
    final belly = Paint()..color = const Color(0xFFEFF2FF);
    final line = Paint()
      ..color = const Color(0xFF2537B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final white = Paint()..color = Colors.white;
    final pupil = Paint()..color = const Color(0xFF101A68);

    final body = Path()
      ..moveTo(20, 72)
      ..cubicTo(23, 49, 50, 30, 84, 31)
      ..cubicTo(104, 32, 119, 42, 132, 58)
      ..cubicTo(122, 70, 98, 78, 68, 80)
      ..cubicTo(46, 82, 29, 77, 20, 72)
      ..close();
    canvas.drawPath(body, blue);

    final tail = Path()
      ..moveTo(127, 54)
      ..cubicTo(140, 50, 145, 38, 158, 40)
      ..cubicTo(153, 49, 155, 56, 162, 61)
      ..cubicTo(164, 61, 165, 64, 166, 66)
      ..cubicTo(154, 71, 148, 80, 135, 79)
      ..cubicTo(125, 78, 119, 68, 115, 62)
      ..close();
    canvas.drawPath(tail, blue);

    final dorsal = Path()
      ..moveTo(82, 32)
      ..cubicTo(83, 18, 93, 8, 109, 4)
      ..cubicTo(104, 18, 111, 27, 120, 36)
      ..close();
    canvas.drawPath(dorsal, blue);

    final fin = Path()
      ..moveTo(92, 66)
      ..cubicTo(99, 77, 113, 84, 128, 81)
      ..cubicTo(121, 75, 115, 68, 112, 61)
      ..close();
    canvas.drawPath(fin, deepBlue);

    final underside = Path()
      ..moveTo(24, 66)
      ..cubicTo(48, 72, 88, 68, 132, 58)
      ..cubicTo(116, 75, 85, 81, 58, 79)
      ..cubicTo(39, 78, 28, 74, 24, 66)
      ..close();
    canvas.drawPath(underside, belly);

    final smile = Path()
      ..moveTo(110, 59)
      ..cubicTo(118, 62, 124, 67, 131, 73);
    canvas.drawPath(smile, line);

    final eye = Path()
      ..moveTo(52, 52)
      ..cubicTo(59, 45, 70, 47, 75, 52)
      ..cubicTo(69, 56, 60, 57, 52, 52)
      ..close();
    canvas.drawPath(eye, white);
    canvas.drawOval(const Rect.fromLTWH(60, 49, 4.2, 5.6), pupil);

    final water = Paint()
      ..color = const Color(0xFF263BC8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(22, 83), const Offset(101, 83), water);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AiWhalePainter oldDelegate) => false;
}

class _AiConversation extends StatelessWidget {
  const _AiConversation({
    super.key,
    required this.messages,
    required this.responding,
    required this.scrollController,
    required this.onCopy,
    required this.onFeedback,
    required this.onSpeak,
    required this.onShare,
    required this.onRegenerate,
  });

  final List<_AiMessage> messages;
  final bool responding;
  final ScrollController scrollController;
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
    required this.onShare,
    required this.onRegenerate,
  });

  final _AiMessage message;
  final bool showActions;
  final VoidCallback onCopy;
  final ValueChanged<int> onFeedback;
  final VoidCallback onSpeak;
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
            if (message.deepThinking || message.webSearch) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (message.deepThinking)
                    _AiModeTag(
                      icon: Icons.psychology_alt_outlined,
                      label: AppLocalizations.of(context)
                          .text('深度思考', 'Deep thinking'),
                    ),
                  if (message.webSearch)
                    _AiModeTag(
                      icon: Icons.language_rounded,
                      label: AppLocalizations.of(context)
                          .text('联网搜索', 'Web search'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            SelectableText(
              message.content,
              style: TextStyle(
                color: AiColors.text(context),
                fontSize: 18,
                height: 1.72,
                letterSpacing: -0.08,
              ),
            ),
            if (showActions) ...[
              const SizedBox(height: 10),
              _AnswerActionBar(
                feedback: message.feedback,
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
          Icon(icon, size: 13, color: AiColors.accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AiColors.accent,
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
    required this.onCopy,
    required this.onFeedback,
    required this.onSpeak,
    required this.onShare,
    required this.onRegenerate,
  });

  final int feedback;
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
          tooltip: text.text('朗读', 'Read aloud'),
          onPressed: onSpeak,
          icon: Icons.volume_up_outlined,
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
        color: selected ? AiColors.accent : AiColors.muted(context),
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
            decoration: const BoxDecoration(
              gradient: AiColors.brandGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 16,
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
    required this.canSend,
    required this.responding,
    required this.deepThinking,
    required this.webSearch,
    required this.onToggleDeepThinking,
    required this.onToggleWebSearch,
    required this.onAttachment,
    required this.onVoice,
    required this.onSend,
    this.attachmentName,
    this.onRemoveAttachment,
    this.recording = false,
  });

  final TextEditingController controller;
  final bool canSend;
  final bool responding;
  final bool deepThinking;
  final bool webSearch;
  final VoidCallback onToggleDeepThinking;
  final VoidCallback onToggleWebSearch;
  final VoidCallback onAttachment;
  final VoidCallback onVoice;
  final VoidCallback onSend;
  final String? attachmentName;
  final VoidCallback? onRemoveAttachment;
  final bool recording;

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 8, 13, 8),
      child: Container(
        key: const Key('ai-composer-card'),
        constraints: const BoxConstraints(minHeight: 106),
        padding: const EdgeInsets.fromLTRB(18, 7, 9, 9),
        decoration: BoxDecoration(
          color: AiColors.surface(context),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AiColors.isDark(context)
                ? AiColors.border(context)
                : const Color(0xFFF2F3F5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: AiColors.isDark(context) ? 0.2 : 0.025,
              ),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (attachmentName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 16),
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
                      tooltip: text.text('移除附件', 'Remove attachment'),
                      onPressed: onRemoveAttachment,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 30,
                        height: 30,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close_rounded, size: 16),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 46,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  key: const Key('ai-composer'),
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    color: AiColors.text(context),
                    fontSize: 18,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: text.text('发消息或按住说话', 'Message or hold to talk'),
                    hintStyle: TextStyle(
                      color: AiColors.hint(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
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
                                ? AiColors.accent
                                : AiColors.text(context),
                            size: 19,
                          ),
                          label: text.text('深度思考', 'Deep thinking'),
                          selected: deepThinking,
                          onTap: onToggleDeepThinking,
                        ),
                        const SizedBox(width: 7),
                        _AiModeChip(
                          key: const Key('ai-web-search'),
                          icon: Icon(
                            Icons.language_rounded,
                            color: webSearch
                                ? AiColors.accent
                                : AiColors.text(context),
                            size: 19,
                          ),
                          label: text.text('智能搜索', 'Smart search'),
                          selected: webSearch,
                          onTap: onToggleWebSearch,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                _AiRoundAction(
                  tooltip: text.text('添加附件', 'Add attachment'),
                  onPressed: onAttachment,
                  icon: DeepSeekPlusIcon(
                    color: AiColors.text(context),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 7),
                if (responding)
                  _AiSendButton(enabled: false, responding: true, onTap: onSend)
                else if (recording || controller.text.trim().isEmpty)
                  _AiRoundAction(
                    tooltip: recording
                        ? text.text('结束录音', 'Stop recording')
                        : text.text('语音输入', 'Voice input'),
                    onPressed: onVoice,
                    icon: DeepSeekVoiceIcon(
                      color: recording
                          ? const Color(0xFFD7464F)
                          : AiColors.text(context),
                      size: 24,
                    ),
                    color: recording ? const Color(0xFFD7464F) : null,
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
                    color: selected ? AiColors.accent : AiColors.text(context),
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
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.color,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
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
                    color: color ?? AiColors.text(context),
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
                        ? AiColors.accent
                        : AiColors.softSurface(context),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: responding
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: AiColors.accent,
                          ),
                        )
                      : Icon(
                          Icons.arrow_upward_rounded,
                          color: enabled
                              ? Colors.white
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

enum _AttachmentAction { upload, files, ocr, search, fetch }

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
