import 'package:flutter/material.dart';

import 'account_controller.dart';
import 'account_style.dart';
import 'account_widgets.dart';
import 'account_localizations.dart';
import '../../localization.dart';
import '../common/page_theme.dart';
import 'password_change_page.dart';

class AccountLogPage extends StatelessWidget {
  const AccountLogPage({
    super.key,
    required this.controller,
    this.showAppBar = false,
  });

  final AccountController controller;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ListView(
          key: const Key('platform-account-log-page'),
          padding: AccountStyle.pagePadding,
          children: [
            AccountPageHeader(
              title: '账号日志',
              subtitle: AppLocalizations.of(context).text(
                '最近 ${controller.logs.length} 条登录与安全操作记录',
                '${controller.logs.length} recent sign-ins and security events',
              ),
            ),
            AccountCard(
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < controller.logs.length;
                    index++
                  ) ...[
                    AccountListRow(
                      key: Key('platform-log-${controller.logs[index].id}'),
                      icon: controller.logs[index].icon,
                      title: controller.logs[index].action,
                      subtitle: controller.logs[index].description,
                      value: controller.logs[index].time,
                      trailing: controller.logs[index].risk
                          ? const AccountStatusTag(
                              label: '需关注',
                              tone: AccountTagTone.warning,
                            )
                          : null,
                      onTap: () =>
                          _showLogDetail(context, controller.logs[index]),
                    ),
                    if (index < controller.logs.length - 1)
                      const AccountRowDivider(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            const AccountInfoBanner(
              message: '如发现非本人操作，请立即修改登录密码，并在设备管理中下线不认识的设备。',
              icon: Icons.gpp_maybe_outlined,
            ),
          ],
        );
      },
    );
  }

  void _showLogDetail(BuildContext context, AccountLogEntry entry) {
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
                    AccountStatusTag(
                      label: entry.risk ? '需关注' : '正常',
                      tone: entry.risk
                          ? AccountTagTone.warning
                          : AccountTagTone.brand,
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
                      color: scheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(
                        AccountStyle.controlRadius,
                      ),
                    ),
                    child: Text(
                      localizeAccountLabel(context, '如非本人操作，建议立即修改密码并检查登录设备。'),
                      style: TextStyle(
                        color: scheme.onTertiaryContainer,
                        fontSize: 11.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AccountPrimaryButton(
                    label: '立即修改密码',
                    icon: Icons.lock_reset_rounded,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => showAppBar
                              ? Scaffold(
                                  backgroundColor:
                                      HostChromeStyle.appBarBackground(context),
                                  appBar: AppBar(
                                    backgroundColor:
                                        HostChromeStyle.appBarBackground(
                                          context,
                                        ),
                                    surfaceTintColor: Colors.transparent,
                                    shape: Border(
                                      bottom: HostChromeStyle.appBarDivider(
                                        context,
                                      ),
                                    ),
                                  ),
                                  body: AccountPasswordChangePage(
                                    controller: controller,
                                  ),
                                )
                              : AccountPasswordChangePage(
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
