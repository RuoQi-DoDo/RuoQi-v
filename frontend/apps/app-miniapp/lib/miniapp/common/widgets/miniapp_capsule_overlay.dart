import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../miniapp_pin.dart';
import 'miniapp_capsule.dart';

/// The only shared chrome that stays fixed inside a mini-program page.
///
/// Mini-programs own their title bars, heroes, and back navigation. The host
/// only anchors this capsule in the top-right safe corner.
class MiniProgramCapsuleOverlay extends StatelessWidget {
  const MiniProgramCapsuleOverlay({
    super.key,
    this.miniProgramId,
    required this.onMore,
    required this.onClose,
  });

  static const double reservedRight = 112;
  static const double reservedHeight = 42;

  final String? miniProgramId;
  final VoidCallback onMore;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final pinController = MiniProgramPinScope.maybeOf(context);
    final canTogglePin =
        miniProgramId != null &&
        pinController != null &&
        pinController.isInitialized;
    final isPinned =
        miniProgramId != null &&
        (pinController?.isPinned(miniProgramId!) ?? false);
    return MiniProgramCapsule(
      onMore: onMore,
      onClose: onClose,
      isPinned: isPinned,
      onLongPressClose: canTogglePin
          ? () {
              unawaited(HapticFeedback.mediumImpact());
              unawaited(pinController.togglePin(miniProgramId!));
            }
          : null,
    );
  }
}
