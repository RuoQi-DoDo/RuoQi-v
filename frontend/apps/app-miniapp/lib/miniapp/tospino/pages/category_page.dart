import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoCategoryPage extends StatelessWidget {
  const TospinoCategoryPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedCategory;
    final categories = controller.categories;
    final products = controller.categoryProducts;
    return ColoredBox(
      key: const Key('tospino-category-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Material(
              color: TospinoColors.resolve(context, TospinoColors.surface),
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                onTap: controller.openSearch,
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.muted,
                        ),
                        size: 19,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          localizeMiniProgramLabel(context, '搜索商品、品牌或关键词'),
                          style: TextStyle(
                            color: TospinoColors.resolve(
                              context,
                              TospinoColors.hint,
                            ),
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: selected == null
                ? Center(
                    child: controller.homeError == null
                        ? const CircularProgressIndicator()
                        : _RetryState(
                            message: controller.homeError!,
                            onRetry: controller.initialize,
                          ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 94,
                        color: TospinoColors.resolve(
                          context,
                          TospinoColors.line,
                        ).withValues(alpha: 0.55),
                        child: ListView.builder(
                          key: const Key('tospino-category-list'),
                          padding: const EdgeInsets.only(top: 2, bottom: 20),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final active =
                                category.id == controller.selectedCategoryId;
                            return InkWell(
                              key: Key('tospino-category-${category.id}'),
                              onTap: () =>
                                  controller.selectCategory(category.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                height: 70,
                                decoration: BoxDecoration(
                                  color: active
                                      ? TospinoColors.resolve(
                                          context,
                                          TospinoColors.surface,
                                        )
                                      : Colors.transparent,
                                  border: active
                                      ? Border(
                                          left: BorderSide(
                                            color: TospinoColors.solidBrand(
                                              context,
                                            ),
                                            width: 3,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: category.iconUrl.isEmpty
                                          ? Icon(
                                              Icons.grid_view_rounded,
                                              size: 19,
                                              color: active
                                                  ? TospinoColors.solidBrand(
                                                      context,
                                                    )
                                                  : TospinoColors.resolve(
                                                      context,
                                                      TospinoColors.secondary,
                                                    ),
                                            )
                                          : Image.network(
                                              category.iconUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                    Icons.grid_view_rounded,
                                                    size: 19,
                                                  ),
                                            ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      category.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: active
                                            ? TospinoColors.solidBrand(context)
                                            : TospinoColors.resolve(
                                                context,
                                                TospinoColors.secondary,
                                              ),
                                        fontSize: 11,
                                        fontWeight: active
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: CustomScrollView(
                          key: const Key('tospino-category-products'),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  14,
                                  14,
                                  10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: TospinoColors.resolve(
                                          context,
                                          TospinoColors.brandPale,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.category_outlined,
                                        size: 19,
                                        color: TospinoColors.solidBrand(
                                          context,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selected.label,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          Text(
                                            '${products.length} '
                                            '${localizeMiniProgramLabel(context, '件商品')}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: localizeMiniProgramLabel(
                                        context,
                                        '搜索',
                                      ),
                                      onPressed: controller.openSearch,
                                      icon: const Icon(
                                        Icons.tune_rounded,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (controller.loadingCategory)
                              const SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (controller.categoryError != null)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: _RetryState(
                                  message: controller.categoryError!,
                                  onRetry: controller.loadCategoryProducts,
                                ),
                              )
                            else if (products.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Text(
                                    localizeMiniProgramLabel(context, '暂无匹配商品'),
                                  ),
                                ),
                              )
                            else
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  0,
                                  12,
                                  24,
                                ),
                                sliver: SliverGrid(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final product = products[index];
                                    return TospinoProductTile(
                                      product: product,
                                      artworkHeight: 92,
                                      onTap: () =>
                                          controller.openProduct(product),
                                    );
                                  }, childCount: products.length),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 9,
                                        crossAxisSpacing: 9,
                                        childAspectRatio: 0.62,
                                      ),
                                ),
                              ),
                          ],
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

class _RetryState extends StatelessWidget {
  const _RetryState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
