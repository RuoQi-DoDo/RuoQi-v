import 'package:common/common.dart';
import 'package:flutter/material.dart';

import 'wms_rule_settings_page.dart';

/// WMS管理入口：全屏控制台弹窗，关闭后回到平台工作台。
class WmsConsoleDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (_) => const _WmsConsoleDialog(),
    );
  }
}

class _WmsConsoleDialog extends StatelessWidget {
  const _WmsConsoleDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          ConsoleTopBar(
            title: 'WMS管理',
            onExit: () => Navigator.of(context).pop(),
          ),
          const Expanded(child: WmsRuleSettingsPage()),
        ],
      ),
    );
  }
}
