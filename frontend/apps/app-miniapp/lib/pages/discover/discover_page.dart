import 'package:flutter/material.dart';

import '../common/page_widgets.dart';
import '../mini_programs/mini_programs_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({
    super.key,
    this.onTap,
    this.onOpenMiniPrograms,
    this.embedded = false,
  });

  final VoidCallback? onOpenMiniPrograms;

  final ValueChanged<String>? onTap;
  final bool embedded;

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const DiscoverPage());

  @override
  Widget build(BuildContext context) {
    final handleTap = onTap ?? (message) => showPageMessage(context, message);
    return SharedPageFrame(
      embedded: embedded,
      title: '发现',
      actions: [
        IconButton(
          tooltip: '搜索',
          onPressed: () => handleTap('搜索功能为模拟入口'),
          icon: const Icon(Icons.search_rounded),
        ),
        IconButton(
          tooltip: '发起',
          onPressed: () => handleTap('发起功能为模拟入口'),
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
        const SizedBox(width: 6),
      ],
      builder: _buildContent,
    );
  }

  Widget _buildContent(BuildContext context) {
    final onTap = this.onTap ?? (message) => showPageMessage(context, message);

    return ListView(
      key: const Key('discover-page'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        PageListGroup(
          children: [
            PageListRow(
              icon: Icons.camera_rounded,
              color: const Color(0xFF49B84A),
              title: '朋友圈',
              compactTrailing: const SquareBadge(),
              onTap: () => onTap('朋友圈为模拟入口'),
            ),
            PageListRow(
              icon: Icons.slow_motion_video_rounded,
              color: const Color(0xFFEE8B2D),
              title: '视频号',
              badge: '1',
              trailingText: '等2个',
              onTap: () => onTap('视频号为模拟入口'),
            ),
            PageListRow(
              icon: Icons.sensors_rounded,
              color: const Color(0xFFF05656),
              title: '直播',
              showRedDot: true,
              onTap: () => onTap('直播为模拟入口'),
            ),
          ],
        ),
        PageListGroup(
          children: [
            PageListRow(
              icon: Icons.qr_code_scanner_rounded,
              color: const Color(0xFF2F88FF),
              title: '扫一扫',
              onTap: () => onTap('扫一扫为模拟入口'),
            ),
            PageListRow(
              icon: Icons.graphic_eq_rounded,
              color: const Color(0xFFF05656),
              title: '听一听',
              onTap: () => onTap('听一听为模拟入口'),
            ),
          ],
        ),
        PageListGroup(
          children: [
            PageListRow(
              icon: Icons.auto_awesome_rounded,
              color: const Color(0xFFE8B72E),
              title: '看一看',
              onTap: () => onTap('看一看为模拟入口'),
            ),
            PageListRow(
              icon: Icons.search_rounded,
              color: const Color(0xFFF05656),
              title: '搜一搜',
              onTap: () => onTap('搜一搜为模拟入口'),
            ),
          ],
        ),
        PageListGroup(
          children: [
            PageListRow(
              icon: Icons.people_alt_outlined,
              color: const Color(0xFF2F88FF),
              title: '附近的人',
              onTap: () => onTap('附近的人为模拟入口'),
            ),
          ],
        ),
        PageListGroup(
          children: [
            PageListRow(
              icon: Icons.sports_esports_outlined,
              color: const Color(0xFF7C62D9),
              title: '游戏',
              onTap: () => onTap('游戏为模拟入口'),
            ),
          ],
        ),
        PageListGroup(
          children: [
            PageListRow(
              key: const Key('discover-mini-programs'),
              icon: Icons.apps_rounded,
              color: const Color(0xFF7C62D9),
              title: '小程序',
              onTap:
                  onOpenMiniPrograms ??
                  () => Navigator.of(
                    context,
                  ).push<void>(MiniProgramsPage.route()),
            ),
          ],
        ),
      ],
    );
  }
}
