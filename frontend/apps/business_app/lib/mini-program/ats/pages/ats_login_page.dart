part of 'misc_pages.dart';

class AtsLoginPage extends StatelessWidget {
  const AtsLoginPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF3FCF9)],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 44, 28, 24),
        children: [
          Center(
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AtsColors.primary, Color(0xFF5DD5B6)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AtsColors.primary.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: const Icon(
                Icons.work_outline_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '欢迎来到企业直聘',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AtsColors.text,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '登录后收藏职位、投递简历并与招聘方沟通',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AtsColors.textMuted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 44),
          AtsPrimaryButton(
            label: '微信一键登录',
            icon: Icons.chat_bubble_outline,
            onPressed: () {
              controller.login();
              atsToast(context, '登录成功');
            },
          ),
          const SizedBox(height: 12),
          AtsOutlineButton(
            label: '手机号验证码登录',
            icon: Icons.phone_iphone,
            onPressed: () => controller.open(AtsRoute.bindPhone),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(child: Divider(color: AtsColors.divider)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '还没有账号？',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider(color: AtsColors.divider)),
            ],
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => controller.open(AtsRoute.loginIndex),
            style: TextButton.styleFrom(foregroundColor: AtsColors.primary),
            child: const Text('立即注册'),
          ),
          const SizedBox(height: 34),
          const Text(
            '登录即代表你已阅读并同意',
            textAlign: TextAlign.center,
            style: TextStyle(color: AtsColors.textMuted, fontSize: 9),
          ),
          const SizedBox(height: 3),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '《用户协议》'),
                TextSpan(text: ' 和 '),
                TextSpan(text: '《隐私政策》'),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: AtsColors.primary, fontSize: 9),
          ),
          const SizedBox(height: 22),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AtsColors.textMuted,
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                '信息安全保护中',
                style: TextStyle(color: AtsColors.textMuted, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
