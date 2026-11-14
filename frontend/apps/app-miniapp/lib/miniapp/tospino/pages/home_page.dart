import 'dart:async';

import 'package:flutter/material.dart';

import '../../common/common.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoHomePage extends StatelessWidget {
  const TospinoHomePage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.homeLoaded) {
      return ColoredBox(
        key: const Key('tospino-home-page'),
        color: TospinoColors.resolve(context, TospinoColors.background),
        child: Column(
          children: [
            _HomeHeader(controller: controller),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  key: Key('tospino-home-loading'),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final products = controller.homeProducts;
    final page = controller.currentHomePage;
    final decoratedFlow = page != null && controller.hasHomeDecoration;
    final hasDecoration =
        page != null && page.components.any((component) => component.isVisible);
    final recommendation = page?.recommendationComponent;
    final recommendationTitle = recommendation?.title.trim().isNotEmpty == true
        ? recommendation!.title
        : localizeMiniProgramLabel(context, '猜你喜欢');
    return ColoredBox(
      key: const Key('tospino-home-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical &&
              notification.metrics.extentAfter < 480) {
            unawaited(controller.loadMoreHome());
          }
          return false;
        },
        child: CustomScrollView(
          key: const Key('tospino-home-scroll'),
          slivers: [
            SliverToBoxAdapter(child: _HomeHeader(controller: controller)),
            if (controller.homePages.length > 1)
              SliverToBoxAdapter(child: _HomePageTabs(controller: controller)),
            if (controller.homeRecommendWords.isNotEmpty)
              SliverToBoxAdapter(
                child: _HomeRecommendWords(controller: controller),
              ),
            if (hasDecoration)
              SliverToBoxAdapter(
                child: _HomeDecorationBody(controller: controller, page: page),
              )
            else if (decoratedFlow)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: Center(
                    child:
                        controller.isHomePageLoading(controller.homePageIndex)
                        ? const CircularProgressIndicator()
                        : Text(
                            localizeMiniProgramLabel(context, '暂无首页装修内容'),
                            style: TospinoText.meta(context),
                          ),
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: _HomeCategoryChips(controller: controller),
              ),
              const SliverToBoxAdapter(child: _HomeBanner()),
              SliverToBoxAdapter(
                child: _HomeActionGrid(controller: controller),
              ),
              const SliverToBoxAdapter(child: _HomeServiceStrip()),
            ],
            if (!hasDecoration ||
                (recommendation?.showTitle == true &&
                    recommendationTitle.trim().isNotEmpty))
              SliverToBoxAdapter(
                child: TospinoSectionHeader(
                  title: recommendationTitle,
                  subtitle: '为你精选',
                ),
              ),
            if (controller.loadingHome && products.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.homeError != null && products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _HomeDataState(
                  message: controller.homeError!,
                  onRetry: controller.refreshHome,
                ),
              )
            else if (products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _HomeDataState(
                  message: localizeMiniProgramLabel(context, '暂无匹配商品'),
                  onRetry: controller.refreshHome,
                ),
              )
            else ...[
              _HomeWaterfall(controller: controller, component: recommendation),
              SliverToBoxAdapter(
                child: _HomePagingFooter(controller: controller),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomePageTabs extends StatelessWidget {
  const _HomePageTabs({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          itemCount: controller.homePages.length,
          separatorBuilder: (_, _) => const SizedBox(width: 22),
          itemBuilder: (context, index) {
            final page = controller.homePages[index];
            final active = index == controller.homePageIndex;
            return InkWell(
              onTap: () => unawaited(controller.selectHomePage(index)),
              child: SizedBox(
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (controller.isHomePageLoading(index))
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      )
                    else
                      Text(
                        page.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: active
                              ? TospinoColors.solidBrand(context)
                              : TospinoColors.resolve(
                                  context,
                                  TospinoColors.secondary,
                                ),
                          fontSize: 15,
                          fontWeight: active
                              ? TospinoText.emphasis
                              : TospinoText.regular,
                        ),
                      ),
                    const SizedBox(height: 7),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: active ? 24 : 0,
                      height: 2,
                      color: TospinoColors.solidBrand(context),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeRecommendWords extends StatelessWidget {
  const _HomeRecommendWords({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          scrollDirection: Axis.horizontal,
          itemCount: controller.homeRecommendWords.length,
          separatorBuilder: (_, _) => const SizedBox(width: 7),
          itemBuilder: (context, index) {
            final word = controller.homeRecommendWords[index];
            return Material(
              color: TospinoColors.resolve(context, TospinoColors.surface),
              borderRadius: BorderRadius.circular(15),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  controller.openSearch();
                  controller.search(word);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.lineStrong,
                      ),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    word,
                    maxLines: 1,
                    style: TospinoText.body(context),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeDecorationBody extends StatelessWidget {
  const _HomeDecorationBody({required this.controller, required this.page});

  final TospinoAppController controller;
  final TospinoHomePageDecoration page;

  /// Android HomeAdapter3.LOWER_GAP_DEFAULT = 30 design units = 10dp.
  static const _defaultComponentGap = 10.0;

  @override
  Widget build(BuildContext context) {
    final components = page.components
        .where(
          (component) =>
              component.isVisible &&
              component.type != TospinoHomeComponent.waterfall,
        )
        .toList(growable: false);
    return Column(
      children: [
        for (var index = 0; index < components.length; index++)
          Padding(
            padding: EdgeInsets.only(bottom: _componentGap(components[index])),
            child: _HomeDecorationComponent(
              key: ValueKey(
                '${page.id}-${components[index].type}-${components[index].name}-$index',
              ),
              controller: controller,
              pageId: page.id,
              component: components[index],
            ),
          ),
      ],
    );
  }

  double _componentGap(TospinoHomeComponent component) {
    if (component.lowerGap > 0) {
      return component.lowerGap.clamp(0, 12).toDouble();
    }
    return _defaultComponentGap;
  }
}

class _HomeDecorationComponent extends StatelessWidget {
  const _HomeDecorationComponent({
    super.key,
    required this.controller,
    required this.pageId,
    required this.component,
  });

  final TospinoAppController controller;
  final String pageId;
  final TospinoHomeComponent component;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = _sidePadding;
    switch (component.type) {
      case TospinoHomeComponent.banner:
        return _HomeBannerCarousel(
          component: component,
          horizontalPadding: horizontalPadding,
          onTap: (item) => _openItem(context, item),
        );
      case TospinoHomeComponent.diamondArea:
        return _HomeDiamondArea(
          component: component,
          onTap: (item) => _openItem(context, item),
        );
      case TospinoHomeComponent.hotImage:
        if (component.imageUrl.isEmpty) return const SizedBox.shrink();
        return _HomeHotImage(
          component: component,
          horizontalPadding: horizontalPadding,
          onTap: (item) => _openItem(context, item),
        );
      case TospinoHomeComponent.secondLevelCategory:
        return _HomeImageGrid(
          component: component,
          columns: 3,
          horizontalPadding: horizontalPadding,
          showLabels: true,
          onTap: (item) => _openItem(context, item),
        );
      case TospinoHomeComponent.oneImage:
        return _HomeImageGrid(
          component: component,
          columns: 1,
          horizontalPadding: horizontalPadding,
          showLabels: false,
          onTap: (item) => _openItem(context, item),
        );
      case TospinoHomeComponent.twoImages:
        return _HomeImageGrid(
          component: component,
          columns: 2,
          horizontalPadding: horizontalPadding,
          showLabels: false,
          onTap: (item) => _openItem(context, item),
        );
      case TospinoHomeComponent.threeImages:
        return _HomeImageGrid(
          component: component,
          columns: 3,
          horizontalPadding: horizontalPadding,
          showLabels: false,
          onTap: (item) => _openItem(context, item),
        );
      case TospinoHomeComponent.twoByTwoImages:
        return _HomeImageGrid(
          component: component,
          columns: 2,
          horizontalPadding: horizontalPadding,
          showLabels: false,
          onTap: (item) => _openItem(context, item),
        );
      case TospinoHomeComponent.twoProducts:
      case TospinoHomeComponent.threeProducts:
        return _HomeProductRail(
          controller: controller,
          pageId: pageId,
          component: component,
        );
      case TospinoHomeComponent.video:
        return _HomeImageGrid(
          component: component,
          columns: 1,
          horizontalPadding: horizontalPadding,
          showLabels: false,
          onTap: (item) => _openItem(context, item),
        );
      default:
        if (component.items.isNotEmpty) {
          return _HomeImageGrid(
            component: component,
            columns: component.items.length == 1 ? 1 : 2,
            horizontalPadding: horizontalPadding,
            showLabels: false,
            onTap: (item) => _openItem(context, item),
          );
        }
        if (component.title.isNotEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(component.title, style: TospinoText.section(context)),
            ),
          );
        }
        return const SizedBox.shrink();
    }
  }

  double get _sidePadding {
    if (component.leftGap > 0) {
      return component.leftGap.clamp(0, 40).toDouble();
    }
    return 0;
  }

  void _openItem(BuildContext context, TospinoHomeComponentItem item) {
    if (item.goodsIds.isNotEmpty) {
      unawaited(
        controller.openProduct(
          TospinoProduct(
            id: item.goodsIds.first,
            title: item.title,
            price: 0,
            imageUrl: item.displayImageUrl,
          ),
        ),
      );
      return;
    }
    if (item.categoryIds.isNotEmpty) {
      unawaited(controller.selectCategory(item.categoryIds.first));
      controller.switchTab(1);
      return;
    }
    if (item.linkAddress == '/home/freeGet') {
      controller.open(TospinoRoute.freeGift);
      return;
    }
    if (item.linkAddress.isNotEmpty || item.title.isNotEmpty) {
      showTospinoToast(
        context,
        item.title.isNotEmpty ? item.title : item.linkAddress,
      );
    }
  }
}

class _HomeHotImage extends StatefulWidget {
  const _HomeHotImage({
    required this.component,
    required this.horizontalPadding,
    required this.onTap,
  });

  final TospinoHomeComponent component;
  final double horizontalPadding;
  final ValueChanged<TospinoHomeComponentItem> onTap;

  @override
  State<_HomeHotImage> createState() => _HomeHotImageState();
}

class _HomeHotImageState extends State<_HomeHotImage> {
  double _aspectRatio = 2.2;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImageRatio();
  }

  void _resolveImageRatio() {
    if (_imageListener != null || widget.component.imageUrl.isEmpty) return;
    final stream = NetworkImage(
      widget.component.imageUrl,
    ).resolve(createLocalImageConfiguration(context));
    late final ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      final width = info.image.width;
      final height = info.image.height;
      if (mounted && width > 0 && height > 0) {
        setState(() => _aspectRatio = width / height);
      }
      stream.removeListener(listener);
      if (identical(_imageListener, listener)) {
        _imageStream = null;
        _imageListener = null;
      }
    });
    _imageStream = stream;
    _imageListener = listener;
    stream.addListener(listener);
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = width / _aspectRatio;
          return AspectRatio(
            aspectRatio: _aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.component.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: TospinoColors.resolve(
                      context,
                      TospinoColors.imagePlaceholder,
                    ),
                    child: const Center(child: Icon(Icons.image_outlined)),
                  ),
                ),
                for (final item in widget.component.items)
                  if (item.positionWidth > 0 && item.positionHeight > 0)
                    Positioned(
                      left: item.positionLeft / 375 * width,
                      top: item.positionTop / (375 / _aspectRatio) * height,
                      width: item.positionWidth / 375 * width,
                      height:
                          item.positionHeight / (375 / _aspectRatio) * height,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onTap(item),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeDiamondArea extends StatelessWidget {
  const _HomeDiamondArea({required this.component, required this.onTap});

  final TospinoHomeComponent component;
  final ValueChanged<TospinoHomeComponentItem> onTap;

  @override
  Widget build(BuildContext context) {
    final items = component.items
        .where((item) => item.displayImageUrl.isNotEmpty)
        .toList(growable: false);
    if (items.isEmpty) return const SizedBox.shrink();
    final rows = component.displayRows > 0 ? component.displayRows : 1;
    final columns = (items.length / rows).ceil().clamp(1, items.length).toInt();
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileWidth = constraints.maxWidth / columns;
          return Column(
            children: [
              for (var row = 0; row < rows; row++)
                Row(
                  children: [
                    for (var column = 0; column < columns; column++)
                      SizedBox(
                        width: tileWidth,
                        child: _buildItem(
                          context,
                          row * columns + column,
                          items,
                          showImageName: component.showImageName,
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    List<TospinoHomeComponentItem> items, {
    required bool showImageName,
  }) {
    if (index >= items.length) {
      return SizedBox(height: showImageName ? 88 : 61);
    }
    final item = items[index];
    return InkWell(
      onTap: () => onTap(item),
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: showImageName ? 88 : 61),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: TospinoColors.resolve(context, TospinoColors.surface),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                item.displayImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.imagePlaceholder,
                  ),
                  child: const Icon(Icons.image_outlined, size: 20),
                ),
              ),
            ),
            if (showImageName) ...[
              const SizedBox(height: 7),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TospinoText.body(
                  context,
                ).copyWith(fontSize: 13, height: 1.2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeImageGrid extends StatelessWidget {
  const _HomeImageGrid({
    required this.component,
    required this.columns,
    required this.horizontalPadding,
    required this.showLabels,
    required this.onTap,
  });

  final TospinoHomeComponent component;
  final int columns;
  final double horizontalPadding;
  final bool showLabels;
  final ValueChanged<TospinoHomeComponentItem> onTap;

  @override
  Widget build(BuildContext context) {
    final items = component.items
        .where((item) => item.displayImageUrl.isNotEmpty)
        .toList(growable: false);
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const itemGap = 4.0;
          final itemWidth =
              (constraints.maxWidth - itemGap * (columns - 1)) / columns;
          final rowCount = (items.length / columns).ceil();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (component.showTitle && component.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    component.title,
                    style: TospinoText.section(context),
                  ),
                ),
              for (var row = 0; row < rowCount; row++)
                Padding(
                  padding: EdgeInsets.only(bottom: row == rowCount - 1 ? 0 : 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var column = 0; column < columns; column++) ...[
                        if (column > 0) const SizedBox(width: itemGap),
                        SizedBox(
                          width: itemWidth,
                          child: _buildItem(
                            context,
                            items,
                            row * columns + column,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    List<TospinoHomeComponentItem> items,
    int index,
  ) {
    if (index >= items.length) return const SizedBox.shrink();
    final item = items[index];
    return InkWell(
      onTap: () => onTap(item),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _IntrinsicNetworkImage(
              url: item.displayImageUrl,
              fit: BoxFit.cover,
              fallbackAspectRatio: columns == 1 ? 2.2 : 1,
            ),
          ),
          if (showLabels && item.title.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TospinoText.body(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _IntrinsicNetworkImage extends StatefulWidget {
  const _IntrinsicNetworkImage({
    required this.url,
    required this.fit,
    this.fallbackAspectRatio = 1,
  });

  final String url;
  final BoxFit fit;
  final double fallbackAspectRatio;

  @override
  State<_IntrinsicNetworkImage> createState() => _IntrinsicNetworkImageState();
}

class _IntrinsicNetworkImageState extends State<_IntrinsicNetworkImage> {
  late double _aspectRatio = widget.fallbackAspectRatio;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  void _resolve() {
    if (_listener != null) return;
    final stream = NetworkImage(
      widget.url,
    ).resolve(createLocalImageConfiguration(context));
    late final ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      if (mounted && info.image.width > 0 && info.image.height > 0) {
        setState(
          () => _aspectRatio = (info.image.width / info.image.height).clamp(
            0.25,
            4,
          ),
        );
      }
      stream.removeListener(listener);
      if (identical(_listener, listener)) {
        _stream = null;
        _listener = null;
      }
    });
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: Image.network(
        widget.url,
        width: double.infinity,
        fit: widget.fit,
        errorBuilder: (_, _, _) => ColoredBox(
          color: TospinoColors.resolve(context, TospinoColors.imagePlaceholder),
          child: const Center(child: Icon(Icons.image_outlined)),
        ),
      ),
    );
  }
}

class _HomeBannerCarousel extends StatefulWidget {
  const _HomeBannerCarousel({
    required this.component,
    required this.horizontalPadding,
    required this.onTap,
  });

  final TospinoHomeComponent component;
  final double horizontalPadding;
  final ValueChanged<TospinoHomeComponentItem> onTap;

  @override
  State<_HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<_HomeBannerCarousel> {
  final _pageController = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.component.items
        .where((item) => item.displayImageUrl.isNotEmpty)
        .toList(growable: false);
    if (items.isEmpty) return const SizedBox.shrink();
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final bannerHeight = widget.component.height > 0
        ? widget.component.height * 2.8 / devicePixelRatio
        : 186.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: SizedBox(
        height: bannerHeight,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (index) => setState(() => _current = index),
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => widget.onTap(item),
                  child: Image.network(
                    item.displayImageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fill,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.imagePlaceholder,
                      ),
                      child: const Center(child: Icon(Icons.image_outlined)),
                    ),
                  ),
                );
              },
            ),
            if (items.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < items.length; index++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3.5),
                        decoration: BoxDecoration(
                          color: index == _current
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeProductRail extends StatelessWidget {
  const _HomeProductRail({
    required this.controller,
    required this.pageId,
    required this.component,
  });

  final TospinoAppController controller;
  final String pageId;
  final TospinoHomeComponent component;

  @override
  Widget build(BuildContext context) {
    final ids = component.goodsIds.take(20).toList(growable: false);
    if (ids.isEmpty) return const SizedBox.shrink();
    final isThreeColumns = component.type == TospinoHomeComponent.threeProducts;
    final cardWidth = isThreeColumns
        ? (MediaQuery.sizeOf(context).width - 44) / 2.7
        : (MediaQuery.sizeOf(context).width - 36) / 2;
    return FutureBuilder<List<TospinoProduct>>(
      future: controller.productsForHomeComponent(
        '$pageId-${component.type}',
        ids,
      ),
      builder: (context, snapshot) {
        final products = snapshot.data ?? const <TospinoProduct>[];
        if (products.isEmpty) {
          return snapshot.connectionState == ConnectionState.waiting
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }
        final background = _parseHomeColor(component.baseColor);
        return ColoredBox(
          color: background ?? Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (component.showTitle && component.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
                  child: Text(
                    component.title,
                    style: TospinoText.section(context),
                  ),
                ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < products.length; index++) ...[
                      if (index > 0) const SizedBox(width: 4),
                      SizedBox(
                        width: cardWidth,
                        child: TospinoProductTile(
                          product: products[index],
                          artworkHeight: isThreeColumns ? 116 : 132,
                          fillHeight: false,
                          showSales: component.showSales,
                          showRating: component.showRating,
                          titleLines: isThreeColumns ? 1 : 2,
                          compact: true,
                          onTap: () => controller.openProduct(products[index]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Color? _parseHomeColor(String value) {
  final hex = value.trim().replaceFirst('#', '');
  if (hex.length != 6 && hex.length != 8) return null;
  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return null;
  return Color(hex.length == 6 ? 0xFF000000 | parsed : parsed);
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: MiniProgramCapsuleOverlay.reservedRight,
              ),
              child: SizedBox(
                height: 38,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    key: const Key('tospino-home-logo'),
                    'lib/miniapp/tospino/assets/tospino-logo.webp',
                    width: 27,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              height: 34,
              decoration: BoxDecoration(
                color: TospinoColors.resolve(
                  context,
                  TospinoColors.surfaceMuted,
                ),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      key: const Key('tospino-home-search'),
                      onTap: controller.openSearch,
                      borderRadius: BorderRadius.circular(17),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 21,
                              color: TospinoColors.resolve(
                                context,
                                TospinoColors.hint,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                localizeMiniProgramLabel(context, '搜索感兴趣商品'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TospinoText.hint(
                                  context,
                                ).copyWith(fontSize: 12),
                              ),
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
      ),
    );
  }
}

class _HomeCategoryChips extends StatelessWidget {
  const _HomeCategoryChips({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 3, 12, 7),
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 7),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Material(
              color: TospinoColors.resolve(context, TospinoColors.surface),
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  controller
                    ..selectCategory(category.id)
                    ..switchTab(1);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TospinoColors.resolve(
                        context,
                        TospinoColors.lineStrong,
                      ),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    category.label,
                    maxLines: 1,
                    style: TospinoText.body(context).copyWith(fontSize: 14),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeBanner extends StatelessWidget {
  const _HomeBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 184,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF4FBFD), Color(0xFFD9EFF5)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -38,
              top: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 22,
              bottom: 12,
              child: Icon(
                Icons.headphones_rounded,
                size: 126,
                color: const Color(0xFF32325D).withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              right: 24,
              top: 26,
              child: Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F8FEA), Color(0xFF12CDA9)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ONLY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '119',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: TospinoText.strong,
                        height: 1,
                      ),
                    ),
                    Text(
                      'GH₵',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 14,
              right: 106,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: TospinoColors.brand,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'For Apple AirPods (3rd Generation)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Wireless Earbuds',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF22224D),
                      fontSize: 27,
                      fontWeight: TospinoText.strong,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Up to 30 hours of battery life,\nspatial audio and water resistance.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF4A4A5F),
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 18,
                        color: TospinoColors.brand,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        localizeMiniProgramLabel(context, '官方配送'),
                        style: TextStyle(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.secondary,
                          ),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: TospinoColors.brandGradient(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              localizeMiniProgramLabel(context, '立即抢购'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
    );
  }
}

class _HomeActionGrid extends StatelessWidget {
  const _HomeActionGrid({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final actions = <_HomeActionData>[
      _HomeActionData(
        '优惠券中心',
        Icons.confirmation_number_outlined,
        const Color(0xFF2CB7AE),
        () => showTospinoToast(context, '优惠券中心'),
      ),
      _HomeActionData(
        '海外购',
        Icons.public_rounded,
        const Color(0xFF21B5B0),
        () => controller.switchTab(1),
      ),
      _HomeActionData(
        'GH 仓库',
        Icons.warehouse_outlined,
        const Color(0xFF22B3AF),
        () => controller.switchTab(1),
      ),
      _HomeActionData(
        '免费拿',
        Icons.card_giftcard_rounded,
        const Color(0xFF2CB7AE),
        () => showTospinoToast(context, '免费拿'),
      ),
      _HomeActionData(
        '为你推荐',
        Icons.local_fire_department_rounded,
        const Color(0xFFFF8A3D),
        () => controller.switchTab(1),
      ),
      _HomeActionData(
        '服务/投诉',
        Icons.support_agent_rounded,
        const Color(0xFFFF7B35),
        () => showTospinoToast(context, '客服功能即将开放'),
      ),
    ];
    return ColoredBox(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          children: [
            for (var row = 0; row < 2; row++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    for (final action in actions.skip(row * 3).take(3))
                      Expanded(child: _HomeAction(action: action)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionData {
  const _HomeActionData(this.label, this.icon, this.color, this.onTap);

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({required this.action});

  final _HomeActionData action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(action.color, Colors.white, 0.18)!,
                    action.color,
                  ],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(action.icon, color: Colors.white, size: 25),
            ),
            const SizedBox(height: 7),
            Text(
              localizeMiniProgramLabel(context, action.label),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TospinoText.body(
                context,
              ).copyWith(fontSize: 13, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeServiceStrip extends StatelessWidget {
  const _HomeServiceStrip();

  @override
  Widget build(BuildContext context) {
    final first = <_ServiceData>[
      _ServiceData('追踪包裹', '实时查看物流', Icons.inventory_2_outlined),
      _ServiceData('寄送包裹', '覆盖加纳主要地区', Icons.local_shipping_outlined),
      _ServiceData('自提点', '查找附近网点', Icons.location_on_outlined),
      _ServiceData('国际配送', '全球跨境送达', Icons.public_rounded),
    ];
    final second = <_ServiceData>[
      _ServiceData('Tospino 履约', '官方仓配', Icons.verified_outlined),
      _ServiceData('100% 正品', '品牌官方保障', Icons.workspace_premium_outlined),
      _ServiceData('轻松退换', '7 天无忧退换', Icons.support_agent_rounded),
      _ServiceData('安全支付', '交易全程保护', Icons.account_balance_wallet_outlined),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Column(
        children: [
          _ServiceCard(items: first),
          const SizedBox(height: 10),
          _ServiceCard(items: second),
        ],
      ),
    );
  }
}

class _ServiceData {
  const _ServiceData(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.items});

  final List<_ServiceData> items;

  @override
  Widget build(BuildContext context) {
    return TospinoSurface(
      border: true,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Expanded(
              child: Column(
                children: [
                  Icon(
                    item.icon,
                    color: TospinoColors.solidBrand(context),
                    size: 21,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    localizeMiniProgramLabel(context, item.title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TospinoText.body(context).copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    localizeMiniProgramLabel(context, item.subtitle),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TospinoText.hint(
                      context,
                    ).copyWith(fontSize: 9, height: 1.15),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeWaterfall extends StatelessWidget {
  const _HomeWaterfall({required this.controller, this.component});

  final TospinoAppController controller;
  final TospinoHomeComponent? component;

  @override
  Widget build(BuildContext context) {
    final products = controller.homeProducts;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      sliver: SliverCrossAxisGroup(
        slivers: [
          SliverCrossAxisExpanded(
            flex: 1,
            sliver: SliverPadding(
              padding: const EdgeInsets.only(right: 2.5),
              sliver: _HomeWaterfallColumn(
                products: products,
                startIndex: 0,
                controller: controller,
                component: component,
              ),
            ),
          ),
          SliverCrossAxisExpanded(
            flex: 1,
            sliver: SliverPadding(
              padding: const EdgeInsets.only(left: 2.5),
              sliver: _HomeWaterfallColumn(
                products: products,
                startIndex: 1,
                controller: controller,
                component: component,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeWaterfallColumn extends StatelessWidget {
  const _HomeWaterfallColumn({
    required this.products,
    required this.startIndex,
    required this.controller,
    this.component,
  });

  final List<TospinoProduct> products;
  final int startIndex;
  final TospinoAppController controller;
  final TospinoHomeComponent? component;
  static const _verticalGap = 8.0;

  @override
  Widget build(BuildContext context) {
    final count = (products.length + 1 - startIndex) ~/ 2;
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final productIndex = startIndex + index * 2;
        final product = products[productIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: _verticalGap),
          child: TospinoProductTile(
            product: product,
            artworkHeight: _artworkHeight(product, productIndex),
            fillHeight: false,
            showSales: component?.showSales ?? true,
            showRating: component?.showRating ?? false,
            onTap: () => controller.openProduct(product),
          ),
        );
      }, childCount: count),
    );
  }

  double _artworkHeight(TospinoProduct product, int index) {
    final seed = product.id.isEmpty
        ? index
        : product.id.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return switch (seed % 4) {
      0 => 132,
      1 => 162,
      2 => 146,
      _ => 174,
    };
  }
}

class _HomePagingFooter extends StatelessWidget {
  const _HomePagingFooter({required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.loadingMoreHome) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: TospinoColors.solidBrand(context),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              localizeMiniProgramLabel(context, '加载更多商品'),
              style: TospinoText.meta(context),
            ),
          ],
        ),
      );
    }
    if (controller.homeMoreError != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        child: Center(
          child: TextButton(
            onPressed: controller.loadMoreHome,
            child: Text(localizeMiniProgramLabel(context, '加载更多失败，点击重试')),
          ),
        ),
      );
    }
    if (!controller.homeHasMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        child: Center(
          child: Text(
            localizeMiniProgramLabel(context, '没有更多商品了'),
            style: TospinoText.meta(context),
          ),
        ),
      );
    }
    return const SizedBox(height: 10);
  }
}

class _HomeDataState extends StatelessWidget {
  const _HomeDataState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: TospinoColors.resolve(context, TospinoColors.hint),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TospinoText.secondary(context),
            ),
            const SizedBox(height: 14),
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
