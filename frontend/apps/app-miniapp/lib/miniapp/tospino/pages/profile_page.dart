import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../../common/widgets/miniapp_capsule_overlay.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoProfilePage extends StatelessWidget {
  const TospinoProfilePage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('tospino-profile-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: ListView(
        key: const Key('tospino-profile-scroll'),
        padding: EdgeInsets.zero,
        children: [
          _ProfileHeader(controller: controller),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
            child: Column(
              children: [
                _OrderShortcuts(controller: controller),
                const SizedBox(height: 12),
                _ServiceMenu(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    final loggedIn = controller.isLoggedIn;
    final displayName = user?.displayName ?? '';
    final initial = displayName.isEmpty ? 'T' : displayName.substring(0, 1);
    return Container(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 16,
        16,
        18,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: MiniProgramCapsuleOverlay.reservedRight - 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: TospinoColors.resolve(
                      context,
                      TospinoColors.brandPale,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: TospinoColors.solidBrand(context),
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: loggedIn
                                  ? null
                                  : () => controller.openLogin(
                                      returnTo: TospinoRoute.profile,
                                    ),
                              child: Text(
                                loggedIn
                                    ? displayName
                                    : localizeMiniProgramLabel(
                                        context,
                                        '登录 / 注册',
                                      ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: TospinoColors.solidBrand(context),
                                  fontSize: 18,
                                  fontWeight: TospinoText.regular,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        loggedIn
                            ? 'ID:${user?.id ?? ''}'
                            : localizeMiniProgramLabel(context, 'Tospino 会员'),
                        style: TospinoText.hint(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _ProfileStat(
                value: '${user?.favoriteCount ?? controller.favorites.length}',
                label: '关注',
                onTap: () => controller.open(TospinoRoute.favorites),
              ),
              _ProfileStat(
                value: '${user?.balance ?? 0}',
                label: '钱包',
                onTap: () => controller.open(TospinoRoute.wallet),
              ),
              _ProfileStat(
                value: '${user?.couponCount ?? 0}',
                label: '优惠券',
                onTap: () => controller.open(TospinoRoute.coupons),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: TextStyle(
                      color: TospinoColors.resolve(context, TospinoColors.ink),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                localizeMiniProgramLabel(context, label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TospinoText.hint(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderShortcuts extends StatelessWidget {
  const _OrderShortcuts({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return TospinoSurface(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                localizeMiniProgramLabel(context, '我的订单'),
                style: TospinoText.section(context),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => controller.openOrders(),
                style: TextButton.styleFrom(
                  foregroundColor: TospinoColors.resolve(
                    context,
                    TospinoColors.muted,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizeMiniProgramLabel(context, '全部订单'),
                      style: const TextStyle(fontSize: 11),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final status in const [
                TospinoOrderStatus.toPay,
                TospinoOrderStatus.toReceive,
                TospinoOrderStatus.toReview,
              ])
                Expanded(
                  child: InkWell(
                    key: Key('tospino-profile-order-${status.name}'),
                    onTap: () => controller.openOrders(status),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                status.icon,
                                color: TospinoColors.resolve(
                                  context,
                                  TospinoColors.ink,
                                ),
                                size: 24,
                              ),
                              if (status == TospinoOrderStatus.toReceive &&
                                  controller.orders.any(
                                    (order) => order.status == status,
                                  ))
                                Positioned(
                                  right: -6,
                                  top: -4,
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    decoration: const BoxDecoration(
                                      color: TospinoColors.price,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${controller.orders.where((order) => order.status == status).length}',
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
                          const SizedBox(height: 7),
                          Text(
                            localizeMiniProgramLabel(context, status.label),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: InkWell(
                  onTap: () => showTospinoToast(context, '退款/售后'),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment_return_outlined,
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.ink,
                          ),
                          size: 24,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          localizeMiniProgramLabel(context, '退款/售后'),
                          style: TospinoText.meta(context),
                        ),
                      ],
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

class _ServiceMenu extends StatelessWidget {
  const _ServiceMenu({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return TospinoSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ServiceItem(
            icon: Icons.group_add_outlined,
            color: TospinoColors.solidBrand(context),
            label: '邀请好友',
            onTap: () => showTospinoToast(context, '邀请好友'),
            trailing: const TospinoTag(label: '领取奖励', solid: true),
          ),
          _ServiceItem(
            icon: Icons.favorite_border_rounded,
            color: TospinoColors.price,
            label: '我的关注',
            onTap: () => controller.open(TospinoRoute.favorites),
          ),
          _ServiceItem(
            key: const Key('tospino-profile-free-gift'),
            icon: Icons.card_giftcard_outlined,
            color: const Color(0xFFFF8248),
            label: '免费拿',
            onTap: () => controller.open(TospinoRoute.freeGift),
          ),
          _ServiceItem(
            icon: Icons.history_rounded,
            color: const Color(0xFF6C83D9),
            label: '最近浏览',
            onTap: () => controller.open(TospinoRoute.favorites),
          ),
          _ServiceItem(
            key: const Key('tospino-profile-wallet'),
            icon: Icons.account_balance_wallet_outlined,
            color: TospinoColors.orange,
            label: '我的钱包',
            onTap: () => controller.open(TospinoRoute.wallet),
          ),
          _ServiceItem(
            key: const Key('tospino-profile-coupons'),
            icon: Icons.confirmation_number_outlined,
            color: TospinoColors.price,
            label: '我的优惠券',
            onTap: () => controller.open(TospinoRoute.coupons),
          ),
          _ServiceItem(
            key: const Key('tospino-profile-address'),
            icon: Icons.location_on_outlined,
            color: TospinoColors.brand,
            label: '地址管理',
            onTap: () => controller.open(TospinoRoute.address),
          ),
          _ServiceItem(
            key: const Key('tospino-profile-shops'),
            icon: Icons.storefront_outlined,
            color: const Color(0xFF6C83D9),
            label: '店铺关注',
            onTap: () => controller.open(TospinoRoute.shopFollow),
          ),
          _ServiceItem(
            key: const Key('tospino-profile-settings'),
            icon: Icons.settings_outlined,
            color: const Color(0xFF7B8794),
            label: '设置',
            onTap: () => controller.open(TospinoRoute.settings),
          ),
          _ServiceItem(
            icon: Icons.feedback_outlined,
            color: const Color(0xFF7B8794),
            label: '意见反馈',
            onTap: () => showTospinoToast(context, '意见反馈'),
          ),
          _ServiceItem(
            icon: Icons.support_agent_rounded,
            color: TospinoColors.solidBrand(context),
            label: '联系客服',
            onTap: () => showTospinoToast(context, '客服功能即将开放'),
          ),
          _ServiceItem(
            icon: Icons.info_outline_rounded,
            color: const Color(0xFFB2863D),
            label: '关于 Tospino',
            onTap: () => controller.open(TospinoRoute.about),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.showDivider = true,
    this.trailing,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: TospinoMetrics.rowHeight,
        margin: const EdgeInsets.only(left: 14),
        padding: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: TospinoColors.resolve(context, TospinoColors.line),
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizeMiniProgramLabel(context, label),
                style: TospinoText.body(context),
              ),
            ),
            if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
            Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: TospinoColors.resolve(context, TospinoColors.hint),
            ),
          ],
        ),
      ),
    );
  }
}
