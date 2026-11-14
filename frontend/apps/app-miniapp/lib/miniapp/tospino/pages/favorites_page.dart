import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoFavoritesPage extends StatelessWidget {
  const TospinoFavoritesPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final products = controller.favorites;
    return ColoredBox(
      key: const Key('tospino-favorites-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: products.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 62,
                    color: TospinoColors.resolve(context, TospinoColors.hint),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizeMiniProgramLabel(context, '收藏商品'),
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
              onRefresh: controller.openFavorites,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                      child: Text(
                        '${products.length} '
                        '${localizeMiniProgramLabel(context, '件商品')}',
                        style: TospinoText.meta(context),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = products[index];
                        return Stack(
                          children: [
                            TospinoProductTile(
                              product: product,
                              artworkHeight: 138,
                              onTap: () => controller.openProduct(product),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Material(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  key: Key('tospino-unfavorite-${product.id}'),
                                  onTap: () async {
                                    try {
                                      await controller.toggleFavorite(product);
                                      if (context.mounted) {
                                        showTospinoToast(context, '已取消收藏');
                                      }
                                    } catch (error) {
                                      if (context.mounted) {
                                        showTospinoToast(
                                          context,
                                          error.toString(),
                                        );
                                      }
                                    }
                                  },
                                  customBorder: const CircleBorder(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(7),
                                    child: Icon(
                                      Icons.favorite_rounded,
                                      color: TospinoColors.price,
                                      size: 17,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }, childCount: products.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 9,
                            crossAxisSpacing: 9,
                            childAspectRatio: 0.63,
                          ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
