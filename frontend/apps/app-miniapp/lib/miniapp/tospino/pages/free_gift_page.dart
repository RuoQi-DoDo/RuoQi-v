import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoFreeGiftPage extends StatefulWidget {
  const TospinoFreeGiftPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  State<TospinoFreeGiftPage> createState() => _TospinoFreeGiftPageState();
}

class _TospinoFreeGiftPageState extends State<TospinoFreeGiftPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.refreshFreeGifts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('tospino-free-gift-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _FreeGiftHero(controller: widget.controller),
          ),
          if (widget.controller.loadingFreeGifts &&
              widget.controller.freeGifts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (widget.controller.freeGiftError != null &&
              widget.controller.freeGifts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: OutlinedButton(
                  onPressed: widget.controller.refreshFreeGifts,
                  child: Text(localizeMiniProgramLabel(context, '重试')),
                ),
              ),
            )
          else if (widget.controller.freeGifts.isEmpty)
            SliverToBoxAdapter(
              child: _FreeGiftEmpty(
                controller: widget.controller,
                onRefresh: widget.controller.refreshFreeGifts,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
              sliver: SliverList.separated(
                itemCount: widget.controller.freeGifts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final gift = widget.controller.freeGifts[index];
                  return _FreeGiftCard(
                    gift: gift,
                    onTap: () => widget.controller.openProduct(
                      TospinoProduct(
                        id: gift.productId,
                        title: gift.productName,
                        price: gift.minPrice,
                        imageUrl: gift.productImage,
                        shopName: gift.storeName,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FreeGiftHero extends StatelessWidget {
  const _FreeGiftHero({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 17),
      decoration: BoxDecoration(
        gradient: TospinoColors.saleGradient(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -26,
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 116,
              color: Colors.white.withValues(alpha: 0.17),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FREE GET',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: TospinoText.strong,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                '邀请好友助力\n0 元拿好物',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: TospinoText.strong,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => showTospinoToast(context, '免费拿活动规则'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('活动规则'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FreeGiftCard extends StatelessWidget {
  const _FreeGiftCard({required this.gift, required this.onTap});

  final TospinoFreeGift gift;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TospinoSurface(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 96,
              height: 96,
              child: gift.productImage.isEmpty
                  ? ColoredBox(
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.imagePlaceholder,
                      ),
                      child: const Icon(Icons.card_giftcard_outlined),
                    )
                  : Image.network(
                      gift.productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.imagePlaceholder,
                        ),
                        child: const Icon(Icons.card_giftcard_outlined),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gift.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TospinoText.body(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gift.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TospinoText.hint(context),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      if (gift.requiredHelpers > 0)
                        TospinoTag(
                          label: '${gift.requiredHelpers} 人助力',
                          solid: true,
                          color: TospinoColors.saleStart,
                        ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          '剩余 ${gift.receiveNum} 件',
                          style: TospinoText.meta(context),
                        ),
                      ),
                      Text(
                        'GH₵ ${gift.minPrice.toStringAsFixed(0)}',
                        style: TospinoText.price(context).copyWith(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.price,
                          ),
                        ),
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

class _FreeGiftEmpty extends StatelessWidget {
  const _FreeGiftEmpty({required this.controller, required this.onRefresh});

  final TospinoAppController controller;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
      child: Column(
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 58,
            color: TospinoColors.resolve(context, TospinoColors.hint),
          ),
          const SizedBox(height: 12),
          Text(
            localizeMiniProgramLabel(context, '暂无免费拿活动'),
            style: TospinoText.section(context),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRefresh,
            child: Text(localizeMiniProgramLabel(context, '刷新')),
          ),
          if (controller.homeProducts.isNotEmpty) ...[
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                localizeMiniProgramLabel(context, '猜你喜欢'),
                style: TospinoText.section(context),
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.homeProducts.take(4).length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 9,
                crossAxisSpacing: 9,
                childAspectRatio: 0.64,
              ),
              itemBuilder: (context, index) {
                final product = controller.homeProducts[index];
                return TospinoProductTile(
                  product: product,
                  artworkHeight: 128,
                  onTap: () => controller.openProduct(product),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
