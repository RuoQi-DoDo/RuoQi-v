import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_models.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoAddressPage extends StatelessWidget {
  const TospinoAddressPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  Widget build(BuildContext context) {
    final address = controller.defaultAddress;
    return ColoredBox(
      key: const Key('tospino-address-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: Column(
        children: [
          Expanded(
            child: address == null
                ? _EmptyAddress(onAdd: controller.openAddress)
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                        child: TospinoSurface(
                          radius: 16,
                          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const TospinoTag(
                                    label: '默认',
                                    solid: true,
                                    color: TospinoColors.saleStart,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      address.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TospinoText.body(
                                        context,
                                      ).copyWith(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      address.phone,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TospinoText.secondary(
                                        context,
                                      ).copyWith(fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    key: const Key('tospino-address-edit'),
                                    tooltip: localizeMiniProgramLabel(
                                      context,
                                      '编辑地址',
                                    ),
                                    onPressed: () => _showAddressEditor(
                                      context,
                                      controller,
                                      address: address,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: TospinoColors.resolve(
                                        context,
                                        TospinoColors.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                address.completeAddress,
                                style: TospinoText.body(
                                  context,
                                ).copyWith(fontSize: 16, height: 1.45),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: TospinoColors.solidBrand(context),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    localizeMiniProgramLabel(context, '默认'),
                                    style: TextStyle(
                                      color: TospinoColors.resolve(
                                        context,
                                        TospinoColors.price,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                onPressed: () => _showAddressEditor(context, controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showAddressEditor(
  BuildContext context,
  TospinoAppController controller, {
  TospinoAddress? address,
}) async {
  final name = TextEditingController(text: address?.name ?? '');
  final phone = TextEditingController(text: address?.phone ?? '');
  final details = TextEditingController(text: address?.completeAddress ?? '');
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: TospinoColors.resolve(context, TospinoColors.surface),
      title: Text(
        localizeMiniProgramLabel(context, address == null ? '添加收货地址' : '编辑地址'),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('tospino-address-name-field'),
              controller: name,
              decoration: InputDecoration(
                labelText: localizeMiniProgramLabel(context, '收货人'),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('tospino-address-phone-field'),
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: localizeMiniProgramLabel(context, '手机号码'),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('tospino-address-detail-field'),
              controller: details,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: localizeMiniProgramLabel(context, '详细地址'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(localizeMiniProgramLabel(context, '取消')),
        ),
        TextButton(
          onPressed: () {
            if (name.text.trim().isEmpty ||
                phone.text.trim().isEmpty ||
                details.text.trim().isEmpty) {
              return;
            }
            Navigator.of(context).pop(true);
          },
          child: Text(localizeMiniProgramLabel(context, '保存地址')),
        ),
      ],
    ),
  );
  if (saved == true) {
    controller.saveLocalAddress(
      name: name.text.trim(),
      phone: phone.text.trim(),
      completeAddress: details.text.trim(),
    );
    if (context.mounted) showTospinoToast(context, '地址已保存');
  }
  name.dispose();
  phone.dispose();
  details.dispose();
}

class _EmptyAddress extends StatelessWidget {
  const _EmptyAddress({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
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
            localizeMiniProgramLabel(context, 'No default shipping address'),
            textAlign: TextAlign.center,
            style: TospinoText.body(context),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onAdd,
            child: Text(localizeMiniProgramLabel(context, '重试')),
          ),
        ],
      ),
    );
  }
}
