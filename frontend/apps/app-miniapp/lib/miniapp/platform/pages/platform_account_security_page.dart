import 'package:flutter/material.dart';

import '../platform_models.dart';
import '../platform_style.dart';
import '../platform_widgets.dart';
import 'platform_account_links_page.dart';
import 'platform_account_log_page.dart';
import 'platform_device_management_page.dart';
import 'platform_email_binding_page.dart';
import 'platform_password_change_page.dart';
import 'platform_phone_binding_page.dart';

class PlatformAccountSecurityPage extends StatelessWidget {
  const PlatformAccountSecurityPage({super.key, required this.controller});

  final PlatformAccountController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return ListView(
          key: const Key('platform-account-security-page'),
          padding: PlatformStyle.pagePadding,
          children: [
            const PlatformPageHeader(
              title: '账号安全',
              subtitle: '管理登录凭证、关联账号与安全记录',
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
                              ? '账号保护良好'
                              : '建议完善安全信息',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '安全手机、邮箱、密码和关联账号会共同保护你的平台账号。',
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
            const PlatformSectionTitle(title: '登录凭证'),
            PlatformCard(
              child: Column(
                children: [
                  PlatformListRow(
                    key: const Key('platform-security-password'),
                    icon: Icons.password_rounded,
                    title: '登录密码',
                    subtitle: controller.passwordSet ? '已设置，建议定期更新' : '尚未设置',
                    trailing: const PlatformStatusTag(
                      label: '安全',
                      tone: PlatformTagTone.brand,
                    ),
                    onTap: () => _push(
                      context,
                      PlatformPasswordChangePage(controller: controller),
                    ),
                  ),
                  const PlatformRowDivider(),
                  PlatformListRow(
                    key: const Key('platform-security-phone'),
                    icon: Icons.phone_iphone_rounded,
                    title: '手机号',
                    subtitle: '用于登录验证与重要操作确认',
                    value: controller.phone ?? '未绑定',
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
                    key: const Key('platform-security-email'),
                    icon: Icons.mark_email_read_outlined,
                    title: '安全邮箱',
                    subtitle: '接收安全通知和验证码',
                    value: controller.email ?? '未绑定',
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
            const PlatformSectionTitle(title: '账号关联'),
            PlatformCard(
              child: PlatformListRow(
                key: const Key('platform-security-links'),
                icon: Icons.link_rounded,
                title: '第三方账号',
                subtitle: 'Apple、Facebook、Google',
                trailing: PlatformStatusTag(
                  label: '已关联 ${controller.linkedAccountCount} 个',
                  tone: PlatformTagTone.brand,
                ),
                onTap: () => _push(
                  context,
                  PlatformAccountLinksPage(controller: controller),
                ),
              ),
            ),
            const PlatformSectionTitle(title: '安全与记录'),
            PlatformCard(
              child: Column(
                children: [
                  PlatformListRow(
                    key: const Key('platform-security-devices'),
                    icon: Icons.devices_other_rounded,
                    title: '设备管理',
                    subtitle: '查看并下线其他在线设备',
                    value: '${controller.devices.length} 台',
                    onTap: () => _push(
                      context,
                      PlatformDeviceManagementPage(controller: controller),
                    ),
                  ),
                  const PlatformRowDivider(),
                  PlatformListRow(
                    key: const Key('platform-security-logs'),
                    icon: Icons.receipt_long_outlined,
                    title: '账号日志',
                    subtitle: '登录、修改与风险操作记录',
                    onTap: () => _push(
                      context,
                      PlatformAccountLogPage(controller: controller),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const PlatformInfoBanner(
              message: '如果发现非本人操作，请立即修改密码，并下线不认识的设备。',
              icon: Icons.gpp_maybe_outlined,
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
