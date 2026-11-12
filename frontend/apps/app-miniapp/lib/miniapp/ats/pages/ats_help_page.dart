part of 'misc_pages.dart';

class AtsHelpPage extends StatelessWidget {
  const AtsHelpPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    const groups = <String, List<String>>{
      '账号与登录': ['如何更换绑定手机号？', '忘记密码怎么办？', '如何切换求职/招聘身份？'],
      '简历与投递': ['如何提高简历曝光？', '投递后多久有反馈？', '如何撤回投递？'],
      '企业招聘': ['如何完成企业认证？', '职位审核需要多久？', '如何邀请候选人面试？'],
      '安全与隐私': ['如何屏蔽企业？', '收到收费信息怎么办？'],
    };
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          height: 104,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AtsColors.resolve(context, AtsColors.primary),
                Color(0xFF58D2B2),
              ],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '有什么可以帮你？',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '查看常见问题，或联系在线客服',
                      style: TextStyle(color: Color(0xD9FFFFFF), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.help_outline_rounded,
                size: 64,
                color: Color(0x35FFFFFF),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AtsCard(
          color: AtsColors.resolve(context, AtsColors.mint),
          onTap: () => controller.open(AtsRoute.robot),
          child: Row(
            children: [
              Icon(
                Icons.support_agent,
                color: AtsColors.resolve(context, AtsColors.primary),
                size: 26,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '在线客服',
                      style: TextStyle(
                        color: AtsColors.resolve(
                          context,
                          AtsColors.primaryDark,
                        ),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '智能客服 7×24 小时在线',
                      style: TextStyle(
                        color: AtsColors.resolve(context, AtsColors.primary),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AtsColors.resolve(context, AtsColors.primary),
                size: 20,
              ),
            ],
          ),
        ),
        for (final entry in groups.entries) ...[
          AtsSectionHeader(title: entry.key),
          AtsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < entry.value.length; i++)
                  AtsListRow(
                    icon: Icons.help_outline,
                    title: entry.value[i],
                    onTap: () => controller.open(AtsRoute.helpDetail),
                    showDivider: i != entry.value.length - 1,
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}
