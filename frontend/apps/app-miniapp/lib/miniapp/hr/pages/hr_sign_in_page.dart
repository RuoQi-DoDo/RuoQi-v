part of 'service_pages.dart';

class HrSignInPage extends StatefulWidget {
  const HrSignInPage({super.key, required this.controller});

  final HrAppController controller;

  @override
  State<HrSignInPage> createState() => _HrSignInPageState();
}

class _HrSignInPageState extends State<HrSignInPage> {
  final _server = TextEditingController(text: 'hr.ruoqi.example');
  final _account = TextEditingController(text: 'zhixia.lin');
  final _password = TextEditingController(text: 'ruoqi-demo');
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _server.dispose();
    _account.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
      children: [
        const Center(child: HrLogoMark(size: 68)),
        const SizedBox(height: 18),
        Text(
          'RuoQi 人事',
          textAlign: TextAlign.center,
          style: HrText.resolve(
            context,
            HrText.appBarTitle,
          ).copyWith(fontSize: 27),
        ),
        const SizedBox(height: 6),
        Text(
          '员工自助 · 考勤 · 休假 · 薪酬',
          textAlign: TextAlign.center,
          style: HrText.resolve(context, HrText.meta),
        ),
        const SizedBox(height: 28),
        HrCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '连接 Horilla HR',
                style: HrText.resolve(context, HrText.cardTitle),
              ),
              const SizedBox(height: 4),
              Text(
                '演示环境已预填服务器与账号，真实接入时由 HR 管理员提供地址。',
                style: HrText.resolve(context, HrText.meta),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _server,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: '服务器地址',
                  hintText: 'hr.company.com',
                  prefixIcon: Icon(Icons.dns_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: _account,
                decoration: const InputDecoration(
                  labelText: '账号',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    tooltip: _obscure ? '显示密码' : '隐藏密码',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              HrPrimaryButton(
                label: _loading ? '正在进入…' : '进入人事工作台',
                icon: Icons.login_rounded,
                onPressed: _loading ? null : _signIn,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        HrCard(
          background: HrColors.resolve(context, HrColors.infoBg),
          borderColor: const Color(0xFFC9DBEA),
          shadow: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: HrColors.resolve(context, HrColors.info),
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '当前为静态登录页，不会发送真实密码。关闭模拟数据后，请通过注入的 RuoQiNetworkClient 完成鉴权。',
                  style: HrText.resolve(
                    context,
                    HrText.meta,
                  ).copyWith(color: HrColors.resolve(context, HrColors.info)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '登录即表示同意企业隐私政策与信息安全规范',
          textAlign: TextAlign.center,
          style: HrText.resolve(context, HrText.meta).copyWith(
            color: HrColors.resolve(context, HrColors.ink4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Future<void> _signIn() async {
    if (_server.text.trim().isEmpty ||
        _account.text.trim().isEmpty ||
        _password.text.isEmpty) {
      hrToast(context, '请填写服务器地址、账号和密码');
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      return;
    }
    widget.controller.completeSignIn();
    hrToast(context, '已进入 ${widget.controller.user.name} 的人事工作台');
  }
}
