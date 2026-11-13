import 'package:flutter/material.dart';

import '../../common/miniapp_localizations.dart';
import '../tospino_routes.dart';
import '../tospino_style.dart';

class TospinoLoginPage extends StatefulWidget {
  const TospinoLoginPage({super.key, required this.controller});

  final TospinoAppController controller;

  @override
  State<TospinoLoginPage> createState() => _TospinoLoginPageState();
}

class _TospinoLoginPageState extends State<TospinoLoginPage> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final account = _accountController.text.trim();
    final password = _passwordController.text;
    if (account.isEmpty || password.isEmpty) {
      showTospinoToast(context, 'Enter your account and password');
      return;
    }
    await widget.controller.login(account: account, password: password);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('tospino-login-page'),
      color: TospinoColors.resolve(context, TospinoColors.background),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 32, 22, 30),
        children: [
          const Center(child: TospinoBrandMark(size: 76)),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Tospino',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: TospinoColors.brandDeep,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Center(
            child: Text(
              localizeMiniProgramLabel(context, '登录 / 注册'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: TospinoColors.resolve(context, TospinoColors.surface),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                TextField(
                  key: const Key('tospino-login-account'),
                  controller: _accountController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.telephoneNumber,
                  ],
                  decoration: InputDecoration(
                    labelText: localizeMiniProgramLabel(context, '手机号码'),
                    hintText: '+233 55 123 4567 / email',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('tospino-login-password'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: localizeMiniProgramLabel(context, '密码'),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                if (widget.controller.loginError != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.controller.loginError!,
                      style: const TextStyle(
                        color: TospinoColors.price,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('tospino-login-submit'),
                    onPressed: widget.controller.busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: TospinoColors.solidBrand(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: widget.controller.busy
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            localizeMiniProgramLabel(context, '登录'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Tospino OAuth · ${widget.controller.isLoggedIn ? 'authenticated' : 'secure sign-in'}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
