import '../miniapp_localizations.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../miniapp_pin.dart';
import 'miniapp_capsule.dart';

/// 小程序统一顶部导航栏。
///
/// 业务小程序只需提供颜色和左侧内容，返回按钮、标题布局及右上角胶囊
/// 由公共层统一维护。
class MiniProgramNavigationBar extends StatelessWidget {
  const MiniProgramNavigationBar({
    super.key,
    required this.title,
    required this.onMore,
    required this.onClose,
    this.miniProgramId,
    this.canGoBack = false,
    this.onBack,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.titleStyle,
    this.height = 48,
    this.horizontalPadding = 10,
    this.backIconSize = 20,
  }) : assert(!canGoBack || onBack != null);

  final String title;
  final VoidCallback onMore;
  final VoidCallback onClose;
  final String? miniProgramId;
  final bool canGoBack;
  final VoidCallback? onBack;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final TextStyle? titleStyle;
  final double height;
  final double horizontalPadding;
  final double backIconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = foregroundColor ?? scheme.onSurface;
    final background = backgroundColor ?? scheme.surface;
    final divider = borderColor ?? scheme.outlineVariant;
    final pinController = MiniProgramPinScope.maybeOf(context);
    final canTogglePin =
        miniProgramId != null &&
        pinController != null &&
        pinController.isInitialized;
    final isPinned =
        miniProgramId != null &&
        (pinController?.isPinned(miniProgramId!) ?? false);

    final Widget left;
    if (leading != null) {
      left = leading!;
    } else if (canGoBack) {
      left = IconButton(
        tooltip: localizeMiniProgramLabel(context, '返回'),
        onPressed: onBack,
        visualDensity: VisualDensity.compact,
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: foreground,
          size: backIconSize,
        ),
      );
    } else {
      left = const SizedBox(width: 40);
    }

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: background,
        border: Border(bottom: BorderSide(color: divider)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(alignment: Alignment.centerLeft, child: left),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 102),
            child: Text(
              localizeMiniProgramLabel(context, title),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  titleStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: MiniProgramCapsule(
              onMore: onMore,
              onClose: onClose,
              isPinned: isPinned,
              onLongPressClose: canTogglePin
                  ? () {
                      unawaited(HapticFeedback.mediumImpact());
                      unawaited(pinController.togglePin(miniProgramId!));
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
