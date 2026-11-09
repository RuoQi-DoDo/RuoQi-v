import 'package:common/common.dart';
import 'package:flutter/material.dart';

import '../mini-program/ats/ats_mini_program.dart';
import '../mini-program/merchant/home_page.dart';
import '../mini-program/mini_program_shell.dart';
import '../mini-program/partner/home_page.dart';

enum _CustomerSubview { host, picker, ats }

/// 客户域独立首页。
///
/// 视觉与交互模拟微信宿主：客户首页作为外层 App，下拉打开小程序选择页，
/// 再从“企业直聘”进入 ATS 小程序。关闭小程序后回到这里。
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  static Route<void> route() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const CustomerHomePage();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  _CustomerSubview _subview = _CustomerSubview.host;
  _CustomerSubview _atsReturnSubview = _CustomerSubview.host;

  void _openMiniProgramPicker() {
    setState(() => _subview = _CustomerSubview.picker);
  }

  void _closeMiniProgramPicker() {
    setState(() => _subview = _CustomerSubview.host);
  }

  void _openAtsMiniProgram() {
    setState(() {
      _atsReturnSubview = _subview;
      _subview = _CustomerSubview.ats;
    });
  }

  void _exitAtsMiniProgram() {
    setState(() => _subview = _atsReturnSubview);
  }

  void _openMerchantMiniProgram() {
    Navigator.of(context).push<void>(
      MiniProgramShell.route(
        title: '商户',
        icon: Icons.fingerprint,
        child: const MerchantHomePage(embedded: true),
      ),
    );
  }

  void _openPartnerMiniProgram() {
    Navigator.of(context).push<void>(
      MiniProgramShell.route(
        title: '伙伴',
        icon: Icons.handshake_outlined,
        child: const PartnerHomePage(embedded: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _subview == _CustomerSubview.host,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        switch (_subview) {
          case _CustomerSubview.host:
            break;
          case _CustomerSubview.picker:
            _closeMiniProgramPicker();
          case _CustomerSubview.ats:
            _exitAtsMiniProgram();
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            fit: StackFit.expand,
            children: [...previousChildren, ?currentChild],
          );
        },
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: switch (_subview) {
          _CustomerSubview.host => _buildHostPage(
            context,
            key: const ValueKey('customer-host-home'),
          ),
          _CustomerSubview.picker => _MiniProgramPickerPage(
            key: const ValueKey('customer-mini-program-picker'),
            onOpenAts: _openAtsMiniProgram,
            onOpenMerchant: _openMerchantMiniProgram,
            onOpenPartner: _openPartnerMiniProgram,
            onExit: _closeMiniProgramPicker,
          ),
          _CustomerSubview.ats => AtsMiniProgram(
            key: const ValueKey('ats-mini-program'),
            onExit: _exitAtsMiniProgram,
          ),
        },
      ),
    );
  }

  Widget _buildHostPage(BuildContext context, {required Key key}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        scheme.onSurfaceVariant;

    return Scaffold(
      key: key,
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
            Text(
              '客户模拟',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: () => _showHostToast(context, '搜索功能为模拟入口'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: '发起',
            onPressed: () => _showHostToast(context, '发起功能为模拟入口'),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          const SizedBox(width: 6),
        ],
        shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      body: RefreshIndicator(
        color: scheme.primary,
        onRefresh: () async {
          _openMiniProgramPicker();
          await Future<void>.delayed(const Duration(milliseconds: 240));
        },
        child: CustomScrollView(
          key: const Key('customer-home-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
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
                  onTap: () => _showHostToast(context, '该聊天由小程序消息模拟'),
                ),
                _ChatRow(
                  title: '佳佳',
                  preview: '周末一起去看展吗？',
                  time: '10:32',
                  unread: 2,
                  color: const Color(0xFFEC6A88),
                  icon: Icons.person_outline_rounded,
                  onTap: () => _showHostToast(context, '聊天详情为模拟入口'),
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
                  onTap: () => _showHostToast(context, '文件传输为模拟入口'),
                ),
                _ChatRow(
                  title: '招聘交流群',
                  preview: '陈一鸣：感谢大家的建议',
                  time: '昨天',
                  unread: 0,
                  color: scheme.primary,
                  icon: Icons.groups_outlined,
                  onTap: () => _showHostToast(context, '群聊为模拟入口'),
                ),
                _ChatRow(
                  title: '腾讯新闻',
                  preview: '今日要闻：数字招聘的新趋势',
                  time: '周一',
                  unread: 0,
                  color: const Color(0xFFE36A2E),
                  icon: Icons.article_outlined,
                  onTap: () => _showHostToast(context, '公众号为模拟入口'),
                ),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _WeChatTabBar(),
    );
  }

  static void _showHostToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MiniProgramPickerPage extends StatefulWidget {
  const _MiniProgramPickerPage({
    super.key,
    required this.onOpenAts,
    required this.onOpenMerchant,
    required this.onOpenPartner,
    required this.onExit,
  });

  final VoidCallback onOpenAts;
  final VoidCallback onOpenMerchant;
  final VoidCallback onOpenPartner;
  final VoidCallback onExit;

  @override
  State<_MiniProgramPickerPage> createState() => _MiniProgramPickerPageState();
}

class _MiniProgramPickerPageState extends State<_MiniProgramPickerPage> {
  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Theme(
      data: ruoQiTheme(brightness: Brightness.dark, accent: accent),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          final muted =
              theme.extension<RuQiThemeExtension>()?.inkMuted ??
              scheme.onSurfaceVariant;
          final info =
              theme.extension<RuQiThemeExtension>()?.info ?? scheme.secondary;

          final recent = <_LauncherMiniProgramData>[
            _LauncherMiniProgramData(
              label: '企业直聘',
              icon: Icons.work_outline_rounded,
              color: scheme.primary,
              opensAts: true,
            ),
            _LauncherMiniProgramData(
              label: '文件助手',
              icon: Icons.folder_outlined,
              color: info,
            ),
            _LauncherMiniProgramData(
              label: '企业服务',
              icon: Icons.business_center_outlined,
              color: const Color(0xFFE36A2E),
            ),
            _LauncherMiniProgramData(
              label: '会议',
              icon: Icons.videocam_outlined,
              color: const Color(0xFF4D8DFF),
            ),
            _LauncherMiniProgramData(
              label: '简历助手',
              icon: Icons.description_outlined,
              color: const Color(0xFF8B5CF6),
            ),
            _LauncherMiniProgramData(
              label: '人才库',
              icon: Icons.people_outline_rounded,
              color: const Color(0xFF16A34A),
            ),
            _LauncherMiniProgramData(
              label: '面试日历',
              icon: Icons.calendar_month_outlined,
              color: const Color(0xFF0EA5E9),
            ),
            _LauncherMiniProgramData(
              label: '更多',
              icon: Icons.apps_rounded,
              color: muted,
            ),
          ];
          final common = <_LauncherMiniProgramData>[
            _LauncherMiniProgramData(
              label: '企业直聘',
              icon: Icons.work_outline_rounded,
              color: scheme.primary,
              opensAts: true,
            ),
            _LauncherMiniProgramData(
              label: '企业服务',
              icon: Icons.business_center_outlined,
              color: const Color(0xFFE36A2E),
            ),
            _LauncherMiniProgramData(
              label: '商户',
              icon: Icons.fingerprint,
              color: const Color(0xFF3B82F6),
              opensMerchant: true,
            ),
            _LauncherMiniProgramData(
              label: '伙伴',
              icon: Icons.handshake_outlined,
              color: const Color(0xFF8B5CF6),
              opensPartner: true,
            ),
            _LauncherMiniProgramData(
              label: '人才测评',
              icon: Icons.psychology_outlined,
              color: const Color(0xFF10B981),
            ),
            _LauncherMiniProgramData(
              label: '视频面试',
              icon: Icons.video_chat_outlined,
              color: const Color(0xFFF97316),
            ),
            _LauncherMiniProgramData(
              label: '日程',
              icon: Icons.event_note_outlined,
              color: const Color(0xFF14B8A6),
            ),
            _LauncherMiniProgramData(
              label: '设置',
              icon: Icons.tune_rounded,
              color: muted,
            ),
          ];

          return Scaffold(
            backgroundColor: scheme.surface,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 58,
                    child: Center(
                      child: Text(
                        '最近',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: scheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _PickerSearchBar(
                      onTap: () => _pickerToast(context, '搜索小程序为模拟入口'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: [
                        _PickerSectionHeader(
                          title: '最近使用的小程序',
                          trailing: '更多',
                          onTap: () => _pickerToast(context, '查看更多最近使用'),
                        ),
                        const SizedBox(height: 14),
                        _LauncherGrid(
                          items: recent,
                          onOpenAts: widget.onOpenAts,
                          onOpenMerchant: widget.onOpenMerchant,
                          onOpenPartner: widget.onOpenPartner,
                          onOther: () => _pickerToast(context, '该小程序为模拟入口'),
                        ),
                        const SizedBox(height: 30),
                        _PickerSectionHeader(
                          title: '常用的小程序',
                          trailing: '我的小程序',
                          onTap: () => _pickerToast(context, '管理我的小程序'),
                        ),
                        const SizedBox(height: 14),
                        _LauncherGrid(
                          items: common,
                          onOpenAts: widget.onOpenAts,
                          onOpenMerchant: widget.onOpenMerchant,
                          onOpenPartner: widget.onOpenPartner,
                          onOther: () => _pickerToast(context, '该小程序为模拟入口'),
                          highlightAtsForTest: true,
                        ),
                        const SizedBox(height: 30),
                        const _PickerSectionHeader(title: '刚刚看过（最近1小时）'),
                        const SizedBox(height: 14),
                        _ViewedMiniProgramCard(
                          onTap: () => _pickerToast(context, '求职课堂视频为模拟入口'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: _PickerSwipeUpExitHandle(
                onExit: widget.onExit,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PickerBottomBar(
                      onSearch: () => _pickerToast(context, '搜索小程序为模拟入口'),
                      onMore: () => _pickerToast(context, '更多为模拟入口'),
                    ),
                    Container(
                      height: 18,
                      color: scheme.surfaceContainer,
                      alignment: Alignment.center,
                      child: Container(
                        width: 110,
                        height: 4,
                        decoration: BoxDecoration(
                          color: scheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static void _pickerToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        ),
      );
  }
}

class _PickerSwipeUpExitHandle extends StatefulWidget {
  const _PickerSwipeUpExitHandle({required this.onExit, required this.child});

  final VoidCallback onExit;
  final Widget child;

  @override
  State<_PickerSwipeUpExitHandle> createState() =>
      _PickerSwipeUpExitHandleState();
}

class _PickerSwipeUpExitHandleState extends State<_PickerSwipeUpExitHandle> {
  double _upwardDistance = 0;

  void _completeExit() {
    _upwardDistance = 0;
    widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '底部上滑返回客户首页',
      child: GestureDetector(
        key: const Key('mini-program-picker-exit-swipe'),
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (_) => _upwardDistance = 0,
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < 0) {
            _upwardDistance -= details.delta.dy;
          }
          if (_upwardDistance >= 48) {
            _completeExit();
          }
        },
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -280) {
            _completeExit();
          }
          _upwardDistance = 0;
        },
        child: widget.child,
      ),
    );
  }
}

class _LauncherMiniProgramData {
  const _LauncherMiniProgramData({
    required this.label,
    required this.icon,
    required this.color,
    this.opensAts = false,
    this.opensMerchant = false,
    this.opensPartner = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool opensAts;
  final bool opensMerchant;
  final bool opensPartner;
}

class _LauncherGrid extends StatelessWidget {
  const _LauncherGrid({
    required this.items,
    required this.onOpenAts,
    required this.onOpenMerchant,
    required this.onOpenPartner,
    required this.onOther,
    this.highlightAtsForTest = false,
  });

  final List<_LauncherMiniProgramData> items;
  final VoidCallback onOpenAts;
  final VoidCallback onOpenMerchant;
  final VoidCallback onOpenPartner;
  final VoidCallback onOther;
  final bool highlightAtsForTest;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 102,
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final key = item.opensAts && highlightAtsForTest
            ? const Key('mini-program-picker-ats')
            : item.opensMerchant
            ? const Key('mini-program-picker-merchant')
            : item.opensPartner
            ? const Key('mini-program-picker-partner')
            : null;
        return _LauncherMiniProgramTile(
          key: key,
          data: item,
          onTap: item.opensAts
              ? onOpenAts
              : item.opensMerchant
              ? onOpenMerchant
              : item.opensPartner
              ? onOpenPartner
              : onOther,
        );
      },
    );
  }
}

class _LauncherMiniProgramTile extends StatelessWidget {
  const _LauncherMiniProgramTile({
    super.key,
    required this.data,
    required this.onTap,
  });

  final _LauncherMiniProgramData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: data.color.withValues(alpha: 0.28)),
            ),
            child: Icon(data.icon, color: data.color, size: 29),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewedMiniProgramCard extends StatelessWidget {
  const _ViewedMiniProgramCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 118,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 158,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF343746), Color(0xFF17181D)],
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: Icon(
                        Icons.school_outlined,
                        color: Color(0x22FFFFFF),
                        size: 100,
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 12,
                      child: Text(
                        '求职课堂',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '视频',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerBottomBar extends StatelessWidget {
  const _PickerBottomBar({required this.onSearch, required this.onMore});

  final VoidCallback onSearch;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        scheme.onSurfaceVariant;
    return Container(
      height: 60,
      color: scheme.surfaceContainer,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'RuoQi',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onSearch,
            tooltip: '搜索',
            icon: Icon(Icons.search_rounded, color: muted, size: 26),
          ),
          IconButton(
            onPressed: onMore,
            tooltip: '更多',
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: muted,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
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

class _WeChatTabBar extends StatelessWidget {
  const _WeChatTabBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        scheme.onSurfaceVariant;
    const items = [
      (Icons.chat_bubble_rounded, 'RuoQi', true),
      (Icons.contacts_outlined, '通讯录', false),
      (Icons.explore_outlined, '发现', false),
      (Icons.person_outline_rounded, '我', false),
    ];
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              for (final (icon, label, selected) in items)
                Expanded(
                  child: InkWell(
                    onTap: selected
                        ? null
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$label 为模拟入口')),
                          ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 23,
                          color: selected ? scheme.primary : muted,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: selected ? scheme.primary : muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerSearchBar extends StatelessWidget {
  const _PickerSearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                '搜索小程序',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerSectionHeader extends StatelessWidget {
  const _PickerSectionHeader({required this.title, this.trailing, this.onTap});

  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: scheme.onSurfaceVariant,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
            child: Text(trailing!),
          ),
      ],
    );
  }
}
