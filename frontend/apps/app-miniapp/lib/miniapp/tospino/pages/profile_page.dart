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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            child: Column(
              children: [
                _OrderShortcuts(controller: controller),
                const SizedBox(height: 12),
                _QuickServices(controller: controller),
                const SizedBox(height: 12),
                _SupportMenu(controller: controller),
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
    final displayName = user?.displayName.trim() ?? '';
    final initial = displayName.isEmpty ? 'T' : displayName.characters.first;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TospinoColors.brandDeep, TospinoColors.solidBrand(context)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -86,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -58,
            bottom: -100,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + 14,
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
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: TospinoColors.brandDeep,
                            fontSize: 24,
                            fontWeight: TospinoText.strong,
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: InkWell(
                          key: const Key('tospino-profile-login'),
                          onTap: loggedIn
                              ? null
                              : () => controller.openLogin(
                                  returnTo: TospinoRoute.profile,
                                ),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loggedIn
                                      ? displayName.isEmpty
                                            ? 'Tospino'
                                            : displayName
                                      : localizeMiniProgramLabel(
                                          context,
                                          '登录 / 注册',
                                        ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: TospinoText.strong,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  loggedIn
                                      ? 'ID:${user?.id ?? ''}'
                                      : localizeMiniProgramLabel(
                                          context,
                                          'Tospino 会员',
                                        ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.72),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        loggedIn
                            ? Icons.verified_rounded
                            : Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.86),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    children: [
                      _ProfileStat(
                        value:
                            '${user?.favoriteCount ?? controller.favorites.length}',
                        label: '关注',
                        onTap: controller.openFavorites,
                      ),
                      const _HeaderDivider(),
                      _ProfileStat(
                        value: _formatProfileAmount(user?.balance ?? 0),
                        label: '钱包',
                        onTap: () => controller.open(TospinoRoute.wallet),
                      ),
                      const _HeaderDivider(),
                      _ProfileStat(
                        value: '${user?.couponCount ?? 0}',
                        label: '优惠券',
                        onTap: () => controller.open(TospinoRoute.coupons),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => showTospinoToast(context, '会员中心即将开放'),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(11, 9, 9, 9),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: TospinoColors.orange.withValues(
                                alpha: 0.95,
                              ),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFF4A2C00),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizeMiniProgramLabel(
                                    context,
                                    'Tospino Plus',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: TospinoText.emphasis,
                                  ),
                                ),
                                Text(
                                  localizeMiniProgramLabel(
                                    context,
                                    '专属折扣与免运费权益',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            localizeMiniProgramLabel(context, '了解会员'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 11,
                              fontWeight: TospinoText.emphasis,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: TospinoText.strong,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                localizeMiniProgramLabel(context, label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  const _HeaderDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 28,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

class _OrderShortcuts extends StatelessWidget {
  const _OrderShortcuts({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return TospinoSurface(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 13),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.brandPale,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: TospinoColors.solidBrand(context),
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  localizeMiniProgramLabel(context, '我的订单'),
                  style: TospinoText.section(context),
                ),
              ),
              TextButton(
                onPressed: () => controller.openOrders(),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: TospinoColors.resolve(
                    context,
                    TospinoColors.secondary,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizeMiniProgramLabel(context, '全部订单'),
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 15),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final status in TospinoOrderStatus.values)
                Expanded(
                  child: _OrderShortcut(
                    status: status,
                    count: controller.orders
                        .where((order) => order.status == status)
                        .length,
                    onTap: () => controller.openOrders(status),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderShortcut extends StatelessWidget {
  const _OrderShortcut({
    required this.status,
    required this.count,
    required this.onTap,
  });

  final TospinoOrderStatus status;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('tospino-profile-order-${status.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TospinoColors.resolve(
                      context,
                      TospinoColors.surfaceMuted,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    status.icon,
                    color: TospinoColors.solidBrand(context),
                    size: 21,
                  ),
                ),
                if (count > 0)
                  Positioned(
                    right: -5,
                    top: -4,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: TospinoColors.price,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
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
            const SizedBox(height: 7),
            Text(
              localizeMiniProgramLabel(context, status.label),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TospinoText.meta(context).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickServices extends StatelessWidget {
  const _QuickServices({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final services = <_QuickServiceData>[
      _QuickServiceData(
        key: const Key('tospino-profile-favorites'),
        icon: Icons.favorite_rounded,
        color: TospinoColors.price,
        label: '我的关注',
        onTap: controller.openFavorites,
      ),
      _QuickServiceData(
        key: const Key('tospino-profile-free-gift'),
        icon: Icons.card_giftcard_rounded,
        color: const Color(0xFFFF8248),
        label: '免费拿',
        onTap: () => controller.open(TospinoRoute.freeGift),
      ),
      _QuickServiceData(
        key: const Key('tospino-profile-recent'),
        icon: Icons.history_rounded,
        color: const Color(0xFF6C83D9),
        label: '最近浏览',
        onTap: controller.openFavorites,
      ),
      _QuickServiceData(
        key: const Key('tospino-profile-shops'),
        icon: Icons.storefront_rounded,
        color: const Color(0xFF5D7DD8),
        label: '店铺关注',
        onTap: () => controller.open(TospinoRoute.shopFollow),
      ),
      _QuickServiceData(
        key: const Key('tospino-profile-wallet'),
        icon: Icons.account_balance_wallet_rounded,
        color: TospinoColors.orange,
        label: '我的钱包',
        onTap: () => controller.open(TospinoRoute.wallet),
      ),
      _QuickServiceData(
        key: const Key('tospino-profile-coupons'),
        icon: Icons.confirmation_number_rounded,
        color: TospinoColors.price,
        label: '我的优惠券',
        onTap: () => controller.open(TospinoRoute.coupons),
      ),
      _QuickServiceData(
        key: const Key('tospino-profile-address'),
        icon: Icons.location_on_rounded,
        color: TospinoColors.solidBrand(context),
        label: '地址管理',
        onTap: () => controller.open(TospinoRoute.address),
      ),
      _QuickServiceData(
        key: const Key('tospino-profile-settings'),
        icon: Icons.settings_rounded,
        color: const Color(0xFF7B8794),
        label: '设置',
        onTap: () => controller.open(TospinoRoute.settings),
      ),
    ];
    return TospinoSurface(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              localizeMiniProgramLabel(context, '常用功能'),
              style: TospinoText.section(context),
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisExtent: 83,
            ),
            itemBuilder: (context, index) {
              return _QuickService(data: services[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _QuickServiceData {
  const _QuickServiceData({
    required this.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final Key key;
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
}

class _QuickService extends StatelessWidget {
  const _QuickService({required this.data});

  final _QuickServiceData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: data.key,
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
          child: Column(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(data.icon, color: data.color, size: 22),
              ),
              const SizedBox(height: 7),
              Expanded(
                child: Text(
                  localizeMiniProgramLabel(context, data.label),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TospinoText.meta(context).copyWith(
                    color: TospinoColors.resolve(context, TospinoColors.ink),
                    fontSize: 11,
                    fontWeight: TospinoText.emphasis,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportMenu extends StatelessWidget {
  const _SupportMenu({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return TospinoSurface(
      radius: 16,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SupportRow(
            icon: Icons.group_add_rounded,
            color: TospinoColors.price,
            label: '邀请好友',
            onTap: () => showTospinoToast(context, '邀请好友'),
            trailing: const TospinoTag(label: '领取奖励', solid: true),
          ),
          _SupportRow(
            icon: Icons.chat_bubble_outline_rounded,
            color: TospinoColors.solidBrand(context),
            label: '联系客服',
            onTap: () => showTospinoToast(context, '客服功能即将开放'),
          ),
          _SupportRow(
            icon: Icons.feedback_outlined,
            color: const Color(0xFF7B8794),
            label: '意见反馈',
            onTap: () => showTospinoToast(context, '意见反馈'),
          ),
          _SupportRow(
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

class _SupportRow extends StatelessWidget {
  const _SupportRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.trailing,
    this.showDivider = true,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
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
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                localizeMiniProgramLabel(context, label),
                style: TospinoText.body(context),
              ),
            ),
            if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: TospinoColors.resolve(context, TospinoColors.hint),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatProfileAmount(double value) {
  final fixed = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final digits = parts.first;
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  return parts.length == 1 ? buffer.toString() : '$buffer.${parts.last}';
}
