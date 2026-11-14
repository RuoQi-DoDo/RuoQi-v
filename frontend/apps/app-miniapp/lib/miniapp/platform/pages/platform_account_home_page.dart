import 'package:flutter/material.dart';

import '../l10n/platform_localizations.dart';
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
              title: platformText(context, '账号中心'),
              subtitle: platformText(context, '平台账号、安全设置与登录记录'),
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
                                    platformText(context, '运营账号'),
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
                              platformAccountLabel(
                                context,
                                controller.accountId,
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
                        tooltip: platformText(context, '编辑个人资料'),
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
                        label: platformText(context, '安全分'),
                      ),
                      _Metric(
                        value: '${controller.linkedAccountCount}',
                        label: platformText(context, '已关联'),
                      ),
                      _Metric(
                        value: '${controller.devices.length}',
                        label: platformText(context, '在线设备'),
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
                  label: platformText(context, '个人资料'),
                  onTap: () => _push(
                    context,
                    PlatformProfilePage(controller: controller),
                  ),
                ),
                _QuickAction(
                  icon: Icons.shield_outlined,
                  label: platformText(context, '账号安全'),
                  onTap: () => _push(
                    context,
                    PlatformAccountSecurityPage(controller: controller),
                  ),
                ),
                _QuickAction(
                  icon: Icons.link_rounded,
                  label: platformText(context, '账号关联'),
                  onTap: () => _push(
                    context,
                    PlatformAccountLinksPage(controller: controller),
                  ),
                ),
                _QuickAction(
                  icon: Icons.devices_other_rounded,
                  label: platformText(context, '设备管理'),
                  onTap: () => _push(
                    context,
                    PlatformDeviceManagementPage(controller: controller),
                  ),
                ),
              ],
            ),
            PlatformSectionTitle(title: platformText(context, '安全概览')),
            PlatformCard(
              child: Column(
                children: [
                  PlatformListRow(
                    icon: Icons.verified_user_outlined,
                    title: platformText(context, '账号保护'),
                    subtitle: controller.securityScore >= 85
                        ? platformText(context, '关键安全信息已完善')
                        : platformText(context, '建议继续完善安全信息'),
                    trailing: PlatformStatusTag(
                      label: controller.securityScore >= 85
                          ? platformText(context, '状态良好')
                          : platformText(context, '待完善'),
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
                    title: platformText(context, '安全手机'),
                    value: controller.phone ?? platformText(context, '未绑定'),
                    onTap: () => _push(
                      context,
                      PlatformAccountSecurityPage(controller: controller),
                    ),
                  ),
                  const PlatformRowDivider(),
                  PlatformListRow(
                    icon: Icons.mark_email_read_outlined,
                    title: platformText(context, '安全邮箱'),
                    value: controller.email ?? platformText(context, '未绑定'),
                    onTap: () => _push(
                      context,
                      PlatformAccountSecurityPage(controller: controller),
                    ),
                  ),
                ],
              ),
            ),
            PlatformSectionTitle(
              title: platformText(context, '最近动态'),
              action: platformText(context, '全部记录'),
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
                  title: platformText(context, '退出平台账号？'),
                  message: platformText(context, '当前为模拟账号，退出后仍可再次进入账号中心。'),
                  confirmLabel: platformText(context, '退出登录'),
                  destructive: true,
                );
                if (confirmed && context.mounted) {
                  showPlatformToast(context, platformText(context, '模拟账号已退出'));
                }
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text(platformText(context, '退出登录')),
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
