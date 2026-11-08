import 'package:flutter/material.dart';

/// 通用业务小程序壳。
///
/// 商户和伙伴页面作为全屏子视图打开，保留微信式胶囊、内部页面栈和
/// 底部上滑退出，不使用 Dialog。
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
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.replay_rounded),
                  title: const Text('重新进入小程序'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _navigatorKey.currentState?.popUntil(
                      (route) => route.isFirst,
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('小程序信息'),
                  subtitle: Text(widget.title),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
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
                      child: _MiniProgramCapsule(
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

class _MiniProgramCapsule extends StatelessWidget {
  const _MiniProgramCapsule({required this.onMore, required this.onClose});

  final VoidCallback onMore;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = scheme.onSurface;
    return Container(
      width: 84,
      height: 30,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: '小程序菜单',
              child: InkWell(
                onTap: onMore,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(99),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: foreground,
                  size: 19,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 15, color: scheme.outlineVariant),
          Expanded(
            child: Tooltip(
              message: '退出小程序',
              child: InkWell(
                onTap: onClose,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(99),
                ),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: foreground, width: 1.7),
                    ),
                    child: Center(
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: foreground,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
