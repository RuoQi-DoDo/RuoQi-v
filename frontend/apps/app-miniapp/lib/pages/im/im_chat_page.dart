import 'package:common/common.dart';
import 'package:flutter/material.dart';
import '../common/page_localizations.dart';
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
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        scheme.onSurfaceVariant;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Text(
              'RuoQi',
              style: zh(
                theme.textTheme.headlineMedium!.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                pageLabel(context, '客户模拟'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: () => showPageMessage(context, '搜索功能为模拟入口'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: '发起',
            onPressed: () => showPageMessage(context, '发起功能为模拟入口'),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          const SizedBox(width: 6),
        ],
        shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
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
    return Material(
      color: scheme.surfaceContainerLowest,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 23),
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (unread > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 18),
                            height: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: scheme.error,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$unread',
                              style: TextStyle(
                                color: scheme.onError,
                                fontSize: 10,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
