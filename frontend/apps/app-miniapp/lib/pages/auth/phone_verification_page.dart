import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization.dart';
import '../common/whatsapp_colors.dart';

/// Verification-code step used after submitting a phone number.
///
/// The UI boundary is ready for the IAM SMS API. Until that backend returns and
/// delivers a code, the standalone app accepts the explicit demo code below.
class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.onVerified,
    required this.onBack,
  });

  final String phoneNumber;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  static const _accent = WhatsAppColors.brandStrong;
  static const _background = Color(0xFFF7F7F7);
  static const _titleColor = Color(0xFF4F565A);
  static const _bodyColor = Color(0xFF70777B);
  static const _demoCode = '123456';

  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _codeFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  bool get _canVerify => _codeController.text.length == 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      key: const Key('phone-verification-page'),
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  key: const Key('phone-code-back'),
                  tooltip: l10n.text('返回', 'Back'),
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.text('更多选项', 'More options'),
                  onPressed: () => _showHelp(context),
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  children: [
                    Text(
                      l10n.text('验证你的电话号码', 'Verify your phone number'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: _titleColor,
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.text(
                        '我们已向 ${_maskedPhone(widget.phoneNumber)} 发送 6 位验证码。',
                        'We sent a 6-digit code to ${_maskedPhone(widget.phoneNumber)}.',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _bodyColor,
                        fontSize: 17,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 42),
                    SizedBox(
                      width: 236,
                      child: TextField(
                        key: const Key('phone-code-input'),
                        controller: _codeController,
                        focusNode: _codeFocusNode,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() => _error = null),
                        onSubmitted: (_) => _verify(),
                        style: const TextStyle(
                          color: _titleColor,
                          fontSize: 26,
                          letterSpacing: 8,
                        ),
                        decoration: InputDecoration(
                          filled: false,
                          counterText: '',
                          hintText: '------',
                          hintStyle: TextStyle(
                            color: _bodyColor.withValues(alpha: 0.45),
                            letterSpacing: 8,
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: _accent, width: 1.5),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: _accent, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _error ??
                          l10n.text(
                            '演示验证码：123456',
                            'Demo verification code: 123456',
                          ),
                      key: const Key('phone-code-status'),
                      style: TextStyle(
                        color: _error == null
                            ? _bodyColor
                            : theme.colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      key: const Key('phone-code-resend'),
                      onPressed: _resend,
                      child: Text(
                        l10n.text('重新发送验证码', 'Resend code'),
                        style: const TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  key: const Key('phone-code-verify'),
                  onPressed: _canVerify ? _verify : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: WhatsAppColors.brand,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    disabledForegroundColor: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.55),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(l10n.text('验证', 'Verify')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verify() {
    if (_codeController.text == _demoCode) {
      _codeFocusNode.unfocus();
      widget.onVerified();
      return;
    }
    setState(() {
      _error = AppLocalizations.of(
        context,
      ).text('验证码不正确，请重新输入', 'Incorrect code. Try again.');
    });
  }

  void _resend() {
    _codeController.clear();
    setState(() => _error = null);
    _codeFocusNode.requestFocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).text('验证码已重新发送', 'Verification code resent'),
          ),
        ),
      );
  }

  Future<void> _showHelp(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.text('需要帮助？', 'Need help?')),
        content: Text(
          l10n.text(
            '请检查短信收件箱。当前演示环境使用验证码 123456。',
            'Check your messages. The demo environment uses code 123456.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.text('关闭', 'Close')),
          ),
        ],
      ),
    );
  }

  String _maskedPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) {
      return value;
    }
    return '${value.substring(0, value.length - digits.length)}'
        '${List.filled(digits.length - 4, '•').join()}'
        '${digits.substring(digits.length - 4)}';
  }
}
