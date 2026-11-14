import 'dart:async';

import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'campaigns.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoHomePage extends StatefulWidget {
  const TospinoHomePage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  State<TospinoHomePage> createState() => _TospinoHomePageState();
}

enum _HomeSort {
  forYou('为你推荐'),
  popular('热卖'),
  rating('好评'),
  value('超值');

  const _HomeSort(this.label);

  final String label;
}

class _TospinoHomePageState extends State<TospinoHomePage> {
  _HomeSort _sort = _HomeSort.forYou;

  TospinoAppController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.homeLoaded) {
      return _HomeLoadingPage(controller: controller);
    }

    final products = controller.homeProducts;
    final recommendations = _sortedProducts(products, _sort);
    final picks = _editorialProducts(products);
    final trending = _trendingProducts(products);
    final gift = controller.freeGifts.isEmpty
        ? null
        : controller.freeGifts.first;

    return ColoredBox(
      key: const Key('tospino-home-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: RefreshIndicator(
        color: TospinoColors.solidBrand(context),
        onRefresh: controller.refreshHome,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.axis == Axis.vertical &&
                notification.metrics.extentAfter < 520) {
              unawaited(controller.loadMoreHome());
            }
            return false;
          },
          child: CustomScrollView(
            key: const Key('tospino-home-scroll'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _HomeHeader(controller: controller)),
              if (controller.homeError != null && products.isNotEmpty)
                SliverToBoxAdapter(
                  child: _HomeInlineNotice(
                    message: controller.homeError!,
                    onRetry: controller.refreshHome,
                  ),
                ),
              if (products.isEmpty && controller.homeError != null)
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
              else ...[
                SliverToBoxAdapter(
                  child: _HomeEditorialHero(
                    products: picks.take(3).toList(growable: false),
                    controller: controller,
                  ),
                ),
                if (gift != null)
                  SliverToBoxAdapter(
                    child: _HomeGiftBanner(
                      gift: gift,
                      onTap: () => controller.open(TospinoRoute.freeGift),
                    ),
                  ),
                if (controller.categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _HomeCategorySection(controller: controller),
                  ),
                const SliverToBoxAdapter(child: _HomeTrustStrip()),
                SliverToBoxAdapter(
                  child: _HomeCampaignHub(controller: controller),
                ),
                if (picks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _HomeDealRail(
                      products: picks.take(8).toList(growable: false),
                      controller: controller,
                    ),
                  ),
                if (trending.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _HomeTrendingRail(
                      products: trending,
                      controller: controller,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _HomeDiscoveryControls(
                    sort: _sort,
                    onChanged: (value) => setState(() => _sort = value),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
                  sliver: SliverGrid.builder(
                    key: const Key('tospino-home-product-grid'),
                    itemCount: recommendations.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.62,
                        ),
                    itemBuilder: (context, index) {
                      final product = recommendations[index];
                      return _HomeProductCard(
                        product: product,
                        onTap: () => controller.openProduct(product),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: _HomePagingFooter(controller: controller),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<TospinoProduct> _sortedProducts(
    List<TospinoProduct> products,
    _HomeSort sort,
  ) {
    final sorted = [...products];
    switch (sort) {
      case _HomeSort.forYou:
        return sorted;
      case _HomeSort.popular:
        sorted.sort((left, right) {
          final sales = right.sales.compareTo(left.sales);
          return sales != 0 ? sales : right.rating.compareTo(left.rating);
        });
      case _HomeSort.rating:
        sorted.sort((left, right) {
          final rating = right.rating.compareTo(left.rating);
          return rating != 0 ? rating : right.sales.compareTo(left.sales);
        });
      case _HomeSort.value:
        sorted.sort((left, right) {
          final discount = right.discountPercent.compareTo(
            left.discountPercent,
          );
          return discount != 0 ? discount : left.price.compareTo(right.price);
        });
    }
    return sorted;
  }

  List<TospinoProduct> _editorialProducts(List<TospinoProduct> products) {
    final ranked = [...products];
    ranked.sort((left, right) {
      final discount = right.discountPercent.compareTo(left.discountPercent);
      if (discount != 0) return discount;
      final sales = right.sales.compareTo(left.sales);
      return sales != 0 ? sales : right.rating.compareTo(left.rating);
    });
    return ranked;
  }

  List<TospinoProduct> _trendingProducts(List<TospinoProduct> products) {
    final ranked = [...products];
    ranked.sort((left, right) {
      final sales = right.sales.compareTo(left.sales);
      if (sales != 0) return sales;
      return right.rating.compareTo(left.rating);
    });
    return ranked.take(6).toList(growable: false);
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.controller, this.loading = false});

  final TospinoAppController controller;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final words = controller.homeRecommendWords.take(8).toList(growable: false);
    return ColoredBox(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 3, 12, 9),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      key: const Key('tospino-home-delivery'),
                      onTap: () => controller.open(TospinoRoute.address),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: TospinoColors.resolve(
                                context,
                                TospinoColors.brandPale,
                              ),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 19,
                              color: TospinoColors.solidBrand(context),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _deliveryLabel(context),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TospinoText.bodyStrong(
                                    context,
                                  ).copyWith(fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  localizeMiniProgramLabel(context, '选择收货地址'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TospinoText.hint(
                                    context,
                                  ).copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 17,
                            color: TospinoColors.resolve(
                              context,
                              TospinoColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: MiniProgramCapsuleOverlay.reservedRight,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            _HomeSearchField(controller: controller),
            if (!loading && words.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 25,
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 15,
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.saleStart,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      localizeMiniProgramLabel(context, '热门搜索'),
                      style: TospinoText.meta(context).copyWith(
                        fontSize: 11.5,
                        fontWeight: TospinoText.emphasis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: words.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 6),
                        itemBuilder: (context, index) {
                          final word = words[index];
                          return Material(
                            color: TospinoColors.resolve(
                              context,
                              TospinoColors.surfaceMuted,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                controller.openSearch();
                                controller.search(word);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                ),
                                child: Center(
                                  child: Text(
                                    word,
                                    maxLines: 1,
                                    style: TospinoText.meta(context).copyWith(
                                      fontSize: 11.5,
                                      color: TospinoColors.resolve(
                                        context,
                                        TospinoColors.secondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _deliveryLabel(BuildContext context) {
    final address = controller.defaultAddress;
    final destination = address == null || address.name.trim().isEmpty
        ? 'Accra, Ghana'
        : address.name.trim();
    return '${localizeMiniProgramLabel(context, '送至')} $destination';
  }
}

class _HomeSearchField extends StatelessWidget {
  const _HomeSearchField({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final brand = TospinoColors.solidBrand(context);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: brand.withValues(alpha: 0.48), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: brand.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('tospino-home-search'),
          onTap: controller.openSearch,
          child: Row(
            children: [
              const SizedBox(width: 13),
              Icon(Icons.search_rounded, size: 22, color: brand),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizeMiniProgramLabel(context, '搜索商品、品牌或关键词'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TospinoText.hint(context).copyWith(
                    fontSize: 12.5,
                    color: TospinoColors.resolve(
                      context,
                      TospinoColors.secondary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: 34,
                  decoration: BoxDecoration(
                    gradient: TospinoColors.brandGradient(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeEditorialHero extends StatelessWidget {
  const _HomeEditorialHero({required this.products, required this.controller});

  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    final lead = products.first;
    final supporting = products.skip(1).take(2).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 2),
      child: Column(
        children: [
          SizedBox(
            height: 194,
            child: _HomeHeroCard(
              key: const Key('tospino-home-hero'),
              product: lead,
              onTap: () => controller.openProduct(lead),
            ),
          ),
          if (supporting.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                for (var index = 0; index < supporting.length; index++) ...[
                  if (index > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _HomeHeroSupportCard(
                      product: supporting[index],
                      onTap: () => controller.openProduct(supporting[index]),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard({super.key, required this.product, required this.onTap});

  final TospinoProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final discount = product.discountPercent;
    final title = product.title.trim().isEmpty
        ? localizeMiniProgramLabel(context, '好物推荐')
        : product.title;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? const [Color(0xFF0B2A31), Color(0xFF0A4F59)]
                  : const [Color(0xFF062E36), Color(0xFF0B8E9A)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -48,
                top: -70,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 18,
                bottom: 18,
                width: 126,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ColoredBox(
                    color: Colors.white.withValues(alpha: 0.12),
                    child: product.imageUrl.isEmpty
                        ? const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white54,
                            size: 38,
                          )
                        : Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white54,
                              size: 38,
                            ),
                          ),
                  ),
                ),
              ),
              Positioned.fill(
                right: 108,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(17, 15, 148, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: TospinoColors.orange,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'TOSPINO SELECTS',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF1C2526),
                                  fontSize: 11,
                                  fontWeight: TospinoText.strong,
                                  height: 1,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(width: 5),
                          Text(
                            'SAVE $discount%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: TospinoText.emphasis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: TospinoText.strong,
                        height: 1.12,
                        letterSpacing: -0.25,
                      ),
                    ),
                    const Spacer(),
                    TospinoPriceText(
                      price: product.price,
                      oldPrice: product.oldPrice > product.price
                          ? product.oldPrice
                          : null,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localizeMiniProgramLabel(context, '立即抢购'),
                            style: const TextStyle(
                              color: Color(0xFF083A40),
                              fontSize: 11.5,
                              fontWeight: TospinoText.strong,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: Color(0xFF083A40),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeroSupportCard extends StatelessWidget {
  const _HomeHeroSupportCard({required this.product, required this.onTap});

  final TospinoProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('tospino-home-hero-mini-${product.id}'),
        onTap: onTap,
        child: SizedBox(
          height: 82,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 58,
                    height: 66,
                    child: product.imageUrl.isEmpty
                        ? ColoredBox(
                            color: TospinoColors.resolve(
                              context,
                              TospinoColors.imagePlaceholder,
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 20,
                            ),
                          )
                        : Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => ColoredBox(
                              color: TospinoColors.resolve(
                                context,
                                TospinoColors.imagePlaceholder,
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 20,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TospinoText.body(context).copyWith(
                          fontSize: 11.5,
                          fontWeight: TospinoText.emphasis,
                          height: 1.18,
                        ),
                      ),
                      const Spacer(),
                      TospinoPriceText(
                        price: product.price,
                        size: 12.5,
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.price,
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

class _HomeGiftBanner extends StatelessWidget {
  const _HomeGiftBanner({required this.gift, required this.onTap});

  final TospinoFreeGift gift;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const Key('tospino-home-free-gift'),
          onTap: onTap,
          child: Ink(
            height: 126,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [Color(0xFF30251C), Color(0xFF3A2028)]
                    : const [Color(0xFFFFF3D8), Color(0xFFFFE1E6)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -32,
                  top: -48,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: dark ? 0.04 : 0.32),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 12, 13, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TospinoColors.orange,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    localizeMiniProgramLabel(context, '限时福利'),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Color(0xFF39260B),
                                      fontSize: 11,
                                      fontWeight: TospinoText.strong,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${gift.receiveNum} '
                                    '${localizeMiniProgramLabel(context, '人已领取')}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TospinoText.hint(
                                      context,
                                    ).copyWith(fontSize: 11.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Text(
                              localizeMiniProgramLabel(context, '免费拿好物'),
                              style: TospinoText.section(context).copyWith(
                                fontSize: 17,
                                color: dark
                                    ? const Color(0xFFFFE2B6)
                                    : const Color(0xFF5B3410),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Expanded(
                              child: Text(
                                gift.productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TospinoText.body(
                                  context,
                                ).copyWith(fontSize: 11.5, height: 1.2),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(9, 5, 7, 5),
                              decoration: BoxDecoration(
                                color: TospinoColors.resolve(
                                  context,
                                  TospinoColors.surface,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    localizeMiniProgramLabel(context, '立即领取'),
                                    style: TospinoText.meta(context).copyWith(
                                      fontSize: 11,
                                      fontWeight: TospinoText.strong,
                                      color: TospinoColors.resolve(
                                        context,
                                        TospinoColors.ink,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 13,
                                    color: TospinoColors.solidBrand(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 94,
                          height: 94,
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.surface,
                          ),
                          child: gift.productImage.isEmpty
                              ? Icon(
                                  Icons.card_giftcard_rounded,
                                  color: TospinoColors.solidBrand(context),
                                  size: 34,
                                )
                              : Image.network(
                                  gift.productImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.card_giftcard_rounded,
                                    color: TospinoColors.solidBrand(context),
                                    size: 34,
                                  ),
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

class _HomeCategorySection extends StatelessWidget {
  const _HomeCategorySection({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final categories = controller.categories.take(8).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          TospinoSectionHeader(
            title: '按分类选购',
            action: '全部分类',
            onAction: controller.openCategory,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
            decoration: BoxDecoration(
              color: TospinoColors.resolve(context, TospinoColors.surface),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: TospinoColors.resolve(context, TospinoColors.line),
                width: 0.5,
              ),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisExtent: 76,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _HomeCategoryItem(
                  category: category,
                  index: index,
                  onTap: () => controller.openCategory(categoryId: category.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCategoryItem extends StatelessWidget {
  const _HomeCategoryItem({
    required this.category,
    required this.index,
    required this.onTap,
  });

  final TospinoCategory category;
  final int index;
  final VoidCallback onTap;

  static const _colors = <Color>[
    Color(0xFFE3F8FA),
    Color(0xFFFFF1E6),
    Color(0xFFFCECF5),
    Color(0xFFEEF0FF),
    Color(0xFFEAF6E8),
    Color(0xFFFFF3D9),
    Color(0xFFEAF4FF),
    Color(0xFFF4EDFF),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _colors[index % _colors.length];
    final icon = _iconForCategory(category.label);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('tospino-home-category-${category.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior: Clip.antiAlias,
                child: category.iconUrl.isEmpty
                    ? Icon(
                        icon,
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.brandDeep,
                        ),
                        size: 23,
                      )
                    : Image.network(
                        category.iconUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          icon,
                          color: TospinoColors.solidBrand(context),
                          size: 23,
                        ),
                      ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: Text(
                  category.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TospinoText.meta(context).copyWith(
                    color: TospinoColors.resolve(context, TospinoColors.ink),
                    fontSize: 11.5,
                    fontWeight: TospinoText.emphasis,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String label) {
    final value = label.toLowerCase();
    if (_containsAny(value, const ['food', 'grocery', 'market', 'snack'])) {
      return Icons.local_grocery_store_rounded;
    }
    if (_containsAny(value, const ['fashion', 'clothing', 'apparel', 'wear'])) {
      return Icons.checkroom_rounded;
    }
    if (_containsAny(value, const [
      'beauty',
      'cosmetic',
      'personal care',
      'hair',
    ])) {
      return Icons.spa_rounded;
    }
    if (_containsAny(value, const [
      'digital',
      'electrical',
      'electronic',
      'phone',
      'computer',
    ])) {
      return Icons.devices_rounded;
    }
    if (_containsAny(value, const ['office', 'stationery', 'school'])) {
      return Icons.business_center_rounded;
    }
    if (_containsAny(value, const ['baby', 'kid', 'child', 'toy'])) {
      return Icons.child_friendly_rounded;
    }
    if (_containsAny(value, const [
      'building',
      'construction',
      'industrial',
      'hardware',
    ])) {
      return Icons.apartment_rounded;
    }
    if (_containsAny(value, const ['light', 'lamp'])) {
      return Icons.lightbulb_rounded;
    }
    if (_containsAny(value, const ['shoe', 'heel', 'sandal'])) {
      return Icons.directions_walk_rounded;
    }
    if (_containsAny(value, const ['watch', 'jewel', 'accessor'])) {
      return Icons.watch_rounded;
    }
    if (_containsAny(value, const ['sport', 'outdoor'])) {
      return Icons.sports_soccer_rounded;
    }
    if (_containsAny(value, const ['auto', 'car', 'vehicle', 'motor'])) {
      return Icons.directions_car_filled_rounded;
    }
    if (_containsAny(value, const ['book', 'media'])) {
      return Icons.menu_book_rounded;
    }
    return Icons.category_rounded;
  }

  bool _containsAny(String value, List<String> keywords) =>
      keywords.any(value.contains);
}

class _HomeTrustStrip extends StatelessWidget {
  const _HomeTrustStrip();

  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String)>[
      (Icons.local_shipping_outlined, '安心配送'),
      (Icons.verified_user_outlined, '正品保障'),
      (Icons.assignment_return_outlined, '轻松退换'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: TospinoColors.resolve(context, TospinoColors.brandPale),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              if (index > 0)
                Container(
                  width: 0.5,
                  height: 17,
                  color: TospinoColors.solidBrand(
                    context,
                  ).withValues(alpha: 0.22),
                ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[index].$1,
                      size: 16,
                      color: TospinoColors.solidBrand(context),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        localizeMiniProgramLabel(context, items[index].$2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.secondary,
                          ),
                          fontSize: 11,
                          fontWeight: TospinoText.emphasis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeCampaignHub extends StatelessWidget {
  const _HomeCampaignHub({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final campaign in tospinoCampaigns)
        (
          campaign: campaign,
          products: tospinoCampaignProducts(campaign, controller),
        ),
    ];
    final activeCount = entries
        .where((entry) => entry.products.isNotEmpty)
        .length;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: TospinoColors.resolve(context, TospinoColors.line),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: TospinoColors.saleGradient(context),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizeMiniProgramLabel(context, '活动中心'),
                        style: TospinoText.section(
                          context,
                        ).copyWith(fontSize: 16),
                      ),
                      Text(
                        localizeMiniProgramLabel(context, '限时优惠、补贴与品牌专场'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TospinoText.meta(context).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TospinoColors.resolve(
                      context,
                      TospinoColors.brandPale,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$activeCount/${entries.length}',
                    style: TextStyle(
                      color: TospinoColors.solidBrand(context),
                      fontSize: 11.5,
                      fontWeight: TospinoText.emphasis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: entries.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisExtent: 87,
            ),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _HomeCampaignTile(
                campaign: entry.campaign,
                productCount: entry.products.length,
                onTap: () => showTospinoCampaignSheet(
                  context,
                  controller,
                  entry.campaign,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HomeCampaignTile extends StatelessWidget {
  const _HomeCampaignTile({
    required this.campaign,
    required this.productCount,
    required this.onTap,
  });

  final TospinoCampaign campaign;
  final int productCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = productCount > 0;
    final muted = TospinoColors.resolve(context, TospinoColors.muted);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('tospino-home-campaign-${campaign.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: active
                      ? campaign.accent.withValues(alpha: 0.11)
                      : TospinoColors.resolve(
                          context,
                          TospinoColors.surfaceMuted,
                        ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  campaign.icon,
                  color: active ? campaign.accent : muted,
                  size: 21,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                localizeMiniProgramLabel(context, campaign.title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TospinoText.meta(context).copyWith(
                  color: TospinoColors.resolve(
                    context,
                    active ? TospinoColors.ink : TospinoColors.muted,
                  ),
                  fontSize: 11,
                  fontWeight: TospinoText.emphasis,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF28A96B) : muted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      active
                          ? '$productCount'
                          : localizeMiniProgramLabel(context, '活动已结束'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TospinoText.hint(context).copyWith(
                        fontSize: 11,
                        color: active ? const Color(0xFF28A96B) : muted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeDealRail extends StatelessWidget {
  const _HomeDealRail({required this.products, required this.controller});

  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = products.any((product) => product.discountPercent > 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TospinoSectionHeader(
          title: hasDiscount ? '今日精选' : '好物推荐',
          subtitle: hasDiscount ? '大牌好物，限时直降' : '人气商品，精选呈现',
          action: '查看全部',
          onAction: controller.openCategory,
        ),
        SizedBox(
          height: 218,
          child: ListView.separated(
            key: const Key('tospino-home-deal-rail'),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final product = products[index];
              return _HomeDealCard(
                product: product,
                onTap: () => controller.openProduct(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomeDealCard extends StatelessWidget {
  const _HomeDealCard({required this.product, required this.onTap});

  final TospinoProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;
    return SizedBox(
      width: 142,
      child: Material(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('tospino-home-deal-${product.id}'),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  TospinoProductArtwork(
                    product: product,
                    height: 116,
                    radius: 0,
                    hero: false,
                  ),
                  if (discount > 0)
                    Positioned(
                      left: 7,
                      top: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.price,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '-$discount%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: TospinoText.strong,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TospinoText.body(context).copyWith(
                          fontSize: 12.5,
                          fontWeight: TospinoText.emphasis,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      TospinoPriceText(
                        price: product.price,
                        oldPrice: product.oldPrice > product.price
                            ? product.oldPrice
                            : null,
                        size: 15,
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.price,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.sales > 0
                            ? '${product.sales} ${localizeMiniProgramLabel(context, '已售')}'
                            : localizeMiniProgramLabel(context, '免运费'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TospinoText.hint(context).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTrendingRail extends StatelessWidget {
  const _HomeTrendingRail({required this.products, required this.controller});

  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TospinoColors.resolve(context, TospinoColors.surface),
            TospinoColors.resolve(context, TospinoColors.brandPale),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: TospinoColors.resolve(context, TospinoColors.line),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: TospinoColors.saleGradient(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizeMiniProgramLabel(context, '人气榜单'),
                        style: TospinoText.section(
                          context,
                        ).copyWith(fontSize: 16),
                      ),
                      Text(
                        localizeMiniProgramLabel(context, '全站热卖'),
                        style: TospinoText.meta(context).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.trending_up_rounded,
                  size: 21,
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.saleStart,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 214,
            child: ListView.separated(
              key: const Key('tospino-home-trending-rail'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 12),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final product = products[index];
                return _HomeTrendingCard(
                  product: product,
                  rank: index + 1,
                  onTap: () => controller.openProduct(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTrendingCard extends StatelessWidget {
  const _HomeTrendingCard({
    required this.product,
    required this.rank,
    required this.onTap,
  });

  final TospinoProduct product;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Material(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('tospino-home-trending-${product.id}'),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  TospinoProductArtwork(
                    product: product,
                    height: 112,
                    radius: 0,
                    hero: false,
                  ),
                  Positioned(
                    left: 7,
                    top: 7,
                    child: Container(
                      width: 25,
                      height: 25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rank <= 3
                            ? TospinoColors.resolve(
                                context,
                                TospinoColors.saleStart,
                              )
                            : TospinoColors.resolve(context, TospinoColors.ink),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: TospinoText.strong,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TospinoText.body(context).copyWith(
                          fontSize: 12,
                          fontWeight: TospinoText.emphasis,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      TospinoPriceText(
                        price: product.price,
                        oldPrice: product.oldPrice > product.price
                            ? product.oldPrice
                            : null,
                        size: 14,
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.price,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (product.rating > 0) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 10,
                              color: TospinoColors.orange,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: TospinoText.hint(
                                context,
                              ).copyWith(fontSize: 11.5),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            product.sales > 0
                                ? '${product.sales} '
                                      '${localizeMiniProgramLabel(context, '已售')}'
                                : localizeMiniProgramLabel(context, '热卖'),
                            maxLines: 1,
                            style: TospinoText.hint(
                              context,
                            ).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeDiscoveryControls extends StatelessWidget {
  const _HomeDiscoveryControls({required this.sort, required this.onChanged});

  final _HomeSort sort;
  final ValueChanged<_HomeSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
      child: Row(
        children: [
          for (var index = 0; index < _HomeSort.values.length; index++) ...[
            if (index > 0) const SizedBox(width: 7),
            Expanded(
              child: _HomeSortChip(
                sort: _HomeSort.values[index],
                selected: sort == _HomeSort.values[index],
                onTap: () => onChanged(_HomeSort.values[index]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeSortChip extends StatelessWidget {
  const _HomeSortChip({
    required this.sort,
    required this.selected,
    required this.onTap,
  });

  final _HomeSort sort;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? TospinoColors.solidBrand(context)
          : TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(9),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('tospino-home-sort-${sort.name}'),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? TospinoColors.solidBrand(context)
                  : TospinoColors.resolve(context, TospinoColors.line),
              width: 0.8,
            ),
          ),
          child: Text(
            localizeMiniProgramLabel(context, sort.label),
            maxLines: 1,
            style: TospinoText.meta(context).copyWith(
              color: selected
                  ? Colors.white
                  : TospinoColors.resolve(context, TospinoColors.secondary),
              fontSize: 11.5,
              fontWeight: selected ? TospinoText.emphasis : TospinoText.regular,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeProductCard extends StatelessWidget {
  const _HomeProductCard({required this.product, required this.onTap});

  final TospinoProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;
    final detail = product.brand.trim().isNotEmpty
        ? product.brand.trim()
        : product.categoryName.trim();
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('tospino-product-${product.id}'),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: TospinoColors.resolve(
                      context,
                      TospinoColors.imagePlaceholder,
                    ),
                  ),
                  if (product.imageUrl.isNotEmpty)
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: TospinoColors.solidBrand(context),
                                ),
                              ),
                            ),
                      errorBuilder: (_, _, _) =>
                          const Center(child: Icon(Icons.image_outlined)),
                    )
                  else
                    const Center(child: Icon(Icons.image_outlined)),
                  if (discount > 0)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.price,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '-$discount%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: TospinoText.strong,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TospinoText.body(context).copyWith(
                        fontSize: 13,
                        fontWeight: TospinoText.emphasis,
                        height: 1.2,
                      ),
                    ),
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TospinoText.hint(context).copyWith(fontSize: 11),
                      ),
                    ],
                    const Spacer(),
                    TospinoPriceText(
                      price: product.price,
                      oldPrice: product.oldPrice > product.price
                          ? product.oldPrice
                          : null,
                      size: 16,
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.price,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (product.rating > 0) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 11,
                            color: TospinoColors.orange,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TospinoText.meta(
                              context,
                            ).copyWith(fontSize: 11),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Expanded(
                          child: Text(
                            product.sales > 0
                                ? '${product.sales} ${localizeMiniProgramLabel(context, '已售')}'
                                : localizeMiniProgramLabel(context, '现货'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TospinoText.hint(
                              context,
                            ).copyWith(fontSize: 11),
                          ),
                        ),
                      ],
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

class _HomePagingFooter extends StatelessWidget {
  const _HomePagingFooter({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.loadingMoreHome) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: TospinoColors.solidBrand(context),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              localizeMiniProgramLabel(context, '加载更多商品'),
              style: TospinoText.meta(context),
            ),
          ],
        ),
      );
    }
    if (controller.homeMoreError != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
        child: Center(
          child: TextButton(
            onPressed: controller.loadMoreHome,
            child: Text(localizeMiniProgramLabel(context, '加载更多失败，点击重试')),
          ),
        ),
      );
    }
    if (!controller.homeHasMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 25),
        child: Center(
          child: Text(
            localizeMiniProgramLabel(context, '没有更多商品了'),
            style: TospinoText.meta(context),
          ),
        ),
      );
    }
    return const SizedBox(height: 14);
  }
}

class _HomeInlineNotice extends StatelessWidget {
  const _HomeInlineNotice({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.brandPale),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 15,
            color: TospinoColors.solidBrand(context),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TospinoText.meta(context),
            ),
          ),
          TextButton(
            onPressed: () => unawaited(onRetry()),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 5),
            ),
            child: Text(localizeMiniProgramLabel(context, '重试')),
          ),
        ],
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
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: TospinoColors.resolve(context, TospinoColors.brandPale),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_outlined,
                size: 31,
                color: TospinoColors.solidBrand(context),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TospinoText.secondary(context),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => unawaited(onRetry()),
              child: Text(localizeMiniProgramLabel(context, '重试')),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeLoadingPage extends StatelessWidget {
  const _HomeLoadingPage({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('tospino-home-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          _HomeHeader(controller: controller, loading: true),
          Expanded(
            child: SingleChildScrollView(
              key: const Key('tospino-home-loading'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SkeletonBlock(height: 194, radius: 20),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: _SkeletonBlock(height: 72, radius: 14),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: _SkeletonBlock(height: 72, radius: 14),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: _SkeletonBlock(height: 72, radius: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SkeletonBlock(height: 16, width: 140, radius: 5),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const _SkeletonBlock(height: 156, radius: 14),
                            const SizedBox(height: 8),
                            const _SkeletonBlock(height: 92, radius: 14),
                            const SizedBox(height: 8),
                            const _SkeletonBlock(height: 118, radius: 14),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            const _SkeletonBlock(height: 118, radius: 14),
                            const SizedBox(height: 8),
                            const _SkeletonBlock(height: 138, radius: 14),
                            const SizedBox(height: 8),
                            const _SkeletonBlock(height: 102, radius: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.height,
    required this.radius,
    this.width,
  });

  final double height;
  final double radius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.tint),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
