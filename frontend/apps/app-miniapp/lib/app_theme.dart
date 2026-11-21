import 'package:common/common.dart';
import 'package:material_ui/material_ui.dart';

/// Shared dark palette for every surface owned by the mini-app shell.
///
/// Long-form pages, settings, conversation surfaces, and navigation all use
/// the same graphite hierarchy so dark mode remains continuous while moving
/// between the host, AI, and shared pages.
abstract final class MiniAppDarkColors {
  static const Color background = Color(0xFF18191C);
  static const Color surface = Color(0xFF202226);
  static const Color surfaceMuted = Color(0xFF26282D);
  static const Color surfaceHigh = Color(0xFF292B30);
  static const Color text = Color(0xFFE6E8EB);
  static const Color muted = Color(0xFFA6AAB1);
  static const Color hint = Color(0xFF81858D);
  static const Color border = Color(0xFF32353B);
  static const Color outline = Color(0xFF454850);
}

/// Applies the mini-app's shared palette on top of the RuoQi design tokens.
///
/// Light mode keeps the existing design-system theme. Dark mode replaces the
/// near-black global canvas with a softer graphite hierarchy and propagates it
/// through both Material roles and component themes.
ThemeData miniAppTheme({
  Brightness brightness = Brightness.light,
  Color? accent,
}) {
  final base = ruoQiTheme(brightness: brightness, accent: accent, mobile: true);
  if (brightness == Brightness.light) {
    return base;
  }

  final scheme = base.colorScheme.copyWith(
    surface: MiniAppDarkColors.background,
    surfaceDim: MiniAppDarkColors.surface,
    surfaceBright: MiniAppDarkColors.surfaceHigh,
    surfaceContainerLowest: MiniAppDarkColors.background,
    surfaceContainerLow: MiniAppDarkColors.surface,
    surfaceContainer: MiniAppDarkColors.surfaceMuted,
    surfaceContainerHigh: MiniAppDarkColors.surfaceHigh,
    surfaceContainerHighest: MiniAppDarkColors.surfaceHigh,
    onSurface: MiniAppDarkColors.text,
    onSurfaceVariant: MiniAppDarkColors.muted,
    outlineVariant: MiniAppDarkColors.border,
    outline: MiniAppDarkColors.outline,
  );
  final textTheme = base.textTheme.apply(
    bodyColor: MiniAppDarkColors.text,
    displayColor: MiniAppDarkColors.text,
  );
  final extension = base.extension<RuQiThemeExtension>()?.copyWith(
    surface3: MiniAppDarkColors.surfaceMuted,
    surface4: MiniAppDarkColors.surfaceHigh,
    hairlineStrong: MiniAppDarkColors.outline,
    hairlineInput: MiniAppDarkColors.outline,
    canvasSoft: MiniAppDarkColors.surface,
    inkMuted: MiniAppDarkColors.muted,
    inkTertiary: MiniAppDarkColors.hint,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: MiniAppDarkColors.background,
    canvasColor: MiniAppDarkColors.background,
    cardColor: MiniAppDarkColors.surface,
    dividerColor: MiniAppDarkColors.border,
    hintColor: MiniAppDarkColors.hint,
    focusColor: MiniAppDarkColors.surfaceHigh,
    hoverColor: MiniAppDarkColors.surfaceHigh,
    highlightColor: MiniAppDarkColors.surfaceMuted,
    primaryColor: scheme.primary,
    textTheme: textTheme,
    primaryTextTheme: base.primaryTextTheme.apply(
      bodyColor: MiniAppDarkColors.text,
      displayColor: MiniAppDarkColors.text,
    ),
    iconTheme: base.iconTheme.copyWith(color: MiniAppDarkColors.muted),
    primaryIconTheme: base.primaryIconTheme.copyWith(
      color: MiniAppDarkColors.text,
    ),
    extensions: extension == null ? null : [extension],
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: MiniAppDarkColors.background,
      foregroundColor: MiniAppDarkColors.text,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: MiniAppDarkColors.text,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomAppBarTheme: base.bottomAppBarTheme.copyWith(
      color: MiniAppDarkColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
      backgroundColor: MiniAppDarkColors.surface,
      selectedItemColor: scheme.primary,
      unselectedItemColor: MiniAppDarkColors.muted,
    ),
    bottomSheetTheme: base.bottomSheetTheme.copyWith(
      backgroundColor: MiniAppDarkColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: base.cardTheme.copyWith(
      color: MiniAppDarkColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: MiniAppDarkColors.border),
      ),
    ),
    dialogTheme: base.dialogTheme.copyWith(
      backgroundColor: MiniAppDarkColors.surface,
      surfaceTintColor: Colors.transparent,
      contentTextStyle: textTheme.bodyMedium,
    ),
    drawerTheme: base.drawerTheme.copyWith(
      backgroundColor: MiniAppDarkColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: base.dividerTheme.copyWith(
      color: MiniAppDarkColors.border,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      fillColor: MiniAppDarkColors.surfaceMuted,
      hintStyle: const TextStyle(color: MiniAppDarkColors.hint),
      labelStyle: const TextStyle(color: MiniAppDarkColors.muted),
      floatingLabelStyle: const TextStyle(color: MiniAppDarkColors.muted),
      prefixIconColor: MiniAppDarkColors.muted,
      suffixIconColor: MiniAppDarkColors.muted,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        borderSide: BorderSide(color: MiniAppDarkColors.border),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        borderSide: BorderSide(color: MiniAppDarkColors.border),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        borderSide: BorderSide(color: MiniAppDarkColors.outline, width: 1.5),
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        borderSide: BorderSide(color: MiniAppDarkColors.border),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: MiniAppDarkColors.surface,
      selectedColor: MiniAppDarkColors.surfaceHigh,
      labelStyle: const TextStyle(color: MiniAppDarkColors.muted),
      secondaryLabelStyle: const TextStyle(color: MiniAppDarkColors.muted),
      side: const BorderSide(color: MiniAppDarkColors.border),
    ),
    listTileTheme: base.listTileTheme.copyWith(
      iconColor: MiniAppDarkColors.muted,
      textColor: MiniAppDarkColors.text,
    ),
    popupMenuTheme: base.popupMenuTheme.copyWith(
      color: MiniAppDarkColors.surface,
      surfaceTintColor: Colors.transparent,
      textStyle: textTheme.bodyMedium,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? MiniAppDarkColors.surfaceHigh
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : MiniAppDarkColors.muted,
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(color: MiniAppDarkColors.border),
        ),
        textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      ),
    ),
    tabBarTheme: base.tabBarTheme.copyWith(
      labelColor: scheme.primary,
      unselectedLabelColor: MiniAppDarkColors.muted,
      indicatorColor: scheme.primary,
      labelStyle: textTheme.labelLarge,
      unselectedLabelStyle: textTheme.labelMedium,
    ),
  );
}
