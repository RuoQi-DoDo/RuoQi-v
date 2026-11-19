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

/// A compact line/filled whale shared by the AI tab and the welcome mark.
class AiTabIcon extends StatelessWidget {
  const AiTabIcon({
    super.key,
    required this.color,
    required this.filled,
    this.size = 24,
  });

  final Color color;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _AiTabWhalePainter(color: color, filled: filled),
      ),
    );
  }
}

class _AiTabWhalePainter extends CustomPainter {
  const _AiTabWhalePainter({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.save();
    canvas.scale(scale, scale);

    final body = Path()
      ..moveTo(1.4, 16.2)
      ..cubicTo(1.8, 12.3, 4.3, 9.1, 8.1, 7.9)
      ..cubicTo(11.2, 7, 13.4, 8.3, 15.2, 10.6)
      ..cubicTo(12.5, 13.7, 7.7, 16.1, 2.7, 17.2)
      ..cubicTo(2, 17.1, 1.6, 16.8, 1.4, 16.2)
      ..close();
    final tail = Path()
      ..moveTo(14.8, 10.3)
      ..cubicTo(17, 9.4, 17.8, 7.4, 19.8, 7.8)
      ..cubicTo(19.3, 8.9, 19.6, 9.8, 20.5, 10.7)
      ..cubicTo(22.4, 10.2, 23.2, 11.2, 23.7, 12.2)
      ..cubicTo(22, 13.9, 21.1, 15.8, 18.6, 15.4)
      ..cubicTo(17, 15.2, 15.8, 14, 15.1, 12.8)
      ..close();
    final dorsal = Path()
      ..moveTo(8.9, 8)
      ..cubicTo(8.9, 5.8, 9.8, 4, 11.8, 2.8)
      ..cubicTo(11.4, 5.2, 12.4, 7, 13.4, 8.7)
      ..close();
    final fin = Path()
      ..moveTo(9.8, 14)
      ..cubicTo(10.8, 15.5, 12.2, 16.8, 14, 17.2)
      ..cubicTo(12.6, 15.8, 11.9, 14.2, 11.8, 12.9)
      ..close();
    final shape = Path.combine(PathOperation.union, body, tail);

    if (filled) {
      canvas.drawPath(shape, Paint()..color = color);
      canvas.drawPath(dorsal, Paint()..color = color);
      canvas.drawPath(fin, Paint()..color = color);
    } else {
      final stroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.55
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(shape, stroke);
      canvas.drawPath(dorsal, stroke);
      canvas.drawPath(fin, stroke);
    }

    final eyeColor = filled ? Colors.white : color;
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(5.9, 11.4),
        width: filled ? 1.7 : 1.1,
        height: 1.2,
      ),
      Paint()..color = eyeColor,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AiTabWhalePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.filled != filled;
}
