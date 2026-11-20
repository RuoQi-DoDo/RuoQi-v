import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../common/page_theme.dart';

/// AI conversation colors resolved from the host application's theme.
abstract final class AiColors {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static ColorScheme _scheme(BuildContext context) =>
      Theme.of(context).colorScheme;

  static Color accent(BuildContext context) => _scheme(context).primary;

  static Color onAccent(BuildContext context) => _scheme(context).onPrimary;

  static Color accentDeep(BuildContext context) {
    final accent = _scheme(context).primary;
    return Color.lerp(accent, Colors.black, isDark(context) ? 0.08 : 0.16)!;
  }

  static Color background(BuildContext context) => _scheme(context).surface;

  static Color surface(BuildContext context) {
    final scheme = _scheme(context);
    return isDark(context)
        ? scheme.surfaceContainerLow
        : scheme.surfaceContainerLowest;
  }

  static Color softSurface(BuildContext context) =>
      _scheme(context).primaryContainer;

  static Color searchSurface(BuildContext context) {
    final scheme = _scheme(context);
    return isDark(context)
        ? scheme.surfaceContainerHigh
        : scheme.surfaceContainer;
  }

  static Color text(BuildContext context) => _scheme(context).onSurface;

  static Color muted(BuildContext context) => _scheme(context).onSurfaceVariant;

  static Color hint(BuildContext context) {
    final scheme = _scheme(context);
    return Color.lerp(
      scheme.onSurfaceVariant,
      scheme.surface,
      isDark(context) ? 0.48 : 0.65,
    )!;
  }

  static Color border(BuildContext context) =>
      HostChromeStyle.dividerColor(context);

  static Color danger(BuildContext context) => _scheme(context).error;

  /// Keeps the system status bar continuous with the AI page on the first
  /// frame, instead of inheriting the launch theme or the previously shown tab.
  static SystemUiOverlayStyle systemUiOverlayStyle(BuildContext context) {
    final dark = isDark(context);
    return SystemUiOverlayStyle(
      statusBarColor: background(context),
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      systemStatusBarContrastEnforced: false,
    );
  }

  static LinearGradient brandGradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentDeep(context), accent(context)],
  );
}

/// The project's RQ loop mark, adapted from the app icon for the AI welcome.
class AiBrandMark extends StatelessWidget {
  const AiBrandMark({super.key, this.size = 104});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _AiBrandMarkPainter(
          accent: AiColors.accent(context),
          accentDeep: AiColors.accentDeep(context),
        ),
      ),
    );
  }
}

class _AiBrandMarkPainter extends CustomPainter {
  const _AiBrandMarkPainter({required this.accent, required this.accentDeep});

  final Color accent;
  final Color accentDeep;

  @override
  void paint(Canvas canvas, Size size) {
    final source = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(386, 264)
      ..lineTo(518, 264)
      ..cubicTo(662, 264, 768, 363, 768, 502)
      ..cubicTo(768, 564, 744, 621, 704, 663)
      ..lineTo(786, 745)
      ..lineTo(716, 815)
      ..lineTo(618, 717)
      ..cubicTo(588, 728, 554, 734, 518, 734)
      ..lineTo(386, 734)
      ..cubicTo(300, 734, 244, 679, 244, 593)
      ..lineTo(244, 406)
      ..cubicTo(244, 320, 300, 264, 386, 264)
      ..close()
      ..moveTo(394, 362)
      ..cubicTo(362, 362, 342, 382, 342, 414)
      ..lineTo(342, 526)
      ..lineTo(430, 526)
      ..lineTo(526, 636)
      ..cubicTo(610, 632, 666, 580, 666, 502)
      ..cubicTo(666, 418, 607, 362, 518, 362)
      ..lineTo(394, 362)
      ..close();

    final bounds = source.getBounds();
    final inset = size.shortestSide * 0.04;
    final scale = math.min(
      (size.width - inset * 2) / bounds.width,
      (size.height - inset * 2) / bounds.height,
    );
    final matrix = Matrix4.identity()
      ..translateByDouble(
        (size.width - bounds.width * scale) / 2 - bounds.left * scale,
        (size.height - bounds.height * scale) / 2 - bounds.top * scale,
        0,
        1,
      )
      ..scaleByDouble(scale, scale, 1, 1);
    final mark = source.transform(matrix.storage)
      ..fillType = PathFillType.evenOdd;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accentDeep, accent],
      ).createShader(Offset.zero & size);

    canvas.drawPath(mark, paint);
  }

  @override
  bool shouldRepaint(covariant _AiBrandMarkPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.accentDeep != accentDeep;
}
