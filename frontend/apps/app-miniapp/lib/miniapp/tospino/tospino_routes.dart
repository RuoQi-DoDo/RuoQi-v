import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api/tospino_api.dart';
import 'tospino_models.dart';
import 'tospino_sharing.dart';

enum TospinoRoute {
  home(path: '/pages/index/index', title: 'Tospino', tabIndex: 0),
  category(path: '/pages/category/category', title: '分类'),
  messages(path: '/pages/message/list', title: '消息', tabIndex: 1),
  cart(path: '/pages/cart/cart', title: '购物车', tabIndex: 2),
  profile(path: '/pages/user/user', title: '我的', tabIndex: 3),
  search(path: '/pages/search/search', title: '搜索'),
  register(path: '/pages/register/register', title: '注册'),
  product(path: '/pages/product/detail', title: '商品详情'),
  checkout(path: '/pages/order/checkout', title: '确认订单'),
  orders(path: '/pages/order/list', title: '我的订单'),
  orderDetail(path: '/pages/order/detail', title: '订单详情'),
  favorites(path: '/pages/user/favorites', title: '我的收藏'),
  freeGift(path: '/pages/free/list', title: '免费拿'),
  wallet(path: '/pages/user/wallet', title: '我的钱包'),
  coupons(path: '/pages/user/coupons', title: '我的优惠券'),
  shopFollow(path: '/pages/user/shops', title: '店铺关注'),
  invite(path: '/pages/user/invite', title: '邀请好友'),
  inviteRewards(path: '/pages/user/invite/rewards', title: '邀请奖励'),
  address(path: '/pages/user/address', title: '收货地址'),
  addressAdd(path: '/pages/user/address/add', title: '新增收货地址'),
  addressEdit(path: '/pages/user/address/edit', title: '编辑收货地址'),
  login(path: '/pages/login/login', title: '登录 Tospino'),
  settings(path: '/pages/user/settings', title: '设置'),
  about(path: '/pages/user/about', title: '关于 Tospino');

  const TospinoRoute({required this.path, required this.title, this.tabIndex});

  final String path;
  final String title;
  final int? tabIndex;

  bool get isTabRoot => tabIndex != null;
}

enum TospinoCartFilter {
  all(queryType: 1),
  priceCut(queryType: 2),
  oftenBuy(queryType: 3);

  const TospinoCartFilter({required this.queryType});

  final int queryType;
}

class TospinoAppController extends ChangeNotifier {
  TospinoAppController({
    TospinoDataSource? api,
    TospinoShareGateway? shareGateway,
    this.initialProductId,
  }) : _api = api ?? TospinoApi(),
       _shareGateway = shareGateway ?? const TospinoSystemShareGateway();

  static const _homePageSize = 20;

  final TospinoDataSource _api;
  final TospinoShareGateway _shareGateway;
  final String? initialProductId;
  final List<TospinoRoute> _history = <TospinoRoute>[TospinoRoute.home];
  final Set<String> _selectedSkuIds = <String>{};
  Timer? _searchDebounce;

  TospinoRoute _route = TospinoRoute.home;
  TospinoRoute _loginReturnRoute = TospinoRoute.profile;
  int _tabIndex = 0;
  bool _forward = true;
  bool _initialized = false;
  bool _homeLoaded = false;
  bool _loginOpen = false;
  bool _loginPasswordOnly = false;
  bool _registrationUseEmail = false;
  bool _busy = false;
  bool _loadingHome = false;
  bool _loadingMoreHome = false;
  bool _homeHasMore = true;
  bool _loadingCategory = false;
  bool _loadingSearch = false;
  bool _loadingCart = false;
  bool _loadingOrders = false;
  bool _loadingDetail = false;
  bool _loadingCheckout = false;
  bool _loadingFreeGifts = false;
  bool _loadingAddresses = false;
  bool _loadingInvite = false;
  bool _loadingMoreInviteFriends = false;
  bool _loadingInviteRewards = false;
  bool _loadingMoreInviteRewards = false;
  bool _addressSelectionMode = false;
  int _cartRequestVersion = 0;
  String? _homeError;
  String? _homeMoreError;
  String? _categoryError;
  String? _searchError;
  String? _cartError;
  String? _ordersError;
  String? _detailError;
  String? _checkoutError;
  String? _freeGiftError;
  String? _addressError;
  String? _inviteError;
  String? _inviteRewardsError;
  String? _loginError;
  String? _registrationError;
  int _nextHomePage = 1;
  List<TospinoCategory> _categories = const [];
  List<String> _homeRecommendWords = const [];
  List<TospinoProduct> _homeProducts = const [];
  List<TospinoProduct> _categoryProducts = const [];
  List<TospinoProduct> _searchResults = const [];
  List<TospinoProduct> _favorites = const [];
  List<TospinoCartLine> _cartLines = const [];
  TospinoCartCounts _cartCounts = const TospinoCartCounts();
  List<TospinoOrder> _orders = const [];
  List<TospinoFreeGift> _freeGifts = const [];
  List<TospinoAddress> _addresses = const [];
  final Set<String> _cancellingOrderIds = <String>{};
  TospinoInviteInfo? _inviteInfo;
  TospinoInviteShareInfo? _inviteShare;
  List<TospinoInviteFriend> _inviteFriends = const [];
  int _inviteFriendsTotal = 0;
  int _inviteFriendsPage = 0;
  int _inviteFriendsPages = 0;
  double _inviteRewardAmount = 0;
  List<TospinoInviteRewardRecord> _inviteRewardRecords = const [];
  int _inviteRewardsTotal = 0;
  int _inviteRewardsPage = 0;
  int _inviteRewardsPages = 0;
  TospinoUser? _user;
  TospinoAddress? _defaultAddress;
  TospinoAddress? _selectedAddress;
  TospinoAddress? _editingAddress;
  TospinoProductDetail? _productDetail;
  TospinoOrder? _selectedOrder;
  TospinoSaleInfo? _saleInfo;
  List<TospinoCartLine> _checkoutLines = const [];
  bool _checkoutFromCart = true;
  String _selectedCategoryId = '';
  String _searchQuery = '';
  String? _selectedProductId;
  TospinoOrderStatus? _orderFilter;
  TospinoCartFilter _cartFilter = TospinoCartFilter.all;

  TospinoRoute get route => _route;
  int get tabIndex => _tabIndex;
  bool get forward => _forward;
  bool get canGoBack => _history.length > 1;
  bool get initialized => _initialized;
  bool get loginOpen => _loginOpen;
  bool get loginPasswordOnly => _loginPasswordOnly;
  bool get registrationUseEmail => _registrationUseEmail;
  bool get homeLoaded => _homeLoaded;
  bool get busy => _busy;
  bool get isLoggedIn => _api.isLoggedIn;
  bool get loadingHome => _loadingHome;
  bool get loadingMoreHome => _loadingMoreHome;
  bool get homeHasMore => _homeHasMore;
  bool get loadingCategory => _loadingCategory;
  bool get loadingSearch => _loadingSearch;
  bool get loadingCart => _loadingCart;
  bool get loadingOrders => _loadingOrders;
  bool get loadingDetail => _loadingDetail;
  bool get loadingCheckout => _loadingCheckout;
  bool get loadingFreeGifts => _loadingFreeGifts;
  bool get loadingAddresses => _loadingAddresses;
  bool get loadingInvite => _loadingInvite;
  bool get loadingMoreInviteFriends => _loadingMoreInviteFriends;
  bool get loadingInviteRewards => _loadingInviteRewards;
  bool get loadingMoreInviteRewards => _loadingMoreInviteRewards;
  bool get addressSelectionMode => _addressSelectionMode;
  String? get homeError => _homeError;
  String? get homeMoreError => _homeMoreError;
  String? get categoryError => _categoryError;
  String? get searchError => _searchError;
  String? get cartError => _cartError;
  String? get ordersError => _ordersError;
  String? get detailError => _detailError;
  String? get checkoutError => _checkoutError;
  String? get freeGiftError => _freeGiftError;
  String? get addressError => _addressError;
  String? get inviteError => _inviteError;
  String? get inviteRewardsError => _inviteRewardsError;
  String? get loginError => _loginError;
  String? get registrationError => _registrationError;
  List<TospinoCategory> get categories => List.unmodifiable(_categories);
  List<String> get homeRecommendWords => List.unmodifiable(_homeRecommendWords);
  List<TospinoProduct> get homeProducts => List.unmodifiable(_homeProducts);
  List<TospinoProduct> get categoryProducts =>
      List.unmodifiable(_categoryProducts);
  List<TospinoProduct> get searchResults => List.unmodifiable(_searchResults);
  List<TospinoProduct> get favorites => List.unmodifiable(_favorites);
  List<TospinoOrder> get orders => List.unmodifiable(_orders);
  List<TospinoFreeGift> get freeGifts => List.unmodifiable(_freeGifts);
  List<TospinoAddress> get addresses => List.unmodifiable(_addresses);
  TospinoInviteInfo? get inviteInfo => _inviteInfo;
  TospinoInviteShareInfo? get inviteShare => _inviteShare;
  List<TospinoInviteFriend> get inviteFriends =>
      List.unmodifiable(_inviteFriends);
  int get inviteFriendsTotal => _inviteFriendsTotal;
  double get inviteRewardAmount => _inviteRewardAmount;
  List<TospinoInviteRewardRecord> get inviteRewardRecords =>
      List.unmodifiable(_inviteRewardRecords);
  int get inviteRewardsTotal => _inviteRewardsTotal;
  bool get hasMoreInviteFriends =>
      _inviteFriendsPages > 0 && _inviteFriendsPage < _inviteFriendsPages;
  bool get hasMoreInviteRewards =>
      _inviteRewardsPages > 0 && _inviteRewardsPage < _inviteRewardsPages;
  TospinoUser? get user => _user;
  TospinoAddress? get defaultAddress => _selectedAddress ?? _defaultAddress;
  TospinoAddress? get editingAddress => _editingAddress;
  TospinoProductDetail? get productDetail => _productDetail;
  TospinoOrder? get selectedOrder => _selectedOrder;
  TospinoSaleInfo? get saleInfo => _saleInfo;
  TospinoOrderStatus? get orderFilter => _orderFilter;
  String get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  String? get selectedProductId => _selectedProductId;

  bool isCancellingOrder(String orderId) =>
      _cancellingOrderIds.contains(orderId);

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

  int get cartCount {
    if (_cartCounts.allTotal > 0) return _cartCounts.allTotal;
    return _cartLines.fold(0, (sum, line) => sum + line.quantity);
  }

  TospinoCartCounts get cartCounts => _cartCounts;
  TospinoCartFilter get cartFilter => _cartFilter;
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
    _loadingMoreHome = false;
    _homeError = null;
    _homeMoreError = null;
    notifyListeners();
    List<String>? recommendWords;
    List<TospinoProduct>? products;
    Object? productError;
    await Future.wait([
      () async {
        try {
          recommendWords = await _api.fetchHomeRecommendWords();
        } catch (_) {
          recommendWords = const [];
        }
      }(),
      () async {
        try {
          products = await _api.searchProducts(
            page: 1,
            pageSize: _homePageSize,
          );
        } catch (error) {
          productError = error;
        }
      }(),
    ]);
    if (recommendWords != null) {
      _homeRecommendWords = recommendWords!;
    }
    if (products != null) {
      _homeProducts = products!;
      _nextHomePage = 2;
      _homeHasMore = _homeProducts.isNotEmpty;
    } else if (productError != null) {
      _homeError = productError.toString();
    }
    _loadingHome = false;
    _homeLoaded = true;
    notifyListeners();
    unawaited(refreshFreeGifts());
  }

  Future<void> refreshFreeGifts() async {
    if (_loadingFreeGifts) return;
    _loadingFreeGifts = true;
    _freeGiftError = null;
    notifyListeners();
    try {
      _freeGifts = await _api.fetchFreeGifts();
    } catch (error) {
      _freeGiftError = error.toString();
    } finally {
      _loadingFreeGifts = false;
      notifyListeners();
    }
  }

  Future<void> loadAddresses() async {
    if (!_api.isLoggedIn) return;
    _loadingAddresses = true;
    _addressError = null;
    notifyListeners();
    try {
      final addresses = await _api.fetchAddresses();
      _addresses = addresses;
      final selectedId = _selectedAddress?.id;
      _selectedAddress = addresses
          .where((address) => address.id == selectedId)
          .firstOrNull;
      _defaultAddress = addresses
          .where((address) => address.isDefault)
          .firstOrNull;
      _defaultAddress ??= addresses.firstOrNull;
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.address);
      } else {
        _addressError = error.toString();
      }
    } finally {
      _loadingAddresses = false;
      notifyListeners();
    }
  }

  Future<void> saveAddress(
    TospinoAddress address, {
    required bool isDefault,
  }) async {
    _busy = true;
    notifyListeners();
    try {
      final saved = await _api.saveAddress(address, isDefault: isDefault);
      if (isDefault) _selectedAddress = null;
      await loadAddresses();
      _defaultAddress ??= saved;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(TospinoAddress address) async {
    _busy = true;
    notifyListeners();
    try {
      await _api.deleteAddress(address.id);
      if (_selectedAddress?.id == address.id) _selectedAddress = null;
      await loadAddresses();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(TospinoAddress address) async {
    _busy = true;
    notifyListeners();
    try {
      await _api.setDefaultAddress(address.id);
      _selectedAddress = null;
      await loadAddresses();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void selectAddress(TospinoAddress address) {
    _selectedAddress = address;
    notifyListeners();
    if (_addressSelectionMode) {
      _addressSelectionMode = false;
      back();
      unawaited(loadCheckout());
    }
  }

  Future<List<TospinoRegion>> fetchRegions({String parentId = '0'}) =>
      _api.fetchRegions(parentId: parentId);

  Future<List<TospinoPhonePrefix>> fetchPhonePrefixes() =>
      _api.fetchPhonePrefixes();

  Future<void> openInvite() async {
    if (!_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.invite);
      return;
    }
    open(TospinoRoute.invite);
    await loadInvite();
  }

  Future<void> loadInvite() async {
    if (!_api.isLoggedIn || _loadingInvite) return;
    _loadingInvite = true;
    _inviteError = null;
    notifyListeners();
    try {
      final info = await _api.fetchInviteInfo();
      _inviteInfo = info;
      Object? friendsError;
      await Future.wait([
        () async {
          try {
            _inviteShare = await _api.fetchInviteShareInfo(info.promoteCode);
          } catch (_) {
            _inviteShare = null;
          }
        }(),
        () async {
          try {
            final friends = await _api.fetchInviteFriends(
              promoteCode: info.promoteCode,
            );
            _inviteFriends = friends.records;
            _inviteFriendsTotal = friends.total;
            _inviteFriendsPage = friends.page;
            _inviteFriendsPages = friends.pages;
          } catch (error) {
            friendsError = error;
          }
        }(),
        () async {
          try {
            _inviteRewardAmount = await _api.fetchInviteRewardAmount(
              info.userId.isEmpty ? _api.userId : info.userId,
            );
          } catch (_) {
            _inviteRewardAmount = 0;
          }
        }(),
      ]);
      if (friendsError != null) throw friendsError!;
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.invite);
      } else {
        _inviteError = error.toString();
      }
    } finally {
      _loadingInvite = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreInviteFriends() async {
    final info = _inviteInfo;
    if (info == null || _loadingMoreInviteFriends || !hasMoreInviteFriends) {
      return;
    }
    _loadingMoreInviteFriends = true;
    notifyListeners();
    try {
      final next = await _api.fetchInviteFriends(
        promoteCode: info.promoteCode,
        page: _inviteFriendsPage + 1,
      );
      final ids = _inviteFriends.map((friend) => friend.userId).toSet();
      _inviteFriends = [
        ..._inviteFriends,
        ...next.records.where((friend) => ids.add(friend.userId)),
      ];
      _inviteFriendsTotal = next.total;
      _inviteFriendsPage = next.page;
      _inviteFriendsPages = next.pages;
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.invite);
      }
    } finally {
      _loadingMoreInviteFriends = false;
      notifyListeners();
    }
  }

  Future<void> openInviteRewards() async {
    if (!_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.inviteRewards);
      return;
    }
    open(TospinoRoute.inviteRewards);
    await loadInviteRewards();
  }

  Future<void> loadInviteRewards() async {
    if (!_api.isLoggedIn || _loadingInviteRewards) return;
    _loadingInviteRewards = true;
    _inviteRewardsError = null;
    notifyListeners();
    try {
      final inviterId = _inviteInfo?.userId.isNotEmpty == true
          ? _inviteInfo!.userId
          : _api.userId;
      final rewards = await _api.fetchInviteRewardPage(inviterId: inviterId);
      _inviteRewardRecords = rewards.records;
      _inviteRewardAmount = rewards.amount;
      _inviteRewardsTotal = rewards.total;
      _inviteRewardsPage = rewards.page;
      _inviteRewardsPages = rewards.pages;
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.inviteRewards);
      } else {
        _inviteRewardsError = error.toString();
      }
    } finally {
      _loadingInviteRewards = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreInviteRewards() async {
    if (_loadingMoreInviteRewards || !hasMoreInviteRewards) return;
    _loadingMoreInviteRewards = true;
    notifyListeners();
    try {
      final inviterId = _inviteInfo?.userId.isNotEmpty == true
          ? _inviteInfo!.userId
          : _api.userId;
      final next = await _api.fetchInviteRewardPage(
        inviterId: inviterId,
        page: _inviteRewardsPage + 1,
      );
      final ids = _inviteRewardRecords.map((record) => record.id).toSet();
      _inviteRewardRecords = [
        ..._inviteRewardRecords,
        ...next.records.where((record) => ids.add(record.id)),
      ];
      _inviteRewardAmount = next.amount;
      _inviteRewardsTotal = next.total;
      _inviteRewardsPage = next.page;
      _inviteRewardsPages = next.pages;
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.inviteRewards);
      }
    } finally {
      _loadingMoreInviteRewards = false;
      notifyListeners();
    }
  }

  String get inviteShareContent {
    final configured = _inviteShare?.shareContent ?? '';
    if (configured.isNotEmpty) return configured;
    final code = _inviteInfo?.promoteCode ?? '';
    return code.isEmpty
        ? 'Join me on Tospino Mall and discover great offers.'
        : 'Join me on Tospino Mall. My invitation code: $code';
  }

  Future<void> shareInviteContent() =>
      _shareGateway.shareText(inviteShareContent, subject: 'Tospino Mall');

  Future<void> loadMoreHome() async {
    if (_loadingHome || _loadingMoreHome || !_homeHasMore) return;
    _loadingMoreHome = true;
    _homeMoreError = null;
    notifyListeners();
    try {
      final products = await _api.searchProducts(
        page: _nextHomePage,
        pageSize: _homePageSize,
      );
      final ids = _homeProducts.map((product) => product.id).toSet();
      final added = products.where((product) => ids.add(product.id)).toList();
      _homeProducts = [..._homeProducts, ...added];
      _nextHomePage++;
      _homeHasMore = products.isNotEmpty && added.isNotEmpty;
    } catch (error) {
      _homeMoreError = error.toString();
    } finally {
      _loadingMoreHome = false;
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
      _categoryError = error.toString();
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
        navigationCategoryId: category.id,
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
    if (_route == TospinoRoute.address) _addressSelectionMode = false;
    if (_route == TospinoRoute.addressAdd ||
        _route == TospinoRoute.addressEdit) {
      _editingAddress = null;
    }
    _forward = false;
    _history.removeLast();
    _route = _history.last;
    final tab = _route.tabIndex;
    if (tab != null) _tabIndex = tab;
    notifyListeners();
  }

  void openCategory({String? categoryId}) {
    final changedCategory =
        categoryId != null &&
        categoryId.isNotEmpty &&
        categoryId != _selectedCategoryId;
    if (changedCategory) _selectedCategoryId = categoryId;
    if (_route == TospinoRoute.category && !changedCategory) return;
    _forward = true;
    if (_route != TospinoRoute.category) {
      _route = TospinoRoute.category;
      _history.add(TospinoRoute.category);
    }
    notifyListeners();
    unawaited(loadCategoryProducts());
  }

  void switchTab(int index) {
    final route = switch (index) {
      0 => TospinoRoute.home,
      1 => TospinoRoute.messages,
      2 => TospinoRoute.cart,
      _ => TospinoRoute.profile,
    };
    _forward = index >= _tabIndex;
    _tabIndex = index;
    _history
      ..clear()
      ..add(route);
    _route = route;
    notifyListeners();
    if (route == TospinoRoute.messages) {
      unawaited(loadMessages());
    } else if (route == TospinoRoute.cart && _api.isLoggedIn) {
      unawaited(refreshCart());
    } else if (route == TospinoRoute.profile && _api.isLoggedIn) {
      unawaited(refreshAccount());
    }
  }

  void resetToHome() {
    _loginOpen = false;
    _loginPasswordOnly = false;
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
    unawaited(_loadDefaultAddressForProduct());
    try {
      _productDetail = await _api.fetchProductDetail(product.id);
    } catch (error) {
      _detailError = error.toString();
    } finally {
      _loadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> _loadDefaultAddressForProduct() async {
    if (!_api.isLoggedIn || _defaultAddress != null) return;
    try {
      final address = await _api.fetchDefaultAddress();
      if (address == null) return;
      _defaultAddress = address;
      notifyListeners();
    } catch (_) {
      // Delivery type can still be shown using the configured site country.
    }
  }

  Future<void> refreshCart() async {
    if (!_api.isLoggedIn) return;
    final requestVersion = ++_cartRequestVersion;
    final queryType = _cartFilter.queryType;
    _loadingCart = true;
    _cartError = null;
    notifyListeners();
    try {
      final countsFuture = _loadCartCounts();
      final lines = await _api.fetchCart(queryType: queryType);
      if (requestVersion != _cartRequestVersion) return;
      _cartLines = lines;
      _cartCounts = await countsFuture ?? _cartCounts;
      if (requestVersion != _cartRequestVersion) return;
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
      } else if (requestVersion == _cartRequestVersion) {
        _cartError = error.toString();
      }
    } finally {
      if (requestVersion == _cartRequestVersion) {
        _loadingCart = false;
        notifyListeners();
      }
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

  Future<void> selectCartFilter(TospinoCartFilter filter) async {
    if (_cartFilter == filter) return;
    _cartFilter = filter;
    notifyListeners();
    await refreshCart();
  }

  Future<bool> toggleOftenBuy(String skuId) async {
    final line = _cartLines.where((item) => item.skuId == skuId).firstOrNull;
    if (line == null) return false;
    final next = !line.isOftenBuy;
    try {
      await _api.setOftenBuy(skuId, isOftenBuy: next);
      await refreshCart();
      return true;
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.cart);
        return false;
      }
      rethrow;
    }
  }

  Future<TospinoCartCounts?> _loadCartCounts() async {
    try {
      return await _api.fetchCartCounts();
    } catch (_) {
      return null;
    }
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
      _selectedAddress ??= await _api.fetchDefaultAddress();
      final address = _selectedAddress;
      if (address == null) {
        throw const TospinoApiException('No default shipping address');
      }
      _saleInfo = await _api.fetchSaleInfo(
        lines: _checkoutLines,
        address: address,
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
    final address = _selectedAddress ?? _defaultAddress;
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

  Future<List<TospinoCancelReason>> fetchCancelOrderReasons() async {
    try {
      final reasons = await _api.fetchCancelOrderReasons();
      if (reasons.isNotEmpty) return reasons;
    } catch (error) {
      if (_requiresLogin(error)) rethrow;
    }
    return const [
      TospinoCancelReason(id: 'changed-mind', reason: '不想要了'),
      TospinoCancelReason(id: 'address', reason: '收货信息填写错误'),
      TospinoCancelReason(id: 'duplicate', reason: '重复下单'),
      TospinoCancelReason(id: 'other', reason: '其他原因'),
    ];
  }

  Future<void> cancelOrder(TospinoOrder order, String reason) async {
    if (!order.canCancel || _cancellingOrderIds.contains(order.id)) return;
    _cancellingOrderIds.add(order.id);
    notifyListeners();
    try {
      await _api.cancelOrder(order.id, reason);
      final cancelled = order.copyWith(statusCode: '5', statusLabel: '已取消');
      _orders = [
        for (final current in _orders)
          if (current.id == order.id) cancelled else current,
      ];
      if (_selectedOrder?.id == order.id) _selectedOrder = cancelled;
      if (_orderFilter == TospinoOrderStatus.toPay) {
        await loadOrders();
      }
    } catch (error) {
      if (_requiresLogin(error)) {
        openLogin(returnTo: TospinoRoute.orders);
      }
      rethrow;
    } finally {
      _cancellingOrderIds.remove(order.id);
      notifyListeners();
    }
  }

  Future<void> loadMessages() async {
    if (!_api.isLoggedIn) return;
    _orderFilter = null;
    await loadOrders();
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
        storeDeliveryCountryName: detail.storeDeliveryCountryName,
        storeDeliveryCountryCode: detail.storeDeliveryCountryCode,
        storeDeliveryAddress: detail.storeDeliveryAddress,
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

  Future<void> openAddress({bool forCheckout = false}) async {
    if (!_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.profile);
      return;
    }
    _addressSelectionMode = forCheckout;
    _addressError = null;
    open(TospinoRoute.address);
    await loadAddresses();
  }

  Future<void> openAddressEditor([TospinoAddress? address]) async {
    if (!_api.isLoggedIn) {
      openLogin(returnTo: TospinoRoute.address);
      return;
    }
    _editingAddress = address;
    open(address == null ? TospinoRoute.addressAdd : TospinoRoute.addressEdit);
  }

  void openLogin({TospinoRoute returnTo = TospinoRoute.profile}) {
    _loginReturnRoute = returnTo;
    _loginError = null;
    _registrationError = null;
    _loginPasswordOnly = false;
    _loginOpen = true;
    notifyListeners();
  }

  void openPasswordLogin() {
    _loginError = null;
    _loginPasswordOnly = true;
    _loginOpen = false;
    open(TospinoRoute.login);
  }

  void openRegistration({required bool useEmail}) {
    _registrationError = null;
    _registrationUseEmail = useEmail;
    _loginOpen = false;
    open(TospinoRoute.register);
  }

  void closeLogin({bool notify = true}) {
    if (!_loginOpen) return;
    _loginOpen = false;
    _loginError = null;
    _registrationError = null;
    if (notify) notifyListeners();
  }

  Future<bool> requestRegistrationCode({
    required String account,
    required bool useEmail,
    String phonePrefix = '+233',
  }) async {
    _busy = true;
    _registrationError = null;
    notifyListeners();
    try {
      await _api.requestRegistrationCode(
        account: account,
        useEmail: useEmail,
        phonePrefix: phonePrefix,
      );
      return true;
    } catch (error) {
      _registrationError = error.toString();
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> verifyRegistrationCode({
    required String account,
    required String code,
    required bool useEmail,
    String phonePrefix = '+233',
  }) async {
    _busy = true;
    _registrationError = null;
    notifyListeners();
    try {
      await _api.verifyRegistrationCode(
        account: account,
        code: code,
        useEmail: useEmail,
        phonePrefix: phonePrefix,
      );
      return true;
    } catch (error) {
      _registrationError = error.toString();
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> registerAccount({
    required String account,
    required String code,
    required String password,
    required bool useEmail,
    String phonePrefix = '+233',
    String promoteCode = '',
  }) async {
    _busy = true;
    _registrationError = null;
    notifyListeners();
    try {
      await _api.registerBuyer(
        account: account,
        code: code,
        password: password,
        useEmail: useEmail,
        phonePrefix: phonePrefix,
        promoteCode: promoteCode,
      );
      final loggedIn = await login(
        account: account,
        password: password,
        phonePrefix: phonePrefix,
      );
      if (!loggedIn) _registrationError = _loginError;
      return loggedIn;
    } catch (error) {
      _registrationError = error.toString();
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
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
      _loginOpen = false;
      _loginPasswordOnly = false;
      _history
        ..clear()
        ..add(_loginReturnRoute);
      _route = _loginReturnRoute;
      _tabIndex = _route.tabIndex ?? _tabIndex;
      _forward = false;
      if (_route == TospinoRoute.invite) {
        unawaited(loadInvite());
      } else if (_route == TospinoRoute.inviteRewards) {
        unawaited(loadInviteRewards());
      }
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
    _addresses = const [];
    _defaultAddress = null;
    _selectedAddress = null;
    _editingAddress = null;
    _inviteInfo = null;
    _inviteShare = null;
    _inviteFriends = const [];
    _inviteFriendsTotal = 0;
    _inviteFriendsPage = 0;
    _inviteFriendsPages = 0;
    _inviteRewardAmount = 0;
    _inviteRewardRecords = const [];
    _inviteRewardsTotal = 0;
    _inviteRewardsPage = 0;
    _inviteRewardsPages = 0;
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
