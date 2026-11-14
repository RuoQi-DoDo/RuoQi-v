import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

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
                TospinoProductArtwork(
                  product: product,
                  height: MediaQuery.sizeOf(context).width,
                  radius: 0,
                  hero: false,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: TospinoSurface(
                    radius: 16,
                    padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TospinoPriceText(
                                price: product.price,
                                oldPrice: product.oldPrice > product.price
                                    ? product.oldPrice
                                    : null,
                                size: 25,
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
                                  color: TospinoColors.price.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    TospinoMetrics.tagRadius,
                                  ),
                                ),
                                child: Text(
                                  '-${product.discountPercent}%',
                                  style: const TextStyle(
                                    color: TospinoColors.price,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.title,
                          style: TospinoText.body(context).copyWith(
                            fontSize: 15,
                            fontWeight: TospinoText.emphasis,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (product.brand.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: TospinoColors.resolve(
                                    context,
                                    TospinoColors.brandPale,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    TospinoMetrics.tagRadius,
                                  ),
                                ),
                                child: Text(
                                  product.brand,
                                  style: TextStyle(
                                    color: TospinoColors.solidBrand(context),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            const Icon(
                              Icons.star_rounded,
                              color: TospinoColors.orange,
                              size: 16,
                            ),
                            Text(
                              '${product.rating}',
                              style: TextStyle(
                                color: TospinoColors.resolve(
                                  context,
                                  TospinoColors.secondary,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${product.sales} ${localizeMiniProgramLabel(context, '已售')}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 11),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: TospinoColors.resolve(
                              context,
                              TospinoColors.surfaceMuted,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_shipping_rounded,
                                size: 17,
                                color: TospinoColors.solidBrand(context),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  localizeMiniProgramLabel(
                                    context,
                                    '预计 2-5 个工作日送达',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TospinoText.meta(context).copyWith(
                                    fontWeight: TospinoText.emphasis,
                                    color: TospinoColors.resolve(
                                      context,
                                      TospinoColors.secondary,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                localizeMiniProgramLabel(context, '官方配送'),
                                style: TospinoText.meta(
                                  context,
                                ).copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TospinoSurface(
                    radius: 16,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        _ProtectionItem(
                          icon: Icons.storefront_outlined,
                          label: detail.storeName.isNotEmpty
                              ? detail.storeName
                              : '安心配送',
                        ),
                        _ProtectionItem(
                          icon: Icons.verified_user_outlined,
                          label: '正品保障',
                        ),
                        _ProtectionItem(
                          icon: Icons.assignment_return_outlined,
                          label: '7 天无忧退换',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TospinoSurface(
                    radius: 16,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizeMiniProgramLabel(context, '商品介绍'),
                          style: TospinoText.section(context),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          detail.description.isEmpty
                              ? product.title
                              : detail.description,
                          style: TospinoText.body(context),
                        ),
                        if (detail.galleryUrls.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              TospinoMetrics.imageRadius,
                            ),
                            child: Image.network(
                              detail.galleryUrls.first,
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ],
                        if (detail.servicePromises.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          for (final promise in detail.servicePromises.take(4))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: TospinoColors.brand,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      promise,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
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

class _ProtectionItem extends StatelessWidget {
  const _ProtectionItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: TospinoColors.solidBrand(context), size: 20),
          const SizedBox(height: 5),
          Text(
            localizeMiniProgramLabel(context, label),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            localizeMiniProgramLabel(context, '猜你喜欢'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 11),
        SizedBox(
          height: 240,
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
                  artworkHeight: 112,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(
          top: BorderSide(
            color: TospinoColors.resolve(context, TospinoColors.line),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            InkWell(
              key: const Key('tospino-product-favorite'),
              onTap: controller.busy
                  ? null
                  : () async {
                      try {
                        final active = await controller.toggleFavorite(product);
                        if (!context.mounted) return;
                        if (active || controller.isFavorite(product.id)) {
                          showTospinoToast(context, '已收藏');
                        }
                      } catch (error) {
                        if (context.mounted) {
                          showTospinoToast(context, error.toString());
                        }
                      }
                    },
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 42,
                height: 44,
                child: Icon(
                  favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: favorite
                      ? TospinoColors.price
                      : TospinoColors.resolve(context, TospinoColors.secondary),
                  size: 23,
                ),
              ),
            ),
            InkWell(
              onTap: () => controller.switchTab(2),
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 42,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.secondary,
                      ),
                      size: 23,
                    ),
                    if (controller.cartCount > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 17,
                            minHeight: 17,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: TospinoColors.price,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${controller.cartCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: TospinoText.strong,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Opacity(
                opacity: controller.busy ? 0.5 : 1,
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  child: Ink(
                    height: 50,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFB43F), Color(0xFFFF8A32)],
                      ),
                    ),
                    child: InkWell(
                      key: const Key('tospino-product-add-cart'),
                      onTap: controller.busy
                          ? null
                          : () async {
                              try {
                                final added = await controller.addToCart(
                                  product,
                                );
                                if (added && context.mounted) {
                                  showTospinoToast(context, '已加入购物车');
                                }
                              } catch (error) {
                                if (context.mounted) {
                                  showTospinoToast(context, error.toString());
                                }
                              }
                            },
                      child: Center(
                        child: Text(
                          localizeMiniProgramLabel(context, '加入购物车'),
                          style: const TextStyle(
                            color: Color(0xFF3B2400),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Opacity(
                opacity: controller.busy ? 0.5 : 1,
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  child: Ink(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: TospinoColors.brandGradient(context),
                    ),
                    child: InkWell(
                      key: const Key('tospino-product-buy-now'),
                      onTap: controller.busy
                          ? null
                          : () async {
                              try {
                                await controller.buyNow(product);
                              } catch (error) {
                                if (context.mounted) {
                                  showTospinoToast(context, error.toString());
                                }
                              }
                            },
                      child: Center(
                        child: Text(
                          localizeMiniProgramLabel(context, '立即购买'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
