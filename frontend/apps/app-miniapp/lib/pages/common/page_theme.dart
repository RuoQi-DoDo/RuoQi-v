import 'package:common/common.dart';
import 'package:flutter/material.dart';

abstract final class HostChromeStyle {
  static const Color lightAppBar = Color(0xFFEDEDED);
  static const Color darkAppBar = Color(0xFF111111);
  static const Color lightBottomBar = Color(0xFFF7F7F7);
  static const Color darkBottomBar = Color(0xFF1E1E1E);
  static const Color lightDivider = Color(0xFFE5E5E5);
  static const Color darkDivider = Color(0xFF303030);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color appBarBackground(BuildContext context) =>
      _isDark(context) ? darkAppBar : lightAppBar;

  static Color bottomBarBackground(BuildContext context) =>
      _isDark(context) ? darkBottomBar : lightBottomBar;

  static Color dividerColor(BuildContext context) =>
      _isDark(context) ? darkDivider : lightDivider;

  static double hairline(BuildContext context) =>
      1 / MediaQuery.devicePixelRatioOf(context);

  static BorderSide appBarDivider(BuildContext context) =>
      BorderSide(color: dividerColor(context), width: hairline(context));
}

abstract final class HostTypography {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight emphasis = FontWeight.w600;
  static const FontWeight strong = FontWeight.w700;

  static const double listTitle = 15;
  static const double sectionTitle = 13;
  static const double pageTitle = 20;
}

ThemeData sharedPageTheme(BuildContext context) {
  final accent = Theme.of(context).colorScheme.primary;
  final brightness = Theme.of(context).brightness;
  final hairline = HostChromeStyle.hairline(context);
  final baseTheme = ruoQiTheme(
    brightness: brightness,
    accent: accent,
    mobile: true,
  );
  if (brightness == Brightness.light) {
    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFEDEDED),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: HostChromeStyle.lightAppBar,
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(
            color: HostChromeStyle.lightDivider,
            width: hairline,
          ),
        ),
      ),
      dividerTheme: baseTheme.dividerTheme.copyWith(
        color: HostChromeStyle.lightDivider,
        thickness: hairline,
        space: hairline,
      ),
      colorScheme: baseTheme.colorScheme.copyWith(
        surface: const Color(0xFFEDEDED),
        surfaceContainerLowest: const Color(0xFFF7F7F7),
        surfaceContainerLow: Colors.white,
        surfaceContainer: Colors.white,
        surfaceContainerHigh: const Color(0xFFF2F2F2),
        onSurface: const Color(0xFF111111),
        onSurfaceVariant: const Color(0xFF707070),
        outlineVariant: HostChromeStyle.lightDivider,
      ),
    );
  }
  return baseTheme.copyWith(
    scaffoldBackgroundColor: const Color(0xFF181818),
    appBarTheme: baseTheme.appBarTheme.copyWith(
      backgroundColor: HostChromeStyle.darkAppBar,
      surfaceTintColor: Colors.transparent,
      shape: Border(
        bottom: BorderSide(color: HostChromeStyle.darkDivider, width: hairline),
      ),
    ),
    dividerTheme: baseTheme.dividerTheme.copyWith(
      color: HostChromeStyle.darkDivider,
      thickness: hairline,
      space: hairline,
    ),
    colorScheme: baseTheme.colorScheme.copyWith(
      surface: const Color(0xFF181818),
      surfaceContainerLowest: const Color(0xFF181818),
      surfaceContainerLow: const Color(0xFF222222),
      surfaceContainer: const Color(0xFF242424),
      surfaceContainerHigh: const Color(0xFF282828),
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFA8A8A8),
      outlineVariant: HostChromeStyle.darkDivider,
    ),
  );
}
