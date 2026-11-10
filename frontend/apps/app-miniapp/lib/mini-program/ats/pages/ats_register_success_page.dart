part of 'misc_pages.dart';

class AtsRegisterSuccessPage extends StatelessWidget {
  const AtsRegisterSuccessPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AtsColors.mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AtsColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '注册成功',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 9),
            const Text(
              '欢迎加入企业直聘。现在可以完善简历，\n让合适的机会更快找到你。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AtsColors.textSecondary,
                fontSize: 12,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              child: AtsPrimaryButton(
                label: '进入首页',
                onPressed: () {
                  controller.login();
                  atsToast(context, '欢迎来到企业直聘');
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 220,
              child: TextButton(
                onPressed: () {
                  controller.login();
                  controller.open(AtsRoute.resume);
                },
                child: const Text('去完善简历'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
