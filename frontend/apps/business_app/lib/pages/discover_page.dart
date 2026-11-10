part of 'customer_home_page.dart';

class _DiscoverPage extends StatelessWidget {
  const _DiscoverPage({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('discover-page'),
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        _WeChatListGroup(
          children: [
            _WeChatListRow(
              icon: Icons.camera_rounded,
              color: const Color(0xFF49B84A),
              title: '朋友圈',
              compactTrailing: const _SquareBadge(),
              onTap: () => onTap('朋友圈为模拟入口'),
            ),
            _WeChatListRow(
              icon: Icons.slow_motion_video_rounded,
              color: const Color(0xFFEE8B2D),
              title: '视频号',
              badge: '1',
              trailingText: '等2个',
              onTap: () => onTap('视频号为模拟入口'),
            ),
            _WeChatListRow(
              icon: Icons.sensors_rounded,
              color: const Color(0xFFF05656),
              title: '直播',
              showRedDot: true,
              onTap: () => onTap('直播为模拟入口'),
            ),
          ],
        ),
        _WeChatListGroup(
          children: [
            _WeChatListRow(
              icon: Icons.qr_code_scanner_rounded,
              color: const Color(0xFF2F88FF),
              title: '扫一扫',
              onTap: () => onTap('扫一扫为模拟入口'),
            ),
            _WeChatListRow(
              icon: Icons.graphic_eq_rounded,
              color: const Color(0xFFF05656),
              title: '听一听',
              onTap: () => onTap('听一听为模拟入口'),
            ),
          ],
        ),
        _WeChatListGroup(
          children: [
            _WeChatListRow(
              icon: Icons.auto_awesome_rounded,
              color: const Color(0xFFE8B72E),
              title: '看一看',
              onTap: () => onTap('看一看为模拟入口'),
            ),
            _WeChatListRow(
              icon: Icons.search_rounded,
              color: const Color(0xFFF05656),
              title: '搜一搜',
              onTap: () => onTap('搜一搜为模拟入口'),
            ),
          ],
        ),
        _WeChatListGroup(
          children: [
            _WeChatListRow(
              icon: Icons.people_alt_outlined,
              color: const Color(0xFF2F88FF),
              title: '附近的人',
              onTap: () => onTap('附近的人为模拟入口'),
            ),
          ],
        ),
        _WeChatListGroup(
          children: [
            _WeChatListRow(
              icon: Icons.shopping_bag_outlined,
              color: const Color(0xFFF0A52D),
              title: '购物',
              onTap: () => onTap('购物为模拟入口'),
            ),
            _WeChatListRow(
              icon: Icons.sports_esports_outlined,
              color: const Color(0xFF7C62D9),
              title: '游戏',
              onTap: () => onTap('游戏为模拟入口'),
            ),
          ],
        ),
        _WeChatListGroup(
          children: [
            _WeChatListRow(
              icon: Icons.apps_rounded,
              color: const Color(0xFF7C62D9),
              title: '小程序',
              onTap: () => onTap('小程序入口为模拟入口'),
            ),
          ],
        ),
      ],
    );
  }
}
