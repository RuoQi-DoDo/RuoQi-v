import 'package:flutter/material.dart';

class TospinoCategory {
  const TospinoCategory({
    required this.id,
    required this.label,
    this.iconUrl = '',
    this.children = const [],
    this.linkIds = const [],
  });

  final String id;
  final String label;
  final String iconUrl;
  final List<TospinoCategory> children;
  final List<String> linkIds;

  Iterable<TospinoCategory> get allDescendants sync* {
    for (final child in children) {
      yield child;
      yield* child.allDescendants;
    }
  }

  TospinoCategory get firstLeaf {
    if (children.isEmpty) return this;
    return children.first.firstLeaf;
  }
}

class TospinoProduct {
  const TospinoProduct({
    required this.id,
    required this.title,
    this.brand = '',
    this.categoryId = '',
    this.categoryName = '',
    required this.price,
    this.oldPrice = 0,
    this.sales = 0,
    this.rating = 0,
    this.imageUrl = '',
    this.shopId = '',
    this.shopName = '',
    this.stock = 0,
    this.deliveryType = 0,
    this.supplyCountryName = '',
    this.supplyCountryCode = '',
    this.transportModes = const [],
  });

  final String id;
  final String title;
  final String brand;
  final String categoryId;
  final String categoryName;
  final double price;
  final double oldPrice;
  final int sales;
  final double rating;
  final String imageUrl;
  final String shopId;
  final String shopName;
  final int stock;
  final int deliveryType;
  final String supplyCountryName;
  final String supplyCountryCode;
  final List<String> transportModes;

  bool get isFbt => deliveryType == 2;
  bool get isFbm => deliveryType == 1;

  int get discountPercent {
    if (oldPrice <= price || oldPrice <= 0) return 0;
    return ((1 - price / oldPrice) * 100).round().clamp(0, 99);
  }

  bool get available => stock > 0;
}

class TospinoProductDetail {
  const TospinoProductDetail({
    required this.product,
    required this.skuId,
    this.galleryUrls = const [],
    this.description = '',
    this.servicePromises = const [],
    this.storeName = '',
    this.isFavorite = false,
    this.storeDeliveryCountryName = '',
    this.storeDeliveryCountryCode = '',
    this.storeDeliveryAddress = '',
  });

  final TospinoProduct product;
  final String skuId;
  final List<String> galleryUrls;
  final String description;
  final List<String> servicePromises;
  final String storeName;
  final bool isFavorite;
  final String storeDeliveryCountryName;
  final String storeDeliveryCountryCode;
  final String storeDeliveryAddress;
}

class TospinoCartLine {
  const TospinoCartLine({
    required this.skuId,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.storeId,
    required this.storeName,
    this.imageUrl = '',
    this.attributes = const [],
    this.selected = true,
    this.valid = true,
    this.isOftenBuy = false,
  });

  final String skuId;
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String storeId;
  final String storeName;
  final String imageUrl;
  final List<String> attributes;
  final bool selected;
  final bool valid;
  final bool isOftenBuy;

  double get subtotal => price * quantity;

  TospinoCartLine copyWith({int? quantity, bool? selected, bool? isOftenBuy}) =>
      TospinoCartLine(
        skuId: skuId,
        productId: productId,
        title: title,
        price: price,
        quantity: quantity ?? this.quantity,
        storeId: storeId,
        storeName: storeName,
        imageUrl: imageUrl,
        attributes: attributes,
        selected: selected ?? this.selected,
        valid: valid,
        isOftenBuy: isOftenBuy ?? this.isOftenBuy,
      );
}

class TospinoCartCounts {
  const TospinoCartCounts({
    this.allTotal = 0,
    this.priceCutTotal = 0,
    this.oftenBuyTotal = 0,
  });

  final int allTotal;
  final int priceCutTotal;
  final int oftenBuyTotal;
}

enum TospinoOrderStatus {
  toPay('待付款', 'To pay', 0, Icons.account_balance_wallet_outlined),
  toShip('待发货', 'To ship', 2, Icons.inventory_2_outlined),
  toReceive('待收货', 'To receive', 4, Icons.local_shipping_outlined),
  toReview('待评价', 'To review', 5, Icons.rate_review_outlined);

  const TospinoOrderStatus(this.label, this.english, this.code, this.icon);

  final String label;
  final String english;
  final int code;
  final IconData icon;

  static TospinoOrderStatus? fromCode(String? code) {
    final parsed = int.tryParse(code ?? '');
    for (final status in values) {
      if (status.code == parsed) return status;
    }
    return null;
  }
}

class TospinoOrderItem {
  const TospinoOrderItem({
    required this.skuId,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    this.imageUrl = '',
  });

  final String skuId;
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String imageUrl;
}

class TospinoOrder {
  const TospinoOrder({
    required this.id,
    required this.orderSn,
    required this.statusCode,
    required this.statusLabel,
    required this.total,
    required this.createdAt,
    this.productAmount = 0,
    this.freight = 0,
    this.items = const [],
    this.receiverName = '',
    this.receiverPhone = '',
    this.receiverAddress = '',
  });

  final String id;
  final String orderSn;
  final String statusCode;
  final String statusLabel;
  final double total;
  final String createdAt;
  final double productAmount;
  final double freight;
  final List<TospinoOrderItem> items;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;

  TospinoOrderStatus? get status => TospinoOrderStatus.fromCode(statusCode);
}

class TospinoUser {
  const TospinoUser({
    required this.id,
    required this.displayName,
    this.phone = '',
    this.email = '',
    this.avatarUrl = '',
    this.balance = 0,
    this.favoriteCount = 0,
    this.couponCount = 0,
  });

  final String id;
  final String displayName;
  final String phone;
  final String email;
  final String avatarUrl;
  final double balance;
  final int favoriteCount;
  final int couponCount;

  String get account => phone.isNotEmpty ? phone : email;
}

class TospinoAddress {
  const TospinoAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.completeAddress,
    this.isDefault = false,
    this.countryCode = '',
    this.countryName = '',
    this.city = '',
    this.province = '',
  });

  final String id;
  final String name;
  final String phone;
  final String completeAddress;
  final bool isDefault;
  final String countryCode;
  final String countryName;
  final String city;
  final String province;
}

class TospinoHomeDecoration {
  const TospinoHomeDecoration({required this.pages});

  final List<TospinoHomePageDecoration> pages;
}

class TospinoHomePageDecoration {
  const TospinoHomePageDecoration({
    required this.id,
    required this.name,
    required this.templateId,
    this.components = const [],
    this.baseColor = '',
    this.backgroundImageUrl = '',
  });

  final String id;
  final String name;
  final String templateId;
  final List<TospinoHomeComponent> components;
  final String baseColor;
  final String backgroundImageUrl;

  bool get hasContent => components.any((component) => component.isVisible);

  TospinoHomeComponent? get recommendationComponent {
    for (final component in components) {
      if (component.type == TospinoHomeComponent.waterfall) return component;
    }
    return null;
  }

  TospinoHomePageDecoration copyWith({
    List<TospinoHomeComponent>? components,
    String? backgroundImageUrl,
  }) => TospinoHomePageDecoration(
    id: id,
    name: name,
    templateId: templateId,
    components: components ?? this.components,
    baseColor: baseColor,
    backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
  );
}

class TospinoHomeComponent {
  const TospinoHomeComponent({
    required this.type,
    this.name = '',
    this.title = '',
    this.showTitle = false,
    this.showImageName = false,
    this.showSales = false,
    this.showRating = false,
    this.imageUrl = '',
    this.videoCoverUrl = '',
    this.proportion = 0,
    this.baseColor = '',
    this.lowerGap = 0,
    this.leftGap = 0,
    this.rightGap = 0,
    this.height = 0,
    this.displayRows = 0,
    this.items = const [],
    this.goodsIds = const [],
  });

  static const base = 0;
  static const navBar = 1;
  static const secondLevelCategory = 2;
  static const banner = 3;
  static const diamondArea = 4;
  static const hotImage = 5;
  static const oneImage = 6;
  static const twoImages = 7;
  static const threeImages = 8;
  static const twoByTwoImages = 9;
  static const twoProducts = 11;
  static const threeProducts = 12;
  static const waterfall = 14;
  static const activityCountdown = 17;
  static const activityProducts = 18;
  static const activityWaterfall = 19;
  static const promotion = 21;
  static const video = 22;

  final int type;
  final String name;
  final String title;
  final bool showTitle;
  final bool showImageName;
  final bool showSales;
  final bool showRating;
  final String imageUrl;
  final String videoCoverUrl;
  final double proportion;
  final String baseColor;
  final double lowerGap;
  final double leftGap;
  final double rightGap;
  final double height;
  final int displayRows;
  final List<TospinoHomeComponentItem> items;
  final List<String> goodsIds;

  bool get isVisible =>
      type == waterfall ||
      (type != base &&
          type != navBar &&
          (items.isNotEmpty ||
              goodsIds.isNotEmpty ||
              imageUrl.isNotEmpty ||
              videoCoverUrl.isNotEmpty));
}

class TospinoHomeComponentItem {
  const TospinoHomeComponentItem({
    this.imageUrl = '',
    this.videoCoverUrl = '',
    this.title = '',
    this.linkType = '',
    this.linkAddress = '',
    this.goodsIds = const [],
    this.categoryIds = const [],
    this.positionTop = 0,
    this.positionLeft = 0,
    this.positionWidth = 0,
    this.positionHeight = 0,
  });

  final String imageUrl;
  final String videoCoverUrl;
  final String title;
  final String linkType;
  final String linkAddress;
  final List<String> goodsIds;
  final List<String> categoryIds;
  final double positionTop;
  final double positionLeft;
  final double positionWidth;
  final double positionHeight;

  String get displayImageUrl => imageUrl.isNotEmpty ? imageUrl : videoCoverUrl;
}

class TospinoFreeGift {
  const TospinoFreeGift({
    required this.id,
    required this.activityCode,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.storeName,
    required this.minPrice,
    required this.maxPrice,
    required this.receiveNum,
    required this.requiredHelpers,
    required this.durationHours,
  });

  final String id;
  final String activityCode;
  final String productId;
  final String productName;
  final String productImage;
  final String storeName;
  final double minPrice;
  final double maxPrice;
  final int receiveNum;
  final int requiredHelpers;
  final int durationHours;
}

class TospinoSaleInfo {
  const TospinoSaleInfo({
    required this.totalProductAmount,
    required this.totalFreight,
    required this.totalDiscount,
    required this.payable,
    required this.orderToken,
    required this.isCashDelivery,
    required this.raw,
  });

  final double totalProductAmount;
  final double totalFreight;
  final double totalDiscount;
  final double payable;
  final String orderToken;
  final bool isCashDelivery;
  final Map<String, dynamic> raw;
}

class TospinoApiException implements Exception {
  const TospinoApiException(this.message, {this.code, this.statusCode});

  final String message;
  final int? code;
  final int? statusCode;

  bool get needsLogin => statusCode == 401 || code == 401 || code == 10401;

  @override
  String toString() => message;
}
