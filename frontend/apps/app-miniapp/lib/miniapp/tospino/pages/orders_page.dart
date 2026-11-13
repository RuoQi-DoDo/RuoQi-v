import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoOrdersPage extends StatelessWidget {
  const TospinoOrdersPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.orderFilter;
    final orders = controller.orders;
    return ColoredBox(
      key: const Key('tospino-orders-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          SizedBox(
            height: 51,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              children: [
                _StatusChip(
                  label: '全部订单',
                  selected: selected == null,
                  onTap: controller.clearOrderFilter,
                ),
                for (final status in TospinoOrderStatus.values)
                  _StatusChip(
                    label: status.label,
                    selected: selected == status,
                    onTap: () => controller.openOrders(status),
                  ),
              ],
            ),
          ),
          Expanded(
            child: controller.loadingOrders && orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : controller.ordersError != null
                ? _OrdersState(
                    message: controller.ordersError!,
                    onRetry: controller.loadOrders,
                  )
                : orders.isEmpty
                ? Center(
                    key: const Key('tospino-orders-empty'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 58,
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.hint,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localizeMiniProgramLabel(context, '暂无订单'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => controller.switchTab(0),
                          child: Text(localizeMiniProgramLabel(context, '去逛逛')),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: controller.loadOrders,
                    child: ListView.separated(
                      key: const Key('tospino-orders-list'),
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _OrderCard(
                        order: orders[index],
                        onTap: () => controller.openOrder(orders[index]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(localizeMiniProgramLabel(context, label)),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: TospinoColors.solidBrand(context),
        backgroundColor: TospinoColors.resolve(context, TospinoColors.surface),
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : TospinoColors.resolve(context, TospinoColors.secondary),
          fontSize: 11.5,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final TospinoOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    return Material(
      key: Key('tospino-order-${order.id}'),
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    status?.icon ?? Icons.receipt_long_outlined,
                    size: 18,
                    color: TospinoColors.solidBrand(context),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    localizeMiniProgramLabel(
                      context,
                      order.statusLabel.isEmpty
                          ? status?.label ?? '全部订单'
                          : order.statusLabel,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order.createdAt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: order.items.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: item.imageUrl.isEmpty
                                  ? const ColoredBox(
                                      color: TospinoColors.line,
                                      child: Icon(Icons.shopping_bag_outlined),
                                    )
                                  : Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const ColoredBox(
                                            color: TospinoColors.line,
                                            child: Icon(
                                              Icons.shopping_bag_outlined,
                                            ),
                                          ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 92,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TospinoPriceText(price: order.total, size: 17),
                          const SizedBox(height: 5),
                          Text(
                            '${order.items.length} '
                            '${localizeMiniProgramLabel(context, '件商品')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 22,
                color: TospinoColors.resolve(context, TospinoColors.line),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${localizeMiniProgramLabel(context, '订单号')} '
                      '${order.orderSn.isEmpty ? order.id : order.orderSn}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: TospinoColors.solidBrand(context),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      localizeMiniProgramLabel(context, '订单详情'),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
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

class _OrdersState extends StatelessWidget {
  const _OrdersState({required this.message, required this.onRetry});

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
