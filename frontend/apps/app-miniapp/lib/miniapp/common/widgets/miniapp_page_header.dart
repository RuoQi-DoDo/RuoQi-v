import 'package:flutter/material.dart';

import '../miniapp_localizations.dart';
import 'miniapp_capsule_overlay.dart';

/// Mini-program-owned lightweight page header.
///
/// This is intentionally not part of the shared fixed navigation bar. Each
/// mini-program provides its own colors and leading content while leaving the
/// top-right capsule area untouched.
class MiniProgramPageHeader extends StatelessWidget {
  const MiniProgramPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.leading,
    this.foregroundColor,
    this.height = 46,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? leading;
  final Color? foregroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final foreground =
        foregroundColor ?? Theme.of(context).colorScheme.onSurface;
    final left = onBack != null
        ? IconButton(
            tooltip: localizeMiniProgramLabel(context, '返回'),
            onPressed: onBack,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: foreground,
            ),
          )
        : leading;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          6,
          0,
          MiniProgramCapsuleOverlay.reservedRight,
          0,
        ),
        child: Row(
          children: [
            if (left != null) ...[left, const SizedBox(width: 4)],
            Expanded(
              child: Text(
                localizeMiniProgramLabel(context, title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
