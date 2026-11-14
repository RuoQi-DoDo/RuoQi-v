import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';
import '../widgets/product_gallery.dart';
import '../widgets/product_html_view.dart';
import '../widgets/tospino_fulfillment_card.dart';

class TospinoProductPage extends StatelessWidget {
  const TospinoProductPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final detail = controller.productDetail;
    if (controller.loadingDetail && detail == null) {
      return const Center(
        key: Key('tospino-product-page'),
        child: CircularProgressIndicator(),
      );
    }
    if (detail == null) {
      return Center(
        key: const Key('tospino-product-page'),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                controller.detailError ??
                    localizeMiniProgramLabel(context, '暂无匹配商品'),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () {
                  final id = controller.selectedProductId;
                  if (id != null) {
                    controller.openProduct(
                      TospinoProduct(id: id, title: '', price: 0),
                    );
                  }
                },
                child: Text(localizeMiniProgramLabel(context, '重试')),
              ),
            ],
          ),
        ),
      );
    }
    final product = detail.product;
    final favorite = controller.isFavorite(product.id);
    return ColoredBox(
      key: const Key('tospino-product-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                TospinoProductGallery(
                  key: const Key('tospino-product-gallery'),
                  product: product,
                  imageUrls: detail.galleryUrls,
                  height: MediaQuery.sizeOf(context).width,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TospinoSurface(
                    radius: 22,
                    padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _PremiumEyebrow(
                              icon: Icons.auto_awesome_rounded,
                              label: product.isFbt ? 'Tospino 精选' : '品质好物',
                            ),
                            const Spacer(),
                            if (product.rating > 0)
                              _ProductRating(
                                rating: product.rating,
                                sales: product.sales,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TospinoPriceText(
                                price: product.price,
                                oldPrice: product.oldPrice > product.price
                                    ? product.oldPrice
                                    : null,
                                size: 30,
                                color: TospinoColors.resolve(
                                  context,
                                  TospinoColors.price,
                                ),
                              ),
                            ),
                            if (product.discountPercent > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: TospinoColors.saleGradient(context),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  'SAVE ${product.discountPercent}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: TospinoText.strong,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.title,
                          style: TospinoText.body(context).copyWith(
                            fontSize: 16.5,
                            fontWeight: TospinoText.emphasis,
                            height: 1.42,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (product.brand.isNotEmpty)
                              _ProductMetaPill(
                                icon: Icons.sell_outlined,
                                label: product.brand,
                                emphasized: true,
                              ),
                            _ProductMetaPill(
                              icon: Icons.verified_user_outlined,
                              label: '正品保障',
                            ),
                            _ProductMetaPill(
                              icon: Icons.local_shipping_outlined,
                              label: product.isFbt ? 'FBT 发货' : 'FBM 发货',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TospinoFulfillmentCard(
                  key: const Key('tospino-product-fulfillment'),
                  detail: detail,
                  destination: controller.defaultAddress,
                ),
                const SizedBox(height: 10),
                _StoreServiceCard(
                  storeName: detail.storeName.isNotEmpty
                      ? detail.storeName
                      : 'Tospino',
                ),
                const SizedBox(height: 10),
                _ProductDescriptionCard(product: product, detail: detail),
                const SizedBox(height: 10),
                _ProductRecommendations(
                  controller: controller,
                  currentProductId: product.id,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _ProductActionBar(
            controller: controller,
            product: product,
            favorite: favorite,
          ),
        ],
      ),
    );
  }
}

class _PremiumEyebrow extends StatelessWidget {
  const _PremiumEyebrow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final brand = TospinoColors.solidBrand(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TospinoColors.resolve(context, TospinoColors.brandPale),
            TospinoColors.resolve(context, TospinoColors.surface),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: brand),
          const SizedBox(width: 5),
          Text(
            localizeMiniProgramLabel(context, label),
            style: TextStyle(
              color: brand,
              fontSize: 10.5,
              fontWeight: TospinoText.strong,
              letterSpacing: 0.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRating extends StatelessWidget {
  const _ProductRating({required this.rating, required this.sales});

  final double rating;
  final int sales;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surfaceMuted),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: TospinoColors.orange),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TospinoText.meta(context).copyWith(
              color: TospinoColors.resolve(context, TospinoColors.ink),
              fontWeight: TospinoText.strong,
            ),
          ),
          Container(
            width: 1,
            height: 11,
            margin: const EdgeInsets.symmetric(horizontal: 7),
            color: TospinoColors.resolve(context, TospinoColors.lineStrong),
          ),
          Text(
            '$sales ${localizeMiniProgramLabel(context, '已售')}',
            style: TospinoText.meta(context).copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

class _ProductMetaPill extends StatelessWidget {
  const _ProductMetaPill({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final brand = TospinoColors.solidBrand(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: emphasized
            ? TospinoColors.resolve(context, TospinoColors.brandPale)
            : TospinoColors.resolve(context, TospinoColors.surfaceMuted),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: emphasized
                ? brand
                : TospinoColors.resolve(context, TospinoColors.muted),
          ),
          const SizedBox(width: 5),
          Text(
            localizeMiniProgramLabel(context, label),
            style: TospinoText.meta(context).copyWith(
              color: emphasized
                  ? brand
                  : TospinoColors.resolve(context, TospinoColors.secondary),
              fontSize: 10.5,
              fontWeight: TospinoText.emphasis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreServiceCard extends StatelessWidget {
  const _StoreServiceCard({required this.storeName});

  final String storeName;

  @override
  Widget build(BuildContext context) {
    final brand = TospinoColors.solidBrand(context);
    return TospinoSurface(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 15),
      border: true,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: TospinoColors.brandGradient(context),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: brand.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TospinoText.bodyStrong(
                        context,
                      ).copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 13, color: brand),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            localizeMiniProgramLabel(context, '官方店铺 · 品质认证'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TospinoText.meta(
                              context,
                            ).copyWith(fontSize: 10.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.brandPale,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: brand,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: TospinoColors.resolve(context, TospinoColors.line),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _ServiceBenefit(
                icon: Icons.verified_user_outlined,
                label: '正品保障',
              ),
              _ServiceBenefit(
                icon: Icons.assignment_return_outlined,
                label: '7 天无忧退换',
              ),
              _ServiceBenefit(icon: Icons.lock_outline_rounded, label: '安全支付'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceBenefit extends StatelessWidget {
  const _ServiceBenefit({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: TospinoColors.solidBrand(context)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              localizeMiniProgramLabel(context, label),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TospinoText.meta(context).copyWith(fontSize: 10.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDescriptionCard extends StatelessWidget {
  const _ProductDescriptionCard({required this.product, required this.detail});

  final TospinoProduct product;
  final TospinoProductDetail detail;

  @override
  Widget build(BuildContext context) {
    return TospinoSurface(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProductSectionHeader(
            title: '商品介绍',
            eyebrow: 'PRODUCT DETAILS',
            icon: Icons.menu_book_outlined,
          ),
          const SizedBox(height: 16),
          TospinoProductHtmlView(
            description: detail.description,
            fallback: product.title,
          ),
          if (detail.servicePromises.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: TospinoColors.resolve(context, TospinoColors.line),
            ),
            const SizedBox(height: 13),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (
                  var index = 0;
                  index < detail.servicePromises.take(4).length;
                  index++
                ) ...[
                  _PromiseItem(label: detail.servicePromises[index]),
                  if (index < detail.servicePromises.take(4).length - 1)
                    const SizedBox(height: 7),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductSectionHeader extends StatelessWidget {
  const _ProductSectionHeader({
    required this.title,
    required this.eyebrow,
    required this.icon,
  });

  final String title;
  final String eyebrow;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final brand = TospinoColors.solidBrand(context);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: TospinoColors.resolve(context, TospinoColors.brandPale),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: brand, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizeMiniProgramLabel(context, title),
                style: TospinoText.section(context).copyWith(fontSize: 17),
              ),
              const SizedBox(height: 2),
              Text(
                eyebrow,
                style: TospinoText.hint(context).copyWith(
                  fontSize: 9,
                  fontWeight: TospinoText.emphasis,
                  letterSpacing: 1.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PromiseItem extends StatelessWidget {
  const _PromiseItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surfaceMuted),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: TospinoColors.brand,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TospinoText.meta(context).copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRecommendations extends StatelessWidget {
  const _ProductRecommendations({
    required this.controller,
    required this.currentProductId,
  });

  final TospinoAppController controller;
  final String currentProductId;

  @override
  Widget build(BuildContext context) {
    final products = controller.homeProducts
        .where((product) => product.id != currentProductId)
        .take(6)
        .toList();
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
          child: const _ProductSectionHeader(
            title: '猜你喜欢',
            eyebrow: 'MORE TO EXPLORE',
            icon: Icons.explore_outlined,
          ),
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 248,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 154,
                child: TospinoProductTile(
                  product: product,
                  artworkHeight: 118,
                  onTap: () => controller.openProduct(product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductActionBar extends StatelessWidget {
  const _ProductActionBar({
    required this.controller,
    required this.product,
    required this.favorite,
  });

  final TospinoAppController controller;
  final TospinoProduct product;
  final bool favorite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TospinoColors.resolve(context, TospinoColors.surface),
              TospinoColors.resolve(context, TospinoColors.surfaceMuted),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: TospinoColors.resolve(context, TospinoColors.line),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Container(
                width: 92,
                height: 46,
                decoration: BoxDecoration(
                  color: TospinoColors.resolve(context, TospinoColors.surface),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: TospinoColors.resolve(context, TospinoColors.line),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        key: const Key('tospino-product-favorite'),
                        onTap: controller.busy
                            ? null
                            : () async {
                                try {
                                  final active = await controller
                                      .toggleFavorite(product);
                                  if (!context.mounted) return;
                                  if (active ||
                                      controller.isFavorite(product.id)) {
                                    showTospinoToast(context, '已收藏');
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    showTospinoToast(context, error.toString());
                                  }
                                }
                              },
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(15),
                        ),
                        child: Icon(
                          favorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: favorite
                              ? TospinoColors.price
                              : TospinoColors.resolve(
                                  context,
                                  TospinoColors.secondary,
                                ),
                          size: 21,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: TospinoColors.resolve(context, TospinoColors.line),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.switchTab(2),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(15),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: TospinoColors.resolve(
                                context,
                                TospinoColors.secondary,
                              ),
                              size: 21,
                            ),
                            if (controller.cartCount > 0)
                              Positioned(
                                right: 3,
                                top: 4,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 17,
                                    minHeight: 17,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TospinoColors.price,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${controller.cartCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: TospinoText.strong,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProductActionButton(
                  actionKey: const Key('tospino-product-add-cart'),
                  label: localizeMiniProgramLabel(context, '加入购物车'),
                  icon: Icons.add_shopping_cart_rounded,
                  enabled: !controller.busy,
                  onTap: () async {
                    try {
                      final added = await controller.addToCart(product);
                      if (added && context.mounted) {
                        showTospinoToast(context, '已加入购物车');
                      }
                    } catch (error) {
                      if (context.mounted) {
                        showTospinoToast(context, error.toString());
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProductActionButton(
                  actionKey: const Key('tospino-product-buy-now'),
                  label: localizeMiniProgramLabel(context, '立即购买'),
                  icon: Icons.bolt_rounded,
                  primary: true,
                  enabled: !controller.busy,
                  onTap: () async {
                    try {
                      await controller.buyNow(product);
                    } catch (error) {
                      if (context.mounted) {
                        showTospinoToast(context, error.toString());
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductActionButton extends StatelessWidget {
  const _ProductActionButton({
    required this.actionKey,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.primary = false,
  });

  final Key actionKey;
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final brand = TospinoColors.solidBrand(context);
    final foreground = primary
        ? Colors.white
        : TospinoColors.resolve(context, TospinoColors.ink);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          height: 46,
          decoration: BoxDecoration(
            gradient: primary
                ? TospinoColors.brandGradient(context)
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      TospinoColors.resolve(context, TospinoColors.brandPale),
                      TospinoColors.resolve(context, TospinoColors.surface),
                    ],
                  ),
            borderRadius: BorderRadius.circular(15),
            border: primary
                ? null
                : Border.all(color: brand.withValues(alpha: 0.28)),
          ),
          child: InkWell(
            key: actionKey,
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 17, color: foreground),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14.5,
                        fontWeight: TospinoText.strong,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
