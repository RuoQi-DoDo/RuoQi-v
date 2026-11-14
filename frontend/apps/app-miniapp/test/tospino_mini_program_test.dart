import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/api/tospino_api.dart';
import 'package:ruoqi_app_miniapp/app_shell.dart';
import 'package:ruoqi_app_miniapp/appearance.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_capsule_overlay.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_navigation_bar.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_status_bar.dart';
import 'package:ruoqi_app_miniapp/miniapp/launcher/miniapp_launcher_item.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/pages/home_page.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_miniapp.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_models.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_routes.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_style.dart';
import 'package:ruoqi_app_miniapp/pages/mini_programs/mini_programs_page.dart';

void main() {
  test('Tospino 默认使用生产 API 和 SSO 地址', () {
    expect(TospinoConfig.apiBaseUrl, 'https://gh2capi.tospino.com.gh');
    expect(TospinoConfig.ssoBaseUrl, 'https://oauthapi.tospino.com.gh');
  });

  test('Tospino 装修商品请求使用 Android 的 productIds 字段', () {
    final payload = tospinoProductsByIdsPayload(['product-1', '', 'product-2']);

    expect(payload, {
      'productIds': ['product-1', 'product-2'],
    });
    expect(payload.containsKey('goodsIdList'), isFalse);
  });

  test('Tospino 登录密码使用安卓同款 AES-CBC 零填充', () {
    expect(tospinoEncryptPassword('123456'), '7BmTCgWd212/bXiQZSW3CQ==');
  });

  test('Tospino 字体按 Android 宽度和字形比例修正', () {
    final scaler = tospinoAndroidTextScaler(const TextScaler.linear(0.85), 360);

    expect(scaler.scale(100), closeTo(85.32, 0.02));
  });

  test('Tospino 首页装修 JSON 按 Android 字段解析', () {
    final page = parseTospinoHomePageDecoration({
      'id': 'style-1',
      'name': 'Recommend',
      'templateID': 'template-1',
      'style': {'baseColor': '#FDFCFC'},
      'config': {
        'backgroundImage': {'imageLink': 'https://example.com/background.jpg'},
      },
      'componentList': [
        {
          'type': 4,
          'config': {
            'showTitle': {'display': 1, 'name': 'Quick entries'},
            'imageName': {'display': 1},
          },
          'style': {
            'baseColor': '',
            'lowerGap': '30',
            'leftGap': '36',
            'rightGap': '36',
            'height': '',
            'displayRows': '2',
          },
          'detailList': [
            {
              'link': {
                'imageLink': 'https://example.com/coupon.jpg',
                'imageName': 'Coupon Center',
                'linkType': 2,
                'linkAddress': '',
              },
              'frontCategoryIds': ['category-1'],
              'goodsIds': [],
            },
          ],
        },
        {
          'type': 14,
          'config': {
            'salesLabel': {'display': 0},
            'evaluationLabel': {'display': 1},
          },
          'detailList': [],
        },
      ],
    });

    expect(page.name, 'Recommend');
    expect(page.backgroundImageUrl, endsWith('background.jpg'));
    expect(page.components.first.type, TospinoHomeComponent.diamondArea);
    expect(page.components.first.lowerGap, 30);
    expect(page.components.first.items.single.title, 'Coupon Center');
    expect(page.components.first.showImageName, isTrue);
    expect(
      page.components.first.items.single.categoryIds,
      contains('category-1'),
    );
    expect(page.recommendationComponent, isNotNull);
    expect(page.recommendationComponent!.showSales, isFalse);
    expect(page.recommendationComponent!.showRating, isTrue);
  });

  testWidgets('Tospino 首页不请求装修并展示商城化信息架构', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-home-page')), findsOneWidget);
    expect(find.byKey(const Key('tospino-home-logo')), findsNothing);
    expect(find.byKey(const Key('tospino-home-delivery')), findsOneWidget);
    expect(find.text(api.products.first.title), findsWidgets);
    expect(tester.widget<Text>(find.text('搜索商品、品牌或关键词')).style?.fontSize, 12.5);
    expect(find.byKey(const Key('tospino-home-hero')), findsOneWidget);
    expect(find.byKey(const Key('tospino-home-category-1')), findsOneWidget);
    expect(find.byKey(const Key('tospino-home-deal-rail')), findsOneWidget);
    expect(find.byKey(const Key('tospino-tab-首页')), findsOneWidget);
    expect(find.byKey(const Key('tospino-tab-消息')), findsOneWidget);
    expect(find.byKey(const Key('tospino-tab-购物车')), findsOneWidget);
    expect(find.byKey(const Key('tospino-tab-我的')), findsOneWidget);
    expect(find.byKey(const Key('tospino-tab-分类')), findsNothing);
    expect(find.byType(MiniProgramCapsuleOverlay), findsOneWidget);
    expect(find.byType(MiniProgramNavigationBar), findsNothing);
    expect(api.searchCalls, greaterThan(0));
    expect(api.categoryCalls, 1);
    expect(api.decorationCalls, 0);
    await tester.drag(
      find.byKey(const Key('tospino-home-scroll')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tospino-home-campaign-groupBuy')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('tospino-home-trending-rail')), findsOneWidget);
    expect(find.byKey(const Key('tospino-home-sort-forYou')), findsOneWidget);
    expect(find.byKey(const Key('tospino-home-product-grid')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tospino 首次加载不会闪现兜底首页', (tester) async {
    _usePhoneSize(tester);
    final api = _DelayedInitializeTospinoApi();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: _controller(api))),
    );

    expect(find.byKey(const Key('tospino-home-loading')), findsOneWidget);
    expect(find.text('暂无匹配商品'), findsNothing);
    expect(find.text('优惠券中心'), findsNothing);

    api.initializeCompleter.complete();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-home-loading')), findsNothing);
    expect(find.text(api.products.first.title), findsWidgets);
  });

  testWidgets('Tospino 首页始终使用本地信息架构而非装修组件', (tester) async {
    _usePhoneSize(tester);
    final api = _DecoratedTospinoApi();
    final controller = _controller(api);
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(api.decorationCalls, 0);
    expect(find.text('Recommend'), findsNothing);
    expect(find.text('Beauty'), findsNothing);
    expect(find.text('Coupon Center'), findsNothing);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Bag'), findsOneWidget);
    expect(find.byKey(const Key('tospino-home-hero')), findsOneWidget);
    expect(find.byKey(const Key('tospino-home-deal-rail')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Tospino 首页推荐流按页加载并去重', () async {
    final api = _PagedTospinoApi();
    final controller = _controller(api);
    await controller.initialize();

    expect(controller.homeProducts, hasLength(20));
    expect(controller.homeHasMore, isTrue);

    await controller.loadMoreHome();

    expect(controller.homeProducts, hasLength(23));
    expect(controller.homeHasMore, isTrue);

    await controller.loadMoreHome();

    expect(controller.homeHasMore, isFalse);
    expect(api.pages, [1, 2, 3]);
  });

  testWidgets('小屏幕下首页、分类和我的页面无布局异常', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TospinoHomePage), findsOneWidget);
    expect(tester.takeException(), isNull);

    final categoryEntry = find.byKey(const Key('tospino-home-category-1'));
    await tester.ensureVisible(categoryEntry);
    await tester.tap(categoryEntry);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-category-page')), findsOneWidget);
    expect(api.categoryProductCalls, greaterThan(0));
    expect(tester.takeException(), isNull);

    controller.back();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-tab-我的')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-profile-page')), findsOneWidget);
    expect(find.text('Ama Mensah'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('商品详情、收藏和加购调用真实数据源协议', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(
      api,
      initialProductId: api.products.first.id,
    );
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-product-page')), findsOneWidget);
    expect(find.text(api.products.first.title), findsWidgets);
    expect(api.detailCalls, 1);
    expect(controller.cartCount, 1);

    await tester.tap(find.byKey(const Key('tospino-product-add-cart')));
    await tester.pumpAndSettle();
    expect(api.addCartCalls, 1);
    expect(controller.cartCount, 2);

    await controller.toggleFavorite(api.products.first);
    expect(api.favoriteCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('消息页使用订单数据展示动态并进入订单详情', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    controller.switchTab(1);
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-messages-page')), findsOneWidget);
    expect(find.byKey(const Key('tospino-messages-list')), findsOneWidget);
    expect(
      find.byKey(const Key('tospino-message-order-order-1')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('tospino-message-order-order-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-order-detail-page')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('页面标题和返回属于可滚动内容，胶囊保持固定', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(
      api,
      initialProductId: api.products.first.id,
    );
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('商品详情'), findsOneWidget);
    expect(find.byType(MiniProgramCapsuleOverlay), findsOneWidget);
    final verticalScrollable = find
        .byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        )
        .last;
    await tester.drag(verticalScrollable, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('商品详情').hitTestable(), findsNothing);
    expect(find.byType(MiniProgramCapsuleOverlay), findsOneWidget);
    expect(find.byType(MiniProgramNavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('上滑后状态栏取消品牌底色', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: _controller(api))),
    );
    await tester.pumpAndSettle();

    final before = tester
        .widget<MiniProgramStatusBar>(find.byType(MiniProgramStatusBar))
        .backgroundColor;
    await tester.drag(
      find.byKey(const Key('tospino-home-scroll')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    final after = tester
        .widget<MiniProgramStatusBar>(find.byType(MiniProgramStatusBar))
        .backgroundColor;
    expect(after, isNot(before));

    await tester.tap(find.byKey(const Key('tospino-tab-我的')));
    await tester.pumpAndSettle();
    expect(find.byType(MiniProgramStatusBar), findsNothing);
    await tester.drag(
      find.byKey(const Key('tospino-profile-scroll')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MiniProgramStatusBar), findsNothing);
    expect(find.byType(MiniProgramCapsuleOverlay), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('购物车结算读取地址和 SaleInfo 后提交真实订单协议', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    await controller.startCheckout();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-checkout-page')), findsOneWidget);
    expect(api.saleInfoCalls, 1);
    final before = controller.orders.length;
    await tester.tap(find.byKey(const Key('tospino-place-order')));
    await tester.pumpAndSettle();

    expect(api.submitOrderCalls, 1);
    expect(controller.orders.length, greaterThan(before));
    expect(find.byKey(const Key('tospino-orders-page')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('购物车降价、常买筛选和常买开关调用真实协议', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    controller.switchTab(2);
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tospino-cart-filter-2')));
    await tester.pumpAndSettle();
    expect(controller.cartFilter, TospinoCartFilter.priceCut);
    expect(api.cartQueryTypes, contains(2));
    expect(find.byKey(const Key('tospino-cart-list')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tospino-cart-filter-3')));
    await tester.pumpAndSettle();
    expect(controller.cartFilter, TospinoCartFilter.oftenBuy);
    expect(api.cartQueryTypes, contains(3));

    await tester.tap(find.byKey(const Key('tospino-cart-filter-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-cart-often-sku-1')));
    await tester.pumpAndSettle();
    expect(api.setOftenBuyCalls, 1);
    expect(api.cart.single.isOftenBuy, isTrue);
    expect(controller.cartLines.single.isOftenBuy, isTrue);

    await tester.tap(find.byKey(const Key('tospino-cart-filter-3')));
    await tester.pumpAndSettle();
    expect(controller.cartLines, hasLength(1));
    expect(find.byKey(const Key('tospino-cart-list')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('搜索通过 API 请求并显示结果与空状态', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    controller.openSearch();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('tospino-search-field'));
    await tester.enterText(field, 'phone');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-search-results')), findsOneWidget);
    expect(find.text(api.products.first.title), findsOneWidget);

    await tester.enterText(field, 'not-found');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-search-empty')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('订单页内切换状态筛选会重新请求 API', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    await controller.openOrders();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, '待付款'));
    await tester.pumpAndSettle();
    expect(controller.orderFilter, TospinoOrderStatus.toPay);
    expect(api.lastOrderStatus, TospinoOrderStatus.toPay);
    expect(controller.orders, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('小程序目录包含 Tospino 入口', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(
      BusinessAppFrame(title: 'test', home: (_) => const MiniProgramsPage()),
    );
    await tester.pumpAndSettle();

    final tospinoEntry = find.byKey(const Key('mini-program-entry-tospino'));
    expect(tospinoEntry, findsOneWidget);
    final icon = tester.widget<Image>(
      find.descendant(of: tospinoEntry, matching: find.byType(Image)),
    );
    expect((icon.image as AssetImage).assetName, tospinoMiniProgramIconAsset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tospino 全部路由均可构建', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();

    for (final route in TospinoRoute.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390,
              height: 760,
              child: TospinoPageRouter.build(route, controller),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Tospino 页面 ${route.name} 构建失败',
      );
    }
  });

  testWidgets('Tospino 跟随宿主切换英文', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    await tester.pumpWidget(
      BusinessAppFrame(
        title: 'test',
        home: (_) => TospinoMiniProgram(controller: _controller(api)),
      ),
    );
    await tester.pumpAndSettle();
    final settings = BusinessThemeScope.of(
      tester.element(find.byKey(const Key('tospino-home-page'))),
    );
    settings.setLocale(const Locale('en'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Home'), findsOneWidget);
    expect(find.byTooltip('Categories'), findsNothing);
    expect(find.byTooltip('Messages'), findsOneWidget);
    expect(find.byTooltip('Cart'), findsOneWidget);
    expect(find.byTooltip('Me'), findsOneWidget);
    expect(find.byTooltip('Close mini-program'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tospino 登录从底部弹出并保留关闭入口', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    controller.openLogin();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('登录 Tospino'), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-close')), findsOneWidget);
    expect(
      find.byKey(const Key('tospino-login-password-method')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('tospino-login-account')), findsNothing);

    await tester.tap(find.byKey(const Key('tospino-login-password-method')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-login-account')), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-password')), findsOneWidget);
    expect(find.text('忘记密码'), findsOneWidget);
    expect(find.text('其他登录方式'), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-agreement')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tospino-login-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-login-page')), findsNothing);
    expect(controller.loginOpen, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('购物车和登录注册入口复用登录底部弹层', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await api.logout();
    await controller.initialize();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tospino-tab-购物车')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-login-page')), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-close')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tospino-login-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-home-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tospino-tab-我的')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-profile-login')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-login-page')), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-close')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('消息页登录入口复用登录底部弹层', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await api.logout();
    await controller.initialize();
    controller.switchTab(1);
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-messages-page')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tospino-messages-login')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-login-page')), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-close')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tospino 我的页面六个入口均打开对应页面', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    controller.switchTab(3);
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    const entries = [
      ('tospino-profile-free-gift', 'tospino-free-gift-page'),
      ('tospino-profile-wallet', 'tospino-wallet-page'),
      ('tospino-profile-coupons', 'tospino-coupons-page'),
      ('tospino-profile-address', 'tospino-address-page'),
      ('tospino-profile-shops', 'tospino-shop-follow-page'),
      ('tospino-profile-settings', 'tospino-settings-page'),
    ];
    for (final (entryKey, pageKey) in entries) {
      final entry = find.byKey(Key(entryKey));
      await tester.ensureVisible(entry);
      await tester.tap(entry);
      await tester.pumpAndSettle();
      expect(find.byKey(Key(pageKey)), findsOneWidget, reason: entryKey);
      expect(tester.takeException(), isNull, reason: pageKey);
      controller.back();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Tospino 深色模式沿用主体表面层级', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: TospinoMiniProgram(controller: _controller(api)),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byKey(const Key('tospino-home-page')));
    final theme = Theme.of(context);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, const Color(0xFF0B0C0F));
    expect(
      TospinoColors.resolve(context, TospinoColors.surface),
      const Color(0xFF141518),
    );
    expect(
      TospinoColors.resolve(context, TospinoColors.imagePlaceholder),
      const Color(0xFF1C1E23),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tospino 使用 Inter 与 Android 字重映射', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: _controller(api))),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byKey(const Key('tospino-home-page')));
    expect(TospinoText.body(context).fontFamily, 'Inter');
    expect(TospinoText.body(context).fontWeight, FontWeight.w400);
    expect(TospinoText.body(context).height, 1.2);
    expect(TospinoText.bodyStrong(context).fontWeight, FontWeight.w600);
    expect(TospinoText.pageTitle(context).fontWeight, FontWeight.w700);
  });

  testWidgets('Tospino 全部路由在深色模式下可构建', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();

    for (final route in TospinoRoute.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Scaffold(
            body: SizedBox(
              width: 390,
              height: 760,
              child: TospinoPageRouter.build(route, controller),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Tospino 深色页面 ${route.name} 构建失败',
      );
    }
  });
}

TospinoAppController _controller(
  _FakeTospinoApi api, {
  String? initialProductId,
}) => TospinoAppController(api: api, initialProductId: initialProductId);

void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(414, 896);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

class _FakeTospinoApi implements TospinoDataSource {
  _FakeTospinoApi() {
    cart.add(
      const TospinoCartLine(
        skuId: 'sku-1',
        productId: '1001',
        title: 'Real API Wireless Headphones',
        price: 199,
        quantity: 1,
        storeId: 'store-1',
        storeName: 'Tospino Store',
      ),
    );
  }

  final products = const [
    TospinoProduct(
      id: '1001',
      title: 'Real API Wireless Headphones',
      brand: 'Tospino',
      categoryId: '1',
      categoryName: 'Electronics',
      price: 199,
      oldPrice: 299,
      sales: 25,
      rating: 4.8,
      imageUrl: 'https://example.com/headphones.jpg',
      stock: 10,
    ),
    TospinoProduct(
      id: '1002',
      title: 'Real API Coffee Beans',
      brand: 'Tospino Market',
      categoryId: '2',
      categoryName: 'Food',
      price: 49,
      oldPrice: 69,
      sales: 12,
      rating: 4.7,
      imageUrl: 'https://example.com/coffee.jpg',
      stock: 20,
    ),
  ];
  final categories = const [
    TospinoCategory(
      id: '1',
      label: 'Electronics',
      children: [TospinoCategory(id: '11', label: 'Audio')],
    ),
    TospinoCategory(id: '2', label: 'Food'),
  ];
  final cart = <TospinoCartLine>[];
  final orders = <TospinoOrder>[
    const TospinoOrder(
      id: 'order-1',
      orderSn: 'TSP-001',
      statusCode: '0',
      statusLabel: '待付款',
      total: 199,
      createdAt: '2026-11-13',
      items: [
        TospinoOrderItem(
          skuId: 'sku-1',
          productId: '1001',
          title: 'Real API Wireless Headphones',
          price: 199,
          quantity: 1,
        ),
      ],
    ),
    const TospinoOrder(
      id: 'order-2',
      orderSn: 'TSP-002',
      statusCode: '2',
      statusLabel: '待发货',
      total: 49,
      createdAt: '2026-11-12',
      items: [
        TospinoOrderItem(
          skuId: 'sku-2',
          productId: '1002',
          title: 'Real API Coffee Beans',
          price: 49,
          quantity: 1,
        ),
      ],
    ),
  ];
  int categoryCalls = 0;
  int categoryProductCalls = 0;
  int decorationCalls = 0;
  int searchCalls = 0;
  int detailCalls = 0;
  int favoriteCalls = 0;
  int addCartCalls = 0;
  int setOftenBuyCalls = 0;
  final cartQueryTypes = <int>[];
  int saleInfoCalls = 0;
  int submitOrderCalls = 0;
  TospinoOrderStatus? lastOrderStatus;
  final favorites = <TospinoProduct>[];
  bool _loggedIn = true;
  final _user = const TospinoUser(
    id: 'buyer-1',
    displayName: 'Ama Mensah',
    phone: '+233 55 123 4567',
    favoriteCount: 2,
    couponCount: 6,
  );
  final _address = const TospinoAddress(
    id: 'address-1',
    name: 'Ama Mensah',
    phone: '+233 55 123 4567',
    completeAddress: '12 Independence Avenue, Accra, Ghana',
    isDefault: true,
  );

  @override
  bool get isLoggedIn => _loggedIn;

  @override
  String get userId => _loggedIn ? _user.id : '';

  @override
  TospinoUser? get currentUser => _loggedIn ? _user : null;

  @override
  Future<void> initialize() async {}

  @override
  Future<List<TospinoHomePageDecoration>> fetchHomeDecoration({
    String? templateId,
    String? styleId,
  }) async {
    decorationCalls++;
    return const [];
  }

  @override
  Future<List<String>> fetchHomeRecommendWords() async => const [];

  @override
  Future<List<TospinoFreeGift>> fetchFreeGifts() async => const [];

  @override
  Future<List<TospinoProduct>> fetchProductsByIds(List<String> ids) async =>
      products.where((product) => ids.contains(product.id)).toList();

  @override
  Future<List<TospinoCategory>> fetchCategories() async {
    categoryCalls++;
    return categories;
  }

  @override
  Future<List<TospinoProduct>> searchProducts({
    String keyword = '',
    String? navigationCategoryId,
    int page = 0,
    int pageSize = 20,
  }) async {
    searchCalls++;
    if (navigationCategoryId != null) {
      categoryProductCalls++;
      return products
          .where((product) => product.categoryId == navigationCategoryId)
          .toList();
    }
    if (keyword.isEmpty) return products;
    final query = keyword.toLowerCase();
    return products
        .where((product) => product.title.toLowerCase().contains(query))
        .toList();
  }

  @override
  Future<TospinoProductDetail> fetchProductDetail(String productId) async {
    detailCalls++;
    final product = products.firstWhere((item) => item.id == productId);
    return TospinoProductDetail(
      product: product,
      skuId: 'sku-${product.id}',
      galleryUrls: [product.imageUrl],
      description: 'Live API product description',
      storeName: 'Tospino Store',
    );
  }

  @override
  Future<List<TospinoCartLine>> fetchCart({int queryType = 1}) async {
    cartQueryTypes.add(queryType);
    if (queryType == 2) return List.of(cart);
    if (queryType == 3) {
      return cart.where((line) => line.isOftenBuy).toList();
    }
    return List.of(cart);
  }

  @override
  Future<TospinoCartCounts> fetchCartCounts() async => TospinoCartCounts(
    allTotal: cart.fold(0, (sum, line) => sum + line.quantity),
    priceCutTotal: cart.isEmpty ? 0 : 1,
    oftenBuyTotal: cart.where((line) => line.isOftenBuy).length,
  );

  @override
  Future<void> addToCart(String skuId, {int quantity = 1}) async {
    addCartCalls++;
    final index = cart.indexWhere((line) => line.skuId == skuId);
    if (index >= 0) {
      cart[index] = cart[index].copyWith(
        quantity: cart[index].quantity + quantity,
      );
    } else {
      final product = products.firstWhere((item) => 'sku-${item.id}' == skuId);
      cart.add(
        TospinoCartLine(
          skuId: skuId,
          productId: product.id,
          title: product.title,
          price: product.price,
          quantity: quantity,
          storeId: 'store-1',
          storeName: 'Tospino Store',
        ),
      );
    }
  }

  @override
  Future<void> updateCartQuantity(String skuId, int quantity) async {
    final index = cart.indexWhere((line) => line.skuId == skuId);
    if (index >= 0) cart[index] = cart[index].copyWith(quantity: quantity);
  }

  @override
  Future<void> setOftenBuy(String skuId, {required bool isOftenBuy}) async {
    setOftenBuyCalls++;
    final index = cart.indexWhere((line) => line.skuId == skuId);
    if (index >= 0) {
      cart[index] = cart[index].copyWith(isOftenBuy: isOftenBuy);
    }
  }

  @override
  Future<void> removeFromCart(String skuId) async {
    cart.removeWhere((line) => line.skuId == skuId);
  }

  @override
  Future<List<TospinoOrder>> fetchOrders({TospinoOrderStatus? status}) async {
    lastOrderStatus = status;
    if (status == null) return List.of(orders);
    return orders.where((order) => order.status == status).toList();
  }

  @override
  Future<TospinoOrder> fetchOrderDetail(String orderId) async =>
      orders.firstWhere((order) => order.id == orderId);

  @override
  Future<TospinoUser> fetchCurrentUser() async => _user;

  @override
  Future<List<TospinoProduct>> fetchFavorites() async => List.of(favorites);

  @override
  Future<void> followProduct(String productId) async {
    favoriteCalls++;
    final product = products.firstWhere((item) => item.id == productId);
    if (!favorites.any((item) => item.id == productId)) favorites.add(product);
  }

  @override
  Future<void> unfollowProduct(String productId) async {
    favoriteCalls++;
    favorites.removeWhere((product) => product.id == productId);
  }

  @override
  Future<TospinoAddress?> fetchDefaultAddress() async => _address;

  @override
  Future<TospinoSaleInfo> fetchSaleInfo({
    required List<TospinoCartLine> lines,
    required TospinoAddress address,
    required bool fromCart,
    required int paymentType,
  }) async {
    saleInfoCalls++;
    final total = lines.fold<double>(0, (sum, line) => sum + line.subtotal);
    return TospinoSaleInfo(
      totalProductAmount: total,
      totalFreight: 15,
      totalDiscount: 0,
      payable: total + 15,
      orderToken: 'sale-token',
      isCashDelivery: true,
      raw: const {'storeSaleInfoList': []},
    );
  }

  @override
  Future<List<String>> submitOrder({
    required List<TospinoCartLine> lines,
    required TospinoAddress address,
    required bool fromCart,
    required int paymentType,
    required TospinoSaleInfo saleInfo,
  }) async {
    submitOrderCalls++;
    final id = 'created-${orders.length + 1}';
    orders.insert(
      0,
      TospinoOrder(
        id: id,
        orderSn: id,
        statusCode: '2',
        statusLabel: '待发货',
        total: saleInfo.payable,
        createdAt: 'now',
      ),
    );
    cart.clear();
    return [id];
  }

  @override
  Future<TospinoUser> login({
    required String account,
    required String password,
    String phonePrefix = '+233',
  }) async {
    _loggedIn = true;
    return _user;
  }

  @override
  Future<void> logout() async {
    _loggedIn = false;
  }
}

class _DelayedInitializeTospinoApi extends _FakeTospinoApi {
  final initializeCompleter = Completer<void>();

  @override
  Future<void> initialize() => initializeCompleter.future;
}

class _PagedTospinoApi extends _FakeTospinoApi {
  final pages = <int>[];

  @override
  Future<List<TospinoProduct>> searchProducts({
    String keyword = '',
    String? navigationCategoryId,
    int page = 0,
    int pageSize = 20,
  }) {
    if (keyword.isNotEmpty || navigationCategoryId != null) {
      return super.searchProducts(
        keyword: keyword,
        navigationCategoryId: navigationCategoryId,
        page: page,
        pageSize: pageSize,
      );
    }
    pages.add(page);
    if (page == 1) {
      return Future.value([
        for (var index = 1; index <= 20; index++)
          TospinoProduct(
            id: 'page-one-$index',
            title: 'Page one product $index',
            price: index.toDouble(),
          ),
      ]);
    }
    if (page == 2) {
      return Future.value([
        for (var index = 21; index <= 23; index++)
          TospinoProduct(
            id: 'page-two-$index',
            title: 'Page two product $index',
            price: index.toDouble(),
          ),
      ]);
    }
    return Future.value(const []);
  }
}

class _DecoratedTospinoApi extends _FakeTospinoApi {
  int lazyDecorationCalls = 0;

  @override
  Future<List<TospinoHomePageDecoration>> fetchHomeDecoration({
    String? templateId,
    String? styleId,
  }) async {
    decorationCalls++;
    if (styleId != null) {
      lazyDecorationCalls++;
      return const [
        TospinoHomePageDecoration(
          id: 'style-2',
          name: 'Beauty',
          templateId: 'template-1',
          components: [
            TospinoHomeComponent(
              type: TospinoHomeComponent.threeImages,
              items: [
                TospinoHomeComponentItem(
                  imageUrl: 'https://example.com/beauty.jpg',
                ),
              ],
            ),
          ],
        ),
      ];
    }
    return const [
      TospinoHomePageDecoration(
        id: 'style-1',
        name: 'Recommend',
        templateId: 'template-1',
        components: [
          TospinoHomeComponent(
            type: TospinoHomeComponent.diamondArea,
            showImageName: true,
            items: [
              TospinoHomeComponentItem(
                imageUrl: 'https://example.com/coupon.jpg',
                title: 'Coupon Center',
              ),
            ],
          ),
          TospinoHomeComponent(
            type: TospinoHomeComponent.banner,
            items: [
              TospinoHomeComponentItem(
                imageUrl: 'https://example.com/banner.jpg',
              ),
            ],
          ),
          TospinoHomeComponent(
            type: TospinoHomeComponent.waterfall,
            title: 'For You',
            showTitle: true,
          ),
        ],
      ),
      TospinoHomePageDecoration(
        id: 'style-2',
        name: 'Beauty',
        templateId: 'template-1',
      ),
    ];
  }

  @override
  Future<List<String>> fetchHomeRecommendWords() async => const [
    'Phone',
    'Bag',
  ];

  @override
  Future<List<TospinoProduct>> fetchProductsByIds(List<String> ids) async =>
      products.where((product) => ids.contains(product.id)).toList();
}
