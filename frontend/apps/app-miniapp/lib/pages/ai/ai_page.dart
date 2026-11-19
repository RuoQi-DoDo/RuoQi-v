import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../localization.dart';
import '../common/page_widgets.dart';
import 'ai_history_drawer.dart';
import 'ai_style.dart';
import 'deepseek_icons.dart';

/// A DeepSeek-inspired AI conversation surface with local demo interactions.
class AiPage extends StatefulWidget {
  const AiPage({super.key, this.onOpenSettings});

  final VoidCallback? onOpenSettings;

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> with SingleTickerProviderStateMixin {
  final TextEditingController _composer = TextEditingController();
  final ScrollController _messageScroll = ScrollController();
  final List<_AiMessage> _messages = <_AiMessage>[];

  late final AnimationController _historyController;
  Timer? _responseTimer;
  bool _deepThinking = false;
  bool _webSearch = true;
  bool _autoRead = false;
  bool _responding = false;

  @override
  void initState() {
    super.initState();
    _historyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _composer.addListener(_handleComposerChanged);
  }

  @override
  void dispose() {
    _responseTimer?.cancel();
    _composer
      ..removeListener(_handleComposerChanged)
      ..dispose();
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
    FocusScope.of(context).unfocus();
    _composer.clear();
    setState(() {
      _messages.clear();
      _deepThinking = false;
      _webSearch = true;
      _autoRead = false;
      _responding = false;
    });
  }

  void _send([String? suggestion]) {
    final prompt = (suggestion ?? _composer.text).trim();
    if (prompt.isEmpty || _responding) {
      return;
    }
    FocusScope.of(context).unfocus();
    _composer.clear();
    setState(() {
      _messages.add(_AiMessage.user(prompt));
      _responding = true;
    });
    _scrollMessagesToEnd();

    _responseTimer?.cancel();
    _responseTimer = Timer(const Duration(milliseconds: 520), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _messages.add(
          _AiMessage.assistant(
            _demoResponse(prompt),
            deepThinking: _deepThinking,
            webSearch: _webSearch,
          ),
        );
        _responding = false;
      });
      _scrollMessagesToEnd();
    });
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
    _historyController.animateTo(
      1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
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
      _deepThinking = false;
      _webSearch = true;
      _responding = false;
    });
    _scrollMessagesToEnd();
  }

  void _showAttachmentMessage() {
    showPageMessage(
      context,
      AppLocalizations.of(context)
          .text('附件上传功能正在接入', 'File upload is coming soon'),
    );
  }

  void _showVoiceMessage() {
    showPageMessage(
      context,
      AppLocalizations.of(context)
          .text('语音输入功能正在接入', 'Voice input is coming soon'),
    );
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
                                    autoRead: _autoRead,
                                    onToggleAutoRead: () =>
                                        setState(() => _autoRead = !_autoRead),
                                  ),
                                  Expanded(
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
                                              scrollController: _messageScroll,
                                            ),
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
                                    onSend: _send,
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
    required this.autoRead,
    required this.onToggleAutoRead,
  });

  final VoidCallback onHistory;
  final VoidCallback onNewConversation;
  final bool autoRead;
  final VoidCallback onToggleAutoRead;

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            IconButton(
              key: const Key('ai-history'),
              tooltip: text.text('对话记录', 'Chat history'),
              onPressed: onHistory,
              icon: _TwoLineMenuIcon(color: AiColors.text(context)),
            ),
            const Spacer(),
            IconButton(
              key: const Key('ai-auto-read'),
              tooltip: text.text('自动朗读', 'Auto read'),
              onPressed: onToggleAutoRead,
              icon: DeepSeekAutoReadIcon(
                color: autoRead ? AiColors.accent : AiColors.text(context),
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
  });

  final List<_AiMessage> messages;
  final bool responding;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const Key('ai-conversation'),
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      itemCount: messages.length + (responding ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const _AiTypingIndicator();
        }
        return _AiMessageBubble(message: messages[index]);
      },
    );
  }
}

class _AiMessageBubble extends StatelessWidget {
  const _AiMessageBubble({required this.message});

  final _AiMessage message;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.role == _AiRole.user;
    final bubble = Container(
      key: fromUser
          ? const Key('ai-user-message')
          : const Key('ai-assistant-message'),
      constraints: const BoxConstraints(maxWidth: 310),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: fromUser ? AiColors.accent : AiColors.surface(context),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(fromUser ? 18 : 5),
          bottomRight: Radius.circular(fromUser ? 5 : 18),
        ),
        border: fromUser ? null : Border.all(color: AiColors.border(context)),
      ),
      child: SelectableText(
        message.content,
        style: TextStyle(
          color: fromUser ? Colors.white : AiColors.text(context),
          fontSize: 14.5,
          height: 1.55,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: fromUser
          ? Align(alignment: Alignment.centerRight, child: bubble)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(width: 9),
                Flexible(
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
                        const SizedBox(height: 7),
                      ],
                      bubble,
                    ],
                  ),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    final text = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 8, 13, 8),
      child: Container(
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
                else if (controller.text.trim().isEmpty)
                  _AiRoundAction(
                    tooltip: text.text('语音输入', 'Voice input'),
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
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget icon;

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

enum _AiRole { user, assistant }

class _AiMessage {
  const _AiMessage.user(this.content)
    : role = _AiRole.user,
      deepThinking = false,
      webSearch = false;

  const _AiMessage.assistant(
    this.content, {
    this.deepThinking = false,
    this.webSearch = false,
  }) : role = _AiRole.assistant;

  final _AiRole role;
  final String content;
  final bool deepThinking;
  final bool webSearch;
}
