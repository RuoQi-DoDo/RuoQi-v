import '../../../localization.dart';

import 'package:flutter/material.dart';

import '../platform_dialogs.dart';
import '../platform_models.dart';
import '../platform_style.dart';
import '../platform_widgets.dart';
import 'platform_account_links_page.dart';
import 'platform_account_security_page.dart';
import 'platform_device_management_page.dart';
import 'platform_profile_page.dart';

class PlatformAccountHomePage extends StatelessWidget {
  const PlatformAccountHomePage({super.key, required this.controller});

  final PlatformAccountController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return ListView(
          key: const Key('platform-account-home'),
          padding: PlatformStyle.pagePadding,
          children: [
            PlatformPageHeader(
              title: AppLocalizations.of(
                context,
              ).text('账号中心', 'Account center'),
              subtitle: AppLocalizations.of(context).text(
                '平台账号、安全设置与登录记录',
                'Account, security and sign-in activity',
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary,
                    Color.lerp(scheme.primary, Colors.black, 0.18)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.2),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      PlatformAvatar(
                        size: 58,
                        styleIndex: controller.avatarStyle,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    controller.nickname,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      height: 1.2,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).text('运营账号', 'Operations'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLocalizations.of(context).text(
                                '账号 ${controller.accountId}',
                                'Account ${controller.accountId}',
                              ),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: AppLocalizations.of(
                          context,
                        ).text('编辑个人资料', 'Edit profile'),
                        onPressed: () => _push(
                          context,
                          PlatformProfilePage(controller: controller),
                        ),
                        icon: const Icon(
                          Icons.edit_note_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      _Metric(
                        value: '${controller.securityScore}',
                        label: AppLocalizations.of(
                          context,
                        ).text('安全分', 'Security score'),
                      ),
                      _Metric(
                        value: '${controller.linkedAccountCount}',
                        label: AppLocalizations.of(
                          context,
                        ).text('已关联', 'Linked'),
                      ),
                      _Metric(
                        value: '${controller.devices.length}',
                        label: AppLocalizations.of(
                          context,
                        ).text('在线设备', 'Devices'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
              children: [
                _QuickAction(
                  icon: Icons.badge_outlined,
                  label: AppLocalizations.of(context).text('个人资料', 'Profile'),
                  onTap: () => _push(
                    context,
                    PlatformProfilePage(controller: controller),
                  ),
                ),
                _QuickAction(
                  icon: Icons.shield_outlined,
                  label: AppLocalizations.of(
                    context,
                  ).text('账号安全', 'Account security'),
                  onTap: () => _push(
                    context,
                    PlatformAccountSecurityPage(controller: controller),
                  ),
                ),
                _QuickAction(
                  icon: Icons.link_rounded,
                  label: AppLocalizations.of(
                    context,
                  ).text('账号关联', 'Linked accounts'),
                  onTap: () => _push(
                    context,
                    PlatformAccountLinksPage(controller: controller),
                  ),
                ),
                _QuickAction(
                  icon: Icons.devices_other_rounded,
                  label: AppLocalizations.of(context).text('设备管理', 'Devices'),
                  onTap: () => _push(
                    context,
                    PlatformDeviceManagementPage(controller: controller),
                  ),
                ),
              ],
            ),
            PlatformSectionTitle(
              title: AppLocalizations.of(
                context,
              ).text('安全概览', 'Security overview'),
            ),
            PlatformCard(
              child: Column(
                children: [
                  PlatformListRow(
                    icon: Icons.verified_user_outlined,
                    title: AppLocalizations.of(
                      context,
                    ).text('账号保护', 'Account protection'),
                    subtitle: controller.securityScore >= 85
                        ? AppLocalizations.of(context).text(
                            '关键安全信息已完善',
                            'Essential security information complete',
                          )
                        : AppLocalizations.of(context).text(
                            '建议继续完善安全信息',
                            'Complete your security information',
                          ),
                    trailing: PlatformStatusTag(
                      label: controller.securityScore >= 85
                          ? AppLocalizations.of(
                              context,
                            ).text('状态良好', 'Protected')
                          : AppLocalizations.of(
                              context,
                            ).text('待完善', 'Incomplete'),
                      tone: controller.securityScore >= 85
                          ? PlatformTagTone.brand
                          : PlatformTagTone.warning,
                    ),
                    onTap: () => _push(
                      context,
                      PlatformAccountSecurityPage(controller: controller),
                    ),
                  ),
                  const PlatformRowDivider(),
                  PlatformListRow(
                    icon: Icons.phone_iphone_rounded,
                    title: AppLocalizations.of(
                      context,
                    ).text('安全手机', 'Security phone'),
                    value:
                        controller.phone ??
                        AppLocalizations.of(context).text('未绑定', 'Not linked'),
                    onTap: () => _push(
                      context,
                      PlatformAccountSecurityPage(controller: controller),
                    ),
                  ),
                  const PlatformRowDivider(),
                  PlatformListRow(
                    icon: Icons.mark_email_read_outlined,
                    title: AppLocalizations.of(
                      context,
                    ).text('安全邮箱', 'Security email'),
                    value:
                        controller.email ??
                        AppLocalizations.of(context).text('未绑定', 'Not linked'),
                    onTap: () => _push(
                      context,
                      PlatformAccountSecurityPage(controller: controller),
                    ),
                  ),
                ],
              ),
            ),
            PlatformSectionTitle(
              title: AppLocalizations.of(
                context,
              ).text('最近动态', 'Recent activity'),
              action: AppLocalizations.of(context).text('全部记录', 'View all'),
              onAction: () => _push(
                context,
                PlatformAccountSecurityPage(controller: controller),
              ),
            ),
            PlatformCard(
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < controller.logs.length;
                    index++
                  ) ...[
                    if (index < 3)
                      PlatformListRow(
                        icon: controller.logs[index].icon,
                        title: controller.logs[index].action,
                        subtitle: controller.logs[index].description,
                        value: controller.logs[index].time,
                        onTap: () => _push(
                          context,
                          PlatformAccountSecurityPage(controller: controller),
                        ),
                      ),
                    if (index < 2) const PlatformRowDivider(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            TextButton.icon(
              onPressed: () async {
                final confirmed = await showPlatformConfirmDialog(
                  context,
                  title: AppLocalizations.of(
                    context,
                  ).text('退出平台账号？', 'Sign out of the platform account?'),
                  message: AppLocalizations.of(context).text(
                    '当前为模拟账号，退出后仍可再次进入账号中心。',
                    'This is a demo account. You can return to the account center after signing out.',
                  ),
                  confirmLabel: AppLocalizations.of(
                    context,
                  ).text('退出登录', 'Sign out'),
                  destructive: true,
                );
                if (confirmed && context.mounted) {
                  showPlatformToast(
                    context,
                    AppLocalizations.of(
                      context,
                    ).text('模拟账号已退出', 'Demo account signed out'),
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text(
                AppLocalizations.of(context).text('退出登录', 'Sign out'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: PlatformStyle.cardBackground(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: scheme.primary, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
