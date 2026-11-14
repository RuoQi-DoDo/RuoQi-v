import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization.dart';
import '../common/whatsapp_colors.dart';
import 'phone_country.dart';
import 'phone_country_picker_page.dart';

/// WhatsApp-style phone verification entry shown after accepting the welcome
/// terms. The callback receives the fully qualified international number.
class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({
    super.key,
    required this.onRequestVerification,
    this.initialCountry,
  });

  final ValueChanged<String> onRequestVerification;
  final PhoneCountry? initialCountry;

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  static const _accent = WhatsAppColors.brandStrong;
  static const _background = Color(0xFFF7F7F7);
  static const _titleColor = Color(0xFF4F565A);
  static const _bodyColor = Color(0xFF70777B);

  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  late final TapGestureRecognizer _helpRecognizer;
  late PhoneCountry _country;

  @override
  void initState() {
    super.initState();
    _country =
        widget.initialCountry ??
        phoneCountries.firstWhere((country) => country.code == 'CN');
    _helpRecognizer = TapGestureRecognizer()..onTap = () => _showHelp(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _phoneFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _helpRecognizer.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '').length >= 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final english = l10n.locale.languageCode == 'en';
    return Scaffold(
      key: const Key('phone-login-page'),
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<_PhoneMenuAction>(
                key: const Key('phone-login-menu'),
                tooltip: l10n.text('更多选项', 'More options'),
                onSelected: (_) => _showHelp(context),
                itemBuilder: (menuContext) => [
                  PopupMenuItem(
                    value: _PhoneMenuAction.help,
                    child: Text(l10n.text('帮助', 'Help')),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  children: [
                    Text(
                      l10n.text('输入电话号码', 'Enter phone number'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: _titleColor,
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PhoneDescription(helpRecognizer: _helpRecognizer),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Column(
                        children: [
                          InkWell(
                            key: const Key('phone-country-selector'),
                            onTap: _selectCountry,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _accent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.only(
                                left: 30,
                                right: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      english
                                          ? _country.nameEn
                                          : _country.nameZh,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            color: scheme.onSurface,
                                            fontSize: 23,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: _accent,
                                    size: 28,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 88,
                                child: Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _accent,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _country.dialCode,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: scheme.onSurface,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextField(
                                  key: const Key('phone-number-input'),
                                  controller: _phoneController,
                                  focusNode: _phoneFocusNode,
                                  autofocus: true,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (_) => setState(() {}),
                                  onSubmitted: (_) => _submit(),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 22,
                                    letterSpacing: 0.4,
                                  ),
                                  decoration: InputDecoration(
                                    filled: false,
                                    hintText: l10n.text('电话号码', 'Phone number'),
                                    hintStyle: theme.textTheme.titleLarge
                                        ?.copyWith(
                                          color: _bodyColor,
                                          fontSize: 22,
                                        ),
                                    contentPadding: const EdgeInsets.only(
                                      bottom: 9,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _accent,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _accent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                  key: const Key('phone-next'),
                  onPressed: _canContinue ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: WhatsAppColors.brand,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: scheme.surfaceContainerHighest,
                    disabledForegroundColor: scheme.onSurfaceVariant.withValues(
                      alpha: 0.55,
                    ),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(l10n.text('下一步', 'Next')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCountry() async {
    _phoneFocusNode.unfocus();
    final selected = await Navigator.of(
      context,
    ).push<PhoneCountry>(PhoneCountryPickerPage.route(_country));
    if (!mounted || selected == null) {
      return;
    }
    setState(() => _country = selected);
    _phoneFocusNode.requestFocus();
  }

  void _submit() {
    if (!_canContinue) {
      return;
    }
    _phoneFocusNode.unfocus();
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    widget.onRequestVerification('${_country.dialCode}$digits');
  }

  Future<void> _showHelp(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.text('我的电话号码是多少？', "What's my number?")),
        content: Text(
          l10n.text(
            '你可以在设备设置或运营商账单中查看手机号码。',
            'You can find your number in device settings or your carrier bill.',
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
}

enum _PhoneMenuAction { help }

class _PhoneDescription extends StatelessWidget {
  const _PhoneDescription({required this.helpRecognizer});

  final TapGestureRecognizer helpRecognizer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: const Color(0xFF70777B),
      fontSize: 17,
      height: 1.45,
    );
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: style,
        children: [
          TextSpan(
            text: l10n.text(
              'RuoQi 需要验证你的电话号码。运营商可能会收取相关费用。',
              'RuoQi needs to verify your phone number. Carrier charges may apply. ',
            ),
          ),
          TextSpan(
            text: l10n.text('我的电话号码是多少？', "What's my number?"),
            recognizer: helpRecognizer,
            style: style?.copyWith(
              color: WhatsAppColors.brandStrong,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
