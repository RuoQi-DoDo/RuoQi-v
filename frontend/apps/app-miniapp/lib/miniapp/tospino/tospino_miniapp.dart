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
import 'pages/messages_page.dart';
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
const double tospinoReadableTextScale = 1.10;

double tospinoAndroidWidthScale(double logicalWidth) =>
    logicalWidth.clamp(0, tospinoAndroidDesignWidth) /
    tospinoAndroidDesignWidth;

/// Keeps Tospino's width-aware scaling while avoiding unreadably small labels
/// on compact phones. System accessibility scaling remains applied first.
///
/// Font weight only selects Regular or Medium in `font/inter.xml`; it does not
/// change the Android `sp` value.
TextScaler tospinoAndroidTextScaler(
  TextScaler hostScaler,
  double logicalWidth,
) => _TospinoAndroidTextScaler(
  hostScaler,
  tospinoAndroidWidthScale(logicalWidth) *
      tospinoAndroidGlyphCompensation *
      tospinoReadableTextScale,
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
  bool _loginSheetShowing = false;

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
    _scheduleLoginSheet();
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
                    fontSize: 11.5,
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

  void _scheduleLoginSheet() {
    if (!_controller.loginOpen || _loginSheetShowing) return;
    _loginSheetShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_presentLoginSheet());
    });
  }

  Future<void> _presentLoginSheet() async {
    if (!mounted || !_controller.loginOpen) {
      _loginSheetShowing = false;
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.46),
      builder: (context) => _TospinoLoginBottomSheet(controller: _controller),
    );
    if (!mounted) return;
    _loginSheetShowing = false;
    _controller.closeLogin();
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

class _TospinoLoginBottomSheet extends StatefulWidget {
  const _TospinoLoginBottomSheet({required this.controller});

  final TospinoAppController controller;

  @override
  State<_TospinoLoginBottomSheet> createState() =>
      _TospinoLoginBottomSheetState();
}

class _TospinoLoginBottomSheetState extends State<_TospinoLoginBottomSheet> {
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant _TospinoLoginBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_handleControllerChange);
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    if (widget.controller.loginOpen || _closing || !mounted) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: FractionallySizedBox(
        heightFactor: keyboardInset > 0 ? 1 : 0.9,
        child: Material(
          color: TospinoColors.resolve(context, TospinoColors.background),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 26,
                    child: Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.lineStrong,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TospinoLoginPage(controller: widget.controller),
                  ),
                ],
              ),
              Positioned(
                top: 6,
                right: 8,
                child: Material(
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.surfaceMuted,
                  ),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    key: const Key('tospino-login-close'),
                    tooltip: localizeMiniProgramLabel(context, '关闭登录'),
                    onPressed: widget.controller.closeLogin,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: TospinoColors.resolve(context, TospinoColors.ink),
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

class TospinoPageRouter {
  const TospinoPageRouter._();

  static Widget build(TospinoRoute route, TospinoAppController controller) {
    return switch (route) {
      TospinoRoute.home => TospinoHomePage(controller: controller),
      TospinoRoute.category => TospinoCategoryPage(controller: controller),
      TospinoRoute.messages => TospinoMessagesPage(controller: controller),
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
    (1, '消息', Icons.notifications_none_rounded, Icons.notifications_rounded),
    (2, '购物车', Icons.shopping_cart_outlined, Icons.shopping_cart_rounded),
    (3, '我的', Icons.person_outline_rounded, Icons.person_rounded),
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
                                    fontSize: 11,
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
