import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoAddressPage extends StatelessWidget {
  const TospinoAddressPage({super.key, required this.controller});

  final TospinoAppController controller;

  Future<void> _setDefault(BuildContext context, TospinoAddress address) async {
    try {
      await controller.setDefaultAddress(address);
      if (context.mounted) showTospinoToast(context, '默认地址已更新');
    } catch (error) {
      if (context.mounted) showTospinoToast(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final addresses = [...controller.addresses]
      ..sort((left, right) {
        if (left.isDefault == right.isDefault) return 0;
        return left.isDefault ? -1 : 1;
      });
    final selectedId = controller.defaultAddress?.id;
    return ColoredBox(
      key: const Key('tospino-address-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          Expanded(
            child: controller.loadingAddresses && addresses.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : controller.addressError != null && addresses.isEmpty
                ? _AddressError(
                    message: controller.addressError!,
                    onRetry: controller.loadAddresses,
                  )
                : addresses.isEmpty
                ? _EmptyAddress(onAdd: () => controller.openAddressEditor())
                : RefreshIndicator(
                    onRefresh: controller.loadAddresses,
                    child: ListView.separated(
                      key: const Key('tospino-address-list'),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
                      itemCount: addresses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return _AddressCard(
                          address: address,
                          selected: address.id == selectedId,
                          selectionMode: controller.addressSelectionMode,
                          onTap: controller.addressSelectionMode
                              ? () => controller.selectAddress(address)
                              : null,
                          onEdit: () => controller.openAddressEditor(address),
                          onSetDefault: address.isDefault
                              ? null
                              : () => _setDefault(context, address),
                        );
                      },
                    ),
                  ),
          ),
          Container(
            color: TospinoColors.resolve(context, TospinoColors.surface),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: SafeArea(
              top: false,
              child: TospinoGradientButton(
                key: const Key('tospino-address-add'),
                label: '添加收货地址',
                onPressed: controller.busy
                    ? null
                    : () => controller.openAddressEditor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onEdit,
    required this.onSetDefault,
  });

  final TospinoAddress address;
  final bool selected;
  final bool selectionMode;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback? onSetDefault;

  String _tagLabel(BuildContext context) {
    if (address.tagEditor.isNotEmpty) return address.tagEditor;
    return switch (address.tag) {
      '1' => localizeMiniProgramLabel(context, '家'),
      '2' => localizeMiniProgramLabel(context, '公司'),
      '3' => localizeMiniProgramLabel(context, '学校'),
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tag = _tagLabel(context);
    return Material(
      key: Key('tospino-address-${address.id}'),
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 14, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (address.isDefault) ...[
                    const TospinoTag(
                      label: '默认',
                      solid: true,
                      color: TospinoColors.saleStart,
                    ),
                    const SizedBox(width: 7),
                  ],
                  if (tag.isNotEmpty) ...[
                    TospinoTag(label: tag),
                    const SizedBox(width: 7),
                  ],
                  Expanded(
                    child: Text(
                      address.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TospinoText.body(context).copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      address.fullPhone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TospinoText.secondary(
                        context,
                      ).copyWith(fontSize: 14),
                    ),
                  ),
                  if (selectionMode)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: selected
                            ? TospinoColors.solidBrand(context)
                            : TospinoColors.resolve(
                                context,
                                TospinoColors.hint,
                              ),
                        size: 22,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                address.completeAddress,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TospinoText.body(
                  context,
                ).copyWith(fontSize: 15, height: 1.45),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  if (onSetDefault != null)
                    TextButton.icon(
                      key: Key('tospino-address-default-${address.id}'),
                      onPressed: onSetDefault,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 17),
                      label: Text(
                        localizeMiniProgramLabel(context, '设为默认'),
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    key: Key('tospino-address-edit-${address.id}'),
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: Text(
                      localizeMiniProgramLabel(context, '编辑地址'),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAddress extends StatelessWidget {
  const _EmptyAddress({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('tospino-address-empty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 54,
            color: TospinoColors.resolve(context, TospinoColors.hint),
          ),
          const SizedBox(height: 14),
          Text(
            localizeMiniProgramLabel(context, '还没有收货地址'),
            textAlign: TextAlign.center,
            style: TospinoText.body(context),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onAdd,
            child: Text(localizeMiniProgramLabel(context, '添加地址')),
          ),
        ],
      ),
    );
  }
}

class _AddressError extends StatelessWidget {
  const _AddressError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(localizeMiniProgramLabel(context, '重试')),
            ),
          ],
        ),
      ),
    );
  }
}
