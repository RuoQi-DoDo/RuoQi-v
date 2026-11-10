part of 'message_pages.dart';

class AtsRobotPage extends StatefulWidget {
  const AtsRobotPage({super.key});

  @override
  State<AtsRobotPage> createState() => _AtsRobotPageState();
}

class _AtsRobotPageState extends State<AtsRobotPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_RobotMessage>[
    _RobotMessage('你好，我是企业直聘智能客服小忧。'),
    _RobotMessage('你可以问我关于职位投递、简历完善、账号登录或企业认证的问题。'),
  ];
  bool _sending = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final value = (preset ?? _textController.text).trim();
    if (value.isEmpty || _sending) {
      return;
    }
    _textController.clear();
    setState(() {
      _messages.add(_RobotMessage(value, mine: true));
      _sending = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }
    setState(() {
      _messages.add(_RobotMessage(_robotReply(value)));
      _sending = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _robotReply(String question) {
    if (question.contains('简历')) {
      return '进入「我的 - 我的简历」，可以编辑个人信息、求职期望、工作经历、项目经历和教育经历。'
          '资料越完整，获得面试邀请的机会越高。';
    }
    if (question.contains('投递')) {
      return '在职位详情底部点击「立即投递」即可。你可以在「我的投递」中查看进度，也可以在消息中直接联系招聘方。';
    }
    if (question.contains('企业') || question.contains('认证')) {
      return '切换到招聘者身份后，从「我的 - 公司管理」进入公司入驻和认证，按页面提示提交资料即可。';
    }
    return '已收到你的问题。目前可以为你解答简历、投递、账号、企业认证等常见问题，'
        '需要人工协助时可以点击底部「联系我们」。';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(14),
            children: [
              const Center(
                child: Text(
                  '智能客服 · 7×24小时在线',
                  style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < _messages.length; i++)
                _RobotBubble(text: _messages[i].text, mine: _messages[i].mine),
              if (_sending)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: _RobotTyping(),
                  ),
                ),
              if (_messages.length == 2) ...[
                const SizedBox(height: 16),
                const Text(
                  '猜你想问',
                  style: TextStyle(color: AtsColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final question in const [
                      '如何完善简历？',
                      '怎么查看投递进度？',
                      '如何进行企业认证？',
                    ])
                      ActionChip(
                        onPressed: () => _send(question),
                        label: Text(question),
                        backgroundColor: AtsColors.mint,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          color: const Color(0xFFF7F8F9),
          child: Row(
            children: [
              IconButton(
                onPressed: () => atsToast(context, '已为你连接人工客服'),
                tooltip: '人工客服',
                icon: const Icon(
                  Icons.support_agent,
                  color: AtsColors.textSecondary,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _send,
                  decoration: const InputDecoration(
                    hintText: '请用一句话描述你的问题',
                    isDense: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: AtsColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '发送',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RobotBubble extends StatelessWidget {
  const _RobotBubble({required this.text, required this.mine});

  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mine) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AtsColors.primary, Color(0xFF54CFAD)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? AtsColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: mine ? Colors.white : AtsColors.text,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ),
          if (mine) ...[
            const SizedBox(width: 8),
            const AtsAvatar(label: '林', size: 34),
          ],
        ],
      ),
    );
  }
}

class _RobotTyping extends StatelessWidget {
  const _RobotTyping();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TypingDot(),
          SizedBox(width: 4),
          _TypingDot(),
          SizedBox(width: 4),
          _TypingDot(),
        ],
      ),
    );
  }
}

class _RobotMessage {
  const _RobotMessage(this.text, {this.mine = false});

  final String text;
  final bool mine;
}

class _TypingDot extends StatelessWidget {
  const _TypingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: AtsColors.textMuted,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ServiceAction {
  const _ServiceAction(this.icon, this.label, {this.badge});

  final IconData icon;
  final String label;
  final String? badge;
}
