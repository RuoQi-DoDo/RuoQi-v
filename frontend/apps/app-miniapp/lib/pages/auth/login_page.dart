import 'package:flutter/material.dart';
import 'package:common/common.dart';

import '../../localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.embedded = false,
    this.appTitle,
    this.heading,
    this.onLoginSuccess,
  });

  final String? appTitle;
  final String? heading;

  /// 嵌入业务工作台弹窗时去掉自带 AppBar（弹窗顶部已有控制台导航栏）。
  final bool embedded;

  /// 登录成功后的业务回调。未提供时保留原有演示提示。
  final VoidCallback? onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final onLoginSuccess = widget.onLoginSuccess;
      if (onLoginSuccess != null) {
        onLoginSuccess();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).text('登录功能待接入后端', 'Login backend integration is pending'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final body = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.heading ?? l10n.text('客户登录', 'Customer login'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('login-username'),
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: l10n.text('用户名', 'Username'),
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? l10n.text('请输入用户名', 'Enter your username')
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('login-password'),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.text('密码', 'Password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? l10n.text('请输入密码', 'Enter your password')
                      : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('login-submit'),
                  onPressed: _submit,
                  child: Text(l10n.text('登 录', 'Log in')),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: AppBadge(appName: 'customer_app', version: '1.0.0'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appTitle ?? l10n.text('RuoQi 客户 App', 'RuoQi Customer App'),
        ),
      ),
      body: body,
    );
  }
}
