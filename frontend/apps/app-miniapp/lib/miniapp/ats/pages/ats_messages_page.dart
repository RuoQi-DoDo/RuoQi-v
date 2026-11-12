part of 'message_pages.dart';

class AtsMessagesPage extends StatelessWidget {
  const AtsMessagesPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final isRecruiter = controller.role == AtsUserRole.recruiter;
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
                        0 => AtsRoute.notices,
                        1 => AtsRoute.applications,
                        2 => isRecruiter ? AtsRoute.connected : AtsRoute.browse,
                        _ => AtsRoute.connected,
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
                                      ? AtsColors.mint
                                      : AtsColors.background,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  actions[i].icon,
                                  size: 21,
                                  color: i == 0
                                      ? AtsColors.primary
                                      : AtsColors.textSecondary,
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
                                      color: AtsColors.red,
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
                              color: AtsColors.textSecondary,
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
            onTap: () => controller.open(AtsRoute.notices),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AtsColors.primary, Color(0xFF50CFAE)],
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
                            AtsTag(
                              '1条新消息',
                              foreground: AtsColors.red,
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
                            color: AtsColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '刚刚',
                    style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
        const AtsSectionHeader(title: '最近聊天'),
        if (atsConversations.isEmpty)
          const AtsEmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: '暂无消息',
          )
        else
          Material(
            color: Colors.white,
            child: Column(
              children: [
                for (var i = 0; i < atsConversations.length; i++) ...[
                  _ConversationTile(
                    conversation: atsConversations[i],
                    onTap: () => controller.open(AtsRoute.privateChat),
                  ),
                  if (i != atsConversations.length - 1)
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

  final AtsConversation conversation;
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
                AtsAvatar(
                  label: conversation.name,
                  size: 45,
                  color: conversation.name == '李经理'
                      ? AtsColors.blue
                      : AtsColors.primary,
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
                            color: AtsColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        conversation.time,
                        style: const TextStyle(
                          color: AtsColors.textMuted,
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
                            color: AtsColors.textMuted,
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
                            color: AtsColors.red,
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
