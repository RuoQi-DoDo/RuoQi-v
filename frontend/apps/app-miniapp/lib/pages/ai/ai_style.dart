import 'package:material_ui/material_ui.dart';

/// DeepSeek-inspired blue palette for the AI conversation surface.
abstract final class AiColors {
  static const accent = Color(0xFF4D6BFE);
  static const accentDeep = Color(0xFF6B4EFF);
  static const lightBackground = Color(0xFFFFFFFF);
  static const darkBackground = Color(0xFF101116);
  static const lightSurface = Color(0xFFFFFFFF);
  static const darkSurface = Color(0xFF191B22);
  static const lightSoftSurface = Color(0xFFF0F3FF);
  static const darkSoftSurface = Color(0xFF1D2238);
  static const lightSearchSurface = Color(0xFFF5F5F6);
  static const darkSearchSurface = Color(0xFF24262D);
  static const lightText = Color(0xFF181A20);
  static const darkText = Color(0xFFF4F5F8);
  static const lightMuted = Color(0xFF697083);
  static const darkMuted = Color(0xFF9BA3B4);
  static const lightHint = Color(0xFFC6C9D0);
  static const darkHint = Color(0xFF666D7D);
  static const lightBorder = Color(0xFFE6E9F0);
  static const darkBorder = Color(0xFF2B2E37);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color background(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color softSurface(BuildContext context) =>
      isDark(context) ? darkSoftSurface : lightSoftSurface;

  static Color searchSurface(BuildContext context) =>
      isDark(context) ? darkSearchSurface : lightSearchSurface;

  static Color text(BuildContext context) =>
      isDark(context) ? darkText : lightText;

  static Color muted(BuildContext context) =>
      isDark(context) ? darkMuted : lightMuted;

  static Color hint(BuildContext context) =>
      isDark(context) ? darkHint : lightHint;

  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentDeep, accent],
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
