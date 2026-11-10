import 'package:flutter/material.dart';

import '../platform_dialogs.dart';
import '../platform_models.dart';
import '../platform_style.dart';
import '../platform_widgets.dart';
import 'platform_account_links_page.dart';
import 'platform_email_binding_page.dart';
import 'platform_phone_binding_page.dart';
import 'platform_profile_edit_page.dart';

class PlatformProfilePage extends StatelessWidget {
  const PlatformProfilePage({super.key, required this.controller});

  final PlatformAccountController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return ListView(
          key: const Key('platform-profile-page'),
          padding: PlatformStyle.pagePadding,
          children: [
            const PlatformPageHeader(title: '个人资料', subtitle: '头像、基础资料与账号绑定信息'),
            PlatformCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  PlatformAvatar(
                    size: 66,
                    styleIndex: controller.avatarStyle,
                    showBadge: true,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.nickname,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '账号 ${controller.accountId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 9),
                        const PlatformStatusTag(
                          label: '普通用户 · 已绑定',
                          tone: PlatformTagTone.brand,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const PlatformSectionTitle(title: '基础资料'),
            PlatformCard(
              child: Column(
                children: [
                  PlatformListRow(
                    icon: Icons.face_retouching_natural_outlined,
                    title: '头像',
                    value: '已设置',
                    onTap: () => _edit(context, PlatformProfileField.avatar),
                  ),
                  const PlatformRowDivider(),
                  PlatformListRow(
                    icon: Icons.badge_outlined,
                    title: '昵称',
                    value: controller.nickname,
                    onTap: () => _edit(context, PlatformProfileField.nickname),
                  ),
                  const PlatformRowDivider(),
                  PlatformListRow(
                    icon: Icons.people_alt_outlined,
                    title: '性别',
                    value: controller.gender,
                    onTap: () => _edit(context, PlatformProfileField.gender),
                  ),
                  const PlatformRowDivider(),
                  PlatformListRow(
                    icon: Icons.cake_outlined,
                    title: '年龄',
                    value: '${controller.age}',
                    onTap: () => _edit(context, PlatformProfileField.age),
                  ),
                  const PlatformRowDivider(),
                  PlatformListRow(
                    icon: Icons.account_circle_outlined,
                    title: '账号',
                    value: controller.accountId,
                  ),
                ],
              ),
            ),
            const PlatformSectionTitle(title: '第三方账号绑定'),
            PlatformCard(
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < controller.linkedAccounts.length;
                    index++
                  ) ...[
                    PlatformListRow(
                      icon: controller.linkedAccounts[index].icon,
                      title: controller.linkedAccounts[index].name,
                      subtitle: controller.linkedAccounts[index].bound
                          ? '已关联平台账号'
                          : '尚未关联',
                      trailing: PlatformStatusTag(
                        label: controller.linkedAccounts[index].bound
                            ? '已绑定'
                            : '未绑定',
                        tone: controller.linkedAccounts[index].bound
                            ? PlatformTagTone.brand
                            : PlatformTagTone.neutral,
                      ),
                      onTap: () => _push(
                        context,
                        PlatformAccountLinksPage(controller: controller),
                      ),
                    ),
                    if (index < controller.linkedAccounts.length - 1)
                      const PlatformRowDivider(),
                  ],
                ],
              ),
            ),
            const PlatformSectionTitle(title: '密保资料'),
            PlatformCard(
              child: Column(
                children: [
                  PlatformListRow(
                    icon: Icons.phone_iphone_rounded,
                    title: '手机号',
                    value: controller.phone ?? '去绑定',
                    onTap: () => _push(
                      context,
                      PlatformPhoneBindingPage(
                        controller: controller,
                        mode: controller.phone == null
                            ? PlatformCredentialMode.bind
                            : PlatformCredentialMode.change,
                      ),
                    ),
                  ),
                  const PlatformRowDivider(),
                  PlatformListRow(
                    icon: Icons.mark_email_read_outlined,
                    title: '邮箱',
                    value: controller.email ?? '去绑定',
                    onTap: () => _push(
                      context,
                      PlatformEmailBindingPage(
                        controller: controller,
                        mode: controller.email == null
                            ? PlatformCredentialMode.bind
                            : PlatformCredentialMode.change,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () async {
                final confirmed = await showPlatformConfirmDialog(
                  context,
                  title: '注销登录？',
                  message: '这只会退出当前模拟会话，不会删除账号资料。',
                  confirmLabel: '注销登录',
                  destructive: true,
                );
                if (confirmed && context.mounted) {
                  showPlatformToast(context, '已退出当前平台账号');
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    PlatformStyle.controlRadius,
                  ),
                ),
              ),
              child: const Text('注销登录'),
            ),
          ],
        );
      },
    );
  }

  void _edit(BuildContext context, PlatformProfileField field) {
    _push(
      context,
      PlatformProfileEditPage(controller: controller, field: field),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }
}
