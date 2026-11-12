import 'package:flutter/material.dart';

import '../../localization.dart';
import 'account_controller.dart';
import 'account_security_content.dart';
import 'account_style.dart';

/// Common account security page for the host and business mini-programs.
class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key, this.controller});

  final AccountController? controller;

  static Route<void> route({AccountController? controller}) =>
      MaterialPageRoute<void>(
        builder: (_) => AccountSecurityPage(controller: controller),
      );

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  AccountController? _ownedController;

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        widget.controller ??
        AccountScope.maybeOf(context) ??
        (_ownedController ??= AccountController());
    return Scaffold(
      key: const Key('account-security-page'),
      backgroundColor: AccountStyle.pageBackground(context),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).text('账号安全', 'Account security'),
        ),
      ),
      body: AccountSecurityContent(controller: controller, showAppBar: true),
    );
  }
}
