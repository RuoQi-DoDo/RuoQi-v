import 'dart:ui' as ui;

import 'package:common/common.dart';
import 'package:material_ui/material_ui.dart';

import '../calls/calls_page.dart';
import '../common/page_theme.dart';
import '../common/page_widgets.dart';
import '../scan/scan_page.dart';
import 'im_localizations.dart';
import 'im_style.dart';

/// Authenticated IM business home. Unauthenticated entry is handled by the app
/// shell's welcome and login gates.
class ImChatPage extends StatelessWidget {
  const ImChatPage({super.key, this.scrollController});

  final ScrollController? scrollController;

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ImChatPage());

  @override
  Widget build(BuildContext context) {
    return _ImChatList(scrollController: scrollController);
  }
}

class _ImChatList extends StatelessWidget {
  const _ImChatList({required this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final conversations = _conversations(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 42,
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: HostChromeStyle.appBarBackground(context),
        title: Text(
          'RuoQi',
          style: zh(
            theme.textTheme.titleLarge!.copyWith(
              color: scheme.onSurface,
              fontWeight: HostTypography.emphasis,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: imText(context, '搜索', 'Search'),
            constraints: const BoxConstraints.tightFor(width: 42, height: 42),
            padding: EdgeInsets.zero,
            onPressed: () => showPageMessage(
              context,
              imText(context, '搜索功能为模拟入口', 'Search is a demo entry'),
            ),
            icon: const Icon(Icons.search_rounded),
          ),
          Builder(
            builder: (buttonContext) => IconButton(
              key: const Key('im-new-chat-button'),
              tooltip: imText(context, '发起', 'New chat'),
              constraints: const BoxConstraints.tightFor(width: 42, height: 42),
              padding: EdgeInsets.zero,
              onPressed: () => _showInitiationMenu(buttonContext),
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ),
          const SizedBox(width: 6),
        ],
        shape: Border(bottom: HostChromeStyle.appBarDivider(context)),
      ),
      body: CustomScrollView(
        key: const Key('customer-home-scroll'),
        controller: scrollController,
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final conversation = conversations[index];
              return _ChatRow(
                title: conversation.title,
                preview: conversation.preview,
                time: conversation.time,
                unread: conversation.unread,
                color: conversation.color,
                icon: conversation.icon,
                onTap: () => showPageMessage(
                  context,
                  imText(
                    context,
                    conversation.actionChinese,
                    conversation.actionEnglish,
                  ),
                ),
              );
            }, childCount: conversations.length),
          ),
        ],
      ),
    );
  }

  Future<void> _showInitiationMenu(BuildContext buttonContext) async {
    final anchor = buttonContext.findRenderObject();
    if (anchor is! RenderBox || !anchor.hasSize) return;
    final anchorRect = anchor.localToGlobal(Offset.zero) & anchor.size;
    final action = await showGeneralDialog<_InitiationAction>(
      context: buttonContext,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      barrierLabel: imText(buttonContext, '关闭发起菜单', 'Close start menu'),
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (context, animation, secondaryAnimation) {
        final media = MediaQuery.sizeOf(context);
        const menuWidth = 136.0;
        const menuRight = 5.0;
        final cardRight = media.width - menuRight;
        final arrowRight = (cardRight - anchorRect.center.dx - 7).clamp(
          12.0,
          menuWidth - 26,
        );
        return SafeArea(
          top: false,
          child: Padding(
            key: const Key('im-initiation-sheet'),
            padding: EdgeInsets.only(
              top: anchorRect.bottom - 5,
              right: menuRight,
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: menuWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: arrowRight),
                        child: const CustomPaint(
                          size: Size(14, 8),
                          painter: _InitiationArrowPainter(),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      elevation: 10,
                      shadowColor: Colors.black38,
                      borderRadius: BorderRadius.circular(7),
                      clipBehavior: Clip.antiAlias,
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: ColoredBox(
                          color: const Color(0xE61C1C1C),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _InitiationMenuItem(
                                key: const Key('im-initiate-call'),
                                icon: Icons.call_outlined,
                                label: imText(context, '发起通话', 'New call'),
                                onTap: () =>
                                    Navigator.of(context)
                                        .pop(_InitiationAction.call),
                              ),
                              const _InitiationMenuDivider(),
                              _InitiationMenuItem(
                                key: const Key('im-initiate-scan'),
                                icon: Icons.qr_code_scanner_rounded,
                                label: imText(context, '扫一扫', 'Scan'),
                                onTap: () =>
                                    Navigator.of(context)
                                        .pop(_InitiationAction.scan),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
    );
    if (!buttonContext.mounted || action == null) return;

    switch (action) {
      case _InitiationAction.call:
        await Navigator.of(buttonContext).push<void>(CallsPage.route());
      case _InitiationAction.scan:
        final value = await openScanner(buttonContext);
        if (value != null && buttonContext.mounted) {
          await showScanResult(buttonContext, value);
        }
    }
  }
}

enum _InitiationAction { call, scan }

class _InitiationMenuItem extends StatelessWidget {
  const _InitiationMenuItem({
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
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.05),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class _InitiationMenuDivider extends StatelessWidget {
  const _InitiationMenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 50,
      endIndent: 5,
      color: Color(0xFF454545),
    );
  }
}

class _InitiationArrowPainter extends CustomPainter {
  const _InitiationArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xE61C1C1C));
  }

  @override
  bool shouldRepaint(covariant _InitiationArrowPainter oldDelegate) => false;
}

List<_Conversation> _conversations(BuildContext context) {
  String text(String chinese, String english) =>
      imText(context, chinese, english);
  return [
    _Conversation(
      title: text('企业直聘', 'Enterprise Recruiting'),
      preview: text(
        '面试邀请：上海世佳科技邀请你参加面试',
        'Interview: Shanghai Shijia Technology wants to meet you',
      ),
      time: text('刚刚', 'Just now'),
      unread: 1,
      color: ImColors.brandStrong,
      icon: Icons.work_outline_rounded,
      actionChinese: '该聊天由小程序消息模拟',
      actionEnglish: 'This chat is simulated by the mini-program',
    ),
    _Conversation(
      title: '佳佳',
      preview: text('周末一起去看展吗？', 'Want to see the exhibition this weekend?'),
      time: '10:32',
      unread: 2,
      color: const Color(0xFFEC6A88),
      icon: Icons.person_outline_rounded,
      actionChinese: '聊天详情为模拟入口',
      actionEnglish: 'Chat details are a demo entry',
    ),
    _Conversation(
      title: text('文件传输助手', 'File Transfer'),
      preview: text('[文件] 简历-林小满.pdf', '[File] Resume - Lin Xiaoman.pdf'),
      time: text('昨天', 'Yesterday'),
      unread: 0,
      color: themeInfo(context),
      icon: Icons.folder_outlined,
      actionChinese: '文件传输为模拟入口',
      actionEnglish: 'File transfer is a demo entry',
    ),
    _Conversation(
      title: text('招聘交流群', 'Recruiting Group'),
      preview: text(
        '陈一鸣：感谢大家的建议',
        'Chen Yiming: Thanks for all the suggestions',
      ),
      time: text('昨天', 'Yesterday'),
      unread: 0,
      color: ImColors.brandStrong,
      icon: Icons.groups_outlined,
      actionChinese: '群聊为模拟入口',
      actionEnglish: 'Group chat is a demo entry',
    ),
    _Conversation(
      title: text('腾讯新闻', 'Tencent News'),
      preview: text('今日要闻：数字招聘的新趋势', 'Today: New trends in digital recruiting'),
      time: text('周一', 'Mon'),
      unread: 0,
      color: const Color(0xFFE36A2E),
      icon: Icons.article_outlined,
      actionChinese: '公众号为模拟入口',
      actionEnglish: 'Official account is a demo entry',
    ),
    _Conversation(
      title: text('张老师', 'Teacher Zhang'),
      preview: text('好的，明天下午两点见', 'Sure, see you at 2 PM tomorrow'),
      time: text('周一', 'Mon'),
      unread: 0,
      color: const Color(0xFF6366F1),
      icon: Icons.school_outlined,
      actionChinese: '聊天详情为模拟入口',
      actionEnglish: 'Chat details are a demo entry',
    ),
    _Conversation(
      title: '林小满',
      preview: text('简历已经更新，请查收', 'My resume is updated. Please take a look'),
      time: '11/10',
      unread: 0,
      color: const Color(0xFF0EA5E9),
      icon: Icons.description_outlined,
      actionChinese: '聊天详情为模拟入口',
      actionEnglish: 'Chat details are a demo entry',
    ),
    _Conversation(
      title: text('项目协作群', 'Project Team'),
      preview: text(
        '王工：需求文档已上传',
        'Engineer Wang: The requirements doc is uploaded',
      ),
      time: '11/09',
      unread: 12,
      color: const Color(0xFF8B5CF6),
      icon: Icons.groups_2_outlined,
      actionChinese: '群聊为模拟入口',
      actionEnglish: 'Group chat is a demo entry',
    ),
    _Conversation(
      title: text('服务通知', 'Service Notifications'),
      preview: text('你有一条新的系统通知', 'You have a new system notification'),
      time: '11/08',
      unread: 1,
      color: const Color(0xFF14B8A6),
      icon: Icons.notifications_outlined,
      actionChinese: '通知详情为模拟入口',
      actionEnglish: 'Notification details are a demo entry',
    ),
    _Conversation(
      title: text('RuoQi 助手', 'RuoQi Assistant'),
      preview: text('欢迎使用企业招聘服务', 'Welcome to RuoQi Recruiting'),
      time: '11/07',
      unread: 0,
      color: ImColors.brandStrong,
      icon: Icons.smart_toy_outlined,
      actionChinese: '助手详情为模拟入口',
      actionEnglish: 'Assistant details are a demo entry',
    ),
    _Conversation(
      title: text('王工', 'Engineer Wang'),
      preview: text('需求文档我再看一下', "I'll take another look at the requirements"),
      time: '11/06',
      unread: 0,
      color: const Color(0xFF64748B),
      icon: Icons.engineering_outlined,
      actionChinese: '聊天详情为模拟入口',
      actionEnglish: 'Chat details are a demo entry',
    ),
    _Conversation(
      title: text('产品设计群', 'Product Design'),
      preview: text('新版原型已经同步', 'The new prototype is synced'),
      time: '11/05',
      unread: 4,
      color: const Color(0xFF8B5CF6),
      icon: Icons.draw_outlined,
      actionChinese: '群聊为模拟入口',
      actionEnglish: 'Group chat is a demo entry',
    ),
    _Conversation(
      title: text('系统提醒', 'System Alerts'),
      preview: text("本周招聘数据已更新", "This week's recruiting data is updated"),
      time: '11/04',
      unread: 1,
      color: const Color(0xFF0EA5E9),
      icon: Icons.insights_outlined,
      actionChinese: '系统提醒为模拟入口',
      actionEnglish: 'System alerts are a demo entry',
    ),
    _Conversation(
      title: '陈一鸣',
      preview: text(
        '面试安排在周四上午',
        'The interview is scheduled for Thursday morning',
      ),
      time: '11/03',
      unread: 0,
      color: const Color(0xFFEC6A88),
      icon: Icons.person_outline_rounded,
      actionChinese: '聊天详情为模拟入口',
      actionEnglish: 'Chat details are a demo entry',
    ),
    _Conversation(
      title: text('运营协作群', 'Operations Team'),
      preview: text('活动物料已准备完成', 'Event materials are ready'),
      time: '11/02',
      unread: 0,
      color: ImColors.brandStrong,
      icon: Icons.campaign_outlined,
      actionChinese: '群聊为模拟入口',
      actionEnglish: 'Group chat is a demo entry',
    ),
    _Conversation(
      title: '刘洋',
      preview: text('收到，我马上处理', "Got it. I'll take care of it"),
      time: '11/01',
      unread: 0,
      color: const Color(0xFF2F88FF),
      icon: Icons.person_outline_rounded,
      actionChinese: '聊天详情为模拟入口',
      actionEnglish: 'Chat details are a demo entry',
    ),
    _Conversation(
      title: text('订阅号消息', 'Subscription Updates'),
      preview: text('你关注的内容有新更新', 'There are updates from your subscriptions'),
      time: '10/31',
      unread: 0,
      color: const Color(0xFF14B8A6),
      icon: Icons.article_outlined,
      actionChinese: '订阅号为模拟入口',
      actionEnglish: 'Subscriptions are a demo entry',
    ),
    _Conversation(
      title: '何川',
      preview: text(
        '文档已上传到共享空间',
        'The document is uploaded to the shared space',
      ),
      time: '10/30',
      unread: 0,
      color: const Color(0xFF6366F1),
      icon: Icons.description_outlined,
      actionChinese: '聊天详情为模拟入口',
      actionEnglish: 'Chat details are a demo entry',
    ),
    _Conversation(
      title: text('客户服务', 'Customer Support'),
      preview: text(
        '感谢你的反馈，我们会尽快处理',
        "Thanks for your feedback. We'll look into it",
      ),
      time: '10/29',
      unread: 0,
      color: const Color(0xFFE36A2E),
      icon: Icons.support_agent_outlined,
      actionChinese: '客户服务为模拟入口',
      actionEnglish: 'Customer support is a demo entry',
    ),
    _Conversation(
      title: text('招聘助手', 'Recruiting Assistant'),
      preview: text('今日新增 3 位候选人', '3 new candidates today'),
      time: '10/28',
      unread: 2,
      color: ImColors.brandStrong,
      icon: Icons.work_outline_rounded,
      actionChinese: '招聘助手为模拟入口',
      actionEnglish: 'Recruiting assistant is a demo entry',
    ),
  ];
}

Color themeInfo(BuildContext context) {
  return Theme.of(context).extension<RuQiThemeExtension>()?.info ??
      Theme.of(context).colorScheme.secondary;
}

class _Conversation {
  const _Conversation({
    required this.title,
    required this.preview,
    required this.time,
    required this.unread,
    required this.color,
    required this.icon,
    required this.actionChinese,
    required this.actionEnglish,
  });

  final String title;
  final String preview;
  final String time;
  final int unread;
  final Color color;
  final IconData icon;
  final String actionChinese;
  final String actionEnglish;
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.title,
    required this.preview,
    required this.time,
    required this.unread,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String preview;
  final String time;
  final int unread;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dividerColor = HostChromeStyle.dividerColor(context);
    final hairline = HostChromeStyle.hairline(context);
    final unreadLabel = imText(context, '$unread 条未读', '$unread unread');
    return Material(
      color: scheme.surfaceContainerLowest,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            SizedBox(
              height: 65,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 9.5, 16, 9.5),
                child: Row(
                  children: [
                    Semantics(
                      label: unread > 0 ? unreadLabel : null,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color, size: 22),
                              ),
                            ),
                            if (unread > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: unread > 9
                                    ? Container(
                                        key: const Key('im-icon-unread'),
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: ImColors.brandStrong,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : Container(
                                        key: const Key('im-icon-unread'),
                                        constraints: const BoxConstraints(
                                          minWidth: 14,
                                        ),
                                        height: 14,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: ImColors.brandStrong,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(7),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$unread',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w700,
                                            height: 1,
                                          ),
                                        ),
                                      ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.08,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                              Text(
                                time,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.brightness == Brightness.dark
                                      ? const Color(0xFF939B97)
                                      : const Color(0xFF737B77),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFFA5ADA9)
                                  : const Color(0xFF5F6864),
                              fontSize: 13,
                              height: 1.12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 71,
              right: 0,
              bottom: 0,
              height: hairline,
              child: ColoredBox(color: dividerColor),
            ),
          ],
        ),
      ),
    );
  }
}
