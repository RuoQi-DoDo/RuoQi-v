part of 'message_pages.dart';

class AtsPrivateChatPage extends StatefulWidget {
  const AtsPrivateChatPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsPrivateChatPage> createState() => _AtsPrivateChatPageState();
}

class _AtsPrivateChatPageState extends State<AtsPrivateChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[
    _ChatMessage(
      text: '你好，我是上海世佳科技的李经理，看到你对 Flutter 开发工程师岗位感兴趣。',
      mine: false,
      time: '10:20',
    ),
    _ChatMessage(text: '你好，是的，我目前有 4 年移动端开发经验。', mine: true, time: '10:22'),
    _ChatMessage(
      text: '很匹配。方便发一份最新简历吗？也可以直接约时间聊一聊。',
      mine: false,
      time: '10:23',
    ),
  ];
  bool _showActions = false;
  bool _voiceMode = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = (preset ?? _messageController.text).trim();
    if (text.isEmpty) {
      return;
    }
    setState(() {
      _messages.add(_ChatMessage(text: text, mine: true, time: '刚刚'));
      _showActions = false;
    });
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
          color: const Color(0xFFFFFAF4),
          child: Row(
            children: [
              Icon(
                Icons.lock_outline,
                size: 15,
                color: AtsColors.resolve(context, AtsColors.orange),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  '请勿向招聘方转账或支付任何费用',
                  style: TextStyle(
                    color: AtsColors.resolve(context, AtsColors.orange),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            children: [
              Center(
                child: Text(
                  '10:20',
                  style: TextStyle(
                    color: AtsColors.resolve(context, AtsColors.textMuted),
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              for (final message in _messages) ...[
                _MessageBubble(message: message),
                const SizedBox(height: 14),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtsAvatar(
                      label: '李',
                      size: 34,
                      color: AtsColors.resolve(context, AtsColors.blue),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 230,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: AtsColors.resolve(context, AtsColors.surface),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AtsColors.resolve(context, AtsColors.divider),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 24,
                                color: AtsColors.resolve(
                                  context,
                                  AtsColors.primary,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Flutter开发工程师-林小满.pdf',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            '点击可预览简历内容',
                            style: TextStyle(
                              color: AtsColors.resolve(
                                context,
                                AtsColors.textMuted,
                              ),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: const Color(0xFFF7F8F9),
          padding: EdgeInsets.fromLTRB(10, 8, 10, _showActions ? 8 : 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _voiceMode = !_voiceMode),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      _voiceMode ? Icons.keyboard_alt_outlined : Icons.mic_none,
                      color: AtsColors.resolve(context, AtsColors.text),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 38),
                      decoration: BoxDecoration(
                        color: AtsColors.resolve(context, AtsColors.surface),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _voiceMode
                          ? InkWell(
                              onLongPress: () {
                                atsToast(context, '正在录音，松开后发送');
                              },
                              child: const SizedBox(
                                height: 38,
                                child: Center(
                                  child: Text(
                                    '按住 说话',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : TextField(
                              controller: _messageController,
                              minLines: 1,
                              maxLines: 3,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(),
                              decoration: InputDecoration(
                                hintText: '发送消息',
                                isDense: true,
                                fillColor: AtsColors.resolve(
                                  context,
                                  AtsColors.surface,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 10,
                                ),
                              ),
                              style: const TextStyle(fontSize: 13),
                            ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _showActions = !_showActions),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: AtsColors.resolve(context, AtsColors.text),
                    ),
                  ),
                  if (_messageController.text.trim().isNotEmpty)
                    TextButton(onPressed: _send, child: const Text('发送')),
                ],
              ),
              if (_showActions) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _AttachmentAction(
                      icon: Icons.image_outlined,
                      label: '图片',
                      onTap: () => atsToast(context, '已选择本地图片'),
                    ),
                    _AttachmentAction(
                      icon: Icons.videocam_outlined,
                      label: '视频',
                      onTap: () => atsToast(context, '已选择本地视频'),
                    ),
                    _AttachmentAction(
                      icon: Icons.description_outlined,
                      label: '简历',
                      onTap: () => _send('这是我的最新简历，请查收。'),
                    ),
                    _AttachmentAction(
                      icon: Icons.phone_outlined,
                      label: '交换电话',
                      onTap: () => _send('可以交换一下联系电话吗？'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: message.mine
            ? AtsColors.solidPrimary(context)
            : AtsColors.resolve(context, AtsColors.surface),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
          bottomLeft: Radius.circular(message.mine ? 10 : 2),
          bottomRight: Radius.circular(message.mine ? 2 : 10),
        ),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: message.mine
              ? Colors.white
              : AtsColors.resolve(context, AtsColors.text),
          fontSize: 13,
          height: 1.55,
        ),
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: message.mine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!message.mine) ...[
          AtsAvatar(
            label: '李',
            size: 34,
            color: AtsColors.resolve(context, AtsColors.blue),
          ),
          const SizedBox(width: 8),
        ],
        bubble,
        if (message.mine) ...[
          const SizedBox(width: 8),
          const AtsAvatar(label: '林', size: 34),
        ],
      ],
    );
  }
}

class _AttachmentAction extends StatelessWidget {
  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AtsColors.resolve(context, AtsColors.surface),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AtsColors.resolve(context, AtsColors.textSecondary),
                  size: 21,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: AtsColors.resolve(context, AtsColors.textMuted),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.mine,
    required this.time,
  });

  final String text;
  final bool mine;
  final String time;
}
