import 'package:flutter/material.dart';

import '../../../pages/account/account.dart';
import '../../../pages/account/account_log_page.dart' as shared;
import '../../../pages/account/account_localizations.dart';
import '../../../pages/account/account_style.dart';

/// Merchant entry for the shared account settings.
class AccountLogPage extends StatelessWidget {
  const AccountLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountControllerBuilder(
      builder: (context, controller) => Scaffold(
        backgroundColor: AccountStyle.pageBackground(context),
        appBar: AppBar(title: Text(localizeAccountLabel(context, '账号日志'))),
        body: shared.AccountLogPage(controller: controller, showAppBar: true),
      ),
    );
  }
}
