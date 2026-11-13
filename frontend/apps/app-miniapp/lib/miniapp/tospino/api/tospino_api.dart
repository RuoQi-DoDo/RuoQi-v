import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as crypt;
import 'package:shared_preferences/shared_preferences.dart';

import '../tospino_models.dart';

class TospinoConfig {
  const TospinoConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'TOSPINO_API_BASE_URL',
    defaultValue: 'https://tospinomallapi-test.tospinomall.com',
  );
  static const ssoBaseUrl = String.fromEnvironment(
    'TOSPINO_SSO_BASE_URL',
    defaultValue: 'https://oauthapi-test.tospinomall.com',
  );
  static const configuredAccessToken = String.fromEnvironment(
    'TOSPINO_ACCESS_TOKEN',
  );
  static const configuredTokenType = String.fromEnvironment(
    'TOSPINO_TOKEN_TYPE',
    defaultValue: 'bearer',
  );
  static const language = String.fromEnvironment(
    'TOSPINO_LANGUAGE',
    defaultValue: 'en',
  );
  static const site = String.fromEnvironment(
    'TOSPINO_SITE',
    defaultValue: 'ghana',
  );
  static const appVersion = '1.0.0';
  static const appVersionCode = '1';
  static const basicAuthorization = 'Basic YnV5ZXI6YnV5ZXI=';
}

class TospinoSession {
  TospinoSession({
    this.accessToken = '',
    this.tokenType = 'bearer',
    this.refreshToken = '',
    this.userId = '',
    this.termId = '',
  });

  String accessToken;
  String tokenType;
  String refreshToken;
  String userId;
  String termId;

  bool get isLoggedIn => accessToken.isNotEmpty;

  String get authorization => isLoggedIn
      ? '${tokenType.isEmpty ? 'bearer' : tokenType} $accessToken'
      : TospinoConfig.basicAuthorization;

  Map<String, String> get headers => {
    'Authorization': authorization,
    'clientType': 'android',
    'language': TospinoConfig.language,
    'version': TospinoConfig.appVersion,
    'versionCode': TospinoConfig.appVersionCode,
    'site': TospinoConfig.site,
    'termId': termId,
  };
}

abstract interface class TospinoDataSource {
  bool get isLoggedIn;
  String get userId;
  TospinoUser? get currentUser;

  Future<void> initialize();
  Future<List<TospinoCategory>> fetchCategories();
  Future<List<TospinoProduct>> searchProducts({
    String keyword = '',
    String? navigationCategoryId,
    int page = 0,
    int pageSize = 20,
  });
  Future<TospinoProductDetail> fetchProductDetail(String productId);
  Future<List<TospinoCartLine>> fetchCart();
  Future<void> addToCart(String skuId, {int quantity = 1});
  Future<void> updateCartQuantity(String skuId, int quantity);
  Future<void> removeFromCart(String skuId);
  Future<List<TospinoOrder>> fetchOrders({TospinoOrderStatus? status});
  Future<TospinoOrder> fetchOrderDetail(String orderId);
  Future<TospinoUser> fetchCurrentUser();
  Future<List<TospinoProduct>> fetchFavorites();
  Future<void> followProduct(String productId);
  Future<void> unfollowProduct(String productId);
  Future<TospinoAddress?> fetchDefaultAddress();
  Future<TospinoSaleInfo> fetchSaleInfo({
    required List<TospinoCartLine> lines,
    required TospinoAddress address,
    required bool fromCart,
    required int paymentType,
  });
  Future<List<String>> submitOrder({
    required List<TospinoCartLine> lines,
    required TospinoAddress address,
    required bool fromCart,
    required int paymentType,
    required TospinoSaleInfo saleInfo,
  });
  Future<TospinoUser> login({
    required String account,
    required String password,
    String phonePrefix = '+233',
  });
  Future<void> logout();
}

class TospinoApi implements TospinoDataSource {
  TospinoApi({Dio? dio, TospinoSession? session})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: TospinoConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 20),
            ),
          ),
      session = session ?? TospinoSession();

  final Dio _dio;
  final TospinoSession session;
  SharedPreferences? _preferences;
  TospinoUser? _currentUser;

  @override
  bool get isLoggedIn => session.isLoggedIn;

  @override
  String get userId => session.userId;

  @override
  TospinoUser? get currentUser => _currentUser;

  @override
  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    session
      ..accessToken =
          _preferences?.getString('tospino_access_token') ??
          TospinoConfig.configuredAccessToken
      ..tokenType =
          _preferences?.getString('tospino_token_type') ??
          TospinoConfig.configuredTokenType
      ..refreshToken = _preferences?.getString('tospino_refresh_token') ?? ''
      ..userId = _preferences?.getString('tospino_user_id') ?? ''
      ..termId = await _deviceId();
  }

  Future<String> _deviceId() async {
    final existing = _preferences?.getString('tospino_term_id');
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final suffix = List.generate(
      12,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    final value = 'ruoqi-flutter-$suffix';
    await _preferences?.setString('tospino_term_id', value);
    return value;
  }

  Options _options({bool authenticated = true}) => Options(
    headers: authenticated
        ? session.headers
        : {
            'Authorization': TospinoConfig.basicAuthorization,
            'clientType': 'android',
            'language': TospinoConfig.language,
            'version': TospinoConfig.appVersion,
            'versionCode': TospinoConfig.appVersionCode,
            'site': TospinoConfig.site,
            'termId': session.termId,
          },
  );

  Future<dynamic> _get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: query,
        options: _options(),
      );
      return _unwrap(response.data);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<dynamic> _post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: _options(),
      );
      return _unwrap(response.data);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<dynamic> _put(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: _options(),
      );
      return _unwrap(response.data);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<dynamic> _delete(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: _options(),
      );
      return _unwrap(response.data);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  dynamic _unwrap(dynamic body) {
    if (body is String) {
      body = jsonDecode(body);
    }
    if (body is! Map) return body;
    final map = Map<String, dynamic>.from(body);
    final code = _asInt(map['code']);
    if (code != null && code != 0 && code != 200) {
      throw TospinoApiException(
        _asString(map['msg']).isEmpty
            ? 'Tospino API request failed'
            : _asString(map['msg']),
        code: code,
      );
    }
    return map['data'];
  }

  TospinoApiException _mapError(DioException error) {
    final body = error.response?.data;
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      return TospinoApiException(
        _asString(map['msg']).isEmpty
            ? 'Tospino API request failed'
            : _asString(map['msg']),
        code: _asInt(map['code']),
        statusCode: error.response?.statusCode,
      );
    }
    return TospinoApiException(
      error.message ?? 'Tospino network request failed',
      statusCode: error.response?.statusCode,
    );
  }

  @override
  Future<List<TospinoCategory>> fetchCategories() async {
    final data = await _get('/product/nav/category/list/tree/1');
    return _asList(data).map(_categoryFromJson).toList(growable: false);
  }

  @override
  Future<List<TospinoProduct>> searchProducts({
    String keyword = '',
    String? navigationCategoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    var categoryIds = const <String>[];
    var productIds = const <String>[];
    if (navigationCategoryId != null) {
      final links = _asMap(
        await _post(
          '/product/nav/category/getCategoryLinkMap',
          data: <String>[navigationCategoryId],
        ),
      );
      categoryIds = _asList(
        links['categoryIds'],
      ).map(_asString).where((id) => id.isNotEmpty).toList(growable: false);
      productIds = _asList(
        links['productIds'],
      ).map(_asString).where((id) => id.isNotEmpty).toList(growable: false);
    }
    final payload = <String, dynamic>{
      'pageNum': '$page',
      'pageIndex': '$page',
      'pageSize': '$pageSize',
      'type': '22',
      'available': '0',
      if (keyword.trim().isNotEmpty) 'searchKeyword': keyword.trim(),
      if (categoryIds.isNotEmpty) 'categoryIds': categoryIds,
      if (productIds.isNotEmpty) 'goodsIdList': productIds,
      if (session.userId.isNotEmpty) 'userId': session.userId,
    };
    final data = await _post('/search/productsearch/query', data: payload);
    return _asList(
      _asMap(data)['items'],
    ).map(_productFromJson).toList(growable: false);
  }

  @override
  Future<TospinoProductDetail> fetchProductDetail(String productId) async {
    final data = await _get(
      '/product/goods/client/detail/$productId',
      query: {if (session.userId.isNotEmpty) 'userId': session.userId},
    );
    final map = _asMap(data);
    final spu = _asMap(map['goodSpuVo']);
    final gallery = _asList(map['carouselMapUrls'])
        .map((item) => _normalizeUrl(_asString(_asMap(item)['imgUrl'])))
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
    final mainPicture = _normalizeUrl(_asString(spu['mainPictureUrl']));
    final product = TospinoProduct(
      id: _asString(spu['id'], fallback: productId),
      title: _asString(spu['goodTitle']),
      brand: _asString(spu['brandName']),
      categoryId: _asString(spu['categoryId']),
      price: _asDouble(spu['minPrice']),
      oldPrice: _asDouble(spu['maxPrice']),
      rating: _asDouble(spu['starLevel']),
      imageUrl: gallery.isNotEmpty ? gallery.first : mainPicture,
      shopName: _asString(_asMap(map['storeInfo'])['storeName']),
    );
    var skuId = '';
    final attrs = _asList(map['saleAttr']);
    if (attrs.isNotEmpty) {
      final values = _asList(_asMap(attrs.first)['attrValues']);
      if (values.isNotEmpty) {
        final skus = _asList(_asMap(values.first)['skuList']);
        if (skus.isNotEmpty) {
          skuId = _asString(_asMap(skus.first)['skuId']);
        }
      }
    }
    if (skuId.isEmpty) {
      throw const TospinoApiException('This product has no purchasable SKU');
    }
    return TospinoProductDetail(
      product: product,
      skuId: skuId,
      galleryUrls: gallery.isEmpty && mainPicture.isNotEmpty
          ? [mainPicture]
          : gallery,
      description: _asString(spu['description']),
      servicePromises: _asList(
        map['servicePromises'],
      ).map(_asString).where((item) => item.isNotEmpty).toList(growable: false),
      storeName: _asString(_asMap(map['storeInfo'])['storeName']),
      isFavorite: _asInt(spu['isAttention']) == 1,
    );
  }

  @override
  Future<List<TospinoCartLine>> fetchCart() async {
    final data = await _get(
      '/carts/shoppingCart/findListPage',
      query: {'queryType': '1'},
    );
    final result = <TospinoCartLine>[];
    for (final storeValue in _asList(_asMap(data)['storeList'])) {
      final store = _asMap(storeValue);
      for (final productValue in _asList(store['products'])) {
        final item = _asMap(productValue);
        result.add(
          TospinoCartLine(
            skuId: _asString(item['productSku']),
            productId: _asString(item['productId']),
            title: _asString(item['productName']),
            imageUrl: _normalizeUrl(_asString(item['mainPictureUrl'])),
            price: _asDouble(item['productPrice']),
            quantity: _asInt(item['quantity']) ?? 1,
            storeId: _asString(item['storeId']),
            storeName: _asString(
              item['storeName'],
              fallback: _asString(store['storeName']),
            ),
            attributes: _asList(item['productAttr'])
                .map(
                  (attr) =>
                      '${_asString(_asMap(attr)['attrName'])}: ${_asString(_asMap(attr)['attrValue'])}',
                )
                .toList(growable: false),
            valid: _asString(item['status']) != '0',
          ),
        );
      }
    }
    return result;
  }

  @override
  Future<void> addToCart(String skuId, {int quantity = 1}) async {
    await _post(
      '/carts/shoppingCart/addCart',
      query: {'skuId': skuId, 'quantity': '$quantity'},
    );
  }

  @override
  Future<void> updateCartQuantity(String skuId, int quantity) async {
    await _put(
      '/carts/shoppingCart/updateCartNumById',
      query: {'skuId': skuId, 'quantity': '$quantity'},
    );
  }

  @override
  Future<void> removeFromCart(String skuId) async {
    await _delete('/carts/shoppingCart/removeCart', query: {'skuIds': skuId});
  }

  @override
  Future<List<TospinoOrder>> fetchOrders({TospinoOrderStatus? status}) async {
    final data = await _get(
      '/order/omsorder/buyer/list/page',
      query: {'pageNum': '1', if (status != null) 'status': '${status.code}'},
    );
    return _asList(
      _asMap(data)['records'],
    ).map(_orderFromJson).toList(growable: false);
  }

  @override
  Future<TospinoOrder> fetchOrderDetail(String orderId) async {
    final data = await _get('/order/omsorder/buyer/detail/$orderId');
    return _orderFromJson(_asMap(data));
  }

  @override
  Future<List<TospinoProduct>> fetchFavorites() async {
    final data = await _get(
      '/admin/buyerAttention/query/page',
      query: {'pageNum': 1},
    );
    return _asList(_asMap(data)['records'])
        .map(
          (value) => TospinoProduct(
            id: _asString(_asMap(value)['productId']),
            title: _asString(_asMap(value)['productName']),
            price: _asDouble(_asMap(value)['productPrice']),
            imageUrl: _normalizeUrl(_asString(_asMap(value)['productImg'])),
          ),
        )
        .where((product) => product.id.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> followProduct(String productId) async {
    await _get('/admin/buyerAttention/attention/good/$productId');
  }

  @override
  Future<void> unfollowProduct(String productId) async {
    await _post(
      '/admin/buyerAttention/cancel/attention/good',
      data: <String>[productId],
    );
  }

  @override
  Future<TospinoAddress?> fetchDefaultAddress() async {
    final data = await _post(
      '/admin/ums/buyer/deliveryAddress/findCurrentDefault',
    );
    if (data == null) return null;
    return _addressFromJson(_asMap(data));
  }

  Map<String, dynamic> _orderPayload({
    required List<TospinoCartLine> lines,
    required TospinoAddress address,
    required bool fromCart,
    required int paymentType,
  }) => {
    'addressId': address.id,
    'isCart': fromCart ? '1' : '0',
    'paymentType': '$paymentType',
    'sourceType': '1',
    'skuItems': [
      for (final line in lines)
        {'skuId': line.skuId, 'count': '${line.quantity}'},
    ],
  };

  @override
  Future<TospinoSaleInfo> fetchSaleInfo({
    required List<TospinoCartLine> lines,
    required TospinoAddress address,
    required bool fromCart,
    required int paymentType,
  }) async {
    final data = await _post(
      '/product/goods/get/saleInfo',
      data: _orderPayload(
        lines: lines,
        address: address,
        fromCart: fromCart,
        paymentType: paymentType,
      ),
    );
    final map = _asMap(data);
    final discount =
        _asDouble(map['totalGoodsDisAmount']) +
        _asDouble(map['totalStoreDisAmount']) +
        _asDouble(map['totalPlatformDisAmount']);
    return TospinoSaleInfo(
      totalProductAmount: _asDouble(map['totalProductAmount']),
      totalFreight: _asDouble(map['totalBuyerFreightAmount']),
      totalDiscount: discount,
      payable: _asDouble(map['totalPayAmount']),
      orderToken: _asString(map['orderToken']),
      isCashDelivery: _asInt(map['isCashDelivery']) == 1,
      raw: map,
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
    final payload =
        _orderPayload(
            lines: lines,
            address: address,
            fromCart: fromCart,
            paymentType: paymentType,
          )
          ..['orderToken'] = saleInfo.orderToken
          ..['storeSaleInfoList'] = saleInfo.raw['storeSaleInfoList'];
    final data = await _post('/order/omsorder/submitOrder', data: payload);
    final map = _asMap(data);
    final ids = _asList(map['orderIds']).map(_asString).toList();
    if (ids.isNotEmpty) return ids;
    final id = _asString(map['id']);
    return id.isEmpty ? const [] : [id];
  }

  @override
  Future<TospinoUser> login({
    required String account,
    required String password,
    String phonePrefix = '+233',
  }) async {
    final trimmed = account.trim();
    final username = trimmed.contains('@') || trimmed.startsWith('+')
        ? trimmed
        : '$phonePrefix$trimmed';
    final form = Uri(
      queryParameters: {
        'grant_type': 'password',
        'username': username,
        'password': tospinoEncryptPassword(password),
      },
    ).query;
    final response = await _dio.post<dynamic>(
      '${TospinoConfig.ssoBaseUrl}/auth/oauth/token',
      data: form,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Authorization': TospinoConfig.basicAuthorization,
          'clientType': 'android',
          'language': TospinoConfig.language,
          'site': TospinoConfig.site,
          'termId': session.termId,
        },
      ),
    );
    final data = _asMap(_unwrap(response.data));
    session
      ..accessToken = _asString(data['access_token'])
      ..tokenType = _asString(data['token_type'], fallback: 'bearer')
      ..refreshToken = _asString(data['refresh_token'])
      ..userId = _asString(_asMap(data['user_info'])['id']);
    await _persistSession();
    _currentUser = await fetchCurrentUser();
    return _currentUser!;
  }

  @override
  Future<TospinoUser> fetchCurrentUser() async {
    final data = await _get('/admin/ums/buyer/findCurrentUserinfo');
    final map = _asMap(data);
    final phone = _asString(map['phone']);
    final email = _asString(map['email']);
    final nickname = _asString(map['nickname']);
    final user = TospinoUser(
      id: _asString(map['id'], fallback: session.userId),
      displayName: nickname.isNotEmpty
          ? nickname
          : phone.isNotEmpty
          ? phone
          : email,
      phone: phone,
      email: email,
      avatarUrl: _normalizeUrl(_asString(map['headPictureUrl'])),
      balance: _asDouble(map['balance']),
      favoriteCount: _asInt(map['attentionProductNum']) ?? 0,
      couponCount: _asInt(map['couponNum']) ?? 0,
    );
    _currentUser = user;
    return user;
  }

  Future<void> _persistSession() async {
    await _preferences?.setString('tospino_access_token', session.accessToken);
    await _preferences?.setString('tospino_token_type', session.tokenType);
    await _preferences?.setString(
      'tospino_refresh_token',
      session.refreshToken,
    );
    await _preferences?.setString('tospino_user_id', session.userId);
  }

  @override
  Future<void> logout() async {
    try {
      if (session.isLoggedIn) {
        await _dio.delete<dynamic>(
          '${TospinoConfig.ssoBaseUrl}/auth/token/logout',
          options: _options(),
        );
      }
    } finally {
      session
        ..accessToken = ''
        ..refreshToken = ''
        ..userId = '';
      _currentUser = null;
      await _preferences?.remove('tospino_access_token');
      await _preferences?.remove('tospino_refresh_token');
      await _preferences?.remove('tospino_user_id');
    }
  }
}

String tospinoEncryptPassword(String password) {
  const keyText = 'tospinomallkeyiv';
  final bytes = utf8.encode(password);
  final paddedLength = ((bytes.length + 15) ~/ 16) * 16;
  final padded = List<int>.filled(paddedLength, 0)
    ..setRange(0, bytes.length, bytes);
  final encrypter = crypt.Encrypter(
    crypt.AES(
      crypt.Key.fromUtf8(keyText),
      mode: crypt.AESMode.cbc,
      padding: null,
    ),
  );
  return encrypter.encryptBytes(padded, iv: crypt.IV.fromUtf8(keyText)).base64;
}

TospinoCategory _categoryFromJson(dynamic value) {
  final map = _asMap(value);
  return TospinoCategory(
    id: _asString(map['id']),
    label: _asString(map['name']),
    iconUrl: _normalizeUrl(_asString(map['icon'])),
    children: _asList(map['children']).map(_categoryFromJson).toList(),
    linkIds: _asList(map['linkIds']).map(_asString).toList(),
  );
}

TospinoProduct _productFromJson(dynamic value) {
  final map = _asMap(value);
  final promotionPrice = _asDouble(map['promotionPrice']);
  final minPrice = _asDouble(map['minPrice']);
  final productPrice = _asDouble(map['productPrice']);
  return TospinoProduct(
    id: _asString(map['productId']),
    title: _asString(map['productTitle']),
    brand: _asString(map['brandName']),
    categoryId: _asString(map['categoryId']),
    categoryName: _asString(map['categoryName']),
    price: promotionPrice > 0
        ? promotionPrice
        : minPrice > 0
        ? minPrice
        : productPrice,
    oldPrice: productPrice > promotionPrice ? productPrice : 0,
    sales: _asInt(map['orderSaleCount']) ?? _asInt(map['saleCount']) ?? 0,
    rating: _asDouble(map['starLevel']),
    imageUrl: _normalizeUrl(_asString(map['mainPictureUrl'])),
    shopId: _asString(map['shopId']),
    shopName: _asString(map['shopName']),
    stock: _asInt(map['stock']) ?? 0,
    deliveryType: _asInt(map['deliveryType']) ?? 0,
  );
}

TospinoOrder _orderFromJson(dynamic value) {
  final map = _asMap(value);
  final statusCode = _asString(map['status']);
  final status = TospinoOrderStatus.fromCode(statusCode);
  final items = _asList(map['items'])
      .map((itemValue) {
        final item = _asMap(itemValue);
        return TospinoOrderItem(
          skuId: _asString(item['skuId']),
          productId: _asString(item['goodId']),
          title: _asString(item['goodName']),
          price: _asDouble(item['goodPrice']),
          quantity: _asInt(item['goodQuantity']) ?? 1,
          imageUrl: _normalizeUrl(_asString(item['goodImg'])),
        );
      })
      .toList(growable: false);
  final receiver = [
    _asString(map['receiverProvince']),
    _asString(map['receiverCity']),
    _asString(map['receiverDetailAddress']),
  ].where((part) => part.isNotEmpty).join(', ');
  return TospinoOrder(
    id: _asString(map['id']),
    orderSn: _asString(map['orderSn']),
    statusCode: statusCode,
    statusLabel: status?.label ?? '',
    total: _asDouble(map['payAmount']),
    productAmount: _asDouble(map['productAmount']),
    freight: _asDouble(map['buyerFreightAmount']),
    createdAt: _asString(map['createTime']),
    items: items,
    receiverName: _asString(map['receiverName']),
    receiverPhone: _asString(map['receiverPhone']),
    receiverAddress: receiver,
  );
}

TospinoAddress _addressFromJson(Map<String, dynamic> map) => TospinoAddress(
  id: _asString(map['id']),
  name: _asString(map['name']),
  phone: '${_asString(map['phonePrefix'])} ${_asString(map['phone'])}'.trim(),
  completeAddress: _asString(
    map['completeAddressDetail'],
    fallback: _asString(
      map['completeAddress'],
      fallback: _asString(map['address']),
    ),
  ),
  isDefault: _asInt(map['isDefault']) == 1,
);

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<dynamic> _asList(dynamic value) =>
    value is List ? List<dynamic>.from(value) : const [];

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String _normalizeUrl(String value) {
  if (value.startsWith('//')) return 'https:$value';
  return value.replaceAll('&amp;', '&');
}
