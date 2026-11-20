import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// DeepSeek-style icons drawn locally so stroke weight and corners stay
/// consistent across font scaling and platforms.
class DeepSeekAutoReadIcon extends StatelessWidget {
  const DeepSeekAutoReadIcon({
    super.key,
    required this.color,
    required this.muted,
    this.size = 24,
  });

  final Color color;
  final bool muted;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _DeepSeekAutoReadPainter(color: color, muted: muted),
      ),
    );
  }
}

class DeepSeekNewChatIcon extends StatelessWidget {
  const DeepSeekNewChatIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _DeepSeekNewChatPainter(color: color)),
    );
  }
}

class DeepSeekThinkingIcon extends StatelessWidget {
  const DeepSeekThinkingIcon({super.key, required this.color, this.size = 18});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _DeepSeekThinkingPainter(color: color)),
    );
  }
}

class DeepSeekVoiceIcon extends StatelessWidget {
  const DeepSeekVoiceIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _DeepSeekVoicePainter(color: color)),
    );
  }
}

class DeepSeekKeyboardIcon extends StatelessWidget {
  const DeepSeekKeyboardIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _DeepSeekKeyboardPainter(color: color)),
    );
  }
}

class DeepSeekPlusIcon extends StatelessWidget {
  const DeepSeekPlusIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _DeepSeekPlusPainter(color: color)),
    );
  }
}

class _DeepSeekAutoReadPainter extends CustomPainter {
  const _DeepSeekAutoReadPainter({required this.color, required this.muted});

  final Color color;
  final bool muted;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24;
    canvas.save();
    canvas.scale(scale, scale);
    final stroke = _stroke(color, 1.8);

    final speaker = Path()
      ..moveTo(3.5, 9.2)
      ..lineTo(6.4, 9.2)
      ..lineTo(10.5, 5.6)
      ..lineTo(10.5, 18.4)
      ..lineTo(6.4, 14.8)
      ..lineTo(3.5, 14.8)
      ..close();
    canvas.drawPath(speaker, stroke);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(10.5, 12), radius: 4.2),
      -0.66,
      1.32,
      false,
      stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(10.5, 12), radius: 7),
      -0.66,
      1.32,
      false,
      stroke,
    );
    if (muted) {
      canvas.drawLine(const Offset(4.1, 4.1), const Offset(19.8, 19.8), stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeepSeekAutoReadPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.muted != muted;
}

class _DeepSeekNewChatPainter extends CustomPainter {
  const _DeepSeekNewChatPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24;
    canvas.save();
    canvas.scale(scale, scale);
    final stroke = _stroke(color, 1.85);

    final bubble = Path()
      ..moveTo(7.1, 20.8)
      ..cubicTo(4.3, 19.1, 2.8, 16.2, 3, 12.4)
      ..cubicTo(3.2, 7.2, 7.3, 3.2, 12.2, 3.1)
      ..cubicTo(17.7, 3, 21.1, 6.9, 21.1, 12.1)
      ..cubicTo(21.1, 17.2, 17, 21.1, 11.9, 21)
      ..cubicTo(10.1, 20.9, 8.6, 20.5, 7.4, 19.8)
      ..cubicTo(7.2, 20.4, 6.9, 20.9, 6.4, 21.2)
      ..cubicTo(6.5, 20.7, 6.7, 20, 6.9, 19.4);
    canvas.drawPath(bubble, stroke);
    canvas.drawLine(const Offset(8.1, 12.1), const Offset(16.2, 12.1), stroke);
    canvas.drawLine(
      const Offset(12.15, 8.05),
      const Offset(12.15, 16.15),
      stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeepSeekNewChatPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DeepSeekThinkingPainter extends CustomPainter {
  const _DeepSeekThinkingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 20;
    canvas.save();
    canvas.scale(scale, scale);
    canvas.translate(10, 10);
    final stroke = _stroke(color, 1.65);
    final capsule = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 6.4, height: 17),
      const Radius.circular(3.2),
    );
    for (final angle in [math.pi / 4, -math.pi / 4]) {
      canvas.save();
      canvas.rotate(angle);
      canvas.drawRRect(capsule, stroke);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeepSeekThinkingPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DeepSeekVoicePainter extends CustomPainter {
  const _DeepSeekVoicePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24;
    canvas.save();
    canvas.scale(scale, scale);
    final stroke = _stroke(color, 1.9);
    canvas.drawCircle(const Offset(8.1, 12), 1.8, Paint()..color = color);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(8.1, 12), radius: 5),
      -0.72,
      1.44,
      false,
      stroke,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(8.1, 12), radius: 8.2),
      -0.72,
      1.44,
      false,
      stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeepSeekVoicePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DeepSeekKeyboardPainter extends CustomPainter {
  const _DeepSeekKeyboardPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 18;
    canvas.save();
    canvas.scale(scale, scale);
    final dotPaint = Paint()..color = color;
    for (final y in <double>[6.7, 10.2]) {
      for (final x in <double>[5.5, 9, 12.5]) {
        canvas.drawCircle(Offset(x, y), 1.05, dotPaint);
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4.7, 13.1, 8.6, 2.2),
        const Radius.circular(1.1),
      ),
      dotPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeepSeekKeyboardPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DeepSeekPlusPainter extends CustomPainter {
  const _DeepSeekPlusPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24;
    canvas.save();
    canvas.scale(scale, scale);
    final stroke = _stroke(color, 1.8);
    canvas.drawLine(const Offset(5.5, 12), const Offset(18.5, 12), stroke);
    canvas.drawLine(const Offset(12, 5.5), const Offset(12, 18.5), stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DeepSeekPlusPainter oldDelegate) =>
      oldDelegate.color != color;
}

Paint _stroke(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;
