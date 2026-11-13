import 'package:flutter/material.dart';

import '../common/miniapp_localizations.dart';
import 'tospino_models.dart';

class TospinoColors {
  const TospinoColors._();

  static const brand = Color(0xFF42B7AE);
  static const brandLight = Color(0xFF70CEB6);
  static const brandDeep = Color(0xFF3EB7AE);
  static const brandPale = Color(0xFFD9F1EF);
  static const background = Color(0xFFFAFAFA);
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF8F8F8);
  static const tint = Color(0xFFF2F2F2);
  static const ink = Color(0xFF383838);
  static const secondary = Color(0xFF666666);
  static const muted = Color(0xFF999999);
  static const hint = Color(0xFFBFBFBF);
  static const line = Color(0xFFF5F5F5);
  static const lineStrong = Color(0xFFDDDDDD);
  static const imagePlaceholder = Color(0xFFF0F1F2);
  static const disabled = Color(0xFFEEEEEE);
  static const price = Color(0xFFFF6666);
  static const orange = Color(0xFFF7B500);
  static const lightOrange = Color(0xFFFACE91);
  static const saleStart = Color(0xFFFB6028);
  static const saleEnd = Color(0xFFF9083B);
  static const link = Color(0xFF0F66DE);
  static const plum = Color(0xFF8A5BEA);

  static Color resolve(BuildContext context, Color color) {
    if (Theme.of(context).brightness != Brightness.dark) return color;
    return switch (color) {
      background => const Color(0xFF0B0C0F),
      surface => const Color(0xFF141518),
      surfaceMuted => const Color(0xFF101215),
      tint => const Color(0xFF1C1E23),
      ink => const Color(0xFFF3F5F5),
      secondary => const Color(0xFFCDD1D8),
      muted => const Color(0xFF8B9098),
      hint => const Color(0xFF63676E),
      line => const Color(0xFF26282F),
      lineStrong => const Color(0xFF353840),
      imagePlaceholder => const Color(0xFF1C1E23),
      disabled => const Color(0xFF2A2D34),
      brandPale => const Color(0xFF153B37),
      price => const Color(0xFFFF7A8A),
      _ => color,
    };
  }

  static Color solidBrand(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF64D5CC)
      : brand;

  static Color solidBrandFrom(Brightness brightness) =>
      brightness == Brightness.dark ? const Color(0xFF64D5CC) : brand;

  static LinearGradient brandGradient(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: dark
          ? const [Color(0xFF64D5CC), Color(0xFF3EB7AE)]
          : const [brandLight, brand],
    );
  }

  static LinearGradient saleGradient(BuildContext context) => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: Theme.of(context).brightness == Brightness.dark
        ? const [Color(0xFFFF8B62), Color(0xFFFF4D70)]
        : const [saleStart, saleEnd],
  );
}

/// Tospino 使用 375pt 设计稿；尺寸只在小程序内部生效，不修改宿主规范。
class TospinoMetrics {
  const TospinoMetrics._();

  static const pagePadding = 12.0;
  static const sectionGap = 12.0;
  static const cardRadius = 8.0;
  static const imageRadius = 6.0;
  static const controlRadius = 5.0;
  static const tagRadius = 4.0;
  static const rowHeight = 53.0;
  static const buttonHeight = 48.0;
  static const compactButtonHeight = 40.0;
}

class TospinoText {
  const TospinoText._();

  // 与 Android `inter.xml` 一致：400/500 使用 Regular，600/700 使用 Medium。
  static const fontFamily = 'Inter';
  static const regular = FontWeight.w400;
  static const emphasis = FontWeight.w600;
  static const strong = FontWeight.w700;

  static TextStyle pageTitle(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    color: TospinoColors.resolve(context, TospinoColors.ink),
    fontSize: 18,
    fontWeight: strong,
    height: 1.2,
  );

  static TextStyle section(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    color: TospinoColors.resolve(context, TospinoColors.ink),
    fontSize: 16,
    fontWeight: strong,
    height: 1.2,
  );

  static TextStyle body(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    color: TospinoColors.resolve(context, TospinoColors.ink),
    fontSize: 14,
    fontWeight: regular,
    height: 1.2,
  );

  static TextStyle bodyStrong(BuildContext context) =>
      body(context).copyWith(fontWeight: emphasis);

  static TextStyle secondary(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    color: TospinoColors.resolve(context, TospinoColors.secondary),
    fontSize: 12,
    fontWeight: regular,
    height: 1.2,
  );

  static TextStyle meta(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    color: TospinoColors.resolve(context, TospinoColors.muted),
    fontSize: 12,
    fontWeight: regular,
    height: 1.2,
  );

  static TextStyle hint(BuildContext context) => TextStyle(
    fontFamily: fontFamily,
    color: TospinoColors.resolve(context, TospinoColors.hint),
    fontSize: 12,
    fontWeight: regular,
    height: 1.2,
  );

  static TextStyle price(BuildContext context, {double size = 16}) => TextStyle(
    fontFamily: fontFamily,
    color: TospinoColors.resolve(context, TospinoColors.ink),
    fontSize: size,
    fontWeight: strong,
    height: 1.1,
  );

  static TextStyle pageTitleFrom(Brightness brightness) => TextStyle(
    fontFamily: fontFamily,
    color: _inkFor(brightness),
    fontSize: 18,
    fontWeight: strong,
    height: 1.2,
  );

  static TextStyle sectionFrom(Brightness brightness) => TextStyle(
    fontFamily: fontFamily,
    color: _inkFor(brightness),
    fontSize: 16,
    fontWeight: strong,
    height: 1.2,
  );

  static TextStyle bodyFrom(Brightness brightness) => TextStyle(
    fontFamily: fontFamily,
    color: _inkFor(brightness),
    fontSize: 14,
    fontWeight: regular,
    height: 1.2,
  );

  static TextStyle secondaryFrom(Brightness brightness) => TextStyle(
    fontFamily: fontFamily,
    color: brightness == Brightness.dark
        ? const Color(0xFFCDD1D8)
        : TospinoColors.secondary,
    fontSize: 12,
    fontWeight: regular,
    height: 1.2,
  );

  static TextStyle metaFrom(Brightness brightness) => TextStyle(
    fontFamily: fontFamily,
    color: brightness == Brightness.dark
        ? const Color(0xFF8B9098)
        : TospinoColors.muted,
    fontSize: 12,
    fontWeight: regular,
    height: 1.2,
  );

  static Color _inkFor(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFFF0F2F5)
      : TospinoColors.ink;
}

class TospinoTheme {
  const TospinoTheme._();

  static ThemeData data({Brightness brightness = Brightness.light}) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: TospinoColors.brand,
      brightness: brightness,
      primary: isDark ? const Color(0xFF64D5CC) : TospinoColors.brand,
      surface: isDark ? const Color(0xFF141518) : TospinoColors.surface,
      onSurface: isDark ? const Color(0xFFF0F2F5) : TospinoColors.ink,
      outline: isDark ? const Color(0xFF353840) : TospinoColors.lineStrong,
      outlineVariant: isDark ? const Color(0xFF26282F) : TospinoColors.line,
    );
    final textTheme = TextTheme(
      headlineSmall: TospinoText.pageTitleFrom(brightness),
      titleLarge: TospinoText.sectionFrom(brightness),
      titleMedium: TospinoText.bodyFrom(
        brightness,
      ).copyWith(fontWeight: TospinoText.emphasis),
      bodyLarge: TospinoText.bodyFrom(brightness),
      bodyMedium: TospinoText.secondaryFrom(brightness),
      bodySmall: TospinoText.metaFrom(brightness),
      labelLarge: TospinoText.bodyFrom(
        brightness,
      ).copyWith(fontWeight: TospinoText.emphasis, fontSize: 14),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0B0C0F)
          : TospinoColors.background,
      fontFamily: TospinoText.fontFamily,
      fontFamilyFallback: const [
        'PingFang SC',
        'Microsoft YaHei',
        'Noto Sans CJK SC',
        'sans-serif',
      ],
      textTheme: textTheme,
      dividerColor: scheme.outlineVariant,
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 0.5,
        space: 0.5,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TospinoColors.solidBrandFrom(brightness),
          foregroundColor: Colors.white,
          minimumSize: const Size(0, TospinoMetrics.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TospinoMetrics.controlRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TospinoColors.solidBrandFrom(brightness),
          minimumSize: const Size(0, TospinoMetrics.compactButtonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: BorderSide(color: TospinoColors.solidBrandFrom(brightness)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TospinoMetrics.controlRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TospinoColors.solidBrandFrom(brightness),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: TospinoText.regular,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF141518) : Colors.white,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF141518) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TospinoMetrics.cardRadius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFFE5E8EC) : TospinoColors.ink,
        contentTextStyle: TextStyle(
          color: isDark ? const Color(0xFF1C1E23) : Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TospinoMetrics.cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF1C1E23)
            : TospinoColors.surfaceMuted,
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF63676E) : TospinoColors.hint,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TospinoMetrics.controlRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TospinoMetrics.controlRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TospinoMetrics.controlRadius),
          borderSide: BorderSide(
            color: TospinoColors.solidBrandFrom(brightness),
            width: 1,
          ),
        ),
      ),
    );
  }
}

class TospinoSurface extends StatelessWidget {
  const TospinoSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin,
    this.radius = TospinoMetrics.cardRadius,
    this.onTap,
    this.border = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final VoidCallback? onTap;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: border
          ? BorderSide(
              color: TospinoColors.resolve(context, TospinoColors.line),
              width: 0.5,
            )
          : BorderSide.none,
    );
    final content = Padding(padding: padding, child: child);
    return Container(
      margin: margin,
      child: Material(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

class TospinoGradientButton extends StatelessWidget {
  const TospinoGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = TospinoMetrics.buttonHeight,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(TospinoMetrics.controlRadius);
    final disabled = onPressed == null;
    final button = Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: TospinoColors.brandGradient(context),
            borderRadius: radius,
          ),
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    localizeMiniProgramLabel(context, label),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class TospinoTag extends StatelessWidget {
  const TospinoTag({
    super.key,
    required this.label,
    this.solid = false,
    this.color,
  });

  final String label;
  final bool solid;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? TospinoColors.solidBrand(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: solid
            ? accent
            : TospinoColors.resolve(context, TospinoColors.brandPale),
        borderRadius: BorderRadius.circular(TospinoMetrics.tagRadius),
      ),
      child: Text(
        localizeMiniProgramLabel(context, label),
        style: TextStyle(
          color: solid ? Colors.white : TospinoColors.solidBrand(context),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

class TospinoListRow extends StatelessWidget {
  const TospinoListRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.showDivider = true,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showDivider;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: TospinoMetrics.rowHeight,
        margin: const EdgeInsets.only(left: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: TospinoColors.resolve(context, TospinoColors.line),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  iconColor ??
                  TospinoColors.resolve(context, TospinoColors.secondary),
              size: 21,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizeMiniProgramLabel(context, label),
                style: TospinoText.body(context),
              ),
            ),
            if (trailing != null) trailing! else const SizedBox(width: 12),
            Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: TospinoColors.resolve(context, TospinoColors.hint),
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

class TospinoBrandMark extends StatelessWidget {
  const TospinoBrandMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: TospinoColors.brandGradient(context),
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      alignment: Alignment.center,
      child: Text(
        'T',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.58,
          fontWeight: TospinoText.strong,
          height: 1,
        ),
      ),
    );
  }
}

class TospinoProductArtwork extends StatelessWidget {
  const TospinoProductArtwork({
    super.key,
    required this.product,
    this.height = 150,
    this.radius = TospinoMetrics.imageRadius,
    this.hero = true,
  });

  final TospinoProduct product;
  final double height;
  final double radius;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final placeholder = TospinoColors.resolve(
      context,
      TospinoColors.imagePlaceholder,
    );
    final artwork = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: placeholder),
          if (product.imageUrl.isNotEmpty)
            Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _ProductImageFallback(height: height),
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: TospinoColors.solidBrand(context),
                        ),
                      ),
                    ),
            )
          else
            _ProductImageFallback(height: height),
          if (product.discountPercent > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  gradient: TospinoColors.saleGradient(context),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(TospinoMetrics.tagRadius),
                  ),
                ),
                child: Text(
                  '-${product.discountPercent}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: TospinoText.emphasis,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return SizedBox(
      height: height,
      child: hero
          ? Hero(tag: 'tospino-product-${product.id}', child: artwork)
          : artwork,
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_outlined,
        color: TospinoColors.resolve(context, TospinoColors.hint),
        size: (height * 0.28).clamp(24, 40).toDouble(),
      ),
    );
  }
}

class TospinoSectionHeader extends StatelessWidget {
  const TospinoSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TospinoMetrics.pagePadding,
        18,
        TospinoMetrics.pagePadding,
        10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizeMiniProgramLabel(context, title),
                  style: TospinoText.section(context),
                ),
                if (subtitle != null)
                  Text(
                    localizeMiniProgramLabel(context, subtitle!),
                    style: TospinoText.secondary(context),
                  ),
              ],
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: TospinoColors.resolve(
                  context,
                  TospinoColors.secondary,
                ),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizeMiniProgramLabel(context, action!),
                    style: TospinoText.secondary(context),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 17),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class TospinoPriceText extends StatelessWidget {
  const TospinoPriceText({
    super.key,
    required this.price,
    this.oldPrice,
    this.size = 16,
    this.color,
  });

  final double price;
  final double? oldPrice;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground =
        color ?? TospinoColors.resolve(context, TospinoColors.ink);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'GH₵',
            style: TextStyle(
              color: foreground,
              fontSize: size * 0.62,
              fontWeight: TospinoText.strong,
              height: 1.2,
            ),
          ),
          Text(
            price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2),
            style: TextStyle(
              color: foreground,
              fontSize: size,
              fontWeight: TospinoText.strong,
              height: 1.1,
            ),
          ),
          if (oldPrice != null) ...[
            const SizedBox(width: 5),
            Text(
              'GH₵${oldPrice!.toStringAsFixed(0)}',
              maxLines: 1,
              style: TextStyle(
                color: TospinoColors.resolve(context, TospinoColors.hint),
                fontSize: 12,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TospinoProductTile extends StatelessWidget {
  const TospinoProductTile({
    super.key,
    required this.product,
    required this.onTap,
    this.artworkHeight = 150,
    this.hero = false,
    this.fillHeight = true,
    this.showSales = true,
    this.showRating = false,
    this.titleLines = 2,
    this.compact = false,
  });

  final TospinoProduct product;
  final VoidCallback onTap;
  final double artworkHeight;
  final bool hero;
  final bool fillHeight;
  final bool showSales;
  final bool showRating;
  final int titleLines;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: compact
          ? const EdgeInsets.fromLTRB(6, 1, 6, 2)
          : const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Text(
            product.title,
            maxLines: titleLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TospinoColors.resolve(context, TospinoColors.ink),
              fontSize: 14,
              fontWeight: TospinoText.regular,
              height: 1.2,
            ),
          ),
          if (fillHeight) const Spacer() else SizedBox(height: compact ? 1 : 8),
          TospinoPriceText(
            price: product.price,
            oldPrice: product.oldPrice > product.price
                ? product.oldPrice
                : null,
            size: 16,
          ),
          SizedBox(height: compact ? 1 : 5),
          if (showRating && product.rating > 0)
            _TospinoRatingStars(rating: product.rating)
          else if (showSales)
            Text(
              product.sales > 0
                  ? '${product.sales} ${localizeMiniProgramLabel(context, '已售')}'
                  : product.brand.isNotEmpty
                  ? product.brand
                  : localizeMiniProgramLabel(context, '现货'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TospinoText.secondary(context),
            ),
        ],
      ),
    );
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(TospinoMetrics.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('tospino-product-${product.id}'),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TospinoProductArtwork(
              product: product,
              height: artworkHeight,
              radius: TospinoMetrics.imageRadius,
              hero: hero,
            ),
            if (fillHeight) Expanded(child: content) else content,
          ],
        ),
      ),
    );
  }
}

class _TospinoRatingStars extends StatelessWidget {
  const _TospinoRatingStars({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 5; index++)
          Icon(
            rating >= index + 1
                ? Icons.star_rounded
                : rating > index
                ? Icons.star_half_rounded
                : Icons.star_rounded,
            size: 9.5,
            color: rating > index
                ? TospinoColors.orange
                : TospinoColors.resolve(context, TospinoColors.disabled),
          ),
      ],
    );
  }
}

void showTospinoToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        content: Text(localizeMiniProgramLabel(context, message)),
      ),
    );
}
