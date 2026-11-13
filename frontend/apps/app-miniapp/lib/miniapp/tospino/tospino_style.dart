import 'package:flutter/material.dart';

import '../common/miniapp_localizations.dart';
import 'tospino_models.dart';

class TospinoColors {
  const TospinoColors._();

  static const brand = Color(0xFF42B7AE);
  static const brandDeep = Color(0xFF2E9F97);
  static const brandPale = Color(0xFFE7F7F4);
  static const background = Color(0xFFFAFAFA);
  static const surface = Colors.white;
  static const ink = Color(0xFF383838);
  static const secondary = Color(0xFF666666);
  static const muted = Color(0xFF999999);
  static const hint = Color(0xFFBFBFBF);
  static const line = Color(0xFFF0F1F2);
  static const price = Color(0xFFFF6666);
  static const orange = Color(0xFFF7B500);
  static const saleStart = Color(0xFFFB6028);
  static const saleEnd = Color(0xFFF9083B);
  static const plum = Color(0xFF8A5BEA);

  static Color resolve(BuildContext context, Color color) {
    if (Theme.of(context).brightness != Brightness.dark) return color;
    return switch (color) {
      background => const Color(0xFF151919),
      surface => const Color(0xFF202525),
      ink => const Color(0xFFF3F5F5),
      secondary => const Color(0xFFC2C8C8),
      muted => const Color(0xFF929D9D),
      hint => const Color(0xFF879191),
      line => const Color(0xFF353D3D),
      brandPale => const Color(0xFF183B38),
      _ => color,
    };
  }

  static Color solidBrand(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? brandDeep : brand;
}

class TospinoTheme {
  const TospinoTheme._();

  static ThemeData data({Brightness brightness = Brightness.light}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: TospinoColors.brand,
      brightness: Brightness.light,
      primary: TospinoColors.brand,
      surface: TospinoColors.surface,
    );
    final light = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: TospinoColors.background,
      fontFamilyFallback: const [
        'PingFang SC',
        'Microsoft YaHei',
        'Noto Sans CJK SC',
      ],
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: TospinoColors.ink,
          fontSize: 23,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          color: TospinoColors.ink,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          color: TospinoColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
        bodyLarge: TextStyle(
          color: TospinoColors.ink,
          fontSize: 15,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: TospinoColors.secondary,
          fontSize: 13,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          color: TospinoColors.muted,
          fontSize: 11.5,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: TospinoColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerColor: TospinoColors.line,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: TospinoColors.ink,
        contentTextStyle: const TextStyle(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TospinoColors.line,
        hintStyle: const TextStyle(color: TospinoColors.hint, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: TospinoColors.brand, width: 1.2),
        ),
      ),
    );
    if (brightness == Brightness.light) return light;
    final dark = ColorScheme.fromSeed(
      seedColor: TospinoColors.brand,
      brightness: Brightness.dark,
      primary: const Color(0xFF64D5CC),
      surface: const Color(0xFF202525),
    );
    return light.copyWith(
      brightness: Brightness.dark,
      colorScheme: dark,
      scaffoldBackgroundColor: const Color(0xFF151919),
      textTheme: light.textTheme.apply(
        bodyColor: dark.onSurface,
        displayColor: dark.onSurface,
      ),
      dividerColor: dark.outlineVariant,
      inputDecorationTheme: light.inputDecorationTheme.copyWith(
        fillColor: const Color(0xFF2B3232),
        hintStyle: TextStyle(color: dark.onSurfaceVariant, fontSize: 13),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF70CEB6), TospinoColors.brand],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3342B7AE),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'T',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.56,
          fontWeight: FontWeight.w900,
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
    this.radius = 16,
    this.hero = true,
  });

  final TospinoProduct product;
  final double height;
  final double radius;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final hue = product.id.codeUnits.fold<int>(0, (sum, code) => sum + code);
    final startColor = HSLColor.fromAHSL(
      1,
      (hue * 17) % 360,
      0.42,
      0.34,
    ).toColor();
    final endColor = HSLColor.fromAHSL(
      1,
      (hue * 17 + 36) % 360,
      0.48,
      0.58,
    ).toColor();
    final artwork = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            right: -height * 0.22,
            top: -height * 0.3,
            child: Container(
              width: height * 0.8,
              height: height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -height * 0.24,
            bottom: -height * 0.28,
            child: Container(
              width: height * 0.75,
              height: height * 0.75,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (product.imageUrl.isNotEmpty)
            Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _ProductImageFallback(height: height),
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : ColoredBox(
                      color: startColor.withValues(alpha: 0.18),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            )
          else
            _ProductImageFallback(height: height),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.52),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                product.brand.isNotEmpty ? product.brand : product.categoryName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
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
      child: Container(
        width: height * 0.5,
        height: height * 0.5,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(height * 0.18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(
          Icons.shopping_bag_outlined,
          color: Colors.white,
          size: height * 0.28,
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [TospinoColors.brand, Color(0xFF70CEB6)],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizeMiniProgramLabel(context, title),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (subtitle != null)
                  Text(
                    localizeMiniProgramLabel(context, subtitle!),
                    style: Theme.of(context).textTheme.bodySmall,
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
                    style: const TextStyle(fontSize: 12),
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
    this.size = 18,
  });

  final double price;
  final double? oldPrice;
  final double size;

  @override
  Widget build(BuildContext context) {
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
              color: TospinoColors.price,
              fontSize: size * 0.58,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
          Text(
            price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2),
            style: TextStyle(
              color: TospinoColors.price,
              fontSize: size,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          if (oldPrice != null) ...[
            const SizedBox(width: 5),
            Text(
              'GH₵${oldPrice!.toStringAsFixed(0)}',
              maxLines: 1,
              style: TextStyle(
                color: TospinoColors.resolve(context, TospinoColors.hint),
                fontSize: size * 0.58,
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
  });

  final TospinoProduct product;
  final VoidCallback onTap;
  final double artworkHeight;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(16),
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
              hero: hero,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.ink,
                        ),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const Spacer(),
                    TospinoPriceText(
                      price: product.price,
                      oldPrice: product.oldPrice > product.price
                          ? product.oldPrice
                          : null,
                      size: 18,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.rating} ★  ·  ${product.sales} ${localizeMiniProgramLabel(context, '已售')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
