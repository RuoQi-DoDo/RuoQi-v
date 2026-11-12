import 'package:flutter/material.dart';

import '../../../pages/account/account.dart';
import '../../../pages/account/account_links_page.dart' as shared;
import '../../../pages/account/account_localizations.dart';
import '../../../pages/account/account_style.dart';

/// Merchant entry for the shared account settings.
class AccountLinksPage extends StatelessWidget {
  const AccountLinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountControllerBuilder(
      builder: (context, controller) => Scaffold(
        backgroundColor: AccountStyle.pageBackground(context),
        appBar: AppBar(title: Text(localizeAccountLabel(context, '账号关联'))),
        body: shared.AccountLinksPage(controller: controller),
      ),
    );
  }
}
