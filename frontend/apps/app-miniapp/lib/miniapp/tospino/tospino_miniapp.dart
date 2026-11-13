import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/common.dart';
import '../launcher/miniapp_launcher_item.dart';
import 'pages/about_page.dart';
import 'pages/address_page.dart';
import 'pages/cart_page.dart';
import 'pages/category_page.dart';
import 'pages/checkout_page.dart';
import 'pages/favorites_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/order_detail_page.dart';
import 'pages/orders_page.dart';
import 'pages/product_page.dart';
import 'pages/profile_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'tospino_routes.dart';
import 'tospino_style.dart';

/// Tospino shopping mini-program.
///
/// The first version is a complete static prototype. Navigation, cart,
/// favorites and created orders are stateful so a real repository can replace
/// the local data without changing the pages.
class TospinoMiniProgram extends StatefulWidget {
  const TospinoMiniProgram({
    super.key,
    this.onExit,
    this.controller,
    this.initialProductId,
  });

  final VoidCallback? onExit;
  final TospinoAppController? controller;
  final String? initialProductId;

  static Route<void> route({VoidCallback? onExit, String? initialProductId}) {
    return MaterialPageRoute<void>(
      builder: (context) => TospinoMiniProgram(
        onExit: onExit ?? () => Navigator.of(context).pop(),
        initialProductId: initialProductId,
      ),
    );
  }

  @override
  State<TospinoMiniProgram> createState() => _TospinoMiniProgramState();
}

class _TospinoMiniProgramState extends State<TospinoMiniProgram> {
  late final TospinoAppController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        TospinoAppController(initialProductId: widget.initialProductId);
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _exit() {
    final callback = widget.onExit;
    if (callback != null) {
      callback();
      return;
    }
    Navigator.of(context).maybePop();
  }

  void _showMore() {
    showMiniProgramActionsSheet(
      context,
      title: 'Tospino',
      subtitle: 'Shopping · local prototype',
      icon: Icons.storefront_rounded,
      onRestart: _controller.resetToHome,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: TospinoTheme.data(brightness: Theme.of(context).brightness),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final route = _controller.route;
          final page = TospinoPageRouter.build(route, _controller);
          final brandNavigation = route.isTabRoot && route != TospinoRoute.cart;
          final background = brandNavigation
              ? TospinoColors.solidBrand(context)
              : TospinoColors.resolve(context, TospinoColors.surface);
          final foreground = brandNavigation
              ? Colors.white
              : TospinoColors.resolve(context, TospinoColors.ink);
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (_controller.canGoBack) {
                _controller.back();
              } else {
                _exit();
              }
            },
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: background,
                statusBarIconBrightness: brandNavigation
                    ? Brightness.light
                    : Theme.of(context).brightness == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark,
                statusBarBrightness: brandNavigation
                    ? Brightness.dark
                    : Theme.of(context).brightness,
              ),
              child: Scaffold(
                backgroundColor: TospinoColors.resolve(
                  context,
                  TospinoColors.background,
                ),
                body: Material(
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.background,
                  ),
                  child: Column(
                    children: [
                      MiniProgramStatusBar(
                        backgroundColor: background,
                        foregroundColor: foreground,
                        fallbackHeight: 26,
                        fontSize: 11,
                        iconSize: 13,
                        iconGap: 4,
                      ),
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(
                              color: brandNavigation
                                  ? TospinoColors.solidBrand(context)
                                  : TospinoColors.resolve(
                                      context,
                                      TospinoColors.background,
                                    ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 210),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                layoutBuilder:
                                    (currentChild, previousChildren) {
                                      return Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ...previousChildren,
                                          ?currentChild,
                                        ],
                                      );
                                    },
                                transitionBuilder: (child, animation) {
                                  final begin = Offset(
                                    _controller.forward ? 0.06 : -0.06,
                                    0,
                                  );
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: begin,
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: KeyedSubtree(
                                  key: ValueKey(route),
                                  child: route == TospinoRoute.home
                                      ? page
                                      : route.isTabRoot
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            top: MiniProgramCapsuleOverlay
                                                .reservedHeight,
                                          ),
                                          child: page,
                                        )
                                      : Column(
                                          children: [
                                            ColoredBox(
                                              color: TospinoColors.resolve(
                                                context,
                                                TospinoColors.background,
                                              ),
                                              child: MiniProgramPageHeader(
                                                title: route.title,
                                                onBack: _controller.canGoBack
                                                    ? _controller.back
                                                    : null,
                                                foregroundColor:
                                                    TospinoColors.resolve(
                                                      context,
                                                      TospinoColors.ink,
                                                    ),
                                              ),
                                            ),
                                            Expanded(child: page),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 10,
                              child: MiniProgramCapsuleOverlay(
                                miniProgramId: MiniProgramLauncherIds.tospino,
                                onMore: _showMore,
                                onClose: _exit,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (route.isTabRoot)
                        _TospinoBottomNavigation(
                          index: _controller.tabIndex,
                          cartCount: _controller.cartCount,
                          onChanged: _controller.switchTab,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TospinoPageRouter {
  const TospinoPageRouter._();

  static Widget build(TospinoRoute route, TospinoAppController controller) {
    return switch (route) {
      TospinoRoute.home => TospinoHomePage(controller: controller),
      TospinoRoute.category => TospinoCategoryPage(controller: controller),
      TospinoRoute.cart => TospinoCartPage(controller: controller),
      TospinoRoute.profile => TospinoProfilePage(controller: controller),
      TospinoRoute.search => TospinoSearchPage(controller: controller),
      TospinoRoute.product => TospinoProductPage(controller: controller),
      TospinoRoute.checkout => TospinoCheckoutPage(controller: controller),
      TospinoRoute.orders => TospinoOrdersPage(controller: controller),
      TospinoRoute.orderDetail => TospinoOrderDetailPage(
        controller: controller,
      ),
      TospinoRoute.favorites => TospinoFavoritesPage(controller: controller),
      TospinoRoute.address => TospinoAddressPage(controller: controller),
      TospinoRoute.login => TospinoLoginPage(controller: controller),
      TospinoRoute.settings => TospinoSettingsPage(controller: controller),
      TospinoRoute.about => TospinoAboutPage(controller: controller),
    };
  }
}

class _TospinoBottomNavigation extends StatelessWidget {
  const _TospinoBottomNavigation({
    required this.index,
    required this.cartCount,
    required this.onChanged,
  });

  final int index;
  final int cartCount;
  final ValueChanged<int> onChanged;

  static const _items = <(String, IconData, IconData)>[
    ('首页', Icons.home_outlined, Icons.home_rounded),
    ('分类', Icons.grid_view_outlined, Icons.grid_view_rounded),
    ('购物车', Icons.shopping_cart_outlined, Icons.shopping_cart_rounded),
    ('我的', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        border: Border(
          top: BorderSide(
            color: TospinoColors.resolve(context, TospinoColors.line),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 55,
          child: Row(
            children: [
              for (var itemIndex = 0; itemIndex < _items.length; itemIndex++)
                Expanded(
                  child: InkWell(
                    key: Key('tospino-tab-${_items[itemIndex].$1}'),
                    onTap: () => onChanged(itemIndex),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: itemIndex == index ? 36 : 30,
                              height: 27,
                              decoration: BoxDecoration(
                                color: itemIndex == index
                                    ? TospinoColors.resolve(
                                        context,
                                        TospinoColors.brandPale,
                                      )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                itemIndex == index
                                    ? _items[itemIndex].$3
                                    : _items[itemIndex].$2,
                                size: 20,
                                color: itemIndex == index
                                    ? TospinoColors.solidBrand(context)
                                    : TospinoColors.resolve(
                                        context,
                                        TospinoColors.muted,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              localizeMiniProgramLabel(
                                context,
                                _items[itemIndex].$1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: itemIndex == index
                                    ? TospinoColors.solidBrand(context)
                                    : TospinoColors.resolve(
                                        context,
                                        TospinoColors.muted,
                                      ),
                                fontSize: 9.5,
                                fontWeight: itemIndex == index
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (itemIndex == 2 && cartCount > 0)
                          Positioned(
                            top: 2,
                            right: 25,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: TospinoColors.price,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                cartCount > 99 ? '99+' : '$cartCount',
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
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
