import 'package:flutter/material.dart';

import '../hr_models.dart';
import '../hr_routes.dart';
import '../hr_style.dart';

class HrMessagesPage extends StatelessWidget {
  const HrMessagesPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    final isRecruiter = controller.role == HrUserRole.recruiter;
    final actions = isRecruiter
        ? const [
            _ServiceAction(
              Icons.notifications_none_rounded,
              '系统通知',
              badge: '1',
            ),
            _ServiceAction(Icons.assignment_outlined, '面试邀请'),
            _ServiceAction(Icons.forum_outlined, '已沟通'),
            _ServiceAction(Icons.visibility_outlined, '谁看过我'),
          ]
        : const [
            _ServiceAction(
              Icons.notifications_none_rounded,
              '系统通知',
              badge: '1',
            ),
            _ServiceAction(Icons.assignment_outlined, '我的投递'),
            _ServiceAction(Icons.history, '浏览记录'),
            _ServiceAction(Icons.visibility_outlined, '谁看过我'),
          ];
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 14),
          child: Row(
            children: [
              for (var i = 0; i < actions.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final route = switch (i) {
                        0 => HrRoute.notices,
                        1 => HrRoute.applications,
                        2 => isRecruiter ? HrRoute.connected : HrRoute.browse,
                        _ => HrRoute.connected,
                      };
                      controller.open(route);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: i == 0
                                      ? HrColors.mint
                                      : HrColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  actions[i].icon,
                                  size: 21,
                                  color: i == 0
                                      ? HrColors.primary
                                      : HrColors.textSecondary,
                                ),
                              ),
                              if (actions[i].badge != null)
                                Positioned(
                                  right: -5,
                                  top: -5,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: HrColors.red,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      actions[i].badge!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            actions[i].label,
                            style: const TextStyle(
                              color: HrColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: () => controller.open(HrRoute.notices),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [HrColors.primary, Color(0xFF50CFAE)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.volume_up_outlined,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '系统通知',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 7),
                            HrTag(
                              '1条新消息',
                              foreground: HrColors.red,
                              background: Color(0xFFFFF0F0),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          '上海世佳科技邀请你参加面试',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: HrColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '刚刚',
                    style: TextStyle(color: HrColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
        const HrSectionHeader(title: '最近聊天'),
        if (hrConversations.isEmpty)
          const HrEmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: '暂无消息',
          )
        else
          Material(
            color: Colors.white,
            child: Column(
              children: [
                for (var i = 0; i < hrConversations.length; i++) ...[
                  _ConversationTile(
                    conversation: hrConversations[i],
                    onTap: () => controller.open(HrRoute.privateChat),
                  ),
                  if (i != hrConversations.length - 1)
                    const Divider(height: 1, indent: 70, endIndent: 14),
                ],
              ],
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final HrConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                HrAvatar(
                  label: conversation.name,
                  size: 45,
                  color: conversation.name == '李经理'
                      ? HrColors.blue
                      : HrColors.primary,
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CD964),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        conversation.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          conversation.job,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: HrColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        conversation.time,
                        style: const TextStyle(
                          color: HrColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: HrColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (conversation.unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          constraints: const BoxConstraints(minWidth: 17),
                          height: 17,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: HrColors.red,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${conversation.unread}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              height: 1,
                            ),
                          ),
                        ),
                    ],
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

class HrPrivateChatPage extends StatefulWidget {
  const HrPrivateChatPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrPrivateChatPage> createState() => _HrPrivateChatPageState();
}

class _HrPrivateChatPageState extends State<HrPrivateChatPage> {
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
          child: const Row(
            children: [
              Icon(Icons.lock_outline, size: 15, color: HrColors.orange),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  '请勿向招聘方转账或支付任何费用',
                  style: TextStyle(color: HrColors.orange, fontSize: 11),
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
              const Center(
                child: Text(
                  '10:20',
                  style: TextStyle(color: HrColors.textMuted, fontSize: 10),
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
                    const HrAvatar(label: '李', size: 34, color: HrColors.blue),
                    const SizedBox(width: 8),
                    Container(
                      width: 230,
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: HrColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 24,
                                color: HrColors.primary,
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
                          const Text(
                            '点击可预览简历内容',
                            style: TextStyle(
                              color: HrColors.textMuted,
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
                      color: HrColors.text,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 38),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _voiceMode
                          ? InkWell(
                              onLongPress: () {
                                hrToast(context, '正在录音，松开后发送');
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
                              decoration: const InputDecoration(
                                hintText: '发送消息',
                                isDense: true,
                                fillColor: Colors.white,
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
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: HrColors.text,
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
                      onTap: () => hrToast(context, '已选择本地图片'),
                    ),
                    _AttachmentAction(
                      icon: Icons.videocam_outlined,
                      label: '视频',
                      onTap: () => hrToast(context, '已选择本地视频'),
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
        color: message.mine ? HrColors.primary : Colors.white,
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
          color: message.mine ? Colors.white : HrColors.text,
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
          const HrAvatar(label: '李', size: 34, color: HrColors.blue),
          const SizedBox(width: 8),
        ],
        bubble,
        if (message.mine) ...[
          const SizedBox(width: 8),
          const HrAvatar(label: '林', size: 34),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: HrColors.textSecondary, size: 21),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(color: HrColors.textMuted, fontSize: 10),
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

class HrNoticesPage extends StatelessWidget {
  const HrNoticesPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HrColors.background,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: hrNotices.length,
        separatorBuilder: (_, _) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          final notice = hrNotices[index];
          return HrCard(
            onTap: () => controller.open(HrRoute.noticeDetail),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: notice.unread ? HrColors.mint : HrColors.background,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    notice.title == '面试邀请'
                        ? Icons.event_available_outlined
                        : notice.title.contains('简历')
                        ? Icons.assignment_turned_in_outlined
                        : Icons.notifications_none,
                    color: HrColors.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            notice.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (notice.unread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: HrColors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            notice.time,
                            style: const TextStyle(
                              color: HrColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        notice.preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: HrColors.textSecondary,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HrNoticeDetailPage extends StatelessWidget {
  const HrNoticeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notice = hrNotices.first;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        HrCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notice.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${notice.time} · 企业直聘',
                style: const TextStyle(color: HrColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 18),
              Text(
                notice.content,
                style: const TextStyle(
                  color: HrColors.textSecondary,
                  fontSize: 14,
                  height: 1.85,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HrColors.mint,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      size: 17,
                      color: HrColors.primary,
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '如需调整面试时间，请直接在消息中与招聘方沟通。',
                        style: TextStyle(
                          color: HrColors.primaryDark,
                          fontSize: 12,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HrRobotPage extends StatefulWidget {
  const HrRobotPage({super.key});

  @override
  State<HrRobotPage> createState() => _HrRobotPageState();
}

class _HrRobotPageState extends State<HrRobotPage> {
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
                  style: TextStyle(color: HrColors.textMuted, fontSize: 10),
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
                  style: TextStyle(color: HrColors.textMuted, fontSize: 11),
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
                        backgroundColor: HrColors.mint,
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
                onPressed: () => hrToast(context, '已为你连接人工客服'),
                tooltip: '人工客服',
                icon: const Icon(
                  Icons.support_agent,
                  color: HrColors.textSecondary,
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
                    color: HrColors.primary,
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
                  colors: [HrColors.primary, Color(0xFF54CFAD)],
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
                color: mine ? HrColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: mine ? Colors.white : HrColors.text,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ),
          if (mine) ...[
            const SizedBox(width: 8),
            const HrAvatar(label: '林', size: 34),
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
        color: HrColors.textMuted,
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
