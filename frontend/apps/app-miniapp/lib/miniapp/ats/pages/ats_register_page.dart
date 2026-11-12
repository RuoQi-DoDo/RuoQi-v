part of 'misc_pages.dart';

class AtsRegisterPage extends StatefulWidget {
  const AtsRegisterPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsRegisterPage> createState() => _AtsRegisterPageState();
}

class _AtsRegisterPageState extends State<AtsRegisterPage> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _agreed = true;
  int _countdown = 0;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_phone.text.trim().length != 11) {
      atsToast(context, '请输入 11 位手机号');
      return;
    }
    setState(() => _countdown = 60);
    while (_countdown > 0 && mounted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _countdown--);
      }
    }
  }

  void _register() {
    if (_phone.text.trim().length != 11 ||
        _code.text.trim().isEmpty ||
        _password.text.length < 6) {
      atsToast(context, '请完整填写手机号、验证码和密码');
      return;
    }
    if (!_agreed) {
      atsToast(context, '请先同意用户协议和隐私政策');
      return;
    }
    widget.controller.open(AtsRoute.registerSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              const Text(
                '创建账号',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 7),
              const Text(
                '注册完成后，可根据需要选择求职者或招聘者身份',
                style: TextStyle(
                  color: AtsColors.textMuted,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: '请输入手机号',
                  prefixIcon: Icon(Icons.phone_iphone, size: 20),
                  counterText: '',
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _code,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '请输入验证码',
                        prefixIcon: Icon(Icons.shield_outlined, size: 20),
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 104,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _countdown == 0 ? _sendCode : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AtsColors.primary,
                        side: const BorderSide(color: AtsColors.primary),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _countdown == 0 ? '获取验证码' : '${_countdown}s',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '请设置登录密码（至少 6 位）',
                  prefixIcon: Icon(Icons.lock_outline, size: 20),
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreed,
                      onChanged: (value) =>
                          setState(() => _agreed = value ?? false),
                      activeColor: AtsColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '我已阅读并同意'),
                          TextSpan(
                            text: '《用户协议》',
                            style: TextStyle(color: AtsColors.primary),
                          ),
                          TextSpan(text: '和'),
                          TextSpan(
                            text: '《隐私政策》',
                            style: TextStyle(color: AtsColors.primary),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: AtsColors.textMuted,
                        fontSize: 10,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          color: Colors.white,
          child: AtsPrimaryButton(label: '注册', onPressed: _register),
        ),
      ],
    );
  }
}
