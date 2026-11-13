import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoShopFollowPage extends StatelessWidget {
  const TospinoShopFollowPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final shops = <String>{
      for (final product in controller.homeProducts)
        if (product.shopName.isNotEmpty) product.shopName,
    }.toList(growable: false);
    return ColoredBox(
      key: const Key('tospino-shop-follow-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: TospinoColors.resolve(
                  context,
                  TospinoColors.surfaceMuted,
                ),
                borderRadius: BorderRadius.circular(19),
              ),
              child: InkWell(
                onTap: () {
                  controller.openSearch();
                  controller.search(localizeMiniProgramLabel(context, '店铺'));
                },
                borderRadius: BorderRadius.circular(19),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.hint,
                        ),
                        size: 19,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        localizeMiniProgramLabel(context, '搜索关注的店铺'),
                        style: TospinoText.hint(context).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: shops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            color: TospinoColors.resolve(
                              context,
                              TospinoColors.brandPale,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.storefront_outlined,
                            size: 52,
                            color: TospinoColors.brand,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizeMiniProgramLabel(context, '还没有关注的店铺'),
                          style: TospinoText.section(context),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => controller.switchTab(0),
                          child: Text(localizeMiniProgramLabel(context, '去逛逛')),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: shops.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final name = shops[index];
                      return TospinoSurface(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: TospinoColors.resolve(
                                  context,
                                  TospinoColors.brandPale,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                name.characters.first.toUpperCase(),
                                style: TextStyle(
                                  color: TospinoColors.solidBrand(context),
                                  fontSize: 22,
                                  fontWeight: TospinoText.emphasis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TospinoText.bodyStrong(context),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => showTospinoToast(
                                context,
                                localizeMiniProgramLabel(context, '店铺详情'),
                              ),
                              child: Text(
                                localizeMiniProgramLabel(context, '查看店铺'),
                              ),
                            ),
                          ],
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
