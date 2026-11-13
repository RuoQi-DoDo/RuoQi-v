import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api/tospino_api.dart';
import 'tospino_models.dart';

enum TospinoRoute {
  home(path: '/pages/index/index', title: 'Tospino', tabIndex: 0),
  category(path: '/pages/category/category', title: '分类', tabIndex: 1),
  cart(path: '/pages/cart/cart', title: '购物车', tabIndex: 2),
  profile(path: '/pages/user/user', title: '我的', tabIndex: 3),
  search(path: '/pages/search/search', title: '搜索'),
  product(path: '/pages/product/detail', title: '商品详情'),
  checkout(path: '/pages/order/checkout', title: '确认订单'),
  orders(path: '/pages/order/list', title: '我的订单'),
  orderDetail(path: '/pages/order/detail', title: '订单详情'),
  favorites(path: '/pages/user/favorites', title: '我的收藏'),
  address(path: '/pages/user/address', title: '收货地址'),
  login(path: '/pages/login/login', title: '登录 Tospino'),
  settings(path: '/pages/user/settings', title: '设置'),
  about(path: '/pages/user/about', title: '关于 Tospino');

  const TospinoRoute({required this.path, required this.title, this.tabIndex});

  final String path;
  final String title;
  final int? tabIndex;

  bool get isTabRoot => tabIndex != null;
}

class TospinoAppController extends ChangeNotifier {
  TospinoAppController({TospinoDataSource? api, this.initialProductId})
    : _api = api ?? TospinoApi();

  final TospinoDataSource _api;
  final String? initialProductId;
  final List<TospinoRoute> _history = <TospinoRoute>[TospinoRoute.home];
  final Set<String> _selectedSkuIds = <String>{};
  Timer? _searchDebounce;

  TospinoRoute _route = TospinoRoute.home;
  TospinoRoute _loginReturnRoute = TospinoRoute.profile;
  int _tabIndex = 0;
  bool _forward = true;
  bool _initialized = false;
  bool _busy = false;
  bool _loadingHome = false;
  bool _loadingCategory = false;
  bool _loadingSearch = false;
  bool _loadingCart = false;
  bool _loadingOrders = false;
  bool _loadingDetail = false;
  bool _loadingCheckout = false;
  String? _homeError;
  String? _categoryError;
  String? _searchError;
  String? _cartError;
  String? _ordersError;
  String? _detailError;
  String? _checkoutError;
  String? _loginError;
  List<TospinoCategory> _categories = const [];
  List<TospinoProduct> _homeProducts = const [];
  List<TospinoProduct> _categoryProducts = const [];
  List<TospinoProduct> _searchResults = const [];
  List<TospinoProduct> _favorites = const [];
  List<TospinoCartLine> _cartLines = const [];
  List<TospinoOrder> _orders = const [];
  TospinoUser? _user;
  TospinoAddress? _defaultAddress;
  TospinoProductDetail? _productDetail;
  TospinoOrder? _selectedOrder;
  TospinoSaleInfo? _saleInfo;
  List<TospinoCartLine> _checkoutLines = const [];
  bool _checkoutFromCart = true;
  String _selectedCategoryId = '';
  String _searchQuery = '';
  String? _selectedProductId;
  TospinoOrderStatus? _orderFilter;

  TospinoRoute get route => _route;
  int get tabIndex => _tabIndex;
  bool get forward => _forward;
  bool get canGoBack => _history.length > 1;
  bool get initialized => _initialized;
  bool get busy => _busy;
  bool get isLoggedIn => _api.isLoggedIn;
  bool get loadingHome => _loadingHome;
  bool get loadingCategory => _loadingCategory;
  bool get loadingSearch => _loadingSearch;
  bool get loadingCart => _loadingCart;
  bool get loadingOrders => _loadingOrders;
  bool get loadingDetail => _loadingDetail;
  bool get loadingCheckout => _loadingCheckout;
  String? get homeError => _homeError;
  String? get categoryError => _categoryError;
  String? get searchError => _searchError;
  String? get cartError => _cartError;
  String? get ordersError => _ordersError;
  String? get detailError => _detailError;
  String? get checkoutError => _checkoutError;
  String? get loginError => _loginError;
  List<TospinoCategory> get categories => List.unmodifiable(_categories);
  List<TospinoProduct> get homeProducts => List.unmodifiable(_homeProducts);
  List<TospinoProduct> get categoryProducts =>
      List.unmodifiable(_categoryProducts);
  List<TospinoProduct> get searchResults => List.unmodifiable(_searchResults);
  List<TospinoProduct> get favorites => List.unmodifiable(_favorites);
  List<TospinoOrder> get orders => List.unmodifiable(_orders);
  TospinoUser? get user => _user;
  TospinoAddress? get defaultAddress => _defaultAddress;
  TospinoProductDetail? get productDetail => _productDetail;
  TospinoOrder? get selectedOrder => _selectedOrder;
  TospinoSaleInfo? get saleInfo => _saleInfo;
  TospinoOrderStatus? get orderFilter => _orderFilter;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  String? get selectedProductId => _selectedProductId;

  TospinoCategory? get selectedCategory {
    for (final category in _categories) {
      if (category.id == _selectedCategoryId) return category;
    }
    return _categories.isEmpty ? null : _categories.first;
  }

  List<TospinoCartLine> get cartLines => [
    for (final line in _cartLines)
      line.copyWith(selected: _selectedSkuIds.contains(line.skuId)),
  ];

  List<TospinoCartLine> get selectedCartLines =>
      cartLines.where((line) => line.selected && line.valid).toList();

  int get cartCount => _cartLines.fold(0, (sum, line) => sum + line.quantity);
  double get cartTotal =>
      selectedCartLines.fold(0, (sum, line) => sum + line.subtotal);
  List<TospinoCartLine> get checkoutLines => List.unmodifiable(_checkoutLines);
  bool get checkoutFromCart => _checkoutFromCart;

  bool isFavorite(String productId) {
    if (_productDetail?.product.id == productId) {
      return _productDetail!.isFavorite;
    }
    return _favorites.any((product) => product.id == productId);
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _api.initialize();
    } catch (_) {
      // Public catalogue requests can still proceed without local storage.
    }
    await Future.wait([refreshHome(), _loadCategories()]);
    if (_api.isLoggedIn) {
      await refreshAccount();
    }
    if (initialProductId != null) {
      final products = [
        ..._homeProducts,
        ..._categoryProducts,
        ..._searchResults,
      ];
      TospinoProduct? product;
      for (final item in products) {
        if (item.id == initialProductId) {
          product = item;
          break;
        }
      }
      await openProduct(
        product ?? TospinoProduct(id: initialProductId!, title: '', price: 0),
      );
    }
    notifyListeners();
  }

  Future<void> refreshHome() async {
    _loadingHome = true;
    _homeError = null;
    notifyListeners();
    try {
      _homeProducts = await _api.searchProducts(page: 0, pageSize: 20);
    } catch (error) {
      _homeError = error.toString();
    } finally {
      _loadingHome = false;
      notifyListeners();
    }
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _api.fetchCategories();
      if (_categories.isNotEmpty) {
        final preferred = _categories.where((category) {
          final name = category.label.toLowerCase();
          return name.contains('for you') || name.contains('digital');
        });
        _selectedCategoryId = preferred.isNotEmpty
            ? preferred.first.id
            : _categories.first.id;
      }
      notifyListeners();
    } catch (error) {
      _homeError ??= error.toString();
      notifyListeners();
    }
  }

  Future<void> selectCategory(String categoryId) async {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    await loadCategoryProducts();
  }

  Future<void> loadCategoryProducts() async {
    final category = selectedCategory;
    if (category == null) return;
    _loadingCategory = true;
    _categoryError = null;
    notifyListeners();
    try {
      _categoryProducts = await _api.searchProducts(
        navigationCategoryId: category.firstLeaf.id,
        pageSize: 20,
      );
    } catch (error) {
      _categoryError = error.toString();
      _categoryProducts = const [];
    } finally {
      _loadingCategory = false;
      notifyListeners();
    }
  }

  void open(TospinoRoute route) {
    if (route == _route) return;
    _forward = true;
    _route = route;
    _history.add(route);
    notifyListeners();
  }

  void back() {
    if (!canGoBack) return;
    _forward = false;
    _history.removeLast();
    _route = _history.last;
    final tab = _route.tabIndex;
    if (tab != null) _tabIndex = tab;
    notifyListeners();
  }

  void switchTab(int index) {
    final route = switch (index) {
      0 => TospinoRoute.home,
      1 => TospinoRoute.category,
      2 => TospinoRoute.cart,
      _ => TospinoRoute.profile,
    };
    if (route == TospinoRoute.cart && !_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.cart);
      return;
    }
    _forward = index >= _tabIndex;
    _tabIndex = index;
    _history
      ..clear()
      ..add(route);
    _route = route;
    notifyListeners();
    if (route == TospinoRoute.category) {
      unawaited(loadCategoryProducts());
    } else if (route == TospinoRoute.cart) {
      unawaited(refreshCart());
    } else if (route == TospinoRoute.profile && _api.isLoggedIn) {
      unawaited(refreshAccount());
    }
  }

  void resetToHome() {
    _history
      ..clear()
      ..add(TospinoRoute.home);
    _route = TospinoRoute.home;
    _tabIndex = 0;
    _forward = false;
    notifyListeners();
  }

  void openSearch() {
    _searchQuery = '';
    _searchResults = const [];
    _searchError = null;
    open(TospinoRoute.search);
  }

  void search(String query) {
    _searchQuery = query;
    _searchError = null;
    notifyListeners();
    _searchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchResults = const [];
      notifyListeners();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_runSearch(trimmed));
    });
  }

  Future<void> _runSearch(String query) async {
    _loadingSearch = true;
    notifyListeners();
    try {
      final results = await _api.searchProducts(keyword: query);
      if (_searchQuery.trim() == query) {
        _searchResults = results;
      }
    } catch (error) {
      if (_searchQuery.trim() == query) {
        _searchResults = const [];
        _searchError = error.toString();
      }
    } finally {
      _loadingSearch = false;
      notifyListeners();
    }
  }

  Future<void> openProduct(TospinoProduct product) async {
    _selectedProductId = product.id;
    _productDetail = null;
    _detailError = null;
    if (_route != TospinoRoute.product) {
      _forward = true;
      _route = TospinoRoute.product;
      _history.add(TospinoRoute.product);
    }
    _loadingDetail = true;
    notifyListeners();
    try {
      _productDetail = await _api.fetchProductDetail(product.id);
    } catch (error) {
      _detailError = error.toString();
    } finally {
      _loadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> refreshCart() async {
    if (!_api.isLoggedIn) return;
    _loadingCart = true;
    _cartError = null;
    notifyListeners();
    try {
      _cartLines = await _api.fetchCart();
      _selectedSkuIds
        ..removeWhere((skuId) => !_cartLines.any((line) => line.skuId == skuId))
        ..addAll(
          _cartLines
              .where((line) => !_selectedSkuIds.contains(line.skuId))
              .map((line) => line.skuId),
        );
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.cart);
      } else {
        _cartError = error.toString();
      }
    } finally {
      _loadingCart = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(TospinoProduct product, {int quantity = 1}) async {
    if (!_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.product);
      return false;
    }
    final detail = _productDetail;
    if (detail == null || detail.product.id != product.id) {
      throw const TospinoApiException('Product details are still loading');
    }
    _busy = true;
    notifyListeners();
    try {
      await _api.addToCart(detail.skuId, quantity: quantity);
      await refreshCart();
      return true;
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.product);
        return false;
      }
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> buyNow(TospinoProduct product, {int quantity = 1}) async {
    if (!_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.product);
      return false;
    }
    final detail = _productDetail;
    if (detail == null || detail.product.id != product.id) {
      throw const TospinoApiException('Product details are still loading');
    }
    final line = TospinoCartLine(
      skuId: detail.skuId,
      productId: product.id,
      title: product.title,
      price: product.price,
      quantity: quantity,
      storeId: '',
      storeName: detail.storeName,
      imageUrl: product.imageUrl,
    );
    await startCheckout(lines: [line], fromCart: false);
    return true;
  }

  void toggleCartSelection(String skuId) {
    if (!_selectedSkuIds.add(skuId)) {
      _selectedSkuIds.remove(skuId);
    }
    notifyListeners();
  }

  void selectAllCart(bool selected) {
    if (selected) {
      _selectedSkuIds.addAll(_cartLines.map((line) => line.skuId));
    } else {
      _selectedSkuIds.clear();
    }
    notifyListeners();
  }

  Future<void> incrementCart(String skuId) async {
    final line = _cartLines.where((item) => item.skuId == skuId).firstOrNull;
    if (line == null) return;
    await _api.updateCartQuantity(skuId, line.quantity + 1);
    await refreshCart();
  }

  Future<void> decrementCart(String skuId) async {
    final line = _cartLines.where((item) => item.skuId == skuId).firstOrNull;
    if (line == null) return;
    if (line.quantity <= 1) {
      await removeFromCart(skuId);
    } else {
      await _api.updateCartQuantity(skuId, line.quantity - 1);
      await refreshCart();
    }
  }

  Future<void> removeFromCart(String skuId) async {
    await _api.removeFromCart(skuId);
    await refreshCart();
  }

  Future<void> startCheckout({
    List<TospinoCartLine>? lines,
    bool fromCart = true,
  }) async {
    if (!_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.cart);
      return;
    }
    _checkoutLines = lines ?? selectedCartLines;
    _checkoutFromCart = fromCart;
    _saleInfo = null;
    _checkoutError = null;
    open(TospinoRoute.checkout);
    await loadCheckout();
  }

  Future<void> loadCheckout() async {
    if (_checkoutLines.isEmpty) {
      _checkoutError = 'Please select at least one item';
      notifyListeners();
      return;
    }
    _loadingCheckout = true;
    _checkoutError = null;
    notifyListeners();
    try {
      _defaultAddress = await _api.fetchDefaultAddress();
      if (_defaultAddress == null) {
        throw const TospinoApiException('No default shipping address');
      }
      _saleInfo = await _api.fetchSaleInfo(
        lines: _checkoutLines,
        address: _defaultAddress!,
        fromCart: _checkoutFromCart,
        paymentType: 2,
      );
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.cart);
      } else {
        _checkoutError = error.toString();
      }
    } finally {
      _loadingCheckout = false;
      notifyListeners();
    }
  }

  Future<List<String>> submitOrder() async {
    final address = _defaultAddress;
    final saleInfo = _saleInfo;
    if (address == null || saleInfo == null) {
      throw const TospinoApiException('Order information is not ready');
    }
    _busy = true;
    notifyListeners();
    try {
      final ids = await _api.submitOrder(
        lines: _checkoutLines,
        address: address,
        fromCart: _checkoutFromCart,
        paymentType: 2,
        saleInfo: saleInfo,
      );
      await refreshCart();
      await loadOrders();
      await refreshAccount();
      _orderFilter = TospinoOrderStatus.toShip;
      _history
        ..clear()
        ..add(TospinoRoute.orders);
      _route = TospinoRoute.orders;
      return ids;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> openOrders([TospinoOrderStatus? status]) async {
    if (!_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.profile);
      return;
    }
    _orderFilter = status;
    if (_route != TospinoRoute.orders) {
      open(TospinoRoute.orders);
    } else {
      notifyListeners();
    }
    await loadOrders();
  }

  Future<void> loadOrders() async {
    if (!_api.isLoggedIn) return;
    _loadingOrders = true;
    _ordersError = null;
    notifyListeners();
    try {
      _orders = await _api.fetchOrders(status: _orderFilter);
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.profile);
      } else {
        _ordersError = error.toString();
        _orders = const [];
      }
    } finally {
      _loadingOrders = false;
      notifyListeners();
    }
  }

  void clearOrderFilter() {
    _orderFilter = null;
    unawaited(loadOrders());
  }

  Future<void> openOrder(TospinoOrder order) async {
    _selectedOrder = order;
    open(TospinoRoute.orderDetail);
    try {
      _selectedOrder = await _api.fetchOrderDetail(order.id);
      notifyListeners();
    } catch (_) {
      // Keep the list record visible and let the user retry by reopening.
    }
  }

  Future<void> openFavorites() async {
    if (!_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.profile);
      return;
    }
    open(TospinoRoute.favorites);
    try {
      _favorites = await _api.fetchFavorites();
      notifyListeners();
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.profile);
      } else {
        _cartError = error.toString();
        notifyListeners();
      }
    }
  }

  Future<bool> toggleFavorite(TospinoProduct product) async {
    if (!_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.product);
      return false;
    }
    final active = isFavorite(product.id);
    if (active) {
      await _api.unfollowProduct(product.id);
    } else {
      await _api.followProduct(product.id);
    }
    if (_productDetail?.product.id == product.id) {
      final detail = _productDetail!;
      _productDetail = TospinoProductDetail(
        product: detail.product,
        skuId: detail.skuId,
        galleryUrls: detail.galleryUrls,
        description: detail.description,
        servicePromises: detail.servicePromises,
        storeName: detail.storeName,
        isFavorite: !active,
      );
    }
    if (active) {
      _favorites = _favorites
          .where((item) => item.id != product.id)
          .toList(growable: false);
    }
    notifyListeners();
    return !active;
  }

  Future<void> refreshAccount() async {
    if (!_api.isLoggedIn) {
      _user = null;
      notifyListeners();
      return;
    }
    try {
      _user = await _api.fetchCurrentUser();
      await Future.wait([refreshCart(), loadOrders()]);
      unawaited(_loadFavoritesSilently());
    } catch (_) {
      _user = null;
    }
    notifyListeners();
  }

  Future<void> _loadFavoritesSilently() async {
    try {
      _favorites = await _api.fetchFavorites();
      notifyListeners();
    } catch (_) {
      // Favorites are optional on the profile page.
    }
  }

  Future<void> openAddress() async {
    if (!_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.profile);
      return;
    }
    open(TospinoRoute.address);
    try {
      _defaultAddress = await _api.fetchDefaultAddress();
    } catch (_) {
      _defaultAddress = null;
    }
    notifyListeners();
  }

  void openLogin({TospinoRoute returnTo = TospinoRoute.profile}) {
    _loginReturnRoute = returnTo;
    _loginError = null;
    open(TospinoRoute.login);
  }

  Future<bool> login({
    required String account,
    required String password,
    String phonePrefix = '+233',
  }) async {
    _busy = true;
    _loginError = null;
    notifyListeners();
    try {
      _user = await _api.login(
        account: account,
        password: password,
        phonePrefix: phonePrefix,
      );
      await Future.wait([refreshCart(), loadOrders()]);
      unawaited(_loadFavoritesSilently());
      _history
        ..clear()
        ..add(_loginReturnRoute);
      _route = _loginReturnRoute;
      _tabIndex = _route.tabIndex ?? _tabIndex;
      _forward = false;
      return true;
    } catch (error) {
      _loginError = error.toString();
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _cartLines = const [];
    _orders = const [];
    _favorites = const [];
    _selectedSkuIds.clear();
    notifyListeners();
  }

  bool _requiresLogin(Object error) =>
      error is TospinoApiException && error.needsLogin;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
