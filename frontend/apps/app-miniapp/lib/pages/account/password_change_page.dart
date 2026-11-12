import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'account_dialogs.dart';
import 'account_controller.dart';
import 'account_style.dart';
import 'account_widgets.dart';
import 'account_localizations.dart';

class AccountPasswordChangePage extends StatefulWidget {
  const AccountPasswordChangePage({super.key, required this.controller});

  final AccountController controller;

  @override
  State<AccountPasswordChangePage> createState() =>
      _AccountPasswordChangePageState();
}

class _AccountPasswordChangePageState extends State<AccountPasswordChangePage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();
  AccountPasswordVerification _verification =
      AccountPasswordVerification.password;
  bool _codeSent = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
          key: const Key('platform-password-change-page'),
          padding: AccountStyle.pagePadding,
          children: [
            const AccountPageHeader(
              title: '修改登录密码',
              subtitle: '先完成身份验证，再设置新的登录密码',
            ),
            Text(
              localizeAccountLabel(context, '选择验证方式'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<AccountPasswordVerification>(
              segments: [
                ButtonSegment(
                  value: AccountPasswordVerification.password,
                  icon: Icon(Icons.password_rounded, size: 18),
                  label: Text(localizeAccountLabel(context, '密码')),
                ),
                ButtonSegment(
                  value: AccountPasswordVerification.sms,
                  icon: Icon(Icons.sms_outlined, size: 18),
                  label: Text(localizeAccountLabel(context, '短信')),
                ),
                ButtonSegment(
                  value: AccountPasswordVerification.email,
                  icon: Icon(Icons.mail_outline_rounded, size: 18),
                  label: Text(localizeAccountLabel(context, '邮箱')),
                ),
              ],
              selected: {_verification},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                setState(() => _verification = selection.first);
              },
            ),
            const SizedBox(height: 18),
            if (_verification == AccountPasswordVerification.password)
              AccountTextField(
                key: const Key('platform-password-current'),
                controller: _currentPasswordController,
                label: '当前登录密码',
                hint: '请输入当前登录密码',
                obscureText: _obscurePassword,
                suffix: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 19,
                  ),
                ),
              )
            else
              AccountTextField(
                key: const Key('platform-password-code'),
                controller: _codeController,
                label: _verification == AccountPasswordVerification.sms
                    ? '短信验证码'
                    : '邮箱验证码',
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
            const SizedBox(height: 20),
            Text(
              localizeAccountLabel(context, '设置新密码'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            AccountTextField(
              key: const Key('platform-password-new'),
              controller: _newPasswordController,
              label: '新密码',
              hint: '请输入 6-20 位新密码',
              obscureText: _obscurePassword,
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
            ),
            const SizedBox(height: 18),
            AccountTextField(
              key: const Key('platform-password-confirm'),
              controller: _confirmPasswordController,
              label: '确认新密码',
              hint: '请再次输入新密码',
              obscureText: _obscurePassword,
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
            ),
            const SizedBox(height: 12),
            Text(
              localizeAccountLabel(context, '建议使用字母、数字与符号组合，避免与其他平台使用相同密码。'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            AccountPrimaryButton(
              key: const Key('platform-password-submit'),
              label: '确认修改密码',
              icon: Icons.lock_reset_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(
                  () => _verification = switch (_verification) {
                    AccountPasswordVerification.password =>
                      AccountPasswordVerification.sms,
                    AccountPasswordVerification.sms =>
                      AccountPasswordVerification.email,
                    AccountPasswordVerification.email =>
                      AccountPasswordVerification.password,
                  },
                );
              },
              child: Text(localizeAccountLabel(context, '换其它方式认证')),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_verification == AccountPasswordVerification.password &&
        _currentPasswordController.text.isEmpty) {
      showAccountToast(context, '请输入当前登录密码');
      return;
    }
    if (_verification != AccountPasswordVerification.password &&
        _codeController.text.length != 6) {
      showAccountToast(context, '请输入 6 位验证码');
      return;
    }
    final password = _newPasswordController.text;
    if (password.length < 6) {
      showAccountToast(context, '新密码至少需要 6 位');
      return;
    }
    if (password != _confirmPasswordController.text) {
      showAccountToast(context, '两次输入的新密码不一致');
      return;
    }
    widget.controller.updatePassword();
    showAccountSuccessDialog(
      context,
      title: '密码修改成功',
      message: '新密码已生效，请使用新密码进行下一次登录。',
      onDone: () => Navigator.of(context).pop(),
    );
  }
}
