import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoCartPage extends StatelessWidget {
  const TospinoCartPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final lines = controller.cartLines;
    return ColoredBox(
      key: const Key('tospino-cart-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          const _CartHeader(),
          _CartTabs(controller: controller),
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: TospinoColors.resolve(context, TospinoColors.line),
          ),
          Expanded(
            child: controller.loadingCart && lines.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : controller.cartError != null && lines.isEmpty
                ? _CartState(
                    message: controller.cartError!,
                    onRetry: controller.refreshCart,
                  )
                : lines.isEmpty
                ? _EmptyCart(controller: controller)
                : RefreshIndicator(
                    onRefresh: controller.refreshCart,
                    child: ListView(
                      key: const Key('tospino-cart-list'),
                      padding: const EdgeInsets.only(top: 10, bottom: 4),
                      children: [
                        for (final line in lines)
                          _CartLineCard(controller: controller, line: line),
                        Container(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.surface,
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                size: 16,
                                color: TospinoColors.solidBrand(context),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  localizeMiniProgramLabel(context, '服务保障'),
                                  style: TospinoText.meta(context),
                                ),
                              ),
                              Text(
                                localizeMiniProgramLabel(context, '7 天无忧退换'),
                                style: TospinoText.meta(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          _CartCheckoutBar(controller: controller),
        ],
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      child: SizedBox(
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              localizeMiniProgramLabel(context, '购物车'),
              style: TospinoText.pageTitle(
                context,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartTabs extends StatelessWidget {
  const _CartTabs({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    const filters = TospinoCartFilter.values;
    final counts = controller.cartCounts;
    final totals = [
      counts.allTotal,
      counts.priceCutTotal,
      counts.oftenBuyTotal,
    ];
    return ColoredBox(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 5, 12, 7),
          child: Row(
            children: [
              for (var index = 0; index < filters.length; index++) ...[
                if (index > 0) const SizedBox(width: 7),
                Expanded(
                  child: Material(
                    color: controller.cartFilter == filters[index]
                        ? TospinoColors.solidBrand(context)
                        : TospinoColors.resolve(
                            context,
                            TospinoColors.surfaceMuted,
                          ),
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: Key(
                        'tospino-cart-filter-${filters[index].queryType}',
                      ),
                      onTap: () => controller.selectCartFilter(filters[index]),
                      child: Center(
                        child: Text(
                          _filterLabel(context, filters[index], totals[index]),
                          maxLines: 1,
                          style: TextStyle(
                            color: controller.cartFilter == filters[index]
                                ? Colors.white
                                : TospinoColors.resolve(
                                    context,
                                    TospinoColors.secondary,
                                  ),
                            fontSize: 12,
                            fontWeight: controller.cartFilter == filters[index]
                                ? TospinoText.emphasis
                                : TospinoText.regular,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _filterLabel(
    BuildContext context,
    TospinoCartFilter filter,
    int total,
  ) {
    final label = localizeMiniProgramLabel(context, switch (filter) {
      TospinoCartFilter.all => '全部',
      TospinoCartFilter.priceCut => '降价',
      TospinoCartFilter.oftenBuy => '常买',
    });
    return total > 0 ? '$label($total)' : label;
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({required this.controller, required this.line});

  final TospinoAppController controller;
  final TospinoCartLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 9),
      padding: const EdgeInsets.fromLTRB(8, 11, 12, 8),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: TospinoColors.resolve(context, TospinoColors.ink),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    line.storeName.isEmpty ? 'Tospino' : line.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TospinoText.bodyStrong(context),
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                key: Key('tospino-cart-select-${line.skuId}'),
                value: line.selected,
                onChanged: line.valid
                    ? (_) => controller.toggleCartSelection(line.skuId)
                    : null,
                activeColor: TospinoColors.solidBrand(context),
                shape: const CircleBorder(),
                visualDensity: VisualDensity.compact,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(TospinoMetrics.imageRadius),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: line.imageUrl.isEmpty
                      ? ColoredBox(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.imagePlaceholder,
                          ),
                          child: const Icon(Icons.image_outlined),
                        )
                      : Image.network(
                          line.imageUrl,
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
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 126,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TospinoText.body(context),
                      ),
                      if (line.attributes.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TospinoColors.resolve(
                              context,
                              TospinoColors.surfaceMuted,
                            ),
                            borderRadius: BorderRadius.circular(
                              TospinoMetrics.tagRadius,
                            ),
                          ),
                          child: Text(
                            line.attributes.join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TospinoText.hint(context),
                          ),
                        ),
                      const SizedBox(height: 4),
                      _OftenBuyButton(controller: controller, line: line),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: TospinoPriceText(
                              price: line.price,
                              size: 16,
                              color: TospinoColors.resolve(
                                context,
                                TospinoColors.price,
                              ),
                            ),
                          ),
                          _QuantityStepper(
                            skuId: line.skuId,
                            quantity: line.quantity,
                            controller: controller,
                          ),
                        ],
                      ),
                    ],
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

class _OftenBuyButton extends StatelessWidget {
  const _OftenBuyButton({required this.controller, required this.line});

  final TospinoAppController controller;
  final TospinoCartLine line;

  @override
  Widget build(BuildContext context) {
    final selected = line.isOftenBuy;
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        key: Key('tospino-cart-often-${line.skuId}'),
        borderRadius: BorderRadius.circular(TospinoMetrics.tagRadius),
        onTap: () async {
          try {
            final changed = await controller.toggleOftenBuy(line.skuId);
            if (!context.mounted || !changed) return;
            showTospinoToast(context, '操作成功');
          } catch (error) {
            if (context.mounted) showTospinoToast(context, '$error');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: selected
                ? TospinoColors.resolve(
                    context,
                    TospinoColors.brandPale,
                  ).withValues(alpha: 0.7)
                : TospinoColors.resolve(context, TospinoColors.surfaceMuted),
            borderRadius: BorderRadius.circular(TospinoMetrics.tagRadius),
            border: Border.all(
              color: selected
                  ? TospinoColors.solidBrand(context)
                  : TospinoColors.resolve(context, TospinoColors.lineStrong),
              width: 0.5,
            ),
          ),
          child: Text(
            localizeMiniProgramLabel(context, selected ? '已常买' : '设为常买'),
            style: TospinoText.hint(context).copyWith(
              color: selected
                  ? TospinoColors.solidBrand(context)
                  : TospinoColors.resolve(context, TospinoColors.secondary),
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.skuId,
    required this.quantity,
    required this.controller,
  });

  final String skuId;
  final int quantity;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final background = TospinoColors.resolve(context, TospinoColors.background);
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            key: Key('tospino-cart-decrement-$skuId'),
            onTap: () => controller.decrementCart(skuId),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(9),
            ),
            child: SizedBox(
              width: 28,
              height: 28,
              child: Icon(
                Icons.remove_rounded,
                size: 16,
                color: TospinoColors.resolve(context, TospinoColors.secondary),
              ),
            ),
          ),
          SizedBox(
            width: 23,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TospinoColors.resolve(context, TospinoColors.ink),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            key: Key('tospino-cart-increment-$skuId'),
            onTap: () => controller.incrementCart(skuId),
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(9),
            ),
            child: SizedBox(
              width: 28,
              height: 28,
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: TospinoColors.resolve(context, TospinoColors.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartCheckoutBar extends StatelessWidget {
  const _CartCheckoutBar({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final lines = controller.cartLines;
    final allSelected =
        lines.isNotEmpty && lines.every((line) => line.selected);
    final selectedCount = controller.selectedCartLines.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
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
            Checkbox(
              value: allSelected,
              onChanged: (selected) =>
                  controller.selectAllCart(selected ?? false),
              activeColor: TospinoColors.solidBrand(context),
              shape: const CircleBorder(),
              visualDensity: VisualDensity.compact,
            ),
            Text(
              localizeMiniProgramLabel(context, '全选'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizeMiniProgramLabel(context, '合计'),
                  style: TospinoText.body(context),
                ),
                const SizedBox(width: 5),
                TospinoPriceText(
                  price: controller.cartTotal,
                  size: 18,
                  color: TospinoColors.resolve(context, TospinoColors.price),
                ),
              ],
            ),
            const SizedBox(width: 10),
            TospinoGradientButton(
              key: const Key('tospino-cart-checkout'),
              label: '结算($selectedCount)',
              onPressed: selectedCount == 0 || controller.loadingCheckout
                  ? null
                  : () => controller.startCheckout(),
              height: 48,
              expand: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final products = controller.homeProducts.take(4).toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 260,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 132,
                  height: 112,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.brandPale,
                          ).withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 54,
                        color: TospinoColors.solidBrand(context),
                      ),
                      Positioned(
                        right: 8,
                        top: 12,
                        child: Icon(
                          Icons.auto_awesome,
                          size: 18,
                          color: TospinoColors.solidBrand(context),
                        ),
                      ),
                      Positioned(
                        left: 7,
                        bottom: 16,
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: TospinoColors.solidBrand(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  localizeMiniProgramLabel(context, '购物车空空的~'),
                  style: TextStyle(
                    color: TospinoColors.solidBrand(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => controller.switchTab(0),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TospinoColors.solidBrand(context),
                    side: BorderSide(color: TospinoColors.solidBrand(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        TospinoMetrics.controlRadius,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    localizeMiniProgramLabel(context, '随便逛逛'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (products.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.lineStrong,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.favorite_rounded,
                    color: TospinoColors.price,
                    size: 18,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    localizeMiniProgramLabel(context, '你可能还喜欢'),
                    style: TospinoText.body(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Divider(
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.lineStrong,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = products[index];
                return TospinoProductTile(
                  product: product,
                  artworkHeight: 126,
                  onTap: () => controller.openProduct(product),
                );
              }, childCount: products.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.64,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _CartState extends StatelessWidget {
  const _CartState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
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
