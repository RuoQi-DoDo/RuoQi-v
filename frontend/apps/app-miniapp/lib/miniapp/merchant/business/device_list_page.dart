import 'package:flutter/material.dart';

import '../../../pages/account/account.dart';
import '../../../pages/account/device_management_page.dart' as shared;
import '../../../pages/account/account_localizations.dart';
import '../../../pages/account/account_style.dart';

/// Merchant entry for the shared account settings.
class DeviceListPage extends StatelessWidget {
  const DeviceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountControllerBuilder(
      builder: (context, controller) => Scaffold(
        backgroundColor: AccountStyle.pageBackground(context),
        appBar: AppBar(title: Text(localizeAccountLabel(context, '设备管理'))),
        body: shared.AccountDeviceManagementPage(controller: controller),
      ),
    );
  }
}
