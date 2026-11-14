import 'package:flutter/material.dart';

import 'account_dialogs.dart';
import 'account_controller.dart';
import 'account_style.dart';
import 'account_widgets.dart';
import 'account_localizations.dart';
import '../../localization.dart';
import '../common/page_theme.dart';

class AccountDeviceManagementPage extends StatelessWidget {
  const AccountDeviceManagementPage({super.key, required this.controller});

  final AccountController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ListView(
          key: const Key('platform-device-management-page'),
          padding: AccountStyle.pagePadding,
          children: [
            AccountPageHeader(
              title: '设备管理',
              subtitle: AppLocalizations.of(context).text(
                '当前有 ${controller.devices.length} 台设备保持登录',
                '${controller.devices.length} devices signed in',
              ),
            ),
            AccountCard(
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < controller.devices.length;
                    index++
                  ) ...[
                    _DeviceRow(
                      device: controller.devices[index],
                      onTap: () =>
                          _showDeviceDetail(context, controller.devices[index]),
                      onRemove: controller.devices[index].current
                          ? null
                          : () => _removeDevice(
                              context,
                              controller.devices[index],
                            ),
                    ),
                    if (index < controller.devices.length - 1)
                      const AccountRowDivider(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            const AccountInfoBanner(
              message: '下线设备后，该设备上的账号会被登出，再次登录时需要进行身份验证。当前设备无法从这里下线。',
              icon: Icons.devices_other_rounded,
            ),
          ],
        );
      },
    );
  }

  void _showDeviceDetail(BuildContext context, AccountDevice device) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: HostTypography.emphasis,
                  ),
                ),
                const SizedBox(height: 18),
                _DetailLine(label: '登录地点', value: device.location),
                _DetailLine(label: '最近活跃', value: device.lastActive),
                _DetailLine(
                  label: '设备状态',
                  value: device.current ? '当前设备' : '允许远程下线',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _removeDevice(BuildContext context, AccountDevice device) async {
    final confirmed = await showAccountConfirmDialog(
      context,
      title: AppLocalizations.of(
        context,
      ).text('下线 ${device.name}？', 'Sign out ${device.name}?'),
      message: '下线后，该设备再次登录时需要重新进行身份验证。',
      confirmLabel: '确认下线',
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    controller.removeDevice(device.id);
    showAccountToast(
      context,
      AppLocalizations.of(
        context,
      ).text('${device.name} 已下线', '${device.name} signed out'),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.device, required this.onTap, this.onRemove});

  final AccountDevice device;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AccountListRow(
      icon: device.icon,
      title: device.name,
      subtitle: '${device.location} · ${device.lastActive}',
      trailing: device.current
          ? const AccountStatusTag(label: '当前设备', tone: AccountTagTone.brand)
          : TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: scheme.error,
              ),
              child: Text(localizeAccountLabel(context, '下线')),
            ),
      onTap: onTap,
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              localizeAccountLabel(context, label),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              localizeAccountLabel(context, value),
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
