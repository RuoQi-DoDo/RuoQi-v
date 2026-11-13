import 'package:common/common.dart';
import 'package:flutter/material.dart';

ThemeData sharedPageTheme(BuildContext context) {
  final accent = Theme.of(context).colorScheme.primary;
  final brightness = Theme.of(context).brightness;
  final baseTheme = ruoQiTheme(
    brightness: brightness,
    accent: accent,
    mobile: true,
  );
  if (brightness == Brightness.light) {
    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFEDEDED),
      colorScheme: baseTheme.colorScheme.copyWith(
        surface: const Color(0xFFEDEDED),
        surfaceContainerLowest: const Color(0xFFF7F7F7),
        surfaceContainerLow: Colors.white,
        surfaceContainer: Colors.white,
        surfaceContainerHigh: const Color(0xFFF2F2F2),
        onSurface: const Color(0xFF111111),
        onSurfaceVariant: const Color(0xFF707070),
        outlineVariant: const Color(0xFFDEDEDE),
      ),
    );
  }
  return baseTheme.copyWith(
    scaffoldBackgroundColor: const Color(0xFF181818),
    colorScheme: baseTheme.colorScheme.copyWith(
      surface: const Color(0xFF181818),
      surfaceContainerLowest: const Color(0xFF181818),
      surfaceContainerLow: const Color(0xFF222222),
      surfaceContainer: const Color(0xFF242424),
      surfaceContainerHigh: const Color(0xFF282828),
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFA8A8A8),
      outlineVariant: const Color(0xFF303030),
    ),
  );
}
