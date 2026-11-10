import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../platform_dialogs.dart';
import '../platform_models.dart';
import '../platform_style.dart';
import '../platform_widgets.dart';

class PlatformPhoneBindingPage extends StatefulWidget {
  const PlatformPhoneBindingPage({
    super.key,
    required this.controller,
    required this.mode,
  });

  final PlatformAccountController controller;
  final PlatformCredentialMode mode;

  @override
  State<PlatformPhoneBindingPage> createState() =>
      _PlatformPhoneBindingPageState();
}

class _PlatformPhoneBindingPageState extends State<PlatformPhoneBindingPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  int _step = 0;
  bool _codeSent = false;
  bool _verifyWithEmail = false;

  bool get _isChange => widget.mode == PlatformCredentialMode.change;

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
      backgroundColor: PlatformStyle.pageBackground(context),
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('platform-phone-binding-page'),
          padding: PlatformStyle.pagePadding,
          children: [
            PlatformPageHeader(
              title: _isChange ? '修改手机号' : '绑定手机号',
              subtitle: _step == 2 ? '安全手机已更新' : '完成身份验证后更新账号安全手机',
            ),
            if (_step == 0) ..._buildPhoneEntry(context),
            if (_step == 1) ..._buildVerification(context),
            if (_step == 2) ..._buildSuccess(context),
            const SizedBox(height: 24),
            PlatformInfoBanner(
              message: _step == 2
                  ? '新的安全手机将用于登录验证和重要操作确认。'
                  : '为保障账号安全，变更重要信息需要完成身份验证。当前为小程序模拟流程。',
              icon: _step == 2
                  ? Icons.verified_user_outlined
                  : Icons.security_rounded,
            ),
            if (_step == 2) ...[
              const SizedBox(height: 22),
              PlatformPrimaryButton(
                key: const Key('platform-phone-success-done'),
                label: '完成',
                icon: Icons.check_rounded,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
            if (_step > 0)
              TextButton(
                onPressed: () => setState(() => _step--),
                child: const Text('返回上一步'),
              ),
            if (_isChange && _step < 2)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '暂不修改',
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
        PlatformCard(
          child: PlatformListRow(
            icon: Icons.phone_iphone_rounded,
            title: '当前安全手机',
            value: widget.controller.phone,
          ),
        ),
        const SizedBox(height: 18),
      ],
      PlatformTextField(
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
        '该号码将接收短信验证码，请确认可以正常使用。',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 22),
      PlatformPrimaryButton(
        key: const Key('platform-phone-next'),
        label: '下一步',
        icon: Icons.arrow_forward_rounded,
        onPressed: () {
          final phone = _phoneController.text.trim();
          if (!RegExp(r'^1\d{10}$').hasMatch(phone)) {
            showPlatformToast(context, '请输入正确的 11 位手机号码');
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
      PlatformCard(
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
                _verifyWithEmail ? '验证码将发送至 $target' : '验证码将发送至 $target',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      PlatformTextField(
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
            showPlatformToast(context, '验证码已发送（模拟）');
          },
          child: Text(_codeSent ? '重新发送' : '获取验证码'),
        ),
      ),
      const SizedBox(height: 18),
      PlatformPrimaryButton(
        key: const Key('platform-phone-verify'),
        label: '验证并绑定',
        icon: Icons.verified_rounded,
        onPressed: () {
          if (_codeController.text.length != 6) {
            showPlatformToast(context, '请输入 6 位验证码');
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
                showPlatformToast(
                  context,
                  _verifyWithEmail ? '已切换至邮箱验证' : '已切换至短信验证',
                );
              },
        child: Text(
          widget.controller.email == null ? '暂无可用的其他验证方式' : '换其它方式认证',
        ),
      ),
    ];
  }

  List<Widget> _buildSuccess(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      PlatformCard(
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
              _isChange ? '手机号修改成功' : '手机号绑定成功',
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
