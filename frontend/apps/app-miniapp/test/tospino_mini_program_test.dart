import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/api/tospino_api.dart';
import 'package:ruoqi_app_miniapp/app_shell.dart';
import 'package:ruoqi_app_miniapp/appearance.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_capsule_overlay.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_navigation_bar.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_status_bar.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/pages/home_page.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_miniapp.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_models.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_routes.dart';
import 'package:ruoqi_app_miniapp/pages/mini_programs/mini_programs_page.dart';

void main() {
  test('Tospino 登录密码使用安卓同款 AES-CBC 零填充', () {
    expect(tospinoEncryptPassword('123456'), '7BmTCgWd212/bXiQZSW3CQ==');
  });

  testWidgets('Tospino 首页数据来自数据源并展示四个主入口', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-home-page')), findsOneWidget);
    expect(find.text('Tospino'), findsWidgets);
    expect(find.text(api.products.first.title), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('分类'), findsOneWidget);
    expect(find.text('购物车'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
    expect(find.byType(MiniProgramCapsuleOverlay), findsOneWidget);
    expect(find.byType(MiniProgramNavigationBar), findsNothing);
    expect(api.searchCalls, greaterThan(0));
    expect(api.categoryCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('小屏幕下首页、分类和我的页面无布局异常', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _FakeTospinoApi();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: _controller(api))),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TospinoHomePage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('tospino-tab-分类')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-category-page')), findsOneWidget);
    expect(api.categoryProductCalls, greaterThan(0));
    expect(tester.takeException(), isNull);

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

    expect(find.byKey(const Key('mini-program-entry-tospino')), findsOneWidget);
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

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
    expect(find.byTooltip('Close mini-program'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
  int searchCalls = 0;
  int detailCalls = 0;
  int favoriteCalls = 0;
  int addCartCalls = 0;
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
  Future<List<TospinoCartLine>> fetchCart() async => List.of(cart);

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
