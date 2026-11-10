import 'package:flutter/material.dart';

import '../platform_models.dart';
import '../platform_style.dart';
import '../platform_widgets.dart';
import 'platform_password_change_page.dart';

class PlatformAccountLogPage extends StatelessWidget {
  const PlatformAccountLogPage({super.key, required this.controller});

  final PlatformAccountController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ListView(
          key: const Key('platform-account-log-page'),
          padding: PlatformStyle.pagePadding,
          children: [
            PlatformPageHeader(
              title: '账号日志',
              subtitle: '最近 ${controller.logs.length} 条登录与安全操作记录',
            ),
            PlatformCard(
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < controller.logs.length;
                    index++
                  ) ...[
                    PlatformListRow(
                      key: Key('platform-log-${controller.logs[index].id}'),
                      icon: controller.logs[index].icon,
                      title: controller.logs[index].action,
                      subtitle: controller.logs[index].description,
                      value: controller.logs[index].time,
                      trailing: controller.logs[index].risk
                          ? const PlatformStatusTag(
                              label: '需关注',
                              tone: PlatformTagTone.warning,
                            )
                          : null,
                      onTap: () =>
                          _showLogDetail(context, controller.logs[index]),
                    ),
                    if (index < controller.logs.length - 1)
                      const PlatformRowDivider(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            const PlatformInfoBanner(
              message: '如发现非本人操作，请立即修改登录密码，并在设备管理中下线不认识的设备。',
              icon: Icons.gpp_maybe_outlined,
            ),
          ],
        );
      },
    );
  }

  void _showLogDetail(BuildContext context, PlatformLogEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final scheme = theme.colorScheme;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(entry.icon, color: scheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.action,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    PlatformStatusTag(
                      label: entry.risk ? '需关注' : '正常',
                      tone: entry.risk
                          ? PlatformTagTone.warning
                          : PlatformTagTone.brand,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _LogLine(label: '操作说明', value: entry.description),
                _LogLine(label: '操作时间', value: entry.time),
                _LogLine(label: '登录设备', value: entry.device),
                _LogLine(label: '操作地点', value: entry.location),
                if (entry.risk) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1DC),
                      borderRadius: BorderRadius.circular(
                        PlatformStyle.controlRadius,
                      ),
                    ),
                    child: const Text(
                      '如非本人操作，建议立即修改密码并检查登录设备。',
                      style: TextStyle(
                        color: Color(0xFF8A5200),
                        fontSize: 11.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PlatformPrimaryButton(
                    label: '立即修改密码',
                    icon: Icons.lock_reset_rounded,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => PlatformPasswordChangePage(
                            controller: controller,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LogLine extends StatelessWidget {
  const _LogLine({required this.label, required this.value});

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
