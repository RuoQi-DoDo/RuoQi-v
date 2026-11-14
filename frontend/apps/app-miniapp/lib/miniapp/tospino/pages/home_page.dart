import 'dart:async';

import 'package:flutter/material.dart';

import '../../common/common.dart';
import 'campaigns.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

const double _homeSideInset = 6;

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
                SliverToBoxAdapter(
                  child: _HomeCampaignHub(controller: controller),
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
                _HomeWaterfall(
                  key: const Key('tospino-home-product-grid'),
                  products: recommendations,
                  controller: controller,
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
        padding: const EdgeInsets.fromLTRB(
          _homeSideInset,
          3,
          _homeSideInset,
          9,
        ),
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

class _HomeGiftBanner extends StatelessWidget {
  const _HomeGiftBanner({required this.gift, required this.onTap});

  final TospinoFreeGift gift;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(_homeSideInset, 14, _homeSideInset, 0),
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
      padding: const EdgeInsets.fromLTRB(_homeSideInset, 8, _homeSideInset, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: TospinoColors.resolve(context, TospinoColors.surface),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: TospinoColors.resolve(context, TospinoColors.line),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    localizeMiniProgramLabel(context, '按分类选购'),
                    style: TospinoText.section(context).copyWith(fontSize: 17),
                  ),
                ),
                TextButton(
                  onPressed: controller.openCategory,
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
                        localizeMiniProgramLabel(context, '全部分类'),
                        style: const TextStyle(fontSize: 11),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 17),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisExtent: 92,
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
          ],
        ),
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

class _HomeCampaignHub extends StatelessWidget {
  const _HomeCampaignHub({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final activeEntries = [
      for (final campaign in tospinoCampaigns)
        if (tospinoCampaignProducts(campaign, controller) case final products
            when products.isNotEmpty)
          (campaign: campaign, products: products),
    ];
    if (activeEntries.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        for (final entry in activeEntries)
          KeyedSubtree(
            key: Key('tospino-home-campaign-${entry.campaign.id}'),
            child: switch (entry.campaign.kind) {
              TospinoCampaignKind.groupBuy => _GroupBuyCampaignSection(
                campaign: entry.campaign,
                products: entry.products,
                controller: controller,
              ),
              TospinoCampaignKind.platformMegaSale => _MegaSaleCampaignSection(
                campaign: entry.campaign,
                products: entry.products,
                controller: controller,
              ),
              TospinoCampaignKind.flashSale => _FlashSaleCampaignSection(
                campaign: entry.campaign,
                products: entry.products,
                controller: controller,
              ),
              TospinoCampaignKind.brandFlashSale => _BrandSaleCampaignSection(
                campaign: entry.campaign,
                products: entry.products,
                controller: controller,
              ),
              TospinoCampaignKind.newcomer => _NewcomerCampaignSection(
                campaign: entry.campaign,
                products: entry.products,
                controller: controller,
              ),
              TospinoCampaignKind.clearance => _ClearanceCampaignSection(
                campaign: entry.campaign,
                products: entry.products,
                controller: controller,
              ),
              TospinoCampaignKind.categoryEvent => _CategoryCampaignSection(
                campaign: entry.campaign,
                products: entry.products,
                controller: controller,
              ),
              TospinoCampaignKind.zeroYuan => _ZeroYuanCampaignSection(
                campaign: entry.campaign,
                products: entry.products,
                controller: controller,
              ),
              TospinoCampaignKind.subsidy => _SubsidyCampaignSection(
                campaign: entry.campaign,
                products: entry.products,
                controller: controller,
              ),
              TospinoCampaignKind.shippingDiscount => _ShippingCampaignSection(
                campaign: entry.campaign,
                products: entry.products,
                controller: controller,
              ),
            },
          ),
      ],
    );
  }
}

class _GroupBuyCampaignSection extends StatelessWidget {
  const _GroupBuyCampaignSection({
    required this.campaign,
    required this.products,
    required this.controller,
  });

  final TospinoCampaign campaign;
  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final shown = products.take(2).toList(growable: false);
    return Container(
      margin: const EdgeInsets.fromLTRB(_homeSideInset, 14, _homeSideInset, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF4E8), Color(0xFFFFE2C9)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CampaignHeader(
            campaign: campaign,
            count: products.length,
            foreground: const Color(0xFF6B3411),
            onMore: () =>
                showTospinoCampaignSheet(context, controller, campaign),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 176,
            child: Row(
              children: [
                for (var index = 0; index < shown.length; index++) ...[
                  if (index > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Material(
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.surface,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => controller.openProduct(shown[index]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CampaignProductImage(
                              product: shown[index],
                              width: double.infinity,
                              height: 112,
                              radius: 0,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TospinoPriceText(
                                      price: shown[index].price,
                                      oldPrice:
                                          shown[index].oldPrice >
                                              shown[index].price
                                          ? shown[index].oldPrice
                                          : null,
                                      size: 13,
                                      color: TospinoColors.resolve(
                                        context,
                                        TospinoColors.price,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.groups_rounded,
                                          size: 13,
                                          color: campaign.accent,
                                        ),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            localizeMiniProgramLabel(
                                              context,
                                              '去拼团',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: campaign.accent,
                                              fontSize: 10,
                                              fontWeight: TospinoText.strong,
                                            ),
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
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MegaSaleCampaignSection extends StatelessWidget {
  const _MegaSaleCampaignSection({
    required this.campaign,
    required this.products,
    required this.controller,
  });

  final TospinoCampaign campaign;
  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final shown = products.take(3).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(_homeSideInset, 16, _homeSideInset, 0),
      child: Column(
        children: [
          _CampaignHeader(
            campaign: campaign,
            count: products.length,
            onMore: () =>
                showTospinoCampaignSheet(context, controller, campaign),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _MegaSaleProductTile(
                  product: shown.first,
                  rank: 1,
                  onTap: () => controller.openProduct(shown.first),
                ),
              ),
              if (shown.length > 1) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _MegaSaleCompactTile(
                        product: shown[1],
                        rank: 2,
                        onTap: () => controller.openProduct(shown[1]),
                      ),
                      if (shown.length > 2) ...[
                        const SizedBox(height: 8),
                        _MegaSaleCompactTile(
                          product: shown[2],
                          rank: 3,
                          onTap: () => controller.openProduct(shown[2]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FlashSaleCampaignSection extends StatelessWidget {
  const _FlashSaleCampaignSection({
    required this.campaign,
    required this.products,
    required this.controller,
  });

  final TospinoCampaign campaign;
  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(_homeSideInset, 14, _homeSideInset, 0),
      padding: const EdgeInsets.fromLTRB(10, 12, 0, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1710), Color(0xFF6B2714)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CampaignHeader(
            campaign: campaign,
            count: products.length,
            foreground: Colors.white,
            onMore: () =>
                showTospinoCampaignSheet(context, controller, campaign),
          ),
          const SizedBox(height: 9),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(right: 10),
            itemCount: products.take(4).length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 108,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => controller.openProduct(product),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Row(
                      children: [
                        _CampaignProductImage(
                          product: product,
                          width: 68,
                          height: 94,
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
                                style: TospinoText.meta(context),
                              ),
                              const Spacer(),
                              TospinoPriceText(
                                price: product.price,
                                size: 13,
                                color: campaign.accent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BrandSaleCampaignSection extends StatelessWidget {
  const _BrandSaleCampaignSection({
    required this.campaign,
    required this.products,
    required this.controller,
  });

  final TospinoCampaign campaign;
  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_homeSideInset, 14, _homeSideInset, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CampaignHeader(
            campaign: campaign,
            count: products.length,
            onMore: () =>
                showTospinoCampaignSheet(context, controller, campaign),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              for (var index = 0; index < products.take(2).length; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: _BrandSaleHeroCard(
                    product: products[index],
                    onTap: () => controller.openProduct(products[index]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandSaleHeroCard extends StatelessWidget {
  const _BrandSaleHeroCard({required this.product, required this.onTap});

  final TospinoProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 154,
      child: Material(
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _CampaignProductImage(
                product: product,
                width: double.infinity,
                height: 154,
                radius: 0,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              Positioned(
                left: 9,
                right: 9,
                bottom: 9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.isEmpty
                          ? localizeMiniProgramLabel(context, '品牌')
                          : product.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: TospinoText.strong,
                      ),
                    ),
                    const SizedBox(height: 2),
                    TospinoPriceText(
                      price: product.price,
                      size: 14,
                      color: Colors.white,
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

class _NewcomerCampaignSection extends StatelessWidget {
  const _NewcomerCampaignSection({
    required this.campaign,
    required this.products,
    required this.controller,
  });

  final TospinoCampaign campaign;
  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final product = products.first;
    return Container(
      margin: const EdgeInsets.fromLTRB(_homeSideInset, 14, _homeSideInset, 0),
      height: 176,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE4FBFC), Color(0xFFB9F0F3)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -28,
            top: -38,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.42),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            campaign.icon,
                            color: const Color(0xFF087F89),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            localizeMiniProgramLabel(context, campaign.title),
                            style: const TextStyle(
                              color: Color(0xFF075D64),
                              fontSize: 16,
                              fontWeight: TospinoText.strong,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        localizeMiniProgramLabel(context, campaign.subtitle),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF2F686D),
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: TospinoColors.solidBrand(context),
                        borderRadius: BorderRadius.circular(9),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => showTospinoCampaignSheet(
                            context,
                            controller,
                            campaign,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            child: Text(
                              '${localizeMiniProgramLabel(context, '新人专享')} · ${products.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: TospinoText.strong,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 142,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 18, 14, 18),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => controller.openProduct(product),
                      child: Column(
                        children: [
                          Expanded(
                            child: _CampaignProductImage(
                              product: product,
                              width: double.infinity,
                              height: double.infinity,
                              radius: 0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
                            child: TospinoPriceText(
                              price: product.price,
                              oldPrice: product.oldPrice > product.price
                                  ? product.oldPrice
                                  : null,
                              size: 14,
                              color: const Color(0xFF087F89),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClearanceCampaignSection extends StatelessWidget {
  const _ClearanceCampaignSection({
    required this.campaign,
    required this.products,
    required this.controller,
  });

  final TospinoCampaign campaign;
  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final shown = products.take(4).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(_homeSideInset, 14, _homeSideInset, 0),
      child: Column(
        children: [
          _CampaignHeader(
            campaign: campaign,
            count: products.length,
            onMore: () =>
                showTospinoCampaignSheet(context, controller, campaign),
          ),
          const SizedBox(height: 9),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: shown.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 78,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final product = shown[index];
              return Material(
                color: TospinoColors.resolve(context, TospinoColors.surface),
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => controller.openProduct(product),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Row(
                      children: [
                        _CampaignProductImage(
                          product: product,
                          width: 60,
                          height: 64,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TospinoText.meta(context),
                              ),
                              const Spacer(),
                              TospinoPriceText(
                                price: product.price,
                                size: 13,
                                color: campaign.accent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryCampaignSection extends StatelessWidget {
  const _CategoryCampaignSection({
    required this.campaign,
    required this.products,
    required this.controller,
  });

  final TospinoCampaign campaign;
  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_homeSideInset, 14, _homeSideInset, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CampaignHeader(
            campaign: campaign,
            count: products.length,
            onMore: () =>
                showTospinoCampaignSheet(context, controller, campaign),
          ),
          const SizedBox(height: 9),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: products.take(4).length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 104,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => controller.openProduct(product),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _CampaignProductImage(
                        product: product,
                        width: double.infinity,
                        height: 104,
                        radius: 0,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 7,
                        child: Text(
                          product.categoryName.isEmpty
                              ? product.title
                              : product.categoryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: TospinoText.emphasis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ZeroYuanCampaignSection extends StatelessWidget {
  const _ZeroYuanCampaignSection({
    required this.campaign,
    required this.products,
    required this.controller,
  });

  final TospinoCampaign campaign;
  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final shown = products.take(4).toList(growable: false);
    return Container(
      margin: const EdgeInsets.fromLTRB(_homeSideInset, 14, _homeSideInset, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8DE), Color(0xFFFFE7D7)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: campaign.accent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeMiniProgramLabel(context, campaign.title),
                      style: TospinoText.section(
                        context,
                      ).copyWith(fontSize: 17),
                    ),
                    Text(
                      localizeMiniProgramLabel(context, campaign.subtitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TospinoText.meta(context),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => controller.open(TospinoRoute.freeGift),
                style: TextButton.styleFrom(
                  foregroundColor: campaign.accent,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${products.length} ${localizeMiniProgramLabel(context, '件')}',
                      style: const TextStyle(fontSize: 10.5),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: shown.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 142,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final product = shown[index];
              return Material(
                borderRadius: BorderRadius.circular(13),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => controller.open(TospinoRoute.freeGift),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _CampaignProductImage(
                        product: product,
                        width: double.infinity,
                        height: 142,
                        radius: 0,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: campaign.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '0元',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: TospinoText.strong,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 9,
                        right: 9,
                        bottom: 9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizeMiniProgramLabel(context, '邀请好友领取'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 9.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  localizeMiniProgramLabel(context, '立即领取'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: TospinoText.strong,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SubsidyCampaignSection extends StatelessWidget {
  const _SubsidyCampaignSection({
    required this.campaign,
    required this.products,
    required this.controller,
  });

  final TospinoCampaign campaign;
  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final shown = products.take(3).toList(growable: false);
    return Container(
      margin: const EdgeInsets.fromLTRB(_homeSideInset, 14, _homeSideInset, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _CampaignHeader(
            campaign: campaign,
            count: products.length,
            foreground: const Color(0xFF7A1F35),
            onMore: () =>
                showTospinoCampaignSheet(context, controller, campaign),
          ),
          const SizedBox(height: 7),
          for (var index = 0; index < shown.length; index++) ...[
            InkWell(
              onTap: () => controller.openProduct(shown[index]),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    _CampaignProductImage(
                      product: shown[index],
                      width: 58,
                      height: 58,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        shown[index].title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TospinoText.meta(
                          context,
                        ).copyWith(color: const Color(0xFF5C2836)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TospinoPriceText(
                          price: shown[index].price,
                          oldPrice: shown[index].oldPrice > shown[index].price
                              ? shown[index].oldPrice
                              : null,
                          size: 13,
                          color: campaign.accent,
                        ),
                        if (shown[index].discountPercent > 0)
                          Text(
                            '${localizeMiniProgramLabel(context, '补贴')} -${shown[index].discountPercent}%',
                            style: TextStyle(
                              color: campaign.accent,
                              fontSize: 9,
                              fontWeight: TospinoText.emphasis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (index != shown.length - 1)
              Divider(
                height: 1,
                color: campaign.accent.withValues(alpha: 0.12),
              ),
          ],
        ],
      ),
    );
  }
}

class _ShippingCampaignSection extends StatelessWidget {
  const _ShippingCampaignSection({
    required this.campaign,
    required this.products,
    required this.controller,
  });

  final TospinoCampaign campaign;
  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_homeSideInset, 12, _homeSideInset, 0),
      child: Material(
        color: const Color(0xFFEAF8EF),
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showTospinoCampaignSheet(context, controller, campaign),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: campaign.accent.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(campaign.icon, color: campaign.accent, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizeMiniProgramLabel(context, campaign.title),
                        style: TospinoText.bodyStrong(context),
                      ),
                      Text(
                        '${localizeMiniProgramLabel(context, campaign.subtitle)} · ${products.length}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TospinoText.meta(context),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: _CampaignProductImage(
                    product: products.first,
                    width: 34,
                    height: 34,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: campaign.accent,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CampaignHeader extends StatelessWidget {
  const _CampaignHeader({
    required this.campaign,
    required this.count,
    required this.onMore,
    this.foreground,
  });

  final TospinoCampaign campaign;
  final int count;
  final VoidCallback onMore;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final color =
        foreground ?? TospinoColors.resolve(context, TospinoColors.ink);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: campaign.accent.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(campaign.icon, color: campaign.accent, size: 19),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizeMiniProgramLabel(context, campaign.title),
                style: TospinoText.section(
                  context,
                ).copyWith(fontSize: 16, color: color),
              ),
              Text(
                localizeMiniProgramLabel(context, campaign.subtitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TospinoText.meta(
                  context,
                ).copyWith(color: color.withValues(alpha: 0.68)),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onMore,
          style: TextButton.styleFrom(
            foregroundColor: campaign.accent,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count ${localizeMiniProgramLabel(context, '件')}',
                style: const TextStyle(fontSize: 10.5),
              ),
              const Icon(Icons.chevron_right_rounded, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _MegaSaleProductTile extends StatelessWidget {
  const _MegaSaleProductTile({
    required this.product,
    required this.rank,
    required this.onTap,
  });

  final TospinoProduct product;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _CampaignProductImage(
                  product: product,
                  width: double.infinity,
                  height: 102,
                  radius: 0,
                ),
                Positioned(
                  left: 6,
                  top: 6,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D5E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: TospinoText.strong,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 6, 7, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TospinoText.meta(context).copyWith(height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  TospinoPriceText(
                    price: product.price,
                    size: 14,
                    color: TospinoColors.resolve(context, TospinoColors.price),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MegaSaleCompactTile extends StatelessWidget {
  const _MegaSaleCompactTile({
    required this.product,
    required this.rank,
    required this.onTap,
  });

  final TospinoProduct product;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                Stack(
                  children: [
                    _CampaignProductImage(
                      product: product,
                      width: 58,
                      height: 72,
                    ),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Container(
                        width: 17,
                        height: 17,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4D5E),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: TospinoText.strong,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                        style: TospinoText.meta(context),
                      ),
                      const Spacer(),
                      TospinoPriceText(
                        price: product.price,
                        size: 12,
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

class _CampaignProductImage extends StatelessWidget {
  const _CampaignProductImage({
    required this.product,
    required this.width,
    required this.height,
    this.radius = 9,
  });

  final TospinoProduct product;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: product.imageUrl.isEmpty
            ? ColoredBox(
                color: TospinoColors.resolve(
                  context,
                  TospinoColors.imagePlaceholder,
                ),
                child: const Icon(Icons.image_outlined),
              )
            : Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.imagePlaceholder,
                  ),
                  child: const Icon(Icons.image_outlined),
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
      margin: const EdgeInsets.fromLTRB(_homeSideInset, 16, _homeSideInset, 0),
      padding: const EdgeInsets.fromLTRB(10, 12, 0, 12),
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
            padding: const EdgeInsets.only(right: 8),
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
              padding: const EdgeInsets.only(right: 8),
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
      width: 140,
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
      padding: const EdgeInsets.fromLTRB(_homeSideInset, 18, _homeSideInset, 8),
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
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('tospino-home-sort-${sort.name}'),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 32,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizeMiniProgramLabel(context, sort.label),
                maxLines: 1,
                style: TospinoText.meta(context).copyWith(
                  color: selected
                      ? TospinoColors.solidBrand(context)
                      : TospinoColors.resolve(context, TospinoColors.secondary),
                  fontSize: 12,
                  fontWeight: selected
                      ? TospinoText.emphasis
                      : TospinoText.regular,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 18 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: TospinoColors.solidBrand(context),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeWaterfall extends StatelessWidget {
  const _HomeWaterfall({
    super.key,
    required this.products,
    required this.controller,
  });

  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(_homeSideInset, 2, _homeSideInset, 0),
      sliver: SliverCrossAxisGroup(
        slivers: [
          SliverCrossAxisExpanded(
            flex: 1,
            sliver: SliverPadding(
              padding: const EdgeInsets.only(right: 4),
              sliver: _HomeWaterfallColumn(
                products: products,
                startIndex: 0,
                controller: controller,
              ),
            ),
          ),
          SliverCrossAxisExpanded(
            flex: 1,
            sliver: SliverPadding(
              padding: const EdgeInsets.only(left: 4),
              sliver: _HomeWaterfallColumn(
                products: products,
                startIndex: 1,
                controller: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeWaterfallColumn extends StatelessWidget {
  const _HomeWaterfallColumn({
    required this.products,
    required this.startIndex,
    required this.controller,
  });

  final List<TospinoProduct> products;
  final int startIndex;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final count = (products.length + 1 - startIndex) ~/ 2;
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final productIndex = startIndex + index * 2;
        final product = products[productIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _HomeProductCard(
            product: product,
            artworkHeight: _artworkHeight(product, productIndex),
            onTap: () => controller.openProduct(product),
          ),
        );
      }, childCount: count),
    );
  }

  double _artworkHeight(TospinoProduct product, int index) {
    final seed = product.id.isEmpty
        ? index
        : product.id.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return switch (seed % 5) {
      0 => 146,
      1 => 174,
      2 => 158,
      3 => 188,
      _ => 166,
    };
  }
}

class _HomeProductCard extends StatelessWidget {
  const _HomeProductCard({
    required this.product,
    required this.artworkHeight,
    required this.onTap,
  });

  final TospinoProduct product;
  final double artworkHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;
    final detail = product.brand.trim().isNotEmpty
        ? product.brand.trim()
        : product.categoryName.trim();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('tospino-product-${product.id}'),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: artworkHeight,
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
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-$discount%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: TospinoText.strong,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    if (product.rating > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.56),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFD45C),
                                size: 11,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: TospinoText.emphasis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
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
                        height: 1.22,
                      ),
                    ),
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.surfaceMuted,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TospinoText.hint(
                            context,
                          ).copyWith(fontSize: 9.5),
                        ),
                      ),
                    ],
                    const SizedBox(height: 9),
                    TospinoPriceText(
                      price: product.price,
                      oldPrice: product.oldPrice > product.price
                          ? product.oldPrice
                          : null,
                      size: 17,
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.price,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.sales > 0
                                ? '${product.sales} ${localizeMiniProgramLabel(context, '已售')}'
                                : localizeMiniProgramLabel(context, '现货'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TospinoText.hint(
                              context,
                            ).copyWith(fontSize: 10),
                          ),
                        ),
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 14,
                          color: TospinoColors.solidBrand(context),
                        ),
                      ],
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

class _HomePagingFooter extends StatelessWidget {
  const _HomePagingFooter({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.loadingMoreHome) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 26),
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
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
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
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 25),
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
      margin: const EdgeInsets.fromLTRB(_homeSideInset, 8, _homeSideInset, 0),
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
              padding: const EdgeInsets.fromLTRB(
                _homeSideInset,
                12,
                _homeSideInset,
                24,
              ),
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
