part of 'misc_pages.dart';

class AtsHelpDetailPage extends StatelessWidget {
  const AtsHelpDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        AtsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '如何提高简历曝光？',
                style: TextStyle(
                  fontSize: 20,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '更新于 2026-11-01 · 约 2 分钟阅读',
                style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 18),
              const Text(
                '一份完整、真实的简历更容易获得招聘方关注。建议你从以下方面完善：',
                style: TextStyle(
                  color: AtsColors.textSecondary,
                  fontSize: 13,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 14),
              for (final item in const [
                ('补全基本信息', '填写年龄、学历、工作经验和求职状态。'),
                ('明确求职期望', '选择与经历匹配的岗位、行业和薪资范围。'),
                ('突出工作成果', '用数字说明你完成了什么、带来了什么变化。'),
                ('保持活跃', '定期更新求职状态，并在工作日及时回复消息。'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AtsColors.mint,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.check,
                          color: AtsColors.primary,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.$2,
                              style: const TextStyle(
                                color: AtsColors.textSecondary,
                                fontSize: 12,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              AtsPrimaryButton(
                label: '去完善简历',
                onPressed: () => atsToast(context, '请从「我的 - 我的简历」进入'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
