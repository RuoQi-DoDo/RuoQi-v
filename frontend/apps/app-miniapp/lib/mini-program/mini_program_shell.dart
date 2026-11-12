import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 通用业务小程序壳。
///
/// 商户和伙伴页面作为全屏子视图打开，保留公共 [MiniProgramCapsule]、
/// 内部页面栈和底部上滑退出，不使用 Dialog。
class MiniProgramShell extends StatefulWidget {
  const MiniProgramShell({
    super.key,
    required this.title,
    required this.child,
    this.icon = Icons.apps_rounded,
  });

  final String title;
  final Widget child;
  final IconData icon;

  static Route<void> route({
    required String title,
    required Widget child,
    IconData icon = Icons.apps_rounded,
  }) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return MiniProgramShell(title: title, icon: icon, child: child);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  @override
  State<MiniProgramShell> createState() => _MiniProgramShellState();
}

class _MiniProgramShellState extends State<MiniProgramShell> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _canGoBack = false;

  void _close() {
    Navigator.of(context).pop();
  }

  void _back() {
    if (_navigatorKey.currentState?.canPop() ?? false) {
      _navigatorKey.currentState!.pop();
    }
  }

  void _refreshNavigationDepth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final canGoBack = _navigatorKey.currentState?.canPop() ?? false;
      if (canGoBack != _canGoBack) {
        setState(() => _canGoBack = canGoBack);
      }
    });
  }

  void _showMore() {
    showMiniProgramActionsSheet(
      context,
      title: widget.title,
      subtitle: 'RuoQi 业务小程序',
      icon: widget.icon,
      onRestart: () {
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (_navigatorKey.currentState?.canPop() ?? false) {
          _back();
        } else {
          _close();
        }
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(
                    bottom: BorderSide(color: scheme.outlineVariant),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _canGoBack
                          ? IconButton(
                              tooltip: '返回',
                              onPressed: _back,
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                              ),
                            )
                          : const SizedBox(width: 40),
                    ),
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MiniProgramCapsule(
                        onMore: _showMore,
                        onClose: _close,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Navigator(
                  key: _navigatorKey,
                  observers: [
                    _MiniProgramNavigatorObserver(_refreshNavigationDepth),
                  ],
                  onGenerateRoute: (settings) {
                    return MaterialPageRoute<void>(
                      settings: settings,
                      builder: (_) => widget.child,
                    );
                  },
                ),
              ),
              _MiniProgramSwipeExit(onExit: _close),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniProgramNavigatorObserver extends NavigatorObserver {
  _MiniProgramNavigatorObserver(this.onChanged);

  final VoidCallback onChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onChanged();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onChanged();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onChanged();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    onChanged();
  }
}

/// 微信式小程序公共胶囊。
///
/// 胶囊固定在小程序导航栏右上角，所有业务小程序复用同一布局、尺寸和交互。
/// 使用半透明白色底，保证图标在图片和彩色背景上都能保持可读。
class MiniProgramCapsule extends StatelessWidget {
  const MiniProgramCapsule({
    super.key,
    required this.onMore,
    required this.onClose,
  });

  static const double width = 94;
  static const double height = 32;
  static const Color surfaceColor = Color(0x99FFFFFF);
  static const Color borderColor = Color(0x1A000000);
  static const Color foregroundColor = Color(0xFF111111);

  final VoidCallback onMore;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          color: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
            side: const BorderSide(color: borderColor, width: 0.6),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Expanded(
                child: _MiniProgramCapsuleAction(
                  tooltip: '小程序菜单',
                  onTap: onMore,
                  child: const _MiniProgramMoreIcon(color: foregroundColor),
                ),
              ),
              SizedBox(
                width: 0.6,
                height: 21,
                child: ColoredBox(color: borderColor),
              ),
              Expanded(
                child: _MiniProgramCapsuleAction(
                  tooltip: '退出小程序',
                  onTap: onClose,
                  child: Center(
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: foregroundColor, width: 2.2),
                      ),
                      child: Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: foregroundColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
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

class _MiniProgramMoreIcon extends StatelessWidget {
  const _MiniProgramMoreIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 17,
      height: 12,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CapsuleDot(size: 2.5, color: color),
            const SizedBox(width: 3.2),
            _CapsuleDot(size: 4.5, color: color),
            const SizedBox(width: 3.2),
            _CapsuleDot(size: 2.5, color: color),
          ],
        ),
      ),
    );
  }
}

class _CapsuleDot extends StatelessWidget {
  const _CapsuleDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _MiniProgramCapsuleAction extends StatelessWidget {
  const _MiniProgramCapsuleAction({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// 微信小程序右上角三点操作面板。
///
/// 交互和分组参考微信真机：顶部为当前小程序，随后是转发联系人、
/// 两行功能入口和底部取消按钮。
const _miniProgramSheetColor = Color(0xFF1E1E1E);
const _miniProgramHeaderColor = Color(0xFF191919);
const _miniProgramTileColor = Color(0xFF292929);
const _miniProgramDividerColor = Color(0xFF2D2D2D);
const _miniProgramPrimaryText = Color(0xFFFFFFFF);
const _miniProgramSecondaryText = Color(0xFF8F8F8F);
const _miniProgramDisabledText = Color(0xFF5C5C5C);
const _miniProgramCancelText = Color(0xFF708AA6);

Future<void> showMiniProgramActionsSheet(
  BuildContext context, {
  required String title,
  required IconData icon,
  String subtitle = '微信小程序',
  VoidCallback? onRestart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.58),
    isScrollControlled: true,
    builder: (context) {
      final height = MediaQuery.sizeOf(context).height;
      return SizedBox(
        height: height * 0.679,
        child: _MiniProgramActionsSheet(
          title: title,
          subtitle: subtitle,
          icon: icon,
          onRestart: onRestart,
        ),
      );
    },
  );
}

class _MiniProgramActionsSheet extends StatefulWidget {
  const _MiniProgramActionsSheet({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onRestart,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onRestart;

  @override
  State<_MiniProgramActionsSheet> createState() =>
      _MiniProgramActionsSheetState();
}

class _MiniProgramActionsSheetState extends State<_MiniProgramActionsSheet> {
  bool _starred = false;
  bool _favorited = false;
  bool _added = false;

  void _close() => Navigator.of(context).pop();

  void _showFeedback(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    _close();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(
      ClipboardData(text: 'https://miniapp.weixin.qq.com/${widget.title}'),
    );
    if (!mounted) {
      return;
    }
    _showFeedback('链接已复制');
  }

  void _showSettings() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(widget.title),
          content: Text(widget.subtitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  void _restart() {
    _close();
    widget.onRestart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final actions = <_MiniProgramActionData>[
      _MiniProgramActionData(
        label: '转发给朋友',
        icon: Icons.turn_right_rounded,
        color: const Color(0xFF07C160),
        onTap: () => _showFeedback('已打开转发面板'),
      ),
      const _MiniProgramActionData(
        label: '分享到朋友圈',
        icon: Icons.camera_alt_outlined,
        color: Color(0xFFB7B7B7),
        enabled: false,
      ),
      _MiniProgramActionData(
        label: _starred ? '取消星标' : '星标',
        icon: _starred ? Icons.star_rounded : Icons.star_border_rounded,
        color: const Color(0xFF3D9BFF),
        onTap: () => setState(() => _starred = !_starred),
      ),
      _MiniProgramActionData(
        label: _favorited ? '已收藏' : '收藏',
        icon: _favorited ? Icons.bookmark_rounded : Icons.widgets_outlined,
        color: const Color(0xFFFFB800),
        onTap: () => setState(() => _favorited = !_favorited),
      ),
      _MiniProgramActionData(
        label: _added ? '已添加' : '添加到\n我的小程序',
        icon: _added ? Icons.check_circle_rounded : Icons.apps_rounded,
        color: const Color(0xFFFFC400),
        onTap: () => setState(() => _added = !_added),
      ),
      _MiniProgramActionData(
        label: '在电脑上\n打开',
        icon: Icons.computer_outlined,
        color: _miniProgramPrimaryText,
        onTap: () => _showFeedback('已打开电脑端入口'),
      ),
      _MiniProgramActionData(
        label: '浮窗',
        icon: Icons.picture_in_picture_alt_outlined,
        color: _miniProgramPrimaryText,
        onTap: () => _showFeedback('已开启浮窗'),
      ),
      _MiniProgramActionData(
        label: '设置',
        icon: Icons.settings_outlined,
        color: _miniProgramPrimaryText,
        onTap: _showSettings,
      ),
      _MiniProgramActionData(
        label: '反馈与投诉',
        icon: Icons.report_problem_outlined,
        color: _miniProgramPrimaryText,
        onTap: () => _showFeedback('已打开反馈入口'),
      ),
      _MiniProgramActionData(
        label: '重新进入\n小程序',
        icon: Icons.restart_alt_rounded,
        color: _miniProgramPrimaryText,
        onTap: _restart,
      ),
      _MiniProgramActionData(
        label: '复制链接',
        icon: Icons.link_rounded,
        color: _miniProgramPrimaryText,
        onTap: _copyLink,
      ),
    ];

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: Material(
        color: _miniProgramSheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(
                height: 75,
                child: ColoredBox(
                  color: _miniProgramHeaderColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _miniProgramTileColor,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Icon(
                            widget.icon,
                            color: const Color(0xFF07C160),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _miniProgramPrimaryText,
                                  fontSize: 15,
                                  height: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _miniProgramSecondaryText,
                                  fontSize: 11,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _miniProgramSecondaryText,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
                        child: Text(
                          '转发给',
                          style: TextStyle(
                            color: _miniProgramPrimaryText,
                            fontSize: 15,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 104,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(left: 12),
                          scrollDirection: Axis.horizontal,
                          itemCount: _shareTargets.length,
                          itemBuilder: (context, index) {
                            final target = _shareTargets[index];
                            return _MiniProgramShareTarget(
                              target: target,
                              onTap: () => _showFeedback('已选择 ${target.name}'),
                            );
                          },
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: _miniProgramDividerColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
                        child: _MiniProgramActionRows(
                          firstRow: actions.take(6).toList(),
                          secondRow: actions.skip(6).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: _miniProgramDividerColor,
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: _close,
                  style: TextButton.styleFrom(
                    foregroundColor: _miniProgramCancelText,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    '取消',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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

class _MiniProgramActionData {
  const _MiniProgramActionData({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;
}

class _MiniProgramActionRows extends StatelessWidget {
  const _MiniProgramActionRows({
    required this.firstRow,
    required this.secondRow,
  });

  final List<_MiniProgramActionData> firstRow;
  final List<_MiniProgramActionData> secondRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MiniProgramActionRow(actions: firstRow),
        const SizedBox(height: 10),
        _MiniProgramActionRow(actions: secondRow),
      ],
    );
  }
}

class _MiniProgramActionRow extends StatelessWidget {
  const _MiniProgramActionRow({required this.actions});

  final List<_MiniProgramActionData> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 99,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return _MiniProgramActionTile(action: actions[index]);
        },
      ),
    );
  }
}

class _MiniProgramActionTile extends StatelessWidget {
  const _MiniProgramActionTile({required this.action});

  final _MiniProgramActionData action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: action.enabled,
      enabled: action.enabled,
      label: action.label.replaceAll('\n', ''),
      child: SizedBox(
        width: 68,
        child: InkWell(
          onTap: action.enabled ? action.onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _miniProgramTileColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: 27),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: SizedBox(
                  width: 68,
                  child: Text(
                    action.label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1.2,
                      fontSize: 11,
                      color: action.enabled
                          ? _miniProgramPrimaryText
                          : _miniProgramDisabledText,
                    ),
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

class _MiniProgramShareTarget extends StatelessWidget {
  const _MiniProgramShareTarget({required this.target, required this.onTap});

  final _MiniProgramShareTargetData target;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: target.colors,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(target.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 11),
            SizedBox(
              width: 68,
              child: Text(
                target.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _miniProgramSecondaryText,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniProgramShareTargetData {
  const _MiniProgramShareTargetData({
    required this.name,
    required this.icon,
    required this.colors,
  });

  final String name;
  final IconData icon;
  final List<Color> colors;
}

const _shareTargets = <_MiniProgramShareTargetData>[
  _MiniProgramShareTargetData(
    name: '文件传输助手',
    icon: Icons.folder_rounded,
    colors: [Color(0xFF67C23A), Color(0xFF3AA846)],
  ),
  _MiniProgramShareTargetData(
    name: '设计群',
    icon: Icons.groups_rounded,
    colors: [Color(0xFFFF9A62), Color(0xFFE65B67)],
  ),
  _MiniProgramShareTargetData(
    name: '林知夏',
    icon: Icons.person_rounded,
    colors: [Color(0xFF68B7FF), Color(0xFF4779E8)],
  ),
  _MiniProgramShareTargetData(
    name: '运营群',
    icon: Icons.forum_rounded,
    colors: [Color(0xFF9A7BFF), Color(0xFF6B59D9)],
  ),
  _MiniProgramShareTargetData(
    name: 'Jengro Woo',
    icon: Icons.person_outline_rounded,
    colors: [Color(0xFF55D6B8), Color(0xFF2A9D8F)],
  ),
];

class _MiniProgramSwipeExit extends StatefulWidget {
  const _MiniProgramSwipeExit({required this.onExit});

  final VoidCallback onExit;

  @override
  State<_MiniProgramSwipeExit> createState() => _MiniProgramSwipeExitState();
}

class _MiniProgramSwipeExitState extends State<_MiniProgramSwipeExit> {
  double _upwardDistance = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return GestureDetector(
      key: const Key('generic-mini-program-exit-swipe'),
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (_) => _upwardDistance = 0,
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < 0) {
          _upwardDistance -= details.delta.dy;
        }
        if (_upwardDistance >= 48) {
          _upwardDistance = 0;
          widget.onExit();
        }
      },
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < -280) {
          widget.onExit();
        }
        _upwardDistance = 0;
      },
      child: Container(
        height: bottomInset > 0 ? bottomInset : 14,
        color: scheme.surface,
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
    );
  }
}
