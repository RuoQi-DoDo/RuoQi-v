part of 'misc_pages.dart';

class AtsBindPhonePage extends StatefulWidget {
  const AtsBindPhonePage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  State<AtsBindPhonePage> createState() => _AtsBindPhonePageState();
}

class _AtsBindPhonePageState extends State<AtsBindPhonePage> {
  final _phone = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 24),
      children: [
        Icon(
          Icons.shield_outlined,
          color: AtsColors.resolve(context, AtsColors.primary),
          size: 46,
        ),
        const SizedBox(height: 14),
        const Text(
          '手机号快捷登录',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '未注册的手机号验证后将自动创建账号',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AtsColors.resolve(context, AtsColors.textMuted),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 34),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          decoration: InputDecoration(
            hintText: '请输入手机号',
            prefixText: '+86  ',
            counterText: '',
            fillColor: AtsColors.resolve(context, AtsColors.surface),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '请输入验证码',
                  fillColor: AtsColors.resolve(context, AtsColors.surface),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () {
                  if (_phone.text.trim().length != 11) {
                    atsToast(context, '请输入 11 位手机号');
                    return;
                  }
                  atsToast(context, '验证码已发送');
                },
                child: const Text('获取验证码'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AtsPrimaryButton(
          label: '登录 / 注册',
          onPressed: () {
            widget.controller.login();
            atsToast(context, '登录成功');
          },
        ),
      ],
    );
  }
}
