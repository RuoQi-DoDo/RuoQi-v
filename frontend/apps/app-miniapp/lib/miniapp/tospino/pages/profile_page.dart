import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
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
        padding: EdgeInsets.zero,
        children: [
          _ProfileHeader(controller: controller),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
            child: Column(
              children: [
                Transform.translate(
                  offset: const Offset(0, -26),
                  child: _OrderShortcuts(controller: controller),
                ),
                Transform.translate(
                  offset: const Offset(0, -12),
                  child: _MembershipCard(controller: controller),
                ),
                Transform.translate(
                  offset: const Offset(0, 2),
                  child: _ServiceMenu(controller: controller),
                ),
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
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TospinoColors.solidBrand(context), const Color(0xFF2C6A72)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 3,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: TospinoColors.brandDeep,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        if (loggedIn) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD761),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              localizeMiniProgramLabel(context, 'Tospino 会员'),
                              style: const TextStyle(
                                color: Color(0xFF654600),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      loggedIn
                          ? user?.account ?? ''
                          : localizeMiniProgramLabel(context, 'Tospino 会员'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: localizeMiniProgramLabel(context, '设置'),
                onPressed: () => controller.open(TospinoRoute.settings),
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _ProfileStat(
                value: '${user?.favoriteCount ?? controller.favorites.length}',
                label: '收藏',
                onTap: () => controller.open(TospinoRoute.favorites),
              ),
              _ProfileStat(
                value: '${user?.couponCount ?? 0}',
                label: '优惠券',
                onTap: () => showTospinoToast(context, '优惠券'),
              ),
              _ProfileStat(
                value: '—',
                label: '积分',
                onTap: () => showTospinoToast(context, '积分商城'),
              ),
              _ProfileStat(
                value: 'GH₵ ${(user?.balance ?? 0).toStringAsFixed(2)}',
                label: '我的钱包',
                onTap: () => showTospinoToast(context, '我的钱包'),
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
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                localizeMiniProgramLabel(context, label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 10.5,
                ),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 13),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                localizeMiniProgramLabel(context, '我的订单'),
                style: Theme.of(context).textTheme.titleMedium,
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
          Row(
            children: [
              for (final status in TospinoOrderStatus.values)
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
                                        fontWeight: FontWeight.w800,
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
            ],
          ),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(15, 14, 13, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF262B35), Color(0xFF454F67)],
        ),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD761).withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Color(0xFFFFD761),
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizeMiniProgramLabel(context, 'Tospino Plus'),
                  style: const TextStyle(
                    color: Color(0xFFFFD761),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  localizeMiniProgramLabel(context, '专属折扣与免运费权益'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => showTospinoToast(context, '会员中心'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFD761),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              localizeMiniProgramLabel(context, '了解会员'),
              style: const TextStyle(fontSize: 10.5),
            ),
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
    return Container(
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          _ServiceItem(
            icon: Icons.favorite_border_rounded,
            color: TospinoColors.price,
            label: '收藏商品',
            onTap: () => controller.open(TospinoRoute.favorites),
          ),
          _ServiceItem(
            icon: Icons.location_on_outlined,
            color: TospinoColors.brand,
            label: '收货地址',
            onTap: () => controller.open(TospinoRoute.address),
          ),
          _ServiceItem(
            icon: Icons.support_agent_rounded,
            color: const Color(0xFF6C83D9),
            label: '客服与帮助',
            onTap: () => showTospinoToast(context, '客服功能即将开放'),
          ),
          _ServiceItem(
            icon: Icons.settings_outlined,
            color: const Color(0xFF7B8794),
            label: '设置',
            onTap: () => controller.open(TospinoRoute.settings),
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
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 15),
        padding: const EdgeInsets.symmetric(vertical: 13),
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
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizeMiniProgramLabel(context, label),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: TospinoColors.resolve(context, TospinoColors.hint),
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
