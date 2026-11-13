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
          Expanded(
            child: controller.loadingCart && lines.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : controller.cartError != null && lines.isEmpty
                ? _CartState(
                    message: controller.cartError!,
                    onRetry: controller.refreshCart,
                  )
                : lines.isEmpty
                ? _EmptyCart(onShop: () => controller.switchTab(0))
                : RefreshIndicator(
                    onRefresh: controller.refreshCart,
                    child: ListView(
                      key: const Key('tospino-cart-list'),
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
                          child: Row(
                            children: [
                              Text(
                                localizeMiniProgramLabel(context, '购物车'),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 7),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: TospinoColors.resolve(
                                    context,
                                    TospinoColors.brandPale,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${controller.cartCount}',
                                  style: TextStyle(
                                    color: TospinoColors.solidBrand(context),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final line in lines) ...[
                          _CartLineCard(controller: controller, line: line),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 4),
                        Row(
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
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              localizeMiniProgramLabel(context, '7 天无忧退换'),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          if (lines.isNotEmpty) _CartCheckoutBar(controller: controller),
        ],
      ),
    );
  }
}

class _CartLineCard extends StatelessWidget {
  const _CartLineCard({required this.controller, required this.line});

  final TospinoAppController controller;
  final TospinoCartLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 11, 10),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
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
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 88,
              height: 88,
              child: line.imageUrl.isEmpty
                  ? const ColoredBox(
                      color: TospinoColors.line,
                      child: Icon(Icons.shopping_bag_outlined),
                    )
                  : Image.network(
                      line.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: TospinoColors.line,
                        child: Icon(Icons.shopping_bag_outlined),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 88,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TospinoColors.resolve(context, TospinoColors.ink),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  if (line.attributes.isNotEmpty)
                    Text(
                      line.attributes.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: TospinoPriceText(price: line.price, size: 17),
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
                fontSize: 11.5,
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
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizeMiniProgramLabel(context, '合计'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 5),
                    TospinoPriceText(price: controller.cartTotal, size: 20),
                  ],
                ),
                Text(
                  '${localizeMiniProgramLabel(context, '已选')} '
                  '$selectedCount '
                  '${localizeMiniProgramLabel(context, '件商品')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(width: 10),
            FilledButton(
              key: const Key('tospino-cart-checkout'),
              onPressed: selectedCount == 0 || controller.loadingCheckout
                  ? null
                  : () => controller.startCheckout(),
              style: FilledButton.styleFrom(
                backgroundColor: TospinoColors.solidBrand(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                localizeMiniProgramLabel(context, '去结算'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: TospinoColors.resolve(context, TospinoColors.brandPale),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: TospinoColors.solidBrand(context),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              localizeMiniProgramLabel(context, '购物车还是空的'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onShop,
              style: FilledButton.styleFrom(
                backgroundColor: TospinoColors.solidBrand(context),
                foregroundColor: Colors.white,
              ),
              child: Text(localizeMiniProgramLabel(context, '去逛逛')),
            ),
          ],
        ),
      ),
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
