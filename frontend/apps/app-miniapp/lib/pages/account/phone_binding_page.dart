import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'account_dialogs.dart';
import 'account_controller.dart';
import 'account_style.dart';
import 'account_widgets.dart';
import 'account_localizations.dart';
import '../../localization.dart';

class AccountPhoneBindingPage extends StatefulWidget {
  const AccountPhoneBindingPage({
    super.key,
    required this.controller,
    required this.mode,
    this.returnToAccount = false,
  });

  final AccountController controller;
  final AccountCredentialMode mode;
  final bool returnToAccount;

  @override
  State<AccountPhoneBindingPage> createState() =>
      _AccountPhoneBindingPageState();
}

class _AccountPhoneBindingPageState extends State<AccountPhoneBindingPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  int _step = 0;
  bool _codeSent = false;
  bool _verifyWithEmail = false;

  bool get _isChange => widget.mode == AccountCredentialMode.change;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: AccountStyle.pageBackground(context),
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('platform-phone-binding-page'),
          padding: AccountStyle.pagePadding,
          children: [
            AccountPageHeader(
              title: _isChange ? '修改手机号' : '绑定手机号',
              subtitle: _step == 2 ? '安全手机已更新' : '完成身份验证后更新账号安全手机',
            ),
            if (_step == 0) ..._buildPhoneEntry(context),
            if (_step == 1) ..._buildVerification(context),
            if (_step == 2) ..._buildSuccess(context),
            const SizedBox(height: 24),
            AccountInfoBanner(
              message: _step == 2
                  ? '新的安全手机将用于登录验证和重要操作确认。'
                  : '为保障账号安全，变更重要信息需要完成身份验证。当前为小程序模拟流程。',
              icon: _step == 2
                  ? Icons.verified_user_outlined
                  : Icons.security_rounded,
            ),
            if (_step == 2) ...[
              const SizedBox(height: 22),
              AccountPrimaryButton(
                key: const Key('platform-phone-success-done'),
                label: '完成',
                icon: Icons.check_rounded,
                onPressed: () {
                  if (widget.returnToAccount) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),
            ],
            if (_step > 0)
              TextButton(
                onPressed: () => setState(() => _step--),
                child: Text(localizeAccountLabel(context, '返回上一步')),
              ),
            if (_isChange && _step < 2)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  localizeAccountLabel(context, '暂不修改'),
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPhoneEntry(BuildContext context) {
    final theme = Theme.of(context);
    return [
      if (_isChange && widget.controller.phone != null) ...[
        AccountCard(
          child: AccountListRow(
            icon: Icons.phone_iphone_rounded,
            title: '当前安全手机',
            value: widget.controller.phone,
          ),
        ),
        const SizedBox(height: 18),
      ],
      AccountTextField(
        key: const Key('platform-phone-input'),
        controller: _phoneController,
        label: '新手机号',
        hint: '请输入 11 位手机号码',
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ],
      ),
      const SizedBox(height: 18),
      Text(
        localizeAccountLabel(context, '该号码将接收短信验证码，请确认可以正常使用。'),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 22),
      AccountPrimaryButton(
        key: const Key('platform-phone-next'),
        label: '下一步',
        icon: Icons.arrow_forward_rounded,
        onPressed: () {
          final phone = _phoneController.text.trim();
          if (!RegExp(r'^1\d{10}$').hasMatch(phone)) {
            showAccountToast(context, '请输入正确的 11 位手机号码');
            return;
          }
          setState(() => _step = 1);
        },
      ),
    ];
  }

  List<Widget> _buildVerification(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final target = _verifyWithEmail
        ? widget.controller.email ?? '安全邮箱'
        : _phoneController.text;
    return [
      AccountCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _verifyWithEmail
                  ? Icons.mark_email_read_outlined
                  : Icons.sms_outlined,
              color: scheme.primary,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                _verifyWithEmail
                    ? AppLocalizations.of(context).text(
                        '验证码将发送至 $target',
                        'Verification code will be sent to $target',
                      )
                    : AppLocalizations.of(context).text(
                        '验证码将发送至 $target',
                        'Verification code will be sent to $target',
                      ),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      AccountTextField(
        key: const Key('platform-phone-code'),
        controller: _codeController,
        label: '验证码',
        hint: '请输入 6 位验证码',
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        suffix: TextButton(
          onPressed: () {
            setState(() => _codeSent = true);
            showAccountToast(context, '验证码已发送（模拟）');
          },
          child: Text(
            localizeAccountLabel(context, _codeSent ? '重新发送' : '获取验证码'),
          ),
        ),
      ),
      const SizedBox(height: 18),
      AccountPrimaryButton(
        key: const Key('platform-phone-verify'),
        label: '验证并绑定',
        icon: Icons.verified_rounded,
        onPressed: () {
          if (_codeController.text.length != 6) {
            showAccountToast(context, '请输入 6 位验证码');
            return;
          }
          widget.controller.bindPhone(_phoneController.text);
          setState(() => _step = 2);
        },
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: widget.controller.email == null
            ? null
            : () {
                setState(() => _verifyWithEmail = !_verifyWithEmail);
                showAccountToast(
                  context,
                  _verifyWithEmail ? '已切换至邮箱验证' : '已切换至短信验证',
                );
              },
        child: Text(
          localizeAccountLabel(
            context,
            widget.controller.email == null ? '暂无可用的其他验证方式' : '换其它方式认证',
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSuccess(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      AccountCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: scheme.primary, size: 42),
            ),
            const SizedBox(height: 18),
            Text(
              localizeAccountLabel(context, _isChange ? '手机号修改成功' : '手机号绑定成功'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              widget.controller.phone ?? '',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    ];
  }
}
