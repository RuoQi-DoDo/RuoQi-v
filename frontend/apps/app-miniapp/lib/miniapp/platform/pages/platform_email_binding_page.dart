import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../platform_dialogs.dart';
import '../platform_models.dart';
import '../platform_style.dart';
import '../platform_widgets.dart';

class PlatformEmailBindingPage extends StatefulWidget {
  const PlatformEmailBindingPage({
    super.key,
    required this.controller,
    required this.mode,
  });

  final PlatformAccountController controller;
  final PlatformCredentialMode mode;

  @override
  State<PlatformEmailBindingPage> createState() =>
      _PlatformEmailBindingPageState();
}

class _PlatformEmailBindingPageState extends State<PlatformEmailBindingPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  int _step = 0;
  bool _codeSent = false;
  bool _verifyWithPhone = false;

  bool get _isChange => widget.mode == PlatformCredentialMode.change;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: PlatformStyle.pageBackground(context),
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('platform-email-binding-page'),
          padding: PlatformStyle.pagePadding,
          children: [
            PlatformPageHeader(
              title: _isChange ? '修改邮箱' : '绑定邮箱',
              subtitle: _step == 2 ? '安全邮箱已更新' : '验证邮箱后接收安全通知与验证码',
            ),
            if (_step == 0) ..._buildEmailEntry(context),
            if (_step == 1) ..._buildVerification(context),
            if (_step == 2) ..._buildSuccess(context),
            const SizedBox(height: 24),
            const PlatformInfoBanner(
              message: '请使用可长期访问的邮箱。重要信息变更需要完成身份验证。',
              icon: Icons.mark_email_read_outlined,
            ),
            if (_step == 2) ...[
              const SizedBox(height: 22),
              PlatformPrimaryButton(
                key: const Key('platform-email-success-done'),
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

  List<Widget> _buildEmailEntry(BuildContext context) {
    final theme = Theme.of(context);
    return [
      if (_isChange && widget.controller.email != null) ...[
        PlatformCard(
          child: PlatformListRow(
            icon: Icons.mark_email_read_outlined,
            title: '当前安全邮箱',
            value: widget.controller.email,
          ),
        ),
        const SizedBox(height: 18),
      ],
      PlatformTextField(
        key: const Key('platform-email-input'),
        controller: _emailController,
        label: '新邮箱',
        hint: '请输入常用邮箱地址',
        keyboardType: TextInputType.emailAddress,
        inputFormatters: [LengthLimitingTextInputFormatter(80)],
      ),
      const SizedBox(height: 18),
      Text(
        '请确认邮箱地址拼写正确，验证码将发送至该邮箱。',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 22),
      PlatformPrimaryButton(
        key: const Key('platform-email-next'),
        label: '下一步',
        icon: Icons.arrow_forward_rounded,
        onPressed: () {
          final email = _emailController.text.trim();
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
            showPlatformToast(context, '请输入正确的邮箱地址');
            return;
          }
          setState(() => _step = 1);
        },
      ),
    ];
  }

  List<Widget> _buildVerification(BuildContext context) {
    final theme = Theme.of(context);
    final target = _verifyWithPhone
        ? widget.controller.phone ?? '安全手机'
        : _emailController.text;
    return [
      PlatformCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _verifyWithPhone
                  ? Icons.sms_outlined
                  : Icons.mark_email_unread_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                '验证码将发送至 $target',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      PlatformTextField(
        key: const Key('platform-email-code'),
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
        key: const Key('platform-email-verify'),
        label: '验证并绑定',
        icon: Icons.verified_rounded,
        onPressed: () {
          if (_codeController.text.length != 6) {
            showPlatformToast(context, '请输入 6 位验证码');
            return;
          }
          widget.controller.bindEmail(_emailController.text);
          setState(() => _step = 2);
        },
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: widget.controller.phone == null
            ? null
            : () {
                setState(() => _verifyWithPhone = !_verifyWithPhone);
                showPlatformToast(
                  context,
                  _verifyWithPhone ? '已切换至手机验证' : '已切换至邮箱验证',
                );
              },
        child: Text(
          widget.controller.phone == null ? '暂无可用的其他验证方式' : '换其它方式认证',
        ),
      ),
    ];
  }

  List<Widget> _buildSuccess(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
              _isChange ? '邮箱修改成功' : '邮箱绑定成功',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              widget.controller.email ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
