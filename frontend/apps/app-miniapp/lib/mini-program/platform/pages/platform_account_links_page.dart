import 'package:flutter/material.dart';

import '../platform_dialogs.dart';
import '../platform_models.dart';
import '../platform_style.dart';
import '../platform_widgets.dart';

class PlatformAccountLinksPage extends StatelessWidget {
  const PlatformAccountLinksPage({super.key, required this.controller});

  final PlatformAccountController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return ListView(
          key: const Key('platform-account-links-page'),
          padding: PlatformStyle.pagePadding,
          children: [
            PlatformPageHeader(
              title: '账号关联',
              subtitle: '已关联 ${controller.linkedAccountCount} 个第三方账号',
            ),
            PlatformCard(
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < controller.linkedAccounts.length;
                    index++
                  ) ...[
                    PlatformListRow(
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
                              child: const Text('解绑'),
                            )
                          : FilledButton.tonal(
                              onPressed: () => _bind(
                                context,
                                controller.linkedAccounts[index],
                              ),
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text('绑定'),
                            ),
                    ),
                    if (index < controller.linkedAccounts.length - 1)
                      const PlatformRowDivider(indent: 14),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            const PlatformInfoBanner(
              message: '关联第三方账号后，可以使用对应账号快速登录。解绑前请确认已设置登录密码和至少一种安全验证方式。',
              icon: Icons.link_rounded,
            ),
          ],
        );
      },
    );
  }

  Future<void> _bind(
    BuildContext context,
    PlatformLinkedAccount account,
  ) async {
    final confirmed = await showPlatformConfirmDialog(
      context,
      title: '绑定 ${account.name}',
      message: '授权后将把 ${account.name} 与当前平台账号关联，用于快速登录和账号识别。',
      confirmLabel: '确认授权',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    controller.setLinkedAccountBound(account.id, true);
    showPlatformToast(context, '${account.name} 绑定成功');
  }

  Future<void> _unbind(
    BuildContext context,
    PlatformLinkedAccount account,
  ) async {
    final confirmed = await showPlatformConfirmDialog(
      context,
      title: '解除 ${account.name} 绑定？',
      message: '解绑后将无法继续使用该账号快速登录平台账号。',
      confirmLabel: '确认解绑',
      destructive: true,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    controller.setLinkedAccountBound(account.id, false);
    showPlatformToast(context, '${account.name} 已解绑');
  }
}
