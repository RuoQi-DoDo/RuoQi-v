import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_style.dart';

enum TospinoFulfillmentKind { fbt, fbmLocalCity, fbmCrossBorder, official }

enum TospinoTransportMode { air, sea, land }

/// Android maps transport mode 1 to air, 2 to sea, and every other non-empty
/// mode to land.
TospinoTransportMode? tospinoTransportModeFromCode(String code) {
  final value = code.trim();
  if (value.isEmpty) return null;
  return switch (value) {
    '1' => TospinoTransportMode.air,
    '2' => TospinoTransportMode.sea,
    _ => TospinoTransportMode.land,
  };
}

class TospinoFulfillmentInfo {
  const TospinoFulfillmentInfo({
    required this.kind,
    required this.sourceLabel,
    required this.transportMode,
    this.sourceAddress = '',
    this.transitLabel = '',
  });

  factory TospinoFulfillmentInfo.fromDetail(
    TospinoProductDetail detail, {
    TospinoAddress? destination,
  }) {
    final product = detail.product;
    final transportMode = tospinoTransportModeFromCode(
      product.transportModes.isEmpty ? '' : product.transportModes.first,
    );
    if (product.isFbt) {
      return const TospinoFulfillmentInfo(
        kind: TospinoFulfillmentKind.fbt,
        sourceLabel: 'Tospino 本地仓',
        transportMode: null,
      );
    }
    if (!product.isFbm) {
      return const TospinoFulfillmentInfo(
        kind: TospinoFulfillmentKind.official,
        sourceLabel: 'Tospino',
        transportMode: null,
      );
    }

    final sourceCountryCode = _firstNotEmpty([
      detail.storeDeliveryCountryCode,
      product.supplyCountryCode,
    ]);
    final sourceCountryName = _firstNotEmpty([
      detail.storeDeliveryCountryName,
      product.supplyCountryName,
    ]);
    final destinationCountryCode = _firstNotEmpty([
      destination?.countryCode ?? '',
      'GH',
    ]);
    final destinationCountryName = _firstNotEmpty([
      destination?.countryName ?? '',
      _countryNameFromCode(destinationCountryCode),
      'Ghana',
    ]);
    final crossBorder = _isDifferentCountry(
      sourceCode: sourceCountryCode,
      sourceName: sourceCountryName,
      destinationCode: destinationCountryCode,
      destinationName: destinationCountryName,
    );

    if (crossBorder) {
      return TospinoFulfillmentInfo(
        kind: TospinoFulfillmentKind.fbmCrossBorder,
        sourceLabel: _firstNotEmpty([
          sourceCountryName,
          sourceCountryCode,
          '卖家国家',
        ]),
        transitLabel: '本地中转仓',
        transportMode: transportMode,
      );
    }

    final storeAddress = detail.storeDeliveryAddress.trim();
    return TospinoFulfillmentInfo(
      kind: TospinoFulfillmentKind.fbmLocalCity,
      sourceLabel: _firstNotEmpty([
        _localCity(storeAddress),
        destination?.city ?? '',
        destinationCountryName,
        '本地卖家',
      ]),
      sourceAddress: storeAddress,
      transportMode: transportMode,
    );
  }

  final TospinoFulfillmentKind kind;
  final String sourceLabel;
  final TospinoTransportMode? transportMode;
  final String sourceAddress;
  final String transitLabel;
}

class TospinoFulfillmentCard extends StatelessWidget {
  const TospinoFulfillmentCard({
    super.key,
    required this.detail,
    this.destination,
  });

  final TospinoProductDetail detail;
  final TospinoAddress? destination;

  @override
  Widget build(BuildContext context) {
    final info = TospinoFulfillmentInfo.fromDetail(
      detail,
      destination: destination,
    );
    return TospinoSurface(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 17),
      border: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.brandPale,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _kindIcon(info.kind),
                  color: TospinoColors.solidBrand(context),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: _FulfillmentBadge(kind: info.kind)),
                        if (info.transportMode != null) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: _TransportBadge(mode: info.transportMode!),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localizeMiniProgramLabel(context, _kindTitle(info.kind)),
                      style: TospinoText.bodyStrong(
                        context,
                      ).copyWith(fontSize: 14.5),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      localizeMiniProgramLabel(
                        context,
                        _kindDescription(info.kind),
                      ),
                      style: TospinoText.meta(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _FulfillmentRoute(info: info),
          if (info.sourceAddress.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '${localizeMiniProgramLabel(context, '发货地址')} · '
              '${info.sourceAddress}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TospinoText.hint(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _FulfillmentBadge extends StatelessWidget {
  const _FulfillmentBadge({required this.kind});

  final TospinoFulfillmentKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('tospino-fulfillment-${kind.name}'),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.brandPale),
        borderRadius: BorderRadius.circular(TospinoMetrics.tagRadius),
      ),
      child: Text(
        localizeMiniProgramLabel(context, _kindBadge(kind)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: TospinoColors.solidBrand(context),
          fontSize: 10.5,
          fontWeight: TospinoText.strong,
          height: 1.2,
        ),
      ),
    );
  }
}

class _TransportBadge extends StatelessWidget {
  const _TransportBadge({required this.mode});

  final TospinoTransportMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('tospino-fulfillment-transport-${mode.name}'),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surfaceMuted),
        borderRadius: BorderRadius.circular(TospinoMetrics.tagRadius),
        border: Border.all(
          color: TospinoColors.resolve(context, TospinoColors.line),
        ),
      ),
      child: Text(
        localizeMiniProgramLabel(context, _transportLabel(mode)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TospinoText.meta(
          context,
        ).copyWith(fontSize: 10.5, fontWeight: TospinoText.emphasis),
      ),
    );
  }
}

class _FulfillmentRoute extends StatelessWidget {
  const _FulfillmentRoute({required this.info});

  final TospinoFulfillmentInfo info;

  @override
  Widget build(BuildContext context) {
    final sourceIcon = switch (info.kind) {
      TospinoFulfillmentKind.fbt => Icons.inventory_2_outlined,
      TospinoFulfillmentKind.fbmCrossBorder => Icons.public_rounded,
      _ => Icons.storefront_outlined,
    };
    final nodes = <Widget>[
      _FulfillmentNode(
        icon: sourceIcon,
        label: info.sourceLabel,
        key: const Key('tospino-fulfillment-source'),
      ),
    ];
    if (info.kind == TospinoFulfillmentKind.fbmCrossBorder) {
      nodes.add(
        _FulfillmentNode(
          icon: Icons.warehouse_outlined,
          label: info.transitLabel,
          key: const Key('tospino-fulfillment-transit'),
        ),
      );
    }
    nodes.add(
      _FulfillmentNode(
        icon: Icons.location_on_outlined,
        label: '收件人',
        key: const Key('tospino-fulfillment-destination'),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(context, TospinoColors.surface),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TospinoColors.resolve(context, TospinoColors.line),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < nodes.length; index++) ...[
            Expanded(child: nodes[index]),
            if (index < nodes.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: TospinoColors.resolve(context, TospinoColors.hint),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _FulfillmentNode extends StatelessWidget {
  const _FulfillmentNode({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: TospinoColors.resolve(context, TospinoColors.surface),
            shape: BoxShape.circle,
            border: Border.all(
              color: TospinoColors.resolve(context, TospinoColors.line),
            ),
          ),
          child: Icon(icon, color: TospinoColors.solidBrand(context), size: 16),
        ),
        const SizedBox(height: 5),
        Text(
          localizeMiniProgramLabel(context, label),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TospinoText.secondary(
            context,
          ).copyWith(fontSize: 11, height: 1.2),
        ),
      ],
    );
  }
}

IconData _kindIcon(TospinoFulfillmentKind kind) => switch (kind) {
  TospinoFulfillmentKind.fbt => Icons.verified_rounded,
  TospinoFulfillmentKind.fbmLocalCity => Icons.delivery_dining_outlined,
  TospinoFulfillmentKind.fbmCrossBorder => Icons.public_rounded,
  TospinoFulfillmentKind.official => Icons.local_shipping_outlined,
};

String _kindBadge(TospinoFulfillmentKind kind) => switch (kind) {
  TospinoFulfillmentKind.fbt => 'FBT',
  TospinoFulfillmentKind.fbmLocalCity => 'FBM 本土',
  TospinoFulfillmentKind.fbmCrossBorder => 'FBM 跨境',
  TospinoFulfillmentKind.official => '官方配送',
};

String _kindTitle(TospinoFulfillmentKind kind) => switch (kind) {
  TospinoFulfillmentKind.fbt => 'Tospino 官方履约',
  TospinoFulfillmentKind.fbmLocalCity => '本土城市配送',
  TospinoFulfillmentKind.fbmCrossBorder => '跨境国家配送',
  TospinoFulfillmentKind.official => '物流信息待确认',
};

String _kindDescription(TospinoFulfillmentKind kind) => switch (kind) {
  TospinoFulfillmentKind.fbt => '本地仓直发，Tospino 负责配送',
  TospinoFulfillmentKind.fbmLocalCity => '卖家从当地城市发货',
  TospinoFulfillmentKind.fbmCrossBorder => '经本地中转仓送达',
  TospinoFulfillmentKind.official => '预计 2-5 个工作日送达',
};

String _transportLabel(TospinoTransportMode mode) => switch (mode) {
  TospinoTransportMode.air => '空运',
  TospinoTransportMode.sea => '海运',
  TospinoTransportMode.land => '陆运',
};

String _firstNotEmpty(Iterable<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

String _localCity(String address) {
  final compact = address.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (compact.isEmpty || compact.length <= 30) return compact;
  final parts = compact
      .split(RegExp(r'[,|;\n]'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.length >= 3) return parts[parts.length - 2];
  if (parts.length == 2) return parts.first;
  return compact.substring(0, 30).trim();
}

String _countryNameFromCode(String code) {
  return switch (code.trim().toUpperCase()) {
    'GH' => 'Ghana',
    'CN' => 'China',
    'NG' => 'Nigeria',
    'KE' => 'Kenya',
    _ => code.trim(),
  };
}

bool _isDifferentCountry({
  required String sourceCode,
  required String sourceName,
  required String destinationCode,
  required String destinationName,
}) {
  final source = _normalizeCountry(
    sourceCode.isNotEmpty ? sourceCode : sourceName,
  );
  final destination = _normalizeCountry(
    destinationCode.isNotEmpty ? destinationCode : destinationName,
  );
  return source.isNotEmpty && destination.isNotEmpty && source != destination;
}

String _normalizeCountry(String value) {
  final normalized = value.trim().toUpperCase().replaceAll(
    RegExp(r'[^A-Z0-9]'),
    '',
  );
  return switch (normalized) {
    'GHANA' => 'GH',
    'CHINA' => 'CN',
    'NIGERIA' => 'NG',
    'KENYA' => 'KE',
    _ => normalized,
  };
}
