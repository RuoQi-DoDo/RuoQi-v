import 'package:flutter/material.dart';

import 'account_dialogs.dart';
import 'account_controller.dart';
import 'account_style.dart';
import 'account_widgets.dart';
import 'account_localizations.dart';
import '../../localization.dart';

class AccountLinksPage extends StatelessWidget {
  const AccountLinksPage({super.key, required this.controller});

  final AccountController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return ListView(
          key: const Key('platform-account-links-page'),
          padding: AccountStyle.pagePadding,
          children: [
            AccountPageHeader(
              title: '账号关联',
              subtitle: AppLocalizations.of(context).text(
                '已关联 ${controller.linkedAccountCount} 个第三方账号',
                '${controller.linkedAccountCount} third-party accounts linked',
              ),
            ),
            AccountCard(
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < controller.linkedAccounts.length;
                    index++
                  ) ...[
                    AccountListRow(
                      key: Key(
                        'platform-link-${controller.linkedAccounts[index].id}',
                      ),
                      icon: controller.linkedAccounts[index].icon,
                      title: controller.linkedAccounts[index].name,
                      subtitle: controller.linkedAccounts[index].bound
                          ? '已关联，可用于快速登录'
                          : '未关联',
                      trailing: controller.linkedAccounts[index].bound
                          ? OutlinedButton(
                              onPressed: () => _unbind(
                                context,
                                controller.linkedAccounts[index],
                              ),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                foregroundColor: scheme.error,
                                side: BorderSide(
                                  color: scheme.error.withValues(alpha: 0.28),
                                ),
                              ),
                              child: Text(localizeAccountLabel(context, '解绑')),
                            )
                          : FilledButton.tonal(
                              onPressed: () => _bind(
                                context,
                                controller.linkedAccounts[index],
                              ),
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(localizeAccountLabel(context, '绑定')),
                            ),
                    ),
                    if (index < controller.linkedAccounts.length - 1)
                      const AccountRowDivider(indent: 14),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            const AccountInfoBanner(
              message: '关联第三方账号后，可以使用对应账号快速登录。解绑前请确认已设置登录密码和至少一种安全验证方式。',
              icon: Icons.link_rounded,
            ),
          ],
        );
      },
    );
  }

  Future<void> _bind(BuildContext context, AccountLinkedAccount account) async {
    final confirmed = await showAccountConfirmDialog(
      context,
      title: AppLocalizations.of(
        context,
      ).text('绑定 ${account.name}', 'Link ${account.name}'),
      message: AppLocalizations.of(context).text(
        '授权后将把 ${account.name} 与当前平台账号关联，用于快速登录和账号识别。',
        'Authorize ${account.name} to link it to your account for quick sign-in.',
      ),
      confirmLabel: '确认授权',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    controller.setLinkedAccountBound(account.id, true);
    showAccountToast(
      context,
      AppLocalizations.of(
        context,
      ).text('${account.name} 绑定成功', '${account.name} linked'),
    );
  }

  Future<void> _unbind(
    BuildContext context,
    AccountLinkedAccount account,
  ) async {
    final confirmed = await showAccountConfirmDialog(
      context,
      title: AppLocalizations.of(
        context,
      ).text('解除 ${account.name} 绑定？', 'Unlink ${account.name}?'),
      message: '解绑后将无法继续使用该账号快速登录平台账号。',
      confirmLabel: '确认解绑',
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    controller.setLinkedAccountBound(account.id, false);
    showAccountToast(
      context,
      AppLocalizations.of(
        context,
      ).text('${account.name} 已解绑', '${account.name} unlinked'),
    );
  }
}
