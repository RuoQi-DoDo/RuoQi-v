import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/api/tospino_api.dart';
import 'package:ruoqi_app_miniapp/app_shell.dart';
import 'package:ruoqi_app_miniapp/appearance.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_capsule_overlay.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_navigation_bar.dart';
import 'package:ruoqi_app_miniapp/miniapp/common/widgets/miniapp_status_bar.dart';
import 'package:ruoqi_app_miniapp/miniapp/launcher/miniapp_launcher_item.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/pages/home_page.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/pages/address_qr_scanner_page.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_miniapp.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_models.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_routes.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_sharing.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/tospino_style.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/widgets/product_html_view.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/widgets/product_gallery.dart';
import 'package:ruoqi_app_miniapp/miniapp/tospino/widgets/tospino_fulfillment_card.dart';
import 'package:ruoqi_app_miniapp/pages/mini_programs/mini_programs_page.dart';

import 'finders.dart';

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

  test('Tospino 详情图按 Android detailsPics 字段解析并过滤视频', () {
    final images = parseTospinoDetailImageUrls([
      {'fileType': '1', 'imgUrl': '//img.example.com/detail-1.jpg'},
      {'fileType': '1', 'imgUrl': 'https://img.example.com/detail-2.jpg'},
      {'fileType': '2', 'imgUrl': 'https://video.example.com/detail.mp4'},
    ]);
    expect(images, [
      'https://img.example.com/detail-1.jpg',
      'https://img.example.com/detail-2.jpg',
    ]);
  });

  test('Tospino 地址二维码按 Android 协议解析门牌和经纬度', () {
    final address = parseTospinoAddressQrCode(
      'address:12 Independence Avenue, Accra,'
      'map:https://maps.google.com/?query=5.6037,-0.1870',
    );
    expect(address, isNotNull);
    expect(address!.detailAddress, '12 Independence Avenue, Accra');
    expect(address.latitude, 5.6037);
    expect(address.longitude, -0.187);
    expect(parseTospinoAddressQrCode('https://example.com'), isNull);
  });

  test('Tospino 扫码定位结果按嵌套地区返回路径', () {
    final path = parseTospinoCoordinateRegionPath([
      {
        'id': 'gh',
        'name': 'Ghana',
        'code': 'GH',
        'level': '0',
        'aresChilds': [
          {
            'id': 'ga',
            'name': 'Greater Accra',
            'code': 'GA',
            'level': '1',
            'aresChilds': [
              {'id': 'acc', 'name': 'Accra', 'code': 'ACC', 'level': '2'},
            ],
          },
        ],
      },
    ]);
    expect(path.map((region) => region.name), [
      'Ghana',
      'Greater Accra',
      'Accra',
    ]);
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
    expect(find.byKey(const Key('tospino-home-category-1')), findsOneWidget);
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
    await tester.scrollUntilVisible(
      find.byKey(const Key('tospino-home-sort-forYou')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('tospino-home-scroll')),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            ),
          )
          .first,
    );
    await tester.pumpAndSettle();
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

  testWidgets('首页 0 元购单商品使用全宽独立样式', (tester) async {
    _usePhoneSize(tester);
    tester.view.physicalSize = const Size(360, 800);
    final api = _SingleFreeGiftTospinoApi();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: _controller(api))),
    );
    await tester.pumpAndSettle();

    final verticalScrollable = find
        .byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        )
        .first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('tospino-home-campaign-zeroYuan')),
      360,
      scrollable: verticalScrollable,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('tospino-home-zero-yuan-single')),
      findsOneWidget,
    );
    expect(find.text('0元购'), findsWidgets);
    expect(find.text('Single zero-yuan product'), findsOneWidget);
    expect(tester.takeException(), isNull);
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

  testWidgets('商品详情价格使用克制的深色层级', (tester) async {
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

    final context = tester.element(
      find.byKey(const Key('tospino-product-page')),
    );
    final price = tester.widget<TospinoPriceText>(
      find.byKey(const Key('tospino-product-price')),
    );
    expect(price.color, TospinoColors.resolve(context, TospinoColors.ink));
    expect(find.textContaining('OFF'), findsOneWidget);
    final discount = tester.widget<Container>(
      find.byKey(const Key('tospino-product-discount')),
    );
    expect((discount.decoration! as BoxDecoration).gradient, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('商品详情长服务承诺自动换行且不横向溢出', (tester) async {
    _usePhoneSize(tester);
    tester.view.physicalSize = const Size(360, 800);
    final api = _FakeTospinoApi();
    final controller = _controller(
      api,
      initialProductId: api.products.first.id,
    );
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '商品详情首屏横向溢出');

    final verticalScrollable = find
        .byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        )
        .last;
    for (var index = 0; index < 4; index++) {
      await tester.drag(verticalScrollable, const Offset(0, -420));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: '商品详情第 ${index + 1} 次滚动后横向溢出',
      );
    }
    expect(
      find.textContaining('FBT products: 7 days without reason'),
      findsOneWidget,
    );
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

  testWidgets('商品描述支持常用 HTML 标签', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TospinoProductHtmlView(
              description:
                  '<h2>Product details</h2>'
                  '<p>Premium <strong>wireless</strong> headphones.</p>'
                  '<ul><li>30-hour battery</li><li>Fast charging</li></ul>'
                  '<img src="https://example.com/detail.jpg"/>',
              fallback: 'Fallback',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-product-html')), findsOneWidget);
    expect(find.textContaining('Product details'), findsOneWidget);
    expect(find.textContaining('Premium wireless headphones.'), findsOneWidget);
    expect(find.textContaining('30-hour battery'), findsOneWidget);
    expect(find.textContaining('<p>'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('商品 HTML 会压缩空白断行并应用常用 CSS', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TospinoProductHtmlView(
              description:
                  '<style>'
                  '.description{text-align:center;font-size:15px;color:#123456}'
                  '.description .price{font-weight:700;color:#ff0000}'
                  '</style>'
                  '<div class="description">'
                  '<p>PRODUCT&nbsp;DESCRIPTION</p>'
                  '<p>&nbsp;</p><p><br><br></p>'
                  '<p>Key <strong>attributes</strong></p>'
                  '<p>Product Type<br><br><span class="price">BRAS</span></p>'
                  '</div>',
              fallback: 'Fallback',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('PRODUCT DESCRIPTION'), findsOneWidget);
    expect(find.textContaining('Key attributes'), findsOneWidget);
    expect(find.textContaining('Product Type'), findsOneWidget);
    expect(find.textContaining('BRAS'), findsOneWidget);
    expect(find.textContaining('\u00A0'), findsNothing);

    final title = tester.widget<Text>(
      find.textContaining('PRODUCT DESCRIPTION').first,
    );
    expect(title.textAlign, TextAlign.center);

    final blankTexts = find
        .descendant(
          of: find.byKey(const Key('tospino-product-html')),
          matching: find.byType(Text),
        )
        .evaluate()
        .where((element) {
          final widget = element.widget as Text;
          final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
          return text.trim().isEmpty;
        });
    expect(blankTexts, isEmpty);
  });

  testWidgets('商品详情展示接口返回的详情长图', (tester) async {
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

    final verticalScrollable = find
        .byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        )
        .last;
    final detailImages = find.byKey(const Key('tospino-product-detail-images'));
    await tester.scrollUntilVisible(
      detailImages,
      500,
      scrollable: verticalScrollable,
    );
    expect(detailImages, findsOneWidget);
    expect(
      find.descendant(of: detailImages, matching: find.byType(Image)),
      findsNWidgets(2),
    );
    expect(
      find.byKey(const Key('tospino-product-detail-image-0')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('商品详情主图支持左右滑动并显示页码', (tester) async {
    const product = TospinoProduct(
      id: 'gallery-product',
      title: 'Gallery product',
      price: 10,
      imageUrl: 'https://example.com/gallery-1.jpg',
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 400,
            child: TospinoProductGallery(
              product: product,
              imageUrls: [
                'https://example.com/gallery-1.jpg',
                'https://example.com/gallery-2.jpg',
                'https://example.com/gallery-3.jpg',
              ],
              height: 390,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 3'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('tospino-product-gallery-pages')),
      const Offset(-360, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('商品主图支持按图片比例动态调整高度', (tester) async {
    _usePhoneSize(tester);
    const product = TospinoProduct(
      id: 'dynamic-gallery',
      title: 'Dynamic gallery',
      price: 10,
      imageUrl: 'https://example.com/gallery-1.jpg',
    );

    Widget gallery(double ratio) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 390,
            child: TospinoProductGallery(
              product: product,
              imageUrls: const [
                'https://example.com/gallery-1.jpg',
                'https://example.com/gallery-2.jpg',
              ],
              height: 390,
              imageAspectRatio: ratio,
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(gallery(4 / 3));
    await tester.pumpAndSettle();
    expect(
      tester
          .getSize(find.byKey(const Key('tospino-product-gallery-frame')))
          .height,
      closeTo(520, 0.5),
    );

    await tester.pumpWidget(gallery(0.79));
    await tester.pumpAndSettle();
    expect(
      tester
          .getSize(find.byKey(const Key('tospino-product-gallery-frame')))
          .height,
      closeTo(390 * 0.79, 0.5),
    );
    expect(tester.takeException(), isNull);
  });

  test('Tospino 物流运输方式与 Android 映射一致', () {
    expect(tospinoTransportModeFromCode('1'), TospinoTransportMode.air);
    expect(tospinoTransportModeFromCode('2'), TospinoTransportMode.sea);
    expect(tospinoTransportModeFromCode('3'), TospinoTransportMode.land);
    expect(tospinoTransportModeFromCode(''), isNull);
  });

  test('Tospino 订单状态码与 Android 一致并限制取消范围', () {
    expect(TospinoOrderStatus.fromCode('0'), TospinoOrderStatus.toPay);
    expect(TospinoOrderStatus.fromCode('1'), TospinoOrderStatus.toShip);
    expect(TospinoOrderStatus.fromCode('2'), TospinoOrderStatus.toReceive);
    expect(TospinoOrderStatus.fromCode('3'), TospinoOrderStatus.toReview);
    const unpaid = TospinoOrder(
      id: 'unpaid',
      orderSn: 'unpaid',
      statusCode: '0',
      statusLabel: '待付款',
      total: 10,
      createdAt: '',
    );
    const cashToShip = TospinoOrder(
      id: 'cash',
      orderSn: 'cash',
      statusCode: '1',
      statusLabel: '待发货',
      total: 10,
      createdAt: '',
      paymentType: 2,
    );
    const onlineToShip = TospinoOrder(
      id: 'online',
      orderSn: 'online',
      statusCode: '1',
      statusLabel: '待发货',
      total: 10,
      createdAt: '',
      paymentType: 1,
      payState: 1,
    );
    expect(unpaid.canCancel, isTrue);
    expect(cashToShip.canCancel, isTrue);
    expect(onlineToShip.canCancel, isFalse);
  });

  testWidgets('Tospino 商品详情区分 FBT、FBM 本土和 FBM 跨境', (tester) async {
    Future<void> pumpDetail({
      required int deliveryType,
      String sourceCountryCode = 'GH',
      String sourceCountryName = 'Ghana',
      String sourceAddress = '12 Independence Avenue, Accra, Ghana',
      String destinationCountryCode = 'GH',
      String destinationCountryName = 'Ghana',
      String destinationCity = 'Accra',
    }) async {
      final detail = TospinoProductDetail(
        product: TospinoProduct(
          id: 'delivery-product',
          title: 'Delivery product',
          price: 10,
          deliveryType: deliveryType,
          transportModes: const ['1'],
        ),
        skuId: 'delivery-sku',
        storeDeliveryCountryCode: sourceCountryCode,
        storeDeliveryCountryName: sourceCountryName,
        storeDeliveryAddress: sourceAddress,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TospinoFulfillmentCard(
                detail: detail,
                destination: TospinoAddress(
                  id: 'destination',
                  name: 'Ama',
                  phone: '+233000000000',
                  completeAddress: 'Accra, Ghana',
                  countryCode: destinationCountryCode,
                  countryName: destinationCountryName,
                  city: destinationCity,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpDetail(deliveryType: 2);
    expect(find.byKey(const Key('tospino-fulfillment-fbt')), findsOneWidget);
    expect(find.text('FBT'), findsOneWidget);
    expect(find.text('Tospino 官方履约'), findsOneWidget);
    expect(find.byKey(const Key('tospino-fulfillment-transit')), findsNothing);

    await pumpDetail(deliveryType: 1);
    expect(
      find.byKey(const Key('tospino-fulfillment-fbmLocalCity')),
      findsOneWidget,
    );
    expect(find.text('FBM 本土'), findsOneWidget);
    expect(find.text('Accra'), findsOneWidget);
    expect(
      find.byKey(const Key('tospino-fulfillment-transport-air')),
      findsOneWidget,
    );

    await pumpDetail(
      deliveryType: 1,
      sourceCountryCode: 'CN',
      sourceCountryName: 'China',
      sourceAddress: 'Shenzhen, China',
    );
    expect(
      find.byKey(const Key('tospino-fulfillment-fbmCrossBorder')),
      findsOneWidget,
    );
    expect(find.text('FBM 跨境'), findsOneWidget);
    expect(find.text('China'), findsOneWidget);
    expect(find.text('本地中转仓'), findsOneWidget);
    expect(
      find.byKey(const Key('tospino-fulfillment-transit')),
      findsOneWidget,
    );

    await pumpDetail(deliveryType: 0);
    expect(
      find.byKey(const Key('tospino-fulfillment-official')),
      findsOneWidget,
    );
    expect(find.text('物流信息待确认'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('商品主图延伸到状态栏，返回和胶囊保持固定', (tester) async {
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

    expect(find.text('商品详情'), findsNothing);
    expect(find.byKey(const Key('tospino-product-back')), findsOneWidget);
    expect(find.byType(MiniProgramCapsuleOverlay), findsOneWidget);
    expect(find.byKey(const Key('miniapp-extended-page-header')), findsNothing);
    expect(find.byType(MiniProgramStatusBar), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const Key('tospino-product-gallery'))).dy,
      0,
    );
    final overlay = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find
          .ancestor(
            of: find.byKey(const Key('tospino-product-page')),
            matching: find.byWidgetPredicate(
              (widget) => widget is AnnotatedRegion<SystemUiOverlayStyle>,
            ),
          )
          .first,
    );
    expect(overlay.value.statusBarColor, Colors.transparent);
    expect(overlay.value.statusBarIconBrightness, Brightness.light);
    final verticalScrollable = find
        .byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        )
        .last;
    await tester.drag(verticalScrollable, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tospino-product-back')).hitTestable(),
      findsOneWidget,
    );
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

  testWidgets('购物车标题与状态栏使用连续浅灰背景', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    controller.switchTab(2);
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byKey(const Key('tospino-cart-page')));
    final expected = TospinoColors.resolve(context, TospinoColors.background);
    final header = tester.widget<ColoredBox>(
      find.byKey(const Key('tospino-cart-title-header')),
    );
    final statusBar = tester.widget<MiniProgramStatusBar>(
      find.byType(MiniProgramStatusBar),
    );
    expect(header.color, expected);
    expect(statusBar.backgroundColor, expected);
    expect(tester.takeException(), isNull);
  });

  testWidgets('购物车结算栏使用克制的深色总价和按钮', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    controller.switchTab(2);
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byKey(const Key('tospino-cart-page')));
    final total = tester.widget<TospinoPriceText>(
      find.byKey(const Key('tospino-cart-total')),
    );
    expect(total.color, TospinoColors.resolve(context, TospinoColors.ink));

    final checkout = find.byKey(const Key('tospino-cart-checkout'));
    expect(tester.getSize(checkout).height, 48);
    final materialColors = find
        .ancestor(of: checkout, matching: find.byType(Material))
        .evaluate()
        .map((element) => (element.widget as Material).color)
        .toList();
    expect(materialColors, contains(const Color(0xFF1D2225)));
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

  testWidgets('待付款订单展示取消入口并按原因提交取消', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    await controller.openOrders();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    final cancel = find.byKey(const Key('tospino-order-cancel-order-1'));
    expect(cancel, findsOneWidget);
    expect(find.byKey(const Key('tospino-order-cancel-order-2')), findsNothing);

    await tester.tap(cancel);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-cancel-reason-list')), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('tospino-cancel-reason-changed-mind')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('tospino-cancel-order-confirm')));
    await tester.pumpAndSettle();

    expect(api.cancelOrderCalls, 1);
    expect(api.lastCancelReason, '不想要了');
    expect(controller.orders.first.statusCode, '5');
    expect(find.text('已取消'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('订单详情保留取消入口并同步取消状态', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    await controller.openOrders();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('订单详情').first);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tospino-order-detail-cancel')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('tospino-order-detail-cancel')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-cancel-reason-other')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tospino-cancel-order-confirm')));
    await tester.pumpAndSettle();

    expect(api.cancelOrderCalls, 1);
    expect(controller.selectedOrder?.statusCode, '5');
    expect(find.byKey(const Key('tospino-order-detail-cancel')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('收货地址支持切换默认、编辑和删除', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    api.addressList.add(
      api.addressList.first.copyWith(
        id: 'address-2',
        name: 'Kojo Mensah',
        isDefault: false,
      ),
    );
    final controller = _controller(api);
    await controller.initialize();
    await controller.openAddress();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-address-list')), findsOneWidget);
    expect(controller.addresses, hasLength(2));
    await tester.tap(
      find.byKey(const Key('tospino-address-default-address-2')),
    );
    await tester.pumpAndSettle();
    expect(api.setDefaultAddressCalls, 1);
    expect(
      controller.addresses.firstWhere((address) => address.id == 'address-2'),
      isA<TospinoAddress>().having(
        (address) => address.isDefault,
        'default',
        true,
      ),
    );

    await tester.tap(find.byKey(const Key('tospino-address-edit-address-1')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tospino-address-editor-page')),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byKey(const Key('tospino-address-scan-tip')), findsNothing);
    await tester.enterText(
      find.byKey(const Key('tospino-address-detail-field')),
      '24 Oxford Street',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-address-save')));
    await tester.pumpAndSettle();
    expect(api.saveAddressCalls, 1);

    await tester.tap(find.byKey(const Key('tospino-address-edit-address-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-address-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-address-delete-confirm')));
    await tester.pumpAndSettle();
    expect(api.deleteAddressCalls, 1);
    expect(controller.addresses, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('新增收货地址通过地区级联生成完整地区编码', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    await controller.openAddress();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tospino-address-add')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-address-scan-tip')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tospino-address-scan-tip-close')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('tospino-address-name-field')),
      'Kojo Mensah',
    );
    await tester.enterText(
      find.byKey(const Key('tospino-address-phone-field')),
      '+233 20 123 4567',
    );
    await tester.enterText(
      find.byKey(const Key('tospino-address-detail-field')),
      '8 Garden Road',
    );
    await tester.tap(find.byKey(const Key('tospino-address-region-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-region-country-gh')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-region-province-ga')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-region-city-acc')));
    await tester.pumpAndSettle();
    expect(find.text('Ghana / Greater Accra / Accra'), findsOneWidget);
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-address-save')));
    await tester.pumpAndSettle();

    expect(api.saveAddressCalls, 1);
    expect(controller.addresses, hasLength(2));
    expect(controller.addresses.last.countryCode, 'GH');
    expect(controller.addresses.last.provinceCode, 'GA');
    expect(controller.addresses.last.cityCode, 'ACC');
    expect(tester.takeException(), isNull);
  });

  testWidgets('地址编辑页支持区号选择和自定义标签', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await controller.initialize();
    await controller.openAddress();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tospino-address-add')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tospino-address-editor-page')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('tospino-address-scan-tip')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tospino-address-scan-tip-close')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.byKey(const Key('tospino-address-phone-prefix')));
    await tester.pumpAndSettle();
    expect(api.phonePrefixCalls, 1);
    expect(find.byKey(const Key('tospino-phone-prefix-list')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tospino-phone-prefix-+234')));
    await tester.pumpAndSettle();
    expect(find.text('+234'), findsOneWidget);

    final customTag = find.byKey(const Key('tospino-address-tag-custom'));
    await tester.ensureVisible(customTag);
    await tester.tap(customTag);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('tospino-address-custom-tag-field')),
      'Warehouse',
    );
    await tester.tap(find.byKey(const Key('tospino-address-custom-tag-save')));
    await tester.pumpAndSettle();
    expect(find.text('Warehouse'), findsOneWidget);
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

    expect(findMaterialTooltip('Home'), findsOneWidget);
    expect(findMaterialTooltip('Categories'), findsNothing);
    expect(findMaterialTooltip('Messages'), findsOneWidget);
    expect(findMaterialTooltip('Cart'), findsOneWidget);
    expect(findMaterialTooltip('Me'), findsOneWidget);
    expect(findMaterialTooltip('Close mini-program'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tospino-tab-我的')));
    await tester.pumpAndSettle();
    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('My wallet'), findsOneWidget);
    expect(find.text('Recently viewed'), findsOneWidget);
    expect(find.text('Invite friends'), findsOneWidget);
    expect(find.text('Contact support'), findsOneWidget);
    expect(find.text('最近浏览'), findsNothing);
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

    expect(find.byKey(const Key('tospino-auth-method-picker')), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-close')), findsOneWidget);
    expect(
      find.byKey(const Key('tospino-login-password-method')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('tospino-login-account')), findsNothing);

    await tester.tap(find.byKey(const Key('tospino-login-password-method')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-login-page')), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-close')), findsNothing);
    expect(find.byKey(const Key('tospino-login-account')), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-password')), findsOneWidget);
    expect(find.text('忘记密码'), findsOneWidget);
    expect(find.text('其他登录方式'), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-agreement')), findsOneWidget);
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
    expect(find.byKey(const Key('tospino-cart-login-state')), findsOneWidget);
    expect(find.byKey(const Key('tospino-auth-method-picker')), findsNothing);
    await tester.tap(find.byKey(const Key('tospino-cart-login')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-auth-method-picker')), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-close')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tospino-login-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-cart-page')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tospino-tab-我的')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-profile-login')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-auth-method-picker')), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-close')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('从 Tospino 各页面点击登录弹层遮罩都不会退出', (tester) async {
    _usePhoneSize(tester);
    final pages = [
      (
        label: '首页',
        pageKey: 'tospino-home-page',
        route: TospinoRoute.home,
        tab: 0,
        product: false,
      ),
      (
        label: '消息',
        pageKey: 'tospino-messages-page',
        route: TospinoRoute.messages,
        tab: 1,
        product: false,
      ),
      (
        label: '购物车',
        pageKey: 'tospino-cart-page',
        route: TospinoRoute.cart,
        tab: 2,
        product: false,
      ),
      (
        label: '我的',
        pageKey: 'tospino-profile-page',
        route: TospinoRoute.profile,
        tab: 3,
        product: false,
      ),
      (
        label: '商品详情',
        pageKey: 'tospino-product-page',
        route: TospinoRoute.product,
        tab: null,
        product: true,
      ),
    ];

    for (final page in pages) {
      final api = _FakeTospinoApi();
      final controller = _controller(api);
      await api.logout();
      await controller.initialize();
      if (page.product) {
        await controller.openProduct(api.products.first);
      } else {
        controller.switchTab(page.tab!);
      }
      controller.openLogin(returnTo: page.route);
      await tester.pumpWidget(
        MaterialApp(
          home: TospinoMiniProgram(
            key: ValueKey('tospino-case-${page.pageKey}'),
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(Key(page.pageKey)),
        findsOneWidget,
        reason: '${page.label}未正常显示',
      );
      expect(
        find.byKey(const Key('tospino-auth-method-picker')),
        findsOneWidget,
      );

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tospino-auth-method-picker')),
        findsNothing,
        reason: '点击${page.label}登录遮罩后应只关闭登录弹层',
      );
      expect(
        find.byKey(Key(page.pageKey)),
        findsOneWidget,
        reason: '点击${page.label}登录遮罩后页面不应退出',
      );
      expect(controller.loginOpen, isFalse);

      controller.openLogin(returnTo: page.route);
      await tester.pumpAndSettle();

      await tester.fling(
        find.byKey(const Key('tospino-login-drag-handle')),
        const Offset(0, 500),
        1200,
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('tospino-auth-method-picker')),
        findsNothing,
        reason: '从${page.label}下滑登录弹层后应只关闭登录弹层',
      );
      expect(
        find.byKey(Key(page.pageKey)),
        findsOneWidget,
        reason: '从${page.label}下滑登录弹层不应退出页面',
      );
      expect(controller.loginOpen, isFalse);
      expect(tester.takeException(), isNull);
    }
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

    expect(find.byKey(const Key('tospino-auth-method-picker')), findsOneWidget);
    expect(find.byKey(const Key('tospino-login-close')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('手机号注册按验证码和设置密码完整流程执行', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final controller = _controller(api);
    await api.logout();
    await controller.initialize();
    controller.openLogin();
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tospino-auth-mode-switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tospino-register-phone-method')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tospino-registration-page')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('tospino-register-account')),
      '0241234567',
    );
    await tester.tap(find.byKey(const Key('tospino-register-agreement')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tospino-register-send-code')));
    await tester.pumpAndSettle();
    expect(api.registrationCodeCalls, 1);

    await tester.enterText(
      find.byKey(const Key('tospino-register-code')),
      '123456',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('tospino-register-verify-code')));
    await tester.pumpAndSettle();
    expect(api.registrationVerifyCalls, 1);

    await tester.enterText(
      find.byKey(const Key('tospino-register-password')),
      'abc12345',
    );
    await tester.enterText(
      find.byKey(const Key('tospino-register-password-repeat')),
      'abc12345',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('tospino-register-submit')));
    await tester.pumpAndSettle();

    expect(api.registerCalls, 1);
    expect(api.lastRegistrationPassword, 'abc12345');
    expect(controller.isLoggedIn, isTrue);
    expect(find.byKey(const Key('tospino-login-page')), findsNothing);
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

  testWidgets('邀请好友页展示邀请码、奖励和邀请记录并支持分享', (tester) async {
    _usePhoneSize(tester);
    final api = _FakeTospinoApi();
    final share = _FakeTospinoShareGateway();
    final controller = TospinoAppController(api: api, shareGateway: share);
    await controller.initialize();
    controller.switchTab(3);
    await tester.pumpWidget(
      MaterialApp(home: TospinoMiniProgram(controller: controller)),
    );
    await tester.pumpAndSettle();

    final inviteEntry = find.byKey(const Key('tospino-profile-invite'));
    await tester.ensureVisible(inviteEntry);
    await tester.tap(inviteEntry);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tospino-invite-page')), findsOneWidget);
    expect(find.text('INV-233'), findsOneWidget);
    expect(find.text('累计邀请 2'), findsOneWidget);
    expect(find.text('Kojo Mensah'), findsOneWidget);
    expect(api.inviteInfoCalls, 1);
    expect(api.inviteFriendCalls, 1);

    await tester.tap(find.byKey(const Key('tospino-invite-share')));
    await tester.pumpAndSettle();
    expect(share.calls, 1);
    expect(share.lastText, contains('INV-233'));
    expect(find.byKey(const Key('tospino-invite-share-system')), findsNothing);

    await tester.tap(find.byKey(const Key('tospino-invite-rewards')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('tospino-invite-rewards-page')),
      findsOneWidget,
    );
    expect(find.text('GH₵25.50'), findsOneWidget);
    expect(api.inviteRewardCalls, 1);
    expect(tester.takeException(), isNull);
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

class _FakeTospinoShareGateway implements TospinoShareGateway {
  int calls = 0;
  String? lastText;

  @override
  Future<void> shareText(
    String text, {
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    calls++;
    lastText = text;
  }
}

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
  int registrationCodeCalls = 0;
  int registrationVerifyCalls = 0;
  int registerCalls = 0;
  String? lastRegistrationAccount;
  String? lastRegistrationCode;
  String? lastRegistrationPassword;
  int searchCalls = 0;
  int detailCalls = 0;
  int favoriteCalls = 0;
  int addCartCalls = 0;
  int setOftenBuyCalls = 0;
  final cartQueryTypes = <int>[];
  int saleInfoCalls = 0;
  int submitOrderCalls = 0;
  int cancelOrderCalls = 0;
  int saveAddressCalls = 0;
  int deleteAddressCalls = 0;
  int setDefaultAddressCalls = 0;
  int phonePrefixCalls = 0;
  int coordinateRegionCalls = 0;
  int inviteInfoCalls = 0;
  int inviteFriendCalls = 0;
  int inviteRewardCalls = 0;
  String? lastCancelReason;
  TospinoOrderStatus? lastOrderStatus;
  final favorites = <TospinoProduct>[];
  final inviteFriends = <TospinoInviteFriend>[
    const TospinoInviteFriend(
      userId: 'friend-1',
      account: '+233 20 111 2233',
      nickname: 'Kojo Mensah',
      registrationTime: '2026-11-15',
    ),
    const TospinoInviteFriend(
      userId: 'friend-2',
      account: '+233 24 555 8899',
      nickname: 'Adwoa Boateng',
      registrationTime: '2026-11-16',
    ),
  ];
  final inviteRewards = <TospinoInviteRewardRecord>[
    const TospinoInviteRewardRecord(
      id: 'reward-1',
      account: 'Kojo Mensah',
      amount: 15,
      registerTime: '2026-11-15',
    ),
    const TospinoInviteRewardRecord(
      id: 'reward-2',
      account: 'Adwoa Boateng',
      amount: 10.5,
      registerTime: '2026-11-16',
    ),
  ];
  bool _loggedIn = true;
  final _user = const TospinoUser(
    id: 'buyer-1',
    displayName: 'Ama Mensah',
    phone: '+233 55 123 4567',
    favoriteCount: 2,
    couponCount: 6,
  );
  final addressList = <TospinoAddress>[
    const TospinoAddress(
      id: 'address-1',
      name: 'Ama Mensah',
      phone: '551234567',
      phonePrefix: '+233',
      completeAddress: 'Ghana, Greater Accra, Accra, 12 Independence Avenue',
      detailAddress: '12 Independence Avenue',
      isDefault: true,
      countryCode: 'GH',
      countryName: 'Ghana',
      provinceCode: 'GA',
      province: 'Greater Accra',
      cityCode: 'ACC',
      city: 'Accra',
      regionPath: [
        TospinoRegion(
          id: 'country-gh',
          name: 'Ghana',
          code: 'GH',
          level: 0,
          hasChildren: true,
        ),
        TospinoRegion(
          id: 'province-ga',
          name: 'Greater Accra',
          code: 'GA',
          parentId: 'country-gh',
          level: 1,
          hasChildren: true,
        ),
        TospinoRegion(
          id: 'city-acc',
          name: 'Accra',
          code: 'ACC',
          parentId: 'province-ga',
          level: 2,
        ),
      ],
    ),
  ];

  TospinoAddress? get _address {
    for (final address in addressList) {
      if (address.isDefault) return address;
    }
    return addressList.isEmpty ? null : addressList.first;
  }

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
  Future<void> requestRegistrationCode({
    required String account,
    required bool useEmail,
    String phonePrefix = '+233',
  }) async {
    registrationCodeCalls++;
    lastRegistrationAccount = account;
  }

  @override
  Future<void> verifyRegistrationCode({
    required String account,
    required String code,
    required bool useEmail,
    String phonePrefix = '+233',
  }) async {
    registrationVerifyCalls++;
    lastRegistrationAccount = account;
    lastRegistrationCode = code;
  }

  @override
  Future<void> registerBuyer({
    required String account,
    required String code,
    required String password,
    required bool useEmail,
    String phonePrefix = '+233',
    String promoteCode = '',
  }) async {
    registerCalls++;
    lastRegistrationAccount = account;
    lastRegistrationCode = code;
    lastRegistrationPassword = password;
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
      detailImageUrls: const [
        'https://example.com/detail-1.jpg',
        'https://example.com/detail-2.jpg',
      ],
      description: 'Live API product description',
      storeName: 'Tospino Store',
      servicePromises: const [
        'False a compensate ten',
        'FBT products: 7 days without reason to return or exchange',
      ],
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
  Future<List<TospinoCancelReason>> fetchCancelOrderReasons() async => const [
    TospinoCancelReason(id: 'changed-mind', reason: '不想要了'),
    TospinoCancelReason(id: 'other', reason: '其他原因'),
  ];

  @override
  Future<void> cancelOrder(String orderId, String reason) async {
    cancelOrderCalls++;
    lastCancelReason = reason;
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      orders[index] = orders[index].copyWith(
        statusCode: '5',
        statusLabel: '已取消',
      );
    }
  }

  @override
  Future<TospinoUser> fetchCurrentUser() async => _user;

  @override
  Future<TospinoInviteInfo> fetchInviteInfo() async {
    inviteInfoCalls++;
    return const TospinoInviteInfo(promoteCode: 'INV-233', userId: 'buyer-1');
  }

  @override
  Future<TospinoInviteFriendsPage> fetchInviteFriends({
    required String promoteCode,
    int page = 1,
    int pageSize = 20,
  }) async {
    inviteFriendCalls++;
    return TospinoInviteFriendsPage(
      records: List.of(inviteFriends),
      total: inviteFriends.length,
      page: page,
      pages: page,
    );
  }

  @override
  Future<TospinoInviteShareInfo> fetchInviteShareInfo(
    String promoteCode,
  ) async => TospinoInviteShareInfo(
    textContent: 'Join me on Tospino Mall with invitation code $promoteCode',
    url: 'https://m.tospino.com.gh/me/invite?promoteCode=$promoteCode',
  );

  @override
  Future<double> fetchInviteRewardAmount(String inviterId) async => 25.5;

  @override
  Future<TospinoInviteRewardPage> fetchInviteRewardPage({
    required String inviterId,
    int page = 1,
    int pageSize = 20,
  }) async {
    inviteRewardCalls++;
    return TospinoInviteRewardPage(
      records: List.of(inviteRewards),
      amount: 25.5,
      total: inviteRewards.length,
      page: page,
      pages: page,
    );
  }

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
  Future<List<TospinoAddress>> fetchAddresses() async => List.of(addressList);

  @override
  Future<TospinoAddress?> fetchDefaultAddress() async => _address;

  @override
  Future<TospinoAddress> saveAddress(
    TospinoAddress address, {
    required bool isDefault,
  }) async {
    saveAddressCalls++;
    if (isDefault) {
      for (var index = 0; index < addressList.length; index++) {
        addressList[index] = addressList[index].copyWith(isDefault: false);
      }
    }
    final saved = address.copyWith(
      id: address.id.isEmpty ? 'address-${addressList.length + 1}' : address.id,
      isDefault: isDefault,
    );
    final index = addressList.indexWhere((item) => item.id == saved.id);
    if (index >= 0) {
      addressList[index] = saved;
    } else {
      addressList.add(saved);
    }
    return saved;
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    deleteAddressCalls++;
    addressList.removeWhere((address) => address.id == addressId);
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    setDefaultAddressCalls++;
    for (var index = 0; index < addressList.length; index++) {
      addressList[index] = addressList[index].copyWith(
        isDefault: addressList[index].id == addressId,
      );
    }
  }

  @override
  Future<List<TospinoRegion>> fetchRegions({String parentId = '0'}) async {
    const regions = [
      TospinoRegion(
        id: 'country-gh',
        name: 'Ghana',
        code: 'GH',
        level: 0,
        hasChildren: true,
      ),
      TospinoRegion(
        id: 'province-ga',
        name: 'Greater Accra',
        code: 'GA',
        parentId: 'country-gh',
        level: 1,
        hasChildren: true,
      ),
      TospinoRegion(
        id: 'city-acc',
        name: 'Accra',
        code: 'ACC',
        parentId: 'province-ga',
        level: 2,
      ),
    ];
    return regions.where((region) {
      if (parentId == '0') return region.level == 0;
      return region.parentId == parentId;
    }).toList();
  }

  @override
  Future<List<TospinoPhonePrefix>> fetchPhonePrefixes() async {
    phonePrefixCalls++;
    return const [
      TospinoPhonePrefix(country: 'Ghana', prefix: '+233'),
      TospinoPhonePrefix(country: 'Nigeria', prefix: '+234'),
      TospinoPhonePrefix(country: 'China', prefix: '+86'),
    ];
  }

  @override
  Future<List<TospinoRegion>> resolveRegionsByCoordinates({
    required double longitude,
    required double latitude,
  }) async {
    coordinateRegionCalls++;
    return const [
      TospinoRegion(
        id: 'country-gh',
        name: 'Ghana',
        code: 'GH',
        level: 0,
        hasChildren: true,
      ),
      TospinoRegion(
        id: 'province-ga',
        name: 'Greater Accra',
        code: 'GA',
        parentId: 'country-gh',
        level: 1,
        hasChildren: true,
      ),
      TospinoRegion(
        id: 'city-acc',
        name: 'Accra',
        code: 'ACC',
        parentId: 'province-ga',
        level: 2,
      ),
    ];
  }

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

class _SingleFreeGiftTospinoApi extends _FakeTospinoApi {
  @override
  Future<List<TospinoFreeGift>> fetchFreeGifts() async => const [
    TospinoFreeGift(
      id: 'free-1',
      activityCode: 'FREE-1',
      productId: 'free-product-1',
      productName: 'Single zero-yuan product',
      productImage: 'https://example.com/free-product.jpg',
      storeName: 'Tospino Store',
      minPrice: 0,
      maxPrice: 0,
      receiveNum: 12,
      requiredHelpers: 3,
      durationHours: 24,
    ),
  ];
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
