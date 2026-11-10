part of 'profile_pages.dart';

class AtsConnectedPage extends StatelessWidget {
  const AtsConnectedPage({super.key, required this.controller});

  final AtsAppController controller;

  @override
  Widget build(BuildContext context) {
    final recruiter = controller.role == AtsUserRole.recruiter;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        AtsCard(
          color: AtsColors.mint,
          child: Row(
            children: [
              const Icon(
                Icons.visibility_outlined,
                color: AtsColors.primary,
                size: 28,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '本周有 12 位新访客',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AtsColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      recruiter ? '持续更新职位可吸引更多人才' : '完善简历可获得更多曝光',
                      style: const TextStyle(
                        color: AtsColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const AtsSectionHeader(title: '最近访客'),
        for (final resume in atsResumes)
          AtsCard(
            margin: const EdgeInsets.only(bottom: 9),
            onTap: () => controller.open(
              recruiter ? AtsRoute.resumeDetail : AtsRoute.privateChat,
            ),
            child: Row(
              children: [
                AtsAvatar(
                  label: resume.name,
                  size: 42,
                  color: resume.gender == '女'
                      ? const Color(0xFFEC6A88)
                      : AtsColors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resume.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${resume.intent} · ${resume.experience}',
                        style: const TextStyle(
                          color: AtsColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '刚刚浏览',
                  style: TextStyle(color: AtsColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
