import 'package:flutter/material.dart';

import '../platform_dialogs.dart';
import '../platform_models.dart';
import '../platform_style.dart';
import '../platform_widgets.dart';

class PlatformDeviceManagementPage extends StatelessWidget {
  const PlatformDeviceManagementPage({super.key, required this.controller});

  final PlatformAccountController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ListView(
          key: const Key('platform-device-management-page'),
          padding: PlatformStyle.pagePadding,
          children: [
            PlatformPageHeader(
              title: '设备管理',
              subtitle: '当前有 ${controller.devices.length} 台设备保持登录',
            ),
            PlatformCard(
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
                      const PlatformRowDivider(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            const PlatformInfoBanner(
              message: '下线设备后，该设备上的账号会被登出，再次登录时需要进行身份验证。当前设备无法从这里下线。',
              icon: Icons.devices_other_rounded,
            ),
          ],
        );
      },
    );
  }

  void _showDeviceDetail(BuildContext context, PlatformDevice device) {
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
                    fontWeight: FontWeight.w800,
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

  Future<void> _removeDevice(
    BuildContext context,
    PlatformDevice device,
  ) async {
    final confirmed = await showPlatformConfirmDialog(
      context,
      title: '下线 ${device.name}？',
      message: '下线后，该设备再次登录时需要重新进行身份验证。',
      confirmLabel: '确认下线',
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    controller.removeDevice(device.id);
    showPlatformToast(context, '${device.name} 已下线');
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.device, required this.onTap, this.onRemove});

  final PlatformDevice device;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PlatformListRow(
      icon: device.icon,
      title: device.name,
      subtitle: '${device.location} · ${device.lastActive}',
      trailing: device.current
          ? const PlatformStatusTag(label: '当前设备', tone: PlatformTagTone.brand)
          : TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: scheme.error,
              ),
              child: const Text('下线'),
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
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
