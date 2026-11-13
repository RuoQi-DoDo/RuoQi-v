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
import 'pages/coupons_page.dart';
import 'pages/favorites_page.dart';
import 'pages/free_gift_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/order_detail_page.dart';
import 'pages/orders_page.dart';
import 'pages/product_page.dart';
import 'pages/profile_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'pages/shop_follow_page.dart';
import 'pages/wallet_page.dart';
import 'tospino_routes.dart';
import 'tospino_style.dart';

const double tospinoAndroidDesignWidth = 375;
const double tospinoAndroidGlyphCompensation = 0.519 / 0.546;

double tospinoAndroidWidthScale(double logicalWidth) =>
    logicalWidth.clamp(0, tospinoAndroidDesignWidth) /
    tospinoAndroidDesignWidth;

/// Matches Tospino Android's `BaseApplication` text scaling:
/// system font scale * width scale * Inter x-height correction.
///
/// Font weight only selects Regular or Medium in `font/inter.xml`; it does not
/// change the Android `sp` value.
TextScaler tospinoAndroidTextScaler(
  TextScaler hostScaler,
  double logicalWidth,
) => _TospinoAndroidTextScaler(
  hostScaler,
  tospinoAndroidWidthScale(logicalWidth) * tospinoAndroidGlyphCompensation,
);

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
  TospinoRoute? _statusRoute;
  bool _statusScrolled = false;

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

  bool _handleScroll(ScrollNotification notification) {
    _setStatusScrolled(notification.metrics.pixels > 8);
    return false;
  }

  void _setStatusScrolled(bool scrolled) {
    if (scrolled != _statusScrolled) {
      setState(() => _statusScrolled = scrolled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: TospinoTheme.data(brightness: Theme.of(context).brightness),
      child: _TospinoTextScaleScope(
        child: AnimatedBuilder(animation: _controller, builder: _buildContent),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Widget? _) {
    final route = _controller.route;
    if (_statusRoute != route) {
      _statusRoute = route;
      _statusScrolled = false;
    }
    final page = TospinoPageRouter.build(route, _controller);
    final transparentStatusBar = route == TospinoRoute.profile;
    final background = route.isTabRoot && _statusScrolled
        ? TospinoColors.resolve(context, TospinoColors.background)
        : TospinoColors.resolve(context, TospinoColors.surface);
    final foreground = TospinoColors.resolve(context, TospinoColors.ink);
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
          statusBarColor: transparentStatusBar
              ? Colors.transparent
              : background,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: Theme.of(context).brightness,
        ),
        child: Scaffold(
          backgroundColor: TospinoColors.resolve(
            context,
            TospinoColors.background,
          ),
          body: Material(
            color: TospinoColors.resolve(context, TospinoColors.background),
            child: Column(
              children: [
                if (!transparentStatusBar)
                  MiniProgramStatusBar(
                    backgroundColor: background,
                    foregroundColor: foreground,
                    fallbackHeight: 26,
                    fontSize: 11,
                    iconSize: 13,
                    iconGap: 4,
                  ),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _handleScroll,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.background,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 210),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [...previousChildren, ?currentChild],
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
                                  : MiniProgramPageCanvas(
                                      title: route.title,
                                      showTitle:
                                          route != TospinoRoute.login &&
                                          (!route.isTabRoot ||
                                              route == TospinoRoute.category),
                                      onBack:
                                          !route.isTabRoot &&
                                              _controller.canGoBack
                                          ? _controller.back
                                          : null,
                                      foregroundColor: TospinoColors.resolve(
                                        context,
                                        TospinoColors.ink,
                                      ),
                                      onScrollChanged: _setStatusScrolled,
                                      child: page,
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          top:
                              (transparentStatusBar
                                  ? MediaQuery.paddingOf(context).top
                                  : 0) +
                              5,
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
  }
}

class _TospinoTextScaleScope extends StatelessWidget {
  const _TospinoTextScaleScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: tospinoAndroidTextScaler(
          media.textScaler,
          media.size.width,
        ),
      ),
      child: child,
    );
  }
}

class _TospinoAndroidTextScaler extends TextScaler {
  const _TospinoAndroidTextScaler(this.hostScaler, this.correction);

  final TextScaler hostScaler;
  final double correction;

  @override
  double scale(double fontSize) => hostScaler.scale(fontSize) * correction;

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is _TospinoAndroidTextScaler &&
      other.hostScaler == hostScaler &&
      other.correction == correction;

  @override
  int get hashCode => Object.hash(hostScaler, correction);
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
      TospinoRoute.freeGift => TospinoFreeGiftPage(controller: controller),
      TospinoRoute.wallet => TospinoWalletPage(controller: controller),
      TospinoRoute.coupons => TospinoCouponsPage(controller: controller),
      TospinoRoute.shopFollow => TospinoShopFollowPage(controller: controller),
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

  static const _items = <(int, String, IconData, IconData)>[
    (0, '首页', Icons.home_outlined, Icons.home_rounded),
    (
      3,
      '我的',
      Icons.sentiment_satisfied_alt_outlined,
      Icons.sentiment_satisfied_alt_rounded,
    ),
    (2, '购物车', Icons.shopping_cart_outlined, Icons.shopping_cart_rounded),
    (1, '分类', Icons.grid_view_outlined, Icons.grid_view_rounded),
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
          height: 48,
          child: Row(
            children: [
              for (final item in _items)
                Expanded(
                  child: Tooltip(
                    message: localizeMiniProgramLabel(context, item.$2),
                    child: InkWell(
                      key: Key('tospino-tab-${item.$2}'),
                      onTap: () => onChanged(item.$1),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            item.$1 == index ? item.$4 : item.$3,
                            size: 24,
                            color: item.$1 == index
                                ? TospinoColors.solidBrand(context)
                                : TospinoColors.resolve(
                                    context,
                                    TospinoColors.hint,
                                  ),
                          ),
                          if (item.$1 == 2 && cartCount > 0)
                            Positioned(
                              top: 3,
                              right: 28,
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
                                    fontWeight: TospinoText.strong,
                                  ),
                                ),
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
      ),
    );
  }
}
