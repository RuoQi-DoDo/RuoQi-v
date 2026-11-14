import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoOrderDetailPage extends StatelessWidget {
  const TospinoOrderDetailPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final order = controller.selectedOrder;
    if (order == null) {
      return const Center(
        key: Key('tospino-order-detail-page'),
        child: CircularProgressIndicator(),
      );
    }
    final status = order.status ?? TospinoOrderStatus.toPay;
    return ColoredBox(
      key: const Key('tospino-order-detail-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 26),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TospinoColors.solidBrand(context),
                  TospinoColors.brandDeep,
                ],
              ),
              borderRadius: BorderRadius.circular(TospinoMetrics.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(
                          TospinoMetrics.imageRadius,
                        ),
                      ),
                      child: Icon(status.icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizeMiniProgramLabel(context, status.label),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: TospinoText.strong,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            status == TospinoOrderStatus.toShip
                                ? 'Your order is being prepared.'
                                : 'Track your Tospino delivery here.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _TrackingStep(status: status),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _DetailCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      localizeMiniProgramLabel(context, '收货地址'),
                      style: TospinoText.bodyStrong(context),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.brandPale,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        localizeMiniProgramLabel(context, '默认地址'),
                        style: TextStyle(
                          color: TospinoColors.solidBrand(context),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    [
                          order.receiverName,
                          order.receiverPhone,
                        ].where((part) => part.isNotEmpty).join('  ') +
                        (order.receiverAddress.isEmpty
                            ? ''
                            : '\n${order.receiverAddress}'),
                    style: TospinoText.secondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _DetailCard(
            child: Column(
              children: [
                for (var index = 0; index < order.items.length; index++) ...[
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          TospinoMetrics.imageRadius,
                        ),
                        child: SizedBox(
                          width: 70,
                          height: 70,
                          child: order.items[index].imageUrl.isEmpty
                              ? ColoredBox(
                                  color: TospinoColors.resolve(
                                    context,
                                    TospinoColors.imagePlaceholder,
                                  ),
                                  child: const Icon(Icons.image_outlined),
                                )
                              : Image.network(
                                  order.items[index].imageUrl,
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
                        child: Text(
                          order.items[index].title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TospinoText.bodyStrong(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TospinoPriceText(
                        price: order.items[index].price,
                        size: 15,
                      ),
                    ],
                  ),
                  if (index != order.items.length - 1)
                    Divider(
                      height: 21,
                      color: TospinoColors.resolve(context, TospinoColors.line),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          _DetailCard(
            child: Column(
              children: [
                _SummaryRow(
                  label: '订单号',
                  value: order.orderSn.isEmpty ? order.id : order.orderSn,
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: '商品合计',
                  value: 'GH₵${order.productAmount.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: '配送费',
                  value: 'GH₵${order.freight.toStringAsFixed(0)}',
                ),
                Divider(
                  height: 22,
                  color: TospinoColors.resolve(context, TospinoColors.line),
                ),
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      localizeMiniProgramLabel(context, '实付款'),
                      style: TospinoText.secondary(context),
                    ),
                    const SizedBox(width: 8),
                    TospinoPriceText(price: order.total, size: 21),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => showTospinoToast(context, '客服功能即将开放'),
            icon: const Icon(Icons.support_agent_rounded, size: 19),
            label: Text(localizeMiniProgramLabel(context, '客服与帮助')),
            style: OutlinedButton.styleFrom(
              foregroundColor: TospinoColors.solidBrand(context),
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: BorderSide(color: TospinoColors.solidBrand(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  TospinoMetrics.controlRadius,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  const _TrackingStep({required this.status});

  final TospinoOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final current = switch (status) {
      TospinoOrderStatus.toPay => 0,
      TospinoOrderStatus.toShip => 1,
      TospinoOrderStatus.toReceive => 2,
      TospinoOrderStatus.toReview => 3,
    };
    const labels = ['已下单', '运输中', '订单已送达'];
    return Row(
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          if (index > 0)
            Expanded(
              child: Container(
                height: 2,
                color: Colors.white.withValues(
                  alpha: index <= current ? 0.82 : 0.22,
                ),
              ),
            ),
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: index <= current
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: index <= current
                    ? const Icon(
                        Icons.check_rounded,
                        color: TospinoColors.brandDeep,
                        size: 12,
                      )
                    : null,
              ),
              const SizedBox(height: 5),
              Text(
                localizeMiniProgramLabel(context, labels[index]),
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: index <= current ? 0.92 : 0.46,
                  ),
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(TospinoMetrics.cardRadius),
      ),
      child: child,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          localizeMiniProgramLabel(context, label),
          style: TospinoText.secondary(context),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TospinoColors.resolve(context, TospinoColors.ink),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
