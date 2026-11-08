import 'package:common/common.dart';
import 'package:flutter/material.dart';

import '../console_content_theme.dart';
import 'in_warehouse_module/in_warehouse_operation_page/index.dart';
import 'inbound_module/inbound_operation_page/index.dart';
import 'outbound_module/outbound_operation_page/index.dart';
import 'rule_module/rule_settings_page/index.dart';

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

enum _WmsConsoleSection {
  rules('规则设置', Icons.tune),
  outbound('出库作业', Icons.local_shipping_outlined),
  inbound('入库作业', Icons.input),
  inWarehouse('仓内作业', Icons.inventory_2_outlined);

  const _WmsConsoleSection(this.label, this.icon);

  final String label;
  final IconData icon;

  String get id => switch (this) {
    _WmsConsoleSection.rules => 'rules',
    _WmsConsoleSection.outbound => 'outbound',
    _WmsConsoleSection.inbound => 'inbound',
    _WmsConsoleSection.inWarehouse => 'in-warehouse',
  };
}

class _WmsConsoleDialog extends StatefulWidget {
  const _WmsConsoleDialog();

  @override
  State<_WmsConsoleDialog> createState() => _WmsConsoleDialogState();
}

class _WmsConsoleDialogState extends State<_WmsConsoleDialog> {
  _WmsConsoleSection _selectedSection = _WmsConsoleSection.rules;

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
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WmsMainSidebar(
                  selectedSection: _selectedSection,
                  onSelected: (section) {
                    setState(() => _selectedSection = section);
                  },
                ),
                Expanded(
                  child: Stack(
                    children: [
                      for (final section in _WmsConsoleSection.values)
                        Positioned.fill(
                          child: Offstage(
                            offstage: section != _selectedSection,
                            child: TickerMode(
                              enabled: section == _selectedSection,
                              child: _buildPage(section),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_WmsConsoleSection section) {
    return switch (section) {
      _WmsConsoleSection.rules => const WmsRuleSettingsPage(),
      _WmsConsoleSection.outbound => const ConsoleContentTheme(
        child: WmsOutboundOperationPage(),
      ),
      _WmsConsoleSection.inbound => const ConsoleContentTheme(
        child: WmsInboundOperationPage(),
      ),
      _WmsConsoleSection.inWarehouse => const ConsoleContentTheme(
        child: WmsInWarehouseOperationPage(),
      ),
    };
  }
}

class _WmsMainSidebar extends StatelessWidget {
  const _WmsMainSidebar({
    required this.selectedSection,
    required this.onSelected,
  });

  static const double width = 160;

  final _WmsConsoleSection selectedSection;
  final ValueChanged<_WmsConsoleSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('wms-main-sidebar'),
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: RuQiSpacing.xs),
        children: [
          for (final section in _WmsConsoleSection.values)
            InkWell(
              key: ValueKey('wms-main-menu-${section.id}'),
              onTap: () => onSelected(section),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: RuQiSpacing.sm),
                color: section == selectedSection
                    ? theme.colorScheme.primaryContainer
                    : Colors.transparent,
                child: Row(
                  children: [
                    Icon(
                      section.icon,
                      size: 18,
                      color: section == selectedSection
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: RuQiSpacing.xs),
                    Expanded(
                      child: Text(
                        section.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: section == selectedSection
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight: section == selectedSection
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
