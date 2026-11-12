import '../common/miniapp_localizations.dart';

import 'package:flutter/material.dart';

import 'hr_format.dart';

abstract final class HrColors {
  static const brand = Color(0xFFC43D28);
  static const brandLight = Color(0xFFE54F38);
  static const brandTint = Color(0xFFFDECE8);
  static const brandTintBorder = Color(0xFFF6CFC7);
  static const ink = Color(0xFF1C1C1C);
  static const ink2 = Color(0xFF444442);
  static const ink3 = Color(0xFF5E5E5C);
  static const ink4 = Color(0xFF9B9B99);
  static const onDark2 = Color(0xFFB5B5B3);
  static const surface = Colors.white;
  static const bg = Color(0xFFF7F7F5);
  static const bg2 = Color(0xFFF1F0EE);
  static const line = Color(0xFFE4E3E0);
  static const line2 = Color(0xFFEFEEEC);
  static const success = Color(0xFF1E7A54);
  static const successBg = Color(0xFFE4F2EA);
  static const warning = Color(0xFF9A6B12);
  static const warningBg = Color(0xFFFAF0DC);
  static const warningBorder = Color(0xFFEFDCB4);
  static const warningInk = Color(0xFF7A5410);
  static const danger = Color(0xFF8E2E22);
  static const dangerBg = Color(0xFFF7E4E0);
  static const dangerBorder = Color(0xFFE8BDB4);
  static const info = Color(0xFF2A5E8C);
  static const infoBg = Color(0xFFE6EEF5);
  static const readDot = Color(0xFFDEDEDC);
  static const onDarkTile = Color(0x12FFFFFF);
  static const onDarkLine = Color(0x24FFFFFF);

  /// Semantic colors for both host brightness modes, without global state.
  static Color resolve(BuildContext context, Color color) {
    if (Theme.of(context).brightness != Brightness.dark) return color;
    return switch (color) {
      surface => const Color(0xFF242422),
      bg => const Color(0xFF161615),
      bg2 => const Color(0xFF30302D),
      ink => const Color(0xFFF1F0EC),
      ink2 => const Color(0xFFD2D0C9),
      ink3 => const Color(0xFFB5B3AA),
      ink4 => const Color(0xFF99978E),
      line => const Color(0xFF44443D),
      line2 => const Color(0xFF363630),
      brand => const Color(0xFFFF8A73),
      brandTint => const Color(0xFF492A23),
      brandTintBorder => const Color(0xFF754639),
      success => const Color(0xFF6FD7A6),
      successBg => const Color(0xFF1D3C2F),
      warning => const Color(0xFFEAC26A),
      warningInk => const Color(0xFFEAC26A),
      warningBg => const Color(0xFF42361D),
      warningBorder => const Color(0xFF6B5730),
      danger => const Color(0xFFFFA094),
      dangerBg => const Color(0xFF482923),
      dangerBorder => const Color(0xFF72483C),
      info => const Color(0xFF90C7F4),
      infoBg => const Color(0xFF203548),
      readDot => const Color(0xFF55554E),
      _ => color,
    };
  }
}

abstract final class HrText {
  static TextStyle resolve(BuildContext context, TextStyle style) {
    final color = style.color;
    return color == null
        ? style
        : style.copyWith(color: HrColors.resolve(context, color));
  }

  static const cardTitle = TextStyle(
    color: HrColors.ink,
    fontSize: 14.5,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  static const appBarTitle = TextStyle(
    color: HrColors.ink,
    fontSize: 21,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const body = TextStyle(
    color: HrColors.ink2,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const meta = TextStyle(
    color: HrColors.ink3,
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const eyebrow = TextStyle(
    color: HrColors.ink4,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    height: 1.3,
  );

  static const mono = TextStyle(
    color: HrColors.ink,
    fontFamilyFallback: ['SF Mono', 'Menlo', 'Consolas'],
    fontSize: 12,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

abstract final class HrShadows {
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x0A1C1C1C), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Color(0x141C1C1C),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -12,
    ),
  ];

  static const hero = <BoxShadow>[
    BoxShadow(
      color: Color(0x701C1C1C),
      offset: Offset(0, 18),
      blurRadius: 40,
      spreadRadius: -18,
    ),
  ];
}

class HrTheme {
  const HrTheme._();

  static ThemeData data({Brightness brightness = Brightness.light}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: HrColors.brand,
      brightness: Brightness.light,
      primary: HrColors.brand,
      surface: HrColors.surface,
    );
    final light = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: HrColors.bg,
      fontFamilyFallback: const [
        'PingFang SC',
        'Microsoft YaHei',
        'Noto Sans CJK SC',
      ],
      textTheme: const TextTheme(
        headlineSmall: HrText.appBarTitle,
        titleLarge: HrText.cardTitle,
        titleMedium: HrText.cardTitle,
        bodyLarge: HrText.body,
        bodyMedium: HrText.body,
        bodySmall: HrText.meta,
        labelLarge: TextStyle(
          color: HrColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerColor: HrColors.line2,
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: HrColors.surface,
        headerBackgroundColor: HrColors.ink,
        headerForegroundColor: HrColors.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: HrColors.ink,
        contentTextStyle: const TextStyle(
          color: HrColors.surface,
          fontSize: 13,
        ),
        actionTextColor: const Color(0xFFFF9B86),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HrColors.bg2,
        hintStyle: HrText.meta.copyWith(color: HrColors.ink4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HrColors.brand, width: 1.2),
        ),
      ),
    );
    if (brightness == Brightness.light) return light;
    final dark = ColorScheme.fromSeed(
      seedColor: HrColors.brand,
      brightness: Brightness.dark,
      primary: const Color(0xFFFF8A73),
      surface: const Color(0xFF242422),
    );
    return light.copyWith(
      brightness: Brightness.dark,
      colorScheme: dark,
      scaffoldBackgroundColor: const Color(0xFF161615),
      textTheme: light.textTheme.apply(
        bodyColor: dark.onSurface,
        displayColor: dark.onSurface,
      ),
      dividerColor: dark.outlineVariant,
      datePickerTheme: DatePickerThemeData(
        backgroundColor: dark.surface,
        headerBackgroundColor: dark.surfaceContainerHigh,
        headerForegroundColor: dark.onSurface,
      ),
      snackBarTheme: light.snackBarTheme.copyWith(
        backgroundColor: dark.inverseSurface,
        contentTextStyle: TextStyle(color: dark.onInverseSurface, fontSize: 13),
      ),
      inputDecorationTheme: light.inputDecorationTheme.copyWith(
        fillColor: const Color(0xFF30302D),
        hintStyle: HrText.meta.copyWith(color: dark.onSurfaceVariant),
      ),
    );
  }
}

class HrCard extends StatelessWidget {
  const HrCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.background = HrColors.surface,
    this.borderColor = HrColors.line,
    this.radius = 22,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color background;
  final Color borderColor;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: HrColors.resolve(context, background),
          borderRadius: borderRadius,
          border: Border.all(color: HrColors.resolve(context, borderColor)),
          boxShadow: shadow ? HrShadows.card : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class HrPrimaryButton extends StatelessWidget {
  const HrPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 50,
    this.background = HrColors.brand,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: Colors.white,
          disabledBackgroundColor: HrColors.resolve(context, HrColors.line),
          disabledForegroundColor: HrColors.resolve(context, HrColors.ink4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19),
              const SizedBox(width: 7),
            ],
            Text(localizeMiniProgramLabel(context, label)),
          ],
        ),
      ),
    );
  }
}

class HrOutlineButton extends StatelessWidget {
  const HrOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? HrColors.resolve(context, HrColors.brand)
        : HrColors.resolve(context, HrColors.ink);
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: danger
                ? HrColors.resolve(context, HrColors.brandTintBorder)
                : HrColors.resolve(context, HrColors.line),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Text(localizeMiniProgramLabel(context, label)),
          ],
        ),
      ),
    );
  }
}

class HrSectionHeader extends StatelessWidget {
  const HrSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(0, 20, 0, 10),
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(
            localizeMiniProgramLabel(context, title),
            style: HrText.resolve(context, HrText.cardTitle).copyWith(
              fontSize: 15,
              color: HrColors.resolve(context, HrColors.ink),
            ),
          ),
          const Spacer(),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: HrColors.resolve(context, HrColors.brand),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizeMiniProgramLabel(context, action!),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class HrStatusChip extends StatelessWidget {
  const HrStatusChip({
    super.key,
    required this.label,
    this.background = HrColors.successBg,
    this.foreground = HrColors.success,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: HrColors.resolve(context, background),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        localizeMiniProgramLabel(context, label),
        style: HrText.resolve(context, HrText.mono).copyWith(
          color: HrColors.resolve(context, foreground),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class HrAvatar extends StatelessWidget {
  const HrAvatar({
    super.key,
    required this.name,
    this.index = 0,
    this.size = 40,
    this.dark = false,
  });

  final String name;
  final int index;
  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? HrColors.brand : hrAvatarColor(name, index);
    final text = name.trim().isEmpty ? '?' : name.trim().characters.last;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? color : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.36),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: dark ? Colors.white : color,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class HrLogoMark extends StatelessWidget {
  const HrLogoMark({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: HrColors.resolve(context, HrColors.surface),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: HrColors.resolve(context, HrColors.line)),
        boxShadow: HrShadows.card,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.45,
            child: Container(
              width: size * 0.52,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: HrColors.ink,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.17,
            child: Container(
              width: size * 0.56,
              height: size * 0.18,
              decoration: BoxDecoration(
                color: HrColors.resolve(context, HrColors.brandLight),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HrEmptyState extends StatelessWidget {
  const HrEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return HrCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: HrColors.resolve(context, HrColors.successBg),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: HrColors.resolve(context, HrColors.success),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            localizeMiniProgramLabel(context, title),
            style: HrText.resolve(context, HrText.cardTitle),
          ),
          const SizedBox(height: 5),
          Text(
            localizeMiniProgramLabel(context, message),
            textAlign: TextAlign.center,
            style: HrText.resolve(context, HrText.meta),
          ),
        ],
      ),
    );
  }
}

void hrToast(BuildContext context, String message, {SnackBarAction? action}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(localizeMiniProgramLabel(context, message)),
        action: action,
        duration: const Duration(seconds: 2),
      ),
    );
}
