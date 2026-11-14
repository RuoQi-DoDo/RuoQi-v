import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

enum TospinoCampaignKind {
  groupBuy,
  platformMegaSale,
  flashSale,
  brandFlashSale,
  newcomer,
  clearance,
  categoryEvent,
  nYuan,
  subsidy,
  shippingDiscount,
}

class TospinoCampaign {
  const TospinoCampaign({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final TospinoCampaignKind kind;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  String get id => kind.name;
}

const tospinoCampaigns = <TospinoCampaign>[
  TospinoCampaign(
    kind: TospinoCampaignKind.groupBuy,
    title: '拼团活动',
    subtitle: '和好友一起省更多',
    icon: Icons.groups_rounded,
    accent: Color(0xFFFF7A3D),
  ),
  TospinoCampaign(
    kind: TospinoCampaignKind.platformMegaSale,
    title: '平台大促',
    subtitle: '全站好价集中放送',
    icon: Icons.campaign_rounded,
    accent: Color(0xFFFF4D5E),
  ),
  TospinoCampaign(
    kind: TospinoCampaignKind.flashSale,
    title: '限时秒杀',
    subtitle: '短时优惠，售完即止',
    icon: Icons.bolt_rounded,
    accent: Color(0xFFFF6A00),
  ),
  TospinoCampaign(
    kind: TospinoCampaignKind.brandFlashSale,
    title: '品牌秒杀',
    subtitle: '精选品牌限时直降',
    icon: Icons.workspace_premium_rounded,
    accent: Color(0xFF8A5BEA),
  ),
  TospinoCampaign(
    kind: TospinoCampaignKind.newcomer,
    title: '新人专享',
    subtitle: '首次下单专属好价',
    icon: Icons.person_add_alt_1_rounded,
    accent: Color(0xFF18C4D2),
  ),
  TospinoCampaign(
    kind: TospinoCampaignKind.clearance,
    title: '断码清仓',
    subtitle: '尺码有限，清完即止',
    icon: Icons.inventory_2_rounded,
    accent: Color(0xFF6B7C93),
  ),
  TospinoCampaign(
    kind: TospinoCampaignKind.categoryEvent,
    title: '品类专场',
    subtitle: '按品类逛活动好物',
    icon: Icons.category_rounded,
    accent: Color(0xFF2B8FE8),
  ),
  TospinoCampaign(
    kind: TospinoCampaignKind.nYuan,
    title: 'N元购',
    subtitle: 'GH₵50 封顶精选',
    icon: Icons.sell_rounded,
    accent: Color(0xFFF4B400),
  ),
  TospinoCampaign(
    kind: TospinoCampaignKind.subsidy,
    title: '平台补贴',
    subtitle: '平台补贴直降',
    icon: Icons.savings_rounded,
    accent: Color(0xFFEF476F),
  ),
  TospinoCampaign(
    kind: TospinoCampaignKind.shippingDiscount,
    title: '运费折扣',
    subtitle: '配送优惠专场',
    icon: Icons.local_shipping_rounded,
    accent: Color(0xFF27AE60),
  ),
];

List<TospinoProduct> tospinoCampaignProducts(
  TospinoCampaign campaign,
  TospinoAppController controller,
) {
  final source = controller.homeProducts;
  final products = switch (campaign.kind) {
    TospinoCampaignKind.groupBuy =>
      source.where((product) => product.sales > 0).toList(),
    TospinoCampaignKind.platformMegaSale =>
      source.where((product) => product.discountPercent > 0).toList(),
    TospinoCampaignKind.flashSale =>
      source.where((product) => product.discountPercent >= 20).toList(),
    TospinoCampaignKind.brandFlashSale =>
      source
          .where(
            (product) =>
                product.brand.isNotEmpty && product.discountPercent > 0,
          )
          .toList(),
    TospinoCampaignKind.newcomer =>
      source
          .where((product) => product.price > 0 && product.price <= 100)
          .toList(),
    TospinoCampaignKind.clearance =>
      source.where((product) => product.discountPercent >= 30).toList(),
    TospinoCampaignKind.categoryEvent =>
      source.where((product) => product.categoryName.isNotEmpty).toList(),
    TospinoCampaignKind.nYuan =>
      source
          .where((product) => product.price > 0 && product.price <= 50)
          .toList(),
    TospinoCampaignKind.subsidy =>
      source.where((product) => product.oldPrice > product.price).toList(),
    TospinoCampaignKind.shippingDiscount =>
      source.where((product) => product.deliveryType != 0).toList(),
  };
  products.sort((left, right) {
    final discount = right.discountPercent.compareTo(left.discountPercent);
    if (discount != 0) return discount;
    final sales = right.sales.compareTo(left.sales);
    return sales != 0 ? sales : left.price.compareTo(right.price);
  });
  return products.take(20).toList(growable: false);
}

Future<void> showTospinoCampaignSheet(
  BuildContext context,
  TospinoAppController controller,
  TospinoCampaign campaign,
) {
  final products = tospinoCampaignProducts(campaign, controller);
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.88,
      child: Material(
        color: TospinoColors.resolve(context, TospinoColors.background),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _CampaignSheetHeader(
              campaign: campaign,
              productCount: products.length,
            ),
            Expanded(
              child: products.isEmpty
                  ? _CampaignEndedState(campaign: campaign)
                  : _CampaignProducts(
                      campaign: campaign,
                      products: products,
                      controller: controller,
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CampaignSheetHeader extends StatelessWidget {
  const _CampaignSheetHeader({
    required this.campaign,
    required this.productCount,
  });

  final TospinoCampaign campaign;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    final active = productCount > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            campaign.accent,
            Color.lerp(campaign.accent, Colors.black, 0.24)!,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(campaign.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeMiniProgramLabel(context, campaign.title),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: TospinoText.strong,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      localizeMiniProgramLabel(context, campaign.subtitle),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  localizeMiniProgramLabel(context, active ? '活动进行中' : '活动已结束'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: TospinoText.emphasis,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ],
          ),
          if (active) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '$productCount ${localizeMiniProgramLabel(context, '件活动商品')}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 11.5,
                    fontWeight: TospinoText.emphasis,
                  ),
                ),
                const Spacer(),
                Text(
                  localizeMiniProgramLabel(context, '优惠以结算页为准'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CampaignProducts extends StatelessWidget {
  const _CampaignProducts({
    required this.campaign,
    required this.products,
    required this.controller,
  });

  final TospinoCampaign campaign;
  final List<TospinoProduct> products;
  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const Key('tospino-campaign-products'),
      slivers: [
        if (products.length < 3)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: campaign.accent.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 17,
                    color: campaign.accent,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      localizeMiniProgramLabel(context, '本场活动商品较少，更多好物正在补充'),
                      style: TospinoText.meta(context).copyWith(
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return TospinoProductTile(
                product: product,
                artworkHeight: 142,
                onTap: () {
                  Navigator.of(context).pop();
                  controller.openProduct(product);
                },
              );
            }, childCount: products.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
              childAspectRatio: 0.63,
            ),
          ),
        ),
      ],
    );
  }
}

class _CampaignEndedState extends StatelessWidget {
  const _CampaignEndedState({required this.campaign});

  final TospinoCampaign campaign;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: campaign.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 40,
                color: campaign.accent,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              localizeMiniProgramLabel(context, '活动已结束'),
              style: TospinoText.section(context).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 7),
            Text(
              localizeMiniProgramLabel(context, '本场活动商品已售罄或活动已结束，看看其他会场吧'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TospinoText.secondary(context),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: Text(localizeMiniProgramLabel(context, '探索其他活动')),
            ),
          ],
        ),
      ),
    );
  }
}
