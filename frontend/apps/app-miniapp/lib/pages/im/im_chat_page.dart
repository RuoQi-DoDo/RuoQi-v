import 'package:common/common.dart';
import 'package:flutter/material.dart';
import '../common/page_theme.dart';
import '../common/page_widgets.dart';

/// IM chat home. Shared navigation is composed by BusinessHostPage.
class ImChatPage extends StatelessWidget {
  const ImChatPage({super.key, this.scrollController});
  final ScrollController? scrollController;
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const ImChatPage());
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: '搜索',
            constraints: const BoxConstraints.tightFor(width: 42, height: 42),
            padding: EdgeInsets.zero,
            onPressed: () => showPageMessage(context, '搜索功能为模拟入口'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: '发起',
            constraints: const BoxConstraints.tightFor(width: 42, height: 42),
            padding: EdgeInsets.zero,
            onPressed: () => showPageMessage(context, '发起功能为模拟入口'),
            icon: const Icon(Icons.add_circle_outline_rounded),
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
            delegate: SliverChildListDelegate([
              _ChatRow(
                title: '企业直聘',
                preview: '面试邀请：上海世佳科技邀请你参加面试',
                time: '刚刚',
                unread: 1,
                color: scheme.primary,
                icon: Icons.work_outline_rounded,
                onTap: () => showPageMessage(context, '该聊天由小程序消息模拟'),
              ),
              _ChatRow(
                title: '佳佳',
                preview: '周末一起去看展吗？',
                time: '10:32',
                unread: 2,
                color: const Color(0xFFEC6A88),
                icon: Icons.person_outline_rounded,
                onTap: () => showPageMessage(context, '聊天详情为模拟入口'),
              ),
              _ChatRow(
                title: '文件传输助手',
                preview: '[文件] 简历-林小满.pdf',
                time: '昨天',
                unread: 0,
                color:
                    theme.extension<RuQiThemeExtension>()?.info ??
                    scheme.secondary,
                icon: Icons.folder_outlined,
                onTap: () => showPageMessage(context, '文件传输为模拟入口'),
              ),
              _ChatRow(
                title: '招聘交流群',
                preview: '陈一鸣：感谢大家的建议',
                time: '昨天',
                unread: 0,
                color: scheme.primary,
                icon: Icons.groups_outlined,
                onTap: () => showPageMessage(context, '群聊为模拟入口'),
              ),
              _ChatRow(
                title: '腾讯新闻',
                preview: '今日要闻：数字招聘的新趋势',
                time: '周一',
                unread: 0,
                color: const Color(0xFFE36A2E),
                icon: Icons.article_outlined,
                onTap: () => showPageMessage(context, '公众号为模拟入口'),
              ),
              _ChatRow(
                title: '张老师',
                preview: '好的，明天下午两点见',
                time: '周一',
                unread: 0,
                color: const Color(0xFF6366F1),
                icon: Icons.school_outlined,
                onTap: () => showPageMessage(context, '聊天详情为模拟入口'),
              ),
              _ChatRow(
                title: '林小满',
                preview: '简历已经更新，请查收',
                time: '11/10',
                unread: 0,
                color: const Color(0xFF0EA5E9),
                icon: Icons.description_outlined,
                onTap: () => showPageMessage(context, '聊天详情为模拟入口'),
              ),
              _ChatRow(
                title: '项目协作群',
                preview: '王工：需求文档已上传',
                time: '11/09',
                unread: 3,
                color: const Color(0xFF8B5CF6),
                icon: Icons.groups_2_outlined,
                onTap: () => showPageMessage(context, '群聊为模拟入口'),
              ),
              _ChatRow(
                title: '服务通知',
                preview: '你有一条新的系统通知',
                time: '11/08',
                unread: 1,
                color: const Color(0xFF14B8A6),
                icon: Icons.notifications_outlined,
                onTap: () => showPageMessage(context, '通知详情为模拟入口'),
              ),
              _ChatRow(
                title: 'RuoQi 助手',
                preview: '欢迎使用企业招聘服务',
                time: '11/07',
                unread: 0,
                color: scheme.primary,
                icon: Icons.smart_toy_outlined,
                onTap: () => showPageMessage(context, '助手详情为模拟入口'),
              ),
              _ChatRow(
                title: '王工',
                preview: '需求文档我再看一下',
                time: '11/06',
                unread: 0,
                color: const Color(0xFF64748B),
                icon: Icons.engineering_outlined,
                onTap: () => showPageMessage(context, '聊天详情为模拟入口'),
              ),
              _ChatRow(
                title: '产品设计群',
                preview: '新版原型已经同步',
                time: '11/05',
                unread: 4,
                color: const Color(0xFF8B5CF6),
                icon: Icons.draw_outlined,
                onTap: () => showPageMessage(context, '群聊为模拟入口'),
              ),
              _ChatRow(
                title: '系统提醒',
                preview: '本周招聘数据已更新',
                time: '11/04',
                unread: 1,
                color: const Color(0xFF0EA5E9),
                icon: Icons.insights_outlined,
                onTap: () => showPageMessage(context, '系统提醒为模拟入口'),
              ),
              _ChatRow(
                title: '陈一鸣',
                preview: '面试安排在周四上午',
                time: '11/03',
                unread: 0,
                color: const Color(0xFFEC6A88),
                icon: Icons.person_outline_rounded,
                onTap: () => showPageMessage(context, '聊天详情为模拟入口'),
              ),
              _ChatRow(
                title: '运营协作群',
                preview: '活动物料已准备完成',
                time: '11/02',
                unread: 0,
                color: const Color(0xFF07C160),
                icon: Icons.campaign_outlined,
                onTap: () => showPageMessage(context, '群聊为模拟入口'),
              ),
              _ChatRow(
                title: '刘洋',
                preview: '收到，我马上处理',
                time: '11/01',
                unread: 0,
                color: const Color(0xFF2F88FF),
                icon: Icons.person_outline_rounded,
                onTap: () => showPageMessage(context, '聊天详情为模拟入口'),
              ),
              _ChatRow(
                title: '订阅号消息',
                preview: '你关注的内容有新更新',
                time: '10/31',
                unread: 0,
                color: const Color(0xFF14B8A6),
                icon: Icons.article_outlined,
                onTap: () => showPageMessage(context, '订阅号为模拟入口'),
              ),
              _ChatRow(
                title: '何川',
                preview: '文档已上传到共享空间',
                time: '10/30',
                unread: 0,
                color: const Color(0xFF6366F1),
                icon: Icons.description_outlined,
                onTap: () => showPageMessage(context, '聊天详情为模拟入口'),
              ),
              _ChatRow(
                title: '客户服务',
                preview: '感谢你的反馈，我们会尽快处理',
                time: '10/29',
                unread: 0,
                color: const Color(0xFFE36A2E),
                icon: Icons.support_agent_outlined,
                onTap: () => showPageMessage(context, '客户服务为模拟入口'),
              ),
              _ChatRow(
                title: '招聘助手',
                preview: '今日新增 3 位候选人',
                time: '10/28',
                unread: 2,
                color: scheme.primary,
                icon: Icons.work_outline_rounded,
                onTap: () => showPageMessage(context, '招聘助手为模拟入口'),
              ),
            ]),
          ),
        ],
      ),
    );
  }
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
    return Material(
      color: scheme.surfaceContainerLowest,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 9.25, 14, 9.25),
              child: Row(
                children: [
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: color, size: 23),
                          ),
                        ),
                        if (unread > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: scheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: scheme.onSurface,
                                fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.05,
                                ),
                              ),
                            ),
                            Text(
                              time,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF8A8A8A)
                                    : const Color(0xFF999999),
                                fontSize: 11,
                                height: 1.05,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                preview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.brightness == Brightness.dark
                                      ? const Color(0xFF8A8A8A)
                                      : const Color(0xFF999999),
                                  fontSize: 12,
                                  height: 1.05,
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
            Positioned(
              left: 68,
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
