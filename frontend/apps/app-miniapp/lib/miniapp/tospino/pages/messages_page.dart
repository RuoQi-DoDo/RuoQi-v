import 'dart:async';

import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoMessagesPage extends StatefulWidget {
  const TospinoMessagesPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  State<TospinoMessagesPage> createState() => _TospinoMessagesPageState();
}

class _TospinoMessagesPageState extends State<TospinoMessagesPage> {
  TospinoAppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(controller.loadMessages());
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = controller.orders;
    return ColoredBox(
      key: const Key('tospino-messages-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          _MessagesHeader(controller: controller),
          Expanded(
            child: !controller.isLoggedIn
                ? _MessagesState(
                    actionKey: const Key('tospino-messages-login'),
                    icon: Icons.mark_email_unread_outlined,
                    title: '登录后查看订单消息',
                    subtitle: '订单状态与配送动态会集中显示在这里',
                    action: '登录 Tospino',
                    onAction: () =>
                        controller.openLogin(returnTo: TospinoRoute.messages),
                  )
                : controller.loadingOrders && orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : controller.ordersError != null && orders.isEmpty
                ? _MessagesState(
                    icon: Icons.cloud_off_outlined,
                    title: '消息加载失败',
                    subtitle: controller.ordersError!,
                    action: '重试',
                    onAction: () => unawaited(controller.loadMessages()),
                  )
                : orders.isEmpty
                ? _MessagesState(
                    icon: Icons.notifications_none_rounded,
                    title: '暂无消息',
                    subtitle: '下单后可在这里查看订单状态和配送动态',
                    action: '去逛逛',
                    onAction: () => controller.switchTab(0),
                  )
                : RefreshIndicator(
                    color: TospinoColors.solidBrand(context),
                    onRefresh: controller.loadMessages,
                    child: ListView.separated(
                      key: const Key('tospino-messages-list'),
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: orders.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
                            child: Row(
                              children: [
                                Text(
                                  localizeMiniProgramLabel(context, '订单动态'),
                                  style: TospinoText.bodyStrong(context),
                                ),
                                const Spacer(),
                                Text(
                                  '${orders.length} ${localizeMiniProgramLabel(context, '条消息')}',
                                  style: TospinoText.meta(context),
                                ),
                              ],
                            ),
                          );
                        }
                        final order = orders[index - 1];
                        return _OrderMessageCard(
                          order: order,
                          onTap: () => unawaited(controller.openOrder(order)),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MessagesHeader extends StatelessWidget {
  const _MessagesHeader({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: TospinoColors.brandGradient(context),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: TospinoColors.solidBrand(
                      context,
                    ).withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizeMiniProgramLabel(context, '消息'),
                    style: TospinoText.pageTitle(
                      context,
                    ).copyWith(fontSize: 21),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    localizeMiniProgramLabel(context, '订单动态与服务通知'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TospinoText.meta(context).copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MiniProgramCapsuleOverlay.reservedRight),
          ],
        ),
      ),
    );
  }
}

class _OrderMessageCard extends StatelessWidget {
  const _OrderMessageCard({required this.order, required this.onTap});

  final TospinoOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    final icon = status?.icon ?? Icons.receipt_long_rounded;
    final statusLabel = order.statusLabel.isEmpty
        ? status?.label ?? '订单状态更新'
        : order.statusLabel;
    final firstItem = order.items.isEmpty ? null : order.items.first;
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('tospino-message-order-${order.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.brandPale,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: TospinoColors.solidBrand(context),
                  size: 21,
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
                            localizeMiniProgramLabel(context, '订单状态更新'),
                            style: TospinoText.bodyStrong(
                              context,
                            ).copyWith(fontSize: 13.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.createdAt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TospinoText.hint(
                            context,
                          ).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      localizeMiniProgramLabel(context, statusLabel),
                      style: TospinoText.secondary(context).copyWith(
                        color: TospinoColors.solidBrand(context),
                        fontWeight: TospinoText.emphasis,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      firstItem == null
                          ? '${localizeMiniProgramLabel(context, '订单号')} ${order.orderSn}'
                          : firstItem.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TospinoText.body(
                        context,
                      ).copyWith(fontSize: 12, height: 1.25),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${localizeMiniProgramLabel(context, '订单号')} '
                            '${order.orderSn.isEmpty ? order.id : order.orderSn}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TospinoText.hint(
                              context,
                            ).copyWith(fontSize: 11),
                          ),
                        ),
                        TospinoPriceText(price: order.total, size: 13.5),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 17,
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.hint,
                          ),
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

class _MessagesState extends StatelessWidget {
  const _MessagesState({
    this.actionKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onAction,
  });

  final IconData icon;
  final Key? actionKey;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TospinoColors.resolve(context, TospinoColors.brandPale),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: TospinoColors.solidBrand(context),
                size: 34,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              localizeMiniProgramLabel(context, title),
              textAlign: TextAlign.center,
              style: TospinoText.section(context),
            ),
            const SizedBox(height: 6),
            Text(
              localizeMiniProgramLabel(context, subtitle),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TospinoText.secondary(context),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: actionKey,
              onPressed: onAction,
              child: Text(localizeMiniProgramLabel(context, action)),
            ),
          ],
        ),
      ),
    );
  }
}
