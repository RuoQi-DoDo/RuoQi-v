import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../localization.dart';
import '../../common/miniapp_localizations.dart';
import '../../common/widgets/miniapp_capsule_overlay.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

enum _LoginMode { selection, password }

class TospinoLoginPage extends StatefulWidget {
  const TospinoLoginPage({
    super.key,
    required this.controller,
    this.passwordOnly = false,
  });

  final TospinoAppController controller;
  final bool passwordOnly;

  @override
  State<TospinoLoginPage> createState() => _TospinoLoginPageState();
}

class _TospinoLoginPageState extends State<TospinoLoginPage> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  late _LoginMode _mode;
  bool _obscurePassword = true;
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.passwordOnly ? _LoginMode.password : _LoginMode.selection;
    _accountController.addListener(_refreshForm);
    _passwordController.addListener(_refreshForm);
  }

  @override
  void dispose() {
    _accountController
      ..removeListener(_refreshForm)
      ..dispose();
    _passwordController
      ..removeListener(_refreshForm)
      ..dispose();
    super.dispose();
  }

  void _refreshForm() {
    if (mounted) setState(() {});
  }

  bool get _isPhoneAccount {
    final account = _accountController.text.trim();
    return account.isNotEmpty && RegExp(r'^\+?[0-9\s-]+$').hasMatch(account);
  }

  bool get _canSubmit =>
      _accountController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      !widget.controller.busy;

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final account = _accountController.text.trim();
    final password = _passwordController.text;
    if (account.isEmpty || password.isEmpty) {
      showTospinoToast(context, '请输入手机号码或邮箱和密码');
      return;
    }
    if (password.length < 6 || password.length > 20) {
      showTospinoToast(context, '请输入 6-20 位密码');
      return;
    }
    if (!_agreed) {
      showTospinoToast(context, '请阅读并勾选协议');
      return;
    }
    await widget.controller.login(account: account, password: password);
  }

  void _showPasswordLogin() {
    setState(() => _mode = _LoginMode.password);
  }

  void _showSelection() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.passwordOnly) {
      widget.controller.back();
      return;
    }
    setState(() => _mode = _LoginMode.selection);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('tospino-login-page'),
      color: TospinoColors.resolve(
        context,
        _mode == _LoginMode.selection
            ? TospinoColors.background
            : TospinoColors.surface,
      ),
      child: switch (_mode) {
        _LoginMode.selection => _LoginSelection(
          onPasswordLogin: _showPasswordLogin,
          onRegister: () => widget.controller.openRegistration(useEmail: false),
          onUnavailable: (label) => showTospinoToast(context, '$label暂未开放'),
        ),
        _LoginMode.password => _buildPasswordLogin(context),
      },
    );
  }

  Widget _buildPasswordLogin(BuildContext context) {
    final dividerColor = TospinoColors.resolve(context, TospinoColors.line);
    final textColor = TospinoColors.resolve(context, TospinoColors.ink);
    final hintColor = TospinoColors.resolve(context, TospinoColors.hint);
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 110),
          children: [
            SizedBox(
              height: 46,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  right: MiniProgramCapsuleOverlay.reservedRight,
                ),
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('tospino-login-back'),
                      tooltip: localizeMiniProgramLabel(context, '返回'),
                      onPressed: _showSelection,
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                localizeMiniProgramLabel(context, '登录 Tospino'),
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        if (_isPhoneAccount) ...[
                          Text(
                            '+233',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 0.5,
                            height: 18,
                            color: dividerColor,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: TextField(
                            key: const Key('tospino-login-account'),
                            controller: _accountController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.telephoneNumber,
                            ],
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(254),
                            ],
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              filled: false,
                              hintText: localizeMiniProgramLabel(
                                context,
                                '输入手机号或邮箱',
                              ),
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 0.5, thickness: 0.5, color: dividerColor),
                  SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('tospino-login-password'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(20),
                            ],
                            onSubmitted: (_) => _canSubmit ? _submit() : null,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              filled: false,
                              hintText: localizeMiniProgramLabel(
                                context,
                                '输入密码 (6-20)',
                              ),
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('tospino-login-password-visibility'),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: textColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 0.5, thickness: 0.5, color: dividerColor),
                  if (widget.controller.loginError != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.controller.loginError!,
                        style: TextStyle(
                          color: TospinoColors.resolve(
                            context,
                            TospinoColors.price,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => showTospinoToast(context, '忘记密码'),
                      child: Text(
                        localizeMiniProgramLabel(context, '忘记密码'),
                        style: TextStyle(color: hintColor, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  TospinoGradientButton(
                    key: const Key('tospino-login-submit'),
                    label: widget.controller.busy
                        ? '登录中…'
                        : AppLocalizations.of(context).text('登录', 'Log In'),
                    onPressed: _canSubmit ? _submit : null,
                    height: 48,
                  ),
                  const SizedBox(height: 30),
                  _AgreementRow(
                    agreed: _agreed,
                    onChanged: () => setState(() => _agreed = !_agreed),
                    linkColor: TospinoColors.solidBrand(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 40,
          child: Center(
            child: _LoginPillButton(
              key: const Key('tospino-login-other'),
              label: '其他登录方式',
              onTap: _showSelection,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginSelection extends StatelessWidget {
  const _LoginSelection({
    required this.onPasswordLogin,
    required this.onRegister,
    required this.onUnavailable,
  });

  final VoidCallback onPasswordLogin;
  final VoidCallback onRegister;
  final ValueChanged<String> onUnavailable;

  @override
  Widget build(BuildContext context) {
    final options = <_LoginOption>[
      _LoginOption(
        key: 'tospino-login-password-method',
        label: '使用账号密码继续',
        icon: Icons.person_rounded,
        color: const Color(0xFF2F8FFF),
        onTap: onPasswordLogin,
      ),
      _LoginOption(
        key: 'tospino-login-phone-method',
        label: '使用手机号码继续',
        icon: Icons.phone_iphone_rounded,
        color: const Color(0xFFE84E83),
        onTap: () =>
            onUnavailable(localizeMiniProgramLabel(context, '使用手机号码继续')),
      ),
      _LoginOption(
        key: 'tospino-login-email-method',
        label: '使用电子邮件继续',
        icon: Icons.mail_rounded,
        color: const Color(0xFFDE4C3F),
        onTap: () =>
            onUnavailable(localizeMiniProgramLabel(context, '使用电子邮件继续')),
      ),
      _LoginOption(
        key: 'tospino-login-facebook-method',
        label: '通过Facebook继续',
        icon: Icons.facebook_rounded,
        color: const Color(0xFF1877F2),
        onTap: () => onUnavailable('Facebook'),
      ),
      _LoginOption(
        key: 'tospino-login-google-method',
        label: '通过Google继续',
        icon: Icons.g_mobiledata_rounded,
        color: const Color(0xFF4285F4),
        onTap: () => onUnavailable('Google'),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 8),
              decoration: BoxDecoration(
                color: TospinoColors.resolve(context, TospinoColors.surface),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    localizeMiniProgramLabel(context, '登录 Tospino'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TospinoColors.resolve(context, TospinoColors.ink),
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final option in options) ...[
                    _LoginOptionTile(option: option),
                    if (option != options.last) const SizedBox(height: 10),
                  ],
                  const Spacer(),
                  _LoginAgreementText(
                    textColor: TospinoColors.resolve(
                      context,
                      TospinoColors.hint,
                    ),
                    linkColor: TospinoColors.solidBrand(context),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 42,
                    alignment: Alignment.center,
                    color: TospinoColors.resolve(
                      context,
                      TospinoColors.background,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          localizeMiniProgramLabel(context, '没有账号？'),
                          style: TospinoText.body(context),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          key: const Key('tospino-login-register'),
                          onTap: onRegister,
                          child: Text(
                            localizeMiniProgramLabel(context, '注册'),
                            style: TextStyle(
                              color: TospinoColors.solidBrand(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginOption {
  const _LoginOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _LoginOptionTile extends StatelessWidget {
  const _LoginOptionTile({required this.option});

  final _LoginOption option;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surface),
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        key: Key(option.key),
        onTap: option.onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(
              color: TospinoColors.resolve(context, TospinoColors.lineStrong),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(option.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: Text(
                  localizeMiniProgramLabel(context, option.label),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TospinoText.body(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginAgreementText extends StatelessWidget {
  const _LoginAgreementText({required this.textColor, required this.linkColor});

  final Color textColor;
  final Color linkColor;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: textColor, fontSize: 14, height: 1.45),
        children: [
          TextSpan(text: localizeMiniProgramLabel(context, '继续即表示你同意我们的')),
          TextSpan(
            text: localizeMiniProgramLabel(context, 'Tospino服务协议'),
            style: TextStyle(color: linkColor),
          ),
          TextSpan(text: localizeMiniProgramLabel(context, '并确认已经阅读')),
          TextSpan(
            text: localizeMiniProgramLabel(context, '隐私政策'),
            style: TextStyle(color: linkColor),
          ),
          TextSpan(
            text: localizeMiniProgramLabel(context, '，了解我们如何收集、使用及分享你的数据。'),
          ),
        ],
      ),
    );
  }
}

class _LoginPillButton extends StatelessWidget {
  const _LoginPillButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TospinoColors.resolve(context, TospinoColors.surfaceMuted),
      borderRadius: BorderRadius.circular(1000),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
          child: Text(
            localizeMiniProgramLabel(context, label),
            style: TospinoText.body(context),
          ),
        ),
      ),
    );
  }
}

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({
    required this.agreed,
    required this.onChanged,
    required this.linkColor,
  });

  final bool agreed;
  final VoidCallback onChanged;
  final Color linkColor;

  @override
  Widget build(BuildContext context) {
    final muted = TospinoColors.resolve(context, TospinoColors.hint);
    return InkWell(
      key: const Key('tospino-login-agreement'),
      onTap: onChanged,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: agreed ? TospinoColors.brand : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: agreed ? TospinoColors.brand : muted,
                  width: 1,
                ),
              ),
              child: agreed
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: muted, fontSize: 14, height: 1.45),
                  children: [
                    TextSpan(
                      text: '${localizeMiniProgramLabel(context, '我已阅读并同意')} ',
                    ),
                    TextSpan(
                      text: localizeMiniProgramLabel(context, 'Tospino服务协议'),
                      style: TextStyle(color: linkColor),
                    ),
                    TextSpan(
                      text: ' ${localizeMiniProgramLabel(context, '和')} ',
                    ),
                    TextSpan(
                      text: localizeMiniProgramLabel(context, '隐私政策'),
                      style: TextStyle(color: linkColor),
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
