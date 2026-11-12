import 'package:flutter/material.dart';

import 'widgets/miniapp_actions_sheet.dart';
import 'widgets/miniapp_navigation_bar.dart';
import 'widgets/miniapp_swipe_exit.dart';

/// 通用业务小程序壳。
///
/// 商户和伙伴页面作为全屏子视图打开，保留公共小程序导航栏、内部页面栈
/// 和底部上滑退出，不使用 Dialog。
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
    final scheme = Theme.of(context).colorScheme;
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
              MiniProgramNavigationBar(
                title: widget.title,
                canGoBack: _canGoBack,
                onBack: _back,
                onMore: _showMore,
                onClose: _close,
                backgroundColor: scheme.surface,
                foregroundColor: scheme.onSurface,
                borderColor: scheme.outlineVariant,
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
              MiniProgramExitHandle(onExit: _close),
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
