part of 'misc_pages.dart';

class AtsLoginIndexPage extends StatelessWidget {
  const AtsLoginIndexPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    const benefits = [
      (Icons.bolt_outlined, '快速投递', '一键发送简历'),
      (Icons.notifications_active_outlined, '实时反馈', '进度及时提醒'),
      (Icons.security_outlined, '真实企业', '严格资质审核'),
      (Icons.support_agent, '专属客服', '全程贴心服务'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      children: [
        const Text(
          '找到更需要你的地方',
          style: TextStyle(
            color: AtsColors.text,
            fontSize: 25,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          '注册企业直聘，开启更好的职业旅程',
          style: TextStyle(color: AtsColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 28),
        Container(
          height: 148,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AtsColors.primary, Color(0xFF51CFAF)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -18,
                child: Icon(
                  Icons.rocket_launch_outlined,
                  size: 130,
                  color: Color(0x24FFFFFF),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '好机会，从这里开始',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '已有超过 120 万求职者加入',
                    style: TextStyle(color: Color(0xDFFFFFFF), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: benefits.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 116,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final item = benefits[index];
            return AtsCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.$1, color: AtsColors.primary, size: 27),
                  const SizedBox(height: 8),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$3,
                    style: const TextStyle(
                      color: AtsColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        AtsPrimaryButton(
          label: '立即注册',
          onPressed: () => controller.open(AtsRoute.register),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => controller.back(),
          child: const Text('已有账号，去登录'),
        ),
      ],
    );
  }
}
