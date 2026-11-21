import 'package:material_ui/material_ui.dart';

import '../../app_theme.dart';

abstract final class HostChromeStyle {
  static const Color lightAppBar = Color(0xFFEDEDED);
  static const Color darkAppBar = MiniAppDarkColors.background;
  static const Color lightBottomBar = Color(0xFFF7F7F7);
  static const Color darkBottomBar = MiniAppDarkColors.surface;
  static const Color lightDivider = Color(0xFFE5E5E5);
  static const Color darkDivider = MiniAppDarkColors.border;

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
  final baseTheme = miniAppTheme(brightness: brightness, accent: accent);
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
  );
}
