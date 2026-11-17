import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

enum _RegistrationStep { method, account, verification, password }

class TospinoRegistrationPage extends StatefulWidget {
  const TospinoRegistrationPage({
    super.key,
    required this.controller,
    required this.useEmail,
    required this.onBack,
  });

  final TospinoAppController controller;
  final bool useEmail;
  final VoidCallback onBack;

  @override
  State<TospinoRegistrationPage> createState() =>
      _TospinoRegistrationPageState();
}

class _TospinoRegistrationPageState extends State<TospinoRegistrationPage> {
  final _accountController = TextEditingController();
  final _promoteController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  _RegistrationStep _step = _RegistrationStep.account;
  late bool _useEmail;
  bool _agreed = false;
  bool _obscurePassword = true;
  bool _obscureRepeat = true;
  int _resendSeconds = 0;
  Timer? _countdown;

  TospinoAppController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _useEmail = widget.useEmail;
    _accountController.addListener(_refresh);
    _codeController.addListener(_refresh);
    _passwordController.addListener(_refresh);
    _repeatPasswordController.addListener(_refresh);
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _accountController
      ..removeListener(_refresh)
      ..dispose();
    _promoteController.dispose();
    _codeController
      ..removeListener(_refresh)
      ..dispose();
    _passwordController
      ..removeListener(_refresh)
      ..dispose();
    _repeatPasswordController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  bool get _validAccount {
    final value = _accountController.text.trim();
    if (_useEmail) {
      return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    }
    return value.replaceAll(RegExp(r'[^0-9]'), '').length >= 7;
  }

  bool get _validCode => _codeController.text.trim().length == 6;

  bool get _validPassword {
    final password = _passwordController.text;
    return !password.contains(' ') &&
        RegExp(
          r'^(?![0-9]+$)(?![a-z]+$)(?![A-Z]+$)(?!([^(0-9a-zA-Z)])+$).{6,20}$',
        ).hasMatch(password) &&
        password == _repeatPasswordController.text;
  }

  void _selectMethod(bool useEmail) {
    setState(() {
      _useEmail = useEmail;
      _accountController.clear();
      _step = _RegistrationStep.account;
    });
  }

  void _handleBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    switch (_step) {
      case _RegistrationStep.method:
        widget.onBack();
      case _RegistrationStep.account:
        widget.onBack();
      case _RegistrationStep.verification:
        setState(() => _step = _RegistrationStep.account);
      case _RegistrationStep.password:
        setState(() => _step = _RegistrationStep.verification);
    }
  }

  Future<void> _agreeAndRequestCode() async {
    if (!_validAccount) {
      showTospinoToast(context, _useEmail ? '请输入有效的电子邮箱' : '请输入有效的手机号码');
      return;
    }
    if (!_agreed) {
      final agreed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: TospinoColors.resolve(
            dialogContext,
            TospinoColors.surface,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            localizeMiniProgramLabel(dialogContext, '阅读并同意服务条款'),
            textAlign: TextAlign.center,
          ),
          content: Text(
            localizeMiniProgramLabel(
              dialogContext,
              '请阅读并同意 Tospino 服务协议和隐私政策后继续注册。',
            ),
            textAlign: TextAlign.center,
            style: TospinoText.secondary(dialogContext),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizeMiniProgramLabel(dialogContext, '暂不同意')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(localizeMiniProgramLabel(dialogContext, '同意')),
            ),
          ],
        ),
      );
      if (agreed != true || !mounted) return;
      setState(() => _agreed = true);
    }
    await _requestCode();
  }

  Future<void> _requestCode() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final sent = await controller.requestRegistrationCode(
      account: _accountController.text.trim(),
      useEmail: _useEmail,
    );
    if (!mounted || !sent) return;
    setState(() {
      _codeController.clear();
      _step = _RegistrationStep.verification;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdown?.cancel();
    setState(() => _resendSeconds = 60);
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds--);
    });
  }

  Future<void> _verifyCode() async {
    if (!_validCode) {
      showTospinoToast(context, '请输入 6 位验证码');
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final verified = await controller.verifyRegistrationCode(
      account: _accountController.text.trim(),
      code: _codeController.text.trim(),
      useEmail: _useEmail,
    );
    if (!mounted || !verified) return;
    _countdown?.cancel();
    setState(() => _step = _RegistrationStep.password);
  }

  Future<void> _register() async {
    if (!_validPassword) {
      showTospinoToast(context, '密码需为 6-20 位，且两次输入一致');
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await controller.registerAccount(
      account: _accountController.text.trim(),
      code: _codeController.text.trim(),
      password: _passwordController.text,
      useEmail: _useEmail,
      promoteCode: _promoteController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('tospino-registration-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: switch (_step) {
        _RegistrationStep.method => _buildMethodStep(context),
        _RegistrationStep.account => _buildAccountStep(context),
        _RegistrationStep.verification => _buildVerificationStep(context),
        _RegistrationStep.password => _buildPasswordStep(context),
      },
    );
  }

  Widget _buildMethodStep(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
        _RegistrationHeader(
          title: '注册 Tospino',
          subtitle: '选择注册方式',
          onBack: _handleBack,
        ),
        const SizedBox(height: 24),
        _RegistrationMethodTile(
          key: const Key('tospino-register-phone'),
          icon: Icons.phone_iphone_rounded,
          color: const Color(0xFF18C4D2),
          title: '使用手机号注册',
          subtitle: '通过短信验证码创建账号',
          onTap: () => _selectMethod(false),
        ),
        const SizedBox(height: 10),
        _RegistrationMethodTile(
          key: const Key('tospino-register-email'),
          icon: Icons.mail_rounded,
          color: const Color(0xFF6C83D9),
          title: '使用邮箱注册',
          subtitle: '通过邮箱验证码创建账号',
          onTap: () => _selectMethod(true),
        ),
        const SizedBox(height: 24),
        Text(
          localizeMiniProgramLabel(context, '注册成功后可使用手机号或邮箱登录 Tospino。'),
          textAlign: TextAlign.center,
          style: TospinoText.secondary(context),
        ),
        const SizedBox(height: 12),
        TextButton(
          key: const Key('tospino-register-back-login'),
          onPressed: widget.onBack,
          child: Text(localizeMiniProgramLabel(context, '已有账号？去登录')),
        ),
      ],
    );
  }

  Widget _buildAccountStep(BuildContext context) {
    final title = _useEmail ? '邮箱注册' : '手机号注册';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
        _RegistrationHeader(title: title, onBack: _handleBack),
        const SizedBox(height: 22),
        TospinoSurface(
          radius: 16,
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
          child: Row(
            children: [
              if (!_useEmail) ...[
                Text(
                  '+233',
                  style: TospinoText.bodyStrong(context).copyWith(fontSize: 14),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 0.5,
                  height: 18,
                  color: TospinoColors.resolve(
                    context,
                    TospinoColors.lineStrong,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  key: const Key('tospino-register-account'),
                  controller: _accountController,
                  autofocus: true,
                  keyboardType: _useEmail
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  inputFormatters: [
                    if (!_useEmail)
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(_useEmail ? 254 : 15),
                  ],
                  decoration: InputDecoration(
                    hintText: localizeMiniProgramLabel(
                      context,
                      _useEmail ? '电子邮箱' : '手机号码',
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 17),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TospinoSurface(
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            key: const Key('tospino-register-promote-code'),
            controller: _promoteController,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [LengthLimitingTextInputFormatter(15)],
            decoration: InputDecoration(
              hintText: localizeMiniProgramLabel(context, '邀请码（选填）'),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 17),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _RegistrationAgreement(
          agreed: _agreed,
          onChanged: () => setState(() => _agreed = !_agreed),
        ),
        if (controller.registrationError != null) ...[
          const SizedBox(height: 10),
          _RegistrationError(message: controller.registrationError!),
        ],
        const SizedBox(height: 18),
        TospinoGradientButton(
          key: const Key('tospino-register-send-code'),
          label: controller.busy ? '发送中…' : '获取验证码',
          onPressed: controller.busy || !_validAccount
              ? null
              : _agreeAndRequestCode,
        ),
      ],
    );
  }

  Widget _buildVerificationStep(BuildContext context) {
    final account = _useEmail
        ? _accountController.text.trim()
        : '+233 ${_accountController.text.trim()}';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
        _RegistrationHeader(title: '验证账号', onBack: _handleBack),
        const SizedBox(height: 24),
        Icon(
          _useEmail ? Icons.mark_email_read_rounded : Icons.sms_rounded,
          size: 54,
          color: TospinoColors.solidBrand(context),
        ),
        const SizedBox(height: 13),
        Text(
          '${localizeMiniProgramLabel(context, '验证码已发送至')}\n$account',
          textAlign: TextAlign.center,
          style: TospinoText.body(context).copyWith(height: 1.5),
        ),
        const SizedBox(height: 22),
        TospinoSurface(
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: TextField(
            key: const Key('tospino-register-code'),
            controller: _codeController,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            style: TospinoText.pageTitle(
              context,
            ).copyWith(fontSize: 24, letterSpacing: 8),
            decoration: InputDecoration(
              hintText: '000000',
              hintStyle: TospinoText.hint(
                context,
              ).copyWith(fontSize: 20, letterSpacing: 8),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                localizeMiniProgramLabel(context, '没有收到验证码？'),
                style: TospinoText.meta(context),
              ),
            ),
            TextButton(
              key: const Key('tospino-register-resend-code'),
              onPressed: controller.busy || _resendSeconds > 0
                  ? null
                  : _requestCode,
              child: Text(
                _resendSeconds > 0
                    ? '$_resendSeconds s'
                    : localizeMiniProgramLabel(context, '重新发送'),
              ),
            ),
          ],
        ),
        if (controller.registrationError != null) ...[
          const SizedBox(height: 6),
          _RegistrationError(message: controller.registrationError!),
        ],
        const SizedBox(height: 18),
        TospinoGradientButton(
          key: const Key('tospino-register-verify-code'),
          label: controller.busy ? '验证中…' : '下一步',
          onPressed: controller.busy || !_validCode ? null : _verifyCode,
        ),
      ],
    );
  }

  Widget _buildPasswordStep(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
        _RegistrationHeader(title: '设置登录密码', onBack: _handleBack),
        const SizedBox(height: 22),
        TospinoSurface(
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            key: const Key('tospino-register-password'),
            controller: _passwordController,
            autofocus: true,
            obscureText: _obscurePassword,
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            decoration: InputDecoration(
              hintText: localizeMiniProgramLabel(context, '输入密码（6-20）'),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 17),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TospinoSurface(
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            key: const Key('tospino-register-password-repeat'),
            controller: _repeatPasswordController,
            obscureText: _obscureRepeat,
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            onSubmitted: (_) {
              if (_validPassword && !controller.busy) _register();
            },
            decoration: InputDecoration(
              hintText: localizeMiniProgramLabel(context, '再次输入密码'),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 17),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscureRepeat = !_obscureRepeat),
                icon: Icon(
                  _obscureRepeat
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          localizeMiniProgramLabel(context, '密码需为 6-20 位，并同时包含字母和数字或特殊符号。'),
          style: TospinoText.meta(context).copyWith(height: 1.45),
        ),
        if (controller.registrationError != null) ...[
          const SizedBox(height: 10),
          _RegistrationError(message: controller.registrationError!),
        ],
        const SizedBox(height: 20),
        TospinoGradientButton(
          key: const Key('tospino-register-submit'),
          label: controller.busy ? '注册中…' : '注册',
          onPressed: controller.busy || !_validPassword ? null : _register,
        ),
      ],
    );
  }
}

class _RegistrationHeader extends StatelessWidget {
  const _RegistrationHeader({
    required this.title,
    required this.onBack,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          key: const Key('tospino-register-back'),
          onPressed: onBack,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizeMiniProgramLabel(context, title),
                style: TospinoText.pageTitle(context).copyWith(fontSize: 24),
              ),
              if (subtitle != null)
                Text(
                  localizeMiniProgramLabel(context, subtitle!),
                  style: TospinoText.secondary(context),
                ),
            ],
          ),
        ),
        const SizedBox(width: 50),
      ],
    );
  }
}

class _RegistrationMethodTile extends StatelessWidget {
  const _RegistrationMethodTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeMiniProgramLabel(context, title),
                      style: TospinoText.bodyStrong(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      localizeMiniProgramLabel(context, subtitle),
                      style: TospinoText.meta(context),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegistrationAgreement extends StatelessWidget {
  const _RegistrationAgreement({required this.agreed, required this.onChanged});

  final bool agreed;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final brand = TospinoColors.solidBrand(context);
    return InkWell(
      key: const Key('tospino-register-agreement'),
      onTap: onChanged,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: agreed ? brand : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: agreed
                      ? brand
                      : TospinoColors.resolve(context, TospinoColors.hint),
                ),
              ),
              child: agreed
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TospinoText.meta(context).copyWith(height: 1.4),
                  children: [
                    TextSpan(
                      text: '${localizeMiniProgramLabel(context, '我已阅读并同意')} ',
                    ),
                    TextSpan(
                      text: localizeMiniProgramLabel(context, 'Tospino服务协议'),
                      style: TextStyle(color: brand),
                    ),
                    TextSpan(
                      text: ' ${localizeMiniProgramLabel(context, '和')} ',
                    ),
                    TextSpan(
                      text: localizeMiniProgramLabel(context, '隐私政策'),
                      style: TextStyle(color: brand),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationError extends StatelessWidget {
  const _RegistrationError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: TospinoColors.resolve(
          context,
          TospinoColors.price,
        ).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: TospinoText.meta(
          context,
        ).copyWith(color: TospinoColors.resolve(context, TospinoColors.price)),
      ),
    );
  }
}
