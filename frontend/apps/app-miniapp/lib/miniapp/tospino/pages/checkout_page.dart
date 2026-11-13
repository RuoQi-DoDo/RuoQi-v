import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoCheckoutPage extends StatelessWidget {
  const TospinoCheckoutPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final address = controller.defaultAddress;
    final saleInfo = controller.saleInfo;
    final lines = controller.checkoutLines;
    if (controller.loadingCheckout && saleInfo == null) {
      return const Center(
        key: Key('tospino-checkout-page'),
        child: CircularProgressIndicator(),
      );
    }
    if (saleInfo == null || address == null) {
      return Center(
        key: const Key('tospino-checkout-page'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 52,
                color: TospinoColors.resolve(context, TospinoColors.hint),
              ),
              const SizedBox(height: 12),
              Text(
                controller.checkoutError ??
                    localizeMiniProgramLabel(context, '暂无订单'),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: controller.loadCheckout,
                child: Text(localizeMiniProgramLabel(context, '重试')),
              ),
            ],
          ),
        ),
      );
    }
    return ColoredBox(
      key: const Key('tospino-checkout-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              children: [
                _AddressCard(address: address, controller: controller),
                const SizedBox(height: 10),
                _CheckoutCard(
                  child: Column(
                    children: [
                      for (var index = 0; index < lines.length; index++) ...[
                        _CheckoutLine(line: lines[index]),
                        if (index != lines.length - 1)
                          Divider(
                            height: 21,
                            color: TospinoColors.resolve(
                              context,
                              TospinoColors.line,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _CheckoutCard(
                  child: Column(
                    children: [
                      _CheckoutRow(
                        label: '配送方式',
                        value: '标准配送',
                        valueColor: TospinoColors.resolve(
                          context,
                          TospinoColors.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          localizeMiniProgramLabel(context, '预计 2-5 个工作日送达'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Divider(
                        height: 22,
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.line,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            color: TospinoColors.brand,
                            size: 21,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              localizeMiniProgramLabel(
                                context,
                                saleInfo.isCashDelivery ? '货到付款' : '在线支付',
                              ),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: TospinoColors.brand,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _CheckoutCard(
                  child: Column(
                    children: [
                      _CheckoutRow(
                        label: '商品合计',
                        value:
                            'GH₵${saleInfo.totalProductAmount.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 10),
                      _CheckoutRow(
                        label: '配送费',
                        value: 'GH₵${saleInfo.totalFreight.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 10),
                      _CheckoutRow(
                        label: '优惠',
                        value:
                            '-GH₵${saleInfo.totalDiscount.toStringAsFixed(0)}',
                        valueColor: TospinoColors.price,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizeMiniProgramLabel(context, '实付款'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TospinoPriceText(price: saleInfo.payable, size: 23),
                      ],
                    ),
                  ),
                  FilledButton(
                    key: const Key('tospino-place-order'),
                    onPressed: controller.busy
                        ? null
                        : () async {
                            try {
                              final ids = await controller.submitOrder();
                              if (ids.isEmpty && context.mounted) {
                                showTospinoToast(context, '订单提交成功');
                              }
                            } catch (error) {
                              if (context.mounted) {
                                showTospinoToast(context, error.toString());
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: TospinoColors.solidBrand(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    child: Text(
                      localizeMiniProgramLabel(context, '提交订单'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.controller});

  final TospinoAddress address;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: controller.openAddress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.brandPale,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: TospinoColors.solidBrand(context),
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            address.phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address.completeAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: TospinoColors.solidBrand(context),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    localizeMiniProgramLabel(context, '默认地址'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Icon(
                Icons.chevron_right_rounded,
                color: TospinoColors.resolve(context, TospinoColors.hint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _CheckoutLine extends StatelessWidget {
  const _CheckoutLine({required this.line});

  final TospinoCartLine line;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: SizedBox(
            width: 76,
            height: 76,
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
        const SizedBox(width: 11),
        Expanded(
          child: SizedBox(
            height: 76,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: TospinoPriceText(price: line.price, size: 16),
                    ),
                    Text(
                      '×${line.quantity}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutRow extends StatelessWidget {
  const _CheckoutRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          localizeMiniProgramLabel(context, label),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          localizeMiniProgramLabel(context, value),
          style: TextStyle(
            color:
                valueColor ?? TospinoColors.resolve(context, TospinoColors.ink),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
