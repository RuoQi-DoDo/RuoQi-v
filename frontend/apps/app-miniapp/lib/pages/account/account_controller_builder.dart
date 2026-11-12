import 'package:flutter/material.dart';

import 'account_controller.dart';

/// Resolves the shared account, owning a local demo account when used alone.
class AccountControllerBuilder extends StatefulWidget {
  const AccountControllerBuilder({
    super.key,
    this.controller,
    required this.builder,
  });

  final AccountController? controller;
  final Widget Function(BuildContext context, AccountController controller)
  builder;

  @override
  State<AccountControllerBuilder> createState() =>
      _AccountControllerBuilderState();
}

class _AccountControllerBuilderState extends State<AccountControllerBuilder> {
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
    return AccountScope(
      controller: controller,
      child: Builder(builder: (context) => widget.builder(context, controller)),
    );
  }
}
