import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoHomePage extends StatelessWidget {
  const TospinoHomePage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final products = controller.homeProducts;
    final background = TospinoColors.resolve(context, TospinoColors.background);
    return ColoredBox(
      key: const Key('tospino-home-page'),
      color: background,
      child: CustomScrollView(
        key: const Key('tospino-home-scroll'),
        slivers: [
          SliverToBoxAdapter(child: _HomeHeader(controller: controller)),
          SliverToBoxAdapter(child: _PromoBanner(controller: controller)),
          SliverToBoxAdapter(child: _QuickActions(controller: controller)),
          SliverToBoxAdapter(
            child: TospinoSectionHeader(
              title: '全部分类',
              action: '查看全部',
              onAction: () => controller.switchTab(1),
            ),
          ),
          SliverToBoxAdapter(child: _CategoryStrip(controller: controller)),
          SliverToBoxAdapter(
            child: TospinoSectionHeader(
              title: '限时秒杀',
              subtitle: '大牌好物，限时直降',
              action: '立即抢购',
              onAction: () {
                controller.switchTab(1);
                showTospinoToast(context, '限时秒杀');
              },
            ),
          ),
          SliverToBoxAdapter(child: _FlashSaleRow(controller: controller)),
          const SliverToBoxAdapter(
            child: TospinoSectionHeader(title: '猜你喜欢', subtitle: '好物推荐'),
          ),
          if (controller.loadingHome && products.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.homeError != null && products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _HomeDataState(
                message: controller.homeError!,
                onRetry: controller.refreshHome,
              ),
            )
          else if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _HomeDataState(
                message: localizeMiniProgramLabel(context, '暂无匹配商品'),
                onRetry: controller.refreshHome,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = products[index];
                  return TospinoProductTile(
                    product: product,
                    artworkHeight: 132,
                    onTap: () => controller.openProduct(product),
                  );
                }, childCount: products.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.67,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final brand = TospinoColors.solidBrand(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            brand,
            Color.lerp(
              brand,
              TospinoColors.resolve(context, TospinoColors.background),
              0.55,
            )!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              right: MiniProgramCapsuleOverlay.reservedRight,
            ),
            child: SizedBox(
              height: 34,
              child: Row(
                children: [
                  _TospinoHomeBrand(),
                  SizedBox(width: 9),
                  Text(
                    'Tospino',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Accra, Ghana',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tospino delivery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: TospinoColors.resolve(context, TospinoColors.surface),
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              key: const Key('tospino-home-search'),
              onTap: controller.openSearch,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.muted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizeMiniProgramLabel(context, '搜索商品、品牌或关键词'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.hint,
                          ),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: TospinoColors.brand,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TospinoHomeBrand extends StatelessWidget {
  const _TospinoHomeBrand();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        'T',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => controller.switchTab(1),
          child: Ink(
            height: 156,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF143B46), Color(0xFF42B7AE)],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -22,
                  top: -30,
                  child: Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 22,
                  bottom: -20,
                  child: Transform.rotate(
                    angle: -0.12,
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      size: 112,
                      color: Color(0xFFEAFBFA),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD761),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'TOSPINO 11.11',
                          style: TextStyle(
                            color: Color(0xFF5B3C00),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizeMiniProgramLabel(context, '今日精选'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        localizeMiniProgramLabel(context, '大牌好物，限时直降'),
                        style: const TextStyle(
                          color: Color(0xFFDFF8F5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          localizeMiniProgramLabel(context, '立即抢购'),
                          style: const TextStyle(
                            color: TospinoColors.brandDeep,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final items = <(String, IconData, Color, VoidCallback)>[
      (
        '免运费',
        Icons.local_shipping_outlined,
        TospinoColors.brand,
        () => showTospinoToast(context, '免运费'),
      ),
      (
        '优惠券',
        Icons.confirmation_number_outlined,
        const Color(0xFFFF8B5E),
        () => showTospinoToast(context, '优惠券'),
      ),
      (
        '限时秒杀',
        Icons.flash_on_rounded,
        TospinoColors.saleEnd,
        () => controller.switchTab(1),
      ),
      (
        '新品上架',
        Icons.auto_awesome_outlined,
        TospinoColors.plum,
        () => controller.switchTab(1),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 2),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: InkWell(
                onTap: item.$4,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item.$3.withValues(alpha: 0.11),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(item.$2, color: item.$3, size: 22),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        localizeMiniProgramLabel(context, item.$1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.ink,
                          ),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return InkWell(
            onTap: () {
              controller
                ..selectCategory(category.id)
                ..switchTab(1);
            },
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 52,
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.brandPale,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _CategoryIcon(category: category),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.secondary,
                      ),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FlashSaleRow extends StatelessWidget {
  const _FlashSaleRow({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final products = controller.homeProducts.take(5).toList();
    return SizedBox(
      height: 258,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 150,
            child: TospinoProductTile(
              product: product,
              artworkHeight: 128,
              onTap: () => controller.openProduct(product),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});

  final TospinoCategory category;

  @override
  Widget build(BuildContext context) {
    if (category.iconUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          category.iconUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _letter(context),
        ),
      );
    }
    return _letter(context);
  }

  Widget _letter(BuildContext context) {
    return Center(
      child: Text(
        category.label.isEmpty ? '#' : category.label.characters.first,
        style: TextStyle(
          color: TospinoColors.solidBrand(context),
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HomeDataState extends StatelessWidget {
  const _HomeDataState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: TospinoColors.resolve(context, TospinoColors.hint),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(localizeMiniProgramLabel(context, '重试')),
            ),
          ],
        ),
      ),
    );
  }
}
