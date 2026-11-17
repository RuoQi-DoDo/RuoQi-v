import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoLoginMethodPicker extends StatefulWidget {
  const TospinoLoginMethodPicker({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  State<TospinoLoginMethodPicker> createState() =>
      _TospinoLoginMethodPickerState();
}

class _TospinoLoginMethodPickerState extends State<TospinoLoginMethodPicker> {
  bool _registerMode = false;

  TospinoAppController get controller => widget.controller;

  void _switchMode(bool registerMode) {
    setState(() => _registerMode = registerMode);
  }

  Future<void> _showUnavailable(String label) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: TospinoColors.resolve(
          dialogContext,
          TospinoColors.surface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          localizeMiniProgramLabel(dialogContext, label),
          textAlign: TextAlign.center,
        ),
        content: Text(
          localizeMiniProgramLabel(
            dialogContext,
            '当前版本暂未接入该方式，请使用账号密码或手机号/邮箱注册。',
          ),
          textAlign: TextAlign.center,
          style: TospinoText.secondary(dialogContext),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizeMiniProgramLabel(dialogContext, '知道了')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginOptions = <_AuthMethodData>[
      _AuthMethodData(
        key: const Key('tospino-login-password-method'),
        icon: Icons.person_rounded,
        color: TospinoColors.solidBrand(context),
        title: '使用账号密码继续',
        subtitle: '使用手机号、邮箱和密码登录',
        onTap: controller.openPasswordLogin,
      ),
      _AuthMethodData(
        key: const Key('tospino-login-phone-method'),
        icon: Icons.phone_iphone_rounded,
        color: const Color(0xFFE84E83),
        title: '使用手机号码继续',
        subtitle: '通过短信验证码登录',
        onTap: () => _showUnavailable('手机验证码登录'),
      ),
      _AuthMethodData(
        key: const Key('tospino-login-email-method'),
        icon: Icons.mail_rounded,
        color: const Color(0xFFDE4C3F),
        title: '使用电子邮件继续',
        subtitle: '通过邮箱验证码登录',
        onTap: () => _showUnavailable('邮箱验证码登录'),
      ),
      _AuthMethodData(
        key: const Key('tospino-login-facebook-method'),
        icon: Icons.facebook_rounded,
        color: const Color(0xFF1877F2),
        title: '通过Facebook继续',
        subtitle: '使用 Facebook 账号登录',
        onTap: () => _showUnavailable('Facebook 登录'),
      ),
      _AuthMethodData(
        key: const Key('tospino-login-google-method'),
        icon: Icons.g_mobiledata_rounded,
        color: const Color(0xFF4285F4),
        title: '通过Google继续',
        subtitle: '使用 Google 账号登录',
        onTap: () => _showUnavailable('Google 登录'),
      ),
    ];
    final registerOptions = <_AuthMethodData>[
      _AuthMethodData(
        key: const Key('tospino-register-phone-method'),
        icon: Icons.phone_iphone_rounded,
        color: TospinoColors.solidBrand(context),
        title: '使用手机号注册',
        subtitle: '通过短信验证码创建账号',
        onTap: () => controller.openRegistration(useEmail: false),
      ),
      _AuthMethodData(
        key: const Key('tospino-register-email-method'),
        icon: Icons.mail_rounded,
        color: const Color(0xFF6C83D9),
        title: '使用邮箱注册',
        subtitle: '通过邮箱验证码创建账号',
        onTap: () => controller.openRegistration(useEmail: true),
      ),
      _AuthMethodData(
        key: const Key('tospino-register-facebook-method'),
        icon: Icons.facebook_rounded,
        color: const Color(0xFF1877F2),
        title: '通过Facebook注册',
        subtitle: '使用 Facebook 账号注册',
        onTap: () => _showUnavailable('Facebook 注册'),
      ),
      _AuthMethodData(
        key: const Key('tospino-register-google-method'),
        icon: Icons.g_mobiledata_rounded,
        color: const Color(0xFF4285F4),
        title: '通过Google注册',
        subtitle: '使用 Google 账号注册',
        onTap: () => _showUnavailable('Google 注册'),
      ),
    ];
    final options = _registerMode ? registerOptions : loginOptions;
    return ListView(
      key: const Key('tospino-auth-method-picker'),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Text(
          localizeMiniProgramLabel(
            context,
            _registerMode ? '注册 Tospino' : '登录 Tospino',
          ),
          textAlign: TextAlign.center,
          style: TospinoText.pageTitle(context).copyWith(fontSize: 25),
        ),
        const SizedBox(height: 20),
        for (var index = 0; index < options.length; index++) ...[
          _AuthMethodTile(data: options[index]),
          if (index != options.length - 1) const SizedBox(height: 9),
        ],
        const SizedBox(height: 16),
        Column(
          children: [
            Text(
              localizeMiniProgramLabel(
                context,
                _registerMode ? '已有账号？' : '没有账号？',
              ),
              style: TospinoText.secondary(context),
            ),
            const SizedBox(height: 4),
            InkWell(
              key: const Key('tospino-auth-mode-switch'),
              onTap: () => _switchMode(!_registerMode),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Text(
                  localizeMiniProgramLabel(
                    context,
                    _registerMode ? '登录' : '注册',
                  ),
                  style: TextStyle(
                    color: TospinoColors.solidBrand(context),
                    fontSize: 15,
                    fontWeight: TospinoText.strong,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthMethodData {
  const _AuthMethodData({
    required this.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Key key;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _AuthMethodTile extends StatelessWidget {
  const _AuthMethodTile({required this.data});

  final _AuthMethodData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: data.key,
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.color, size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeMiniProgramLabel(context, data.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TospinoText.bodyStrong(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      localizeMiniProgramLabel(context, data.subtitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TospinoText.meta(context),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: TospinoColors.resolve(context, TospinoColors.hint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
