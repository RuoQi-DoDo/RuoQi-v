import '../miniapp_localizations.dart';

import 'package:flutter/material.dart';

/// 包裹小程序底部区域，提供统一的上滑退出手势。
class MiniProgramSwipeExitRegion extends StatefulWidget {
  const MiniProgramSwipeExitRegion({
    super.key,
    required this.onExit,
    required this.child,
    this.semanticsLabel = '底部上滑离开小程序',
    this.upwardDistance = 48,
    this.upwardVelocity = -280,
  });

  final VoidCallback onExit;
  final Widget child;
  final String semanticsLabel;
  final double upwardDistance;
  final double upwardVelocity;

  @override
  State<MiniProgramSwipeExitRegion> createState() =>
      _MiniProgramSwipeExitRegionState();
}

class _MiniProgramSwipeExitRegionState
    extends State<MiniProgramSwipeExitRegion> {
  double _distance = 0;
  bool _exitTriggered = false;

  void _reset() {
    _distance = 0;
    _exitTriggered = false;
  }

  void _completeExit() {
    if (_exitTriggered) {
      return;
    }
    _exitTriggered = true;
    widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: localizeMiniProgramLabel(context, widget.semanticsLabel),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (_) => _reset(),
        onVerticalDragUpdate: (details) {
          if (_exitTriggered) {
            return;
          }
          if (details.delta.dy < 0) {
            _distance -= details.delta.dy;
          }
          if (_distance >= widget.upwardDistance) {
            _completeExit();
          }
        },
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < widget.upwardVelocity) {
            _completeExit();
          }
          _reset();
        },
        onVerticalDragCancel: _reset,
        child: widget.child,
      ),
    );
  }
}

/// 小程序底部统一的退出拖拽条。
class MiniProgramExitHandle extends StatelessWidget {
  const MiniProgramExitHandle({
    super.key,
    required this.onExit,
    this.backgroundColor,
    this.handleColor,
    this.handleWidth = 110,
    this.minimumHeight = 14,
  });

  final VoidCallback onExit;
  final Color? backgroundColor;
  final Color? handleColor;
  final double handleWidth;
  final double minimumHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return MiniProgramSwipeExitRegion(
      key: const Key('generic-mini-program-exit-swipe'),
      onExit: onExit,
      child: Container(
        height: bottomInset > 0 ? bottomInset : minimumHeight,
        color: backgroundColor ?? scheme.surface,
        alignment: Alignment.center,
        child: Container(
          width: handleWidth,
          height: 4,
          decoration: BoxDecoration(
            color: handleColor ?? scheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
