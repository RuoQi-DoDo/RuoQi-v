import 'package:flutter/material.dart';

import '../../localization.dart';

import 'account_controller.dart';
import 'account_style.dart';
import 'account_widgets.dart';
import 'account_links_page.dart';
import 'account_log_page.dart';
import 'device_management_page.dart';
import 'email_binding_page.dart';
import 'password_change_page.dart';
import 'phone_binding_page.dart';

class AccountSecurityContent extends StatelessWidget {
  const AccountSecurityContent({
    super.key,
    required this.controller,
    this.showAppBar = false,
  });

  final AccountController controller;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return ListView(
          key: const Key('platform-account-security-page'),
          padding: AccountStyle.pagePadding,
          children: [
            AccountInfoBanner(
              message: l10n.text(
                '当前为演示流程，修改仅保存在本次运行中，不会更新真实账号。',
                'Demo only: changes last for this session and do not update a real account.',
              ),
              icon: Icons.info_outline,
            ),
            const SizedBox(height: 16),
            AccountPageHeader(
              title: l10n.text('账号安全', 'Account security'),
              subtitle: l10n.text(
                '管理登录凭证、关联账号与安全记录',
                'Manage credentials, linked accounts and security history',
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 66,
                    height: 66,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: controller.securityScore / 100,
                          strokeWidth: 7,
                          backgroundColor: scheme.surface.withValues(
                            alpha: 0.6,
                          ),
                          color: scheme.primary,
                          strokeCap: StrokeCap.round,
                        ),
                        Center(
                          child: Text(
                            '${controller.securityScore}',
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.securityScore >= 85
                              ? l10n.text('账号保护良好', 'Your account is protected')
                              : l10n.text(
                                  '建议完善安全信息',
                                  'Complete your security information',
                                ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          l10n.text(
                            '安全手机、邮箱、密码和关联账号会共同保护你的账号。',
                            'Your phone, email, password and linked accounts help protect your account.',
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: 11.5,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AccountSectionTitle(title: l10n.text('登录凭证', 'Login credentials')),
            AccountCard(
              child: Column(
                children: [
                  AccountListRow(
                    key: const Key('platform-security-password'),
                    icon: Icons.password_rounded,
                    title: l10n.text('登录密码', 'Password'),
                    subtitle: controller.passwordSet
                        ? l10n.text('已设置，建议定期更新', 'Set; update regularly')
                        : l10n.text('尚未设置', 'Not set'),
                    trailing: AccountStatusTag(
                      label: l10n.text('安全', 'Secure'),
                      tone: AccountTagTone.brand,
                    ),
                    onTap: () => _push(
                      context,
                      AccountPasswordChangePage(controller: controller),
                    ),
                  ),
                  AccountRowDivider(),
                  AccountListRow(
                    key: const Key('platform-security-phone'),
                    icon: Icons.phone_iphone_rounded,
                    title: l10n.text('手机号', 'Phone number'),
                    subtitle: l10n.text(
                      '用于登录验证与重要操作确认',
                      'For sign-in verification and important actions',
                    ),
                    value: controller.phone ?? l10n.text('未绑定', 'Not linked'),
                    onTap: () => _push(
                      context,
                      AccountPhoneBindingPage(
                        controller: controller,
                        returnToAccount: showAppBar,
                        mode: controller.phone == null
                            ? AccountCredentialMode.bind
                            : AccountCredentialMode.change,
                      ),
                    ),
                  ),
                  AccountRowDivider(),
                  AccountListRow(
                    key: const Key('platform-security-email'),
                    icon: Icons.mark_email_read_outlined,
                    title: l10n.text('安全邮箱', 'Security email'),
                    subtitle: l10n.text(
                      '接收安全通知和验证码',
                      'Receive security alerts and verification codes',
                    ),
                    value: controller.email ?? l10n.text('未绑定', 'Not linked'),
                    onTap: () => _push(
                      context,
                      AccountEmailBindingPage(
                        controller: controller,
                        returnToAccount: showAppBar,
                        mode: controller.email == null
                            ? AccountCredentialMode.bind
                            : AccountCredentialMode.change,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AccountSectionTitle(title: l10n.text('账号关联', 'Linked accounts')),
            AccountCard(
              child: AccountListRow(
                key: const Key('platform-security-links'),
                icon: Icons.link_rounded,
                title: l10n.text('第三方账号', 'Third-party accounts'),
                subtitle: 'Apple、Facebook、Google',
                trailing: AccountStatusTag(
                  label: l10n.text(
                    '已关联 ${controller.linkedAccountCount} 个',
                    '${controller.linkedAccountCount} linked',
                  ),
                  tone: AccountTagTone.brand,
                ),
                onTap: () =>
                    _push(context, AccountLinksPage(controller: controller)),
              ),
            ),
            AccountSectionTitle(
              title: l10n.text('安全与记录', 'Security and history'),
            ),
            AccountCard(
              child: Column(
                children: [
                  AccountListRow(
                    key: const Key('platform-security-devices'),
                    icon: Icons.devices_other_rounded,
                    title: l10n.text('设备管理', 'Devices'),
                    subtitle: l10n.text(
                      '查看并下线其他在线设备',
                      'View and sign out other devices',
                    ),
                    value: l10n.text(
                      '${controller.devices.length} 台',
                      '${controller.devices.length} devices',
                    ),
                    onTap: () => _push(
                      context,
                      AccountDeviceManagementPage(controller: controller),
                    ),
                  ),
                  AccountRowDivider(),
                  AccountListRow(
                    key: const Key('platform-security-logs'),
                    icon: Icons.receipt_long_outlined,
                    title: l10n.text('账号日志', 'Account activity'),
                    subtitle: l10n.text(
                      '登录、修改与风险操作记录',
                      'Sign-ins, changes and sensitive actions',
                    ),
                    onTap: () =>
                        _push(context, AccountLogPage(controller: controller)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AccountInfoBanner(
              message: l10n.text(
                '如果发现非本人操作，请立即修改密码，并下线不认识的设备。',
                'If you see unfamiliar activity, change your password and sign out unknown devices.',
              ),
              icon: Icons.gpp_maybe_outlined,
            ),
          ],
        );
      },
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) =>
            showAppBar ? Scaffold(appBar: AppBar(), body: page) : page,
      ),
    );
  }
}
