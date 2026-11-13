import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
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
      child: address == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      size: 56,
                      color: TospinoColors.resolve(context, TospinoColors.hint),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      localizeMiniProgramLabel(
                        context,
                        'No default shipping address',
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: controller.openAddress,
                      child: Text(localizeMiniProgramLabel(context, '重试')),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: TospinoColors.resolve(
                      context,
                      TospinoColors.surface,
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (address.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: TospinoColors.resolve(
                                  context,
                                  TospinoColors.brandPale,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                localizeMiniProgramLabel(context, '默认地址'),
                                style: TextStyle(
                                  color: TospinoColors.solidBrand(context),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        address.phone,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 9),
                      Text(
                        address.completeAddress,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Address editing remains available in the official Tospino app.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}
