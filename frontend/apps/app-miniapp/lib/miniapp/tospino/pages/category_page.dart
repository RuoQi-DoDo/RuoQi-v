import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoCategoryPage extends StatelessWidget {
  const TospinoCategoryPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedCategory;
    return ColoredBox(
      key: const Key('tospino-category-page'),
      color: TospinoColors.resolve(context, TospinoColors.surface),
      child: Column(
        children: [
          _CategorySearchBar(onTap: controller.openSearch),
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: TospinoColors.resolve(context, TospinoColors.line),
          ),
          Expanded(
            child: selected == null
                ? _CategoryInitialState(controller: controller)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CategoryRail(
                        categories: controller.categories,
                        selected: selected,
                        onSelected: controller.selectCategory,
                      ),
                      Expanded(
                        child: _CategoryContent(
                          controller: controller,
                          selected: selected,
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

class _CategorySearchBar extends StatelessWidget {
  const _CategorySearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: TospinoColors.resolve(context, TospinoColors.surfaceMuted),
          borderRadius: BorderRadius.circular(17),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: TospinoColors.resolve(context, TospinoColors.muted),
                  size: 18,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    localizeMiniProgramLabel(context, '搜索商品、品牌或关键词'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TospinoText.hint(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<TospinoCategory> categories;
  final TospinoCategory selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = categories.indexWhere(
      (category) => category.id == selected.id,
    );
    return SizedBox(
      width: 96,
      child: ColoredBox(
        color: TospinoColors.resolve(context, TospinoColors.surfaceMuted),
        child: ListView.builder(
          key: const Key('tospino-category-list'),
          padding: EdgeInsets.zero,
          itemExtent: 60,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryRailItem(
              key: Key('tospino-category-${category.id}'),
              label: category.label,
              active: index == selectedIndex,
              previous: index == selectedIndex - 1,
              next: index == selectedIndex + 1,
              onTap: () => onSelected(category.id),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryRailItem extends StatelessWidget {
  const _CategoryRailItem({
    super.key,
    required this.label,
    required this.active,
    required this.previous,
    required this.next,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool previous;
  final bool next;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = active
        ? TospinoColors.resolve(context, TospinoColors.surface)
        : TospinoColors.resolve(context, TospinoColors.surfaceMuted);
    final radius = previous
        ? const BorderRadius.only(bottomRight: Radius.circular(14))
        : next
        ? const BorderRadius.only(topRight: Radius.circular(14))
        : BorderRadius.zero;
    return Material(
      color: background,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            if (active)
              Positioned(
                left: 0,
                top: 19,
                child: Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: TospinoColors.brandGradient(context),
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(2),
                    ),
                  ),
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active
                        ? TospinoColors.resolve(context, TospinoColors.ink)
                        : TospinoColors.resolve(
                            context,
                            TospinoColors.secondary,
                          ),
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryContent extends StatelessWidget {
  const _CategoryContent({required this.controller, required this.selected});

  final TospinoAppController controller;
  final TospinoCategory selected;

  @override
  Widget build(BuildContext context) {
    final sections = _sectionsFor(selected);
    if (sections.isNotEmpty) {
      return _CategorySectionsView(
        sections: sections,
        onSelected: (category) {
          controller.openSearch();
          controller.search(category.label);
        },
      );
    }
    return _CategoryProductFallback(controller: controller);
  }

  List<_CategorySectionData> _sectionsFor(TospinoCategory category) {
    final sections = <_CategorySectionData>[];
    final directChildren = <TospinoCategory>[];
    for (final child in category.children) {
      if (child.children.isEmpty) {
        directChildren.add(child);
      } else {
        sections.add(
          _CategorySectionData(title: child.label, items: child.children),
        );
      }
    }
    if (directChildren.isNotEmpty) {
      sections.insert(
        0,
        _CategorySectionData(title: category.label, items: directChildren),
      );
    }
    return sections;
  }
}

class _CategorySectionData {
  const _CategorySectionData({required this.title, required this.items});

  final String title;
  final List<TospinoCategory> items;
}

class _CategorySectionsView extends StatelessWidget {
  const _CategorySectionsView({
    required this.sections,
    required this.onSelected,
  });

  final List<_CategorySectionData> sections;
  final ValueChanged<TospinoCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const Key('tospino-category-products'),
      slivers: [
        for (final section in sections) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 11),
              child: Text(
                section.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TospinoText.body(
                  context,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = section.items[index];
                return _ChildCategoryTile(
                  category: category,
                  onTap: () => onSelected(category),
                );
              }, childCount: section.items.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 9,
                childAspectRatio: 0.62,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _ChildCategoryTile extends StatelessWidget {
  const _ChildCategoryTile({required this.category, required this.onTap});

  final TospinoCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TospinoMetrics.imageRadius),
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(TospinoMetrics.imageRadius),
                child: category.iconUrl.isEmpty
                    ? _CategoryArtwork(category: category)
                    : Image.network(
                        category.iconUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _CategoryArtwork(category: category),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            category.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TospinoText.secondary(
              context,
            ).copyWith(fontSize: 14, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _CategoryArtwork extends StatelessWidget {
  const _CategoryArtwork({required this.category});

  final TospinoCategory category;

  @override
  Widget build(BuildContext context) {
    final initial = category.label.isEmpty
        ? '#'
        : category.label.characters.first;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.brandPale),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: TospinoColors.solidBrand(context),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CategoryProductFallback extends StatelessWidget {
  const _CategoryProductFallback({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final products = controller.categoryProducts;
    if (controller.loadingCategory && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.categoryError != null && products.isEmpty) {
      return _RetryState(
        message: controller.categoryError!,
        onRetry: controller.loadCategoryProducts,
      );
    }
    if (products.isEmpty) {
      return Center(
        child: Text(
          localizeMiniProgramLabel(context, '暂无匹配商品'),
          style: TospinoText.meta(context),
        ),
      );
    }
    return CustomScrollView(
      key: const Key('tospino-category-products'),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return TospinoProductTile(
                product: product,
                artworkHeight: 96,
                onTap: () => controller.openProduct(product),
              );
            }, childCount: products.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _CategoryInitialState extends StatelessWidget {
  const _CategoryInitialState({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.homeError == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _RetryState(
      message: controller.homeError!,
      onRetry: controller.initialize,
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
              style: TospinoText.secondary(context),
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
